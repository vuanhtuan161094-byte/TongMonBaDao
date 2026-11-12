extends RefCounted
# VFX12 — JX-inspired ORIGINAL code art, LAB PREVIEW ONLY.
# Missile timing, casting, AOE circle, and impact are VISUAL only.
# This does not define / change skill stats, targets, actual damage or Save.
const SNOW := Color("e8f5ff")
const BLUE := Color("78d7f9")
const MINT := Color("89dff0")
const GOLD := Color("f8d48b")
const VIOLET := Color("7269be")
const DARK := Color("223355")
const TWO_PI := PI * 2.0

static func _alpha(color: Color, a: float) -> Color:
    return Color(color.r, color.g, color.b, clampf(a, 0.0, 1.0))

static func _ease(x: float) -> float:
    var t := clampf(x, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

static func _ring(c: CanvasItem, at: Vector2, rx: float, ry: float,
        col: Color, opacity: float, phase: float = 0.0) -> void:
    if opacity <= 0.01:
        return
    var points := PackedVector2Array()
    for i in range(33):
        var a := TWO_PI * float(i) / 32.0 + phase
        points.append(at + Vector2(cos(a) * rx, sin(a) * ry))
    c.draw_polyline(points, _alpha(col, opacity * 0.13), 4.0, true)
    c.draw_polyline(points, _alpha(col, opacity * 0.68), 1.45, true)

static func _spark(c: CanvasItem, p: Vector2, z: float, a: float) -> void:
    if a <= 0.01:
        return
    c.draw_circle(p, 4.0 * z, _alpha(BLUE, a * 0.08))
    c.draw_circle(p, 1.2 * z, _alpha(SNOW, a * 0.72))

static func _blade(c: CanvasItem, center: Vector2, forward: Vector2,
        zoom: float, opacity: float) -> void:
    # A rigid STRAIGHT sword-qi silhouette. Metal-like dark bevel + bright
    # blade edge stays readable at 1x; restrained light only on the edge.
    var a := clampf(opacity, 0.0, 1.0)
    if a < 0.012:
        return
    var z := clampf(zoom, 0.3, 1.75)
    var f := forward.normalized()
    if f.length_squared() < 0.1:
        f = Vector2.RIGHT
    var side := f.orthogonal()
    var root := center - f * (18.0 * z)
    var shoulder := center + f * (21.0 * z)
    var tip := center + f * (50.0 * z)
    var guard := root - f * (4.0 * z)
    var pommel := guard - f * (17.0 * z)
    # Aura silhouette, bounded to the blade instead of broad neon strips.
    c.draw_colored_polygon(PackedVector2Array([
        root - side * 7.0 * z, shoulder - side * 7.0 * z, tip,
        shoulder + side * 7.0 * z, root + side * 7.0 * z
    ]), _alpha(BLUE, a * 0.09))
    c.draw_colored_polygon(PackedVector2Array([
        root - side * 4.8 * z, shoulder - side * 4.5 * z, tip,
        shoulder + side * 4.5 * z, root + side * 4.8 * z
    ]), _alpha(DARK, a * 0.95))
    c.draw_colored_polygon(PackedVector2Array([
        root, root - side * 3.8 * z, shoulder - side * 3.3 * z, tip
    ]), _alpha(SNOW, a * 0.88))
    c.draw_colored_polygon(PackedVector2Array([
        root, tip, shoulder + side * 3.3 * z, root + side * 3.8 * z
    ]), _alpha(BLUE, a * 0.64))
    # Ancient jian's single talisman keeps a recognisable silhouette
    # without demanding a detailed hilt on each of 9 flying blades.
    var seal := root + f * (20.0 * z)
    c.draw_polyline(PackedVector2Array([
        seal - f * 4.5 * z, seal - side * 2.1 * z,
        seal + f * 4.5 * z, seal + side * 2.1 * z,
        seal - f * 4.5 * z
    ]), _alpha(GOLD, a * 0.93), maxf(0.7, 0.9 * z), true)
    # Fine short quillon, pommel: shape should be read as sword, not arrow.
    c.draw_line(guard - side * 8.0 * z, guard + side * 8.0 * z,
        _alpha(GOLD, a * 0.91), maxf(1.0, 2.2 * z), true)
    c.draw_line(guard, pommel, _alpha(VIOLET, a * 0.84),
        maxf(1.0, 2.5 * z), true)
    c.draw_circle(pommel, 2.0 * z, _alpha(GOLD, a * 0.84))
    # Small final-edge light: don't wash out the bright face.
    c.draw_line(shoulder - side * 3.3 * z, tip,
        _alpha(SNOW, a * 0.42), maxf(0.7, 0.85 * z), true)

static func flight_timing(index: int) -> Vector2:
    # Three successive 3-sword volleys, with slight internal offset.
    var wave := floori(float(index) / 3.0)
    var lane := index % 3
    var launch := 0.335 + float(wave) * 0.105 + float(lane) * 0.014
    return Vector2(launch, launch + 0.260)

static func blade_opacity(index: int, t: float) -> float:
    var schedule := flight_timing(index)
    if t < schedule.x:
        # Three swords are visible during charge, not nine glowing props.
        return _ease(t / 0.24) * (0.68 if index < 3 else 0.0)
    if t <= schedule.y:
        return 1.0
    # Remain readable after contact, then melt into trailing light.
    return 1.0 - _ease((t - schedule.y) / 0.155)

static func _aoe(c: CanvasItem, at: Vector2, z: float, t: float) -> void:
    # Wide recognizable mystic area; no numerical radius/hit authority.
    if t < 0.20 or t > 0.98:
        return
    var incoming := _ease((t - 0.20) / 0.18)
    var outgoing := 1.0 - _ease((t - 0.82) / 0.16)
    var a := incoming * outgoing
    var rx := 127.0 * z
    var ry := 77.0 * z
    _ring(c, at, rx, ry, BLUE, a * 0.74)
    _ring(c, at, rx * 0.74, ry * 0.74, GOLD, a * 0.50, 0.06)
    for i in range(8):
        var theta := TWO_PI * float(i) / 8.0
        var direction := Vector2(cos(theta) * rx, sin(theta) * ry)
        c.draw_line(at + direction * 0.83, at + direction * 0.98,
            _alpha(GOLD, a * 0.54), maxf(0.85, 1.2 * z), true)
    # Four restrained target sigils at the feet of the four Lab monsters.
    for j in range(4):
        var anchor := at + Vector2(
            (float(j % 2) - 0.5) * 112.0,
            (float(floori(float(j) / 2.0)) - 0.5) * 102.0)
        _ring(c, anchor, 19.0 * z, 9.0 * z, BLUE, a * 0.42)

static func _hit(c: CanvasItem, at: Vector2, z: float,
        relative: float, seed: int) -> void:
    var k := clampf(relative, 0.0, 1.0)
    if k >= 1.0:
        return
    var strong := 1.0 - _ease(k)
    c.draw_circle(at, (6.0 + k * 8.0) * z, _alpha(BLUE, strong * 0.18))
    c.draw_circle(at, (2.0 + k * 2.0) * z, _alpha(SNOW, strong * 0.85))
    _ring(c, at + Vector2(0, 10 * z), (8.0 + 42.0 * k) * z,
        (5.0 + 20.0 * k) * z, GOLD, strong * 0.66)
    for j in range(4):
        var theta := TWO_PI * (float(j) / 4.0 + float(seed) * 0.09)
        var axis := Vector2.from_angle(theta)
        var start := at + axis * (5.0 + 11.0 * k) * z
        var finish := at + axis * (15.0 + 38.0 * k) * z
        c.draw_line(start, finish,
            _alpha(SNOW if j % 2 == 0 else GOLD, strong * 0.68),
            maxf(0.65, 1.65 * z), true)

static func render(c: CanvasItem, from: Vector2, to: Vector2,
        progress: float, zoom: float, lod: int = 2) -> void:
    var t := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.6, 1.95)
    _aoe(c, to, z, t)
    if t < 0.37:
        # A focused golden-blue charge seal below the caster, NOT a
        # second full bright AOE. Its principal silhouette stays small.
        var charge := _ease(t / 0.25) * (1.0 - _ease((t - 0.28) / 0.09))
        _ring(c, from + Vector2(0.0, 28.0 * z),
            35.0 * z, 13.0 * z, GOLD, charge * 0.64)
        _spark(c, from + Vector2(0.0, -7.0 * z), 2.0 * z, charge * 0.67)
    var count := 9 if lod >= 2 else (6 if lod == 1 else 3)
    for i in range(count):
        var wave := floori(float(i) / 3.0)
        var lane := i % 3
        var schedule := flight_timing(i)
        var alpha := blade_opacity(i, t)
        if alpha < 0.012:
            continue
        # Fan-shaped charge (not grid or overlapping circular blades).
        var source := from + Vector2(
            38.0 + float(wave) * 31.0,
            (float(lane) - 1.0) * 68.0 - float(wave) * 8.0) * z
        var group := i % 4
        var mob := to + Vector2(
            (float(group % 2) - 0.5) * 112.0,
            (float(floori(float(group) / 2.0)) - 0.5) * 102.0)
        var spread := Vector2(
            (float(lane) - 1.0) * 15.0,
            (float(wave) - 1.0) * 11.0) * z
        var impact_pos := mob + spread
        var direction := (impact_pos - source).normalized()
        var flight := clampf((t - schedule.x) /
            maxf(0.01, schedule.y - schedule.x), 0.0, 1.0)
        var position := source.lerp(impact_pos, _ease(flight))
        var after_hit := clampf((t - schedule.y) / 0.155, 0.0, 1.0)
        position += direction * (after_hit * 10.0 * z)
        var size := (0.80 if wave == 0 else 0.63) * z
        # The qi should follow the sword, not obscure the metal silhouette.
        if flight > 0.03 and flight < 0.99:
            var tail := position - direction * 39.0 * size
            c.draw_line(tail - direction * 19.0 * z,
                tail - direction * 4.0 * z,
                _alpha(BLUE, alpha * 0.22), maxf(0.75, 1.4 * z), true)
            _spark(c, tail, 0.7 * z, alpha * 0.32)
        _blade(c, position, direction, size, alpha)
        if t > schedule.y and lane == 1:
            _hit(c, impact_pos, z * 0.70,
                (t - schedule.y) / 0.18, group)
    # Last wave unfolds then fades; short afterglow, no persistent disk.
    if t > 0.69:
        var age := clampf((t - 0.69) / 0.31, 0.0, 1.0)
        _ring(c, to, (52.0 + age * 83.0) * z,
            (29.0 + age * 48.0) * z, BLUE,
            (1.0 - _ease(age)) * 0.53)
