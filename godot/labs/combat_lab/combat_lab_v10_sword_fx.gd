extends RefCounted
# V10 SWORD LAB-ONLY. Original GDScript vector light art, no picture/texture.
# An AOE circle is a VISUAL PREVIEW, not target, damage or range authority.
# All progress is deterministic; no timers/particles spawned per frame.
const SKY := Color("72dfff")
const ICE := Color("e6f8ff")
const GOLD := Color("f7d38b")
const DEEP := Color("293e84")
const PURPLE := Color("9668e9")
const TAU_S := PI * 2.0

static func _ink(c: Color, a: float) -> Color:
    return Color(c.r, c.g, c.b, clampf(a, 0.0, 1.0))

static func _smooth(t: float) -> float:
    var v := clampf(t, 0.0, 1.0)
    return v * v * (3.0 - 2.0 * v)

static func _arc(canvas: CanvasItem, at: Vector2, rx: float, ry: float,
        hue: Color, a: float, phase: float = 0.0) -> void:
    if a < 0.006:
        return
    var ring := PackedVector2Array()
    for i in range(33):
        var angle := TAU_S * float(i) / 32.0 + phase
        ring.append(at + Vector2(cos(angle) * rx, sin(angle) * ry))
    canvas.draw_polyline(ring, _ink(hue, a * 0.17), 5.0, true)
    canvas.draw_polyline(ring, _ink(hue, a * 0.58), 1.5, true)

static func _glint(canvas: CanvasItem, at: Vector2, z: float,
        hue: Color, a: float) -> void:
    if a < 0.01:
        return
    canvas.draw_circle(at, 5.0 * z, _ink(hue, a * 0.06))
    canvas.draw_circle(at, 2.0 * z, _ink(hue, a * 0.24))
    canvas.draw_circle(at, 0.85 * z, _ink(ICE, a * 0.65))

static func _sword(canvas: CanvasItem, center: Vector2,
        forward: Vector2, scale: float, visibility: float) -> void:
    var a := clampf(visibility, 0.0, 1.0)
    if a < 0.014:
        return
    var z := clampf(scale, 0.5, 1.8)
    var f: Vector2 = forward.normalized()
    if f.length_squared() < 0.5:
        f = Vector2.RIGHT
    var side: Vector2 = f.orthogonal()
    # Rigid jian silhouette: a true pointed blade, thicker root,
    # symmetric guard and wrapped hilt. No neon stroke is the weapon body.
    var root: Vector2 = center - f * 16.0 * z
    var tip: Vector2 = center + f * 45.0 * z
    var shoulder: Vector2 = center + f * 21.0 * z
    var guard: Vector2 = root - f * 3.0 * z
    var pommel: Vector2 = guard - f * 18.0 * z
    canvas.draw_colored_polygon(PackedVector2Array([
        root - side * 9.8 * z, shoulder - side * 9.8 * z, tip,
        shoulder + side * 9.8 * z, root + side * 9.8 * z
    ]), _ink(SKY, a * 0.066))
    canvas.draw_colored_polygon(PackedVector2Array([
        root - side * 5.2 * z, shoulder - side * 5.2 * z, tip,
        shoulder + side * 5.2 * z, root + side * 5.2 * z
    ]), _ink(DEEP, a * 0.85))
    canvas.draw_colored_polygon(PackedVector2Array([
        root, root - side * 4.2 * z, shoulder - side * 4.2 * z, tip
    ]), _ink(ICE, a * 0.91))
    canvas.draw_colored_polygon(PackedVector2Array([
        root, tip, shoulder + side * 4.2 * z, root + side * 4.2 * z
    ]), _ink(SKY, a * 0.64))
    canvas.draw_line(root, tip, _ink(ICE, a * 0.70),
        maxf(0.65, 0.85 * z), true)
    # Engraved diamond rune and paired longitudinal veins; attached
    # to blade axis, so details cannot distort during flight.
    var seal: Vector2 = root + f * 16.0 * z
    canvas.draw_polyline(PackedVector2Array([
        seal - f * 5.0 * z,
        seal - side * 2.5 * z,
        seal + f * 5.0 * z,
        seal + side * 2.5 * z,
        seal - f * 5.0 * z
    ]), _ink(GOLD, a * 0.93), maxf(0.75, 0.87 * z), true)
    for sign in [-1.0, 1.0]:
        var ofs := float(sign) * 2.1 * z
        canvas.draw_line(root + f * 24.0 * z + side * ofs,
            root + f * 35.0 * z + side * ofs * 0.42,
            _ink(GOLD, a * 0.83), maxf(0.65, 0.73 * z), true)
    # Guard tips curl back towards the blade, rather than a plain bar.
    var left: Vector2 = guard - side * 8.0 * z
    var right: Vector2 = guard + side * 8.0 * z
    canvas.draw_line(left, right, _ink(GOLD, a * 0.92), 2.3 * z, true)
    canvas.draw_line(left, left + f * 4.0 * z - side * 2.7 * z,
        _ink(GOLD, a), 1.35 * z, true)
    canvas.draw_line(right, right + f * 4.0 * z + side * 2.7 * z,
        _ink(GOLD, a), 1.35 * z, true)
    canvas.draw_line(guard, pommel, _ink(PURPLE, a * 0.86),
        3.2 * z, true)
    for j in range(3):
        var p: Vector2 = guard.lerp(pommel, float(j + 1) * 0.24)
        canvas.draw_line(p - side * 1.7 * z, p + side * 1.7 * z,
            _ink(GOLD, a * 0.86), maxf(0.7, 0.8 * z), true)
    canvas.draw_circle(pommel, 2.0 * z, _ink(GOLD, a * 0.88))
    _glint(canvas, tip, z, SKY, a * 0.65)

static func _aoe_seal(canvas: CanvasItem, center: Vector2,
        z: float, progress: float) -> void:
    # Physical location of the demon's feet in the 1280x720 Lab view.
    # The preview ring never signals a new gameplay hit.
    var t := clampf(progress, 0.0, 1.0)
    if t < 0.22:
        return
    var grow := _smooth((t - 0.22) / 0.18)
    var decay := 1.0 - _smooth((t - 0.80) / 0.19)
    var strength := grow * decay
    if strength < 0.005:
        return
    var ground := center + Vector2(0.0, 28.0 * z)
    var outer_rx := 81.0 * z
    var outer_ry := 37.0 * z
    _arc(canvas, ground, outer_rx, outer_ry, SKY, strength * 0.58)
    _arc(canvas, ground, outer_rx * 0.70, outer_ry * 0.70,
        GOLD, strength * 0.43, -0.13)
    # Twelve subtle talismans on the ground circle.
    for j in range(12):
        var ang := TAU_S * float(j) / 12.0
        var radial := Vector2(cos(ang) * outer_rx, sin(ang) * outer_ry)
        var inner := ground + radial * 0.84
        var outer := ground + radial * 0.97
        canvas.draw_line(inner, outer, _ink(GOLD, strength * 0.62),
            maxf(0.75, z), true)
    for j in range(4):
        var ang := TAU_S * float(j) / 4.0 + PI / 4.0
        var tip := ground + Vector2(cos(ang) * outer_rx * 0.49,
            sin(ang) * outer_ry * 0.49)
        _glint(canvas, tip, z * 0.8, SKY, strength * 0.58)

static func _impact(canvas: CanvasItem, at: Vector2, z: float,
        time_after: float, group_id: int) -> void:
    var age := clampf(time_after, 0.0, 1.0)
    if age >= 1.0:
        return
    var alpha := 1.0 - age
    var flash := pow(alpha, 2.4)
    canvas.draw_circle(at, (7.0 + age * 12.0) * z,
        _ink(SKY, flash * 0.12))
    canvas.draw_circle(at, (2.0 + age * 3.0) * z,
        _ink(ICE, flash * 0.73))
    var ground := at + Vector2(0.0, 23.0 * z)
    _arc(canvas, ground, (6.0 + 22.0 * age) * z,
        (3.0 + 10.0 * age) * z, SKY, alpha * 0.72)
    # Four fading motes, fixed number and deterministic directions.
    for j in range(4):
        var theta := float(group_id * 2 + j) * TAU_S / 9.0
        var drift := Vector2(cos(theta), sin(theta)) * (9.0 + 22.0 * age) * z
        _glint(canvas, at + drift, z * (0.55 + 0.35 * alpha),
            GOLD if j % 2 == 0 else SKY, alpha * 0.63)

static func render(canvas: CanvasItem, from: Vector2, to: Vector2,
        time01: float, zoom: float, detail: int = 2) -> void:
    var t := clampf(time01, 0.0, 1.0)
    var z := clampf(zoom, 0.6, 2.0)
    var sword_count := 12 if detail >= 2 else (8 if detail == 1 else 5)
    # AOE floor seal is revealed BEFORE impact, remains briefly afterwards.
    _aoe_seal(canvas, to, z, t)
    if t < 0.28:
        var charge := _smooth(t / 0.28)
        _arc(canvas, from + Vector2(0.0, 17.0 * z),
            (13.0 + charge * 56.0) * z,
            (5.0 + charge * 21.0) * z,
            SKY, 0.14 + charge * 0.36)
    for i in range(sword_count):
        var phi := TAU_S * float(i) / float(sword_count)
        var orbit := Vector2(cos(phi), sin(phi) * 0.64)
        var start := from + orbit * 122.0 * z
        var group := i % 4
        var col := float(group % 2)
        var row_index := float(floori(float(group) / 2.0))
        var slot := float(floori(float(i) / 4.0)) - 1.0
        var aim := to + Vector2((col - 0.5) * 106.0,
            (row_index - 0.5) * 94.0) + Vector2(slot * 7.0, slot * 8.0) * z
        var forward: Vector2 = (aim - start).normalized()
        var launch := 0.37 + float(i % 3) * 0.045
        var reach := 0.73 + float(i % 3) * 0.045
        var phase := clampf((t - launch) / maxf(0.001, reach - launch), 0.0, 1.0)
        # Single clean forward path, never wobble the rigid jian body.
        var position := start.lerp(aim, _smooth(phase))
        # The blade settles into its impact point while its light dissolves.
        var after_hit := clampf((t - reach) / 0.14, 0.0, 1.0)
        position += forward * (after_hit * 9.0 * z)
        var ready := _smooth((t - float(i) * 0.007) / 0.20)
        # Sword remains intact at impact, fades progressively over ~0.16
        # normalized seconds; no abrupt disappearance at reach.
        var dissolve := 1.0 - _smooth((t - reach - 0.008) / 0.13)
        var visible := ready * dissolve
        if visible < 0.012:
            continue
        var size_multiplier := (0.83 if t < launch else 0.91) * z * (1.0 - after_hit * 0.14)
        _sword(canvas, position, forward, size_multiplier, visible)
        if phase > 0.04 and phase < 1.0:
            # One restrained afterimage, not a neon rod obscuring the blade.
            var tail := position - forward * 21.0 * z
            canvas.draw_line(tail, position - forward * 9.0 * z,
                _ink(SKY, visible * 0.23), 2.4 * z, true)
        if t > reach and i < 4:
            # One impact burst per preview target, not 12 overlapping
            # particle bursts; the other eight swords still dissolve.
            var fade_age := clampf((t - reach) / 0.17, 0.0, 1.0)
            _impact(canvas, aim, z * 0.56, fade_age, group)
    # Final AOE wave and brief lingering halo, never an invented damage event.
    if t >= 0.73:
        var age := clampf((t - 0.73) / 0.27, 0.0, 1.0)
        _arc(canvas, to + Vector2(0.0, 28.0 * z),
            (65.0 + 46.0 * age) * z,
            (30.0 + 22.0 * age) * z,
            SKY, (1.0 - age) * 0.55)
