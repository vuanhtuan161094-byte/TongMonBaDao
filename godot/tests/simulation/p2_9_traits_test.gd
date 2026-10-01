extends SceneTree

const TEST_SEED := 2029292
const SAVE_PATH := "user://p2_9_traits_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_p2_8_gate_unchanged():
        return
    if not _verify_deterministic_profiles_and_empty_is_stable():
        return
    if not _verify_cultivation_trait_consequences():
        return
    if not _verify_work_trait_consequences():
        return
    if not _verify_combat_trait_consequences():
        return
    if not _verify_hidden_reveal_is_history_driven():
        return
    if not _verify_recruitment_profile_lifecycle():
        return
    if not _verify_persistence_and_continuation():
        return

    print("P2.9 TRAITS + HIDDEN REVEAL TEST PASS")
    quit(0)

func _verify_p2_8_gate_unchanged() -> bool:
    var legacy := P28Factory.create_state(TEST_SEED)
    if legacy.sect.disciple_traits_enabled:
        return _fail("P2.8 must remain trait-system disabled.")
    if not legacy.sect.disciple_trait_profiles.is_empty():
        return _fail("P2.9 trait state leaked into the locked P2.8 factory.")
    return true

func _verify_deterministic_profiles_and_empty_is_stable() -> bool:
    var state_a := P29Factory.create_state(TEST_SEED + 1)
    var state_b := P29Factory.create_state(TEST_SEED + 1)
    if not state_a.sect.disciple_traits_enabled or not state_b.sect.disciple_traits_enabled:
        return _fail("P2.9 factory did not enable traits.")
    if state_a.sect.disciple_trait_profiles != state_b.sect.disciple_trait_profiles:
        return _fail("P2.9 same-seed trait profiles diverged.")

    var found_empty := false
    var trait_system := TraitSystem.new()
    var probe_state := P28Factory.create_state(TEST_SEED + 11)
    probe_state.sect.disciple_traits_enabled = true
    var generator := DiscipleGeneratorV2.new()
    for index in range(40, 140):
        var candidate := generator.generate_candidate(probe_state, DiscipleGeneratorV2.SOURCE_ORDINARY, index)
        probe_state.recruitment_candidates[candidate.id] = candidate
        var profile := trait_system.ensure_candidate_profile(probe_state, candidate)
        if Array(profile.get("visible", [])).is_empty():
            var before := profile.duplicate(true)
            var after := trait_system.ensure_candidate_profile(probe_state, candidate).duplicate(true)
            if before != after or not bool(after.get("initialized", false)):
                return _fail("P2.9 empty visible trait result was rerolled or lost initialization state.")
            found_empty = true
            break
    if not found_empty:
        return _fail("P2.9 deterministic sample could not produce a valid no-visible-trait candidate.")
    return true

func _verify_cultivation_trait_consequences() -> bool:
    var state := P29Factory.create_state(TEST_SEED + 2)
    var neutral := _probe_disciple("cult_neutral")
    var positive := _probe_disciple("cult_positive")
    var negative := _probe_disciple("cult_negative")
    _set_profile(state, neutral.id, [], [])
    _set_profile(state, positive.id, [str(TraitSystem.TRAIT_STEADY_MERIDIANS)], [])
    _set_profile(state, negative.id, [str(TraitSystem.TRAIT_FRAGILE_MERIDIANS)], [])
    var cultivation := CultivationSystem.new()
    var neutral_gain := cultivation.add_progress(state, neutral, 10.0)
    var positive_gain := cultivation.add_progress(state, positive, 10.0)
    var negative_gain := cultivation.add_progress(state, negative, 10.0)
    if not (positive_gain > neutral_gain and neutral_gain > negative_gain):
        return _fail("P2.9 cultivation traits do not measurably affect real cultivation gain.")
    return true

func _verify_work_trait_consequences() -> bool:
    var state := P29Factory.create_state(TEST_SEED + 3)
    var neutral := _probe_disciple("work_neutral")
    var positive := _probe_disciple("work_positive")
    var negative := _probe_disciple("work_negative")
    for actor in [neutral, positive, negative]:
        actor.region_id = &"sect"
        actor.comprehension = 0.55
        actor.profession_traits = []
        actor.profession_xp = {}
        actor.work_progress = {}
        actor.stamina = 100.0
    _set_profile(state, neutral.id, [], [])
    _set_profile(state, positive.id, [str(TraitSystem.TRAIT_DILIGENT_WORKER)], [])
    _set_profile(state, negative.id, [str(TraitSystem.TRAIT_CARELESS_WORKER)], [])
    var workforce := WorkforceSystem.new()
    workforce.perform_work(state, neutral, WorkforceSystem.PROF_MINING)
    workforce.perform_work(state, positive, WorkforceSystem.PROF_MINING)
    workforce.perform_work(state, negative, WorkforceSystem.PROF_MINING)
    var neutral_progress := float(neutral.work_progress.get("mining", 0.0))
    var positive_progress := float(positive.work_progress.get("mining", 0.0))
    var negative_progress := float(negative.work_progress.get("mining", 0.0))
    if not (positive_progress > neutral_progress and neutral_progress > negative_progress):
        return _fail("P2.9 work traits do not measurably affect real work speed.")
    return true

func _verify_combat_trait_consequences() -> bool:
    var state := P29Factory.create_state(TEST_SEED + 4)
    var neutral := _probe_disciple("combat_neutral")
    var positive := _probe_disciple("combat_positive")
    var negative := _probe_disciple("combat_negative")
    _set_profile(state, neutral.id, [], [])
    _set_profile(state, positive.id, [str(TraitSystem.TRAIT_FEARLESS)], [])
    _set_profile(state, negative.id, [str(TraitSystem.TRAIT_TIMID)], [])
    var cultivation := CultivationSystem.new()
    var neutral_power := cultivation.effective_combat_power(state, neutral)
    var positive_power := cultivation.effective_combat_power(state, positive)
    var negative_power := cultivation.effective_combat_power(state, negative)
    if not (positive_power > neutral_power and neutral_power > negative_power):
        return _fail("P2.9 combat traits do not change real effective combat power.")
    return true

func _verify_hidden_reveal_is_history_driven() -> bool:
    var state := P29Factory.create_state(TEST_SEED + 5)
    var actor := _probe_disciple("hidden_battle")
    actor.profile_seed = 17
    state.disciples[actor.id] = actor
    _set_profile(state, actor.id, [], [str(TraitSystem.TRAIT_BATTLE_INSTINCT)])
    var trait_system := TraitSystem.new()
    var cultivation := CultivationSystem.new()
    var latent_before := trait_system.latent_trait_ids(state, actor.id).duplicate()
    var power_before := cultivation.effective_combat_power(state, actor)
    actor.metrics["combats"] = 2
    if not trait_system.process_reveals(state, actor).is_empty():
        return _fail("P2.9 hidden battle trait revealed before its history threshold.")
    if cultivation.effective_combat_power(state, actor) != power_before:
        return _fail("P2.9 hidden trait affected combat before reveal.")
    actor.metrics["combats"] = 3
    var revealed_now := trait_system.process_reveals(state, actor)
    if not revealed_now.has(str(TraitSystem.TRAIT_BATTLE_INSTINCT)):
        return _fail("P2.9 hidden battle trait did not reveal at its deterministic threshold.")
    if trait_system.latent_trait_ids(state, actor.id) != latent_before:
        return _fail("P2.9 reveal mutated the pre-generated latent trait identity.")
    if cultivation.effective_combat_power(state, actor) <= power_before:
        return _fail("P2.9 revealed battle trait has no real combat consequence.")
    return true

func _verify_recruitment_profile_lifecycle() -> bool:
    var state := P29Factory.create_state(TEST_SEED + 6)
    state.sect.disciple_capacity += 3
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.size() < 2:
        return _fail("P2.9 recruitment lifecycle needs at least two candidates.")
    var accepted_id := StringName(ids[0])
    var rejected_id := StringName(ids[1])
    var trait_system := TraitSystem.new()
    var profile_before := trait_system.profile_for(state, accepted_id).duplicate(true)
    if profile_before.is_empty():
        return _fail("P2.9 candidate was generated without a trait profile.")
    var accept_result := RecruitmentSystem.new().accept_candidate(state, accepted_id)
    if not bool(accept_result.get("ok", false)):
        return _fail("P2.9 could not accept candidate in profile lifecycle probe.")
    if trait_system.profile_for(state, accepted_id) != profile_before:
        return _fail("P2.9 candidate -> disciple acceptance rerolled or changed trait identity.")
    var reject_result := RecruitmentSystem.new().reject_candidate(state, rejected_id)
    if not bool(reject_result.get("ok", false)):
        return _fail("P2.9 could not reject candidate in profile lifecycle probe.")
    if not trait_system.profile_for(state, rejected_id).is_empty():
        return _fail("P2.9 rejected candidate left an orphan trait profile.")
    return true

func _verify_persistence_and_continuation() -> bool:
    var state_a := P29Factory.create_state(TEST_SEED + 7)
    state_a.sect.disciple_capacity += 2
    var ids: Array = state_a.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        return _fail("P2.9 persistence probe has no candidate.")
    var candidate_id := StringName(ids[0])
    if not bool(RecruitmentSystem.new().accept_candidate(state_a, candidate_id).get("ok", false)):
        return _fail("P2.9 persistence probe could not accept candidate.")
    var actor: DiscipleState = state_a.disciples.get(candidate_id)
    _set_profile(state_a, actor.id, [], [str(TraitSystem.TRAIT_MEDITATIVE_INSIGHT)])
    actor.metrics["cultivation_sessions"] = 3
    TraitSystem.new().process_reveals(state_a, actor)

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P2.9 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.disciple_traits_enabled:
        return _fail("P2.9 save did not restore trait feature state.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.9 exact save/load state diverged.")

    SimulationScheduler.new(state_a).run_ticks(80)
    SimulationScheduler.new(loaded).run_ticks(80)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.9 deterministic continuation diverged after save/load.")
    var errors := _all_invariants(loaded)
    if not errors.is_empty():
        return _fail("P2.9 invariant failure after continuation: %s" % " | ".join(errors))
    _cleanup()
    return true

func _probe_disciple(id_text: String) -> DiscipleState:
    return DiscipleState.new({
        "id":id_text,
        "name":id_text,
        "combat_power":18.0,
        "profile_seed":1,
        "aptitude":0.55,
        "comprehension":0.55,
        "spiritual_root_quality":"ordinary",
        "cultivation_stage_index":0,
        "cultivation_progress":0.0,
        "cultivation_combat_bonus":0.0,
        "cultivation_hp_bonus":0.0
    })

func _set_profile(state: SimulationState, character_id: StringName, visible: Array, latent: Array, revealed: Array = []) -> void:
    var visible_copy := visible.duplicate()
    var latent_copy := latent.duplicate()
    var revealed_copy := revealed.duplicate()
    visible_copy.sort()
    latent_copy.sort()
    revealed_copy.sort()
    state.sect.disciple_trait_profiles[str(character_id)] = {
        "initialized":true,
        "visible":visible_copy,
        "latent":latent_copy,
        "revealed":revealed_copy
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
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
