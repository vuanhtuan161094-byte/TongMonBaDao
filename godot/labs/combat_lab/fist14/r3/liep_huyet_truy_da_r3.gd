extends Control
## FIST14 R3 LAB ONLY. Frame-based VFX; synthetic target; no gameplay status/damage.
## Gate: the scene refuses to run without all four original-source atlases.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_04.human"
const EFFECT := "mark"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const DECLARED_DURATION := 6.0
const PROJECTILE_SPEED := 0.0
const HIT_COUNT_DECLARED := false
const RELEASE_TIME := 0.45
const CONTACT_TIME := 0.82
const CONTACT_END := 1.22
const MARK_END := CONTACT_TIME + DECLARED_DURATION
const FADE_END := 7.11
const LOOP_END := 7.43
const ASSET_ROOT := "res://labs/combat_lab/fist14/r3/assets/atlases/"
const ASSET_NAMES := ["f14_charge.png", "f14_flight.png", "f14_contact.png", "f14_mark.png"]
const ATLAS_COUNTS := [8, 12, 8, 8]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed := 0.0
var paused := false
var _textures: Array[Texture2D] = []

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "gather"
    if t < CONTACT_TIME: return "punch_flight"
    if t < CONTACT_END: return "one_contact"
    if t < MARK_END: return "one_mark_sustain"
    if t < FADE_END: return "mark_fade"
    return "idle"

static func caster_at(t: float) -> Vector2:
    return Vector2(431.0 + 26.0 * smoothstep(0.37, 0.69, t) * (1.0 - smoothstep(1.18, 1.49, t)), 550.0)

static func foe_at(t: float) -> Vector2:
    return Vector2(806.0 - 67.0 * smoothstep(0.16, 1.13, t) + 32.0 * smoothstep(2.40, 4.0, t) - 23.0 * smoothstep(5.0, 6.4, t), 545.0)

static func mark_at(target_index: int, t: float) -> Vector2:
    if target_index != 0: return Vector2(-9999, -9999)
    return foe_at(t) + Vector2(19, -65)

static func contact_at(t: float) -> Vector2:
    return mark_at(0, t) + Vector2(-43, 5)

static func fist_at(t: float) -> Vector2:
    var q: float = smoothstep(RELEASE_TIME, CONTACT_TIME, clampf(t, RELEASE_TIME, CONTACT_TIME))
    return (caster_at(t) + Vector2(61, -107)).lerp(contact_at(t), q)

static func mark_opacity(t: float) -> float:
    if t < CONTACT_TIME or t >= FADE_END: return 0.0
    return smoothstep(CONTACT_TIME, CONTACT_TIME + 0.12, t) * (1.0 - smoothstep(MARK_END, FADE_END, t))

static func impact_opacity(t: float) -> float:
    if t < CONTACT_TIME or t >= CONTACT_END: return 0.0
    return smoothstep(CONTACT_TIME, CONTACT_TIME + 0.035, t) * (1.0 - smoothstep(CONTACT_TIME + 0.13, CONTACT_END, t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    for name in ASSET_NAMES:
        var path: String = ASSET_ROOT + name
        if not ResourceLoader.exists(path):
            push_error("FIST14_R3_G3_SOURCE_TRANSFER_BLOCKED path=" + path)
            get_tree().quit(4)
            return
        var item := load(path)
        if not item is Texture2D:
            push_error("FIST14_R3_G3_INVALID_ATLAS path=" + path)
            get_tree().quit(4)
            return
        _textures.append(item)
    var expected := [Vector2i(1280,640), Vector2i(1280,960), Vector2i(1280,640), Vector2i(1280,640)]
    for i in range(4):
        if Vector2i(_textures[i].get_size()) != expected[i]:
            push_error("FIST14_R3_ATLAS_DIMENSIONS_FAIL index=" + str(i))
            get_tree().quit(4)
            return
    print("FIST14_R3_G35_NATIVE_READY view_only=true one_mark=true no_rig=true")

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed + maxf(0.0, delta), LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE: elapsed = 0.0
        elif event.keycode == KEY_P: paused = not paused

func _cell(tex: Texture2D, index: int, position: Vector2, scale: float, opacity: float) -> void:
    if opacity <= 0.002: return
    var n := clampi(index, 0, 1000)
    var c := 320.0
    draw_set_transform(position, 0.0, Vector2.ONE * scale)
    draw_texture_rect_region(tex, Rect2(-160, -160, 320, 320),
        Rect2(float(n % 4) * c, float(int(n / 4)) * c, c, c),
        Color(1, 1, 1, clampf(opacity, 0.0, 1.0)))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _flip(tex: Texture2D, count: int, position_in_sequence: float, location: Vector2, scale: float, opacity: float) -> void:
    if opacity <= 0.002: return
    var q := clampf(position_in_sequence, 0.0, float(count - 1))
    var index := clampi(int(floor(q)), 0, count - 1)
    var next_index := mini(index + 1, count - 1)
    var mix_value := smoothstep(0.0, 1.0, q - float(index))
    _cell(tex, index, location, scale, opacity * (1.0 - mix_value))
    if next_index != index:
        _cell(tex, next_index, location, scale, opacity * mix_value)

func _actor(feet: Vector2) -> void:
    draw_texture_rect_region(IDLE, Rect2(feet - Vector2(69, 151), Vector2(138, 169)),
        Rect2(0, 0, 320, 384), Color.WHITE)

func _monster(feet: Vector2, t: float) -> void:
    var count := MONSTER_FRAMES.get_frame_count("walk")
    var tex: Texture2D = MONSTER_FRAMES.get_frame_texture("walk", int(floor(t * 13.0)) % maxi(1, count))
    draw_texture_rect(tex, Rect2(feet - Vector2(76, 139), Vector2(152, 139)), false, Color.WHITE)

func _draw() -> void:
    if _textures.size() != 4: return
    var t := elapsed
    draw_texture_rect(BG, Rect2(0, 0, 1280, 720), false, Color.WHITE)
    var caster := caster_at(t)
    var foe := foe_at(t)
    if t < 0.51:
        var gain := smoothstep(0.0, 0.12, t) * (1.0 - smoothstep(0.39, 0.51, t))
        _flip(_textures[0], 8, 7.0 * t / CAST_TIME, caster + Vector2(78, -69), 0.82, gain)
    if t >= CAST_TIME and t < CONTACT_TIME:
        var q := clampf((t - CAST_TIME) / (CONTACT_TIME - CAST_TIME), 0.0, 1.0)
        _flip(_textures[1], 12, 11.0 * q, fist_at(t), 1.04, smoothstep(0.0, 0.08, q) * (1.0 - smoothstep(0.90, 1.0, q)))
    _actor(caster)
    _monster(foe, t)
    if t >= CONTACT_TIME and t < CONTACT_END:
        var q := clampf((t - CONTACT_TIME) / (CONTACT_END - CONTACT_TIME), 0.0, 1.0)
        _flip(_textures[2], 8, 7.0 * q, contact_at(t), 0.62, impact_opacity(t))
    if mark_opacity(t) > 0.002:
        _flip(_textures[3], 8, fposmod((t - CONTACT_TIME) * 5.2, 8.0), mark_at(0, t), 1.04, mark_opacity(t))
