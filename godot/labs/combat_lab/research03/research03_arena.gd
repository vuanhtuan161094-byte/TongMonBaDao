extends "res://labs/combat_lab/research01/research01_arena.gd"
# VFX18 — LIGHTCORE2D. One luminous qi first; second mode = a REAL
# orbiting light-streak formation inspired by owner-approved REFERENCE frame.
# This is strictly a MOCK/ART LAB, not a V6.3 skill or a combat event.
const LIGHT_SHADER = preload("res://labs/combat_lab/research03/light_core_2d.gdshader")
const HIT_SHADER = preload("res://labs/combat_lab/research03/light_contact_2d.gdshader")
const NEW_COLOR := Color("59d8fa")
const SKY := Color("d9faff")
const FIELD_CENTER := Vector2(620.0, 354.0)
const LIGHT_CASTER := Vector2(298.0, 464.0)
const CYCLE_SECONDS := 3.2
const PROJECTILE_START := 0.255
const CONTACT := 0.744
const CONTACT_END := 0.824
const PROJECTILE_REACH := 0.875 # its local x tip on ColorRect
const ORBIT_COUNT := 16 # decorative streaks; NONE represent hit events
var study_mode := 0 # 0 = one luminous sword-qi, 1 = rotating sword-qi array.
var blades: Array[ColorRect] = []
var contacts: Array[ColorRect] = []
var intensity_cache: Array[float] = []
var elapsed_local := 0.0

static func _clamp(v: float) -> float:
    return clampf(v, 0.0, 1.0)

static func _smooth(v: float) -> float:
    var z := _clamp(v)
    return z * z * (3.0 - 2.0 * z)

static func approved_target() -> Vector2:
    return Vector2(855.0, 328.0)

static func start_point() -> Vector2:
    return LIGHT_CASTER + Vector2(44.0, -82.0)

static func stop_point() -> Vector2:
    # Keep the energy tip clearly BEFORE the victim's chest/face.
    return approved_target() + Vector2(-40.0, -34.0)

static func cubic(a: Vector2, b: Vector2, c: Vector2, d: Vector2,
        u: float) -> Vector2:
    var v := _clamp(u)
    var inv := 1.0 - v
    return a * inv * inv * inv + b * (3.0 * inv * inv * v) \
        + c * (3.0 * inv * v * v) + d * v * v * v

static func flight_head(u: float) -> Vector2:
    var a := start_point()
    var d := stop_point()
    return cubic(a, a.lerp(d, 0.30) + Vector2(0.0, -78.0),
        a.lerp(d, 0.67) + Vector2(0.0, -59.0), d, pow(_clamp(u), 1.2))

static func flight_direction(u: float) -> Vector2:
    var lo := flight_head(maxf(0.0, u - 0.015))
    var hi := flight_head(minf(1.0, u + 0.015))
    var diff := hi - lo
    return diff.normalized() if diff.length_squared() > 0.0001 else Vector2.RIGHT

static func orbit_streak(i: int, t: float) -> Dictionary:
    var ring := i % 2
    var j := int(i / 2)
    var theta := (float(j) / 8.0) * TAU + t * TAU * (0.91 if ring == 0 else -0.62)
    var rx := 190.0 if ring == 0 else 239.0
    var ry := 120.0 if ring == 0 else 150.0
    var angle_offset := 0.08 if ring == 0 else 0.48
    theta += angle_offset
    var pt := FIELD_CENTER + Vector2(cos(theta) * rx, sin(theta) * ry)
    var tangent := Vector2(-sin(theta) * rx, cos(theta) * ry)
    if ring != 0:
        tangent = -tangent
    var axis := tangent.normalized()
    # Deliberately uneven lengths / intensity, deterministic frame to frame.
    var variation := sin(float(j) * 2.71 + float(ring) * 1.9)
    var length := (110.0 if ring == 0 else 93.0) + variation * 19.0
    var brightness := 0.52 + 0.16 * variation + (0.13 if ring == 0 else 0.0)
    return {
        "position": pt, "axis": axis, "length": length,
        "energy": clampf(brightness, 0.22, 0.94),
        "ring": ring,
        "theta": theta,
    }

func _ready() -> void:
    super._ready()
    title_label.text = "VFX18 | LIGHTCORE2D — KIEM KHI ANH SANG"
    detail_label.text = "1: mot kiem khi  2: kiem tran xoay  SPACE: phat lai  P: tam dung  |  MOCK LAB / PVE HOLD"
    study_mode = 1 if OS.get_environment("TMB_VFX18_MODE") == "orbit" else 0
    # The entire sword-qi is mathematical light: ColorRect quad + shader.
    # NO image material, metal sword, or JX/Source-A VFX textures.
    for i in range(ORBIT_COUNT):
        var panel := ColorRect.new()
        panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        panel.color = Color.WHITE
        panel.visible = false
        var mat := ShaderMaterial.new()
        mat.shader = LIGHT_SHADER
        mat.set_shader_parameter("seed", float(i) * 1.17)
        mat.set_shader_parameter("width_bias", 0.82 if i % 2 else 1.0)
        panel.material = mat
        panel.z_index = 1
        add_child(panel)
        blades.append(panel)
    var hit := ColorRect.new()
    hit.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hit.color = Color.WHITE
    hit.material = ShaderMaterial.new()
    (hit.material as ShaderMaterial).shader = HIT_SHADER
    hit.size = Vector2(132.0, 108.0)
    hit.visible = false
    hit.z_index = 2
    add_child(hit)
    contacts.append(hit)
    _update_visuals()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1:
            study_mode = 0
            elapsed = 0.0
        KEY_2:
            study_mode = 1
            elapsed = 0.0
        KEY_SPACE:
            elapsed = 0.0
        KEY_P:
            paused = not paused
    _update_visuals()
    queue_redraw()

func _process(delta: float) -> void:
    super._process(delta)
    _update_visuals()

func _place_light(panel: ColorRect, at: Vector2,
        axis: Vector2, length: float, height: float, energy: float,
        t: float) -> void:
    panel.visible = energy > 0.025
    if not panel.visible:
        return
    var f := axis.normalized()
    var side := f.orthogonal()
    panel.size = Vector2(length, height)
    panel.rotation = f.angle()
    panel.position = at - f * length * PROJECTILE_REACH - side * height * 0.5
    var shader_mat := panel.material as ShaderMaterial
    shader_mat.set_shader_parameter("energy", _clamp(energy))
    shader_mat.set_shader_parameter("phase", _clamp(t))

func _update_visuals() -> void:
    if blades.is_empty():
        return
    var t := fposmod(elapsed, CYCLE_SECONDS) / CYCLE_SECONDS
    for panel in blades:
        panel.visible = false
    for obj in contacts:
        obj.visible = false
    if study_mode == 0:
        # One bullet/one approved mock target/one visual contact only.
        var charge := _smooth(t / 0.18)
        var p := (t - PROJECTILE_START) / (CONTACT - PROJECTILE_START)
        if p >= 0.0 and p < 1.0:
            var k := _clamp(p)
            var head := flight_head(k)
            var axis := flight_direction(k)
            var fade_in := _smooth(k / 0.095)
            var fade_out := 1.0 - _smooth((k - 0.91) / 0.09)
            _place_light(blades[0], head, axis, 245.0, 84.0,
                charge * fade_in * fade_out, k)
        if t >= CONTACT and t < CONTACT_END:
            var hit_age := _clamp((t - CONTACT) / (CONTACT_END - CONTACT))
            var hit := contacts[0]
            hit.visible = true
            hit.size = Vector2(132.0 + 20.0 * hit_age, 108.0 + 8.0 * hit_age)
            hit.position = stop_point() - hit.size * 0.5
            var m := hit.material as ShaderMaterial
            m.set_shader_parameter("age", hit_age)
            m.set_shader_parameter("power", 0.92)
    else:
        # The owner reference is a real orbit: 2 projected depths, opposite
        # velocities, tangents and brightness are not uniform spokes.
        var wake := _smooth(t / 0.10) * (1.0 - _smooth((t - 0.83) / 0.15))
        for i in range(ORBIT_COUNT):
            var info := orbit_streak(i, t)
            var panel := blades[i]
            var strength := float(info["energy"]) * wake
            _place_light(panel, info["position"], info["axis"],
                float(info["length"]), 56.0, strength, t)
            var m := panel.material as ShaderMaterial
            m.set_shader_parameter("seed", float(i) * 0.47 + t * 1.4)

func _draw() -> void:
    var t := fposmod(elapsed, CYCLE_SECONDS) / CYCLE_SECONDS
    _landscape()
    if study_mode == 0:
        _single_trail(t)
        for i in range(MOBS.size()):
            var mob: Vector2 = MOBS[i]
            draw_circle(mob + Vector2(0.0, 10.0), 23.0,
                Color(0.01, 0.02, 0.04, 0.27))
            RIG.render(self,
                {"id":"vfx18_mob_" + str(i), "side":"monster",
                 "tier":"normal", "hp":100.0},
                mob, "fist", "idle", elapsed, 1.72, -1.0, 0.0)
        RIG.render(self,
            {"id":"vfx18_caster", "side":"disciple", "hp":100.0},
            LIGHT_CASTER, "fist", "cast", elapsed, 2.0, 1.0, 0.18)
        _single_charge(t)
        # A circle on the ignored 4th preview mob is NOT drawn.
    else:
        _orbit_ground(t)
        draw_circle(FIELD_CENTER + Vector2(0.0, 25.0), 44.0,
            Color(0.02, 0.04, 0.07, 0.13))
        RIG.render(self,
            {"id":"vfx18_orbit_caster", "side":"disciple", "hp":100.0},
            FIELD_CENTER + Vector2(0.0, 24.0),
            "fist", "cast", elapsed, 2.1, 1.0, 0.18)
        for i in range(2):
            var at := Vector2(968.0 + float(i)*82.0, 353.0 + float(i)*110.0)
            RIG.render(self,
                {"id":"vfx18_orbit_mob_" + str(i), "side":"monster",
                 "tier":"normal", "hp":100.0},
                at, "fist", "idle", elapsed, 1.4, -1.0, 0.0)
    draw_line(Vector2(20, 624), Vector2(1260, 624),
        Color(0.35, 0.72, 0.88, 0.17), 1.0, true)

func _landscape() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("0b1220"))
    # R1 ART FIX: a huge isometric courtyard PNG looked like a grey diamond,
    # not an actual wide game map. Replace it with fine native gravel.
    # FX itself uses only analytic light shaders, with NO source-game art.
    draw_rect(Rect2(17, 91, 1246, 526), Color("3a3d3c"))
    for layer in range(7):
        var yy := 92.0 + float(layer) * 76.0
        draw_rect(Rect2(17.0, yy, 1246.0, 76.0),
            Color(0.03, 0.05, 0.06, 0.040 + float(layer % 2) * 0.013))
    # Deterministic non-repeating stone/sand specs; static in all frames.
    # Fine values keep beam halos clear and do not create a geometric grid.
    for i in range(460):
        var v := float(i)
        var x := 25.0 + fposmod(v * 73.719 + sin(v * 3.73) * 123.6, 1228.0)
        var y := 98.0 + fposmod(v * 47.217 + cos(v * 2.49) * 57.1, 510.0)
        var r := 0.5 + fposmod(v * 0.337, 1.0) * 1.4
        var shade := 0.10 + fposmod(v * 0.093, 1.0) * 0.12
        draw_circle(Vector2(x, y), r,
            Color(0.70, 0.74, 0.72, shade if i % 3 else shade * 0.55))
    draw_line(Vector2(18, 92), Vector2(1261, 92),
        Color(0.25, 0.63, 0.87, 0.11), 1.2, true)
    draw_line(Vector2(18, 617), Vector2(1261, 617),
        Color(0.25, 0.63, 0.87, 0.11), 1.2, true)

func _single_trail(t: float) -> void:
    var p := (t - PROJECTILE_START) / (CONTACT - PROJECTILE_START)
    if p < 0.0 or p >= 1.0:
        return
    var fade := (_smooth(p / 0.15) *
        (1.0 - _smooth((p - 0.85) / 0.15)))
    if fade < 0.008:
        return
    # The moving tail is an actual sampled HISTORY of this curved route.
    # Do NOT draw three straight arrows or a fake second projectile.
    var path := PackedVector2Array()
    for j in range(15):
        var u := float(j) / 14.0
        var hist := maxf(0.0, p - 0.23 + 0.23 * u)
        path.append(flight_head(hist))
    draw_polyline(path, Color(0.08, 0.31, 0.82, fade * 0.043), 25.0, true)
    draw_polyline(path, Color(0.11, 0.66, 1.0, fade * 0.095), 11.0, true)
    draw_polyline(path, Color(0.24, 0.89, 1.0, fade * 0.21), 3.1, true)

func _single_charge(t: float) -> void:
    var k := _smooth(t / 0.18) * (1.0 - _smooth((t - 0.223) / 0.035))
    if k < 0.003:
        return
    var origin := LIGHT_CASTER + Vector2(2.0, -58.0)
    var head := start_point()
    # Short gathering strands; V9 light-line, NOT a long lasting UI ring.
    for j in range(3):
        var d := float(j - 1) * 15.0
        var source := origin + Vector2(-29.0 + 4.0 * sin(t * 9.0 + j), d)
        var end := head + Vector2(0.0, d * 0.20)
        V9_LIGHT_LINE(self, source, end, k * (0.46 - float(j) * 0.08))
    draw_circle(head, 2.1 + 1.4 * k, Color(0.95, 1.0, 1.0, 0.65 * k))

func V9_LIGHT_LINE(canvas: CanvasItem, a: Vector2, b: Vector2,
        power: float) -> void:
    # Minimal short strands, no rendered sprite or hard neon blade polygon.
    canvas.draw_line(a, b, Color(0.10, 0.39, 1.0, power * 0.065), 11.0, true)
    canvas.draw_line(a, b, Color(0.16, 0.81, 1.0, power * 0.22), 4.0, true)
    canvas.draw_line(a, b, Color(0.95, 0.99, 1.0, power * 0.76), 1.2, true)

func _orbit_ground(t: float) -> void:
    var k := _smooth(t / 0.11) * (1.0 - _smooth((t - 0.82) / 0.18))
    if k < 0.003:
        return
    # Art R1: real recent-position light trails, not a static UI ring.
    # Transparent sanctuary at actor center; no fake target or AOE effect.
    for i in range(ORBIT_COUNT):
        var path := PackedVector2Array()
        for j in range(9):
            var q := float(j) / 8.0
            var earlier := maxf(0.0, t - 0.073 + q * 0.073)
            var track: Dictionary = orbit_streak(i, earlier)
            var pos: Vector2 = track["position"]
            path.append(pos + Vector2(0.0, 20.0))
        var strength := k * (0.75 if i % 2 == 0 else 0.49)
        draw_polyline(path, Color(0.09, 0.33, 0.97,
            strength * 0.072), 24.0, true)
        draw_polyline(path, Color(0.16, 0.68, 1.0,
            strength * 0.15), 9.0, true)
        draw_polyline(path, Color(0.66, 0.91, 1.0,
            strength * 0.21), 1.9, true)
        # Occasional trailing hot motes break up uniform orbital repetition.
        if i % 3 == 0:
            var echo: Dictionary = orbit_streak(i, maxf(0.0, t - 0.039))
            var mote: Vector2 = echo["position"]
            draw_circle(mote + Vector2(0.0, 20.0), 1.35,
                Color(0.72, 0.93, 1.0, strength * 0.47))
    # Only a few soft broken ground arcs; no constant thick white donuts.
    for ring in range(2):
        var rx := 190.0 if ring == 0 else 239.0
        var ry := 120.0 if ring == 0 else 150.0
        for i in range(8):
            var phase := float(i) / 8.0 * TAU + t * (
                0.82 if ring == 0 else -0.53)
            var sweep := 0.28 + 0.12 * sin(t * 9.0 + float(i) * 2.11)
            var poly := PackedVector2Array()
            for j in range(9):
                var angle := phase + float(j) * sweep / 8.0
                poly.append(FIELD_CENTER + Vector2(
                    cos(angle) * rx, sin(angle) * ry + 20.0))
            draw_polyline(poly, Color(0.11, 0.34, 0.76,
                k * (0.035 if ring == 0 else 0.022)), 18.0, true)
            draw_polyline(poly, Color(0.20, 0.70, 1.0,
                k * (0.12 if ring == 0 else 0.07)), 2.0, true)
