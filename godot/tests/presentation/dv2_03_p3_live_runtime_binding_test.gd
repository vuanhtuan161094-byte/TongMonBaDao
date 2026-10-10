extends SceneTree

const TEST_SAVE_PATH := "user://dv2_03_p3_live_runtime_binding_test.json"
const LIVE_SEED := 31012026

var ui: Control

func _init() -> void:
    call_deferred("_run")

func _assert(valid: bool, reason: String) -> bool:
    if not valid:
        push_error(reason)
        _cleanup()
        if ui != null:
            ui.queue_free()
        quit(1)
        return false
    return true

func _remove(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _cleanup() -> void:
    _remove(TEST_SAVE_PATH)
    ProjectSettings.set_setting("runtime/live_save_path", null)

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path", TEST_SAVE_PATH)

    var baseline := P37Factory.create_state(LIVE_SEED)
    var expected_count := baseline.disciples.size()
    var expected_capacity := baseline.sect.disciple_capacity

    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _assert(packed != null,"Could not load live P3.2 main scene."):
        return
    ui = packed.instantiate() as Control
    if not _assert(ui != null,"Could not instantiate live P3.2 main scene."):
        return

    root.add_child(ui)
    await process_frame

    if not _assert(bool(ui.get("runtime_ready")),
        "P3.2 did not start the persistent live runtime."):
        return

    var state := ui.get("state") as SimulationState
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if not _assert(state != null and runtime != null and runtime.state() == state,
        "P3.2 presentation does not reference the runtime owner's state."):
        return

    if not _assert(
        state.disciples.size()==expected_count and
        state.sect.disciple_capacity==expected_capacity,
        "P3.2 still mutates a presentation-only demo roster at startup."):
        return

    if not _assert(
        state.sect.disciple_v2_birth_enabled and
        state.sect.v2_training_enabled and
        not state.sect.v2_training_rules.is_empty(),
        "P3.2 did not activate canonical DV2-03 live rules."):
        return

    var poll_timer := ui.get("runtime_poll_timer") as Timer
    var autosave_timer := ui.get("autosave_timer") as Timer
    if not _assert(
        poll_timer != null and
        absf(poll_timer.wait_time-1.0)<0.00001 and
        autosave_timer != null and
        absf(autosave_timer.wait_time-15.0)<0.00001,
        "P3.2 still uses the old 0.55s simulation timer or lacks autosave."):
        return

    # Stop real timers so the remainder of this test is fully deterministic.
    poll_timer.stop()
    autosave_timer.stop()

    var before_tick := state.tick
    var base_wall := state.runtime_last_wall_unix
    if not _assert(base_wall > 0,"Live P3 runtime has no persisted wall timestamp."):
        return

    var partial := runtime.poll(base_wall+59)
    if not _assert(bool(partial.get("ok",false)) and
        int(partial.get("steps_run",-1))==0 and state.tick==before_tick,
        "P3 live runtime advanced before a full wall minute."):
        return

    var minute := runtime.poll(base_wall+60)
    ui.call("_refresh_all")
    if not _assert(bool(minute.get("ok",false)) and
        int(minute.get("steps_run",-1))==1 and
        state.tick==before_tick+1,
        "P3 live runtime did not advance exactly one scheduler minute."):
        return

    var save_result := runtime.save(base_wall+60)
    if not _assert(bool(save_result.get("ok",false)) and
        FileAccess.file_exists(TEST_SAVE_PATH),
        "P3 live runtime did not persist its current state."):
        return

    var saved := SaveService.new().load_from_path(TEST_SAVE_PATH)
    if not _assert(saved != null and saved.tick==state.tick and
        saved.runtime_last_wall_unix==state.runtime_last_wall_unix,
        "Persisted P3 state does not match the live runtime state."):
        return

    ui.queue_free()
    await process_frame
    ui = null
    _cleanup()
    print("DV2-03 P3 LIVE RUNTIME BINDING: PASS")
    quit(0)
