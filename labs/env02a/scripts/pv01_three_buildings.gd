extends Node2D
## PV-01 visual-only pilot. Reuses the original TransferMapModel for
## occupied cells, placement validation, rotated footprints, doorway and AStar.
## Never mutates canonical TongMon gameplay, Warehouse, save or EXP.

const MapModel = preload("res://scripts/map_model.gd")
const EnvironmentRenderer = preload("res://scripts/env01_environment.gd")
const HALF_W := 25.0
const HALF_H := 13.0
const MAP_ORIGIN := Vector2(500.0, 135.0)
const VIEW_SIZE := Vector2(1280.0, 720.0)
const START_CAMERA := Vector2(640.0, 360.0)
const BUILDING_DATA := {
    "main_hall": {"name": "TONG MON DAI DIEN", "origin": Vector2i(2, 2), "width": 300.0, "height": 201.0, "image": "res://pv01_assets/main_hall/510052.png"},
    "warehouse": {"name": "KHO", "origin": Vector2i(14, 3), "width": 162.0, "height": 138.0, "image": "res://pv01_assets/warehouse/510102.png"},
    "forge": {"name": "LUYEN KHI DUONG", "origin": Vector2i(10, 8), "width": 205.0, "height": 164.0, "image": "res://pv01_assets/forge/520081.png"}
}

var model = MapModel.new()
var placement_ok := true
var loaded_assets: Dictionary = {}
var sprites: Dictionary = {}
var selected_id := "main_hall"
var status := "Chon cong trinh: click/tap | Pan: right-drag / touch-drag | Zoom: wheel/pinch"
var camera: Camera2D
var drag_right := false
var touch_points: Dictionary = {}
var touch_start: Dictionary = {}
var touch_moved: Dictionary = {}
var pinch_distance := 0.0
var top_status: Label
var detail_status: Label
var environment_layer
var connected_routes_ok := false

func _ready() -> void:
    camera = Camera2D.new()
    camera.name = "PV01MapCamera"
    camera.position = START_CAMERA
    camera.zoom = Vector2.ONE
    camera.enabled = true
    add_child(camera)

    for id in ["main_hall", "warehouse", "forge"]:
        var d: Dictionary = BUILDING_DATA[id]
        var placement: Dictionary = model.place(id, id, d["origin"])
        if not placement.get("ok", false):
            placement_ok = false
            push_error("PV01_INITIAL_PLACE_FAILED " + id + " " + str(placement.get("reason", "unknown")))
        else:
            print("PV01_PLACE ", id, " footprint=", model.rotated_size(id, 0), " doorway=", placement["door"])
        var tex: Texture2D = load(d["image"])
        loaded_assets[id] = tex != null and tex.get_width() > 0 and tex.get_height() > 0
        if tex == null:
            push_error("PV01_ASSET_MISSING " + id)
            continue
        var s := Sprite2D.new()
        s.name = "Building_" + id
        s.texture = tex
        s.centered = true
        s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        s.scale = Vector2(float(d["width"]) / float(tex.get_width()), float(d["height"]) / float(tex.get_height()))
        var footprint: Vector2i = model.rotated_size(id, 0)
        var grid_origin: Vector2i = d["origin"]
        var cell_mid := Vector2(grid_origin.x + float(footprint.x - 1) * 0.5, grid_origin.y + float(footprint.y - 1) * 0.5)
        s.position = world_for(cell_mid) + Vector2(0.0, -float(d["height"]) * 0.28)
        s.z_index = int(s.position.y)
        add_child(s)
        sprites[id] = s
        print("PV01_ASSET_LOADED ", id, " dimensions=", tex.get_width(), "x", tex.get_height(), " display=", d["width"], "x", d["height"])

    _connect_source_a_roads()
    environment_layer = EnvironmentRenderer.new()
    environment_layer.name = "ENV01_SourceAEnvironment"
    environment_layer.configure(model, MAP_ORIGIN, HALF_W, HALF_H)
    add_child(environment_layer)
    environment_layer.set_selection(selected_id)
    _install_hud()
    _refresh_hud()
    queue_redraw()
    if OS.get_cmdline_user_args().has("--env01-verify"):
        _run_env01_verify.call_deferred()
    elif OS.get_cmdline_user_args().has("--pv01-smoke"):
        _run_smoke.call_deferred()


func _connect_source_a_roads() -> void:
    # Visual-only roads. Use the original MapModel AStar grid and its
    # building occupancy; never create an alternate navigation authority.
    var hall: Dictionary = model.get_building("main_hall")
    var warehouse: Dictionary = model.get_building("warehouse")
    var forge: Dictionary = model.get_building("forge")
    if hall.is_empty() or warehouse.is_empty() or forge.is_empty():
        push_error("ENV01_ROADS_MISSING_BUILDINGS")
        return
    var hall_door: Vector2i = model.doorway("main_hall", hall["origin"], 0)
    var warehouse_door: Vector2i = model.doorway("warehouse", warehouse["origin"], 0)
    var forge_door: Vector2i = model.doorway("forge", forge["origin"], 0)
    var junction := Vector2i(9, 7)
    var pairs := [
        [MapModel.SPAWN, hall_door],
        [hall_door, junction],
        [junction, warehouse_door],
        [junction, forge_door]
    ]
    connected_routes_ok = true
    for endpoints in pairs:
        var nav: AStarGrid2D = model._navigation()
        var segment: Array[Vector2i] = nav.get_id_path(endpoints[0], endpoints[1])
        if segment.is_empty():
            connected_routes_ok = false
            push_error("ENV01_ROAD_SEGMENT_UNREACHABLE " + str(endpoints))
            continue
        for cell in segment:
            if not model.occupied(cell) and cell not in model.roads:
                model.toggle_road(cell)
    for id in ["main_hall", "warehouse", "forge"]:
        connected_routes_ok = connected_routes_ok and not model.path_to(id, MapModel.SPAWN).is_empty()
    print("ENV01_ROADS linked=", connected_routes_ok, " paved_cells=", model.roads.size())

func _run_env01_verify() -> void:
    var buildings_ok := placement_ok and loaded_assets.size() == 3
    for id in ["main_hall", "warehouse", "forge"]:
        buildings_ok = buildings_ok and bool(loaded_assets.get(id, false))
    var art_ok: bool = environment_layer != null and environment_layer.art_load_ok
    var decorations_ok: bool = environment_layer != null and environment_layer.decor_layout_ok and environment_layer.decoration_count >= 10
    var routes_ok: bool = connected_routes_ok and environment_layer.validate_existing_routes()
    var no_occupied_road := true
    for cell in model.roads:
        if model.occupied(cell):
            no_occupied_road = false
    var result_pass: bool = buildings_ok and art_ok and decorations_ok and routes_ok and no_occupied_road
    print("ENV01_VERIFY buildings=", buildings_ok, " art=", art_ok, " decoration=", decorations_ok, " routes=", routes_ok, " road_clear=", no_occupied_road)
    print("ENV01_RESULT ", "PASS_STRUCTURE" if result_pass else "FAIL_STRUCTURE")
    get_tree().quit(0 if result_pass else 3)

func world_for(cell: Vector2) -> Vector2:
    return MAP_ORIGIN + Vector2((cell.x - cell.y) * HALF_W, (cell.x + cell.y) * HALF_H)

func cell_for(world: Vector2) -> Vector2i:
    var u := (world.x - MAP_ORIGIN.x) / HALF_W
    var v := (world.y - MAP_ORIGIN.y) / HALF_H
    return Vector2i(roundi((u + v) * 0.5), roundi((v - u) * 0.5))

func world_from_screen(screen: Vector2) -> Vector2:
    return get_viewport().get_canvas_transform().affine_inverse() * screen

func _diamond(center: Vector2, color: Color, outline: Color) -> void:
    var points := PackedVector2Array([
        center + Vector2(0, -HALF_H), center + Vector2(HALF_W, 0),
        center + Vector2(0, HALF_H), center + Vector2(-HALF_W, 0)
    ])
    draw_colored_polygon(points, color)
    for i in range(4):
        draw_line(points[i], points[(i + 1) % 4], outline, 1.2)

func _draw() -> void:
    # The ENV-01 child owns terrain, roads and selection highlights.
    pass

func _install_hud() -> void:
    var hud := CanvasLayer.new()
    hud.layer = 8
    hud.name = "PV01FixedHUD"
    add_child(hud)
    var top := ColorRect.new()
    top.color = Color(0.06, 0.11, 0.10, 0.92)
    top.position = Vector2.ZERO
    top.size = Vector2(1280, 82)
    top.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(top)
    var title := Label.new()
    title.text = "TONG MON BA DAO  |  ENV-01 SOURCE A  /  THREE BUILDINGS"
    title.position = Vector2(30, 10)
    title.add_theme_font_size_override("font_size", 23)
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(title)
    top_status = Label.new()
    top_status.position = Vector2(30, 48)
    top_status.add_theme_font_size_override("font_size", 14)
    top_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(top_status)
    var bottom := ColorRect.new()
    bottom.color = Color(0.05, 0.11, 0.10, 0.93)
    bottom.position = Vector2(0, 622)
    bottom.size = Vector2(1280, 98)
    bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(bottom)
    detail_status = Label.new()
    detail_status.position = Vector2(28, 635)
    detail_status.add_theme_font_size_override("font_size", 20)
    detail_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(detail_status)
    var help := Label.new()
    help.text = "Source A terrain / stone road / trees / bamboo / rock / lantern  |  Grid + AStar unchanged  |  Right-drag / touch pan; wheel / pinch zoom"
    help.position = Vector2(29, 687)
    help.add_theme_font_size_override("font_size", 13)
    help.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(help)

func _refresh_hud() -> void:
    if top_status == null or detail_status == null:
        return
    top_status.text = status
    var b: Dictionary = model.get_building(selected_id)
    if b.is_empty():
        detail_status.text = "Chua chon cong trinh"
        return
    var door: Vector2i = model.doorway(b["kind"], b["origin"], b["orientation"])
    var route: Array[Vector2i] = model.path_to(selected_id, MapModel.SPAWN)
    detail_status.text = str(BUILDING_DATA[selected_id]["name"]) + "    footprint: " + str(model.rotated_size(b["kind"], b["orientation"])) + "    door: " + str(door) + "    AStar: " + str(route.size()) + " cells"

func _zoom(next_zoom: float) -> void:
    var z := clampf(next_zoom, 0.65, 1.65)
    camera.zoom = Vector2(z, z)
    status = "Zoom " + str(snappedf(z * 100.0, 1.0)) + "%"
    _refresh_hud()

func _select_world(point: Vector2) -> String:
    var cell := cell_for(point)
    var id := model.building_at(cell) if model.inside(cell) else ""
    if id == "":
        # Sprite silhouette may exceed the actual footprint. Rect is a visual-only
        # click fallback; primary selection remains canonical grid occupancy.
        var order := ["forge", "warehouse", "main_hall"]
        for candidate in order:
            if not sprites.has(candidate):
                continue
            var s: Sprite2D = sprites[candidate]
            var dimensions: Vector2 = s.texture.get_size() * s.scale
            if Rect2(s.position - dimensions * 0.5, dimensions).has_point(point):
                id = candidate
                break
    if id != "":
        selected_id = id
        status = "Selected: " + str(BUILDING_DATA[id]["name"]) + "  [visual-only - no gameplay mutation]"
    else:
        status = "No building at " + str(cell)
    _refresh_hud()
    if environment_layer != null:
        environment_layer.set_selection(selected_id)
    queue_redraw()
    return id

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            _zoom(camera.zoom.x * 1.12)
            get_viewport().set_input_as_handled()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            _zoom(camera.zoom.x / 1.12)
            get_viewport().set_input_as_handled()
        elif event.button_index == MOUSE_BUTTON_RIGHT:
            drag_right = event.pressed
        elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            if event.position.y > 82.0 and event.position.y < 622.0:
                _select_world(world_from_screen(event.position))
                get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and drag_right:
        camera.position -= event.relative / camera.zoom
        status = "Camera pan: " + str(camera.position.round())
        _refresh_hud()
    elif event is InputEventScreenTouch:
        if event.pressed:
            touch_points[event.index] = event.position
            touch_start[event.index] = event.position
            touch_moved[event.index] = false
        else:
            if touch_points.has(event.index) and not bool(touch_moved.get(event.index, false)):
                if event.position.y > 82.0 and event.position.y < 622.0:
                    _select_world(world_from_screen(event.position))
            touch_points.erase(event.index)
            touch_start.erase(event.index)
            touch_moved.erase(event.index)
            pinch_distance = 0.0
    elif event is InputEventScreenDrag:
        if not touch_points.has(event.index):
            return
        touch_points[event.index] = event.position
        if event.position.distance_to(touch_start.get(event.index, event.position)) > 10.0:
            touch_moved[event.index] = true
        if touch_points.size() == 1:
            camera.position -= event.relative / camera.zoom
        elif touch_points.size() == 2:
            var indexes := touch_points.keys()
            var distance: float = Vector2(touch_points[indexes[0]]).distance_to(Vector2(touch_points[indexes[1]]))
            if pinch_distance > 0.0:
                _zoom(camera.zoom.x * (distance / pinch_distance))
            pinch_distance = distance

func _run_smoke() -> void:
    var all_loaded := loaded_assets.size() == 3
    for id in ["main_hall", "warehouse", "forge"]:
        all_loaded = all_loaded and bool(loaded_assets.get(id, false))
    var overlap_rejected := not bool(model.validate("warehouse", Vector2i(3, 3), 0).get("ok", true))
    var door_outside_rejected := not bool(model.validate("forge", Vector2i(11, 0), 0).get("ok", true))
    var routes_pass := true
    var doorway_pass := true
    for id in ["main_hall", "warehouse", "forge"]:
        var b: Dictionary = model.get_building(id)
        if b.is_empty():
            routes_pass = false
            doorway_pass = false
            continue
        var door: Vector2i = model.doorway(id, b["origin"], 0)
        doorway_pass = doorway_pass and model.inside(door) and not model.occupied(door)
        var route: Array[Vector2i] = model.path_to(id, MapModel.SPAWN)
        routes_pass = routes_pass and route.size() > 0 and route.back() == door
        for c in route:
            routes_pass = routes_pass and not model.occupied(c)
    var selection_pass := _select_world(world_for(Vector2(3, 3))) == "main_hall"
    var before_cam := camera.position
    _zoom(1.25)
    camera.position += Vector2(37.0, 22.0)
    var camera_pass := camera.zoom.x > 1.0 and camera.position != before_cam
    camera.position = START_CAMERA
    camera.zoom = Vector2.ONE
    selected_id = "main_hall"
    if environment_layer != null:
        environment_layer.set_selection(selected_id)
    status = "PV-01  |  3 ORIGINAL SOURCE A PNGs  |  Camera / Click / Footprint / Doorway"
    _refresh_hud()
    queue_redraw()
    await get_tree().process_frame
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var img := get_viewport().get_texture().get_image()
    var size_pass := img.get_width() == 1280 and img.get_height() == 720
    var diversity: Dictionary = {}
    if size_pass:
        for x in range(250, 1150, 27):
            for y in range(105, 545, 27):
                diversity[img.get_pixel(x, y).to_html()] = true
    var appearance_pass := diversity.size() >= 24
    var out_dir := ProjectSettings.globalize_path("res://PV01_EVIDENCE")
    var mk_err := DirAccess.make_dir_recursive_absolute(out_dir)
    var screenshot_error := ERR_CANT_CREATE
    if mk_err == OK and size_pass:
        screenshot_error = img.save_png(out_dir.path_join("pv01_three_buildings.png"))
    var result_pass := placement_ok and all_loaded and overlap_rejected and door_outside_rejected and routes_pass and doorway_pass and selection_pass and camera_pass and size_pass and appearance_pass and screenshot_error == OK
    print("PV01_ASSERT placement=", placement_ok, " asset_load=", all_loaded, " overlap_rejected=", overlap_rejected, " door_outside_rejected=", door_outside_rejected, " doorway=", doorway_pass, " astar=", routes_pass, " select=", selection_pass, " camera=", camera_pass)
    print("PV01_CAPTURE resolution=", img.get_width(), "x", img.get_height(), " unique_colors=", diversity.size(), " visual_diversity=", appearance_pass, " png_error=", screenshot_error)
    print("PV01_RESULT ", "PASS" if result_pass else "FAIL")
    get_tree().quit(0 if result_pass else 3)