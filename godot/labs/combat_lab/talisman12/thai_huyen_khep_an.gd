extends Control
## PAF02 Thái Huyền Khép Ấn — visual-only WIND LINE to up to three preselected targets.
## The 5.5-second mark is a separate debuff state, NOT 5.5 seconds of casting VFX.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.active_02.human"
const ELEMENT := "wind"
const EFFECT := "mark"
const SHAPE := "line"
const TARGET_LIMIT := 3
const HIT_COUNT := 1
const DECLARED_RANGE := 9.0
const DECLARED_CAST_TIME := 0.5
const DECLARED_COOLDOWN := 10.8
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 5.5
const DECLARED_RADIUS := 0.0
const DECLARED_DAMAGE_RATIO := 0.6
const HAND := Vector2(388, 424)
const CASTER := Vector2(304, 548)
const APPLY_SIMULATED := 0.78
const VFX_FADE_END := 1.58
const MOVIE_LOOP := 2.20
const CHARGE: Texture2D = preload("res://labs/combat_lab/talisman12/assets/paf02_charge.webp")
const LINE: Texture2D = preload("res://labs/combat_lab/talisman12/assets/paf02_line.webp")
const CONTACT: Texture2D = preload("res://labs/combat_lab/talisman12/assets/paf02_contact.webp")
const BADGE: Texture2D = preload("res://labs/combat_lab/talisman12/assets/paf02_badge.webp")
const BACKDROP: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var time := 0.0
var paused := false
var _light: Texture2D

static func target_foot(index: int, t: float) -> Vector2:
    if index < 0 or index >= TARGET_LIMIT: return Vector2.INF
    return Vector2(635.0 + 207.0 * float(index) + 23.0 * sin(t * 1.47 + float(index) * 1.48), 517.0 + 9.0 * sin(t * 1.83 + float(index) * 1.91))
static func target_contact(index: int, t: float) -> Vector2:
    return target_foot(index, t) + Vector2(0, -88)
static func badge_anchor(index: int, t: float) -> Vector2:
    return target_foot(index, t) + Vector2(0, -155)
static func status_active(index: int, t: float) -> bool:
    return index >= 0 and index < TARGET_LIMIT and t >= APPLY_SIMULATED and t < APPLY_SIMULATED + DECLARED_DURATION
static func charge_gain(t: float) -> float:
    if t < .02 or t >= .55: return 0.0
    return smoothstep(.02, .18, t) * (1.0 - smoothstep(.43, .55, t))
static func line_gain(t: float) -> float:
    if t < .48 or t >= 1.06: return 0.0
    return smoothstep(.48, .63, t) * (1.0 - smoothstep(.87, 1.06, t))
static func contact_gain(t: float) -> float:
    if t < APPLY_SIMULATED or t >= 1.23: return 0.0
    return smoothstep(APPLY_SIMULATED, .87, t) * (1.0 - smoothstep(1.08, 1.23, t))
static func gesture_active(t: float) -> bool:
    return t >= .02 and t < VFX_FADE_END
static func visual_phase(t: float) -> String:
    if t < DECLARED_CAST_TIME: return "charge"
    if t < APPLY_SIMULATED: return "seal_line"
    if t < 1.23: return "mark_contact"
    if t < VFX_FADE_END: return "residual"
    return "gesture_finished_status_independent"

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    var im := Image.create(96, 96, false, Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p: Vector2 = (Vector2(x, y) - Vector2(47.5, 47.5)) / 47.5
            var a := clampf(exp(-8.8 * p.length_squared()) * (1.0 - smoothstep(.78, 1.0, p.length())), 0, 1)
            im.set_pixel(x, y, Color(1, 1, 1, a))
    _light = ImageTexture.create_from_image(im)
    print("VFX_PAF02_READY id=", SKILL_ID, " moving_targets=3 mark_5_5_separate=true cast_0_5=true projectile_0=true view_only=true")
    set_process(true)
func _process(delta: float) -> void:
    if paused: return
    time = fposmod(time + maxf(delta, 0.0), MOVIE_LOOP)
    queue_redraw()
func _glow(p: Vector2, r: float, col: Color) -> void:
    if col.a > .003: draw_texture_rect(_light, Rect2(p - Vector2.ONE * r, Vector2.ONE * r * 2), false, col)
func _cell(tex: Texture2D, i: int, w: int, h: int, rect: Rect2, col: Color) -> void:
    draw_texture_rect_region(tex, rect, Rect2(i % 4 * w, int(i / 4) * h, w, h), col)
func _flip(tex: Texture2D, frames: int, w: int, h: int, progress: float, rect: Rect2, col: Color) -> void:
    var f := clampf(progress, 0, 1) * float(frames - 1)
    var i := int(floor(f))
    var j := mini(frames - 1, i + 1)
    var alpha := f - float(i)
    if j == i or alpha < .005:
        _cell(tex, i, w, h, rect, col)
    else:
        _cell(tex, i, w, h, rect, Color(col.r, col.g, col.b, col.a * sqrt(1.0 - alpha)))
        _cell(tex, j, w, h, rect, Color(col.r, col.g, col.b, col.a * sqrt(alpha)))
func _draw() -> void:
    var t := time
    draw_texture_rect(BACKDROP, Rect2(0, 0, 1280, 720), false)
    var n := MONSTER.get_frame_count("walk")
    for i in range(TARGET_LIMIT):
        var foot := target_foot(i, t)
        var texture: Texture2D = MONSTER.get_frame_texture("walk", (int(t * 15) + i * 3) % maxi(1, n))
        _glow(foot + Vector2(0, -6), 38, Color("68d7ba", .055))
        draw_texture_rect(texture, Rect2(foot - Vector2(57, 127), Vector2(114, 127)), false)
    var wind := line_gain(t)
    if wind > .004:
        var end := target_contact(2, t)
        var v := end - HAND
        draw_set_transform(HAND, v.angle(), Vector2.ONE)
        _flip(LINE, 18, 512, 256, clampf((t - .48) / .58, 0, 1), Rect2(0, -66, v.length(), 132), Color(1, 1, 1, wind * .90))
        draw_set_transform(Vector2.ZERO)
    var imprint := contact_gain(t)
    if imprint > .004:
        for i in range(TARGET_LIMIT):
            var p := target_contact(i, t)
            var local: float = clampf((t - APPLY_SIMULATED) / .45, 0, 1)
            _flip(CONTACT, 12, 256, 256, local, Rect2(p - Vector2(57, 60), Vector2(114, 120)), Color(1, 1, 1, imprint * .88))
            _glow(p, 23, Color("e0ffed", imprint * .19))
    # LAB-only debuff icons. On integration these MUST subscribe to actual Combat V2 status receipts.
    for i in range(TARGET_LIMIT):
        if status_active(i, t):
            var p := badge_anchor(i, t)
            _flip(BADGE, 8, 128, 128, fposmod(t * 2.8 + float(i) * .27, 7.0) / 7.0, Rect2(p - Vector2(21, 21), Vector2(42, 42)), Color(1, 1, 1, .67))
    draw_texture_rect_region(CASTER_ART, Rect2(CASTER - Vector2(72, 163), Vector2(144, 163)), Rect2(0, 0, 320, 384), Color("e5d7ca"))
    var charge := charge_gain(t)
    if charge > .004:
        var center := HAND + Vector2(22, -14)
        var sz := 232.0 + 28.0 * smoothstep(.08, .46, t)
        _flip(CHARGE, 14, 320, 320, clampf(t / .50, 0, 1), Rect2(center - Vector2.ONE * sz * .5, Vector2.ONE * sz), Color(1, 1, 1, charge * .94))
        _glow(HAND + Vector2(7, -5), 39, Color("beffe8", charge * .22))
