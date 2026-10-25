class_name PveLiveWorldMapV1
extends Control

# Live, read-only presentation of the authoritative C01 Combat V2 snapshot.
# The 20-site topology comes from PveMultiCampPopulationV1; unused sites are
# locations only, never implied active monsters. Ground is lightweight terrain
# geometry while the bamboo props are the project's verified Source A PNGs.
const WORLD_SIZE := Vector2(256.0,192.0)
const RIVER_X := 148.0
const TREE_A: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570036.png")
const TREE_B: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570041.png")
const TREE_C: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570073.png")
const TREE_POINTS := [
	Vector2(14,23),Vector2(46,14),Vector2(95,10),Vector2(143,12),
	Vector2(244,29),Vector2(14,47),Vector2(53,84),Vector2(103,52),
	Vector2(202,43),Vector2(244,82),Vector2(11,139),Vector2(48,174),
	Vector2(112,171),Vector2(173,166),Vector2(244,163)
]
const FOREST := Color("29473a")
const FOREST_LIGHT := Color("526d4b")
const TEXT := Color("f2edd9")
const GOLD := Color("e8bf68")
const FRIEND := Color("77dfd0")
const ENEMY := Color("f07d69")

var battle: MapBattleV2
var population: Dictionary = {}
var active_camp_index := 0
var selected_camp_index := 0
var camera_center := WORLD_SIZE*0.5
var camera_zoom := 1.0
var _dragging := false
var _drag_distance := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	queue_redraw()

func show_authority_snapshot(snapshot: MapBattleV2, camp_population: Dictionary = {}) -> void:
	# Snapshot is only read by this renderer. Combat V2 remains the only writer.
	battle = snapshot
	population = camp_population.duplicate(false)
	active_camp_index = 0
	if battle != null:
		for actor in battle.actors.values():
			if str(actor.get("side","")) != "monster":
				continue
			var slot := str(actor.get("spawn_slot_id",""))
			if slot.begins_with("C") and slot.length() >= 3:
				active_camp_index = clampi(slot.substr(1,2).to_int()-1,0,19)
				break
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func map_rect() -> Rect2:
	return Rect2(Vector2(14,30),Vector2(maxf(1.0,size.x-28.0),maxf(1.0,size.y-52.0)))

func minimap_rect() -> Rect2:
	return Rect2(Vector2(maxf(8.0,size.x-194.0),8.0),Vector2(182.0,132.0))

func minimap_inner_rect() -> Rect2:
	var rect := minimap_rect()
	return Rect2(rect.position+Vector2(7.0,20.0),rect.size-Vector2(14.0,27.0))

func world_scale() -> float:
	var rect := map_rect()
	return minf(rect.size.x/WORLD_SIZE.x,rect.size.y/WORLD_SIZE.y)*camera_zoom

func world_to_screen(world: Vector2) -> Vector2:
	return map_rect().get_center()+(world-camera_center)*world_scale()

func screen_to_world(screen: Vector2) -> Vector2:
	return camera_center+(screen-map_rect().get_center())/maxf(world_scale(),0.001)

func _minimap_world_to_screen(world: Vector2) -> Vector2:
	var inner := minimap_inner_rect()
	return inner.position+Vector2(world.x/WORLD_SIZE.x*inner.size.x,world.y/WORLD_SIZE.y*inner.size.y)

func _minimap_screen_to_world(screen: Vector2) -> Vector2:
	var inner := minimap_inner_rect()
	var uv := (screen-inner.position)/inner.size
	return Vector2(clampf(uv.x,0.0,1.0)*WORLD_SIZE.x,clampf(uv.y,0.0,1.0)*WORLD_SIZE.y)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed:
			_zoom_at(mouse.position,1.15)
			accept_event()
		elif mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
			_zoom_at(mouse.position,1.0/1.15)
			accept_event()
		elif mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				if minimap_rect().has_point(mouse.position):
					camera_center = _minimap_screen_to_world(mouse.position)
					_clamp_camera()
					queue_redraw()
					accept_event()
				else:
					_dragging = true
					_drag_distance = 0.0
			else:
				if _dragging and _drag_distance < 8.0 and map_rect().has_point(mouse.position):
					selected_camp_index = _nearest_camp(mouse.position)
				_dragging = false
				queue_redraw()
				accept_event()
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		camera_center -= motion.relative/maxf(world_scale(),0.001)
		_drag_distance += motion.relative.length()
		_clamp_camera()
		queue_redraw()
		accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if not minimap_rect().has_point(drag.position):
			camera_center -= drag.relative/maxf(world_scale(),0.001)
			_clamp_camera()
			queue_redraw()
			accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and minimap_rect().has_point(touch.position):
			camera_center = _minimap_screen_to_world(touch.position)
			_clamp_camera()
			queue_redraw()
			accept_event()

func _zoom_at(screen: Vector2, factor: float) -> void:
	var anchor := screen_to_world(screen)
	camera_zoom = clampf(camera_zoom*factor,0.75,3.2)
	camera_center = anchor-(screen-map_rect().get_center())/maxf(world_scale(),0.001)
	_clamp_camera()
	queue_redraw()

func _clamp_camera() -> void:
	var visible := map_rect().size/maxf(world_scale(),0.001)
	if visible.x >= WORLD_SIZE.x:
		camera_center.x = WORLD_SIZE.x*0.5
	else:
		camera_center.x = clampf(camera_center.x,visible.x*0.5,WORLD_SIZE.x-visible.x*0.5)
	if visible.y >= WORLD_SIZE.y:
		camera_center.y = WORLD_SIZE.y*0.5
	else:
		camera_center.y = clampf(camera_center.y,visible.y*0.5,WORLD_SIZE.y-visible.y*0.5)

func _nearest_camp(screen: Vector2) -> int:
	var result := 0
	var distance := INF
	for index in range(PveMultiCampPopulationV1.CAMP_COUNT):
		var at := world_to_screen(PveMultiCampPopulationV1.camp_position(index))
		var candidate := at.distance_squared_to(screen)
		if candidate < distance:
			distance = candidate
			result = index
	return result

func _draw() -> void:
	var rect := map_rect()
	draw_rect(Rect2(Vector2.ZERO,size),Color("172e29"))
	draw_rect(rect,FOREST)
	_draw_terrain()
	_draw_river()
	_draw_routes()
	_draw_source_a_bamboo()
	_draw_camps(false)
	_draw_live_actors(false)
	draw_rect(Rect2(Vector2(12,8),Vector2(350,18)),Color(0.08,0.18,0.15,0.92))
	_text(Vector2(18,22),"THANH TRÚC LÂM  ·  20 VỊ TRÍ BÃI  ·  C01 LIVE COMBAT V2",12,GOLD)
	draw_rect(Rect2(Vector2(14,size.y-19),Vector2(400,16)),Color(0.08,0.18,0.15,0.9))
	_text(Vector2(20,size.y-7),"Kéo: camera  ·  Cuộn: zoom  ·  Minimap: định vị  ·  C02–C20: vị trí chưa mở",10,TEXT)
	_draw_minimap()

func _draw_terrain() -> void:
	# Low-cost forest floor relief and clearings; no extra simulation or collision.
	for row in range(7):
		for col in range(9):
			var world := Vector2(16.0+float(col)*29.0,12.0+float(row)*28.0)
			var center := world_to_screen(world)
			if not map_rect().grow(40.0).has_point(center):
				continue
			var radius := 18.0*camera_zoom
			var shade := Color(0.39,0.50,0.34,0.14) if (row+col)%2 == 0 else Color(0.14,0.27,0.22,0.17)
			draw_colored_polygon(PackedVector2Array([
				center+Vector2(-radius,0),center+Vector2(0,-radius*0.53),
				center+Vector2(radius,0),center+Vector2(0,radius*0.53)
			]),shade)
	for ridge in [
		PackedVector2Array([Vector2(4,48),Vector2(27,43),Vector2(49,51),Vector2(69,46)]),
		PackedVector2Array([Vector2(176,118),Vector2(198,112),Vector2(219,119),Vector2(252,111)]),
		PackedVector2Array([Vector2(74,184),Vector2(91,178),Vector2(112,185),Vector2(129,180)])
	]:
		var points := PackedVector2Array()
		for point in ridge:
			points.append(world_to_screen(point))
		draw_polyline(points,Color(0.57,0.64,0.43,0.36),4.0*camera_zoom,true)

func _draw_river() -> void:
	var points := PackedVector2Array()
	for y in range(0,193,8):
		points.append(world_to_screen(Vector2(RIVER_X+sin(float(y)*0.047)*3.8,float(y))))
	draw_polyline(points,Color(0.13,0.35,0.39,0.88),maxf(5.0,8.0*camera_zoom),true)
	draw_polyline(points,Color(0.42,0.66,0.62,0.50),maxf(1.0,1.5*camera_zoom),true)
	for row in PveMultiCampPopulationV1.BRIDGE_ROWS:
		var at := world_to_screen(Vector2(RIVER_X,float(PveMultiCampPopulationV1.ROWS[row])))
		draw_line(at+Vector2(-9,0),at+Vector2(9,0),Color("735a3a"),maxf(3.0,5.0*camera_zoom),true)
		draw_line(at+Vector2(-8,-1),at+Vector2(8,-1),Color("c5a76c"),maxf(1.0,2.0*camera_zoom),true)

func _draw_routes() -> void:
	for edge in PveMultiCampPopulationV1.road_edges():
		var a := world_to_screen(PveMultiCampPopulationV1.camp_position(edge.x))
		var b := world_to_screen(PveMultiCampPopulationV1.camp_position(edge.y))
		draw_line(a,b,Color(0.20,0.25,0.19,0.82),maxf(5.0,9.0*camera_zoom),true)
		draw_line(a,b,Color(0.71,0.62,0.43,0.73),maxf(2.0,3.0*camera_zoom),true)

func _draw_source_a_bamboo() -> void:
	var textures: Array[Texture2D] = [TREE_A,TREE_B,TREE_C]
	for i in range(TREE_POINTS.size()):
		var at := world_to_screen(TREE_POINTS[i])
		if not map_rect().grow(60.0).has_point(at):
			continue
		var texture := textures[i%textures.size()]
		var height := 47.0*camera_zoom
		var width := height*float(texture.get_width())/maxf(float(texture.get_height()),1.0)
		draw_texture_rect(texture,Rect2(at-Vector2(width*0.5,height*0.88),Vector2(width,height)),false,Color(0.96,1.0,0.91,0.88))

func _draw_camps(minimap: bool) -> void:
	for index in range(PveMultiCampPopulationV1.CAMP_COUNT):
		var world := PveMultiCampPopulationV1.camp_position(index)
		var at := _minimap_world_to_screen(world) if minimap else world_to_screen(world)
		var is_active := index == active_camp_index and battle != null and battle.active
		var is_selected := index == selected_camp_index
		if minimap:
			draw_circle(at,3.1,GOLD if is_active else Color(0.72,0.79,0.62,0.85))
		else:
			if not map_rect().grow(24.0).has_point(at):
				continue
			draw_circle(at,11.0*clampf(camera_zoom,0.8,1.5),Color(0.12,0.22,0.18,0.95))
			draw_arc(at,9.5*clampf(camera_zoom,0.8,1.5),0.0,TAU,24,GOLD if is_active or is_selected else Color(0.74,0.81,0.62,0.88),2.0,true)
			_text(at+Vector2(-12,4),PveMultiCampPopulationV1.camp_id(index),10,GOLD if is_active else TEXT)
			if is_active:
				_text(at+Vector2(-12,-12),"LIVE",8,Color("a5f0d4"))

func _battle_world_position(actor: Dictionary) -> Vector2:
	# Combat arena coordinates are mapped into a small C01 clearing. Movement is
	# taken from the real battle actor every refresh; no second movement sim.
	var arena: Rect2 = MapBattleV2.ARENA
	var local: Vector2 = actor.get("position",arena.get_center())
	var normalized := (local-arena.position)/arena.size
	var offset := Vector2((normalized.x-0.5)*12.0,(normalized.y-0.5)*8.0)
	return PveMultiCampPopulationV1.camp_position(active_camp_index)+offset

func _draw_live_actors(minimap: bool) -> void:
	if battle == null:
		return
	var actor_ids: Array = battle.actors.keys()
	actor_ids.sort()
	for actor_id in actor_ids:
		var actor: Dictionary = battle.actors[actor_id]
		var world := _battle_world_position(actor)
		var at := _minimap_world_to_screen(world) if minimap else world_to_screen(world)
		var side := str(actor.get("side",""))
		var live := float(actor.get("hp",0.0)) > 0.0
		var tint := FRIEND if side == "disciple" else ENEMY
		if not live:
			tint = Color(0.58,0.57,0.50,0.74)
		if minimap:
			draw_circle(at,2.0,tint)
			continue
		if not map_rect().grow(12.0).has_point(at):
			continue
		draw_circle(at,5.8*clampf(camera_zoom,0.85,1.5),Color(0.04,0.09,0.08,0.94))
		draw_circle(at,4.2*clampf(camera_zoom,0.85,1.5),tint)
		var ratio := clampf(float(actor.get("hp",0.0))/maxf(1.0,float(actor.get("max_hp",1.0))),0.0,1.0)
		draw_rect(Rect2(at+Vector2(-8,7),Vector2(16,2)),Color(0.12,0.12,0.10,0.9))
		if ratio > 0.0:
			draw_rect(Rect2(at+Vector2(-8,7),Vector2(16*ratio,2)),Color("83d68a") if side == "disciple" else Color("e58471"))

func _draw_minimap() -> void:
	var frame := minimap_rect()
	draw_rect(frame,Color(0.05,0.11,0.10,0.97))
	draw_rect(Rect2(frame.position+Vector2(1,1),frame.size-Vector2(2,2)),Color(0.16,0.31,0.24,0.98))
	_text(frame.position+Vector2(7,14),"MINIMAP · 20 BÃI",9,GOLD)
	var edges := PveMultiCampPopulationV1.road_edges()
	for edge in edges:
		draw_line(_minimap_world_to_screen(PveMultiCampPopulationV1.camp_position(edge.x)),
			_minimap_world_to_screen(PveMultiCampPopulationV1.camp_position(edge.y)),Color(0.73,0.66,0.48,0.58),1.0,true)
	_draw_camps(true)
	_draw_live_actors(true)
	var inner := minimap_inner_rect()
	var visible := map_rect().size/maxf(world_scale(),0.001)
	var rect_size := Vector2(
		minf(inner.size.x,visible.x/WORLD_SIZE.x*inner.size.x),
		minf(inner.size.y,visible.y/WORLD_SIZE.y*inner.size.y)
	)
	var center := _minimap_world_to_screen(camera_center)
	draw_rect(Rect2(center-rect_size*0.5,rect_size),Color(1.0,0.86,0.53,0.08),true)
	draw_rect(Rect2(center-rect_size*0.5,rect_size),Color(1.0,0.86,0.53,0.95),false,1.4)
	_text(frame.position+Vector2(7,frame.size.y-5),"Xanh: đội  ·  Đỏ: quái  ·  Vàng: camera",8,TEXT)

func _text(pos: Vector2, value: String, font_size: int, tint: Color) -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return
	draw_string_outline(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,2,Color(0.04,0.08,0.07,0.92))
	draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,tint)
