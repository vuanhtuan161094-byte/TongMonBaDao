extends SceneTree

const TEST_SEED := 1121212
const DETERMINISM_TICKS := 1200
const SAVE_PATH := "user://p2_1_persistence_diagnostic.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P21Factory.create_state(TEST_SEED)
    var cultivation := CultivationSystem.new()
    cultivation.set_directive(state, &"tran_mac", CultivationSystem.DIRECTIVE_CULTIVATE)
    SimulationScheduler.new(state).run_ticks(DETERMINISM_TICKS)

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        _fail("P2.1 diagnostic save failed")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("P2.1 diagnostic load failed")
        return

    var difference := _first_difference(state.to_dict(), loaded.to_dict(), "state")
    if difference != "":
        print("P2.1 PERSISTENCE DIAGNOSTIC: DIFFERENCE AFTER SAVE/LOAD")
        print(difference)
        print("control_tick=", state.tick, " loaded_tick=", loaded.tick)
        print("control_rng=", state.rng_state, " loaded_rng=", loaded.rng_state)
        _cleanup()
        quit(2)
        return

    print("P2.1 PERSISTENCE DIAGNOSTIC PASS: exact state preserved after save/load")
    _cleanup()
    quit(0)

func _first_difference(left: Variant, right: Variant, path: String) -> String:
    if typeof(left) != typeof(right):
        return "%s type differs: %s vs %s | values=%s vs %s" % [path, type_string(typeof(left)), type_string(typeof(right)), str(left), str(right)]
    if left is Dictionary:
        var left_dict: Dictionary = left
        var right_dict: Dictionary = right
        var left_keys: Array = left_dict.keys()
        var right_keys: Array = right_dict.keys()
        left_keys.sort_custom(func(a: Variant, b: Variant) -> bool: return str(a) < str(b))
        right_keys.sort_custom(func(a: Variant, b: Variant) -> bool: return str(a) < str(b))
        if left_keys.size() != right_keys.size():
            return "%s key count differs: %d vs %d | left=%s | right=%s" % [path, left_keys.size(), right_keys.size(), str(left_keys), str(right_keys)]
        for index in range(left_keys.size()):
            if str(left_keys[index]) != str(right_keys[index]):
                return "%s keys differ: %s vs %s" % [path, str(left_keys[index]), str(right_keys[index])]
            var key_left: Variant = left_keys[index]
            var key_right: Variant = right_keys[index]
            var key_difference := _first_difference(key_left, key_right, "%s.<key:%s>" % [path, str(key_left)])
            if key_difference != "":
                return key_difference
            var child := _first_difference(left_dict[key_left], right_dict[key_right], "%s.%s" % [path, str(key_left)])
            if child != "":
                return child
        return ""
    if left is Array:
        var left_array: Array = left
        var right_array: Array = right
        if left_array.size() != right_array.size():
            return "%s array size differs: %d vs %d" % [path, left_array.size(), right_array.size()]
        for index in range(left_array.size()):
            var child := _first_difference(left_array[index], right_array[index], "%s[%d]" % [path, index])
            if child != "":
                return child
        return ""
    if left is float:
        if left != right:
            return "%s float differs: %.17f (float) vs %.17f (float)" % [path, float(left), float(right)]
        return ""
    if left != right:
        return "%s differs: %s vs %s" % [path, str(left), str(right)]
    return ""

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> void:
    push_error(message)
    _cleanup()
    quit(1)
