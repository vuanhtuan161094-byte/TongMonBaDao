class_name CombatLabVfxV2
extends RefCounted

# The Lab VFX is deterministic presentation based on committed combat events.
# NEVER calls CombatStatsV2/MapBattleV2 damage setters. Render-only primitives.
const MAX_PARTICLES_PER_CUE := 12
const DOC_CHAM_NEEDLE: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/doc_cham_needle.png")
const CO_DOC_GU_SERPENT: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/co_doc_gu_serpent.png")
const DUOC_DOC_JADE_LOTUS: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/duoc_doc_jade_lotus.png")
const VENOM_SMOKE: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/venom_smoke_corrosion.png")

static func school_color(school: String) -> Color:
    match school:
        "bow": return Color("ffce75")
        "fist": return Color("ff9f69")
        "poison": return Color("9af3be")
        "boss": return Color("ff4f76")
    return Color("cdbbea")

# Branch identities use the canonical V6.3 skill ID. These change visual
# signatures only; they never create poison stacks, ticks or heal events.
static func poison_branch(skill_id: String) -> String:
    if ".co_doc." in skill_id:
        return "co_doc"
    if ".duoc_doc." in skill_id:
        return "duoc_doc"
    return "doc_cham"

static func _poison_tint(branch: String) -> Color:
    match branch:
        "co_doc": return Color("c0ed69")
        "duoc_doc": return Color("8af3db")
    return Color("a68cf4")

static func _tinted(hex_code: String, opacity: float) -> Color:
    var color := Color(hex_code)
    color.a = opacity
    return color

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

static func _draw_art(canvas: CanvasItem, texture: Texture2D, center: Vector2,
        size: Vector2, rotation: float, opacity: float) -> void:
    if texture == null or opacity <= 0.005:
        return
    var safe_size := Vector2(clampf(size.x, 2.0, 640.0), clampf(size.y, 2.0, 480.0))
    canvas.draw_set_transform(center, rotation, Vector2.ONE)
    canvas.draw_texture_rect(texture, Rect2(-safe_size * 0.5, safe_size), false,
        Color(1.0, 1.0, 1.0, clampf(opacity, 0.0, 1.0)))
    canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _render_poison(canvas: CanvasItem, cue: Dictionary, p: Vector2, source: Vector2,
        t: float, radius_px: float, zoom: float) -> void:
    var kind := str(cue.get("kind", ""))
    var skill_id := str(cue.get("skill_id", cue.get("source_skill_id", "")))
    var branch := poison_branch(skill_id)
    var effect := str(cue.get("effect", ""))
    var shape := str(cue.get("shape", ""))
    var target_limit := int(cue.get("target_limit", 0))
    var generation := str(cue.get("generation", "human"))
    var scale := clampf(zoom, 1.0, 4.0)
    var life := clampf(1.0 - t, 0.0, 1.0)
    var pulse := sin(clampf(t, 0.0, 1.0) * PI)
    var direction := (p - source).normalized()
    if direction.length_squared() < 0.001:
        direction = Vector2.RIGHT
    var rotation := direction.angle()
    var branch_texture: Texture2D = DOC_CHAM_NEEDLE
    match branch:
        "co_doc": branch_texture = CO_DOC_GU_SERPENT
        "duoc_doc": branch_texture = DUOC_DOC_JADE_LOTUS

    # AOE uses only the radius supplied from the real skill definition/event.
    # The organic smoke master replaces the former prototype rings and hexes.
    if kind in ["venom_cloud", "aoe", "area_burst"] or (shape == "circle" and kind == "skill_release"):
        var cloud_radius := clampf(radius_px, 18.0 * scale, 360.0)
        var opacity := 0.76 if kind == "venom_cloud" else 0.66
        _draw_art(canvas, VENOM_SMOKE, p + Vector2(0, -9.0 * scale),
            Vector2(cloud_radius * 2.0, cloud_radius * 1.16), 0.0, opacity * maxf(0.28, life))
        _draw_art(canvas, VENOM_SMOKE, p + Vector2(7.0 * scale, 4.0 * scale),
            Vector2(cloud_radius * 1.44, cloud_radius * 0.86), -0.12, opacity * 0.54 * maxf(0.25, life))
        return

    # Effect semantics come from the canonical V6.3 definition and committed
    # event: medicinal skills never receive an attack impact treatment.
    if kind in ["heal", "cleanse"] or effect in ["heal", "cleanse"]:
        var rise := (16.0 + 18.0 * t) * scale
        _draw_art(canvas, DUOC_DOC_JADE_LOTUS, p + Vector2(0, -rise),
            Vector2(70.0 * scale, 53.0 * scale), -0.10 + t * 0.18,
            (0.86 if kind == "heal" else 0.72) * maxf(0.24, life))
        if kind == "cleanse":
            _draw_art(canvas, VENOM_SMOKE, p + Vector2(0, -8.0 * scale),
                Vector2((48.0 + 24.0 * t) * scale, 26.0 * scale), 0.0, 0.34 * pulse)
        return

    match kind:
        "projectile":
            var progress := projectile_progress(t)
            var head := source.lerp(p, progress)
            var traveled_alpha := 0.98 - 0.20 * progress
            var offset := head - direction * 18.0 * scale
            _draw_art(canvas, VENOM_SMOKE, offset,
                Vector2(54.0 * scale, 28.0 * scale), rotation, 0.52 * traveled_alpha)
            var shot_size := Vector2(78.0, 27.0) * scale
            if branch == "co_doc": shot_size = Vector2(58.0, 42.0) * scale
            elif branch == "duoc_doc": shot_size = Vector2(50.0, 39.0) * scale
            if branch == "doc_cham" and target_limit > 1:
                var fan_count := mini(5, target_limit)
                for index in range(fan_count):
                    var fan_offset := float(index) - float(fan_count - 1) * 0.5
                    _draw_art(canvas, branch_texture, head + direction.orthogonal() * fan_offset * 5.0 * scale,
                        shot_size * Vector2(1.0, 0.76), rotation + fan_offset * 0.13,
                        traveled_alpha * 0.70)
            else:
                _draw_art(canvas, branch_texture, head, shot_size,
                    rotation if branch == "doc_cham" else rotation * 0.30,
                    traveled_alpha)
        "cast":
            var cast_center := p + Vector2(0, -25.0 * scale)
            if branch == "doc_cham":
                for index in range(3):
                    var side := float(index - 1)
                    var orbit := Vector2(cos(t * 2.8 + side * 0.42) * 14.0,
                        sin(t * 2.8 + side * 0.42) * 8.0) * scale
                    _draw_art(canvas, DOC_CHAM_NEEDLE, cast_center + orbit,
                        Vector2(48.0, 16.0) * scale, rotation + side * 0.15,
                        (0.72 - absf(side) * 0.12) * maxf(0.3, life))
            elif branch == "co_doc":
                _draw_art(canvas, VENOM_SMOKE, cast_center + Vector2(0, 15.0 * scale),
                    Vector2(60.0, 38.0) * scale, t * 0.28, 0.48 * maxf(0.3, life))
                _draw_art(canvas, CO_DOC_GU_SERPENT, cast_center,
                    Vector2(59.0, 44.0) * scale, -0.12 + t * 0.25,
                    0.88 * maxf(0.35, life))
            else:
                _draw_art(canvas, DUOC_DOC_JADE_LOTUS, cast_center,
                    Vector2(62.0, 47.0) * scale, t * 0.15, 0.82 * maxf(0.32, life))
        "impact":
            var impact_pos := p + Vector2(0, -16.0 * scale)
            _draw_art(canvas, VENOM_SMOKE, impact_pos,
                Vector2((44.0 + 16.0 * pulse) * scale, (25.0 + 8.0 * pulse) * scale),
                rotation, 0.76 * pulse)
            var impact_size := Vector2(43.0, 15.0) * scale
            if branch == "co_doc": impact_size = Vector2(48.0, 36.0) * scale
            elif branch == "duoc_doc": impact_size = Vector2(42.0, 32.0) * scale
            _draw_art(canvas, branch_texture, impact_pos,
                impact_size, rotation if branch == "doc_cham" else -0.18,
                0.78 * pulse)
        "poison", "poison_apply", "poison_tick":
            var status_pos := p + Vector2(0, -19.0 * scale - 8.0 * t * scale)
            var tick_size := Vector2(38.0, 23.0) * scale if kind == "poison_tick" else Vector2(52.0, 32.0) * scale
            _draw_art(canvas, VENOM_SMOKE, status_pos, tick_size,
                sin(t * TAU) * 0.14, 0.72 * maxf(0.28, life))
            if kind != "poison_tick":
                var status_size := Vector2(40.0, 14.0) * scale
                if branch == "co_doc": status_size = Vector2(43.0, 32.0) * scale
                elif branch == "duoc_doc": status_size = Vector2(42.0, 32.0) * scale
                _draw_art(canvas, branch_texture, status_pos,
                    status_size, rotation if branch == "doc_cham" else t * 0.20,
                    0.60 * maxf(0.25, life))
        "venom_burst":
            var inward := lerpf(43.0, 5.0, t) * scale
            _draw_art(canvas, VENOM_SMOKE, p,
                Vector2(66.0, 42.0) * scale, t * 0.30, 0.46 * pulse)
            _draw_art(canvas, CO_DOC_GU_SERPENT, p + Vector2(inward, -inward * 0.22),
                Vector2(60.0 - 20.0 * t, 44.0 - 14.0 * t) * scale,
                lerpf(-0.30, 0.0, t), 0.88 * pulse)
            _draw_art(canvas, CO_DOC_GU_SERPENT, p + Vector2(-inward, inward * 0.18),
                Vector2(46.0 - 14.0 * t, 35.0 - 10.0 * t) * scale,
                lerpf(0.35, 0.0, t), 0.58 * pulse)
        "mark":
            var mark_texture := CO_DOC_GU_SERPENT if branch == "co_doc" else branch_texture
            _draw_art(canvas, mark_texture, p + Vector2(0, -27.0 * scale),
                Vector2(48.0, 36.0) * scale, sin(t * TAU) * 0.08,
                0.82 * maxf(0.30, life))
        "guard":
            _draw_art(canvas, branch_texture, p + Vector2(0, -18.0 * scale),
                Vector2(49.0, 37.0) * scale, sin(t * PI) * 0.1,
                0.72 * maxf(0.28, life))
        "mobility":
            _draw_art(canvas, VENOM_SMOKE, source.lerp(p, 0.5),
                Vector2(70.0, 32.0) * scale, rotation,
                0.60 * maxf(0.25, life))
        _:
            return

    # Immortal/divine accents reuse the same approved masters; these are
    # cosmetic layers, not separate claimed animations or combat behavior.
    if generation in ["immortal", "divine"] and kind in ["cast", "impact", "venom_burst"]:
        var accent_texture := CO_DOC_GU_SERPENT if branch == "co_doc" else DUOC_DOC_JADE_LOTUS
        var accent_alpha := 0.22 if generation == "immortal" else 0.34
        _draw_art(canvas, accent_texture, p + Vector2(0, -32.0 * scale),
            Vector2(34.0, 26.0) * scale, -t * 0.2, accent_alpha * pulse)

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
    var branch := poison_branch(str(cue.get("skill_id", cue.get("source_skill_id", ""))))
    var venom := _poison_tint(branch)
    venom.a *= alpha
    var radius := clampf(radius_px, 0.0, 1600.0)
    if school == "poison":
        _render_poison(canvas, cue, p, source, t, radius, zoom_factor)
        return
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
                match branch:
                    "doc_cham":
                        # Three clearly legible dark-purple poisoned needles.
                        _streak(canvas, head - direction * (25.0 * zoom_factor), head, venom, 2.0 * zoom_factor)
                        _diamond(canvas, head + direction * 4.0 * zoom_factor, 5.0 * zoom_factor, venom)
                        for i in range(3):
                            var tip_offset := direction.orthogonal() * float(i - 1) * 3.1 * zoom_factor
                            _streak(canvas, head - direction * (13.0 + float(i) * 3.0) * zoom_factor + tip_offset,
                                head - direction * 2.0 * zoom_factor + tip_offset, _tinted("d1f5ad", venom.a), 1.1 * zoom_factor)
                    "co_doc":
                        # Coiling gu-serpent silhouette: two sinusoidal venom strands.
                        for i in range(7):
                            var distance := float(i) * 3.0 * zoom_factor
                            var center := head - direction * distance
                            var sway := direction.orthogonal() * sin(float(i) * 1.15 - t * 13.0) * 4.2 * zoom_factor
                            canvas.draw_circle(center + sway, maxf(1.0, (3.6 - i * 0.35)) * zoom_factor, venom)
                        _diamond(canvas, head, 5.5 * zoom_factor, _tinted("edfbac", venom.a))
                    "duoc_doc":
                        # Medicine-seal projectile: center bead and four herbal petals.
                        canvas.draw_circle(head, 5.0 * zoom_factor, venom)
                        for i in range(4):
                            var a := TAU * float(i) / 4.0 + t * 2.5
                            _diamond(canvas, head + Vector2.from_angle(a) * 7.0 * zoom_factor,
                                2.5 * zoom_factor, _tinted("d9f8bd", venom.a))
                        _streak(canvas, tail, head, venom, 1.6 * zoom_factor)
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
                # Impact style follows the cast branch but carries no damage.
                var burst := (7.0 + 17.0 * t) * zoom_factor
                for i in range(6):
                    var ang := TAU * float(i) / 6.0 + t * (3.0 if branch == "co_doc" else 0.6)
                    var q := p + Vector2.from_angle(ang) * burst
                    if branch == "doc_cham":
                        _streak(canvas, p + Vector2.from_angle(ang) * burst * 0.35,
                            q, venom, 1.5 * zoom_factor)
                    elif branch == "co_doc":
                        canvas.draw_circle(q, (2.6 + float(i % 2)) * zoom_factor, venom)
                    else:
                        _diamond(canvas, q, 3.2 * zoom_factor, venom)
                _hex(canvas, p, (8.0 + 11.0 * t) * zoom_factor, venom, -t * TAU)
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
                # Distinct posture read: hovering needles, gu-bugs, herbal vial.
                match branch:
                    "doc_cham":
                        for i in range(5):
                            var a := (-0.8 + 0.4 * float(i)) + t * 0.6
                            var end := p + Vector2(cos(a) * 18.0, -13.0 + sin(a) * 8.0) * zoom_factor
                            _streak(canvas, end - Vector2(6.0, -5.0) * zoom_factor, end, venom, 1.6 * zoom_factor)
                            _diamond(canvas, end, 3.4 * zoom_factor, _tinted("def8bc", venom.a))
                    "co_doc":
                        for i in range(6):
                            var a := float(i) * TAU / 6.0 + t * 3.4
                            var q := p + Vector2.from_angle(a) * ring
                            canvas.draw_circle(q, 3.0 * zoom_factor, venom)
                            canvas.draw_line(q, q + Vector2.from_angle(a + 1.6) * 5.0 * zoom_factor,
                                _tinted("e2f6a4", venom.a), 1.4 * zoom_factor, true)
                        _hex(canvas, p, ring * 0.7, venom, t * TAU)
                    "duoc_doc":
                        _hex(canvas, p, ring * 0.75, venom, -t * TAU * 0.5)
                        for i in range(5):
                            var a := float(i) * TAU / 5.0 + t * 1.4
                            _diamond(canvas, p + Vector2.from_angle(a) * ring,
                                3.2 * zoom_factor, _tinted("dcf8b5", venom.a))
                        canvas.draw_circle(p, 4.5 * zoom_factor, venom)
            else:
                _hex(canvas, p, ring, base, t * TAU * 0.65)
        "guard":
            var shield_radius := (14.0 + 3.5 * sin(t * PI)) * zoom_factor
            _hex(canvas, p + Vector2(0, -13 * zoom_factor), shield_radius, base, 0.0)
            _hex(canvas, p + Vector2(0, -13 * zoom_factor), shield_radius * 0.74, c, PI / 6.0)
            _diamond(canvas, p + Vector2(0, -13 * zoom_factor), 5 * zoom_factor, base)
        "poison", "poison_apply", "poison_tick":
            # Apply: rising toxin seal. Tick: tight acidic pulse. No implied
            # extra damage, stacks or tick rate from the drawing itself.
            var is_tick := kind == "poison_tick"
            var spread := (4.5 + (6.0 if is_tick else 14.0) * t) * zoom_factor
            var count := 5 if is_tick else 8
            for i in range(count):
                var ang := TAU * float(i) / float(count) + t * (3.8 if branch == "co_doc" else 1.5)
                var q := p + Vector2.from_angle(ang) * spread + Vector2(0, -9.0 * t * zoom_factor)
                if branch == "doc_cham":
                    _diamond(canvas, q, (2.4 - 0.7 * t) * zoom_factor, venom)
                elif branch == "co_doc":
                    canvas.draw_circle(q, (2.0 + float(i % 3) * 0.7) * zoom_factor, venom)
                    canvas.draw_line(q, q + Vector2(3.0, -2.0) * zoom_factor, venom, 1.0 * zoom_factor, true)
                else:
                    _diamond(canvas, q, 2.2 * zoom_factor, _tinted("c9ffcf", venom.a))
            if not is_tick:
                _hex(canvas, p + Vector2(0, -9.0 * zoom_factor), spread, venom, t * TAU * 0.3)
        "venom_burst":
            # Co Độc consumes only committed stacks; collapse then snap.
            var inward := (21.0 - 17.0 * t) * zoom_factor
            for i in range(8):
                var a := TAU * float(i) / 8.0 + t * 0.8
                var q := p + Vector2.from_angle(a) * inward
                _streak(canvas, q, q + Vector2.from_angle(a + PI) * 7.0 * zoom_factor,
                    venom, 2.0 * zoom_factor)
            _hex(canvas, p, (5.0 + 9.0 * sin(t * PI)) * zoom_factor, venom, t * 2.0)
        "venom_cloud":
            # Cloud radius comes from the real skill definition; never invent
            # ground coverage or create a game-world status zone.
            var cloud_radius := maxf(7.0 * zoom_factor, radius)
            for i in range(8):
                var ang := TAU * float(i) / 8.0 + 0.35 * t
                var center := p + Vector2.from_angle(ang) * cloud_radius * (0.35 + 0.4 * t)
                canvas.draw_circle(center, (4.0 + 5.0 * t) * zoom_factor,
                    Color(venom.r, venom.g, venom.b, venom.a * 0.18))
            canvas.draw_arc(p, cloud_radius, 0.0, TAU, 40, venom, 1.7 * zoom_factor, true)
        "heal":
            if school == "poison" and branch == "duoc_doc":
                # Medicinal recovery is a rising lotus, not a poison explosion.
                for i in range(6):
                    var a := TAU * float(i) / 6.0 + t * 0.65
                    var tip := p + Vector2.from_angle(a) * (5.0 + 10.0 * t) * zoom_factor
                    tip.y -= t * 17.0 * zoom_factor
                    _diamond(canvas, tip, (4.2 - t) * zoom_factor, _tinted("c4fbc7", venom.a))
                canvas.draw_circle(p + Vector2(0, -9.0 - 9.0 * t) * zoom_factor,
                    4.0 * zoom_factor, venom)
                return
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
            if school == "poison" and branch == "duoc_doc":
                # Floating herbal leaves cleanse an actual status; no fake heal.
                for i in range(6):
                    var a := TAU * float(i) / 6.0 - t * 1.6
                    var q := p + Vector2.from_angle(a) * (6.0 + 14.0 * t) * zoom_factor
                    _diamond(canvas, q, 3.0 * zoom_factor, _tinted("c8ffd1", venom.a))
                _hex(canvas, p, (7.0 + 15.0 * t) * zoom_factor, venom, -t * TAU)
                return
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
