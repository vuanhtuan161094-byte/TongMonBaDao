extends Node2D

const MapModel = preload("res://scripts/map_model.gd")
const MAIN_HALL_PREVIEW = preload("res://source_visuals/510052.png")
const TILE_HALF_W := 25.0
const TILE_HALF_H := 13.0
const MAP_ORIGIN := Vector2(500, 100)
const DISPLAY_KINDS := ["main_hall", "mine", "spirit_field", "warehouse", "forest"]
const BUTTON_W := 175.0

var model = MapModel.new()
var actor_cell := Vector2i(0, 0)
var actor_screen := Vector2.ZERO
var visual_state := "IDLE"
var route: Array[Vector2i] = []
var route_index := 0
var route_t := 0.0
var target_id := "mine"
var work_time := 0.0
var selected_kind := ""
var moving_id := ""
var orientation := 0
var preview_cell := Vector2i(-1, -1)
var road_mode := false
var status_text := "Click a building to move; choose a button to place; Q rotate; R road mode."
var last_revision := 0

func _ready() -> void:
	for spec in [
		["main_hall", "main_hall", Vector2i(2, 2)],
		["mine", "mine", Vector2i(12, 2)],
		["spirit_field", "spirit_field", Vector2i(10, 7)],
		["warehouse", "warehouse", Vector2i(3, 9)],
		["forest", "forest", Vector2i(16, 8)],
	]:
		var result := model.place(spec[0], spec[1], spec[2])
		if not result["ok"]:
			push_error("INITIAL_PLACE_FAILED " + spec[0] + ": " + result["reason"])
	actor_screen = screen_for(actor_cell)
	last_revision = model.revision
	set_target("mine")
	if OS.get_cmdline_user_args().has("--transfer-smoke"):
		_run_smoke.call_deferred()

func screen_for(cell: Vector2i) -> Vector2:
	return MAP_ORIGIN + Vector2((cell.x - cell.y) * TILE_HALF_W, (cell.x + cell.y) * TILE_HALF_H)

func cell_for(point: Vector2) -> Vector2i:
	var u := (point.x - MAP_ORIGIN.x) / TILE_HALF_W
	var v := (point.y - MAP_ORIGIN.y) / TILE_HALF_H
	return Vector2i(roundi((u + v) * 0.5), roundi((v - u) * 0.5))

func set_target(id: String) -> void:
	target_id = id
	route = model.path_to(id, actor_cell)
	route_index = 1
	route_t = 0.0
	visual_state = "WALK" if route.size() > 1 else "IDLE"
	status_text = "Route to " + id + " doorway: " + str(route.size()) + " cells; nav revision " + str(model.revision)
	queue_redraw()

func _process(delta: float) -> void:
	if model.revision != last_revision:
		last_revision = model.revision
		set_target(target_id)
	if visual_state == "WALK" and route_index < route.size():
		route_t += delta * 3.4
		if route_t >= 1.0:
			actor_cell = route[route_index]
			route_index += 1
			route_t = 0.0
			if route_index >= route.size():
				visual_state = "WORK"
				work_time = 2.0
				status_text = "Arrived at " + target_id + " doorway. WORK visual only."
		if route_index < route.size():
			actor_screen = screen_for(actor_cell).lerp(screen_for(route[route_index]), route_t)
		else:
			actor_screen = screen_for(actor_cell)
	elif visual_state == "WORK":
		work_time -= delta
		if work_time <= 0.0:
			visual_state = "IDLE"
			status_text = "IDLE. Choose another building or move the Mine to recompute path."
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		preview_cell = cell_for(event.position)
		queue_redraw()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q and (selected_kind != "" or moving_id != ""):
			orientation = (orientation + 1) % 4
			status_text = "Orientation " + str(orientation * 90) + " degrees"
		if event.keycode == KEY_R:
			road_mode = not road_mode
			selected_kind = ""
			moving_id = ""
			status_text = "Road paint ON" if road_mode else "Road paint OFF"
		queue_redraw()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var point: Vector2 = event.position
		if point.y >= 620.0:
			var index := int((point.x - 20.0) / BUTTON_W)
			if index >= 0 and index < DISPLAY_KINDS.size():
				selected_kind = DISPLAY_KINDS[index]
				moving_id = ""
				orientation = 0
				road_mode = false
				status_text = "Placing " + selected_kind + "; click map tile, Q to rotate."
				queue_redraw()
			return
		var cell := cell_for(point)
		if not model.inside(cell):
			return
		if road_mode:
			status_text = "Road toggled at " + str(cell) if model.toggle_road(cell) else "Road blocked by building"
		elif moving_id != "":
			var result := model.move(moving_id, cell, orientation, actor_cell)
			status_text = "Moved " + moving_id if result["ok"] else "Cannot move: " + result["reason"]
			if result["ok"]:
				moving_id = ""
				selected_kind = ""
		elif selected_kind != "":
			var id := selected_kind + "_" + str(model.buildings.size() + 1)
			var result := model.place(id, selected_kind, cell, orientation, actor_cell)
			status_text = "Placed " + id if result["ok"] else "Cannot place: " + result["reason"]
			if result["ok"]:
				selected_kind = ""
		else:
			var hit := model.building_at(cell)
			if hit != "":
				moving_id = hit
				orientation = model.get_building(hit)["orientation"]
				status_text = "Moving " + hit + "; click destination, Q to rotate."
				set_target(hit)
		queue_redraw()

func _diamond(center: Vector2, color: Color, border: Color = Color(0.17, 0.31, 0.32)) -> void:
	var corners := PackedVector2Array([
		center + Vector2(0, -TILE_HALF_H), center + Vector2(TILE_HALF_W, 0),
		center + Vector2(0, TILE_HALF_H), center + Vector2(-TILE_HALF_W, 0),
	])
	draw_colored_polygon(corners, color)
	for i in range(4):
		draw_line(corners[i], corners[(i + 1) % 4], border, 1.1)

func _label(text: String, pos: Vector2, size: int = 17, color: Color = Color.WHITE) -> void:
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.06, 0.11, 0.14))
	draw_rect(Rect2(0, 0, 1280, 75), Color(0.10, 0.19, 0.22))
	_label("TONG MON — HOME MAP TRANSFER LAB", Vector2(26, 30), 25)
	_label("Source-A footprint/doorway metadata · independent Godot pathfinding · visual state only", Vector2(28, 56), 14, Color(0.73, 0.85, 0.80))
	for x in range(MapModel.WIDTH):
		for y in range(MapModel.HEIGHT):
			var c := Vector2i(x, y)
			var road_color := Color(0.34, 0.37, 0.28) if c in model.roads else Color(0.13, 0.23, 0.21)
			_diamond(screen_for(c), road_color)
	for b in model.buildings:
		var def: Dictionary = MapModel.DEFINITIONS[b["kind"]]
		var color: Color = def["color"]
		for c in model.cells_for(b["kind"], b["origin"], b["orientation"]):
			_diamond(screen_for(c), color, Color(0.86, 0.82, 0.65))
		var door := model.doorway(b["kind"], b["origin"], b["orientation"])
		draw_circle(screen_for(door), 6.0, Color(0.97, 0.87, 0.42))
		var size := model.rotated_size(b["kind"], b["orientation"])
		var label_cell: Vector2i = b["origin"] + Vector2i(size.x / 2, size.y / 2)
		if b["id"] == "main_hall":
			var image_center := screen_for(label_cell)
			draw_texture_rect(MAIN_HALL_PREVIEW, Rect2(image_center + Vector2(-150, -138), Vector2(300, 201)), false)
			_label("Source art preview · static atlas", image_center + Vector2(-88, 76), 12, Color(1.0, 0.95, 0.72))
		else:
			_label(def["name"], screen_for(label_cell) + Vector2(-34, 5), 12, Color(0.06, 0.09, 0.10))
	if route.size() > 1:
		for i in range(route.size() - 1):
			draw_line(screen_for(route[i]), screen_for(route[i + 1]), Color(0.99, 0.78, 0.34, 0.8), 3.0)
	var preview_kind := selected_kind
	if moving_id != "":
		preview_kind = model.get_building(moving_id)["kind"]
	if preview_kind != "" and model.inside(preview_cell):
		var check := model.validate(preview_kind, preview_cell, orientation, moving_id, actor_cell)
		var tint := Color(0.2, 0.9, 0.5, 0.56) if check["ok"] else Color(1.0, 0.25, 0.25, 0.6)
		for c in model.cells_for(preview_kind, preview_cell, orientation):
			if model.inside(c):
				_diamond(screen_for(c), tint, Color.WHITE)
		var door := model.doorway(preview_kind, preview_cell, orientation)
		if model.inside(door):
			draw_circle(screen_for(door), 7.0, Color(1.0, 0.9, 0.2))
		_label(check["reason"], Vector2(975, 110), 16, tint)
	draw_circle(actor_screen + Vector2(0, -9), 13.0, Color(0.94, 0.89, 0.68))
	draw_circle(actor_screen + Vector2(0, -13), 6.0, Color(0.26, 0.32, 0.43))
	_label("Disciple " + visual_state, actor_screen + Vector2(-45, -29), 13, Color(0.98, 0.96, 0.78))
	draw_rect(Rect2(0, 565, 1280, 155), Color(0.10, 0.18, 0.20))
	_label(status_text, Vector2(26, 595), 17, Color(0.92, 0.95, 0.89))
	for i in range(DISPLAY_KINDS.size()):
		var kind: String = DISPLAY_KINDS[i]
		var rect := Rect2(20.0 + BUTTON_W * i, 625, BUTTON_W - 7, 55)
		draw_rect(rect, MapModel.DEFINITIONS[kind]["color"])
		_label(MapModel.DEFINITIONS[kind]["name"], rect.position + Vector2(10, 31), 16, Color(0.05, 0.08, 0.09))
	_label("Q: rotate     R: paint road     Click building then tile: move     Gold line: A* path", Vector2(29, 704), 14, Color(0.75, 0.83, 0.79))

func _run_smoke() -> void:
	var overlap := model.validate("mine", Vector2i(3, 3), 0)
	var door_out := model.validate("mine", Vector2i(12, 0), 0, "mine")
	var rotated := model.validate("warehouse", Vector2i(13, 7), 1, "warehouse")
	var before := model.path_to("mine", actor_cell)
	var moved := model.move("mine", Vector2i(13, 4), 0, actor_cell)
	var after := model.path_to("mine", actor_cell)
	set_target("mine")
	var safe := not after.is_empty()
	for c in after:
		if model.occupied(c):
			safe = false
	var ok: bool = not overlap["ok"] and not door_out["ok"] and rotated["ok"] and moved["ok"] and safe and before != after
	print("TRANSFER_MAP_ASSERT overlap_rejected=", not overlap["ok"], " door_rejected=", not door_out["ok"],
		" rotation_valid=", rotated["ok"], " move_valid=", moved["ok"], " replan_changed=", before != after,
		" path_avoids_buildings=", safe, " revision=", model.revision)
	await get_tree().create_timer(1.2).timeout
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png("E:/TongMonIntegrationLab/TransferKit/Previews/map_prototype.png")
	print("TRANSFER_MAP_SCREENSHOT ", img.get_width(), "x", img.get_height(), " err=", err)
	var saw_walk := visual_state == "WALK"
	var saw_work := false
	var saw_idle := false
	for i in range(100):
		_process(0.31)
		if visual_state == "WORK":
			saw_work = true
		if saw_work and visual_state == "IDLE":
			saw_idle = true
			break
	print("TRANSFER_ACTOR_ASSERT walk=", saw_walk, " work=", saw_work, " idle=", saw_idle,
		" arrived_at_door=", actor_cell == model.doorway("mine", model.get_building("mine")["origin"], 0))
	get_tree().quit(0 if ok and err == OK and saw_walk and saw_work and saw_idle else 3)