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
    if OS.get_environment("TMB_HALL_ONLY") == "1":
        if not await _capture_full_hall(out):
            return
        screen.set("runtime_ready",false)
        screen.queue_free()
        await process_frame
        _cleanup()
        print("HALL FULLSCREEN SIX_TABS_CAPTURE PASS")
        quit(0)
        return
    if OS.get_environment("TMB_MAP01_ONLY") == "1":
        # Two real views of the same screen; no fake resources or UI mockup.
        screen.call("_art05_focus_masterplan_district","forge",true)
        for _frame in range(24):
            await process_frame
        if not await _capture(out.path_join("01_map_production_focus_1280x720.png")):
            return
        screen.call("_art05_collapse_dock")
        await process_frame
        if not await _capture(out.path_join("02_map_clear_view_1280x720.png")):
            return
        # Additional actual camera states, still the same map screen.
        for district in ["cultivation","residence","gate"]:
            screen.call("_art05_focus_masterplan_district",district,true)
            for _frame in range(24):
                await process_frame
            if not await _capture(out.path_join("03_map_"+district+"_1280x720.png")):
                return
        screen.set("runtime_ready",false)
        screen.queue_free()
        await process_frame
        _cleanup()
        print("MAP01 REAL_GODOT_CAPTURE PASS")
        quit(0)
        return
    var extended := OS.get_environment("TMB_PLAYBOOK_CAPTURE") == "1"
    if extended and not await _capture_playbook(out):
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
        screen.call("_open_player_building",StringName(pair[0]))
        for _i in range(3):
            await process_frame
        if StringName(screen.get("selected_building")) != StringName(pair[0]):
            _fail("Real GUI did not select requested panel: " + str(pair[0]))
            return
        if StringName(pair[0]) == SectMapPresentation.DEST_MAIN_HALL:
            if not _verify_full_hall():
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
        "screenshots": 10 if extended else 7,
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

func _verify_full_hall() -> bool:
    var hall := screen.get_node_or_null("DaiDienScreenV1") as Control
    if hall == null or not hall.is_visible_in_tree() or hall.size.distance_to(Vector2(1280,720)) > 2.0:
        return _fail("The actual player Hall route did not open a full-screen 1280x720 Hall.")
    var old_panel := screen.find_child("BuildingOperationPanel",true,false) as Control
    if old_panel != null and old_panel.is_visible_in_tree():
        return _fail("Old floating Hall panel is still visible.")
    for index in range(6):
        var tab := hall.find_child("HallTab_%d" % index,true,false) as Button
        if tab == null or not tab.is_visible_in_tree():
            return _fail("Hall navigation missing tab %d." % index)
    var ledger := hall.find_child("HallReceiptLedger",true,false) as Label
    if ledger == null:
        return _fail("Receipt ledger is missing from the new Economy tab.")
    return true

func _capture_full_hall(out: String) -> bool:
    screen.call("_open_player_building",SectMapPresentation.DEST_MAIN_HALL)
    for _i in range(4):
        await process_frame
    if not _verify_full_hall():
        return false
    var hall := screen.get_node_or_null("DaiDienScreenV1") as Control
    var names := ["overview","offices","upgrade","rank","economy","policies"]
    for index in range(names.size()):
        var button := hall.find_child("HallTab_%d" % index,true,false) as Button
        button.pressed.emit()
        await process_frame
        if not await _capture(out.path_join("hall_%02d_%s.png" % [index,names[index]])):
            return false
    var back := hall.find_child("HallBackToMap",true,false) as Button
    if back == null:
        return _fail("Hall return button absent.")
    back.pressed.emit()
    await process_frame
    if screen.get_node_or_null("DaiDienScreenV1") != null:
        return _fail("Hall return failed to restore the map.")
    return true

func _capture_playbook(out: String) -> bool:
    var entry := screen.find_child("OneGamePlaybookButton",true,false) as Button
    if entry == null or not entry.is_visible_in_tree():
        return _fail("OneGame help entry is absent from the real HUD.")
    entry.pressed.emit()
    await process_frame
    var panel := screen.find_child("OneGamePlaybook",true,false) as Panel
    if panel == null or not panel.is_visible_in_tree():
        return _fail("Help button did not open the real playbook.")
    for action in ["recruit","school","production","cultivation","hunt","craft"]:
        var item := panel.find_child("OneGamePlaybook_"+action,true,false) as Button
        if item == null or item.disabled or not item.is_visible_in_tree():
            return _fail("Playbook navigation is unavailable: "+action)
    if not await _capture(out.path_join("07_playbook_1280x720.png")):
        return false
    var production := panel.find_child("OneGamePlaybook_production",true,false) as Button
    production.pressed.emit()
    await process_frame
    if StringName(screen.get("selected_building")) != SectMapPresentation.DEST_MINE:
        return _fail("Playbook production action did not select the actual Mine.")
    screen.call("_bottom_action","home")
    screen.call("_art05_focus_masterplan_district","forge",true)
    for _i in range(30):
        await process_frame
    if not await _capture(out.path_join("09_production_district_1280x720.png")):
        return false
    screen.call("_bottom_action","home")
    entry.pressed.emit()
    await process_frame
    panel = screen.find_child("OneGamePlaybook",true,false) as Panel
    if panel == null:
        return _fail("Playbook could not be reopened.")
    var cultivate := panel.find_child("OneGamePlaybook_cultivation",true,false) as Button
    if cultivate == null:
        return _fail("Cultivation navigation unavailable.")
    cultivate.pressed.emit()
    await process_frame
    if screen.find_child("DiscipleDeepScreen",true,false) == null:
        return _fail("Playbook cultivation action did not open the real disciple profile.")
    var technique := screen.find_child("DiscipleTabContentText",true,false) as Label
    if str(screen.get("disciple_profile_active_tab_name")) != "Công pháp" or technique == null or technique.text == "Chưa có dữ liệu.":
        return _fail("Playbook cultivation link must show the actual canonical technique tab.")
    if not await _capture(out.path_join("10_disciple_cultivation_1280x720.png")):
        return false
    screen.call("_bottom_action","home")
    await process_frame
    print("ONEGAME_PLAYBOOK_REAL_NAV_PASS")
    return true

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
    if OS.get_environment("TMB_PLAYBOOK_CAPTURE") == "1":
        for _i in range(24):
            await process_frame
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
