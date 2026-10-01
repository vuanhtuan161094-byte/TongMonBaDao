extends SceneTree

const TEST_SEED := 1526362
const RUN_TICKS := 600
const SAVE_PATH := "user://p2_6_persistence_diagnostic.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P26Factory.create_state(TEST_SEED)
    _seed_forge_materials(state)
    EquipmentSystem.new().craft(state, &"thanh_thiet_kiem", true)
    _prepare_buyer(state, &"bach_nguyet", &"sword", "metal")
    SimulationScheduler.new(state).run_ticks(RUN_TICKS)

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        push_error("P2.6 PERSISTENCE DIAGNOSTIC: save failed")
        _cleanup()
        quit(2)
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        push_error("P2.6 PERSISTENCE DIAGNOSTIC: load failed")
        _cleanup()
        quit(2)
        return

    var before := state.to_dict()
    var after := loaded.to_dict()
    var difference := _first_difference(before, after, "state")
    if not difference.is_empty():
        print("P2.6 PERSISTENCE DIAGNOSTIC: DIFFERENCE AFTER SAVE/LOAD")
        print(difference)
        print("control_tick=", state.tick, " loaded_tick=", loaded.tick)
        print("control_rng=", state.rng_state, " loaded_rng=", loaded.rng_state)
        _cleanup()
        quit(2)
        return

    print("P2.6 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical")
    _cleanup()
    quit(0)

func _seed_forge_materials(state: SimulationState) -> void:
    state.sect.forge_materials = {
        "linh_moc":20,
        "thanh_thiet":20,
        "tinh_lang_bi":20,
        "yeu_dan":20
    }

func _prepare_buyer(state: SimulationState, disciple_id: StringName, path_id: StringName, element: String) -> void:
    var actor: DiscipleState = state.disciples.get(disciple_id)
    actor.region_id = &"sect"
    actor.wallet = 1000
    actor.spend_bias = 0.90
    actor.cultivation_path_xp = {"sword":0.0, "body":0.0, "spell":0.0}
    actor.cultivation_path_xp[str(path_id)] = CultivationPathSystem.DEPTH_XP
    actor.spiritual_root_elements = [element]
    match path_id:
        &"sword":
            actor.learned_techniques["thanh_phong_kiem_quyet"] = {"level":1, "xp":0.0}
            actor.active_technique_id = &"thanh_phong_kiem_quyet"
        &"body":
            actor.learned_techniques["huyen_giap_cong"] = {"level":1, "xp":0.0}
            actor.active_technique_id = &"huyen_giap_cong"
        _:
            actor.learned_techniques["xich_viem_chan_quyet"] = {"level":1, "xp":0.0}
            actor.active_technique_id = &"xich_viem_chan_quyet"
    state.initial_total_money = state.total_money()

func _first_difference(a: Variant, b: Variant, path: String) -> String:
    if typeof(a) != typeof(b):
        return "%s type differs: %s vs %s | values=%s vs %s" % [path, type_string(typeof(a)), type_string(typeof(b)), str(a), str(b)]

    if a is Dictionary:
        var a_dict: Dictionary = a
        var b_dict: Dictionary = b
        var a_keys: Array = a_dict.keys()
        var b_keys: Array = b_dict.keys()
        a_keys.sort()
        b_keys.sort()
        if a_keys != b_keys:
            return "%s keys differ: %s vs %s" % [path, str(a_keys), str(b_keys)]
        for key in a_keys:
            var nested := _first_difference(a_dict[key], b_dict[key], "%s.%s" % [path, str(key)])
            if not nested.is_empty():
                return nested
        return ""

    if a is Array:
        var a_array: Array = a
        var b_array: Array = b
        if a_array.size() != b_array.size():
            return "%s size differs: %d vs %d" % [path, a_array.size(), b_array.size()]
        for index in range(a_array.size()):
            var nested := _first_difference(a_array[index], b_array[index], "%s[%d]" % [path, index])
            if not nested.is_empty():
                return nested
        return ""

    if a != b:
        return "%s value differs: %s vs %s | type=%s" % [path, str(a), str(b), type_string(typeof(a))]
    return ""

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
