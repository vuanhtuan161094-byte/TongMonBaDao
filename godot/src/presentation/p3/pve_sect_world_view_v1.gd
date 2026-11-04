class_name PveSectWorldViewV1
extends Control

signal move_ordered(actor_ids: Array, destination: Vector2)
signal selection_changed(actor_ids: Array)
signal hunt_policy_ordered(actor_ids: Array, policy: String)

const MINIMAP_MARGIN := 10.0
const MIN_ZOOM := 0.28
const MAX_ZOOM := 1.35

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
var battle: MapBattleV2
var population: Dictionary = {}
var camp_index := 0
var selected_actor_ids: Array[String] = []
var source_error := ""
var world: SectIsometricWorldV1
var prepare_world_call_count := 0
var topology_build_count := 0
var minimap_build_count := 0
var _cached_source_blob_sha := ""
var _cached_source_map := ""
var _cached_navigation: Dictionary = {}
var _cached_topology: Dictionary = {}
var _cached_minimap: Texture2D
var _container: SubViewportContainer
var _viewport: SubViewport
var _overlay: InputOverlay
var _disciples: Dictionary = {}
var _view_rows: Dictionary = {}
var _zoom_in_button: Button
var _zoom_out_button: Button
var _hunt_auto_button: Button
var _hunt_hold_button: Button
var performance_logging_enabled := false
var performance_vfx_draw_count := 0
var performance_vfx_draw_usec_total := 0
var performance_vfx_draw_usec_max := 0
var _dragging := false
var _left_dragging := false
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
	performance_logging_enabled = OS.get_environment("TMB_PVE_PERF_LOG") == "1"
	clip_contents = true
	_container = SubViewportContainer.new()
	_container.name = "SectPveWorldViewportContainer"
	_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# The P3.2 layout sizes this viewport explicitly on every resize.
	# Keeping stretch enabled conflicts with assigning SubViewport.size and
	# emits a warning during hunt open/refresh, so this is an exact-size child.
	_container.stretch = false
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_container)
	_viewport = SubViewport.new()
	_viewport.name = "SectPveWorldSubViewport"
	_viewport.size = Vector2i(maxi(1,roundi(size.x)),maxi(1,roundi(size.y)))
	# Hidden hunt UI should not keep rendering. While visible, UPDATE_WHEN_VISIBLE
	# still updates each frame for actor motion, camera changes, and live VFX.
	_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
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
	_create_zoom_controls()
	_create_hunt_controls()
	_overlay.queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _viewport != null:
		_viewport.size = Vector2i(maxi(1,roundi(size.x)),maxi(1,roundi(size.y)))
		if world != null:
			world._update_chunks()
			world.queue_redraw()
		if _overlay != null:
			_overlay.queue_redraw()

func _process(_delta: float) -> void:
	if world != null and world.pve_jx_sword_vfx.active_count() > 0:
		_queue_overlay_redraw()

func _input(event: InputEvent) -> void:
	# Handle the wheel in the input phase before fullscreen HUD parents or other
	# Controls can consume it as a scroll event. The map overlay still owns
	# click, drag, and touch input; this only routes wheel zoom reliably.
	if not visible or not is_inside_tree() or world == null or world.camera == null:
		return
	if not event is InputEventMouseButton:
		return
	var mouse := event as InputEventMouseButton
	if not mouse.pressed or mouse.button_index not in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		return
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered != null and (not is_ancestor_of(hovered) or hovered is BaseButton):
		return
	var local_point: Vector2 = get_global_transform_with_canvas().affine_inverse()*mouse.position
	if not Rect2(Vector2.ZERO,size).has_point(local_point):
		return
	var factor := 1.12 if mouse.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0/1.12
	_zoom_at_map(local_point,factor)
	get_viewport().set_input_as_handled()

func _create_zoom_controls() -> void:
	_zoom_in_button = _make_zoom_button("PveWorldZoomIn","+","Phóng to bản đồ")
	_zoom_out_button = _make_zoom_button("PveWorldZoomOut","−","Thu nhỏ bản đồ")
	for entry in [[_zoom_in_button,176.0],[_zoom_out_button,226.0]]:
		var button: Button = entry[0]
		# The right edge is covered by the live Combat V2 facts panel in the
		# 1280x720 P3.2 layout. Keep the controls in the clear left gutter below
		# the status card so both mouse and touch can reach them.
		button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		button.offset_left = 12.0
		button.offset_top = float(entry[1])
		button.offset_right = 60.0
		button.offset_bottom = float(entry[1])+44.0
		add_child(button)
	_zoom_in_button.pressed.connect(_zoom_in_at_center)
	_zoom_out_button.pressed.connect(_zoom_out_at_center)

func _create_hunt_controls() -> void:
	# Compact game commands below the two zoom icons. Never display enabled
	# actions until the exclusive P3.2 writer connects the authoritative
	# runtime+SaveService callbacks; avoid inert/misleading UI.
	_hunt_auto_button = _make_zoom_button(
		"PveP0HuntAuto","⚔ Tự săn","Đệ tử đã chọn tự săn gần vị trí đang đứng")
	_hunt_hold_button = _make_zoom_button(
		"PveP0HuntHold","◆ Giữ","Đệ tử đã chọn giữ vị trí, đánh trong tầm")
	for entry in [[_hunt_auto_button,280.0],[_hunt_hold_button,326.0]]:
		var button: Button = entry[0]
		button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		button.offset_left = 12.0
		button.offset_top = float(entry[1])
		button.offset_right = 124.0
		button.offset_bottom = float(entry[1])+40.0
		button.custom_minimum_size = Vector2(112,40)
		button.add_theme_font_size_override("font_size",15)
		add_child(button)
	_hunt_auto_button.pressed.connect(func(): _emit_hunt_policy("auto"))
	_hunt_hold_button.pressed.connect(func(): _emit_hunt_policy("hold"))
	refresh_hunt_controls()

func refresh_hunt_controls() -> void:
	if _hunt_auto_button == null or _hunt_hold_button == null:
		return
	var p0 := battle != null and battle.world_mode \
		and PveDistributedWorldV1.enabled(population)
	var authoritative_listener := hunt_policy_ordered.has_connections()
	for button in [_hunt_auto_button,_hunt_hold_button]:
		button.visible = p0 and authoritative_listener
		button.disabled = not p0 or not authoritative_listener \
			or selected_actor_ids.is_empty()

func _emit_hunt_policy(policy: String) -> void:
	if not ["auto","hold"].has(policy) or selected_actor_ids.is_empty() \
		or not hunt_policy_ordered.has_connections() \
		or battle == null or not battle.world_mode \
		or not PveDistributedWorldV1.enabled(population):
		return
	var selected: Array[String] = []
	for raw_id in selected_actor_ids:
		var id := str(raw_id)
		var actor: Dictionary = battle.actors.get(id,{})
		if str(actor.get("side","")) != "disciple" \
			or float(actor.get("hp",0.0)) <= 0.0:
			return
		selected.append(id)
	selected.sort()
	hunt_policy_ordered.emit(selected,policy)

func _make_zoom_button(node_name: String,text_value: String,tooltip: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text_value
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(48.0,44.0)
	button.add_theme_font_size_override("font_size",22)
	button.add_theme_color_override("font_color",Color("f3efdd"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035,0.105,0.085,0.96)
	normal.border_color = Color("d7c695")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(6)
	button.add_theme_stylebox_override("normal",normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("315a49")
	button.add_theme_stylebox_override("hover",hover)
	button.add_theme_stylebox_override("pressed",hover)
	return button

func _zoom_in_at_center() -> void:
	_zoom_at_map(size*0.5,1.12)

func _zoom_out_at_center() -> void:
	_zoom_at_map(size*0.5,1.0/1.12)

func consume_vfx_draw_metrics() -> Dictionary:
	var result := {
		"count":performance_vfx_draw_count,
		"total_usec":performance_vfx_draw_usec_total,
		"max_usec":performance_vfx_draw_usec_max
	}
	performance_vfx_draw_count = 0
	performance_vfx_draw_usec_total = 0
	performance_vfx_draw_usec_max = 0
	return result

func prepare_world() -> Dictionary:
	prepare_world_call_count += 1
	if world == null:
		source_error = "source_a_world_renderer_missing"
		return {"ok":false,"reason":source_error}
	# SectIsometricWorldV1 builds this immutable navigation and minimap once
	# during _ready. Reuse those exact objects: the live HUD refreshes every
	# 250 ms, while generating forest identity, topology BFS and a 192x192 image
	# on every refresh caused visible stutter without changing gameplay state.
	var navigation: Dictionary = world.pve_navigation
	var source_sha := str(navigation.get("source_blob_sha",""))
	var source_map := str(navigation.get("source_map",""))
	if source_sha.length() != 40 or source_map.is_empty():
		source_error = "source_a_world_identity_missing"
		return {"ok":false,"reason":source_error}
	var cache_matches := source_sha == _cached_source_blob_sha and source_map == _cached_source_map
	if cache_matches:
		topology = _cached_topology
	else:
		var built := PveOpenWorldTopologyV1.build(navigation,Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5))
		if not bool(built.get("ok",false)):
			source_error = str(built.get("reason","source_a_world_topology_failed"))
			return {"ok":false,"reason":source_error}
		if str(built.get("source_blob_sha","")) != source_sha or str(built.get("source_map","")) != source_map:
			source_error = "source_a_topology_identity_mismatch"
			return {"ok":false,"reason":source_error}
		topology_build_count += 1
		var minimap := world.pve_mini_texture
		if minimap == null:
			minimap = SectIsometricWorldV1._pve_minimap_texture(navigation,world.pve_path_cells)
			minimap_build_count += 1
		_cached_source_blob_sha = source_sha
		_cached_source_map = source_map
		_cached_navigation = navigation
		_cached_topology = built
		_cached_minimap = minimap
		topology = _cached_topology
	world.pve_topology = topology
	world.pve_navigation = _cached_navigation
	world.pve_mini_texture = _cached_minimap
	source_error = ""
	if not world.pve_camera_initialized:
		var camps: Array = topology.get("camp_positions",[])
		if not camps.is_empty():
			world.set_pve_camera(camps[0],0.72)
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
	# Reapply after the hunt panel becomes visible: the viewport may have been
	# promoted to UPDATE_ALWAYS by the previous hidden/visible parent lifecycle.
	if _viewport != null:
		_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	battle = snapshot
	population = world_population.duplicate(false)
	camp_index = clampi(current_camp_index,0,PveMultiCampPopulationV1.CAMP_COUNT-1)
	_disciples = disciples.duplicate(false)
	_view_rows = view_rows.duplicate(true)
	if battle == null:
		selected_actor_ids.clear()
		refresh_hunt_controls()
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
	# Legacy six-member pilot starts with the whole squad selected. P0
	# independent world MUST start with no implicit selection: otherwise a
	# single minimap click unintentionally orders every deployed hunter.
	if kept.is_empty() and not PveDistributedWorldV1.enabled(population):
		kept = current_disciples.duplicate()
	selected_actor_ids = kept
	refresh_hunt_controls()
	world.set_pve_snapshot(battle,_view_rows,selected_actor_ids,topology.get("camp_positions",[]))
	_overlay.queue_redraw()

func _handle_pointer_event(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = mouse.pressed
			_drag_position = mouse.position
			_drag_distance = 0.0
		elif mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				_left_dragging = map_rect().has_point(mouse.position) and not minimap_rect().has_point(mouse.position)
				_drag_position = mouse.position
				_drag_distance = 0.0
				if minimap_rect().has_point(mouse.position):
					_focus_minimap(mouse.position)
			else:
				# A click orders/selects; a real drag pans and must never issue a move.
				var short_click := _left_dragging and _drag_distance < 6.0
				_left_dragging = false
				if short_click and map_rect().has_point(mouse.position) and not minimap_rect().has_point(mouse.position):
					_select_or_move_map(mouse.position,mouse.shift_pressed)
	elif event is InputEventMouseMotion and (_dragging or _left_dragging):
		var motion := event as InputEventMouseMotion
		_drag_distance += motion.relative.length()
		if _left_dragging and _drag_distance < 6.0:
			return
		world.camera.position -= motion.relative/maxf(world.camera.zoom.x,0.001)
		_clamp_camera()
		_drag_position = motion.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and minimap_rect().has_point(touch.position):
			_focus_minimap(touch.position)
		elif not touch.pressed and map_rect().has_point(touch.position) and not minimap_rect().has_point(touch.position):
			_select_or_move_map(touch.position,false)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		world.camera.position -= drag.relative/maxf(world.camera.zoom.x,0.001)
		_clamp_camera()

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
		refresh_hunt_controls()
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
	_clamp_camera()

func _focus_minimap(screen: Vector2) -> void:
	var uv := (screen-minimap_inner_rect().position)/minimap_inner_rect().size
	var bounds: Rect2 = topology.get("bounds",Rect2(Vector2.ZERO,Vector2(SectIsometricWorldV1.GRID)))
	var cell := Vector2(clampf(uv.x,0.0,1.0)*bounds.size.x,clampf(uv.y,0.0,1.0)*bounds.size.y)
	# Age-of-Empires-style minimap command: selected hunters GO to the
	# clicked area. No selected actors means an ordinary camera focus.
	# Only emit an order; the canonical P3.2 owner validates and persists it.
	if not selected_actor_ids.is_empty() and battle != null and battle.world_mode:
		var navigation: Dictionary = battle.world_navigation
		var walkable := PveOpenWorldTopologyV1._nearest_walkable(
			navigation,Vector2i(floori(cell.x),floori(cell.y)))
		if walkable.x >= 0:
			move_ordered.emit(selected_actor_ids.duplicate(),
				Vector2(walkable)+Vector2(0.5,0.5))
		return
	world.camera.position = SectIsometricWorldV1.project(cell)
	_clamp_camera()

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
		var controls_rect := Rect2(Vector2(310.0,size.y-80.0),Vector2(368.0,20.0))
		canvas.draw_rect(controls_rect,Color(0.03,0.07,0.06,0.84))
		var controls_text := "Bấm đất: di chuyển · Kéo trái/phải: camera · Lăn / + −: zoom"
		canvas.draw_string_outline(font,Vector2(316.0,size.y-66.0),controls_text,HORIZONTAL_ALIGNMENT_LEFT,-1,9,2,Color(0.01,0.02,0.02,0.9))
		canvas.draw_string(font,Vector2(316.0,size.y-66.0),controls_text,HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("f3efdd"))
	if not source_error.is_empty() and font != null:
		canvas.draw_string(font,Vector2(12,44),source_error,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("f0a474"))
	if world == null or world.pve_jx_sword_vfx.comparison_style == "source_a":
		return
	var vfx_draw_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
	for cue in world.pve_jx_sword_vfx.render_cues():
		var position := _world_to_screen(cue.get("at",Vector2.ZERO))
		if not map_rect().grow(80.0).has_point(position) or minimap_rect().has_point(position):
			continue
		var phase := str(cue.get("phase",""))
		var drew_effect: bool = world.pve_jx_sword_vfx.atlas.draw_effect(canvas,str(cue.get("effect","")),position,
			float(cue.get("elapsed",0.0)),float(cue.get("scale",0.4))*world.camera.zoom.x)
		if phase in ["flight","await_hit"]:
			var from := _world_to_screen(cue.get("from",Vector2.ZERO))
			var to := _world_to_screen(cue.get("to",Vector2.ZERO))
			var direction := to-from
			if direction.length_squared() > 0.001:
				canvas.draw_line(position-direction.normalized()*12.0,position-direction.normalized()*3.0,
					Color(0.88,0.83,0.58,0.62),1.8,true)
	if performance_logging_enabled:
		var elapsed_usec := Time.get_ticks_usec()-vfx_draw_started_usec
		performance_vfx_draw_count += 1
		performance_vfx_draw_usec_total += elapsed_usec
		performance_vfx_draw_usec_max = maxi(performance_vfx_draw_usec_max,elapsed_usec)

func _minimap_point(cell: Vector2,inner: Rect2) -> Vector2:
	var bounds: Rect2 = topology.get("bounds",Rect2(Vector2.ZERO,Vector2(SectIsometricWorldV1.GRID)))
	return inner.position+Vector2(cell.x/bounds.size.x*inner.size.x,cell.y/bounds.size.y*inner.size.y)

func _queue_overlay_redraw() -> void:
	if _overlay != null:
		_overlay.queue_redraw()

