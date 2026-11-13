extends Control
# VFX-RESEARCH-01: three independent, owner-reviewable VISUAL treatments.
# MIT-reference technique study; all visuals authored fresh in GDScript.
# LAB ONLY. No combat authority, damage, hitbox, targeting, skill data, or Save.
const OLD = preload("res://labs/combat_lab/combat_lab_v14_sword_fx.gd")
const RIG = preload("res://labs/combat_lab/combat_lab_actor_rig_v2.gd")
const MODE_NAMES := ["V14.2 / DOI CHUNG", "A / NGUYET KIEM KHI", "B / LUU QUANG TAN ANH"]
const DESCRIPTIONS := [
    "Kiem vat the + vong shock / giu nguyen ban cu",
    "Crescent co dau/duoi; 1 cung kiem, it vong sang / REEBOO-inspired",
    "Mui kiem + du anh ngan, contact hit-stop / GDQuest + PSC-inspired"
]
const BACK := Color("101522")
const CYAN := Color("4edce7")
const ICE := Color("e5faff")
const BLUE := Color("3172ba")
const GOLD := Color("f7dba4")
const CASTER := Vector2(298.0, 464.0)
const MOBS := [
    Vector2(855.0, 328.0), Vector2(974.0, 328.0),
    Vector2(855.0, 446.0), Vector2(974.0, 446.0)
]
const LOOP_SECONDS := 2.65
var approved_hits: Array[Vector2] = [MOBS[0], MOBS[1], MOBS[2]]
var locked_center := MOBS[0]
var mode_id := 0
var elapsed := 0.0
var paused := false
var title_label: Label
var detail_label: Label

static func flight_window(wave: int, slot: int) -> Vector2:
    var begin := 0.265 + float(wave) * 0.135 + float(slot) * 0.014
    return Vector2(begin, begin + 0.173)

static func impact_window(wave: int, slot: int) -> Vector2:
    var begin := flight_window(wave, slot).y
    return Vector2(begin, begin + 0.188)

static func phase(t: float) -> float:
    return clampf(t, 0.0, 1.0)

static func ease_out(t: float) -> float:
    var k := phase(t)
    return 1.0 - pow(1.0 - k, 2.6)

static func ink_alpha(age: float) -> float:
    return 1.0 - smoothstep(0.37, 1.0, phase(age))

static func approved_demo_hits() -> Array[Vector2]:
    return [MOBS[0], MOBS[1], MOBS[2]]

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    var env := OS.get_environment("TMB_VFX_RESEARCH_MODE").to_lower()
    if env == "crescent" or env == "a":
        mode_id = 1
    elif env == "afterimage" or env == "b":
        mode_id = 2
    else:
        mode_id = 0
    title_label = Label.new()
    title_label.position = Vector2(30, 24)
    title_label.add_theme_font_size_override("font_size", 28)
    title_label.add_theme_color_override("font_color", ICE)
    add_child(title_label)
    detail_label = Label.new()
    detail_label.position = Vector2(30, 652)
    detail_label.add_theme_font_size_override("font_size", 17)
    detail_label.add_theme_color_override("font_color", Color("c4d9ec"))
    add_child(detail_label)
    _refresh_title()
    set_process(true)

func _refresh_title() -> void:
    title_label.text = "VFX RESEARCH 01 | " + MODE_NAMES[mode_id]
    detail_label.text = DESCRIPTIONS[mode_id] + "   |   1/2/3: doi mau    SPACE: phat lai    P: dung"
    queue_redraw()

func set_mode_id(value: int) -> void:
    mode_id = clampi(value, 0, 2)
    elapsed = 0.0
    if title_label != null:
        _refresh_title()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1: set_mode_id(0)
        KEY_2: set_mode_id(1)
        KEY_3: set_mode_id(2)
        KEY_SPACE:
            elapsed = 0.0
            queue_redraw()
        KEY_P: paused = not paused

func _process(delta: float) -> void:
    if not paused:
        elapsed += clampf(delta, 0.0, 0.06)
        queue_redraw()

func _tint(c: Color, a: float) -> Color:
    return Color(c.r, c.g, c.b, clampf(a, 0.0, 1.0))

func _draw() -> void:
    var t := fposmod(elapsed, LOOP_SECONDS) / LOOP_SECONDS
    _arena()
    # Same caster, four real demo monster rigs, three permitted visual targets
    # for ALL variants. The diagonal fourth monster is NEVER flashed.
    for i in range(MOBS.size()):
        var p: Vector2 = MOBS[i]
        draw_circle(p + Vector2(0, 10), 23.0, _tint(Color.BLACK, 0.3))
        RIG.render(self,
            {"id": "research01_mob_" + str(i), "side": "monster",
             "tier": "normal", "hp": 100.0}, p, "fist", "idle",
             elapsed, 1.72, -1.0, 0.0)
    RIG.render(self,
        {"id": "research01_caster", "side": "disciple", "hp": 100.0},
        CASTER, "fist", "cast", elapsed, 2.0, 1.0, 0.18)
    _target_telegraph(t)
    if mode_id == 0:
        OLD.render(self, CASTER + Vector2(0.0, -60.0), locked_center,
            approved_hits, Vector2(130.0, 120.0), t, 1.55, 2)
    elif mode_id == 1:
        _crescent_mode(t)
    else:
        _afterimage_mode(t)
    # Dim preview-only fourth mob; this marker is not a hit event.
    draw_arc(MOBS[3] + Vector2(0.0, 12.0), 21.0, 0.0, TAU, 30,
        _tint(Color("8c949d"), 0.28), 1.2, true)
    draw_line(Vector2(20.0, 625.0), Vector2(1260.0, 625.0),
        _tint(CYAN, 0.12), 1.0, true)

func _arena() -> void:
    draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), BACK)
    draw_rect(Rect2(18, 90, 1244, 527), Color("202a36"))
    for yy in range(100, 615, 48):
        draw_line(Vector2(22, yy), Vector2(1257, yy),
            Color("38434f", 0.37), 1.0)
    for xx in range(32, 1260, 70):
        draw_line(Vector2(xx, 94), Vector2(xx, 614),
            Color("38434f", 0.30), 1.0)
    draw_circle(CASTER + Vector2(0, 12), 48.0, _tint(BLUE, 0.06))

func _target_telegraph(t: float) -> void:
    var fade := smoothstep(0.13, 0.25, t) * (1.0 - smoothstep(0.83, 0.98, t))
    for j in range(approved_hits.size()):
        var p: Vector2 = approved_hits[j]
        draw_arc(p + Vector2(0, 11), 22, 0.0, TAU, 32,
            _tint(GOLD, fade * 0.32), 1.1, true)

# Technique A: REEBOO-inspired tapered crescent body instead of 3D sword.
# Original ring segments and sampled polygons; NO REEBOO source asset copied.
func _crescent_mode(t: float) -> void:
    for wave in range(3):
        for slot in range(3):
            var victim: Vector2 = approved_hits[slot]
            var win := flight_window(wave, slot)
            var u := (t - win.x) / (win.y - win.x)
            if u >= 0.0 and u < 1.0:
                _approach(victim, u, wave, slot, false)
            var hit := impact_window(wave, slot)
            var age := (t - hit.x) / (hit.y - hit.x)
            if age >= 0.0 and age < 1.0:
                var at := victim + Vector2(0.0, -25.0)
                var strength := (0.46 if wave == 0 else
                    (0.62 if wave == 1 else 0.88)) * ink_alpha(age)
                _crescent(at + Vector2(-7.0, -2.0),
                    56.0 + age * 19.0, 44.0 + age * 11.0,
                    -2.72 + float(slot) * 0.13, 0.72 + float(slot) * 0.09,
                    strength, 12.5, BLUE)
                _crescent(at, 56.0 + age * 19.0, 43.0 + age * 11.0,
                    -2.65 + float(slot) * 0.13, 0.70 + float(slot) * 0.09,
                    strength * 0.77, 5.5, CYAN)
                _arc_tip(at, age, strength, float(slot))
                if wave == 2:
                    _hit_sparks(at, age, strength * 0.45, slot, true)
    # AOE readability: one LARGE, controlled saber crescent per volley.
    # This is not a new hit; only the three approved victims get contact cuts.
    for wave in range(3):
        var contact := impact_window(wave, 1).x
        var age := (t - contact) / 0.285
        if age < 0.0 or age >= 1.0:
            continue
        var body := (0.30 if wave == 0 else
            (0.47 if wave == 1 else 0.62)) * ink_alpha(age)
        var center := Vector2(916.0, 388.0)
        var radius := 132.0 + 23.0 * ease_out(age)
        _crescent(center + Vector2(-6.0, 4.0), radius, 88.0 + 13.0 * age,
            -2.83, 0.38, body, 23.0, BLUE)
        _crescent(center, radius, 86.0 + 12.0 * age,
            -2.77, 0.43, body * 0.88, 9.0, CYAN)
        _crescent(center - Vector2(15.0, 7.0), radius * 0.83,
            70.0 + 9.0 * age, -2.75, 0.40,
            body * 0.22, 2.3, GOLD)

func _crescent(at: Vector2, rx: float, ry: float, angle_a: float,
        angle_b: float, alpha: float, body_width: float, hue: Color) -> void:
    if alpha < 0.01:
        return
    var poly := PackedVector2Array()
    var cuts := 26
    for i in range(cuts + 1):
        var u := float(i) / float(cuts)
        var ang := lerpf(angle_a, angle_b, u)
        var width := maxf(0.35, body_width * pow(sin(PI * u), 0.78))
        poly.append(at + Vector2(cos(ang) * (rx + width),
            sin(ang) * (ry + width * 0.74)))
    for i in range(cuts, -1, -1):
        var u := float(i) / float(cuts)
        var ang := lerpf(angle_a, angle_b, u)
        var width := maxf(0.35, body_width * pow(sin(PI * u), 0.78))
        poly.append(at + Vector2(cos(ang) * (rx - width),
            sin(ang) * (ry - width * 0.74)))
    draw_colored_polygon(poly, _tint(hue, alpha * 0.60))
    var edge := PackedVector2Array()
    for i in range(cuts + 1):
        var u := float(i) / float(cuts)
        var ang := lerpf(angle_a, angle_b, u)
        edge.append(at + Vector2(cos(ang) * rx, sin(ang) * ry))
    draw_polyline(edge, _tint(ICE, alpha * 0.78), 1.55, true)

func _arc_tip(at: Vector2, age: float, alpha: float, seed: float) -> void:
    var phi := -2.65 + 3.3 * ease_out(age)
    var p := at + Vector2(cos(phi) * (56.0 + age * 19.0),
        sin(phi) * (43.0 + age * 11.0))
    draw_circle(p, 2.0 + 2.0 * (1.0 - age), _tint(ICE, alpha * 0.75))
    var tail := p + Vector2(-13.0, 10.0 + seed)
    draw_line(tail, p, _tint(CYAN, alpha * 0.50), 1.6, true)

# Technique B: GDQuest-inspired short-lived afterimages, PSC-style hit cue.
# BurstParticles2D studied for burst timing but NOT imported into the lab.
func _afterimage_mode(t: float) -> void:
    for wave in range(3):
        for slot in range(3):
            var victim: Vector2 = approved_hits[slot]
            var win := flight_window(wave, slot)
            var u := (t - win.x) / (win.y - win.x)
            if u >= 0.0 and u < 1.0:
                _approach(victim, u, wave, slot, true)
            var hit := impact_window(wave, slot)
            var age := (t - hit.x) / (hit.y - hit.x)
            if age >= 0.0 and age < 1.0:
                var at := victim + Vector2(0.0, -22.0)
                var a := (0.51 if wave == 0 else
                    (0.72 if wave == 1 else 0.98)) * ink_alpha(age)
                _oblique_cut(at, age, a, slot)
                if wave == 2:
                    _hit_sparks(at, age, a * 0.7, slot, false)
    # Strong diagonal master stroke across the 3-target footprint:
    # one visible directional axis, not 9 independent glowing circles.
    for wave in range(3):
        var contact := impact_window(wave, 1).x
        var age := (t - contact) / 0.31
        if age < 0.0 or age >= 1.0:
            continue
        var alpha := (0.32 if wave == 0 else
            (0.48 if wave == 1 else 0.74)) * ink_alpha(age)
        _oblique_cut(Vector2(914.0, 388.0), age, alpha, 1, 3.0)
        var direction := Vector2(0.88, -0.48)
        draw_line(Vector2(914.0, 388.0) - direction * 130.0 +
            direction.orthogonal() * 17.0,
            Vector2(914.0, 388.0) + direction * 128.0 +
            direction.orthogonal() * 17.0,
            _tint(BLUE, alpha * 0.16), 3.0, true)

func _approach(victim: Vector2, u: float, wave: int,
        slot: int, afterimage: bool) -> void:
    var origin := CASTER + Vector2(44.0, -95.0 + float(slot - 1) * 27.0)
    var stop := victim + Vector2(-34.0, -25.0)
    var p := origin.lerp(stop, ease_out(u))
    var direction := (stop - origin).normalized()
    var normal := direction.orthogonal()
    var fade := (smoothstep(0.0, 0.18, u) *
        (1.0 - smoothstep(0.73, 0.98, u)))
    if fade < 0.01:
        return
    var body := (0.7 if afterimage else 0.4) * fade
    var size := 61.0 if afterimage else 49.0
    if afterimage:
        for j in range(3, 0, -1):
            var ghost := p - direction * float(j) * 15.0
            _tapered_ray(ghost, direction, normal, size * 0.85,
                body * float(4 - j) * 0.15, BLUE)
    _tapered_ray(p, direction, normal, size,
        body * (0.79 if afterimage else 0.48), CYAN)
    draw_line(p - direction * size * 0.69, p,
        _tint(ICE, body * 0.66), 1.4, true)
    if not afterimage:
        var whisp := p - direction * size * 1.5
        draw_line(whisp + normal * (5.0 + float(wave)),
            p - direction * size * 0.7,
            _tint(BLUE, fade * 0.24), 2.0, true)

func _tapered_ray(tip: Vector2, dir: Vector2, normal: Vector2,
        length: float, a: float, color: Color) -> void:
    var root := tip - dir * length
    var shoulder := root.lerp(tip, 0.58)
    draw_colored_polygon(PackedVector2Array([
        root - normal * 2.5, shoulder - normal * 6.0, tip,
        shoulder + normal * 6.0, root + normal * 2.5
    ]), _tint(color, a))

func _oblique_cut(at: Vector2, age: float, alpha: float,
        slot: int, scale_factor: float = 1.0) -> void:
    # A single strong diagonal sword stroke; no opaque, full-body white flash.
    var axis := Vector2(0.88, -0.48).rotated(float(slot - 1) * 0.10)
    var n := axis.orthogonal()
    var spread := (35.0 + 15.0 * ease_out(age)) * scale_factor
    var start := at - axis * spread
    var end := at + axis * spread
    var taper := 6.5 * scale_factor * (1.0 - 0.72 * age)
    draw_colored_polygon(PackedVector2Array([
        start, at - n * taper * 1.5, end,
        at + n * taper * 1.5
    ]), _tint(BLUE, alpha * 0.35))
    draw_line(start, end, _tint(CYAN, alpha * 0.76),
        minf(6.8, 3.6 * scale_factor), true)
    draw_line(start + axis * 8.0, end - axis * 8.0,
        _tint(ICE, alpha * 0.84), minf(2.8, 1.4 * scale_factor), true)
    # A modest ink-blue echo carries motion while preserving monster art.
    if age > 0.08:
        var shift := n * (6.0 + age * 9.0)
        draw_line(start + shift, end + shift,
            _tint(BLUE, alpha * 0.26), 2.3, true)
    var rr := (19.0 + age * 28.0) * scale_factor
    draw_arc(at + Vector2(0.0, 25.0), rr,
        -2.4, -0.14, 24, _tint(CYAN, alpha * 0.19), 1.3, true)

func _hit_sparks(at: Vector2, age: float, alpha: float,
        slot: int, crescent: bool) -> void:
    for j in range(5):
        var direction := Vector2.from_angle(
            float(j) * TAU / 5.0 + float(slot) * 0.45)
        var root := at + direction * (8.0 + age * 14.0)
        var tip := at + direction * (19.0 + age * 26.0)
        draw_line(root, tip,
            _tint(GOLD if (j % 2 == 0 and crescent) else CYAN,
                alpha * (1.0 - age) * 0.5), 1.2, true)
