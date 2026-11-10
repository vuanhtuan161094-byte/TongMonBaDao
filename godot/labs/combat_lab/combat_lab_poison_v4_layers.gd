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

static func lotus(canvas: CanvasItem, p: Vector2, radius: float, c: Color, opacity: float, t: float) -> void:
    ring(canvas, p, radius * 0.60, c, opacity * 0.68, t * 0.25)
    for i in range(6):
        var vec := Vector2.from_angle(float(i) * TAU4 / 6.0 + t * 0.2)
        line(canvas, p, p + vec * radius, c, opacity * 0.6, 1.0)
        spark(canvas, p + vec * (radius * 0.8), GOLD, opacity * 0.8, 1.5)
    spark(canvas, p, c, opacity, radius * 0.2)

static func serpent(canvas: CanvasItem, p: Vector2, q: Vector2, c: Color, opacity: float, z: float, t: float) -> void:
    var d := (q - p).normalized()
    if d.length_squared() < 0.01: d = Vector2.RIGHT
    var n := d.orthogonal()
    var previous := p
    for i in range(1, 10):
        var ratio := float(i) / 9.0
        var to := p.lerp(q, ratio) + n * sin(ratio * TAU4 * 2.0 - t * 8.0) * z * 4.0 * (1.0 - ratio * 0.35)
        line(canvas, previous, to, c, opacity * (0.65 + 0.30 * ratio), maxf(0.8, z * 1.2))
        previous = to
    spark(canvas, q, GOLD, opacity, z * 2.3)

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
    var p := target + Vector2(0.0, -17.0 * z)
    var d := (target - source).normalized()
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
            var center := p - Vector2(0, 13.0 * z)
            ring(canvas, center, (9.0 + pulse * 10.0) * z, c, maxf(0.15, pulse) * 0.75, k)
            if branch == "doc_cham":
                for i in range(3):
                    var shift := Vector2(float(i - 1) * 8.0, -float(i % 2) * 4.0) * z
                    line(canvas, center + shift - Vector2(9, -4) * z,
                        center + shift + Vector2(9, -4) * z, c, maxf(0.15, pulse), 1.5 * z)
            elif branch == "co_doc":
                serpent(canvas, center - Vector2(20, 5) * z, center + Vector2(18, -7) * z, c, pulse, z, k)
            else:
                lotus(canvas, center, 19.0 * z, c, maxf(0.15, pulse), k)
            debris(canvas, center, 15.0 * z, c, pulse, k)
        "projectile":
            var head := source.lerp(target, k)
            var tail := head - d * (22.0 * z)
            if branch == "doc_cham":
                for i in range(3):
                    var n := d.orthogonal() * float(i - 1) * 4.0 * z
                    line(canvas, tail + n, head + n, c, 0.9, 1.4 * z)
            elif branch == "co_doc":
                serpent(canvas, tail, head, c, 0.9, z, k)
            else:
                lotus(canvas, head, 12.0 * z, c, 0.84, k)
            debris(canvas, head - d * (8.0 * z), 9.0 * z, c, 0.5, k)
        "impact":
            if branch == "doc_cham":
                for i in range(8):
                    var ray := Vector2.from_angle(float(i) * TAU4 / 8.0)
                    line(canvas, p + ray * (3.0 * z), p + ray * (12.0 + 16.0 * k) * z, c, pulse, 1.0 * z)
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
