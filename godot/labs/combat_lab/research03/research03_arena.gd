extends "res://labs/combat_lab/research01/research01_arena.gd"
# VFX18 — LIGHTCORE2D. One luminous qi first; second mode = a REAL
# orbiting light-streak formation inspired by owner-approved REFERENCE frame.
# This is strictly a MOCK/ART LAB, not a V6.3 skill or a combat event.
const LIGHT_SHADER = preload("res://labs/combat_lab/research03/light_core_2d.gdshader")
const HIT_SHADER = preload("res://labs/combat_lab/research03/light_contact_2d.gdshader")
const ATMOSPHERE_SHADER = preload("res://labs/combat_lab/research03/light_orbit_aurora.gdshader")
const ORBIT_RIG = preload("res://labs/combat_lab/research03/orbit_actor_overlay.gd")
const NEW_COLOR := Color("59d8fa")
const SKY := Color("d9faff")
const FIELD_CENTER := Vector2(620.0, 354.0)
const LIGHT_CASTER := Vector2(298.0, 464.0)
const CYCLE_SECONDS := 3.2
const PROJECTILE_START := 0.255
const CONTACT := 0.744
const CONTACT_END := 0.824
const PROJECTILE_REACH := 0.875 # analytic light-tip UV on centered Sprite2D
const ORBIT_COUNT := 16 # decorative streaks; NONE represent hit events
var study_mode := 0 # 0 = one luminous sword-qi, 1 = rotating sword-qi array.
var blades: Array[Sprite2D] = []
var contacts: Array[Sprite2D] = []
var intensity_cache: Array[float] = []
var elapsed_local := 0.0
var orbit_actor: Node2D
var atmosphere: Sprite2D

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
    # One stable deterministic orbit sample. Front/behind classification
    # comes from the projected Y coordinate; no combat target changes.
    var ring := i % 2
    var j := int(i / 2)
    var phase_offset := 0.08 if ring == 0 else 0.48
    var rate := 0.82 if ring == 0 else -0.56
    var angle := (float(j) / 8.0) * TAU + t * TAU * rate + phase_offset
    # Imperfect natural spacings, never eight metronomic equal clock hands.
    angle += 0.067 * sin(float(j) * 2.17 + float(ring) * 1.63)
    angle += 0.019 * sin(t * TAU * 2.7 + float(j) * 1.83)
    var formation := lerpf(0.66, 1.0, _smooth(t / 0.148))
    var breathe := 1.0 + 0.025 * sin(t * TAU * 2.1 + float(j) * 1.8)
    var rx := (185.0 if ring == 0 else 242.0) * formation * breathe
    var ry := (126.0 if ring == 0 else 153.0) * formation * breathe
    var pt := FIELD_CENTER + Vector2(cos(angle) * rx, sin(angle) * ry)
    var tangent := Vector2(-sin(angle) * rx, cos(angle) * ry)
    if ring == 1:
        tangent = -tangent
    var variation := sin(float(j) * 2.71 + float(ring) * 1.9)
    var front := sin(angle) > 0.09
    var length := (96.0 if ring == 0 else 105.0) + variation * 24.0
    var luminance := (0.43 if ring == 0 else 0.35) + 0.15 * variation
    if front:
        luminance += 0.23
    return {
        "position": pt,
        "axis": tangent.normalized(),
        "length": clampf(length, 66.0, 137.0),
        "energy": clampf(luminance, 0.18, 0.86),
        "ring": ring,
        "theta": angle,
        "front": front,
    }

func _ready() -> void:
    super._ready()
    title_label.text = "VFX18.2 | LIGHTCORE2D — LUONG QUANG KIEM KHI"
    detail_label.text = "1: mot kiem khi  2: kiem tran xoay  SPACE: phat lai  P: tam dung  |  MOCK LAB / PVE HOLD"
    study_mode = 1 if OS.get_environment("TMB_VFX18_MODE") == "orbit" else 0
    # Render the mathematical UV shader on a tiny PROCEDURALLY GENERATED
    # all-white carrier (4×4): absolutely no painted sword/JX texture.
    # Sprite2D uses a centered Node2D transform, so the hot tip remains
    # exactly anchored to flight_head despite rotation/scaling.
    var blank := Image.create(4, 4, false, Image.FORMAT_RGBA8)
    blank.fill(Color.WHITE)
    var blank_texture := ImageTexture.create_from_image(blank)
    for i in range(ORBIT_COUNT):
        var panel := Sprite2D.new()
        panel.texture = blank_texture
        panel.centered = true
        panel.modulate = Color.WHITE
        panel.visible = false
        var mat := ShaderMaterial.new()
        mat.shader = LIGHT_SHADER
        mat.set_shader_parameter("seed", float(i) * 1.17)
        mat.set_shader_parameter("width_bias", 0.82 if i % 2 else 1.0)
        panel.material = mat
        panel.z_index = 1
        add_child(panel)
        blades.append(panel)
    var hit := Sprite2D.new()
    hit.texture = blank_texture
    hit.centered = true
    hit.modulate = Color.WHITE
    hit.material = ShaderMaterial.new()
    (hit.material as ShaderMaterial).shader = HIT_SHADER
    hit.scale = Vector2(132.0 / 4.0, 108.0 / 4.0)
    hit.visible = false
    hit.z_index = 2
    add_child(hit)
    contacts.append(hit)
    # Controlled non-opaque energy underglow in the *orbit* only.
    atmosphere = Sprite2D.new()
    atmosphere.texture = blank_texture
    atmosphere.centered = true
    atmosphere.position = FIELD_CENTER + Vector2(0.0, 17.0)
    atmosphere.scale = Vector2(580.0 / 4.0, 390.0 / 4.0)
    atmosphere.z_index = 1
    var light_fog := ShaderMaterial.new()
    light_fog.shader = ATMOSPHERE_SHADER
    atmosphere.material = light_fog
    atmosphere.visible = false
    add_child(atmosphere)
    orbit_actor = ORBIT_RIG.new()
    orbit_actor.z_index = 2
    add_child(orbit_actor)
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
    if orbit_actor != null and study_mode == 1:
        orbit_actor.queue_redraw()

func _place_light(panel: Sprite2D, at: Vector2,
        axis: Vector2, length: float, height: float, energy: float,
        t: float) -> void:
    panel.visible = energy > 0.025
    if not panel.visible:
        return
    var f := axis.normalized()
    # 4×4 plain-white shader carrier only. Sprite2D's origin is CENTERED.
    # The .875 local-point convention maps to the exact scripted tip.
    panel.scale = Vector2(length / 4.0, height / 4.0)
    panel.rotation = f.angle()
    panel.position = at - f * length * (PROJECTILE_REACH - 0.5)
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
    if orbit_actor != null:
        orbit_actor.visible = study_mode == 1
    if atmosphere != null:
        atmosphere.visible = study_mode == 1
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
            (blades[0].material as ShaderMaterial).set_shader_parameter(
                "curl", 0.0)
        if t >= CONTACT and t < CONTACT_END:
            var hit_age := _clamp((t - CONTACT) / (CONTACT_END - CONTACT))
            var hit := contacts[0]
            hit.visible = true
            hit.scale = Vector2((172.0 + 18.0 * hit_age) / 4.0,
                (134.0 + 7.0 * hit_age) / 4.0)
            # Separate, contained visual contact on the near-side silhouette.
            hit.position = stop_point() + Vector2(12.0, 6.0)
            var m := hit.material as ShaderMaterial
            m.set_shader_parameter("age", hit_age)
            m.set_shader_parameter("power", 0.92)
    else:
        # The owner reference is a real orbit: 2 projected depths, opposite
        # velocities, tangents and brightness are not uniform spokes.
        var wake := _smooth(t / 0.10) * (1.0 - _smooth((t - 0.83) / 0.15))
        if atmosphere != null:
            var haze: ShaderMaterial = atmosphere.material as ShaderMaterial
            haze.set_shader_parameter("phase", t)
            haze.set_shader_parameter("energy", wake)
        for i in range(ORBIT_COUNT):
            var info := orbit_streak(i, t)
            var panel := blades[i]
            var strength := float(info["energy"]) * wake
            _place_light(panel, info["position"], info["axis"],
                float(info["length"]), 56.0, strength, t)
            # Correct depth: far streak behind actor, near streak in front.
            panel.z_index = 3 if bool(info["front"]) else 1
            var m := panel.material as ShaderMaterial
            m.set_shader_parameter("seed", float(i) * 0.47 + t * 1.4)
            m.set_shader_parameter("curl", 0.67 if i % 2 == 0 else 0.88)

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
        _impact_splinters(t)
        # A circle on the ignored 4th preview mob is NOT drawn.
    else:
        _orbit_ground(t)
        draw_circle(FIELD_CENTER + Vector2(0.0, 25.0), 44.0,
            Color(0.02, 0.04, 0.07, 0.13))
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
    var fade := (_smooth(p / 0.12) *
        (1.0 - _smooth((p - 0.87) / 0.13)))
    if fade < 0.008:
        return
    # Physical camera-scale energy HISTORY, not cloned parallel arrows.
    # Each segment softens to transparent toward the rear instead of a
    # full-width, hard-edged blue-polyline that looks like UI geometry.
    var axis := flight_direction(p)
    var n := axis.orthogonal()
    var prev := flight_head(maxf(0.0, p - 0.25))
    var prev_alt := prev
    for j in range(1, 17):
        var u := float(j) / 16.0
        var k := maxf(0.0, p - 0.25 + u * 0.25)
        var at := flight_head(k)
        var envelope := sin(PI * u) * (1.0 - u)
        var drift := sin(u * 8.2 - t * 18.0) * 6.0 * envelope
        var alt := at + n * drift
        var strength := fade * pow(u, 1.52)
        var width := 5.0 + 15.0 * sin(PI * u) + 4.0 * u
        draw_line(prev, at, Color(0.06, 0.25, 0.79,
            strength * 0.075), width * 1.5, true)
        draw_line(prev, at, Color(0.13, 0.59, 1.0,
            strength * 0.23), width * 0.46, true)
        draw_line(prev, at, Color(0.66, 0.96, 1.0,
            strength * 0.39), maxf(0.7, width * 0.095), true)
        draw_line(prev_alt, alt, Color(0.32, 0.75, 1.0,
            strength * 0.16), maxf(0.7, 2.3 * sin(PI * u)), true)
        prev = at
        prev_alt = alt


static func charge_source(j: int, t: float) -> Vector2:
    # Three sources to the caster's right + two left: visual energy actually
    # GATHERS at the hand rather than being hidden behind the actor sprite.
    var side := 1.0 if j != 2 and j != 4 else -1.0
    var dist := 45.0 + float(j) * 12.0
    return start_point() + Vector2(
        side * dist + 8.0 * sin(t * 15.0 + float(j) * 1.31),
        float(j - 2) * 21.0 + 7.0 * cos(t * 17.0 + float(j) * 1.67))

func _single_charge(t: float) -> void:
    var k: float = (_smooth(t / 0.145) *
        (1.0 - _smooth((t - 0.232) / 0.024)))
    if k < 0.003:
        return
    var focus := start_point()
    # Five moving "light rivers" converge. SEGMENT energy changes as
    # a pulse travels towards the source tip, so they don't look like
    # static white electricity lines stamped on the caster.
    for j in range(5):
        var src: Vector2 = charge_source(j, t)
        var distance: Vector2 = focus - src
        var normal: Vector2 = distance.normalized().orthogonal()
        var bend_mag := (18.0 if j < 2 else 10.0) * (
            -1.0 if j % 2 == 0 else 1.0)
        var c1 := src + distance * 0.30 + normal * bend_mag
        var c2 := src + distance * 0.75 + normal * (
            5.0 * sin(t * 17.0 + float(j)))
        var prev := src
        var speed := fposmod(t * 6.8 + float(j) * 0.23, 1.0)
        for n in range(1, 16):
            var u := float(n) / 15.0
            var at := cubic(src, c1, c2, focus, u)
            var reach := _smooth((u - 0.08) / 0.89)
            var glint := exp(-pow((u - speed) / 0.17, 2.0))
            var amp := k * (0.28 + 0.72 * reach) * (
                0.55 + 0.45 * glint) * (0.79 if j >= 2 else 1.0)
            var width := 7.5 + 3.5 * sin(PI * u)
            draw_line(prev, at,
                Color(0.055, 0.27, 0.95, amp * 0.115),
                width * 2.15, true)
            draw_line(prev, at,
                Color(0.21, 0.78, 1.0, amp * 0.39),
                width * 0.73, true)
            draw_line(prev, at,
                Color(0.95, 0.99, 1.0, amp * 0.62),
                maxf(0.75, width * 0.17), true)
            prev = at
    # Three concentric *soft luminous dots*, not a filled UI circle.
    draw_circle(focus, 17.0, Color(0.06, 0.32, 1.0, k * 0.060))
    draw_circle(focus, 7.0, Color(0.25, 0.82, 1.0, k * 0.16))
    draw_circle(focus, 2.2, Color(0.99, 1.0, 1.0, k * 0.89))


func _impact_splinters(t: float) -> void:
    if t < CONTACT or t >= CONTACT_END:
        return
    var age := _clamp((t - CONTACT) / (CONTACT_END - CONTACT))
    var power := 1.0 - _smooth((age - 0.08) / 0.90)
    var origin := stop_point() + Vector2(9.0, 6.0)
    # A directional wound in the energy field, *not* a bomb or false hit.
    # Each fragment follows a tiny staggered cubic and fades individually.
    for i in range(6):
        var index := float(i)
        var angle := -2.46 + index * 0.49 + 0.13 * sin(index * 2.31)
        var direction := Vector2.from_angle(angle)
        var normal := direction.orthogonal()
        var stagger := float(i % 3) * 0.11
        var local_age := _clamp((age - stagger) / maxf(0.15, 1.0 - stagger))
        var spark_fade := power * (1.0 - _smooth(local_age))
        if spark_fade < 0.016:
            continue
        var start := origin + direction * (6.0 + 8.0 * local_age)
        var mid := origin + direction * (
            25.0 + 25.0 * local_age) + normal * (
            3.0 * sin(index + local_age * 2.4))
        var end := origin + direction * (
            36.0 + 43.0 * local_age) + normal * (
            8.0 * sin(index * 1.9 + local_age * 1.4))
        draw_line(start, mid,
            Color(0.10, 0.46, 0.99, spark_fade * 0.16),
            6.5, true)
        draw_line(mid, end,
            Color(0.15, 0.76, 1.0, spark_fade * 0.31),
            2.1, true)
        draw_line(start + direction * 3.0, mid,
            Color(0.94, 0.99, 1.0, spark_fade * 0.66),
            1.15, true)
    # Hot point ends BEFORE character centre, no large white blob.
    draw_circle(origin, 7.5,
        Color(0.11, 0.45, 1.0, power * 0.105))
    draw_circle(origin, 2.1,
        Color(0.97, 1.0, 1.0, power * 0.68))


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
    # Eight dim moving wakelets soften the sterile 16-stroke outline.
    # They are just trail history, NEVER additional attacks or projectiles.
    for j in range(8):
        var i := j * 2 + (j % 2)
        var wave := PackedVector2Array()
        for n in range(6):
            var u := float(n) / 5.0
            var hist_t := maxf(0.0, t - 0.145 + 0.094 * u)
            var o: Dictionary = orbit_streak(i, hist_t)
            wave.append((o["position"] as Vector2) + Vector2(0.0, 20.0))
        var alpha := k * (0.18 + 0.12 *
            sin(float(j) * 2.1 + t * 11.0))
        draw_polyline(wave,
            Color(0.05, 0.39, 1.0, alpha * 0.25),
            11.0, true)
        draw_polyline(wave,
            Color(0.27, 0.85, 1.0, alpha * 0.39),
            1.8, true)
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
