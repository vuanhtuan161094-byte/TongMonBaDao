extends Control
## FIST06 — Trấn Địa Quyền / Kim Cang Human / Earth single target.
## Original painted mineral sprite-first pressure and one localized contact.
## READ-ONLY Godot 4.7.2 Combat LAB. No rig, no HP damage or combat receipt.
const SKILL_ID := "tmb.skill.fist.kim_cang.active_01.human"
const DISPLAY_NAME := "Trấn Địa Quyền"
const ART_REVISION := "R3_PAINTERLY_MINERAL_LIGHT"
const EFFECT := "damage"
const ELEMENT := "earth"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const PROJECTILE_SPEED := 8.0
const DAMAGE_RATIO := 1.35
const HIT_AT := 0.72
const HIT_END := 1.10
const FADE_END := 1.28
const LOOP_END := 1.68
const ATLAS_RAW_RGBA_BYTES := 6291456
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const HERO: Texture2D = preload("res://labs/combat_lab/fist06/assets/generated/earth_fist_main.png")
const HIT: Texture2D = preload("res://labs/combat_lab/fist06/assets/generated/earth_fist_hit.png")
const CASTER := Vector2(405.0,553.0)
const DEMO_TARGET := Vector2(746.0,549.0)
const HAND := Vector2(493.0,458.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false
var glow_tex: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_TIME:
        return "charge"
    if t < HIT_AT:
        return "earth_fist_travel"
    if t < HIT_END:
        return "single_target_contact"
    if t < FADE_END:
        return "dust_settle"
    return "clear"

static func contact_alpha(t: float) -> float:
    var age := t-HIT_AT
    if age < 0.0 or age >= .39:
        return 0.0
    return smoothstep(0.0,.038,age) * (1.0-smoothstep(.12,.39,age))

static func recoil(t: float) -> float:
    var age:=t-HIT_AT
    if age<0.0 or age>.37:
        return 0.0
    return 22.0*smoothstep(.014,.07,age)*(1.0-smoothstep(.19,.37,age))

static func target_position(t: float) -> Vector2:
    return DEMO_TARGET+Vector2(14.0*sin(t*2.70),3.0*sin(t*1.4))

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    glow_tex=_feather_texture()
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST06_R3_READY id=",SKILL_ID," effect=damage element=earth cap=1 frames=24 textures=2 no_rig=true view_only=true")

func _feather_texture() -> Texture2D:
    var image := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var distance := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var value := exp(-5.2*distance.length_squared())*(1.0-smoothstep(.75,1.0,distance.length()))
            image.set_pixel(x,y,Color(1,1,1,clampf(value,0.0,1.0)))
    return ImageTexture.create_from_image(image)

func _process(delta: float) -> void:
    if paused:
        return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark:
        return
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode==KEY_P:
        paused=not paused

func _atlas(texture: Texture2D, frame: int, at: Vector2,
        scale_factor: float, alpha: float, pivot: Vector2=Vector2(206.0,129.0)) -> void:
    var col:=frame%4
    var row:=int(frame/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(texture,Rect2(-pivot,Vector2(256,256)),
        Rect2(float(col)*256.0,float(row)*256.0,256.0,256.0),
        Color(1.0,1.0,1.0,clampf(alpha,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _glow(position: Vector2,radius: float,opacity: float) -> void:
    draw_texture_rect(glow_tex,Rect2(position-Vector2.ONE*radius,Vector2.ONE*radius*2.0),
        false,Color(.95,.78,.47,opacity))

func _actor(feet: Vector2,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(0,0,320,384),tint)

func _draw() -> void:
    var t:=elapsed
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280.0,720.0),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280.0,73.0),Color("1b1820",.77))
    var target_foot:=target_position(t)+Vector2(recoil(t),0.0)
    var chest:=target_position(t)+Vector2(0.0,-92.0)
    var alpha:=contact_alpha(t)
    # Base dust and light remain behind both actors, never another giant AOE.
    if t < CAST_TIME:
        var charge:=clampf(t/CAST_TIME,0.0,1.0)
        _glow(HAND,53.0,.15+.14*charge)
        _atlas(HERO,clampi(int(floor(charge*4.0)),0,3),HAND,
            .47+.21*charge,.53+.43*charge)
    elif t < HIT_AT:
        var flight:=clampf((t-CAST_TIME)/(HIT_AT-CAST_TIME),0.0,1.0)
        var eased:=1.0-pow(1.0-flight,2.8)
        var head:=HAND.lerp(chest,eased)
        var idx:=4+clampi(int(floor(flight*12.0)),0,11)
        # A tiny motion smear using the SAME atlas, no extra textures.
        var previous:=HAND.lerp(chest,maxf(0.0,eased-.11))
        _atlas(HERO,idx,previous,.78,.19)
        _atlas(HERO,idx,head,1.02,.99)
    if alpha>.001:
        _glow(chest,65.0,alpha*.55)
    if not vfx_only_benchmark:
        _actor(CASTER,Color("e9e5dc"))
        _actor(target_foot,Color.WHITE.lerp(Color("f7eccd"),alpha*.56))
    # Single receiver: one physical impact and short recoil, not an AOE.
    if t>=HIT_AT and t < FADE_END:
        var age:=t-HIT_AT
        var frame:=clampi(int(floor(age/(FADE_END-HIT_AT)*8.0)),0,7)
        var fade:=1.0-smoothstep(HIT_END,FADE_END,t)
        _atlas(HIT,frame,chest+Vector2(0,8),1.02,.96*fade,Vector2(128,136))
        if age<.12:
            _glow(chest,54.0,(1.0-smoothstep(.025,.12,age))*.44)
    if not vfx_only_benchmark:
        draw_string(ThemeDB.fallback_font,Vector2(27,33),
            "TRAN DIA QUYEN / KIM CANG",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("f9e6cb"))
        draw_string(ThemeDB.fallback_font,Vector2(28,58),
            "FIST06 R3 | ROCK FIST / PIGMENT LIGHT | ONE CONTACT",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("d4c5b4"))
        draw_string(ThemeDB.fallback_font,Vector2(28,683),
            "GODOT 4.7.2 COMPATIBILITY | VIEW ONLY | 24 FRAMES / 2 ATLASES | NO RIG",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e5c9a3"))
