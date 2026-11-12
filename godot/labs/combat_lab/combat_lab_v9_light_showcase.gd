extends Control
# Official Godot showcase for V9: only runtime generated light geometry.
# Characters use existing Lab atlas/rig; VFX itself uses ZERO painted images.
const Fx = preload("res://labs/combat_lab/combat_lab_v9_energy_fx.gd")
const PoisonAtlas = preload("res://labs/combat_lab/combat_lab_poison_atlas_v1.gd")
const Rig = preload("res://labs/combat_lab/combat_lab_actor_rig_v2.gd")
const SWORD_GLOW = preload("res://labs/combat_lab/combat_lab_v11_arcane_circle.gdshader")
const SWORD_TARGETS = preload("res://labs/combat_lab/combat_lab_v13_sword_fx.gd")
var effect: Control
var title: Label
var charge_glow: ColorRect
var target_glow: ColorRect
var preview_positions: Array = []
var preview_primary_index := 0
var preview_hit_count := 0
const PREVIEW_RADIUS_PX := Vector2(130.0, 120.0)

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
    # Four demo monsters are visible, but only targets in the actual
    # demo footprint and first 3 catalogue slots receive sword visuals.
    # This is a deterministic visual demonstration, NOT live PvE authority.
    for i in range(4):
        preview_positions.append(effect.target + Vector2(
            float(i % 2) * 112.0 - 56.0,
            float(floori(float(i) / 2.0)) * 102.0 - 51.0))
    _set_preview_primary(0)
    # Bounded shader layers stay BEHIND V11 normal-alpha sword geometry.
    # Their emission changes only from the deterministic demo timeline.
    charge_glow = _make_glow(0, effect.caster + Vector2(0, -62))
    target_glow = _make_glow(1, preview_positions[preview_primary_index])
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
    sword.text = "2 · CỬU KIẾM LIÊN HOÀN"
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

func _set_preview_primary(index: int) -> void:
    if preview_positions.is_empty():
        return
    preview_primary_index = clampi(index, 0, preview_positions.size() - 1)
    var center: Vector2 = preview_positions[preview_primary_index]
    var hits: Array = SWORD_TARGETS.preview_circle_targets(
        preview_positions, center, PREVIEW_RADIUS_PX, 3)
    preview_hit_count = hits.size()
    if effect != null:
        effect.call("set_sword_preview", center, hits, PREVIEW_RADIUS_PX)
    if target_glow != null:
        target_glow.position = center - target_glow.size * 0.5
    queue_redraw()

func _make_glow(mode: int, center: Vector2) -> ColorRect:
    var rect := ColorRect.new()
    rect.name = "SwordArcaneCharge" if mode == 0 else "SwordArcaneAOE"
    rect.size = Vector2(350, 350)
    rect.position = center - rect.size * 0.5
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var mat := ShaderMaterial.new()
    mat.shader = SWORD_GLOW
    mat.set_shader_parameter("ritual_mode", mode)
    rect.material = mat
    add_child(rect)
    move_child(rect, 0)
    return rect

func _process(_delta: float) -> void:
    if effect == null:
        return
    var progress := fposmod(float(effect.get("elapsed")),
        float(effect.get("loop_seconds"))) / float(effect.get("loop_seconds"))
    for glow in [charge_glow, target_glow]:
        if glow == null:
            continue
        glow.visible = str(effect.get("demo_school")) == "sword"
        var mat := glow.material as ShaderMaterial
        if mat != null:
            mat.set_shader_parameter("progress", progress)

func _refresh_title() -> void:
    var sword := str(effect.get("demo_school")) == "sword"
    title.text = (
        "VFX13 · CỬU KIẾM LIÊN HOÀN · TÂM QUÁI %d · NGẮM %d/4 · BẤM QUÁI ĐỂ CHỌN · LAB" %
        [preview_primary_index + 1, preview_hit_count]
        if sword else "VFX09 · ĐỘC QUANG HÓA XÀ · LAB ONLY")
    charge_glow.visible = sword
    target_glow.visible = sword
    queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var click: InputEventMouseButton = event
        if click.pressed and click.button_index == MOUSE_BUTTON_LEFT and str(effect.get("demo_school")) == "sword":
            for i in range(preview_positions.size()):
                var monster: Vector2 = preview_positions[i]
                if click.position.distance_to(monster + Vector2(0, -20)) <= 44.0:
                    _set_preview_primary(i)
                    effect.set("elapsed", 0.0)
                    _refresh_title()
                    return
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
        # Sword-cultivator preview must not wield a bow: this is a VFX
        # showcase, not a claim that the full sword actor asset exists.
        Rig.render(self, {"id":"v9sword","side":"disciple","hp":100.0},
            caster, "fist", "cast", float(effect.get("elapsed")), 2.0, 1.0, 0.18)
    if is_sword and preview_positions.size() == 4:
        var primary: Vector2 = preview_positions[preview_primary_index]
        draw_circle(primary + Vector2(0.0, 15.0), 15.0,
            Color("70d7ff", 0.15))
        draw_arc(primary + Vector2(0.0, 15.0), 24.0, 0.0, TAU,
            28, Color("e6d09d", 0.68), 2.0, true)
    for i in range(preview_positions.size()):
        Rig.render(self, {"id":"v9mob_" + str(i),"side":"monster","tier":"normal","hp":100.0},
            preview_positions[i], "fist", "idle",
            float(effect.get("elapsed")), 1.7, -1.0, 0.0)
