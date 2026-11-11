extends SceneTree
## AS-BUILD01: real map placement / Source-A-style new candidate at the actual canonical Alchemy Hall.
## Actual Godot X11 screenshot only. Not physical Windows/Android, not owner-accepted artwork.
const SAVE_PATH := "user://as_build01_visual_isolated.json"
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("Requires Xvfb/Mesa real software render; no headless fake screenshot")
        return
    var args := OS.get_cmdline_user_args()
    if args.is_empty():
        _fail("Missing evidence directory")
        return
    var out := args[0]
    DirAccess.make_dir_recursive_absolute(out)
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    DisplayServer.window_set_size(Vector2i(1280,720))
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("Missing canonical OneGame scene")
        return
    var game := scene.instantiate() as Control
    root.add_child(game)
    for i in range(10):
        await process_frame
    if not bool(game.get("runtime_ready")):
        _fail("Canonical runtime not initialized")
        return
    var world := game.get("iso_world") as SectIsometricWorldV1
    if world == null or not world.candidate_site_art.has("alchemy_hall"):
        _fail("AS-BUILD01 SVG not imported as real map candidate")
        return
    var target := {}
    for row in world.display_instances:
        if str(row.get("destination","")) == "alchemy_hall" and bool(row.get("managed",false)):
            target = row
            break
    if target.is_empty():
        _fail("No actual alchemy BuildingState to frame; visual tests must not create fake buildings")
        return
    if game.has_method("_close_building_operation_panel"):
        game.call("_close_building_operation_panel",true)
    game.set_process(false) # prevent the live camera follow from recentring during this isolated capture
    world.camera.position = target["world"]
    world.camera.zoom = Vector2(1.0,1.0)
    world.queue_redraw()
    var sub := game.get("iso_viewport") as SubViewport
    if sub != null:
        sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    for i in range(6):
        await process_frame
    await RenderingServer.frame_post_draw
    var screenshot := root.get_texture().get_image()
    if screenshot == null or screenshot.is_empty() or screenshot.get_size() != Vector2i(1280,720):
        _fail("Real map capture size or content invalid")
        return
    var path := out.path_join("as_build01_alchemy_real_map_focus_1280x720.png")
    if screenshot.save_png(path) != OK:
        _fail("Failed to save real scene capture")
        return
    print("AS_BUILD01_REAL_MAP_FOCUS PASS ",path," source_art_candidate=alchemy_hall; no synthetic building")
    game.set("runtime_ready",false)
    game.queue_free()
    for i in range(5):
        await process_frame
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    quit(0)
func _fail(message: String) -> void:
    push_error("AS_BUILD01_MAP_CAPTURE FAIL "+message)
    quit(1)
