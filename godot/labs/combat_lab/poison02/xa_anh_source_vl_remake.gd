extends Control
## VFX-POI-02 CLEAN-SHEET. Original painted, alpha-cutout 6-pose flipbook;
## animate art, NOT lines as a pretend snake. Source VL layering reference.
## View-only fixed lab dummy. No rigs, combat, targeting, status, economy, save.
const SKILL_ID := "tmb.skill.poison.co_doc.active_02.human"
const CASTER := Vector2(326.0, 505.0)
const TARGET := Vector2(892.0, 506.0)
const CAST_AT := 0.54
const CONTACT_AT := 1.63
const COIL_END := 2.57
const DISSOLVE_END := 3.45
const LOOP_SECONDS := 4.10
const SOURCE_ATLAS: Texture2D = preload("res://labs/combat_lab/poison02/assets/serpent-flight-atlas.webp")
## Approved serpent-only source split into independently composited 4-pose layers.
const COIL_BACK_ATLAS: Texture2D = preload("res://labs/combat_lab/poison02/assets/serpent-bind-back-4pose.webp")
const COIL_FRONT_ATLAS: Texture2D = preload("res://labs/combat_lab/poison02/assets/serpent-bind-front-4pose.webp")
const COIL_POSES := 4
const COIL_CELL := Vector2(128.0, 128.0)
const JX_IMPACT: Texture2D = preload("res://assets/combat_v4/jx1_skill_fx/1fffed7e.webp")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const FLIGHT_FRAME_SIZE := Vector2(512.0, 179.0)
const FRAME_COUNT := 6
const IMPACT_FRAME_MS := 56
const IMPACT_FRAME_COUNT := 13

var elapsed := 0.0
var paused := false
var flight_frames: Array[AtlasTexture] = []
var _flight: Sprite2D
var _specular: Sprite2D
var _back_a: Sprite2D
var _back_b: Sprite2D
var _front_a: Sprite2D
var _front_b: Sprite2D
var _target_actor: Sprite2D
var _coil_back_frames: Array[AtlasTexture] = []
var _coil_front_frames: Array[AtlasTexture] = []
var _radial: Texture2D
var _impact_rects: Array = []

static func phase_at(t: float) -> String:
    if t < CAST_AT: return "charge"
    if t < CONTACT_AT: return "flight"
    if t < COIL_END: return "bind"
    if t < DISSOLVE_END: return "dissolve"
    return "idle"

static func flight_gain(t: float) -> float:
    if t < CAST_AT or t >= CONTACT_AT + 0.18: return 0.0
    return smoothstep(CAST_AT, CAST_AT + 0.12, t) * (1.0 - smoothstep(CONTACT_AT - 0.16, CONTACT_AT + 0.18, t))

static func bind_gain(t: float) -> float:
    if t < CONTACT_AT - 0.07 or t > DISSOLVE_END: return 0.0
    return smoothstep(CONTACT_AT - 0.07, CONTACT_AT + 0.12, t) * (1.0 - smoothstep(COIL_END, DISSOLVE_END, t))

static func impact_frame(t: float) -> int:
    if t < CONTACT_AT: return -1
    var f := int(floor((t - CONTACT_AT) * 1000.0 / float(IMPACT_FRAME_MS)))
    return f if f >= 0 and f < IMPACT_FRAME_COUNT else -1

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0, 720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _radial = _radial_texture()
    _read_jx_manifest()
    for i in range(FRAME_COUNT):
        var tex := AtlasTexture.new()
        tex.atlas = SOURCE_ATLAS
        tex.region = Rect2(Vector2(float(i % 3) * FLIGHT_FRAME_SIZE.x,
            float(floori(float(i) / 3.0)) * FLIGHT_FRAME_SIZE.y), FLIGHT_FRAME_SIZE)
        flight_frames.append(tex)
    _flight = _add_fx(false, 1)
    _specular = _add_fx(true, 2)
    # Independent back/front sprite animation; do not duplicate an actor from concept art.
    for i in range(COIL_POSES):
        var region := Rect2(Vector2(float(i % 2) * COIL_CELL.x,
            float(floori(float(i) / 2.0)) * COIL_CELL.y), COIL_CELL)
        var back_frame := AtlasTexture.new()
        back_frame.atlas = COIL_BACK_ATLAS
        back_frame.region = region
        _coil_back_frames.append(back_frame)
        var front_frame := AtlasTexture.new()
        front_frame.atlas = COIL_FRONT_ATLAS
        front_frame.region = region
        _coil_front_frames.append(front_frame)
    _back_a = _add_fx(false, 1)
    _back_b = _add_fx(false, 1)
    _target_actor = _make_target_actor()
    _front_a = _add_fx(false, 3)
    _front_b = _add_fx(false, 3)
    _update_fx()
    print("VFX_POI02_READY skill=", SKILL_ID, " flight=", FRAME_COUNT,
        " impact=", IMPACT_FRAME_COUNT, " visual_only=true")
    set_process(true)
    queue_redraw()

func _read_jx_manifest() -> void:
    var path := "res://assets/combat_v4/jx1_skill_fx/fx_manifest.json"
    if not FileAccess.file_exists(path):
        push_error("VFX_POI02_MISSING_JX_MANIFEST")
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if data is Dictionary:
        var effects: Dictionary = data.get("effects", {})
        var wudu: Dictionary = effects.get("jx_wudu_63_impact", {})
        _impact_rects = wudu.get("rects", [])
    if _impact_rects.size() < IMPACT_FRAME_COUNT * 6:
        push_error("VFX_POI02_JX_RECTS_UNAVAILABLE")

func _add_fx(additive: bool, z: int) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    sprite.centered = true
    sprite.z_index = z
    var blend := CanvasItemMaterial.new()
    blend.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD if additive else CanvasItemMaterial.BLEND_MODE_MIX
    sprite.material = blend
    add_child(sprite)
    sprite.visible = false
    return sprite

## Draw the target between the actual serpent's rear and front coils.
func _make_target_actor() -> Sprite2D:
    var frame := AtlasTexture.new()
    frame.atlas = ACTOR
    frame.region = Rect2(Vector2.ZERO, Vector2(320.0, 384.0))
    var actor := Sprite2D.new()
    actor.texture = frame
    actor.centered = false
    actor.z_index = 2
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    actor.position = TARGET - Vector2(160.0, 351.0) * 0.44
    actor.scale = Vector2.ONE * 0.44
    actor.modulate = Color("9ea6b2")
    add_child(actor)
    return actor

static func coil_pose_at(t: float) -> int:
    if t < CONTACT_AT - 0.07 or t >= DISSOLVE_END:
        return -1
    var u := clampf((t - CONTACT_AT) / maxf(0.001, COIL_END - CONTACT_AT), 0.0, 1.0)
    return mini(COIL_POSES - 1, floori(u * float(COIL_POSES)))

func _radial_texture() -> Texture2D:
    var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
    for y in range(64):
        for x in range(64):
            var p := (Vector2(float(x), float(y)) - Vector2(31.5, 31.5)) / 31.5
            var d := p.length()
            img.set_pixel(x, y, Color(1.0, 1.0, 1.0,
                clampf(exp(-6.2 * p.length_squared()) * (1.0 - smoothstep(0.7, 1.0, d)), 0.0, 1.0)))
    return ImageTexture.create_from_image(img)

func _update_fx() -> void:
    var attack := flight_gain(elapsed)
    _flight.visible = attack > 0.008
    _specular.visible = _flight.visible
    if _flight.visible:
        var u := clampf((elapsed - CAST_AT) / (CONTACT_AT - CAST_AT), 0.0, 1.0)
        var travel := u * u * (3.0 - 2.0 * u)
        var head := (CASTER + Vector2(36.0, -84.0)).lerp(TARGET + Vector2(-20.0, -92.0), travel)
        head += Vector2(0.0, -45.0 * sin(u * PI))
        var s := 0.43 + 0.76 * smoothstep(0.0, 0.69, u)
        var frame := posmod(int(floor((elapsed - CAST_AT) * 10.5)), FRAME_COUNT)
        var center := head - Vector2(204.0, -19.0) * s
        _flight.texture = flight_frames[frame]
        _specular.texture = flight_frames[frame]
        _flight.position = center
        _specular.position = center
        _flight.scale = Vector2.ONE * s
        _specular.scale = Vector2.ONE * s * 1.016
        _flight.modulate = Color(1.0, 1.0, 1.0, attack * 0.96)
        _specular.modulate = Color("9bffbf", attack * 0.13)
    # Authored FOUR bind poses, separately composited behind/in front of victim.
    # The successfully reviewed flight atlas and projectile timing remain unchanged.
    var binding := bind_gain(elapsed)
    var pose_f := clampf((elapsed - CONTACT_AT) / maxf(0.01, COIL_END - CONTACT_AT), 0.0, 1.0) * float(COIL_POSES - 1)
    var pose_a := mini(COIL_POSES - 1, floori(pose_f))
    var pose_b := mini(COIL_POSES - 1, pose_a + 1)
    var cross := smoothstep(0.68, 1.0, pose_f - float(pose_a)) if pose_b > pose_a else 0.0
    var origin := TARGET + Vector2(3.0 + 2.0 * sin(elapsed * 3.0), -98.0 + 3.0 * sin(elapsed * 4.2))
    var ease_release := smoothstep(COIL_END, DISSOLVE_END, elapsed)
    var zoom := 1.60 * (1.0 - 0.035 * ease_release)
    var back: Array[Sprite2D] = [_back_a, _back_b]
    var front: Array[Sprite2D] = [_front_a, _front_b]
    for i in range(2):
        back[i].visible = binding > 0.009
        front[i].visible = binding > 0.009
        if binding <= 0.009:
            continue
        var pose_id := pose_a if i == 0 else pose_b
        var alpha := binding * (1.0 - cross if i == 0 else cross)
        back[i].texture = _coil_back_frames[pose_id]
        front[i].texture = _coil_front_frames[pose_id]
        back[i].position = origin
        front[i].position = origin
        back[i].rotation = 0.010 * sin(elapsed * 4.2)
        front[i].rotation = back[i].rotation
        back[i].scale = Vector2.ONE * zoom
        front[i].scale = Vector2.ONE * zoom
        back[i].modulate = Color(1.0, 1.0, 1.0, alpha * 0.93)
        front[i].modulate = Color(1.0, 1.0, 1.0, alpha * 0.99)

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed + maxf(0.0, delta), LOOP_SECONDS)
    _update_fx()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        _update_fx()
        queue_redraw()
    elif event.keycode == KEY_P:
        paused = not paused

func _draw() -> void:
    # Dark slate stage, scale comparable to source VL 1x; visual is image-backed.
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280.0, 720.0)), Color("101723"))
    draw_texture_rect(_radial, Rect2(92.0, 130.0, 1100.0, 520.0), false, Color("41685e", 0.18))
    for i in range(9):
        var y := 276.0 + float(i) * 42.0
        draw_line(Vector2(88.0, y), Vector2(1195.0, y + 13.0),
            Color("68847f", 0.075), 1.0)
    for i in range(11):
        var x := 113.0 + float(i) * 111.0
        draw_line(Vector2(x, 244.0), Vector2(x + 92.0, 657.0),
            Color("67747b", 0.08), 1.0)
    for i in range(45):
        var v := float(i)
        var x := 105.0 + fposmod(v * 134.7, 1058.0)
        var y := 285.0 + fposmod(v * 67.3, 331.0)
        draw_circle(Vector2(x, y), 0.72, Color("83a3a0", 0.15))

    var charge := smoothstep(0.08, 0.42, elapsed) * (1.0 - smoothstep(CAST_AT, 0.83, elapsed))
    if charge > 0.005:
        _mote(CASTER + Vector2(18.0, -77.0), 72.0, Color("67f6bd", 0.48 * charge))
        _mote(CASTER + Vector2(18.0, -77.0), 25.0, Color("c7ffdc", 0.45 * charge))
        for n in range(7):
            var a := float(n) * 2.399 + elapsed * 2.0
            var p := CASTER + Vector2(18.0 + cos(a) * 37.0, -81.0 + sin(a) * 28.0)
            _mote(p, 7.0, Color("d9ffb0", 0.36 * charge))

    _actor(CASTER, Color.WHITE)
    _mote(TARGET + Vector2(0.0, 6.0), 52.0, Color("10141b", 0.56))

    if elapsed >= CONTACT_AT and elapsed < CONTACT_AT + 0.14:
        var shock := (elapsed - CONTACT_AT) / 0.14
        _mote(TARGET + Vector2(-8.0, -90.0), 55.0 + 18.0 * shock,
            Color("efffda", 0.40 * (1.0 - shock)))
    var hit_index := impact_frame(elapsed)
    if hit_index >= 0 and _impact_rects.size() >= IMPACT_FRAME_COUNT * 6:
        var q := hit_index * 6
        var rect := Rect2(float(_impact_rects[q]), float(_impact_rects[q+1]),
            float(_impact_rects[q+2]), float(_impact_rects[q+3]))
        if rect.size.x > 1.0 and rect.size.y > 1.0:
            var contact := TARGET + Vector2(0.0, -91.0)
            var pivot := Vector2(float(_impact_rects[q+4]),float(_impact_rects[q+5]))
            var scale_factor := 2.15
            draw_texture_rect_region(JX_IMPACT,
                Rect2(contact - pivot * scale_factor, rect.size * scale_factor), rect,
                Color(1.0, 1.0, 1.0, 0.81))
    var bind := bind_gain(elapsed)
    if bind > 0.005:
        _mote(TARGET + Vector2(0.0, -110.0), 80.0, Color("93efbc", 0.09 * bind))
        _mote(TARGET + Vector2(0.0, -110.0), 36.0, Color("e4fff1", 0.13 * bind))
        for i in range(8):
            var theta := float(i) * 2.399 + elapsed * 0.55
            var pt := TARGET + Vector2(cos(theta) * (45.0 + 6.0 * sin(elapsed*2.0)),
                -111.0 + sin(theta) * 49.0)
            _mote(pt, 11.0, Color("d9ffcc", 0.25 * bind))
    if elapsed >= COIL_END and elapsed <= DISSOLVE_END:
        var fade := clampf((elapsed - COIL_END) / (DISSOLVE_END - COIL_END), 0.0, 1.0)
        for n in range(11):
            var theta := float(n) * 2.399
            var center := TARGET + Vector2(cos(theta) * (27.0 + fade * 85.0),
                -95.0 + sin(theta) * (18.0 + fade * 60.0) - fade * 40.0)
            _mote(center, 8.0 + 4.0 * (1.0-fade),
                Color("c6ffbf", 0.31 * (1.0-fade)))

    draw_string(ThemeDB.fallback_font, Vector2(38.0, 44.0),
        "XA ANH QUAN MACH  /  CO DOC", HORIZONTAL_ALIGNMENT_LEFT,
        -1, 25, Color("e4ffe9"))
    draw_string(ThemeDB.fallback_font, Vector2(38.0, 69.0),
        "ORIGINAL SPRITE FLIPBOOK  /  SOURCE VL LIGHTING REFERENCE",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("8cafb2"))
    draw_string(ThemeDB.fallback_font, Vector2(38.0, 682.0),
        "VFX-POI-02 CLEAN-SHEET  |  GODOT COMPATIBILITY  |  LAB ONLY  |  SPACE REPLAY",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("aac6c1"))

func _mote(p: Vector2, radius: float, tint: Color) -> void:
    draw_texture_rect(_radial,
        Rect2(p - Vector2.ONE * radius, Vector2.ONE * radius * 2.0), false, tint)

func _actor(feet: Vector2, tint: Color) -> void:
    _mote(feet + Vector2(0.0, 6.0), 52.0, Color("10141b", 0.56))
    var s := 0.44
    var pos := feet - Vector2(160.0, 351.0) * s
    draw_texture_rect_region(ACTOR, Rect2(pos, Vector2(320.0, 384.0) * s),
        Rect2(Vector2.ZERO, Vector2(320.0, 384.0)), tint)
