extends RefCounted
# V11 SWORD LAB-ONLY. Original Godot code geometry; dual-shaded steel body, edge glow, no image imports.
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

# ART SOURCE: original code geometry (not scraped textures/painted weapon images).
# V11. Sword metal is normally alpha-composited, not full-screen additive:
# a legible dark rim, faceted steel and only a restrained light-edge.
static func _sword(canvas: CanvasItem, center: Vector2,
        forward: Vector2, scale: float, visibility: float) -> void:
    var a := clampf(visibility, 0.0, 1.0)
    if a < 0.014:
        return
    var z := clampf(scale, 0.42, 2.3)
    var f: Vector2 = forward.normalized()
    if f.length_squared() < 0.5:
        f = Vector2.RIGHT
    var side: Vector2 = f.orthogonal()
    var base: Vector2 = center - f * 17.0 * z
    var shoulder: Vector2 = center + f * 30.0 * z
    var tip: Vector2 = center + f * 62.0 * z
    var guard: Vector2 = base - f * 4.0 * z
    var handle: Vector2 = guard - f * 15.0 * z
    var pommel: Vector2 = handle - f * 5.0 * z
    # Drop shadow under the blade establishes a crisp SILHOUETTE at 1x.
    var blade_outer := PackedVector2Array([
        base - side * 6.6 * z, shoulder - side * 6.6 * z, tip,
        shoulder + side * 6.6 * z, base + side * 6.6 * z
    ])
    canvas.draw_colored_polygon(blade_outer, _ink(Color("15223c"), a * 0.99))
    # Two steel bevels meeting at the central ridge. Slightly off-white,
    # otherwise the eye perceives a flat neon rod rather than a forged jian.
    canvas.draw_colored_polygon(PackedVector2Array([
        base - side * 4.7 * z, shoulder - side * 5.1 * z, tip, base
    ]), _ink(Color("d5e1ed"), a * 0.99))
    canvas.draw_colored_polygon(PackedVector2Array([
        base, tip, shoulder + side * 5.1 * z, base + side * 4.7 * z
    ]), _ink(Color("4e719d"), a * 0.93))
    canvas.draw_line(base, tip, _ink(Color("f5faff"), a * 0.77),
        maxf(0.75, 0.75 * z), true)
    # Only the CUTTING EDGES glow, not the whole body.
    for sign in [-1.0, 1.0]:
        var n := float(sign)
        canvas.draw_line(base + side * n * 5.4 * z,
            shoulder + side * n * 5.5 * z,
            _ink(SKY, a * 0.48), maxf(0.65, 1.0 * z), true)
        canvas.draw_line(shoulder + side * n * 5.5 * z, tip,
            _ink(SKY, a * 0.49), maxf(0.65, 1.0 * z), true)
    # A jeweled median ridge and 2 diagonal gold talismans.
    var rune: Color = _ink(Color("e9bb65"), a * 0.96)
    var seal: Vector2 = base + f * 21.0 * z
    canvas.draw_polyline(PackedVector2Array([
        seal - f * 5.0 * z, seal - side * 2.8 * z,
        seal + f * 5.0 * z, seal + side * 2.8 * z,
        seal - f * 5.0 * z
    ]), rune, maxf(0.82, z), true)
    for sign in [-1.0, 1.0]:
        var n := float(sign)
        canvas.draw_line(seal + f * 10.0 * z + side * n * 2.4 * z,
            seal + f * 20.0 * z + side * n * 1.2 * z,
            rune, maxf(0.72, 0.82 * z), true)
    # Dark gold quillon and carefully curved flukes.
    var left: Vector2 = guard - side * 10.0 * z
    var right: Vector2 = guard + side * 10.0 * z
    canvas.draw_line(left, right, _ink(Color("392e39"), a), 4.0 * z, true)
    canvas.draw_line(left, right, rune, 2.1 * z, true)
    canvas.draw_line(left, left + f * 6.0 * z - side * 3.3 * z,
        rune, 1.7 * z, true)
    canvas.draw_line(right, right + f * 6.0 * z + side * 3.3 * z,
        rune, 1.7 * z, true)
    canvas.draw_line(guard, handle, _ink(Color("171e39"), a), 5.0 * z, true)
    canvas.draw_line(guard, handle, _ink(Color("7365aa"), a * 0.74),
        2.0 * z, true)
    for band in range(3):
        var v: Vector2 = guard.lerp(handle, float(band + 1) / 4.0)
        canvas.draw_line(v - side * 2.4 * z, v + side * 2.4 * z,
            rune, maxf(0.8, 1.15 * z), true)
    canvas.draw_circle(pommel, 3.2 * z, _ink(Color("44315c"), a))
    canvas.draw_circle(pommel, 1.5 * z, rune)
    # Tiny controlled aura at the sharpest point; preserve steel shape.
    _glint(canvas, tip, z * 0.55, SKY, a * 0.75)

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
    var ground := center
    var outer_rx := 81.0 * z
    var outer_ry := 49.0 * z
    _arc(canvas, ground, outer_rx, outer_ry, SKY, strength * 0.87)
    _arc(canvas, ground, outer_rx * 0.71, outer_ry * 0.71,
        GOLD, strength * 0.65, -0.13)
    # Eight inward arcane spokes distinguish the AOE warning circle
    # from an ordinary selection ring.
    for spoke in range(8):
        var ang := TAU_S * float(spoke) / 8.0
        var ray := Vector2(cos(ang) * outer_rx, sin(ang) * outer_ry)
        canvas.draw_line(ground + ray * 0.74, ground + ray * 0.90,
            _ink(GOLD, strength * 0.40), maxf(0.7, z), true)
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

# Four short-lived impact bursts, one per actual demo target: hard
# central white hit, golden cutting-star, expanding cyan shock ring,
# then transparent ember slivers. No random spawning or fake gameplay hit.
static func _impact(canvas: CanvasItem, at: Vector2, z: float,
        time_after: float, group_id: int) -> void:
    var age := clampf(time_after, 0.0, 1.0)
    if age >= 0.997:
        return
    var alpha := 1.0 - _smooth(age)
    var flash := pow(1.0 - age, 4.0)
    var ground := at + Vector2(0.0, 19.0 * z)
    canvas.draw_circle(at, (7.0 + age * 11.0) * z,
        _ink(SKY, flash * 0.23))
    canvas.draw_circle(at, (3.2 + age * 2.4) * z,
        _ink(ICE, flash * 0.96))
    _arc(canvas, ground, (8.0 + 40.0 * age) * z,
        (3.0 + 19.0 * age) * z, SKY, alpha * 0.84)
    # A flash-cross with unequal arms resembles a slice-through, not fireworks.
    for j in range(4):
        var angle := TAU_S * float(j) / 4.0 + 0.17 * float(group_id)
        var f: Vector2 = Vector2.from_angle(angle)
        var p: Vector2 = at + f * (4.0 + 9.0 * age) * z
        var q: Vector2 = at + f * (17.0 + 30.0 * age) * z
        canvas.draw_line(p, q,
            _ink(GOLD if j % 2 == 0 else ICE, alpha * 0.80),
            maxf(0.8, (2.4 - 1.5 * age) * z), true)
    # Elliptical steel fragments and restrained afterglow at the hit.
    for j in range(5):
        var theta := TAU_S * (float(group_id) * 0.13 + float(j) / 5.0)
        var drift: Vector2 = Vector2.from_angle(theta) * (5.0 + 28.0 * age) * z
        _glint(canvas, at + drift, z * (0.70 - 0.37 * age),
            GOLD if j % 2 == 0 else SKY, alpha * 0.52)

# V11 visual dramaturgy: charge 0.00..0.40, lock circle 0.22..0.42,
# launch 0.42..0.86, impacts, sword-form dissolve 0.80..1.00.
# 4 LEAD swords are dominant; 8 subordinate copies are less opaque and
# smaller. They are original geometry, never fake authoritative hits.
static func render(canvas: CanvasItem, from: Vector2, to: Vector2,
        time01: float, zoom: float, detail: int = 2) -> void:
    var t := clampf(time01, 0.0, 1.0)
    var z := clampf(zoom, 0.6, 2.0)
    var sword_count := 12 if detail >= 2 else (8 if detail == 1 else 4)
    _aoe_seal(canvas, to, z, t)
    if t < 0.43:
        var charge := _smooth(t / 0.43)
        _arc(canvas, from + Vector2(0.0, 14.0 * z),
            (25.0 + charge * 75.0) * z,
            (11.0 + charge * 22.0) * z,
            GOLD, 0.09 + charge * 0.30)
        _glint(canvas, from + Vector2(0.0, -9.0 * z), z * 1.8,
            SKY, charge * 0.55)
    # Target runes ignite just before the first sword hits.
    # All four target centers are derived from the DEMO composition only;
    # this does not replace the actual arena's canonical targeting.
    if t >= 0.59 and t < 0.94:
        var prelight := _smooth((t - 0.59) / 0.12) * (1.0 - _smooth((t - 0.81) / 0.13))
        for g in range(4):
            var aim_center := to + Vector2(
                (float(g % 2) - 0.5) * 106.0,
                (float(floori(float(g) / 2.0)) - 0.5) * 94.0)
            _arc(canvas, aim_center + Vector2(0.0, 16.0 * z),
                23.0 * z, 10.0 * z, GOLD, prelight * 0.48)
            _glint(canvas, aim_center, z * 1.8, SKY, prelight * 0.60)
    # More varied but legible 4-sided formation: four ceremonial blades
    # lead, smaller blades form the secondary energy ranks behind each.
    for i in range(sword_count):
        var group := i % 4
        var rank := floori(float(i) / 4.0)
        var hero := rank == 0
        var angle := TAU_S * float(group) / 4.0 + float(rank) * 0.20
        var orbit := Vector2(cos(angle), sin(angle) * 0.62)
        var origin := from + orbit * (93.0 + float(rank) * 25.0) * z
        var col := float(group % 2)
        var row_index := float(floori(float(group) / 2.0))
        var spread := Vector2((float(rank) - 1.0) * 14.0,
            (float(rank) - 1.0) * 17.0) * z
        var target := to + Vector2((col - 0.5) * 106.0,
            (row_index - 0.5) * 94.0) + spread
        var f: Vector2 = (target - origin).normalized()
        var launch := 0.41 + float(group) * 0.015 + float(rank) * 0.028
        var reach := 0.74 + float(group) * 0.028 + float(rank) * 0.023
        var travel_time := clampf((t - launch) / (reach - launch), 0.0, 1.0)
        # Finite acceleration and deceleration, then gradual sinking as the
        # sword dissolves. No instantaneous disappearance on contact.
        var position := origin.lerp(target, _smooth(travel_time))
        var after_hit := clampf((t - reach) / 0.14, 0.0, 1.0)
        position += f * (after_hit * 9.0 * z)
        var born := _smooth((t - float(rank) * 0.032) / 0.22)
        var fading := 1.0 - _smooth((t - reach - 0.004) / 0.14)
        var opacity := born * fading * (1.0 if hero else 0.64)
        if opacity < 0.012:
            continue
        var body_scale := (0.84 if hero else 0.53) * z
        _sword(canvas, position, f, body_scale, opacity)
        # The trailing energy is short, narrow and BEHIND the whole blade.
        # No luminous line is allowed to run down the weapon's metal face.
        if travel_time > 0.04 and travel_time < 0.99:
            var base: Vector2 = position - f * (42.0 * body_scale)
            canvas.draw_line(base - f * 15.0 * z, base - f * 5.0 * z,
                _ink(SKY, opacity * 0.26), maxf(0.8, 1.2 * z), true)
        if t > reach and hero:
            _impact(canvas, target, z * 0.66,
                clampf((t - reach) / 0.19, 0.0, 1.0), group)
    if t > 0.75:
        var aftermath := clampf((t - 0.75) / 0.25, 0.0, 1.0)
        _arc(canvas, to, (78.0 + aftermath * 48.0) * z,
            (46.0 + aftermath * 24.0) * z,
            SKY, (1.0 - aftermath) * 0.51)
