extends RefCounted
# V8 Lab visual layer. ORIGINAL CODE-DRAWN ART, no third-party assets.
# Every draw is presentation-only: never mutate HP, events, target lists or Save.
# Camera positions/skill hit timings come exclusively from caller's real cue.

const VOID := Color("15142b")
const VENOM_EDGE := Color("3b2357")
const VENOM_BODY := Color("227c56")
const JADE := Color("a6ff9b")
const VIOLET := Color("a56bfa")
const SILVER := Color("eff9ff")
const STEEL := Color("577b96")
const CYAN := Color("5fdaf7")
const TAU8 := PI * 2.0

static func fade(color: Color, opacity: float) -> Color:
    return Color(color.r, color.g, color.b, clampf(opacity, 0.0, 1.0))

static func _poly(c: CanvasItem, vertices: Array[Vector2], color: Color, opacity: float) -> void:
    c.draw_colored_polygon(PackedVector2Array(vertices), fade(color, opacity))

static func _spark(c: CanvasItem, center: Vector2, radius: float, color: Color, a: float) -> void:
    c.draw_circle(center, radius * 2.3, fade(color, a * 0.13))
    c.draw_circle(center, radius, fade(color, a * 0.57))
    c.draw_circle(center, radius * 0.38, fade(SILVER, a * 0.86))

# Spectral cobra has a discernible tapered tail, S-shaped body, hood,
# articulated jaw, TWO eyes and fangs; it is not a laser/needle.
# progress [0,1] comes from a real V6.3 projectile cue release deadline.
static func cobra(c: CanvasItem, origin: Vector2, destination: Vector2,
        progress: float, zoom: float, opacity: float = 1.0) -> void:
    var k := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.8, 2.3)
    var a := clampf(opacity, 0.0, 0.95)
    var travel := destination - origin
    var length := travel.length()
    if length < 6.0 or a < 0.01:
        return
    var axis := travel / length
    var side := axis.orthogonal()
    # Reveal from the hand, then stretch along actual skill trajectory.
    var head := origin.lerp(destination, k)
    var tail_t := maxf(0.0, k - minf(0.34, 90.0 / length))
    var tail := origin.lerp(destination, tail_t)
    var body_length := head.distance_to(tail)
    if body_length < 3.0:
        _spark(c, origin, (4.0 + 4.0 * k) * z, JADE, a)
        return
    var segments := 16
    var points := PackedVector2Array()
    for i in range(segments + 1):
        var u := float(i) / float(segments)
        var base := tail.lerp(head, u)
        var amp := minf(17.0 * z, body_length * 0.19) * sin(u * PI)
        var wave := sin(u * TAU8 * 1.45 - k * 8.0) * amp
        points.append(base + side * wave)
    for i in range(segments):
        var u := (float(i) + 0.5) / float(segments)
        var width := (2.3 + 7.2 * pow(sin(u * PI), 1.15)) * z
        var p0: Vector2 = points[i]
        var p1: Vector2 = points[i + 1]
        c.draw_line(p0, p1, fade(VENOM_EDGE, a * 0.55), width * 2.7, true)
        c.draw_line(p0, p1, fade(VOID, a * 0.92), width * 1.50, true)
        c.draw_line(p0, p1, fade(VENOM_BODY, a), width, true)
        c.draw_line(p0 - side * width * 0.18, p1 - side * width * 0.18,
            fade(JADE, a * 0.65), width * 0.22, true)
        if i > 2 and i < segments - 2 and i % 2 == 0:
            var scale_point := p0.lerp(p1, 0.5)
            c.draw_line(scale_point - side * width * 0.50, scale_point + side * width * 0.26,
                fade(JADE, a * 0.25), maxf(0.75, z), true)
    # Cobra hood at front remains visibly wider than the neck.
    var h := points[segments]
    var neck := points[segments - 2]
    var jaw := h + axis * 12.0 * z
    _poly(c, [
        neck - side * 5.0 * z, h - side * 11.0 * z,
        jaw - side * 6.5 * z, jaw + axis * 6.5 * z,
        jaw + side * 6.5 * z, h + side * 11.0 * z,
        neck + side * 5.0 * z
    ], VOID, a * 0.98)
    _poly(c, [
        neck - side * 4.2 * z, h - side * 8.0 * z,
        jaw - side * 4.1 * z, jaw + axis * 3.0 * z,
        jaw + side * 4.1 * z, h + side * 8.0 * z,
        neck + side * 4.2 * z
    ], VENOM_BODY, a * 0.96)
    c.draw_line(neck, jaw + axis * 2.0 * z, fade(JADE, a * 0.78), 2.2 * z, true)
    for sign in [-1.0, 1.0]:
        var eye := h + axis * 5.1 * z + side * sign * 4.7 * z
        _spark(c, eye, 1.8 * z, JADE, a)
        var fang := jaw + side * sign * 3.4 * z
        c.draw_line(fang, fang + axis * 4.6 * z + side * sign * 0.6 * z,
            fade(SILVER, a * 0.95), maxf(1.0, 1.2 * z), true)
    c.draw_line(jaw - side * 4.5 * z, jaw + side * 4.5 * z,
        fade(VOID, a), 2.0 * z, true)
    # A few deterministic glints, bounded even during 6x playback.
    for n in range(3):
        var idx := maxi(0, mini(segments, 4 + n * 5))
        _spark(c, points[idx] + side * (n - 1) * 3.0 * z,
            1.4 * z, VIOLET if n % 2 == 0 else JADE, a * 0.65)

static func cobra_impact(c: CanvasItem, center: Vector2,
        t: float, zoom: float) -> void:
    var k := clampf(t, 0.0, 1.0)
    var z := clampf(zoom, 0.8, 2.3)
    var life := 1.0 - k
    var r := (8.0 + k * 28.0) * z
    c.draw_arc(center, r, 0.0, TAU8, 28, fade(JADE, 0.50 * life), 2.4 * z, true)
    c.draw_arc(center, r * 0.72, k * 2.0, k * 2.0 + TAU8 * 0.78,
        24, fade(VIOLET, 0.66 * life), 3.5 * z, true)
    for i in range(7):
        var theta := float(i) * TAU8 / 7.0 + k * 0.4
        var vec := Vector2.from_angle(theta)
        var p := center + vec * r * 0.7
        _spark(c, p, (2.8 - k * 1.3) * z,
            JADE if i % 2 == 0 else VIOLET, life * 0.85)

# A full jian: metal blade, bevel, guard and wrapped hilt. Distinct blades
# keep formation readable; flight trails never replace the weapon shape.
static func jian(c: CanvasItem, center: Vector2,
        angle: float, scale_factor: float, opacity: float = 1.0) -> void:
    var z := clampf(scale_factor, 0.45, 2.6)
    var a := clampf(opacity, 0.0, 1.0)
    var f := Vector2.from_angle(angle)
    var s := f.orthogonal()
    var tip := center + f * 33.0 * z
    var base := center - f * 11.0 * z
    var guard := center - f * 12.0 * z
    var pommel := center - f * 27.0 * z
    _poly(c, [base - s * 5.0 * z, tip, base + s * 5.0 * z],
        Color("1f455a"), a)
    _poly(c, [base, tip, base - s * 3.2 * z], SILVER, a * 0.96)
    _poly(c, [base, tip, base + s * 3.2 * z], CYAN, a * 0.82)
    c.draw_line(base, tip, fade(SILVER, a * 0.88), maxf(0.75, z), true)
    c.draw_line(guard - s * 9.0 * z, guard + s * 9.0 * z,
        fade(VOID, a), 4.0 * z, true)
    c.draw_line(guard - s * 8.0 * z, guard + s * 8.0 * z,
        fade(SILVER, a), 2.1 * z, true)
    c.draw_line(guard - f * 1.3 * z, pommel,
        fade(VOID, a), 4.8 * z, true)
    c.draw_line(guard - f * 1.3 * z, pommel,
        fade(STEEL, a), 2.7 * z, true)
    _spark(c, pommel, 2.5 * z, CYAN, a * 0.80)

# Pure lab-preview timeline. Not callable to select targets or settle HP.
static func sword_array(c: CanvasItem, caster: Vector2, target: Vector2,
        time01: float, zoom: float, sword_count: int = 12) -> void:
    var t := clampf(time01, 0.0, 1.0)
    var z := clampf(zoom, 0.65, 2.1)
    var count := clampi(sword_count, 6, 16)
    if t < 0.31:
        var charge := clampf(t / 0.31, 0.0, 1.0)
        c.draw_arc(caster, 43.0 * z * (0.75 + 0.25 * charge),
            0.0, TAU8, 48, fade(CYAN, 0.25 + 0.40 * charge), 2.0 * z, true)
    for i in range(count):
        var a := TAU8 * float(i) / float(count)
        var ring := caster + Vector2(cos(a), sin(a) * 0.48) * 58.0 * z
        var dest := target + Vector2(cos(a), sin(a) * 0.50) * 47.0 * z
        var position := ring
        var facing := a + PI * 0.5
        var opacity := 1.0
        if t < 0.30:
            opacity = clampf((t * 8.0) - float(i % 4) * 0.10, 0.0, 1.0)
        elif t < 0.45:
            var turn := (t - 0.30) / 0.15
            facing = facing + turn * PI
        elif t < 0.79:
            var flight := clampf((t - 0.45) / 0.34 - float(i % 3) * 0.05, 0.0, 1.0)
            flight = flight * flight * (3.0 - 2.0 * flight)
            position = ring.lerp(dest, flight)
            facing = (dest - ring).angle()
            var trail := position - Vector2.from_angle(facing) * 24.0 * z
            c.draw_line(trail, position, fade(CYAN, 0.40), 1.9 * z, true)
        else:
            position = dest
            facing = (dest - ring).angle()
            opacity = clampf((1.0 - t) / 0.21, 0.0, 1.0)
        jian(c, position, facing, z * 0.78, opacity)
    if t >= 0.72:
        var p := clampf((t - 0.72) / 0.28, 0.0, 1.0)
        c.draw_arc(target, (18.0 + p * 57.0) * z, 0.0, TAU8,
            36, fade(CYAN, (1.0 - p) * 0.64), 2.5 * z, true)
