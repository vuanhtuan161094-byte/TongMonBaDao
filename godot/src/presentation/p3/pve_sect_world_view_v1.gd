class_name PveSectWorldViewV1
extends Control

signal move_ordered(actor_ids: Array, destination: Vector2)
signal selection_changed(actor_ids: Array)

const MINIMAP_MARGIN := 10.0
const MIN_ZOOM := 0.28
const MAX_ZOOM := 0.92

class InputOverlay:
	extends Control
	var event_handler: Callable
	var draw_handler: Callable

	func _gui_input(event: InputEvent) -> void:
		if event_handler.is_valid():
			event_handler.call(event)
		accept_event()

	func _draw() -> void:
		if draw_handler.is_valid():
			draw_handler.call(self)

var topology: Dictionary = {}
# Presentation-only cache: the PvE Source A geometry is immutable for one map
# revision. This must never cache or mutate authoritative Combat V2 state.
var _prepared_world: SectIsometricWorldV1
var _cached_navigation_sha := ""
var topology_build_count := 0  # Diagnostic counter for focused QA.
var battle: MapBattleV2
var population: Dictionary = {}
var camp_index := 0
var selected_actor_ids: Array[String] = []
var source_error := ""
var world: SectIsometricWorldV1
var _container: SubViewportContainer
var _viewport: SubViewport
var _overlay: InputOverlay
var _disciples: Dictionary = {}
var _view_rows: Dictionary = {}
var _dragging := false
var _drag_position := Vector2.ZERO
var _drag_distance := 0.0

var camera_zoom: float:
	get: return world.camera.zoom.x if world != null and world.camera != null else 0.0
	set(value):
		if world != null and world.camera != null:
			world.camera.zoom = Vector2.ONE*clampf(value,MIN_ZOOM,MAX_ZOOM)
			world._update_chunks()
			_queue_overlay_redraw()

var camera_center: Vector2:
	get: return SectIsometricWorldV1.inverse(world.camera.position) if world != null and world.camera != null else Vector2.ZERO
	set(value):
		if world != null and world.camera != null:
			world.camera.position = SectIsometricWorldV1.project(value)
			world._update_chunks()
			_queue_overlay_redraw()

var source_a_atlas: CombatV5SourceAAtlas:
	get: return world.pve_source_atlas if world != null else null

var _render_positions: Dictionary:
	get: return world.pve_render_positions if world != null else {}

func _ready() -> void:
	clip_contents = true
	_container = SubViewportContainer.new()
	_container.name = "SectPveWorldViewportContainer"
	_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_container.stretch = true
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_container)
	_viewport = SubViewport.new()
	_viewport.name = "SectPveWorldSubViewport"
	_viewport.size = Vector2i(maxi(1,roundi(size.x)),maxi(1,roundi(size.y)))
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.gui_disable_input = true
	_container.add_child(_viewport)
	world = SectIsometricWorldV1.new()
	world.name = "SectIsometricWorldV1PveAdapter"
	world.configure_pve_landscape()
	_viewport.add_child(world)
	_overlay = InputOverlay.new()
	_overlay.name = "PveWorldInputAndMinimap"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.event_handler = Callable(self,"_handle_pointer_event")
	_overlay.draw_handler = Callable(self,"_draw_overlay")
	add_child(_overlay)
	_overlay.queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _viewport != null:
		_viewport.size = Vector2i(maxi(1,roundi(size.x)),maxi(1,roundi(size.y)))
		if _overlay != null:
			_overlay.queue_redraw()

func prepare_world() -> Dictionary:
	# Called by the 0.25s main-game hunt HUD, not just when entering a map.
	# Use the navigation prepared by SectIsometricWorldV1._ready() instead of
	# rebuilding its 192x192 collision/20-camp graph on every HUD refresh.
	if world == null or not is_instance_valid(world):
		source_error = "source_a_world_not_ready"
		return {"ok":false,"reason":source_error}
	var navigation: Dictionary = world.pve_navigation
	if navigation.is_empty():
		navigation = SectIsometricWorldV1.pve_navigation_grid()
	var current_sha := str(navigation.get("source_blob_sha",""))
	if current_sha.is_empty():
		source_error = "source_a_navigation_sha_missing"
		return {"ok":false,"reason":source_error}
	if _prepared_world == world and not topology.is_empty() \
			and bool(topology.get("ok",false)) \
			and str(topology.get("source_blob_sha","")) == current_sha \
			and _cached_navigation_sha == current_sha:
		# Fast path: preserve the exact topology Dictionary and minimap Texture.
		# The caller still reads a fresh, authoritative battle snapshot.
		return {"ok":true,"topology":topology,"source_map":str(topology.get("source_map",""))}
	var built := PveOpenWorldTopologyV1.build(navigation,
		Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5))
	if not bool(built.get("ok",false)):
		source_error = str(built.get("reason","source_a_world_topology_failed"))
		return {"ok":false,"reason":source_error}
	# A different source hash invalidates the old minimap (including a changed
	# collision map); first-time setup reuses the map's already-built texture.
	if world.pve_mini_texture == null or (
			not _cached_navigation_sha.is_empty() and _cached_navigation_sha != current_sha):
		world.pve_mini_texture = SectIsometricWorldV1._pve_minimap_texture(
			navigation,world.pve_path_cells)
	topology = built
	_prepared_world = world
	_cached_navigation_sha = current_sha
	topology_build_count += 1
	source_error = ""
	world.pve_topology = topology
	world.pve_navigation = navigation
	if not world.pve_camera_initialized:
		var camps: Array = topology.get("camp_positions",[])
		if not camps.is_empty():
			world.set_pve_camera(camps[0],0.55)
	_overlay.queue_redraw()
	return {"ok":true,"topology":topology,"source_map":str(topology.get("source_map",""))}


func get_open_world_options() -> Dictionary:
	var result := prepare_world()
	if not bool(result.get("ok",false)):
		return result
	var options: Dictionary = topology.duplicate(true)
	options["respawn_delay_sim_seconds"] = 30.0
	options["auto_hunt"] = true
	return options

func show_authority_snapshot(snapshot: MapBattleV2, world_population: Dictionary = {},
		current_camp_index: int = 0, disciples: Dictionary = {}, view_rows: Dictionary = {}) -> void:
	battle = snapshot
	population = world_population.duplicate(false)
	camp_index = clampi(current_camp_index,0,PveMultiCampPopulationV1.CAMP_COUNT-1)
	_disciples = disciples.duplicate(false)
	_view_rows = view_rows.duplicate(true)
	if battle == null:
		selected_actor_ids.clear()
		world.set_pve_snapshot(null,{},selected_actor_ids)
		_overlay.queue_redraw()
		return
	var current_disciples: Array[String] = []
	for raw_id in battle.actors:
		var actor: Dictionary = battle.actors[raw_id]
		if str(actor.get("side","")) == "disciple":
			current_disciples.append(str(raw_id))
	var kept: Array[String] = []
	for id in selected_actor_ids:
		if current_disciples.has(id):
			kept.append(id)
	if kept.is_empty():
		kept = current_disciples.duplicate()
	selected_actor_ids = kept
	world.set_pve_snapshot(battle,_view_rows,selected_actor_ids,topology.get("camp_positions",[]))
	_overlay.queue_redraw()

func _handle_pointer_event(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed:
			_zoom_at_map(mouse.position,1.12)
		elif mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
			_zoom_at_map(mouse.position,1.0/1.12)
		elif mouse.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = mouse.pressed
			_drag_position = mouse.position
			_drag_distance = 0.0
		elif mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				if minimap_rect().has_point(mouse.position):
					_focus_minimap(mouse.position)
					return
				_drag_distance = 0.0
			elif not _dragging and _drag_distance < 5.0 and map_rect().has_point(mouse.position) and not minimap_rect().has_point(mouse.position):
				_select_or_move_map(mouse.position,mouse.shift_pressed)
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		world.camera.position -= motion.relative/maxf(world.camera.zoom.x,0.001)
		world._update_chunks()
		_drag_distance += motion.relative.length()
		_drag_position = motion.position
		_overlay.queue_redraw()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and minimap_rect().has_point(touch.position):
			_focus_minimap(touch.position)
		elif not touch.pressed and map_rect().has_point(touch.position) and not minimap_rect().has_point(touch.position):
			_select_or_move_map(touch.position,false)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		world.camera.position -= drag.relative/maxf(world.camera.zoom.x,0.001)
		world._update_chunks()
		_overlay.queue_redraw()

func _select_or_move_map(screen: Vector2,shift: bool) -> void:
	var nearest := ""
	var best := 22.0*22.0
	if battle != null:
		for raw_id in battle.actors:
			var actor: Dictionary = battle.actors[raw_id]
			if str(actor.get("side","")) != "disciple" or float(actor.get("hp",0.0)) <= 0.0:
				continue
			var point := _world_to_screen(world.pve_render_positions.get(str(raw_id),actor.get("position",Vector2.ZERO)))
			var distance := point.distance_squared_to(screen)
			if distance < best:
				best = distance
				nearest = str(raw_id)
	if not nearest.is_empty():
		if shift:
			if selected_actor_ids.has(nearest):
				selected_actor_ids.erase(nearest)
			else:
				selected_actor_ids.append(nearest)
		else:
			selected_actor_ids = [nearest]
		selection_changed.emit(selected_actor_ids.duplicate())
		world.pve_selected_actor_ids = selected_actor_ids.duplicate()
		world.queue_redraw()
		_overlay.queue_redraw()
		return
	if selected_actor_ids.is_empty() or battle == null:
		return
	var cell := world.pve_screen_to_cell(screen,size)
	var nav: Dictionary = battle.world_navigation if battle.world_mode else topology.get("navigation",{})
	var target := PveOpenWorldTopologyV1._nearest_walkable(nav,Vector2i(floori(cell.x),floori(cell.y)))
	if target.x >= 0:
		move_ordered.emit(selected_actor_ids.duplicate(),Vector2(target)+Vector2(0.5,0.5))

func _zoom_at_map(screen: Vector2,factor: float) -> void:
	var old_zoom := world.camera.zoom.x
	var projected_anchor := world.camera.position+(screen-size*0.5)/old_zoom
	var next_zoom := clampf(old_zoom*factor,MIN_ZOOM,MAX_ZOOM)
	world.camera.zoom = Vector2.ONE*next_zoom
	world.camera.position = projected_anchor-(screen-size*0.5)/next_zoom
	world._update_chunks()
	_overlay.queue_redraw()

func _focus_minimap(screen: Vector2) -> void:
	var uv := (screen-minimap_inner_rect().position)/minimap_inner_rect().size
	var bounds: Rect2 = topology.get("bounds",Rect2(Vector2.ZERO,Vector2(SectIsometricWorldV1.GRID)))
	var cell := Vector2(clampf(uv.x,0.0,1.0)*bounds.size.x,clampf(uv.y,0.0,1.0)*bounds.size.y)
	world.camera.position = SectIsometricWorldV1.project(cell)
	world._update_chunks()
	_overlay.queue_redraw()

func _world_to_screen(cell: Vector2) -> Vector2:
	return size*0.5+(SectIsometricWorldV1.project(cell)-world.camera.position)*world.camera.zoom.x

func _screen_to_cell(screen: Vector2) -> Vector2:
	return world.pve_screen_to_cell(screen,size)

func map_rect() -> Rect2:
	return Rect2(Vector2.ZERO,size)

func minimap_rect() -> Rect2:
	return Rect2(Vector2(size.x-170.0,10.0),Vector2(160.0,156.0))

func minimap_inner_rect() -> Rect2:
	return Rect2(minimap_rect().position+Vector2(6.0,20.0),minimap_rect().size-Vector2(12.0,26.0))

func minimap_world_to_screen(cell: Vector2) -> Vector2:
	return _minimap_point(cell,minimap_inner_rect())

func world_to_screen(cell: Vector2) -> Vector2:
	return _world_to_screen(cell)

func _gui_input(event: InputEvent) -> void:
	_handle_pointer_event(event)

func _zoom_at(screen: Vector2,factor: float) -> void:
	_zoom_at_map(screen,factor)

func _select_or_move(screen: Vector2,shift: bool) -> void:
	_select_or_move_map(screen,shift)

func _clamp_camera() -> void:
	if world == null or world.camera == null:
		return
	var center := SectIsometricWorldV1.inverse(world.camera.position)
	center.x = clampf(center.x,0.0,float(SectIsometricWorldV1.GRID.x-1))
	center.y = clampf(center.y,0.0,float(SectIsometricWorldV1.GRID.y-1))
	world.camera.position = SectIsometricWorldV1.project(center)
	world._update_chunks()
	_queue_overlay_redraw()

func _draw_overlay(canvas: CanvasItem) -> void:
	var font := ThemeDB.fallback_font
	var heading := "THANH TRÚC LÂM · RỪNG NGUYÊN SINH"
	canvas.draw_rect(Rect2(Vector2(8,8),Vector2(minf(300.0,size.x-190.0),22.0)),Color(0.03,0.07,0.06,0.82))
	if font != null:
		canvas.draw_string_outline(font,Vector2(14,24),heading,HORIZONTAL_ALIGNMENT_LEFT,-1,11,2,Color(0.01,0.02,0.02,0.9))
		canvas.draw_string(font,Vector2(14,24),heading,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("f1d488"))
	for index in range(topology.get("camp_positions",[]).size()):
		var center: Vector2 = topology["camp_positions"][index]
		var point := _world_to_screen(center)
		if not map_rect().grow(22).has_point(point):
			continue
		var radius := maxf(8.0,6.0*world.camera.zoom.x)
		canvas.draw_circle(point,radius,Color(0.78,0.63,0.37,0.035))
		canvas.draw_arc(point,radius,0.0,TAU,20,Color("d7c18d",0.42),1.0,true)
		if index == camp_index and font != null:
			canvas.draw_string_outline(font,point+Vector2(7,-6),"C%02d" % (index+1),HORIZONTAL_ALIGNMENT_LEFT,-1,9,2,Color(0.02,0.03,0.02,0.9))
			canvas.draw_string(font,point+Vector2(7,-6),"C%02d" % (index+1),HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("f1d488"))
	var frame := minimap_rect()
	canvas.draw_rect(frame,Color("09110e",0.94))
	var inner := minimap_inner_rect()
	var mini := world.pve_minimap_texture()
	if mini != null:
		canvas.draw_texture_rect(mini,inner,false)
	for index in range(topology.get("camp_positions",[]).size()):
		var center: Vector2 = topology["camp_positions"][index]
		canvas.draw_circle(_minimap_point(center,inner),2.0,Color("f2d385") if index == camp_index else Color(0.84,0.71,0.46,0.82))
	if battle != null:
		for raw_id in battle.actors:
			var actor: Dictionary = battle.actors[raw_id]
			var point := _minimap_point(actor.get("position",Vector2.ZERO),inner)
			var is_disciple := str(actor.get("side","")) == "disciple"
			var alive := float(actor.get("hp",0.0)) > 0.0
			canvas.draw_circle(point,2.0,Color("65ddc6") if is_disciple else Color("ed806b") if alive else Color("888a7e"))
	var corners: Array[Vector2] = []
	for screen_corner in [Vector2.ZERO,Vector2(size.x,0),size,Vector2(0,size.y)]:
		corners.append(_minimap_point(_screen_to_cell(screen_corner),inner))
	var polygon := PackedVector2Array(corners)
	canvas.draw_colored_polygon(polygon,Color(0.94,0.77,0.35,0.09))
	canvas.draw_polyline(PackedVector2Array([polygon[0],polygon[1],polygon[2],polygon[3],polygon[0]]),Color("f2d385"),1.1,true)
	canvas.draw_rect(frame,Color("d3c494"),false,1.0)
	canvas.draw_rect(Rect2(frame.position+Vector2(1,1),Vector2(frame.size.x-2,18)),Color(0.035,0.075,0.072,0.92))
	if font != null:
		canvas.draw_string(font,frame.position+Vector2(5,14),"MINIMAP · THẾ GIỚI THẬT",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("f1d488"))
		canvas.draw_string_outline(font,Vector2(12,size.y-10),"Bấm đất: di chuyển · Kéo phải: camera · Lăn: zoom",HORIZONTAL_ALIGNMENT_LEFT,-1,9,2,Color(0.01,0.02,0.02,0.9))
		canvas.draw_string(font,Vector2(12,size.y-10),"Bấm đất: di chuyển · Kéo phải: camera · Lăn: zoom",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("f3efdd"))
	if not source_error.is_empty() and font != null:
		canvas.draw_string(font,Vector2(12,44),source_error,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("f0a474"))

func _minimap_point(cell: Vector2,inner: Rect2) -> Vector2:
	var bounds: Rect2 = topology.get("bounds",Rect2(Vector2.ZERO,Vector2(SectIsometricWorldV1.GRID)))
	return inner.position+Vector2(cell.x/bounds.size.x*inner.size.x,cell.y/bounds.size.y*inner.size.y)

func _queue_overlay_redraw() -> void:
	if _overlay != null:
		_overlay.queue_redraw()
