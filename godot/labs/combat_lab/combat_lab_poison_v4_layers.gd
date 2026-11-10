class_name CombatLabPoisonV4Layers
extends RefCounted

# Render-only V4, selected by an explicit Lab opt-in. Never writes battle state.
const TAU4 := PI * 2.0
const LIGHT := Color("effff5")
const GOLD := Color("ffdb82")

static func school(skill_id: String) -> String:
    if ".co_doc." in skill_id: return "co_doc"
    if ".duoc_doc." in skill_id: return "duoc_doc"
    return "doc_cham"

static func tint(branch: String) -> Color:
    match branch:
        "co_doc": return Color("b5ec62")
        "duoc_doc": return Color("65f3cd")
    return Color("a28bff")

static func a(c: Color, opacity: float) -> Color:
    return Color(c.r, c.g, c.b, clampf(opacity, 0.0, 0.95))

static func line(canvas: CanvasItem, p: Vector2, q: Vector2, c: Color, opacity: float, width: float = 2.0) -> void:
    canvas.draw_line(p, q, a(c, opacity * 0.14), width + 9.0, true)
    canvas.draw_line(p, q, a(c, opacity * 0.48), width + 3.0, true)
    canvas.draw_line(p, q, a(LIGHT, opacity), width, true)

static func spark(canvas: CanvasItem, p: Vector2, c: Color, opacity: float, size: float = 2.0) -> void:
    if opacity < 0.002: return
    canvas.draw_circle(p, size * 2.3, a(c, opacity * 0.12))
    canvas.draw_circle(p, size * 1.2, a(c, opacity * 0.43))
    canvas.draw_circle(p, size * 0.52, a(LIGHT, opacity))

static func ring(canvas: CanvasItem, p: Vector2, r: float, c: Color, opacity: float, time: float) -> void:
    if r <= 0 or opacity < 0.002: return
    canvas.draw_arc(p, r, time, TAU4 + time, 40, a(c, opacity * 0.18), 7.0, true)
    canvas.draw_arc(p, r, time, TAU4 + time, 40, a(c, opacity * 0.56), 3.0, true)
    canvas.draw_arc(p, r, time, TAU4 + time, 40, a(LIGHT, opacity), 1.2, true)

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
    canvas.draw_colored_polygon(border, a(Color("261336"), opacity * 0.90))
    line(canvas, origin + axis * (length * 0.10), tip, color, opacity * 0.88, maxf(1.1, z * 1.0))
    spark(canvas, tip, LIGHT, opacity, maxf(1.0, 1.2 * z))

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
        canvas.draw_colored_polygon(petal, a(c.darkened(0.56), opacity * 0.91))
        line(canvas, base, tip, GOLD, opacity * 0.68, maxf(0.9, radius * 0.08))
    spark(canvas, center, c, opacity, core_radius)

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
        line(canvas, previous, to, c, opacity * (0.65 + ratio * 0.32),
            maxf(1.3, (2.5 - ratio * 0.9) * z))
        previous = to
    var v := head - d * (4.5 * z)
    canvas.draw_colored_polygon(PackedVector2Array([
        head + d * 3.7 * z, v + n * 3.0 * z, v - n * 3.0 * z
    ]), a(c, opacity * 0.92))
    spark(canvas, head + n * 1.1 * z, GOLD, opacity, maxf(1.0, 0.95 * z))

static func debris(canvas: CanvasItem, p: Vector2, radius: float, c: Color, opacity: float, t: float) -> void:
    for i in range(7):
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
    var z := clampf(zoom, 1.0, 6.0)
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
        ring(canvas, target, area * (0.55 + k * 0.45), c, life * 0.68, k * 0.8)
        ring(canvas, target, area * (0.45 + k * 0.2), GOLD, life * 0.35, -k * 0.6)
        debris(canvas, target, area * 0.6, c, life, k)
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
            debris(canvas, head - d * (8.0 * z), 7.0 * z, c, 0.36, k)
        "impact":
            if branch == "doc_cham":
                for i in range(8):
                    var ray := Vector2.from_angle(float(i) * TAU4 / 8.0)
                    needle(canvas, p + ray * (3.0 * z), p + ray * (12.0 + 16.0 * k) * z, c, pulse, z * 0.74)
            elif branch == "co_doc":
                ring(canvas, p, (9.0 + 18.0 * k) * z, c, pulse, k)
                serpent(canvas, p - Vector2(18, 5) * z, p + Vector2(12, -4) * z, c, pulse, z, k)
            else:
                lotus(canvas, p, (15.0 + 12.0 * k) * z, c, pulse, k)
            debris(canvas, p, 16.0 * z, c, pulse, k)
        "poison", "poison_apply", "poison_tick":
            debris(canvas, p - Vector2(0, k * 7.0 * z), 9.0 * z, c, life * 0.65, k)
            if kind != "poison_tick": ring(canvas, p, 8.0 * z, c, life * 0.44, k)
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
