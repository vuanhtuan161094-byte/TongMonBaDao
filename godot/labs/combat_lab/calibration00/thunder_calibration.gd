extends Control
## VFX-CAL-00 | Original HTML Cửu Thiên Lôi Kiếp -> Godot 4.7.2 GL Compatibility.
## Isolated visual-only Combat Lab. NO combat events, HP, target authority or SaveService.
## Original first-demo rhythm: six 0.31s-spaced strikes, 0.34s each.
## Three locked lab contacts (each revisited twice); no fourth target can receive a flash.
const RIG = preload("res://labs/combat_lab/combat_lab_actor_rig_v2.gd")
const FEATHER = preload("res://labs/combat_lab/calibration00/thunder_feather.gdshader")
const CASTER := Vector2(380.0, 428.0)
const CONTACTS := [
    Vector2(740.0, 309.0),
    Vector2(892.0, 356.0),
    Vector2(1025.0, 306.0)
]
const NEUTRAL := Vector2(925.0, 510.0)
const LOOP_SECONDS := 4.65
const STRIKE_COUNT := 6
const STRIKE_START := 1.15
const STRIKE_SPACING := 0.31
const STRIKE_DURATION := 0.34
const RENDER_SIZE := Vector2(1280.0, 720.0)
const MAX_SIDE_BRANCHES := 1
const WHITE := Color("f1faff")
const LAVENDER := Color("9ba9ff")
const PURPLE := Color("795fff")

var elapsed := 0.0
var paused := false
var _layers: Array = []
var _texture: Texture2D
var _radial: Texture2D
var _title: Label
var _footer: Label

static func strike_age(beat: int, t: float) -> float:
    return t - STRIKE_START - float(beat) * STRIKE_SPACING

static func active_primary_count(t: float) -> int:
    var n := 0
    for i in range(STRIKE_COUNT):
        var age := strike_age(i, t)
        if age >= 0.0 and age < STRIKE_DURATION:
            n += 1
    return n

static func selected_contact(beat: int) -> Vector2:
    return CONTACTS[posmod(beat, CONTACTS.size())]

static func visual_pulse(age: float) -> float:
    if age < 0.0 or age >= STRIKE_DURATION:
        return 0.0
    var k := clampf(age / STRIKE_DURATION, 0.0, 1.0)
    return pow(maxf(0.0, sin(PI * k)), 0.62)

func _ready() -> void:
    custom_minimum_size = RENDER_SIZE
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _texture = _make_white_texture()
    _radial = _make_radial_texture()
    for i in range(STRIKE_COUNT + 1):
        _layers.append(_new_three_layer_beam())
    _title = Label.new()
    _title.position = Vector2(29.0, 19.0)
    _title.add_theme_font_size_override("font_size", 27)
    _title.add_theme_color_override("font_color", Color("ede5ff"))
    _title.text = "CỬU THIÊN LÔI KIẾP  |  CLASSIC LIGHT"
    add_child(_title)
    _footer = Label.new()
    _footer.position = Vector2(29.0, 663.0)
    _footer.add_theme_font_size_override("font_size", 16)
    _footer.add_theme_color_override("font_color", Color("bdc5da"))
    _footer.text = "VFX-CAL-00  ·  LAB ONLY / PVE OFF  ·  SPACE: REPLAY  ·  P: PAUSE"
    add_child(_footer)
    _update_beams()
    set_process(true)

func _make_white_texture() -> Texture2D:
    var im := Image.create(2, 2, false, Image.FORMAT_RGBA8)
    im.fill(Color.WHITE)
    return ImageTexture.create_from_image(im)

func _make_radial_texture() -> Texture2D:
    var im := Image.create(128, 128, false, Image.FORMAT_RGBA8)
    for y in range(128):
        for x in range(128):
            var dx := (float(x) - 63.5) / 63.5
            var dy := (float(y) - 63.5) / 63.5
            var r2 := dx * dx + dy * dy
            var alpha := exp(-6.2 * r2) * (1.0 - smoothstep(0.70, 1.0, sqrt(r2)))
            im.set_pixel(x, y, Color(1.0, 1.0, 1.0, maxf(alpha, 0.0)))
    return ImageTexture.create_from_image(im)

func _new_three_layer_beam() -> Array:
    var result: Array = []
    var widths := [84.0, 30.0, 4.9]
    var colors := [PURPLE, LAVENDER, WHITE]
    var alphas := [0.17, 0.49, 0.94]
    var feathers := [9.1, 6.8, 2.2]
    for i in range(3):
        var line := Line2D.new()
        line.width = widths[i]
        line.default_color = colors[i]
        line.texture = _texture
        line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
        line.joint_mode = Line2D.LINE_JOINT_ROUND
        line.begin_cap_mode = Line2D.LINE_CAP_ROUND
        line.end_cap_mode = Line2D.LINE_CAP_ROUND
        line.round_precision = 16
        line.antialiased = true
        line.z_index = 4 + i
        var mat := ShaderMaterial.new()
        mat.shader = FEATHER
        mat.set_shader_parameter("feather", feathers[i])
        line.material = mat
        line.set_meta("base_alpha", alphas[i])
        line.visible = false
        add_child(line)
        result.append(line)
    return result

func _beam_path(beat: int, t: float) -> PackedVector2Array:
    var contact := selected_contact(beat) + Vector2(0.0, -42.0)
    var x0 := contact.x + sin(float(beat) * 3.0) * 23.0
    var seed := float(beat) + floorf(t * 24.0) * 0.035
    var points := PackedVector2Array([Vector2(x0, -20.0)])
    for j in range(1, 14):
        var p := float(j) / 14.0
        var offset := sin((float(j) + seed) * 18.14) * 24.0 * (1.0 - p * 0.6)
        offset += sin((float(j) + seed) * 4.4) * 11.0
        points.append(Vector2(lerpf(x0, contact.x, p) + offset,
            lerpf(-20.0, contact.y, p)))
    points.append(contact)
    return points

func _reveal_path(points: PackedVector2Array, reveal: float) -> PackedVector2Array:
    var result := PackedVector2Array()
    if points.size() < 2 or reveal <= 0.0:
        return result
    var extent := clampf(reveal, 0.0, 1.0) * float(points.size() - 1)
    result.append(points[0])
    for i in range(points.size() - 1):
        var f := clampf(extent - float(i), 0.0, 1.0)
        if f <= 0.0:
            break
        result.append(points[i].lerp(points[i + 1], f))
        if f < 1.0:
            break
    return result

func _put_beam(slot: int, path: PackedVector2Array, strength: float) -> void:
    var lines: Array = _layers[slot]
    var available := strength > 0.003 and path.size() >= 2
    for line in lines:
        line.visible = available
        if available:
            line.points = path
            line.modulate.a = float(line.get_meta("base_alpha")) * strength

func _relay_path(t: float) -> PackedVector2Array:
    var a: Vector2 = CONTACTS[0] + Vector2(0.0, -43.0)
    var b: Vector2 = CONTACTS[1] + Vector2(0.0, -43.0)
    var points := PackedVector2Array([a])
    for i in range(1, 6):
        var f := float(i) / 6.0
        points.append(a.lerp(b, f) +
            Vector2(0.0, sin(float(i) * 7.7 + floorf(t * 24.0) * 0.1) * 10.0))
    points.append(b)
    return points

func _update_beams() -> void:
    for beat in range(STRIKE_COUNT):
        var age := strike_age(beat, elapsed)
        if age < 0.0 or age >= STRIKE_DURATION:
            _put_beam(beat, PackedVector2Array(), 0.0)
            continue
        # A short downward 48ms reveal; after arrival the bolt holds and flickers.
        var reveal := clampf((age + 0.008) / 0.048, 0.0, 1.0)
        var power := visual_pulse(age) * (0.90 + 0.10 * sin(age * 96.0))
        _put_beam(beat, _reveal_path(_beam_path(beat, elapsed), reveal), power)
    # One faint relay AFTER the primary strikes; never a web of six lines.
    var relay_age := elapsed - 3.065
    if relay_age >= 0.0 and relay_age < 0.16:
        var power := 0.34 * sin(PI * relay_age / 0.16)
        _put_beam(STRIKE_COUNT, _relay_path(elapsed), power)
    else:
        _put_beam(STRIKE_COUNT, PackedVector2Array(), 0.0)

func _process(delta: float) -> void:
    if paused:
        return
    elapsed = fposmod(elapsed + maxf(delta, 0.0), LOOP_SECONDS)
    _update_beams()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        _update_beams()
        queue_redraw()
    elif event.keycode == KEY_P:
        paused = not paused

func _draw() -> void:
    _ground()
    # Actual pre-existing Combat Lab actor renderer. No new character rig.
    for i in range(CONTACTS.size()):
        var p: Vector2 = CONTACTS[i]
        draw_circle(p + Vector2(0.0, 9.0), 27.0, Color(0, 0, 0, 0.30))
        RIG.render(self, {"id": "cal00_dummy_" + str(i),
            "side": "monster", "tier": "normal", "hp": 100.0},
            p, "fist", "idle", elapsed, 1.75, -1.0, 0.0)
    RIG.render(self, {"id": "cal00_caster", "side": "disciple",
        "hp": 100.0}, CASTER, "fist", "cast", elapsed, 2.08, 1.0, 0.18)
    # A fourth monster is intentionally not contacted.
    RIG.render(self, {"id": "cal00_unselected", "side": "monster",
        "tier": "normal", "hp": 100.0},
        NEUTRAL, "fist", "idle", elapsed, 1.70, -1.0, 0.0)
    _ritual()
    var global_flash := 0.0
    for beat in range(STRIKE_COUNT):
        var age := strike_age(beat, elapsed)
        if age >= 0.052 and age < 0.40:
            var gain := (1.0 - smoothstep(0.052, 0.40, age))
            var p := selected_contact(beat) + Vector2(0.0, -36.0)
            _contact(p, age, gain)
            global_flash = maxf(global_flash, 0.064 * gain)
    if global_flash > 0.001:
        draw_rect(Rect2(Vector2.ZERO, RENDER_SIZE),
            Color(0.86, 0.80, 1.0, global_flash))

func _ground() -> void:
    draw_rect(Rect2(Vector2.ZERO, RENDER_SIZE), Color("0b111c"))
    draw_rect(Rect2(35.0, 172.0, 1210.0, 440.0), Color("18222f"))
    for k in range(7):
        var y := 194.0 + float(k) * 62.0
        draw_line(Vector2(65.0, y), Vector2(1235.0, y),
            Color("64778f", 0.075), 1.0)
    for k in range(13):
        var x := 94.0 + float(k) * 94.0
        draw_line(Vector2(x, 182.0), Vector2(x + 140.0, 611.0),
            Color("63758f", 0.055), 1.0)
    for j in range(85):
        var k := float(j)
        var xx := 75.0 + fposmod(k * 79.71 + sin(k * 13.0) * 43.0, 1140.0)
        var yy := 205.0 + fposmod(k * 61.89, 389.0)
        draw_circle(Vector2(xx, yy), 0.75,
            Color("b6bbce", 0.06 + fposmod(k * 0.139, 0.085)))

func _ritual() -> void:
    var charge := smoothstep(0.12, 0.87, elapsed) *         (1.0 - smoothstep(2.9, 3.56, elapsed))
    if charge <= 0.0:
        return
    var center := Vector2(883.0, 431.0)
    draw_texture_rect(_radial,
        Rect2(center - Vector2(184, 74), Vector2(368, 148)), false,
        Color(0.47, 0.36, 0.94, 0.24 * charge))
    draw_texture_rect(_radial,
        Rect2(Vector2(705, -75), Vector2(360, 295)), false,
        Color(0.52, 0.38, 0.95, 0.085 * charge))
    # Only two very faint, flattened circular rituals; not neon target disks.
    for j in range(2):
        var radius := 94.0 + float(j) * 39.0
        var pts := PackedVector2Array()
        for k in range(65):
            var theta := TAU * float(k) / 64.0
            pts.append(center + Vector2(cos(theta) * radius,
                sin(theta) * radius * 0.38))
        draw_polyline(pts, Color("b5a2ff", (0.16 - float(j) * 0.06) * charge),
            1.3, true)

func _contact(p: Vector2, age: float, power: float) -> void:
    # The impact glow is spatially feathered, never a hard white circle.
    var spike := pow(maxf(0.0, 1.0 - smoothstep(0.052, 0.27, age)), 1.4)
    draw_texture_rect(_radial,
        Rect2(p - Vector2(101.0, 93.0), Vector2(202.0, 186.0)),
        false, Color("b5a0ff", power * 0.49))
    draw_texture_rect(_radial,
        Rect2(p - Vector2(40.0, 44.0), Vector2(80.0, 88.0)),
        false, Color("f5eaff", spike * 0.72))
    var life := clampf((age - 0.052) / 0.36, 0.0, 1.0)
    # Six directional, short-lived contact sparks, not a particle blizzard.
    for i in range(6):
        var theta := float(i) * TAU / 6.0 + float(i % 2) * 0.23
        var dir := Vector2(cos(theta), sin(theta) * 0.60)
        var head := p + dir * (7.0 + 65.0 * life)
        var tail := head - dir * (13.0 + 10.0 * (1.0 - life))
        draw_line(tail, head, Color("d6c4ff", power * (1.0 - life) * 0.74),
            1.1 + (1.0 - life) * 1.9, true)
