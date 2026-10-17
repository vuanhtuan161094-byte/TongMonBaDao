extends "res://src/presentation/p3_1_landscape_sect.gd"

const ZOOM_STEP := 1.12
const CAMERA_TWEEN_SECONDS := 0.22
const FOCUS_MARKER_SIZE := Vector2(82.0, 82.0)
const PRODUCTION_PANEL_WIDTH := 420.0
const PRODUCTION_CONTENT_WIDTH := 384.0
# Visual travel rate in map world pixels/second; gameplay travel, scheduler
# and profession work speed remain separate canonical systems.
const MAP_ACTOR_VISUAL_WALK_PX_PER_SEC := 175.0
const MAP_TOUCH_DRAG_THRESHOLD_PX := 12.0
const MAP_MOUSE_DRAG_THRESHOLD_PX := 8.0

var map_zoom: float = SectMapCamera.DEFAULT_ZOOM
var touch_points: Dictionary = {}
var touch_start_points: Dictionary = {}
var last_pinch_distance: float = 0.0
var mouse_panning := false
var mouse_press_position := Vector2.ZERO
var camera_tween: Tween
var focus_marker_tween: Tween
var zoom_readout: Label
var focus_readout: Label
var focus_target_button: Button
var focus_marker: Panel
var focused_world_point := Vector2.ZERO
var focused_kind: StringName = &""
var focused_id: StringName = &""
var focused_label := ""
var has_focus_target := false
var tab_status_text := ""
var technique_system := TechniqueSystem.new()
var equipment_system := EquipmentSystem.new()
var needs_system := NeedsSystem.new()
var recruitment_system := RecruitmentSystem.new()
var spirit_crop_registry := SpiritCropRegistry.new()
var production_plan_registry := ProductionPlanRegistry.new()
var living_cue_resolver := LivingCueResolver.new()
var living_cue_tracker := LivingCueTracker.new()
var living_cue_layer: LivingCueLayer
var visible_living_cues: Array[Dictionary] = []
var female_motion_library: AnimationLibrary
var workforce_return_building_id: StringName = &""
var modular_live_actor_ids: Dictionary = {}
var actor_walk_tweens: Dictionary = {}
# Visual destinations let recurring scheduler refreshes reuse a running tween.
var actor_walk_targets: Dictionary = {}
# Only three source scenes currently: cache shared stand textures by scene path,
# never make one atlas/AnimatedSprite2D per disciple or roster entry.
var source_a_portrait_textures: Dictionary = {}
# Read-only map display; receipt baseline is presentation-memory only and is
# initialized from the loaded save to prevent phantom "collected" messages.
var map_worksite_cues: Dictionary = {}
var map_worksite_receipt_baseline: Dictionary = {}
# Cached presentation anchors/offsets; layout and zoom never touch simulation.
var map_worksite_anchors: Dictionary = {}
var map_worksite_screen_offsets: Dictionary = {}
var map_worksite_last_scale := -1.0
const MAP_WORKSITE_MAX_CUES := 10

var camera_controls_panel: Panel
var camera_hint: Label
var disciple_summary_panel: Panel
var disciple_summary_initial: Label
var disciple_summary_name: Label
var disciple_summary_meta: Label
var disciple_summary_body: Label
var summary_feedback := ""

var building_operation_panel: Panel
var building_operation_title: Label
var building_operation_body: Label
var building_operation_progress_caption: Label
var building_operation_progress_bar: ProgressBar
var building_operation_content: VBoxContainer
var building_management_container: VBoxContainer
var building_management_feedback := ""
var building_management_query := ""
var disciple_profile_query := ""
const MANAGEMENT_PAGE_SIZE := 50
const DISCIPLE_PROFILE_PAGE_SIZE := 50
var selected_building: StringName = &""
var iso_view_container: SubViewportContainer
var iso_viewport: SubViewport
var iso_world: SectIsometricWorldV1
var iso_building_count := -1
# UI selection only; actual building ID/worker/production live in SimulationState.
var selected_production_instance_id: StringName = &""
var sect_layout_preview_open := false
# Presentation-only listing state; all actual producers stay in SimulationState.
var sect_production_board_open := false
var sect_production_board_filter: StringName = &""
var sect_production_attention_only := false
var sect_production_board_page := 0
const SECT_PRODUCTION_PAGE_SIZE := 8
var workforce_picker_panel: Panel
var workforce_picker_results: VBoxContainer
var workforce_picker_search: LineEdit
var workforce_picker_building_id: StringName = &""
var workforce_picker_query := ""
var workforce_picker_offset := 0
var workforce_advanced_visible := false
# Presentation-only navigation state. All displayed numbers come from the
# existing canonical SimulationState, never from a second model.
var sect_hub_panel: Panel
var sect_hub_content: VBoxContainer
var sect_hub_button: Button
var last_accepted_disciple_id: StringName = &""
const WORKFORCE_PICKER_PAGE_SIZE := 8
var deep_restore_summary := false
var screen_pointer_dragged := false
var mouse_pointer_dragged := false

func _ready() -> void:
    super._ready()
    if not runtime_ready:
        return
    female_motion_library = FemaleNormalV1MotionLibrary.build()
    _install_modular_live_actors()
    _install_main_isometric_world()
    _sync_actor_positions()
    popup_layer.z_index = 100
    _reset_camera(false)
    _build_focus_marker()
    _build_camera_controls()
    _build_disciple_summary_panel()
    _build_building_operation_panel()
    _build_sect_hub()
    _build_living_cue_layer()
    _seed_map_worksite_receipts()
    _refresh_map_worksite_cues()
    living_cue_tracker.seed_from_state(state)
    _refresh_living_cues()

# Only the 2.5D world goes in a real Camera2D canvas; legacy controls/HUD
# remain outside it. All actual jobs, buildings and stocks are untouched.
func _install_main_isometric_world() -> void:
    if map_layer == null or iso_world != null:
        return
    iso_view_container = SubViewportContainer.new()
    iso_view_container.name = "SectMainIsoViewportContainer"
    iso_view_container.position = SectMapCamera.VIEW_RECT.position
    iso_view_container.size = SectMapCamera.VIEW_RECT.size
    iso_view_container.stretch = false
    iso_view_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(iso_view_container)
    # Background is child 0; the Control actor/interaction map layer follows.
    # Insert the 2.5D texture BEFORE map_layer or it overpaints disciples.
    move_child(iso_view_container,map_layer.get_index())
    iso_viewport = SubViewport.new()
    iso_viewport.name = "SectMainIsoSubViewport"
    iso_viewport.size = Vector2i(1280,570)
    # Only camera movement and building-layout changes invalidate this static map.
    # The moving disciple actors remain outside the map SubViewport.
    iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    iso_viewport.gui_disable_input = true
    iso_view_container.add_child(iso_viewport)
    iso_world = SectIsometricWorldV1.new()
    iso_world.name = "SectIsoWorld192"
    iso_viewport.add_child(iso_world)
    iso_world.refresh_from_state(state)
    iso_building_count = state.building_event_count
    # Retain the names of historical test controls but hide flat graybox
    # visuals; no old token can intercept a genuine 2.5D world tap.
    for node in map_layer.get_children():
        if node is ModularDiscipleActor:
            continue
        if node is CanvasItem:
            (node as CanvasItem).visible = false
        if node is Control:
            _disable_legacy_hit_input(node)
    iso_world.set_legacy_transform(map_zoom,map_layer.position)

func _disable_legacy_hit_input(parent: Node) -> void:
    if parent is Control:
        (parent as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
    for child in parent.get_children():
        _disable_legacy_hit_input(child)

func _iso_actor_point(destination: StringName) -> Vector2:
    if iso_world == null:
        return SectMapPresentation.position_for_destination(destination)
    return SectIsometricWorldV1.virtual_legacy_point(destination)

func _iso_open_picked_building(picked: Dictionary) -> void:
    if picked.is_empty():
        return
    var dest := StringName(picked.get("destination",""))
    if dest == &"":
        return
    var real_id := StringName(picked.get("building_id",""))
    # One exact-ID path controls selection, focus AND the first panel paint.
    # Opening the generic type first used to pan toward its primary site.
    _open_building(dest,real_id)

func _try_iso_map_pick(screen_point: Vector2) -> bool:
    if iso_world == null or not SectMapCamera.is_map_screen_point(screen_point):
        return false
    if _popup_is_open() or _building_operation_is_open() or _disciple_summary_is_open():
        return false
    var picked := iso_world.pick_at_screen(screen_point)
    if picked.is_empty():
        return false
    _iso_open_picked_building(picked)
    get_viewport().set_input_as_handled()
    return true

func _unhandled_input(event: InputEvent) -> void:
    if _popup_is_open():
        _clear_pointer_state()
        return

    if event is InputEventScreenTouch:
        _handle_screen_touch(event as InputEventScreenTouch)
        return
    if event is InputEventScreenDrag:
        _handle_screen_drag(event as InputEventScreenDrag)
        return
    if event is InputEventMouseButton:
        _handle_mouse_button(event as InputEventMouseButton)
        return
    if event is InputEventMouseMotion:
        _handle_mouse_motion(event as InputEventMouseMotion)

func _build_focus_marker() -> void:
    focus_marker = Panel.new()
    focus_marker.size = FOCUS_MARKER_SIZE
    focus_marker.visible = false
    focus_marker.z_index = 80
    focus_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    focus_marker.add_theme_stylebox_override("panel", _style(Color(1.0, 1.0, 1.0, 0.02), GOLD, 3, 41))
    map_layer.add_child(focus_marker)

func _build_camera_controls() -> void:
    var panel := Panel.new()
    camera_controls_panel = panel
    panel.position = Vector2(1204, 150)
    panel.size = Vector2(60, 252)
    panel.z_index = 20
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.add_theme_stylebox_override("panel", _style(Color(0.91, 0.86, 0.72, 0.92), INK, 2, 14))
    add_child(panel)

    var plus := Button.new()
    plus.text = "+"
    plus.position = Vector2(8, 8)
    plus.size = Vector2(44, 42)
    plus.add_theme_font_size_override("font_size", 22)
    plus.tooltip_text = "Phóng to"
    plus.pressed.connect(_zoom_in)
    panel.add_child(plus)

    zoom_readout = Label.new()
    zoom_readout.position = Vector2(4, 55)
    zoom_readout.size = Vector2(52, 26)
    zoom_readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    zoom_readout.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    zoom_readout.add_theme_font_size_override("font_size", 12)
    zoom_readout.add_theme_color_override("font_color", INK)
    panel.add_child(zoom_readout)

    var minus := Button.new()
    minus.text = "−"
    minus.position = Vector2(8, 84)
    minus.size = Vector2(44, 42)
    minus.add_theme_font_size_override("font_size", 22)
    minus.tooltip_text = "Thu nhỏ"
    minus.pressed.connect(_zoom_out)
    panel.add_child(minus)

    focus_target_button = Button.new()
    focus_target_button.text = "Mục"
    focus_target_button.position = Vector2(8, 134)
    focus_target_button.size = Vector2(44, 40)
    focus_target_button.add_theme_font_size_override("font_size", 11)
    focus_target_button.tooltip_text = "Tới mục tiêu đang chọn"
    focus_target_button.disabled = true
    focus_target_button.pressed.connect(_focus_current_target)
    panel.add_child(focus_target_button)

    var reset := Button.new()
    reset.text = "Toàn"
    reset.position = Vector2(8, 184)
    reset.size = Vector2(44, 40)
    reset.add_theme_font_size_override("font_size", 11)
    reset.tooltip_text = "Về toàn cảnh"
    reset.pressed.connect(_reset_camera.bind(true))
    panel.add_child(reset)

    focus_readout = Label.new()
    focus_readout.text = ""
    focus_readout.position = Vector2(-156, 228)
    focus_readout.size = Vector2(208, 20)
    focus_readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    focus_readout.add_theme_font_size_override("font_size", 10)
    focus_readout.add_theme_color_override("font_color", Color(0.16, 0.16, 0.13, 0.74))
    focus_readout.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(focus_readout)

    var hint := Label.new()
    camera_hint = hint
    hint.text = "Chụm 2 ngón: zoom  •  Kéo: di chuyển  •  Chạm đúp: phóng nhanh"
    hint.position = Vector2(704, 606)
    hint.size = Vector2(480, 26)
    hint.z_index = 20
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hint.add_theme_font_size_override("font_size", 11)
    hint.add_theme_color_override("font_color", Color(0.16, 0.16, 0.13, 0.74))
    hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(hint)

    _refresh_zoom_readout()
    _refresh_focus_readout()

func _handle_screen_touch(touch: InputEventScreenTouch) -> void:
    if touch.pressed:
        if not SectMapCamera.is_map_screen_point(touch.position):
            return
        if touch_points.is_empty():
            screen_pointer_dragged = false
        else:
            screen_pointer_dragged = true
        touch_points[touch.index] = touch.position
        touch_start_points[touch.index] = touch.position
        if touch.double_tap:
            screen_pointer_dragged = true
            _zoom_at(touch.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
        _refresh_pinch_baseline()
        return

    var was_single_pointer := touch_points.size() == 1 and touch_points.has(touch.index)
    touch_points.erase(touch.index)
    touch_start_points.erase(touch.index)
    _refresh_pinch_baseline()
    if touch_points.is_empty() and screen_pointer_dragged:
        _refresh_map_worksite_cues()
    if was_single_pointer and not screen_pointer_dragged:
        if _try_iso_map_pick(touch.position):
            return
        if _disciple_summary_is_open():
            _close_disciple_summary(true)
        elif _building_operation_is_open():
            _close_building_operation_panel(true)

func _handle_screen_drag(drag: InputEventScreenDrag) -> void:
    if not touch_points.has(drag.index):
        return
    var old_point := Vector2(touch_points[drag.index])
    touch_points[drag.index] = drag.position

    if touch_points.size() >= 2:
        screen_pointer_dragged = true
        var pair := _first_two_touch_points()
        if pair.size() < 2:
            return
        var point_a: Vector2 = pair[0]
        var point_b: Vector2 = pair[1]
        var distance := point_a.distance_to(point_b)
        var center := (point_a + point_b) * 0.5
        if last_pinch_distance > 0.0001:
            var ratio := distance / last_pinch_distance
            if absf(ratio - 1.0) > 0.002:
                _zoom_at(center, map_zoom * ratio, false)
        last_pinch_distance = distance
        get_viewport().set_input_as_handled()
        return

    # Ignore small per-event jitter until TOTAL finger travel crosses
    # a finger-friendly threshold; otherwise a pan can become a false tap.
    var start := Vector2(touch_start_points.get(drag.index,old_point))
    if not screen_pointer_dragged and drag.position.distance_to(start) < MAP_TOUCH_DRAG_THRESHOLD_PX:
        return
    screen_pointer_dragged = true
    _pan_camera(drag.position-old_point)
    get_viewport().set_input_as_handled()

func _handle_mouse_button(mouse: InputEventMouseButton) -> void:
    if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed:
        if SectMapCamera.is_map_screen_point(mouse.position):
            _zoom_at(mouse.position, map_zoom * ZOOM_STEP, false)
            get_viewport().set_input_as_handled()
        return

    if mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
        if SectMapCamera.is_map_screen_point(mouse.position):
            _zoom_at(mouse.position, map_zoom / ZOOM_STEP, false)
            get_viewport().set_input_as_handled()
        return

    if mouse.button_index != MOUSE_BUTTON_LEFT:
        return

    if mouse.pressed:
        if not SectMapCamera.is_map_screen_point(mouse.position):
            return
        mouse_pointer_dragged = false
        mouse_press_position = mouse.position
        if mouse.double_click:
            mouse_pointer_dragged = true
            _zoom_at(mouse.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
            return
        mouse_panning = true
    else:
        # A release over the world without a preceding world press must
        # not become an accidental building selection.
        if not mouse_panning:
            return
        var should_close_summary := mouse_panning and not mouse_pointer_dragged and _disciple_summary_is_open()
        var should_close_building := mouse_panning and not mouse_pointer_dragged and _building_operation_is_open()
        mouse_panning = false
        if mouse_pointer_dragged:
            _refresh_map_worksite_cues()
        if not mouse_pointer_dragged and _try_iso_map_pick(mouse.position):
            return
        if should_close_summary:
            _close_disciple_summary(true)
        elif should_close_building:
            _close_building_operation_panel(true)

func _handle_mouse_motion(motion: InputEventMouseMotion) -> void:
    if not mouse_panning:
        return
    if (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
        mouse_panning = false
        return
    if not mouse_pointer_dragged and motion.position.distance_to(mouse_press_position) < MAP_MOUSE_DRAG_THRESHOLD_PX:
        return
    mouse_pointer_dragged = true
    _pan_camera(motion.relative)
    get_viewport().set_input_as_handled()

func _zoom_in() -> void:
    _zoom_at(_camera_center(), map_zoom * ZOOM_STEP, true)

func _zoom_out() -> void:
    _zoom_at(_camera_center(), map_zoom / ZOOM_STEP, true)

func _zoom_at(screen_point: Vector2, requested_zoom: float, animate: bool) -> void:
    var transform := SectMapCamera.zoom_around_screen_point(map_layer.position, map_zoom, requested_zoom, screen_point)
    var target_position: Vector2 = transform["position"]
    _apply_camera(float(transform["zoom"]), target_position, animate)

func _pan_camera(delta: Vector2) -> void:
    var next_position := SectMapCamera.pan_position(map_layer.position, delta, map_zoom)
    _apply_camera(map_zoom, next_position, false)

func _focus_world_point(world_point: Vector2, requested_zoom: float = SectMapCamera.FOCUS_ZOOM) -> void:
    var target_zoom := maxf(map_zoom, requested_zoom)
    var transform := SectMapCamera.focus_transform(world_point, target_zoom)
    var target_position: Vector2 = transform["position"]
    _apply_camera(float(transform["zoom"]), target_position, true)

func _focus_current_target() -> void:
    if not has_focus_target:
        return
    if focused_kind == &"disciple":
        _refresh_focused_disciple_point()
    _refresh_disciple_summary_content()
    _refresh_building_operation_content()
    _refresh_living_cues()
    _focus_world_point(focused_world_point)
    _pulse_focus_marker()

func _set_focus_target(world_point: Vector2, kind: StringName, target_id: StringName, label: String, focus_now: bool) -> void:
    focused_world_point = world_point
    focused_kind = kind
    focused_id = target_id
    focused_label = label
    has_focus_target = true
    _position_focus_marker(world_point)
    if focus_target_button != null:
        focus_target_button.disabled = false
    _refresh_focus_readout()
    if focus_now:
        _focus_world_point(world_point)
    _pulse_focus_marker()

func _position_focus_marker(world_point: Vector2) -> void:
    if focus_marker == null:
        return
    focus_marker.position = world_point - FOCUS_MARKER_SIZE * 0.5
    focus_marker.visible = true

func _pulse_focus_marker() -> void:
    if focus_marker == null or not focus_marker.visible:
        return
    if focus_marker_tween != null and focus_marker_tween.is_valid():
        focus_marker_tween.kill()
    focus_marker.modulate = Color(1.0, 1.0, 1.0, 0.45)
    focus_marker_tween = create_tween()
    focus_marker_tween.set_loops(2)
    focus_marker_tween.tween_property(focus_marker, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.14)
    focus_marker_tween.tween_property(focus_marker, "modulate", Color(1.0, 1.0, 1.0, 0.45), 0.14)

func _refresh_focused_disciple_point() -> void:
    if focused_id == &"":
        return
    var key := str(focused_id)
    if not actor_nodes.has(key):
        return
    var actor: Control = actor_nodes[key]
    focused_world_point = actor.position + actor.size * 0.5
    _position_focus_marker(focused_world_point)

func _refresh_focus_readout() -> void:
    if focus_readout != null:
        focus_readout.text = focused_label if has_focus_target else ""

func _reset_camera(animate: bool = true) -> void:
    var transform := SectMapCamera.reset_transform()
    var target_position: Vector2 = transform["position"]
    _apply_camera(float(transform["zoom"]), target_position, animate)

func _apply_camera(zoom: float, position: Vector2, animate: bool) -> void:
    map_zoom = SectMapCamera.clamp_zoom(zoom)
    var target_scale := Vector2.ONE * map_zoom
    var target_position := SectMapCamera.clamp_position(position, map_zoom)

    if camera_tween != null and camera_tween.is_valid():
        camera_tween.kill()

    if animate:
        camera_tween = create_tween()
        camera_tween.set_parallel(true)
        camera_tween.set_trans(Tween.TRANS_QUAD)
        camera_tween.set_ease(Tween.EASE_OUT)
        camera_tween.tween_property(map_layer, "scale", target_scale, CAMERA_TWEEN_SECONDS)
        camera_tween.tween_property(map_layer, "position", target_position, CAMERA_TWEEN_SECONDS)
        # Re-select visible worksite cards after the camera animation,
        # rather than rescanning all buildings on every interpolation frame.
        camera_tween.finished.connect(_refresh_map_worksite_cues)
    else:
        map_layer.scale = target_scale
        map_layer.position = target_position
        if not mouse_panning and touch_points.is_empty():
            _refresh_map_worksite_cues()

    _refresh_zoom_readout()

func _refresh_zoom_readout() -> void:
    if zoom_readout != null:
        zoom_readout.text = "%d%%" % int(round(map_zoom * 100.0))

func _refresh_pinch_baseline() -> void:
    if touch_points.size() < 2:
        last_pinch_distance = 0.0
        return
    var pair := _first_two_touch_points()
    if pair.size() >= 2:
        var point_a: Vector2 = pair[0]
        var point_b: Vector2 = pair[1]
        last_pinch_distance = point_a.distance_to(point_b)

func _first_two_touch_points() -> Array:
    var keys: Array = touch_points.keys()
    keys.sort()
    if keys.size() < 2:
        return []
    var point_a: Vector2 = touch_points[keys[0]]
    var point_b: Vector2 = touch_points[keys[1]]
    return [point_a, point_b]

func _camera_center() -> Vector2:
    return SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5

func _popup_is_open() -> bool:
    return popup_layer != null and popup_layer.get_child_count() > 0

func _clear_pointer_state() -> void:
    touch_points.clear()
    touch_start_points.clear()
    last_pinch_distance = 0.0
    mouse_press_position = Vector2.ZERO
    mouse_panning = false
    screen_pointer_dragged = false
    mouse_pointer_dragged = false

func _open_building(destination: StringName, instance_id: StringName = &"") -> void:
    _hide_sect_hub()
    _close_disciple_summary(true)
    _close_workforce_picker()
    _clear_popup()
    if selected_building != destination:
        workforce_advanced_visible = false
        selected_production_instance_id = &""
    selected_building = destination
    var point := _iso_actor_point(destination)
    # Validate the given ID against the destination, not merely existence.
    # Keep ordinary type-only navigation compatible with existing callers.
    if instance_id != &"" and state.buildings.has(str(instance_id)):
        var requested: BuildingState = state.buildings[str(instance_id)]
        if _sect_production_destination(requested.building_type) == destination:
            selected_production_instance_id = requested.id
    if selected_production_instance_id != &"" and state.buildings.has(str(selected_production_instance_id)):
        var exact: BuildingState = state.buildings[str(selected_production_instance_id)]
        if _sect_production_destination(exact.building_type) == destination:
            point = SectIsometricWorldV1.virtual_legacy_point(destination,exact.id)
    _set_focus_target(point, &"building", destination, _building_name(destination), true)
    _show_building_operation_panel()

func _open_notice(title_text: String, body: String) -> void:
    _close_disciple_summary(true)
    _close_building_operation_panel(true)
    super._open_notice(title_text, body)

func _bottom_action(action: String) -> void:
    if action == "home":
        _clear_popup()
        _close_disciple_summary(true)
        _close_building_operation_panel(true)
        _reset_camera(true)
        _show_sect_hub()
        return
    if action == "disciples":
        _hide_sect_hub()
        var ids: Array = state.disciples.keys()
        ids.sort()
        if ids.is_empty():
            return
        var target_id: StringName = selected_id if selected_id != &"" and state.disciples.has(selected_id) else StringName(ids[0])
        deep_restore_summary = false
        _open_disciple_deep_screen(target_id, "Thuộc tính")
        return
    super._bottom_action(action)

func _open_disciple(disciple_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    workforce_return_building_id = &""
    _hide_sect_hub()
    _close_building_operation_panel(true)
    selected_id = disciple_id
    opened_disciple_profile = true
    summary_feedback = ""
    _refresh_tasks()
    _clear_popup()

    var key := str(disciple_id)
    if actor_nodes.has(key):
        var actor: Control = actor_nodes[key] as Control
        var disciple: DiscipleState = state.disciples[disciple_id]
        var point := actor.position + actor.size * 0.5
        _set_focus_target(point, &"disciple", disciple_id, disciple.display_name, true)

    _show_disciple_summary()

func _reconcile_live_actors() -> void:
    # O2: recruitment mutates the authoritative roster after scene startup.
    # Materialize only roster IDs that do not already have a live map actor.
    var needs_install := false
    for raw_id in state.disciples.keys():
        var key := str(raw_id)
        if not actor_nodes.has(key):
            needs_install = true
            break
        var actor := actor_nodes.get(key) as Control
        if actor == null or not is_instance_valid(actor):
            needs_install = true
            break
    if needs_install:
        _install_modular_live_actors()

# Read-only map work cues from committed production snapshots. These
# labels communicate timer activity, but are not a replacement for authored
# mining/forestry/sowing animation clips.
func _active_resource_work_cues() -> Dictionary:
    var cues := {}
    if state == null:
        return cues
    for raw_building in state.buildings.values():
        if not (raw_building is BuildingState):
            continue
        var building: BuildingState = raw_building
        if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
            var raw_jobs = building.production_state.get("economy_a_jobs",[])
            if not (raw_jobs is Array):
                continue
            for job in raw_jobs:
                if job is Dictionary:
                    var worker_id := str(job.get("worker_id",""))
                    if worker_id != "":
                        cues[worker_id] = "Đang khai khoáng" if building.building_type == BuildingSystem.TYPE_MINE else "Đang khai lâm"
        elif building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
            var raw_plots = building.production_state.get("plots",[])
            if not (raw_plots is Array):
                continue
            for plot in raw_plots:
                if plot is Dictionary and StringName(plot.get("status","")) == BuildingSystem.PLOT_GROWING:
                    var worker_id := str(plot.get("assigned_worker_id",""))
                    if worker_id != "":
                        cues[worker_id] = "Linh Điền đang trồng"
    return cues

# Active work production is drawn at its exact persisted building instance,
# not at the primary instance's type-wide destination. This visual position
# never influences the simulation worker assignment, pathing or job clocks.
func _production_actor_world_foot(disciple: DiscipleState, destination: StringName, index: int, work_cues: Dictionary) -> Vector2:
    var fallback := _iso_actor_point(destination) + _actor_offset(index)
    if disciple == null or not work_cues.has(str(disciple.id)) or disciple.worksite_building_id == &"":
        return fallback
    var site := state.buildings.get(str(disciple.worksite_building_id)) as BuildingState
    if not _map_worksite_is_supported(site):
        return fallback
    return SectIsometricWorldV1.virtual_legacy_point(site.building_type,site.id) + Vector2(12,14)

func _sync_actor_positions() -> void:
    _reconcile_live_actors()
    var actual_work_cues := _active_resource_work_cues()
    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var key := str(disciple_id)
        if not actor_nodes.has(key):
            continue

        var disciple: DiscipleState = state.disciples[disciple_id]
        var previous := StringName(actor_destinations.get(key, str(SectMapPresentation.DEST_COURTYARD)))
        var destination := SectMapPresentation.destination_for_action(disciple.current_action, previous)
        actor_destinations[key] = str(destination)

        var actor: Control = actor_nodes[key] as Control
        var world_foot := _production_actor_world_foot(disciple,destination,index,actual_work_cues)
        var target := world_foot - _actor_anchor_offset(actor)
        # Sort live actors by their ground contact while keeping them below
        # all navigation and modal panels (z >= 20).
        actor.z_index = clampi(int(world_foot.y / 160.0),0,5)
        var delta := target - actor.position
        var old_tween := actor_walk_tweens.get(key) as Tween
        var continuing_walk := (
            delta.length() > 1.0
            and old_tween != null and old_tween.is_running()
            and actor_walk_targets.has(key)
            and Vector2(actor_walk_targets[key]).distance_to(target) <= 1.0
        )

        if actor is ModularDiscipleActor:
            var modular := actor as ModularDiscipleActor
            if delta.length() > 1.0 and not continuing_walk:
                # Two authored horizontal facings only. Vertical map travel
                # still moves vertically; character uses last left/right
                # visual and built-in Godot rig mirroring for left.
                var two_way := _iso_two_direction_delta(delta,modular.facing)
                var direction := DiscipleActorVisualCatalog.direction_for_delta(two_way,modular.facing)
                if (
                    modular.rig_id == DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1
                    and _stage_a_live_assets_ready()
                    and direction != modular.facing
                ):
                    FemaleStageAAssetLoader.apply_public_direction(modular,direction)
                modular.play_walk_for_delta(two_way)
            elif delta.length() <= 1.0:
                modular.sync_action(disciple.current_action)

        if delta.length() > 1.0 and not continuing_walk:
            # Do not reset a running same-destination tween on each refresh;
            # this can cause sliding/jitter and an artificially late arrival.
            # Travel remains cosmetic and does not change work or scheduler.
            if old_tween != null and old_tween.is_running():
                old_tween.kill()
            var duration := clampf(delta.length()/MAP_ACTOR_VISUAL_WALK_PX_PER_SEC,0.18,6.0)
            var tween := create_tween()
            tween.set_trans(Tween.TRANS_LINEAR)
            tween.tween_property(actor, "position", target, duration)
            actor_walk_tweens[key] = tween
            actor_walk_targets[key] = target
            tween.finished.connect(Callable(self,"_finish_actor_walk").bind(disciple_id,target))
        elif delta.length() <= 1.0:
            if old_tween != null and old_tween.is_running():
                old_tween.kill()
            actor_walk_tweens.erase(key)
            actor_walk_targets.erase(key)

        if actor_status_labels.has(key):
            var status := actor_status_labels[key] as Label
            if is_instance_valid(status):
                if actual_work_cues.has(key):
                    status.text = _compact_production_actor_status(str(actual_work_cues[key]))
                    status.visible = true
                else:
                    status.text = SectMapPresentation.action_label(disciple.current_action)
                    if actor is ModularDiscipleActor:
                        status.visible = (actor as ModularDiscipleActor).current_clip in [
                            DiscipleActorVisualCatalog.CLIP_MINING,
                            DiscipleActorVisualCatalog.CLIP_FORGING,
                            DiscipleActorVisualCatalog.CLIP_WORK
                        ]

    if focused_kind == &"disciple":
        _refresh_focused_disciple_point()
    _refresh_disciple_summary_content()
    _refresh_building_operation_content()
    _refresh_living_cues()

# Space for characters is intentionally narrow. Full job text lives in
# exact-ID production badges and the workforce panel; this is just a tag.
func _compact_production_actor_status(full_status: String) -> String:
    match full_status:
        "Đang khai khoáng": return "Đang ở Mỏ"
        "Đang khai lâm": return "Đang ở Lâm"
        "Linh Điền đang trồng": return "Đang trồng"
        _: return full_status

func _finish_actor_walk(disciple_id: StringName, expected_target: Vector2) -> void:
    actor_walk_tweens.erase(str(disciple_id))
    actor_walk_targets.erase(str(disciple_id))
    var actor := actor_nodes.get(str(disciple_id)) as ModularDiscipleActor
    if actor == null or not is_instance_valid(actor) or actor.position.distance_to(expected_target) > 1.0:
        return
    var disciple := state.disciples.get(disciple_id) as DiscipleState
    if disciple != null:
        actor.sync_action(disciple.current_action)

func _actor_anchor_offset(actor: Control) -> Vector2:
    if actor is ModularDiscipleActor:
        return DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
    return Vector2(30.0, 30.0)

func _stage_a_live_assets_ready() -> bool:
    return FemaleStageAAssetLoader.assets_available(&"right")

func _iso_two_direction_delta(delta: Vector2, old_facing: StringName) -> Vector2:
    # Facial orientation is independent of movement vector/position tween.
    var x := delta.x
    if absf(x) <= 0.01:
        x = -1.0 if old_facing == &"left" else 1.0
    return Vector2(-1.0 if x < 0.0 else 1.0,0.0)

func _install_modular_live_actors() -> void:
    modular_live_actor_ids.clear()
    if female_motion_library == null:
        return

    var female_assets_ready := _stage_a_live_assets_ready()
    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var key := str(disciple_id)
        var disciple: DiscipleState = state.disciples[disciple_id]
        if actor_nodes.has(key) and actor_nodes[key] is ModularDiscipleActor:
            modular_live_actor_ids[key] = true
            continue

        var old_actor: Control = actor_nodes.get(key) as Control
        var replacing_tween := actor_walk_tweens.get(key) as Tween
        if replacing_tween != null and replacing_tween.is_running():
            replacing_tween.kill()
        actor_walk_tweens.erase(key)
        actor_walk_targets.erase(key)
        if old_actor != null and is_instance_valid(old_actor):
            if old_actor.get_parent() != null:
                old_actor.get_parent().remove_child(old_actor)
            old_actor.queue_free()

        var destination := StringName(actor_destinations.get(key, str(_initial_destination(disciple))))
        actor_destinations[key] = str(destination)

        var actor := ModularDiscipleActor.new()
        actor.name = "ModularDisciple_%s" % key
        actor.configure(disciple)
        actor.set_animation_library(female_motion_library)
        if actor.rig_id == DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1 and female_assets_ready:
            FemaleStageAAssetLoader.apply_public_direction(actor, &"right")
        # Deterministic presentation-only Source A selection. The pool admits
        # only verified, imported art of the correct body/sex family.
        var baked_scene := DiscipleSourceAVisualPool.scene_for_disciple(disciple)
        if baked_scene != null and not actor.production_body_active():
            actor.set_baked_visual(baked_scene)
        actor.sync_action(disciple.current_action)
        actor.actor_pressed.connect(Callable(self, "_open_disciple"))
        var world_foot := _iso_actor_point(destination) + _actor_offset(index)
        actor.position = world_foot - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
        actor.z_index = clampi(int(world_foot.y / 160.0),0,5)
        map_layer.add_child(actor)

        actor_nodes[key] = actor
        actor_status_labels[key] = actor.status_label
        modular_live_actor_ids[key] = true

func _build_building_operation_panel() -> void:
    building_operation_panel = Panel.new()
    building_operation_panel.name = "BuildingOperationPanel"
    building_operation_panel.position = Vector2(824, 80)
    building_operation_panel.size = Vector2(440, 552)
    building_operation_panel.z_index = 60
    building_operation_panel.visible = false
    building_operation_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    building_operation_panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 14))
    add_child(building_operation_panel)

    building_operation_title = _label(building_operation_panel, "", Vector2(18, 14), Vector2(350, 34), 22)
    building_operation_title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    var subtitle := _label(building_operation_panel, "Tình hình vận hành", Vector2(18, 48), Vector2(350, 22), 11)
    subtitle.name = "BuildingOperationSubtitle"
    subtitle.add_theme_color_override("font_color", Color(0.22, 0.20, 0.16, 0.72))

    var close := Button.new()
    close.name = "CloseBuildingOperation"
    close.text = "×"
    close.position = Vector2(388, 12)
    close.size = Vector2(36, 34)
    close.add_theme_font_size_override("font_size", 20)
    close.add_theme_stylebox_override("normal", _style(Color(0.86, 0.80, 0.66, 1.0), INK, 1, 16))
    close.pressed.connect(Callable(self, "_close_building_operation_panel").bind(true))
    building_operation_panel.add_child(close)

    var separator := HSeparator.new()
    separator.name = "BuildingOperationSeparator"
    separator.position = Vector2(14, 78)
    separator.size = Vector2(412, 2)
    building_operation_panel.add_child(separator)

    # Above-the-fold actual production timer, visible without scrolling.
    # The backing value is recomputed from real saved jobs/plots on refresh.
    building_operation_progress_caption = Label.new()
    building_operation_progress_caption.name = "ProductionProgressCaption"
    building_operation_progress_caption.position = Vector2(16, 84)
    building_operation_progress_caption.size = Vector2(PRODUCTION_CONTENT_WIDTH,40)
    building_operation_progress_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    building_operation_progress_caption.add_theme_font_size_override("font_size",13)
    building_operation_progress_caption.add_theme_color_override("font_color",INK)
    building_operation_progress_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
    building_operation_progress_caption.visible = false
    building_operation_panel.add_child(building_operation_progress_caption)

    building_operation_progress_bar = ProgressBar.new()
    building_operation_progress_bar.name = "ProductionProgressBar"
    building_operation_progress_bar.position = Vector2(16,127)
    building_operation_progress_bar.size = Vector2(PRODUCTION_CONTENT_WIDTH,13)
    building_operation_progress_bar.min_value = 0.0
    building_operation_progress_bar.max_value = 100.0
    building_operation_progress_bar.show_percentage = false
    building_operation_progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    building_operation_progress_bar.add_theme_stylebox_override("background",_style(Color(0.80,0.79,0.70),INK,1,5))
    building_operation_progress_bar.add_theme_stylebox_override("fill",_style(JADE_DARK,JADE_DARK,0,5))
    building_operation_progress_bar.visible = false
    building_operation_panel.add_child(building_operation_progress_bar)

    var scroll := ScrollContainer.new()
    scroll.name = "BuildingOperationScroll"
    scroll.position = Vector2(14, 92)
    scroll.size = Vector2(412, 442)
    building_operation_panel.add_child(scroll)

    building_operation_content = VBoxContainer.new()
    building_operation_content.name = "BuildingOperationContent"
    building_operation_content.custom_minimum_size = Vector2(384, 0)
    building_operation_content.add_theme_constant_override("separation", 10)
    scroll.add_child(building_operation_content)

    building_operation_body = Label.new()
    building_operation_body.name = "BuildingOperationBody"
    building_operation_body.custom_minimum_size = Vector2(384, 0)
    building_operation_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    building_operation_body.add_theme_font_size_override("font_size", 13)
    building_operation_body.add_theme_color_override("font_color", INK)
    building_operation_content.add_child(building_operation_body)

    building_management_container = VBoxContainer.new()
    building_management_container.name = "BuildingManagementControls"
    building_management_container.custom_minimum_size = Vector2(384, 0)
    building_management_container.add_theme_constant_override("separation", 7)
    building_operation_content.add_child(building_management_container)

func _building_operation_is_open() -> bool:
    return building_operation_panel != null and is_instance_valid(building_operation_panel) and building_operation_panel.visible

func _show_building_operation_panel() -> void:
    if building_operation_panel == null or selected_building == &"":
        return
    building_operation_panel.visible = true
    if camera_controls_panel != null:
        camera_controls_panel.visible = false
    if camera_hint != null:
        camera_hint.visible = false
    _refresh_building_operation_content()
    _refresh_map_worksite_cues()

func _hide_building_operation_panel() -> void:
    if building_operation_panel != null:
        building_operation_panel.visible = false
    if camera_controls_panel != null and not _disciple_summary_is_open():
        camera_controls_panel.visible = true
    if camera_hint != null and not _disciple_summary_is_open():
        camera_hint.visible = true

func _close_building_operation_panel(clear_selection: bool = true) -> void:
    _close_workforce_picker()
    _hide_building_operation_panel()
    building_management_feedback = ""
    if not clear_selection:
        return
    selected_building = &""
    # Closing the panel also ends its selection. Otherwise the previous
    # Mine/Forest/Field badge stays "selected" on the map indefinitely.
    selected_production_instance_id = &""
    if iso_world != null:
        _refresh_map_worksite_cues()
    if focused_kind == &"building":
        focused_kind = &""
        focused_id = &""
        focused_label = ""
        has_focus_target = false
        if focus_marker != null:
            focus_marker.visible = false
        if focus_target_button != null:
            focus_target_button.disabled = true
        _refresh_focus_readout()

func _refresh_building_operation_content() -> void:
    if not _building_operation_is_open() or selected_building == &"":
        return
    building_operation_title.text = _building_name(selected_building)
    var subtitle := building_operation_panel.get_node("BuildingOperationSubtitle") as Label
    var focused_work_type := _workforce_building_type()
    var focused_site := _selected_resource_instance(focused_work_type) if focused_work_type != &"" else null
    if focused_site != null:
        # Show which of several identical Mine/Forest/Field sites is open.
        subtitle.text = "ID: %s · Cấp %d" % [str(focused_site.id),focused_site.level]
        subtitle.tooltip_text = subtitle.text
        subtitle.clip_text = true
    else:
        subtitle.text = "Tình hình vận hành"
        subtitle.tooltip_text = ""
    var feedback := ""
    if building_management_feedback != "":
        feedback = "\n\n%s" % building_management_feedback
    var workforce_target := _workforce_building_type()
    _layout_building_operation_panel(workforce_target != &"")
    _refresh_production_progress_header(workforce_target)
    building_operation_body.text = (
        _workforce_operation_summary(workforce_target) if workforce_target != &""
        else _building_operation_text(selected_building)
    ) + feedback
    # The 3 production panels must expose actions above the fold on 1280x720.
    if workforce_target != &"":
        building_operation_body.custom_minimum_size.y = 0
    elif selected_building == SectMapPresentation.DEST_BODY_TRAINING:
        building_operation_body.custom_minimum_size.y = 248
    elif selected_building == SectMapPresentation.DEST_GUIDANCE:
        building_operation_body.custom_minimum_size.y = 150
    elif selected_building == SectMapPresentation.DEST_SPIRIT_FIELD:
        building_operation_body.custom_minimum_size.y = 220
    else:
        building_operation_body.custom_minimum_size.y = 0
    _rebuild_building_management_controls()
    _ensure_disabled_controls_readable(building_management_container)

# These controls are opaque even when disabled; use readable dark labels,
# never the white-on-middle-gray text observed in the owner's visual audit.
func _ensure_disabled_controls_readable(root_node: Node) -> void:
    for child in root_node.get_children():
        if child is Button:
            var button := child as Button
            button.add_theme_color_override("font_disabled_color",INK)
            button.add_theme_stylebox_override(
                "disabled",_style(Color(0.84,0.83,0.75),Color(0.46,0.44,0.37),1,8)
            )
        _ensure_disabled_controls_readable(child)

func _refresh_production_progress_header(building_type: StringName) -> void:
    if building_operation_progress_caption == null or building_operation_progress_bar == null:
        return
    var shown := building_type != &""
    building_operation_progress_caption.visible = shown
    building_operation_progress_bar.visible = shown
    if not shown:
        return
    var building := _selected_resource_instance(building_type)
    if building == null:
        building_operation_progress_caption.text = "Chưa có công trình · chọn công trình trước"
        building_operation_progress_bar.value = 0.0
        return
    var buildings := BuildingSystem.new()
    if building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var jobs := buildings.resource_timer_jobs(building)
        if not jobs.is_empty() and jobs[0] is Dictionary:
            var job: Dictionary = jobs[0]
            var start_tick := int(job.get("started_tick",state.tick))
            var finish_tick := int(job.get("finish_tick",state.tick))
            var total := maxi(1,finish_tick-start_tick)
            var elapsed := clampi(state.tick-start_tick,0,total)
            var resource_name := ResourceRegistry.new().display_name(
                StringName(job.get("resource_id",""))
            )
            building_operation_progress_caption.text = (
                "%s ×%d mẻ · đã thu %d\n%d/%d phút · %s" % [
                    resource_name,maxi(0,int(job.get("output_quantity",0))),
                    maxi(0,int(building.metrics.get("units_produced",0))),
                    elapsed,total,
                    "Chờ scheduler kết toán" if finish_tick <= state.tick
                    else "Còn %d phút" % (finish_tick-state.tick)
                ]
            )
            building_operation_progress_bar.value = 100.0*float(elapsed)/float(total)
        else:
            var plan := buildings.selected_resource_production_plan(building)
            building_operation_progress_caption.text = "Đã thu %d · %d mẻ\nMẻ mới: %s ×%d" % [
                maxi(0,int(building.metrics.get("units_produced",0))),
                maxi(0,int(building.metrics.get("production_batches",0))),
                ResourceRegistry.new().display_name(production_plan_registry.output_resource_id(plan)),
                production_plan_registry.scaled_yield(plan,building.level)
            ]
            building_operation_progress_bar.value = 0.0
        return
    # Linh Điền has several concurrent plots. Show the nearest pending
    # harvest explicitly, not a made-up overall progress percentage.
    var nearest: Dictionary = {}
    var active_count := 0
    var snapshots = building.production_state.get("plots",[])
    if snapshots is Array:
        for raw in snapshots:
            if not (raw is Dictionary):
                continue
            var plot: Dictionary = raw
            if StringName(plot.get("status","")) != BuildingSystem.PLOT_GROWING:
                continue
            active_count += 1
            if nearest.is_empty() or int(plot.get("finish_tick",0)) < int(nearest.get("finish_tick",0)):
                nearest = plot
    if nearest.is_empty():
        building_operation_progress_caption.text = "Chưa trồng · đã nhập %d\nChọn đệ tử và bấm Bắt đầu" % maxi(0,int(building.metrics.get("units_produced",0)))
        building_operation_progress_bar.value = 0.0
        return
    var start_tick := int(nearest.get("started_tick",state.tick))
    var finish_tick := int(nearest.get("finish_tick",state.tick))
    var total := maxi(1,finish_tick-start_tick)
    var elapsed := clampi(state.tick-start_tick,0,total)
    building_operation_progress_caption.text = "%d ô · %s ×%d · đã nhập %d\n%d/%d phút · %s" % [
        active_count,
        spirit_crop_registry.display_name(StringName(nearest.get("crop_id",""))),
        maxi(0,int(nearest.get("routine_yield",0))),
        maxi(0,int(building.metrics.get("units_produced",0))),elapsed,total,
        "Chờ kết toán" if finish_tick <= state.tick
        else "Còn %d phút" % (finish_tick-state.tick)
    ]
    building_operation_progress_bar.value = 100.0*float(elapsed)/float(total)

func _layout_building_operation_panel(compact: bool) -> void:
    var width := PRODUCTION_PANEL_WIDTH if compact else 440.0
    var content_width := PRODUCTION_CONTENT_WIDTH if compact else 384.0
    building_operation_panel.position.x = 1280.0-width-16.0
    building_operation_panel.size.x = width
    building_operation_title.size.x = width-76.0
    var subtitle := building_operation_panel.get_node("BuildingOperationSubtitle") as Label
    subtitle.size.x = width-76.0
    var close := building_operation_panel.get_node("CloseBuildingOperation") as Button
    close.position.x = width-54.0
    close.size = Vector2(44,44)
    var separator := building_operation_panel.get_node("BuildingOperationSeparator") as HSeparator
    separator.size.x = width-28.0
    var scroll := building_operation_panel.get_node("BuildingOperationScroll") as ScrollContainer
    scroll.size.x = width-28.0
    scroll.position.y = 150.0 if compact else 92.0
    scroll.size.y = 384.0 if compact else 442.0
    building_operation_progress_caption.size.x = content_width
    building_operation_progress_bar.size.x = content_width
    building_operation_content.custom_minimum_size.x = content_width
    building_operation_body.custom_minimum_size.x = content_width
    building_management_container.custom_minimum_size.x = content_width

func _rebuild_building_management_controls() -> void:
    if building_management_container == null:
        return
    for child in building_management_container.get_children():
        building_management_container.remove_child(child)
        child.queue_free()

    match selected_building:
        SectMapPresentation.DEST_MAIN_HALL:
            _build_main_hall_policy_controls()
        SectMapPresentation.DEST_WAREHOUSE:
            _build_economy_a_market_controls()
        SectMapPresentation.DEST_MINE:
            _build_workforce_card(BuildingSystem.TYPE_MINE,WorkforceSystem.PROF_MINING)
            _build_work_management(WorkforceSystem.PROF_MINING, &"mining_crew", "Đội Khai Khoáng", "Khai khoáng")
            _build_mine_upgrade_control()
        SectMapPresentation.DEST_LINH_FOREST:
            _build_workforce_card(BuildingSystem.TYPE_LINH_FOREST,WorkforceSystem.PROF_FORESTRY)
            _build_work_management(WorkforceSystem.PROF_FORESTRY, &"forestry_crew", "Đội Lâm Nghiệp", "Thu hoạch")
        SectMapPresentation.DEST_ALCHEMY_HALL:
            _build_alchemy_management()
        SectMapPresentation.DEST_SPIRIT_FIELD:
            _build_workforce_card(BuildingSystem.TYPE_SPIRIT_FIELD,WorkforceSystem.PROF_HERBALISM)
            _build_spirit_field_management()
        SectMapPresentation.DEST_FORGE:
            _build_work_management(WorkforceSystem.PROF_FORGING, &"forge_hall", "Luyện Khí Đường", "Luyện khí")
            _build_forge_craft_controls()
        SectMapPresentation.DEST_CULTIVATION:
            _build_direct_order_management(WorkforceSystem.COMMAND_CULTIVATE, "", "Gọi tu luyện", false)
        SectMapPresentation.DEST_BODY_TRAINING:
            _build_body_training_management()
        SectMapPresentation.DEST_RESIDENCE:
            _build_direct_order_management(WorkforceSystem.COMMAND_REST, "", "Gọi nghỉ", false)
            _build_lodging_expansion_control()
        SectMapPresentation.DEST_MEDICINE:
            _build_needs_priority_controls("ƯU TIÊN HẬU CẦN")
            _build_healing_pill_controls()
        SectMapPresentation.DEST_GUIDANCE:
            _build_guidance_recruitment_controls()
        SectMapPresentation.DEST_GATE:
            _build_direct_order_management(WorkforceSystem.COMMAND_RETURN_SECT, "", "Triệu hồi", true)
        _:
            pass
    if _workforce_building_type() != &"":
        _fold_workforce_legacy_controls()


# GUI-WORKFORCE V1: the visible compact card is presentation only. All
# occupancy, jobs, cancellation and salary come from the canonical systems.
func _workforce_building_type() -> StringName:
    match selected_building:
        SectMapPresentation.DEST_MINE:
            return BuildingSystem.TYPE_MINE
        SectMapPresentation.DEST_LINH_FOREST:
            return BuildingSystem.TYPE_LINH_FOREST
        SectMapPresentation.DEST_SPIRIT_FIELD:
            return BuildingSystem.TYPE_SPIRIT_FIELD
        _:
            return &""

func _workforce_profession(building_type: StringName) -> StringName:
    match building_type:
        BuildingSystem.TYPE_MINE:
            return WorkforceSystem.PROF_MINING
        BuildingSystem.TYPE_LINH_FOREST:
            return WorkforceSystem.PROF_FORESTRY
        BuildingSystem.TYPE_SPIRIT_FIELD:
            return WorkforceSystem.PROF_HERBALISM
        _:
            return &""

func _workforce_occupants(building: BuildingState) -> Array[StringName]:
    if building == null:
        var none: Array[StringName] = []
        return none
    return BuildingSystem.new().assigned_worker_ids(state,building)

func _selected_resource_instance(building_type: StringName) -> BuildingState:
    var buildings := BuildingSystem.new()
    if selected_production_instance_id != &"" and state.buildings.has(str(selected_production_instance_id)):
        var selected: BuildingState = state.buildings[str(selected_production_instance_id)]
        if selected.building_type == building_type:
            return selected
    return buildings.primary_building(state,building_type)

func _choose_resource_instance(index: int, building_type: StringName, ids: Array[StringName]) -> void:
    if index < 0 or index >= ids.size() or not state.buildings.has(str(ids[index])):
        return
    var chosen: BuildingState = state.buildings[str(ids[index])]
    if chosen.building_type != building_type:
        return
    selected_production_instance_id = chosen.id
    workforce_advanced_visible = false
    building_management_feedback = ""
    var destination := _sect_production_destination(building_type)
    if destination != &"":
        _set_focus_target(
            SectIsometricWorldV1.virtual_legacy_point(destination,chosen.id),
            &"building",destination,_building_name(destination),true
        )
    _refresh_building_operation_content()

func _build_resource_instance_chooser(building_type: StringName) -> void:
    var instances := ResourceBuildingExpansionPolicyV2.existing_instances(state,building_type)
    if instances.is_empty():
        return
    var ids: Array[StringName] = []
    var select := OptionButton.new()
    select.name = "WorkforceInstanceChooser"
    select.custom_minimum_size = Vector2(PRODUCTION_CONTENT_WIDTH,46)
    select.add_theme_font_size_override("font_size",14)
    var active := _selected_resource_instance(building_type)
    var selected_index := 0
    for instance in instances:
        ids.append(instance.id)
        select.add_item("%s · Lv%d · %s" % [
            str(instance.id),instance.level,
            "Có người" if not BuildingSystem.new().assigned_worker_ids(state,instance).is_empty() else "Chưa giao"
        ])
        if active != null and active.id == instance.id:
            selected_index = ids.size()-1
    select.select(selected_index)
    select.disabled = instances.size() < 2
    select.tooltip_text = "Mỗi công trình dùng đúng ID instance và một đệ tử; không tạo thêm công trình."
    select.item_selected.connect(Callable(self,"_choose_resource_instance").bind(building_type,ids))
    building_management_container.add_child(select)

func _workforce_operation_summary(building_type: StringName) -> String:
    var buildings := BuildingSystem.new()
    var building := _selected_resource_instance(building_type)
    if building == null:
        return "Công trình chưa có trong tông môn."
    var assigned := _workforce_occupants(building)
    var who: String = "Chưa giao" if assigned.is_empty() else (
        state.disciples[assigned[0]].display_name if state.disciples.has(assigned[0])
        else str(assigned[0])
    )
    if assigned.size() > 1:
        who = "Lỗi dữ liệu: nhiều đệ tử cùng một công trình"
    var output := ""
    if building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var plan := buildings.selected_resource_production_plan(building)
        var rid := production_plan_registry.output_resource_id(plan)
        var product := ResourceRegistry.new().display_name(rid)
        var units := production_plan_registry.scaled_yield(plan,building.level)
        output = "Sản phẩm: %s · mẻ dự kiến %d\nKho: %s" % [product,units,_warehouse_pair(rid,true)]
        if assigned.size() == 1:
            var running: Dictionary = {}
            for raw_job in buildings.resource_timer_jobs(building):
                if raw_job is Dictionary and str(raw_job.get("worker_id","")) == str(assigned[0]):
                    running = raw_job
                    break
            if not running.is_empty():
                output = "Đang làm: %s ×%d · +%.0f EXP nghề\nCòn %d phút · Kho: %s" % [
                    ResourceRegistry.new().display_name(StringName(running.get("resource_id",""))),
                    int(running.get("output_quantity",0)),float(running.get("profession_xp_gain",0.0)),
                    maxi(0,int(running.get("finish_tick",state.tick))-state.tick),_warehouse_pair(rid,true)
                ]
    else:
        var growing := 0
        var plots := buildings.spirit_field_plots(state,building)
        for raw_plot in plots:
            if raw_plot is Dictionary and StringName(raw_plot.get("status","")) == BuildingSystem.PLOT_GROWING:
                growing += 1
        output = "Đang trồng: %d/%d ô · Kho Linh Cốc: %s" % [
            growing,plots.size(),_warehouse_pair(&"linh_coc",true)
        ]
    return "%s · Lv%d · 1 đệ tử / công trình\nPhụ trách: %s\n%s" % [str(building.id),building.level,who,output]

# Read-only operations ledger from the already-saved job / plot snapshots.
# UI never owns another timer, clock, warehouse, work slot or payout.
func _workforce_live_production_lines(building: BuildingState) -> Array[String]:
    var lines: Array[String] = []
    if building == null:
        return lines
    var buildings := BuildingSystem.new()
    if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var jobs := buildings.resource_timer_jobs(building)
        for raw_job in jobs:
            if not (raw_job is Dictionary):
                continue
            var job: Dictionary = raw_job
            var resource_id := StringName(job.get("resource_id",""))
            var output := maxi(int(job.get("output_quantity",0)),0)
            var started := int(job.get("started_tick",state.tick))
            var finish := int(job.get("finish_tick",state.tick))
            var total := maxi(1,finish-started)
            var elapsed := clampi(state.tick-started,0,total)
            lines.append("%s ×%d · %d/%d phút (%.0f%%)" % [
                ResourceRegistry.new().display_name(resource_id),output,elapsed,total,
                100.0*float(elapsed)/float(total)
            ])
            lines.append("Còn %d phút · Kho: %s" % [
                maxi(0,finish-state.tick),_warehouse_pair(resource_id,true)
            ])
        if lines.is_empty():
            var plan := buildings.selected_resource_production_plan(building)
            var rid := production_plan_registry.output_resource_id(plan)
            var batch := production_plan_registry.scaled_yield(plan,building.level)
            lines.append("Chưa có mẻ · kế hoạch %s ×%d/mẻ" % [
                ResourceRegistry.new().display_name(rid),batch
            ])
        return lines
    if building.building_type != BuildingSystem.TYPE_SPIRIT_FIELD:
        return lines
    var plots := buildings.spirit_field_plots(state,building)
    for raw_plot in plots:
        if not (raw_plot is Dictionary):
            continue
        var plot: Dictionary = raw_plot
        var plot_id := str(plot.get("plot_id","?"))
        if StringName(plot.get("status","")) != BuildingSystem.PLOT_GROWING:
            lines.append("%s · Trống" % plot_id)
            continue
        var crop_id := StringName(plot.get("crop_id",""))
        var started := int(plot.get("started_tick",state.tick))
        var finish := int(plot.get("finish_tick",state.tick))
        var total := maxi(1,finish-started)
        var elapsed := clampi(state.tick-started,0,total)
        var base_units := maxi(int(plot.get("routine_yield",0)),0)
        # Routine yield is already snapped at plant time. Lucky outcomes are
        # deliberately NOT promised before the scheduler resolves the plot.
        lines.append("%s · %s ×%d thường · còn %d phút (%.0f%%)" % [
            plot_id,spirit_crop_registry.display_name(crop_id),base_units,
            maxi(0,finish-state.tick),100.0*float(elapsed)/float(total)
        ])
    return lines

# Explain every disabled Start in the same operation panel. Do not preempt
# Workforce/BuildingSystem authority: their real command remains the gate.
func _workforce_start_block_reason(building: BuildingState, worker_id: StringName) -> String:
    if building == null or worker_id == &"" or not state.disciples.has(worker_id):
        return "Chọn một đệ tử phụ trách trước."
    var actor: DiscipleState = state.disciples[worker_id]
    var buildings := BuildingSystem.new()
    if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        if not buildings.resource_timer_jobs(building).is_empty():
            return "Mẻ đang chạy; chờ hoàn thành hoặc dùng Hủy mẻ."
        if state.sect.economy_a_enabled and DiscipleRealmProgressV2.owns_v2_progression(actor):
            var plan := buildings.selected_resource_production_plan(building)
            if production_plan_registry.has(plan):
                var resource_id := production_plan_registry.output_resource_id(plan)
                var units := production_plan_registry.scaled_yield(plan,building.level)
                var stock := WarehouseSystem.new().quantity(state,resource_id)
                var target := mini(units*10,WarehouseSystem.MAX_SAFE_STACK)
                if stock >= target:
                    return "Kho đã đạt mục tiêu %d %s; đổi kế hoạch hoặc dùng nguyên liệu trước." % [
                        target,ResourceRegistry.new().display_name(resource_id)
                    ]
                if units > WarehouseSystem.MAX_SAFE_STACK-stock:
                    return "Kho gần giới hạn lưu trữ an toàn; chưa thể bắt đầu mẻ này."
    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty():
        return "Đệ tử đang xuất môn hoặc tham gia PvE."
    if not actor.work_cycle_state.is_empty():
        return "Đệ tử đang hoàn thành lượt làm việc cũ."
    var other_timer := buildings.active_resource_timer_for_worker(state,worker_id)
    if not other_timer.is_empty():
        return "Đệ tử đang có mẻ sản xuất ở công trình khác."
    if buildings.disciple_has_active_timed_recipe(state,worker_id):
        return "Đệ tử đang luyện chế hoặc sản xuất có hẹn giờ."
    if DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor):
        return "Đệ tử đang giữ lượt Rèn Thân."
    var profession := _workforce_profession(building.building_type)
    if profession == &"":
        return "Không có nghề sản xuất hợp lệ."
    if building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
        var plots := buildings.spirit_field_plots(state,building)
        var has_empty := false
        for raw_plot in plots:
            if raw_plot is Dictionary and StringName(raw_plot.get("status","")) == BuildingSystem.PLOT_EMPTY:
                has_empty = true
                break
        if not has_empty:
            return "Đã đủ ô Linh Điền; chờ thu hoạch để gieo tiếp."
        if not buildings.work_available(state,profession,actor):
            return "Chưa có cây hợp lệ: kiểm tra Linh Thạch, chính sách và mục tiêu kho."
    elif not buildings.work_available(state,profession,actor):
        return "Chưa đủ điều kiện làm việc: kiểm tra công trình, vật liệu và trạng thái."
    # The pending command remains owned by the scheduler; a duplicate Start
    # must not be advertised as a new job while another order is queued.
    if not actor.direct_command.is_empty():
        var kind := StringName(actor.direct_command.get("kind",""))
        var target := str(actor.direct_command.get("target",""))
        if kind != WorkforceSystem.COMMAND_WORK or target != str(profession):
            return "Đệ tử đã có lệnh khác chờ xử lý."
    return ""

func _workforce_worker_status(building: BuildingState, worker_id: StringName) -> String:
    var buildings := BuildingSystem.new()
    var timer := buildings.active_resource_timer_for_worker(state,worker_id)
    if not timer.is_empty():
        var rid := StringName(timer.get("resource_id",""))
        return "Mẻ %s · %d phút còn lại" % [
            str(rid),maxi(0,int(timer.get("finish_tick",state.tick))-state.tick)
        ]
    if building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
        var growing := 0
        var latest := 0
        for raw_plot in buildings.spirit_field_plots(state,building):
            if raw_plot is Dictionary and str(raw_plot.get("status","")) == str(BuildingSystem.PLOT_GROWING) and str(raw_plot.get("assigned_worker_id","")) == str(worker_id):
                growing += 1
                latest = maxi(latest,int(raw_plot.get("finish_tick",state.tick))-state.tick)
        if growing > 0:
            return "%d ô đang trồng · hoàn thành muộn nhất %d phút" % [growing,latest]
    if state.disciples.has(worker_id):
        var actor: DiscipleState = state.disciples[worker_id]
        if not actor.work_cycle_state.is_empty():
            return "Đang xử lý lượt cũ: %s" % str(actor.work_cycle_state.get("phase",""))
        if not actor.direct_command.is_empty():
            return "Đã nhận lệnh: %s" % str(actor.direct_command.get("kind",""))
    return "Sẵn sàng nhận công việc"

func _workforce_ui_button(parent: Control, node_name: String, label_text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.name = node_name
    button.text = label_text
    button.custom_minimum_size = Vector2(84,44)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size",13)
    button.add_theme_color_override("font_color",Color(0.97,0.95,0.86))
    button.add_theme_color_override("font_hover_color",Color(1.0,0.98,0.89))
    button.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,8))
    button.add_theme_stylebox_override("hover",_style(JADE_DARK.lightened(0.13),GOLD,2,8))
    button.add_theme_stylebox_override("disabled",_style(Color(0.69,0.67,0.58),Color(0.49,0.47,0.40),1,8))
    button.pressed.connect(callback)
    parent.add_child(button)
    return button

func _build_workforce_card(building_type: StringName, profession_id: StringName) -> void:
    var buildings := BuildingSystem.new()
    var building := _selected_resource_instance(building_type)
    _add_management_section_label("ĐỆ TỬ PHỤ TRÁCH")
    if building == null:
        _add_management_section_label("Chưa có công trình để phân công.")
        return
    var assigned := _workforce_occupants(building)
    var owned := assigned.size() == 1 and state.disciples.has(assigned[0])
    var worker_id: StringName = assigned[0] if owned else &""
    var owner_row := HBoxContainer.new()
    owner_row.name = "WorkforceOwnerRow"
    owner_row.custom_minimum_size = Vector2(PRODUCTION_CONTENT_WIDTH,48)
    owner_row.add_theme_constant_override("separation",8)
    building_management_container.add_child(owner_row)
    if owned:
        var avatar := _disciple_avatar_button(state.disciples[worker_id],48)
        avatar.name = "WorkforceOwnerAvatar"
        avatar.tooltip_text = "Xem hồ sơ %s" % state.disciples[worker_id].display_name
        avatar.pressed.connect(Callable(self,"_open_workforce_owner").bind(worker_id,building.id))
        owner_row.add_child(avatar)
    var label := Label.new()
    label.name = "WorkforceOwner"
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(PRODUCTION_CONTENT_WIDTH-56.0 if owned else PRODUCTION_CONTENT_WIDTH,40)
    label.add_theme_font_size_override("font_size",15)
    label.add_theme_color_override("font_color",INK)
    if assigned.size() > 1:
        label.text = "Dữ liệu phân công không hợp lệ: %d người." % assigned.size()
    elif owned:
        var actor: DiscipleState = state.disciples[worker_id]
        var level := workforce.profession_level_for_state(state,actor,profession_id)
        label.text = "%s · Nghề Lv%d\n%s" % [
            actor.display_name,level,_workforce_worker_status(building,worker_id)
        ]
    else:
        label.text = "Chưa có đệ tử. Chọn người để bắt đầu."
    owner_row.add_child(label)
    _build_resource_instance_chooser(building_type)
    var buttons := HBoxContainer.new()
    buttons.name = "WorkforceQuickActions"
    buttons.custom_minimum_size = Vector2(PRODUCTION_CONTENT_WIDTH,48)
    buttons.add_theme_constant_override("separation",7)
    building_management_container.add_child(buttons)
    var choose := _workforce_ui_button(buttons,"WorkforceChoose","Chọn / Đổi",Callable(self,"_open_workforce_picker").bind(building.id))
    choose.disabled = assigned.size() > 1
    var can_plant_more := owned and building_type == BuildingSystem.TYPE_SPIRIT_FIELD and buildings.disciple_has_active_spirit_plot(state,worker_id,building)
    var start := _workforce_ui_button(buttons,"WorkforceStart","Gieo ô tiếp" if can_plant_more else "Bắt đầu",Callable(self,"_workforce_start").bind(building.id))
    var block_reason := _workforce_start_block_reason(building,worker_id)
    start.disabled = not owned or block_reason != ""
    start.tooltip_text = (
        block_reason if block_reason != "" else
        "Gửi lệnh đến scheduler; hàng chỉ nhập kho sau khi hoàn tất thực tế."
    )
    var active_timer := false
    if owned and building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        for raw_job in buildings.resource_timer_jobs(building):
            if raw_job is Dictionary and str(raw_job.get("worker_id","")) == str(worker_id):
                active_timer = true
                break
    var remove := _workforce_ui_button(buttons,"WorkforceRemove","Hủy mẻ" if active_timer else "Gỡ người",
        Callable(self,"_workforce_cancel_timer").bind(building.id,worker_id) if active_timer else Callable(self,"_workforce_remove").bind(building.id))
    remove.disabled = not owned or (not active_timer and (buildings.disciple_has_active_timed_recipe(state,worker_id) or buildings.disciple_has_active_spirit_plot(state,worker_id)))
    if remove.disabled and owned:
        remove.tooltip_text = "Lượt sản xuất đang chạy; không thể gỡ người khi chưa kết thúc."
    # Progress is visible immediately after the 44px touch actions, and is
    # recomputed from saved snapshots whenever the live UI refreshes.
    var live_lines := _workforce_live_production_lines(building)
    var live_label := Label.new()
    live_label.name = "WorkforceLiveProgress"
    live_label.custom_minimum_size = Vector2(PRODUCTION_CONTENT_WIDTH,0)
    live_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    live_label.add_theme_font_size_override("font_size",12)
    live_label.add_theme_color_override("font_color",INK)
    live_label.text = "TIẾN ĐỘ THỰC TẾ\n" + "\n".join(live_lines)
    building_management_container.add_child(live_label)
    if not state.sect.economy_a_enabled and building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var enable := _workforce_ui_button(building_management_container,"WorkforceEnableTimer","Bật chu kỳ sản xuất",Callable(self,"_workforce_enable_timer"))
        enable.custom_minimum_size = Vector2(PRODUCTION_CONTENT_WIDTH,44)
        enable.tooltip_text = "Dùng chu kỳ sản xuất thật từ Economy-A và scheduler hiện có."

func _workforce_enable_timer() -> void:
    var result := EconomySystem.new().enable_v1(state)
    building_management_feedback = "Đã bật timer; dùng chung scheduler và kho." if bool(result.get("ok",false)) else "Không thể bật timer: %s" % str(result.get("reason",""))
    _refresh_building_operation_content()

func _workforce_start(building_id: StringName) -> void:
    if not state.buildings.has(str(building_id)):
        return
    var building: BuildingState = state.buildings[str(building_id)]
    var assigned := _workforce_occupants(building)
    if assigned.size() != 1:
        building_management_feedback = "Cần đúng một đệ tử phụ trách công trình này."
    else:
        var reason := _workforce_start_block_reason(building,assigned[0])
        if reason != "":
            building_management_feedback = "Chưa thể bắt đầu: " + reason
        else:
            var profession_id := _workforce_profession(building.building_type)
            var ok := workforce.issue_command(state,assigned[0],WorkforceSystem.COMMAND_WORK,str(profession_id),40)
            building_management_feedback = (
                "Đã nhận lệnh. Scheduler sẽ gieo ô/mở mẻ ở nhịp hợp lệ; xem TIẾN ĐỘ THỰC TẾ."
                if ok else "Chưa thể gửi lệnh: trạng thái việc làm đã thay đổi, hãy chọn lại."
            )
    _refresh_building_operation_content()

func _workforce_remove(building_id: StringName) -> void:
    if not state.buildings.has(str(building_id)):
        return
    var assigned := _workforce_occupants(state.buildings[str(building_id)])
    if assigned.size() != 1:
        building_management_feedback = "Không có đúng một người để gỡ."
    else:
        var ok := workforce.assign_group(state,assigned[0],&"")
        building_management_feedback = "Đã gỡ người phụ trách khỏi công trình." if ok else "Đệ tử đang bận; phải hoàn thành hoặc hủy công việc hợp lệ trước."
    _refresh_building_operation_content()

func _workforce_cancel_timer(building_id: StringName, worker_id: StringName) -> void:
    if not state.buildings.has(str(building_id)):
        return
    var building: BuildingState = state.buildings[str(building_id)]
    var owns_timer := false
    for raw_job in BuildingSystem.new().resource_timer_jobs(building):
        if raw_job is Dictionary and str(raw_job.get("worker_id","")) == str(worker_id):
            owns_timer = true
            break
    if not owns_timer:
        building_management_feedback = "Mẻ đã kết thúc; không có gì để hủy."
    else:
        var cancelled := BuildingSystem.new().cancel_resource_timer(state,worker_id)
        building_management_feedback = "Đã hủy mẻ trên công trình này." if cancelled else "Không thể hủy mẻ hiện tại."
    _refresh_building_operation_content()

# Resolve the same verified sex+seed visual as the map, even when this
# disciple has not been instantiated as a map actor (paged roster / workforce).
# Texture2D is shared across buttons and loaded once per accepted Source A rig.
func _disciple_source_a_portrait_texture(disciple: DiscipleState) -> Texture2D:
    if disciple == null:
        return null
    var scene_path := DiscipleSourceAVisualPool.scene_path_for_disciple(disciple)
    if scene_path.is_empty():
        return null
    if source_a_portrait_textures.has(scene_path):
        return source_a_portrait_textures[scene_path] as Texture2D
    var packed := DiscipleSourceAVisualPool.scene_for_disciple(disciple)
    if packed == null:
        return null
    var preview := packed.instantiate() as AnimatedSprite2D
    if preview == null:
        return null
    var texture: Texture2D = null
    var frames := preview.sprite_frames
    if frames != null and frames.has_animation(&"stand") and frames.get_frame_count(&"stand") > 0:
        texture = frames.get_frame_texture(&"stand",0)
    preview.free()
    if texture != null:
        source_a_portrait_textures[scene_path] = texture
    return texture

func _disciple_avatar_button(disciple: DiscipleState, edge: float) -> Button:
    var avatar := Button.new()
    avatar.text = disciple.display_name.substr(0,1)
    avatar.custom_minimum_size = Vector2(edge,edge)
    avatar.add_theme_color_override("font_color",INK)
    avatar.add_theme_stylebox_override("normal",_style(Color(0.86,0.91,0.77),JADE_DARK,1,8))
    var actor := actor_nodes.get(str(disciple.id)) as ModularDiscipleActor
    # A real modular production body takes precedence over Source A artwork.
    var can_show_baked := actor == null or not actor.production_body_active()
    var baked_texture: Texture2D = null
    if can_show_baked:
        baked_texture = _disciple_source_a_portrait_texture(disciple)
    if baked_texture != null:
        var portrait := TextureRect.new()
        portrait.name = "VerifiedSourceAPortrait"
        portrait.texture = baked_texture
        portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        avatar.text = ""
        avatar.add_child(portrait)
        return avatar

    # Verified Source A portrait not yet imported for this disciple:
    # render a lightweight seed-stable face/hair/robe tile instead of a
    # misleading female art swap or the same initial-only green square.
    var look := DiscipleActorVisualCatalog.default_appearance_for_disciple(disciple)
    var garment := Color.from_string(str(look.get("outfit_tint","455472")),Color(0.27,0.33,0.45))
    var hair_tint := Color.from_string(str(look.get("hair_tint","2b2624")),Color(0.17,0.15,0.14))
    var stage := Control.new()
    stage.name = "FallbackPortrait"
    stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var chest := Panel.new()
    chest.position = Vector2(edge*0.15,edge*0.62)
    chest.size = Vector2(edge*0.70,edge*0.33)
    chest.mouse_filter = Control.MOUSE_FILTER_IGNORE
    chest.add_theme_stylebox_override("panel",_style(garment,INK,1,5))
    stage.add_child(chest)
    var face := Panel.new()
    face.position = Vector2(edge*0.29,edge*0.23)
    face.size = Vector2(edge*0.42,edge*0.43)
    face.mouse_filter = Control.MOUSE_FILTER_IGNORE
    face.add_theme_stylebox_override("panel",_style(Color(0.94,0.79,0.65),INK,1,9))
    stage.add_child(face)
    var hair := Panel.new()
    hair.position = Vector2(edge*0.24,edge*0.12)
    hair.size = Vector2(edge*0.52,edge*0.20)
    hair.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hair.add_theme_stylebox_override("panel",_style(hair_tint,INK,1,8))
    stage.add_child(hair)
    avatar.text = ""
    avatar.tooltip_text = disciple.display_name
    avatar.add_child(stage)
    return avatar

func _open_workforce_owner(disciple_id: StringName, building_id: StringName) -> void:
    _open_disciple(disciple_id)
    workforce_return_building_id = building_id
    _show_disciple_summary()

func _return_to_workforce_building() -> void:
    var building_id := workforce_return_building_id
    workforce_return_building_id = &""
    if not state.buildings.has(str(building_id)):
        return
    var building: BuildingState = state.buildings[str(building_id)]
    var destination := &""
    match building.building_type:
        BuildingSystem.TYPE_MINE: destination = SectMapPresentation.DEST_MINE
        BuildingSystem.TYPE_LINH_FOREST: destination = SectMapPresentation.DEST_LINH_FOREST
        BuildingSystem.TYPE_SPIRIT_FIELD: destination = SectMapPresentation.DEST_SPIRIT_FIELD
    if destination == &"":
        return
    _close_disciple_summary(true)
    _open_building(destination)
    selected_production_instance_id = building_id
    _refresh_building_operation_content()

# Advanced controls remain accessible for production plans, policies, and the
# historical P3 interaction contracts, but are not the main mobile workflow.
func _fold_workforce_legacy_controls() -> void:
    var children := building_management_container.get_children()
    if children.size() < 4:
        return
    var advanced := VBoxContainer.new()
    advanced.name = "WorkforceAdvancedControls"
    advanced.add_theme_constant_override("separation",6)
    var header_size := 4 # title, owner, per-instance chooser, quick-action row
    if children.size() > header_size and str(children[header_size].name) == "WorkforceEnableTimer":
        header_size += 1
    for index in range(header_size,children.size()):
        var node := children[index] as Control
        if node == null:
            continue
        building_management_container.remove_child(node)
        advanced.add_child(node)
    var toggle := Button.new()
    toggle.name = "WorkforceAdvancedToggle"
    toggle.text = "Ẩn tùy chọn nâng cao" if workforce_advanced_visible else "Kế hoạch / Danh sách nâng cao"
    toggle.custom_minimum_size = Vector2(PRODUCTION_CONTENT_WIDTH,44)
    toggle.pressed.connect(_toggle_workforce_advanced)
    building_management_container.add_child(toggle)
    building_management_container.add_child(advanced)
    advanced.visible = workforce_advanced_visible
    if workforce_advanced_visible:
        _fit_workforce_controls(advanced)

func _fit_workforce_controls(node: Node) -> void:
    if node is Control:
        var control := node as Control
        if control.custom_minimum_size.x > PRODUCTION_CONTENT_WIDTH:
            control.custom_minimum_size.x = PRODUCTION_CONTENT_WIDTH
    for child in node.get_children():
        _fit_workforce_controls(child)

func _toggle_workforce_advanced() -> void:
    workforce_advanced_visible = not workforce_advanced_visible
    _refresh_building_operation_content()

func _close_workforce_picker() -> void:
    if workforce_picker_panel != null and is_instance_valid(workforce_picker_panel):
        workforce_picker_panel.queue_free()
    workforce_picker_panel = null
    workforce_picker_results = null
    workforce_picker_search = null
    workforce_picker_building_id = &""

func _open_workforce_picker(building_id: StringName) -> void:
    _close_workforce_picker()
    if not state.buildings.has(str(building_id)):
        return
    workforce_picker_building_id = building_id
    workforce_picker_query = ""
    workforce_picker_offset = 0
    workforce_picker_panel = Panel.new()
    workforce_picker_panel.name = "WorkforcePicker"
    # Keep the picker entirely to the left of the wider, legible 420px
    # production panel. No overlap with Start/Remove at 1280x720.
    workforce_picker_panel.position = Vector2(340,102)
    workforce_picker_panel.size = Vector2(480,516)
    workforce_picker_panel.z_index = 90
    workforce_picker_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    workforce_picker_panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,16))
    add_child(workforce_picker_panel)
    var picker_title := _label(workforce_picker_panel,"CHỌN ĐỆ TỬ",Vector2(18,12),Vector2(320,35),20)
    picker_title.add_theme_color_override("font_color",INK)
    var close := Button.new()
    close.name = "WorkforcePickerClose"
    close.text = "Đóng ×"
    close.position = Vector2(377,13)
    close.size = Vector2(85,44)
    close.pressed.connect(_close_workforce_picker)
    workforce_picker_panel.add_child(close)
    workforce_picker_search = LineEdit.new()
    workforce_picker_search.name = "WorkforcePickerSearch"
    workforce_picker_search.placeholder_text = "Tìm tên / ID... (ưu tiên người rảnh)"
    workforce_picker_search.position = Vector2(18,67)
    workforce_picker_search.size = Vector2(444,44)
    workforce_picker_search.text_changed.connect(_workforce_picker_search_changed)
    workforce_picker_panel.add_child(workforce_picker_search)
    var scroll := ScrollContainer.new()
    scroll.name = "WorkforcePickerScroll"
    scroll.position = Vector2(18,120)
    scroll.size = Vector2(444,336)
    workforce_picker_panel.add_child(scroll)
    workforce_picker_results = VBoxContainer.new()
    workforce_picker_results.name = "WorkforcePickerResults"
    workforce_picker_results.custom_minimum_size = Vector2(424,0)
    workforce_picker_results.add_theme_constant_override("separation",5)
    scroll.add_child(workforce_picker_results)
    var prev := Button.new()
    prev.name = "WorkforcePickerPrev"
    prev.text = "◀ Trang trước"
    prev.position = Vector2(18,463)
    prev.size = Vector2(165,44)
    prev.pressed.connect(_workforce_picker_previous)
    workforce_picker_panel.add_child(prev)
    var next := Button.new()
    next.name = "WorkforcePickerNext"
    next.text = "Trang tiếp ▶"
    next.position = Vector2(297,463)
    next.size = Vector2(165,44)
    next.pressed.connect(_workforce_picker_next)
    workforce_picker_panel.add_child(next)
    _render_workforce_picker()

func _workforce_picker_search_changed(value: String) -> void:
    workforce_picker_query = value.strip_edges().to_lower()
    workforce_picker_offset = 0
    _render_workforce_picker()

func _workforce_picker_previous() -> void:
    workforce_picker_offset = maxi(0,workforce_picker_offset-WORKFORCE_PICKER_PAGE_SIZE)
    _render_workforce_picker()

func _workforce_picker_next() -> void:
    workforce_picker_offset += WORKFORCE_PICKER_PAGE_SIZE
    _render_workforce_picker()

func _workforce_candidate_reason(actor: DiscipleState, building: BuildingState, current: Array[StringName]) -> String:
    if current.has(actor.id):
        return "Đang phụ trách"
    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty():
        return "Đang xuất môn / PvE"
    if actor.worksite_building_id != &"":
        var old_site = state.buildings.get(str(actor.worksite_building_id))
        if not (old_site is BuildingState) or old_site.worker_group_id != actor.work_group_id:
            return "Điểm làm việc cũ không hợp lệ"
    if not actor.work_cycle_state.is_empty():
        var phase := str(actor.work_cycle_state.get("phase",actor.work_cycle_state.get("status","")))
        if phase == "travel_out":
            return "Lượt cũ: đang đi mỏ (travel_out)"
        return "Đang xử lý lượt làm việc" if phase == "" else "Đang làm: %s" % phase
    if not actor.direct_command.is_empty():
        return "Đang có lệnh chờ xử lý"
    if not (actor.current_action in [&"EVALUATE",&"IDLE",&"HOLD"]):
        return "Đang: %s" % SectMapPresentation.action_label(actor.current_action)
    var buildings := BuildingSystem.new()
    if buildings.disciple_has_active_timed_recipe(state,actor.id) or buildings.disciple_has_active_spirit_plot(state,actor.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor):
        return "Đang có lượt sản xuất / Rèn Thân"
    if current.size() > 1:
        return "Công trình đang bị phân nhiều người"
    if current.size() == 1 and state.disciples.has(current[0]):
        var former: DiscipleState = state.disciples[current[0]]
        if not former.work_cycle_state.is_empty() or not former.direct_command.is_empty() or not former.active_pve_encounter_id.is_empty() or former.region_id != &"sect" or str(former.current_action).begins_with("WORK_") or former.current_action in [&"CULTIVATE",&"TRAIN_BODY"] or BuildingSystem.new().disciple_has_active_timed_recipe(state,former.id) or BuildingSystem.new().disciple_has_active_spirit_plot(state,former.id):
            return "Người cũ đang sản xuất"
    return ""

func _render_workforce_picker() -> void:
    if workforce_picker_results == null or not is_instance_valid(workforce_picker_results) or not state.buildings.has(str(workforce_picker_building_id)):
        return
    for old in workforce_picker_results.get_children():
        workforce_picker_results.remove_child(old)
        old.queue_free()
    var building: BuildingState = state.buildings[str(workforce_picker_building_id)]
    var current := _workforce_occupants(building)
    var profession_id := _workforce_profession(building.building_type)
    # Compute eligibility once per actor, not O(N log N) scanning every
    # building/timer again inside the sort comparator at 1,000–3,000 people.
    var candidates: Array[Dictionary] = []
    for raw_id in state.disciples.keys():
        var actor: DiscipleState = state.disciples[raw_id]
        if workforce_picker_query != "" and not actor.display_name.to_lower().contains(workforce_picker_query) and not str(actor.id).to_lower().contains(workforce_picker_query):
            continue
        candidates.append({
            "id":actor.id,
            "reason":_workforce_candidate_reason(actor,building,current),
            "level":workforce.profession_level_for_state(state,actor,profession_id)
        })
    candidates.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var lready := str(a["reason"]) == ""
        var rready := str(b["reason"]) == ""
        if lready != rready:
            return lready
        if int(a["level"]) != int(b["level"]):
            return int(a["level"]) > int(b["level"])
        return str(a["id"]) < str(b["id"])
    )
    workforce_picker_offset = mini(workforce_picker_offset,maxi(0,candidates.size()-1))
    var end_index := mini(candidates.size(),workforce_picker_offset+WORKFORCE_PICKER_PAGE_SIZE)
    for index in range(workforce_picker_offset,end_index):
        var entry: Dictionary = candidates[index]
        var actor: DiscipleState = state.disciples[entry["id"]]
        var reason := str(entry["reason"])
        var row := HBoxContainer.new()
        row.name = "WorkforceCandidate_%s" % str(actor.id)
        row.custom_minimum_size = Vector2(424,48)
        workforce_picker_results.add_child(row)
        var avatar := _disciple_avatar_button(actor,44)
        avatar.name = "WorkforceCandidateAvatar_%s" % str(actor.id)
        avatar.tooltip_text = actor.display_name
        avatar.disabled = true
        row.add_child(avatar)
        var text_label := Label.new()
        text_label.text = "%s · nghề Lv%d\n%s" % [actor.display_name,
            int(entry["level"]),
            ("Sẵn sàng" if actor.work_group_id == &"" else "Có thể chuyển từ %s" % str(actor.work_group_id)) if reason == "" else reason]
        text_label.custom_minimum_size = Vector2(250,48)
        text_label.add_theme_color_override("font_color",INK)
        text_label.add_theme_font_size_override("font_size",12)
        row.add_child(text_label)
        var select := Button.new()
        select.name = "WorkforcePick_%s" % str(actor.id)
        select.text = "Chọn" if reason == "" else "Bận"
        select.custom_minimum_size = Vector2(104,44)
        select.disabled = reason != ""
        select.tooltip_text = "Giao người cho công trình thật" if reason == "" else reason
        select.pressed.connect(Callable(self,"_workforce_pick_candidate").bind(actor.id))
        row.add_child(select)
    if candidates.is_empty():
        _add_management_section_label_to(workforce_picker_results,"Không tìm thấy đệ tử phù hợp.")
    var prev := workforce_picker_panel.find_child("WorkforcePickerPrev",true,false) as Button
    var next := workforce_picker_panel.find_child("WorkforcePickerNext",true,false) as Button
    prev.disabled = workforce_picker_offset == 0
    next.disabled = end_index >= candidates.size()

func _add_management_section_label_to(parent: Control, message: String) -> void:
    var label := Label.new()
    label.text = message
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_color_override("font_color",INK)
    parent.add_child(label)

func _workforce_pick_candidate(disciple_id: StringName) -> void:
    if not state.buildings.has(str(workforce_picker_building_id)) or not state.disciples.has(disciple_id):
        return
    var building: BuildingState = state.buildings[str(workforce_picker_building_id)]
    var occupants := _workforce_occupants(building)
    var reason := _workforce_candidate_reason(state.disciples[disciple_id],building,occupants)
    if reason != "":
        building_management_feedback = reason
        _render_workforce_picker()
        return
    var result := workforce.transfer_production_worker(state,disciple_id,building.id,true)
    if not bool(result.get("ok",false)):
        building_management_feedback = "Không thể giao việc: %s" % str(result.get("reason","invalid_assignment"))
        _render_workforce_picker()
        return
    _close_workforce_picker()
    var profession_id := _workforce_profession(building.building_type)
    var started := workforce.issue_command(state,disciple_id,WorkforceSystem.COMMAND_WORK,str(profession_id),40)
    building_management_feedback = (
        "Đã giao %s vào %s; lệnh đang chờ scheduler. Xem tiến độ khi mẻ bắt đầu." % [
            state.disciples[disciple_id].display_name,str(building.id)
        ]
        if started else "Đã giao người vào %s; chưa gửi được lệnh. Bấm Bắt đầu để xem lý do." % str(building.id)
    )
    _refresh_building_operation_content()


# SECT-PLAYABLE V1: one central, touch-sized route through the existing map
# and canonical gameplay. This panel owns no economy, roster or job state.
func _build_sect_hub() -> void:
    sect_hub_button = Button.new()
    sect_hub_button.name = "OpenSectHub"
    sect_hub_button.text = "Điều hành"
    sect_hub_button.position = Vector2(306,16)
    sect_hub_button.size = Vector2(154,43)
    sect_hub_button.z_index = 55
    sect_hub_button.add_theme_font_size_override("font_size",15)
    sect_hub_button.add_theme_color_override("font_color",INK)
    sect_hub_button.add_theme_stylebox_override("normal",_style(PAPER_LIGHT,INK,2,10))
    sect_hub_button.pressed.connect(_show_sect_hub)
    add_child(sect_hub_button)

    sect_hub_panel = Panel.new()
    sect_hub_panel.name = "SectOperationsHub"
    sect_hub_panel.position = Vector2(269,85)
    sect_hub_panel.size = Vector2(740,543)
    sect_hub_panel.z_index = 85
    sect_hub_panel.visible = false
    sect_hub_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    sect_hub_panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,16))
    add_child(sect_hub_panel)

    var title := _label(sect_hub_panel,"TÔNG MÔN · ĐIỀU HÀNH",Vector2(20,12),Vector2(585,36),22)
    title.add_theme_color_override("font_color",CINNABAR.darkened(0.18))
    var close := Button.new()
    close.name = "CloseSectHub"
    close.text = "Đóng ×"
    close.position = Vector2(630,13)
    close.size = Vector2(90,44)
    close.pressed.connect(_hide_sect_hub)
    sect_hub_panel.add_child(close)
    var scroll := ScrollContainer.new()
    scroll.name = "SectHubScroll"
    scroll.position = Vector2(18,68)
    scroll.size = Vector2(704,459)
    sect_hub_panel.add_child(scroll)
    sect_hub_content = VBoxContainer.new()
    sect_hub_content.name = "SectHubContent"
    sect_hub_content.custom_minimum_size = Vector2(675,0)
    sect_hub_content.add_theme_constant_override("separation",9)
    scroll.add_child(sect_hub_content)

func _hide_sect_hub() -> void:
    sect_layout_preview_open = false
    sect_production_board_open = false
    if sect_hub_panel != null and is_instance_valid(sect_hub_panel):
        sect_hub_panel.visible = false
    if iso_world != null:
        _refresh_map_worksite_cues()

func _show_sect_hub() -> void:
    if not runtime_ready or sect_hub_panel == null or not is_instance_valid(sect_hub_panel):
        return
    _close_workforce_picker()
    _close_building_operation_panel(true)
    _close_disciple_summary(true)
    _clear_popup()
    _refresh_sect_hub()
    sect_hub_panel.visible = true
    _refresh_map_worksite_cues()

func _sect_hub_label(message: String, font_size: int = 14) -> void:
    var label := Label.new()
    label.text = message
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(665,0)
    label.add_theme_font_size_override("font_size",font_size)
    label.add_theme_color_override("font_color",INK)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    sect_hub_content.add_child(label)

func _sect_hub_route(text_label: String, destination: StringName) -> void:
    var button := Button.new()
    button.text = text_label
    button.name = "SectHubRoute_%s" % str(destination)
    button.custom_minimum_size = Vector2(675,48)
    button.add_theme_color_override("font_color",INK)
    button.add_theme_font_size_override("font_size",15)
    button.pressed.connect(Callable(self,"_open_building").bind(destination))
    sect_hub_content.add_child(button)

func _sect_hub_production_line(
    label_text: String, building_type: StringName, resource_id: StringName
) -> String:
    var buildings := BuildingSystem.new()
    var building := buildings.primary_building(state,building_type)
    if building == null:
        return "%s · Chưa có công trình" % label_text
    var instance_count := ResourceBuildingExpansionPolicyV2.existing_instances(state,building_type).size()
    var occupied := buildings.assigned_worker_ids(state,building)
    var actual_resource_id := resource_id
    if building_type == BuildingSystem.TYPE_MINE:
        actual_resource_id = production_plan_registry.output_resource_id(
            buildings.selected_resource_production_plan(building)
        )
    var worker_name := "Chưa giao"
    var activity := "Cần chọn đệ tử"
    if occupied.size() == 1 and state.disciples.has(occupied[0]):
        worker_name = (state.disciples[occupied[0]] as DiscipleState).display_name
        activity = _workforce_worker_status(building,occupied[0])
    elif occupied.size() > 1:
        activity = "Cần kiểm tra phân công"
    return "%s · %d công trình thật · Lv%d (mẫu đầu) · %s\n%s · Kho %s" % [
        label_text,instance_count,building.level,worker_name,activity,_warehouse_pair(actual_resource_id,true)
    ]

# G1.7: one read-only, paged view of EVERY canonical producer instance.
# No shadow map, local clock, construction/assignment command or save writes.
func _sect_production_instances(filter_type: StringName = &"", attention_only: bool = false) -> Array[BuildingState]:
    var urgent: Array[BuildingState] = []
    var regular: Array[BuildingState] = []
    for building_type in [
        BuildingSystem.TYPE_MINE,
        BuildingSystem.TYPE_LINH_FOREST,
        BuildingSystem.TYPE_SPIRIT_FIELD
    ]:
        if filter_type != &"" and filter_type != building_type:
            continue
        for building in ResourceBuildingExpansionPolicyV2.existing_instances(state,building_type):
            if bool(_sect_production_attention(building).get("needs_action",false)):
                urgent.append(building)
            elif not attention_only:
                regular.append(building)
    # Attention rows appear first; stable type and ID ordering in each bucket.
    urgent.append_array(regular)
    return urgent

# G1.8 actionable hints are derived from canonical, persisted snapshots.
# These labels are *advice only*. No resource delivery, new job, auto-order,
# construction, instant harvest, or migration may happen while viewing the hub.
func _sect_production_attention(building: BuildingState) -> Dictionary:
    if building == null:
        return {"needs_action":false,"label":"Không có công trình"}
    var buildings := BuildingSystem.new()
    var assigned := buildings.assigned_worker_ids(state,building)
    if assigned.size() > 1:
        return {"needs_action":true,"label":"Phân công bất thường: kiểm tra số người"}
    if assigned.is_empty():
        return {"needs_action":true,"label":"Chưa có đệ tử · Mở để phân công"}
    var worker_id: StringName = assigned[0]
    if not state.disciples.has(worker_id):
        return {"needs_action":true,"label":"Không tìm thấy người phụ trách · cần kiểm tra"}
    var actor: DiscipleState = state.disciples[worker_id]

    if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var jobs := buildings.resource_timer_jobs(building)
        if not jobs.is_empty():
            var first_job = jobs[0]
            if first_job is Dictionary:
                var remaining := int(first_job.get("finish_tick",state.tick))-state.tick
                if remaining <= 0:
                    return {"needs_action":false,"label":"Mẻ đến hạn · chờ scheduler xử lý"}
                return {"needs_action":false,"label":"Mẻ đang chạy · còn %d phút" % remaining}
            return {"needs_action":true,"label":"Dữ liệu mẻ không hợp lệ · cần kiểm tra"}
        if not actor.work_cycle_state.is_empty():
            return {"needs_action":false,"label":"Đang hoàn tất chu kỳ sản xuất cũ"}
        if not state.sect.economy_a_enabled:
            return {"needs_action":true,"label":"Chưa bật chu kỳ timer · mở công trình"}
        if DiscipleRealmProgressV2.owns_v2_progression(actor):
            var plan_id := buildings.selected_resource_production_plan(building)
            if production_plan_registry.has(plan_id):
                var output_id := production_plan_registry.output_resource_id(plan_id)
                var batch_units := production_plan_registry.scaled_yield(plan_id,building.level)
                var stock := WarehouseSystem.new().quantity(state,output_id)
                var target := mini(batch_units*10,WarehouseSystem.MAX_SAFE_STACK)
                if stock >= target:
                    return {"needs_action":true,"label":"Kho đạt mục tiêu %d · đổi kế hoạch hoặc tiêu thụ" % target}
                if batch_units > WarehouseSystem.MAX_SAFE_STACK-stock:
                    return {"needs_action":true,"label":"Kho không đủ chỗ cho mẻ tiếp theo"}
    elif building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
        # The accessor spirit_field_plots() may *write* legacy migration.
        # Inspect the persisted snapshots directly in this read-only board.
        if not building.production_state.has("plots"):
            return {"needs_action":true,"label":"Linh Điền cũ · mở công trình để đồng bộ"}
        var stored_plots = building.production_state.get("plots",[])
        if not (stored_plots is Array):
            return {"needs_action":true,"label":"Dữ liệu ô đất cần kiểm tra"}
        var growing := 0
        var empty := 0
        var due := 0
        for raw_plot in stored_plots:
            if not (raw_plot is Dictionary):
                continue
            var plot: Dictionary = raw_plot
            var plot_status := StringName(plot.get("status",""))
            if plot_status == BuildingSystem.PLOT_GROWING:
                growing += 1
                if int(plot.get("finish_tick",state.tick))-state.tick <= 0:
                    due += 1
            elif plot_status == BuildingSystem.PLOT_EMPTY:
                empty += 1
        if due > 0:
            return {"needs_action":false,"label":"%d ô đến hạn · chờ scheduler xử lý" % due}
        if empty == 0:
            return {"needs_action":false,"label":"Đang trồng đủ %d ô" % growing}
        var eligible := spirit_crop_registry.eligible_crop_ids(building.level)
        var affordable := false
        for crop_id in eligible:
            if state.sect.spirit_stones >= spirit_crop_registry.cost(crop_id):
                affordable = true
                break
        if not affordable:
            return {"needs_action":true,"label":"Chưa đủ Linh Thạch gieo trồng"}
    else:
        return {"needs_action":false,"label":"Không thuộc nhóm sản xuất"}

    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty():
        return {"needs_action":true,"label":"Người phụ trách đang xuất môn/PvE"}
    if not actor.direct_command.is_empty():
        var target := str(actor.direct_command.get("target",""))
        var kind := StringName(actor.direct_command.get("kind",""))
        if kind == WorkforceSystem.COMMAND_WORK and target == str(_workforce_profession(building.building_type)):
            return {"needs_action":false,"label":"Đã nhận lệnh · chờ scheduler mở lượt"}
        return {"needs_action":true,"label":"Có lệnh khác chờ xử lý"}
    if building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
        return {"needs_action":true,"label":"Còn ô trống · mở để kiểm tra gieo tiếp"}
    return {"needs_action":true,"label":"Chưa có mẻ · mở để bắt đầu"}

func _sect_production_type_name(building_type: StringName) -> String:
    match building_type:
        BuildingSystem.TYPE_MINE:
            return "Mỏ"
        BuildingSystem.TYPE_LINH_FOREST:
            return "Linh Lâm"
        BuildingSystem.TYPE_SPIRIT_FIELD:
            return "Linh Điền"
    return "Công trình"

func _sect_production_destination(building_type: StringName) -> StringName:
    match building_type:
        BuildingSystem.TYPE_MINE:
            return SectMapPresentation.DEST_MINE
        BuildingSystem.TYPE_LINH_FOREST:
            return SectMapPresentation.DEST_LINH_FOREST
        BuildingSystem.TYPE_SPIRIT_FIELD:
            return SectMapPresentation.DEST_SPIRIT_FIELD
    return &""

func _sect_production_status(building: BuildingState) -> String:
    if building == null:
        return "Công trình không tồn tại."
    var buildings := BuildingSystem.new()
    var assigned := buildings.assigned_worker_ids(state,building)
    if assigned.size() > 1:
        return "Lỗi phân công: %d người cùng công trình" % assigned.size()
    var owner := "Chưa có đệ tử"
    if assigned.size() == 1:
        owner = (
            (state.disciples[assigned[0]] as DiscipleState).display_name
            if state.disciples.has(assigned[0]) else str(assigned[0])
        )
    var activity := "Chưa có mẻ"
    if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var jobs := buildings.resource_timer_jobs(building)
        if not jobs.is_empty() and jobs[0] is Dictionary:
            var job: Dictionary = jobs[0]
            activity = "Đang làm %s ×%d · còn %d phút" % [
                ResourceRegistry.new().display_name(StringName(job.get("resource_id",""))),
                maxi(0,int(job.get("output_quantity",0))),
                maxi(0,int(job.get("finish_tick",state.tick))-state.tick)
            ]
        elif not assigned.is_empty() and state.disciples.has(assigned[0]):
            activity = _workforce_worker_status(building,assigned[0])
        else:
            var plan := buildings.selected_resource_production_plan(building)
            activity = "Kế hoạch %s ×%d/mẻ" % [
                ResourceRegistry.new().display_name(production_plan_registry.output_resource_id(plan)),
                production_plan_registry.scaled_yield(plan,building.level)
            ]
    elif building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
        # Dashboard reads the persisted plot snapshot directly, because the
        # BuildingSystem accessor can lazily migrate an old Field on read.
        # Merely opening this board must not write to production_state.
        var stored_plots = building.production_state.get("plots",[])
        if not (stored_plots is Array):
            return "Phụ trách: %s\nDữ liệu ô đất cần đồng bộ tại công trình." % owner
        var plots: Array = stored_plots
        if not building.production_state.has("plots"):
            return "Phụ trách: %s\nLinh Điền cũ: mở công trình để xem các ô đã đồng bộ." % owner
        var growing := 0
        var next_remaining := -1
        var crop_label := ""
        for raw_plot in plots:
            if not (raw_plot is Dictionary):
                continue
            var plot: Dictionary = raw_plot
            if StringName(plot.get("status","")) != BuildingSystem.PLOT_GROWING:
                continue
            growing += 1
            var remaining := maxi(0,int(plot.get("finish_tick",state.tick))-state.tick)
            if next_remaining < 0 or remaining < next_remaining:
                next_remaining = remaining
                crop_label = "%s ×%d thường" % [
                    spirit_crop_registry.display_name(StringName(plot.get("crop_id",""))),
                    maxi(0,int(plot.get("routine_yield",0)))
                ]
        activity = "%d/%d ô đang trồng" % [growing,plots.size()]
        if growing > 0:
            activity += " · gần nhất %d phút · %s" % [next_remaining,crop_label]
    return "Phụ trách: %s\n%s" % [owner,activity]

func _open_sect_production_instance(building_id: StringName) -> void:
    if not state.buildings.has(str(building_id)):
        _refresh_sect_production_board()
        return
    var building: BuildingState = state.buildings[str(building_id)]
    var destination := _sect_production_destination(building.building_type)
    if destination == &"":
        return
    # Open, focus and first render must all use the same selected ID.
    _open_building(destination,building.id)

func _show_sect_production_board() -> void:
    sect_production_board_filter = &""
    sect_production_attention_only = false
    sect_production_board_page = 0
    sect_layout_preview_open = false
    sect_production_board_open = true
    _refresh_sect_production_board(true)

func _sect_production_filter_changed(building_type: StringName) -> void:
    if building_type != &"" and not ResourceBuildingExpansionPolicyV2.RAW_TYPES.has(building_type):
        return
    sect_production_board_filter = building_type
    sect_production_board_page = 0
    _refresh_sect_production_board(true)

func _sect_production_attention_filter_changed() -> void:
    sect_production_attention_only = not sect_production_attention_only
    sect_production_board_page = 0
    _refresh_sect_production_board(true)

func _sect_production_page_changed(direction: int) -> void:
    var total := _sect_production_instances(sect_production_board_filter,sect_production_attention_only).size()
    var max_page := maxi(0,int(ceili(float(total)/float(SECT_PRODUCTION_PAGE_SIZE)))-1)
    sect_production_board_page = clampi(sect_production_board_page+direction,0,max_page)
    _refresh_sect_production_board(true)

func _refresh_sect_production_board(reset_scroll: bool = false) -> void:
    if not sect_production_board_open or sect_hub_content == null or not is_instance_valid(sect_hub_content):
        return
    var scroll := sect_hub_panel.find_child("SectHubScroll",false,false) as ScrollContainer
    var scroll_before := 0
    if not reset_scroll and scroll != null:
        scroll_before = scroll.scroll_vertical
    for child in sect_hub_content.get_children():
        sect_hub_content.remove_child(child)
        child.queue_free()
    var mine_count := _sect_production_instances(BuildingSystem.TYPE_MINE).size()
    var forest_count := _sect_production_instances(BuildingSystem.TYPE_LINH_FOREST).size()
    var field_count := _sect_production_instances(BuildingSystem.TYPE_SPIRIT_FIELD).size()
    _sect_hub_label("SẢN XUẤT TÔNG MÔN · DỮ LIỆU THẬT",19)
    _sect_hub_label("Mỏ %d · Linh Lâm %d · Linh Điền %d · Tick %d" % [
        mine_count,forest_count,field_count,state.tick
    ],13)
    var attention_count := _sect_production_instances(&"",true).size()
    _sect_hub_label("CẦN XỬ LÝ: %d công trình · các mục này được xếp trước" % attention_count,14)
    var attention_button := Button.new()
    attention_button.name = "SectProductionAttentionOnly"
    attention_button.text = "Đang lọc: Cần xử lý ✓" if sect_production_attention_only else "Chỉ xem CẦN XỬ LÝ"
    attention_button.custom_minimum_size = Vector2(662,46)
    attention_button.add_theme_font_size_override("font_size",14)
    attention_button.add_theme_color_override("font_color",INK)
    attention_button.pressed.connect(_sect_production_attention_filter_changed)
    sect_hub_content.add_child(attention_button)

    var tabs := HBoxContainer.new()
    tabs.name = "SectProductionFilters"
    tabs.custom_minimum_size = Vector2(662,48)
    tabs.add_theme_constant_override("separation",5)
    sect_hub_content.add_child(tabs)
    for entry in [
        {"type":&"","name":"Tất cả"},
        {"type":BuildingSystem.TYPE_MINE,"name":"Mỏ"},
        {"type":BuildingSystem.TYPE_LINH_FOREST,"name":"Linh Lâm"},
        {"type":BuildingSystem.TYPE_SPIRIT_FIELD,"name":"Linh Điền"}
    ]:
        var type_id: StringName = StringName(entry["type"])
        var filter_button := Button.new()
        filter_button.name = "SectProductionFilter_%s" % (
            "all" if type_id == &"" else str(type_id)
        )
        filter_button.text = str(entry["name"])
        filter_button.custom_minimum_size = Vector2(153,46)
        filter_button.add_theme_font_size_override("font_size",13)
        filter_button.add_theme_color_override("font_color",INK)
        if type_id == sect_production_board_filter:
            filter_button.add_theme_stylebox_override("normal",_style(Color(0.95,0.86,0.61),INK,2,8))
        filter_button.pressed.connect(Callable(self,"_sect_production_filter_changed").bind(type_id))
        tabs.add_child(filter_button)

    var all_instances := _sect_production_instances(sect_production_board_filter,sect_production_attention_only)
    var max_page := maxi(0,ceili(float(all_instances.size())/float(SECT_PRODUCTION_PAGE_SIZE))-1)
    sect_production_board_page = clampi(sect_production_board_page,0,max_page)
    var first := sect_production_board_page*SECT_PRODUCTION_PAGE_SIZE
    var last := mini(first+SECT_PRODUCTION_PAGE_SIZE,all_instances.size())
    if all_instances.is_empty():
        _sect_hub_label("Chưa có công trình thuộc nhóm này. Không tự xây mới.",14)
    for index in range(first,last):
        var building: BuildingState = all_instances[index]
        var card := PanelContainer.new()
        card.name = "SectProductionCard_%s" % str(building.id)
        card.add_theme_stylebox_override("panel",_style(Color(0.95,0.91,0.80),INK,1,9))
        sect_hub_content.add_child(card)
        var horizontal := HBoxContainer.new()
        horizontal.custom_minimum_size = Vector2(645,104)
        horizontal.add_theme_constant_override("separation",8)
        card.add_child(horizontal)
        var attention := _sect_production_attention(building)
        var detail := Label.new()
        detail.name = "SectProductionStatus_%s" % str(building.id)
        detail.text = "%s · %s · Lv%d\n%s\n%s: %s" % [
            _sect_production_type_name(building.building_type),
            str(building.id),building.level,_sect_production_status(building),
            "CẦN XỬ LÝ" if bool(attention.get("needs_action",false)) else "TRẠNG THÁI",
            str(attention.get("label",""))
        ]
        detail.custom_minimum_size = Vector2(493,98)
        detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        detail.add_theme_font_size_override("font_size",13)
        detail.add_theme_color_override("font_color",INK)
        detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
        horizontal.add_child(detail)
        var open_button := Button.new()
        open_button.name = "SectProductionOpen_%s" % str(building.id)
        open_button.text = "Xử lý" if bool(attention.get("needs_action",false)) else "Mở"
        open_button.custom_minimum_size = Vector2(119,48)
        open_button.add_theme_font_size_override("font_size",15)
        open_button.add_theme_color_override("font_color",PAPER_LIGHT)
        open_button.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,8))
        open_button.pressed.connect(Callable(self,"_open_sect_production_instance").bind(building.id))
        horizontal.add_child(open_button)

    var paging := HBoxContainer.new()
    paging.name = "SectProductionPaging"
    paging.custom_minimum_size = Vector2(662,48)
    paging.add_theme_constant_override("separation",13)
    sect_hub_content.add_child(paging)
    var prev := Button.new()
    prev.name = "SectProductionPrevious"
    prev.text = "← Trước"
    prev.custom_minimum_size = Vector2(133,46)
    prev.disabled = sect_production_board_page == 0
    prev.pressed.connect(Callable(self,"_sect_production_page_changed").bind(-1))
    paging.add_child(prev)
    var page_label := Label.new()
    page_label.name = "SectProductionPageInfo"
    page_label.text = "Trang %d/%d · %d công trình" % [
        sect_production_board_page+1,max_page+1,all_instances.size()
    ]
    page_label.custom_minimum_size = Vector2(258,44)
    page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    paging.add_child(page_label)
    var next := Button.new()
    next.name = "SectProductionNext"
    next.text = "Sau →"
    next.custom_minimum_size = Vector2(133,46)
    next.disabled = sect_production_board_page >= max_page
    next.pressed.connect(Callable(self,"_sect_production_page_changed").bind(1))
    paging.add_child(next)

    var back := Button.new()
    back.name = "SectProductionBackToHub"
    back.text = "← Quay lại Điều hành"
    back.custom_minimum_size = Vector2(662,48)
    back.pressed.connect(_refresh_sect_hub)
    sect_hub_content.add_child(back)
    _ensure_disabled_controls_readable(sect_hub_content)
    if scroll != null:
        scroll.set_deferred("scroll_vertical",scroll_before)

# Read-only cap and land geometry authority; do NOT enable construction
# without one persistent SectLayoutState, real Hall and approved tariffs.
func _show_sect_layout_preview() -> void:
    if not runtime_ready or sect_hub_content == null or not is_instance_valid(sect_hub_content):
        return
    sect_production_board_open = false
    sect_layout_preview_open = true
    for child in sect_hub_content.get_children():
        sect_hub_content.remove_child(child)
        child.queue_free()
    _sect_hub_label("QUY HOẠCH TÔNG MÔN V2 · XEM TRƯỚC",19)
    _sect_hub_label("Bản đồ đề xuất 192×192 · khu đầu 48×48 · chunk 16×16")
    _sect_hub_label("XÂY MỚI / MỞ ĐẤT: CHƯA KHẢ DỤNG. Thiếu Đại Điện thật, bố cục có thể lưu, chi phí đã duyệt và QA ENV-02A.")
    var grid := SectLandRegionPreviewV2.preview()
    _sect_hub_label("Vùng quy hoạch: %d · đất đầu đề xuất: %d ô · không có quyền mở đất ở lượt chơi này." % [
        int(grid.get("region_count",0)),int(grid.get("starter_cells",0))
    ])
    _sect_hub_label("GIỚI HẠN CÔNG TRÌNH THEO CẤP ĐẠI ĐIỆN (ĐỀ XUẤT):",16)
    for hall in [1,10,20,40,60,80,100]:
        _sect_hub_label("Đại Điện Lv%d: Mỏ %d · Linh Lâm %d · Linh Điền %d" % [
            hall,
            ResourceBuildingExpansionPolicyV2.capacity_for(hall,BuildingSystem.TYPE_MINE),
            ResourceBuildingExpansionPolicyV2.capacity_for(hall,BuildingSystem.TYPE_LINH_FOREST),
            ResourceBuildingExpansionPolicyV2.capacity_for(hall,BuildingSystem.TYPE_SPIRIT_FIELD)
        ])
    _sect_hub_label("CÔNG TRÌNH THẬT ĐANG CÓ:",16)
    for item in [
        {"name":"Mỏ","type":BuildingSystem.TYPE_MINE},
        {"name":"Linh Lâm","type":BuildingSystem.TYPE_LINH_FOREST},
        {"name":"Linh Điền","type":BuildingSystem.TYPE_SPIRIT_FIELD}
    ]:
        var existing := ResourceBuildingExpansionPolicyV2.existing_instances(state,item["type"])
        var lines: Array[String] = []
        for building in existing:
            lines.append("%s Lv%d" % [str(building.id),building.level])
        _sect_hub_label("%s: %d · %s" % [
            item["name"],existing.size(),
            " · ".join(lines) if not lines.is_empty() else "Chưa có"
        ])
    _sect_hub_label("Vùng ngoài khu đầu chưa được mở. Bản vẽ không thay đổi save, kho, Linh Thạch, công trình hoặc thời gian.")
    var back := Button.new()
    back.name = "SectLayoutPreviewBack"
    back.text = "← Trở lại điều hành"
    back.custom_minimum_size = Vector2(675,50)
    back.pressed.connect(_refresh_sect_hub)
    sect_hub_content.add_child(back)

func _refresh_sect_hub() -> void:
    sect_layout_preview_open = false
    sect_production_board_open = false
    if sect_hub_content == null or not is_instance_valid(sect_hub_content):
        return
    var scroll := sect_hub_panel.find_child("SectHubScroll",false,false) as ScrollContainer
    var last_scroll := scroll.scroll_vertical if scroll != null else 0
    for child in sect_hub_content.get_children():
        sect_hub_content.remove_child(child)
        child.queue_free()
    _sect_hub_label("Đệ tử: %d/%d · Ứng viên chờ: %d · Chiêu Mộ Lệnh: %d" % [
        state.disciples.size(),state.sect.disciple_capacity,
        state.recruitment_candidates.size(),state.sect.disciple_recruitment_tokens
    ],15)
    _sect_hub_label("Linh Thạch tông môn: %d · Tick %d" % [
        state.sect.spirit_stones,state.tick
    ])
    var attention_count := _sect_production_instances(&"",true).size()
    var dashboard := Button.new()
    dashboard.name = "SectHubOpenProductionBoard"
    dashboard.text = "BẢNG SẢN XUẤT · %d cần xử lý" % attention_count
    dashboard.custom_minimum_size = Vector2(675,50)
    dashboard.add_theme_font_size_override("font_size",16)
    dashboard.add_theme_color_override("font_color",PAPER_LIGHT)
    dashboard.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,9))
    dashboard.pressed.connect(_show_sect_production_board)
    sect_hub_content.add_child(dashboard)
    _sect_hub_route("DẪN TIÊN · Tuyển và nhận đệ tử",SectMapPresentation.DEST_GUIDANCE)
    _sect_hub_label(_sect_hub_production_line("MỎ LINH KHOÁNG",BuildingSystem.TYPE_MINE,&"thanh_thiet"))
    _sect_hub_route("MỎ · Chọn người / Khai khoáng",SectMapPresentation.DEST_MINE)
    _sect_hub_label(_sect_hub_production_line("LINH LÂM",BuildingSystem.TYPE_LINH_FOREST,&"linh_moc"))
    _sect_hub_route("LINH LÂM · Chọn người / Thu hoạch",SectMapPresentation.DEST_LINH_FOREST)
    _sect_hub_label(_sect_hub_production_line("LINH ĐIỀN",BuildingSystem.TYPE_SPIRIT_FIELD,&"linh_coc"))
    _sect_hub_route("LINH ĐIỀN · Chọn người / Gieo trồng",SectMapPresentation.DEST_SPIRIT_FIELD)
    _sect_hub_route("KHO · Kiểm tra vật tư / Phường Thị",SectMapPresentation.DEST_WAREHOUSE)
    var layout := Button.new()
    layout.name = "SectHubLayoutPreview"
    layout.text = "QUY HOẠCH · 30 Mỏ / 30 Linh Lâm / 40 Linh Điền (xem trước)"
    layout.custom_minimum_size = Vector2(675,50)
    layout.pressed.connect(_show_sect_layout_preview)
    sect_hub_content.add_child(layout)
    var disciples_button := Button.new()
    disciples_button.name = "SectHubDisciples"
    disciples_button.text = "ĐỆ TỬ · Thuộc tính và công việc"
    disciples_button.custom_minimum_size = Vector2(675,48)
    disciples_button.pressed.connect(Callable(self,"_bottom_action").bind("disciples"))
    sect_hub_content.add_child(disciples_button)
    var save := Button.new()
    save.name = "SectHubSave"
    save.text = "LƯU TIẾN ĐỘ NGAY"
    save.custom_minimum_size = Vector2(675,48)
    save.pressed.connect(_sect_hub_save)
    sect_hub_content.add_child(save)
    if scroll != null:
        scroll.set_deferred("scroll_vertical",last_scroll)

func _sect_hub_save() -> void:
    if runtime_session == null or not runtime_ready:
        return
    var result := runtime_session.save()
    tab_status_text = (
        "Đã lưu tông môn."
        if bool(result.get("ok",false))
        else "Chưa lưu được: %s" % str(result.get("reason",result.get("error","unknown")))
    )
    _refresh_sect_hub()
    _sect_hub_label(tab_status_text,14)

func _open_new_recruit_workforce(disciple_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    _open_building(SectMapPresentation.DEST_MINE)
    var building := BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_MINE)
    if building == null:
        return
    _open_workforce_picker(building.id)
    if workforce_picker_search != null:
        workforce_picker_search.text = str(disciple_id)
        _workforce_picker_search_changed(str(disciple_id))

func _build_main_hall_policy_controls() -> void:
    _build_economy_a_hall_controls()
    _add_management_section_label("CHÍNH SÁCH LAO ĐỘNG")
    _add_policy_button_row([
        {"label":"Cân bằng", "value":WorkforceSystem.POLICY_BALANCED},
        {"label":"Sản xuất", "value":WorkforceSystem.POLICY_PRODUCTION},
        {"label":"Tu luyện", "value":WorkforceSystem.POLICY_CULTIVATION}
    ], state.sect.work_policy, "_set_work_policy_from_building")

    _add_management_section_label("ƯU TIÊN HẬU CẦN")
    _add_policy_button_row([
        {"label":"Cân bằng", "value":NeedsSystem.PRIORITY_BALANCED},
        {"label":"Thuốc", "value":NeedsSystem.PRIORITY_MEDICINE},
        {"label":"Vật tư", "value":NeedsSystem.PRIORITY_SUPPLIES}
    ], state.sect.needs_priority, "_set_needs_priority_from_building")

    _add_management_section_label("CHÍNH SÁCH TRANG BỊ")
    _add_policy_button_row([
        {"label":"Cân bằng", "value":EquipmentSystem.POLICY_BALANCED},
        {"label":"Chiến đấu", "value":EquipmentSystem.POLICY_COMBAT},
        {"label":"Tiết kiệm", "value":EquipmentSystem.POLICY_FRUGAL}
    ], state.sect.equipment_policy, "_set_equipment_policy_from_building")

# ECONOMY-A player actions are actual simulation transactions; no fake income.
func _build_economy_a_hall_controls() -> void:
    _add_management_section_label("KINH TẾ V1 · LINH THẠCH")
    if not state.sect.economy_a_enabled:
        var enable := Button.new()
        enable.name = "EconomyA_Enable"
        enable.text = "Bật kinh tế V1 cho lượt chơi này"
        enable.custom_minimum_size = Vector2(384,36)
        enable.pressed.connect(_economy_a_enable_from_ui)
        building_management_container.add_child(enable)
        return
    var policy: Dictionary = state.sect.economy_a_policy
    var summary := Label.new()
    summary.text = "Quỹ: %d · Lương/mẻ: %d · Mỏ/Lâm T1: %d phút" % [
        state.sect.spirit_stones,
        int(policy.get("wage_per_batch",2)),
        production_plan_registry.base_cycle_ticks(ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1)
    ]
    summary.custom_minimum_size = Vector2(384,32)
    summary.add_theme_font_size_override("font_size",12)
    building_management_container.add_child(summary)
    var heal_toggle := Button.new()
    heal_toggle.name = "EconomyA_AutoHP"
    heal_toggle.text = "Tự chữa HP: BẬT" if bool(policy.get("auto_hp_service",false)) else "Tự chữa HP: TẮT"
    heal_toggle.custom_minimum_size = Vector2(384,36)
    heal_toggle.pressed.connect(_economy_a_toggle_heal_from_ui)
    building_management_container.add_child(heal_toggle)
    var spending_limit := Button.new()
    spending_limit.name = "EconomyA_AutoSpendLimit"
    spending_limit.text = "Hạn mức tự chữa: %d LT/đệ tử/ngày" % int(policy.get("auto_hp_daily_stone_limit",6))
    spending_limit.custom_minimum_size = Vector2(384,36)
    spending_limit.pressed.connect(_economy_a_cycle_spend_limit_from_ui)
    building_management_container.add_child(spending_limit)

func _economy_a_enable_from_ui() -> void:
    var result := EconomySystem.new().enable_v1(state)
    building_management_feedback = "Đã bật Kinh tế V1; các mẻ mới của đệ tử V2 dùng timer." if bool(result.get("ok",false)) else str(result.get("reason","Không thể bật kinh tế."))
    _refresh_building_operation_content()

func _economy_a_toggle_heal_from_ui() -> void:
    var economy := EconomySystem.new()
    var old := bool(state.sect.economy_a_policy.get("auto_hp_service",false))
    var result := economy.configure_v1(state,"auto_hp_service",not old)
    building_management_feedback = "Đã đổi chính sách chi tiêu cá nhân." if bool(result.get("ok",false)) else "Chính sách bị từ chối."
    _refresh_building_operation_content()

func _economy_a_cycle_spend_limit_from_ui() -> void:
    var choices := [0,3,6,12]
    var current := int(state.sect.economy_a_policy.get("auto_hp_daily_stone_limit",6))
    var index := choices.find(current)
    var next_value := int(choices[(index+1) % choices.size()])
    var result := EconomySystem.new().configure_v1(state,"auto_hp_daily_stone_limit",next_value)
    building_management_feedback = "Đã đổi hạn mức tự chữa." if bool(result.get("ok",false)) else "Không đổi được hạn mức."
    _refresh_building_operation_content()

func _build_economy_a_market_controls() -> void:
    if not state.sect.economy_a_enabled:
        return
    var economy := EconomySystem.new()
    economy.sync_market_day(state)
    _add_management_section_label("PHƯỜNG THỊ · GIAO DỊCH NGUYÊN LIỆU")
    var quota := Label.new()
    quota.text = "Bán %d · mua %d đơn vị/ngày · thương nhân còn %d LT." % [
        economy.market_remaining(state),economy.market_buy_remaining(state),
        economy.market_stone_budget_remaining(state)]
    quota.custom_minimum_size = Vector2(384,28)
    building_management_container.add_child(quota)
    for raw_id in ["linh_moc","thanh_thiet","thanh_linh_thao","linh_coc"]:
        var resource_id := StringName(raw_id)
        var available := WarehouseSystem.new().available_quantity(state,resource_id)
        var price := int(ResourceRegistry.new().definition(resource_id).get("market_value",0))
        var max_sale := int(state.sect.economy_a_policy.get("market_max_per_sale",5))
        var sellable := mini(available,mini(max_sale,economy.market_remaining(state)))
        sellable = mini(sellable,int(economy.market_stone_budget_remaining(state) / maxi(price,1)))
        var row := Button.new()
        row.name = "EconomyA_Sell_%s" % raw_id
        row.text = "Bán %s ×%d · +%d LT" % [ResourceRegistry.new().display_name(resource_id),sellable,price*sellable]
        row.custom_minimum_size = Vector2(384,36)
        row.disabled = sellable <= 0 or price <= 0
        row.pressed.connect(Callable(self,"_economy_a_sell_from_ui").bind(resource_id,sellable))
        building_management_container.add_child(row)
        var merchant_stock := int(state.sect.economy_a_market_stock.get(raw_id,0))
        var buy_price := economy.market_purchase_price(state,resource_id)
        var buyable := mini(merchant_stock,mini(int(state.sect.economy_a_policy.get("market_max_per_buy",5)),economy.market_buy_remaining(state)))
        buyable = mini(buyable,int(state.sect.spirit_stones / maxi(buy_price,1)))
        var buy_row := Button.new()
        buy_row.name = "EconomyA_Buy_%s" % raw_id
        buy_row.text = "Mua %s ×%d · -%d LT · Chợ còn %d" % [ResourceRegistry.new().display_name(resource_id),buyable,buy_price*buyable,merchant_stock]
        buy_row.custom_minimum_size = Vector2(384,36)
        buy_row.disabled = buyable <= 0 or buy_price <= 0 or state.sect.spirit_stones < buy_price*buyable
        buy_row.pressed.connect(Callable(self,"_economy_a_buy_from_ui").bind(resource_id,buyable))
        building_management_container.add_child(buy_row)

func _economy_a_buy_from_ui(resource_id: StringName, qty: int) -> void:
    var request_id := "panel-buy:%s:%d" % [str(resource_id),state.sect.economy_a_event_count+1]
    var result := EconomySystem.new().buy_from_npc_v1(state,resource_id,qty,request_id)
    var receipt: Dictionary = result.get("receipt",{})
    building_management_feedback = (
        "Đã mua %d sản phẩm; quỹ -%d Linh Thạch." % [qty,int(receipt.get("cost",0))]
        if bool(result.get("ok",false)) and not bool(result.get("already_settled",false))
        else ("Lệnh mua đã xử lý trước đó." if bool(result.get("already_settled",false)) else "Không mua được: %s" % str(result.get("reason","unknown")))
    )
    _refresh_building_operation_content()

func _economy_a_sell_from_ui(resource_id: StringName, qty: int) -> void:
    var request_id := "panel:%s:%d" % [str(resource_id),state.sect.economy_a_event_count+1]
    var result := EconomySystem.new().sell_to_npc_v1(state,resource_id,qty,request_id)
    var receipt: Dictionary = result.get("receipt",{})
    building_management_feedback = (
        "Phường Thị nhận %d sản phẩm; quỹ +%d Linh Thạch." % [qty,int(receipt.get("earned",0))]
        if bool(result.get("ok",false)) and not bool(result.get("already_settled",false))
        else ("Lệnh bán đã xử lý trước đó." if bool(result.get("already_settled",false)) else "Không bán được: %s" % str(result.get("reason","unknown")))
    )
    _refresh_building_operation_content()

func _build_needs_priority_controls(title: String) -> void:
    _add_management_section_label(title)
    _add_policy_button_row([
        {"label":"Cân bằng", "value":NeedsSystem.PRIORITY_BALANCED},
        {"label":"Ưu tiên thuốc", "value":NeedsSystem.PRIORITY_MEDICINE},
        {"label":"Ưu tiên vật tư", "value":NeedsSystem.PRIORITY_SUPPLIES}
    ], state.sect.needs_priority, "_set_needs_priority_from_building")

func _build_guidance_recruitment_controls() -> void:
    _add_management_section_label("DẪN TIÊN")
    if last_accepted_disciple_id != &"" and state.disciples.has(last_accepted_disciple_id):
        var newest: DiscipleState = state.disciples[last_accepted_disciple_id]
        var assign_next := Button.new()
        assign_next.name = "GuidanceAssignNewRecruit"
        assign_next.text = "Phân công ngay: %s → Mỏ" % newest.display_name
        assign_next.custom_minimum_size = Vector2(384,48)
        assign_next.pressed.connect(Callable(self,"_open_new_recruit_workforce").bind(last_accepted_disciple_id))
        building_management_container.add_child(assign_next)
    var order := Button.new()
    order.name = "GuidanceRecruitOrder"
    order.text = "Dùng Chiêu Mộ Lệnh (%d)" % state.sect.disciple_recruitment_tokens
    order.custom_minimum_size = Vector2(384, 36)
    order.disabled = state.sect.disciple_recruitment_tokens <= 0
    order.pressed.connect(_guidance_recruit_with_order)
    building_management_container.add_child(order)

    _add_management_section_label("ỨNG VIÊN ĐANG CHỜ")
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        var empty := Label.new()
        empty.text = "Hiện chưa có ứng viên chờ xét."
        empty.add_theme_font_size_override("font_size", 12)
        building_management_container.add_child(empty)
        return

    for raw_id in ids:
        var candidate_id := StringName(raw_id)
        var candidate: CandidateState = state.recruitment_candidates[candidate_id]
        var card := VBoxContainer.new()
        card.name = "RecruitCandidate_%s" % str(candidate_id)
        card.custom_minimum_size = Vector2(384, 82)
        card.add_theme_constant_override("separation", 4)
        building_management_container.add_child(card)

        var info := Label.new()
        info.text = "%s · %s\nTư %.0f · Cốt %.0f · Duyên %.0f · Tuệ %.0f · Mị %.0f · Tiềm %.0f" % [
            candidate.display_name,
            str(DiscipleGeneratorV2.QUALITY_NAMES.get(str(candidate.disciple_quality), str(candidate.disciple_quality))),
            candidate.aptitude,
            candidate.constitution,
            candidate.fortune,
            candidate.comprehension,
            candidate.charisma,
            candidate.potential
        ]
        if not _candidate_recruitable(candidate):
            info.text += "\nHồ sơ cũ: không thể nhận vào runtime V2; có thể từ chối."
        info.custom_minimum_size = Vector2(384, 50)
        info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        info.add_theme_font_size_override("font_size", 11)
        card.add_child(info)

        var actions := HBoxContainer.new()
        actions.add_theme_constant_override("separation", 8)
        card.add_child(actions)

        var accept := Button.new()
        accept.name = "AcceptCandidate_%s" % str(candidate_id)
        accept.text = "Nhận"
        accept.custom_minimum_size = Vector2(120, 34)
        accept.disabled = (
            not recruitment_system.can_accept_more(state)
            or not _candidate_recruitable(candidate)
        )
        accept.pressed.connect(Callable(self, "_accept_guidance_candidate").bind(candidate_id))
        actions.add_child(accept)

        var reject := Button.new()
        reject.name = "RejectCandidate_%s" % str(candidate_id)
        reject.text = "Từ chối"
        reject.custom_minimum_size = Vector2(120, 34)
        reject.pressed.connect(Callable(self, "_reject_guidance_candidate").bind(candidate_id))
        actions.add_child(reject)

func _candidate_recruitable(candidate: CandidateState) -> bool:
    if candidate == null:
        return false
    if state.sect.disciple_v2_birth_enabled:
        return DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile)
    return true

func _guidance_recruit_with_order() -> void:
    var result := recruitment_system.guidance_recruit_with_order(state)
    if bool(result.get("ok", false)):
        building_management_feedback = "Dẫn Tiên Đài đã tiếp nhận thêm một ứng viên."
    else:
        building_management_feedback = _recruitment_feedback(str(result.get("reason", "generation_failed")))
    _refresh_all()
    _refresh_building_operation_content()

func _accept_guidance_candidate(candidate_id: StringName) -> void:
    var candidate: CandidateState = state.recruitment_candidates.get(candidate_id)
    var candidate_name := candidate.display_name if candidate != null else str(candidate_id)
    var result := recruitment_system.accept_candidate(state, candidate_id)
    if bool(result.get("ok", false)):
        last_accepted_disciple_id = candidate_id
        building_management_feedback = "Đã nhận %s vào tông môn. Có thể phân công ngay." % candidate_name
    else:
        building_management_feedback = _recruitment_feedback(str(result.get("reason", "accept_failed")))
    # Refresh immediately so a successful authoritative roster mutation creates
    # its real map actor without waiting for a wall-clock poll.
    _refresh_all()
    _refresh_building_operation_content()

func _reject_guidance_candidate(candidate_id: StringName) -> void:
    var candidate: CandidateState = state.recruitment_candidates.get(candidate_id)
    var candidate_name := candidate.display_name if candidate != null else str(candidate_id)
    var result := recruitment_system.reject_candidate(state, candidate_id)
    if bool(result.get("ok", false)):
        building_management_feedback = "Đã từ chối %s." % candidate_name
    else:
        building_management_feedback = _recruitment_feedback(str(result.get("reason", "reject_failed")))
    _refresh_all()
    _refresh_building_operation_content()

func _recruitment_feedback(reason: String) -> String:
    match reason:
        "capacity_full":
            return "Không thể nhận thêm: Đệ Tử Xá đã đủ chỗ."
        "candidate_missing":
            return "Ứng viên này không còn trong danh sách chờ."
        "not_enough_recruitment_tokens":
            return "Không còn Chiêu Mộ Lệnh."
        "guidance_disabled", "recruitment_disabled":
            return "Dẫn Tiên hiện chưa khả dụng."
        "v2_birth_profile_incomplete":
            return "Hồ sơ V2 của ứng viên chưa hợp lệ."
        _:
            return "Thao tác tuyển mộ chưa thể thực hiện: %s." % reason

func _add_policy_button_row(options: Array, current_value: StringName, handler_name: String) -> void:
    var row := HBoxContainer.new()
    row.custom_minimum_size = Vector2(384, 36)
    row.add_theme_constant_override("separation", 5)
    building_management_container.add_child(row)

    for option_value in options:
        var option: Dictionary = option_value
        var value := StringName(option.get("value", ""))
        var button := Button.new()
        button.text = "%s%s" % [str(option.get("label", value)), " ✓" if value == current_value else ""]
        button.custom_minimum_size = Vector2(118, 34)
        button.add_theme_font_size_override("font_size", 10)
        button.pressed.connect(Callable(self, handler_name).bind(value))
        row.add_child(button)

func _build_lodging_expansion_control() -> void:
    _add_management_section_label("MỞ RỘNG CHỖ Ở")
    var row := HBoxContainer.new()
    row.custom_minimum_size = Vector2(384, 38)
    row.add_theme_constant_override("separation", 8)
    building_management_container.add_child(row)

    var info := Label.new()
    info.text = "Hiện %d chỗ · Vật tư %d" % [state.sect.lodging_capacity, state.sect.supply_stock]
    info.custom_minimum_size = Vector2(236, 34)
    info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    info.add_theme_font_size_override("font_size", 11)
    row.add_child(info)

    var button := Button.new()
    button.name = "ExpandLodging"
    button.text = "+1 chỗ · -%d" % NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT
    button.custom_minimum_size = Vector2(136, 34)
    button.add_theme_font_size_override("font_size", 10)
    button.pressed.connect(_expand_lodging_from_building)
    row.add_child(button)

func _build_mine_upgrade_control() -> void:
    var buildings := BuildingSystem.new()
    var mine := _selected_resource_instance(BuildingSystem.TYPE_MINE)
    _add_management_section_label("NÂNG CẤP MỎ")
    if mine == null:
        var missing := Label.new()
        missing.text = "Mỏ chưa tồn tại trong trạng thái hiện tại."
        missing.add_theme_font_size_override("font_size", 11)
        building_management_container.add_child(missing)
        return

    var row := VBoxContainer.new()
    row.custom_minimum_size = Vector2(384, 0)
    row.add_theme_constant_override("separation", 4)
    building_management_container.add_child(row)

    var info := Label.new()
    info.name = "MineUpgradeStatus"
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_theme_font_size_override("font_size", 10)
    row.add_child(info)

    var button := Button.new()
    button.name = "Upgrade_mine"
    button.custom_minimum_size = Vector2(384, 34)
    button.add_theme_font_size_override("font_size", 10)
    row.add_child(button)

    if mine.is_upgrading():
        info.text = "Lv%d → Lv%d · tiến độ %.0f/%.0f" % [
            mine.level, mine.upgrade_target_level,
            mine.upgrade_progress, mine.upgrade_required_work
        ]
        button.text = "Đang nâng cấp..."
        button.disabled = true
        return

    if mine.level >= mine.max_level:
        info.text = "Mỏ đã đạt Lv%d tối đa." % mine.level
        button.text = "Đã tối đa"
        button.disabled = true
        return

    var cost := buildings.upgrade_cost_for_state(state,mine)
    var ore_need := int(cost.get(BuildingSystem.MATERIAL_ORE, 0))
    var wood_need := int(cost.get(BuildingSystem.MATERIAL_WOOD, 0))
    var stone_need := int(cost.get("spirit_stones", 0))
    var check := buildings.can_start_upgrade(state, mine.id)
    info.text = (
        "Lv%d → Lv%d · Thanh Thiết dùng %d/%d · Linh Mộc dùng %d/%d · Linh Thạch %d/%d · thời gian %.0f phút"
    ) % [
        mine.level, mine.level + 1,
        _warehouse_available(StringName(BuildingSystem.MATERIAL_ORE)), ore_need,
        _warehouse_available(StringName(BuildingSystem.MATERIAL_WOOD)), wood_need,
        state.sect.spirit_stones, stone_need,
        buildings.upgrade_required_work(mine)
    ]
    button.text = "Nâng cấp Mỏ lên Lv%d" % (mine.level + 1)
    button.disabled = not bool(check.get("ok", false))
    if button.disabled:
        button.tooltip_text = _building_upgrade_reason(check)
    button.pressed.connect(Callable(self, "_start_building_upgrade_from_ui").bind(mine.id))

func _start_building_upgrade_from_ui(building_id: StringName) -> void:
    var buildings := BuildingSystem.new()
    var result := buildings.start_upgrade(state, building_id)
    if bool(result.get("ok", false)):
        building_management_feedback = "Đã bắt đầu nâng cấp Mỏ lên Lv%d; chi phí đã trừ đúng một lần." % int(result.get("target_level", 0))
    else:
        building_management_feedback = "Không thể nâng cấp Mỏ: %s" % _building_upgrade_reason(result)
    _refresh_all()
    _refresh_building_operation_content()

func _building_upgrade_reason(result: Dictionary) -> String:
    var reason := str(result.get("reason", ""))
    match reason:
        "already_upgrading":
            return "Đang có lượt nâng cấp."
        "missing_material":
            return "Thiếu %s: dùng được %d/%d." % [
                EquipmentSystem.new().material_name(StringName(result.get("material_id", ""))),
                int(result.get("have", 0)),
                int(result.get("need", 0))
            ]
        "missing_spirit_stones":
            return "Thiếu Linh Thạch: %d/%d." % [
                int(result.get("have", 0)),
                int(result.get("need", 0))
            ]
        "max_level":
            return "Đã đạt cấp tối đa."
        "":
            return "Sẵn sàng."
        _:
            return reason

func _build_forge_craft_controls() -> void:
    _add_management_section_label("LUYỆN CHẾ TRANG BỊ")
    var recipe_ids: Array = EquipmentSystem.RECIPES.keys()
    recipe_ids.sort()
    for raw_id in recipe_ids:
        var recipe_id := StringName(raw_id)
        var data := equipment_system.recipe(recipe_id)
        if data.is_empty():
            continue

        var row := VBoxContainer.new()
        row.custom_minimum_size = Vector2(384, 0)
        row.add_theme_constant_override("separation", 3)
        building_management_container.add_child(row)

        var top := HBoxContainer.new()
        top.custom_minimum_size = Vector2(384, 36)
        top.add_theme_constant_override("separation", 6)
        row.add_child(top)

        var name := Label.new()
        name.text = str(data.get("name", recipe_id))
        name.custom_minimum_size = Vector2(244, 34)
        name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        name.add_theme_font_size_override("font_size", 11)
        top.add_child(name)

        var craft := Button.new()
        craft.name = "Craft_%s" % str(recipe_id)
        craft.text = "Luyện vào kho"
        craft.custom_minimum_size = Vector2(128, 34)
        craft.add_theme_font_size_override("font_size", 10)
        craft.disabled = not equipment_system.can_craft(state, recipe_id)
        if craft.disabled:
            craft.tooltip_text = _recipe_material_status(recipe_id)
        craft.pressed.connect(Callable(self, "_craft_from_building").bind(recipe_id))
        top.add_child(craft)

        var materials := Label.new()
        materials.text = _recipe_material_status(recipe_id)
        materials.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        materials.add_theme_font_size_override("font_size", 10)
        materials.add_theme_color_override("font_color", Color(0.24, 0.22, 0.18, 0.76))
        row.add_child(materials)

func _recipe_material_status(recipe_id: StringName) -> String:
    var data := equipment_system.recipe(recipe_id)
    if data.is_empty():
        return "Recipe không tồn tại."
    var materials: Dictionary = equipment_system.crafting_requirements(state,recipe_id)
    var ids: Array = materials.keys()
    ids.sort()
    var parts: Array[String] = []
    var missing: Array[String] = []
    for raw_id in ids:
        var material_id := StringName(raw_id)
        var need := int(materials[raw_id])
        var total := _warehouse_quantity(material_id)
        var usable := _warehouse_available(material_id)
        parts.append("%s tồn %d / dùng %d / cần %d" % [equipment_system.material_name(material_id), total, usable, need])
        if usable < need:
            missing.append(equipment_system.material_name(material_id))
    var can_craft := equipment_system.can_craft(state, recipe_id)
    var suffix := " · Đủ nguyên liệu" if can_craft else (
        " · Thiếu vật tư dùng được: %s" % ", ".join(missing) if not missing.is_empty()
        else " · Chưa thể chế tạo"
    )
    return "Nguyên liệu (tồn / dùng / cần): %s%s" % [" · ".join(parts), suffix]

func _set_work_policy_from_building(policy: StringName) -> void:
    var ok := workforce.set_work_policy(state, policy)
    building_management_feedback = "Đã đổi chính sách lao động: %s." % _work_policy_label(policy) if ok else "Không thể đổi chính sách lao động."
    _refresh_building_operation_content()

func _set_needs_priority_from_building(priority: StringName) -> void:
    var ok := needs_system.set_priority(state, priority)
    building_management_feedback = "Đã đổi ưu tiên hậu cần: %s." % _needs_priority_label(priority) if ok else "Không thể đổi ưu tiên hậu cần."
    _refresh_building_operation_content()

func _set_equipment_policy_from_building(policy: StringName) -> void:
    var ok := equipment_system.set_policy(state, policy)
    building_management_feedback = "Đã đổi chính sách trang bị: %s." % _equipment_policy_label(policy) if ok else "Không thể đổi chính sách trang bị."
    _refresh_building_operation_content()

func _expand_lodging_from_building() -> void:
    var ok := needs_system.expand_lodging(state, 1)
    if ok:
        building_management_feedback = "Đã mở rộng +1 chỗ nghỉ, tốn %d vật tư." % NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT
    else:
        building_management_feedback = "Không đủ %d vật tư để mở rộng +1 chỗ." % NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT
    _refresh_building_operation_content()

func _craft_from_building(recipe_id: StringName) -> void:
    var item := equipment_system.craft(state, recipe_id, false)
    if item.is_empty():
        building_management_feedback = "Không đủ nguyên liệu: %s" % _recipe_material_status(recipe_id)
    else:
        building_management_feedback = "Đã luyện chế %s · %s vào Kho Tông Môn." % [
            str(item.get("name", recipe_id)),
            equipment_system.quality_name(StringName(item.get("quality", "pham")))
        ]
    _refresh_building_operation_content()

func _add_management_search() -> void:
    var search := LineEdit.new()
    search.name = "BuildingDiscipleSearch"
    search.placeholder_text = "Tìm tên hoặc ID đệ tử · Enter để lọc"
    search.text = building_management_query
    search.custom_minimum_size = Vector2(384,34)
    search.text_submitted.connect(Callable(self,"_apply_management_search"))
    building_management_container.add_child(search)

func _apply_management_search(value: String) -> void:
    building_management_query = value.strip_edges().to_lower()
    _refresh_building_operation_content()

func _ranked_management_ids(profession_id: StringName, group_id: StringName) -> Array:
    var ids: Array = []
    for raw_id in state.disciples.keys():
        var disciple: DiscipleState = state.disciples[raw_id]
        if building_management_query != "" and not disciple.display_name.to_lower().contains(building_management_query) and not str(disciple.id).to_lower().contains(building_management_query):
            continue
        ids.append(raw_id)
    var modifiers := ProfessionModifierSystem.new()
    ids.sort_custom(func(a: Variant, b: Variant) -> bool:
        var left: DiscipleState = state.disciples[a]
        var right: DiscipleState = state.disciples[b]
        var left_level := workforce.profession_level_for_state(state,left,profession_id)
        var right_level := workforce.profession_level_for_state(state,right,profession_id)
        var left_score := modifiers.total_work_speed_factor(state,left,left_level)
        var right_score := modifiers.total_work_speed_factor(state,right,right_level)
        if left.work_group_id == group_id:
            left_score += 10000.0
        if right.work_group_id == group_id:
            right_score += 10000.0
        if not is_equal_approx(left_score,right_score):
            return left_score > right_score
        return str(a) < str(b)
    )
    return ids

func _build_work_management(profession_id: StringName, group_id: StringName, group_label: String, order_label: String) -> void:
    _add_management_section_label("PHÂN CÔNG")
    var active_building_ids: Array[StringName] = []
    var building_system := BuildingSystem.new()
    var active_producer: BuildingState = null
    if building_system.is_building_profession(profession_id):
        active_producer = _selected_resource_instance(building_system.building_type_for_profession(profession_id))
        if active_producer != null:
            active_building_ids = building_system.active_worker_ids(state, active_producer)

    if profession_id == WorkforceSystem.PROF_MINING and active_producer != null and state.sect.economy_a_enabled:
        var selected_plan := building_system.selected_resource_production_plan(active_producer)
        var next_plan := ProductionPlanRegistry.PLAN_MINE_HUYEN_THIET_T2 if selected_plan == ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1 else ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1
        var plan_button := Button.new()
        plan_button.name = "MineProductionPlan"
        plan_button.text = "Mỏ đang khai thác: %s · đổi sang %s" % [
            "Huyền Thiết" if selected_plan == ProductionPlanRegistry.PLAN_MINE_HUYEN_THIET_T2 else "Thanh Thiết",
            "Huyền Thiết" if next_plan == ProductionPlanRegistry.PLAN_MINE_HUYEN_THIET_T2 else "Thanh Thiết"]
        plan_button.custom_minimum_size = Vector2(384,36)
        plan_button.disabled = active_producer.level < ProductionPlanRegistry.new().required_building_level(next_plan)
        if plan_button.disabled:
            plan_button.tooltip_text = "Huyền Thiết mở ở Mỏ Lv30."
        plan_button.pressed.connect(Callable(self,"_set_mine_plan_from_ui").bind(active_producer.id,next_plan))
        building_management_container.add_child(plan_button)
    # Secondary instances are assigned exclusively by the canonical picker;
    # old crew-wide buttons cannot silently mutate the primary producer.
    if active_producer != null and building_system.primary_building(state,active_producer.building_type) != active_producer:
        _add_management_section_label("Công trình bổ sung: chọn một đệ tử bằng Chọn / Đổi ở trên.")
        return
    _add_management_search()
    var ids := _ranked_management_ids(profession_id,group_id)
    var shown := 0
    for raw_id in ids:
        if shown >= MANAGEMENT_PAGE_SIZE:
            break
        var disciple: DiscipleState = state.disciples[raw_id]
        var row := _new_management_row(disciple)
        var level := workforce.profession_level_for_state(state,disciple,profession_id)
        var name_label := row.get_child(0) as Label
        name_label.text = "%s · nghề Lv%d" % [disciple.display_name,level]
        name_label.tooltip_text = "%s · nghề Lv%d · tốc độ ×%.2f" % [
            disciple.display_name,level,ProfessionModifierSystem.new().total_work_speed_factor(state,disciple,level)]
        shown += 1
        var in_group := disciple.work_group_id == group_id
        var timed_recipe_busy := building_system.disciple_has_active_timed_recipe(state, disciple.id)

        var group_button := Button.new()
        group_button.name = "Group_%s_%s" % [str(group_id), str(disciple.id)]
        group_button.text = "Rút đội" if in_group else "Phân đội"
        group_button.custom_minimum_size = Vector2(70, 34)
        group_button.add_theme_font_size_override("font_size", 11)
        if timed_recipe_busy:
            group_button.disabled = true
            group_button.tooltip_text = "Đệ tử đang hoàn thành mẻ đã commit; không thể đổi đội."
        if in_group:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(disciple.id, &"", "Đã rút %s khỏi %s." % [disciple.display_name, group_label]))
        else:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(disciple.id, group_id, "Đã phân %s vào %s." % [disciple.display_name, group_label]))
        row.add_child(group_button)

        # GP-01: distinguish crew membership from an explicit, persisted Mine
        # worksite. Full crews may retain waiting members; only active slots
        # receive work orders. No fake worksite/building state is created.
        if profession_id == WorkforceSystem.PROF_MINING and active_producer != null:
            var site_button := Button.new()
            site_button.name = "MineWorksite_%s" % str(disciple.id)
            var assigned_here := disciple.worksite_building_id == active_producer.id
            site_button.text = "Bỏ điểm" if assigned_here else "Chọn Mỏ"
            site_button.custom_minimum_size = Vector2(76, 34)
            site_button.add_theme_font_size_override("font_size", 11)
            site_button.disabled = not in_group or timed_recipe_busy
            site_button.tooltip_text = (
                "Giữ nhóm nghề; chỉ xóa điểm làm việc cụ thể." if assigned_here
                else "Đặt điểm làm việc tại Mỏ thật. Nếu hết slot, đệ tử tiếp tục chờ."
            )
            site_button.pressed.connect(Callable(self, "_assign_mine_worksite").bind(
                disciple.id, &"" if assigned_here else active_producer.id
            ))
            row.add_child(site_button)

        var order_button := Button.new()
        order_button.name = "Work_%s_%s" % [str(profession_id), str(disciple.id)]
        order_button.text = order_label
        order_button.custom_minimum_size = Vector2(82, 34)
        order_button.add_theme_font_size_override("font_size", 11)
        if building_system.is_building_profession(profession_id):
            var has_active_slot := active_building_ids.has(disciple.id)
            order_button.disabled = not has_active_slot or not building_system.work_available(state, profession_id, disciple)
            if not has_active_slot:
                order_button.tooltip_text = "Cần thuộc một chỗ hoạt động của công trình trước khi ra lệnh."
            elif order_button.disabled:
                order_button.tooltip_text = "Công trình hiện chưa thể bắt đầu lượt làm việc mới."
        order_button.pressed.connect(Callable(self, "_issue_building_order").bind(
            disciple.id,
            WorkforceSystem.COMMAND_WORK,
            str(profession_id),
            "Đã ra lệnh %s: %s." % [order_label.to_lower(), disciple.display_name]
        ))
        row.add_child(order_button)

func _set_mine_plan_from_ui(building_id: StringName, plan_id: StringName) -> void:
    var ok := BuildingSystem.new().set_resource_production_plan(state,building_id,plan_id)
    building_management_feedback = "Đã đổi kế hoạch khai khoáng." if ok else "Chưa thể đổi kế hoạch khai khoáng."
    _refresh_building_operation_content()

func _build_spirit_field_management() -> void:
    var buildings := BuildingSystem.new()
    var field := _selected_resource_instance(BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        _add_management_section_label("LINH ĐIỀN CHƯA SẴN SÀNG")
        return

    _add_management_section_label("CHÍNH SÁCH CÂY TRỒNG")
    var policy_row := HBoxContainer.new()
    policy_row.custom_minimum_size = Vector2(384, 36)
    policy_row.add_theme_constant_override("separation", 5)
    building_management_container.add_child(policy_row)

    var auto_button := Button.new()
    auto_button.name = "FieldPolicy_auto_demand"
    auto_button.text = "Tự động ✓" if StringName(field.production_state.get("policy_mode", "")) == BuildingSystem.FIELD_POLICY_AUTO_DEMAND else "Tự động"
    auto_button.custom_minimum_size = Vector2(94, 34)
    auto_button.add_theme_font_size_override("font_size", 10)
    auto_button.pressed.connect(Callable(self, "_set_spirit_field_policy_from_ui").bind(
        field.id, BuildingSystem.FIELD_POLICY_AUTO_DEMAND, &""
    ))
    policy_row.add_child(auto_button)

    for crop_id in spirit_crop_registry.eligible_crop_ids(field.level):
        var fixed := Button.new()
        fixed.name = "FieldPolicy_fixed_%s" % str(crop_id)
        fixed.text = "Cố định %s" % spirit_crop_registry.display_name(crop_id)
        fixed.custom_minimum_size = Vector2(132, 34)
        fixed.add_theme_font_size_override("font_size", 9)
        fixed.disabled = field.level < 10
        if fixed.disabled:
            fixed.tooltip_text = "Chính sách Cố định mở ở Linh Điền Lv10."
        fixed.pressed.connect(Callable(self, "_set_spirit_field_policy_from_ui").bind(
            field.id, BuildingSystem.FIELD_POLICY_FIXED, crop_id
        ))
        policy_row.add_child(fixed)

    _add_management_section_label("PHÂN CÔNG & GIEO TRỒNG")
    var active_ids := buildings.active_worker_ids(state, field)
    if buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD) != field:
        _add_management_section_label("Linh Điền bổ sung: dùng Chọn / Đổi để gán riêng một người.")
        return
    _add_management_search()
    var ids := _ranked_management_ids(WorkforceSystem.PROF_HERBALISM,&"herbalism_crew")
    var shown := 0
    for raw_id in ids:
        if shown >= MANAGEMENT_PAGE_SIZE:
            break
        var disciple: DiscipleState = state.disciples[raw_id]
        var row := _new_management_row(disciple)
        var level := workforce.profession_level_for_state(state,disciple,WorkforceSystem.PROF_HERBALISM)
        var name_label := row.get_child(0) as Label
        name_label.text = "%s · nghề Lv%d" % [disciple.display_name,level]
        shown += 1
        var in_group := disciple.work_group_id == &"herbalism_crew"
        var has_plot := buildings.disciple_has_active_spirit_plot(state, disciple.id, field)

        var group_button := Button.new()
        group_button.name = "FieldGroup_%s" % str(disciple.id)
        group_button.text = "Rút đội" if in_group else "Phân đội"
        group_button.custom_minimum_size = Vector2(70, 34)
        group_button.add_theme_font_size_override("font_size", 11)
        group_button.disabled = has_plot
        if has_plot:
            group_button.tooltip_text = "Field duty đang chạy; phải xử lý hết các ô đang trồng trước khi đổi người phụ trách."
        elif in_group:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(
                disciple.id, &"", "Đã rút %s khỏi Đội Linh Thực." % disciple.display_name
            ))
        else:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(
                disciple.id, &"herbalism_crew", "Đã phân %s vào Đội Linh Thực." % disciple.display_name
            ))
        row.add_child(group_button)

        var plant_button := Button.new()
        plant_button.name = "FieldPlant_%s" % str(disciple.id)
        plant_button.text = "Gieo ô tiếp" if has_plot else "Gieo trồng"
        plant_button.custom_minimum_size = Vector2(82, 34)
        plant_button.add_theme_font_size_override("font_size", 10)
        var reason := _spirit_field_start_reason(disciple, field, active_ids)
        plant_button.disabled = reason != ""
        if plant_button.disabled:
            plant_button.tooltip_text = reason
        plant_button.pressed.connect(Callable(self, "_issue_building_order").bind(
            disciple.id,
            WorkforceSystem.COMMAND_WORK,
            str(WorkforceSystem.PROF_HERBALISM),
            "Đã ra lệnh gieo trồng: %s." % disciple.display_name
        ))
        row.add_child(plant_button)

func _set_spirit_field_policy_from_ui(field_id: StringName, mode: StringName, crop_id: StringName) -> void:
    var ok := BuildingSystem.new().set_spirit_field_policy(state, field_id, mode, crop_id)
    building_management_feedback = "Đã cập nhật chính sách Linh Điền." if ok else "Không thể đổi chính sách Linh Điền ở cấp hiện tại."
    _refresh_building_operation_content()

func _spirit_field_start_reason(disciple: DiscipleState, field: BuildingState, active_ids: Array[StringName]) -> String:
    var buildings := BuildingSystem.new()
    if disciple.region_id != &"sect":
        return "Đệ tử phải ở trong tông môn."
    if disciple.work_group_id != &"herbalism_crew":
        return "Cần phân vào Đội Linh Thực."
    if not active_ids.has(disciple.id):
        return "Linh Điền này đã có người phụ trách khác."

    var has_empty := false
    for raw_plot in buildings.spirit_field_plots(state, field):
        if raw_plot is Dictionary and StringName(raw_plot.get("status", "")) == BuildingSystem.PLOT_EMPTY:
            has_empty = true
            break
    if not has_empty:
        return "Không còn ô Linh Điền trống."

    var eligible := spirit_crop_registry.eligible_crop_ids(field.level)
    var affordable := false
    for crop_id in eligible:
        if state.sect.spirit_stones >= spirit_crop_registry.cost(crop_id):
            affordable = true
            break
    if not affordable:
        return "Không đủ Linh Thạch cho cây trồng hợp lệ."
    if not buildings.work_available(state, WorkforceSystem.PROF_HERBALISM, disciple):
        return "Chính sách hiện tại chưa chọn được cây có thể trồng."
    return ""

func _build_direct_order_management(kind: StringName, target: String, button_text: String, outside_only: bool) -> void:
    _add_management_section_label("LỆNH TÔNG CHỦ")
    var ids: Array = state.disciples.keys()
    ids.sort()
    var added := 0
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if outside_only and disciple.region_id == &"sect" and not SectMapPresentation.is_outside_flow(disciple.current_action):
            continue
        var row := _new_management_row(disciple)
        var order_button := Button.new()
        order_button.name = "Order_%s_%s" % [str(kind), str(disciple.id)]
        order_button.text = button_text
        order_button.custom_minimum_size = Vector2(94, 34)
        order_button.add_theme_font_size_override("font_size", 11)
        order_button.pressed.connect(Callable(self, "_issue_building_order").bind(
            disciple.id,
            kind,
            target,
            "%s: %s." % [button_text, disciple.display_name]
        ))
        row.add_child(order_button)
        added += 1

    if added == 0:
        var empty := Label.new()
        empty.text = "Không có đệ tử phù hợp để ra lệnh tại đây."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.add_theme_font_size_override("font_size", 12)
        building_management_container.add_child(empty)

func _add_management_section_label(text: String) -> void:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", CINNABAR.darkened(0.12))
    building_management_container.add_child(label)

func _new_management_row(disciple: DiscipleState) -> GridContainer:
    # Two columns keep the Mine's three actions within the 384px panel.
    # The name stays readable on paper and commands wrap to a second row.
    var row := GridContainer.new()
    row.name = "Person_%s" % str(disciple.id)
    row.columns = 2
    row.custom_minimum_size = Vector2(384, 0)
    row.add_theme_constant_override("h_separation", 6)
    row.add_theme_constant_override("v_separation", 3)
    building_management_container.add_child(row)

    var name := Label.new()
    name.text = "%s · TL %.0f" % [disciple.display_name, disciple.stamina]
    name.custom_minimum_size = Vector2(190, 34)
    name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    name.add_theme_font_size_override("font_size", 11)
    name.add_theme_color_override("font_color", INK)
    row.add_child(name)
    return row

func _assign_building_group(disciple_id: StringName, group_id: StringName, success_text: String) -> void:
    if not state.disciples.has(disciple_id):
        return
    var ok := workforce.assign_group(state, disciple_id, group_id)
    building_management_feedback = success_text if ok else "Không thể đổi phân công lúc này."
    _refresh_building_operation_content()

func _assign_mine_worksite(disciple_id: StringName, building_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    var ok := workforce.assign_worksite(state, disciple_id, building_id)
    building_management_feedback = (
        "Đã cập nhật điểm làm việc; slot hoạt động do công trình quyết định."
        if ok else "Không thể cập nhật điểm làm việc lúc này."
    )
    _refresh_building_operation_content()

func _issue_building_order(disciple_id: StringName, kind: StringName, target: String, success_text: String) -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    if kind == WorkforceSystem.COMMAND_CULTIVATE and DiscipleRealmProgressV2.owns_v2_progression(disciple):
        # GP-02A: the Cultivation Platform must use the same preflight as the
        # authentic V2 profile, never the legacy direct-command shortcut.
        building_management_feedback = _v2_training_ui_feedback(
            _queue_v2_training("cultivation", disciple_id), "cultivation"
        )
    else:
        var ok := workforce.issue_command(state, disciple_id, kind, target, 40)
        building_management_feedback = success_text if ok else "Không thể ra lệnh lúc này."
    _refresh_building_operation_content()

# Display only two actual slots, rather than offering imaginary building
# capacity or a parallel character roster. Rows are backed by persisted V2
# worksite assignments and the same runtime that performs paid minutes.
func _build_body_training_management() -> void:
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_BODY_TRAINING)
    if hall == null:
        _add_management_section_label("Chưa có Rèn Thân Đường trong save hiện tại.")
        return
    var slots := buildings.worker_slots(hall)
    var holders := buildings.active_worker_ids(state,hall)
    _add_management_section_label("VỊ TRÍ LUYỆN THỂ (%d/%d)" % [holders.size(),slots])
    for index in range(slots):
        var row := HBoxContainer.new()
        row.name = "BodyTrainingSlot_%d" % (index+1)
        row.custom_minimum_size = Vector2(384,42)
        building_management_container.add_child(row)
        var line := Label.new()
        line.custom_minimum_size = Vector2(252,36)
        line.add_theme_font_size_override("font_size",12)
        line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        if index >= holders.size():
            line.text = "Chỗ %d: Trống" % (index+1)
            row.add_child(line)
            continue
        var disciple_id: StringName = holders[index]
        var disciple: DiscipleState = state.disciples[disciple_id]
        var phase := "Đang luyện" if disciple.current_action == &"TRAIN_BODY" else "Đã giữ chỗ"
        line.text = "Chỗ %d: %s · %s" % [index+1,disciple.display_name,phase]
        line.clip_text = true
        row.add_child(line)
        var release := Button.new()
        release.name = "BodyTrainingRelease_%s" % str(disciple_id)
        release.text = "Trả chỗ"
        release.custom_minimum_size = Vector2(112,34)
        release.pressed.connect(Callable(self,"_release_body_training_from_building").bind(disciple_id))
        row.add_child(release)

    _add_management_section_label("PHÂN CÔNG ĐỆ TỬ V2")
    var ids: Array = state.disciples.keys()
    ids.sort()
    var shown := 0
    for raw_id in ids:
        if shown >= 12:
            break
        var member: DiscipleState = state.disciples[raw_id]
        if not DiscipleRealmProgressV2.owns_v2_progression(member):
            continue
        if holders.has(member.id):
            continue
        if member.region_id != &"sect":
            continue
        var row := HBoxContainer.new()
        row.name = "BodyTrainingCandidate_%s" % str(member.id)
        row.custom_minimum_size = Vector2(384,40)
        building_management_container.add_child(row)
        var label := Label.new()
        label.text = member.display_name
        label.custom_minimum_size = Vector2(252,34)
        label.clip_text = true
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.add_theme_font_size_override("font_size",12)
        row.add_child(label)
        var start := Button.new()
        start.name = "BodyTrainingAssign_%s" % str(member.id)
        start.text = "Rèn thân"
        start.custom_minimum_size = Vector2(112,34)
        start.disabled = holders.size() >= slots or hall.status != BuildingSystem.STATUS_ACTIVE
        start.pressed.connect(Callable(self,"_start_body_training_from_building").bind(member.id))
        row.add_child(start)
        shown += 1
    if shown == 0:
        _add_management_section_label("Không có đệ tử V2 rảnh vị trí trong Tông Môn.")
    elif shown >= 12:
        _add_management_section_label("Đang hiển thị 12 đệ tử đầu; danh sách lớn sẽ bổ sung lọc/tìm kiếm.")

func _start_body_training_from_building(disciple_id: StringName) -> void:
    var result := _queue_v2_training("body",disciple_id)
    building_management_feedback = _v2_training_ui_feedback(result,"body")
    _refresh_building_operation_content()

func _release_body_training_from_building(disciple_id: StringName) -> void:
    var result := DiscipleBodyTrainingFacilityV2.release_slot(state,disciple_id)
    building_management_feedback = (
        "Đã trả vị trí Rèn Thân; không trừ hoặc hoàn phí phút đã luyện."
        if bool(result.get("ok",false))
        else _v2_training_ui_feedback(result,"body")
    )
    _refresh_building_operation_content()

func _body_training_operation_text() -> String:
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_BODY_TRAINING)
    if hall == null:
        return "Công trình chưa được khởi tạo trong runtime V2 hiện tại."
    var holders := buildings.active_worker_ids(state,hall)
    var running := 0
    var status_lines: Array[String] = []
    for disciple_id in holders:
        if not state.disciples.has(disciple_id):
            continue
        var disciple: DiscipleState = state.disciples[disciple_id]
        if disciple.current_action == &"TRAIN_BODY":
            running += 1
        var last: Dictionary = disciple.last_decision.get("v2_body_training_result",{})
        var evidence := ""
        if bool(last.get("ok",false)) and last.has("gained"):
            evidence = " · lượt gần nhất +%.0f EXP" % float(last["gained"])
        elif last.has("reason"):
            evidence = " · %s" % _v2_training_ui_feedback(last,"body")
        status_lines.append("• %s: %s%s" % [
            disciple.display_name,SectMapPresentation.action_label(disciple.current_action),evidence
        ])
    var xp_text := str(int(DiscipleBodyTrainingFacilityV2.BASE_BODY_XP_PER_MINUTE))
    if xp_text.length() > 3:
        xp_text = xp_text.insert(xp_text.length() - 3, ".")
    return (
        "RÈN THÂN ĐƯỜNG · Lv%d\n"
        + "Vị trí: %d/%d · đang luyện: %d\n"
        + "Linh Thạch Tông Môn: %d\n"
        + "Phí: %d Linh Thạch / phút mô phỏng\n"
        + "EXP nền: %s EXP/phút (+0,20%% mỗi điểm Căn Cốt)\n"
        + "Lượt đã thanh toán: %d · Linh Thạch đã tiêu: %d\n\n"
        + "ĐỆ TỬ ĐANG PHÂN CÔNG\n%s\n\n"
        + "Bấm Rèn thân chỉ xếp lệnh; phí/EXP phát sinh khi đủ một phút hợp lệ."
    ) % [
        hall.level,holders.size(),buildings.worker_slots(hall),running,
        state.sect.spirit_stones,
        DiscipleBodyTrainingFacilityV2.STONE_COST_PER_MINUTE,
        xp_text,
        int(hall.production_state.get("paid_training_minutes",0)),
        int(hall.production_state.get("spent_spirit_stones",0)),
        "• Trống" if status_lines.is_empty() else "\n".join(status_lines)
    ]

func _building_operation_text(destination: StringName) -> String:
    match destination:
        SectMapPresentation.DEST_MAIN_HALL:
            return _main_hall_operation_text()
        SectMapPresentation.DEST_MINE:
            return _mine_operation_text()
        SectMapPresentation.DEST_LINH_FOREST:
            return _linh_forest_operation_text()
        SectMapPresentation.DEST_ALCHEMY_HALL:
            return _alchemy_operation_text()
        SectMapPresentation.DEST_SPIRIT_FIELD:
            return _spirit_field_operation_text()
        SectMapPresentation.DEST_FORGE:
            return _forge_operation_text()
        SectMapPresentation.DEST_CULTIVATION:
            return _cultivation_operation_text()
        SectMapPresentation.DEST_BODY_TRAINING:
            return _body_training_operation_text()
        SectMapPresentation.DEST_RESIDENCE:
            return _residence_operation_text()
        SectMapPresentation.DEST_MEDICINE:
            return _medicine_operation_text()
        SectMapPresentation.DEST_WAREHOUSE:
            return _warehouse_operation_text()
        SectMapPresentation.DEST_GUIDANCE:
            return _guidance_operation_text()
        SectMapPresentation.DEST_GATE:
            return _gate_operation_text()
        _:
            return "Sân trung tâm. Không có dữ liệu quản lý riêng."

func _guidance_operation_text() -> String:
    var platform := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return "Dẫn Tiên Đài chưa tồn tại trong trạng thái hiện tại."
    var snapshot := recruitment_system.guidance_state_snapshot(state)
    return (
        "TUYỂN MỘ\n"
        + "Đệ tử: %d / %d\n"
        + "Ứng viên đang chờ: %d\n"
        + "Chiêu Mộ Lệnh: %d\n"
        + "Mục tiêu tiếp nhận hôm nay: %d · Đã tạo: %d\n\n"
        + "Nhận hoặc từ chối ứng viên trực tiếp tại đây. Mọi giới hạn sức chứa và hồ sơ V2 do RecruitmentSystem quyết định."
    ) % [
        state.disciples.size(),
        state.sect.disciple_capacity,
        state.recruitment_candidates.size(),
        state.sect.disciple_recruitment_tokens,
        int(snapshot.get("daily_arrival_target", 0)),
        int(snapshot.get("daily_arrivals_generated", 0))
    ]

func _main_hall_operation_text() -> String:
    return (
        "TỔNG QUAN\n"
        + "Đệ tử: %d / %d\n"
        + "Ngân khố: %d\n"
        + "Linh Thạch: %d\n\n"
        + "CHÍNH SÁCH HIỆN TẠI\n"
        + "Lao động: %s\n"
        + "Hậu cần: %s\n"
        + "Trang bị: %s\n\n"
        + "Chọn một hướng ưu tiên để điều chỉnh cách tông môn tự vận hành."
        + ("\n\nKINH TẾ V1: ĐANG BẬT · Lương mẻ đã thanh toán theo giao dịch thực." if state.sect.economy_a_enabled else "")
    ) % [
        state.disciples.size(), state.sect.disciple_capacity,
        state.sect.treasury, state.sect.spirit_stones,
        _work_policy_label(state.sect.work_policy),
        _needs_priority_label(state.sect.needs_priority),
        _equipment_policy_label(state.sect.equipment_policy)
    ]

func _build_alchemy_management() -> void:
    _build_work_management(WorkforceSystem.PROF_ALCHEMY, &"alchemy_crew", "Đội Luyện Đan", "Luyện đan")
    var hall := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if hall == null:
        return
    _add_management_section_label("CÔNG THỨC THƯỜNG TRỰC")
    var enabled := bool(hall.production_state.get("recipe_enabled", true))
    var toggle := Button.new()
    toggle.name = "AlchemyRecipeToggle"
    toggle.text = "Tắt tự luyện" if enabled else "Bật tự luyện"
    toggle.custom_minimum_size = Vector2(170, 34)
    toggle.pressed.connect(Callable(self, "_set_alchemy_recipe_enabled_from_ui").bind(hall.id, not enabled))
    building_management_container.add_child(toggle)

func _set_alchemy_recipe_enabled_from_ui(hall_id: StringName, enabled: bool) -> void:
    var ok := BuildingSystem.new().set_alchemy_recipe_enabled(state, hall_id, enabled)
    building_management_feedback = ("Đã bật tự luyện Hồi Xuân Đan." if enabled else "Đã tắt mẻ mới; mẻ đã commit vẫn hoàn thành.") if ok else "Không thể đổi chính sách Luyện Đan."
    _refresh_building_operation_content()

func _build_healing_pill_controls() -> void:
    _add_management_section_label("HỒI XUÂN ĐAN")
    var available := WarehouseSystem.new().available_quantity(state, NeedsSystem.HEALING_PILL_ID)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var shown := 0
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id != &"sect" or disciple.hp >= disciple.max_hp:
            continue
        var row := _new_management_row(disciple)
        var use := Button.new()
        use.name = "UsePill_%s" % str(disciple.id)
        use.text = "Dùng đan"
        use.custom_minimum_size = Vector2(92, 34)
        use.disabled = available <= 0
        if use.disabled:
            use.tooltip_text = "Không có Hồi Xuân Đan có thể dùng trong Kho."
        use.pressed.connect(Callable(self, "_use_healing_pill_from_ui").bind(disciple.id))
        row.add_child(use)
        shown += 1
    if shown == 0:
        _add_management_section_label("Không có đệ tử bị thương đang ở trong tông.")

func _use_healing_pill_from_ui(disciple_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var before := disciple.hp
    var ok := needs_system.use_healing_pill(state, disciple)
    building_management_feedback = (
        "Đã dùng 1 Hồi Xuân Đan cho %s: HP %.0f → %.0f." % [disciple.display_name, before, disciple.hp]
        if ok else "Không thể dùng Hồi Xuân Đan cho mục tiêu này."
    )
    _refresh_building_operation_content()

func _alchemy_operation_text() -> String:
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if hall == null:
        return "Luyện Đan Điện chưa tồn tại trong trạng thái hiện tại."
    var jobs := buildings.alchemy_jobs(state, hall)
    var lines: Array[String] = []
    for raw_job in jobs:
        var job: Dictionary = raw_job
        var worker_id := StringName(job.get("worker_id", ""))
        var worker_name := str(worker_id)
        if state.disciples.has(worker_id):
            worker_name = state.disciples[worker_id].display_name
        lines.append("• %s · còn %d phút" % [worker_name, maxi(int(job.get("finish_tick", state.tick)) - state.tick, 0)])
    if lines.is_empty():
        lines.append("• Không có mẻ đang luyện")
    var alchemy_registry := AlchemyRecipeRegistry.new()
    var recipe_inputs := alchemy_registry.inputs(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN)
    var herb_need := int(recipe_inputs.get("thanh_linh_thao", 0))
    return (
        "LUYỆN ĐAN ĐIỆN · Lv%d\n"
        + "Chỗ hoạt động: %d/%d · mẻ đang luyện: %d\n"
        + "Công thức thường trực: Hồi Xuân Đan · %s\n"
        + "Thanh Linh Thảo: %s\n"
        + "Hồi Xuân Đan: %s\n"
        + "Công thức: %d Thanh Linh Thảo → 1 Hồi Xuân Đan · nền %d phút\n\n"
        + "MẺ ĐANG CHẠY\n%s"
    ) % [
        hall.level,
        buildings.active_worker_ids(state, hall).size(),
        buildings.worker_slots(hall),
        jobs.size(),
        "BẬT" if bool(hall.production_state.get("recipe_enabled", true)) else "TẮT",
        _warehouse_pair(&"thanh_linh_thao", true),
        _warehouse_pair(&"hoi_xuan_dan", true),
        herb_need,
        alchemy_registry.base_cycle_ticks(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN),
        "\n".join(lines)
    ]

func _linh_forest_operation_text() -> String:
    var members := _disciples_in_work_group(&"forestry_crew")
    var building_system := BuildingSystem.new()
    var forest := building_system.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    var active_ids: Array[StringName] = []
    var slots := 0
    if forest != null:
        active_ids = building_system.active_worker_ids(state, forest)
        slots = building_system.worker_slots(forest)

    var lines: Array[String] = []
    for disciple_value in members:
        if lines.size() >= 5:
            break
        var disciple: DiscipleState = disciple_value
        var level := workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_FORESTRY)
        lines.append("• %s · Lv%d · %s" % [
            disciple.display_name,
            level,
            _resource_job_member_status(disciple, WorkforceSystem.PROF_FORESTRY, active_ids.has(disciple.id))
        ])
    if lines.is_empty():
        lines.append("• Chưa có thành viên Đội Lâm Nghiệp")
    elif members.size() > 5:
        lines.append("• Còn %d người; dùng tìm kiếm bên dưới." % [members.size()-5])
    var production_note := "Chu kỳ legacy: đi tới Linh Lâm → thu hoạch → vận chuyển về Kho."
    if state.sect.economy_a_enabled and forest != null:
        var forest_batch := production_plan_registry.scaled_yield(ProductionPlanRegistry.PLAN_FOREST_LINH_MOC_T1,forest.level)
        var forest_stock := WarehouseSystem.new().quantity(state,&"linh_moc")
        production_note = "Timer V2: %d Linh Mộc/mẻ · nền %d phút · kho %d/%d%s." % [
            forest_batch,
            production_plan_registry.base_cycle_ticks(ProductionPlanRegistry.PLAN_FOREST_LINH_MOC_T1),
            forest_stock,forest_batch*10,
            " · tạm dừng" if forest_stock >= forest_batch*10 else ""
        ]

    return (
        "SẢN XUẤT\n"
        + "Linh Lâm Lv%d\n"
        + "Linh Mộc tồn (dùng): %s\n"
        + "Chỗ hoạt động: %d/%d\n"
        + "Đang làm Lâm Nghiệp: %d\n"
        + "Thành viên đội: %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "%s"
    ) % [
        0 if forest == null else forest.level,
        _warehouse_pair(&"linh_moc"),
        active_ids.size(),
        slots,
        _count_action(&"WORK_FORESTRY"),
        members.size(),
        "\n".join(lines),
        production_note
    ]

func _resource_job_member_status(disciple: DiscipleState, profession_id: StringName, has_active_slot: bool) -> String:
    if state.sect.economy_a_enabled:
        var timer := BuildingSystem.new().active_resource_timer_for_worker(state,disciple.id)
        if not timer.is_empty() and StringName(timer.get("profession_id","")) == profession_id:
            return "Đang sản xuất · còn %d phút" % maxi(int(timer.get("finish_tick",state.tick))-state.tick,0)
    if not has_active_slot:
        return "Chờ chỗ hoạt động"
    var cycle: Dictionary = disciple.work_cycle_state
    var cycle_profession := StringName(cycle.get("profession_id", cycle.get("profession", "")))
    if cycle_profession != profession_id:
        return "Sẵn sàng · %s" % SectMapPresentation.action_label(disciple.current_action)

    var phase := StringName(cycle.get("phase", ""))
    var progress := maxf(float(cycle.get("progress", 0.0)), 0.0)
    match phase:
        &"travel_out":
            return "Đang tới công trình · %.1f" % progress
        &"mining":
            return "Đang khai thác · %.1f" % progress
        &"harvesting":
            return "Đang thu hoạch Linh Mộc · %.1f" % progress
        &"haul_back":
            return "Vận chuyển về kho · %.1f · mang %d" % [
                progress, maxi(int(cycle.get("carried_units", 0)), 0)
            ]
        _:
            return "Sẵn sàng · %s" % SectMapPresentation.action_label(disciple.current_action)

func _mine_operation_text() -> String:
    var members := _disciples_in_work_group(&"mining_crew")
    var building_system := BuildingSystem.new()
    var mine := building_system.primary_building(state, BuildingSystem.TYPE_MINE)
    var active_ids: Array[StringName] = []
    var slots := 0
    if mine != null:
        active_ids = building_system.active_worker_ids(state, mine)
        slots = building_system.worker_slots(mine)

    var lines: Array[String] = []
    var waiting_count := 0
    for disciple_value in members:
        var disciple: DiscipleState = disciple_value
        var level := workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_MINING)
        var is_active := active_ids.has(disciple.id)
        if not is_active:
            waiting_count += 1
        var location := (
            " · điểm %s" % str(disciple.worksite_building_id)
            if disciple.worksite_building_id != &"" else " · điểm mặc định"
        )
        if lines.size() < 5:
            lines.append("• %s · Lv%d · %s%s" % [
                disciple.display_name, level,
                _mining_member_status(disciple, is_active), location
            ])
    if lines.is_empty():
        lines.append("• Chưa có thành viên Đội Khai Khoáng")
    elif members.size() > 5:
        lines.append("• Còn %d người; dùng tìm kiếm bên dưới." % [members.size()-5])

    var upgrade_text := "Ổn định"
    if mine != null and mine.is_upgrading():
        upgrade_text = "Nâng Lv%d→%d · %.0f/%.0f" % [
            mine.level, mine.upgrade_target_level,
            mine.upgrade_progress, mine.upgrade_required_work
        ]
    var production_note := "Chu kỳ legacy: đi tới mỏ → khai thác → vận chuyển về kho."
    if state.sect.economy_a_enabled and mine != null:
        var plan_id := building_system.selected_resource_production_plan(mine)
        var output_id := production_plan_registry.output_resource_id(plan_id)
        var batch := production_plan_registry.scaled_yield(plan_id,mine.level)
        var stock := WarehouseSystem.new().quantity(state,output_id)
        var target := batch * 10
        production_note = "%s: %d/mẻ · nền %d phút · kho %d/%d. %s" % [
            ResourceRegistry.new().display_name(output_id),batch,
            production_plan_registry.base_cycle_ticks(plan_id),stock,target,
            "Tạm dừng khi đạt mục tiêu kho." if stock >= target else "Có thể tiếp tục."
        ]

    return (
        "SẢN XUẤT\n"
        + "Mỏ Lv%d · %s\n"
        + "Thanh Thiết tồn (dùng): %s\n"
        + "Chỗ hoạt động: %d/%d\n"
        + "Đang chờ slot Mỏ: %d\n"
        + "Đang khai khoáng: %d\n"
        + "Thành viên đội: %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "%s"
    ) % [
        0 if mine == null else mine.level,
        upgrade_text,
        _warehouse_pair(&"thanh_thiet"),
        active_ids.size(),
        slots,
        waiting_count,
        _count_action(&"WORK_MINING"),
        members.size(),
        "\n".join(lines),
        production_note
    ]

func _mining_member_status(disciple: DiscipleState, has_active_slot: bool) -> String:
    if state.sect.economy_a_enabled:
        var timer := BuildingSystem.new().active_resource_timer_for_worker(state,disciple.id)
        if not timer.is_empty():
            return "Mẻ timer · còn %d phút" % maxi(int(timer.get("finish_tick",state.tick))-state.tick,0)
    if not has_active_slot:
        return "Chờ chỗ hoạt động"
    var cycle: Dictionary = disciple.work_cycle_state
    if StringName(cycle.get("profession", "")) != WorkforceSystem.PROF_MINING:
        return "Sẵn sàng · %s" % SectMapPresentation.action_label(disciple.current_action)

    var phase := StringName(cycle.get("phase", ""))
    var progress := maxf(float(cycle.get("progress", 0.0)), 0.0)
    match phase:
        &"travel_out":
            return "Đang tới mỏ · %.1f" % progress
        &"mining":
            return "Đang khai thác · %.1f" % progress
        &"haul_back":
            return "Vận chuyển về kho · %.1f · mang %d" % [
                progress, maxi(int(cycle.get("carried_units", 0)), 0)
            ]
        _:
            return "Sẵn sàng · %s" % SectMapPresentation.action_label(disciple.current_action)

func _spirit_field_operation_text() -> String:
    var buildings := BuildingSystem.new()
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        return "Linh Điền chưa tồn tại trong trạng thái hiện tại."

    var plots := buildings.spirit_field_plots(state, field)
    var active_ids := buildings.active_worker_ids(state, field)
    var growing := 0
    var plot_lines: Array[String] = []
    for raw_plot in plots:
        var plot: Dictionary = raw_plot
        var plot_id := str(plot.get("plot_id", "?"))
        if StringName(plot.get("status", "")) != BuildingSystem.PLOT_GROWING:
            plot_lines.append("• %s · Trống" % plot_id)
            continue
        growing += 1
        var crop_id := StringName(plot.get("crop_id", ""))
        var worker_id := StringName(plot.get("assigned_worker_id", ""))
        var worker_name := str(worker_id)
        if state.disciples.has(worker_id):
            worker_name = (state.disciples[worker_id] as DiscipleState).display_name
        var remaining := maxi(int(plot.get("finish_tick", state.tick)) - state.tick, 0)
        plot_lines.append("• %s · %s · %s · còn %d phút · đã trả %d LT" % [
            plot_id,
            spirit_crop_registry.display_name(crop_id),
            worker_name,
            remaining,
            int(plot.get("paid_spirit_stones", 0))
        ])

    var crop_lines: Array[String] = []
    for crop_id in spirit_crop_registry.eligible_crop_ids(field.level):
        var crop_plan := spirit_crop_registry.production_plan_id(crop_id)
        var actual_yield := production_plan_registry.scaled_yield(crop_plan,field.level)
        crop_lines.append("• %s · phí %d LT · nền %d phút · thường %d/ô" % [
            spirit_crop_registry.display_name(crop_id),
            spirit_crop_registry.cost(crop_id),
            spirit_crop_registry.base_cycle_ticks(crop_id),
            actual_yield
        ])

    return (
        "LINH ĐIỀN Lv%d\n"
        + "Chính sách: %s\n"
        + "Linh Thạch Tông Môn: %d\n"
        + "Worker hoạt động: %d/%d · Ô đang trồng: %d/%d\n\n"
        + "CÂY HỢP LỆ\n%s\n\n"
        + "Ô RUỘNG\n%s\n\n"
        + "KHO THU HOẠCH (tồn / dùng)\n"
        + "Linh Cốc: %s\nThanh Linh Thảo: %s\nTử Vân Thảo: %s\n\n"
        + "Lv1–9 dùng AUTO_DEMAND; Cố định/Priority mở từ Lv10 theo authority hiện có."
    ) % [
        field.level,
        _spirit_field_policy_label(field),
        state.sect.spirit_stones,
        active_ids.size(), buildings.worker_slots(field),
        growing, plots.size(),
        "\n".join(crop_lines),
        "\n".join(plot_lines),
        _warehouse_pair(&"linh_coc", true),
        _warehouse_pair(&"thanh_linh_thao", true),
        _warehouse_pair(&"tu_van_thao", true)
    ]

func _spirit_field_policy_label(field: BuildingState) -> String:
    var mode := StringName(field.production_state.get("policy_mode", str(BuildingSystem.FIELD_POLICY_AUTO_DEMAND)))
    match mode:
        BuildingSystem.FIELD_POLICY_FIXED:
            var crop_id := StringName(field.production_state.get("fixed_crop_id", ""))
            return "Cố định · %s" % spirit_crop_registry.display_name(crop_id)
        BuildingSystem.FIELD_POLICY_PRIORITY:
            return "Ưu tiên theo trọng số"
        _:
            return "Tự động theo thiếu hụt"

func _forge_operation_text() -> String:
    var members := _disciples_in_work_group(&"forge_hall")
    var lines: Array[String] = []
    for disciple_value in members:
        var disciple: DiscipleState = disciple_value
        var level := workforce.profession_level(disciple, WorkforceSystem.PROF_FORGING)
        var progress := float(disciple.work_progress.get(str(WorkforceSystem.PROF_FORGING), 0.0))
        lines.append("• %s · Lv%d · tiến độ %.1f/5 · thể lực %.0f · %s" % [
            disciple.display_name, level, progress, disciple.stamina,
            SectMapPresentation.action_label(disciple.current_action)
        ])
    if lines.is_empty():
        lines.append("• Chưa có thành viên Luyện Khí Đường")

    var craftable := 0
    var recipe_ids: Array = EquipmentSystem.RECIPES.keys()
    recipe_ids.sort()
    for raw_id in recipe_ids:
        if equipment_system.can_craft(state, StringName(raw_id)):
            craftable += 1

    return (
        "VẬT LIỆU\n"
        + "Tồn (dùng): Thanh Thiết %s · Linh Mộc %s\n"
        + "Tinh Lang Bì %s · Yêu Đan %s\n"
        + "Điểm hỗ trợ rèn: %d\n"
        + "Công thức có thể luyện: %d / %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "Phân người phụ trách luyện khí và chế tạo trang bị khi đủ nguyên liệu."
    ) % [
        _warehouse_pair(&"thanh_thiet"),
        _warehouse_pair(&"linh_moc"),
        _warehouse_pair(&"tinh_lang_bi"),
        _warehouse_pair(&"yeu_dan"),
        state.sect.forge_support_points,
        craftable, recipe_ids.size(),
        "\n".join(lines)
    ]

func _cultivation_operation_text() -> String:
    var lines: Array[String] = []
    var ready_count := 0
    var v2_gate_count := 0
    var active_count := 0
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var active := disciple.current_action in [&"CULTIVATE", &"BREAKTHROUGH"]
        if active:
            active_count += 1
        var snapshot := _disciple_snapshot(disciple)
        if bool(snapshot.get("authentic_v2", false)):
            # Only the canonical V2 progression snapshot may describe a V2
            # realm/floor/XP. Never fall back to P2, even if V2 is malformed.
            var progression: Dictionary = snapshot.get("progression", {})
            if not bool(progression.get("ready", false)):
                if active:
                    lines.append("• %s · Tu Vi V2: dữ liệu chưa sẵn sàng" % disciple.display_name)
                continue
            var tuvi: Dictionary = progression["cultivation"]
            var at_gate := bool(tuvi.get("at_major_gate", false))
            if at_gate:
                v2_gate_count += 1
            if active or at_gate:
                lines.append("• %s · %s tầng %d · %.0f/%.0f · Thể lực viễn chinh %.0f%s" % [
                    disciple.display_name,
                    str(tuvi["name"]), int(tuvi["floor"]),
                    float(tuvi["xp"]), float(tuvi["required_xp"]),
                    disciple.stamina,
                    " · CHỜ CỔNG ĐẠI CẢNH" if at_gate else ""
                ])
            continue

        # Preserve the established P2 legacy presentation and eligibility.
        var required := cultivation.required_progress(disciple)
        var progress_text := "Viên mãn" if required <= 0.0 else "%.0f/%.0f" % [disciple.cultivation_progress, required]
        var ready := cultivation.can_breakthrough(state, disciple)
        if ready:
            ready_count += 1
        if active or ready:
            lines.append("• %s · %s · %s · thể lực %.0f%s" % [
                disciple.display_name,
                cultivation.stage_name(disciple),
                progress_text,
                disciple.stamina,
                " · CÓ THỂ ĐỘT PHÁ" if ready else ""
            ])
    if lines.is_empty():
        lines.append("• Chưa có ai đang tu luyện hoặc đủ điều kiện đột phá")

    return (
        "Đang tu luyện/phá cảnh: %d\n"
        + "Đủ điều kiện đột phá: %d\n"
        + "Chờ cổng đại cảnh: %d\n\n"
        + "ĐỆ TỬ LIÊN QUAN\n%s\n\n"
        + "Tiến độ tu luyện hiển thị theo hồ sơ từng đệ tử; cổng đại cảnh có điều kiện riêng."
    ) % [active_count, ready_count, v2_gate_count, "\n".join(lines)]

func _residence_operation_text() -> String:
    var population := state.disciples.size()
    var overloaded := population > state.sect.lodging_capacity
    var recovery_pct := NeedsSystem.new().rest_recovery_multiplier(state) * 100.0
    var rest_lines := _action_disciple_lines([&"REST"])
    return (
        "Sức chứa: %d / %d\n"
        + "Tình trạng: %s\n"
        + "Hệ số hồi phục hiện tại: %.0f%%\n"
        + "Vật tư: %d\n"
        + "Đang nghỉ: %d\n\n"
        + "ĐỆ TỬ ĐANG NGHỈ\n%s\n\n"
        + "Gọi đệ tử về nghỉ hoặc mở rộng chỗ ở khi tông môn quá tải."
    ) % [
        population, state.sect.lodging_capacity,
        "QUÁ TẢI" if overloaded else "Ổn định",
        recovery_pct, state.sect.supply_stock,
        _count_action(&"REST"),
        rest_lines
    ]

func _medicine_operation_text() -> String:
    var injured: Array[String] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
        if ratio < 0.72:
            injured.append("• %s · HP %.0f/%.0f · %s" % [
                disciple.display_name, disciple.hp, disciple.max_hp,
                SectMapPresentation.action_label(disciple.current_action)
            ])
    if injured.is_empty():
        injured.append("• Không có đệ tử dưới ngưỡng HP 72%")

    return (
        "Thuốc hậu cần: %d / %d\n"
        + "Hồi Xuân Đan: %s\n"
        + "Vật tư: %d / %d\n"
        + "Đang trị thương: %d\n"
        + "Ưu tiên hậu cần: %s\n"
        + "Đã dùng thuốc: %d · Đã sản xuất: %d\n\n"
        + "NGƯỜI CẦN CHÚ Ý\n%s\n\n"
        + "Điều chỉnh ưu tiên hậu cần để cân bằng thuốc và vật tư theo tình hình hiện tại."
    ) % [
        state.sect.medicine_stock, NeedsSystem.MEDICINE_CAP,
        _warehouse_pair(NeedsSystem.HEALING_PILL_ID, true),
        state.sect.supply_stock, NeedsSystem.SUPPLY_CAP,
        _count_action(&"HEAL"),
        _needs_priority_label(state.sect.needs_priority),
        int(state.sect.needs_stats.get("medicine_used", 0)),
        int(state.sect.needs_stats.get("medicine_produced", 0)),
        "\n".join(injured)
    ]

func _warehouse_operation_text() -> String:
    var storage_count := 0
    var shop_count := 0
    var equipped_count := 0
    for item_value in state.sect.equipment_items.values():
        var item: Dictionary = item_value
        match StringName(item.get("location", "")):
            EquipmentSystem.LOCATION_STORAGE: storage_count += 1
            EquipmentSystem.LOCATION_SHOP: shop_count += 1
            EquipmentSystem.LOCATION_EQUIPPED: equipped_count += 1

    return (
        "TIỀN TỆ\n"
        + "Ngân khố: %d · Linh Thạch: %d\n\n"
        + "SINH HOẠT\n"
        + "Thuốc: %d · Vật tư: %d\n\n"
        + "KHO VẬT LIỆU (tồn / có thể dùng)\n"
        + "Thanh Thiết: %s · Linh Mộc: %s\n"
        + "Tinh Lang Bì: %s · Yêu Đan: %s\n"
        + "Linh Cốc: %s · Thanh Linh Thảo: %s\n"
        + "Tử Vân Thảo: %s · Hồi Xuân Đan: %s\n\n"
        + "TRANG BỊ\n"
        + "Trong kho: %d · Đang bán: %d · Đã trang bị: %d\n\n"
        + "Trang bị và vật tư được tổng hợp tại đây."
    ) % [
        state.sect.treasury, state.sect.spirit_stones,
        state.sect.medicine_stock, state.sect.supply_stock,
        _warehouse_pair(&"thanh_thiet"),
        _warehouse_pair(&"linh_moc"),
        _warehouse_pair(&"tinh_lang_bi"),
        _warehouse_pair(&"yeu_dan"),
        _warehouse_pair(&"linh_coc", true),
        _warehouse_pair(&"thanh_linh_thao", true),
        _warehouse_pair(&"tu_van_thao", true),
        _warehouse_pair(&"hoi_xuan_dan", true),
        storage_count, shop_count, equipped_count
    ]

func _gate_operation_text() -> String:
    var outside: Array[String] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id == &"sect" and not SectMapPresentation.is_outside_flow(disciple.current_action):
            continue
        var location := str(disciple.region_id)
        if disciple.region_id == &"sect":
            location = "Đại Môn"
        outside.append("• %s · %s · %s · HP %.0f/%.0f · TL %.0f" % [
            disciple.display_name,
            SectMapPresentation.action_label(disciple.current_action),
            location,
            disciple.hp, disciple.max_hp, disciple.stamina
        ])
    if outside.is_empty():
        outside.append("• Không có đệ tử trong luồng xuất môn")

    return (
        "Đệ tử ngoài tông: %d\n"
        + "Trong luồng săn/di chuyển/chiến đấu: %d\n"
        + "Vật tư tông môn: %d\n\n"
        + "TÌNH HÌNH XUẤT MÔN\n%s\n\n"
        + "Có thể triệu hồi đệ tử đang ở ngoài tông khi tình hình không an toàn."
    ) % [
        _count_outside(),
        _count_actions([&"HUNT", &"TRAVEL", &"COMBAT", &"LOOT", &"RETURN_SECT"]),
        state.sect.supply_stock,
        "\n".join(outside)
    ]

func _disciples_in_work_group(group_id: StringName) -> Array[DiscipleState]:
    var result: Array[DiscipleState] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id == group_id:
            result.append(disciple)
    return result

func _action_disciple_lines(actions: Array) -> String:
    var lines: Array[String] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if actions.has(disciple.current_action):
            lines.append("• %s · HP %.0f/%.0f · thể lực %.0f" % [
                disciple.display_name, disciple.hp, disciple.max_hp, disciple.stamina
            ])
    return "• Không có" if lines.is_empty() else "\n".join(lines)

func _work_policy_label(policy: StringName) -> String:
    match policy:
        WorkforceSystem.POLICY_PRODUCTION: return "Ưu tiên sản xuất"
        WorkforceSystem.POLICY_CULTIVATION: return "Ưu tiên tu luyện"
        _: return "Cân bằng"

func _needs_priority_label(priority: StringName) -> String:
    match priority:
        NeedsSystem.PRIORITY_MEDICINE: return "Ưu tiên thuốc"
        NeedsSystem.PRIORITY_SUPPLIES: return "Ưu tiên vật tư"
        _: return "Cân bằng"

func _equipment_policy_label(policy: StringName) -> String:
    match policy:
        EquipmentSystem.POLICY_COMBAT: return "Chiến đấu"
        EquipmentSystem.POLICY_FRUGAL: return "Tiết kiệm"
        _: return "Cân bằng"

# G1 map production: each cue is anchored by the real building instance ID,
# not the type's first building. Every snapshot is read-only and bounded.
func _map_worksite_is_supported(building: BuildingState) -> bool:
    return building != null and building.building_type in [
        BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST,BuildingSystem.TYPE_SPIRIT_FIELD
    ]

func _map_worksite_metrics(building: BuildingState) -> Dictionary:
    return {
        "batches":maxi(0,int(building.metrics.get("production_batches",0))),
        "units":maxi(0,int(building.metrics.get("units_produced",0)))
    }

func _seed_map_worksite_receipts() -> void:
    map_worksite_receipt_baseline.clear()
    if state == null:
        return
    for raw_building in state.buildings.values():
        if raw_building is BuildingState and _map_worksite_is_supported(raw_building):
            var building: BuildingState = raw_building
            map_worksite_receipt_baseline[str(building.id)] = _map_worksite_metrics(building)

func _map_worksite_snapshot(building: BuildingState) -> Dictionary:
    if not _map_worksite_is_supported(building) or state == null:
        return {}
    var type_title := _sect_production_type_name(building.building_type)
    var result := {
        "heading":type_title,"worker":"Chưa phân công","detail":"Chưa có người",
        "received":maxi(0,int(building.metrics.get("units_produced",0))),
        "progress":0.0,"active":false,"waiting":false
    }
    var assigned := BuildingSystem.new().assigned_worker_ids(state,building)
    if not assigned.is_empty():
        var assigned_id := StringName(assigned[0])
        result["worker"] = (
            state.disciples[assigned_id].display_name
            if state.disciples.has(assigned_id) else str(assigned_id)
        )
    if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        # resource_timer_jobs does not normalize / migrate state on read.
        var raw_jobs = building.production_state.get("economy_a_jobs",[])
        if raw_jobs is Array:
            for job in raw_jobs:
                if not (job is Dictionary):
                    continue
                var start_tick := int(job.get("started_tick",state.tick))
                var finish_tick := int(job.get("finish_tick",state.tick))
                var total := maxi(1,finish_tick-start_tick)
                var elapsed := clampi(state.tick-start_tick,0,total)
                var output_id := StringName(job.get("resource_id",""))
                var active_worker_id := StringName(job.get("worker_id",""))
                if active_worker_id != &"":
                    result["worker"] = (
                        state.disciples[active_worker_id].display_name
                        if state.disciples.has(active_worker_id) else str(active_worker_id)
                    )
                result["heading"] = "%s · %s" % [type_title,ResourceRegistry.new().display_name(output_id)]
                result["detail"] = "Mẻ ×%d · %s" % [
                    maxi(0,int(job.get("output_quantity",0))),
                    "Chờ nhập kho" if finish_tick <= state.tick else "còn %dp" % (finish_tick-state.tick)
                ]
                # Compact map text keeps BOTH quantity and ETA inside 186px;
                # the authoritative full-detail string remains unchanged.
                result["display_detail"] = "×%s · %s" % [
                    SectProductionWorksiteCue._map_quantity(maxi(0,int(job.get("output_quantity",0)))),
                    "chờ kho" if finish_tick <= state.tick else "%dp" % (finish_tick-state.tick)
                ]
                result["progress"] = 100.0*float(elapsed)/float(total)
                result["active"] = true # Includes newly started 0% jobs.
                result["waiting"] = finish_tick <= state.tick
                return result
        if assigned.is_empty():
            result["detail"] = "Chưa phân công"
        else:
            var total_received := maxi(0,int(building.metrics.get("units_produced",0)))
            # The next line already reports cumulative Warehouse credit.
            # Do not duplicate the same number in the batch-status line.
            result["detail"] = "Chờ mẻ tiếp" if total_received > 0 else "Chưa có mẻ"
        return result
    var plot_data = building.production_state.get("plots",[])
    if not (plot_data is Array):
        result["detail"] = "Chờ đồng bộ ô đất"
        return result
    if not building.production_state.has("plots"):
        result["detail"] = "Chưa đồng bộ ô đất"
        return result
    var growing := 0
    var nearest: Dictionary = {}
    for raw_plot in plot_data:
        if not (raw_plot is Dictionary):
            continue
        var plot: Dictionary = raw_plot
        if StringName(plot.get("status","")) != BuildingSystem.PLOT_GROWING:
            continue
        growing += 1
        if nearest.is_empty() or int(plot.get("finish_tick",0)) < int(nearest.get("finish_tick",0)):
            nearest = plot
    result["heading"] = "Linh Điền · %d/%d ô" % [growing,plot_data.size()]
    if nearest.is_empty():
        result["detail"] = "Chưa trồng" if not assigned.is_empty() else "Chưa phân công"
        return result
    var plot_worker_id := StringName(nearest.get("assigned_worker_id",""))
    if plot_worker_id != &"":
        result["worker"] = (
            state.disciples[plot_worker_id].display_name
            if state.disciples.has(plot_worker_id) else str(plot_worker_id)
        )
    var start_tick := int(nearest.get("started_tick",state.tick))
    var finish_tick := int(nearest.get("finish_tick",state.tick))
    var total := maxi(1,finish_tick-start_tick)
    var elapsed := clampi(state.tick-start_tick,0,total)
    # routine_yield is the baseline, not a claim about future rare harvest.
    result["detail"] = "Thường ×%d · %s" % [
        maxi(0,int(nearest.get("routine_yield",0))),
        "Chờ nhập kho" if finish_tick <= state.tick else "còn %dp" % (finish_tick-state.tick)
    ]
    result["display_detail"] = "%s ×%s · %s" % [
        spirit_crop_registry.display_name(StringName(nearest.get("crop_id",""))),
        SectProductionWorksiteCue._map_quantity(maxi(0,int(nearest.get("routine_yield",0)))),
        "chờ kho" if finish_tick <= state.tick else "%dp" % (finish_tick-state.tick)
    ]
    result["progress"] = 100.0*float(elapsed)/float(total)
    result["active"] = true
    result["waiting"] = finish_tick <= state.tick
    return result

func _map_worksite_deliveries() -> Dictionary:
    var deliveries := {}
    if state == null:
        return deliveries
    for raw_building in state.buildings.values():
        if not (raw_building is BuildingState):
            continue
        var building: BuildingState = raw_building
        if not _map_worksite_is_supported(building):
            continue
        var key := str(building.id)
        var current := _map_worksite_metrics(building)
        if map_worksite_receipt_baseline.has(key):
            var previous: Dictionary = map_worksite_receipt_baseline[key]
            # BuildingSystem increments BOTH only after Warehouse credit.
            # On save/reload we seed baseline, so no old receipts replay.
            if (
                int(current["batches"]) > int(previous.get("batches",0))
                and int(current["units"]) > int(previous.get("units",0))
            ):
                deliveries[key] = int(current["units"])-int(previous.get("units",0))
        map_worksite_receipt_baseline[key] = current
    return deliveries

# Cards use constant SCREEN pixels even when the isometric world zooms.
# Try above the building first, otherwise below; horizontally clamp at the
# camera edge. Skip overlapping low-priority cards rather than covering work.
func _map_worksite_layout_for_anchor(anchor: Vector2, occupied: Array) -> Dictionary:
    var zoom := maxf(map_layer.scale.x,0.1)
    var screen := SectMapCamera.world_to_screen(anchor,map_layer.position,zoom)
    var card := SectProductionWorksiteCue.CARD_SIZE
    var bounds := SectMapCamera.VIEW_RECT.grow(-6.0)
    var left := clampf(screen.x-card.x*0.5,bounds.position.x,bounds.end.x-card.x)
    for top in [screen.y-card.y-43.0,screen.y+22.0]:
        var box := Rect2(Vector2(left,top),card)
        if not bounds.encloses(box):
            continue
        var collides := false
        for used in occupied:
            if used is Rect2 and box.grow(5.0).intersects(used):
                collides = true
                break
        if not collides:
            return {"offset":box.position-screen,"rect":box}
    return {}

# Keep read-only world badges out from behind operational panels. A selected
# production panel always carries the same exact-ID timeline if a badge is hidden.
func _map_worksite_panel_exclusions() -> Array:
    var blocked: Array = []
    for panel in [building_operation_panel,disciple_summary_panel,sect_hub_panel,workforce_picker_panel]:
        if panel is Control and is_instance_valid(panel) and panel.visible:
            blocked.append(Rect2(panel.global_position,panel.size).grow(4.0))
    return blocked

# Reposition at most ten cached lightweight widgets during camera tweens.
# Avoid any building scans, production reads or UI node allocation per frame.
func _reflow_map_worksite_cues() -> void:
    if map_layer == null:
        return
    var zoom := maxf(map_layer.scale.x,0.1)
    if is_equal_approx(zoom,map_worksite_last_scale):
        return
    map_worksite_last_scale = zoom
    for key in map_worksite_cues.keys():
        var cue := map_worksite_cues[key] as SectProductionWorksiteCue
        if cue == null or not is_instance_valid(cue):
            continue
        cue.scale = Vector2.ONE / zoom
        cue.position = Vector2(map_worksite_anchors.get(key,Vector2.ZERO)) + (
            Vector2(map_worksite_screen_offsets.get(key,Vector2.ZERO)) / zoom
        )

func _refresh_map_worksite_cues() -> void:
    if state == null or map_layer == null or iso_world == null:
        return
    var deliveries := _map_worksite_deliveries()
    var candidates: Array[Dictionary] = []
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building: BuildingState = state.buildings[raw_id]
        if not _map_worksite_is_supported(building):
            continue
        var anchor := SectIsometricWorldV1.virtual_legacy_point(building.building_type,building.id)
        var screen := SectMapCamera.world_to_screen(anchor,map_layer.position,map_layer.scale.x)
        # Labels stay in the legacy world overlay and transform with the map.
        # Keep only visible, important producers to avoid 100 UI cards.
        if not SectMapCamera.VIEW_RECT.grow(95.0).has_point(screen):
            continue
        var snapshot := _map_worksite_snapshot(building)
        var attention := 0
        if building.id == selected_production_instance_id:
            attention = 4
        elif deliveries.has(str(building.id)):
            attention = 3
        elif bool(snapshot.get("active",false)):
            # A 0% freshly started mẻ is just as real as a 99% mẻ.
            attention = 2
        else:
            var prior_cue := map_worksite_cues.get(str(building.id)) as SectProductionWorksiteCue
            if prior_cue != null and is_instance_valid(prior_cue) and prior_cue.receipt != null and prior_cue.receipt.visible:
                # Do not hide an authentic delivery popup when the batch ends.
                attention = 3
        candidates.append({"building":building,"anchor":anchor,"snapshot":snapshot,"priority":attention})
    candidates.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        if int(a["priority"]) != int(b["priority"]):
            return int(a["priority"]) > int(b["priority"])
        var one: BuildingState = a["building"]
        var two: BuildingState = b["building"]
        return str(one.id) < str(two.id)
    )
    var retained := {}
    var occupied: Array = _map_worksite_panel_exclusions()
    var idle_shown := 0
    for entry in candidates:
        if retained.size() >= MAP_WORKSITE_MAX_CUES:
            break
        # Most idle sites are discoverable from the existing production board.
        # Two small idle previews are enough; the map belongs to active work.
        if int(entry["priority"]) == 0 and idle_shown >= 2:
            continue
        var building: BuildingState = entry["building"]
        var key := str(building.id)
        var anchor := Vector2(entry["anchor"])
        var layout := _map_worksite_layout_for_anchor(anchor,occupied)
        if layout.is_empty():
            continue
        if int(entry["priority"]) == 0:
            idle_shown += 1
        occupied.append(layout["rect"])
        map_worksite_anchors[key] = anchor
        map_worksite_screen_offsets[key] = layout["offset"]
        var cue := map_worksite_cues.get(key) as SectProductionWorksiteCue
        if cue == null or not is_instance_valid(cue):
            cue = SectProductionWorksiteCue.new()
            cue.name = "MapWorksite_%s" % key
            map_layer.add_child(cue)
            cue.z_index = 9
            map_worksite_cues[key] = cue
        var actual_zoom := maxf(map_layer.scale.x,0.1)
        cue.scale = Vector2.ONE / actual_zoom
        cue.position = anchor + Vector2(layout["offset"]) / actual_zoom
        cue.display(entry["snapshot"])
        if deliveries.has(key):
            cue.show_delivered(int(deliveries[key]))
        retained[key] = true
    for key in map_worksite_cues.keys():
        if retained.has(key):
            continue
        var old_cue := map_worksite_cues[key] as SectProductionWorksiteCue
        if old_cue != null and is_instance_valid(old_cue):
            old_cue.queue_free()
        map_worksite_cues.erase(key)
        map_worksite_anchors.erase(key)
        map_worksite_screen_offsets.erase(key)
    map_worksite_last_scale = maxf(map_layer.scale.x,0.1)

func _refresh_all() -> void:
    super._refresh_all()
    _refresh_map_worksite_cues()
    if _building_operation_is_open() and workforce_picker_panel == null:
        _refresh_building_operation_content()
    if sect_hub_panel != null and is_instance_valid(sect_hub_panel) and sect_hub_panel.visible:
        # Planning geometry is immutable and has no runtime job output to poll.
        # A production board is dynamic: real scheduler ticks change ETA and
        # work status; refresh only the current bounded/paged board.
        if sect_production_board_open:
            _refresh_sect_production_board()
        elif not sect_layout_preview_open:
            _refresh_sect_hub()

func _process(_delta: float) -> void:
    if iso_world != null:
        # Synchronize every animated camera tween frame with old actor overlay.
        if iso_world.set_legacy_transform(map_layer.scale.x,map_layer.position):
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
        if state != null and state.building_event_count != iso_building_count:
            iso_building_count = state.building_event_count
            iso_world.refresh_from_state(state)
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    _reflow_map_worksite_cues()
    _refresh_living_cue_positions()

func _build_living_cue_layer() -> void:
    living_cue_layer = LivingCueLayer.new()
    living_cue_layer.name = "LivingCueLayer"
    living_cue_layer.position = Vector2.ZERO
    living_cue_layer.size = SectMapCamera.WORLD_SIZE
    living_cue_layer.cue_pressed.connect(_on_living_cue_pressed)
    map_layer.add_child(living_cue_layer)

func _refresh_living_cues() -> void:
    if living_cue_layer == null or not is_instance_valid(living_cue_layer):
        return

    var candidates := living_cue_resolver.resolve_state_cues(state, cultivation, equipment_system)
    var events := living_cue_tracker.observe(state, Time.get_ticks_msec())
    candidates.append_array(events)

    var candidate_anchors := _living_cue_anchor_positions(candidates)
    var camera_center := SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5
    for cue_value in candidates:
        var cue: Dictionary = cue_value
        var key := str(cue.get("stable_key", ""))
        var anchor := Vector2(candidate_anchors.get(key, Vector2.ZERO))
        var screen_point := SectMapCamera.world_to_screen(anchor, map_layer.position, map_zoom)
        cue["in_view"] = SectMapCamera.VIEW_RECT.has_point(screen_point)
        cue["distance_to_camera"] = screen_point.distance_to(camera_center)

    visible_living_cues = living_cue_resolver.select_visible(candidates, 3)
    living_cue_layer.show_cues(visible_living_cues, _living_cue_anchor_positions(visible_living_cues))

func _refresh_living_cue_positions() -> void:
    if living_cue_layer == null or not is_instance_valid(living_cue_layer) or visible_living_cues.is_empty():
        return
    living_cue_layer.refresh_positions(visible_living_cues, _living_cue_anchor_positions(visible_living_cues))

func _living_cue_anchor_positions(cues: Array[Dictionary]) -> Dictionary:
    var positions: Dictionary = {}
    for cue_value in cues:
        var cue: Dictionary = cue_value
        var key := str(cue.get("stable_key", ""))
        if key == "":
            continue

        var target_kind := StringName(cue.get("target_kind", ""))
        var target_id := StringName(cue.get("target_id", ""))
        if target_kind == LivingCueResolver.TARGET_DISCIPLE:
            var actor_key := str(target_id)
            if actor_nodes.has(actor_key):
                var actor := actor_nodes[actor_key] as Control
                if actor != null and is_instance_valid(actor):
                    positions[key] = actor.position + actor.size * 0.5
                    continue
        elif target_kind == LivingCueResolver.TARGET_BUILDING:
            positions[key] = SectMapPresentation.position_for_destination(target_id)
            continue

        positions[key] = SectMapPresentation.position_for_destination(SectMapPresentation.DEST_COURTYARD)
    return positions

func _on_living_cue_pressed(cue: Dictionary) -> void:
    var target_kind := StringName(cue.get("target_kind", ""))
    var target_id := StringName(cue.get("target_id", ""))
    if target_kind == LivingCueResolver.TARGET_DISCIPLE:
        _open_disciple(target_id)
    elif target_kind == LivingCueResolver.TARGET_BUILDING:
        _open_building(target_id)

func _build_disciple_summary_panel() -> void:
    disciple_summary_panel = Panel.new()
    disciple_summary_panel.name = "DiscipleSummaryPanel"
    disciple_summary_panel.position = Vector2(956, 80)
    disciple_summary_panel.size = Vector2(308, 552)
    disciple_summary_panel.z_index = 60
    disciple_summary_panel.visible = false
    disciple_summary_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    disciple_summary_panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 14))
    add_child(disciple_summary_panel)

    disciple_summary_initial = _label(disciple_summary_panel, "?", Vector2(16, 16), Vector2(56, 56), 32)
    disciple_summary_initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    disciple_summary_initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    disciple_summary_initial.add_theme_color_override("font_color", JADE_DARK)

    disciple_summary_name = _label(disciple_summary_panel, "", Vector2(82, 14), Vector2(172, 30), 20)
    disciple_summary_name.add_theme_color_override("font_color", INK)

    disciple_summary_meta = _label(disciple_summary_panel, "", Vector2(82, 44), Vector2(176, 34), 12)
    disciple_summary_meta.add_theme_color_override("font_color", CINNABAR.darkened(0.12))

    var close := Button.new()
    close.name = "CloseSummary"
    close.text = "×"
    close.position = Vector2(250, 12)
    close.size = Vector2(44, 44)
    close.add_theme_font_size_override("font_size", 20)
    close.add_theme_stylebox_override("normal", _style(Color(0.86, 0.80, 0.66, 1.0), INK, 1, 16))
    close.pressed.connect(Callable(self, "_close_disciple_summary").bind(true))
    disciple_summary_panel.add_child(close)

    var separator := HSeparator.new()
    separator.position = Vector2(14, 82)
    separator.size = Vector2(280, 2)
    disciple_summary_panel.add_child(separator)

    disciple_summary_body = _label(disciple_summary_panel, "", Vector2(16, 94), Vector2(276, 294), 13)
    disciple_summary_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    disciple_summary_body.add_theme_color_override("font_color", INK)

    _add_summary_order_button("Tu luyện", Vector2(16, 398), Vector2(88, 38), WorkforceSystem.COMMAND_CULTIVATE)
    _add_summary_order_button("Nghỉ", Vector2(110, 398), Vector2(82, 38), WorkforceSystem.COMMAND_REST)
    _add_summary_order_button("Về tông", Vector2(198, 398), Vector2(94, 38), WorkforceSystem.COMMAND_RETURN_SECT)
    _add_summary_order_button("Khai khoáng", Vector2(16, 442), Vector2(132, 38), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_MINING))
    # Authentic V2 selects an actual Mine/Forest/Field instance instead of
    # issuing a generic historical Mine command without a worksite.
    var quick_assign := Button.new()
    quick_assign.name = "SummaryQuickAssignment"
    quick_assign.text = "Phân công"
    quick_assign.position = Vector2(16,442)
    quick_assign.size = Vector2(132,38)
    quick_assign.add_theme_font_size_override("font_size",13)
    quick_assign.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,8))
    quick_assign.add_theme_color_override("font_color",PAPER_LIGHT)
    quick_assign.visible = false
    quick_assign.pressed.connect(_open_selected_disciple_quick_assignment)
    disciple_summary_panel.add_child(quick_assign)
    _add_summary_order_button("Luyện khí", Vector2(160, 442), Vector2(132, 38), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_FORGING))
    # V2 only: a real paid Body-training command replaces the legacy forge
    # shortcut at the same location. It does not act as a free EXP button.
    var body_button := Button.new()
    body_button.name = "SummaryV2BodyTraining"
    body_button.text = "Rèn thân"
    body_button.position = Vector2(160, 442)
    body_button.size = Vector2(132, 38)
    body_button.add_theme_font_size_override("font_size", 12)
    body_button.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), Color(0.45, 0.37, 0.25, 1.0), 1, 7))
    body_button.pressed.connect(_issue_v2_summary_body)
    body_button.visible = false
    disciple_summary_panel.add_child(body_button)

    var detail := Button.new()
    detail.name = "OpenDiscipleDetail"
    detail.text = "Xem chi tiết"
    detail.position = Vector2(16, 494)
    detail.size = Vector2(276, 42)
    detail.add_theme_font_size_override("font_size", 14)
    detail.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 9))
    detail.add_theme_stylebox_override("hover", _style(CINNABAR.lightened(0.08), GOLD, 3, 9))
    detail.pressed.connect(_open_selected_disciple_detail)
    disciple_summary_panel.add_child(detail)

    var return_button := Button.new()
    return_button.name = "ReturnToWorkforce"
    return_button.text = "← Công trình"
    return_button.position = Vector2(16,494)
    return_button.size = Vector2(130,44)
    return_button.visible = false
    return_button.add_theme_color_override("font_color",INK)
    return_button.add_theme_stylebox_override("normal",_style(Color(0.88,0.82,0.67),INK,1,8))
    return_button.pressed.connect(_return_to_workforce_building)
    disciple_summary_panel.add_child(return_button)

func _add_summary_order_button(text: String, pos: Vector2, button_size: Vector2, kind: StringName, target: String = "") -> void:
    var button := Button.new()
    button.text = text
    if kind == WorkforceSystem.COMMAND_WORK and target == str(WorkforceSystem.PROF_FORGING):
        button.name = "SummaryLegacyForge"
    if kind == WorkforceSystem.COMMAND_WORK and target == str(WorkforceSystem.PROF_MINING):
        button.name = "SummaryLegacyMining"
    button.position = pos
    button.size = button_size
    button.add_theme_font_size_override("font_size", 12)
    button.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), Color(0.45, 0.37, 0.25, 1.0), 1, 7))
    button.add_theme_stylebox_override("hover", _style(Color(0.97, 0.88, 0.64, 1.0), GOLD, 2, 7))
    button.pressed.connect(Callable(self, "_issue_summary_order").bind(kind, target, text))
    disciple_summary_panel.add_child(button)

func _disciple_summary_is_open() -> bool:
    return disciple_summary_panel != null and is_instance_valid(disciple_summary_panel) and disciple_summary_panel.visible

func _show_disciple_summary() -> void:
    if disciple_summary_panel == null or selected_id == &"" or not state.disciples.has(selected_id):
        return
    disciple_summary_panel.visible = true
    var return_button := disciple_summary_panel.get_node("ReturnToWorkforce") as Button
    return_button.visible = workforce_return_building_id != &""
    var detail_button := disciple_summary_panel.get_node("OpenDiscipleDetail") as Button
    detail_button.position.x = 154 if return_button.visible else 16
    detail_button.size.x = 138 if return_button.visible else 276
    if camera_controls_panel != null:
        camera_controls_panel.visible = false
    if camera_hint != null:
        camera_hint.visible = false
    _refresh_disciple_summary_content()

func _hide_disciple_summary() -> void:
    if disciple_summary_panel != null:
        disciple_summary_panel.visible = false
    if camera_controls_panel != null:
        camera_controls_panel.visible = true
    if camera_hint != null:
        camera_hint.visible = true

func _close_disciple_summary(clear_selection: bool = true) -> void:
    _hide_disciple_summary()
    summary_feedback = ""
    if not clear_selection:
        return
    workforce_return_building_id = &""
    selected_id = &""
    deep_restore_summary = false
    if focused_kind == &"disciple":
        focused_kind = &""
        focused_id = &""
        focused_label = ""
        has_focus_target = false
        if focus_marker != null:
            focus_marker.visible = false
        if focus_target_button != null:
            focus_target_button.disabled = true
        _refresh_focus_readout()


func _refresh_disciple_summary_content() -> void:
    if not _disciple_summary_is_open() or selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    var snapshot := _disciple_snapshot(disciple)
    disciple_summary_initial.text = disciple.display_name.substr(0, 1)
    disciple_summary_name.text = disciple.display_name
    if not bool(snapshot.get("ok", false)):
        disciple_summary_meta.text = "Dữ liệu chưa sẵn sàng"
        disciple_summary_body.text = "Không thể đọc hồ sơ đệ tử hiện tại."
        return

    var authentic_v2 := bool(snapshot.get("authentic_v2", false))
    var legacy_forge: Button = disciple_summary_panel.get_node_or_null("SummaryLegacyForge")
    var legacy_mine: Button = disciple_summary_panel.get_node_or_null("SummaryLegacyMining")
    var v2_quick: Button = disciple_summary_panel.get_node_or_null("SummaryQuickAssignment")
    var v2_body: Button = disciple_summary_panel.get_node_or_null("SummaryV2BodyTraining")
    if legacy_forge != null:
        legacy_forge.visible = not authentic_v2
    if legacy_mine != null:
        legacy_mine.visible = not authentic_v2
    if v2_quick != null:
        v2_quick.visible = authentic_v2
    if v2_body != null:
        v2_body.visible = authentic_v2
    var identity: Dictionary = snapshot["identity"]
    var quality := str(identity.get("quality_name", "—"))
    if quality.is_empty():
        quality = "—"
    if bool(snapshot.get("authentic_v2", false)):
        var progression: Dictionary = snapshot["progression"]
        if bool(progression.get("ready", false)):
            var tuvi: Dictionary = progression["cultivation"]
            disciple_summary_meta.text = "%s · %s tầng %d" % [
                quality, str(tuvi["name"]), int(tuvi["floor"])
            ]
        else:
            disciple_summary_meta.text = "%s · Tiến độ chưa sẵn sàng" % quality
    else:
        disciple_summary_meta.text = "%s · %s" % [quality, cultivation.stage_name(disciple)]
    disciple_summary_body.text = _disciple_summary_text(disciple)
    if authentic_v2 and state.sect.economy_a_enabled:
        disciple_summary_meta.text += " · %d Linh Thạch cá nhân" % disciple.spirit_stones


func _disciple_summary_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc hồ sơ đệ tử."
    if bool(snapshot.get("authentic_v2", false)):
        return _v2_disciple_summary_text(snapshot)

    var required := cultivation.required_progress(disciple)
    var cultivation_text := "Đã viên mãn" if required <= 0.0 else "%.0f / %.0f" % [disciple.cultivation_progress, required]
    var destination := StringName(actor_destinations.get(str(disciple.id), str(SectMapPresentation.DEST_COURTYARD)))
    var power := cultivation.effective_combat_power(state, disciple)

    var technique_text := "Chưa chọn"
    if disciple.active_technique_id != &"":
        technique_text = technique_system.technique_name(disciple.active_technique_id)

    var bloodline_text := "—"
    var bloodline_profile := bloodlines.profile_for(state, disciple.id)
    if not bloodline_profile.is_empty():
        if bool(bloodline_profile.get("revealed", false)):
            var bloodline_id := StringName(bloodline_profile.get("bloodline_id", "none"))
            bloodline_text = bloodlines.bloodline_name(bloodline_id)
        else:
            bloodline_text = "Chưa xác định"

    var physique_text := "—"
    var physique_profile := physiques.profile_for(state, disciple.id)
    if not physique_profile.is_empty():
        physique_text = physiques.display_physique(state, disciple.id)

    var command_text := _direct_command_label(disciple)
    var feedback := ""
    if summary_feedback != "":
        feedback = "\n%s" % summary_feedback

    return (
        "HP %.0f/%.0f  ·  Thể lực %.0f/100\n"
        + "Tu vi: %s\n"
        + "Đang làm: %s\n"
        + "Vị trí: %s\n"
        + "Nhóm việc: %s\n\n"
        + "Chiến lực: %.1f\n"
        + "Công pháp: %s\n"
        + "Huyết Mạch: %s\n"
        + "Thể Chất: %s\n\n"
        + "Lệnh Tông Chủ: %s%s"
    ) % [
        disciple.hp, disciple.max_hp, disciple.stamina,
        cultivation_text,
        SectMapPresentation.action_label(disciple.current_action),
        _building_name(destination),
        _work_group_label(disciple),
        power,
        technique_text,
        bloodline_text,
        physique_text,
        command_text,
        feedback
    ]


func _disciple_snapshot(disciple: DiscipleState) -> Dictionary:
    return DisciplePresentationSnapshotV2.build(state, disciple)

func _v2_disciple_summary_text(snapshot: Dictionary) -> String:
    var life: Dictionary = snapshot["life"]
    var progression: Dictionary = snapshot["progression"]
    var injury_text := "Thương Thế: Khỏe mạnh" if int(life.get("injury_level",0)) == 0 else ("Thương Thế: Đang hồi phục · %d phút mô phỏng" % int(life.get("injury_remaining_ticks",0)))
    if not bool(progression.get("ready", false)):
        return (
            "HP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n"
            + "Tu Vi/Luyện Thể: dữ liệu chưa sẵn sàng\n"
            + "Đang làm: %s\n"
            + "%s"
        ) % [
            float(life["hp"]), float(life["max_hp"]),
            float(life["expedition_stamina"]),
            SectMapPresentation.action_label(StringName(life["current_action"])),
            injury_text
        ]

    var tuvi: Dictionary = progression["cultivation"]
    var body: Dictionary = progression["body"]
    var combat: Dictionary = snapshot["combat"]
    var atk := 0.0
    var defense := 0.0
    if bool(combat.get("ready", false)):
        var stats: Dictionary = combat["stats"]
        atk = float(stats.get("attack", 0.0))
        defense = float(stats.get("defense", 0.0))
    var innate: Dictionary = snapshot["innate"]
    var work: Dictionary = snapshot["work"]
    var destination := StringName(actor_destinations.get(
        str(snapshot["disciple_id"]), str(SectMapPresentation.DEST_COURTYARD)
    ))
    var feedback := ""
    if summary_feedback != "":
        feedback = "\n%s" % summary_feedback

    return (
        "HP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n"
        + "Tu Vi: %s tầng %d · %.0f/%.0f\n"
        + "Luyện Thể: %s tầng %d · %.0f/%.0f\n"
        + "Công %.1f · Thủ %.1f\n"
        + "Đang làm: %s · %s\n"
        + "Nhóm việc: %s\n\n"
        + "Linh Căn: %s\n"
        + "Đặc Chất: %s\n"
        + "Huyết Mạch: %s · Thể Chất: %s\n"
        + "Mệnh Cách: %s\n"
        + "Lệnh Tông Chủ: %s%s\n"
        + "%s"
    ) % [
        float(life["hp"]), float(life["max_hp"]), float(life["expedition_stamina"]),
        str(tuvi["name"]), int(tuvi["floor"]), float(tuvi["xp"]), float(tuvi["required_xp"]),
        str(body["name"]), int(body["floor"]), float(body["xp"]), float(body["required_xp"]),
        atk, defense,
        SectMapPresentation.action_label(StringName(life["current_action"])),
        _building_name(destination),
        _work_group_label_id(StringName(work.get("group_id", ""))),
        _v2_root_brief(innate),
        _v2_trait_brief(innate),
        _v2_identity_brief(innate["bloodline"], "Không"),
        _v2_identity_brief(innate["physique"], "Không"),
        _v2_identity_brief(innate["destiny"], "Không"),
        _direct_command_label_data(work.get("direct_command", {})),
        feedback,
        injury_text
    ]

func _v2_root_brief(innate: Dictionary) -> String:
    var root: Dictionary = innate["spiritual_root"]
    var values: Dictionary = root.get("current_values", {})
    var ids: Array = values.keys()
    ids.sort()
    var parts: Array[String] = []
    for raw_id in ids:
        var row: Dictionary = values[raw_id]
        parts.append("%s %d" % [str(row.get("name", raw_id)), int(row.get("purity", 0))])
    var mutation: Dictionary = root.get("mutation", {})
    if str(mutation.get("status", "")) == "revealed":
        parts.append("Dị Căn %s" % str(mutation.get("name", "?")))
    return " · ".join(parts) if not parts.is_empty() else "—"

func _v2_trait_brief(innate: Dictionary) -> String:
    var rows: Array = innate["traits"].get("visible", [])
    var names: Array[String] = []
    for raw_row in rows:
        if raw_row is Dictionary:
            names.append(str(raw_row.get("name", "?")))
    return " · ".join(names) if not names.is_empty() else "—"

func _v2_identity_brief(row: Dictionary, none_text: String = "Không") -> String:
    match str(row.get("status", "none")):
        "revealed":
            return str(row.get("name", "?"))
        "unrevealed":
            return "Chưa xác định"
        _:
            return none_text

func _work_group_label_id(group_id: StringName) -> String:
    match group_id:
        &"mining_crew": return "Đội Khai Khoáng"
        &"forestry_crew": return "Đội Lâm Nghiệp"
        &"alchemy_crew": return "Đội Luyện Đan"
        &"forge_hall": return "Luyện Khí Đường"
        &"": return "Chưa phân"
        _: return str(group_id)

func _direct_command_label_data(command: Variant) -> String:
    if not (command is Dictionary) or command.is_empty():
        return "Không"
    var kind := StringName(command.get("kind", ""))
    var target := StringName(command.get("target", ""))
    match kind:
        WorkforceSystem.COMMAND_CULTIVATE: return "Tu luyện"
        WorkforceSystem.COMMAND_REST: return "Nghỉ"
        WorkforceSystem.COMMAND_RETURN_SECT: return "Về tông"
        WorkforceSystem.COMMAND_HOLD: return "Giữ tại tông"
        WorkforceSystem.COMMAND_WORK:
            if target == WorkforceSystem.PROF_MINING:
                return "Khai khoáng"
            if target == WorkforceSystem.PROF_FORGING:
                return "Luyện khí"
            if target == WorkforceSystem.PROF_HERBALISM:
                return "Linh thực"
            return "Làm nghề"
        WorkforceSystem.COMMAND_HUNT_REGION: return "Xuất môn"
        _: return str(kind)

func _work_group_label(disciple: DiscipleState) -> String:
    match disciple.work_group_id:
        &"mining_crew": return "Đội Khai Khoáng"
        &"forge_hall": return "Luyện Khí Đường"
        &"herbalism_crew": return "Đội Linh Thực"
        &"": return "Chưa phân"
        _: return str(disciple.work_group_id)

func _direct_command_label(disciple: DiscipleState) -> String:
    if disciple.direct_command.is_empty():
        return "Không"
    var kind := StringName(disciple.direct_command.get("kind", ""))
    var target := StringName(disciple.direct_command.get("target", ""))
    match kind:
        WorkforceSystem.COMMAND_CULTIVATE: return "Tu luyện"
        WorkforceSystem.COMMAND_REST: return "Nghỉ"
        WorkforceSystem.COMMAND_RETURN_SECT: return "Về tông"
        WorkforceSystem.COMMAND_HOLD: return "Giữ tại tông"
        WorkforceSystem.COMMAND_WORK:
            if target == WorkforceSystem.PROF_MINING:
                return "Khai khoáng"
            if target == WorkforceSystem.PROF_FORGING:
                return "Luyện khí"
            return "Làm nghề"
        WorkforceSystem.COMMAND_HUNT_REGION: return "Xuất môn"
        _: return str(kind)

func _issue_summary_order(kind: StringName, target: String, label: String) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    if kind == WorkforceSystem.COMMAND_CULTIVATE and DiscipleRealmProgressV2.owns_v2_progression(disciple):
        summary_feedback = _v2_training_ui_feedback(_queue_v2_training("cultivation"),"cultivation")
        _refresh_disciple_summary_content()
        return
    var ok := workforce.issue_command(state, selected_id, kind, target, 40)
    summary_feedback = "Đã ra lệnh: %s" % label if ok else "Không thể ra lệnh lúc này."
    _refresh_disciple_summary_content()

# Player actions use the same V2 command boundary as scheduler/AI. This
# queues work but never commits XP or economic cost on button press.
func _queue_v2_training(track: String, disciple_id: StringName = &"") -> Dictionary:
    var chosen_id := selected_id if disciple_id == &"" else disciple_id
    if chosen_id == &"" or not state.disciples.has(chosen_id):
        return {"ok":false,"reason":"unknown_training_disciple"}
    var disciple: DiscipleState = state.disciples[chosen_id]
    if not DiscipleRealmProgressV2.owns_v2_progression(disciple):
        return {"ok":false,"reason":"v2_disciple_not_initialized"}
    if track == "cultivation":
        # GP-02A presentation preflight: current_action may be EVALUATE
        # between real Mine/Forest carry-cycle steps. A rejected order must
        # not cancel carried goods or consume a timed job/field reservation.
        if not disciple.work_cycle_state.is_empty():
            return {"ok":false,"reason":"busy_cultivation_work_cycle"}
        var buildings := BuildingSystem.new()
        if buildings.disciple_has_active_spirit_plot(state, disciple.id):
            return {"ok":false,"reason":"busy_spirit_plot"}
        if buildings.disciple_has_active_timed_recipe(state, disciple.id):
            return {"ok":false,"reason":"busy_timed_recipe"}
    if track == "body":
        var slot := DiscipleBodyTrainingFacilityV2.reserve_slot(state,chosen_id)
        if not bool(slot.get("ok",false)):
            return slot
    var result := DiscipleTrainingActionV2.request_training(state,chosen_id,track)
    if bool(result.get("ok",false)):
        workforce.clear_command(state,disciple)
        DiscipleTrainingPolicyV2.set_policy(
            state,chosen_id,"body_focus" if track == "body" else "cultivation_focus"
        )
    return result

func _v2_training_ui_feedback(result: Dictionary, track: String) -> String:
    if bool(result.get("ok",false)):
        if track == "body":
            return "Đã xếp Rèn Thân Đường. Mỗi phút hợp lệ tiêu 1 Linh Thạch; chưa trừ phí/cộng EXP."
        return "Đã xếp Chuyên Tu. EXP chỉ cộng khi mô phỏng chạy đủ phút."
    var reason := str(result.get("reason","unknown_training_error"))
    match reason:
        "body_training_slots_full":
            return "Rèn Thân Đường đã kín 2 chỗ."
        "insufficient_training_spirit_stones":
            return "Không đủ Linh Thạch Tông Môn để Rèn Thân."
        "body_training_facility_unavailable":
            return "Rèn Thân Đường chưa sẵn sàng."
        "body_training_slot_not_reserved":
            return "Chưa được phân vào vị trí Rèn Thân."
        "training_cannot_interrupt_active_work", "busy_cultivation_work_cycle", "busy_spirit_plot", "busy_timed_recipe":
            return "Đệ tử đang bận; không thể ngắt công việc, vận chuyển hoặc tác vụ giữ chỗ."
        "major_gate_waiting":
            return "Đã tới cổng đại cảnh; cần đột phá trước."
        "training_disciple_not_present", "training_actor_not_available":
            return "Đệ tử không đủ điều kiện hoặc không ở Tông Môn."
        "v2_disciple_not_initialized", "training_profile_not_ready":
            return "Hồ sơ V2 chưa đủ điều kiện."
        _:
            return "Chưa thể thực hiện: %s" % reason

func _issue_v2_summary_body() -> void:
    summary_feedback = _v2_training_ui_feedback(_queue_v2_training("body"),"body")
    _refresh_disciple_summary_content()

func _open_selected_disciple_detail() -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    deep_restore_summary = true
    _open_disciple_deep_screen(selected_id, "Thuộc tính")

# G1.5: fast disciple-to-building assignment. UI-only, no separate
# workforce model: every eventual transfer goes through the existing picker
# and its single-job/canonical-worksite/active-timer guards.
func _open_selected_disciple_quick_assignment() -> void:
    if selected_id != &"":
        _open_disciple_quick_assignment(selected_id)

func _open_disciple_quick_assignment(disciple_id: StringName, preserve_summary_origin: bool = false, feedback_message: String = "") -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var returning_to_summary := _disciple_summary_is_open() or preserve_summary_origin
    selected_id = disciple_id
    _hide_disciple_summary()
    _clear_popup()
    _add_dim()

    var panel := Panel.new()
    panel.name = "DiscipleQuickAssignment"
    panel.position = Vector2(310,87)
    panel.size = Vector2(660,546)
    panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,16))
    popup_layer.add_child(panel)

    var heading := _label(panel,"PHÂN CÔNG · %s" % disciple.display_name,Vector2(22,12),Vector2(475,37),22)
    heading.add_theme_color_override("font_color",JADE_DARK)
    var message := "Chọn công trình đang có. Chỉ người rảnh mới được giao việc." if feedback_message == "" else feedback_message
    var description := _label(panel,message,Vector2(22,51),Vector2(604,29),13)
    description.add_theme_color_override("font_color",INK)
    var back := Button.new()
    back.name = "DiscipleQuickAssignmentBack"
    back.text = "← Hồ sơ"
    back.position = Vector2(514,12)
    back.size = Vector2(125,43)
    back.add_theme_color_override("font_color",INK)
    back.add_theme_stylebox_override("normal",_style(Color(0.88,0.82,0.67),INK,1,8))
    back.pressed.connect(Callable(self,"_return_from_disciple_quick_assignment").bind(disciple_id,returning_to_summary))
    panel.add_child(back)

    var scroll := ScrollContainer.new()
    scroll.name = "DiscipleQuickAssignmentScroll"
    scroll.position = Vector2(22,92)
    scroll.size = Vector2(614,427)
    if _can_cancel_queued_assignment_command(disciple):
        # Explicit player action. Never clear a live timer, Body-training
        # reservation, field plot, PvE encounter or work cycle here.
        var cancel_pending := Button.new()
        cancel_pending.name = "QuickAssignmentCancelPendingCommand"
        cancel_pending.text = "Hủy lệnh chờ"
        cancel_pending.position = Vector2(22,88)
        cancel_pending.size = Vector2(177,42)
        cancel_pending.add_theme_font_size_override("font_size",14)
        cancel_pending.add_theme_stylebox_override("normal",_style(CINNABAR,PAPER_LIGHT,1,8))
        cancel_pending.tooltip_text = "Chỉ hủy lệnh chưa chạy; không xóa sản phẩm, công việc đang chạy hoặc công trình."
        cancel_pending.pressed.connect(
            Callable(self,"_cancel_quick_assignment_pending_command").bind(disciple_id,returning_to_summary)
        )
        panel.add_child(cancel_pending)
        var pending_tip := _label(
            panel,"Đệ tử đang có lệnh chờ. Hủy để chọn công việc mới.",
            Vector2(209,93),Vector2(415,34),12
        )
        pending_tip.add_theme_color_override("font_color",INK)
        scroll.position = Vector2(22,140)
        scroll.size = Vector2(614,379)
    panel.add_child(scroll)
    var rows := VBoxContainer.new()
    rows.name = "DiscipleQuickAssignmentRows"
    rows.custom_minimum_size = Vector2(587,0)
    rows.add_theme_constant_override("separation",8)
    scroll.add_child(rows)

    var count := 0
    var definitions := [
        {"type":BuildingSystem.TYPE_MINE,"name":"MỎ KHOÁNG"},
        {"type":BuildingSystem.TYPE_LINH_FOREST,"name":"LINH LÂM"},
        {"type":BuildingSystem.TYPE_SPIRIT_FIELD,"name":"LINH ĐIỀN"}
    ]
    for item in definitions:
        var building_type := StringName(item["type"])
        var instances := ResourceBuildingExpansionPolicyV2.existing_instances(state,building_type)
        var group_name := Label.new()
        group_name.text = "%s · %d công trình" % [str(item["name"]),instances.size()]
        group_name.add_theme_font_size_override("font_size",16)
        group_name.add_theme_color_override("font_color",CINNABAR)
        rows.add_child(group_name)
        for building in instances:
            count += 1
            var occupants := _workforce_occupants(building)
            var reason := _workforce_candidate_reason(disciple,building,occupants)
            var already_owner := reason == "Đang phụ trách"
            var can_assign := reason == "" or already_owner
            var entry := HBoxContainer.new()
            entry.name = "QuickAssignRow_%s" % str(building.id)
            entry.custom_minimum_size = Vector2(582,56)
            entry.add_theme_constant_override("separation",8)
            rows.add_child(entry)
            var info := Label.new()
            info.name = "QuickAssignStatus_%s" % str(building.id)
            var busy_worker := ""
            if occupants.size() == 1 and state.disciples.has(occupants[0]):
                busy_worker = state.disciples[occupants[0]].display_name
            var occupation := "Chưa có người" if occupants.is_empty() else (
                busy_worker if busy_worker != "" else "%d người" % occupants.size()
            )
            info.text = "%s · Lv%d · %s\n%s" % [
                str(building.id),building.level,occupation,
                ("Đang phụ trách" if already_owner else "Có thể nhận việc" if reason == "" else reason)
            ]
            info.custom_minimum_size = Vector2(448,52)
            info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            info.add_theme_font_size_override("font_size",12)
            info.add_theme_color_override("font_color",INK)
            entry.add_child(info)
            var choose := Button.new()
            choose.name = "QuickAssignTarget_%s" % str(building.id)
            choose.text = "Xem" if already_owner else "Giao việc"
            choose.custom_minimum_size = Vector2(125,46)
            choose.disabled = not can_assign
            choose.tooltip_text = "Mở công trình đang phụ trách" if already_owner else (
                "Phân công qua Workforce V2" if reason == "" else reason
            )
            choose.add_theme_font_size_override("font_size",13)
            choose.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,8))
            choose.add_theme_color_override("font_color",PAPER_LIGHT)
            choose.pressed.connect(Callable(self,"_disciple_quick_assign_target").bind(disciple_id,building.id))
            entry.add_child(choose)
    if count == 0:
        var empty := Label.new()
        empty.text = "Chưa có Mỏ / Linh Lâm / Linh Điền. Không thể phân công."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        rows.add_child(empty)
    # Three buildings should not leave half the 1280x720 game covered by
    # an empty dialog; many buildings still scroll inside the max height.
    var compact_height := clampf(180.0 + float(count)*83.0,420.0,546.0)
    panel.size.y = compact_height
    scroll.size.y = compact_height-scroll.position.y-18.0
    _ensure_disabled_controls_readable(panel)

func _can_cancel_queued_assignment_command(disciple: DiscipleState) -> bool:
    if disciple == null or disciple.direct_command.is_empty():
        return false
    if disciple.region_id != &"sect" or not disciple.active_pve_encounter_id.is_empty():
        return false
    if not disciple.work_cycle_state.is_empty():
        return false
    if not [&"EVALUATE",&"IDLE",&"HOLD"].has(disciple.current_action):
        return false
    var buildings := BuildingSystem.new()
    if buildings.disciple_has_active_timed_recipe(state,disciple.id):
        return false
    if buildings.disciple_has_active_spirit_plot(state,disciple.id):
        return false
    if DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        return false
    return true

func _cancel_quick_assignment_pending_command(disciple_id: StringName, to_summary: bool) -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not _can_cancel_queued_assignment_command(disciple):
        return
    # The authoritative Workforce method increments the canonical event
    # counter. Do not write direct_command/current_action from presentation.
    workforce.clear_command(state,disciple)
    if not disciple.direct_command.is_empty():
        return
    _open_disciple_quick_assignment(
        disciple_id,to_summary,"Đã hủy lệnh chờ. Chọn công trình phù hợp để nhận việc."
    )

func _return_from_disciple_quick_assignment(disciple_id: StringName, to_summary: bool) -> void:
    if not state.disciples.has(disciple_id):
        _clear_popup()
        return
    _clear_popup()
    selected_id = disciple_id
    if to_summary:
        _show_disciple_summary()
    else:
        _open_disciple_deep_screen(disciple_id,"Thuộc tính")

func _disciple_quick_assign_target(disciple_id: StringName, building_id: StringName) -> void:
    if not state.disciples.has(disciple_id) or not state.buildings.has(str(building_id)):
        return
    var building: BuildingState = state.buildings[str(building_id)]
    var destination := &""
    match building.building_type:
        BuildingSystem.TYPE_MINE:
            destination = SectMapPresentation.DEST_MINE
        BuildingSystem.TYPE_LINH_FOREST:
            destination = SectMapPresentation.DEST_LINH_FOREST
        BuildingSystem.TYPE_SPIRIT_FIELD:
            destination = SectMapPresentation.DEST_SPIRIT_FIELD
    if destination == &"":
        return
    var reason := _workforce_candidate_reason(
        state.disciples[disciple_id],building,_workforce_occupants(building)
    )
    if reason != "" and reason != "Đang phụ trách":
        return
    _open_building(destination)
    selected_production_instance_id = building_id
    _refresh_building_operation_content()
    if reason == "Đang phụ trách":
        return
    # This is exactly the same vetted action as a tap on the existing
    # Worksite picker button, including scheduler/One Active Job guards.
    _open_workforce_picker(building_id)
    _workforce_pick_candidate(disciple_id)


func _open_disciple_deep_screen(disciple_id: StringName, tab_name: String = "Thuộc tính", preserve_feedback: bool = false) -> void:
    if not state.disciples.has(disciple_id):
        return
    selected_id = disciple_id
    opened_disciple_profile = true
    if not preserve_feedback and tab_name != "Huyết Mạch" and tab_name != "Thể Chất":
        tab_status_text = ""
    _refresh_tasks()
    _hide_disciple_summary()
    _clear_popup()
    _add_dim()

    var panel := Panel.new()
    panel.name = "DiscipleDeepScreen"
    panel.position = Vector2(48, 82)
    panel.size = Vector2(1184, 548)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)

    var title := _label(panel, "Hồ sơ đệ tử", Vector2(20, 12), Vector2(220, 34), 23)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    # Direct player shortcut: pick an EXISTING worksite and use the canonical
    # Workforce V2 command (no new slot/job/warehouse authority).
    var quick_assign := Button.new()
    quick_assign.name = "DeepQuickAssignment"
    quick_assign.text = "Phân công"
    quick_assign.position = Vector2(751,12)
    quick_assign.size = Vector2(174,44)
    quick_assign.add_theme_font_size_override("font_size",14)
    quick_assign.add_theme_color_override("font_color",PAPER_LIGHT)
    quick_assign.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,8))
    quick_assign.pressed.connect(Callable(self,"_open_disciple_quick_assignment").bind(disciple_id))
    panel.add_child(quick_assign)

    var back := Button.new()
    back.name = "BackToMapContext"
    back.text = "← Trở lại bản đồ"
    back.position = Vector2(936, 12)
    back.size = Vector2(184, 44)
    back.add_theme_color_override("font_color",INK)
    back.add_theme_color_override("font_hover_color",INK)
    back.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), INK, 1, 8))
    back.pressed.connect(_return_to_disciple_summary)
    panel.add_child(back)

    var close := Button.new()
    close.text = "×"
    close.position = Vector2(1120, 12)
    close.size = Vector2(44, 44)
    close.add_theme_color_override("font_color",INK)
    close.add_theme_font_size_override("font_size", 22)
    close.add_theme_stylebox_override("normal", _style(Color(0.76, 0.70, 0.58, 1.0), INK, 1, 16))
    close.pressed.connect(_return_to_disciple_summary)
    panel.add_child(close)

    var roster_panel := Panel.new()
    roster_panel.position = Vector2(18, 58)
    roster_panel.size = Vector2(184, 464)
    roster_panel.add_theme_stylebox_override("panel", _style(Color(0.86, 0.80, 0.66, 1.0), Color(0.40, 0.31, 0.20, 1.0), 2, 10))
    panel.add_child(roster_panel)

    var roster_search := LineEdit.new()
    roster_search.name = "DiscipleProfileSearch"
    roster_search.position = Vector2(8, 8)
    roster_search.size = Vector2(168, 44)
    roster_search.placeholder_text = "Tên hoặc ID · Enter"
    roster_search.text = disciple_profile_query
    roster_search.tooltip_text = "Tìm theo tên hoặc ID; hiển thị tối đa 50 đệ tử mỗi lượt."
    roster_search.text_submitted.connect(Callable(self,"_set_disciple_profile_search").bind(disciple_id,tab_name))
    roster_panel.add_child(roster_search)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(8, 58)
    scroll.size = Vector2(168, 398)
    roster_panel.add_child(scroll)

    var roster := VBoxContainer.new()
    roster.custom_minimum_size = Vector2(150, 0)
    roster.add_theme_constant_override("separation", 6)
    scroll.add_child(roster)

    var ids: Array = state.disciples.keys()
    ids.sort()
    if disciple_profile_query.is_empty() and ids.has(disciple_id):
        ids.erase(disciple_id)
        ids.push_front(disciple_id)
    var roster_shown := 0
    for raw_id in ids:
        if roster_shown >= DISCIPLE_PROFILE_PAGE_SIZE:
            break
        var id := StringName(raw_id)
        var roster_disciple: DiscipleState = state.disciples[id]
        if not disciple_profile_query.is_empty() and not (
            roster_disciple.display_name.to_lower().contains(disciple_profile_query)
            or str(id).to_lower().contains(disciple_profile_query)
        ):
            continue
        roster_shown += 1
        var entry := Button.new()
        entry.text = "      " + roster_disciple.display_name
        entry.custom_minimum_size = Vector2(148, 44)
        entry.add_theme_font_size_override("font_size", 13)
        entry.add_theme_color_override("font_color",INK)
        entry.add_theme_color_override("font_hover_color",INK)
        var is_selected := id == selected_id
        entry.add_theme_stylebox_override("normal", _style(Color(0.97, 0.90, 0.70, 1.0) if is_selected else Color(0.91, 0.86, 0.72, 1.0), GOLD if is_selected else Color(0.45, 0.37, 0.25, 1.0), 2 if is_selected else 1, 8))
        entry.pressed.connect(Callable(self, "_open_disciple_deep_screen").bind(id, tab_name))
        roster.add_child(entry)
        var avatar := _disciple_avatar_button(roster_disciple,36)
        avatar.name = "DiscipleRosterAvatar_%s" % str(id)
        avatar.position = Vector2(4,4)
        avatar.size = Vector2(36,36)
        avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        entry.add_child(avatar)

    var disciple: DiscipleState = state.disciples[selected_id]

    var showcase := Panel.new()
    showcase.position = Vector2(220, 58)
    showcase.size = Vector2(300, 394)
    showcase.add_theme_stylebox_override("panel", _style(Color(0.76, 0.84, 0.72, 1.0), Color(0.31, 0.40, 0.28, 1.0), 2, 80))
    panel.add_child(showcase)

    var selected_actor := actor_nodes.get(str(disciple.id)) as ModularDiscipleActor
    var selected_source_scene := DiscipleSourceAVisualPool.scene_for_disciple(disciple)
    if selected_source_scene != null and (selected_actor == null or not selected_actor.production_body_active()):
        # Keep the authored foot anchor while fitting each real crop in the
        # same profile art area; all three portrait surfaces use this scene.
        var artwork := selected_source_scene.instantiate() as AnimatedSprite2D
        artwork.name = "DiscipleSourceAArtwork"
        var stand_frame := artwork.sprite_frames.get_frame_texture(&"stand",0)
        var art_size := stand_frame.get_size() if stand_frame != null else Vector2(192,192)
        var art_scale := minf(230.0/maxf(art_size.x,1.0),175.0/maxf(art_size.y,1.0))
        artwork.scale = Vector2.ONE * art_scale
        artwork.position = Vector2(150,185)
        artwork.z_index = 1
        showcase.add_child(artwork)
        artwork.play(&"stand")
    else:
        var initial := _label(showcase, disciple.display_name.substr(0, 1), Vector2(70, 60), Vector2(160, 138), 86)
        initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        initial.add_theme_color_override("font_color", JADE_DARK)
        var art_pending := _label(showcase,"Chưa có chân dung xác minh",Vector2(25,204),Vector2(250,20),12)
        art_pending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        art_pending.add_theme_color_override("font_color",INK)

    var center_name := _label(showcase, disciple.display_name, Vector2(20, 232), Vector2(260, 32), 22)
    center_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center_name.add_theme_color_override("font_color", INK)

    var center_status := _label(showcase, _deep_status_text(disciple), Vector2(22, 272), Vector2(256, 108), 13)
    center_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    center_status.add_theme_color_override("font_color", INK)

    var content_panel := Panel.new()
    content_panel.position = Vector2(538, 58)
    content_panel.size = Vector2(626, 394)
    content_panel.add_theme_stylebox_override("panel", _style(Color(0.93, 0.89, 0.78, 0.76), Color(0.50, 0.42, 0.30, 1.0), 1, 10))
    panel.add_child(content_panel)

    var tab_title := _label(content_panel, tab_name, Vector2(18, 12), Vector2(360, 30), 20)
    tab_title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    # The six-dimensional radar and all tab text consume the same real
    # canonical snapshot. No independent stat generation or persisted UI state.
    var profile_snapshot := _disciple_snapshot(disciple)

    # Make attribute/Body requirements readable without overlapping action row.
    var details_scroll := ScrollContainer.new()
    details_scroll.name = "DiscipleTabContentScroll"
    details_scroll.position = Vector2(18, 52)
    details_scroll.size = Vector2(590, 286)
    content_panel.add_child(details_scroll)
    var content := Label.new()
    content.name = "DiscipleTabContentText"
    content.text = _disciple_tab_text(tab_name, disciple)
    content.custom_minimum_size = Vector2(565, 0)
    content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_theme_font_size_override("font_size", 14)
    content.add_theme_color_override("font_color", INK)
    details_scroll.add_child(content)

    # Read-only G1 six-foundation radar. Reuse full existing text/scroll/actions
    # without changing progression, workforce, equipment or hidden identities.
    if tab_name == "Thuộc tính" and bool(profile_snapshot.get("ok",false)):
        var radar := DiscipleSixDimensionRadar.new()
        radar.name = "DiscipleSixDimensionRadar"
        radar.position = Vector2(18,52)
        radar.size = Vector2(274,286)
        radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        if radar.apply_snapshot(profile_snapshot):
            content_panel.add_child(radar)
            details_scroll.position = Vector2(302,52)
            details_scroll.size = Vector2(306,286)
            content.custom_minimum_size = Vector2(282,0)
            content.add_theme_font_size_override("font_size",13)

    var authentic_v2 := bool(profile_snapshot.get("authentic_v2", false))
    if not authentic_v2:
        if tab_name == "Huyết Mạch":
            _add_tab_action_button(content_panel, "Thức tỉnh", Vector2(18, 344), "bloodline_awaken")
            _add_tab_action_button(content_panel, "Luyện huyết", Vector2(140, 344), "bloodline_refine")
        elif tab_name == "Thể Chất":
            _add_tab_action_button(content_panel, "Tôi thể", Vector2(18, 344), "physique_temper")
            _add_tab_action_button(content_panel, "Cải thể", Vector2(140, 344), "physique_transform")
    elif tab_name == "Thuộc tính":
        _add_tab_action_button(content_panel, "Chuyên tu", Vector2(18, 344), "v2_cultivate")
        _add_tab_action_button(content_panel, "Rèn thân", Vector2(140, 344), "v2_body_train")
        var gate_preview := DiscipleBodyGateTransactionV2.new().preview_gate(state,selected_id)
        var gate_button := Button.new()
        gate_button.name = "BodyGateRealCommit"
        gate_button.text = "Đột phá Luyện Thể"
        gate_button.position = Vector2(266, 344)
        gate_button.size = Vector2(175, 40)
        gate_button.add_theme_font_size_override("font_size", 12)
        gate_button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
        gate_button.disabled = not bool(gate_preview.get("can_commit",false))
        gate_button.tooltip_text = _body_gate_reason(str(gate_preview.get("reason","")))
        gate_button.pressed.connect(Callable(self, "_disciple_tab_action").bind("v2_body_gate"))
        content_panel.add_child(gate_button)

    var tab_names: Array[String] = ["Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    for index in range(tab_names.size()):
        var tab := Button.new()
        tab.text = tab_names[index]
        tab.position = Vector2(220 + index * 154, 470)
        tab.size = Vector2(144, 44)
        tab.add_theme_font_size_override("font_size", 12)
        tab.add_theme_color_override("font_color",INK)
        tab.add_theme_color_override("font_hover_color",INK)
        var active := tab_names[index] == tab_name
        tab.add_theme_stylebox_override("normal", _style(Color(0.97, 0.88, 0.64, 1.0) if active else Color(0.88, 0.82, 0.67, 1.0), GOLD if active else Color(0.45, 0.37, 0.25, 1.0), 2 if active else 1, 7))
        tab.pressed.connect(Callable(self, "_open_disciple_deep_screen").bind(selected_id, str(tab_names[index])))
        panel.add_child(tab)


func _set_disciple_profile_search(query: String, disciple_id: StringName, tab_name: String) -> void:
    disciple_profile_query = query.strip_edges().to_lower()
    _open_disciple_deep_screen(disciple_id,tab_name,true)


func _deep_status_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        var life: Dictionary = snapshot["life"]
        var progression: Dictionary = snapshot["progression"]
        if not bool(progression.get("ready", false)):
            return "Tiến độ chưa sẵn sàng\nHP %.0f/%.0f\n%s" % [
                float(life["hp"]), float(life["max_hp"]),
                SectMapPresentation.action_label(StringName(life["current_action"]))
            ]
        var tuvi: Dictionary = progression["cultivation"]
        var body: Dictionary = progression["body"]
        var destination := StringName(actor_destinations.get(str(disciple.id), str(SectMapPresentation.DEST_COURTYARD)))
        return "%s tầng %d\n%s tầng %d\nHP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n%s · %s" % [
            str(tuvi["name"]), int(tuvi["floor"]),
            str(body["name"]), int(body["floor"]),
            float(life["hp"]), float(life["max_hp"]), float(life["expedition_stamina"]),
            SectMapPresentation.action_label(StringName(life["current_action"])),
            _building_name(destination)
        ]

    var required := cultivation.required_progress(disciple)
    var progress_text := "Đã viên mãn" if required <= 0.0 else "%.0f / %.0f" % [disciple.cultivation_progress, required]
    var destination := StringName(actor_destinations.get(str(disciple.id), str(SectMapPresentation.DEST_COURTYARD)))
    return "%s\nHP %.0f/%.0f · Thể lực %.0f/100\nTu vi %s\n%s · %s" % [
        cultivation.stage_name(disciple),
        disciple.hp, disciple.max_hp, disciple.stamina,
        progress_text,
        SectMapPresentation.action_label(disciple.current_action),
        _building_name(destination)
    ]

func _return_to_disciple_summary() -> void:
    _clear_popup()
    if deep_restore_summary and selected_id != &"" and state.disciples.has(selected_id):
        _restore_selected_focus_marker()
        _show_disciple_summary()
        return
    _close_disciple_summary(true)

func _restore_selected_focus_marker() -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var key := str(selected_id)
    if not actor_nodes.has(key):
        return
    var actor: Control = actor_nodes[key] as Control
    var disciple: DiscipleState = state.disciples[selected_id]
    var point := actor.position + actor.size * 0.5
    _set_focus_target(point, &"disciple", selected_id, disciple.display_name, false)

func _tab_notice(tab_name: String) -> void:
    _open_disciple_tab(tab_name)

func _open_disciple_tab(tab_name: String) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    _open_disciple_deep_screen(selected_id, tab_name)

func _add_tab_action_button(parent: Control, text: String, pos: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = text
    button.position = pos
    button.size = Vector2(112, 40)
    button.add_theme_font_size_override("font_size", 13)
    button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
    button.pressed.connect(Callable(self, "_disciple_tab_action").bind(action))
    parent.add_child(button)


func _disciple_tab_action(action: String) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    var snapshot := _disciple_snapshot(disciple)
    if action == "v2_body_gate":
        var gate := DiscipleBodyGateTransactionV2.new()
        var checked := gate.preview_gate(state,selected_id)
        if not bool(checked.get("can_commit",false)):
            tab_status_text = _body_gate_reason(str(checked.get("reason","body_gate_denied")))
        else:
            var request_id := "ui:body-gate:%s:%d" % [str(selected_id),int(checked["source_realm"])]
            var applied := gate.commit_gate(state,selected_id,request_id)
            tab_status_text = "Đột phá Luyện Thể thành công." if bool(applied.get("ok",false)) else _body_gate_reason(str(applied.get("reason","")))
            if bool(applied.get("ok",false)) and runtime_ready and runtime_session != null:
                var persisted := runtime_session.save()
                if not bool(persisted.get("ok",false)):
                    tab_status_text += " CẢNH BÁO: chưa lưu được tiến độ."
        _open_disciple_deep_screen(selected_id,"Thuộc tính",true)
        return
    if action == "v2_cultivate" or action == "v2_body_train":
        var track := "body" if action == "v2_body_train" else "cultivation"
        tab_status_text = _v2_training_ui_feedback(_queue_v2_training(track),track)
        # Normal tab navigation clears old feedback; this explicit action
        # refresh must retain the real backend receipt/rejection for the player.
        _open_disciple_deep_screen(selected_id,"Thuộc tính",true)
        return
    var requested_tab := "Huyết Mạch" if action.begins_with("bloodline_") else "Thể Chất"
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        tab_status_text = "Cơ chế cũ không áp dụng cho hồ sơ này."
        _open_disciple_tab(requested_tab)
        return

    var result: Dictionary = {}
    var tab_name := "Thuộc tính"
    match action:
        "bloodline_awaken":
            result = bloodlines.awaken_bloodline(state, selected_id)
            tab_name = "Huyết Mạch"
        "bloodline_refine":
            result = bloodlines.refine_bloodline(state, selected_id)
            tab_name = "Huyết Mạch"
        "physique_temper":
            result = physiques.temper_body(state, selected_id)
            tab_name = "Thể Chất"
        "physique_transform":
            result = physiques.transform_body(state, selected_id)
            tab_name = "Thể Chất"
        _:
            return
    tab_status_text = _action_result_text(result)
    _open_disciple_tab(tab_name)

func _action_result_text(result: Dictionary) -> String:
    if result.is_empty():
        return "Không có thay đổi."
    var ok := bool(result.get("ok", false))
    var reason := _player_reason_text(str(result.get("reason", "")))
    return "%s%s" % [
        "Thành công" if ok else "Chưa thể thực hiện",
        "" if reason == "" else " · %s" % reason
    ]

func _player_reason_text(reason: String) -> String:
    match reason:
        "bloodlines_disabled_or_disciple_missing", "physiques_disabled_or_disciple_missing":
            return "Không tìm thấy đệ tử."
        "profile_missing":
            return "Chưa có hồ sơ phù hợp."
        "no_special_bloodline":
            return "Không có huyết mạch đặc biệt để thức tỉnh."
        "bloodline_hidden":
            return "Huyết mạch vẫn chưa được phát hiện."
        "already_awakened":
            return "Huyết mạch đã thức tỉnh."
        "bloodline_not_awakened":
            return "Cần thức tỉnh huyết mạch trước."
        "max_purity":
            return "Độ thuần đã đạt giới hạn."
        "yao_core_missing":
            return "Không đủ Yêu Đan."
        "max_temper_level":
            return "Tôi thể đã đạt giới hạn."
        "already_special_physique":
            return "Đã có thể chất đặc biệt."
        "temper_level_too_low":
            return "Cần tôi thể thêm trước khi cải thể."
        "transformation_target_missing":
            return "Chưa có hướng cải thể phù hợp."
        "spirit_essence_missing":
            return "Không đủ Linh Tủy."
        "awakened":
            return "Huyết mạch đã thức tỉnh."
        "refined":
            return "Độ thuần huyết mạch đã tăng."
        "tempered":
            return "Tôi thể thành công."
        "transformed":
            return "Cải thể thành công."
        _:
            return ""


# F4 pure V2 read model: one selected disciple, no per-roster scans.
func _body_gate_preview_text(disciple_id: StringName) -> String:
    var preview := DiscipleBodyGateTransactionV2.new().preview_gate(state,disciple_id)
    if not bool(preview.get("ok",false)):
        return "Đột phá Luyện Thể: " + _body_gate_reason(str(preview.get("reason","")))
    var lines: Array[String] = []
    lines.append("ĐỘT PHÁ LUYỆN THỂ %d → %d | EXP %.0f / %.0f" % [
        int(preview["source_realm"]),int(preview["target_realm"]),
        float(preview["xp_have"]),float(preview["xp_need"])
    ])
    var registry := ResourceRegistry.new()
    var requirements: Array = preview.get("requirements",[])
    for data in requirements:
        var material: Dictionary = data
        var note := " [KHÓA]" if bool(material["locked"]) else (
            " [DỰ TRỮ]" if int(material["available"]) < int(material["total"]) else ""
        )
        lines.append("• %s: dùng được %d/%d (kho %d)%s" % [
            registry.display_name(StringName(material["item_id"])),
            int(material["available"]),int(material["need"]),int(material["total"]),note
        ])
    lines.append("Trạng thái: " + (
        "ĐỦ ĐIỀU KIỆN — có thể đột phá" if bool(preview.get("can_commit",false))
        else _body_gate_reason(str(preview.get("reason","")))
    ))
    if int(preview["source_realm"]) <= 6:
        lines.append("Nguồn: Linh Điền / săn Thanh Trúc Lâm, Bạch Thạch Khê, Hắc Phong Cốc.")
    else:
        lines.append("Nguồn cao giới chưa có — không thể đột phá bằng vật phẩm giả.")
    return "\n".join(lines)

func _body_gate_reason(reason: String) -> String:
    match reason:
        "": return "Sẵn sàng."
        "content_unavailable": return "Nội dung chưa mở; cần vùng và nguồn vật phẩm thật."
        "body_major_gate_not_ready": return "Cần đạt tầng 10 Luyện Thể."
        "body_gate_xp_incomplete": return "Chưa đủ EXP Luyện Thể tầng 10."
        "body_gate_material_missing": return "Thiếu nguyên liệu tại Kho Tông Môn."
        "body_gate_material_locked_or_reserved": return "Nguyên liệu đang khóa hoặc được đặt mức dự trữ."
        "body_gate_disciple_busy": return "Đệ tử đang thực hiện hoạt động khác."
        "body_gate_disciple_unavailable": return "Đệ tử phải còn sống và ở tông môn."
        "body_gate_already_committed": return "Đã đột phá cổng này; không trừ trùng."
        "body_gate_last_realm": return "Đã tới đại cảnh giới cuối."
        _: return "Không thể đột phá (" + reason + ")."

func _disciple_tab_text(tab_name: String, disciple: DiscipleState) -> String:
    match tab_name:
        "Thuộc tính":
            return _attributes_tab_text(disciple)
        "Công pháp":
            return _technique_tab_text(disciple)
        "Trang bị":
            return _equipment_tab_text(disciple)
        "Huyết Mạch":
            return _bloodline_tab_text(disciple)
        "Thể Chất":
            return _physique_tab_text(disciple)
        "Quan hệ":
            return _relationship_tab_text(disciple)
        _:
            return "Chưa có dữ liệu."


func _attributes_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        return _v2_attributes_tab_text(snapshot) + "\n\n" + _v2_foundation_meaning_text() + "\n\n" + _v2_profession_summary_text(snapshot) + "\n\n" + _body_gate_preview_text(disciple.id)

    var required := cultivation.required_progress(disciple)
    var progress_text := "Đã viên mãn" if required <= 0.0 else "%.0f / %.0f" % [disciple.cultivation_progress, required]
    var chance := cultivation.breakthrough_success_chance(disciple, state) * 100.0
    var power := cultivation.effective_combat_power(state, disciple)
    var path_lines := [
        "Kiếm %.1f" % float(disciple.cultivation_path_xp.get("sword", 0.0)),
        "Thể %.1f" % float(disciple.cultivation_path_xp.get("body", 0.0)),
        "Pháp %.1f" % float(disciple.cultivation_path_xp.get("spell", 0.0))
    ]
    return (
        "Cảnh giới: %s\nTu vi: %s\nChiến lực hiệu dụng: %.1f\nXác suất đột phá hiện tại: %.1f%%\n"
        + "HP %.0f/%.0f · Thể lực %.0f/100 · Ví %d\n\n"
        + "Tư Chất %s · Căn Cốt %s · Cơ Duyên %s\nThông Tuệ %s · Mị Lực %s · Tiềm Lực %s\n\n"
        + "Tích lũy đường tu: %s\nHành động hiện tại: %s\n%s"
    ) % [
        cultivation.stage_name(disciple), progress_text, power, chance,
        disciple.hp, disciple.max_hp, disciple.stamina, disciple.wallet,
        _score(disciple.aptitude), _score(disciple.constitution), _score(disciple.fortune),
        _score(disciple.comprehension), _score(disciple.charisma), _score(disciple.potential),
        " · ".join(path_lines), SectMapPresentation.action_label(disciple.current_action),
        tab_status_text
    ]



# Source effects are established in FoundationSystem and the V2 stat contract.
# Fortune/Charisma remain conditional checks; this text does not activate them.
func _v2_foundation_meaning_text() -> String:
    return (
        "ẢNH HƯỞNG LỤC DUY (điểm hiện tại)\n"
        + "Tư Chất: +0,25% / điểm vào Tu Vi tự nhiên\n"
        + "Căn Cốt: +0,20% / điểm vào EXP Luyện Thể\n"
        + "Thông Tuệ: +0,15% / điểm vào học / EXP nghề hợp lệ\n"
        + "Tiềm Lực: +0,05% / điểm vào lõi HP, Công, Thủ\n"
        + "Cơ Duyên: kiểm tra vận may khi có sự kiện hợp lệ\n"
        + "Mị Lực: kiểm tra tương tác xã hội khi có sự kiện hợp lệ"
    )

func _v2_attributes_tab_text(snapshot: Dictionary) -> String:
    var progression: Dictionary = snapshot["progression"]
    var life: Dictionary = snapshot["life"]
    var foundations: Dictionary = snapshot["foundations"]["current"]
    var innate: Dictionary = snapshot["innate"]
    if not bool(progression.get("ready", false)):
        return (
            "Hồ sơ tiến độ chưa sẵn sàng. Không dùng cảnh giới cũ để thay thế.\n\n"
            + "HP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n"
            + "Tư Chất %s · Căn Cốt %s · Cơ Duyên %s\n"
            + "Thông Tuệ %s · Mị Lực %s · Tiềm Lực %s"
        ) % [
            float(life["hp"]), float(life["max_hp"]), float(life["expedition_stamina"]),
            _score(float(foundations["aptitude"])), _score(float(foundations["constitution"])),
            _score(float(foundations["fortune"])), _score(float(foundations["comprehension"])),
            _score(float(foundations["charisma"])), _score(float(foundations["potential"]))
        ]

    var tuvi: Dictionary = progression["cultivation"]
    var body: Dictionary = progression["body"]
    var combat: Dictionary = snapshot["combat"]
    var stats: Dictionary = combat.get("stats", {})
    var gate_text := "Chưa tới cổng đại cảnh"
    if bool(tuvi.get("at_major_gate", false)):
        gate_text = "Đột phá %.1f%%" % (float(tuvi.get("effective_breakthrough_chance", 0.0)) * 100.0)
    var body_gate := "Chưa tới cổng đại cảnh"
    if bool(body.get("at_major_gate", false)):
        body_gate = "Đủ EXP; cần hoàn tất yêu cầu Thối Thể"

    return (
        "Tu Vi: %s tầng %d · %.0f / %.0f · %s\n"
        + "Luyện Thể: %s tầng %d · %.0f / %.0f · %s\n"
        + "HP %.0f/%.0f · Công %.1f · Thủ %.1f · Thể lực viễn chinh %.0f/100\n\n"
        + "Tư Chất %s · Căn Cốt %s · Cơ Duyên %s\n"
        + "Thông Tuệ %s · Mị Lực %s · Tiềm Lực %s\n\n"
        + "Linh Căn: %s\n"
        + "Đặc Chất: %s\n"
        + "Huyết Mạch: %s · Thể Chất: %s · Mệnh Cách: %s\n"
        + "Hiệu ứng đặc thù bẩm sinh: Chưa khả dụng\n"
        + "Hành động hiện tại: %s\n%s"
    ) % [
        str(tuvi["name"]), int(tuvi["floor"]), float(tuvi["xp"]), float(tuvi["required_xp"]), gate_text,
        str(body["name"]), int(body["floor"]), float(body["xp"]), float(body["required_xp"]), body_gate,
        float(life["hp"]), float(life["max_hp"]),
        float(stats.get("attack", 0.0)), float(stats.get("defense", 0.0)),
        float(life["expedition_stamina"]),
        _score(float(foundations["aptitude"])), _score(float(foundations["constitution"])),
        _score(float(foundations["fortune"])), _score(float(foundations["comprehension"])),
        _score(float(foundations["charisma"])), _score(float(foundations["potential"])),
        _v2_root_brief(innate), _v2_trait_brief(innate),
        _v2_identity_brief(innate["bloodline"], "Không"),
        _v2_identity_brief(innate["physique"], "Không"),
        _v2_identity_brief(innate["destiny"], "Không"),
        SectMapPresentation.action_label(StringName(life["current_action"])),
        tab_status_text
    ]


func _v2_profession_summary_text(snapshot: Dictionary) -> String:
    var work: Dictionary = snapshot["work"]
    var professions: Dictionary = work.get("professions", {})
    var names := {
        "mining":"Khai Khoáng", "forestry":"Lâm Nghiệp",
        "herbalism":"Linh Thực", "alchemy":"Luyện Đan",
        "forging":"Luyện Khí", "logistics":"Hậu Cần"
    }
    var lines: Array[String] = ["Nghề nghiệp · cấp / EXP:"]
    for profession_id in ["mining","forestry","herbalism","alchemy","forging","logistics"]:
        var row: Dictionary = professions.get(profession_id, {})
        lines.append("• %s Lv%d · EXP %.1f" % [
            str(names[profession_id]), int(row.get("level",0)), float(row.get("xp",0.0))
        ])
    var site := str(work.get("worksite_building_id",""))
    if not site.is_empty():
        lines.append("Điểm làm việc: %s" % site)
    return "\n".join(lines)


func _technique_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc dữ liệu Công Pháp."
    var learning: Dictionary = snapshot["learning"]
    var learned: Dictionary = learning.get("learned_techniques", {})
    var active_id := StringName(learning.get("active_technique_id", ""))
    var lines: Array[String] = []
    var ids: Array = learned.keys()
    ids.sort()
    for raw_id in ids:
        var technique_id := StringName(raw_id)
        var mastery: Dictionary = learned[raw_id]
        lines.append("• %s · Lv%d · XP %.1f%s" % [
            technique_system.technique_name(technique_id),
            int(mastery.get("level", 1)),
            float(mastery.get("xp", 0.0)),
            " · ĐANG DÙNG" if active_id == technique_id else ""
        ])
    if lines.is_empty():
        lines.append("• Chưa học công pháp")
    var note := ""
    if bool(snapshot.get("authentic_v2", false)):
        note = "\n\nCơ chế Công Pháp mới chưa khả dụng; dữ liệu đang lưu chỉ được hiển thị, không tự cộng hiệu ứng mới."
    var life: Dictionary = snapshot["life"]
    return "Công pháp đã học: %d/%d\nCống hiến: %d · Linh thạch cá nhân: %d\n\n%s%s" % [
        learned.size(), TechniqueSystem.MAX_LEARNED_TECHNIQUES,
        int(life["contribution_points"]), int(life["personal_spirit_stones"]),
        "\n".join(lines), note
    ]


func _equipment_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc dữ liệu Trang bị."
    var equipment: Dictionary = snapshot["equipment"]
    var by_slot: Dictionary = {}
    for raw_row in equipment.get("items", []):
        if raw_row is Dictionary:
            by_slot[str(raw_row.get("slot", ""))] = raw_row

    var lines: Array[String] = []
    for slot in EquipmentSystem.VALID_SLOTS:
        var slot_key := str(slot)
        var slot_name := _equipment_slot_name(slot)
        if not by_slot.has(slot_key):
            lines.append("• %s: Chưa trang bị" % slot_name)
            continue
        var row: Dictionary = by_slot[slot_key]
        var item: Dictionary = row.get("item", {})
        lines.append("• %s: %s · %s · %s" % [
            slot_name,
            str(item.get("name", row.get("item_id", "?"))),
            equipment_system.quality_name(StringName(item.get("quality", "pham"))),
            "Đã khóa" if bool(row.get("locked", false)) else "Tự động"
        ])
    var life: Dictionary = snapshot["life"]
    if bool(snapshot.get("authentic_v2", false)):
        return (
            "Trang bị hiện tại:\n%s\n\n"
            + "Hệ trang bị hoàn chỉnh chưa khả dụng cho hồ sơ này; các vật phẩm tương thích cũ không được tự tính vào chỉ số chiến đấu mới.\n"
            + "Ví cá nhân: %d"
        ) % ["\n".join(lines), int(life["wallet"])]

    var equip_power := equipment_system.combat_power_bonus(state, disciple)
    var damage_reduction := (1.0 - equipment_system.incoming_damage_multiplier(state, disciple)) * 100.0
    return "Trang bị hiện tại:\n%s\n\nĐóng góp chiến lực: +%.1f\nGiảm sát thương từ trang bị: %.1f%%\nVí cá nhân: %d" % [
        "\n".join(lines), equip_power, damage_reduction, int(life["wallet"])
    ]


func _bloodline_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        var bloodline: Dictionary = snapshot["innate"]["bloodline"]
        match str(bloodline.get("status", "none")):
            "none":
                return "Huyết Mạch: Không có huyết mạch đặc biệt.\n\nHiệu ứng đặc thù: Không."
            "unrevealed":
                return "Huyết Mạch: Chưa xác định\n\nChưa đủ điều kiện để nhận biết huyết mạch của đệ tử này."
            "revealed":
                return (
                    "Huyết Mạch: %s\n"
                    + "Độ thuần hiện tại: %d%% · Lúc sinh: %d%%\n"
                    + "Trạng thái: %s\n\n"
                    + "Hiệu ứng đặc thù: Chưa khả dụng. Hồ sơ chỉ hiển thị identity đã được xác nhận."
                ) % [
                    str(bloodline.get("name", "?")),
                    int(bloodline.get("current_purity", 0)),
                    int(bloodline.get("birth_purity", 0)),
                    "Đã thức tỉnh" if bool(bloodline.get("awakened", false)) else "Chưa thức tỉnh"
                ]

    var profile := bloodlines.profile_for(state, disciple.id)
    if profile.is_empty():
        return "Chưa có hồ sơ Huyết Mạch."
    if not bool(profile.get("revealed", false)):
        return "Huyết Mạch: Chưa xác định\n\nChưa đủ điều kiện để nhận biết huyết mạch của đệ tử này."
    var id := StringName(profile.get("bloodline_id", "none"))
    var awakened := bool(profile.get("awakened", false))
    var stats := bloodlines.stat_profile(state, disciple)
    var status := "Đã thức tỉnh" if awakened else "Chưa thức tỉnh"
    return (
        "Huyết Mạch: %s\nĐộ thuần: %.1f%% · %s · Luyện huyết %d lần\n\n"
        + "Công +%.1f · Giảm sát thương %.1f%%\nTu luyện +%.1f%% · Đột phá +%.1f%% · Hồi phục +%.1f%%\n"
        + "Tiêu hao thêm khi xuất môn: %d\n\nYêu Đan trong tông: %d\n%s"
    ) % [
        bloodlines.bloodline_name(id), float(profile.get("purity", 0.0)) * 100.0, status, int(profile.get("refinement_count", 0)),
        float(stats.get("combat_power_bonus", 0.0)), float(stats.get("damage_reduction_pct", 0.0)),
        float(stats.get("cultivation_bonus_pct", 0.0)), float(stats.get("breakthrough_bonus_pct", 0.0)), float(stats.get("recovery_bonus_pct", 0.0)),
        int(stats.get("extra_departure_supply", 0)), _warehouse_quantity(&"yeu_dan", true), tab_status_text
    ]


func _physique_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        var physique: Dictionary = snapshot["innate"]["physique"]
        match str(physique.get("status", "none")):
            "none":
                return "Thể Chất: Không có thể chất đặc biệt.\n\nHiệu ứng đặc thù: Không."
            "unrevealed":
                return "Thể Chất: Chưa xác định\n\nThể chất đặc biệt chưa được nhận biết."
            "revealed":
                return (
                    "Thể Chất: %s\n\n"
                    + "Đây là Core Physique hiện được ghi nhận.\n"
                    + "Hiệu ứng đặc thù: Chưa khả dụng; không dùng cơ chế Tôi thể/Cải thể cũ để sửa hồ sơ này."
                ) % str(physique.get("name", "?"))

    var profile := physiques.profile_for(state, disciple.id)
    if profile.is_empty():
        return "Chưa có hồ sơ Thể Chất."
    var stats := physiques.stat_profile(state, disciple)
    var defense := (1.0 - float(stats.get("incoming_damage_multiplier", 1.0))) * 100.0
    var cultivate_pct := (float(stats.get("cultivation_multiplier", 1.0)) - 1.0) * 100.0
    var breakthrough_pct := float(stats.get("breakthrough_bonus", 0.0)) * 100.0
    var recovery_pct := (float(stats.get("recovery_multiplier", 1.0)) - 1.0) * 100.0
    return (
        "Thể Chất: %s\nTôi thể: %d/%d · Đã cải thể: %s\n\n"
        + "Công +%.1f · Giảm sát thương %.1f%%\nTu luyện %.1f%% · Đột phá %.1f%% · Hồi phục %.1f%%\n"
        + "Kiếm đạo XP x%.2f · Thể đạo XP x%.2f · Pháp đạo XP x%.2f\n\n"
        + "Yêu Đan: %d · Linh Tủy: %d\n%s"
    ) % [
        physiques.display_physique(state, disciple.id), int(profile.get("temper_level", 0)), PhysiqueSystem.MAX_TEMPER_LEVEL,
        "Có" if bool(profile.get("transformed", false)) else "Không",
        float(stats.get("attack_bonus", 0.0)), defense, cultivate_pct, breakthrough_pct, recovery_pct,
        float(stats.get("sword_xp_multiplier", 1.0)), float(stats.get("body_xp_multiplier", 1.0)), float(stats.get("spell_xp_multiplier", 1.0)),
        _warehouse_quantity(&"yeu_dan", true), _warehouse_quantity(&"linh_tuy", true), tab_status_text
    ]


func _relationship_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc dữ liệu Quan hệ."
    var relation_data: Dictionary = snapshot["relationships"]
    var lines: Array[String] = []
    for raw_row in relation_data.get("rows", []):
        if not (raw_row is Dictionary):
            continue
        lines.append("• %s · Thân %.0f · Tin %.0f · Kính %.0f · Tương tác %d" % [
            str(raw_row.get("target_name", "?")),
            float(raw_row.get("affinity", 0.0)),
            float(raw_row.get("trust", 0.0)),
            float(raw_row.get("respect", 0.0)),
            int(raw_row.get("interactions", 0))
        ])
    if lines.is_empty():
        lines.append("• Chưa có quan hệ đáng kể được lưu")
    var companion := str(relation_data.get("companion_name", ""))
    if companion.is_empty():
        companion = "Chưa phân"
    return "Đồng hành ưu tiên: %s\n\n%s\n\nQuan hệ thay đổi theo những lần đồng hành, chiến đấu và sinh hoạt cùng nhau." % [
        companion, "\n".join(lines)
    ]

func _equipment_slot_name(slot: StringName) -> String:
    match slot:
        EquipmentSystem.SLOT_WEAPON: return "Vũ khí"
        EquipmentSystem.SLOT_ARMOR: return "Giáp"
        EquipmentSystem.SLOT_TALISMAN: return "Phụ kiện"
        _: return str(slot)
