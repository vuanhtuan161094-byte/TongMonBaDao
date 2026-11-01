class_name RecruitmentSystem
extends RefCounted

const DEFAULT_POOL_SIZE := 3

# P3.7C1 Dẫn Tiên v1 balance. One simulation day = 24 * 60 ticks.
const GUIDANCE_DAY_TICKS := 1440
# C2 technical safety: cap materialized candidates, including paid orders.
# Saved overflow is preserved; free arrivals skip when full, never delete data.
# Owner may re-balance this limit after real device/queue QA.
const C2_QUEUE_CAP := 30
const GUIDANCE_QUALITY_FULL_CHARM := 2500.0
const GUIDANCE_ASSISTANT_VISITOR_STEP := 500.0
const GUIDANCE_HEAVEN_QUOTA_STEP := 625.0

const GUIDANCE_BASE_RATES := {
    "common": 0.65,
    "outstanding": 0.25,
    "prodigy": 0.08,
    "peerless": 0.018,
    "heaven_defying": 0.002
}
const GUIDANCE_MAX_RATES := {
    "common": 0.35,
    "outstanding": 0.25,
    "prodigy": 0.20,
    "peerless": 0.15,
    "heaven_defying": 0.05
}

var building_system := BuildingSystem.new()

const SURNAMES := ["Lâm", "Trần", "Bạch", "Cố", "Triệu", "Tần", "Mạc", "Tô", "Lý", "Vương", "Đỗ", "Hạ"]
const GIVEN_NAMES := ["An", "Minh", "Phong", "Nguyệt", "Vũ", "Thanh", "Nhi", "Mặc", "Huyền", "Linh", "Trúc", "Thiên"]
const ARCHETYPE_IDS := ["daring", "cautious", "balanced", "frugal_guarded", "reckless", "prudent"]
const ARCHETYPES := {
    "daring": {"risk": 0.80, "spend": 0.50, "survival": 0.35},
    "cautious": {"risk": 0.20, "spend": 0.32, "survival": 0.86},
    "balanced": {"risk": 0.50, "spend": 0.50, "survival": 0.55},
    "frugal_guarded": {"risk": 0.28, "spend": 0.22, "survival": 0.74},
    "reckless": {"risk": 0.92, "spend": 0.58, "survival": 0.22},
    "prudent": {"risk": 0.42, "spend": 0.62, "survival": 0.82}
}

func ensure_candidate_pool(state: SimulationState, target_count: int = DEFAULT_POOL_SIZE) -> void:
    if not state.p1_recruitment_enabled:
        return
    var desired := maxi(target_count, 0)
    while state.recruitment_candidates.size() < desired:
        var candidate := generate_candidate(state)
        if candidate == null:
            return

func generate_candidate(state: SimulationState, source: StringName = DiscipleGeneratorV2.SOURCE_ORDINARY) -> CandidateState:
    if not state.p1_recruitment_enabled:
        return null

    if state.sect.disciple_generation_v2_enabled:
        if not DiscipleGeneratorV2.VALID_SOURCES.has(source):
            return null
        if state.sect.disciple_v2_birth_enabled and not state.sect.foundation_points_enabled:
            push_error("DV2-01B requires open-point P3.7C1 foundation authority.")
            return null
        var generation_index_v2 := state.recruitment_generation_index + 1
        var candidate_v2: CandidateState
        if state.sect.foundation_points_enabled:
            candidate_v2 = DiscipleGeneratorOpenPoints.new().generate_candidate(state, source, generation_index_v2)
        else:
            candidate_v2 = DiscipleGeneratorV2.new().generate_candidate(state, source, generation_index_v2)
        if candidate_v2 == null:
            return null
        state.recruitment_generation_index = generation_index_v2
        state.recruitment_candidates[candidate_v2.id] = candidate_v2
        state.sect.disciple_generation_event_count += 1
        if not state.sect.disciple_v2_birth_enabled:
            if state.sect.disciple_traits_enabled:
                TraitSystem.new().ensure_candidate_profile(state, candidate_v2)
            if state.sect.spiritual_root_refinement_enabled:
                RootRefinementSystem.new().ensure_candidate_profile(state, candidate_v2)
            if state.sect.bloodlines_enabled:
                BloodlineSystem.new().ensure_candidate_profile(state, candidate_v2)
            if state.sect.physiques_enabled:
                PhysiqueSystem.new().ensure_candidate_profile(state, candidate_v2)
        if state.p3_7_buildings_enabled:
            WorkforceSystem.new().ensure_p3_7_candidate_profile(state, candidate_v2)
        if state.sect.disciple_v2_birth_enabled:
            DiscipleBirthRollV2.sync_profession_talent(candidate_v2.v2_birth_profile, candidate_v2)
        return candidate_v2

    if source != DiscipleGeneratorV2.SOURCE_ORDINARY:
        return null

    var generation_index := state.recruitment_generation_index + 1
    var rng := GameRng.new(_candidate_seed(state.seed, generation_index))
    var surname := str(SURNAMES[rng.randi_range(0, SURNAMES.size() - 1)])
    var given_name := str(GIVEN_NAMES[rng.randi_range(0, GIVEN_NAMES.size() - 1)])
    var archetype_id := str(ARCHETYPE_IDS[rng.randi_range(0, ARCHETYPE_IDS.size() - 1)])
    var profile: Dictionary = ARCHETYPES[archetype_id]

    var candidate := CandidateState.new({
        "id": "candidate_%04d" % generation_index,
        "name": "%s %s" % [surname, given_name],
        "combat_power": rng.randf_range(14.0, 24.0),
        "risk_bias": clampf(float(profile["risk"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "spend_bias": clampf(float(profile["spend"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "survival_bias": clampf(float(profile["survival"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "personality_id": archetype_id,
        "generated_index": generation_index
    })

    if state.sect.spiritual_roots_enabled:
        var roots := SpiritualRootSystem.new()
        roots.ensure_candidate_root(state, candidate)
        if state.sect.techniques_enabled:
            roots.ensure_candidate_elements(state, candidate)
    if state.sect.workforce_enabled:
        WorkforceSystem.new().ensure_candidate_profile(state, candidate)

    state.recruitment_generation_index = generation_index
    state.recruitment_candidates[candidate.id] = candidate
    return candidate

func gacha_candidate(state: SimulationState) -> Dictionary:
    if not state.p1_recruitment_enabled or not state.sect.disciple_generation_v2_enabled:
        return _result(false, "generation_v2_disabled")
    # P3.7 has one ordinary paid-recruitment authority: Chiêu Mộ Lệnh goes
    # through Dẫn Tiên instead of silently using the old P2 gacha distribution.
    if state.sect.guidance_recruitment_enabled:
        return guidance_recruit_with_order(state)
    if state.sect.disciple_recruitment_tokens <= 0:
        return _result(false, "not_enough_recruitment_tokens")
    state.sect.disciple_recruitment_tokens -= 1
    var candidate := generate_candidate(state, DiscipleGeneratorV2.SOURCE_GACHA)
    if candidate == null:
        state.sect.disciple_recruitment_tokens += 1
        return _result(false, "generation_failed")
    var result := _result(true, "gacha")
    result["candidate_id"] = str(candidate.id)
    result["remaining_tokens"] = state.sect.disciple_recruitment_tokens
    return result

func fate_candidate(state: SimulationState) -> Dictionary:
    if not state.p1_recruitment_enabled or not state.sect.disciple_generation_v2_enabled:
        return _result(false, "generation_v2_disabled")
    var candidate := generate_candidate(state, DiscipleGeneratorV2.SOURCE_FATE)
    if candidate == null:
        return _result(false, "generation_failed")
    var result := _result(true, "fate")
    result["candidate_id"] = str(candidate.id)
    return result

func accept_candidate(state: SimulationState, candidate_id: StringName) -> Dictionary:
    if not state.p1_recruitment_enabled:
        return _result(false, "recruitment_disabled")
    if not state.recruitment_candidates.has(candidate_id):
        return _result(false, "candidate_missing")
    if SectHallSystemV1.installed(state):
        SectResidenceSystemV1.refresh_capacity(state)
    if state.disciples.size() >= state.sect.disciple_capacity:
        return _result(false, "capacity_full")
    if state.disciples.has(candidate_id):
        return _result(false, "duplicate_disciple_id")

    var candidate: CandidateState = state.recruitment_candidates[candidate_id]
    if state.sect.disciple_v2_birth_enabled and not DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
        return _result(false, "v2_birth_profile_incomplete")
    var disciple := candidate.to_disciple()
    # USER LOCK 2026-10-09: every NEW production V2 disciple starts at
    # Phàm Nhân tầng 1 + Phàm Thân tầng 1, both 0 EXP. Birth quality/foundations
    # affect future growth rate, never starting realm/floor.
    if DiscipleRealmProgressV2.owns_v2_progression(disciple):
        var started := DiscipleRealmProgressV2.initialize(disciple,1,1,1,1)
        if not bool(started.get("ok",false)):
            return _result(false,str(started.get("reason","v2_progress_initialization_failed")))
    if state.sect.spiritual_roots_enabled and not state.sect.disciple_v2_birth_enabled:
        var roots := SpiritualRootSystem.new()
        roots.ensure_disciple_root(state, disciple)
        if state.sect.techniques_enabled:
            roots.ensure_disciple_elements(state, disciple)
    if state.sect.workforce_enabled and (not state.sect.disciple_generation_v2_enabled or disciple.profile_seed <= 0):
        WorkforceSystem.new().ensure_disciple_profile(state, disciple)
    # V2 birth identity was selected and stored before recruitment.
    # Do not reroll parallel P2 Trait/Root/Bloodline/Physique profiles for V2 recruits.
    if not state.sect.disciple_v2_birth_enabled:
        if state.sect.disciple_traits_enabled:
            TraitSystem.new().ensure_disciple_profile(state, disciple)
        if state.sect.spiritual_root_refinement_enabled:
            RootRefinementSystem.new().ensure_disciple_profile(state, disciple)
        if state.sect.bloodlines_enabled:
            BloodlineSystem.new().ensure_disciple_profile(state, disciple)
        if state.sect.physiques_enabled:
            PhysiqueSystem.new().ensure_disciple_profile(state, disciple)
    state.disciples[disciple.id] = disciple
    state.recruitment_candidates.erase(candidate_id)
    state.recruitment_stats["accepted"] = int(state.recruitment_stats.get("accepted", 0)) + 1
    if SectHallSystemV1.installed(state):
        SectResidenceSystemV1.auto_assign_beds(state)
        SectHallSystemV1.record_prestige(state, 25)
        SectHallSystemV1.record_office_event(state, SectHallSystemV1.OFFICE_GUIDE, true)

    if state.p1_goal_personality_enabled:
        GoalSystem.new().update_goal(state, disciple)
    if state.p1_relationships_enabled:
        RelationshipSystem.new().introduce_new_disciple(state, disciple)

    var result := _result(true, "accepted")
    result["disciple_id"] = str(disciple.id)
    return result

func reject_candidate(state: SimulationState, candidate_id: StringName) -> Dictionary:
    if not state.p1_recruitment_enabled:
        return _result(false, "recruitment_disabled")
    if not state.recruitment_candidates.has(candidate_id):
        return _result(false, "candidate_missing")
    if state.sect.disciple_traits_enabled:
        TraitSystem.new().remove_profile(state, candidate_id)
    if state.sect.spiritual_root_refinement_enabled:
        RootRefinementSystem.new().remove_profile(state, candidate_id)
    if state.sect.bloodlines_enabled:
        BloodlineSystem.new().remove_profile(state, candidate_id)
    if state.sect.physiques_enabled:
        PhysiqueSystem.new().remove_profile(state, candidate_id)
    state.recruitment_candidates.erase(candidate_id)
    state.recruitment_stats["rejected"] = int(state.recruitment_stats.get("rejected", 0)) + 1
    return _result(true, "rejected")

func can_accept_more(state: SimulationState) -> bool:
    if SectHallSystemV1.installed(state):
        return state.p1_recruitment_enabled and state.disciples.size() < SectResidenceSystemV1.current_limit(state)
    return state.p1_recruitment_enabled and state.disciples.size() < state.sect.disciple_capacity

func _candidate_seed(base_seed: int, generation_index: int) -> int:
    return base_seed + generation_index * 104729 + 7919

func _result(ok: bool, reason: String) -> Dictionary:
    return {"ok": ok, "reason": reason}


# -----------------------------------------------------------------------------
# P3.7C1 — Dẫn Tiên Đài
# -----------------------------------------------------------------------------

func process_guidance_tick(state: SimulationState) -> void:
    if not _guidance_available(state):
        return
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return
    var data := _guidance_state(platform)
    var day_index := guidance_day_index(state)
    if int(data.get("snapshot_day_index", -1)) != day_index:
        _begin_guidance_day(state, platform, data, day_index, true)

func guidance_day_index(state: SimulationState) -> int:
    return maxi(int(floor(float(maxi(state.tick, 0)) / float(GUIDANCE_DAY_TICKS))), 0)

func assign_guidance_main(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not _guidance_available(state):
        return _result(false, "guidance_disabled")
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return _result(false, "guidance_platform_missing")
    if disciple_id != &"" and not state.disciples.has(disciple_id):
        return _result(false, "disciple_missing")
    if disciple_id != &"" and not guidance_guide_eligible(state, disciple_id):
        return _result(false, "guide_busy_or_injured")
    # DD-06: Dẫn Tiên is the same Tiếp Dẫn main office. All seven seats,
    # including later unlocked offices, obey the one-main-office invariant.
    # This guard must also run for callers bypassing the Đại Điện UI.
    if disciple_id != &"" and SectHallSystemV1.installed(state):
        for other_office in SectHallSystemV1.OFFICES:
            if other_office != SectHallSystemV1.OFFICE_GUIDE \
                    and SectHallSystemV1.holder_id(state, other_office) == str(disciple_id):
                return _result(false, "disciple_owns_other_office")
    var data := _guidance_state(platform)
    var assistants: Array = data.get("assistant_guide_ids", [])
    assistants.erase(str(disciple_id))
    data["assistant_guide_ids"] = assistants
    data["main_guide_id"] = str(disciple_id)
    platform.production_state = data
    state.building_event_count += 1
    return _result(true, "assigned_main")

func set_guidance_assistants(state: SimulationState, disciple_ids: Array) -> Dictionary:
    if not _guidance_available(state):
        return _result(false, "guidance_disabled")
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return _result(false, "guidance_platform_missing")
    var data := _guidance_state(platform)
    var main_id := str(data.get("main_guide_id", ""))
    var max_assistants := maxi(building_system.guidance_elder_slots(platform) - 1, 0)
    var normalized: Array = []
    for raw_id in disciple_ids:
        var disciple_id := str(raw_id)
        if disciple_id == "" or disciple_id == main_id or normalized.has(disciple_id):
            continue
        if not state.disciples.has(StringName(disciple_id)):
            return _result(false, "disciple_missing")
        if not guidance_guide_eligible(state, StringName(disciple_id)):
            return _result(false, "guide_busy_or_injured")
        if normalized.size() >= max_assistants:
            return _result(false, "assistant_slots_full")
        normalized.append(disciple_id)
    normalized.sort()
    data["assistant_guide_ids"] = normalized
    platform.production_state = data
    state.building_event_count += 1
    return _result(true, "assigned_assistants")

func guidance_guide_eligible(state: SimulationState, disciple_id: StringName) -> bool:
    var disciple: DiscipleState = state.disciples.get(disciple_id)
    if disciple == null or disciple.injury_level != 0:
        return false
    if disciple.region_id != &"sect" or not disciple.active_pve_encounter_id.is_empty():
        return false
    if not disciple.work_cycle_state.is_empty() or not disciple.direct_command.is_empty():
        return false
    if disciple.current_action not in [&"IDLE", &"HOLD", &"EVALUATE"]:
        return false
    return not building_system.disciple_has_active_timed_recipe(state,disciple.id) \
        and not building_system.disciple_has_active_spirit_plot(state,disciple.id) \
        and not DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple)

func guidance_quality_rates_for_charisma(charisma: float) -> Dictionary:
    # Quality odds themselves have a ceiling chosen by design (5% Nghịch Thiên,
    # 15% Tuyệt Luân). Mị Lực is not capped: excess still increases the daily
    # enhanced-Nghịch-Thiên allowance.
    var t := clampf(maxf(charisma, 0.0) / GUIDANCE_QUALITY_FULL_CHARM, 0.0, 1.0)
    var rates: Dictionary = {}
    for quality in DiscipleGeneratorV2.VALID_QUALITIES:
        var key := str(quality)
        rates[key] = lerpf(float(GUIDANCE_BASE_RATES[key]), float(GUIDANCE_MAX_RATES[key]), t)
    return rates

func guidance_base_quality_rates() -> Dictionary:
    return GUIDANCE_BASE_RATES.duplicate(true)

func guidance_current_quality_rates(state: SimulationState) -> Dictionary:
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return guidance_base_quality_rates()
    var data := _guidance_state(platform)
    if int(data.get("snapshot_day_index", -1)) != guidance_day_index(state):
        return guidance_base_quality_rates()
    if not _guidance_enhanced_active(data):
        return guidance_base_quality_rates()
    return guidance_quality_rates_for_charisma(float(data.get("snapshot_main_charisma", 0.0)))

func guidance_enhanced_heaven_daily_limit(charisma: float) -> int:
    var effective := maxf(charisma, 0.0)
    if effective <= 0.0:
        return 0
    return maxi(1, int(ceil(effective / GUIDANCE_HEAVEN_QUOTA_STEP)))

func guidance_daily_arrival_target(state: SimulationState) -> int:
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return 0
    var data := _guidance_state(platform)
    var total := building_system.guidance_base_daily_arrivals(platform)
    var max_assistants := maxi(building_system.guidance_elder_slots(platform) - 1, 0)
    var assistants: Array = data.get("assistant_guide_ids", [])
    for index in range(mini(assistants.size(), max_assistants)):
        var disciple = state.disciples.get(StringName(str(assistants[index])))
        if not (disciple is DiscipleState) or not guidance_guide_eligible(state, disciple.id):
            continue
        var effective := maxf(disciple.charisma, 0.0)
        total += int(floor(effective / GUIDANCE_ASSISTANT_VISITOR_STEP))
    return maxi(total, 0)

func begin_guidance_day(state: SimulationState, generate_arrivals: bool = true) -> Dictionary:
    if not _guidance_available(state):
        return _result(false, "guidance_disabled")
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return _result(false, "guidance_platform_missing")
    var data := _guidance_state(platform)
    _begin_guidance_day(state, platform, data, guidance_day_index(state), generate_arrivals)
    var result := _result(true, "day_started")
    result["arrival_target"] = int(platform.production_state.get("daily_arrival_target", 0))
    result["arrivals_generated"] = int(platform.production_state.get("daily_arrivals_generated", 0))
    return result

func guidance_recruit_with_order(state: SimulationState) -> Dictionary:
    if not _guidance_available(state):
        return _result(false, "guidance_disabled")
    if state.sect.disciple_recruitment_tokens <= 0:
        return _result(false, "not_enough_recruitment_tokens")
    # A paid order must never debit before both free slots and current-day
    # arrivals (which can fill the queue) have been accounted for.
    if state.recruitment_candidates.size() >= C2_QUEUE_CAP:
        return _result(false, "candidate_queue_full")
    _ensure_guidance_day_snapshot(state)
    if state.recruitment_candidates.size() >= C2_QUEUE_CAP:
        return _result(false, "candidate_queue_full")
    state.sect.disciple_recruitment_tokens -= 1
    var candidate := _generate_guidance_candidate(state)
    if candidate == null:
        state.sect.disciple_recruitment_tokens += 1
        return _result(false, "generation_failed")
    var result := _result(true, "guidance_order")
    result["candidate_id"] = str(candidate.id)
    result["quality"] = str(candidate.disciple_quality)
    result["remaining_tokens"] = state.sect.disciple_recruitment_tokens
    return result

func guidance_state_snapshot(state: SimulationState) -> Dictionary:
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return {}
    return _guidance_state(platform).duplicate(true)

func validate_guidance_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.guidance_recruitment_enabled:
        return errors
    if not state.sect.foundation_points_enabled:
        errors.append("Dẫn Tiên recruitment requires open-point foundations.")
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        errors.append("Dẫn Tiên recruitment is enabled without a Dẫn Tiên Đài.")
        return errors
    var data := _guidance_state(platform)
    var main_id := str(data.get("main_guide_id", ""))
    if main_id != "" and not state.disciples.has(StringName(main_id)):
        errors.append("Dẫn Tiên main guide references a missing disciple.")
    var assistants: Array = data.get("assistant_guide_ids", [])
    if assistants.size() > maxi(building_system.guidance_elder_slots(platform) - 1, 0):
        errors.append("Dẫn Tiên has more assistant guides than slots.")
    var seen: Dictionary = {}
    for raw_id in assistants:
        var disciple_id := str(raw_id)
        if disciple_id == "" or disciple_id == main_id or seen.has(disciple_id) or not state.disciples.has(StringName(disciple_id)):
            errors.append("Dẫn Tiên has an invalid assistant guide assignment.")
            break
        seen[disciple_id] = true
    var count := int(data.get("enhanced_heaven_count", 0))
    var daily_limit := guidance_enhanced_heaven_daily_limit(float(data.get("snapshot_main_charisma", 0.0)))
    if count < 0 or count > daily_limit:
        errors.append("Dẫn Tiên enhanced Nghịch Thiên daily counter is invalid.")
    return errors

func _guidance_available(state: SimulationState) -> bool:
    return state.p1_recruitment_enabled and state.sect.disciple_generation_v2_enabled and state.sect.guidance_recruitment_enabled and state.p3_7_buildings_enabled

func _guidance_state(platform: BuildingState) -> Dictionary:
    var raw = platform.production_state
    var data: Dictionary = raw.duplicate(true) if raw is Dictionary else {}
    data["main_guide_id"] = str(data.get("main_guide_id", ""))
    var assistants: Array = []
    var raw_assistants = data.get("assistant_guide_ids", [])
    if raw_assistants is Array:
        for raw_id in raw_assistants:
            var text_id := str(raw_id)
            if text_id != "" and not assistants.has(text_id):
                assistants.append(text_id)
    assistants.sort()
    data["assistant_guide_ids"] = assistants
    data["snapshot_day_index"] = int(data.get("snapshot_day_index", -1))
    data["snapshot_main_charisma"] = maxf(float(data.get("snapshot_main_charisma", 0.0)), 0.0)
    data["enhanced_heaven_count"] = maxi(int(data.get("enhanced_heaven_count", 0)), 0)
    data["daily_arrival_target"] = maxi(int(data.get("daily_arrival_target", 0)), 0)
    data["daily_arrivals_generated"] = maxi(int(data.get("daily_arrivals_generated", 0)), 0)
    platform.production_state = data
    return data

func _guidance_enhanced_active(data: Dictionary) -> bool:
    var charm := maxf(float(data.get("snapshot_main_charisma", 0.0)), 0.0)
    var limit := guidance_enhanced_heaven_daily_limit(charm)
    return limit > 0 and int(data.get("enhanced_heaven_count", 0)) < limit

func _ensure_guidance_day_snapshot(state: SimulationState) -> void:
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return
    var data := _guidance_state(platform)
    var day_index := guidance_day_index(state)
    if int(data.get("snapshot_day_index", -1)) != day_index:
        _begin_guidance_day(state, platform, data, day_index, true)

func _begin_guidance_day(state: SimulationState, platform: BuildingState, data: Dictionary, day_index: int, generate_arrivals: bool) -> void:
    var main_id := str(data.get("main_guide_id", ""))
    var main_charisma := 0.0
    var main = state.disciples.get(StringName(main_id))
    if main is DiscipleState and guidance_guide_eligible(state, main.id):
        main_charisma = maxf(main.charisma, 0.0)
        if SectHallSystemV1.installed(state) and SectHallSystemV1.holder_id(state, SectHallSystemV1.OFFICE_GUIDE) == str(main.id):
            main_charisma += SectHallSystemV1.role_effect(state, SectHallSystemV1.OFFICE_GUIDE)

    data["snapshot_day_index"] = day_index
    data["snapshot_main_charisma"] = main_charisma
    data["enhanced_heaven_count"] = 0
    platform.production_state = data
    data["daily_arrival_target"] = guidance_daily_arrival_target(state)
    data["daily_arrivals_generated"] = 0
    platform.production_state = data
    state.building_event_count += 1

    if generate_arrivals:
        var target := int(data.get("daily_arrival_target", 0))
        for _i in range(target):
            # Free arrivals are day-scoped, not an infinite hidden backlog.
            # Do not discard or reroll any candidate already materialized.
            if state.recruitment_candidates.size() >= C2_QUEUE_CAP:
                break
            if _generate_guidance_candidate(state) == null:
                break
            data = _guidance_state(platform)
            data["daily_arrivals_generated"] = int(data.get("daily_arrivals_generated", 0)) + 1
            platform.production_state = data

func _generate_guidance_candidate(state: SimulationState) -> CandidateState:
    var platform := building_system.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return null
    var data := _guidance_state(platform)
    var enhanced_active := _guidance_enhanced_active(data)
    var rates := guidance_quality_rates_for_charisma(float(data.get("snapshot_main_charisma", 0.0))) if enhanced_active else guidance_base_quality_rates()
    var generation_index := state.recruitment_generation_index + 1
    var roll := _stable_guidance_roll(state.seed, generation_index, int(data.get("snapshot_day_index", 0)))
    var quality := _quality_from_rates(rates, roll)
    var candidate := _generate_open_candidate_with_quality(state, quality)
    if candidate == null:
        return null
    if enhanced_active and quality == DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
        data = _guidance_state(platform)
        data["enhanced_heaven_count"] = int(data.get("enhanced_heaven_count", 0)) + 1
        platform.production_state = data
    return candidate

func _generate_open_candidate_with_quality(state: SimulationState, quality: StringName) -> CandidateState:
    var generation_index := state.recruitment_generation_index + 1
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,
        DiscipleGeneratorV2.SOURCE_ORDINARY,
        generation_index,
        quality
    )
    if candidate == null:
        return null
    state.recruitment_generation_index = generation_index
    state.recruitment_candidates[candidate.id] = candidate
    state.sect.disciple_generation_event_count += 1
    if not state.sect.disciple_v2_birth_enabled:
        if state.sect.disciple_traits_enabled:
            TraitSystem.new().ensure_candidate_profile(state, candidate)
        if state.sect.spiritual_root_refinement_enabled:
            RootRefinementSystem.new().ensure_candidate_profile(state, candidate)
        if state.sect.bloodlines_enabled:
            BloodlineSystem.new().ensure_candidate_profile(state, candidate)
        if state.sect.physiques_enabled:
            PhysiqueSystem.new().ensure_candidate_profile(state, candidate)
    if state.p3_7_buildings_enabled:
        WorkforceSystem.new().ensure_p3_7_candidate_profile(state, candidate)
    if state.sect.disciple_v2_birth_enabled:
        DiscipleBirthRollV2.sync_profession_talent(candidate.v2_birth_profile, candidate)
    return candidate

func _quality_from_rates(rates: Dictionary, roll: float) -> StringName:
    var cursor := clampf(roll, 0.0, 0.999999999)
    var cumulative := 0.0
    for quality in DiscipleGeneratorV2.VALID_QUALITIES:
        cumulative += maxf(float(rates.get(str(quality), 0.0)), 0.0)
        if cursor < cumulative:
            return quality
    return DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING

func _stable_guidance_roll(seed_value: int, generation_index: int, day_index: int) -> float:
    var text := "%d|guidance|%d|%d" % [seed_value, generation_index, day_index]
    var value := 17
    for index in range(text.length()):
        value = int((value * 131 + text.unicode_at(index)) % 2147483629)
    return float(value % 1000000) / 1000000.0
