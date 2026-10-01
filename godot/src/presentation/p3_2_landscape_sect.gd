extends "res://src/presentation/p3_1_landscape_sect.gd"

const ZOOM_STEP := 1.12
const CAMERA_TWEEN_SECONDS := 0.22

var map_zoom: float = SectMapCamera.DEFAULT_ZOOM
var touch_points: Dictionary = {}
var last_pinch_distance: float = 0.0
var mouse_panning := false
var camera_tween: Tween
var zoom_readout: Label

func _ready() -> void:
    super._ready()
    _reset_camera(false)
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

func _build_camera_controls() -> void:
    var panel := Panel.new()
    panel.position = Vector2(1204, 184)
    panel.size = Vector2(60, 184)
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

    var reset := Button.new()
    reset.text = "Toàn"
    reset.position = Vector2(8, 134)
    reset.size = Vector2(44, 40)
    reset.add_theme_font_size_override("font_size", 11)
    reset.tooltip_text = "Về toàn cảnh"
    reset.pressed.connect(_reset_camera.bind(true))
    panel.add_child(reset)

    var hint := Label.new()
    hint.text = "Chụm 2 ngón: zoom  •  Kéo: di chuyển  •  Chạm đúp: phóng nhanh"
    hint.position = Vector2(704, 606)
    hint.size = Vector2(480, 26)
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hint.add_theme_font_size_override("font_size", 11)
    hint.add_theme_color_override("font_color", Color(0.16, 0.16, 0.13, 0.74))
    hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(hint)

    _refresh_zoom_readout()

func _handle_screen_touch(touch: InputEventScreenTouch) -> void:
    if touch.pressed:
        if not SectMapCamera.VIEW_RECT.has_point(touch.position):
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
        if SectMapCamera.VIEW_RECT.has_point(mouse.position):
            _zoom_at(mouse.position, map_zoom * ZOOM_STEP, false)
            get_viewport().set_input_as_handled()
        return

    if mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
        if SectMapCamera.VIEW_RECT.has_point(mouse.position):
            _zoom_at(mouse.position, map_zoom / ZOOM_STEP, false)
            get_viewport().set_input_as_handled()
        return

    if mouse.button_index != MOUSE_BUTTON_LEFT:
        return

    if mouse.pressed:
        if not SectMapCamera.VIEW_RECT.has_point(mouse.position):
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
    _apply_camera(float(transform["zoom"]), Vector2(transform["position"]), animate)

func _pan_camera(delta: Vector2) -> void:
    var next_position := SectMapCamera.pan_position(map_layer.position, delta, map_zoom)
    _apply_camera(map_zoom, next_position, false)

func _focus_world_point(world_point: Vector2) -> void:
    var target_zoom := maxf(map_zoom, SectMapCamera.FOCUS_ZOOM)
    var transform := SectMapCamera.focus_transform(world_point, target_zoom)
    _apply_camera(float(transform["zoom"]), Vector2(transform["position"]), true)

func _reset_camera(animate: bool = true) -> void:
    var transform := SectMapCamera.reset_transform()
    _apply_camera(float(transform["zoom"]), Vector2(transform["position"]), animate)

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
        last_pinch_distance = Vector2(pair[0]).distance_to(Vector2(pair[1]))

func _first_two_touch_points() -> Array:
    var keys: Array = touch_points.keys()
    keys.sort()
    if keys.size() < 2:
        return []
    return [Vector2(touch_points[keys[0]]), Vector2(touch_points[keys[1]])]

func _camera_center() -> Vector2:
    return SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5

func _popup_is_open() -> bool:
    return popup_layer != null and popup_layer.get_child_count() > 0

func _clear_pointer_state() -> void:
    touch_points.clear()
    last_pinch_distance = 0.0
    mouse_panning = false
