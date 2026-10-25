extends SceneTree

# MAP-D1B layout, route, selection and no-gameplay-mutation contract.
const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const SAVE_PATH := "user://sect_map_d1b_layout_contract_test.json"
const EXPECTED_ROUTES := [
	"gate_to_courtyard",
	"courtyard_to_main_hall",
	"courtyard_to_warehouse",
	"courtyard_to_forge",
	"courtyard_to_mine",
	"courtyard_to_linh_forest",
	"courtyard_to_spirit_field",
	"courtyard_to_residence",
	"courtyard_to_cultivation"
]

var scene: Control
var iso: SectIsometricWorldV1

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for suffix in ["",".tmp",".bak"]:
		if FileAccess.file_exists(SAVE_PATH+suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_fail("production P3.2 scene is unavailable")
		return
	scene = packed.instantiate() as Control
	root.add_child(scene)
	await process_frame
	var state := scene.get("state") as SimulationState
	iso = scene.find_child("SectIsoWorld192",true,false) as SectIsometricWorldV1
	if state == null or not bool(scene.get("runtime_ready")) or iso == null:
		_fail("layout test did not mount P3.2's canonical runtime and map")
		return
	var initial_state := state.to_dict().duplicate(true)
	if iso.GRID != Vector2i(192,192) or iso.CHUNK != 16 or iso.STARTER != Rect2i(72,72,48,48):
		_fail("fixed 192/16/48 map bounds changed")
		return
	if iso.HALF_W != 25.0 or iso.HALF_H != 13.0 or iso.VIEW_SIZE != Vector2(1280,570) or iso.MAP_SCREEN_OFFSET != Vector2(0,72):
		_fail("fixed isometric projection or 1280x570 viewport changed")
		return
	if iso.TYPE_ANCHORS.size() != 13:
		_fail("destination key count changed: %d" % iso.TYPE_ANCHORS.size())
		return
	var unique_cells: Dictionary = {}
	for raw_key in iso.TYPE_ANCHORS.keys():
		var key := str(raw_key)
		var cell: Vector2i = iso.TYPE_ANCHORS[key]
		if not iso.STARTER.has_point(cell):
			_fail("%s anchor outside starter at %s" % [key,str(cell)])
			return
		if unique_cells.has(cell):
			_fail("destination anchors overlap: %s and %s at %s" % [str(unique_cells[cell]),key,str(cell)])
			return
		unique_cells[cell] = key
	if iso.SPAWN_CELL != iso.TYPE_ANCHORS["gate"]:
		_fail("presentation route seed no longer begins at the reserved Gate marker")
		return
	if not iso.lab_routes_ready or iso.preview_routes.size() != EXPECTED_ROUTES.size():
		_fail("AStar route seed incomplete: ready=%s routes=%d expected=%d" % [str(iso.lab_routes_ready),iso.preview_routes.size(),EXPECTED_ROUTES.size()])
		return
	for route_id: String in EXPECTED_ROUTES:
		if not iso.preview_routes.has(route_id):
			_fail("missing route %s" % route_id)
			return
		var route: Array = iso.preview_routes[route_id]
		if route.size() < 2:
			_fail("route %s has no traversable segment" % route_id)
			return
		for index in range(route.size()):
			var cell: Vector2i = route[index]
			if not iso.STARTER.has_point(cell) or iso.lab_geometry.occupied(cell) or not iso.preview_roads.has(cell):
				_fail("route %s invalid at occupied/out-of-area cell %s" % [route_id,str(cell)])
				return
			if index > 0:
				var previous: Vector2i = route[index-1]
				if absi(cell.x-previous.x)+absi(cell.y-previous.y) != 1:
					_fail("route %s has a non-cardinal jump %s -> %s" % [route_id,str(previous),str(cell)])
					return
	var hall_door: Vector2i = iso.lab_geometry.doorway("main_hall",iso.lab_geometry.get_building("main_hall")["origin"],0)
	if iso.preview_routes["gate_to_courtyard"][0] != iso.SPAWN_CELL or iso.preview_routes["courtyard_to_main_hall"][-1] != hall_door:
		_fail("gate/courtyard/Hall route endpoints are disconnected from their layout anchors")
		return
	for producer: String in ["mine","linh_forest","spirit_field"]:
		var route_id: String = "courtyard_to_"+producer
		var offset: Vector2i = iso.PRODUCER_ROUTE_APPROACH[producer]
		var expected_end: Vector2i = iso.TYPE_ANCHORS[producer]+offset
		if iso.preview_routes[route_id][-1] != expected_end or not iso.STARTER.has_point(expected_end):
			_fail("%s route does not reach its accessible approach cell %s" % [producer,str(expected_end)])
			return
	# Actual static footprints are the only blockers in the map model. Verify
	# they remain pairwise disjoint and all three real Source A images persist.
	var occupied: Dictionary = {}
	for kind in ["main_hall","warehouse","forge"]:
		var building := iso.lab_geometry.get_building(kind)
		if building.is_empty():
			_fail("verified landmark %s has no layout footprint" % kind)
			return
		for tile in iso.lab_geometry.cells_for(kind,building["origin"],building["orientation"]):
			if occupied.has(tile):
				_fail("PV01 footprint overlap at %s: %s / %s" % [str(tile),str(occupied[tile]),kind])
				return
			occupied[tile] = kind
	for art_key in [iso.HOUSE_TEXTURES["main_hall"],iso.HOUSE_TEXTURES["warehouse"],iso.HOUSE_TEXTURES["forge"]]:
		if not iso.render_art.has(str(art_key)):
			_fail("verified building texture did not load: %s" % str(art_key))
			return
	if not bool(iso.art_source_status.get("manifest_valid",false)) or int(iso.art_source_status.get("missing_count",0)) != 0 or int(iso.art_source_status.get("rejected_count",0)) != 0:
		_fail("layout-used MAP25 textures failed their SHA gate: %s" % str(iso.art_source_status))
		return
	# The full four-texture palette and all six road variants must be represented
	# by actual tiles in the B layout, not merely by filenames in a registry.
	var terrain_used: Dictionary = {}
	for y in range(iso.STARTER.position.y,iso.STARTER.end.y):
		for x in range(iso.STARTER.position.x,iso.STARTER.end.x):
			var key := iso._terrain_texture_key(Vector2i(x,y))
			if not key.is_empty():
				terrain_used[key] = int(terrain_used.get(key,0))+1
	for key in ["stone_courtyard.png","stone_border.png","stone_runes.png","stone_variant.png"]:
		if not terrain_used.has("env01_assets/terrain/"+key):
			_fail("verified terrain texture has no layout role: %s" % key)
			return
	var road_used: Dictionary = {}
	for raw_cell in iso.preview_roads.keys():
		var cell: Vector2i = raw_cell
		var road_kind := iso._road_key(cell)
		road_used[road_kind] = int(road_used.get(road_kind,0))+1
		var texture_path := "env01_assets/roads/"+str(iso.ROAD_TEXTURES[road_kind])
		if not iso.render_art.has(texture_path):
			_fail("road tile %s has no verified texture %s" % [str(cell),texture_path])
			return
	for kind in iso.ROAD_TEXTURES.keys():
		if not road_used.has(kind):
			_fail("route topology does not use road texture kind %s; topology=%s" % [str(kind),str(road_used)])
			return
	# Destination screen order follows Gate -> courtyard -> Hall in one camera.
	var gate := _screen_for_world(Vector2(iso.project(Vector2(iso.TYPE_ANCHORS["gate"]))))
	var court := _screen_for_world(Vector2(iso.project(Vector2(iso.ROADS_JUNCTION))))
	var hall_row := _row_for_destination("main_hall")
	if hall_row.is_empty():
		_fail("Main Hall Source A row missing")
		return
	var hall := _screen_for_world(hall_row["world"])
	if not (gate.y > court.y and court.y > hall.y and absf(gate.x-hall.x) <= 80.0):
		_fail("visual spine misaligned: gate=%s courtyard=%s hall=%s" % [str(gate),str(court),str(hall)])
		return
	if not SectMapCamera.is_map_screen_point(gate) or not SectMapCamera.is_map_screen_point(hall):
		_fail("gate or Hall focal anchor is outside the default map viewport")
		return
	# Real Mine/Forest/Field rows preserve unique canonical IDs and still open
	# the actual existing worksite management panel from their map hit targets.
	var live_ids: Dictionary = {}
	for raw_id in state.buildings.keys():
		var building: BuildingState = state.buildings[raw_id]
		if str(building.building_type) in ["mine","linh_forest","spirit_field"]:
			live_ids[str(building.id)] = str(building.building_type)
	var shown_ids: Dictionary = {}
	for row in iso.display_instances:
		if bool(row["managed"]):
			var id := str(row["building_id"])
			if not live_ids.has(id) or live_ids[id] != str(row["destination"]) or shown_ids.has(id):
				_fail("managed map marker lost a canonical producer id: %s" % id)
				return
			shown_ids[id] = str(row["destination"])
	if shown_ids != live_ids:
		_fail("producer marker IDs differ from SimulationState: shown=%s live=%s" % [str(shown_ids),str(live_ids)])
		return
	for producer in ["mine","linh_forest","spirit_field"]:
		var live: BuildingState = null
		var wanted_type: StringName = BuildingSystem.TYPE_MINE if producer == "mine" else (BuildingSystem.TYPE_LINH_FOREST if producer == "linh_forest" else BuildingSystem.TYPE_SPIRIT_FIELD)
		for raw_id in state.buildings.keys():
			var building: BuildingState = state.buildings[raw_id]
			if building.building_type == wanted_type:
				live = building
				break
		if live == null:
			_fail("required live producer is absent: %s" % producer)
			return
		var row := _row_for_building(live.id)
		var tap := _screen_for_world(row["world"]+Vector2(0,-36))
		if not SectMapCamera.is_map_screen_point(tap):
			# The legacy map layer itself is translated in screen space. Move it
			# by center-tap to bring the target back to the viewport center.
			var recenter := Vector2(640,357)-tap
			scene.call("_pan_camera",recenter)
			await process_frame
			tap = _screen_for_world(row["world"]+Vector2(0,-36))
		if not SectMapCamera.is_map_screen_point(tap):
			_fail("%s tap is outside map viewport at %s after pan; id=%s cell=%s zoom=%s camera=%s" % [producer,str(tap),str(live.id),str(row.get("cell",Vector2i.ZERO)),str(iso.camera.zoom),str(iso.camera.position)])
			return
		var hit := iso.pick_at_screen(tap)
		if StringName(hit.get("building_id","")) != live.id:
			_fail("%s pick lost its canonical id at %s: %s" % [producer,str(tap),str(hit)])
			return
		if not bool(scene.call("_try_iso_map_pick",tap)):
			_fail("%s tap did not open the existing P3.2 worksite panel" % producer)
			return
		await process_frame
		if StringName(scene.get("selected_production_instance_id")) != live.id:
			_fail("%s panel selected %s instead of %s" % [producer,str(scene.get("selected_production_instance_id")),str(live.id)])
			return
		scene.call("_close_building_operation_panel",true)
		await process_frame
	# Camera zoom, pan and pick are checked through P3.2's own controls; the
	# selected Hall anchor remains tappable inside the separate map SubViewport.
	for zoom in [0.75,1.0,1.35,1.80]:
		scene.call("_zoom_at",Vector2(640,357),zoom,false)
		await process_frame
		if not is_equal_approx(float(scene.get("map_zoom")),zoom) or not is_equal_approx(iso.camera.zoom.x,zoom):
			_fail("camera transform diverged at zoom %.2f" % zoom)
			return
		scene.call("_pan_camera",Vector2(30,-18))
		await process_frame
		scene.call("_pan_camera",Vector2(-30,18))
		await process_frame
		var hall_tap := _screen_for_world(hall_row["world"]+Vector2(0,-36))
		if not SectMapCamera.is_map_screen_point(hall_tap):
			scene.call("_pan_camera",Vector2(640,357)-hall_tap)
			await process_frame
			hall_tap = _screen_for_world(hall_row["world"]+Vector2(0,-36))
		if not SectMapCamera.is_map_screen_point(hall_tap) or StringName(iso.pick_at_screen(hall_tap).get("destination","")) != &"main_hall":
			_fail("Hall picking failed after zoom/pan %.2f at %s" % [zoom,str(hall_tap)])
			return
		if iso.active_chunks.is_empty() or iso.active_chunks.size() > 144:
			_fail("chunk culling invalid after zoom/pan %.2f" % zoom)
			return
	if state.to_dict() != initial_state:
		_fail("layout/render/pick/camera changed canonical SimulationState")
		return
	print("MAP-D1B LAYOUT CONTRACT PASS routes=%d roads=%s terrain=%s props=%d producers=%d" % [iso.preview_routes.size(),str(road_used),str(terrain_used),iso.decoration_items.size(),shown_ids.size()])
	quit(0)

func _row_for_destination(destination: String) -> Dictionary:
	for row in iso.display_instances:
		if str(row["destination"]) == destination:
			return row
	return {}

func _row_for_building(building_id: StringName) -> Dictionary:
	for row in iso.display_instances:
		if StringName(row["building_id"]) == building_id:
			return row
	return {}

func _screen_for_world(world: Vector2) -> Vector2:
	return iso.MAP_SCREEN_OFFSET+iso.VIEW_SIZE*0.5+(world-iso.camera.position)*iso.camera.zoom.x

func _fail(message: String) -> void:
	push_error("MAP-D1B LAYOUT CONTRACT FAIL: "+message)
	if scene != null:
		scene.queue_free()
	quit(1)
