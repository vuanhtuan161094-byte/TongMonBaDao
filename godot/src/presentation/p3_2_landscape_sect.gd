extends "res://src/presentation/p3_1_landscape_sect.gd"

const ZOOM_STEP := 1.12
const CAMERA_TWEEN_SECONDS := 0.22
const FOCUS_MARKER_SIZE := Vector2(82.0, 82.0)

var map_zoom: float = SectMapCamera.DEFAULT_ZOOM
var touch_points: Dictionary = {}
var last_pinch_distance: float = 0.0
var mouse_panning := false
var camera_tween: Tween
var focus_marker_tween: Tween
var zoom_readout: Label
var focus_target_button: Button
var focus_marker: Panel
var focused_world_point := Vector2.ZERO
var focused_kind: StringName = &""
var focused_id: StringName = &""
var focused_label := ""
var has_focus_target := false

func _ready() -> void:
    super._ready()
    popup_layer.z_index = 100
    _reset_camera(false)
    _build_focus_marker()
    _build_camera_controls()

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

    var selected := Label.new()
    selected.name = "SelectedTargetLabel"
    selected.text = ""
    selected.position = Vector2(-156, 228)
    selected.size = Vector2(208, 20)
    selected.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    selected.add_theme_font_size_override("font_size", 10)
    selected.add_theme_color_override("font_color", Color(0.16, 0.16, 0.13, 0.74))
    selected.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(selected)

    var hint := Label.new()
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
        touch_points[touch.index] = touch.position
        if touch.double_tap:
            _zoom_at(touch.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
        _refresh_pinch_baseline()
        return

    touch_points.erase(touch.index)
    _refresh_pinch_baseline()

func _handle_screen_drag(drag: InputEventScreenDrag) -> void:
    if not touch_points.has(drag.index):
        return
    touch_points[drag.index] = drag.position

    if touch_points.size() >= 2:
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

    _pan_camera(drag.relative)
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
        if mouse.double_click:
            _zoom_at(mouse.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
            return
        mouse_panning = true
    else:
        mouse_panning = false

func _handle_mouse_motion(motion: InputEventMouseMotion) -> void:
    if not mouse_panning:
        return
    if (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
        mouse_panning = false
        return
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
    var selected_label := get_node_or_null("Panel/SelectedTargetLabel") as Label
    if selected_label == null:
        for child in get_children():
            if child is Panel:
                var candidate := child.get_node_or_null("SelectedTargetLabel") as Label
                if candidate != null:
                    selected_label = candidate
                    break
    if selected_label == null:
        return
    selected_label.text = focused_label if has_focus_target else ""

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
    else:
        map_layer.scale = target_scale
        map_layer.position = target_position

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
    last_pinch_distance = 0.0
    mouse_panning = false

func _open_building(destination: StringName) -> void:
    var point := SectMapPresentation.position_for_destination(destination)
    _set_focus_target(point, &"building", destination, _building_name(destination), true)
    super._open_building(destination)

func _open_disciple(disciple_id: StringName) -> void:
    if actor_nodes.has(str(disciple_id)) and state.disciples.has(disciple_id):
        var actor: Control = actor_nodes[str(disciple_id)]
        var disciple: DiscipleState = state.disciples[disciple_id]
        var point := actor.position + actor.size * 0.5
        _set_focus_target(point, &"disciple", disciple_id, disciple.display_name, true)
    super._open_disciple(disciple_id)

func _sync_actor_positions() -> void:
    super._sync_actor_positions()
    if focused_kind == &"disciple":
        _refresh_focused_disciple_point()
