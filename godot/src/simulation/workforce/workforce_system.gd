class_name WorkforceSystem
extends RefCounted

const PROF_FORGING := &"forging"
const PROF_ALCHEMY := &"alchemy"
const PROF_HERBALISM := &"herbalism"
const PROF_MINING := &"mining"
const PROF_FORESTRY := &"forestry"
const PROF_LOGISTICS := &"logistics"
const VALID_PROFESSIONS := [PROF_FORGING, PROF_ALCHEMY, PROF_HERBALISM, PROF_MINING, PROF_FORESTRY, PROF_LOGISTICS]

const COMMAND_WORK := &"WORK_PROFESSION"
const COMMAND_CULTIVATE := &"CULTIVATE"
const COMMAND_HUNT_REGION := &"HUNT_REGION"
const COMMAND_RETURN_SECT := &"RETURN_SECT"
const COMMAND_REST := &"REST"
const COMMAND_HOLD := &"HOLD_AT_SECT"
const VALID_COMMANDS := [COMMAND_WORK, COMMAND_CULTIVATE, COMMAND_HUNT_REGION, COMMAND_RETURN_SECT, COMMAND_REST, COMMAND_HOLD]

const POLICY_BALANCED := &"balanced"
const POLICY_PRODUCTION := &"production_push"
const POLICY_CULTIVATION := &"cultivation_focus"
const VALID_POLICIES := [POLICY_BALANCED, POLICY_PRODUCTION, POLICY_CULTIVATION]

const SCHEDULE_CYCLE := 20
const BASE_WORK_XP := 10.0
const MINING_DURATION := 4.0
const FORGING_DURATION := 5.0
const P3_7_XP_LEVEL_SCALE := 24.0
const ACTIVE_WORK_HOURS_PER_STEP := 1.0 / 60.0

const TRAIT_FORGE := "forge_talent"
const TRAIT_MINER := "miner_instinct"
const TRAIT_HERBALIST := "herbalist_affinity"
const TRAIT_DILIGENT := "diligent"
const TRAIT_LAZY := "lazy"
const PROFESSION_TRAITS := [TRAIT_FORGE, TRAIT_MINER, TRAIT_HERBALIST, TRAIT_DILIGENT, TRAIT_LAZY]

var trait_system := TraitSystem.new()
var building_system := BuildingSystem.new()
var profession_modifiers := ProfessionModifierSystem.new()
var cultivation_system := CultivationSystem.new()

func initialize(state: SimulationState) -> void:
    if not state.sect.equipment_enabled:
        return
    state.sect.workforce_enabled = true
    if not VALID_POLICIES.has(state.sect.work_policy):
        state.sect.work_policy = POLICY_BALANCED
    if state.sect.work_groups.is_empty():
        state.sect.work_groups = {
            "mining_crew": {"name":"Đội Khai Khoáng", "priorities":{"mining":3}},
            "forge_hall": {"name":"Luyện Khí Đường", "priorities":{"forging":3}}
        }

    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple: DiscipleState = state.disciples[ids[index]]
        ensure_disciple_profile(state, disciple)
        if disciple.work_group_id == &"":
            if index < 2:
                disciple.work_group_id = &"mining_crew"
            elif index < 4:
                disciple.work_group_id = &"forge_hall"

    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for candidate_id in candidate_ids:
        ensure_candidate_profile(state, state.recruitment_candidates[candidate_id])

func ensure_disciple_profile(state: SimulationState, disciple: DiscipleState) -> void:
    if disciple.foundation_model_version < FoundationSystem.MODEL_OPEN_POINTS and disciple.comprehension <= 0.0:
        var rng := GameRng.new(_profile_seed(state.seed, str(disciple.id), 1709))
        disciple.comprehension = rng.randf_range(0.35, 0.95)
    if disciple.sect_rank == &"":
        disciple.sect_rank = &"outer"
    if disciple.profession_traits.is_empty():
        disciple.profession_traits = _roll_traits(state.seed, str(disciple.id))

func ensure_candidate_profile(state: SimulationState, candidate: CandidateState) -> void:
    if candidate.foundation_model_version < FoundationSystem.MODEL_OPEN_POINTS and candidate.comprehension <= 0.0:
        var rng := GameRng.new(_profile_seed(state.seed, str(candidate.id), 2713))
        candidate.comprehension = rng.randf_range(0.35, 0.95)
    if candidate.profession_traits.is_empty():
        candidate.profession_traits = _roll_traits(state.seed, str(candidate.id))

func ensure_p3_7_disciple_profile(state: SimulationState, disciple: DiscipleState) -> void:
    ensure_disciple_profile(state, disciple)
    _ensure_profession_trait_grades(disciple.profession_traits, disciple.profession_trait_grades)
    _roll_p3_7_profession_talent_if_needed(state, disciple)

func ensure_p3_7_candidate_profile(state: SimulationState, candidate: CandidateState) -> void:
    ensure_candidate_profile(state, candidate)
    _ensure_profession_trait_grades(candidate.profession_traits, candidate.profession_trait_grades)
    _roll_p3_7_candidate_talent_if_needed(state, candidate)

func set_work_policy(state: SimulationState, policy: StringName) -> bool:
    if not state.sect.workforce_enabled or not VALID_POLICIES.has(policy):
        return false
    state.sect.work_policy = policy
    state.sect.workforce_event_count += 1
    return true

func assign_group(state: SimulationState, disciple_id: StringName, group_id: StringName) -> bool:
    if not state.sect.workforce_enabled or not state.disciples.has(disciple_id):
        return false
    if group_id != &"" and not state.sect.work_groups.has(str(group_id)):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not disciple.active_pve_encounter_id.is_empty():
        return false
    # Explicitly assigning a different crew frees the real Body facility slot;
    # a returned position may be immediately reused by another disciple.
    if group_id != disciple.work_group_id and DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        var released := DiscipleBodyTrainingFacilityV2.release_slot(state,disciple_id)
        if not bool(released.get("ok",false)):
            return false
    if (
        state.p3_7_buildings_enabled
        and building_system.disciple_has_active_timed_recipe(state, disciple.id)
        and group_id != building_system.worker_group_for_profession(PROF_ALCHEMY)
    ):
        return false
    if state.p3_7_buildings_enabled and not disciple.work_cycle_state.is_empty():
        var cycle_profession := StringName(disciple.work_cycle_state.get("profession_id", disciple.work_cycle_state.get("profession", "")))
        var expected_group := building_system.worker_group_for_profession(cycle_profession)
        if expected_group != &"" and group_id != expected_group:
            building_system.cancel_work_cycle(state, disciple, true)

    # O3: leaving the crew that owns an explicit profession command must cancel
    # that command immediately. Otherwise the actor can loop WORK_* against a
    # missing building slot until TTL expires after the real work cycle is gone.
    if command_kind(disciple) == COMMAND_WORK:
        var commanded_profession := command_target(disciple)
        var commanded_group := building_system.worker_group_for_profession(commanded_profession)
        if commanded_group != &"" and group_id != commanded_group:
            clear_command(state, disciple)

    disciple.work_group_id = group_id
    if disciple.worksite_building_id != &"":
        var assigned = state.buildings.get(str(disciple.worksite_building_id))
        if not (assigned is BuildingState) or assigned.worker_group_id != group_id:
            disciple.worksite_building_id = &""
    state.sect.workforce_event_count += 1
    return true

func assign_worksite(state: SimulationState, disciple_id: StringName, building_id: StringName) -> bool:
    if state.disciples.has(disciple_id) and not (state.disciples[disciple_id] as DiscipleState).active_pve_encounter_id.is_empty():
        return false
    if not state.sect.workforce_enabled or not state.disciples.has(disciple_id):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    # The primary-building fallback counts group-only members as assigned.
    # Clearing only worksite would therefore leave a hidden Rèn Thân slot.
    # Use the canonical two-field release for an explicit vacancy request.
    if DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        if building_id == &"":
            return bool(DiscipleBodyTrainingFacilityV2.release_slot(state,disciple_id).get("ok",false))
        # A second same-group training building is not yet authored; reject
        # implicit overbook/transfer until the player releases this slot.
        if building_id != disciple.worksite_building_id:
            return false
    if building_id == &"":
        disciple.worksite_building_id = &""
        if not disciple.work_cycle_state.is_empty():
            building_system.cancel_work_cycle(state, disciple, true)
        state.sect.workforce_event_count += 1
        return true
    var building = state.buildings.get(str(building_id))
    if not (building is BuildingState) or building.worker_group_id == &"" or disciple.work_group_id != building.worker_group_id:
        return false
    if disciple.worksite_building_id != building_id and not disciple.work_cycle_state.is_empty():
        building_system.cancel_work_cycle(state, disciple, true)
    disciple.worksite_building_id = building_id
    state.sect.workforce_event_count += 1
    return true

func set_work_preference(state: SimulationState, disciple_id: StringName, profession_id: StringName, priority: int) -> bool:
    if not state.sect.workforce_enabled or not state.disciples.has(disciple_id) or not VALID_PROFESSIONS.has(profession_id):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    disciple.work_preferences[str(profession_id)] = clampi(priority, 0, 4)
    state.sect.workforce_event_count += 1
    return true

func effective_priority(state: SimulationState, disciple: DiscipleState, profession_id: StringName) -> int:
    if disciple.work_preferences.has(str(profession_id)):
        return clampi(int(disciple.work_preferences[str(profession_id)]), 0, 4)
    if disciple.work_group_id != &"":
        var group: Dictionary = state.sect.work_groups.get(str(disciple.work_group_id), {})
        var priorities: Dictionary = group.get("priorities", {})
        if priorities.has(str(profession_id)):
            return clampi(int(priorities[str(profession_id)]), 0, 4)
    return 0

func profession_xp(disciple: DiscipleState, profession_id: StringName) -> float:
    return maxf(float(disciple.profession_xp.get(str(profession_id), 0.0)), 0.0)

func profession_level(disciple: DiscipleState, profession_id: StringName) -> int:
    # Locked P2 compatibility curve.
    var xp := profession_xp(disciple, profession_id)
    if xp >= 900.0:
        return 6
    if xp >= 600.0:
        return 5
    if xp >= 380.0:
        return 4
    if xp >= 220.0:
        return 3
    if xp >= 100.0:
        return 2
    if xp >= 35.0:
        return 1
    return 0

func p3_7_profession_level(disciple: DiscipleState, profession_id: StringName) -> int:
    var xp := profession_xp(disciple, profession_id)
    if xp <= 0.0:
        return 0
    return maxi(int(floor(sqrt(xp / P3_7_XP_LEVEL_SCALE))), 0)

func profession_level_for_state(state: SimulationState, disciple: DiscipleState, profession_id: StringName) -> int:
    return p3_7_profession_level(disciple, profession_id) if state.p3_7_buildings_enabled else profession_level(disciple, profession_id)

func issue_command(state: SimulationState, disciple_id: StringName, kind: StringName, target: String = "", ttl: int = 40) -> bool:
    if not state.sect.workforce_enabled or not state.disciples.has(disciple_id) or not VALID_COMMANDS.has(kind):
        return false
    if kind == COMMAND_WORK and not VALID_PROFESSIONS.has(StringName(target)):
        return false
    if kind == COMMAND_HUNT_REGION and not state.regions.has(StringName(target)):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]

    if not disciple.active_pve_encounter_id.is_empty():
        return false
    if kind == COMMAND_HUNT_REGION and disciple.injury_level == 1 and DiscipleRealmProgressV2.owns_v2_progression(disciple):
        return false

    # GP-02B1: legacy-compatible direct CULTIVATE cannot sidestep the
    # authoritative V2 training occupation guard. Do not alter P2 command
    # cancellation/transfer semantics or explicit non-training commands.
    if kind == COMMAND_CULTIVATE and DiscipleRealmProgressV2.owns_v2_progression(disciple):
        if not disciple.work_cycle_state.is_empty():
            return false
        if state.p3_7_buildings_enabled and building_system.disciple_has_active_spirit_plot(state,disciple.id):
            return false
    if state.p3_7_buildings_enabled and building_system.disciple_has_active_timed_recipe(state, disciple.id):
        return false

    # O3/O4 fail-closed production command boundary: a direct Mine/Field
    # order is only real when the authoritative building can start work for
    # this disciple now. Waiting slots, occupied plots and unpaid crops are not
    # allowed to become fake direct commands.
    if (
        kind == COMMAND_WORK
        and state.p3_7_buildings_enabled
        and building_system.is_building_profession(StringName(target))
        and not building_system.work_available(state, StringName(target), disciple)
    ):
        return false

    # Any accepted explicit non-Body command transfers the player out of the
    # dedicated facility. Invalid commands above must NOT evict trainees.
    if DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        var released := DiscipleBodyTrainingFacilityV2.release_slot(state,disciple_id)
        if not bool(released.get("ok",false)):
            return false
    if state.p3_7_buildings_enabled and not disciple.work_cycle_state.is_empty():
        var cycle_profession := StringName(disciple.work_cycle_state.get("profession", ""))
        var keeps_current_work := kind == COMMAND_WORK and StringName(target) == cycle_profession
        if not keeps_current_work:
            building_system.cancel_work_cycle(state, disciple, true)
    disciple.direct_command = {
        "kind": str(kind),
        "target": target,
        "issued_tick": state.tick,
        "expires_tick": state.tick + maxi(ttl, 1)
    }
    state.sect.workforce_event_count += 1
    return true

func clear_command(state: SimulationState, disciple: DiscipleState) -> void:
    if not disciple.direct_command.is_empty():
        disciple.direct_command.clear()
        state.sect.workforce_event_count += 1

func command_kind(disciple: DiscipleState) -> StringName:
    return StringName(disciple.direct_command.get("kind", ""))

func command_target(disciple: DiscipleState) -> StringName:
    return StringName(disciple.direct_command.get("target", ""))

func next_action(state: SimulationState, disciple: DiscipleState) -> StringName:
    if not disciple.active_pve_encounter_id.is_empty():
        return &"HOLD"
    if not state.sect.workforce_enabled:
        return &""

    _expire_command_if_needed(state, disciple)

    var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
    var owns_v2 := DiscipleRealmProgressV2.owns_v2_progression(disciple)
    if hp_ratio < 0.72 or (not owns_v2 and disciple.stamina < 42.0):
        return &""

    if state.p3_7_buildings_enabled and building_system.disciple_has_active_spirit_plot(state, disciple.id):
        return &""
    if state.p3_7_buildings_enabled and building_system.disciple_has_active_timed_recipe(state, disciple.id):
        return &"HOLD"

    var direct := _direct_command_action(state, disciple)
    if direct != &"":
        return direct

    # A dedicated Rèn Thân assignment owns this actor's scheduled occupation.
    # General profession work preferences must never steal a paid training
    # minute. Injury/urgent healing and explicit player orders remain upstream.
    if owns_v2 and DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        var training := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
        if bool(training.get("ok",false)):
            disciple.last_decision["v2_auto_training"] = training.duplicate(true)
            return StringName(training["action"])
        return &"HOLD"

    if state.p3_7_buildings_enabled:
        var cycle_profession := StringName(disciple.work_cycle_state.get("profession_id", disciple.work_cycle_state.get("profession", "")))
        var cycle_action := _profession_action(cycle_profession)
        if cycle_action != &"":
            return cycle_action

    if disciple.region_id != &"sect":
        return &""

    var phase := schedule_phase(state, disciple)
    match phase:
        &"work":
            var profession := choose_work_profession(state, disciple)
            return _profession_action(profession)
        &"cultivate":
            if owns_v2:
                var auto_training := DiscipleTrainingPolicyV2.choose_auto_action(
                    state,disciple
                )
                if bool(auto_training.get("ok",false)):
                    disciple.last_decision["v2_auto_training"] = auto_training.duplicate(true)
                    return StringName(auto_training["action"])
                return &""
            if state.sect.cultivation_enabled and disciple.stamina >= 55.0:
                return &"CULTIVATE"
        &"recovery":
            if not owns_v2 and disciple.stamina < 88.0:
                return &"REST"
        _:
            pass
    return &""

func schedule_phase(state: SimulationState, disciple: DiscipleState) -> StringName:
    var slot := (state.tick + _stable_text_value(str(disciple.id))) % SCHEDULE_CYCLE
    match state.sect.work_policy:
        POLICY_PRODUCTION:
            if slot < 13:
                return &"work"
            if slot < 17:
                return &"cultivate"
            return &"recovery"
        POLICY_CULTIVATION:
            if slot < 6:
                return &"work"
            if slot < 16:
                return &"cultivate"
            return &"recovery"
        _:
            if slot < 10:
                return &"work"
            if slot < 16:
                return &"cultivate"
            return &"recovery"

func choose_work_profession(state: SimulationState, disciple: DiscipleState) -> StringName:
    var candidates := [PROF_MINING, PROF_FORGING]
    if state.p3_7_buildings_enabled:
        candidates.append(PROF_HERBALISM)
        candidates.append(PROF_FORESTRY)
        candidates.append(PROF_ALCHEMY)
    var best := &""
    var best_score := -1.0e30
    for profession_id in candidates:
        if state.p3_7_buildings_enabled and not building_system.work_available(state, profession_id, disciple):
            continue
        var priority := effective_priority(state, disciple, profession_id)
        if priority <= 0:
            continue
        var score := float(priority) * 100.0 + float(profession_level_for_state(state, disciple, profession_id)) * 3.0
        if _has_profession_trait(disciple, profession_id):
            score += 8.0
        if score > best_score or (absf(score - best_score) <= 0.000001 and (best == &"" or str(profession_id) < str(best))):
            best_score = score
            best = profession_id
    return best

func perform_work(state: SimulationState, disciple: DiscipleState, profession_id: StringName) -> Dictionary:
    if not disciple.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"disciple_in_v2_pve"}
    if not state.sect.workforce_enabled or disciple.region_id != &"sect" or not VALID_PROFESSIONS.has(profession_id):
        return {"ok":false, "completed":false}
    if state.p3_7_buildings_enabled and building_system.disciple_has_active_spirit_plot(state, disciple.id):
        return {"ok":false, "completed":false, "reason":"busy_spirit_plot"}
    if state.p3_7_buildings_enabled:
        if profession_id == PROF_MINING:
            return _perform_p3_7_mining(state, disciple)
        if profession_id == PROF_FORESTRY:
            return _perform_p3_7_forestry(state, disciple)
        if profession_id == PROF_ALCHEMY:
            return _perform_p3_7_alchemy(state, disciple)
        if profession_id == PROF_HERBALISM:
            return _perform_p3_7_herbalism(state, disciple)
    var duration := _work_duration(profession_id)
    if duration <= 0.0:
        return {"ok":false, "completed":false}

    var speed := _work_speed(state, disciple, profession_id)
    var key := str(profession_id)
    var progress := float(disciple.work_progress.get(key, 0.0)) + speed
    disciple.work_progress[key] = progress
    if not DiscipleRealmProgressV2.owns_v2_progression(disciple):
        disciple.stamina = maxf(0.0, disciple.stamina - 4.0)
    disciple.metrics["work_actions"] = int(disciple.metrics.get("work_actions", 0)) + 1

    var result := {"ok":true, "completed":false, "profession":key, "progress":progress}
    if progress + 0.000001 < duration:
        return result

    disciple.work_progress[key] = maxf(progress - duration, 0.0)
    var xp_gain := BASE_WORK_XP * _learning_multiplier(state, disciple, profession_id)
    disciple.profession_xp[key] = profession_xp(disciple, profession_id) + xp_gain
    disciple.metrics["work_completions"] = int(disciple.metrics.get("work_completions", 0)) + 1
    state.sect.workforce_event_count += 1
    result["completed"] = true
    result["xp_gain"] = xp_gain

    match profession_id:
        PROF_MINING:
            var produced := 1 + int(profession_level(disciple, profession_id) >= 3)
            state.sect.forge_materials["thanh_thiet"] = int(state.sect.forge_materials.get("thanh_thiet", 0)) + produced
            disciple.metrics["mining_completions"] = int(disciple.metrics.get("mining_completions", 0)) + 1
            result["produced"] = produced
        PROF_FORGING:
            var support := 1 + int(profession_level(disciple, profession_id) >= 4)
            state.sect.forge_support_points += support
            disciple.metrics["forging_completions"] = int(disciple.metrics.get("forging_completions", 0)) + 1
            result["support_points"] = support
        _:
            pass

    if command_kind(disciple) == COMMAND_WORK and command_target(disciple) == profession_id:
        clear_command(state, disciple)
    return result

func _perform_p3_7_mining(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var result := building_system.perform_mining_step(state, disciple, _work_speed(state, disciple, PROF_MINING))
    if not bool(result.get("ok", false)):
        return result

    var stamina_cost := maxf(float(result.get("stamina_cost", 1.0)), 0.0)
    if DiscipleRealmProgressV2.owns_v2_progression(disciple):
        # Expedition stamina cannot be spent by an in-sect mining shift.
        result["effective_stamina_cost"] = 0.0
    else:
        disciple.stamina = maxf(0.0, disciple.stamina - stamina_cost)
        result["effective_stamina_cost"] = stamina_cost
    result["work_cultivation_gain"] = _grant_p3_7_work_cultivation(state, disciple, PROF_MINING)
    # DV2-03: only an actual mining-phase minute has verified physical load.
    # Travel and haul are not active extraction. P3.7 mine ownership/slot
    # checks already succeeded inside perform_mining_step(). Legacy stays on
    # its own progression, with no V2 Body EXP bridge.
    if state.sect.v2_training_enabled and disciple.current_action == &"WORK_MINING" and DiscipleRealmProgressV2.owns_v2_progression(disciple) and str(result.get("phase", "")) == "mining":
        var body_rule = state.sect.v2_training_rules.get("body", null)
        if body_rule is Dictionary:
            var body_source := {
                "source_id": "p3_7_mine_active_extraction:%s" % str(result.get("building_id", "")),
                "source_kind": DiscipleBodyXpSourceV2.SOURCE_PRODUCTION,
                "base_body_xp_per_minute": DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE,
                "floor_costs": body_rule.get("floor_costs", {}),
                "modifiers": [],
                "active_work_verified": true
            }
            result["body_xp_result"] = DiscipleBodyXpSourceV2.commit_minute(
                state, disciple, body_source,
                "dv2:mine:active:%s:%d" % [str(disciple.id), state.tick]
            )
        else:
            result["body_xp_result"] = {"ok": false, "reason": "missing_authored_body_rule"}
    disciple.metrics["work_actions"] = int(disciple.metrics.get("work_actions", 0)) + 1
    if not bool(result.get("completed", false)):
        return result

    var key := str(PROF_MINING)
    var xp_gain := BASE_WORK_XP * _learning_multiplier(state, disciple, PROF_MINING)
    disciple.profession_xp[key] = profession_xp(disciple, PROF_MINING) + xp_gain
    disciple.metrics["work_completions"] = int(disciple.metrics.get("work_completions", 0)) + 1
    disciple.metrics["mining_completions"] = int(disciple.metrics.get("mining_completions", 0)) + 1
    state.sect.workforce_event_count += 1
    result["xp_gain"] = xp_gain

    if command_kind(disciple) == COMMAND_WORK and command_target(disciple) == PROF_MINING:
        clear_command(state, disciple)
    return result

func _perform_p3_7_forestry(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var result := building_system.perform_forestry_step(
        state, disciple, _work_speed(state, disciple, PROF_FORESTRY)
    )
    if not bool(result.get("ok", false)):
        return result

    var stamina_cost := maxf(float(result.get("stamina_cost", 1.0)), 0.0)
    if DiscipleRealmProgressV2.owns_v2_progression(disciple):
        result["effective_stamina_cost"] = 0.0
    else:
        disciple.stamina = maxf(0.0, disciple.stamina - stamina_cost)
        result["effective_stamina_cost"] = stamina_cost
    result["work_cultivation_gain"] = _grant_p3_7_work_cultivation(state, disciple, PROF_FORESTRY)
    disciple.metrics["work_actions"] = int(disciple.metrics.get("work_actions", 0)) + 1
    if not bool(result.get("completed", false)):
        return result

    var key := str(PROF_FORESTRY)
    var xp_gain := BASE_WORK_XP * _learning_multiplier(state, disciple, PROF_FORESTRY)
    disciple.profession_xp[key] = profession_xp(disciple, PROF_FORESTRY) + xp_gain
    disciple.metrics["work_completions"] = int(disciple.metrics.get("work_completions", 0)) + 1
    disciple.metrics["forestry_completions"] = int(disciple.metrics.get("forestry_completions", 0)) + 1
    state.sect.workforce_event_count += 1
    result["xp_gain"] = xp_gain

    if command_kind(disciple) == COMMAND_WORK and command_target(disciple) == PROF_FORESTRY:
        clear_command(state, disciple)
    return result

func _perform_p3_7_alchemy(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var xp_gain := BASE_WORK_XP * _learning_multiplier(state, disciple, PROF_ALCHEMY)
    var result := building_system.perform_alchemy_step(
        state,
        disciple,
        profession_level_for_state(state, disciple, PROF_ALCHEMY),
        _work_speed(state, disciple, PROF_ALCHEMY),
        xp_gain
    )
    if not bool(result.get("ok", false)):
        return result
    disciple.metrics["work_actions"] = int(disciple.metrics.get("work_actions", 0)) + 1
    result["work_cultivation_gain"] = _grant_p3_7_work_cultivation(state, disciple, PROF_ALCHEMY)
    if bool(result.get("started", false)) and command_kind(disciple) == COMMAND_WORK and command_target(disciple) == PROF_ALCHEMY:
        clear_command(state, disciple)
    return result

func _perform_p3_7_herbalism(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var result := building_system.perform_spirit_field_step(state, disciple, _work_speed(state, disciple, PROF_HERBALISM))
    if not bool(result.get("ok", false)):
        return result

    result["work_cultivation_gain"] = _grant_p3_7_work_cultivation(state, disciple, PROF_HERBALISM)
    disciple.metrics["work_actions"] = int(disciple.metrics.get("work_actions", 0)) + 1
    if not bool(result.get("completed", false)):
        return result

    var key := str(PROF_HERBALISM)
    var base_xp := maxf(float(result.get("base_work_xp", BASE_WORK_XP)), 0.0)
    var field_xp_factor := maxf(float(result.get("field_xp_factor", 1.0)), 0.0)
    var xp_gain := base_xp * _learning_multiplier(state, disciple, PROF_HERBALISM) * field_xp_factor
    disciple.profession_xp[key] = profession_xp(disciple, PROF_HERBALISM) + xp_gain
    disciple.metrics["work_completions"] = int(disciple.metrics.get("work_completions", 0)) + 1
    disciple.metrics["herbalism_completions"] = int(disciple.metrics.get("herbalism_completions", 0)) + 1
    state.sect.workforce_event_count += 1
    result["xp_gain"] = xp_gain

    if command_kind(disciple) == COMMAND_WORK and command_target(disciple) == PROF_HERBALISM:
        clear_command(state, disciple)
    return result

func notify_action_completed(state: SimulationState, disciple: DiscipleState, action: StringName) -> void:
    var kind := command_kind(disciple)
    if kind == &"":
        return
    match kind:
        COMMAND_CULTIVATE:
            if action == &"CULTIVATE":
                clear_command(state, disciple)
        COMMAND_REST:
            if action == &"REST":
                clear_command(state, disciple)
        COMMAND_RETURN_SECT:
            if disciple.region_id == &"sect":
                clear_command(state, disciple)
        COMMAND_HUNT_REGION:
            if action == &"COMBAT":
                clear_command(state, disciple)
        _:
            pass

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.workforce_enabled:
        return errors
    if not VALID_POLICIES.has(state.sect.work_policy):
        errors.append("Workforce policy is invalid.")
    if state.sect.forge_support_points < 0:
        errors.append("Forge support points are negative.")
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
            if disciple.comprehension < 0.0:
                errors.append("%s has invalid open-point comprehension." % disciple.display_name)
        elif disciple.comprehension <= 0.0 or disciple.comprehension > 1.0:
            errors.append("%s has invalid legacy comprehension." % disciple.display_name)
        if disciple.work_group_id != &"" and not state.sect.work_groups.has(str(disciple.work_group_id)):
            errors.append("%s references missing work group %s." % [disciple.display_name, disciple.work_group_id])
        for profession_id in disciple.profession_xp.keys():
            if not VALID_PROFESSIONS.has(StringName(profession_id)) or float(disciple.profession_xp[profession_id]) < 0.0:
                errors.append("%s has invalid profession XP." % disciple.display_name)
        for preference_id in disciple.work_preferences.keys():
            var preference := int(disciple.work_preferences[preference_id])
            if not VALID_PROFESSIONS.has(StringName(preference_id)) or preference < 0 or preference > 4:
                errors.append("%s has invalid work preference." % disciple.display_name)
        for progress_id in disciple.work_progress.keys():
            if not VALID_PROFESSIONS.has(StringName(progress_id)) or float(disciple.work_progress[progress_id]) < 0.0:
                errors.append("%s has invalid work progress." % disciple.display_name)
        for trait_id in disciple.profession_traits:
            if not PROFESSION_TRAITS.has(str(trait_id)):
                errors.append("%s has invalid profession trait %s." % [disciple.display_name, trait_id])
            var grade := int(disciple.profession_trait_grades.get(str(trait_id), 1))
            if grade < 1 or grade > 5:
                errors.append("%s has invalid profession trait grade for %s." % [disciple.display_name, trait_id])
        if disciple.worksite_building_id != &"":
            var assigned = state.buildings.get(str(disciple.worksite_building_id))
            if not (assigned is BuildingState):
                errors.append("%s references missing worksite %s." % [disciple.display_name, disciple.worksite_building_id])
            elif assigned.worker_group_id != disciple.work_group_id:
                errors.append("%s worksite/group assignment is inconsistent." % disciple.display_name)
        if not disciple.direct_command.is_empty():
            var kind := StringName(disciple.direct_command.get("kind", ""))
            if not VALID_COMMANDS.has(kind):
                errors.append("%s has invalid direct command." % disciple.display_name)
    return errors

func _direct_command_action(state: SimulationState, disciple: DiscipleState) -> StringName:
    var kind := command_kind(disciple)
    match kind:
        COMMAND_WORK:
            if disciple.region_id != &"sect":
                return &"RETURN_SECT"
            return _profession_action(command_target(disciple))
        COMMAND_CULTIVATE:
            if disciple.region_id != &"sect":
                return &"RETURN_SECT"
            if DiscipleRealmProgressV2.owns_v2_progression(disciple):
                # Old UI command is allowed to route to the V2 action owner,
                # but never to P2 if V2 content/profile is unavailable.
                if state.sect.v2_training_enabled and DiscipleRealmProgressV2.progression_ready(disciple):
                    return &"CULTIVATE"
                # Do not leave a rejected compatibility command stuck in an
                # endless HOLD -> EVALUATE -> HOLD loop.
                clear_command(state,disciple)
                disciple.last_decision["v2_training_result"] = {
                    "ok":false,"reason":"v2_training_not_ready"
                }
                return &""
            return &"CULTIVATE"
        COMMAND_HUNT_REGION:
            if disciple.injury_level == 1 and DiscipleRealmProgressV2.owns_v2_progression(disciple):
                return &"HOLD"
            if disciple.region_id == &"sect":
                disciple.target_region_id = command_target(disciple)
                return &"HUNT"
            if disciple.region_id == command_target(disciple):
                return &"COMBAT"
            return &"RETURN_SECT"
        COMMAND_RETURN_SECT:
            if disciple.region_id == &"sect":
                clear_command(state, disciple)
                return &""
            return &"RETURN_SECT"
        COMMAND_REST:
            if disciple.region_id != &"sect":
                return &"RETURN_SECT"
            return &"REST"
        COMMAND_HOLD:
            if disciple.region_id != &"sect":
                return &"RETURN_SECT"
            return &"HOLD"
        _:
            return &""

func _profession_action(profession_id: StringName) -> StringName:
    match profession_id:
        PROF_MINING:
            return &"WORK_MINING"
        PROF_FORGING:
            return &"WORK_FORGING"
        PROF_HERBALISM:
            return &"WORK_HERBALISM"
        PROF_FORESTRY:
            return &"WORK_FORESTRY"
        PROF_ALCHEMY:
            return &"WORK_ALCHEMY"
        _:
            return &""

func _work_duration(profession_id: StringName) -> float:
    match profession_id:
        PROF_MINING:
            return MINING_DURATION
        PROF_FORGING:
            return FORGING_DURATION
        _:
            return 0.0

func _work_speed(state: SimulationState, disciple: DiscipleState, profession_id: StringName) -> float:
    var level := profession_level_for_state(state, disciple, profession_id)
    if state.p3_7_buildings_enabled:
        return profession_modifiers.total_work_speed_factor(state, disciple, level)

    var speed := 1.0 + float(level) * 0.08
    speed *= lerpf(0.90, 1.18, clampf(disciple.comprehension, 0.0, 1.0))
    if _has_profession_trait(disciple, profession_id):
        speed *= 1.18
    if disciple.profession_traits.has(TRAIT_DILIGENT):
        speed *= 1.08
    if disciple.profession_traits.has(TRAIT_LAZY):
        speed *= 0.88
    if state.sect.disciple_traits_enabled:
        speed *= trait_system.work_speed_multiplier(state, disciple)
    return maxf(speed, 0.25)

func _learning_multiplier(state: SimulationState, disciple: DiscipleState, profession_id: StringName) -> float:
    if state.p3_7_buildings_enabled:
        return profession_modifiers.total_profession_xp_factor(state, disciple, profession_id)

    var multiplier := lerpf(0.75, 1.35, clampf(disciple.comprehension, 0.0, 1.0))
    if _has_profession_trait(disciple, profession_id):
        multiplier *= 1.25
    if state.sect.disciple_traits_enabled:
        multiplier *= trait_system.profession_learning_multiplier(state, disciple)
    return multiplier

func _grant_p3_7_work_cultivation(state: SimulationState, disciple: DiscipleState, profession_id: StringName) -> float:
    if DiscipleRealmProgressV2.owns_v2_progression(disciple):
        # USER LOCK 2026-10-09: ordinary work does NOT create a second Tu Vi
        # source. V2 passive natural Tu Vi is resolved once per simulation minute
        # by SimulationScheduler regardless of ordinary activity.
        return 0.0

    if not state.sect.cultivation_enabled:
        return 0.0
    var required := cultivation_system.required_progress(disciple)
    if required <= 0.0:
        return 0.0
    var level := p3_7_profession_level(disciple, profession_id)
    var raw_gain := required * profession_modifiers.raw_work_cultivation_ratio_per_hour(level) * ACTIVE_WORK_HOURS_PER_STEP
    return cultivation_system.add_progress(state, disciple, raw_gain)

func _has_profession_trait(disciple: DiscipleState, profession_id: StringName) -> bool:
    if profession_id == PROF_FORGING:
        return disciple.profession_traits.has(TRAIT_FORGE)
    if profession_id == PROF_MINING:
        return disciple.profession_traits.has(TRAIT_MINER)
    if profession_id == PROF_HERBALISM:
        return disciple.profession_traits.has(TRAIT_HERBALIST)
    return false

func _ensure_profession_trait_grades(traits: Array, grades: Dictionary) -> void:
    for trait_id in traits:
        if not grades.has(str(trait_id)):
            grades[str(trait_id)] = 1

func _roll_p3_7_profession_talent_if_needed(state: SimulationState, disciple: DiscipleState) -> void:
    if _has_any_p3_7_profession_talent(disciple.profession_traits):
        return
    var source := disciple.recruitment_source
    var chance := _p3_7_talent_chance(source)
    var rng := GameRng.new(_profile_seed(state.seed, str(disciple.id), 9371))
    if rng.randf_range(0.0, 1.0) >= chance:
        return
    var pool := [TRAIT_FORGE, TRAIT_MINER, TRAIT_HERBALIST]
    var trait_id := str(pool[rng.randi_range(0, pool.size() - 1)])
    disciple.profession_traits.append(trait_id)
    disciple.profession_traits.sort()
    disciple.profession_trait_grades[trait_id] = profession_modifiers.roll_grade(rng)

func _roll_p3_7_candidate_talent_if_needed(state: SimulationState, candidate: CandidateState) -> void:
    if _has_any_p3_7_profession_talent(candidate.profession_traits):
        return
    var chance := _p3_7_talent_chance(candidate.recruitment_source)
    var rng := GameRng.new(_profile_seed(state.seed, str(candidate.id), 9371))
    if rng.randf_range(0.0, 1.0) >= chance:
        return
    var pool := [TRAIT_FORGE, TRAIT_MINER, TRAIT_HERBALIST]
    var trait_id := str(pool[rng.randi_range(0, pool.size() - 1)])
    candidate.profession_traits.append(trait_id)
    candidate.profession_traits.sort()
    candidate.profession_trait_grades[trait_id] = profession_modifiers.roll_grade(rng)

func _has_any_p3_7_profession_talent(traits: Array) -> bool:
    return traits.has(TRAIT_FORGE) or traits.has(TRAIT_MINER) or traits.has(TRAIT_HERBALIST)

func _p3_7_talent_chance(source: StringName) -> float:
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        return 0.40
    if source == DiscipleGeneratorV2.SOURCE_FATE:
        return 0.50
    return 0.30

func _expire_command_if_needed(state: SimulationState, disciple: DiscipleState) -> void:
    if disciple.direct_command.is_empty():
        return
    if state.tick >= int(disciple.direct_command.get("expires_tick", state.tick + 1)):
        clear_command(state, disciple)

func _roll_traits(base_seed: int, identity: String) -> Array:
    var rng := GameRng.new(_profile_seed(base_seed, identity, 3571))
    var result: Array = []
    if rng.randf_range(0.0, 1.0) < 0.38:
        result.append(TRAIT_FORGE if rng.randi_range(0, 1) == 0 else TRAIT_MINER)
    if rng.randf_range(0.0, 1.0) < 0.24:
        var temperament := TRAIT_DILIGENT if rng.randi_range(0, 1) == 0 else TRAIT_LAZY
        if not result.has(temperament):
            result.append(temperament)
    result.sort()
    return result

func _profile_seed(base_seed: int, identity: String, offset: int) -> int:
    return base_seed + _stable_text_value(identity) * 104729 + offset

func _stable_text_value(text: String) -> int:
    var value := 0
    for index in range(text.length()):
        value = (value * 131 + text.unicode_at(index)) % 2147483629
    return value