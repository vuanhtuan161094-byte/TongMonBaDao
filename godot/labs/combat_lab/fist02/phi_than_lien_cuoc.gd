extends Control
## FIST02 V4 ART-FIRST — Phi Than Lien Cuoc. The name is an art prompt,
## NOT a command to animate unavailable kicking character poses.
## Stationary real actor stand-in; only first-party sprite energy animates.
## Guard/Fire/Single target, never a damage or hit simulation. No rig.
const SKILL_ID := "tmb.skill.fist.ba_quyen.active_02.human"
const REVISION := "V4_IMAGEGEN_SPRITE_FIRST_GUARD"
const EFFECT := "guard"
const ELEMENT := "fire"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const DECLARED_RANGE := 5.5
const DECLARED_DURATION := 4.0
const DECLARED_POWER := 0.35
const PROJECTILE_SPEED := 0.0
const GUARD_START := 0.45
const GUARD_END := 4.45
const FADE_END := 4.94
const LOOP_END := 5.32
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const SPIRIT_CAST: Texture2D = preload("res://labs/combat_lab/fist02/assets/v4/generated/spirit_cast.png")
const SPIRIT_GUARD: Texture2D = preload("res://labs/combat_lab/fist02/assets/v4/generated/spirit_guard.png")
const ASH: Texture2D = preload("res://labs/combat_lab/fist02/assets/v4/generated/spirit_embers.png")
const CASTER := Vector2(452.0, 544.0)
const OTHER := Vector2(793.0, 544.0)
const SPRITE_ANCHOR := CASTER + Vector2(0.0, -108.0)
var elapsed := 0.0
var paused := false
var glow_tex: Texture2D

static func phase_at(t: float) -> String:
    if t < 0.11:
        return "gather"
    if t < CAST_TIME:
        return "manifest"
    if t < GUARD_END:
        return "spirit_guard"
    if t < FADE_END:
        return "dissolve"
    return "idle"

static func guard_strength(t: float) -> float:
    if t < GUARD_START or t >= FADE_END:
        return 0.0
    return smoothstep(GUARD_START, GUARD_START + 0.12, t) * \
        (1.0 - smoothstep(GUARD_END, FADE_END, t))

static func summon_strength(t: float) -> float:
    if t <= 0.02 or t >= GUARD_START + 0.20:
        return 0.0
    return smoothstep(0.02, 0.09, t) * \
        (1.0 - smoothstep(GUARD_START, GUARD_START + 0.20, t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0, 720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    glow_tex = _feather()
    set_process(true)
    queue_redraw()
    print("VFX_FIST02_READY id=", SKILL_ID, " revision=", REVISION,
        " effect=guard duration=4s frames=28 no_rig=true static_actor=true no_fake_hit=true")

func _feather() -> Texture2D:
    var im := Image.create(80,80,false,Image.FORMAT_RGBA8)
    for y in range(80):
        for x in range(80):
            var p := (Vector2(float(x),float(y))-Vector2(39.5,39.5))/39.5
            var alpha := exp(-6.7*p.length_squared()) * \
                (1.0-smoothstep(0.73,1.0,p.length()))
            im.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(alpha,0,1)))
    return ImageTexture.create_from_image(im)

func _process(delta: float) -> void:
    if paused:
        return
    elapsed = fposmod(elapsed + maxf(delta,0.0), LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        elif event.keycode == KEY_P:
            paused = not paused

func _halo(pos: Vector2, radius: float, tint: Color) -> void:
    draw_texture_rect(glow_tex, Rect2(pos-Vector2.ONE*radius,Vector2.ONE*radius*2.0),false,tint)

func _atlas(tex: Texture2D, idx: int, target: Vector2, scale_factor: float,
        alpha: float, pivot: Vector2=Vector2(160.0,160.0)) -> void:
    var col := idx%4
    var row := int(idx/4)
    draw_set_transform(target,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex, Rect2(-pivot,Vector2(320.0,320.0)),
        Rect2(float(col)*320.0,float(row)*320.0,320.0,320.0),
        Color(1.0,1.0,1.0,alpha))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2, tint: Color) -> void:
    draw_texture_rect_region(ACTOR,
        Rect2(feet-Vector2(70.0,154.0),Vector2(140.0,169.0)),
        Rect2(0.0,0.0,320.0,384.0),tint)

func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BG,Rect2(0.0,0.0,1280.0,720.0),false,Color.WHITE)
    draw_rect(Rect2(0.0,0.0,1280.0,76.0),Color("111522",0.70))
    _halo(CASTER+Vector2(0,17),54.0,Color("483628",0.16))
    _halo(OTHER+Vector2(0,17),54.0,Color("2e2c3a",0.14))
    var summon := summon_strength(t)
    var guard := guard_strength(t)
    # Original first-party illustrated spirit AFTERIMAGES, not character limbs.
    # Layer behind actor; the dummy caster never moves or kicks.
    if summon > 0.004:
        var idx := clampi(int(floor(t/CAST_TIME*12.0)),0,11)
        _halo(SPRITE_ANCHOR,145.0,Color("ffa85a",summon*0.16))
        _atlas(SPIRIT_CAST,idx,SPRITE_ANCHOR+Vector2(9,-7),1.31,summon*0.95)
    # Four-second Hỏa khí protector around exactly one recipient.
    if guard > 0.004:
        var frame := posmod(int(floor((t-GUARD_START)*7.2)),8)
        var pulse := 0.86+0.06*sin(t*7.3)
        _halo(SPRITE_ANCHOR,159.0,Color("f5a959",guard*0.19))
        _atlas(SPIRIT_GUARD,frame,SPRITE_ANCHOR,1.31,guard*pulse)
        _halo(CASTER+Vector2(0,-91),25.0,Color("ffe7af",guard*0.09))
    if t >= 0.04 and t < 1.0:
        var dust_frame := clampi(int(floor(t*8.0)),0,7)
        var dust_alpha := 1.0-smoothstep(0.22,1.0,t)
        _atlas(ASH,dust_frame,CASTER+Vector2(0,10),0.83,dust_alpha*0.75,Vector2(160.0,242.0))
    # Static source actors are visual scale proxies ONLY, no kick animation/rig.
    _actor(CASTER,Color("eee1cd"))
    _actor(OTHER,Color("bac2cc"))
    draw_string(ThemeDB.fallback_font,Vector2(28,33),
        "PHI THAN LIEN CUOC / BA QUYEN",
        HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("fff0d1"))
    draw_string(ThemeDB.fallback_font,Vector2(28,58),
        "FIST02 V4 | PAINTED SPIRIT / FIRE GUARD / ONE RECIPIENT 4s",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e8c6a4"))
    draw_string(ThemeDB.fallback_font,Vector2(28,681),
        "GODOT 4.7.2 COMPATIBILITY | ACTOR STATIONARY | GUARD NOT DAMAGE",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f1d1b0"))
