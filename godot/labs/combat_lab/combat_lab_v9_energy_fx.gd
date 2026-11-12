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

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    var fx_material := ShaderMaterial.new()
    fx_material.shader = LIGHT_SHADER
    material = fx_material
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    if not paused and demo_mode:
        elapsed += clampf(delta, 0.0, 0.08)
    queue_redraw()

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

static func serpent_light(canvas: CanvasItem, from: Vector2, to: Vector2,
        progress: float, zoom: float, lod: int = 2) -> void:
    # The perceived snake is a moving, braided ENERGY BODY. Its luminous head
    # is the convergent endpoint of 3 waves, not a pre-painted reptile sprite.
    var k := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.8, 2.25)
    var vector := to - from
    var distance := vector.length()
    if distance < 8.0:
        return
    var dir := vector / distance
    var normal := dir.orthogonal()
    var front := _ease(k)
    var trail_span := minf(0.48, 235.0 / distance)
    var rear := maxf(0.0, front - trail_span)
    var segments := 18 if lod >= 1 else 10
    for lane in range(3 if lod >= 1 else 2):
        var points := PackedVector2Array()
        var strand := float(lane)
        for i in range(segments + 1):
            var u := float(i) / float(segments)
            var x := lerpf(rear, front, u)
            var envelope := sin(u * PI)
            var angle := x * 15.0 - k * 17.0 + strand * 1.95
            var wave := sin(angle) * envelope * (12.0 + 5.0 * sin(k * 11.0)) * z
            var side := (strand - 1.0) * envelope * 5.0 * z
            points.append(from + vector * x + normal * (wave + side))
        _ribbon(canvas, points,
            JADE if lane == 0 else (VIOLET if lane == 1 else CYAN),
            (4.2 if lane == 0 else 2.8) * z,
            0.85 if lane == 0 else 0.70)
    var head := from.lerp(to, front)
    # A bright leading energy crest and twin lower arcs imply the jaw
    # without painting a snake head object.
    _flare(canvas, head, 5.2 * z, JADE, 0.98)
    for sign in [-1.0, 1.0]:
        var jaw := PackedVector2Array()
        for i in range(9):
            var u := float(i) / 8.0
            var distance_back := (1.0 - u) * 35.0 * z
            var bend: float = sin(u * PI) * float(sign) * 10.0 * z
            jaw.append(head - dir * distance_back + normal * bend)
        _ribbon(canvas, jaw, JADE if sign > 0 else VIOLET, 1.8 * z, 0.72)
    # Scales are travelling specular sparks, not texture details.
    var motes := 9 if lod >= 2 else 4
    for i in range(motes):
        var u := fposmod(float(i) / float(motes) + k * 0.37, 1.0)
        var x := lerpf(rear, front, u)
        var center := from + vector * x
        var lateral := sin(x * 14.0 - k * 17.0) * sin(u * PI) * 11.0 * z
        _flare(canvas, center + normal * lateral, 1.2 * z,
            JADE if i % 2 == 0 else VIOLET, 0.44)

static func serpent_impact(canvas: CanvasItem, at: Vector2,
        age: float, zoom: float, lod: int = 2) -> void:
    var t := clampf(age, 0.0, 1.0)
    var z := clampf(zoom, 0.8, 2.25)
    var strength := 1.0 - t
    _flare(canvas, at, (13.0 + 10.0 * (1.0 - t)) * z,
        JADE, strength * 0.98)
    _ellipse(canvas, at + Vector2(0, 18 * z),
        (20 + 58 * t) * z, (8 + 24 * t) * z,
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

static func _energy_blade(canvas: CanvasItem, center: Vector2,
        forward: Vector2, z: float, energy: float) -> void:
    # A flying sword is built from converging high-energy beams (white core,
    # ice bevel, dark-violet side glow) instead of a metal PNG polygon.
    var tip := center + forward * (35.0 * z)
    var base := center - forward * (19.0 * z)
    var cross := forward.orthogonal()
    _light_line(canvas, base, tip, CYAN, 3.1 * z, energy)
    _light_line(canvas, base - cross * 3.1 * z, tip, INDIGO,
        1.6 * z, energy * 0.60)
    _light_line(canvas, base + cross * 3.1 * z, tip, CYAN,
        1.6 * z, energy * 0.60)
    var guard := center - forward * (20.0 * z)
    _light_line(canvas, guard - cross * 8 * z,
        guard + cross * 8 * z, CYAN, 1.3 * z, energy * 0.65)
    _light_line(canvas, guard, guard - forward * 13.0 * z,
        INDIGO, 1.5 * z, energy * 0.55)
    _flare(canvas, tip, 1.8 * z, WHITE, energy)

static func sword_light(canvas: CanvasItem, from: Vector2, to: Vector2,
        progress: float, zoom: float, lod: int = 2) -> void:
    var t := clampf(progress, 0.0, 1.0)
    var z := clampf(zoom, 0.6, 2.1)
    var count := 12 if lod >= 2 else (8 if lod == 1 else 5)
    if t < 0.52:
        var charge := _ease(t / 0.52)
        _ellipse(canvas, from + Vector2(0, 18.0 * z),
            (18 + charge * 66) * z, (8 + charge * 24) * z,
            CYAN, 0.25 + charge * 0.63, charge * 0.45)
    for i in range(count):
        var a := TAU9 * float(i) / float(count)
        var orbit := Vector2(cos(a), sin(a) * 0.48)
        var source := from + orbit * (64.0 + 15.0 * sin(t * 5.0 + a)) * z
        var arrival := to + Vector2(cos(a), sin(a) * 0.58) * 45.0 * z
        var flight := clampf((t - 0.40 - float(i % 3) * 0.012) / 0.39, 0.0, 1.0)
        var pos := source.lerp(arrival, _ease(flight))
        var direction := (arrival - source).normalized()
        if direction.length_squared() < 0.01:
            direction = Vector2.RIGHT
        var opacity := clampf(t * 6.0 - float(i % 3) * 0.13, 0.0, 1.0)
        if t > 0.82:
            opacity *= clampf((1.0 - t) / 0.18, 0.0, 1.0)
        if flight > 0.01 and flight < 1.0:
            var wake := pos - direction * 28.0 * z
            _light_line(canvas, wake, pos, CYAN, 3.2 * z, opacity * 0.72)
        _energy_blade(canvas, pos, direction, z * 0.71, opacity)
    if t > 0.69:
        var impact := clampf((t - 0.69) / 0.31, 0.0, 1.0)
        var alpha := (1.0 - impact)
        _flare(canvas, to, (8.0 + impact * 13.0) * z,
            CYAN, alpha * 0.84)
        _ellipse(canvas, to + Vector2(0, 18 * z),
            (11 + impact * 83) * z, (7 + impact * 36) * z,
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
