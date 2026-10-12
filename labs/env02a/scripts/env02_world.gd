extends Node2D
## ENV-02A ONLY: large WORLD VIEW using exactly one TransferMapModel.
## Fixed three-building preview. NO build/move/unlock gameplay or persistent layout.
const MapModel = preload("res://scripts/map_model.gd")
const EnvLarge = preload("res://scripts/env02_chunk_environment.gd")
const WORLD_GRID := Vector2i(192, 192)
const CHUNK_CELLS := 16
const INITIAL_AREA := Rect2i(72, 72, 48, 48)
const PREVIEW_SPAWN := Vector2i(82, 84)
const HALF_W := 25.0
const HALF_H := 13.0
const MAP_ORIGIN := Vector2.ZERO
const VIEW_SIZE := Vector2(1280.0, 720.0)
const MIN_ZOOM := 0.65
const MAX_ZOOM := 1.65
const DRAG_THRESHOLD := 12.0
const HOUSE_SPECS := {
    "main_hall": {"name": "TONG MON DAI DIEN", "origin": Vector2i(84, 86), "size": Vector2(300, 201), "image": "res://pv01_assets/main_hall/510052.png"},
    "warehouse": {"name": "KHO", "origin": Vector2i(96, 87), "size": Vector2(162, 138), "image": "res://pv01_assets/warehouse/510102.png"},
    "forge": {"name": "LUYEN KHI DUONG", "origin": Vector2i(92, 92), "size": Vector2(205, 164), "image": "res://pv01_assets/forge/520081.png"}
}

var model = MapModel.new(WORLD_GRID, PREVIEW_SPAWN)
var camera: Camera2D
var environment_layer
var building_sprites: Dictionary = {}
var assets_ok := true
var placements_ok := true
var roads_ok := false
var selected_id := "main_hall"
var hud_title: Label
var hud_detail: Label
var shown_chunks: Array[Vector2i] = []
var mouse_pan := false
var mouse_press := Vector2.ZERO
var mouse_moved := false
var touches: Dictionary = {}
var touch_origins: Dictionary = {}
var multi_touch_gesture := false
var old_pinch_distance := 0.0

func _ready() -> void:
    # Runtime scene is separate from PV01/ENV01; both still share map_model.gd.
    _seed_buildings()
    _seed_roads()
    environment_layer = EnvLarge.new()
    environment_layer.name = "ENV02A_CulledEnvironment"
    environment_layer.configure(model, MAP_ORIGIN, HALF_W, HALF_H)
    environment_layer.configure_district(INITIAL_AREA, PREVIEW_SPAWN, CHUNK_CELLS)
    add_child(environment_layer)
    environment_layer.set_selection(selected_id)
    camera = Camera2D.new()
    camera.name = "ENV02A_WorldCamera"
    camera.enabled = true
    camera.position = world_for(Vector2(92, 92))
    camera.zoom = Vector2.ONE
    add_child(camera)
    _install_hud()
    _update_culling()
    _update_hud()
    if OS.get_cmdline_user_args().has("--env02-verify"):
        _verify_deferred.call_deferred()

func world_for(cell: Vector2) -> Vector2:
    return MAP_ORIGIN + Vector2((cell.x - cell.y) * HALF_W, (cell.x + cell.y) * HALF_H)

func cell_for(world: Vector2) -> Vector2i:
    var u: float = (world.x - MAP_ORIGIN.x) / HALF_W
    var v: float = (world.y - MAP_ORIGIN.y) / HALF_H
    return Vector2i(roundi((u + v) * 0.5), roundi((v - u) * 0.5))

func world_from_screen(screen: Vector2) -> Vector2:
    # Camera2D world coordinates with no offset/rotation and smoothing disabled.
    return camera.position + (screen - VIEW_SIZE * 0.5) / camera.zoom

func _seed_buildings() -> void:
    for kind in ["main_hall", "warehouse", "forge"]:
        var spec: Dictionary = HOUSE_SPECS[kind]
        var origin: Vector2i = spec["origin"]
        var placement: Dictionary = model.place(kind, kind, origin)
        if not bool(placement.get("ok", false)):
            placements_ok = false
            push_error("ENV02A_PLACE_FAIL " + kind + " " + str(placement.get("reason", "?")))
            continue
        if not INITIAL_AREA.has_point(origin):
            placements_ok = false
            push_error("ENV02A_BUILDING_NOT_IN_INITIAL_AREA " + kind)
        var texture: Texture2D = load(str(spec["image"]))
        if texture == null or texture.get_width() < 1 or texture.get_height() < 1:
            assets_ok = false
            push_error("ENV02A_TEXTURE_MISSING " + kind)
            continue
        var sprite := Sprite2D.new()
        sprite.name = "SourceA_" + kind
        sprite.texture = texture
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        sprite.scale = Vector2(spec["size"]) / texture.get_size()
        var footprint: Vector2i = model.rotated_size(kind, 0)
        var center_cell := Vector2(origin.x + (footprint.x - 1) * 0.5, origin.y + (footprint.y - 1) * 0.5)
        sprite.position = world_for(center_cell) + Vector2(0.0, -float(spec["size"].y) * 0.28)
        sprite.z_index = roundi(sprite.position.y)
        add_child(sprite)
        building_sprites[kind] = sprite
        print("ENV02A_ASSET " + kind + " " + str(texture.get_size()))

func _seed_roads() -> void:
    var hall: Dictionary = model.get_building("main_hall")
    var store: Dictionary = model.get_building("warehouse")
    var forge: Dictionary = model.get_building("forge")
    if hall.is_empty() or store.is_empty() or forge.is_empty():
        push_error("ENV02A_ROAD_BUILDING_MISSING")
        return
    var hall_door: Vector2i = model.doorway("main_hall", hall["origin"], 0)
    var store_door: Vector2i = model.doorway("warehouse", store["origin"], 0)
    var forge_door: Vector2i = model.doorway("forge", forge["origin"], 0)
    var junction := Vector2i(91, 91)
    var segments := [
        [PREVIEW_SPAWN, hall_door],
        [hall_door, junction],
        [junction, store_door],
        [junction, forge_door]
    ]
    roads_ok = true
    for endpoints in segments:
        var nav: AStarGrid2D = model._navigation()
        var segment: Array[Vector2i] = nav.get_id_path(endpoints[0], endpoints[1])
        if segment.is_empty():
            roads_ok = false
            push_error("ENV02A_ROAD_DISCONNECTED " + str(endpoints))
            continue
        for cell in segment:
            if not model.occupied(cell) and cell not in model.roads:
                model.toggle_road(cell)
    for kind in ["main_hall", "warehouse", "forge"]:
        roads_ok = roads_ok and not model.path_to(kind, PREVIEW_SPAWN).is_empty()
    print("ENV02A_ROADS_OK=", roads_ok, " road_cells=", model.roads.size())

func _world_bounds() -> Rect2:
    var corners := [world_for(Vector2(0, 0)), world_for(Vector2(191, 0)), world_for(Vector2(191, 191)), world_for(Vector2(0, 191))]
    var minimum := Vector2(INF, INF)
    var maximum := Vector2(-INF, -INF)
    for point in corners:
        minimum = minimum.min(point)
        maximum = maximum.max(point)
    return Rect2(minimum - Vector2(120, 150), maximum - minimum + Vector2(240, 300))

func _clamp_camera(center: Vector2) -> Vector2:
    var bounds := _world_bounds()
    var half_view := VIEW_SIZE * 0.5 / camera.zoom
    var minimum := bounds.position + half_view
    var maximum := bounds.end - half_view
    if minimum.x > maximum.x:
        center.x = bounds.get_center().x
    else:
        center.x = clampf(center.x, minimum.x, maximum.x)
    if minimum.y > maximum.y:
        center.y = bounds.get_center().y
    else:
        center.y = clampf(center.y, minimum.y, maximum.y)
    return center

func _pan(delta_screen: Vector2) -> void:
    camera.position = _clamp_camera(camera.position - delta_screen / camera.zoom)
    _update_culling()
    _update_hud()

func _set_zoom(new_zoom: float, screen_anchor: Vector2) -> void:
    var before := world_from_screen(screen_anchor)
    var value: float = clampf(new_zoom, MIN_ZOOM, MAX_ZOOM)
    camera.zoom = Vector2.ONE * value
    camera.position = _clamp_camera(before - (screen_anchor - VIEW_SIZE * 0.5) / value)
    _update_culling()
    _update_hud()

func _chunks_for_view(center: Vector2, zoom: float) -> Array[Vector2i]:
    # Derive visible cell bounds by inverse isometric projection of the viewport
    # corners. This is not another tile occupancy/map authority.
    var half_view := VIEW_SIZE * 0.5 / zoom
    var min_cell := Vector2i(999999, 999999)
    var max_cell := Vector2i(-999999, -999999)
    for corner in [center + Vector2(-half_view.x, -half_view.y), center + Vector2(half_view.x, -half_view.y), center + Vector2(half_view.x, half_view.y), center + Vector2(-half_view.x, half_view.y)]:
        var cell: Vector2i = cell_for(corner)
        min_cell.x = mini(min_cell.x, cell.x)
        min_cell.y = mini(min_cell.y, cell.y)
        max_cell.x = maxi(max_cell.x, cell.x)
        max_cell.y = maxi(max_cell.y, cell.y)
    # Padding covers overlapping foliage/courtyard tiles and building silhouettes.
    var from_x: int = clampi(floori(float(min_cell.x - 5) / CHUNK_CELLS), 0, 11)
    var from_y: int = clampi(floori(float(min_cell.y - 5) / CHUNK_CELLS), 0, 11)
    var until_x: int = clampi(floori(float(max_cell.x + 5) / CHUNK_CELLS), 0, 11)
    var until_y: int = clampi(floori(float(max_cell.y + 5) / CHUNK_CELLS), 0, 11)
    var result: Array[Vector2i] = []
    if from_x > until_x or from_y > until_y:
        return result
    for chunk_x in range(from_x, until_x + 1):
        for chunk_y in range(from_y, until_y + 1):
            result.append(Vector2i(chunk_x, chunk_y))
    return result

func _update_culling() -> void:
    var next_chunks: Array[Vector2i] = _chunks_for_view(camera.position, camera.zoom.x)
    if shown_chunks != next_chunks:
        shown_chunks = next_chunks
        if environment_layer != null:
            environment_layer.set_visible_chunks(shown_chunks)
    for id in building_sprites:
        var sprite: Sprite2D = building_sprites[id]
        var padding := Vector2(160, 190)
        var distance := (sprite.position - camera.position).abs() * camera.zoom.x
        sprite.visible = distance.x < VIEW_SIZE.x * 0.5 + padding.x and distance.y < VIEW_SIZE.y * 0.5 + padding.y

func _pick_building(screen: Vector2) -> void:
    var world := world_from_screen(screen)
    var cell := cell_for(world)
    var id: String = model.building_at(cell) if model.inside(cell) else ""
    if id == "":
        for candidate in ["forge", "warehouse", "main_hall"]:
            var sprite: Sprite2D = building_sprites.get(candidate)
            if sprite == null or not sprite.visible:
                continue
            var dims: Vector2 = sprite.texture.get_size() * sprite.scale
            if Rect2(sprite.position - dims * 0.5, dims).has_point(world):
                id = candidate
                break
    if id != "":
        selected_id = id
        environment_layer.set_selection(id)
        _update_hud()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse := event as InputEventMouseButton
        if mouse.pressed and mouse.button_index == MOUSE_BUTTON_WHEEL_UP:
            _set_zoom(camera.zoom.x * 1.12, mouse.position)
        elif mouse.pressed and mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _set_zoom(camera.zoom.x / 1.12, mouse.position)
        elif mouse.button_index == MOUSE_BUTTON_RIGHT:
            mouse_pan = mouse.pressed
        elif mouse.button_index == MOUSE_BUTTON_LEFT:
            if mouse.pressed:
                mouse_press = mouse.position
                mouse_moved = false
            elif not mouse_moved and mouse_press.distance_to(mouse.position) < DRAG_THRESHOLD:
                _pick_building(mouse.position)
    elif event is InputEventMouseMotion and mouse_pan:
        _pan(event.relative)
    elif event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed:
            touches[touch.index] = touch.position
            touch_origins[touch.index] = touch.position
            if touches.size() > 1:
                multi_touch_gesture = true
        else:
            if touches.size() == 1 and not multi_touch_gesture and touch_origins.has(touch.index):
                if Vector2(touch_origins[touch.index]).distance_to(touch.position) < DRAG_THRESHOLD:
                    _pick_building(touch.position)
            touches.erase(touch.index)
            touch_origins.erase(touch.index)
            old_pinch_distance = 0.0
            if touches.is_empty():
                multi_touch_gesture = false
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if not touches.has(drag.index):
            return
        touches[drag.index] = drag.position
        if touches.size() == 1 and not multi_touch_gesture:
            _pan(drag.relative)
        elif touches.size() >= 2:
            var keys: Array = touches.keys()
            var distance: float = Vector2(touches[keys[0]]).distance_to(Vector2(touches[keys[1]]))
            var middle: Vector2 = (Vector2(touches[keys[0]]) + Vector2(touches[keys[1]])) * 0.5
            if old_pinch_distance > 0.0:
                _set_zoom(camera.zoom.x * (distance / old_pinch_distance), middle)
            old_pinch_distance = maxf(distance, 1.0)

func _install_hud() -> void:
    var layer := CanvasLayer.new()
    layer.name = "ENV02A_HUD_OutsideCamera"
    layer.layer = 10
    add_child(layer)
    var top := ColorRect.new()
    top.color = Color(0.05, 0.13, 0.11, 0.85)
    top.position = Vector2.ZERO
    top.size = Vector2(1280, 56)
    top.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(top)
    hud_title = Label.new()
    hud_title.position = Vector2(19, 9)
    hud_title.add_theme_font_size_override("font_size", 21)
    hud_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(hud_title)
    var bottom := ColorRect.new()
    bottom.color = Color(0.06, 0.12, 0.11, 0.81)
    bottom.position = Vector2(0, 670)
    bottom.size = Vector2(1280, 50)
    bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(bottom)
    hud_detail = Label.new()
    hud_detail.position = Vector2(19, 683)
    hud_detail.add_theme_font_size_override("font_size", 16)
    hud_detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(hud_detail)

func _update_hud() -> void:
    if hud_title == null or hud_detail == null or camera == null:
        return
    hud_title.text = "TONG MON BA DAO | ENV-02A | 192x192 logical | CHUNK 16 | " + str(shown_chunks.size()) + "/144 chunks"
    var b: Dictionary = model.get_building(selected_id)
    if b.is_empty():
        return
    var door: Vector2i = model.doorway(selected_id, b["origin"], b["orientation"])
    hud_detail.text = str(HOUSE_SPECS[selected_id]["name"]) + " | door " + str(door) + " | zoom " + str(roundi(camera.zoom.x * 100)) + "% | swipe/pinch (Android), right drag/wheel (PC)"

func _verify_deferred() -> void:
    # Complete a real Godot model/runtime gate without requiring GUI screenshots.
    var legacy = MapModel.new()
    var legacy_ok: bool = legacy.grid_size == Vector2i(20, 13) and legacy.spawn_cell == Vector2i.ZERO
    for entry in [["main_hall", Vector2i(2, 2)], ["warehouse", Vector2i(14, 3)], ["forge", Vector2i(10, 8)]]:
        var placed: Dictionary = legacy.place(entry[0], entry[0], entry[1])
        legacy_ok = legacy_ok and bool(placed.get("ok", false))
    legacy_ok = legacy_ok and not bool(legacy.validate("warehouse", Vector2i(3, 3), 0).get("ok", true))
    for id in ["main_hall", "warehouse", "forge"]:
        legacy_ok = legacy_ok and not legacy.path_to(id, Vector2i.ZERO).is_empty()
    var size_ok: bool = model.grid_size == WORLD_GRID and model.inside(Vector2i(191, 191)) and not model.inside(Vector2i(192, 191)) and not model.inside(Vector2i(-1, 0))
    var buildings_ok: bool = assets_ok and placements_ok and building_sprites.size() == 3
    var routes_ok: bool = roads_ok
    for id in ["main_hall", "warehouse", "forge"]:
        var building: Dictionary = model.get_building(id)
        var door: Vector2i = model.doorway(id, building.get("origin", Vector2i.ZERO), 0)
        var route: Array[Vector2i] = model.path_to(id, PREVIEW_SPAWN)
        routes_ok = routes_ok and model.inside(door) and not model.occupied(door) and route.size() > 0
        if not route.is_empty():
            routes_ok = routes_ok and route.back() == door
    var chunk_ok: bool = shown_chunks.size() > 0 and shown_chunks.size() < 144
    for c in shown_chunks:
        chunk_ok = chunk_ok and c.x >= 0 and c.y >= 0 and c.x < 12 and c.y < 12
    var old_center := camera.position
    _pan(Vector2(300, 80))
    var pan_ok: bool = camera.position != old_center
    _set_zoom(1.22, VIEW_SIZE * 0.5)
    var zoom_ok: bool = is_equal_approx(camera.zoom.x, 1.22)
    camera.position = world_for(Vector2(92, 92))
    camera.zoom = Vector2.ONE
    _update_culling()
    _update_hud()
    var overall: bool = legacy_ok and size_ok and buildings_ok and routes_ok and chunk_ok and pan_ok and zoom_ok and environment_layer.art_load_ok and environment_layer.decor_layout_ok
    print("ENV02A_ASSERT legacy_20x13=", legacy_ok, " grid_192x192=", size_ok, " buildings=", buildings_ok, " AStar=", routes_ok, " chunks=", chunk_ok, " pan=", pan_ok, " zoom=", zoom_ok, " art=", environment_layer.art_load_ok, " decor=", environment_layer.decor_layout_ok)
    print("ENV02A_RESULT ", "PASS_STRUCTURE" if overall else "FAIL_STRUCTURE")
    get_tree().quit(0 if overall else 3)