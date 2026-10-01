extends SceneTree

const TEST_SEED := 2031222
const SAVE_PATH := "user://p2_12_physique_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_p2_11_gate_unchanged():
        return
    if not _verify_profiles_are_deterministic_and_ordinary_is_stable():
        return
    if not _verify_grade_schema_probabilities_and_scaling():
        return
    if not _verify_special_physiques_have_real_value():
        return
    if not _verify_tempering_and_transformation_use_real_resources():
        return
    if not _verify_sword_bone_path_and_drawback():
        return
    if not _verify_diamond_body_defense_and_slow_cultivation():
        return
    if not _verify_cold_yin_root_synergy():
        return
    if not _verify_fire_spirit_root_synergy():
        return
    if not _verify_overlap_stacks_with_bloodline():
        return
    if not _verify_recruitment_profile_lifecycle():
        return
    if not _verify_persistence_and_continuation():
        return

    print("P2.12 PHYSIQUE + GRADES + TEMPERING + TRANSFORMATION TEST PASS")
    quit(0)

func _verify_p2_11_gate_unchanged() -> bool:
    var legacy := P211Factory.create_state(TEST_SEED)
    if legacy.sect.physiques_enabled:
        return _fail("P2.11 must remain physique-disabled.")
    if not legacy.sect.physique_profiles.is_empty():
        return _fail("P2.12 physique state leaked into P2.11.")
    return true

func _verify_profiles_are_deterministic_and_ordinary_is_stable() -> bool:
    var state_a := P212Factory.create_state(TEST_SEED + 1)
    var state_b := P212Factory.create_state(TEST_SEED + 1)
    if state_a.sect.physique_profiles != state_b.sect.physique_profiles:
        return _fail("P2.12 same-seed physique profiles diverged.")

    var probe_state := P211Factory.create_state(TEST_SEED + 2)
    probe_state.sect.physiques_enabled = true
    var generator := DiscipleGeneratorV2.new()
    var system := PhysiqueSystem.new()
    var found_ordinary := false
    for index in range(20, 140):
        var candidate := generator.generate_candidate(probe_state, DiscipleGeneratorV2.SOURCE_ORDINARY, index)
        var first := system.ensure_candidate_profile(probe_state, candidate).duplicate(true)
        var grade := StringName(first.get("physique_grade", ""))
        if not PhysiqueSystem.VALID_GRADES.has(grade):
            return _fail("P2.12 generated candidate has no valid physique grade.")
        if StringName(first.get("physique_id", "ordinary_body")) == PhysiqueSystem.PHYSIQUE_ORDINARY:
            var second := system.ensure_candidate_profile(probe_state, candidate).duplicate(true)
            if first != second:
                return _fail("P2.12 ordinary-body result was rerolled.")
            var latent := StringName(first.get("latent_transformation", ""))
            if not PhysiqueSystem.SPECIAL_PHYSIQUES.has(latent):
                return _fail("P2.12 ordinary body lacks a deterministic future transformation route.")
            found_ordinary = true
            break
    if not found_ordinary:
        return _fail("P2.12 deterministic sample could not produce a valid ordinary-body candidate.")
    return true

func _verify_grade_schema_probabilities_and_scaling() -> bool:
    var system := PhysiqueSystem.new()
    var sources := [
        DiscipleGeneratorV2.SOURCE_ORDINARY,
        DiscipleGeneratorV2.SOURCE_GACHA,
        DiscipleGeneratorV2.SOURCE_FATE
    ]
    for source_value in sources:
        var source := StringName(source_value)
        var rates := system.grade_rates_for_source(source)
        var total := 0.0
        for grade_value in PhysiqueSystem.VALID_GRADES:
            var grade := StringName(grade_value)
            if not rates.has(str(grade)):
                return _fail("P2.12 source %s is missing grade rate %s." % [source, grade])
            var rate := float(rates.get(str(grade), -1.0))
            if rate < 0.0:
                return _fail("P2.12 source %s has negative physique-grade probability." % source)
            total += rate
        if absf(total - 1.0) > 0.000001:
            return _fail("P2.12 source %s physique-grade probabilities do not sum to 1." % source)

    var ordinary_divine := float(system.grade_rates_for_source(DiscipleGeneratorV2.SOURCE_ORDINARY).get("divine_body", 0.0))
    var gacha_divine := float(system.grade_rates_for_source(DiscipleGeneratorV2.SOURCE_GACHA).get("divine_body", 0.0))
    var fate_divine := float(system.grade_rates_for_source(DiscipleGeneratorV2.SOURCE_FATE).get("divine_body", 0.0))
    if not (ordinary_divine < gacha_divine and gacha_divine < fate_divine):
        return _fail("P2.12 Thần Thể probability must increase ordinary -> gacha -> fate.")

    var state := P212Factory.create_state(TEST_SEED + 31)
    var mortal := _probe_disciple("grade_mortal")
    var divine := _probe_disciple("grade_divine")
    mortal.spiritual_root_elements = ["fire"]
    divine.spiritual_root_elements = ["fire"]
    state.disciples[mortal.id] = mortal
    state.disciples[divine.id] = divine
    _neutralize_bloodline(state, mortal.id)
    _neutralize_bloodline(state, divine.id)
    _set_physique(state, mortal.id, PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT, 2, false, "", PhysiqueSystem.GRADE_MORTAL)
    _set_physique(state, divine.id, PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT, 2, false, "", PhysiqueSystem.GRADE_DIVINE)
    var mortal_stats := system.stat_profile(state, mortal)
    var divine_stats := system.stat_profile(state, divine)
    if float(divine_stats.get("attack_bonus", 0.0)) <= float(mortal_stats.get("attack_bonus", 0.0)):
        return _fail("P2.12 Thần Thể grade does not increase real Công versus same-type Phàm Thể.")
    if float(divine_stats.get("cultivation_multiplier", 1.0)) <= float(mortal_stats.get("cultivation_multiplier", 1.0)):
        return _fail("P2.12 Thần Thể grade does not increase real cultivation versus same-type Phàm Thể.")
    if system.display_physique(state, divine.id) != "Hỏa Linh Thể · Thần Thể":
        return _fail("P2.12 special physique + grade display contract is incorrect.")

    var generic := _probe_disciple("generic_spirit_body")
    state.disciples[generic.id] = generic
    _neutralize_bloodline(state, generic.id)
    _set_physique(state, generic.id, PhysiqueSystem.PHYSIQUE_ORDINARY, 0, false, PhysiqueSystem.PHYSIQUE_SWORD_BONE, PhysiqueSystem.GRADE_SPIRIT)
    if system.display_physique(state, generic.id) != "Linh Thể":
        return _fail("P2.12 unnamed ordinary physique should display only its grade, not duplicate body labels.")
    return true

func _verify_special_physiques_have_real_value() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 3)
    var system := PhysiqueSystem.new()
    var ids := [
        PhysiqueSystem.PHYSIQUE_SWORD_BONE,
        PhysiqueSystem.PHYSIQUE_DIAMOND_OVERLORD,
        PhysiqueSystem.PHYSIQUE_COLD_YIN,
        PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT,
        PhysiqueSystem.PHYSIQUE_PURE_DAO
    ]
    for physique_value in ids:
        var id := StringName(physique_value)
        var actor := _probe_disciple("value_%s" % str(id))
        actor.spiritual_root_elements = ["water", "fire"]
        state.disciples[actor.id] = actor
        _neutralize_bloodline(state, actor.id)
        _set_physique(state, actor.id, id, 2, false, "")
        var stats := system.stat_profile(state, actor)
        var has_attack_or_defense := float(stats.get("attack_bonus", 0.0)) > 0.000001 or float(stats.get("incoming_damage_multiplier", 1.0)) < 0.999999
        if not has_attack_or_defense:
            return _fail("P2.12 %s has no direct Công/Thủ advantage." % system.physique_name(id))
        var beneficial_axes := 0
        if float(stats.get("attack_bonus", 0.0)) > 0.000001:
            beneficial_axes += 1
        if float(stats.get("incoming_damage_multiplier", 1.0)) < 0.999999:
            beneficial_axes += 1
        if float(stats.get("cultivation_multiplier", 1.0)) > 1.000001:
            beneficial_axes += 1
        if float(stats.get("breakthrough_bonus", 0.0)) > 0.000001:
            beneficial_axes += 1
        if float(stats.get("recovery_multiplier", 1.0)) > 1.000001:
            beneficial_axes += 1
        if maxf(float(stats.get("sword_xp_multiplier", 1.0)), maxf(float(stats.get("body_xp_multiplier", 1.0)), float(stats.get("spell_xp_multiplier", 1.0)))) > 1.000001:
            beneficial_axes += 1
        if beneficial_axes < 2:
            return _fail("P2.12 %s has fewer than two meaningful beneficial axes." % system.physique_name(id))
    return true

func _verify_tempering_and_transformation_use_real_resources() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 4)
    var actor := _probe_disciple("transform_probe")
    state.disciples[actor.id] = actor
    _neutralize_bloodline(state, actor.id)
    _set_physique(state, actor.id, PhysiqueSystem.PHYSIQUE_ORDINARY, 2, false, PhysiqueSystem.PHYSIQUE_SWORD_BONE)
    state.sect.technique_materials[PhysiqueSystem.TEMPER_MATERIAL_ID] = 3
    state.sect.technique_materials[PhysiqueSystem.TRANSFORM_MATERIAL_ID] = 5
    var system := PhysiqueSystem.new()
    var before_stats := system.stat_profile(state, actor)
    var grade_before := system.physique_grade(state, actor.id)
    var yao_before := int(state.sect.technique_materials.get(PhysiqueSystem.TEMPER_MATERIAL_ID, 0))
    var temper_result := system.temper_body(state, actor.id)
    if not bool(temper_result.get("ok", false)):
        return _fail("P2.12 tempering failed.")
    if int(state.sect.technique_materials.get(PhysiqueSystem.TEMPER_MATERIAL_ID, 0)) != yao_before - 1:
        return _fail("P2.12 tempering did not consume exactly one real Yêu Đan.")
    if system.temper_level(state, actor.id) != 3:
        return _fail("P2.12 tempering did not increase temper level.")
    var after_stats := system.stat_profile(state, actor)
    if float(after_stats.get("attack_bonus", 0.0)) <= float(before_stats.get("attack_bonus", 0.0)):
        return _fail("P2.12 tempering increased a number but not real body stats.")

    var latent_before := StringName(system.profile_for(state, actor.id).get("latent_transformation", ""))
    var linh_tuy_before := int(state.sect.technique_materials.get(PhysiqueSystem.TRANSFORM_MATERIAL_ID, 0))
    var transform_result := system.transform_body(state, actor.id)
    if not bool(transform_result.get("ok", false)):
        return _fail("P2.12 body transformation failed.")
    if int(state.sect.technique_materials.get(PhysiqueSystem.TRANSFORM_MATERIAL_ID, 0)) != linh_tuy_before - PhysiqueSystem.TRANSFORM_MATERIAL_COST:
        return _fail("P2.12 transformation did not consume the configured real Linh Tủy cost.")
    var profile := system.profile_for(state, actor.id)
    if StringName(profile.get("physique_id", "")) != latent_before:
        return _fail("P2.12 transformation rerolled the pre-generated target.")
    if system.physique_grade(state, actor.id) != grade_before:
        return _fail("P2.12 transformation unexpectedly rerolled physique grade.")
    if not bool(profile.get("transformed", false)):
        return _fail("P2.12 transformed body did not record its history.")
    return true

func _verify_sword_bone_path_and_drawback() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 5)
    state.sect.lodging_capacity = 20
    var neutral := _probe_disciple("sword_neutral")
    var sword := _probe_disciple("sword_bone")
    state.disciples[neutral.id] = neutral
    state.disciples[sword.id] = sword
    _neutralize_bloodline(state, neutral.id)
    _neutralize_bloodline(state, sword.id)
    _set_physique(state, neutral.id, PhysiqueSystem.PHYSIQUE_ORDINARY, 0, false, PhysiqueSystem.PHYSIQUE_SWORD_BONE)
    _set_physique(state, sword.id, PhysiqueSystem.PHYSIQUE_SWORD_BONE, 0, false, "")

    var paths := CultivationPathSystem.new()
    var neutral_gain := paths.add_experience(state, neutral, CultivationPathSystem.PATH_SWORD, 10.0)
    var sword_gain := paths.add_experience(state, sword, CultivationPathSystem.PATH_SWORD, 10.0)
    if sword_gain <= neutral_gain:
        return _fail("P2.12 Kiếm Cốt does not accelerate real Sword path experience.")

    neutral.hp = 50.0
    sword.hp = 50.0
    neutral.stamina = 20.0
    sword.stamina = 20.0
    var needs := NeedsSystem.new()
    var neutral_recovery := needs.apply_rest(state, neutral)
    var sword_recovery := needs.apply_rest(state, sword)
    if sword_recovery >= neutral_recovery:
        return _fail("P2.12 Kiếm Cốt drawback is not real: recovery should be slightly worse before tempering.")
    return true

func _verify_diamond_body_defense_and_slow_cultivation() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 6)
    var neutral := _probe_disciple("diamond_neutral")
    var diamond := _probe_disciple("diamond_body")
    state.disciples[neutral.id] = neutral
    state.disciples[diamond.id] = diamond
    _neutralize_bloodline(state, neutral.id)
    _neutralize_bloodline(state, diamond.id)
    _set_physique(state, neutral.id, PhysiqueSystem.PHYSIQUE_ORDINARY, 0, false, PhysiqueSystem.PHYSIQUE_DIAMOND_OVERLORD)
    _set_physique(state, diamond.id, PhysiqueSystem.PHYSIQUE_DIAMOND_OVERLORD, 0, false, "")
    var system := PhysiqueSystem.new()
    if system.incoming_damage_multiplier(state, diamond) >= system.incoming_damage_multiplier(state, neutral):
        return _fail("P2.12 Kim Cương Bá Thể has no real defensive advantage.")
    var cultivation := CultivationSystem.new()
    neutral.cultivation_progress = 0.0
    diamond.cultivation_progress = 0.0
    var neutral_gain := cultivation.add_progress(state, neutral, 20.0)
    var diamond_gain := cultivation.add_progress(state, diamond, 20.0)
    if diamond_gain >= neutral_gain:
        return _fail("P2.12 Kim Cương Bá Thể drawback is not real: cultivation should be slower.")
    return true

func _verify_cold_yin_root_synergy() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 7)
    var matched := _probe_disciple("cold_water")
    var mismatched := _probe_disciple("cold_fire")
    matched.spiritual_root_elements = ["water"]
    mismatched.spiritual_root_elements = ["fire"]
    state.disciples[matched.id] = matched
    state.disciples[mismatched.id] = mismatched
    _neutralize_bloodline(state, matched.id)
    _neutralize_bloodline(state, mismatched.id)
    _set_physique(state, matched.id, PhysiqueSystem.PHYSIQUE_COLD_YIN, 0, false, "")
    _set_physique(state, mismatched.id, PhysiqueSystem.PHYSIQUE_COLD_YIN, 0, false, "")
    var system := PhysiqueSystem.new()
    var good := system.stat_profile(state, matched)
    var bad := system.stat_profile(state, mismatched)
    if float(good.get("cultivation_multiplier", 1.0)) <= float(bad.get("cultivation_multiplier", 1.0)):
        return _fail("P2.12 Hàn Âm Thể does not gain real Water-root cultivation synergy.")
    if float(good.get("recovery_multiplier", 1.0)) <= float(bad.get("recovery_multiplier", 1.0)):
        return _fail("P2.12 Hàn Âm Thể mismatch has no real cold-energy recovery penalty.")
    return true

func _verify_fire_spirit_root_synergy() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 8)
    var matched := _probe_disciple("fire_match")
    var mismatched := _probe_disciple("fire_mismatch")
    matched.spiritual_root_elements = ["fire"]
    mismatched.spiritual_root_elements = ["water"]
    state.disciples[matched.id] = matched
    state.disciples[mismatched.id] = mismatched
    _neutralize_bloodline(state, matched.id)
    _neutralize_bloodline(state, mismatched.id)
    _set_physique(state, matched.id, PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT, 0, false, "")
    _set_physique(state, mismatched.id, PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT, 0, false, "")
    var system := PhysiqueSystem.new()
    var good := system.stat_profile(state, matched)
    var bad := system.stat_profile(state, mismatched)
    if float(good.get("attack_bonus", 0.0)) <= float(bad.get("attack_bonus", 0.0)):
        return _fail("P2.12 Hỏa Linh Thể does not gain real Fire-root attack synergy.")
    if float(good.get("cultivation_multiplier", 1.0)) <= float(bad.get("cultivation_multiplier", 1.0)):
        return _fail("P2.12 Hỏa Linh Thể does not gain real Fire-root cultivation synergy.")
    return true

func _verify_overlap_stacks_with_bloodline() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 9)
    var physique_only := _probe_disciple("stack_physique")
    var bloodline_only := _probe_disciple("stack_bloodline")
    var combined := _probe_disciple("stack_combined")
    var actors: Array[DiscipleState] = [physique_only, bloodline_only, combined]
    for actor in actors:
        state.disciples[actor.id] = actor
        actor.spiritual_root_elements = ["fire"]

    _set_physique(state, physique_only.id, PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT, 2, false, "")
    _set_physique(state, bloodline_only.id, PhysiqueSystem.PHYSIQUE_ORDINARY, 0, false, PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT)
    _set_physique(state, combined.id, PhysiqueSystem.PHYSIQUE_FIRE_SPIRIT, 2, false, "")
    _set_bloodline(state, physique_only.id, BloodlineSystem.BLOODLINE_NONE, 0.0, false)
    _set_bloodline(state, bloodline_only.id, BloodlineSystem.BLOODLINE_TRUE_DRAGON, 0.50, true)
    _set_bloodline(state, combined.id, BloodlineSystem.BLOODLINE_TRUE_DRAGON, 0.50, true)

    var cultivation := CultivationSystem.new()
    var physique_power := cultivation.effective_combat_power(state, physique_only)
    var bloodline_power := cultivation.effective_combat_power(state, bloodline_only)
    var combined_power := cultivation.effective_combat_power(state, combined)
    if combined_power <= physique_power or combined_power <= bloodline_power:
        return _fail("P2.12 overlap rule broken: Bloodline + Physique Công does not stack.")

    physique_only.cultivation_progress = 0.0
    bloodline_only.cultivation_progress = 0.0
    combined.cultivation_progress = 0.0
    var physique_gain := cultivation.add_progress(state, physique_only, 20.0)
    var bloodline_gain := cultivation.add_progress(state, bloodline_only, 20.0)
    var combined_gain := cultivation.add_progress(state, combined, 20.0)
    if combined_gain <= physique_gain or combined_gain <= bloodline_gain:
        return _fail("P2.12 overlap rule broken: Bloodline + Physique cultivation bonuses do not stack.")
    return true

func _verify_recruitment_profile_lifecycle() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 10)
    state.sect.disciple_capacity += 3
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.size() < 2:
        return _fail("P2.12 recruitment lifecycle needs at least two candidates.")
    var accepted_id := StringName(ids[0])
    var rejected_id := StringName(ids[1])
    var system := PhysiqueSystem.new()
    var accepted_profile := system.profile_for(state, accepted_id).duplicate(true)
    if accepted_profile.is_empty():
        return _fail("P2.12 candidate has no physique profile.")
    if not bool(RecruitmentSystem.new().accept_candidate(state, accepted_id).get("ok", false)):
        return _fail("P2.12 could not accept candidate.")
    if system.profile_for(state, accepted_id) != accepted_profile:
        return _fail("P2.12 candidate -> disciple acceptance changed physique identity/grade.")
    if not bool(RecruitmentSystem.new().reject_candidate(state, rejected_id).get("ok", false)):
        return _fail("P2.12 could not reject candidate.")
    if not system.profile_for(state, rejected_id).is_empty():
        return _fail("P2.12 rejected candidate left an orphan physique profile.")
    return true

func _verify_persistence_and_continuation() -> bool:
    var state_a := P212Factory.create_state(TEST_SEED + 11)
    var actor := _accept_first_candidate(state_a)
    if actor == null:
        return _fail("P2.12 persistence probe could not accept candidate.")
    _set_physique(state_a, actor.id, PhysiqueSystem.PHYSIQUE_ORDINARY, 2, false, PhysiqueSystem.PHYSIQUE_DIAMOND_OVERLORD, PhysiqueSystem.GRADE_MYSTIC)
    state_a.sect.technique_materials[PhysiqueSystem.TEMPER_MATERIAL_ID] = 5
    state_a.sect.technique_materials[PhysiqueSystem.TRANSFORM_MATERIAL_ID] = 5
    var system := PhysiqueSystem.new()
    system.temper_body(state_a, actor.id)
    system.transform_body(state_a, actor.id)

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P2.12 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.physiques_enabled:
        return _fail("P2.12 save did not restore physique feature state.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.12 exact save/load state diverged.")
    if system.physique_grade(loaded, actor.id) != PhysiqueSystem.GRADE_MYSTIC:
        return _fail("P2.12 save/load did not preserve Huyền Thể grade.")

    SimulationScheduler.new(state_a).run_ticks(80)
    SimulationScheduler.new(loaded).run_ticks(80)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.12 deterministic continuation diverged after save/load.")
    var errors := _all_invariants(loaded)
    if not errors.is_empty():
        return _fail("P2.12 invariant failure after continuation: %s" % " | ".join(errors))
    _cleanup()
    return true

func _accept_first_candidate(state: SimulationState) -> DiscipleState:
    state.sect.disciple_capacity += 2
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        return null
    var candidate_id := StringName(ids[0])
    var result := RecruitmentSystem.new().accept_candidate(state, candidate_id)
    if not bool(result.get("ok", false)):
        return null
    return state.disciples.get(candidate_id)

func _probe_disciple(id_text: String) -> DiscipleState:
    return DiscipleState.new({
        "id":id_text,
        "name":id_text,
        "profile_seed":101,
        "recruitment_source":"ordinary",
        "latent_identity_seed":303,
        "combat_power":18.0,
        "potential":0.60,
        "aptitude":0.55,
        "spiritual_root_quality":"ordinary",
        "spiritual_root_purity":0.55,
        "spiritual_root_elements":["fire"],
        "cultivation_stage_index":8,
        "cultivation_progress":0.0,
        "cultivation_combat_bonus":8.0,
        "cultivation_hp_bonus":16.0,
        "hp":116.0,
        "max_hp":116.0,
        "stamina":100.0,
        "cultivation_path_xp":{"sword":0.0, "body":0.0, "spell":0.0}
    })

func _set_physique(state: SimulationState, character_id: StringName, id: StringName, level: int, transformed: bool, latent: StringName, grade: StringName = PhysiqueSystem.GRADE_MORTAL) -> void:
    state.sect.physique_profiles[str(character_id)] = {
        "initialized":true,
        "physique_id":str(id),
        "physique_grade":str(grade),
        "initial_physique_id":str(PhysiqueSystem.PHYSIQUE_ORDINARY) if transformed else str(id),
        "temper_level":level,
        "transformed":transformed,
        "latent_transformation":str(latent) if latent != &"" else (str(id) if transformed else "")
    }

func _neutralize_bloodline(state: SimulationState, character_id: StringName) -> void:
    _set_bloodline(state, character_id, BloodlineSystem.BLOODLINE_NONE, 0.0, false)

func _set_bloodline(state: SimulationState, character_id: StringName, id: StringName, purity: float, awakened: bool) -> void:
    state.sect.bloodline_profiles[str(character_id)] = {
        "initialized":true,
        "bloodline_id":str(id),
        "purity":purity,
        "revealed":true,
        "awakened":awakened,
        "refinement_count":0
    }

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
    errors.append_array(TraitSystem.new().validate_invariants(state))
    errors.append_array(RootRefinementSystem.new().validate_invariants(state))
    errors.append_array(BloodlineSystem.new().validate_invariants(state))
    errors.append_array(PhysiqueSystem.new().validate_invariants(state))
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
