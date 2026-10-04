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
var female_motion_library: AnimationLibrary
var modular_live_actor_ids: Dictionary = {}

func _ready() -> void:
    super._ready()
    female_motion_library = FemaleNormalV1MotionLibrary.build()
    _install_modular_live_actors()
    _sync_actor_positions()
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
        var world_foot := SectMapPresentation.position_for_destination(destination) + _actor_offset(index)
        var target := world_foot - _actor_anchor_offset(actor)
        var delta := target - actor.position

        if actor is ModularDiscipleActor:
            var modular := actor as ModularDiscipleActor
            if delta.length() > 1.0:
                var direction := DiscipleActorVisualCatalog.direction_for_delta(delta, modular.facing)
                if direction != modular.facing:
                    FemaleStageAAssetLoader.apply_public_direction(modular, direction)
                modular.play_walk_for_delta(delta)
            else:
                modular.sync_action(disciple.current_action)

        if delta.length() > 1.0:
            var tween := create_tween()
            tween.set_trans(Tween.TRANS_QUAD)
            tween.set_ease(Tween.EASE_IN_OUT)
            tween.tween_property(actor, "position", target, 0.32)

        if actor_status_labels.has(key):
            var status := actor_status_labels[key] as Label
            if is_instance_valid(status):
                status.text = SectMapPresentation.action_label(disciple.current_action)

    if focused_kind == &"disciple":
        _refresh_focused_disciple_point()

func _actor_anchor_offset(actor: Control) -> Vector2:
    if actor is ModularDiscipleActor:
        return DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
    return Vector2(30.0, 30.0)

func _stage_a_live_assets_ready() -> bool:
    return (
        FemaleStageAAssetLoader.assets_available(&"down")
        and FemaleStageAAssetLoader.assets_available(&"right")
        and FemaleStageAAssetLoader.assets_available(&"up")
    )

func _install_modular_live_actors() -> void:
    modular_live_actor_ids.clear()
    if female_motion_library == null or not _stage_a_live_assets_ready():
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var key := str(disciple_id)
        var disciple: DiscipleState = state.disciples[disciple_id]
        if DiscipleActorVisualCatalog.rig_for_disciple(disciple) != DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1:
            continue
        if actor_nodes.has(key) and actor_nodes[key] is ModularDiscipleActor:
            modular_live_actor_ids[key] = true
            continue

        var old_actor: Control = actor_nodes.get(key) as Control
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
        FemaleStageAAssetLoader.apply_public_direction(actor, &"down")
        actor.sync_action(disciple.current_action)
        actor.actor_pressed.connect(Callable(self, "_open_disciple").bind())
        var world_foot := SectMapPresentation.position_for_destination(destination) + _actor_offset(index)
        actor.position = world_foot - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
        map_layer.add_child(actor)

        actor_nodes[key] = actor
        actor_status_labels[key] = actor.status_label
        modular_live_actor_ids[key] = true

func _tab_notice(tab_name: String) -> void:
    _open_disciple_tab(tab_name)

func _open_disciple_tab(tab_name: String) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    _clear_popup()
    _add_dim()

    var panel := Panel.new()
    panel.position = Vector2(110, 82)
    panel.size = Vector2(1060, 548)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)

    var title := _label(panel, "%s · %s" % [disciple.display_name, tab_name], Vector2(24, 16), Vector2(720, 38), 24)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    var back := Button.new()
    back.text = "← Hồ sơ"
    back.position = Vector2(820, 14)
    back.size = Vector2(140, 38)
    back.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), INK, 1, 8))
    back.pressed.connect(Callable(self, "_open_disciple").bind(selected_id))
    panel.add_child(back)

    var close := Button.new()
    close.text = "×"
    close.position = Vector2(1008, 14)
    close.size = Vector2(36, 34)
    close.add_theme_font_size_override("font_size", 22)
    close.add_theme_stylebox_override("normal", _style(Color(0.76, 0.70, 0.58, 1.0), INK, 1, 16))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)

    var content_panel := Panel.new()
    content_panel.position = Vector2(24, 68)
    content_panel.size = Vector2(1012, 370)
    content_panel.add_theme_stylebox_override("panel", _style(Color(0.93, 0.89, 0.78, 0.72), Color(0.50, 0.42, 0.30, 1.0), 1, 10))
    panel.add_child(content_panel)

    var content := _label(content_panel, _disciple_tab_text(tab_name, disciple), Vector2(20, 16), Vector2(972, 330), 15)
    content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_theme_color_override("font_color", INK)

    if tab_name == "Huyết Mạch":
        _add_tab_action_button(panel, "Thức tỉnh", Vector2(26, 450), "bloodline_awaken")
        _add_tab_action_button(panel, "Luyện huyết", Vector2(148, 450), "bloodline_refine")
    elif tab_name == "Thể Chất":
        _add_tab_action_button(panel, "Tôi thể", Vector2(26, 450), "physique_temper")
        _add_tab_action_button(panel, "Cải thể", Vector2(148, 450), "physique_transform")

    var tab_names: Array[String] = ["Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    for index in range(tab_names.size()):
        var tab := Button.new()
        tab.text = tab_names[index]
        tab.position = Vector2(300 + index * 122, 486)
        tab.size = Vector2(114, 36)
        tab.add_theme_font_size_override("font_size", 12)
        var active: bool = tab_names[index] == tab_name
        tab.add_theme_stylebox_override("normal", _style(Color(0.97, 0.88, 0.64, 1.0) if active else Color(0.88, 0.82, 0.67, 1.0), GOLD if active else Color(0.45, 0.37, 0.25, 1.0), 2 if active else 1, 6))
        tab.pressed.connect(Callable(self, "_open_disciple_tab").bind(str(tab_names[index])))
        panel.add_child(tab)

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
    var reason := str(result.get("reason", ""))
    return "%s · %s" % ["Thành công" if ok else "Chưa thể thực hiện", reason]

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

func _technique_tab_text(disciple: DiscipleState) -> String:
    var lines: Array[String] = []
    var ids: Array = disciple.learned_techniques.keys()
    ids.sort()
    for raw_id in ids:
        var technique_id := StringName(raw_id)
        var mastery: Dictionary = disciple.learned_techniques[raw_id]
        lines.append("• %s · Lv%d · XP %.1f%s" % [
            technique_system.technique_name(technique_id),
            int(mastery.get("level", 1)),
            float(mastery.get("xp", 0.0)),
            " · ĐANG DÙNG" if disciple.active_technique_id == technique_id else ""
        ])
    if lines.is_empty():
        lines.append("• Chưa học công pháp")
    return "Công pháp đã học: %d/%d\nCống hiến: %d · Linh thạch cá nhân: %d\n\n%s\n\nCông pháp đang dùng ảnh hưởng trực tiếp tu luyện/chiến đấu theo P2.3–P2.5." % [
        disciple.learned_techniques.size(), TechniqueSystem.MAX_LEARNED_TECHNIQUES,
        disciple.contribution_points, disciple.spirit_stones, "\n".join(lines)
    ]

func _equipment_tab_text(disciple: DiscipleState) -> String:
    var lines: Array[String] = []
    for slot in EquipmentSystem.VALID_SLOTS:
        var item := equipment_system.equipped_item(state, disciple, slot)
        var slot_name := _equipment_slot_name(slot)
        if item.is_empty():
            lines.append("• %s: Chưa trang bị" % slot_name)
            continue
        var locked := bool(disciple.locked_equipment_slots.get(str(slot), false))
        lines.append("• %s: %s · %s · %s" % [
            slot_name,
            str(item.get("name", "?")),
            equipment_system.quality_name(StringName(item.get("quality", "pham"))),
            "Đã khóa" if locked else "Tự động"
        ])
    var equip_power := equipment_system.combat_power_bonus(state, disciple)
    var damage_reduction := (1.0 - equipment_system.incoming_damage_multiplier(state, disciple)) * 100.0
    return "Trang bị hiện tại:\n%s\n\nĐóng góp chiến lực: +%.1f\nGiảm sát thương từ trang bị: %.1f%%\nVí cá nhân: %d\n\nSlot không khóa vẫn được AI tự mua/nâng; slot khóa do Tông Chủ kiểm soát." % [
        "\n".join(lines), equip_power, damage_reduction, disciple.wallet
    ]

func _bloodline_tab_text(disciple: DiscipleState) -> String:
    var profile := bloodlines.profile_for(state, disciple.id)
    if profile.is_empty():
        return "Chưa có hồ sơ Huyết Mạch."
    if not bool(profile.get("revealed", false)):
        return "Huyết Mạch: Chưa xác định\n\nDanh tính ẩn đã được cố định từ lúc sinh; giao diện không tiết lộ trước khi đủ điều kiện phát hiện."
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
        int(stats.get("extra_departure_supply", 0)), int(state.sect.technique_materials.get("yeu_dan", 0)), tab_status_text
    ]

func _physique_tab_text(disciple: DiscipleState) -> String:
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
        int(state.sect.technique_materials.get("yeu_dan", 0)), int(state.sect.technique_materials.get("linh_tuy", 0)), tab_status_text
    ]

func _relationship_tab_text(disciple: DiscipleState) -> String:
    var lines: Array[String] = []
    var raw_map = state.relationships.get(str(disciple.id), {})
    if raw_map is Dictionary:
        var target_ids: Array = raw_map.keys()
        target_ids.sort()
        for raw_target in target_ids:
            var relation: RelationshipState = raw_map[raw_target]
            var target_id := StringName(raw_target)
            var target_name := str(target_id)
            if state.disciples.has(target_id):
                var target: DiscipleState = state.disciples[target_id]
                target_name = target.display_name
            lines.append("• %s · Thân %.0f · Tin %.0f · Kính %.0f · Tương tác %d" % [
                target_name, relation.affinity, relation.trust, relation.respect, relation.interactions
            ])
    if lines.is_empty():
        lines.append("• Chưa có quan hệ đáng kể được lưu")
    var companion := str(state.companion_assignments.get(str(disciple.id), ""))
    if companion != "" and state.disciples.has(StringName(companion)):
        var companion_disciple: DiscipleState = state.disciples[StringName(companion)]
        companion = companion_disciple.display_name
    else:
        companion = "Chưa phân"
    return "Đồng hành ưu tiên: %s\n\n%s\n\nQuan hệ là state thật của P1.3; hành vi và ký ức tiếp tục thay đổi các giá trị này." % [companion, "\n".join(lines)]

func _equipment_slot_name(slot: StringName) -> String:
    match slot:
        EquipmentSystem.SLOT_WEAPON: return "Vũ khí"
        EquipmentSystem.SLOT_ARMOR: return "Giáp"
        EquipmentSystem.SLOT_TALISMAN: return "Phụ kiện"
        _: return str(slot)
