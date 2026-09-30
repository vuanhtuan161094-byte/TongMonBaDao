extends SceneTree

const SAVE_PATH := "user://tong_mon_p0_roundtrip.json"
const MALFORMED_SAVE_PATH := "user://tong_mon_p0_malformed.json"
const INVALID_VERSION_SAVE_PATH := "user://tong_mon_p0_invalid_version.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P0Factory.create_state(24680)
    var scheduler := SimulationScheduler.new(state)
    scheduler.run_ticks(1000)

    var before_snapshot := state.to_dict()
    var control := SimulationState.from_dict(before_snapshot)

    var service := SaveService.new()
    var error := service.save_to_path(state, SAVE_PATH)
    if error != OK:
        _fail("Save failed with error %d." % error)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("Load returned null.")
        return

    if loaded.to_dict() != before_snapshot:
        _fail("Full-state mismatch after save/load round trip.")
        return

    if not _test_invalid_payload_rejection(service):
        _cleanup()
        quit(1)
        return

    var resumed := SimulationScheduler.new(loaded)
    var control_scheduler := SimulationScheduler.new(control)
    resumed.run_ticks(2000)
    control_scheduler.run_ticks(2000)

    var errors := loaded.validate_invariants()
    if not errors.is_empty():
        _fail("Loaded simulation violated invariants: %s" % " | ".join(errors))
        return

    if loaded.to_dict() != control.to_dict():
        _fail("Resumed simulation diverged from the same-state control; RNG/state restoration is not exact.")
        return

    print("P0 SAVE ROUNDTRIP TEST PASS")
    print("tick=", loaded.tick, " money=", loaded.total_money(), " disciples=", loaded.disciples.size())
    _cleanup()
    quit(0)

func _test_invalid_payload_rejection(service: SaveService) -> bool:
    if not _write_raw(MALFORMED_SAVE_PATH, "{\"save_version\":1}"):
        push_error("Could not create malformed-save fixture.")
        return false
    if service.load_from_path(MALFORMED_SAVE_PATH) != null:
        push_error("Malformed current-version save must be rejected instead of creating a default state.")
        return false

    if not _write_raw(INVALID_VERSION_SAVE_PATH, "{\"save_version\":-1}"):
        push_error("Could not create invalid-version save fixture.")
        return false
    if service.load_from_path(INVALID_VERSION_SAVE_PATH) != null:
        push_error("Negative save version must be rejected.")
        return false

    return true

func _write_raw(path: String, raw: String) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(raw)
    file.close()
    return true

func _fail(message: String) -> void:
    push_error(message)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    for path in [SAVE_PATH, MALFORMED_SAVE_PATH, INVALID_VERSION_SAVE_PATH]:
        var absolute := ProjectSettings.globalize_path(path)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(absolute)
