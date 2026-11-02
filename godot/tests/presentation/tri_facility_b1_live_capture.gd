extends SceneTree
## Capture the genuine P3.2 main scene and open each B1 screen via its live management button.
## A dedicated user:// QA save path is used; no default player save is read or written.
const GAME = preload("res://scenes/p3/p3_2_landscape_sect.tscn")
const SAVE_PATH := "user://tri02_live_ui_capture_isolated.json"
const CAPTURE_FILES := {
    "hall":"01_hall_live_state.png",
    "residence":"02_residence_live_state.png",
    "guidance":"03_guidance_live_state.png"
}
const REQUIRED_MAP_ART := {
    "main_hall": "pv01_assets/main_hall/510052.png",
    "residence": "pv01_assets/residence/510076.png",
    "guidance": "pv01_assets/guidance/510111.png"
}

var game: Control

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var argv := OS.get_cmdline_user_args()
    if argv.is_empty():
        _fail("Pass isolated absolute screenshot output directory after --.")
        return
    var out_dir: String = argv[0]
    DirAccess.make_dir_recursive_absolute(out_dir)
    _remove_test_save()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    DisplayServer.window_set_size(Vector2i(1280,720))

    game = GAME.instantiate() as Control
    if game == null:
        _fail("Could not instantiate the real P3.2 main scene.")
        return
    root.add_child(game)
    await process_frame
    await process_frame
    if game.get("state") == null or not bool(game.get("runtime_ready")):
        _fail("P3.2 live runtime did not start with the isolated QA save.")
        return

    var state: SimulationState = game.get("state") as SimulationState
    if not SectHallSystemV1.installed(state):
        var install: Dictionary = SectHallSystemV1.ensure_live(state)
        if not bool(install.get("ok",false)):
            _fail("Canonical Hall/Residence prerequisites are unavailable.")
            return
        game.call("_refresh_all")
        await process_frame

    var world = game.get("iso_world")
    if world == null:
        _fail("P3.2 main scene has no isometric world renderer.")
        return
    var loaded_art: Dictionary = world.get("render_art")
    var world_script := world.get_script() as Script
    if world_script == null:
        _fail("P3.2 world renderer script is unavailable.")
        return
    var constants: Dictionary = world_script.get_script_constant_map()
    var texture_map: Dictionary = constants.get("HOUSE_TEXTURES",{})
    var size_map: Dictionary = constants.get("HOUSE_SIZES",{})
    for kind in REQUIRED_MAP_ART:
        var relative: String = REQUIRED_MAP_ART[kind]
        if str(texture_map.get(kind,"")) != relative or not loaded_art.has(relative):
            _fail("P3.2 map did not bind its SHA-gated Source A %s sprite." % kind)
            return
        var texture: Texture2D = loaded_art[relative] as Texture2D
        var target_size: Vector2 = size_map.get(kind,Vector2.ZERO)
        if texture == null or target_size.x <= 0.0 or target_size.y <= 0.0:
            _fail("P3.2 map has no renderable texture/size for %s." % kind)
            return
        var source_ratio := float(texture.get_width())/float(texture.get_height())
        if absf(source_ratio-target_size.x/target_size.y) > 0.01:
            _fail("P3.2 map would distort Source A %s." % kind)
            return

    if not await _save_frame(out_dir,"00_p3_2_map_context.png"):
        return
    if not await _open_from_map("hall","510052",SectMapPresentation.DEST_MAIN_HALL,"OpenDaiDienScreenV1",out_dir,CAPTURE_FILES["hall"]):
        return
    if not await _open_from_map("residence","510076",SectMapPresentation.DEST_RESIDENCE,"OpenResidenceManagementV1",out_dir,CAPTURE_FILES["residence"]):
        return
    if not await _open_from_map("guidance","510111",SectMapPresentation.DEST_GUIDANCE,"OpenDanTienScreenV2",out_dir,CAPTURE_FILES["guidance"]):
        return

    game.set("runtime_ready",false)
    game.queue_free()
    await process_frame
    game = null
    _remove_test_save()
    print("TRI02_P32_CONTEXT_CAPTURE_PASS map=1 hall=1 residence=1 guidance=1 size=1280x720")
    quit(0)

func _open_from_map(kind: String, model_id: String, destination: StringName, button_name: String, out_dir: String, filename: String) -> bool:
    game.call("_open_building",destination)
    await process_frame
    await process_frame
    var button := _find_button(game,button_name)
    if button == null or button.disabled:
        _fail("Live P3.2 facility button is absent or disabled: %s." % button_name)
        return false
    button.pressed.emit()
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var screen_name := "DanTienScreenV2" if button_name == "OpenDanTienScreenV2" else "DaiDienScreenV1"
    var screen := game.get_node_or_null(screen_name)
    if screen == null:
        _fail("Live P3.2 route did not create the expected B1 screen: %s." % screen_name)
        return false
    var facility_art := _find_facility_art(screen,kind)
    if facility_art == null or not bool(facility_art.get("_original_source")):
        _fail("Live B1 %s screen did not resolve its verified Source A art." % kind)
        return false
    if str(facility_art.get("_source_model_id")) != model_id:
        _fail("Live B1 %s screen resolved a different Source A model." % kind)
        return false
    var ui_texture: Variant = facility_art.get("_art")
    if not (ui_texture is Texture2D):
        _fail("Live B1 %s screen has no rendered Source A texture." % kind)
        return false
    if not await _save_frame(out_dir,filename):
        return false
    game.get_node(screen_name).queue_free()
    await process_frame
    return true

func _find_facility_art(node: Node, kind: String) -> Control:
    var script := node.get_script() as Script
    if script != null and script.resource_path == "res://src/presentation/uiux/sect_facility_art_v2.gd":
        if str(node.get("facility_kind")) == kind:
            return node as Control
    for child in node.get_children():
        var found := _find_facility_art(child,kind)
        if found != null:
            return found
    return null

func _find_button(node: Node, expected_name: String) -> Button:
    if node is Button and node.name == expected_name:
        return node as Button
    for child in node.get_children():
        var found := _find_button(child,expected_name)
        if found != null:
            return found
    return null

func _save_frame(out_dir: String, filename: String) -> bool:
    await RenderingServer.frame_post_draw
    var rendered: Image = root.get_texture().get_image()
    if rendered == null or rendered.is_empty() or rendered.get_size() != Vector2i(1280,720):
        _fail("Godot rendered no native 1280x720 frame for %s." % filename)
        return false
    var file_path := out_dir.path_join(filename)
    if rendered.save_png(file_path) != OK:
        _fail("Cannot save P3.2 screen capture %s." % file_path)
        return false
    print("TRI02_P32_CAPTURE_OK path=%s size=1280x720" % file_path)
    return true

func _remove_test_save() -> void:
    var path := ProjectSettings.globalize_path(SAVE_PATH)
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)

func _fail(message: String) -> void:
    if game != null and is_instance_valid(game):
        game.set("runtime_ready",false)
        game.queue_free()
        game = null
    _remove_test_save()
    push_error("TRI02_P32_CAPTURE_FAIL: " + message)
    quit(1)
