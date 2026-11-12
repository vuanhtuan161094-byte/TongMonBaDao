extends RefCounted
# VFX13 Lab-only: explicit LOCKED primary AOE center + approved hit targets.
# No renderer target-selection or damage authority. Original Godot code art.
const PREV = preload("res://labs/combat_lab/combat_lab_v12_sword_fx.gd")
const CYAN := Color("7bdcff")
const ICE := Color("f3fdff")
const GOLD := Color("f8d694")
const BLUE := Color("63a8f4")
const DARK := Color("28538d")
const TAU13 := PI * 2.0

static func _col(color: Color, a: float) -> Color:
    return Color(color.r, color.g, color.b, clampf(a, 0.0, 1.0))

static func _ease(x: float) -> float:
    var t := clampf(x, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

# Standalone DEMO locator only. Real battle must pass an authoritative
# resolved target list from the combat engine, NEVER run this helper to
# create new hit events or alter selection gameplay.
static func preview_circle_targets(actors: Array, locked_center: Vector2,
        radii_px: Vector2, max_targets: int = 3) -> Array:
    var eligible: Array = []
    if max_targets <= 0:
        return eligible
    var rx := maxf(1.0, radii_px.x)
    var ry := maxf(1.0, radii_px.y)
    for value in actors:
        if not value is Vector2:
            continue
        var p: Vector2 = value
        var delta := p - locked_center
        if (delta.x * delta.x) / (rx * rx) + (delta.y * delta.y) / (ry * ry) <= 1.0:
            eligible.append(p)
            if eligible.size() >= maxi(0, max_targets):
                break
    return eligible

# Pure timetable (3 waves x 3); sword count is GRAPHICS ONLY,
# not authorized actor count or number of damage ticks.
static func flight_timing(index: int) -> Vector2:
    var wave := floori(float(index) / 3.0)
    var slot := index % 3
    var launch := 0.330 + float(wave) * 0.104 + float(slot) * 0.012
    return Vector2(launch, launch + 0.261)

static func visibility_after_contact(t: float, reach: float) -> float:
    return 1.0 - _ease((t - reach - 0.006) / 0.156)

static func _trail(c: CanvasItem, at: Vector2, direction: Vector2,
        z: float, opacity: float, motion: float) -> void:
    var strength := clampf(opacity, 0.0, 1.0) * clampf(motion, 0.0, 1.0)
    if strength <= 0.01:
        return
    var f := direction.normalized()
    var n := f.orthogonal()
    var start := at - f * 44.0 * z
    var end := start - f * 78.0 * z
    # Broad at the back of the HILT, narrowing to a point at the rear:
    # 2 convex triangles avoid invalid-polygon triangulation and keep
    # the sword's steel faces/filigree uncovered.
    c.draw_colored_polygon(PackedVector2Array([
        start + n * 9.0 * z, start - n * 9.0 * z, end
    ]), _col(BLUE, strength * 0.089))
    c.draw_colored_polygon(PackedVector2Array([
        start + n * 3.5 * z, start - n * 3.5 * z, end
    ]), _col(CYAN, strength * 0.168))
    c.draw_line(start - f * 9.0 * z, start,
        _col(ICE, strength * 0.35), maxf(0.8, 1.45 * z), true)
    # Sparse travelling embers flow along both sides, fixed cost.
    for j in range(3):
        var u := 0.17 + float(j) * 0.30
        var p := start.lerp(end, u)
        var orbit := sin(u * 19.0 + motion * 12.0) * (4.0 - 2.5 * u) * z
        PREV._spark(c, p + n * orbit, 0.7 * z, strength * (0.43 - u * 0.17))

static func _aoe(c: CanvasItem, at: Vector2, radii: Vector2,
        hit_targets: Array, t: float) -> void:
    if t < 0.205 or t >= 0.99:
        return
    var emerge := _ease((t - 0.205) / 0.175)
    var vanish := 1.0 - _ease((t - 0.84) / 0.15)
    var a := emerge * vanish
    var rx := maxf(1.0, radii.x)
    var ry := maxf(1.0, radii.y)
    PREV._ring(c, at, rx, ry, CYAN, 0.84 * a)
    PREV._ring(c, at, rx * 0.76, ry * 0.76, GOLD, 0.54 * a)
    for i in range(12):
        var angle := TAU13 * float(i) / 12.0
        var ray := Vector2(cos(angle) * rx, sin(angle) * ry)
        c.draw_line(at + ray * 0.86, at + ray * 0.96,
            _col(GOLD, a * 0.63), 1.35, true)
    # Show ONLY known eligible targets, never a fictional hit on the
    # fourth monster that happens to be visible in the Lab scene.
    for p in hit_targets:
        if not p is Vector2:
            continue
        var dest: Vector2 = p
        PREV._ring(c, dest + Vector2(0.0, 10.0),
            22.0, 9.0, GOLD, a * 0.42)

static func _impact(c: CanvasItem, at: Vector2,
        z: float, elapsed: float, index: int) -> void:
    var k := clampf(elapsed, 0.0, 1.0)
    if k >= 1.0:
        return
    var a := 1.0 - _ease(k)
    var flash := pow(1.0 - k, 3.2)
    c.draw_circle(at, (7.0 + 18.0 * k) * z,
        _col(CYAN, 0.22 * flash))
    c.draw_circle(at, (3.0 + 3.0 * k) * z,
        _col(ICE, 0.70 * flash))
    PREV._ring(c, at + Vector2(0, 17.0 * z),
        (13.0 + 44.0 * k) * z,
        (7.0 + 22.0 * k) * z, GOLD, a * 0.75)
    # A very brief directional cut passes through the ACTUAL struck
    # monster's body; the broad blue aura remains below the hit.
    var cut_axis := Vector2(0.91, -0.42)
    var cut_start := at - cut_axis * (25.0 + 10.0 * k) * z
    var cut_end := at + cut_axis * (24.0 + 12.0 * k) * z
    c.draw_line(cut_start, cut_end, _col(CYAN, flash * 0.23),
        maxf(1.0, 5.3 * z), true)
    c.draw_line(cut_start, cut_end, _col(ICE, flash * 0.78),
        maxf(0.8, 1.45 * z), true)
    for j in range(4):
        var dir := Vector2.from_angle(TAU13 * float(j) / 4.0 + float(index) * 0.28)
        var begin := at + dir * (7.0 + k * 10.0) * z
        var finish := at + dir * (18.0 + k * 37.0) * z
        c.draw_line(begin, finish,
            _col(ICE if j % 2 == 0 else GOLD, a * 0.65),
            maxf(0.7, (2.1 - 1.1 * k) * z), true)

static func _wave_arc(c: CanvasItem, at: Vector2,
        radius: Vector2, t: float) -> void:
    if t < 0.70 or t > 0.985:
        return
    var age := clampf((t - 0.70) / 0.285, 0.0, 1.0)
    var opacity := 1.0 - _ease(age)
    var points := PackedVector2Array()
    for i in range(31):
        var phi := -2.35 + float(i) * 2.22 / 30.0
        points.append(at + Vector2(
            cos(phi) * radius.x * (0.81 + age * 0.32),
            sin(phi) * radius.y * (0.81 + age * 0.32)))
    c.draw_polyline(points, _col(CYAN, opacity * 0.12), 11.0, true)
    c.draw_polyline(points, _col(ICE, opacity * 0.43), 1.8, true)

static func render(c: CanvasItem, caster: Vector2, locked_center: Vector2,
        hit_targets: Array, radii_px: Vector2, progress: float,
        zoom: float, lod: int = 2) -> void:
    var t := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.6, 1.95)
    _aoe(c, locked_center, radii_px, hit_targets, t)
    if t < 0.36:
        var charge := _ease(t / 0.26) * (1.0 - _ease((t - 0.29) / 0.075))
        PREV._ring(c, caster + Vector2(0, 24 * z), 34 * z,
            14 * z, GOLD, charge * 0.70)
        PREV._spark(c, caster + Vector2(0, -9 * z),
            z * 1.8, charge * 0.82)
    # All three waves converge ONLY on given actual/approved targets.
    # If hit_targets is empty, do NOT infer enemies from the screen.
    var count := mini(9 if lod >= 2 else (6 if lod == 1 else 3), hit_targets.size() * 3)
    for i in range(count):
        var wave := floori(float(i) / 3.0)
        var slot := i % 3
        var hit: Vector2 = hit_targets[slot % hit_targets.size()]
        var schedule := flight_timing(i)
        var onset := _ease((t - float(wave) * 0.040) / 0.21)
        var alpha := onset * visibility_after_contact(t, schedule.y)
        # Only first three swords become visible during charge.
        if t < schedule.x:
            alpha *= 1.0 if wave == 0 else 0.0
        if alpha < 0.015:
            continue
        var origin := caster + Vector2(
            38.0 + float(wave) * 41.0,
            (float(slot) - 1.0) * 73.0 - float(wave) * 7.0) * z
        var axis := (hit - origin).normalized()
        var elapsed := clampf((t - schedule.x) /
            (schedule.y - schedule.x), 0.0, 1.0)
        var center := origin.lerp(hit, _ease(elapsed))
        var fading := clampf((t - schedule.y) / 0.155, 0.0, 1.0)
        center += axis * fading * 9.0 * z
        var size := (0.77 if wave == 0 else 0.61) * z
        if elapsed > 0.02 and elapsed < 0.998:
            _trail(c, center, axis, size, alpha, elapsed)
        PREV._blade(c, center, axis, size, alpha)
    # One primary impact emphasis for each VALID hit target at last volley;
    # number of projectile copies never multiplies numerical damage.
    for j in range(hit_targets.size()):
        var last_wave_hit := flight_timing(6 + (j % 3)).y
        if t >= last_wave_hit and t < last_wave_hit + 0.19:
            _impact(c, hit_targets[j], z * 0.82,
                (t - last_wave_hit) / 0.19, j)
    _wave_arc(c, locked_center, radii_px, t)
