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
var workforce_system := WorkforceSystem.new()
var trait_system := TraitSystem.new()
var bloodline_system := BloodlineSystem.new()
var economy_system := EconomySystem.new()
var combat_system := CombatSystem.new()
var building_system := BuildingSystem.new()
var v63_learning_system := V63LearningSystem.new()
var v63_preview_overrides: Dictionary = {}
var recruitment_system := RecruitmentSystem.new()
var performance_logging_enabled := false
var performance_stage_usec: Dictionary = {}

func _init(simulation_state: SimulationState) -> void:
    state = simulation_state
    rng = GameRng.new(state.seed)
    performance_logging_enabled = OS.get_environment("TMB_PVE_PERF_LOG") == "1"
    if state.rng_state != 0:
        rng.restore_seed_state(state.rng_state)

func step() -> void:
    if performance_logging_enabled:
        performance_stage_usec.clear()
        workforce_system.performance_stage_usec.clear()
    var step_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    var phase_usec := 0
    var building_usec := 0
    var recruitment_usec := 0
    var needs_usec := 0
    var disciple_usec := 0
    var reveal_usec := 0
    var action_counts: Dictionary = {}
    var action_usec: Dictionary = {}
    state.tick += 1
    if state.p3_7_buildings_enabled:
        phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
        building_system.process_tick(state)
        if performance_logging_enabled:
            building_usec = Time.get_ticks_usec()-phase_usec
    if not state.sect.v63_learning_active_jobs.is_empty():
        v63_learning_system.process_tick(state, v63_preview_overrides)
    if state.sect.guidance_recruitment_enabled:
        phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
        recruitment_system.process_guidance_tick(state)
        if performance_logging_enabled:
            recruitment_usec = Time.get_ticks_usec()-phase_usec
    if state.sect.needs_enabled:
        phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
        needs_system.process_logistics_tick(state)
        if performance_logging_enabled:
            needs_usec = Time.get_ticks_usec()-phase_usec

    # P1.5 introduces same-tick dependencies on teammates/leaders. Dictionary
    # iteration order is not a valid simulation contract across save/load, so
    # organization-enabled states use a canonical disciple order. Earlier
    # locked P0-P1.4 paths retain their original iteration behavior exactly.
    if state.p1_organization_enabled:
        var disciple_ids: Array = state.disciples.keys()
        disciple_ids.sort()
        for raw_id in disciple_ids:
            var disciple: DiscipleState = state.disciples[raw_id]
            var action_key := str(disciple.current_action) if performance_logging_enabled else ""
            phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
            _step_disciple(disciple)
            if performance_logging_enabled:
                var elapsed_usec := Time.get_ticks_usec()-phase_usec
                disciple_usec += elapsed_usec
                action_counts[action_key] = int(action_counts.get(action_key,0))+1
                action_usec[action_key] = int(action_usec.get(action_key,0))+elapsed_usec
            disciple.metrics["actions"] = int(disciple.metrics.get("actions", 0)) + 1
            if state.sect.disciple_traits_enabled:
                phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
                trait_system.process_reveals(state, disciple)
                if performance_logging_enabled:
                    reveal_usec += Time.get_ticks_usec()-phase_usec
            if state.sect.bloodlines_enabled:
                phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
                bloodline_system.process_reveal(state, disciple)
                if performance_logging_enabled:
                    reveal_usec += Time.get_ticks_usec()-phase_usec
    else:
        for disciple in state.disciples.values():
            var action_key := str(disciple.current_action) if performance_logging_enabled else ""
            phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
            _step_disciple(disciple)
            if performance_logging_enabled:
                var elapsed_usec := Time.get_ticks_usec()-phase_usec
                disciple_usec += elapsed_usec
                action_counts[action_key] = int(action_counts.get(action_key,0))+1
                action_usec[action_key] = int(action_usec.get(action_key,0))+elapsed_usec
            disciple.metrics["actions"] = int(disciple.metrics.get("actions", 0)) + 1
            if state.sect.disciple_traits_enabled:
                phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
                trait_system.process_reveals(state, disciple)
                if performance_logging_enabled:
                    reveal_usec += Time.get_ticks_usec()-phase_usec
            if state.sect.bloodlines_enabled:
                phase_usec = Time.get_ticks_usec() if performance_logging_enabled else 0
                bloodline_system.process_reveal(state, disciple)
                if performance_logging_enabled:
                    reveal_usec += Time.get_ticks_usec()-phase_usec

    state.rng_state = rng.snapshot_seed_state()
    if performance_logging_enabled:
        print("TMB_SCHEDULER_STEP_METRIC "+JSON.stringify({
            "tick":state.tick,
            "total_usec":Time.get_ticks_usec()-step_started_usec,
            "building_usec":building_usec,
            "recruitment_usec":recruitment_usec,
            "needs_usec":needs_usec,
            "disciple_usec":disciple_usec,
            "reveal_usec":reveal_usec,
            "disciples":state.disciples.size(),
            "buildings":state.buildings.size(),
            "actions":action_counts,
            "action_usec":action_usec,
            "stage_usec":performance_stage_usec.duplicate(),
            "workforce_stage_usec":workforce_system.performance_stage_usec.duplicate()
        }))

func run_ticks(count: int) -> void:
    for _i in range(count):
        step()

func _record_performance_stage(stage: String,started_usec: int) -> void:
    if started_usec <= 0:
        return
    performance_stage_usec[stage] = int(performance_stage_usec.get(stage,0)) + (Time.get_ticks_usec()-started_usec)

func _step_disciple(disciple: DiscipleState) -> void:
    # One scheduler step is one simulation minute. Authentic V2 disciples
    # continuously absorb natural Tu Vi during ordinary life/activity.
    # CULTIVATE is Chuyên Tu: it accelerates this same source for the minute.
    if DiscipleRealmProgressV2.owns_v2_progression(disciple) and state.sect.v2_training_enabled:
        var tuvi_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
        var passive_tuvi := DiscipleTuViFlowV2.resolve_minute(
            state,disciple,disciple.current_action == &"CULTIVATE"
        )
        if performance_logging_enabled:
            _record_performance_stage("v2_passive_tuvi",tuvi_started_usec)
        disciple.last_decision["v2_passive_tuvi_result"] = passive_tuvi.duplicate(true)

    # Natural V2 Tu Vi above still accrues once per minute on expeditions.
    # All competing work/legacy combat actions are suspended until settlement.
    if not disciple.active_pve_encounter_id.is_empty():
        return
    if disciple.injury_level == 1 and disciple.region_id == &"sect" and disciple.injury_recover_at_tick > 0 and state.tick >= disciple.injury_recover_at_tick:
        disciple.injury_level = 0
        disciple.injury_recover_at_tick = 0
    # Study occupies the same disciple job slot as production and hunting.
    # Its time is advanced once by process_tick above; no second action may run.
    if not disciple.v63_study_job.is_empty():
        return
    if state.sect.economy_a_enabled and disciple.current_action == &"EVALUATE":
        economy_system.auto_personal_service_tick(state,disciple)
    match disciple.current_action:
        &"IDLE":
            disciple.current_action = &"EVALUATE"

        &"EVALUATE":
            if state.sect.techniques_enabled and disciple.region_id == &"sect":
                var technique_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
                technique_system.deposit_special_inventory(state, disciple)
                if performance_logging_enabled:
                    _record_performance_stage("evaluate_technique_deposit",technique_started_usec)
            if state.sect.equipment_enabled and disciple.region_id == &"sect":
                var equipment_deposit_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
                equipment_system.deposit_forge_inventory(state, disciple)
                if performance_logging_enabled:
                    _record_performance_stage("evaluate_equipment_deposit",equipment_deposit_started_usec)
                var equipment_upgrade_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
                equipment_system.try_auto_upgrade(state, disciple)
                if performance_logging_enabled:
                    _record_performance_stage("evaluate_equipment_upgrade",equipment_upgrade_started_usec)
            if state.p1_goal_personality_enabled:
                var goal_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
                goal_system.update_goal(state, disciple)
                if performance_logging_enabled:
                    _record_performance_stage("evaluate_goal",goal_started_usec)
            if state.sect.workforce_enabled:
                var workforce_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
                var workforce_action := workforce_system.next_action(state, disciple)
                if performance_logging_enabled:
                    _record_performance_stage("evaluate_workforce",workforce_started_usec)
                if workforce_action != &"":
                    disciple.last_decision["workforce_action"] = str(workforce_action)
                    disciple.current_action = workforce_action
                    return
                # O4: an active Spirit Field plot reserves its worker until
                # harvest. Do not fall through to generic AI (hunt/rest/etc.)
                # while the canonical plot still owns this disciple.
                if (
                    state.p3_7_buildings_enabled
                    and building_system.disciple_has_active_spirit_plot(state, disciple.id)
                ):
                    disciple.last_decision["workforce_action"] = "FIELD_RESERVED"
                    disciple.current_action = &"IDLE"
                    return
            var decision_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
            var decision := decision_system.evaluate(state, disciple)
            if performance_logging_enabled:
                _record_performance_stage("evaluate_decision",decision_started_usec)
            disciple.current_action = StringName(decision["action"])
            if disciple.injury_level == 1 and DiscipleRealmProgressV2.owns_v2_progression(disciple) and disciple.current_action == &"HUNT":
                disciple.current_action = &"HOLD"

        &"HUNT":
            if disciple.injury_level == 1 and DiscipleRealmProgressV2.owns_v2_progression(disciple):
                disciple.current_action = &"HOLD" if disciple.region_id == &"sect" else &"RETURN_SECT"
                return
            if disciple.region_id == &"sect":
                var direct_region := &""
                if state.sect.workforce_enabled and workforce_system.command_kind(disciple) == WorkforceSystem.COMMAND_HUNT_REGION:
                    direct_region = workforce_system.command_target(disciple)
                if direct_region != &"" and state.regions.has(direct_region):
                    disciple.target_region_id = direct_region
                else:
                    disciple.target_region_id = decision_system.choose_region(state, disciple)
                if state.sect.needs_enabled:
                    needs_system.prepare_departure(state, disciple)
                disciple.current_action = &"TRAVEL"
            else:
                disciple.current_action = &"COMBAT"

        &"TRAVEL":
            if disciple.injury_level == 1 and DiscipleRealmProgressV2.owns_v2_progression(disciple):
                disciple.current_action = &"RETURN_SECT"
                return
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
            if disciple.injury_level == 1 and DiscipleRealmProgressV2.owns_v2_progression(disciple):
                disciple.current_action = &"RETURN_SECT"
                return
            var result := combat_system.resolve_encounter(state, disciple, rng)
            disciple.stamina = maxf(0.0, disciple.stamina - 10.0)
            var outcome := str(result.get("outcome", "invalid"))
            if state.p1_relationships_enabled:
                relationship_system.record_local_combat_outcome(state, disciple, outcome)
            if state.p1_memory_enabled:
                memory_system.record_combat_outcome(state, disciple, outcome)
            if state.sect.cultivation_enabled and outcome == "win" and not DiscipleRealmProgressV2.owns_v2_progression(disciple):
                cultivation_system.add_combat_win_progress(state, disciple)
            if state.sect.cultivation_paths_enabled and outcome in ["win", "retreat", "defeat"]:
                var path_gain := 0.0
                if state.sect.combat_skills_enabled:
                    path_gain = combat_skill_system.record_combat_path_experience(state, disciple, result, outcome)
                else:
                    path_gain = cultivation_path_system.record_combat(state, disciple, outcome)
                if path_gain > 0.0:
                    disciple.metrics["path_combat_events"] = int(disciple.metrics.get("path_combat_events", 0)) + 1
            if state.sect.workforce_enabled:
                workforce_system.notify_action_completed(state, disciple, &"COMBAT")
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
            if state.sect.workforce_enabled:
                workforce_system.notify_action_completed(state, disciple, &"RETURN_SECT")
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
            var owns_v2 := DiscipleRealmProgressV2.owns_v2_progression(disciple)
            if state.sect.needs_enabled:
                needs_system.apply_rest(state, disciple, not owns_v2)
            else:
                if not owns_v2:
                    disciple.stamina = minf(100.0, disciple.stamina + 48.0)
                disciple.hp = minf(disciple.max_hp, disciple.hp + 5.0)
                disciple.metrics["rests"] = int(disciple.metrics.get("rests", 0)) + 1
            if state.sect.workforce_enabled:
                workforce_system.notify_action_completed(state, disciple, &"REST")
            disciple.current_action = &"EVALUATE"

        &"CULTIVATE":
            if DiscipleRealmProgressV2.owns_v2_progression(disciple):
                # V2 Chuyên Tu never creates a second EXP grant. The minute's
                # natural Tu Vi was already resolved above with specialized=true.
                var v2_gain: Dictionary = disciple.last_decision.get(
                    "v2_passive_tuvi_result",
                    {"ok":false,"reason":"v2_passive_tuvi_not_resolved"}
                )
                disciple.last_decision["v2_training_result"] = v2_gain.duplicate(true)
            else:
                var gained := cultivation_system.cultivate(state, disciple)
                if gained > 0.0 and state.sect.techniques_enabled:
                    technique_system.train_active_technique(state, disciple)
                if gained > 0.0 and state.sect.cultivation_paths_enabled:
                    if cultivation_path_system.record_cultivation(state, disciple) > 0.0:
                        disciple.metrics["path_cultivation_events"] = int(disciple.metrics.get("path_cultivation_events", 0)) + 1
            if state.sect.workforce_enabled:
                workforce_system.notify_action_completed(state, disciple, &"CULTIVATE")
            disciple.current_action = &"EVALUATE"

        &"TRAIN_BODY":
            if DiscipleRealmProgressV2.owns_v2_progression(disciple):
                # Real paid facility minute; economic cost committed before EXP.
                disciple.last_decision["v2_body_training_result"] = (
                    DiscipleTrainingActionV2.resolve(state,disciple,"TRAIN_BODY")
                )
            if state.sect.workforce_enabled:
                workforce_system.notify_action_completed(state, disciple, &"TRAIN_BODY")
            disciple.current_action = &"EVALUATE"

        &"WORK_MINING":
            workforce_system.perform_work(state, disciple, WorkforceSystem.PROF_MINING)
            disciple.current_action = &"EVALUATE"

        &"WORK_FORGING":
            workforce_system.perform_work(state, disciple, WorkforceSystem.PROF_FORGING)
            disciple.current_action = &"EVALUATE"

        &"WORK_HERBALISM":
            workforce_system.perform_work(state, disciple, WorkforceSystem.PROF_HERBALISM)
            disciple.current_action = &"EVALUATE"

        &"WORK_FORESTRY":
            workforce_system.perform_work(state, disciple, WorkforceSystem.PROF_FORESTRY)
            disciple.current_action = &"EVALUATE"

        &"WORK_ALCHEMY":
            workforce_system.perform_work(state, disciple, WorkforceSystem.PROF_ALCHEMY)
            disciple.current_action = &"EVALUATE"

        &"HOLD":
            if not DiscipleRealmProgressV2.owns_v2_progression(disciple):
                disciple.stamina = minf(100.0, disciple.stamina + 2.0)
            disciple.current_action = &"EVALUATE"

        &"BREAKTHROUGH":
            if DiscipleRealmProgressV2.owns_v2_progression(disciple):
                disciple.last_decision["v2_breakthrough_result"] = {
                    "ok":false,"reason":"v2_breakthrough_content_not_authorized"
                }
            else:
                cultivation_system.attempt_breakthrough(state, disciple, rng)
            disciple.current_action = &"EVALUATE"

        _:
            disciple.current_action = &"IDLE"

