extends SceneTree

const TEST_SEED := 2030202
const SAVE_PATH := "user://p2_10_root_refinement_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_p2_9_gate_unchanged():
        return
    if not _verify_profiles_are_deterministic():
        return
    if not _verify_refinement_consumes_real_resource_and_preserves_elements():
        return
    if not _verify_quality_bridge_and_technique_consequence():
        return
    if not _verify_purity_changes_cultivation_and_breakthrough():
        return
    if not _verify_specialization_tradeoff():
        return
    if not _verify_hidden_mutation_reveal_and_consequence():
        return
    if not _verify_recruitment_profile_lifecycle():
        return
    if not _verify_persistence_and_continuation():
        return

    print("P2.10 SPIRITUAL ROOT REFINEMENT + MUTATION TEST PASS")
    quit(0)

func _verify_p2_9_gate_unchanged() -> bool:
    var legacy := P29Factory.create_state(TEST_SEED)
    if legacy.sect.spiritual_root_refinement_enabled:
        return _fail("P2.9 must remain root-refinement disabled.")
    if not legacy.sect.spiritual_root_profiles.is_empty():
        return _fail("P2.10 root profile state leaked into P2.9.")
    return true

func _verify_profiles_are_deterministic() -> bool:
    var state_a := P210Factory.create_state(TEST_SEED + 1)
    var state_b := P210Factory.create_state(TEST_SEED + 1)
    if not state_a.sect.spiritual_root_refinement_enabled or not state_b.sect.spiritual_root_refinement_enabled:
        return _fail("P2.10 factory did not enable root refinement.")
    if state_a.sect.spiritual_root_profiles != state_b.sect.spiritual_root_profiles:
        return _fail("P2.10 same-seed latent root profiles diverged.")
    return true

func _verify_refinement_consumes_real_resource_and_preserves_elements() -> bool:
    var state := P210Factory.create_state(TEST_SEED + 2)
    var actor := _accept_first_candidate(state)
    if actor == null:
        return _fail("P2.10 refinement probe could not accept a candidate.")
    var roots := RootRefinementSystem.new()
    var elements_before := actor.spiritual_root_elements.duplicate()
    var purity_before := actor.spiritual_root_purity
    var material_before := int(state.sect.technique_materials.get(RootRefinementSystem.MATERIAL_ID, 0))
    var result := roots.refine_disciple(state, actor.id)
    if not bool(result.get("ok", false)):
        return _fail("P2.10 root refinement action failed.")
    if actor.spiritual_root_purity <= purity_before:
        return _fail("P2.10 refinement did not increase root purity.")
    if actor.spiritual_root_elements != elements_before:
        return _fail("P2.10 ordinary refinement incorrectly changed root element count/list.")
    if int(state.sect.technique_materials.get(RootRefinementSystem.MATERIAL_ID, 0)) != material_before - 1:
        return _fail("P2.10 refinement did not consume exactly one real Linh Tủy material.")
    return true

func _verify_quality_bridge_and_technique_consequence() -> bool:
    var state := P210Factory.create_state(TEST_SEED + 3)
    var actor := _accept_first_candidate(state)
    if actor == null:
        return _fail("P2.10 quality bridge probe could not accept a candidate.")
    actor.spiritual_root_elements = ["fire"]
    actor.spiritual_root_purity = 0.64
    actor.spiritual_root_quality = SpiritualRootSystem.QUALITY_ORDINARY
    actor.potential = 1.0
    actor.learned_techniques = {
        "xich_viem_chan_quyet":{"level":1, "xp":0.0}
    }
    actor.active_technique_id = &"xich_viem_chan_quyet"
    state.sect.technique_materials[RootRefinementSystem.MATERIAL_ID] = 3
    var technique := TechniqueSystem.new()
    var before_bonus := technique.combat_power_bonus(state, actor)
    var result := RootRefinementSystem.new().refine_disciple(state, actor.id)
    if not bool(result.get("ok", false)):
        return _fail("P2.10 threshold refinement failed.")
    if actor.spiritual_root_purity < 0.65 or actor.spiritual_root_quality != SpiritualRootSystem.QUALITY_EARTH:
        return _fail("P2.10 purity crossing did not update the legacy root-quality bridge.")
    var after_bonus := technique.combat_power_bonus(state, actor)
    if after_bonus <= before_bonus:
        return _fail("P2.10 refined root quality did not improve a real matching technique effect.")
    return true

func _verify_purity_changes_cultivation_and_breakthrough() -> bool:
    var state := P210Factory.create_state(TEST_SEED + 4)
    var low := _probe_disciple("root_low", 0.35, ["fire", "metal"])
    var high := _probe_disciple("root_high", 0.90, ["fire", "metal"])
    state.disciples[low.id] = low
    state.disciples[high.id] = high
    _set_root_profile(state, low.id, 0, RootRefinementSystem.MUTATION_NONE, &"")
    _set_root_profile(state, high.id, 0, RootRefinementSystem.MUTATION_NONE, &"")
    var cultivation := CultivationSystem.new()
    var low_gain := cultivation.add_progress(state, low, 10.0)
    var high_gain := cultivation.add_progress(state, high, 10.0)
    if high_gain <= low_gain:
        return _fail("P2.10 higher root purity did not improve real cultivation gain.")
    low.cultivation_stage_index = 8
    high.cultivation_stage_index = 8
    low.hp = low.max_hp
    high.hp = high.max_hp
    low.stamina = 100.0
    high.stamina = 100.0
    var low_chance := cultivation.breakthrough_success_chance(low, state)
    var high_chance := cultivation.breakthrough_success_chance(high, state)
    if high_chance <= low_chance:
        return _fail("P2.10 higher root purity did not improve real breakthrough chance.")
    return true

func _verify_specialization_tradeoff() -> bool:
    var state := P210Factory.create_state(TEST_SEED + 5)
    var single := _probe_disciple("single_root", 0.75, ["fire"])
    var multi := _probe_disciple("multi_root", 0.75, ["fire", "metal", "water"])
    state.disciples[single.id] = single
    state.disciples[multi.id] = multi
    _set_root_profile(state, single.id, 0, RootRefinementSystem.MUTATION_NONE, &"")
    _set_root_profile(state, multi.id, 0, RootRefinementSystem.MUTATION_NONE, &"")
    var roots := RootRefinementSystem.new()
    var single_match := roots.technique_effect_multiplier(state, single, &"fire")
    var multi_match := roots.technique_effect_multiplier(state, multi, &"fire")
    var multi_flex := roots.technique_effect_multiplier(state, multi, &"water")
    if single_match <= multi_match:
        return _fail("P2.10 single-root specialization is not stronger on the same matching element.")
    if multi_flex <= 1.0:
        return _fail("P2.10 multi-root flexibility has no positive matching-element value.")
    return true

func _verify_hidden_mutation_reveal_and_consequence() -> bool:
    var state := P210Factory.create_state(TEST_SEED + 6)
    var actor := _probe_disciple("mutation_probe", 0.71, ["fire"])
    actor.potential = 1.0
    state.disciples[actor.id] = actor
    _set_root_profile(state, actor.id, 2, RootRefinementSystem.MUTATION_FIRE, &"")
    state.sect.technique_materials[RootRefinementSystem.MATERIAL_ID] = 2
    var roots := RootRefinementSystem.new()
    var before_multiplier := roots.cultivation_multiplier(state, actor)
    var latent_before := str(roots.profile_for(state, actor.id).get("latent_mutation", ""))
    var result := roots.refine_disciple(state, actor.id)
    if not bool(result.get("ok", false)):
        return _fail("P2.10 mutation reveal refinement failed.")
    if roots.revealed_mutation(state, actor.id) != RootRefinementSystem.MUTATION_FIRE:
        return _fail("P2.10 latent root mutation did not reveal at the deterministic threshold.")
    if str(roots.profile_for(state, actor.id).get("latent_mutation", "")) != latent_before:
        return _fail("P2.10 mutation reveal rerolled the pre-generated latent mutation.")
    var after_multiplier := roots.cultivation_multiplier(state, actor)
    if after_multiplier <= before_multiplier:
        return _fail("P2.10 revealed mutation has no real cultivation consequence.")
    var matching_effect := roots.technique_effect_multiplier(state, actor, &"fire")
    var mismatch_effect := roots.technique_effect_multiplier(state, actor, &"water")
    if matching_effect <= mismatch_effect:
        return _fail("P2.10 revealed mutation does not strengthen its matching element.")
    return true

func _verify_recruitment_profile_lifecycle() -> bool:
    var state := P210Factory.create_state(TEST_SEED + 7)
    state.sect.disciple_capacity += 3
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.size() < 2:
        return _fail("P2.10 recruitment lifecycle needs at least two candidates.")
    var accepted_id := StringName(ids[0])
    var rejected_id := StringName(ids[1])
    var roots := RootRefinementSystem.new()
    var accepted_profile := roots.profile_for(state, accepted_id).duplicate(true)
    if accepted_profile.is_empty():
        return _fail("P2.10 candidate has no latent root profile.")
    if not bool(RecruitmentSystem.new().accept_candidate(state, accepted_id).get("ok", false)):
        return _fail("P2.10 could not accept candidate.")
    if roots.profile_for(state, accepted_id) != accepted_profile:
        return _fail("P2.10 candidate -> disciple acceptance rerolled root identity.")
    if not bool(RecruitmentSystem.new().reject_candidate(state, rejected_id).get("ok", false)):
        return _fail("P2.10 could not reject candidate.")
    if not roots.profile_for(state, rejected_id).is_empty():
        return _fail("P2.10 rejected candidate left an orphan root profile.")
    return true

func _verify_persistence_and_continuation() -> bool:
    var state_a := P210Factory.create_state(TEST_SEED + 8)
    var actor := _accept_first_candidate(state_a)
    if actor == null:
        return _fail("P2.10 persistence probe could not accept candidate.")
    state_a.sect.technique_materials[RootRefinementSystem.MATERIAL_ID] = 5
    RootRefinementSystem.new().refine_disciple(state_a, actor.id)

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P2.10 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.spiritual_root_refinement_enabled:
        return _fail("P2.10 save did not restore root refinement feature state.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.10 exact save/load state diverged.")

    SimulationScheduler.new(state_a).run_ticks(80)
    SimulationScheduler.new(loaded).run_ticks(80)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.10 deterministic continuation diverged after save/load.")
    var errors := _all_invariants(loaded)
    if not errors.is_empty():
        return _fail("P2.10 invariant failure after continuation: %s" % " | ".join(errors))
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

func _probe_disciple(id_text: String, purity: float, elements: Array) -> DiscipleState:
    return DiscipleState.new({
        "id":id_text,
        "name":id_text,
        "profile_seed":100,
        "recruitment_source":"ordinary",
        "latent_identity_seed":200,
        "aptitude":0.55,
        "potential":0.55,
        "spiritual_root_quality":str(SpiritualRootSystem.new().quality_for_purity(purity)),
        "spiritual_root_purity":purity,
        "spiritual_root_elements":elements,
        "cultivation_stage_index":0,
        "cultivation_progress":0.0,
        "cultivation_combat_bonus":0.0,
        "cultivation_hp_bonus":0.0
    })

func _set_root_profile(state: SimulationState, character_id: StringName, count: int, latent: StringName, revealed: StringName) -> void:
    state.sect.spiritual_root_profiles[str(character_id)] = {
        "initialized":true,
        "refinement_count":count,
        "latent_mutation":str(latent),
        "revealed_mutation":str(revealed)
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
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
