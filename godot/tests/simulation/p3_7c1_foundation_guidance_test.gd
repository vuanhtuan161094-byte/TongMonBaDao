extends SceneTree

const TEST_SEED := 371001
const SAVE_PATH := "user://p3_7c1_foundation_guidance_test.json"

var foundations := FoundationSystem.new()
var recruitment := RecruitmentSystem.new()
var buildings := BuildingSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_legacy_p2_isolation():
        return
    if not _verify_open_point_foundations():
        return
    if not _verify_total_budget_generation():
        return
    if not _verify_foundation_effects_and_overcap_growth():
        return
    if not _verify_guidance_building_and_roles():
        return
    if not _verify_guidance_quality_cap_and_daily_fallback():
        return
    if not _verify_guidance_order_and_persistence():
        return
    print("P3.7C1 FOUNDATION + DAN TIEN RECRUITMENT TEST PASS")
    _cleanup()
    quit(0)

func _verify_legacy_p2_isolation() -> bool:
    var legacy := P212Factory.create_state(TEST_SEED)
    if legacy.sect.foundation_points_enabled or legacy.sect.guidance_recruitment_enabled:
        return _fail("P2.12 unexpectedly enabled P3.7C1 authorities.")
    var ids: Array = legacy.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        return _fail("P2.12 isolation probe has no recruitment candidate.")
    var candidate: CandidateState = legacy.recruitment_candidates[ids[0]]
    if candidate.foundation_model_version != FoundationSystem.MODEL_LEGACY_NORMALIZED:
        return _fail("P2.12 candidate was silently migrated to open-point foundations.")
    return true

func _verify_open_point_foundations() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 1)
    if not state.sect.foundation_points_enabled or not state.sect.guidance_recruitment_enabled:
        return _fail("P37Factory did not enable P3.7C1 authorities.")
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.foundation_model_version != FoundationSystem.MODEL_OPEN_POINTS:
            return _fail("Existing P3.7 disciple did not migrate to open-point foundations.")
        if disciple.foundation_birth_values.is_empty():
            return _fail("Migrated disciple lost immutable birth-foundation history.")
        var errors := foundations.validate_disciple(disciple)
        if not errors.is_empty():
            return _fail("Migrated disciple foundation invariant failed: %s" % " | ".join(errors))
    for candidate_value in state.recruitment_candidates.values():
        var candidate: CandidateState = candidate_value
        if candidate.foundation_model_version != FoundationSystem.MODEL_OPEN_POINTS:
            return _fail("Existing P3.7 candidate did not migrate to open-point foundations.")
        if candidate.foundation_birth_values.is_empty():
            return _fail("Migrated candidate lost birth-foundation history.")
    return true

func _verify_total_budget_generation() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 2)
    var generator := DiscipleGeneratorOpenPoints.new()
    for index in range(1, 81):
        var quality := DiscipleGeneratorV2.VALID_QUALITIES[index % DiscipleGeneratorV2.VALID_QUALITIES.size()]
        var candidate := generator.generate_candidate(state, DiscipleGeneratorV2.SOURCE_ORDINARY, 1000 + index, quality)
        if candidate == null:
            return _fail("Open-point generator returned null.")
        var errors := foundations.validate_candidate(candidate)
        if not errors.is_empty():
            return _fail("Open-point candidate invariant failed: %s" % " | ".join(errors))
        var total := foundations.total_candidate(candidate)
        if candidate.disciple_quality != foundations.quality_for_total(total):
            return _fail("Candidate quality is not derived from current total lục duy.")
        var minimum := floor(total / 12.0)
        var maximum := floor(total / 2.0)
        for value in [candidate.aptitude, candidate.constitution, candidate.fortune, candidate.comprehension, candidate.charisma, candidate.potential]:
            if value + 0.000001 < minimum or value - 0.000001 > maximum:
                return _fail("Birth lục-duy distribution escaped the locked 0.5x..3x-average envelope.")
        if absf(foundations.birth_total(candidate.foundation_birth_values) - total) > 0.000001:
            return _fail("Birth-foundation snapshot does not equal generated total.")
    return true

func _verify_foundation_effects_and_overcap_growth() -> bool:
    if not is_equal_approx(foundations.cultivation_gain_factor(2500.0), 7.25):
        return _fail("Tư Chất 2500 must currently yield x7.25 base cultivation.")
    if not is_equal_approx(foundations.body_training_gain_factor(2500.0), 6.0):
        return _fail("Căn Cốt 2500 must currently yield x6.00 body-training XP.")
    if not is_equal_approx(foundations.learning_gain_factor(2500.0), 4.75):
        return _fail("Thông Tuệ 2500 must currently yield x4.75 learning XP.")
    if not is_equal_approx(foundations.potential_growth_factor(2500.0), 2.25):
        return _fail("Tiềm Lực 2500 must currently yield x2.25 Realm/Body growth stats.")
    if foundations.luck_tier_for_score(foundations.luck_score(0.0, 0.0, 9900)) != FoundationSystem.LUCK_TIER_GREAT_FORTUNE:
        return _fail("Cơ Duyên Great Fortune threshold is not 9900.")
    if foundations.luck_tier_for_score(foundations.luck_score(0.0, 0.0, 9500)) != FoundationSystem.LUCK_TIER_VERY_RARE:
        return _fail("Cơ Duyên Very Rare threshold is not 9500.")
    if foundations.luck_tier_for_score(foundations.luck_score(0.0, 0.0, 8500)) != FoundationSystem.LUCK_TIER_RARE:
        return _fail("Cơ Duyên Rare threshold is not 8500.")
    if foundations.luck_tier_for_score(foundations.luck_score(0.0, 0.0, 6000)) != FoundationSystem.LUCK_TIER_GOOD:
        return _fail("Cơ Duyên Good threshold is not 6000.")

    var state := P37Factory.create_state(TEST_SEED + 3)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var actor: DiscipleState = state.disciples[ids[0]]
    var birth_before := actor.foundation_birth_values.duplicate(true)
    if not foundations.add_permanent_points(actor, FoundationSystem.DIM_APTITUDE, 12000.0):
        return _fail("Permanent Tư Chất growth was rejected.")
    if actor.aptitude <= 10000.0:
        return _fail("Open-point Tư Chất still behaves as if it had a hard cap.")
    if actor.foundation_birth_values != birth_before:
        return _fail("Permanent growth rewrote immutable birth-foundation history.")
    if actor.disciple_quality != foundations.quality_for_total(foundations.total_disciple(actor)):
        return _fail("Permanent foundation growth did not recompute disciple quality.")
    return true

func _verify_guidance_building_and_roles() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 4)
    var platform := buildings.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null or platform.level != 1:
        return _fail("Dẫn Tiên Đài was not created as a real Lv1 building.")
    if buildings.guidance_elder_slots(platform) != 1:
        return _fail("Lv1 Dẫn Tiên Đài must have one guide slot.")

    platform.level = 100
    if buildings.guidance_elder_slots(platform) != 6:
        return _fail("Lv100 Dẫn Tiên Đài must currently expose six guide slots.")
    if buildings.guidance_base_daily_arrivals(platform) != 12:
        return _fail("Lv100 Dẫn Tiên Đài base-arrival curve is wrong.")

    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.size() < 4:
        return _fail("Dẫn Tiên role probe requires at least four disciples.")
    var main: DiscipleState = state.disciples[ids[0]]
    var a: DiscipleState = state.disciples[ids[1]]
    var b: DiscipleState = state.disciples[ids[2]]
    var c: DiscipleState = state.disciples[ids[3]]
    main.charisma = 2500.0
    a.charisma = 500.0
    b.charisma = 1000.0
    c.charisma = 2500.0
    foundations.recompute_disciple_quality(main)
    foundations.recompute_disciple_quality(a)
    foundations.recompute_disciple_quality(b)
    foundations.recompute_disciple_quality(c)

    if not bool(recruitment.assign_guidance_main(state, main.id).get("ok", false)):
        return _fail("Could not assign Dẫn Tiên main guide.")
    if not bool(recruitment.set_guidance_assistants(state, [a.id, b.id, c.id]).get("ok", false)):
        return _fail("Could not assign Dẫn Tiên assistant guides.")
    var started := recruitment.begin_guidance_day(state, false)
    if not bool(started.get("ok", false)):
        return _fail("Could not snapshot Dẫn Tiên day.")
    # Main guide affects quality only. Assistants add 1 + 2 + 5 visitors.
    if int(started.get("arrival_target", -1)) != 20:
        return _fail("Dẫn Tiên daily arrivals incorrectly counted main-guide Mị Lực or assistant contribution.")
    return true

func _verify_guidance_quality_cap_and_daily_fallback() -> bool:
    var max_rates := recruitment.guidance_quality_rates_for_charisma(2500.0)
    var overcap_rates := recruitment.guidance_quality_rates_for_charisma(10000.0)
    if max_rates != overcap_rates:
        return _fail("Dẫn Tiên quality bonus ignored the 2500 effective-Mị-Lực cap.")
    if not is_equal_approx(float(max_rates.get("heaven_defying", 0.0)), 0.05):
        return _fail("Dẫn Tiên Nghịch Thiên boosted rate must cap at 5%.")
    if not is_equal_approx(float(max_rates.get("peerless", 0.0)), 0.15):
        return _fail("Dẫn Tiên Tuyệt Luân boosted rate must cap at 15%.")
    for value in max_rates.values():
        if float(value) <= 0.0:
            return _fail("Dẫn Tiên must never reduce a quality tier to 0%.")
    if recruitment.guidance_enhanced_heaven_daily_limit(2500.0) != 4:
        return _fail("Mị Lực 2500 must currently allow four enhanced Nghịch Thiên hits/day.")
    if recruitment.guidance_enhanced_heaven_daily_limit(1000.0) != 2:
        return _fail("Mị Lực 1000 daily enhanced-Nghịch-Thiên limit is wrong.")

    var state := P37Factory.create_state(TEST_SEED + 5)
    var platform := buildings.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var main: DiscipleState = state.disciples[ids[0]]
    main.charisma = 2500.0
    foundations.recompute_disciple_quality(main)
    recruitment.assign_guidance_main(state, main.id)
    recruitment.begin_guidance_day(state, false)
    var data := recruitment.guidance_state_snapshot(state)
    data["enhanced_heaven_count"] = 4
    platform.production_state = data
    if recruitment.guidance_current_quality_rates(state) != recruitment.guidance_base_quality_rates():
        return _fail("After the daily enhanced Nghịch Thiên quota, rates did not return to normal.")
    return true

func _verify_guidance_order_and_persistence() -> bool:
    var state_a := P37Factory.create_state(TEST_SEED + 6)
    state_a.sect.disciple_recruitment_tokens = 2
    var ids: Array = state_a.disciples.keys()
    ids.sort()
    var main: DiscipleState = state_a.disciples[ids[0]]
    main.charisma = 2500.0
    foundations.recompute_disciple_quality(main)
    recruitment.assign_guidance_main(state_a, main.id)
    recruitment.begin_guidance_day(state_a, false)

    var tokens_before := state_a.sect.disciple_recruitment_tokens
    var result := recruitment.guidance_recruit_with_order(state_a)
    if not bool(result.get("ok", false)):
        return _fail("Chiêu Mộ Lệnh could not recruit through Dẫn Tiên.")
    if state_a.sect.disciple_recruitment_tokens != tokens_before - 1:
        return _fail("Dẫn Tiên did not consume exactly one Chiêu Mộ Lệnh.")
    var candidate_id := StringName(result.get("candidate_id", ""))
    var candidate: CandidateState = state_a.recruitment_candidates.get(candidate_id)
    if candidate == null or candidate.foundation_model_version != FoundationSystem.MODEL_OPEN_POINTS:
        return _fail("Dẫn Tiên Chiêu Mộ Lệnh did not create an open-point whole-person candidate.")

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P3.7C1 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("P3.7C1 load failed.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P3.7C1 exact save/load diverged.")
    if not RecruitmentSystem.new().validate_guidance_invariants(loaded).is_empty():
        return _fail("Dẫn Tiên invariants failed after save/load.")

    SimulationScheduler.new(state_a).run_ticks(10)
    SimulationScheduler.new(loaded).run_ticks(10)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P3.7C1 deterministic continuation diverged after save/load.")

    _cleanup()
    return _validate(loaded)

func _validate(state: SimulationState) -> bool:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    errors.append_array(EquipmentSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    errors.append_array(TraitSystem.new().validate_invariants(state))
    errors.append_array(RootRefinementSystem.new().validate_invariants(state))
    errors.append_array(BloodlineSystem.new().validate_invariants(state))
    errors.append_array(PhysiqueSystem.new().validate_invariants(state))
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(RecruitmentSystem.new().validate_guidance_invariants(state))
    for disciple_value in state.disciples.values():
        errors.append_array(foundations.validate_disciple(disciple_value))
    for candidate_value in state.recruitment_candidates.values():
        var candidate: CandidateState = candidate_value
        if candidate.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
            errors.append_array(foundations.validate_candidate(candidate))
    if not errors.is_empty():
        return _fail("Invariant failure: %s" % " | ".join(errors))
    return true

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
