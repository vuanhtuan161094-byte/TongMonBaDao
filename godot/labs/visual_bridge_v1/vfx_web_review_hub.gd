extends Node2D
# VFX REVIEW HUB — WEB ONLY, same canonical Godot project sources, not another game.
# Character and VFX art remain independent. A scenario is listed ONLY if genuine
# available assets and visual event bindings exist. No combat authority or save.
const AS48_SCENE := preload("res://labs/visual_bridge_v1/as48_sword_anchor_lab.tscn")

var _lab: Node2D
var _paused := false
var _moving := true
var _fx := true
var _bright := false
var _zoomed := false
var _speed := 1.0
var _state: Label
var _pause_button: Button
var _moving_button: Button
var _fx_button: Button
var _bg_button: Button
var _zoom_button: Button

func _ready() -> void:
    get_window().size = Vector2i(1280, 720)
    _lab = AS48_SCENE.instantiate() as Node2D
    if _lab == null:
        push_error("VFX_WEB_REVIEW_REAL_LAB_MISSING")
        return
    add_child(_lab)
    var canvas := CanvasLayer.new()
    canvas.layer = 15
    add_child(canvas)
    var panel := PanelContainer.new()
    panel.name = "WebReviewControls"
    panel.position = Vector2(1036, 114)
    panel.custom_minimum_size = Vector2(226, 0)
    panel.size = Vector2(226, 486)
    canvas.add_child(panel)
    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 7)
    panel.add_child(vbox)
    var title := Label.new()
    title.text = "VFX REVIEW / GODOT WEB"
    title.add_theme_font_size_override("font_size", 16)
    vbox.add_child(title)
    var label := Label.new()
    label.text = "Kiếm Tu · Ngự Kiếm\nPhi Kiếm Truy Ảnh · NHÂN"
    label.add_theme_font_size_override("font_size", 14)
    vbox.add_child(label)
    var badge := Label.new()
    badge.text = "AS48 · CANDIDATE · FRONT"
    badge.add_theme_color_override("font_color", Color("f3c772"))
    vbox.add_child(badge)
    _button(vbox, "Thử lại chiêu", _replay)
    _pause_button = _button(vbox, "Tạm dừng", _toggle_pause)
    _moving_button = _button(vbox, "Quái di chuyển: BẬT", _toggle_moving)
    _fx_button = _button(vbox, "Hiện VFX: BẬT", _toggle_fx)
    _bg_button = _button(vbox, "Nền: TỐI", _toggle_bg)
    _zoom_button = _button(vbox, "Actor: 1×", _toggle_zoom)
    var speed_label := Label.new()
    speed_label.text = "Tốc độ 0.25× — 2×"
    vbox.add_child(speed_label)
    var speed_slider := HSlider.new()
    speed_slider.min_value = 0.25
    speed_slider.max_value = 2.0
    speed_slider.step = 0.25
    speed_slider.value = 1.0
    speed_slider.custom_minimum_size = Vector2(190, 24)
    speed_slider.value_changed.connect(_on_speed)
    vbox.add_child(speed_slider)
    var help := Label.new()
    help.text = "Chỉ có hướng FRONT thật.\nCác hướng khác: chờ Asset."
    help.add_theme_font_size_override("font_size", 12)
    help.add_theme_color_override("font_color", Color("f3c772"))
    vbox.add_child(help)
    _state = Label.new()
    _state.text = "VFX kỹ thuật tạm\nG3 Art-First: CHƯA ĐẠT\nKhông Combat, không PvE"
    _state.add_theme_font_size_override("font_size", 12)
    vbox.add_child(_state)
    _apply()

func _button(parent: BoxContainer, title: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = title
    button.custom_minimum_size = Vector2(192, 34)
    button.pressed.connect(action)
    parent.add_child(button)
    return button

func _apply() -> void:
    if _lab == null:
        return
    _lab.call("review_set_paused", _paused)
    _lab.call("review_set_moving", _moving)
    _lab.call("review_set_fx", _fx)
    _lab.call("review_set_bright", _bright)
    _lab.call("review_set_map_zoom", _zoomed)
    _lab.call("review_set_speed", _speed)

func _replay() -> void:
    _paused = false
    _lab.call("review_replay")
    _pause_button.text = "Tạm dừng"
    _apply()

func _toggle_pause() -> void:
    _paused = not _paused
    _pause_button.text = "Tiếp tục" if _paused else "Tạm dừng"
    _apply()

func _toggle_moving() -> void:
    _moving = not _moving
    _moving_button.text = "Quái di chuyển: BẬT" if _moving else "Quái di chuyển: TẮT"
    _apply()

func _toggle_fx() -> void:
    _fx = not _fx
    _fx_button.text = "Hiện VFX: BẬT" if _fx else "Hiện VFX: TẮT"
    _apply()

func _toggle_bg() -> void:
    _bright = not _bright
    _bg_button.text = "Nền: SÁNG" if _bright else "Nền: TỐI"
    _apply()

func _toggle_zoom() -> void:
    _zoomed = not _zoomed
    _zoom_button.text = "Actor: 2×" if _zoomed else "Actor: 1×"
    _apply()

func _on_speed(value: float) -> void:
    _speed = value
    _apply()
