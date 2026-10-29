extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D7_ARCHIVE_ENTRY_FAIL: " + message)
    quit(1)

func _run() -> void:
    var state := P23Factory.create_state(770077)
    state.tick = 37
    var packed := load("res://scenes/p2/p2_3_techniques.tscn") as PackedScene
    if packed == null:
        _fail("existing P2.3 techniques scene did not load")
        return
    var archive := packed.instantiate() as Control
    archive.set("initial_state_override",state)
    archive.set("external_scheduler_mode",true)
    archive.set("archive_preview_overrides",{"sect_codex":true})
    archive.set("learning_preview_overrides",{"technique_learning":true})
    root.add_child(archive)
    await process_frame
    if archive.get("state") != state:
        _fail("Archive entry created a parallel state instead of using P3.2 canonical state")
        return
    if archive.get("scheduler") != null:
        _fail("embedded Archive created a second scheduler")
        return
    if not archive.get("external_scheduler_mode"):
        _fail("embedded Archive did not retain refresh-only mode")
        return
    archive.queue_free()
    print("V63 D7 ARCHIVE ENTRY PASS: existing P2.3 uses shared state and creates no second scheduler")
    quit(0)
