extends SceneTree

# Read-only visual design map, NOT a 300-monster gameplay integration test.
const PREVIEW_SCENE := "res://scenes/p3/pve_world_topology_preview_v1.tscn"


func _init() -> void:
    call_deferred("_run")


func _fail(message: String) -> void:
    push_error("PVE TOPOLOGY PREVIEW CONTRACT FAIL: "+message)
    quit(1)


func _run() -> void:
    var scene: PackedScene = load(PREVIEW_SCENE) as PackedScene
    if scene == null:
        _fail("visual-only 20-camp preview scene not loadable")
        return
    var preview := scene.instantiate() as PveWorldTopologyPreviewV1
    if preview == null:
        _fail("preview scene script is not PveWorldTopologyPreviewV1")
        return
    root.add_child(preview)
    await process_frame
    if PveWorldTopologyPreviewV1.WORLD_CELLS != Vector2(256,192):
        _fail("draft 256x192 topology scale unexpectedly changed")
        return
    if PveWorldTopologyPreviewV1.CAMP_COUNTS.size() != 20 or PveWorldTopologyPreviewV1.design_population() != 300:
        _fail("20 proposed camps / 300 proposed normal-monster count mismatch")
        return
    var unique: Dictionary = {}
    for index in range(20):
        var at := PveWorldTopologyPreviewV1.camp_cell(index)
        var id := PveWorldTopologyPreviewV1.camp_id(index)
        if at.x <= 0.0 or at.y <= 0.0 or at.x >= 256.0 or at.y >= 192.0:
            _fail("camp coordinate out of bounds: "+id)
            return
        if unique.has(at) or id != "C%02d" % (index+1):
            _fail("duplicate or mislabeled camp: "+id)
            return
        unique[at] = true
    var links := PveWorldTopologyPreviewV1.design_edges()
    if links.size() != 30 or not PveWorldTopologyPreviewV1.design_graph_connected():
        _fail("draft topology must have exactly 30 road edges and be connected")
        return
    var forbidden := Vector2i(7,8) # C08 -> C09 has no bridge.
    for edge in links:
        if edge == forbidden or edge == Vector2i(8,7):
            _fail("unbridged C08-C09 crossing was included")
            return
    for bridge in [Vector2i(2,3),Vector2i(12,13),Vector2i(17,18)]:
        if bridge not in links:
            _fail("proposed north/central/south bridge missing: "+str(bridge))
            return
    var before_screen := preview.cell_to_screen(PveWorldTopologyPreviewV1.camp_cell(7))
    if before_screen.distance_to(preview.cell_to_screen(Vector2(124.0,64.0))) > 0.001:
        _fail("C08 map projection differs from source coordinate")
        return
    var cell_back := preview.screen_to_cell(before_screen)
    if cell_back.distance_to(Vector2(124.0,64.0)) > 0.001:
        _fail("map projection is not invertible")
        return
    if preview.select_at(before_screen) != 7:
        _fail("clicking C08 does not select C08")
        return
    preview._zoom_at(before_screen,1.20)
    var after_zoom := preview.cell_to_screen(Vector2(124.0,64.0))
    if before_screen.distance_to(after_zoom) > 0.01:
        _fail("zoom anchor moved selected camp off the pointer")
        return
    preview.camera_pan += Vector2(-42.0,26.0)
    var after_pan := preview.cell_to_screen(Vector2(124.0,64.0))
    if after_pan.distance_to(after_zoom) < 40.0:
        _fail("camera pan did not move map")
        return
    preview.queue_redraw()
    await process_frame
    print("PVE WORLD TOPOLOGY PREVIEW CONTRACT PASS world=256x192 camps=20 population=300_design_only roads=30 bridges=3 camera=pan_zoom")
    quit(0)
