extends SceneTree

const TEST_SEED := 1425252
const DETERMINISM_TICKS := 600
const CONTINUATION_TICKS := 300
const SAVE_PATH := "user://p2_5_combat_skill_test.json"

var skills := CombatSkillSystem.new()
var combat := CombatSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_p24_keeps_legacy_combat():
        return
    if not _verify_realm_gates_learning_without_path_lock():
        return
    if not _verify_path_styles_are_distinct():
        return
    if not _verify_affinity_and_path_depth_change_skill_strength():
        return
    if not _verify_projectile_has_real_travel_and_burn():
        return
    if not _verify_guard_weaken_and_fire_combo_are_real():
        return

    var state_a := P25Factory.create_state(TEST_SEED)
    var state_b := P25Factory.create_state(TEST_SEED)
    _seed_live_combat_actor(state_a)
    _seed_live_combat_actor(state_b)
    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.5 same-seed initial states diverged.")
        return

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)
    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.5 same-seed simulation diverged.")
        return

    var errors := _all_invariants(state_a)
    if not errors.is_empty():
        _fail("P2.5 invariant failure: %s" % " | ".join(errors))
        return

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        _fail("P2.5 save failed.")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.combat_skills_enabled:
        _fail("P2.5 save did not restore combat skills.")
        return
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.5 combat skill state was not preserved by save/load.")
        return

    var loaded_actor: DiscipleState = loaded.disciples.get(&"bach_nguyet")
    if not bool(loaded_actor.learned_combat_skills.get("hoa_cau", false)):
        _fail("P2.5 learned combat skill was lost after save/load.")
        return

    var scheduler_control := SimulationScheduler.new(state_a)
    var scheduler_loaded := SimulationScheduler.new(loaded)
    scheduler_control.run_ticks(CONTINUATION_TICKS)
    scheduler_loaded.run_ticks(CONTINUATION_TICKS)
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.5 deterministic continuation diverged after save/load.")
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    print("P2.5 REALTIME COMBAT + INDEPENDENT SKILLS TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " skill_events=", loaded.sect.combat_skill_event_count, " skills=", loaded_actor.learned_combat_skills)
    quit(0)

func _verify_p24_keeps_legacy_combat() -> bool:
    var state := P24Factory.create_state(TEST_SEED + 1)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.region_id = &"thanh_truc_lam"
    if state.sect.combat_skills_enabled or not actor.learned_combat_skills.is_empty():
        _fail("P2.4 unexpectedly enabled P2.5 combat skill state.")
        return false
    var result := combat.resolve_encounter(state, actor, GameRng.new(TEST_SEED + 101))
    if result.has("trace"):
        _fail("P2.5 realtime resolver leaked into P2.4 legacy combat.")
        return false
    return true

func _verify_realm_gates_learning_without_path_lock() -> bool:
    var state := P25Factory.create_state(TEST_SEED + 2)
    var actor: DiscipleState = state.disciples.get(&"co_truong_phong")
    actor.cultivation_stage_index = 0
    if not skills.learn_skill(state, actor, &"thanh_phong_tram"):
        _fail("Luyện Khí tầng 1 could not learn its basic sword skill.")
        return false
    if not skills.learn_skill(state, actor, &"hoa_cau"):
        _fail("Combat skill learning was incorrectly hard-locked by path.")
        return false
    if skills.learn_skill(state, actor, &"ngu_kiem_thuat"):
        _fail("A Foundation-stage combat skill was learned below its realm requirement.")
        return false
    actor.cultivation_stage_index = 9
    if not skills.learn_skill(state, actor, &"ngu_kiem_thuat"):
        _fail("Foundation-stage combat skill stayed locked after realm requirement was met.")
        return false
    return true

func _verify_path_styles_are_distinct() -> bool:
    var state := P25Factory.create_state(TEST_SEED + 3)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.learned_techniques = {
        "thanh_phong_kiem_quyet":{"level":1, "xp":0.0},
        "huyen_giap_cong":{"level":1, "xp":0.0},
        "duong_khi_quyet":{"level":1, "xp":0.0}
    }
    actor.active_technique_id = &"thanh_phong_kiem_quyet"
    var sword := skills.style_profile(state, actor)
    actor.active_technique_id = &"huyen_giap_cong"
    var body := skills.style_profile(state, actor)
    actor.active_technique_id = &"duong_khi_quyet"
    var spell := skills.style_profile(state, actor)
    if str(sword.get("id")) != "sword" or str(body.get("id")) != "body" or str(spell.get("id")) != "spell":
        _fail("P2.5 could not derive distinct Sword/Body/Spell combat styles.")
        return false
    if float(spell.get("preferred_distance")) <= float(sword.get("preferred_distance")) or float(sword.get("preferred_distance")) <= float(body.get("preferred_distance")):
        _fail("P2.5 path spacing does not distinguish ranged, mid-range and contact combat.")
        return false
    if float(sword.get("basic_interval")) >= float(body.get("basic_interval")):
        _fail("Sword basic cadence is not measurably faster than Body cadence.")
        return false
    return true

func _verify_affinity_and_path_depth_change_skill_strength() -> bool:
    var state := P25Factory.create_state(TEST_SEED + 4)
    var actor: DiscipleState = state.disciples.get(&"trieu_linh_nhi")
    actor.learned_techniques["xich_viem_chan_quyet"] = {"level":1, "xp":0.0}
    actor.active_technique_id = &"xich_viem_chan_quyet"
    actor.spiritual_root_quality = SpiritualRootSystem.QUALITY_ORDINARY
    actor.spiritual_root_elements = ["fire"]
    actor.cultivation_path_xp = {"sword":0.0, "body":0.0, "spell":0.0}
    var shallow := skills.effect_multiplier(state, actor, &"hoa_cau")
    actor.cultivation_path_xp["spell"] = CultivationPathSystem.DEPTH_XP
    var deep := skills.effect_multiplier(state, actor, &"hoa_cau")
    actor.spiritual_root_elements = ["water"]
    var mismatched := skills.effect_multiplier(state, actor, &"hoa_cau")
    if deep <= shallow:
        _fail("Deep Spell history did not strengthen a Spell combat skill.")
        return false
    if mismatched >= deep:
        _fail("Spiritual-root elemental affinity did not affect combat skill strength.")
        return false
    return true

func _verify_projectile_has_real_travel_and_burn() -> bool:
    var state := P25Factory.create_state(TEST_SEED + 5)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.learned_techniques["duong_khi_quyet"] = {"level":1, "xp":0.0}
    actor.active_technique_id = &"duong_khi_quyet"
    actor.spiritual_root_elements = ["fire"]
    actor.combat_power = 8.0
    actor.max_hp = 200.0
    actor.hp = 200.0
    actor.risk_bias = 1.0
    actor.region_id = &"hac_phong_coc"
    state.regions[&"hac_phong_coc"].monster_weights = {"hac_lang":1.0}
    if not skills.learn_skill(state, actor, &"hoa_cau"):
        _fail("Could not seed Hỏa Cầu for projectile verification.")
        return false

    var result := combat.resolve_encounter(state, actor, GameRng.new(TEST_SEED + 505))
    var launch_time := -1.0
    var hit_time := -1.0
    var burn_tick_seen := false
    for event_value in result.get("trace", []):
        var event: Dictionary = event_value
        if str(event.get("type", "")) == "projectile_launch" and str(event.get("skill_id", "")) == "hoa_cau" and launch_time < 0.0:
            launch_time = float(event.get("time", -1.0))
        elif str(event.get("type", "")) == "projectile_hit" and str(event.get("skill_id", "")) == "hoa_cau" and hit_time < 0.0:
            hit_time = float(event.get("time", -1.0))
        elif str(event.get("type", "")) == "burn_tick":
            burn_tick_seen = true
    if launch_time < 0.0 or hit_time <= launch_time:
        _fail("Projectile skill did not have real travel time before impact.")
        return false
    if not burn_tick_seen:
        _fail("Hỏa Cầu burn did not create real delayed damage.")
        return false
    if result.get("trace", []).size() > CombatSystem.MAX_TRACE_EVENTS:
        _fail("P2.5 combat event trace exceeded its bound.")
        return false
    return true

func _verify_guard_weaken_and_fire_combo_are_real() -> bool:
    var state := P25Factory.create_state(TEST_SEED + 6)
    var actor: DiscipleState = state.disciples.get(&"lam_an")
    actor.cultivation_stage_index = 9
    actor.learned_techniques["xich_viem_chan_quyet"] = {"level":1, "xp":0.0}
    actor.active_technique_id = &"xich_viem_chan_quyet"
    actor.spiritual_root_quality = SpiritualRootSystem.QUALITY_ORDINARY
    actor.spiritual_root_elements = ["fire"]

    var guard_context := _effect_context()
    var guard_trace: Array = []
    combat._apply_skill_effect(state, actor, GameRng.new(61), 10.0, &"bat_dong_than", guard_context, guard_trace)
    if float(guard_context.get("guard_multiplier", 1.0)) >= 1.0 or float(guard_context.get("guard_until", -1.0)) <= 0.0:
        _fail("Body guard skill did not create real incoming-damage mitigation state.")
        return false

    var weaken_context := _effect_context()
    var weaken_trace: Array = []
    combat._apply_skill_effect(state, actor, GameRng.new(62), 10.0, &"chan_son_quyen", weaken_context, weaken_trace)
    if float(weaken_context.get("weaken_multiplier", 1.0)) >= 1.0 or float(weaken_context.get("weaken_until", -1.0)) <= 0.0:
        _fail("Weaken skill did not create real monster damage reduction state.")
        return false

    var normal_context := _effect_context()
    normal_context["monster_hp"] = 200.0
    var burning_context := _effect_context()
    burning_context["monster_hp"] = 200.0
    burning_context["burn_until"] = 10.0
    combat._apply_skill_effect(state, actor, GameRng.new(63), 10.0, &"liet_diem", normal_context, [])
    combat._apply_skill_effect(state, actor, GameRng.new(63), 10.0, &"liet_diem", burning_context, [])
    var normal_damage := 200.0 - float(normal_context["monster_hp"])
    var burning_damage := 200.0 - float(burning_context["monster_hp"])
    if burning_damage <= normal_damage * 1.30:
        _fail("Liệt Diễm did not gain meaningful damage against a burning target.")
        return false
    return true

func _effect_context() -> Dictionary:
    return {
        "time":0.0,
        "distance":1.0,
        "monster_hp":100.0,
        "monster_power":10.0,
        "guard_until":-1.0,
        "guard_multiplier":1.0,
        "burn_until":-1.0,
        "burn_next_tick":-1.0,
        "burn_damage":0.0,
        "weaken_until":-1.0,
        "weaken_multiplier":1.0
    }

func _seed_live_combat_actor(state: SimulationState) -> void:
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.learned_techniques["duong_khi_quyet"] = {"level":1, "xp":0.0}
    actor.active_technique_id = &"duong_khi_quyet"
    actor.cultivation_directive = CultivationSystem.DIRECTIVE_FIELD
    skills.learn_skill(state, actor, &"hoa_cau")

func _all_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    return errors

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
