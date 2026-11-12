extends RefCounted
# VFX14 Lab-only: JX/Kiem The/NKVS reference-led layered sword-qi.
# Original procedural Godot geometry, no imported commercial assets.
# LOCKED primary AOE center + approved hit targets; no combat authority.
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

# A readable flying jian with spectral facets, a compact golden hilt,
# and energy fins BEHIND the blade; no full-body additive whitening.
static func _qi_blade(c: CanvasItem, at: Vector2,
        forward: Vector2, z: float, a: float) -> void:
    if a < 0.014:
        return
    var f: Vector2 = forward.normalized()
    if f.length_squared() < 0.01:
        f = Vector2.RIGHT
    var n: Vector2 = f.orthogonal()
    var root: Vector2 = at - f * 18.0 * z
    var shoulder: Vector2 = at + f * 24.0 * z
    var tip: Vector2 = at + f * 62.0 * z
    var guard: Vector2 = root - f * 3.0 * z
    var hilt_end: Vector2 = guard - f * 18.0 * z
    # Pale blue glow follows the BLADE shape; small compared to weapon core.
    c.draw_colored_polygon(PackedVector2Array([
        root - n * 13.0 * z,
        shoulder - n * 10.0 * z,
        tip,
        shoulder + n * 10.0 * z,
        root + n * 13.0 * z
    ]), _col(BLUE, a * 0.105))
    c.draw_colored_polygon(PackedVector2Array([
        root - n * 6.3 * z,
        shoulder - n * 5.7 * z,
        tip,
        shoulder + n * 5.7 * z,
        root + n * 6.3 * z
    ]), _col(DARK, a * 0.96))
    c.draw_colored_polygon(PackedVector2Array([
        root, root - n * 4.4 * z, shoulder - n * 4.2 * z, tip
    ]), _col(ICE, a * 0.94))
    c.draw_colored_polygon(PackedVector2Array([
        root, tip, shoulder + n * 4.1 * z, root + n * 4.4 * z
    ]), _col(CYAN, a * 0.72))
    c.draw_line(root, tip, _col(ICE, a * 0.82),
        maxf(0.9, 0.95 * z), true)
    var seal: Vector2 = root + f * 22.0 * z
    c.draw_polyline(PackedVector2Array([
        seal - f * 5.0 * z, seal - n * 2.7 * z,
        seal + f * 5.0 * z, seal + n * 2.7 * z,
        seal - f * 5.0 * z
    ]), _col(GOLD, a * 0.82), maxf(0.8, 1.0 * z), true)
    # Distinctive jian silhouette rather than an arrow-shaped neon wedge.
    c.draw_line(guard - n * 9.0 * z, guard + n * 9.0 * z,
        _col(GOLD, a * 0.92), maxf(1.0, 2.2 * z), true)
    c.draw_line(guard, hilt_end, _col(DARK, a), maxf(1.0, 3.4 * z), true)
    c.draw_line(guard - f * 5.0 * z, hilt_end,
        _col(GOLD, a * 0.55), maxf(0.7, 1.0 * z), true)
    c.draw_circle(hilt_end, 1.8 * z, _col(GOLD, a * 0.9))
    # Two tiny luminous fins at the guard deliver the classic sword-qi style.
    for sign in [-1.0, 1.0]:
        var side := float(sign)
        c.draw_colored_polygon(PackedVector2Array([
            root - f * 10.0 * z + n * side * 4.0 * z,
            root + f * 7.0 * z + n * side * 7.8 * z,
            root - f * 21.0 * z + n * side * 18.0 * z
        ]), _col(CYAN, a * 0.15))

# Five-segment curved tapered energy cloth: two convex translucent bands
# and a fast white-blue core, all BEHIND the rigid blade silhouette.
# Everything uses deterministic phase and fixed primitive budgets.
static func _trail(c: CanvasItem, at: Vector2, direction: Vector2,
        z: float, opacity: float, motion: float) -> void:
    var strength := clampf(opacity, 0.0, 1.0) * clampf(motion, 0.0, 1.0)
    if strength <= 0.01:
        return
    var f: Vector2 = direction.normalized()
    var n: Vector2 = f.orthogonal()
    var base: Vector2 = at - f * 38.0 * z
    var curve := PackedVector2Array()
    var widths := PackedFloat32Array()
    for i in range(6):
        var u := float(i) / 5.0
        var sway := sin(u * 3.3 - motion * 4.0) * u * 11.5 * z
        curve.append(base - f * u * 99.0 * z + n * sway)
        widths.append((1.0 - u) * (11.5 - u * 2.5) * z)
    # Each quadrilateral is convex; bounded geometry avoids long
    # self-crossing polygons and the V9.3 triangulation regression.
    for i in range(5):
        var fade := strength * (1.0 - float(i) / 5.0)
        var left0: Vector2 = curve[i] + n * widths[i]
        var right0: Vector2 = curve[i] - n * widths[i]
        var left1: Vector2 = curve[i + 1] + n * widths[i + 1]
        var right1: Vector2 = curve[i + 1] - n * widths[i + 1]
        c.draw_colored_polygon(PackedVector2Array([
            left0, right0, right1, left1
        ]), _col(BLUE, fade * 0.12))
        c.draw_colored_polygon(PackedVector2Array([
            curve[i] + n * widths[i] * 0.26,
            curve[i] - n * widths[i] * 0.26,
            curve[i + 1] - n * widths[i + 1] * 0.26,
            curve[i + 1] + n * widths[i + 1] * 0.26
        ]), _col(CYAN, fade * 0.15))
    c.draw_polyline(curve, _col(CYAN, strength * 0.24),
        maxf(0.8, 2.2 * z), true)
    c.draw_line(curve[0], curve[1], _col(ICE, strength * 0.37),
        maxf(0.75, 1.15 * z), true)
    for i in range(2):
        var p: Vector2 = curve[2 + i] + n * (4.0 if i == 0 else -5.0) * z
        PREV._spark(c, p, 1.05 * z, strength * (0.54 - 0.11 * float(i)))

# AOE: locked radius = caller-projected radius; brighter layered ring
# with 8 radiant sigils, two arc sectors and only approved victim marks.
# No graphic ever widens the authoritative world radius.
static func _aoe(c: CanvasItem, at: Vector2, radii: Vector2,
        hit_targets: Array, t: float) -> void:
    if t < 0.205 or t >= 0.99:
        return
    var emerge := _ease((t - 0.205) / 0.14)
    var vanish := 1.0 - _ease((t - 0.83) / 0.16)
    var a := emerge * vanish
    var rx := maxf(1.0, radii.x)
    var ry := maxf(1.0, radii.y)
    PREV._ring(c, at, rx, ry, CYAN, a * 0.96)
    PREV._ring(c, at, rx * 0.81, ry * 0.81, GOLD, a * 0.66)
    PREV._ring(c, at, rx * 0.42, ry * 0.42, BLUE, a * 0.29)
    for i in range(12):
        var angle := TAU13 * float(i) / 12.0
        var ray := Vector2(cos(angle) * rx, sin(angle) * ry)
        c.draw_line(at + ray * 0.80, at + ray * 0.97,
            _col(GOLD, a * 0.70), maxf(0.95, 1.4), true)
        if i % 3 == 0:
            var mark := at + ray * 0.90
            PREV._spark(c, mark, 1.2, a * 0.67)
    # Rotating arc SECTORS, not a solid bright disk blocking monsters.
    for sector in range(2):
        var arc := PackedVector2Array()
        for j in range(9):
            var angle := t * (0.46 if sector == 0 else -0.46)
            angle += PI * float(sector) + float(j) * 0.11
            arc.append(at + Vector2(cos(angle) * rx * 0.68,
                sin(angle) * ry * 0.68))
        c.draw_polyline(arc, _col(CYAN, a * 0.35), 2.0, true)
    for p in hit_targets:
        if p is Vector2:
            var dest: Vector2 = p
            PREV._ring(c, dest + Vector2(0.0, 9.0),
                23.0, 10.0, GOLD, a * 0.63)
            PREV._spark(c, dest + Vector2(0.0, -7.0), 1.2, a * 0.36)

# Strong but BOUNDED impact: one white blade-cut per approved target
# and one expanding ground shock ring. No 9 fake damage numbers.
static func _impact(c: CanvasItem, at: Vector2,
        z: float, elapsed: float, index: int) -> void:
    var k := clampf(elapsed, 0.0, 1.0)
    if k >= 0.999:
        return
    var a := 1.0 - _ease(k)
    var flash := pow(1.0 - k, 3.3)
    c.draw_circle(at, (12.0 + 26.0 * k) * z,
        _col(BLUE, flash * 0.14))
    c.draw_circle(at, (4.0 + 8.0 * k) * z,
        _col(ICE, flash * 0.79))
    # Golden sword aura rising only over hit target; extra vivid vertical
    # shape like 2.5D JX attack, not a rectangular laser column.
    var base := at + Vector2(0.0, 14.0 * z)
    c.draw_colored_polygon(PackedVector2Array([
        base - Vector2(15.0, 0.0) * z,
        at + Vector2(-4.0, -77.0) * z,
        at + Vector2(5.0, -88.0) * z,
        base + Vector2(15.0, 0.0) * z
    ]), _col(CYAN, flash * 0.12))
    c.draw_line(at + Vector2(0.0, 6.0 * z),
        at - Vector2(0.0, 61.0 * z),
        _col(ICE, flash * 0.40), maxf(1.0, (3.2 - 2.1 * k) * z), true)
    PREV._ring(c, base, (14.0 + 50.0 * k) * z,
        (7.0 + 27.0 * k) * z, CYAN, a * 0.91)
    PREV._ring(c, base, (9.0 + 28.0 * k) * z,
        (4.0 + 12.0 * k) * z, GOLD, a * 0.62)
    # A single oblique serrated cut, then 6 small shards rotating out.
    var cut_axis := Vector2(0.88, -0.47)
    var cut_start := at - cut_axis * (26.0 + 19.0 * k) * z
    var cut_end := at + cut_axis * (29.0 + 15.0 * k) * z
    c.draw_line(cut_start, cut_end,
        _col(BLUE, flash * 0.20), 7.0 * z, true)
    c.draw_line(cut_start, cut_end,
        _col(ICE, flash * 0.89), maxf(0.8, 1.85 * z), true)
    for j in range(6):
        var ang := TAU13 * float(j) / 6.0 + 0.19 * float(index)
        var direction := Vector2.from_angle(ang)
        var start := at + direction * (8.0 + 12.0 * k) * z
        var finish := at + direction * (22.0 + 41.0 * k) * z
        c.draw_line(start, finish, _col(GOLD if j % 2 == 0 else CYAN,
            a * 0.54), maxf(0.8, (1.9 - 1.0 * k) * z), true)

# Three faint crescent sweeps are decorative rhythm; only valid
# hit targets ever receive the strong per-target impact layer.
static func _wave_arc(c: CanvasItem, at: Vector2,
        radius: Vector2, t: float) -> void:
    if t < 0.60 or t > 0.968:
        return
    for wave in range(3):
        var begin := 0.600 + float(wave) * 0.095
        var age := clampf((t - begin) / 0.18, 0.0, 1.0)
        if t < begin or age >= 1.0:
            continue
        var opacity := (1.0 - _ease(age)) * 0.73
        var points := PackedVector2Array()
        for i in range(25):
            var phi := -2.42 + float(i) * 2.08 / 24.0
            phi += float(wave) * 0.17
            points.append(at + Vector2(
                cos(phi) * radius.x * (0.73 + age * 0.20),
                sin(phi) * radius.y * (0.73 + age * 0.20)))
        c.draw_polyline(points, _col(CYAN, opacity * 0.13), 8.0, true)
        c.draw_polyline(points, _col(ICE, opacity * 0.56), 1.6, true)

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
        _qi_blade(c, center, axis, size, alpha)
    # One primary impact emphasis for each VALID hit target at last volley;
    # number of projectile copies never multiplies numerical damage.
    for j in range(hit_targets.size()):
        var last_wave_hit := flight_timing(6 + (j % 3)).y
        if t >= last_wave_hit and t < last_wave_hit + 0.19:
            _impact(c, hit_targets[j], z * 0.82,
                (t - last_wave_hit) / 0.19, j)
    _wave_arc(c, locked_center, radii_px, t)
