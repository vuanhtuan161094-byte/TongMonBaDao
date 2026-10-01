extends SceneTree

const TEST_SEED := 1928282
const SAVE_PATH := "user://p2_8_disciple_generation_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_legacy_gate_unchanged():
        return
    if not _verify_same_seed_profiles():
        return
    if not _verify_sources_and_resources():
        return
    if not _verify_foundation_quality_and_promotion():
        return
    if not _verify_specific_value_can_beat_quality():
        return
    if not _verify_root_axes_are_independent():
        return
    if not _verify_combat_power_is_derived():
        return
    if not _verify_aptitude_has_real_cultivation_consequence():
        return
    if not _verify_accept_preserves_identity():
        return
    if not _verify_persistence_and_continuation():
        return

    print("P2.8 DISCIPLE GENERATION V2 TEST PASS")
    quit(0)

func _verify_legacy_gate_unchanged() -> bool:
    var legacy := P27Factory.create_state(TEST_SEED)
    if legacy.sect.disciple_generation_v2_enabled:
        return _fail("P2.7 must remain generation-v2 disabled.")
    var candidate := RecruitmentSystem.new().generate_candidate(legacy)
    if candidate == null or candidate.profile_seed != 0 or candidate.recruitment_source != &"":
        return _fail("P2.8 feature gate changed legacy P1.2/P2.7 candidate generation.")
    return true

func _verify_same_seed_profiles() -> bool:
    var state_a := P28Factory.create_state(TEST_SEED + 1)
    var state_b := P28Factory.create_state(TEST_SEED + 1)
    if not state_a.sect.disciple_generation_v2_enabled or not state_b.sect.disciple_generation_v2_enabled:
        return _fail("P2.8 factory did not enable generation v2.")
    if _candidate_rows(state_a) != _candidate_rows(state_b):
        return _fail("P2.8 same-seed candidate pool diverged.")
    return true

func _verify_sources_and_resources() -> bool:
    var state := P28Factory.create_state(TEST_SEED + 2)
    var recruitment := RecruitmentSystem.new()
    var tokens_before := state.sect.disciple_recruitment_tokens
    var gacha_result := recruitment.gacha_candidate(state)
    if not bool(gacha_result.get("ok", false)):
        return _fail("P2.8 Chiêu Hiền could not generate a candidate.")
    if state.sect.disciple_recruitment_tokens != tokens_before - 1:
        return _fail("P2.8 Chiêu Hiền did not consume exactly one recruitment token.")
    var gacha_id := StringName(gacha_result.get("candidate_id", ""))
    var gacha_candidate: CandidateState = state.recruitment_candidates.get(gacha_id)
    if gacha_candidate == null or gacha_candidate.recruitment_source != DiscipleGeneratorV2.SOURCE_GACHA:
        return _fail("P2.8 Chiêu Hiền did not use the shared gacha source policy.")

    var fate_result := recruitment.fate_candidate(state)
    if not bool(fate_result.get("ok", false)):
        return _fail("P2.8 Nhân Duyên could not generate a candidate.")
    var fate_id := StringName(fate_result.get("candidate_id", ""))
    var fate_candidate: CandidateState = state.recruitment_candidates.get(fate_id)
    if fate_candidate == null or fate_candidate.recruitment_source != DiscipleGeneratorV2.SOURCE_FATE:
        return _fail("P2.8 Nhân Duyên did not use the shared fate source policy.")
    return true

func _verify_foundation_quality_and_promotion() -> bool:
    var state := P28Factory.create_state(TEST_SEED + 3)
    var candidate: CandidateState = _first_candidate(state)
    if candidate == null:
        return _fail("P2.8 factory has no generated candidate.")
    var generator := DiscipleGeneratorV2.new()
    var errors := generator.validate_candidate(candidate)
    if not errors.is_empty():
        return _fail("P2.8 generated candidate failed identity validation: %s" % " | ".join(errors))

    var original_quality := candidate.disciple_quality
    candidate.combat_power += 999.0
    candidate.cultivation_stage_index = mini(candidate.cultivation_stage_index + 2, 8)
    candidate.profession_traits.append("diligent")
    if generator.recompute_candidate_quality(candidate) != original_quality:
        return _fail("P2.8 quality incorrectly counted combat power, current realm or profession state.")

    var grower := CandidateState.new({
        "aptitude":0.45, "constitution":0.45, "fortune":0.45,
        "comprehension":0.45, "charisma":0.45, "potential":0.45
    })
    var before := generator.recompute_candidate_quality(grower)
    grower.aptitude = 0.76
    grower.constitution = 0.76
    grower.fortune = 0.76
    grower.comprehension = 0.76
    grower.charisma = 0.76
    grower.potential = 0.76
    var after := generator.recompute_candidate_quality(grower)
    if _quality_index(after) <= _quality_index(before):
        return _fail("P2.8 permanent foundation growth could not promote disciple quality.")
    return true

func _verify_specific_value_can_beat_quality() -> bool:
    var generator := DiscipleGeneratorV2.new()
    var specialist := CandidateState.new({
        "aptitude":0.42, "constitution":0.42, "fortune":0.42,
        "comprehension":0.58, "charisma":0.42, "potential":0.42,
        "profession_traits":["forge_talent"]
    })
    var generalist := CandidateState.new({
        "aptitude":0.62, "constitution":0.62, "fortune":0.62,
        "comprehension":0.62, "charisma":0.62, "potential":0.62,
        "profession_traits":[]
    })
    generator.recompute_candidate_quality(specialist)
    generator.recompute_candidate_quality(generalist)
    if _quality_index(specialist.disciple_quality) >= _quality_index(generalist.disciple_quality):
        return _fail("P2.8 suitability probe did not start with lower overall quality.")
    if generator.profession_suitability(specialist, WorkforceSystem.PROF_FORGING) <= generator.profession_suitability(generalist, WorkforceSystem.PROF_FORGING):
        return _fail("P2.8 lower-quality forge specialist could not outperform a higher-quality generalist at forging.")
    return true

func _verify_root_axes_are_independent() -> bool:
    var base_state := P27Factory.create_state(TEST_SEED + 4)
    var generator := DiscipleGeneratorV2.new()
    var count_by_quality: Dictionary = {}
    var found_same_quality_different_count := false
    var found_good_multi_root := false
    for index in range(1, 241):
        var candidate := generator.generate_candidate(base_state, DiscipleGeneratorV2.SOURCE_ORDINARY, index)
        var quality_key := str(candidate.disciple_quality)
        var element_count := candidate.spiritual_root_elements.size()
        if count_by_quality.has(quality_key) and int(count_by_quality[quality_key]) != element_count:
            found_same_quality_different_count = true
        elif not count_by_quality.has(quality_key):
            count_by_quality[quality_key] = element_count
        if candidate.spiritual_root_purity >= 0.65 and element_count >= 2:
            found_good_multi_root = true
        if found_same_quality_different_count and found_good_multi_root:
            break
    if not found_same_quality_different_count:
        return _fail("P2.8 root element count still behaves as if locked to disciple quality.")
    if not found_good_multi_root:
        return _fail("P2.8 could not generate a multi-element root with good purity.")
    return true

func _verify_combat_power_is_derived() -> bool:
    var state := P28Factory.create_state(TEST_SEED + 5)
    var candidate: CandidateState = _first_candidate(state)
    if candidate == null:
        return _fail("P2.8 combat derivation probe has no candidate.")
    var expected_intrinsic := 10.0 + candidate.constitution * 8.0 + candidate.potential * 5.0 + candidate.aptitude * 3.0
    if absf(candidate.combat_power - expected_intrinsic) > 0.000001:
        return _fail("P2.8 combat power is not derived from generated foundation.")
    var stage: Dictionary = CultivationSystem.STAGES[candidate.cultivation_stage_index]
    if absf(candidate.cultivation_combat_bonus - float(stage.get("combat_bonus", 0.0))) > 0.000001:
        return _fail("P2.8 starting realm is not connected to the existing P2.1 combat bonus model.")
    return true

func _verify_aptitude_has_real_cultivation_consequence() -> bool:
    var state := P28Factory.create_state(TEST_SEED + 6)
    var low := DiscipleState.new({
        "id":"low_aptitude", "profile_seed":11, "aptitude":0.20,
        "spiritual_root_quality":"ordinary", "cultivation_stage_index":0
    })
    var high := DiscipleState.new({
        "id":"high_aptitude", "profile_seed":12, "aptitude":0.90,
        "spiritual_root_quality":"ordinary", "cultivation_stage_index":0
    })
    var cultivation := CultivationSystem.new()
    var low_gain := cultivation.add_progress(state, low, 10.0)
    var high_gain := cultivation.add_progress(state, high, 10.0)
    if high_gain <= low_gain:
        return _fail("P2.8 Tư Chất does not measurably change cultivation gain.")
    return true

func _verify_accept_preserves_identity() -> bool:
    var state := P28Factory.create_state(TEST_SEED + 7)
    state.sect.disciple_capacity += 2
    var candidate: CandidateState = _first_candidate(state)
    if candidate == null:
        return _fail("P2.8 acceptance probe has no candidate.")
    var expected := _candidate_identity(candidate)
    var result := RecruitmentSystem.new().accept_candidate(state, candidate.id)
    if not bool(result.get("ok", false)):
        return _fail("P2.8 could not accept generated candidate.")
    var disciple: DiscipleState = state.disciples.get(candidate.id)
    if disciple == null or _disciple_identity(disciple) != expected:
        return _fail("P2.8 candidate -> disciple acceptance changed generated identity.")
    return true

func _verify_persistence_and_continuation() -> bool:
    var state_a := P28Factory.create_state(TEST_SEED + 8)
    state_a.sect.disciple_capacity += 3
    var recruitment := RecruitmentSystem.new()
    recruitment.gacha_candidate(state_a)
    recruitment.fate_candidate(state_a)
    var first: CandidateState = _first_candidate(state_a)
    if first == null or not bool(recruitment.accept_candidate(state_a, first.id).get("ok", false)):
        return _fail("P2.8 persistence probe could not accept candidate.")

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P2.8 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.disciple_generation_v2_enabled:
        return _fail("P2.8 save did not restore feature state.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.8 exact save/load state diverged.")

    var next_a := RecruitmentSystem.new().generate_candidate(state_a, DiscipleGeneratorV2.SOURCE_ORDINARY)
    var next_b := RecruitmentSystem.new().generate_candidate(loaded, DiscipleGeneratorV2.SOURCE_ORDINARY)
    if next_a == null or next_b == null or next_a.to_dict() != next_b.to_dict():
        return _fail("P2.8 deterministic recruitment continuation diverged after load.")

    SimulationScheduler.new(state_a).run_ticks(80)
    SimulationScheduler.new(loaded).run_ticks(80)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.8 deterministic simulation continuation diverged after load.")

    var errors := _all_invariants(loaded)
    if not errors.is_empty():
        return _fail("P2.8 invariant failure after continuation: %s" % " | ".join(errors))
    _cleanup()
    return true

func _candidate_rows(state: SimulationState) -> Array:
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    var rows: Array = []
    for raw_id in ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        rows.append(candidate.to_dict())
    return rows

func _first_candidate(state: SimulationState) -> CandidateState:
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        return null
    return state.recruitment_candidates[ids[0]]

func _candidate_identity(candidate: CandidateState) -> Dictionary:
    return {
        "profile_seed":candidate.profile_seed,
        "source":str(candidate.recruitment_source),
        "race":str(candidate.race_id),
        "sex":str(candidate.sex_id),
        "origin":str(candidate.origin_id),
        "aptitude":candidate.aptitude,
        "constitution":candidate.constitution,
        "fortune":candidate.fortune,
        "comprehension":candidate.comprehension,
        "charisma":candidate.charisma,
        "potential":candidate.potential,
        "quality":str(candidate.disciple_quality),
        "root_quality":str(candidate.spiritual_root_quality),
        "root_purity":candidate.spiritual_root_purity,
        "root_elements":candidate.spiritual_root_elements.duplicate(),
        "profession_traits":candidate.profession_traits.duplicate(),
        "age":candidate.age,
        "base_lifespan":candidate.base_lifespan,
        "max_lifespan":candidate.max_lifespan,
        "latent_seed":candidate.latent_identity_seed,
        "stage":candidate.cultivation_stage_index,
        "progress":candidate.cultivation_progress,
        "combat_power":candidate.combat_power
    }

func _disciple_identity(disciple: DiscipleState) -> Dictionary:
    return {
        "profile_seed":disciple.profile_seed,
        "source":str(disciple.recruitment_source),
        "race":str(disciple.race_id),
        "sex":str(disciple.sex_id),
        "origin":str(disciple.origin_id),
        "aptitude":disciple.aptitude,
        "constitution":disciple.constitution,
        "fortune":disciple.fortune,
        "comprehension":disciple.comprehension,
        "charisma":disciple.charisma,
        "potential":disciple.potential,
        "quality":str(disciple.disciple_quality),
        "root_quality":str(disciple.spiritual_root_quality),
        "root_purity":disciple.spiritual_root_purity,
        "root_elements":disciple.spiritual_root_elements.duplicate(),
        "profession_traits":disciple.profession_traits.duplicate(),
        "age":disciple.age,
        "base_lifespan":disciple.base_lifespan,
        "max_lifespan":disciple.max_lifespan,
        "latent_seed":disciple.latent_identity_seed,
        "stage":disciple.cultivation_stage_index,
        "progress":disciple.cultivation_progress,
        "combat_power":disciple.combat_power
    }

func _quality_index(quality: StringName) -> int:
    return DiscipleGeneratorV2.VALID_QUALITIES.find(quality)

func _all_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    errors.append_array(EquipmentSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    var generator := DiscipleGeneratorV2.new()
    for candidate_value in state.recruitment_candidates.values():
        var candidate: CandidateState = candidate_value
        if candidate.profile_seed > 0:
            errors.append_array(generator.validate_candidate(candidate))
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
