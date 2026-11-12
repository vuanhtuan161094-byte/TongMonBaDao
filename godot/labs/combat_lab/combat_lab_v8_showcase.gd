extends Control
# Godot scene for V8 readability review. RENDER_ONLY / LAB_ONLY.
# Keys 1,2 or touch buttons choose spell. Space restarts; no combat state exists.
const Fx = preload("res://labs/combat_lab/combat_lab_vfx_v8_jian_serpent.gd")
const POISON := Color("a7eeb7")
const ICE := Color("b0eafb")
var selected := 0
var clock := 0.0
var pause := false
var caption: Label
var play_button: Button

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    if OS.get_environment("TMB_VFX_V8_SHOWCASE") == "sword":
        selected = 1
    var bar := HBoxContainer.new()
    bar.position = Vector2(18, 14)
    bar.add_theme_constant_override("separation", 12)
    add_child(bar)
    var serpent_button := Button.new()
    serpent_button.text = "1 · U MINH ĐỘC XÀ"
    serpent_button.custom_minimum_size = Vector2(200, 42)
    serpent_button.pressed.connect(func(): _select(0))
    bar.add_child(serpent_button)
    var swords_button := Button.new()
    swords_button.text = "2 · VẠN KIẾM QUY TÔNG"
    swords_button.custom_minimum_size = Vector2(245, 42)
    swords_button.pressed.connect(func(): _select(1))
    bar.add_child(swords_button)
    play_button = Button.new()
    play_button.text = "TẠM DỪNG"
    play_button.custom_minimum_size = Vector2(130, 42)
    play_button.pressed.connect(_toggle_pause)
    bar.add_child(play_button)
    var replay := Button.new()
    replay.text = "PHÁT LẠI"
    replay.custom_minimum_size = Vector2(120, 42)
    replay.pressed.connect(func(): clock = 0.0)
    bar.add_child(replay)
    caption = Label.new()
    caption.position = Vector2(24, 665)
    caption.add_theme_font_size_override("font_size", 18)
    caption.add_theme_color_override("font_color", Color("d8e9eb"))
    caption.text = "VFX V8 · GODOT 4.7.2 · LAB_ONLY · chỉ trình diễn hình ảnh, không tạo sát thương"
    add_child(caption)

func _select(mode: int) -> void:
    selected = clampi(mode, 0, 1)
    clock = 0.0
    queue_redraw()

func _toggle_pause() -> void:
    pause = not pause
    play_button.text = "TIẾP TỤC" if pause else "TẠM DỪNG"

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_1:
            _select(0)
        elif event.keycode == KEY_2:
            _select(1)
        elif event.keycode == KEY_SPACE:
            clock = 0.0
        elif event.keycode == KEY_P:
            _toggle_pause()

func _process(delta: float) -> void:
    if not pause:
        clock += minf(delta, 0.1)
        queue_redraw()

func _actor(p: Vector2, enemy: bool) -> void:
    var coat := Color("383743") if enemy else Color("3d285d")
    draw_ellipse_placeholder(p, enemy)
    draw_circle(p + Vector2(0, -50), 17.0, Color("e5c6a9"))
    draw_colored_polygon(PackedVector2Array([
        p + Vector2(-21, -37), p + Vector2(20, -37),
        p + Vector2(31, -5), p + Vector2(-30, -5)
    ]), coat)
    draw_line(p + Vector2(0, -42), p + Vector2(4, -8),
        Color("d8c6ec"), 2.0, true)

func draw_ellipse_placeholder(p: Vector2, enemy: bool) -> void:
    draw_circle(p, 25.0, Color("11131d" if enemy else "170e26"))
    draw_line(p + Vector2(-18, -6), p + Vector2(19, -6),
        Color("56576b" if enemy else "8155b5"), 3.0, true)

func _draw() -> void:
    var w := size.x
    var h := size.y
    var k := minf(w / 1280.0, h / 720.0)
    var offset := Vector2((w - 1280.0 * k) * 0.5, (h - 720.0 * k) * 0.5)
    draw_set_transform(offset, 0.0, Vector2.ONE * k)
    draw_rect(Rect2(0, 0, 1280, 720), Color("111925"))
    draw_rect(Rect2(20, 80, 1240, 560), Color("283044"))
    # Quiet stone floor to leave negative space for actual spell shapes.
    for yy in range(90, 620, 55):
        draw_line(Vector2(30, yy), Vector2(1250, yy),
            Color("394457"), 1.0)
    for xx in range(40, 1250, 75):
        draw_line(Vector2(xx, 85), Vector2(xx, 630),
            Color("364053"), 1.0)
    var caster := Vector2(330, 454)
    var target := Vector2(897, 383)
    _actor(caster, false)
    for i in range(4):
        _actor(target + Vector2(float(i % 2) * 95.0 - 44.0,
            float(i / 2) * 98.0 - 49.0), true)
    var phase := fposmod(clock, 2.5) / 2.5
    if selected == 0:
        if phase < 0.12:
            draw_arc(caster + Vector2(0, -12), 48,
                0.0, TAU, 40, Color("6bc568"), 3.0, true)
        elif phase < 0.72:
            Fx.cobra(self, caster + Vector2(10, -37), target + Vector2(0, -40),
                (phase - 0.12) / 0.60, 1.8)
        else:
            Fx.cobra_impact(self, target + Vector2(0, -30),
                (phase - 0.72) / 0.28, 1.5)
    else:
        Fx.sword_array(self, caster + Vector2(0, -58),
            target + Vector2(0, -30), phase, 1.7, 12)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
