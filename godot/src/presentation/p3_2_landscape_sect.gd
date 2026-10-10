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
var needs_system := NeedsSystem.new()
var living_cue_resolver := LivingCueResolver.new()
var living_cue_tracker := LivingCueTracker.new()
var living_cue_layer: LivingCueLayer
var visible_living_cues: Array[Dictionary] = []
var female_motion_library: AnimationLibrary
var modular_live_actor_ids: Dictionary = {}

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
var building_operation_content: VBoxContainer
var building_management_container: VBoxContainer
var building_management_feedback := ""
var selected_building: StringName = &""
var deep_restore_summary := false
var screen_pointer_dragged := false
var mouse_pointer_dragged := false

func _ready() -> void:
    super._ready()
    if not runtime_ready:
        return
    female_motion_library = FemaleNormalV1MotionLibrary.build()
    _install_modular_live_actors()
    _sync_actor_positions()
    popup_layer.z_index = 100
    _reset_camera(false)
    _build_focus_marker()
    _build_camera_controls()
    _build_disciple_summary_panel()
    _build_building_operation_panel()
    _build_living_cue_layer()
    living_cue_tracker.seed_from_state(state)
    _refresh_living_cues()

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
        if touch.double_tap:
            screen_pointer_dragged = true
            _zoom_at(touch.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
        _refresh_pinch_baseline()
        return

    var was_single_pointer := touch_points.size() == 1 and touch_points.has(touch.index)
    touch_points.erase(touch.index)
    _refresh_pinch_baseline()
    if was_single_pointer and not screen_pointer_dragged:
        if _disciple_summary_is_open():
            _close_disciple_summary(true)
        elif _building_operation_is_open():
            _close_building_operation_panel(true)

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

    if drag.relative.length() > 2.0:
        screen_pointer_dragged = true
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
        mouse_pointer_dragged = false
        if mouse.double_click:
            mouse_pointer_dragged = true
            _zoom_at(mouse.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
            return
        mouse_panning = true
    else:
        var should_close_summary := mouse_panning and not mouse_pointer_dragged and _disciple_summary_is_open()
        var should_close_building := mouse_panning and not mouse_pointer_dragged and _building_operation_is_open()
        mouse_panning = false
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
    if motion.relative.length() > 2.0:
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
    screen_pointer_dragged = false
    mouse_pointer_dragged = false

func _open_building(destination: StringName) -> void:
    _close_disciple_summary(true)
    _clear_popup()
    selected_building = destination
    var point := SectMapPresentation.position_for_destination(destination)
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
        return
    if action == "disciples":
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
                if (
                    modular.rig_id == DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1
                    and _stage_a_live_assets_ready()
                    and direction != modular.facing
                ):
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
    _refresh_disciple_summary_content()
    _refresh_building_operation_content()
    _refresh_living_cues()

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
            FemaleStageAAssetLoader.apply_public_direction(actor, &"down")
        actor.sync_action(disciple.current_action)
        actor.actor_pressed.connect(Callable(self, "_open_disciple"))
        var world_foot := SectMapPresentation.position_for_destination(destination) + _actor_offset(index)
        actor.position = world_foot - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
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
    separator.position = Vector2(14, 78)
    separator.size = Vector2(412, 2)
    building_operation_panel.add_child(separator)

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
    building_operation_body.custom_minimum_size = Vector2(384, 420)
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

func _hide_building_operation_panel() -> void:
    if building_operation_panel != null:
        building_operation_panel.visible = false
    if camera_controls_panel != null and not _disciple_summary_is_open():
        camera_controls_panel.visible = true
    if camera_hint != null and not _disciple_summary_is_open():
        camera_hint.visible = true

func _close_building_operation_panel(clear_selection: bool = true) -> void:
    _hide_building_operation_panel()
    building_management_feedback = ""
    if not clear_selection:
        return
    selected_building = &""
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
    var feedback := ""
    if building_management_feedback != "":
        feedback = "\n\n%s" % building_management_feedback
    building_operation_body.text = _building_operation_text(selected_building) + feedback
    # E3: expose two real assignment rows within the scroll viewport instead
    # of leaving them permanently below the generic 420px explanation block.
    building_operation_body.custom_minimum_size.y = (
        248 if selected_building == SectMapPresentation.DEST_BODY_TRAINING else 420
    )
    _rebuild_building_management_controls()

func _rebuild_building_management_controls() -> void:
    if building_management_container == null:
        return
    for child in building_management_container.get_children():
        building_management_container.remove_child(child)
        child.queue_free()

    match selected_building:
        SectMapPresentation.DEST_MAIN_HALL:
            _build_main_hall_policy_controls()
        SectMapPresentation.DEST_MINE:
            _build_work_management(WorkforceSystem.PROF_MINING, &"mining_crew", "Đội Khai Khoáng", "Khai khoáng")
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
        SectMapPresentation.DEST_GATE:
            _build_direct_order_management(WorkforceSystem.COMMAND_RETURN_SECT, "", "Triệu hồi", true)
        _:
            pass

func _build_main_hall_policy_controls() -> void:
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

func _build_needs_priority_controls(title: String) -> void:
    _add_management_section_label(title)
    _add_policy_button_row([
        {"label":"Cân bằng", "value":NeedsSystem.PRIORITY_BALANCED},
        {"label":"Ưu tiên thuốc", "value":NeedsSystem.PRIORITY_MEDICINE},
        {"label":"Ưu tiên vật tư", "value":NeedsSystem.PRIORITY_SUPPLIES}
    ], state.sect.needs_priority, "_set_needs_priority_from_building")

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
    var materials: Dictionary = data.get("materials", {})
    var ids: Array = materials.keys()
    ids.sort()
    var parts: Array[String] = []
    var missing: Array[String] = []
    for raw_id in ids:
        var material_id := StringName(raw_id)
        var need := int(materials[raw_id])
        var have := int(state.sect.forge_materials.get(str(material_id), 0))
        parts.append("%s %d/%d" % [equipment_system.material_name(material_id), have, need])
        if have < need:
            missing.append(equipment_system.material_name(material_id))
    var suffix := " · Đủ nguyên liệu" if missing.is_empty() else " · Thiếu: %s" % ", ".join(missing)
    return "Nguyên liệu: %s%s" % [" · ".join(parts), suffix]

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

func _build_work_management(profession_id: StringName, group_id: StringName, group_label: String, order_label: String) -> void:
    _add_management_section_label("PHÂN CÔNG")
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var row := _new_management_row(disciple)
        var in_group := disciple.work_group_id == group_id

        var group_button := Button.new()
        group_button.name = "Group_%s_%s" % [str(group_id), str(disciple.id)]
        group_button.text = "Rút đội" if in_group else "Phân đội"
        group_button.custom_minimum_size = Vector2(70, 34)
        group_button.add_theme_font_size_override("font_size", 11)
        if in_group:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(disciple.id, &"", "Đã rút %s khỏi %s." % [disciple.display_name, group_label]))
        else:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(disciple.id, group_id, "Đã phân %s vào %s." % [disciple.display_name, group_label]))
        row.add_child(group_button)

        var order_button := Button.new()
        order_button.name = "Work_%s_%s" % [str(profession_id), str(disciple.id)]
        order_button.text = order_label
        order_button.custom_minimum_size = Vector2(82, 34)
        order_button.add_theme_font_size_override("font_size", 11)
        order_button.pressed.connect(Callable(self, "_issue_building_order").bind(
            disciple.id,
            WorkforceSystem.COMMAND_WORK,
            str(profession_id),
            "Đã ra lệnh %s: %s." % [order_label.to_lower(), disciple.display_name]
        ))
        row.add_child(order_button)

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

func _new_management_row(disciple: DiscipleState) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.name = "Person_%s" % str(disciple.id)
    row.custom_minimum_size = Vector2(384, 38)
    row.add_theme_constant_override("separation", 6)
    building_management_container.add_child(row)

    var name := Label.new()
    name.text = "%s · TL %.0f" % [disciple.display_name, disciple.stamina]
    name.custom_minimum_size = Vector2(190, 34)
    name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    name.add_theme_font_size_override("font_size", 11)
    row.add_child(name)
    return row

func _assign_building_group(disciple_id: StringName, group_id: StringName, success_text: String) -> void:
    if not state.disciples.has(disciple_id):
        return
    var ok := workforce.assign_group(state, disciple_id, group_id)
    building_management_feedback = success_text if ok else "Không thể đổi phân công lúc này."
    _refresh_building_operation_content()

func _issue_building_order(disciple_id: StringName, kind: StringName, target: String, success_text: String) -> void:
    if not state.disciples.has(disciple_id):
        return
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
    return (
        "RÈN THÂN ĐƯỜNG · Lv%d\n"
        + "Vị trí: %d/%d · đang luyện: %d\n"
        + "Linh Thạch Tông Môn: %d\n"
        + "Phí: %d Linh Thạch / phút mô phỏng\n"
        + "EXP nền: %.0f/phút (+0,20%% mỗi điểm Căn Cốt)\n"
        + "Lượt đã thanh toán: %d · Linh Thạch đã tiêu: %d\n\n"
        + "ĐỆ TỬ ĐANG PHÂN CÔNG\n%s\n\n"
        + "Bấm Rèn thân chỉ xếp lệnh; phí/EXP phát sinh khi đủ một phút hợp lệ."
    ) % [
        hall.level,holders.size(),buildings.worker_slots(hall),running,
        state.sect.spirit_stones,
        DiscipleBodyTrainingFacilityV2.STONE_COST_PER_MINUTE,
        DiscipleBodyTrainingFacilityV2.BASE_BODY_XP_PER_MINUTE,
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
        SectMapPresentation.DEST_GATE:
            return _gate_operation_text()
        _:
            return "Sân trung tâm. Không có dữ liệu quản lý riêng."

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
    ) % [
        state.disciples.size(), state.sect.disciple_capacity,
        state.sect.treasury, state.sect.spirit_stones,
        _work_policy_label(state.sect.work_policy),
        _needs_priority_label(state.sect.needs_priority),
        _equipment_policy_label(state.sect.equipment_policy)
    ]

func _mine_operation_text() -> String:
    var members := _disciples_in_work_group(&"mining_crew")
    var lines: Array[String] = []
    for disciple_value in members:
        var disciple: DiscipleState = disciple_value
        var level := workforce.profession_level(disciple, WorkforceSystem.PROF_MINING)
        var progress := float(disciple.work_progress.get(str(WorkforceSystem.PROF_MINING), 0.0))
        lines.append("• %s · Lv%d · tiến độ %.1f/4 · thể lực %.0f · %s" % [
            disciple.display_name, level, progress, disciple.stamina,
            SectMapPresentation.action_label(disciple.current_action)
        ])
    if lines.is_empty():
        lines.append("• Chưa có thành viên Đội Khai Khoáng")

    return (
        "SẢN XUẤT\n"
        + "Thanh Thiết: %d\n"
        + "Đang khai khoáng: %d\n"
        + "Thành viên đội: %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "Phân người vào đội để duy trì khai khoáng lâu dài, hoặc ra lệnh làm ngay khi cần."
    ) % [
        int(state.sect.forge_materials.get("thanh_thiet", 0)),
        _count_action(&"WORK_MINING"),
        members.size(),
        "\n".join(lines)
    ]

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
        + "Thanh Thiết: %d · Linh Mộc: %d\n"
        + "Tinh Lang Bì: %d · Yêu Đan: %d\n"
        + "Điểm hỗ trợ rèn: %d\n"
        + "Công thức có thể luyện: %d / %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "Phân người phụ trách luyện khí và chế tạo trang bị khi đủ nguyên liệu."
    ) % [
        int(state.sect.forge_materials.get("thanh_thiet", 0)),
        int(state.sect.forge_materials.get("linh_moc", 0)),
        int(state.sect.forge_materials.get("tinh_lang_bi", 0)),
        int(state.sect.forge_materials.get("yeu_dan", 0)),
        state.sect.forge_support_points,
        craftable, recipe_ids.size(),
        "\n".join(lines)
    ]

func _cultivation_operation_text() -> String:
    var lines: Array[String] = []
    var ready_count := 0
    var active_count := 0
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.current_action in [&"CULTIVATE", &"BREAKTHROUGH"]:
            active_count += 1
        var required := cultivation.required_progress(disciple)
        var progress_text := "Viên mãn" if required <= 0.0 else "%.0f/%.0f" % [disciple.cultivation_progress, required]
        var ready := cultivation.can_breakthrough(state, disciple)
        if ready:
            ready_count += 1
        if disciple.current_action in [&"CULTIVATE", &"BREAKTHROUGH"] or ready:
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
        + "Đủ điều kiện đột phá: %d\n\n"
        + "ĐỆ TỬ LIÊN QUAN\n%s\n\n"
        + "Có thể gọi đệ tử tới tu luyện; đột phá do chính đệ tử thực hiện khi đủ điều kiện."
    ) % [active_count, ready_count, "\n".join(lines)]

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
        "Thuốc: %d / %d\n"
        + "Vật tư: %d / %d\n"
        + "Đang trị thương: %d\n"
        + "Ưu tiên hậu cần: %s\n"
        + "Đã dùng thuốc: %d · Đã sản xuất: %d\n\n"
        + "NGƯỜI CẦN CHÚ Ý\n%s\n\n"
        + "Điều chỉnh ưu tiên hậu cần để cân bằng thuốc và vật tư theo tình hình hiện tại."
    ) % [
        state.sect.medicine_stock, NeedsSystem.MEDICINE_CAP,
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
        + "VẬT LIỆU LUYỆN KHÍ\n"
        + "Thanh Thiết: %d · Linh Mộc: %d\n"
        + "Tinh Lang Bì: %d · Yêu Đan: %d\n\n"
        + "TRANG BỊ\n"
        + "Trong kho: %d · Đang bán: %d · Đã trang bị: %d\n\n"
        + "Trang bị và vật tư được tổng hợp tại đây."
    ) % [
        state.sect.treasury, state.sect.spirit_stones,
        state.sect.medicine_stock, state.sect.supply_stock,
        int(state.sect.forge_materials.get("thanh_thiet", 0)),
        int(state.sect.forge_materials.get("linh_moc", 0)),
        int(state.sect.forge_materials.get("tinh_lang_bi", 0)),
        int(state.sect.forge_materials.get("yeu_dan", 0)),
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

func _process(_delta: float) -> void:
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
    close.position = Vector2(262, 12)
    close.size = Vector2(34, 34)
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

func _add_summary_order_button(text: String, pos: Vector2, button_size: Vector2, kind: StringName, target: String = "") -> void:
    var button := Button.new()
    button.text = text
    if kind == WorkforceSystem.COMMAND_WORK and target == str(WorkforceSystem.PROF_FORGING):
        button.name = "SummaryLegacyForge"
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
    var v2_body: Button = disciple_summary_panel.get_node_or_null("SummaryV2BodyTraining")
    if legacy_forge != null:
        legacy_forge.visible = not authentic_v2
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
    if not bool(progression.get("ready", false)):
        return (
            "HP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n"
            + "Tu Vi/Luyện Thể: dữ liệu chưa sẵn sàng\n"
            + "Đang làm: %s"
        ) % [
            float(life["hp"]), float(life["max_hp"]),
            float(life["expedition_stamina"]),
            SectMapPresentation.action_label(StringName(life["current_action"]))
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
        + "Lệnh Tông Chủ: %s%s"
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
        feedback
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
        "training_cannot_interrupt_active_work", "busy_spirit_plot":
            return "Đệ tử đang bận; không thể ngắt công việc hoặc ô Linh Điền."
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

    var back := Button.new()
    back.name = "BackToMapContext"
    back.text = "← Trở lại bản đồ"
    back.position = Vector2(936, 12)
    back.size = Vector2(184, 38)
    back.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), INK, 1, 8))
    back.pressed.connect(_return_to_disciple_summary)
    panel.add_child(back)

    var close := Button.new()
    close.text = "×"
    close.position = Vector2(1128, 12)
    close.size = Vector2(36, 34)
    close.add_theme_font_size_override("font_size", 22)
    close.add_theme_stylebox_override("normal", _style(Color(0.76, 0.70, 0.58, 1.0), INK, 1, 16))
    close.pressed.connect(_return_to_disciple_summary)
    panel.add_child(close)

    var roster_panel := Panel.new()
    roster_panel.position = Vector2(18, 58)
    roster_panel.size = Vector2(184, 464)
    roster_panel.add_theme_stylebox_override("panel", _style(Color(0.86, 0.80, 0.66, 1.0), Color(0.40, 0.31, 0.20, 1.0), 2, 10))
    panel.add_child(roster_panel)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(8, 8)
    scroll.size = Vector2(168, 448)
    roster_panel.add_child(scroll)

    var roster := VBoxContainer.new()
    roster.custom_minimum_size = Vector2(150, 0)
    roster.add_theme_constant_override("separation", 6)
    scroll.add_child(roster)

    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var id := StringName(raw_id)
        var roster_disciple: DiscipleState = state.disciples[id]
        var entry := Button.new()
        entry.text = roster_disciple.display_name
        entry.custom_minimum_size = Vector2(148, 44)
        entry.add_theme_font_size_override("font_size", 13)
        var is_selected := id == selected_id
        entry.add_theme_stylebox_override("normal", _style(Color(0.97, 0.90, 0.70, 1.0) if is_selected else Color(0.91, 0.86, 0.72, 1.0), GOLD if is_selected else Color(0.45, 0.37, 0.25, 1.0), 2 if is_selected else 1, 8))
        entry.pressed.connect(Callable(self, "_open_disciple_deep_screen").bind(id, tab_name))
        roster.add_child(entry)

    var disciple: DiscipleState = state.disciples[selected_id]

    var showcase := Panel.new()
    showcase.position = Vector2(220, 58)
    showcase.size = Vector2(300, 394)
    showcase.add_theme_stylebox_override("panel", _style(Color(0.76, 0.84, 0.72, 1.0), Color(0.31, 0.40, 0.28, 1.0), 2, 80))
    panel.add_child(showcase)

    var initial := _label(showcase, disciple.display_name.substr(0, 1), Vector2(70, 66), Vector2(160, 150), 86)
    initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    initial.add_theme_color_override("font_color", JADE_DARK)

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

    var content := _label(content_panel, _disciple_tab_text(tab_name, disciple), Vector2(18, 52), Vector2(590, 286), 14)
    content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_theme_color_override("font_color", INK)

    var profile_snapshot := _disciple_snapshot(disciple)
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

    var tab_names: Array[String] = ["Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    for index in range(tab_names.size()):
        var tab := Button.new()
        tab.text = tab_names[index]
        tab.position = Vector2(220 + index * 154, 470)
        tab.size = Vector2(144, 42)
        tab.add_theme_font_size_override("font_size", 12)
        var active := tab_names[index] == tab_name
        tab.add_theme_stylebox_override("normal", _style(Color(0.97, 0.88, 0.64, 1.0) if active else Color(0.88, 0.82, 0.67, 1.0), GOLD if active else Color(0.45, 0.37, 0.25, 1.0), 2 if active else 1, 7))
        tab.pressed.connect(Callable(self, "_open_disciple_deep_screen").bind(selected_id, str(tab_names[index])))
        panel.add_child(tab)


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
        return _v2_attributes_tab_text(snapshot)

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
        int(stats.get("extra_departure_supply", 0)), int(state.sect.technique_materials.get("yeu_dan", 0)), tab_status_text
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
        int(state.sect.technique_materials.get("yeu_dan", 0)), int(state.sect.technique_materials.get("linh_tuy", 0)), tab_status_text
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
