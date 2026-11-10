class_name CombatLabPoisonV4Layers
extends RefCounted

# Render-only V4, selected by an explicit Lab opt-in. Never writes battle state.
const TAU4 := PI * 2.0
# Dark-fantasy palette: saturated silhouettes first, restrained light accents.
# Every effect is limited to a few bounded CanvasItem draws (Android GL compatibility).
const LIGHT := Color("e7f8d1")
const GOLD := Color("edc979")
const NEEDLE_DARK := Color("24163f")
const GU_DARK := Color("24351c")
const JADE_DARK := Color("143e3d")

static func school(skill_id: String) -> String:
    if ".co_doc." in skill_id: return "co_doc"
    if ".duoc_doc." in skill_id: return "duoc_doc"
    return "doc_cham"

static func tint(branch: String) -> Color:
    match branch:
        "co_doc": return Color("9acd32")
        "duoc_doc": return Color("63e6be")
    return Color("7a5cff")

static func a(c: Color, opacity: float) -> Color:
    return Color(c.r, c.g, c.b, clampf(opacity, 0.0, 0.95))

static func line(canvas: CanvasItem, p: Vector2, q: Vector2, c: Color, opacity: float, width: float = 2.0) -> void:
    # One dark edge and a crisp colored blade; no large white glow over actors.
    if opacity <= 0.001: return
    canvas.draw_line(p, q, a(c.darkened(0.78), opacity * 0.88), width + 2.8, true)
    canvas.draw_line(p, q, a(c, opacity * 0.82), width, true)
    canvas.draw_line(p, q, a(LIGHT, opacity * 0.24), maxf(0.65, width * 0.36), true)

static func spark(canvas: CanvasItem, p: Vector2, c: Color, opacity: float, size: float = 2.0) -> void:
    if opacity < 0.002: return
    canvas.draw_circle(p, size * 1.55, a(c.darkened(0.65), opacity * 0.40))
    canvas.draw_circle(p, size * 0.8, a(c, opacity * 0.85))
    canvas.draw_circle(p, size * 0.32, a(LIGHT, opacity * 0.54))

# Original, bounded 2D spell glints: soft colored aura + sharp star core.
# Deterministic phase (no RNG) so Movie Maker and 24 Hz gameplay agree.
static func glint(canvas: CanvasItem, p: Vector2, c: Color, opacity: float, radius: float, phase: float) -> void:
    if opacity <= 0.005: return
    var r := maxf(1.0, radius)
    canvas.draw_circle(p, r * 2.15, a(c, opacity * 0.075))
    canvas.draw_circle(p, r * 1.25, a(c, opacity * 0.20))
    canvas.draw_circle(p, r * 0.58, a(LIGHT, opacity * 0.78))
    var axis := Vector2.from_angle(phase)
    var wing := axis.orthogonal()
    canvas.draw_line(p - axis * r * 1.75, p + axis * r * 1.75,
        a(LIGHT, opacity * 0.45), maxf(0.7, r * 0.12), true)
    canvas.draw_line(p - wing * r * 1.05, p + wing * r * 1.05,
        a(c, opacity * 0.63), maxf(0.7, r * 0.14), true)

static func ring(canvas: CanvasItem, p: Vector2, r: float, c: Color, opacity: float, time: float) -> void:
    if r <= 0 or opacity < 0.002: return
    # Broken rune perimeter instead of three bright concentric rings.
    for i in range(6):
        var begin := time + float(i) * TAU4 / 6.0
        canvas.draw_arc(p, r, begin, begin + TAU4 / 9.0, 6,
            a(c.darkened(0.32), opacity * 0.62), 2.2, true)
        canvas.draw_arc(p, r, begin + 0.05, begin + TAU4 / 10.0, 5,
            a(c, opacity * 0.75), 1.0, true)

# Solid silhouette: translucent beams alone vanish at real 1x gameplay size.
static func needle(canvas: CanvasItem, origin: Vector2, tip: Vector2,
        color: Color, opacity: float, z: float) -> void:
    var axis := (tip - origin).normalized()
    if axis.length_squared() < 0.001: axis = Vector2.RIGHT
    var n := axis.orthogonal()
    var length := maxf(5.0, origin.distance_to(tip))
    var hilt := origin + axis * (length * 0.48)
    var width := maxf(1.8, 2.3 * z)
    var border := PackedVector2Array([
        origin + n * width, hilt + n * width * 1.25, tip,
        hilt - n * width * 1.25, origin - n * width
    ])
    canvas.draw_colored_polygon(border, a(NEEDLE_DARK, opacity * 0.94))
    # Violet metal spine with a thin toxic jade bevel, not a laser.
    canvas.draw_line(origin + axis * (length * 0.12), tip, a(color, opacity * 0.92),
        maxf(1.0, 1.18 * z), true)
    canvas.draw_line(hilt + n * width * 0.22, tip, a(Color("a7f28a"), opacity * 0.48),
        maxf(0.6, z * 0.42), true)

static func lotus(canvas: CanvasItem, center: Vector2, radius: float, c: Color, opacity: float, t: float) -> void:
    # Six jade petals with dark roots and gold inner edges, not a hexagon.
    var core_radius := maxf(2.0, radius * 0.22)
    for i in range(6):
        var angle := float(i) * TAU4 / 6.0 + t * 0.16
        var axis := Vector2.from_angle(angle)
        var n := axis.orthogonal()
        var base := center + axis * (radius * 0.13)
        var tip := center + axis * radius
        var wide := radius * 0.33
        var petal := PackedVector2Array([base, center + axis * radius * 0.62 + n * wide,
            tip, center + axis * radius * 0.62 - n * wide])
        canvas.draw_colored_polygon(petal, a(JADE_DARK, opacity * 0.90))
        var inner := PackedVector2Array([base, center + axis * radius * 0.61 + n * wide * 0.58,
            center + axis * radius * 0.91, center + axis * radius * 0.61 - n * wide * 0.58])
        canvas.draw_colored_polygon(inner, a(c, opacity * 0.64))
        canvas.draw_line(base, tip, a(GOLD, opacity * 0.45), maxf(0.65, radius * 0.035), true)
    spark(canvas, center, c, opacity, core_radius * 0.72)

static func serpent(canvas: CanvasItem, start: Vector2, head: Vector2, c: Color,
        opacity: float, z: float, t: float) -> void:
    # A tapering luminous body and pointed head keep Cổ Độc recognizable.
    var d := (head - start).normalized()
    if d.length_squared() < 0.001: d = Vector2.RIGHT
    var n := d.orthogonal()
    var previous := start
    for i in range(1, 10):
        var ratio := float(i) / 9.0
        var to := start.lerp(head, ratio) + n * sin(ratio * TAU4 * 1.4 - t * 8.0) * z * 3.5 * (1.0 - ratio)
        canvas.draw_line(previous, to, a(GU_DARK, opacity * 0.92),
            maxf(1.6, (4.1 - ratio * 1.4) * z), true)
        canvas.draw_line(previous, to, a(c, opacity * (0.55 + ratio * 0.30)),
            maxf(0.85, (2.5 - ratio * 0.9) * z), true)
        previous = to
    var v := head - d * (4.5 * z)
    canvas.draw_colored_polygon(PackedVector2Array([
        head + d * 4.6 * z, v + n * 3.5 * z, v - n * 3.5 * z
    ]), a(GU_DARK, opacity * 0.98))
    canvas.draw_colored_polygon(PackedVector2Array([
        head + d * 3.1 * z, v + n * 2.0 * z, v - n * 2.0 * z
    ]), a(c, opacity * 0.86))
    # Two tiny antique-gold eyes keep the serpent visibly alive at 1x.
    canvas.draw_circle(head - d * 1.6 * z + n * 1.25 * z,
        maxf(0.75, 0.65 * z), a(GOLD, opacity * 0.9))

static func debris(canvas: CanvasItem, p: Vector2, radius: float, c: Color, opacity: float, t: float) -> void:
    for i in range(4):
        var theta := float(i) * 2.39996
        var rr := radius * (0.3 + 0.65 * absf(sin(float(i + 1) * 1.5 + t * 3.0)))
        spark(canvas, p + Vector2(cos(theta + t) * rr, sin(theta) * rr * 0.4 - t * 9.0), c, opacity * 0.68, 1.25)

static func render(canvas: CanvasItem, cue: Dictionary, target: Vector2, source: Vector2, t: float, radius_px: float, zoom: float) -> void:
    var skill_id := str(cue.get("skill_id", cue.get("source_skill_id", "")))
    var branch := school(skill_id)
    var c := tint(branch)
    var kind := str(cue.get("kind", ""))
    var effect := str(cue.get("effect", ""))
    var shape := str(cue.get("shape", ""))
    # Shape size is capped independently from camera zoom to protect 1x-6x readability.
    var z := clampf(zoom, 1.0, 2.4)
    var k := clampf(t, 0.0, 1.0)
    var life := 1.0 - k
    var pulse := sin(k * PI)
    # Feet are the world-space authority. The arena supplies display-only
    # body offsets based on the actual target/caster visual rig, not zoom*z.
    var p := target + Vector2(0.0, float(cue.get("v4_target_body_offset", -25.0 * (0.55 + 0.29 * z))))
    var caster_hand := source + Vector2(0.0, float(cue.get("v4_source_body_offset", -35.0 * (0.55 + 0.29 * z))))
    var d := (p - caster_hand).normalized()
    if d.length_squared() < 0.01: d = Vector2.RIGHT
    if kind in ["venom_cloud", "aoe", "area_burst"] or (shape == "circle" and kind == "skill_release"):
        # No invented radius: only radius_px from authoritative V6.3/event.
        var area := clampf(radius_px, 1.0, 1600.0)
        # The outside edge is exactly the canonical skill radius. It is a
        # warning/feedback boundary only, never the source of a damage hit.
        for i in range(12):
            var begin := float(i) * TAU4 / 12.0
            canvas.draw_arc(target, area, begin, begin + TAU4 / 17.0, 5,
                a(c, life * 0.56), maxf(1.0, z * 0.8), true)
        # Low-opacity petals/motes on the floor; leave monsters visible.
        for i in range(7):
            var ang := float(i) * TAU4 / 7.0 + k * 0.33
            var q := target + Vector2.from_angle(ang) * area * (0.23 + k * 0.27)
            glint(canvas, q, c, life * 0.52, 1.1 * z, ang)
        return
    if kind == "heal" or effect == "heal":
        lotus(canvas, p - Vector2(0, k * 23.0 * z), 20.0 * z, c, life * 0.9, k)
        debris(canvas, p, 16.0 * z, c, life, k)
        return
    if kind == "cleanse" or effect == "cleanse":
        ring(canvas, p, (10.0 + 31.0 * k) * z, GOLD, life * 0.84, k)
        lotus(canvas, p, 14.0 * z, c, life * 0.77, k)
        return
    match kind:
        "cast":
            var center := caster_hand - Vector2(0, 2.0 * z)
            ring(canvas, center, (9.0 + pulse * 10.0) * z, c, maxf(0.15, pulse) * 0.75, k)
            if branch == "doc_cham":
                for i in range(3):
                    var shift := Vector2(float(i - 1) * 8.0, -float(i % 2) * 4.0) * z
                    needle(canvas, center + shift - Vector2(9, -4) * z,
                        center + shift + Vector2(9, -4) * z, c, maxf(0.15, pulse), z)
            elif branch == "co_doc":
                serpent(canvas, center - Vector2(20, 5) * z, center + Vector2(18, -7) * z, c, pulse, z, k)
            else:
                lotus(canvas, center, 19.0 * z, c, maxf(0.15, pulse), k)
            for i in range(3):
                var phi := float(i) * TAU4 / 3.0 + k * 0.65
                glint(canvas, center + Vector2.from_angle(phi) * (13.0 + 7.0 * pulse) * z,
                    c, pulse * 0.62, 1.8 * z, phi)
            debris(canvas, center, 15.0 * z, c, pulse, k)
        "projectile":
            # The projectile endpoint follows its canonical actor ID through
            # the full flight. The impact happens at the V6.3 release deadline.
            var head := caster_hand.lerp(p, k)
            var tail := head - d * (22.0 * z)
            if branch == "doc_cham":
                for i in range(3):
                    var side := d.orthogonal() * float(i - 1) * 3.4 * z
                    needle(canvas, tail + side, head + side, c, 0.94, z)
            elif branch == "co_doc":
                serpent(canvas, tail, head, c, 0.94, z, k)
            else:
                lotus(canvas, head, 11.0 * z, c, 0.90, k)
            # Jewel-like highlights and tapered wakes, never random overdraw.
            for i in range(4):
                var progress := float(i + 1) / 5.0
                var trailing := head - d * (8.0 + float(i) * 5.0) * z
                var jitter := d.orthogonal() * sin(float(i) * 2.3 + k * 9.0) * 2.0 * z
                glint(canvas, trailing + jitter, c, (1.0 - progress) * 0.47,
                    (2.4 - progress) * z, k * 3.0 + float(i))
            glint(canvas, head, c, 0.75, 2.2 * z, d.angle())
            debris(canvas, head - d * (8.0 * z), 7.0 * z, c, 0.36, k)
        "impact":
            if branch == "doc_cham":
                # Five angled punctures read as a stabbing strike, not an explosion.
                for i in range(5):
                    var ray := Vector2.from_angle((-0.55 + float(i) * 0.27) + d.angle())
                    needle(canvas, p - ray * (5.0 * z), p + ray * (10.0 + 7.0 * k) * z,
                        c, pulse * 0.85, z * 0.75)
            elif branch == "co_doc":
                # Bite and coil, not an enlarged generic impact halo.
                serpent(canvas, p - d * 19.0 * z, p + d * 7.0 * z, c, pulse, z, k)
                spark(canvas, p, GOLD, pulse * 0.54, 1.8 * z)
            else:
                lotus(canvas, p, (15.0 + 12.0 * k) * z, c, pulse, k)
            for i in range(5):
                var theta := float(i) * TAU4 / 5.0 + k * 0.35
                var q := p + Vector2.from_angle(theta) * (9.0 + k * 8.0) * z
                glint(canvas, q, c, pulse * 0.60, 1.8 * z, theta)
            glint(canvas, p, GOLD if branch == "co_doc" else c, pulse * 0.82, 3.0 * z, k * 2.4)
            debris(canvas, p, 9.0 * z, c, pulse * 0.55, k)
        "poison", "poison_apply", "poison_tick":
            # DoT tick is deliberately quieter than the original impact.
            debris(canvas, p - Vector2(0, k * 7.0 * z), 6.0 * z, c, life * 0.37, k)
            if kind != "poison_tick": ring(canvas, p, 7.0 * z, c, life * 0.24, k)
        "venom_burst":
            for i in range(4):
                var vector := Vector2.from_angle(float(i) * TAU4 / 4.0)
                serpent(canvas, p + vector * (1.0 - k) * 22.0 * z, p, c, pulse * 0.85, z, k)
            spark(canvas, p, GOLD, pulse, 5.0 * z)
        "mark":
            ring(canvas, p, 15.0 * z, c, life * 0.65, k)
        "guard":
            ring(canvas, p, (14.0 + 7.0 * k) * z, c, life * 0.65, k)
        "mobility":
            debris(canvas, source.lerp(target, 0.5), 17.0 * z, c, life, k)
        _:
            return
