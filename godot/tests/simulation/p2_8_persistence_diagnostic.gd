extends SceneTree

const TEST_SEED := 1928382
const SAVE_PATH := "user://p2_8_persistence_diagnostic.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P28Factory.create_state(TEST_SEED)
    state.sect.disciple_capacity += 2
    var recruitment := RecruitmentSystem.new()
    recruitment.gacha_candidate(state)
    recruitment.fate_candidate(state)

    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        push_error("P2.8 PERSISTENCE DIAGNOSTIC: no candidate")
        quit(2)
        return
    var candidate_id := StringName(ids[0])
    if not bool(recruitment.accept_candidate(state, candidate_id).get("ok", false)):
        push_error("P2.8 PERSISTENCE DIAGNOSTIC: accept failed")
        quit(2)
        return

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        push_error("P2.8 PERSISTENCE DIAGNOSTIC: save failed")
        _cleanup()
        quit(2)
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        push_error("P2.8 PERSISTENCE DIAGNOSTIC: load failed")
        _cleanup()
        quit(2)
        return

    var difference := _first_difference(state.to_dict(), loaded.to_dict(), "state")
    if not difference.is_empty():
        print("P2.8 PERSISTENCE DIAGNOSTIC: DIFFERENCE AFTER SAVE/LOAD")
        print(difference)
        _cleanup()
        quit(2)
        return

    print("P2.8 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical")
    _cleanup()
    quit(0)

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
