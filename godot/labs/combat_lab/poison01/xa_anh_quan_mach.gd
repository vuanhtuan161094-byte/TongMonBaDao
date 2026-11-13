extends Control
## VFX-POI-01. Original Gaussian light serpent. VIEW-ONLY isolated scene.
## Single fixed visual dummy; NEVER writes HP, events, targeting, DoT, Save.
## Static owner-approved idle sprite only; NO rig and no character animation.
const SKILL_ID := "tmb.skill.poison.co_doc.active_02.human"
const CASTER := Vector2(330.0, 490.0)
const VICTIM := Vector2(850.0, 490.0)
const LOOP_SECONDS := 4.25
const FLIGHT_START := 0.83
const FLIGHT_END := 1.63
const COIL_START := 1.53
const COIL_PEAK := 2.22
const RELEASE := 2.85
const FADE_END := 3.48
const FLIGHT_FRAMES := 9
const COIL_FRAMES := 12
const MASTER: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const OUTER := Color("755ab0")
const JADE := Color("55d69a")
const HOT := Color("d9ffde")
const EYE := Color("f7ffaf")
var elapsed := 0.0
var paused := false
var _radial: Texture2D
var _flight_frames: Array[Texture2D] = []
var _coil_frames: Array[Texture2D] = []
var _flight: Sprite2D
var _coil: Sprite2D

static func phase_at(t: float) -> String:
    if t < FLIGHT_START: return "charge"
    if t < FLIGHT_END: return "flight"
    if t < RELEASE: return "coil"
    if t < FADE_END: return "dissolve"
    return "idle"

static func anchor() -> Vector2:
    return VICTIM + Vector2(0.0, -44.0)

static func visual_contact(t: float) -> bool:
    return t >= COIL_START and t < FADE_END

static func flight_gain(t: float) -> float:
    if t < FLIGHT_START or t >= FLIGHT_END + 0.12: return 0.0
    return smoothstep(FLIGHT_START, FLIGHT_START + 0.13, t) * (1.0 - smoothstep(FLIGHT_END - 0.10, FLIGHT_END + 0.12, t))

static func coil_gain(t: float) -> float:
    if not visual_contact(t): return 0.0
    return smoothstep(COIL_START, COIL_START + 0.18, t) * (1.0 - smoothstep(RELEASE, FADE_END, t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0, 720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _radial = _bake_radial()
    for i in range(FLIGHT_FRAMES):
        _flight_frames.append(_bake_snake(false, i, FLIGHT_FRAMES))
    for i in range(COIL_FRAMES):
        _coil_frames.append(_bake_snake(true, i, COIL_FRAMES))
    _flight = _layer(true)
    _coil = _layer(false)
    _update_layers()
    set_process(true)
    print("VFX_POI01_READY | ", SKILL_ID, " | VISUAL_ONLY")

func _layer(additive: bool) -> Sprite2D:
    var s := Sprite2D.new()
    s.centered = false
    s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    var material := CanvasItemMaterial.new()
    material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD if additive else CanvasItemMaterial.BLEND_MODE_MIX
    s.material = material
    s.visible = false
    add_child(s)
    return s

func _bake_radial() -> Texture2D:
    var im := Image.create(96, 96, false, Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var n := (Vector2(float(x), float(y)) - Vector2(47.5, 47.5)) / 47.5
            var d2 := n.length_squared()
            var alpha := exp(-6.8 * d2) * (1.0 - smoothstep(0.80, 1.0, sqrt(d2)))
            im.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
    return ImageTexture.create_from_image(im)

func _bake_snake(coil: bool, frame: int, count: int) -> Texture2D:
    # 21 original pre-baked poses at startup, not each render frame.
    # Whole-path Gaussian prevents triangular joins rejected in thunder R2.
    var w := 250 if coil else 350
    var h := 226 if coil else 134
    var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
    im.fill(Color.TRANSPARENT)
    var path: Array[Vector2] = []
    var k := float(frame) / float(maxi(1, count - 1))
    var reveal := (0.32 + 0.68 * k) if coil else 1.0
    var steps := 57 if coil else 35
    for i in range(steps):
        var u := float(i) / float(steps - 1)
        if coil:
            if u > reveal and i > 1: break
            var theta := -2.25 + u * TAU * 1.93 + k * 0.22
            var radius := 51.0 - 21.0 * u + 4.5 * sin(theta * 3.2 + u * 2.1)
            path.append(Vector2(125.0 + cos(theta) * radius,
                126.0 + sin(theta) * radius * 0.72 - 16.0 * u))
        else:
            var wave := 20.0 * sin(u * TAU * 1.32 - k * 1.4) * sin(u * PI)
            wave += 5.0 * sin(u * TAU * 2.4 + k * 2.3) * sin(u * PI)
            path.append(Vector2(62.0 + u * 225.0, 69.0 + wave))
    var a: Array[Vector2] = []
    var d: Array[Vector2] = []
    var inv: Array[float] = []
    for j in range(path.size() - 1):
        var delta: Vector2 = path[j + 1] - path[j]
        a.append(path[j])
        d.append(delta)
        inv.append(1.0 / maxf(delta.length_squared(), 0.001))
    var head: Vector2 = path[path.size() - 1]
    var forward: Vector2 = (head - path[path.size() - 2]).normalized()
    var side := forward.orthogonal()
    var eye1 := head - forward * 6.0 + side * 7.0
    var eye2 := head - forward * 6.0 - side * 7.0
    var hood_center := head - forward * 5.0
    var tongue_base := head + forward * 9.0
    var fork1 := head + forward * 22.0 + side * 5.0
    var fork2 := head + forward * 22.0 - side * 5.0
    for y in range(h):
        for x in range(w):
            var p := Vector2(float(x) + 0.5, float(y) + 0.5)
            var nearest2 := 1.0e12
            var body_u := 0.0
            for j in range(a.size()):
                var f := clampf((p - a[j]).dot(d[j]) * inv[j], 0.0, 1.0)
                var sample_d2 := p.distance_squared_to(a[j] + d[j] * f)
                if sample_d2 < nearest2:
                    nearest2 = sample_d2
                    body_u = (float(j) + f) / float(maxi(1, path.size() - 1))
            var width := 1.6 + (5.2 if coil else 4.6) * smoothstep(0.0, 0.22, body_u)
            var head_glow := exp(-p.distance_squared_to(hood_center) / (2.0 * 10.0 * 10.0))
            var along := (p - hood_center).dot(forward)
            var cross := (p - hood_center).dot(side)
            var head_shape := sqrt(pow(along / 13.0, 2.0) + pow(cross / 10.5, 2.0))
            var hood_fill := 1.0 - smoothstep(0.80, 1.06, head_shape)
            var hood_rim := exp(-pow((head_shape - 0.98) * 7.0, 2.0))
            var outer := 0.23 * exp(-nearest2 / (2.0 * pow(width + 15.0, 2.0)))
            var mid := 0.70 * exp(-nearest2 / (2.0 * pow(width + 3.7, 2.0))) + 0.14 * head_glow
            var core := 0.49 * exp(-nearest2 / (2.0 * pow(width * 0.30 + 0.65, 2.0))) + 0.05 * head_glow
            var weight := outer + mid + core
            if weight < 0.007 and hood_fill < 0.003 and hood_rim < 0.003: continue
            var tint := (OUTER * outer + JADE * mid + HOT * core) / maxf(weight, 0.001)
            tint = tint.lerp(Color("1e6049"), hood_fill * 0.82)
            tint = tint.lerp(Color("93e8b0"), hood_rim * 0.62)
            var eye_d2 := minf(p.distance_squared_to(eye1), p.distance_squared_to(eye2))
            var glint := 1.00 * exp(-eye_d2 / (2.0 * 1.48 * 1.48))
            tint = tint.lerp(EYE, clampf(glint, 0.0, 1.0))
            var tongue := 0.0
            if p.distance_squared_to(head) < 880.0:
                var d1 := fork1 - tongue_base
                var d2 := fork2 - tongue_base
                var f1 := clampf((p - tongue_base).dot(d1) / maxf(d1.length_squared(), 0.001), 0.0, 1.0)
                var f2 := clampf((p - tongue_base).dot(d2) / maxf(d2.length_squared(), 0.001), 0.0, 1.0)
                var t2 := minf(p.distance_squared_to(tongue_base + f1 * d1), p.distance_squared_to(tongue_base + f2 * d2))
                tongue = 0.78 * exp(-t2 / (2.0 * 0.86 * 0.86))
                tint = tint.lerp(Color("f6d49a"), tongue)
            im.set_pixel(x, y, Color(tint.r, tint.g, tint.b,
                clampf(weight + hood_fill * 0.91 + hood_rim * 0.32 + glint + tongue, 0.0, 1.0)))
    return ImageTexture.create_from_image(im)

func _update_layers() -> void:
    if _flight == null or _coil == null: return
    var alpha := flight_gain(elapsed)
    _flight.visible = alpha > 0.002
    if _flight.visible:
        var u := clampf((elapsed - FLIGHT_START) / (FLIGHT_END - FLIGHT_START), 0.0, 1.0)
        var easing := u * u * (3.0 - 2.0 * u)
        var head := (CASTER + Vector2(48.0, -70.0)).lerp(anchor(), easing)
        head.y -= sin(u * PI) * 49.0
        var index := clampi(int(floor(u * float(FLIGHT_FRAMES))), 0, FLIGHT_FRAMES - 1)
        _flight.texture = _flight_frames[index]
        _flight.position = head - Vector2(287.0, 69.0)
        _flight.modulate.a = alpha * (0.92 + 0.08 * sin(elapsed * 21.0))
    var binding := coil_gain(elapsed)
    _coil.visible = binding > 0.002
    if _coil.visible:
        var u := clampf((elapsed - COIL_START) / (COIL_PEAK - COIL_START), 0.0, 1.0)
        var index := clampi(int(floor(u * float(COIL_FRAMES))), 0, COIL_FRAMES - 1)
        _coil.texture = _coil_frames[index]
        _coil.position = anchor() - Vector2(125.0, 126.0)
        var squeeze := smoothstep(COIL_PEAK, RELEASE, elapsed)
        _coil.scale = Vector2(1.0 - 0.055 * squeeze, 1.0 - 0.075 * squeeze)
        _coil.modulate.a = binding * (0.91 + 0.03 * sin(elapsed * 27.0))

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed + maxf(delta, 0.0), LOOP_SECONDS)
    _update_layers()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        _update_layers()
        queue_redraw()
    elif event.keycode == KEY_P:
        paused = not paused

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("091219"))
    draw_texture_rect(_radial, Rect2(55.0, 164.0, 1170.0, 490.0),
        false, Color("36524d", 0.34))
    for i in range(68):
        var k := float(i)
        var gx := 85.0 + fposmod(k * 113.17 + sin(k * 9.0) * 34.0, 1100.0)
        var gy := 268.0 + fposmod(k * 73.49, 340.0)
        draw_circle(Vector2(gx, gy), 0.9, Color("9aa79a", 0.065))
    var charge := smoothstep(0.12, FLIGHT_START - 0.09, elapsed) * (1.0 - smoothstep(FLIGHT_START, 1.29, elapsed))
    if charge > 0.001:
        draw_texture_rect(_radial,
            Rect2(CASTER + Vector2(-93.0, -179.0), Vector2(186.0, 186.0)),
            false, Color("7be8ad", 0.53 * charge))
        for j in range(5):
            var theta := float(j) * 2.399 + elapsed * 1.1
            var mote := CASTER + Vector2(cos(theta) * 37.0, -65.0 + sin(theta) * 26.0)
            draw_texture_rect(_radial, Rect2(mote - Vector2(10, 10), Vector2(20, 20)),
                false, Color("d2ffd6", 0.31 * charge))
    _actor(CASTER, Color.WHITE, 0.40)
    _actor(VICTIM, Color("789c88"), 0.40)
    var bind := coil_gain(elapsed)
    if bind > 0.001:
        var p := anchor()
        draw_texture_rect(_radial, Rect2(p - Vector2(116, 113), Vector2(232, 226)),
            false, Color("7c6fba", 0.16 * bind))
        draw_texture_rect(_radial, Rect2(p - Vector2(75, 77), Vector2(150, 154)),
            false, Color("79f0aa", 0.14 * bind))
        for j in range(3):
            var f := float(j) * 2.12 + elapsed * 0.23
            var a := p + Vector2(cos(f) * 38.0, sin(f) * 37.0)
            draw_line(a, a + Vector2(cos(f + 0.7) * 13.0, -15.0),
                Color("c6ffd7", bind * 0.25), 1.1, true)
    if elapsed >= RELEASE and elapsed < FADE_END:
        var fade := clampf((elapsed - RELEASE) / (FADE_END - RELEASE), 0.0, 1.0)
        for j in range(7):
            var angle := float(j) * 2.399 + 0.3
            var p := anchor() + Vector2(cos(angle) * (24.0 + 46.0 * fade),
                sin(angle) * (16.0 + 43.0 * fade) - 16.0 * fade)
            draw_texture_rect(_radial, Rect2(p - Vector2(13, 13), Vector2(26, 26)),
                false, Color("b9f8bd", 0.35 * (1.0 - fade)))
    draw_string(ThemeDB.fallback_font, Vector2(35.0, 45.0),
        "XÀ ẢNH QUẤN MẠCH   |   ĐỘC TU · CỔ ĐỘC",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("dcf7e0"))
    draw_string(ThemeDB.fallback_font, Vector2(35.0, 683.0),
        "VFX-POI-01 · LAB ONLY · ONE VISUAL TARGET · SPACE REPLAY / P PAUSE",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b5c3bc"))

func _actor(feet: Vector2, tint: Color, scale_factor: float) -> void:
    draw_texture_rect(_radial, Rect2(feet - Vector2(55, 24), Vector2(110, 48)),
        false, Color("000000", 0.27))
    var size := Vector2(320, 384) * scale_factor
    var pos := feet - Vector2(160, 351) * scale_factor
    draw_texture_rect_region(MASTER, Rect2(pos, size),
        Rect2(Vector2.ZERO, Vector2(320, 384)), tint)
