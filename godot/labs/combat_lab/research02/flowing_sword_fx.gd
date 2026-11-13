extends RefCounted
# VFX17 / RESEARCH-02 — Flowing Sword Qi, LAB-ONLY visual renderer.
# A legible V14 faceted JIAN remains straight and recognizable.
# The silk-like 2-strand tail follows the cubic flight route with moving
# phase offsets inspired by the successful V9 serpent-light spine.
# No gameplay effect, no target discovery, no shader overdraw, no TIME().
const OLD_BLADE = preload("res://labs/combat_lab/combat_lab_v14_sword_fx.gd")
const PALE := Color("ecfaff")
const ICE := Color("a9eefa")
const TEAL := Color("4dbbda")
const BLUE := Color("3464aa")
const INDIGO := Color("353e75")
const GOLD := Color("f3ce85")
const CAST_TIP := Vector2(38.0, -72.0)
const MAX_WAVES := 3
const SLOTS := 3
const SOURCE_SEGMENTS := 13

static func _a(t: float) -> float:
    return clampf(t, 0.0, 1.0)

static func _smooth(t: float) -> float:
    var k := _a(t)
    return k * k * (3.0 - 2.0 * k)

static func _c(c: Color, alpha: float) -> Color:
    return Color(c.r, c.g, c.b, _a(alpha))

static func visual_indices(lod: int) -> PackedInt32Array:
    if lod >= 2:
        return PackedInt32Array([0, 1, 2, 3, 4, 5, 6, 7, 8])
    if lod == 1:
        return PackedInt32Array([0, 2, 3, 5, 6, 8])
    return PackedInt32Array([1, 4, 7])

static func flight_window(wave: int, slot: int) -> Vector2:
    # LAB timing only; these events are not player/combat events.
    var launch := 0.282 + float(wave) * 0.132 + float(slot) * 0.012
    return Vector2(launch, launch + 0.187)

static func impact_window(wave: int, slot: int) -> Vector2:
    var arrive := flight_window(wave, slot).y
    return Vector2(arrive, arrive + 0.088)

static func _bezier(a: Vector2, b: Vector2, c: Vector2, d: Vector2, t: float) -> Vector2:
    var k := _a(t)
    var q := 1.0 - k
    return a * q * q * q + b * (3.0 * q * q * k) + c * (3.0 * q * k * k) + d * k * k * k

static func flight_point(caster: Vector2, victim: Vector2, wave: int,
        slot: int, t: float) -> Vector2:
    var start := caster + CAST_TIP + Vector2(
        float(wave) * 15.0, float(slot - 1) * 40.0 - float(wave) * 11.0)
    var end := victim + Vector2(-42.0, -31.0)
    var lift := (18.0 + float(wave) * 12.0) * (1.0 if slot != 2 else -0.7)
    var control1 := start.lerp(end, 0.29) + Vector2(0.0, -115.0 + lift)
    var control2 := start.lerp(end, 0.73) + Vector2(0.0, -54.0 - lift)
    return _bezier(start, control1, control2, end, t)

static func flight_axis(caster: Vector2, victim: Vector2, wave: int,
        slot: int, t: float) -> Vector2:
    var left := flight_point(caster, victim, wave, slot, maxf(0.0, t - 0.017))
    var right := flight_point(caster, victim, wave, slot, minf(1.0, t + 0.017))
    var v := right - left
    return v.normalized() if v.length_squared() > 0.01 else Vector2.RIGHT

static func _strand(canvas: CanvasItem, points: PackedVector2Array,
        width: float, tint: Color, alpha: float) -> void:
    if points.size() < 2 or alpha < 0.01:
        return
    # Serpent-light principle: low-alpha atmospheric body, readable thin core.
    # NO global additive CanvasItem material.
    canvas.draw_polyline(points, _c(BLUE, alpha * 0.052), width * 4.3, true)
    canvas.draw_polyline(points, _c(tint, alpha * 0.18), width * 2.2, true)
    canvas.draw_polyline(points, _c(tint, alpha * 0.48), width * 0.92, true)
    canvas.draw_polyline(points, _c(PALE, alpha * 0.31), maxf(1.0, width * 0.21), true)

static func _tail(canvas: CanvasItem, caster: Vector2, victim: Vector2,
        wave: int, slot: int, progress: float, alpha: float,
        zoom: float, lod: int) -> void:
    # Sample the *same actual flight trajectory*, not 3 offset copies of
    # a straight line. Only front 0.21 param-units get a visible trail.
    var z := clampf(zoom, 0.75, 1.65)
    var reach := 0.245
    var rear := maxf(0.0, progress - reach)
    var direction := flight_axis(caster, victim, wave, slot, progress)
    var normal := direction.orthogonal()
    var mid := PackedVector2Array()
    var upper := PackedVector2Array()
    var lower := PackedVector2Array()
    var count := SOURCE_SEGMENTS if lod >= 1 else 8
    for i in range(count + 1):
        var u := float(i) / float(count)
        var p := lerpf(rear, progress, u)
        var base := flight_point(caster, victim, wave, slot, p)
        var env := sin(PI * u) * (0.55 + 0.45 * u)
        var phase := p * 21.0 - progress * 13.0 + float(wave) * 1.1
        var sway := sin(phase) * 5.2 * z * env
        mid.append(base + normal * sway)
        upper.append(base + normal * (sway + sin(phase * 1.15) *
            7.5 * z * env + 2.0 * z))
        lower.append(base + normal * (sway - cos(phase * 1.09) *
            7.0 * z * env - 2.0 * z))
    # Broad blue atmospheric glow always sits behind the rigid sword.
    _strand(canvas, mid, 7.7 * z, TEAL, alpha * 0.80)
    _strand(canvas, upper, 3.6 * z, ICE, alpha * 0.59)
    if lod >= 1:
        _strand(canvas, lower, 3.5 * z, BLUE, alpha * 0.58)
    # Gold specks are rare and move on the same energy spine.
    if lod >= 2 and progress > 0.1:
        for j in range(3):
            var q := _a(progress - float(j + 1) * 0.047)
            var pos := flight_point(caster, victim, wave, slot, q)
            canvas.draw_circle(pos + normal * float(j - 1) * 3.0 * z,
                1.1 * z, _c(GOLD, alpha * (0.43 - float(j) * 0.09)))

static func _charge(canvas: CanvasItem, caster: Vector2, t: float,
        zoom: float) -> void:
    if t >= 0.282:
        return
    var z := clampf(zoom, 0.7, 1.65)
    var alpha := _smooth(t / 0.18) * (1.0 - _smooth((t - 0.258) / 0.03))
    if alpha <= 0.004:
        return
    var root := caster + CAST_TIP
    for slot in range(3):
        var theta := -0.56 + float(slot) * 0.44 + t * 1.5
        var at := root + Vector2(42.0 + float(slot) * 14.0,
            (float(slot) - 1.0) * 40.0 + sin(t * 9.0 + float(slot)) * 7.0)
        OLD_BLADE._qi_blade(canvas, at,
            Vector2(cos(theta), sin(theta)), 0.84 * z, alpha * 0.74)
        canvas.draw_line(root + Vector2(-12, 0), at,
            _c(TEAL, alpha * 0.16), 1.4, true)

static func _impact(canvas: CanvasItem, victim: Vector2,
        age: float, power: float, wave: int,
        slot: int, zoom: float) -> void:
    # A single moving diagonal cut, followed by 4 deterministic very short
    # sparks. No full-screen flash, white blob or concentric giant circles.
    var k := _a(age)
    var a := _a(power) * (1.0 - _smooth(k))
    if a < 0.008:
        return
    var z := clampf(zoom, 0.8, 1.65)
    var pivot := victim + Vector2(0.0, -26.0)
    var angle := -0.52 + (float(slot) - 1.0) * 0.15 + float(wave) * 0.07
    var f := Vector2.from_angle(angle)
    var n := f.orthogonal()
    var half := (34.0 + float(wave) * 10.0 + 22.0 * _smooth(k)) * z
    var center := pivot + f * lerpf(-16.0, 14.0, _smooth(k))
    var x0 := center - f * half
    var x1 := center + f * half
    var thickness := (6.8 + float(wave) * 2.4) * z * (1.0 - k * 0.83)
    # Carved tapered ink-like slash, brighter only at the sharp inner edge.
    canvas.draw_colored_polygon(PackedVector2Array([
        x0, center - n * thickness, x1, center + n * thickness
    ]), _c(BLUE, a * 0.31))
    canvas.draw_line(x0, x1, _c(TEAL, a * 0.62), 3.4 * z, true)
    canvas.draw_line(x0 + f * 10.0 * z, x1 - f * 9.0 * z,
        _c(PALE, a * 0.83), 1.3 * z, true)
    if wave == 2:
        for i in range(4):
            var ang := float(i) * 1.53 - 0.7 + float(slot) * 0.22
            var ray := Vector2.from_angle(ang)
            var source := pivot + ray * (5.0 + 11.0 * k) * z
            var tip := pivot + ray * (13.0 + 26.0 * k) * z
            canvas.draw_line(source, tip,
                _c(GOLD if i == 1 else ICE, a * 0.42), 1.25 * z, true)
    # Thin grounding echo that NEVER fills/occludes the target sprite.
    canvas.draw_arc(victim + Vector2(0.0, 11.0), (18.0 + 22.0 * k) * z,
        PI * 0.10, PI * 0.93, 15, _c(TEAL, a * 0.25), 1.4, true)

static func render(canvas: CanvasItem, caster: Vector2, targets: Array,
        progress: float, zoom: float = 1.35, lod: int = 2) -> void:
    if targets.is_empty():
        return
    var t := _a(progress)
    _charge(canvas, caster, t, zoom)
    for index in visual_indices(lod):
        var wave := int(index / 3)
        var slot := index % 3
        if slot >= targets.size():
            continue
        var victim: Vector2 = targets[slot]
        var flight := flight_window(wave, slot)
        var arrival := flight.y
        if t >= flight.x and t < arrival + 0.022:
            var p := _a((t - flight.x) / (arrival - flight.x))
            # A gentle acceleration, still camera-readable in 60fps video.
            var k := pow(p, 1.16)
            var pos := flight_point(caster, victim, wave, slot, k)
            var axis := flight_axis(caster, victim, wave, slot, k)
            var fade_in := _smooth(p / 0.15)
            var fade_out := 1.0 - _smooth((t - arrival) / 0.022)
            var power := (0.70 if wave == 0 else
                (0.87 if wave == 1 else 1.0)) * fade_in * fade_out
            _tail(canvas, caster, victim, wave, slot, k,
                power, zoom, lod)
            # Crisp sculpted, rune-inscribed jian (not an arrow / arc).
            OLD_BLADE._qi_blade(canvas, pos, axis,
                (1.07 if wave == 0 else 1.21) * zoom, power)
        var hit := impact_window(wave, slot)
        if t >= hit.x and t < hit.y:
            var impact_age := (t - hit.x) / (hit.y - hit.x)
            _impact(canvas, victim, impact_age,
                0.48 if wave == 0 else (0.67 if wave == 1 else 0.90),
                wave, slot, zoom)
