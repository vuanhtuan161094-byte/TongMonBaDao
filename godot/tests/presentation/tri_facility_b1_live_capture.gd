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
const REQUIRED_MAP_ART := [
    "pv01_assets/main_hall/510052.png",
    "pv01_assets/residence/510076.png",
    "pv01_assets/guidance/510111.png"
]

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
    for relative in REQUIRED_MAP_ART:
        if not loaded_art.has(relative):
            _fail("P3.2 map did not load SHA-gated Source A building %s." % relative)
            return

    if not await _save_frame(out_dir,"00_p3_2_map_context.png"):
        return
    if not await _open_from_map(SectMapPresentation.DEST_MAIN_HALL,"OpenDaiDienScreenV1",out_dir,CAPTURE_FILES["hall"]):
        return
    if not await _open_from_map(SectMapPresentation.DEST_RESIDENCE,"OpenResidenceManagementV1",out_dir,CAPTURE_FILES["residence"]):
        return
    if not await _open_from_map(SectMapPresentation.DEST_GUIDANCE,"OpenDanTienScreenV2",out_dir,CAPTURE_FILES["guidance"]):
        return

    game.set("runtime_ready",false)
    game.queue_free()
    await process_frame
    game = null
    _remove_test_save()
    print("TRI02_P32_CONTEXT_CAPTURE_PASS map=1 hall=1 residence=1 guidance=1 size=1280x720")
    quit(0)

func _open_from_map(destination: StringName, button_name: String, out_dir: String, filename: String) -> bool:
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
    if game.get_node_or_null(screen_name) == null:
        _fail("Live P3.2 route did not create the expected B1 screen: %s." % screen_name)
        return false
    if not await _save_frame(out_dir,filename):
        return false
    game.get_node(screen_name).queue_free()
    await process_frame
    return true

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
