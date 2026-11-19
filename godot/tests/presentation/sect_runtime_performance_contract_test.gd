extends SceneTree
## PERF-WEB-01: no screenshot or fabricated FPS claims. Check real Godot
## camera update contract and opt-in instrumentation in the actual game scene.
const MAP_SCENE := preload("res://scenes/p3/p3_2_landscape_sect.tscn")
const SAVE := "user://sect_runtime_perf_qa_isolated.json"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(SAVE + suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE + suffix))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE)
    var scene := MAP_SCENE.instantiate() as Control
    root.add_child(scene)
    for i in range(7):
        await process_frame
    if not bool(scene.get("runtime_ready")):
        _fail("real one-game simulation did not load")
        return
    var world := scene.find_child("SectIsoWorld192",true,false) as SectIsometricWorldV1
    var hud := scene.find_child("SectRuntimePerfHud",true,false)
    if world == null or hud == null:
        _fail("real world/performance overlay not mounted")
        return
    if bool(hud.get("_enabled")) or (hud.get("_hud") as Control).visible:
        _fail("profiling must be disabled by default")
        return
    var original := world.camera.position
    var baseline_chunks := world.active_chunks.duplicate()
    var before := world.draw_revision
    world.camera.position = original+Vector2(0.10,0.10)
    world._update_chunks()
    if world.active_chunks == baseline_chunks and world.draw_revision != before:
        _fail("static sect redraw occurred for a tiny camera displacement")
        return
    world.camera.position = original + Vector2(112,0)
    world._update_chunks()
    if world.draw_revision <= before:
        _fail("sect visual refresh did not trigger for a substantial camera move")
        return
    world.camera.position = original
    world._update_chunks()
    var before_toggle := scene.state.to_dict().duplicate(true)
    hud.toggle()
    if not bool(hud.get("_enabled")) or not (hud.get("_hud") as Control).visible:
        _fail("F8-style toggle did not activate on-device profiler")
        return
    for i in range(50):
        hud._process(0.016)
    var readout := hud.get("_readout") as Label
    if readout == null or not readout.text.contains("1% low") or not readout.text.contains("P95"):
        _fail("profile HUD lacks frame-pace and 1% low metrics")
        return
    hud.toggle()
    if bool(hud.get("_enabled")) or (hud.get("_hud") as Control).visible:
        _fail("F8 did not disable sampler")
        return
    if scene.state.to_dict() != before_toggle:
        _fail("read-only telemetry changed simulation or Save state")
        return
    print("SECT RUNTIME PERF PASS static redraw camera threshold + F8 live HUD no gameplay mutation")
    quit(0)

func _fail(message: String) -> void:
    push_error("SECT RUNTIME PERF FAIL: "+message)
    quit(1)
