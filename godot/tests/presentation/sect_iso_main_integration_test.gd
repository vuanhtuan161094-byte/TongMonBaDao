extends SceneTree

# MAP-2.5D V1: scene-bound camera, chunk projection and canonical building
# tap. Requires actual Godot 4.7.2 runtime; static review != runtime PASS.
const SAVE_PATH := "user://sect_iso_main_integration_test.json"
var scene: Control
var iso: SectIsometricWorldV1

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("main landscape scene absent")
        return
    scene = packed.instantiate() as Control
    root.add_child(scene)
    await process_frame
    var state := scene.get("state") as SimulationState
    if state == null or not bool(scene.get("runtime_ready")):
        _fail("canonical runtime unavailable")
        return
    var container := scene.find_child("SectMainIsoViewportContainer",true,false) as SubViewportContainer
    var sub := scene.find_child("SectMainIsoSubViewport",true,false) as SubViewport
    iso = scene.find_child("SectIsoWorld192",true,false) as SectIsometricWorldV1
    if container == null or sub == null or iso == null or iso.camera == null:
        _fail("main scene did not mount genuine 2.5D SubViewport/Camera2D")
        return
    var original_map_layer := scene.get("map_layer") as Control
    if original_map_layer == null or container.get_index() >= original_map_layer.get_index():
        _fail("isometric texture overpaints avatar/map interaction layer")
        return
    if (
        sub.size != Vector2i(1028,570)
        or iso.GRID != Vector2i(192,192)
        or iso.CHUNK != 16
        or iso.STARTER != Rect2i(72,72,48,48)
    ):
        _fail("main scene's map does not match ENV02A 192x192/48x48/16")
        return
    if iso.active_chunks.is_empty() or iso.active_chunks.size() > 144:
        _fail("initial camera did not cull chunks")
        return
    # The main world reuses the lab's authentic TransferMapModel AStar API.
    if iso.lab_geometry == null or iso.lab_geometry.grid_size != Vector2i(192,192) or not iso.lab_routes_ready:
        _fail("ENV02A geometry/doorway and AStar routes are not active")
        return
    for kind in ["main_hall","warehouse","forge"]:
        if iso.lab_geometry.path_to(kind,iso.SPAWN_CELL).is_empty():
            _fail("main-world lab route to "+kind+" is broken")
            return
    var initial_snapshot := state.to_dict()
    var first := BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_MINE)
    if first == null:
        _fail("real Mine BuildingState missing")
        return
    var matched_instance: Dictionary = {}
    for item in iso.display_instances:
        if item["building_id"] == first.id:
            matched_instance = item
            break
    if matched_instance.is_empty():
        _fail("main isometric world did not project canonical Mine ID")
        return
    var mine_world: Vector2 = matched_instance["world"]
    var screen := iso.MAP_SCREEN_OFFSET+iso.VIEW_SIZE*0.5+(
        mine_world+Vector2(0,-36)-iso.camera.position
    )*iso.camera.zoom.x
    if not SectMapCamera.is_map_screen_point(screen):
        _fail("Mine world building outside default tap viewport")
        return
    var picked := iso.pick_at_screen(screen)
    if StringName(picked.get("building_id","")) != first.id:
        _fail("isometric camera ray picking lost canonical BuildingState ID")
        return
    if not bool(scene.call("_try_iso_map_pick",screen)):
        _fail("tap did not open actual management panel")
        return
    await process_frame
    if (
        StringName(scene.get("selected_production_instance_id")) != first.id
        or StringName(scene.get("selected_building")) != SectMapPresentation.DEST_MINE
    ):
        _fail("2.5D Mine selection did not reach exact WorkForce panel")
        return
    var panel := scene.find_child("BuildingOperationPanel",true,false) as Panel
    if panel == null or not panel.visible:
        _fail("actual one-worker management HUD failed to open")
        return
    # Vertical movement retains horizontal-facing art, left mirrored, no
    # requirement for separate up/down sprite sheets in the map renderer.
    var vertical_left: Vector2 = scene.call("_iso_two_direction_delta",Vector2(0,-85),&"left")
    var vertical_right: Vector2 = scene.call("_iso_two_direction_delta",Vector2(0,85),&"right")
    if vertical_left != Vector2(-1,0) or vertical_right != Vector2(1,0):
        _fail("up/down travel unexpectedly required a third/fourth sprite facing")
        return
    scene.call("_close_building_operation_panel",true)
    scene.call("_pan_camera",Vector2(-90,40))
    await process_frame
    scene.call("_zoom_at",Vector2(620,340),1.28,false)
    await process_frame
    if not is_equal_approx(iso.camera.zoom.x,float(scene.get("map_zoom"))):
        _fail("real camera zoom and UI zoom diverged")
        return
    var changed := iso.active_chunks.duplicate()
    if changed.is_empty() or changed.size() > 144:
        _fail("pan and pinch broke chunk culling")
        return
    if state.to_dict() != initial_snapshot:
        _fail("2.5D selection/camera erroneously mutated canonical save data")
        return
    print("MAP 2.5D REAL MAIN SCENE WORKFORCE CAMERA PASS")
    scene.queue_free()
    quit(0)

func _fail(reason: String) -> void:
    push_error("MAP 2.5D INTEGRATION FAIL: "+reason)
    if scene != null:
        scene.queue_free()
    quit(1)
