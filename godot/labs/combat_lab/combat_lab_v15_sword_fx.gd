extends RefCounted
# VFX15: original CODE-DRAWN sword-light for 2D/2.5D. LAB-ONLY.
# No metal mesh, hilt, guard, 3D weapon, external sprites or gameplay authority.
# A visual sword-qi is always STOPPED BEFORE the enemy silhouette; a short
# burst takes over at the contact boundary. Hit recipients are caller-supplied.
const OLD = preload("res://labs/combat_lab/combat_lab_v14_sword_fx.gd")
const CYAN := Color("71dfff")
const ICE := Color("f1faff")
const AZURE := Color("478eff")
const AQUA := Color("86ffe4")
const GOLD := Color("f5d89c")
const VIOLET := Color("a58dfc")
const TAU15 := PI * 2.0

static func _col(color: Color, alpha: float) -> Color:
    return Color(color.r, color.g, color.b, clampf(alpha, 0.0, 1.0))

static func _ease(v: float) -> float:
    var k := clampf(v, 0.0, 1.0)
    return k * k * (3.0 - 2.0 * k)

# Preview-only selection; DO NOT use this function to determine real damage.
static func preview_circle_targets(actors: Array, locked_center: Vector2,
        radii_px: Vector2, max_targets: int = 3) -> Array:
    return OLD.preview_circle_targets(actors, locked_center, radii_px, max_targets)

static func flight_timing(index: int) -> Vector2:
    return OLD.flight_timing(index)

static func contact_time(index: int) -> float:
    var travel := flight_timing(index)
    # The sword-qi stops at 82% of the original visual flight time.
    return lerpf(travel.x, travel.y, 0.82)

static func contact_point(victim: Vector2, forward: Vector2, scale: float) -> Vector2:
    var direction := forward.normalized()
    if direction.length_squared() < 0.001:
        direction = Vector2.RIGHT
    # Monster rig anchor is near feet, while chest is a little above.
    # Stop the sword tip outside the chest: NO vertex may pass this point.
    return victim + Vector2(0.0, -19.0 * scale) - direction * (29.0 * scale)

static func pre_contact_opacity(u: float) -> float:
    # The projectile starts de-materializing BEFORE reaching its target,
    # transferring energy to the contact flash. No post-hit sword frame.
    return 1.0 - _ease((u - 0.66) / 0.34) * 0.97

static func _ring(c: CanvasItem, at: Vector2, rx: float, ry: float,
        color: Color, alpha: float, start_angle: float = 0.0,
        span: float = TAU15) -> void:
    if alpha <= 0.01:
        return
    var pts := PackedVector2Array()
    for i in range(33):
        var phi := start_angle + span * float(i) / 32.0
        pts.append(at + Vector2(cos(phi) * rx, sin(phi) * ry))
    c.draw_polyline(pts, _col(color, alpha * 0.15), 6.0, true)
    c.draw_polyline(pts, _col(color, alpha * 0.68), 1.35, true)

static func _spark(c: CanvasItem, p: Vector2, z: float,
        hue: Color, alpha: float) -> void:
    if alpha <= 0.01:
        return
    c.draw_circle(p, 4.0 * z, _col(hue, alpha * 0.075))
    c.draw_circle(p, 1.0 * z, _col(ICE, alpha * 0.64))

# LIGHT SWORD, NOT A MODEL: a luminous tapered blade-SHAPED current.
# The white central spine is slightly shorter than a translucent blue sheath.
# No guard, metal facets, outlines, hilt, or pommel.
static func _light_blade(c: CanvasItem, tip: Vector2, heading: Vector2,
        size: float, alpha: float, seed: int) -> void:
    if alpha <= 0.012:
        return
    var z := maxf(0.2, size)
    var f := heading.normalized()
    if f.length_squared() < 0.01:
        f = Vector2.RIGHT
    var n := f.orthogonal()
    var base := tip - f * 64.0 * z
    var mid := tip - f * 23.0 * z
    var shoulder := tip - f * 42.0 * z
    # A soft outer silhouette with a ghost double-image.
    c.draw_colored_polygon(PackedVector2Array([
        base - n * 7.0 * z, shoulder - n * 13.0 * z,
        tip, shoulder + n * 13.0 * z, base + n * 7.0 * z
    ]), _col(AZURE, alpha * 0.091))
    c.draw_colored_polygon(PackedVector2Array([
        base - n * 3.8 * z, mid - n * 6.0 * z,
        tip, mid + n * 6.0 * z, base + n * 3.8 * z
    ]), _col(CYAN, alpha * 0.205))
    c.draw_colored_polygon(PackedVector2Array([
        base - n * 1.7 * z, mid - n * 2.1 * z,
        tip, mid + n * 2.1 * z, base + n * 1.7 * z
    ]), _col(ICE, alpha * 0.30))
    # Deliberately broken luminous spine: the whole weapon never looks solid.
    c.draw_line(base + f * 12.0 * z, mid,
        _col(AQUA, alpha * 0.36), maxf(0.7, 1.5 * z), true)
    c.draw_line(mid, tip, _col(ICE, alpha * 0.76),
        maxf(0.75, 1.35 * z), true)
    c.draw_line(tip - f * 9.0 * z, tip,
        _col(ICE, alpha * 0.89), maxf(0.7, 0.95 * z), true)
    # Two etheric whiskers make this read as a qi-technique, not ammunition.
    for sign in [-1.0, 1.0]:
        var side := float(sign)
        var bend := sin(float(seed) * 1.47) * 3.0
        c.draw_line(base + n * side * (3.0 + bend) * z,
            shoulder + n * side * 7.5 * z,
            _col(CYAN, alpha * 0.26), maxf(0.65, 0.9 * z), true)
    _spark(c, tip - f * 3.5 * z, 1.1 * z, ICE, alpha * 0.75)

# Flowing air extends BEHIND the qi blade; six deterministic stations,
# five convex trapezoids, no expensive particle nodes.
static func _flow_trail(c: CanvasItem, tip: Vector2, heading: Vector2,
        z: float, alpha: float, u: float, seed: int) -> void:
    if alpha <= 0.012:
        return
    var f := heading.normalized()
    var n := f.orthogonal()
    var spine := PackedVector2Array()
    var widths := PackedFloat32Array()
    var base := tip - f * 63.0 * z
    for i in range(6):
        var t := float(i) / 5.0
        var flicker := sin(u * 8.0 - t * 5.1 + float(seed) * 0.65)
        var sway := (t * t) * (10.0 + 7.0 * flicker) * z
        spine.append(base - f * t * 90.0 * z + n * sway)
        widths.append((1.0 - t) * (11.0 - 4.0 * t) * z)
    for j in range(5):
        var falloff := (1.0 - float(j) / 5.0) * alpha
        c.draw_colored_polygon(PackedVector2Array([
            spine[j] + n * widths[j],
            spine[j] - n * widths[j],
            spine[j+1] - n * widths[j+1],
            spine[j+1] + n * widths[j+1]
        ]), _col(AZURE, falloff * 0.072))
        c.draw_colored_polygon(PackedVector2Array([
            spine[j] + n * widths[j] * 0.33,
            spine[j] - n * widths[j] * 0.33,
            spine[j+1] - n * widths[j+1] * 0.33,
            spine[j+1] + n * widths[j+1] * 0.33
        ]), _col(CYAN, falloff * 0.20))
    c.draw_polyline(spine, _col(CYAN, alpha * 0.26),
        maxf(0.75, 1.8 * z), true)
    for k in range(2):
        var pos := spine[2 + k] + n * (4.0 if k == 0 else -4.0) * z
        _spark(c, pos, 0.7 * z, AQUA, alpha * 0.45)

static func _sigils(c: CanvasItem, center: Vector2,
        radii: Vector2, approved: Array, t: float) -> void:
    if t <= 0.18 or t >= 0.985:
        return
    var appear := _ease((t - 0.18) / 0.20)
    var dissolve := 1.0 - _ease((t - 0.81) / 0.18)
    var a := appear * dissolve
    var rx := maxf(1.0, radii.x)
    var ry := maxf(1.0, radii.y)
    # Soft phantasmagoric isometric aura; no solid filled disk.
    _ring(c, center, rx, ry, CYAN, a * 0.62)
    _ring(c, center, rx * 0.82, ry * 0.82, GOLD, a * 0.45)
    for band in range(3):
        var angle := float(band) * TAU15 / 3.0 + t * (0.55 if band % 2 == 0 else -0.55)
        _ring(c, center, rx * 0.69, ry * 0.69,
            CYAN if band % 2 == 0 else VIOLET, a * 0.29, angle, 0.71)
    for j in range(10):
        var theta := TAU15 * float(j) / 10.0
        var radial := Vector2(cos(theta) * rx, sin(theta) * ry)
        c.draw_line(center + radial * 0.89, center + radial * 0.96,
            _col(GOLD, a * 0.50), 1.05, true)
    # Exactly the supplied hit targets have a short target lock glimmer.
    for val in approved:
        if val is Vector2:
            var at: Vector2 = val
            _ring(c, at + Vector2(0.0, 7.0), 18.0, 8.0,
                AQUA, a * 0.47)

# One quick clean contact event per sword, separated from its projectile.
# Early waves have small contacts; last wave gets one strong 2.5D slash.
# This remains purely ornamental and does not create extra gameplay hits.
static func _impact_burst(c: CanvasItem, victim: Vector2, z: float,
        age: float, wave: int, lane: int) -> void:
    var k := clampf(age, 0.0, 1.0)
    if k >= 0.999:
        return
    var a := 1.0 - _ease(k)
    var main := wave == 2
    var gain := 1.0 if main else (0.33 if wave == 0 else 0.48)
    var at := victim + Vector2(0.0, -19.0 * z)
    var seed := float(lane) * 0.38
    # Contact flash with a soft halo; the projectile has already stopped.
    c.draw_circle(at, (11.0 + k * 14.0) * z,
        _col(AZURE, a * gain * 0.12))
    c.draw_circle(at, (2.8 + k * 2.8) * z,
        _col(ICE, a * gain * 0.86))
    var axis := Vector2(cos(-0.45+seed), sin(-0.45+seed))
    var start := at - axis * (16.0 + 5.0 * k) * z
    var finish := at + axis * (24.0 + 9.0 * k) * z
    c.draw_line(start, finish, _col(CYAN, a * gain * 0.19),
        (6.0 if main else 3.5) * z, true)
    c.draw_line(start, finish, _col(ICE, a * gain * 0.78),
        maxf(0.8, (1.9 if main else 1.15) * z), true)
    if main:
        # 2.5D light shower, not a 3D sword or a tall solid laser beam.
        var foot := victim + Vector2(0.0, 9.0 * z)
        _ring(c, foot, (15.0 + 36.0 * k) * z,
            (7.0 + 18.0 * k) * z, CYAN, a * 0.81)
        _ring(c, foot, (10.0 + 21.0 * k) * z,
            (4.0 + 11.0 * k) * z, GOLD, a * 0.55)
        for j in range(5):
            var angle := TAU15 * float(j) / 5.0 + seed
            var ray := Vector2.from_angle(angle)
            var begin := at + ray * (7.0 + 13.0 * k) * z
            var end := at + ray * (18.0 + 32.0 * k) * z
            c.draw_line(begin, end,
                _col(AQUA if j % 2 == 0 else GOLD, a * 0.48),
                maxf(0.7, (1.7 - 0.8 * k) * z), true)
        var up := Vector2(0.0, -1.0)
        c.draw_line(at, at + up * (24.0 + 34.0 * k) * z,
            _col(CYAN, a * 0.26), maxf(0.8, (2.5 - k) * z), true)
    else:
        _ring(c, victim + Vector2(0.0, 9.0 * z),
            (10.0 + 20.0 * k) * z, (4.5 + 9.0 * k) * z,
            CYAN, a * gain * 0.50)

# Sword-qi pre-contact tip follows a curved trajectory to the OUTSIDE
# boundary of the monster. The final 18% of V14 flight is used for
# contact transformation; there is no flying sword after contact.
static func projectile_tip(index: int, caster: Vector2, victim: Vector2,
        t: float, z: float) -> Vector2:
    var wave := floori(float(index) / 3.0)
    var lane := index % 3
    var origin := caster + Vector2(
        37.0 + float(wave) * 41.0,
        (float(lane) - 1.0) * 68.0 - float(wave) * 8.0) * z
    var forward := (victim - origin).normalized()
    var end := contact_point(victim, forward, z)
    var n := forward.orthogonal()
    var control := origin.lerp(end, 0.45) + n * (float(lane) - 1.0) * (31.0 + float(wave) * 8.0) * z
    var travel := flight_timing(index)
    var collision_t := contact_time(index)
    var u := _ease((t - travel.x) / maxf(0.001, collision_t - travel.x))
    var remain := 1.0 - u
    return origin * remain * remain + control * (2.0 * remain * u) + end * (u * u)

static func render(c: CanvasItem, caster: Vector2, locked_center: Vector2,
        hit_targets: Array, radii_px: Vector2, progress: float,
        zoom: float, lod: int = 2) -> void:
    var t := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.6, 1.95)
    if hit_targets.is_empty():
        return
    _sigils(c, locked_center, radii_px, hit_targets, t)
    if t < 0.35:
        var charge := _ease(t / 0.23) * (1.0 - _ease((t - 0.29) / 0.06))
        _ring(c, caster + Vector2(0, 24.0 * z),
            35.0 * z, 13.0 * z, GOLD, charge * 0.49)
        _spark(c, caster + Vector2(0.0, -9.0 * z),
            z * 1.65, ICE, charge * 0.81)
    var max_swords := 9 if lod >= 2 else (6 if lod == 1 else 3)
    # Keep all 3 visual volleys even if the AOE legally hits only one
    # or two enemies. Fewer targets change which destination each qi uses,
    # never shorten the three-beat choreography.
    var count := max_swords
    # Travel/charge only; no sword is drawn after reaching the contact bound.
    for i in range(count):
        var schedule := flight_timing(i)
        var contact := contact_time(i)
        var wave := floori(float(i) / 3.0)
        var lane := i % 3
        if t >= contact:
            continue
        if t < schedule.x and wave > 0:
            continue
        var victim: Vector2 = hit_targets[lane % hit_targets.size()]
        var onset := _ease((t - float(wave) * 0.04) / 0.21)
        var u := clampf((t - schedule.x) / maxf(0.001, contact - schedule.x),
            0.0, 1.0)
        var fade := pre_contact_opacity(u)
        var alpha := onset * fade
        if alpha < 0.012:
            continue
        var origin := caster + Vector2(
            37.0 + float(wave) * 41.0,
            (float(lane) - 1.0) * 68.0 - float(wave) * 8.0) * z
        var travel_f := (victim - origin).normalized()
        var tip := projectile_tip(i, caster, victim, t, z)
        var future := projectile_tip(i, caster, victim, minf(contact, t + 0.012), z)
        var heading := (future - tip).normalized()
        if heading.length_squared() < 0.001:
            heading = travel_f
        # Sword shrinks into light as collision approaches, then only the
        # independent contact burst remains. Never render through the rig.
        var shrink := 1.0 - 0.58 * _ease((u - 0.73) / 0.27)
        var size := (0.82 if wave == 0 else 0.71) * z * shrink
        if u > 0.06:
            _flow_trail(c, tip, heading, size,
                alpha * (1.0 - _ease((u - 0.72) / 0.28)), u, i)
        _light_blade(c, tip, heading, size, alpha, i)
    # Contact flashes take over immediately at the stop boundary.
    # All visible effects are derived from caller-provided victims ONLY.
    for i in range(count):
        var contact := contact_time(i)
        if t < contact or t >= contact + 0.12:
            continue
        var lane := i % 3
        var victim: Vector2 = hit_targets[lane % hit_targets.size()]
        _impact_burst(c, victim, z * 0.80,
            (t - contact) / 0.12, floori(float(i) / 3.0), lane)
