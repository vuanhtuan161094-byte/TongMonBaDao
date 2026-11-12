class_name CombatLabPoisonV4Layers
extends RefCounted

const ArtBrief = preload("res://labs/combat_lab/combat_lab_poison_skill_art_brief.gd")
const V8Fx = preload("res://labs/combat_lab/combat_lab_vfx_v8_jian_serpent.gd")
# Original, already-proven RGBA V3 masters; V4 adds layered motion and
# skill-specific silhouettes, not a new source or fake character atlas.
const NEEDLE_MASTER: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/doc_cham_needle.png")
const GU_MASTER: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/co_doc_gu_serpent.png")
const LOTUS_MASTER: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/duoc_doc_jade_lotus.png")
const MIST_MASTER: Texture2D = preload("res://labs/combat_lab/assets/poison_vfx/venom_smoke_corrosion.png")

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

# A few richly-painted RGBA sprites are cheaper and softer than stacking
# dozens of circle primitives. Alpha bound below and sizes capped for GL
# Compatibility on Windows and Android. Drawing resets local transform.
static func master(canvas: CanvasItem, art: Texture2D, at: Vector2,
        dimensions: Vector2, radians: float, opacity: float, tint_color: Color = Color.WHITE) -> void:
    if art == null or opacity <= 0.006:
        return
    var bounds := Vector2(clampf(dimensions.x, 2.0, 520.0),
        clampf(dimensions.y, 2.0, 400.0))
    var shade := Color(tint_color.r, tint_color.g, tint_color.b, clampf(opacity, 0.0, 0.83))
    canvas.draw_set_transform(at, radians, Vector2.ONE)
    canvas.draw_texture_rect(art, Rect2(bounds * -0.5, bounds), false, shade)
    canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# A real travelling ribbon: bright thin center with a translucent textured
# wake. Used only by committed heal, not by a synthetic healing event.
static func medicine_stream(canvas: CanvasItem, source: Vector2, destination: Vector2,
        opacity: float, k: float, z: float) -> void:
    var distance := source.distance_to(destination)
    if distance < 6.0:
        return
    var d := (destination - source).normalized()
    var n := d.orthogonal()
    var previous := source
    for i in range(1, 13):
        var u := float(i) / 12.0
        var point := source.lerp(destination, u)
        point += n * sin(u * PI) * (10.0 + 2.0 * sin(k * TAU4)) * z
        line(canvas, previous, point, Color("74f0d4"),
            opacity * (0.22 + 0.45 * sin(u * PI)), maxf(1.0, 1.5 * z))
        previous = point
    for i in range(3):
        var u := clampf((float(i) + 1.0 + k * 2.0) / 5.0, 0.05, 0.96)
        var point := source.lerp(destination, u)
        point += n * sin(u * PI) * (10.0 + 2.0 * sin(k * TAU4)) * z
        glint(canvas, point, Color("bafbe7"), opacity * 0.6, 2.3 * z, k + float(i))

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

# VFX-07: Visual-only reinterpretation of three owner mockups.
# The timelines read V6.3 cue k, but cannot add targets or alter HP.
static func v7_fan_shower(canvas: CanvasItem, source: Vector2, destination: Vector2,
        progress: float, z: float, c: Color, strands: int, lod: int) -> void:
    var axis := (destination - source).normalized()
    if axis.length_squared() < 0.001:
        axis = Vector2.RIGHT
    var n := axis.orthogonal()
    var head := source.lerp(destination, progress)
    var phase := clampf((progress - 0.18) / 0.70, 0.0, 1.0)
    var separation := (7.0 + 15.0 * phase) * z
    # 5-8 cosmetic strands according to genuine mastery; 0 extra damage.
    var painted := clampi(strands, 3, 8)
    for index in range(painted):
        var lane := (float(index) - float(painted - 1) * 0.5) / maxf(1.0, float(painted - 1) * 0.5)
        var lateral := n * lane * separation
        var tip := head + lateral
        var tail := tip - axis * (15.0 + 5.0 * float(index % 3)) * z
        if lod >= 1 or index % 2 == 0:
            master(canvas, NEEDLE_MASTER, tip - axis * 5.0 * z,
                Vector2(36.0, 11.0) * z, axis.angle(), 0.35 + 0.35 * phase)
        needle(canvas, tail, tip, c, 0.70 + 0.20 * phase, z * 0.76)
        if lod >= 1 and index % 2 == 0:
            glint(canvas, tip - axis * 4.0 * z, Color("f3e6ff"),
                0.48 + 0.26 * phase, 1.9 * z, float(index) * 0.73)

static func v7_gu_fog(canvas: CanvasItem, center: Vector2, bounds: Vector2,
        progress: float, opacity: float, z: float, lod: int) -> void:
    # Fog planes stay INSIDE the authoritative ellipse. No fake AoE extent.
    var phase := progress * TAU4
    for strand in range(2 if lod == 0 else 3):
        var u := float(strand) - 0.5 if lod == 0 else float(strand) - 1.0
        var drift := Vector2(sin(phase + u * 1.4) * bounds.x * 0.12,
            u * bounds.y * 0.17)
        master(canvas, MIST_MASTER, center + drift,
            Vector2(bounds.x * 0.95, bounds.y * 0.42),
            u * 0.12 + phase * 0.025, opacity * 0.31, Color("c9f28c"))
    var motes := 5 if lod == 0 else 9
    for index in range(motes):
        var ang := float(index) * TAU4 / float(motes) + phase * 0.13
        var phase_radius := 0.21 + 0.15 * sin(phase * 0.5 + float(index) * 0.7)
        var mote := center + Vector2(cos(ang) * bounds.x, sin(ang) * bounds.y) * phase_radius
        glint(canvas, mote, GOLD, opacity * 0.73, 1.8 * z, ang)
        if lod >= 1 and index % 3 == 0:
            master(canvas, GU_MASTER, mote, Vector2(18.0, 13.0) * z,
                ang * 0.10, opacity * 0.41, Color("eaff9b"))

static func v7_jade_foot_lotus(canvas: CanvasItem, foot: Vector2,
        progress: float, z: float, motif: String, mastery: int, lod: int) -> void:
    # Beneath actual healed ally. This is a local floor ornament, NOT
    # a targeting ring / added heal over time.
    var bloom := sin(clampf(progress, 0.0, 1.0) * PI)
    var size_boost := 1.12 if motif == "jade_ultimate" else 1.0
    var flower_size := Vector2(52.0, 25.0) * z * size_boost
    master(canvas, LOTUS_MASTER, foot + Vector2(0, -5.0 * z),
        flower_size * (0.70 + bloom * 0.45),
        progress * 0.18, (0.34 + 0.22 * bloom) * (1.0 - progress), Color("b1ffe9"))
    # A few warm gold filaments: keep ally feet and real HP bar visible.
    var petal_glints := 4 if lod == 0 else clampi(5 + floori(float(mastery) / 5.0), 5, 7)
    for index in range(petal_glints):
        var angle := float(index) * TAU4 / float(petal_glints) + progress * 0.22
        var mote := foot + Vector2(cos(angle) * 23.0, sin(angle) * 9.0) * z * size_boost
        glint(canvas, mote, Color("ffe6a9"), bloom * 0.58, 1.2 * z, angle)

static func render(canvas: CanvasItem, cue: Dictionary, target: Vector2, source: Vector2, t: float, radius_px: float, zoom: float) -> void:
    var skill_id := str(cue.get("skill_id", cue.get("source_skill_id", "")))
    var branch := school(skill_id)
    var motif := str(ArtBrief.profile(skill_id).get("motif", ""))
    var c := tint(branch)
    var kind := str(cue.get("kind", ""))
    var effect := str(cue.get("effect", ""))
    var shape := str(cue.get("shape", ""))
    var growth: Dictionary = cue.get("v4_growth", {})
    var mastery := clampi(int(growth.get("mastery_level", 1)), 1, 12)
    var lod := int(growth.get("lod", 2))
    var live_cues := int(cue.get("v4_crowd", 0))
    if live_cues >= 28: lod = 0
    elif live_cues >= 14: lod = mini(lod, 1)
    var decor_strands := clampi(int(growth.get("decorative_strands", 5)), 3, 8)
    if lod == 0: decor_strands = mini(decor_strands, 5)
    # More mastery = slightly richer VALUE, not increased gameplay radius.
    var glamour := clampf(float(growth.get("intensity", 0.78)), 0.75, 1.0)
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
    # V8 snake is opt-in and strictly real-cue driven. Other schools, V4
    # effects, non-poison skills, AoE footprint and production stay untouched.
    if (bool(cue.get("v8_preview", false)) or OS.get_environment("TMB_POISON_V8_PREVIEW") == "1") and motif == "serpent_bind":
        if kind == "projectile":
            V8Fx.cobra(canvas, caster_hand, p, k, z)
            return
        if kind == "impact":
            V8Fx.cobra_impact(canvas, p, k, z)
            return
    if bool(cue.get("v4_heal_ground", false)):
        if kind == "heal" and motif in ["jade_heal", "jade_ultimate"]:
            v7_jade_foot_lotus(canvas, target, k, z, motif, mastery, lod)
        return
    if kind in ["venom_cloud", "aoe", "area_burst"] or (shape == "circle" and kind == "skill_release"):
        # No invented radius: only radius_px from authoritative V6.3/event.
        var area := clampf(radius_px, 1.0, 1600.0)
        var area_y := clampf(float(cue.get("v4_radius_y", area)), 1.0, 1600.0)
        # Film-grade low smoke belongs on the FLOOR: no bloom over monster
        # faces or HP bars, and no visual enlargement of the real hit radius.
        var fog_tint := Color("bd9af1") if branch == "doc_cham" else Color("b3eb77")
        var ground_opacity := (0.23 if branch == "doc_cham" else 0.27) * life
        if branch == "co_doc" and motif in ["gu_mist", "gu_domain"]:
            ground_opacity *= 1.12
        master(canvas, MIST_MASTER, target, Vector2(area * 1.75, area_y * 0.85),
            k * 0.08, ground_opacity, fog_tint)
        master(canvas, MIST_MASTER, target + Vector2(0.0, area_y * 0.09),
            Vector2(area * 1.35, area_y * 0.58), -k * 0.14,
            ground_opacity * 0.57, c)
        # The outside edge is exactly the canonical skill radius. It is a
        # warning/feedback boundary only, never the source of a damage hit.
        for i in range(12):
            var begin := float(i) * TAU4 / 12.0
            var last := target + Vector2(cos(begin) * area, sin(begin) * area_y)
            for segment in range(1, 6):
                var theta := begin + float(segment) * TAU4 / (17.0 * 5.0)
                var next := target + Vector2(cos(theta) * area, sin(theta) * area_y)
                # Gameplay radius remains exact; this border must not steal
                # attention from characters or imply all six targets are hit.
                canvas.draw_line(last, next, a(c, life * 0.18),
                    maxf(0.8, z * 0.52), true)
                last = next
        # Low-opacity petals/motes on the floor; leave monsters visible.
        var ground_motes := 5 if lod == 0 else 9
        for i in range(ground_motes):
            var ang := float(i) * TAU4 / float(ground_motes) + k * 0.33
            var q := target + Vector2(cos(ang) * area,
                sin(ang) * area_y) * (0.23 + k * 0.27)
            glint(canvas, q, c, life * 0.45 * glamour, 2.0 * z, ang)
        if motif == "gu_mist":
            v7_gu_fog(canvas, target, Vector2(area, area_y), k, life * glamour, z, lod)
        # Distinct authored silhouettes for each AoE: the same canonical
        # radius is preserved. These floor details cannot select/hit targets.
        match motif:
            "needle_fan", "thousand_needles":
                var count := decor_strands if motif == "needle_fan" else (10 if lod >= 1 else 6)
                for i in range(count):
                    var theta := float(i) * TAU4 / float(count) + k * 0.2
                    var ray := Vector2.from_angle(theta)
                    var end := target + Vector2(cos(theta) * area,
                        sin(theta) * area_y) * (0.34 + 0.17 * k)
                    needle(canvas, end - ray * (3.0 + 2.0 * k) * z, end + ray * 4.0 * z,
                        c, life * (0.33 if motif == "needle_fan" else 0.44), z * 0.50)
            "miasma_pulse":
                canvas.draw_circle(target, area * 0.62, a(c.darkened(0.32), life * 0.095))
                ring(canvas, target, area * (0.32 + 0.28 * k), c, life * 0.32, k)
            "gu_mist":
                # Living, low fog tendrils cross the painted poison footprint
                # instead of another concentric circle.
                for strand in range(3):
                    var path := PackedVector2Array()
                    for segment in range(9):
                        var u := float(segment) / 8.0
                        var x := (u - 0.5) * area * 0.9
                        var y := sin(u * TAU4 * 1.3 + k * 1.8 + float(strand)) * area_y * 0.10
                        path.append(target + Vector2(x, y + (float(strand) - 1.0) * area_y * 0.17))
                    canvas.draw_polyline(path, a(c, life * 0.12),
                        maxf(1.0, z * 0.9), true)
                for i in range(4):
                    var theta := float(i) * TAU4 / 4.0 + k * 0.7
                    var cloud := target + Vector2(cos(theta) * area,
                        sin(theta) * area_y) * 0.24
                    canvas.draw_circle(cloud, area * 0.20, a(GU_DARK, life * 0.16))
                    glint(canvas, cloud, GOLD, life * 0.28, 1.0 * z, theta)
            "gu_scatter", "gu_domain":
                var count := 5 if motif == "gu_scatter" else 7
                for i in range(count):
                    var theta := float(i) * TAU4 / float(count) - k * 0.65
                    var ray := Vector2.from_angle(theta)
                    var tip := target + Vector2(cos(theta) * area,
                        sin(theta) * area_y) * (0.33 + 0.13 * k)
                    spark(canvas, tip, c, life * 0.48, 1.45 * z)
                    if motif == "gu_domain":
                        canvas.draw_line(tip - ray * 6.0 * z, tip,
                            a(GOLD, life * 0.34), maxf(0.7, z * 0.55), true)
        return
    if kind == "heal" or effect == "heal":
        # Display ONLY when the canonical heal event is committed.
        # A medicinal stream can connect caster and ally without granting
        # extra HP, and becomes a short lotus pulse for self-healing.
        medicine_stream(canvas, caster_hand, p, life * 0.78, k, z)
        var lift := k * 13.0 * z
        master(canvas, LOTUS_MASTER, p - Vector2(0, lift),
            Vector2(66, 55) * z, -0.12 + k * 0.34, life * 0.76)
        master(canvas, LOTUS_MASTER, p - Vector2(0, lift + 7.0 * z),
            Vector2(43, 36) * z, 0.14 - k * 0.28, life * 0.39, GOLD)
        lotus(canvas, p - Vector2(0, k * 23.0 * z), 17.0 * z, c, life * 0.67, k)
        for i in range(3):
            var stride := (float(i) - 1.0) * 9.0 * z
            var light_from := p + Vector2(stride, -10.0 * z + k * 14.0 * z)
            var light_to := p + Vector2(stride * 0.74, -(31.0 + 7.0 * sin(k * PI)) * z)
            line(canvas, light_from, light_to, Color("a9ffe3"), life * 0.27, z * 0.76)
        glint(canvas, p - Vector2(0, 17.0 * z), GOLD,
            life * 0.74, 4.0 * z, k * 0.8)
        for i in range(6):
            var theta := float(i) * TAU4 / 6.0 + k * 0.28
            var seed := p + Vector2.from_angle(theta) * (13.0 + 12.0 * k) * z
            glint(canvas, seed - Vector2(0, lift), c, life * 0.68, 1.9 * z, theta)
        debris(canvas, p, 16.0 * z, c, life, k)
        return
    if kind == "cleanse" or effect == "cleanse":
        master(canvas, LOTUS_MASTER, p - Vector2(0, k * 18.0 * z),
            Vector2(56, 47) * z, -k * 0.45, life * 0.58)
        ring(canvas, p, (10.0 + 22.0 * k) * z, GOLD, life * 0.62, k)
        lotus(canvas, p, 14.0 * z, c, life * 0.77, k)
        return
    match kind:
        "cast":
            var center := caster_hand - Vector2(0, 2.0 * z)
            # Three restrained luminous texture layers around the ACTUAL
            # casting hand; drawn before needle / serpent / lotus silhouette.
            if branch == "doc_cham":
                master(canvas, NEEDLE_MASTER, center + Vector2(0, -5.0 * z),
                    Vector2(58, 20) * z, -0.18 + k * 0.16,
                    maxf(0.20, pulse) * 0.63)
            elif branch == "co_doc":
                master(canvas, GU_MASTER, center, Vector2(57, 43) * z,
                    k * 0.18, maxf(0.20, pulse) * 0.48)
            else:
                master(canvas, LOTUS_MASTER, center, Vector2(62, 49) * z,
                    -k * 0.22, maxf(0.22, pulse) * 0.64)
                glint(canvas, center - Vector2(0, 11) * z, GOLD,
                    maxf(0.20, pulse) * 0.55, 3.0 * z, k)
            ring(canvas, center, (9.0 + pulse * 10.0) * z, c, maxf(0.15, pulse) * 0.46, k)
            if branch == "doc_cham":
                var count := 5 if motif in ["needle_fan", "thousand_needles"] else 3
                for i in range(count):
                    var shift := Vector2((float(i) - float(count - 1) * 0.5) * 6.2,
                        -float(i % 2) * 4.0) * z
                    needle(canvas, center + shift - Vector2(9, -4) * z,
                        center + shift + Vector2(9, -4) * z, c, maxf(0.15, pulse), z)
                if motif == "miasma_pulse":
                    canvas.draw_circle(center, 13.0 * z, a(c, pulse * 0.09))
            elif branch == "co_doc":
                serpent(canvas, center - Vector2(20, 5) * z, center + Vector2(18, -7) * z, c, pulse, z, k)
                if motif == "gu_domain":
                    ring(canvas, center, 21.0 * z, GOLD, pulse * 0.34, -k)
            else:
                lotus(canvas, center, 19.0 * z, c, maxf(0.15, pulse), k)
                if motif == "jade_ultimate":
                    lotus(canvas, center, 10.0 * z, GOLD, pulse * 0.48, -k)
            for i in range(3):
                var phi := float(i) * TAU4 / 3.0 + k * 0.65
                glint(canvas, center + Vector2.from_angle(phi) * (13.0 + 7.0 * pulse) * z,
                    c, pulse * 0.62, 1.8 * z, phi)
            debris(canvas, center, 15.0 * z, c, pulse, k)
        "projectile":
            # Event-clocked flight: textured, controlled bright core and one
            # painted translucent wake, but NO new projectile authority.
            var head := caster_hand.lerp(p, k)
            var tail := head - d * (22.0 * z)
            var wake := head - d * (15.0 * z)
            master(canvas, MIST_MASTER, wake, Vector2(57, 25) * z, d.angle(),
                0.34, c)
            if branch == "doc_cham":
                if motif == "needle_fan":
                    # Real skill cast produces one projectile cue. Its
                    # silhouette is the owner's seven-strand fan mockup.
                    v7_fan_shower(canvas, caster_hand, p, k, z, c, decor_strands, lod)
                else:
                    var fan := motif in ["thousand_needles", "miasma_pulse"]
                    var breadth := 2.9 if fan else 0.0
                    for i in range(3 if fan else 1):
                        var offset := d.orthogonal() * (float(i) - (1.0 if fan else 0.0)) * breadth * z
                        master(canvas, NEEDLE_MASTER, head - d * (6.0 * z) + offset,
                            Vector2(47, 17) * z, d.angle(),
                            (0.67 if fan else 0.80))
            elif branch == "co_doc":
                master(canvas, GU_MASTER, head, Vector2(44, 35) * z,
                    d.angle() * 0.20, 0.73, Color("dfff98"))
            else:
                master(canvas, LOTUS_MASTER, head, Vector2(38, 31) * z,
                    k * 1.45, 0.71)
            if branch == "doc_cham":
                if motif == "needle_fan":
                    pass # The seven-strand real-cue fan is already painted above.
                elif motif == "miasma_pulse":
                    spark(canvas, head, c, 0.84, 4.0 * z)
                    canvas.draw_circle(head - d * 8.0 * z, 8.0 * z, a(c, 0.11))
                else:
                    var count := 1 if motif in ["needle_basic", "needle_pierce", "needle_venom"] else 5
                    for i in range(count):
                        var side := d.orthogonal() * (float(i) - float(count - 1) * 0.5) * 2.9 * z
                        needle(canvas, tail + side, head + side, c, 0.94, z * 0.82)
            elif branch == "co_doc":
                if motif == "gu_bite":
                    spark(canvas, head, c, 0.92, 3.4 * z)
                    for i in range(2):
                        var wing := d.orthogonal() * (1.0 if i == 0 else -1.0)
                        canvas.draw_line(head - d * 5.0 * z,
                            head - d * 3.0 * z + wing * 4.0 * z,
                            a(GOLD, 0.66), maxf(0.7, z * 0.70), true)
                else:
                    serpent(canvas, tail, head, c, 0.94, z, k)
            else:
                lotus(canvas, head, 11.0 * z, c, 0.90, k)
            # Jewel-like highlights and tapered wakes, never random overdraw.
            for i in range(2 if lod == 0 else 4):
                var progress := float(i + 1) / 5.0
                var trailing := head - d * (8.0 + float(i) * 5.0) * z
                var jitter := d.orthogonal() * sin(float(i) * 2.3 + k * 9.0) * 2.0 * z
                glint(canvas, trailing + jitter, c, (1.0 - progress) * 0.47,
                    (2.4 - progress) * z, k * 3.0 + float(i))
            glint(canvas, head, c, 0.75, 2.2 * z, d.angle())
            debris(canvas, head - d * (8.0 * z), 7.0 * z, c, 0.36, k)
        "impact":
            # Render soft impact bloom first. The final bright puncture is
            # reserved for a real committed V6.3 hit event, NOT every monster
            # merely standing inside a 3-cell AoE indicator.
            master(canvas, MIST_MASTER, p + Vector2(0, 3) * z,
                Vector2(60, 31) * z, d.angle() * 0.2, pulse * 0.31, c)
            if branch == "doc_cham":
                master(canvas, NEEDLE_MASTER, p - d * 3.0 * z,
                    Vector2(49, 16) * z, d.angle(), pulse * 0.63)
            elif branch == "co_doc":
                master(canvas, GU_MASTER, p, Vector2(44, 35) * z,
                    -k * 0.33, pulse * 0.51, Color("f2e57c"))
            else:
                master(canvas, LOTUS_MASTER, p, Vector2(43, 34) * z,
                    k * 0.38, pulse * 0.61)
            if branch == "doc_cham":
                # A puncture cluster is directional, NEVER a five-spoke
                # purple flower. AOE still flashes only on actual hit actors.
                var count := 1 if motif in ["needle_basic", "needle_pierce", "needle_venom"] else 3
                for i in range(count):
                    var angle := (float(i) - float(count - 1) * 0.5) * 0.16 + d.angle()
                    var ray := Vector2.from_angle(angle)
                    needle(canvas, p - ray * 4.0 * z, p + ray * (13.0 + 6.0 * k) * z,
                        c, pulse * 0.88, z * 0.70)
            elif branch == "co_doc":
                if motif == "gu_bite":
                    spark(canvas, p, GOLD, pulse * 0.82, 3.3 * z)
                else:
                    serpent(canvas, p - d * 19.0 * z, p + d * 7.0 * z, c, pulse, z, k)
                    spark(canvas, p, GOLD, pulse * 0.54, 1.8 * z)
            else:
                lotus(canvas, p, (15.0 + 12.0 * k) * z, c, pulse, k)
            var shards := 2 if lod == 0 else 5
            for i in range(shards):
                var theta := float(i) * TAU4 / float(shards) + k * 0.35
                var q := p + Vector2.from_angle(theta) * (9.0 + k * 8.0) * z
                glint(canvas, q, c, pulse * 0.60, 1.8 * z, theta)
            glint(canvas, p, GOLD if branch == "co_doc" else Color("f4edff"),
                pulse * 0.94, 4.8 * z, k * 2.4)
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
