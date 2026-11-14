extends Control
## FIST01: Khai Son Trong Quyen, ORIGINAL 24 sprite-frame qi + feathered light.
## View-only lab: this preview contact is not a Combat V2 hit or damage event.
## NO RIG, NO GAMEPLAY/HP/STATUS/TARGET/PVE INTEGRATION.
const SKILL_ID := "tmb.skill.fist.ba_quyen.active_01.human"
const EFFECT := "damage"
const ELEMENT := "fire"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST := 0.45
const DECLARED_RANGE := 2.8
const CASTER := Vector2(448.0, 541.0)
const VICTIM := Vector2(752.0, 541.0)
const HAND := Vector2(510.0, 490.0)
const CONTACT := Vector2(713.0, 484.0)
const CAST_END := 0.45
const RELEASE_END := 0.52
const CONTACT_AT := 0.79
const IMPACT_END := 1.17
const FADE_END := 1.63
const LOOP_SECONDS := 2.30
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const CHARGE = [
    preload("res://labs/combat_lab/fist01/assets/qi_charge_00.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_charge_01.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_charge_02.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_charge_03.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_charge_04.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_charge_05.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_charge_06.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_charge_07.svg"),
]
const FLIGHT = [
    preload("res://labs/combat_lab/fist01/assets/qi_flight_00.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_flight_01.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_flight_02.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_flight_03.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_flight_04.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_flight_05.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_flight_06.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_flight_07.svg"),
]
const IMPACT = [
    preload("res://labs/combat_lab/fist01/assets/qi_impact_00.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_impact_01.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_impact_02.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_impact_03.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_impact_04.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_impact_05.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_impact_06.svg"),
    preload("res://labs/combat_lab/fist01/assets/qi_impact_07.svg"),
]
var elapsed := 0.0
var paused := false
var _glow: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_END:
        return "charge"
    if t < RELEASE_END:
        return "release"
    if t < CONTACT_AT:
        return "flight"
    if t < IMPACT_END:
        return "impact"
    if t < FADE_END:
        return "dissolve"
    return "idle"

static func flight_at(t: float) -> float:
    if t <= RELEASE_END:
        return 0.0
    return smoothstep(RELEASE_END, CONTACT_AT, t)

static func charge_gain(t: float) -> float:
    if t >= RELEASE_END:
        return 0.0
    return smoothstep(0.06, 0.38, t) * (1.0 - smoothstep(CAST_END, RELEASE_END, t))

static func impact_gain(t: float) -> float:
    if t < CONTACT_AT or t >= FADE_END:
        return 0.0
    return smoothstep(CONTACT_AT, CONTACT_AT + 0.065, t) * (1.0 - smoothstep(IMPACT_END, FADE_END, t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0, 720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _glow = _radial()
    set_process(true)
    queue_redraw()
    print("VFX_FIST01_READY | ", SKILL_ID, " | sprite_frames=24 | no_rig=true | gameplay=false")

func _radial() -> Texture2D:
    var img := Image.create(80, 80, false, Image.FORMAT_RGBA8)
    for y in range(80):
        for x in range(80):
            var p := (Vector2(float(x), float(y)) - Vector2(39.5, 39.5)) / 39.5
            var alpha := exp(-6.7 * p.length_squared()) * (1.0 - smoothstep(0.7, 1.0, p.length()))
            img.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if paused:
        return
    elapsed = fposmod(elapsed + maxf(0.0, delta), LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        queue_redraw()
    elif event.keycode == KEY_P:
        paused = not paused

func _halo(p: Vector2, radius: float, tint: Color) -> void:
    draw_texture_rect(_glow, Rect2(p - Vector2.ONE * radius,
        Vector2.ONE * radius * 2.0), false, tint)

func _paint(tex: Texture2D, origin: Vector2, scale_factor: float,
        alpha: float, pivot: Vector2 = Vector2(160.0, 160.0)) -> void:
    draw_set_transform(origin, 0.0, Vector2.ONE * scale_factor)
    draw_texture_rect(tex, Rect2(-pivot, Vector2(320.0, 320.0)), false,
        Color(1.0, 1.0, 1.0, alpha))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _actor(feet: Vector2, tint: Color) -> void:
    var crop := Rect2(0.0, 0.0, 320.0, 384.0)
    var sc := 0.44
    var dest := Rect2(feet - Vector2(160.0, 351.0) * sc, crop.size * sc)
    draw_texture_rect_region(ACTOR, dest, crop, tint)

func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BG, Rect2(0.0, 0.0, 1280.0, 720.0), false, Color.WHITE)
    draw_rect(Rect2(0.0, 0.0, 1280.0, 79.0), Color("0d1120", 0.73))
    _halo(CASTER + Vector2(0, 14), 58.0, Color("271d24", 0.32))
    _halo(VICTIM + Vector2(0, 15), 56.0, Color("271d24", 0.32))
    var ch := charge_gain(t)
    if ch > 0.005:
        _halo(HAND, 55.0, Color("f5a25d", ch * 0.25))
        _halo(HAND, 21.0, Color("fff2be", ch * 0.42))
    var flight := t >= RELEASE_END and t < CONTACT_AT
    var q := flight_at(t)
    if flight:
        var tip := HAND.lerp(CONTACT, q)
        _halo(tip + Vector2(-34.0, 1.0), 83.0, Color("f49a58", 0.22))
        _halo(tip, 28.0, Color("fff2cc", 0.34))
    var hit := impact_gain(t)
    if hit > 0.008:
        _halo(CONTACT, 111.0, Color("fc9554", hit * 0.30))
        _halo(CONTACT, 58.0, Color("fff2b5", hit * 0.46))
    # Existing game atlas is just a 1x-scale dummy silhouette, not fist actor approval.
    _actor(CASTER, Color("ede2d1"))
    _actor(VICTIM, Color("c4ccd1"))
    if ch > 0.005:
        var frame := clampi(int(floor(t / CAST_END * float(CHARGE.size()))), 0, CHARGE.size() - 1)
        _paint(CHARGE[frame], HAND, 0.51, ch * 0.92)
    if flight:
        var tip := HAND.lerp(CONTACT, q)
        var frame := clampi(int(floor(q * float(FLIGHT.size()))), 0, FLIGHT.size() - 1)
        # The authored flight frame's tip is at image x ~= 250.
        _paint(FLIGHT[frame], tip, 1.00, 0.97, Vector2(280.0, 154.0))
        for j in range(4):
            var old := t - 0.034 * float(j + 1)
            if old <= RELEASE_END:
                continue
            var echo := HAND.lerp(CONTACT, flight_at(old))
            _halo(echo + Vector2(-23, 0), 40.0 - 3.0 * float(j),
                Color("ffa467", 0.16 - 0.026 * float(j)))
    if hit > 0.008:
        var frame := clampi(int(floor((t - CONTACT_AT) / (FADE_END - CONTACT_AT) *
            float(IMPACT.size()))), 0, IMPACT.size() - 1)
        var spread := 0.77 + 0.43 * smoothstep(CONTACT_AT, IMPACT_END, t)
        _paint(IMPACT[frame], CONTACT, spread, hit * 0.84)
        var fade_q := clampf((t - CONTACT_AT) / (FADE_END - CONTACT_AT), 0.0, 1.0)
        for j in range(9):
            var a := float(j) * 2.399
            var r := 29.0 + (46.0 + float(j % 3) * 12.0) * fade_q
            var p := CONTACT + Vector2(cos(a) * r, sin(a) * r * 0.63)
            _halo(p, 4.0 + 3.0 * (1.0 - fade_q), Color("ffd085", 0.17 * hit))
    draw_string(ThemeDB.fallback_font, Vector2(29, 36), "KHAI SON TRONG QUYEN / BA QUYEN",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("fff0d5"))
    draw_string(ThemeDB.fallback_font, Vector2(29, 62),
        "FIST01 | ORIGINAL 24 SPRITE FRAMES | FIRE / SINGLE TARGET",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("e8c1a2"))
    draw_string(ThemeDB.fallback_font, Vector2(29, 683),
        "GODOT 4.7.2 COMPATIBILITY | LAB VISUAL ONLY | NO DAMAGE / V63 OFF",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("eecbab"))
