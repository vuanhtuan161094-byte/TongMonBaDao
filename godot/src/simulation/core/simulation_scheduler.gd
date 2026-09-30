class_name SimulationScheduler
extends RefCounted

var state: SimulationState
var rng: GameRng
var goal_system := GoalSystem.new()
var decision_system := DecisionSystem.new()
var relationship_system := RelationshipSystem.new()
var economy_system := EconomySystem.new()
var combat_system := CombatSystem.new()

func _init(simulation_state: SimulationState) -> void:
    state = simulation_state
    rng = GameRng.new(state.seed)
    if state.rng_state != 0:
        rng.restore_seed_state(state.rng_state)

func step() -> void:
    state.tick += 1

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
            if state.p1_goal_personality_enabled:
                goal_system.update_goal(state, disciple)
            var decision := decision_system.evaluate(state, disciple)
            disciple.current_action = StringName(decision["action"])

        &"HUNT":
            if disciple.region_id == &"sect":
                disciple.target_region_id = decision_system.choose_region(state, disciple)
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
                disciple.stamina = maxf(0.0, disciple.stamina - 8.0)
                disciple.current_action = &"COMBAT"
            else:
                disciple.target_region_id = &""
                disciple.current_action = &"EVALUATE"

        &"COMBAT":
            var result := combat_system.resolve_encounter(state, disciple, rng)
            disciple.stamina = maxf(0.0, disciple.stamina - 10.0)
            var outcome := str(result.get("outcome", "invalid"))
            if state.p1_relationships_enabled:
                relationship_system.record_local_combat_outcome(state, disciple, outcome)
            match outcome:
                "win":
                    disciple.pending_loot = result.get("loot", {}).duplicate(true)
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
            disciple.current_action = &"EVALUATE"

        &"SELL":
            var earned := economy_system.sell_inventory(state, disciple)
            # If the sect market is temporarily out of spendable treasury,
            # do not spin forever between EVALUATE and SELL.
            disciple.current_action = &"EVALUATE" if earned > 0 else &"HUNT"

        &"BUY":
            economy_system.buy_supplies(state, disciple)
            disciple.current_action = &"EVALUATE"

        &"HEAL":
            if not economy_system.heal(state, disciple):
                disciple.current_action = &"REST"
            else:
                disciple.current_action = &"EVALUATE"

        &"REST":
            disciple.stamina = minf(100.0, disciple.stamina + 48.0)
            disciple.hp = minf(disciple.max_hp, disciple.hp + 5.0)
            disciple.metrics["rests"] = int(disciple.metrics.get("rests", 0)) + 1
            disciple.current_action = &"EVALUATE"

        _:
            disciple.current_action = &"IDLE"
