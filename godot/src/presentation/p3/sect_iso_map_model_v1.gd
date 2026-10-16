class_name SectIsoMapModelV1
extends RefCounted

# Bit-for-bit lab algorithm except class rename; presentation-only instance.
# The production main map does not expose place/move/toggle_road to UI.
# One SimulationState remains the only gameplay/save authority.

const WIDTH := 20
const HEIGHT := 13
const SPAWN := Vector2i(0, 0)
const AUTO_START := Vector2i(-999999, -999999)
const DEFINITIONS := {
	"main_hall": {"name": "Main Hall", "size": Vector2i(7, 5), "door": Vector2i(3, -1), "color": Color(0.66, 0.48, 0.27)},
	"mine": {"name": "Mine", "size": Vector2i(3, 3), "door": Vector2i(1, -1), "color": Color(0.47, 0.55, 0.63)},
	"spirit_field": {"name": "Spirit Field", "size": Vector2i(2, 2), "door": Vector2i(0, -1), "color": Color(0.38, 0.68, 0.38)},
	"warehouse": {"name": "Warehouse", "size": Vector2i(3, 2), "door": Vector2i(1, -1), "color": Color(0.68, 0.55, 0.37)},
	"forge": {"name": "Forge", "size": Vector2i(3, 3), "door": Vector2i(1, -1), "color": Color(0.68, 0.41, 0.30)},
	"forest": {"name": "Linh Forest", "size": Vector2i(2, 2), "door": Vector2i(0, -1), "color": Color(0.27, 0.52, 0.39)},
}

var buildings: Array[Dictionary] = []
var roads: Array[Vector2i] = []
var revision := 0
# Default construction stays exactly 20x13 for the historic PV-01/ENV-01 scenes.
# ENV-02A configures these dimensions only on its own separate model instance.
var grid_size: Vector2i = Vector2i(WIDTH, HEIGHT)
var spawn_cell: Vector2i = SPAWN

func _init(p_grid_size: Vector2i = Vector2i(WIDTH, HEIGHT), p_spawn: Vector2i = SPAWN) -> void:
    assert(p_grid_size.x > 0 and p_grid_size.y > 0)
    grid_size = p_grid_size
    spawn_cell = p_spawn
    assert(inside(spawn_cell))


func inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y

func rotated_size(kind: String, orientation: int) -> Vector2i:
	var base: Vector2i = DEFINITIONS[kind]["size"]
	return Vector2i(base.y, base.x) if orientation % 2 == 1 else base

func doorway(kind: String, origin: Vector2i, orientation: int) -> Vector2i:
	var d: Vector2i = DEFINITIONS[kind]["door"]
	var s: Vector2i = DEFINITIONS[kind]["size"]
	match posmod(orientation, 4):
		1: d = Vector2i(s.y - 1 - d.y, d.x)
		2: d = Vector2i(s.x - 1 - d.x, s.y - 1 - d.y)
		3: d = Vector2i(d.y, s.x - 1 - d.x)
	return origin + d

func cells_for(kind: String, origin: Vector2i, orientation: int) -> Array[Vector2i]:
	var size := rotated_size(kind, orientation)
	var result: Array[Vector2i] = []
	for x in range(size.x):
		for y in range(size.y):
			result.append(origin + Vector2i(x, y))
	return result

func occupied(cell: Vector2i, ignore_id: String = "") -> bool:
	for b in buildings:
		if b["id"] == ignore_id:
			continue
		if cell in cells_for(b["kind"], b["origin"], b["orientation"]):
			return true
	return false

func building_at(cell: Vector2i) -> String:
	for b in buildings:
		if cell in cells_for(b["kind"], b["origin"], b["orientation"]):
			return b["id"]
	return ""

func _navigation(extra_kind: String = "", extra_origin: Vector2i = Vector2i(-1, -1), extra_orientation: int = 0, ignore_id: String = "") -> AStarGrid2D:
	var nav := AStarGrid2D.new()
	nav.region = Rect2i(Vector2i.ZERO, grid_size)
	nav.cell_size = Vector2.ONE
	nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	nav.update()
	for b in buildings:
		if b["id"] == ignore_id:
			continue
		for c in cells_for(b["kind"], b["origin"], b["orientation"]):
			if inside(c):
				nav.set_point_solid(c, true)
	if extra_kind != "":
		for c in cells_for(extra_kind, extra_origin, extra_orientation):
			if inside(c):
				nav.set_point_solid(c, true)
	for road in roads:
		if inside(road) and not nav.is_point_solid(road):
			nav.set_point_weight_scale(road, 0.7)
	return nav

func validate(kind: String, origin: Vector2i, orientation: int, ignore_id: String = "", start: Vector2i = AUTO_START) -> Dictionary:
	if start == AUTO_START:
		start = spawn_cell
	if not DEFINITIONS.has(kind):
		return {"ok": false, "reason": "unknown building"}
	for c in cells_for(kind, origin, orientation):
		if not inside(c):
			return {"ok": false, "reason": "outside map"}
		if occupied(c, ignore_id):
			return {"ok": false, "reason": "footprint overlaps"}
		if c == start:
			return {"ok": false, "reason": "actor cell blocked"}
	var door := doorway(kind, origin, orientation)
	if not inside(door):
		return {"ok": false, "reason": "door outside map"}
	if occupied(door, ignore_id) or door in cells_for(kind, origin, orientation):
		return {"ok": false, "reason": "door blocked"}
	var nav := _navigation(kind, origin, orientation, ignore_id)
	if not inside(start) or nav.is_point_solid(start):
		return {"ok": false, "reason": "start blocked"}
	var path := nav.get_id_path(start, door)
	if path.is_empty():
		return {"ok": false, "reason": "door unreachable"}
	return {"ok": true, "reason": "valid", "door": door, "path_length": path.size()}

func place(id: String, kind: String, origin: Vector2i, orientation: int = 0, start: Vector2i = AUTO_START) -> Dictionary:
	if get_building(id).size() > 0:
		return {"ok": false, "reason": "duplicate id"}
	var result := validate(kind, origin, orientation, "", start)
	if result["ok"]:
		buildings.append({"id": id, "kind": kind, "origin": origin, "orientation": orientation})
		revision += 1
	return result

func move(id: String, origin: Vector2i, orientation: int, start: Vector2i = AUTO_START) -> Dictionary:
	var old := get_building(id)
	if old.is_empty():
		return {"ok": false, "reason": "unknown id"}
	var result := validate(old["kind"], origin, orientation, id, start)
	if result["ok"]:
		for b in buildings:
			if b["id"] == id:
				b["origin"] = origin
				b["orientation"] = orientation
				revision += 1
				break
	return result

func get_building(id: String) -> Dictionary:
	for b in buildings:
		if b["id"] == id:
			return b
	return {}

func path_to(id: String, start: Vector2i) -> Array[Vector2i]:
	var b := get_building(id)
	if b.is_empty() or not inside(start):
		return []
	var door := doorway(b["kind"], b["origin"], b["orientation"])
	var nav := _navigation()
	if nav.is_point_solid(start) or nav.is_point_solid(door):
		return []
	return nav.get_id_path(start, door)

func toggle_road(cell: Vector2i) -> bool:
	if not inside(cell) or occupied(cell):
		return false
	if cell in roads:
		roads.erase(cell)
	else:
		roads.append(cell)
	revision += 1
	return true