extends SceneTree

const TEST_SEED := 919191
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p1_5_resume_diagnostic.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var organization := OrganizationSystem.new()
    var state := P15Factory.create_state(TEST_SEED)
    var ids: Array = state.disciples.keys()
    ids.sort()
    organization.assign_role(state, StringName(ids[0]), OrganizationSystem.ROLE_HUNTER)

    var scheduler := SimulationScheduler.new(state)
    scheduler.run_ticks(DETERMINISM_TICKS)

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        _fail("diagnostic save failed")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("diagnostic load failed")
        return

    var initial_control: Dictionary = state.to_dict()
    var initial_loaded: Dictionary = loaded.to_dict()
    var immediate := _first_difference(initial_control, initial_loaded, "state")
    if immediate != "":
        print("P1.5 DIAGNOSTIC: DIFFERENCE EXISTS IMMEDIATELY AFTER LOAD")
        print(immediate)
        _cleanup()
        quit(2)
        return

    print("P1.5 DIAGNOSTIC: immediate save/load state is identical")

    var control_scheduler := SimulationScheduler.new(state)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    for offset in range(1, CONTINUATION_TICKS + 1):
        control_scheduler.step()
        loaded_scheduler.step()

        var control_snapshot: Dictionary = state.to_dict()
        var loaded_snapshot: Dictionary = loaded.to_dict()
        if control_snapshot != loaded_snapshot:
            var difference := _first_difference(control_snapshot, loaded_snapshot, "state")
            if difference != "":
                print("P1.5 DIAGNOSTIC: FIRST DIVERGENCE AT CONTINUATION STEP ", offset, " / TICK ", state.tick)
                print(difference)
                print("control_rng=", state.rng_state, " loaded_rng=", loaded.rng_state)
                _cleanup()
                quit(3)
                return

        if offset % 100 == 0:
            print("P1.5 DIAGNOSTIC: checked continuation step ", offset, " / ", CONTINUATION_TICKS)

    print("P1.5 DIAGNOSTIC PASS: no divergence across ", CONTINUATION_TICKS, " continuation ticks")
    _cleanup()
    quit(0)

func _first_difference(left: Variant, right: Variant, path: String) -> String:
    if typeof(left) != typeof(right):
        # JSON round-trip legitimately turns StringName into String in nested UI/debug dictionaries.
        if (left is StringName and right is String) or (left is String and right is StringName):
            if str(left) == str(right):
                return ""
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
        if absf(float(left) - float(right)) > 0.000000001:
            return "%s float differs: %.17g vs %.17g" % [path, float(left), float(right)]
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
