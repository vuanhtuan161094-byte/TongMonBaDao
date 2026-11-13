extends RefCounted
# VFX19 THIEN LOI -- ORIGINAL procedural electricity, LAB ONLY.
# V9's white-hot / cyan / violet translucent light language, but
# original hierarchical midpoint-displacement lightning topology.
# NEVER owns targeting, damage, HP, status, cooldown, or Save.
const WHITE := Color("f5fdff")
const CYAN := Color("6fe9fc")
const AZURE := Color("3989f2")
const VIOLET := Color("9869eb")
const DARK_BLUE := Color("254aab")
const LOOP_SECONDS := 3.20
const HIT_COUNT := 3
const MAX_BRANCHES := 6
const MAX_SPLINTERS := 7
const MAIN_BEGIN := 0.320
const MAIN_CONTACT := 0.458
const MAIN_END := 0.548
const SECOND_BEGIN := 0.530
const SECOND_END := 0.737

static func _clamp(v: float) -> float:
    return clampf(v, 0.0, 1.0)

static func _smooth(v: float) -> float:
    var k := _clamp(v)
    return k * k * (3.0 - 2.0 * k)

static func _rgba(c: Color, a: float) -> Color:
    return Color(c.r, c.g, c.b, _clamp(a))

static func _rand(seed: float) -> float:
    return fposmod(sin(seed * 12.9898 + 78.233) * 43758.5453, 1.0)

static func sky_root() -> Vector2:
    return Vector2(771.0, 76.0)

static func caster_root(caster: Vector2) -> Vector2:
    return caster + Vector2(34.0, -91.0)

static func mock_contact_target(targets: Array, slot: int) -> Vector2:
    # Caller supplies approved mock positions explicitly. Not a target picker.
    if slot < 0 or slot >= mini(targets.size(), HIT_COUNT):
        return Vector2.ZERO
    var p: Vector2 = targets[slot]
    return p + Vector2(0.0, -29.0)

static func impact_window(mode: int, slot: int) -> Vector2:
    # These are mock visual timeline windows, not actual combat events.
    if slot == 0:
        return Vector2(0.446, 0.552) if mode == 0 else Vector2(0.457, 0.566)
    if slot == 1:
        return Vector2(0.570, 0.675)
    if slot == 2:
        return Vector2(0.625, 0.735)
    return Vector2(-1.0, -1.0)

static func active_mock_contacts(mode: int, t: float) -> PackedInt32Array:
    var allowed := PackedInt32Array()
    for slot in range(HIT_COUNT):
        var interval := impact_window(mode, slot)
        if t >= interval.x and t < interval.y:
            allowed.append(slot)
    return allowed

static func discharge_root(mode: int, caster: Vector2) -> Vector2:
    return sky_root() if mode == 0 else caster_root(caster)

static func _light_line(canvas: CanvasItem, a: Vector2, b: Vector2,
        strength: float, width: float, hue: Color = CYAN) -> void:
    if strength < 0.006:
        return
    # Same physics-inspired white-hot signature as the liked V9 serpent.
    # Wide atmospheric passes have VERY low alpha so edges remain soft.
    canvas.draw_line(a, b, _rgba(VIOLET, strength * 0.034),
        width * 8.8, true)
    canvas.draw_line(a, b, _rgba(DARK_BLUE, strength * 0.089),
        width * 5.4, true)
    canvas.draw_line(a, b, _rgba(hue, strength * 0.30),
        width * 2.5, true)
    canvas.draw_line(a, b, _rgba(WHITE, strength * 0.88),
        maxf(0.85, width * 0.63), true)

static func _flash(canvas: CanvasItem, p: Vector2,
        strength: float, radius: float) -> void:
    if strength < 0.01:
        return
    canvas.draw_circle(p, radius * 3.1,
        _rgba(VIOLET, strength * 0.024))
    canvas.draw_circle(p, radius * 1.75,
        _rgba(AZURE, strength * 0.095))
    canvas.draw_circle(p, radius * 0.75,
        _rgba(CYAN, strength * 0.27))
    canvas.draw_circle(p, maxf(0.85, radius * 0.19),
        _rgba(WHITE, strength * 0.76))

static func bolt_path(a: Vector2, b: Vector2, seed: int,
        beat: int, depth: int = 4,
        spread: float = 36.0) -> PackedVector2Array:
    # Hierarchical midpoint displacement. Large bends determine silhouette;
    # fine subdivision adds distinct micro-crackles rather than a uniform
    # 'zig-zag ladder'. Fixed endpoints => safe approved targets.
    var path := PackedVector2Array([a, b])
    var side := (b - a).orthogonal().normalized()
    for level in range(clampi(depth, 1, 4)):
        var next := PackedVector2Array()
        var damping := pow(0.57, float(level))
        for i in range(path.size() - 1):
            var p0 := path[i]
            var p1 := path[i + 1]
            next.append(p0)
            var sample := float(seed) * 7.73 + float(beat) * 3.17 \
                + float(level) * 17.23 + float(i) * 4.31
            var wiggle := (_rand(sample) * 2.0 - 1.0) * spread * damping
            var along := (_rand(sample + 8.5) - 0.5) * 5.0 * damping
            var mid := p0.lerp(p1, 0.5) + side * wiggle
            mid += (b - a).normalized() * along
            next.append(mid)
        next.append(path[path.size() - 1])
        path = next
    return path

static func bolt_endpoint(path: PackedVector2Array,
        reveal: float) -> Vector2:
    if path.is_empty():
        return Vector2.ZERO
    if path.size() < 2:
        return path[0]
    var float_last := float(path.size() - 1) * _clamp(reveal)
    var a := mini(int(floor(float_last)), path.size() - 1)
    var b := mini(a + 1, path.size() - 1)
    return path[a].lerp(path[b], float_last - float(a))

static func _stroke(canvas: CanvasItem, path: PackedVector2Array,
        reveal: float, power: float, width: float,
        hue: Color = CYAN) -> void:
    if path.size() < 2 or reveal <= 0.0 or power <= 0.005:
        return
    var end_segment := float(path.size() - 1) * _clamp(reveal)
    for i in range(path.size() - 1):
        if float(i) > end_segment:
            break
        var span := _clamp(end_segment - float(i))
        if span <= 0.0:
            break
        var u := float(i) / float(path.size() - 1)
        # Bolt naturally narrows towards the ground end, while keeping a
        # thin bright core continuous, so it does not turn into an arrow.
        var silhouette := 1.09 - 0.29 * u
        var flicker := 0.76 + 0.22 * sin(float(i) * 3.6 + float(path.size()))
        _light_line(canvas, path[i], path[i].lerp(path[i + 1], span),
            power * flicker, width * silhouette, hue)

static func _subforks(canvas: CanvasItem,
        main_path: PackedVector2Array, seed: int,
        beat: int, reveal: float, energy: float, lod: int) -> void:
    if main_path.size() < 9:
        return
    var count := mini(MAX_BRANCHES, 6 if lod >= 2 else (4 if lod == 1 else 2))
    for j in range(count):
        var u := 0.17 + float(j) * 0.124
        if u > reveal + 0.005:
            continue
        var index := clampi(roundi(u * float(main_path.size() - 1)),
            1, main_path.size() - 2)
        var anchor := main_path[index]
        var axis: Vector2 = (main_path[index + 1] - main_path[index - 1]).normalized()
        var n := axis.orthogonal()
        var side := -1.0 if j % 2 == 0 else 1.0
        var lean := float(j) * 0.11
        var length := 64.0 + float(j % 3) * 23.0
        var finish := anchor + n * side * length \
            + axis * (36.0 + 13.0 * lean)
        var branch_path := bolt_path(anchor, finish,
            seed + j * 17 + 120, beat, 3, 15.0)
        var fade := energy * (0.55 - float(j) * 0.038)
        _stroke(canvas, branch_path,
            _clamp((reveal - u) * 5.2), fade, 1.55,
            VIOLET if j % 3 == 0 else AZURE)
        if lod >= 2 and j % 2 == 0:
            var elbow := branch_path[branch_path.size() - 3]
            var tip := elbow + n * side * (20.0 + float(j) * 2.1)
            var tiny := bolt_path(elbow, tip,
                seed + j * 41 + 802, beat, 2, 7.0)
            _stroke(canvas, tiny, _clamp((reveal - u) * 4.0),
                fade * 0.46, 0.9, CYAN)

static func _charge(canvas: CanvasItem, caster: Vector2,
        t: float, mode: int, lod: int) -> void:
    if t >= MAIN_BEGIN:
        return
    var k := _smooth((t - 0.065) / 0.175) \
        * (1.0 - _smooth((t - 0.275) / 0.044))
    if k < 0.009:
        return
    var hand := caster_root(caster)
    _flash(canvas, hand, 0.16 + 0.50 * k, 5.5)
    var n := 5 if lod >= 1 else 3
    var beat := int(floor(t * 73.0))
    for j in range(n):
        var angle := float(j) * 1.19 + t * 9.3
        var start := hand + Vector2.from_angle(angle) \
            * (22.0 + 18.0 * float(j % 3))
        var route := bolt_path(start, hand, 150 + j * 12,
            beat, 3, 7.5)
        _stroke(canvas, route, 1.0,
            k * (0.26 + 0.13 * float(j % 2)), 1.35,
            CYAN if j % 2 == 0 else VIOLET)
    # A sky-flash deliberately hints at the coming vertical discharge.
    if mode == 0 and t > 0.19:
        var root := sky_root()
        _flash(canvas, root, _smooth((t - 0.18) / 0.095) * 0.44, 7.5)
        for j in range(3):
            var at := root + Vector2(
                float(j - 1) * 44.0, -17.0 + float(j) * 12.0)
            _stroke(canvas, bolt_path(root, at, 410 + j,
                beat, 3, 12.0), 1.0,
                k * 0.19, 1.0, VIOLET)

static func _contact(canvas: CanvasItem, at: Vector2,
        slot: int, t: float, mode: int, lod: int) -> void:
    var win := impact_window(mode, slot)
    if t < win.x or t >= win.y:
        return
    var age := _clamp((t - win.x) / (win.y - win.x))
    var power := 1.0 - _smooth((age - 0.13) / 0.87)
    _flash(canvas, at, power * (0.95 if slot == 0 else 0.62),
        14.0 if slot == 0 else 9.5)
    # Chaotic ground-hugging electrical discharge -- no full circular
    # shockwave / no fake AoE: irregular, incomplete crawling filaments.
    var spokes := MAX_SPLINTERS if lod >= 2 else (4 if lod == 1 else 2)
    var beat := int(floor(t * 68.0))
    for i in range(spokes):
        var a := -2.92 + float(i) * 0.79 + float(slot) * 0.18
        var length := (24.0 + float(i % 3) * 12.0 +
            35.0 * _smooth(age)) * (0.78 if slot > 0 else 1.0)
        var v := Vector2(cos(a) * length, sin(a) * length * 0.47)
        var finish := at + Vector2(v.x, v.y + 9.0)
        var crackle := bolt_path(at, finish,
            970 + slot * 29 + i * 23, beat, 2, 6.5)
        _stroke(canvas, crackle, 1.0, power * (0.36 + 0.06 * float(i % 3)),
            1.1, AZURE if i % 2 else CYAN)
    # Two sparse motes: no skill-state icons and no ongoing false DoT.
    if lod >= 2:
        for j in range(2):
            var offset := Vector2(float(j - 1) * 13.0, -16.0 * (1.0 - age))
            _flash(canvas, at + offset, power * 0.20, 3.0)

static func _leader(canvas: CanvasItem, caster: Vector2, targets: Array,
        t: float, mode: int, lod: int) -> void:
    if targets.size() < HIT_COUNT or t < MAIN_BEGIN or t >= MAIN_END:
        return
    var begin := discharge_root(mode, caster)
    var finish := mock_contact_target(targets, 0)
    var rise := _smooth((t - MAIN_BEGIN) /
        (MAIN_CONTACT - MAIN_BEGIN))
    var decay := 1.0 - _smooth((t - MAIN_CONTACT) /
        (MAIN_END - MAIN_CONTACT))
    var intensity := 0.15 + 0.85 * rise
    intensity *= maxf(0.0, decay)
    var beat := int(floor(t * 73.0))
    var path := bolt_path(begin, finish,
        179 if mode == 0 else 218, beat, 4,
        34.0 if mode == 0 else 47.0)
    var reveal := _clamp((t - MAIN_BEGIN) /
        (MAIN_CONTACT - MAIN_BEGIN))
    # The leader PROGRESSES through the sky before full ignition.
    _stroke(canvas, path, reveal, intensity, 3.55,
        CYAN if mode == 0 else AZURE)
    _subforks(canvas, path, 298 if mode == 0 else 347,
        beat, reveal, intensity * 0.94, lod)
    var tip := bolt_endpoint(path, reveal)
    _flash(canvas, tip, intensity * 0.72, 7.0)
    if mode == 0:
        _flash(canvas, begin, intensity * 0.40, 8.0)

static func _chain(canvas: CanvasItem, targets: Array,
        t: float, mode: int, lod: int) -> void:
    if targets.size() < HIT_COUNT or t < SECOND_BEGIN or t >= SECOND_END:
        return
    var previous := mock_contact_target(targets, 0)
    for slot in range(1, HIT_COUNT):
        var start := 0.532 if slot == 1 else 0.598
        var ignite := start + 0.049
        var expire := start + 0.133
        if t < start or t >= expire:
            continue
        var dest := mock_contact_target(targets, slot)
        var reveal := _smooth((t - start) / (ignite - start))
        var fade := 1.0 - _smooth((t - ignite) / (expire - ignite))
        var strength := (0.86 if slot == 1 else 0.77) * fade
        var beat := int(floor(t * 79.0)) + slot * 8
        var points := bolt_path(previous, dest,
            517 + slot * 43 + mode * 31, beat,
            4, 20.0 if slot == 1 else 24.0)
        _stroke(canvas, points, reveal,
            strength * maxf(0.2, reveal), 2.25, AZURE)
        _subforks(canvas, points, 504 + slot * 9,
            beat, reveal, strength * 0.35, maxi(0, lod - 1))
        previous = dest if mode == 1 else mock_contact_target(targets, 0)

static func render(canvas: CanvasItem, caster: Vector2,
        targets: Array, progress: float,
        mode: int = 0, lod: int = 2) -> void:
    # 3 explicit mock targets ONLY; no independent hit discovery or API.
    if targets.size() < HIT_COUNT:
        return
    var t := _clamp(progress)
    _charge(canvas, caster, t, mode, lod)
    _leader(canvas, caster, targets, t, mode, lod)
    _chain(canvas, targets, t, mode, lod)
    for slot in active_mock_contacts(mode, t):
        _contact(canvas, mock_contact_target(targets, slot),
            slot, t, mode, lod)
