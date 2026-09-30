extends SceneTree

const TEST_SEED := 1324242
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p2_4_cultivation_path_test.json"

var paths := CultivationPathSystem.new()
var cultivation := CultivationSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_p23_path_stays_inert():
        return
    if not _verify_path_history_follows_used_technique():
        return
    if not _verify_identity_is_derived_and_mixed():
        return
    if not _verify_same_technique_gets_better_with_path_depth():
        return
    if not _verify_body_and_spell_have_real_consequences():
        return
    if not _verify_path_changes_ai_scores():
        return

    var state_a := P24Factory.create_state(TEST_SEED)
    var state_b := P24Factory.create_state(TEST_SEED)
    _seed_live_path_actor(state_a)
    _seed_live_path_actor(state_b)
    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.4 same-seed initial states diverged.")
        return

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)
    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.4 same-seed simulation diverged.")
        return

    var errors := _all_invariants(state_a)
    if not errors.is_empty():
        _fail("P2.4 invariant failure: %s" % " | ".join(errors))
        return

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        _fail("P2.4 save failed.")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.cultivation_paths_enabled:
        _fail("P2.4 save did not restore cultivation paths.")
        return
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.4 path state was not preserved by save/load.")
        return

    var scheduler_control := SimulationScheduler.new(state_a)
    var scheduler_loaded := SimulationScheduler.new(loaded)
    scheduler_control.run_ticks(CONTINUATION_TICKS)
    scheduler_loaded.run_ticks(CONTINUATION_TICKS)
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.4 deterministic continuation diverged after save/load.")
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    var actor: DiscipleState = loaded.disciples.get(&"bach_nguyet")
    print("P2.4 CULTIVATION PATH + IDENTITY CONSEQUENCE TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " identity=", paths.identity_label(actor), " path_xp=", actor.cultivation_path_xp, " events=", loaded.sect.cultivation_path_event_count)
    quit(0)

func _verify_p23_path_stays_inert() -> bool:
    var state := P23Factory.create_state(TEST_SEED + 1)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    if state.sect.cultivation_paths_enabled or not actor.cultivation_path_xp.is_empty():
        _fail("P2.3 path unexpectedly enabled P2.4 state.")
        return false
    actor.learned_techniques["thanh_phong_kiem_quyet"] = {"level": 3, "xp": 0.0}
    actor.active_technique_id = &"thanh_phong_kiem_quyet"
    if absf(paths.technique_effect_multiplier(state, actor, CultivationPathSystem.PATH_SWORD) - 1.0) > 0.000001:
        _fail("P2.4 path effects leaked into P2.3.")
        return false
    return true

func _verify_path_history_follows_used_technique() -> bool:
    var state := P24Factory.create_state(TEST_SEED + 2)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.learned_techniques = {
        "thanh_phong_kiem_quyet": {"level": 1, "xp": 0.0},
        "duong_khi_quyet": {"level": 1, "xp": 0.0}
    }
    actor.active_technique_id = &"thanh_phong_kiem_quyet"
    paths.record_cultivation(state, actor)
    paths.record_combat(state, actor, "win")
    if absf(paths.path_xp(actor, CultivationPathSystem.PATH_SWORD) - 14.0) > 0.000001:
        _fail("Sword path did not gain XP from cultivation + combat using a sword technique.")
        return false
    actor.active_technique_id = &"duong_khi_quyet"
    paths.record_cultivation(state, actor)
    if absf(paths.path_xp(actor, CultivationPathSystem.PATH_SPELL) - 10.0) > 0.000001:
        _fail("Switching active technique did not grow the new technique path.")
        return false
    if absf(paths.path_xp(actor, CultivationPathSystem.PATH_SWORD) - 14.0) > 0.000001:
        _fail("Changing path incorrectly erased prior path history.")
        return false
    return true

func _verify_identity_is_derived_and_mixed() -> bool:
    var state := P24Factory.create_state(TEST_SEED + 3)
    var actor: DiscipleState = state.disciples.get(&"tran_mac")
    actor.cultivation_path_xp = {"sword": 700.0, "body": 0.0, "spell": 300.0}
    if paths.identity_label(actor) != "Kiếm tu":
        _fail("70/30 path history did not derive a primary Kiếm tu identity.")
        return false
    actor.cultivation_path_xp = {"sword": 600.0, "body": 0.0, "spell": 400.0}
    if paths.identity_label(actor) != "Kiếm–Pháp song tu":
        _fail("Mixed path history did not derive a Kiếm–Pháp song-tu identity.")
        return false
    return true

func _verify_same_technique_gets_better_with_path_depth() -> bool:
    var novice_state := P24Factory.create_state(TEST_SEED + 4)
    var veteran_state := P24Factory.create_state(TEST_SEED + 4)
    var novice: DiscipleState = novice_state.disciples.get(&"co_truong_phong")
    var veteran: DiscipleState = veteran_state.disciples.get(&"co_truong_phong")
    for actor in [novice, veteran]:
        actor.learned_techniques["thanh_phong_kiem_quyet"] = {"level": 5, "xp": 0.0}
        actor.active_technique_id = &"thanh_phong_kiem_quyet"
        actor.cultivation_path_xp = {"sword": 0.0, "body": 0.0, "spell": 0.0}
    veteran.cultivation_path_xp["sword"] = CultivationPathSystem.DEPTH_XP
    var novice_power := cultivation.effective_combat_power(novice_state, novice)
    var veteran_power := cultivation.effective_combat_power(veteran_state, veteran)
    if veteran_power <= novice_power + 3.9:
        _fail("Deep sword history did not improve real combat power with the same sword technique.")
        return false
    return true

func _verify_body_and_spell_have_real_consequences() -> bool:
    var state := P24Factory.create_state(TEST_SEED + 5)
    var body: DiscipleState = state.disciples.get(&"lam_an")
    body.cultivation_path_xp = {"sword": 0.0, "body": CultivationPathSystem.DEPTH_XP, "spell": 0.0}
    if paths.incoming_damage_multiplier(state, body) >= 0.999:
        _fail("Deep body path did not reduce incoming damage.")
        return false

    var novice_state := P24Factory.create_state(TEST_SEED + 6)
    var veteran_state := P24Factory.create_state(TEST_SEED + 6)
    var novice: DiscipleState = novice_state.disciples.get(&"trieu_linh_nhi")
    var veteran: DiscipleState = veteran_state.disciples.get(&"trieu_linh_nhi")
    for actor in [novice, veteran]:
        actor.learned_techniques["duong_khi_quyet"] = {"level": 1, "xp": 0.0}
        actor.active_technique_id = &"duong_khi_quyet"
        actor.region_id = &"sect"
        actor.stamina = 100.0
        actor.cultivation_progress = 0.0
        actor.spiritual_root_quality = SpiritualRootSystem.QUALITY_ORDINARY
        actor.spiritual_root_elements = ["wood"]
        actor.cultivation_path_xp = {"sword": 0.0, "body": 0.0, "spell": 0.0}
    veteran.cultivation_path_xp["spell"] = CultivationPathSystem.DEPTH_XP
    var novice_gain := cultivation.cultivate(novice_state, novice)
    var veteran_gain := cultivation.cultivate(veteran_state, veteran)
    if veteran_gain <= novice_gain:
        _fail("Deep spell path did not increase real cultivation gain.")
        return false
    return true

func _verify_path_changes_ai_scores() -> bool:
    var state := P24Factory.create_state(TEST_SEED + 7)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.cultivation_path_xp = {"sword": 0.0, "body": 0.0, "spell": 0.0}
    var base_scores := {"HUNT": 70.0, "CULTIVATE": 60.0, "REST": 0.0}
    paths.apply_action_modifiers(state, actor, base_scores)
    var before := float(base_scores["CULTIVATE"])
    actor.cultivation_path_xp["spell"] = CultivationPathSystem.DEPTH_XP
    var shaped_scores := {"HUNT": 70.0, "CULTIVATE": 60.0, "REST": 0.0}
    paths.apply_action_modifiers(state, actor, shaped_scores)
    if float(shaped_scores["CULTIVATE"]) <= before or float(shaped_scores["CULTIVATE"]) <= float(shaped_scores["HUNT"]):
        _fail("Deep spell path did not measurably change autonomous action utility toward cultivation.")
        return false
    return true

func _seed_live_path_actor(state: SimulationState) -> void:
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.learned_techniques["duong_khi_quyet"] = {"level": 1, "xp": 0.0}
    actor.active_technique_id = &"duong_khi_quyet"
    actor.cultivation_directive = CultivationSystem.DIRECTIVE_CULTIVATE

func _all_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    return errors

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
