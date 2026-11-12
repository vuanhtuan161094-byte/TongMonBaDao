extends Control
# Official Godot showcase for V9: only runtime generated light geometry.
# Characters use existing Lab atlas/rig; VFX itself uses ZERO painted images.
const Fx = preload("res://labs/combat_lab/combat_lab_v9_energy_fx.gd")
const PoisonAtlas = preload("res://labs/combat_lab/combat_lab_poison_atlas_v1.gd")
const Rig = preload("res://labs/combat_lab/combat_lab_actor_rig_v2.gd")
var effect: Control
var title: Label

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    var school := OS.get_environment("TMB_VFX_V9_SHOWCASE")
    effect = Fx.new()
    effect.name = "AdditiveEnergyVFX"
    effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    effect.caster = Vector2(325, 455)
    effect.target = Vector2(910, 371)
    effect.set_mode("sword" if school == "sword" else "serpent")
    add_child(effect)
    var buttons := HBoxContainer.new()
    buttons.position = Vector2(24, 18)
    buttons.add_theme_constant_override("separation", 12)
    add_child(buttons)
    var serpent := Button.new()
    serpent.text = "1 · ĐỘC QUANG HÓA XÀ"
    serpent.custom_minimum_size = Vector2(225, 40)
    serpent.pressed.connect(func(): effect.call("set_mode", "serpent"); _refresh_title())
    buttons.add_child(serpent)
    var sword := Button.new()
    sword.text = "2 · KIẾM KHÍ QUY TÔNG"
    sword.custom_minimum_size = Vector2(245, 40)
    sword.pressed.connect(func(): effect.call("set_mode", "sword"); _refresh_title())
    buttons.add_child(sword)
    var repeat := Button.new()
    repeat.text = "PHÁT LẠI"
    repeat.pressed.connect(func(): effect.set("elapsed", 0.0))
    buttons.add_child(repeat)
    var pause := Button.new()
    pause.text = "TẠM DỪNG / TIẾP"
    pause.pressed.connect(func(): effect.set("paused", effect.get("paused") != true))
    buttons.add_child(pause)
    title = Label.new()
    title.position = Vector2(28, 645)
    title.add_theme_font_size_override("font_size", 19)
    title.add_theme_color_override("font_color", Color("d9f8fe"))
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(title)
    _refresh_title()

func _refresh_title() -> void:
    title.text = ("VFX09 · VẠN KIẾM QUY TÔNG" if str(effect.get("demo_school")) == "sword" else "VFX09 · ĐỘC QUANG HÓA XÀ") + "  |  Additive · Light ribbons · No skill PNG · Lab only"

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_1:
            effect.call("set_mode", "serpent")
            _refresh_title()
        elif event.keycode == KEY_2:
            effect.call("set_mode", "sword")
            _refresh_title()
        elif event.keycode == KEY_SPACE:
            effect.set("elapsed", 0.0)

func _draw() -> void:
    # Dark arena, restrained environment so light gradients read at 1x.
    draw_rect(Rect2(Vector2.ZERO, size), Color("0d1222"), true)
    draw_rect(Rect2(Vector2(16, 78), Vector2(1248, 550)),
        Color("202637"), true)
    for yy in range(88, 627, 52):
        draw_line(Vector2(24, yy), Vector2(1250, yy),
            Color("353e50"), 1.0)
    for xx in range(30, 1248, 76):
        draw_line(Vector2(xx, 88), Vector2(xx, 622),
            Color("303b50"), 1.0)
    var caster := Vector2(325, 455)
    var is_sword := str(effect.get("demo_school")) == "sword"
    if not is_sword:
        var pose := "cast"
        if not PoisonAtlas.draw(self, caster, pose, float(effect.get("elapsed")),
                0.18, 2.05, 1.0, 0.57):
            Rig.render(self, {"id":"v9caster","side":"disciple","hp":100.0},
                caster, "poison", "cast", float(effect.get("elapsed")), 2.0, 1.0, 0.18)
    else:
        Rig.render(self, {"id":"v9sword","side":"disciple","hp":100.0},
            caster, "bow", "cast", float(effect.get("elapsed")), 2.0, 1.0, 0.18)
    for i in range(4):
        var offset := Vector2(float(i % 2) * 112.0 - 56.0,
            float(floori(float(i) / 2.0)) * 102.0 - 51.0)
        Rig.render(self, {"id":"v9mob_" + str(i),"side":"monster","tier":"normal","hp":100.0},
            Vector2(910, 371) + offset, "fist", "idle",
            float(effect.get("elapsed")), 1.7, -1.0, 0.0)
