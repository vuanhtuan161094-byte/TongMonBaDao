class_name SimulationScheduler
extends RefCounted

var state: SimulationState
var rng: GameRng
var goal_system := GoalSystem.new()
var decision_system := DecisionSystem.new()
var relationship_system := RelationshipSystem.new()
var memory_system := MemorySystem.new()
var needs_system := NeedsSystem.new()
var cultivation_system := CultivationSystem.new()
var technique_system := TechniqueSystem.new()
var cultivation_path_system := CultivationPathSystem.new()
var combat_skill_system := CombatSkillSystem.new()
var equipment_system := EquipmentSystem.new()
var economy_system := EconomySystem.new()
var combat_system := CombatSystem.new()

func _init(simulation_state: SimulationState) -> void:
    state = simulation_state
    rng = GameRng.new(state.seed)
    if state.rng_state != 0:
        rng.restore_seed_state(state.rng_state)

func step() -> void:
    state.tick += 1
    if state.sect.needs_enabled:
        needs_system.process_logistics_tick(state)

    # P1.5 introduces same-tick dependencies on teammates/leaders. Dictionary
    # iteration order is not a valid simulation contract across save/load, so
    # organization-enabled states use a canonical disciple order. Earlier
    # locked P0-P1.4 paths retain their original iteration behavior exactly.
    if state.p1_organization_enabled:
        var disciple_ids: Array = state.disciples.keys()
        disciple_ids.sort()
        for raw_id in disciple_ids:
            var disciple: DiscipleState = state.disciples[raw_id]
            _step_disciple(disciple)
            disciple.metrics["actions"] = int(disciple.metrics.get("actions", 0)) + 1
    else:
        for disciple in state.disciples.values():
            _step_disciple(disciple)
            disciple.metrics["actions"] = int(disciple.metrics.get("actions", 0)) + 1

    state.rng_state = rng.snapshot_seed_state()

func run_ticks(count: int) -> void:
    for _i in range(count):
        step()

func _step_disciple(disciple: DiscipleState) -> void:
    match disciple.current_action:
        &"IDLE":
            disciple.current_action = &"EVALUATE"

        &"EVALUATE":
            if state.sect.techniques_enabled and disciple.region_id == &"sect":
                technique_system.deposit_special_inventory(state, disciple)
            if state.sect.equipment_enabled and disciple.region_id == &"sect":
                equipment_system.deposit_forge_inventory(state, disciple)
                equipment_system.try_auto_upgrade(state, disciple)
            if state.p1_goal_personality_enabled:
                goal_system.update_goal(state, disciple)
            var decision := decision_system.evaluate(state, disciple)
            disciple.current_action = StringName(decision["action"])

        &"HUNT":
            if disciple.region_id == &"sect":
                disciple.target_region_id = decision_system.choose_region(state, disciple)
                if state.sect.needs_enabled:
                    needs_system.prepare_departure(state, disciple)
                disciple.current_action = &"TRAVEL"
            else:
                disciple.current_action = &"COMBAT"

        &"TRAVEL":
            if state.regions.has(disciple.target_region_id):
                disciple.region_id = disciple.target_region_id
                var region: RegionState = state.regions[disciple.region_id]
                if region.danger >= 3:
                    disciple.metrics["danger_visits"] = int(disciple.metrics.get("danger_visits", 0)) + 1
                elif region.danger == 2:
                    disciple.metrics["medium_visits"] = int(disciple.metrics.get("medium_visits", 0)) + 1
                else:
                    disciple.metrics["safe_visits"] = int(disciple.metrics.get("safe_visits", 0)) + 1
                var travel_cost := needs_system.consume_travel_stamina_cost(state, disciple) if state.sect.needs_enabled else 8.0
                disciple.stamina = maxf(0.0, disciple.stamina - travel_cost)
                disciple.current_action = &"COMBAT"
            else:
                disciple.target_region_id = &""
                disciple.metrics.erase("p1_6_departure_supplied")
                disciple.current_action = &"EVALUATE"

        &"COMBAT":
            var base_combat_power := disciple.combat_power
            if state.sect.equipment_enabled:
                disciple.combat_power = base_combat_power + equipment_system.combat_power_bonus(state, disciple)
            var result := combat_system.resolve_encounter(state, disciple, rng)
            disciple.combat_power = base_combat_power
            disciple.stamina = maxf(0.0, disciple.stamina - 10.0)
            var outcome := str(result.get("outcome", "invalid"))
            if state.p1_relationships_enabled:
                relationship_system.record_local_combat_outcome(state, disciple, outcome)
            if state.p1_memory_enabled:
                memory_system.record_combat_outcome(state, disciple, outcome)
            if state.sect.cultivation_enabled and outcome == "win":
                cultivation_system.add_combat_win_progress(state, disciple)
            if state.sect.cultivation_paths_enabled and outcome in ["win", "retreat", "defeat"]:
                var path_gain := 0.0
                if state.sect.combat_skills_enabled:
                    path_gain = combat_skill_system.record_combat_path_experience(state, disciple, result, outcome)
                else:
                    path_gain = cultivation_path_system.record_combat(state, disciple, outcome)
                if path_gain > 0.0:
                    disciple.metrics["path_combat_events"] = int(disciple.metrics.get("path_combat_events", 0)) + 1
            match outcome:
                "win":
                    var loot: Dictionary = result.get("loot", {}).duplicate(true)
                    if state.sect.techniques_enabled:
                        var special_loot := technique_system.roll_farm_loot(state, disciple)
                        for item_id in special_loot.keys():
                            loot[str(item_id)] = int(loot.get(str(item_id), 0)) + int(special_loot[item_id])
                    if state.sect.equipment_enabled:
                        var forge_loot := equipment_system.forge_loot_for_victory(state, result)
                        for material_id in forge_loot.keys():
                            loot[str(material_id)] = int(loot.get(str(material_id), 0)) + int(forge_loot[material_id])
                    disciple.pending_loot = loot
                    disciple.current_action = &"LOOT"
                "retreat", "defeat":
                    disciple.current_action = &"RETURN_SECT"
                _:
                    disciple.current_action = &"EVALUATE"

        &"LOOT":
            for item_key in disciple.pending_loot.keys():
                disciple.add_item(str(item_key), int(disciple.pending_loot[item_key]))
            disciple.pending_loot.clear()
            disciple.current_action = &"EVALUATE"

        &"RETURN_SECT":
            disciple.region_id = &"sect"
            disciple.target_region_id = &""
            if state.sect.techniques_enabled:
                technique_system.deposit_special_inventory(state, disciple)
            if state.sect.equipment_enabled:
                equipment_system.deposit_forge_inventory(state, disciple)
            disciple.current_action = &"EVALUATE"

        &"SELL":
            if state.sect.techniques_enabled:
                technique_system.deposit_special_inventory(state, disciple)
            if state.sect.equipment_enabled:
                equipment_system.deposit_forge_inventory(state, disciple)
            var earned := economy_system.sell_inventory(state, disciple)
            disciple.current_action = &"EVALUATE" if earned > 0 else &"HUNT"

        &"BUY":
            economy_system.buy_supplies(state, disciple)
            disciple.current_action = &"EVALUATE"

        &"HEAL":
            var healed := needs_system.heal_with_medicine(state, disciple, economy_system) if state.sect.needs_enabled else economy_system.heal(state, disciple)
            disciple.current_action = &"EVALUATE" if healed else &"REST"

        &"REST":
            if state.sect.needs_enabled:
                needs_system.apply_rest(state, disciple)
            else:
                disciple.stamina = minf(100.0, disciple.stamina + 48.0)
                disciple.hp = minf(disciple.max_hp, disciple.hp + 5.0)
                disciple.metrics["rests"] = int(disciple.metrics.get("rests", 0)) + 1
            disciple.current_action = &"EVALUATE"

        &"CULTIVATE":
            var gained := cultivation_system.cultivate(state, disciple)
            if gained > 0.0 and state.sect.techniques_enabled:
                technique_system.train_active_technique(state, disciple)
            if gained > 0.0 and state.sect.cultivation_paths_enabled:
                if cultivation_path_system.record_cultivation(state, disciple) > 0.0:
                    disciple.metrics["path_cultivation_events"] = int(disciple.metrics.get("path_cultivation_events", 0)) + 1
            disciple.current_action = &"EVALUATE"

        &"BREAKTHROUGH":
            cultivation_system.attempt_breakthrough(state, disciple, rng)
            disciple.current_action = &"EVALUATE"

        _:
            disciple.current_action = &"IDLE"
