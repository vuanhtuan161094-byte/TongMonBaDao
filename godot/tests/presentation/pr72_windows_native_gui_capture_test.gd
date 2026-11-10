extends SceneTree

# Windows-native GUI capture, NOT Android or physical-owner acceptance.
# Render the live P3.2 scene using the actual Windows Godot 4.7.2 display.
const SAVE_PATH := "user://qa_pr72_native_windows_gui.json"
var screen: Control

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("Headless display is not a Windows GUI result.")
        return
    var args := OS.get_cmdline_user_args()
    if args.is_empty():
        _fail("Pass an absolute evidence directory after --.")
        return
    var out := args[0]
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        _fail("Cannot create QA output directory: " + out)
        return
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    DisplayServer.window_set_size(Vector2i(1280,720))
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("Canonical gameplay scene is missing.")
        return
    screen = scene.instantiate() as Control
    root.add_child(screen)
    for _i in range(8):
        await process_frame
    var state: SimulationState = screen.get("state")
    if state == null or not bool(screen.get("runtime_ready")):
        _fail("Live gameplay runtime did not initialize in GUI.")
        return
    var cap := await _capture(out.path_join("00_map_1280x720.png"))
    if not cap:
        return
    var paths := [
        [SectMapPresentation.DEST_MINE,"01_mine_1280x720.png"],
        [SectMapPresentation.DEST_LINH_FOREST,"02_forest_1280x720.png"],
        [SectMapPresentation.DEST_SPIRIT_FIELD,"03_field_1280x720.png"],
        [SectMapPresentation.DEST_WAREHOUSE,"04_warehouse_1280x720.png"]
    ]
    for pair in paths:
        screen.call("_open_building",StringName(pair[0]))
        for _i in range(3):
            await process_frame
        if StringName(screen.get("selected_building")) != StringName(pair[0]):
            _fail("Real GUI did not select requested panel: " + str(pair[0]))
            return
        if not await _capture(out.path_join(str(pair[1]))):
            return
    # Real visible workforce widgets must be present on the selected Field.
    screen.call("_open_building",SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    var found := 0
    for raw_id in state.disciples.keys():
        var row := screen.find_child("FieldGroup_%s" % str(raw_id),true,false) as Button
        if row != null:
            found += 1
    if found < 1 or screen.find_child("FieldProfessionXpGuide",true,false) == null:
        _fail("Production GUI lacks live worker rows or profession XP guide.")
        return
    var started := Time.get_ticks_msec()
    var fps_sum := 0.0
    var fps_samples := 0
    for _i in range(120):
        await process_frame
        var rate := float(Engine.get_frames_per_second())
        if rate > 0.0:
            fps_sum += rate
            fps_samples += 1
    var elapsed := Time.get_ticks_msec()-started
    var metrics := {
        "evidence_kind": "windows_native_runner_rendered_gui_not_physical_playtest",
        "display_server": DisplayServer.get_name(),
        "window_pixels": [root.size.x,root.size.y],
        "engine_version": Engine.get_version_info().get("string",""),
        "frames_observed": 120,
        "elapsed_ms": elapsed,
        "mean_engine_fps_observed": fps_sum/float(maxi(fps_samples,1)),
        "static_memory_bytes": OS.get_static_memory_usage(),
        "workforce_rows": found,
        "screenshots": 5,
        "physical_windows_owner_acceptance": false,
        "android_device_tested": false
    }
    var file := FileAccess.open(out.path_join("native_gui_metrics.json"),FileAccess.WRITE)
    if file == null:
        _fail("Cannot persist Windows GUI evidence metrics.")
        return
    file.store_string(JSON.stringify(metrics,"  "))
    file.close()
    screen.set("runtime_ready",false)
    screen.queue_free()
    await process_frame
    _cleanup()
    print("PR72 WINDOWS_NATIVE_GUI_RENDER_CAPTURE PASS ",JSON.stringify(metrics))
    quit(0)

func _capture(path: String) -> bool:
    for _i in range(3):
        await process_frame
    await RenderingServer.frame_post_draw
    var image := root.get_texture().get_image()
    if image == null or image.is_empty() or image.get_size() != Vector2i(1280,720):
        return _fail("Windows GPU viewport missing/incorrect 1280x720 pixels: " + path)
    var colors := {}
    for yy in range(1,8):
        for xx in range(1,12):
            var key := image.get_pixel(xx*100,yy*90).to_html()
            colors[key] = true
    if colors.size() < 7:
        return _fail("Screenshot is suspiciously blank, distinct samples="+str(colors.size()))
    var error := image.save_png(path)
    if error != OK:
        return _fail("Could not save Windows-rendered PNG: "+path+" "+str(error))
    print("PR72 WINDOWS_GUI_SCREENSHOT_OK ",path," distinct_samples=",colors.size())
    return true

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error("PR72 WINDOWS NATIVE GUI: "+message)
    if screen != null and is_instance_valid(screen):
        screen.set("runtime_ready",false)
        screen.queue_free()
    _cleanup()
    quit(1)
    return false
