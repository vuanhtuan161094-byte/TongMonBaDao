class_name CombatLabVfxV2
extends RefCounted

# The Lab VFX is deterministic presentation based on committed combat events.
# NEVER calls CombatStatsV2/MapBattleV2 damage setters. Render-only primitives.
const MAX_PARTICLES_PER_CUE := 12

static func school_color(school: String) -> Color:
    match school:
        "bow": return Color("ffce75")
        "fist": return Color("ff9f69")
        "poison": return Color("9af3be")
        "boss": return Color("ff4f76")
    return Color("cdbbea")

static func _streak(canvas: CanvasItem, start: Vector2, finish: Vector2,
        color: Color, width: float) -> void:
    canvas.draw_line(start, finish, color.darkened(0.38), width + 3.0, true)
    canvas.draw_line(start, finish, color, width, true)

static func _diamond(canvas: CanvasItem, p: Vector2, radius: float, color: Color) -> void:
    canvas.draw_colored_polygon(PackedVector2Array([
        p + Vector2(0, -radius), p + Vector2(radius * 0.68, 0),
        p + Vector2(0, radius), p + Vector2(-radius * 0.68, 0)
    ]), color)

static func _hex(canvas: CanvasItem, p: Vector2, radius: float, color: Color, phase: float) -> void:
    for i in range(6):
        var a0 := phase + float(i) * TAU / 6.0
        var a1 := phase + float(i + 1) * TAU / 6.0
        canvas.draw_line(p + Vector2.from_angle(a0) * radius,
            p + Vector2.from_angle(a1) * radius, color, 2.0, true)

# Interpolation must reach 100% precisely at the authoritative impact time.
# No acceleration that makes the arrow visually strike before combat settles.
static func projectile_progress(t: float) -> float:
    return clampf(t, 0.0, 1.0)

static func render(canvas: CanvasItem, cue: Dictionary, p: Vector2, source: Vector2,
        t: float, radius_px: float, zoom: float) -> void:
    var kind := str(cue.get("kind", ""))
    var school := str(cue.get("school", ""))
    var c: Color = cue.get("color", school_color(school))
    var alpha := clampf(1.0 - t, 0.0, 1.0)
    c.a *= alpha
    var base := school_color(school)
    base.a *= alpha
    var zoom_factor := clampf(zoom, 1.0, 6.0)
    var generation := str(cue.get("generation", "human"))
    var radius := clampf(radius_px, 0.0, 1600.0)
    match kind:
        "projectile":
            var traveled := projectile_progress(t)
            var head := source.lerp(p, traveled)
            var direction := (p - source).normalized()
            if direction.length_squared() <= 0.01: direction = Vector2.RIGHT
            var tail := head - direction * minf(22.0 * zoom_factor, 48.0)
            if school == "bow":
                _streak(canvas, tail, head, base, 2.6 * zoom_factor)
                _diamond(canvas, head, 6.0 * zoom_factor, base)
                for index in range(3):
                    var behind := head - direction * (8 + index * 7) * zoom_factor
                    canvas.draw_circle(behind, (2.8 - index * 0.65) * zoom_factor, base)
            elif school == "poison":
                _streak(canvas, tail, head, Color(c.r * 0.75, c.g, c.b * 0.7, c.a), 2.2 * zoom_factor)
                for index in range(5):
                    var residue := head - direction * float(index * 5) * zoom_factor
                    residue += direction.orthogonal() * sin(t * 17.0 + index * 2.0) * 4.0 * zoom_factor
                    canvas.draw_circle(residue, (2.6 + index * 0.45) * zoom_factor,
                        Color(c.r * 0.70, c.g, c.b, c.a * (1.0 - index * 0.10)))
            else:
                _streak(canvas, tail, head, base, 5.0 * zoom_factor)
                _hex(canvas, head, 6.0 * zoom_factor, c, t * TAU)
        "telegraph":
            # Uses exactly the Boss center and radius present in source events.
            var r := maxf(6.0, radius) * (0.88 + 0.12 * t)
            canvas.draw_circle(p, r, Color(c.r, c.g, c.b, 0.07 * alpha))
            canvas.draw_arc(p, r, 0, TAU, 56, c, 3.3 * zoom_factor, true)
            canvas.draw_arc(p, r * 0.77, t * TAU, t * TAU + TAU * 0.85, 48, c, 1.2 * zoom_factor, true)
            for i in range(8):
                var ang := TAU * float(i) / 8.0
                var outer := p + Vector2.from_angle(ang) * r
                _diamond(canvas, outer, 3.5 * zoom_factor, c)
                canvas.draw_line(p + Vector2.from_angle(ang) * r * 0.90, outer,
                    c, 2.0 * zoom_factor, true)
        "aoe", "area_burst":
            var ra := maxf(12.0 * zoom_factor, radius)
            if kind == "area_burst": ra = (14.0 + t * 26.0) * zoom_factor
            canvas.draw_arc(p, ra * (0.76 + t * 0.24), 0.1 + t, TAU + t,
                36, c, 3.0 * zoom_factor, true)
            for i in range(8):
                var ang := float(i) * TAU / 8.0 + t * 2.3
                _streak(canvas, p + Vector2.from_angle(ang) * ra * 0.55,
                    p + Vector2.from_angle(ang) * ra * 0.85, base, 1.6 * zoom_factor)
        "impact":
            if school == "fist":
                # Impact crack + outward kinematic shock; not a generic circle.
                var spread := (9.0 + 20.0 * t) * zoom_factor
                for i in range(7):
                    var ang := TAU * float(i) / 7.0 + 0.2
                    var ray := Vector2.from_angle(ang)
                    _streak(canvas, p + ray * spread * 0.20,
                        p + ray * spread * (0.83 + float(i % 3) * 0.08), base, 3.0 * zoom_factor)
                    _diamond(canvas, p + ray * spread, 2.6 * zoom_factor, c)
                canvas.draw_arc(p, spread * 0.7, 0.0, TAU, 32, c, 3.0 * zoom_factor, true)
            elif school == "poison":
                for i in range(8):
                    var a := TAU * float(i) / 8.0 + t * 3.4
                    var q := p + Vector2.from_angle(a) * (7.0 + 14.0 * t) * zoom_factor
                    canvas.draw_circle(q, maxf(1.0, (3.3 - 1.7 * t)) * zoom_factor, base)
                _hex(canvas, p, (9.0 + 10.0 * t) * zoom_factor, c, t * 1.1)
            else:
                for i in range(6):
                    var a := TAU * float(i) / 6.0 - 0.4
                    var ray := Vector2.from_angle(a)
                    _streak(canvas, p + ray * 3.0 * zoom_factor,
                        p + ray * (14.0 + 17.0 * t) * zoom_factor, base, 1.8 * zoom_factor)
                _diamond(canvas, p, (7.0 + 4.0 * t) * zoom_factor, c)
        "cast":
            # Different magical silhouettes, not the same ring recolored.
            # All art is read-only and bounded to at most eight accents.
            var ring := (8.0 + 8.0 * t) * zoom_factor
            if school == "bow":
                # Converging arrowheads and a drawn golden moon-bow.
                var arc_origin := p + Vector2(6.0, -2.0) * zoom_factor
                canvas.draw_arc(arc_origin, ring, -1.10, 1.10, 26, base, 2.6 * zoom_factor, true)
                _streak(canvas, arc_origin + Vector2(-5.0, -ring * 0.85),
                    arc_origin + Vector2(-5.0, ring * 0.85), c, 1.3 * zoom_factor)
                for i in range(3):
                    var trail := float(i) * 5.5 * zoom_factor
                    _diamond(canvas, p + Vector2((9.0 + t * 8.0) * zoom_factor - trail,
                        (-6.0 + float(i) * 6.0) * zoom_factor),
                        (2.5 + t * 1.2) * zoom_factor, base)
            elif school == "fist":
                # Stone-like impact sigil with four approaching shock plates.
                _hex(canvas, p, ring, base, PI / 6.0)
                for i in range(4):
                    var a := float(i) * TAU / 4.0 + PI / 4.0
                    var edge := p + Vector2.from_angle(a) * ring
                    var inward := p + Vector2.from_angle(a) * ring * 0.55
                    _streak(canvas, edge, inward, c, 3.4 * zoom_factor)
                    _diamond(canvas, edge, 3.0 * zoom_factor, base)
            elif school == "poison":
                # Two counter-rotating venom spirals and droplet seeds.
                for i in range(8):
                    var a := float(i) * TAU / 8.0 + t * 3.0
                    var radial := (ring * 0.45 + 4.5 * float(i % 3) * zoom_factor)
                    var drop := p + Vector2.from_angle(a) * radial
                    canvas.draw_circle(drop, (1.8 + float(i % 3) * 0.6) * zoom_factor,
                        base if i % 2 == 0 else c)
                _hex(canvas, p, ring * 0.55, c, -t * TAU)
            else:
                _hex(canvas, p, ring, base, t * TAU * 0.65)
        "guard":
            var shield_radius := (14.0 + 3.5 * sin(t * PI)) * zoom_factor
            _hex(canvas, p + Vector2(0, -13 * zoom_factor), shield_radius, base, 0.0)
            _hex(canvas, p + Vector2(0, -13 * zoom_factor), shield_radius * 0.74, c, PI / 6.0)
            _diamond(canvas, p + Vector2(0, -13 * zoom_factor), 5 * zoom_factor, base)
        "poison":
            for i in range(8):
                var a := TAU * float(i) / 8.0 + t * 2.4
                var outward := (5.0 + 8.0 * t) * zoom_factor
                var q := p + Vector2.from_angle(a) * outward + Vector2(0, -t * 18.0 * zoom_factor)
                canvas.draw_circle(q, (2.2 + (i % 3)) * zoom_factor, c)
            canvas.draw_arc(p, (8.0 + 6.0 * t) * zoom_factor, 0.0, TAU, 20, base, 1.5 * zoom_factor, true)
        "heal":
            for i in range(4):
                var a := TAU * float(i) / 4.0 + t * 2.0
                var q := p + Vector2.from_angle(a) * 11.0 * zoom_factor
                q.y -= t * 21.0 * zoom_factor
                _diamond(canvas, q, 3.5 * zoom_factor, c)
            canvas.draw_line(p + Vector2(-6, -7) * zoom_factor,
                p + Vector2(6, -7) * zoom_factor, c, 3.0 * zoom_factor, true)
            canvas.draw_line(p + Vector2(0, -13) * zoom_factor,
                p + Vector2(0, -1) * zoom_factor, c, 3.0 * zoom_factor, true)
        "cleanse":
            var r := (7.0 + 15.0 * t) * zoom_factor
            for i in range(8):
                var a := TAU * float(i) / 8.0
                _diamond(canvas, p + Vector2.from_angle(a) * r, 3.0 * zoom_factor, c)
            canvas.draw_arc(p, r * 0.75, 0, TAU, 40, c, 2.0 * zoom_factor, true)
        "mark":
            _hex(canvas, p + Vector2(0, -23 * zoom_factor),
                (8.0 + sin(t * PI) * 3.0) * zoom_factor, c, PI / 6.0)
            _diamond(canvas, p + Vector2(0, -23 * zoom_factor), 4.0 * zoom_factor, base)
        "mobility":
            for i in range(4):
                var start := source.lerp(p, float(i) * 0.23)
                var finish := source.lerp(p, 0.38 + float(i) * 0.19)
                _streak(canvas, start, finish, base, maxf(1.0, 3.0 - i * 0.5) * zoom_factor)
        "miss":
            var ra := (8.0 + 14.0 * t) * zoom_factor
            canvas.draw_arc(p, ra, PI / 4.0, PI * 1.75, 22, c, 2.0 * zoom_factor, true)
        "death":
            for i in range(10):
                var a := TAU * float(i) / 10.0
                var ray := Vector2.from_angle(a)
                _diamond(canvas, p + ray * (5 + 19 * t) * zoom_factor, 3.0 * zoom_factor, c)
        "boss_phase":
            _hex(canvas, p, (21.0 + 12.0 * t) * zoom_factor, c, t * TAU)
            _hex(canvas, p, (14.0 + 8.0 * t) * zoom_factor, c, -t * TAU)
        "blood_frenzy":
            for i in range(6):
                var a := float(i) * TAU / 6.0 + t * TAU
                _diamond(canvas, p + Vector2.from_angle(a) * (8.0 + 12.0 * t) * zoom_factor,
                    4.0 * zoom_factor, c)
        _:
            return

    # Successor-generation art layer only: no changes to hits, timers or
    # simulation. Human -> Immortal -> Divine gains visibly distinct runework.
    if generation in ["immortal", "divine"] and kind in ["cast", "impact", "guard", "aoe", "area_burst"]:
        var sigil_radius := (13.0 + 8.0 * t) * zoom_factor
        _hex(canvas, p, sigil_radius, base, -t * TAU * 0.35)
        if generation == "divine":
            var divine_glow := base.lightened(0.30)
            divine_glow.a *= 0.68
            for i in range(5):
                var angle := float(i) * TAU / 5.0 + t * 0.7
                _diamond(canvas, p + Vector2.from_angle(angle) * sigil_radius * 1.35,
                    (2.0 + 1.5 * (1.0 - t)) * zoom_factor, divine_glow)
