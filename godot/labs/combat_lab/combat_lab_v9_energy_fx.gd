extends Control
# VFX09: additive ENERGY, not painted pictures / geometric objects in flight.
# Presentation-only. The live mode reads existing MapBattleV2 cues, NEVER
# creates a hit, changes HP, target selection, timing, Save, or skill stats.
const LIGHT_SHADER = preload("res://labs/combat_lab/combat_lab_v9_energy_light.gdshader")
const CYAN := Color("56ddff")
const WHITE := Color("f5fdff")
const INDIGO := Color("7961ec")
const JADE := Color("69f8a6")
const VIOLET := Color("a26aff")
const TAU9 := PI * 2.0
const MAX_LIVE_FX := 12

var demo_mode := true
var demo_school := "serpent"
var elapsed := 0.0
var loop_seconds := 2.5
var paused := false
var caster := Vector2(325, 455)
var target := Vector2(910, 371)
var _live_had_effect := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    var fx_material := ShaderMaterial.new()
    fx_material.shader = LIGHT_SHADER
    material = fx_material
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    if demo_mode:
        if not paused:
            elapsed += clampf(delta, 0.0, 0.08)
            queue_redraw()
        return
    # Event-driven visibility gate: no 60 FPS full overlay redraw when the
    # laboratory is idle or V9 is OFF. An empty frame clears the last glow.
    var host := get_parent()
    var active := false
    if host != null and host.get("v9_preview_enabled") == true:
        var now := float(host.get("visual_time"))
        var active_cues: Array = host.get("cues")
        for cue_value in active_cues:
            var cue: Dictionary = cue_value
            if not str(cue.get("skill_id", "")).contains(".co_doc.active_02."):
                continue
            var kind := str(cue.get("kind", ""))
            if kind == "projectile":
                var began := float(cue.get("launch_at", now))
                var ended := float(cue.get("impact_at", began))
                if now >= began and now <= ended:
                    active = true
                    break
            elif kind == "impact":
                var age_ms := now * 1000.0 - float(cue.get("created", 0))
                if age_ms >= 0.0 and age_ms <= float(cue.get("life", 0.0)):
                    active = true
                    break
    if active or active != _live_had_effect:
        queue_redraw()
    _live_had_effect = active

func set_mode(value: String) -> void:
    demo_school = "sword" if value == "sword" else "serpent"
    elapsed = 0.0
    queue_redraw()

func set_live_mode() -> void:
    demo_mode = false
    set_process(true)
    queue_redraw()

static func _tint(c: Color, a: float) -> Color:
    return Color(c.r, c.g, c.b, clampf(a, 0.0, 0.92))

static func _flare(canvas: CanvasItem, p: Vector2, r: float,
        c: Color, a: float) -> void:
    # Four short-lived radial light levels; additive bloom even in GL Compatibility.
    if a < 0.005:
        return
    canvas.draw_circle(p, r * 4.8, _tint(c, a * 0.025))
    canvas.draw_circle(p, r * 2.7, _tint(c, a * 0.075))
    canvas.draw_circle(p, r * 1.5, _tint(c, a * 0.17))
    canvas.draw_circle(p, maxf(0.6, r * 0.42), _tint(WHITE, a * 0.47))

static func _light_line(canvas: CanvasItem, a: Vector2, b: Vector2,
        c: Color, width: float, opacity: float) -> void:
    if opacity < 0.005:
        return
    canvas.draw_line(a, b, _tint(c, opacity * 0.060), width * 5.1, true)
    canvas.draw_line(a, b, _tint(c, opacity * 0.14), width * 2.9, true)
    canvas.draw_line(a, b, _tint(c, opacity * 0.31), width * 1.25, true)
    canvas.draw_line(a, b, _tint(WHITE, opacity * 0.60), maxf(0.85, width * 0.32), true)

static func _ribbon(canvas: CanvasItem, points: PackedVector2Array,
        c: Color, width: float, opacity: float) -> void:
    if points.size() < 2 or opacity < 0.005:
        return
    canvas.draw_polyline(points, _tint(c, opacity * 0.044), width * 6.0, true)
    canvas.draw_polyline(points, _tint(c, opacity * 0.12), width * 3.5, true)
    canvas.draw_polyline(points, _tint(c, opacity * 0.33), width * 1.45, true)
    canvas.draw_polyline(points, _tint(WHITE, opacity * 0.52), maxf(0.8, width * 0.28), true)

static func _ellipse(canvas: CanvasItem, center: Vector2,
        radius_x: float, radius_y: float, c: Color,
        alpha: float, phase: float = 0.0) -> void:
    var coords := PackedVector2Array()
    for i in range(37):
        var angle := float(i) * TAU9 / 36.0 + phase
        coords.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
    _ribbon(canvas, coords, c, 1.35, alpha)

static func _ease(x: float) -> float:
    var t := clampf(x, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

# V9.3: broad ribbon BODY with soft-edge additive shells. This is
# reconstructed every frame from deterministic spell time; zero texture/PDF
# /sprite imports and no change to the authoritative target or hit event.
static func _flow_shell(canvas: CanvasItem, spine: PackedVector2Array,
        z: float, width_factor: float, hue: Color, alpha: float) -> void:
    if spine.size() < 3 or alpha < 0.01:
        return
    # Individual segment quads cannot self-intersect at an S turn.
    # A global polygon of all upper/lower vertices is invalid under bends.
    var limit := spine.size() - 1
    for i in range(limit):
        var p0: Vector2 = spine[i]
        var p1: Vector2 = spine[i + 1]
        var step: Vector2 = p1 - p0
        if step.length_squared() < 0.25:
            continue
        var normal: Vector2 = step.normalized().orthogonal()
        var u0 := float(i) / float(limit)
        var u1 := float(i + 1) / float(limit)
        var envelope0 := (0.17 + 0.83 * sin(PI * u0 * 0.88)) * _ease(u0 * 5.5)
        var envelope1 := (0.17 + 0.83 * sin(PI * u1 * 0.88)) * _ease(u1 * 5.5)
        var width0 := maxf(0.3, (6.0 + 9.0 * envelope0) * z * width_factor)
        var width1 := maxf(0.3, (6.0 + 9.0 * envelope1) * z * width_factor)
        canvas.draw_colored_polygon(PackedVector2Array([
            p0 - normal * width0, p1 - normal * width1,
            p1 + normal * width1, p0 + normal * width0
        ]), _tint(hue, alpha))

static func serpent_light(canvas: CanvasItem, from: Vector2, to: Vector2,
        progress: float, zoom: float, lod: int = 2) -> void:
    var k := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.8, 2.25)
    var travel := to - from
    var distance := travel.length()
    if distance < 8.0:
        return
    var direction: Vector2 = travel / distance
    var normal: Vector2 = direction.orthogonal()
    var front := _ease(k)
    var span := minf(0.64, 330.0 / distance)
    var rear := maxf(0.0, front - span)
    var samples := 18 if lod >= 1 else 10
    var spine := PackedVector2Array()
    # A single coherent S-shaped serpent, rather than 3 separate neon ropes.
    for i in range(samples + 1):
        var u := float(i) / float(samples)
        var x := lerpf(rear, front, u)
        var envelope := sin(PI * u)
        var wave := sin(u * PI * 2.65 - k * 5.7) * envelope * 25.0 * z
        spine.append(from + travel * x + normal * wave)
    if front < 0.025:
        _flare(canvas, from, 8.0 * z, JADE, 0.75)
        return
    # One organic soft plasma volume; bright interior stays distinct.
    _flow_shell(canvas, spine, z, 2.6, VIOLET, 0.052)
    _flow_shell(canvas, spine, z, 1.85, JADE, 0.14)
    _flow_shell(canvas, spine, z, 1.02, CYAN, 0.14)
    _flow_shell(canvas, spine, z, 0.54, JADE, 0.23)
    _ribbon(canvas, spine, JADE, 2.1 * z, 0.44)
    var head: Vector2 = spine[spine.size() - 1]
    var neck: Vector2 = spine[maxi(0, spine.size() - 3)]
    # A cobra hood generated by luminous energy wings and two eye sparks.
    for sign in [-1.0, 1.0]:
        var side := float(sign)
        var hood := PackedVector2Array([
            neck + normal * side * 6.0 * z,
            head - direction * 23.0 * z + normal * side * 27.0 * z,
            head - direction * 8.0 * z + normal * side * 22.0 * z,
            head + direction * 8.0 * z + normal * side * 9.0 * z
        ])
        canvas.draw_colored_polygon(hood, _tint(VIOLET if sign < 0 else JADE, 0.24))
        _light_line(canvas, hood[1], hood[3],
            VIOLET if sign < 0 else JADE, 1.1 * z, 0.43)
        # Twin jade pinpricks at the front make the snake head readable.
        _flare(canvas, head + direction * 2.0 * z + normal * side * 6.0 * z,
            1.65 * z, WHITE, 0.72)
    _flare(canvas, head + direction * 6.0 * z, 6.8 * z, JADE, 0.82)
    # A short, bifurcated energy tongue and lightning-like venom whiskers.
    for sign in [-1.0, 1.0]:
        var p: Vector2 = head + direction * 9.0 * z
        var q: Vector2 = p + direction * 10.0 * z + normal * float(sign) * 4.0 * z
        _light_line(canvas, p, q, JADE, 0.72 * z, 0.38)
    # Sparse trailing motes; no expensive sparkle on every body segment.
    var motes := 6 if lod >= 2 else 3
    for i in range(motes):
        var u := fposmod(float(i) / float(motes) + k * 0.27, 1.0)
        var index := clampi(roundi(u * float(samples)), 0, samples)
        var p: Vector2 = spine[index] + normal * sin(float(i) * 2.7 + k * 5.0) * 11.0 * z
        _flare(canvas, p, 1.1 * z, JADE if i % 2 == 0 else VIOLET, 0.30)

static func serpent_impact(canvas: CanvasItem, at: Vector2,
        age: float, zoom: float, lod: int = 2) -> void:
    var t := clampf(age, 0.0, 1.0)
    var z := clampf(zoom, 0.8, 2.25)
    var strength := 1.0 - t
    _flare(canvas, at, (18.0 + 17.0 * (1.0 - t)) * z,
        JADE, strength * 0.98)
    _ellipse(canvas, at + Vector2(0, 18 * z),
        (26 + 96 * t) * z, (9 + 45 * t) * z,
        VIOLET, strength * 0.83, t * 0.7)
    _ellipse(canvas, at, (12 + 39 * t) * z, (15 + 26 * t) * z,
        JADE, strength * 0.51, -t * 1.2)
    for i in range(7 if lod >= 1 else 3):
        var phi := float(i) * TAU9 / 7.0 + t * 1.5
        var direction := Vector2(cos(phi), sin(phi))
        var start := at + direction * (7.0 + 17.0 * t) * z
        var finish := at + direction * (14.0 + 48.0 * t) * z
        _light_line(canvas, start, finish,
            JADE if i % 2 == 0 else VIOLET, 1.5 * z, strength * 0.73)

# V9.2: readable STRAIGHT jian made only of luminous geometry, not an image.
# ~4 blade polygons + ~13 detail primitives per sword; old renderer used
# nine segments x many glow-lines and was expensive with 12 active swords.
# The blade, tang, guard and engraved motifs always share one forward axis.
static func _energy_blade(canvas: CanvasItem, center: Vector2,
        forward: Vector2, z: float, energy: float) -> void:
    if energy < 0.025:
        return
    var f: Vector2 = forward.normalized()
    if f.length_squared() < 0.5:
        f = Vector2.RIGHT
    var side: Vector2 = f.orthogonal()
    var root: Vector2 = center - f * 15.0 * z
    var mid: Vector2 = center + f * 19.0 * z
    var tip: Vector2 = center + f * 51.0 * z
    var guard: Vector2 = center - f * 18.0 * z
    var pommel: Vector2 = center - f * 38.0 * z
    # Outer aura, the darker bevel, then two faceted white/azure surfaces.
    # No curved spine and no separate segment orientation: a rigid straight blade.
    canvas.draw_colored_polygon(PackedVector2Array([
        root - side * 13.0 * z, mid - side * 17.5 * z, tip,
        mid + side * 17.5 * z, root + side * 13.0 * z
    ]), _tint(CYAN, energy * 0.060))
    canvas.draw_colored_polygon(PackedVector2Array([
        root - side * 6.6 * z, mid - side * 7.1 * z, tip,
        mid + side * 7.1 * z, root + side * 6.6 * z
    ]), _tint(INDIGO, energy * 0.29))
    canvas.draw_colored_polygon(PackedVector2Array([
        root, root - side * 4.8 * z, mid - side * 5.0 * z, tip
    ]), _tint(WHITE, energy * 0.70))
    canvas.draw_colored_polygon(PackedVector2Array([
        root, tip, mid + side * 5.0 * z, root + side * 4.8 * z
    ]), _tint(CYAN, energy * 0.62))
    canvas.draw_line(root, tip, _tint(WHITE, energy * 0.84), 1.0 * z, true)
    # Carved luminous motifs: diamond talisman, paired lines and a central seal.
    # Their location is attached to the blade's axis; they cannot bend the sword.
    var seal: Vector2 = center + f * 4.0 * z
    var rune_top: Vector2 = seal + f * 6.0 * z
    var rune_bottom: Vector2 = seal - f * 6.0 * z
    var rune_left: Vector2 = seal - side * 2.8 * z
    var rune_right: Vector2 = seal + side * 2.8 * z
    var engraving: Color = _tint(Color("ffb954"), energy * 0.94)
    canvas.draw_polyline(PackedVector2Array([
        rune_bottom, rune_left, rune_top, rune_right, rune_bottom
    ]), engraving, maxf(0.9, 1.20 * z), true)
    canvas.draw_line(root + f * 13.0 * z - side * 1.7 * z,
        root + f * 27.0 * z - side * 1.7 * z,
        engraving, maxf(0.75, 0.98 * z), true)
    canvas.draw_line(root + f * 13.0 * z + side * 1.7 * z,
        root + f * 27.0 * z + side * 1.7 * z,
        engraving, maxf(0.75, 0.98 * z), true)
    # Mirror-engraved vein lines inside the faceted blade, glowing amber.
    canvas.draw_line(root + f * 5.0 * z - side * 3.4 * z,
        mid - side * 4.2 * z, engraving, maxf(0.72, 0.80 * z), true)
    canvas.draw_line(root + f * 5.0 * z + side * 3.4 * z,
        mid + side * 4.2 * z, engraving, maxf(0.72, 0.80 * z), true)
    # Ornate quillon: broad horizontal guard with mirrored curled endpoints.
    var guard_left: Vector2 = guard - side * 9.0 * z
    var guard_right: Vector2 = guard + side * 9.0 * z
    _light_line(canvas, guard_left, guard_right, CYAN, 1.85 * z, energy * 0.76)
    canvas.draw_line(guard_left, guard_left + f * 4.5 * z - side * 4.0 * z,
        engraving, 1.1 * z, true)
    canvas.draw_line(guard_right, guard_right + f * 4.5 * z + side * 4.0 * z,
        engraving, 1.1 * z, true)
    # Wrapped hilt and jewel finial, not a glow stick.
    _light_line(canvas, guard, pommel, INDIGO, 2.2 * z, energy * 0.81)
    for band in range(3):
        var p: Vector2 = guard.lerp(pommel, (float(band) + 1.0) * 0.24)
        canvas.draw_line(p - side * 2.0 * z, p + side * 2.0 * z,
            engraving, maxf(0.7, z), true)
    canvas.draw_circle(pommel, 3.2 * z, _tint(CYAN, energy * 0.32))
    canvas.draw_circle(pommel, 1.4 * z, _tint(WHITE, energy * 0.78))
    canvas.draw_circle(tip, 2.0 * z, _tint(WHITE, energy * 0.89))

static func sword_light(canvas: CanvasItem, from: Vector2, to: Vector2,
        progress: float, zoom: float, lod: int = 2) -> void:
    var t := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.6, 2.1)
    var count := 12 if lod >= 2 else (8 if lod == 1 else 5)
    if t < 0.42:
        var charge := _ease(t / 0.42)
        _ellipse(canvas, from + Vector2(0, 25.0 * z),
            (16 + charge * 52) * z, (9 + charge * 18) * z,
            CYAN, 0.15 + charge * 0.49, charge * 0.45)
        _flare(canvas, from, (6.0 + charge * 10.0) * z,
            CYAN, 0.2 + charge * 0.46)
    for i in range(count):
        var column_index := i % 4
        var formation_row := floori(float(i) / 4.0)
        # Form a precise 4x3 flying-sword constellation; no overlap near
        # caster while charging. Materials become visible one by one.
        var source := from + Vector2(
            97.0 + float(column_index) * 66.0,
            (float(formation_row) - 1.0) * 87.0 - 12.0) * minf(z, 1.25)
        # Four visible attack lanes (3 swords per target in full preview).
        # Every blade maintains its straight axis toward its own destination,
        # preventing twelve swords from becoming a single neon smear.
        var slot := i % 4
        var column := float(slot % 2)
        var row_index := float(floori(float(slot) / 2.0))
        var within_group := float(floori(float(i) / 4.0)) - 1.0
        var mob_center := to + Vector2(
            (column - 0.5) * 112.0, (row_index - 0.5) * 102.0)
        var arrival := mob_center + Vector2(
            within_group * 10.0, within_group * 11.0) * z
        # Four small waves, rather than twelve projectiles striking at once.
        var flight := clampf((t - 0.40 - float(i % 3) * 0.025) / 0.37, 0.0, 1.0)
        var pos := source.lerp(arrival, _ease(flight))
        var direction := (arrival - source).normalized()
        if direction.length_squared() < 0.01:
            direction = Vector2.RIGHT
        var opacity := clampf((t - 0.01 - float(i) * 0.008) * 9.0, 0.0, 1.0)
        if t > 0.82:
            opacity *= clampf((1.0 - t) / 0.18, 0.0, 1.0)
        if flight > 0.01 and flight < 1.0:
            var wake := pos - direction * 27.0 * z
            _light_line(canvas, wake, pos, CYAN, 2.1 * z, opacity * 0.46)
        _energy_blade(canvas, pos, direction, z * 0.71, opacity)
    if t > 0.69:
        var impact := clampf((t - 0.69) / 0.31, 0.0, 1.0)
        var alpha := (1.0 - impact)
        for target_slot in range(4 if lod >= 2 else 2):
            var column := float(target_slot % 2)
            var row_index := float(floori(float(target_slot) / 2.0))
            var center := to + Vector2(
                (column - 0.5) * 112.0,
                (row_index - 0.5) * 102.0)
            _flare(canvas, center, (6.0 + impact * 9.0) * z,
                CYAN, alpha * 0.75)
            _ellipse(canvas, center + Vector2(0, 12.0 * z),
                (8.0 + impact * 31.0) * z,
                (4.0 + impact * 15.0) * z, CYAN, alpha * 0.55)
        _flare(canvas, to, (13.0 + impact * 23.0) * z,
            CYAN, alpha * 0.50)
        _ellipse(canvas, to + Vector2(0, 18 * z),
            (18 + impact * 115) * z, (9 + impact * 49) * z,
            CYAN, alpha * 0.65, impact * 0.35)
        for i in range(9 if lod >= 2 else 4):
            var phi := TAU9 * float(i) / 9.0
            var ray := Vector2.from_angle(phi)
            _light_line(canvas, to + ray * (12.0 + 14.0 * impact) * z,
                to + ray * (19.0 + 54.0 * impact) * z,
                WHITE, 1.2 * z, alpha * 0.68)

func _draw() -> void:
    if demo_mode:
        var phase := fposmod(elapsed, loop_seconds) / loop_seconds
        if demo_school == "sword":
            sword_light(self, caster + Vector2(0, -62),
                target + Vector2(0, -34), phase, 1.55)
        elif phase < 0.17:
            var k := phase / 0.17
            _flare(self, caster + Vector2(14, -63), 5.0 + 11.0 * k,
                JADE, 0.2 + k * 0.8)
            _ellipse(self, caster + Vector2(0, 18),
                (12 + 40 * k), (6 + 19 * k), VIOLET, k * 0.65)
        elif phase < 0.79:
            serpent_light(self, caster + Vector2(14, -63),
                target + Vector2(0, -32), (phase - 0.17) / 0.62, 1.8)
        else:
            serpent_impact(self, target + Vector2(0, -32),
                (phase - 0.79) / 0.21, 1.8)
        return
    # LIVE LAB: render ONLY canonical Co Doc serpents actually represented
    # by existing Combat Lab MapBattleV2 event cues. Never invent targets.
    var host := get_parent()
    if host == null or host.get("v9_preview_enabled") != true:
        return
    var now := float(host.get("visual_time"))
    var active_cues: Array = host.get("cues")
    var rendered := 0
    for cue_variant in active_cues:
        if rendered >= MAX_LIVE_FX:
            break
        var cue: Dictionary = cue_variant
        if not str(cue.get("skill_id", "")).contains(".co_doc.active_02."):
            continue
        var kind := str(cue.get("kind", ""))
        if kind not in ["projectile", "impact"]:
            continue
        var target_world: Vector2 = host.call("_cue_target_world_position", cue)
        var dest: Vector2 = host.call("_world_to_local", target_world)
        var source_world: Vector2 = cue.get("from_position", target_world)
        var from: Vector2 = host.call("_world_to_local", source_world)
        var zoom := float(host.call("v4_effective_render_zoom"))
        var z := clampf(zoom, 1.0, 2.1)
        if kind == "projectile":
            var launched := float(cue.get("launch_at", now))
            var landed := maxf(launched + 0.001, float(cue.get("impact_at", launched + 0.1)))
            var k := clampf((now - launched) / (landed - launched), 0.0, 1.0)
            if now >= launched and now <= landed:
                serpent_light(self, from + Vector2(0, -24 * z),
                    dest + Vector2(0, -24 * z), k, z, 1)
                rendered += 1
        else:
            var created := int(cue.get("created", 0))
            # Match Combat Lab's presentation clock so HOLD freezes bloom.
            var age := clampf((now * 1000.0 - float(created)) /
                maxf(1.0, float(cue.get("life", 1.0))), 0.0, 1.0)
            serpent_impact(self, dest + Vector2(0, -24 * z), age, z, 1)
            rendered += 1
