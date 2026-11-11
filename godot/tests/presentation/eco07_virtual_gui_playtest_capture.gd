extends SceneTree

# ECO-07 virtual DISPLAY capture: genuine Linux Godot GL renderer under Xvfb.
# NOT a Windows-owner/Android hardware acceptance or touch-input QA.
# Render the actual canonical OneGame scene 1280x720; export audit PNGs.
const SAVE_PATH := "user://eco07_virtual_gui_isolated_playtest.json"
var screen: Control

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("Xvfb display absent: headless is NOT valid rasterized GUI evidence.")
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
        [SectMapPresentation.DEST_MAIN_HALL,"01_hall_1280x720.png"],
        [SectMapPresentation.DEST_MINE,"02_mine_1280x720.png"],
        [SectMapPresentation.DEST_LINH_FOREST,"03_forest_1280x720.png"],
        [SectMapPresentation.DEST_SPIRIT_FIELD,"04_field_1280x720.png"],
        [SectMapPresentation.DEST_WAREHOUSE,"05_warehouse_1280x720.png"],
        [SectMapPresentation.DEST_ALCHEMY_HALL,"06_alchemy_1280x720.png"]
    ]
    for pair in paths:
        screen.call("_open_building",StringName(pair[0]))
        for _i in range(3):
            await process_frame
        if StringName(screen.get("selected_building")) != StringName(pair[0]):
            _fail("Real GUI did not select requested panel: " + str(pair[0]))
            return
        if StringName(pair[0]) == SectMapPresentation.DEST_MAIN_HALL:
            var ledger := screen.find_child("EconomyA_RealIncome",true,false) as Label
            if ledger == null or not ledger.text.contains("SỔ THU CHI"):
                _fail("Rendered Hall lacks ECO06 real receipt-backed cashflow.")
                return
        if StringName(pair[0]) in [
                SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST,
                SectMapPresentation.DEST_SPIRIT_FIELD]:
            var display := screen.find_child("ECO06WorksiteSummary",true,false) as Label
            if display == null or not display.text.contains("NHÂN CÔNG"):
                _fail("Rendered production panel lacks ECO06 authoritative worker status.")
                return
        if StringName(pair[0]) == SectMapPresentation.DEST_WAREHOUSE:
            var market := screen.find_child("ECO06MarketSummary",true,false) as Label
            if market == null or not market.text.contains("Bán đã thu"):
                _fail("Rendered Warehouse lacks ECO06 real market receipts.")
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
        "evidence_kind": "linux_xvfb_virtual_render_not_physical_windows_or_android_playtest",
        "display_server": DisplayServer.get_name(),
        "window_pixels": [root.size.x,root.size.y],
        "engine_version": Engine.get_version_info().get("string",""),
        "frames_observed": 120,
        "elapsed_ms": elapsed,
        "mean_engine_fps_observed": fps_sum/float(maxi(fps_samples,1)),
        "static_memory_bytes": OS.get_static_memory_usage(),
        "workforce_rows": found,
        "screenshots": 7,
        "physical_windows_owner_acceptance": false,
        "linux_virtual_display_only": true,
        "android_device_tested": false
    }
    var file := FileAccess.open(out.path_join("eco07_virtual_gui_metrics.json"),FileAccess.WRITE)
    if file == null:
        _fail("Cannot persist Windows GUI evidence metrics.")
        return
    file.store_string(JSON.stringify(metrics,"  "))
    file.close()
    screen.set("runtime_ready",false)
    screen.queue_free()
    await process_frame
    _cleanup()
    print("ECO07 VIRTUAL_GODOT_GUI_CAPTURE PASS ",JSON.stringify(metrics))
    quit(0)

func _capture(path: String) -> bool:
    for _i in range(3):
        await process_frame
    await RenderingServer.frame_post_draw
    var image := root.get_texture().get_image()
    if image == null or image.is_empty() or image.get_size() != Vector2i(1280,720):
        return _fail("Virtual GL viewport missing/incorrect 1280x720 pixels: " + path)
    var colors := {}
    for yy in range(1,8):
        for xx in range(1,12):
            var key := image.get_pixel(xx*100,yy*90).to_html()
            colors[key] = true
    if colors.size() < 7:
        return _fail("Screenshot is suspiciously blank, distinct samples="+str(colors.size()))
    var error := image.save_png(path)
    if error != OK:
        return _fail("Could not save Virtual GL rendered PNG: "+path+" "+str(error))
    print("ECO07 VIRTUAL_GODOT_SCREENSHOT_OK ",path," distinct_samples=",colors.size())
    return true

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error("ECO07 VIRTUAL-GUI: "+message)
    if screen != null and is_instance_valid(screen):
        screen.set("runtime_ready",false)
        screen.queue_free()
    _cleanup()
    quit(1)
    return false
