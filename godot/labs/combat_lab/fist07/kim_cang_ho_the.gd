extends Control
## FIST07 — Kim Cang Ho The / Kim Cang Human, PURE-GOLD WARD.
## EARTH guard for ONE recipient, 4 seconds after 0.45 cast.
## Original RGBA sprite art + narrow contact flash. VIEW ONLY: no damage/status.
## No rig, body/weapon transformation, gameplay receipt, or movement spoofing.
const SKILL_ID := "tmb.skill.fist.kim_cang.active_02.human"
const ART_REVISION := "R2_LIVING_PLASMA_GOLD_WARD"
const EFFECT := "guard"
const ELEMENT := "earth"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 5.5
const DECLARED_DURATION := 4.0
const DECLARED_POWER := 0.35
const PROJECTILE_SPEED := 0.0
const GUARD_START := 0.45
const GUARD_END := 4.45
const FADE_END := 4.85
const LOOP_END := 5.28
const HIT_DURATION := 0.24
const ATLAS_RAW_RGBA_BYTES := 6291456
const DEMO_BLOCK_TIMES := [1.29,3.12]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WARD: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/gold_ward.png")
const BLOCK: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/guarded_hit.png")
const CASTER := Vector2(465.0,553.0)
const DUMMY := Vector2(827.0,553.0)
const WARD_CENTER := CASTER + Vector2(0.0,-110.0)
const BLOCK_ANCHOR := CASTER + Vector2(60.0,-101.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false
var manual_blocks: Array[float] = []
var bloom: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_TIME:
        return "ward_manifest"
    if t < GUARD_END:
        return "guard_active"
    if t < FADE_END:
        return "ward_dissolve"
    return "clear"

static func guard_alpha(t: float) -> float:
    if t < GUARD_START or t >= FADE_END:
        return 0.0
    return smoothstep(GUARD_START, GUARD_START + 0.09,t) * (1.0 - smoothstep(GUARD_END,FADE_END,t))

static func block_alpha(t: float, block_at: float) -> float:
    if block_at < GUARD_START or block_at > GUARD_END:
        return 0.0
    var age := t-block_at
    if age < 0.0 or age >= HIT_DURATION:
        return 0.0
    return smoothstep(0.0,0.026,age) * (1.0-smoothstep(0.07,HIT_DURATION,age))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0,720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    bloom = _bloom()
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST07_R2_READY id=",SKILL_ID,
            " guard=true earth=true single_target=true cast=0.45 duration=4",
            " atlas_frames=24 two_textures=true no_rig=true view_only=true")

func _bloom() -> Texture2D:
    var im := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var d := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a := exp(-5.8*d.length_squared())*(1.0-smoothstep(0.77,1.0,d.length()))
            im.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(a,0.0,1.0)))
    return ImageTexture.create_from_image(im)

func _process(delta: float) -> void:
    if paused: return
    var before := elapsed
    elapsed = fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    if elapsed<before:
        manual_blocks.clear()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        manual_blocks.clear()
        queue_redraw()
    elif event.keycode==KEY_P:
        paused=not paused
    elif event.keycode==KEY_H:
        # Manual LAB simulation: does NOT mean gameplay accepted the hit.
        if elapsed>=GUARD_START and elapsed<GUARD_END:
            manual_blocks.append(elapsed)
            if manual_blocks.size()>6:
                manual_blocks.pop_front()
            queue_redraw()

func _atlas(tex: Texture2D,frame: int,pos: Vector2,
        scale_factor: float,opacity: float,pivot: Vector2=Vector2(128.0,128.0)) -> void:
    var col := frame%4
    var row := int(frame/4)
    draw_set_transform(pos,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-pivot,Vector2(256.0,256.0)),
        Rect2(float(col)*256.0,float(row)*256.0,256.0,256.0),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _glow(pos: Vector2,radius: float,alpha: float) -> void:
    draw_texture_rect(bloom,Rect2(pos-Vector2.ONE*radius,Vector2.ONE*radius*2.0),
        false,Color(1.0,.83,.28,clampf(alpha,0.0,1.0)))

func _actor(feet: Vector2,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,
        Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(0.0,0.0,320.0,384.0),tint)

func _block_intensity(t: float) -> float:
    var result := 0.0
    for event_at in DEMO_BLOCK_TIMES:
        result=maxf(result,block_alpha(t,event_at))
    for event_at in manual_blocks:
        result=maxf(result,block_alpha(t,event_at))
    return result

func _draw() -> void:
    var t := elapsed
    var shield:=guard_alpha(t)
    var impact:=_block_intensity(t)
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280.0,720.0),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280.0,76.0),Color("151522",0.71))
        _glow(CASTER+Vector2(0,16),66.0,.16)
        _glow(DUMMY+Vector2(0,16),52.0,.11)
    # The original frame-by-frame HERO texture is the dominant visual layer.
    if t<CAST_TIME:
        var q:=clampf(t/CAST_TIME,0.0,1.0)
        var frame:=clampi(int(floor(q*4.0)),0,3)
        _glow(WARD_CENTER,81.0,.06+.13*q)
        _atlas(WARD,frame,WARD_CENTER,1.02+.09*q,.52+.48*q)
    elif t<FADE_END:
        var idx:=4+posmod(int(floor((t-GUARD_START)*8.8)),8)
        if t>=GUARD_END:
            idx=12+clampi(int(floor((t-GUARD_END)/(FADE_END-GUARD_END)*4.0)),0,3)
        var breathe:=.93+.055*sin(t*6.3)
        _glow(WARD_CENTER,115.0,shield*.14)
        _atlas(WARD,idx,WARD_CENTER,1.13,shield*breathe)
    # Characters are the same unmodified idle atlas, for composition QA only.
    if not vfx_only_benchmark:
        _actor(CASTER,Color.WHITE.lerp(Color("fffbdf"),impact*.28))
        _actor(DUMMY,Color("bac2c8"))
    # Demo protected-hit response: instant, localized, no outgoing damage cue.
    if impact > 0.003 and t>=GUARD_START and t<GUARD_END:
        _glow(BLOCK_ANCHOR,66.0,impact*.90)
        var event_age:=0.0
        var active:=false
        for event_at in DEMO_BLOCK_TIMES:
            if t>=event_at and t<event_at+HIT_DURATION:
                event_age=t-event_at
                active=true
        for event_at in manual_blocks:
            if t>=event_at and t<event_at+HIT_DURATION:
                event_age=t-event_at
                active=true
        if active:
            var f:=clampi(int(floor(event_age/HIT_DURATION*8.0)),0,7)
            _atlas(BLOCK,f,BLOCK_ANCHOR,1.23,impact,Vector2(171.0,119.0))
    if not vfx_only_benchmark:
        draw_string(ThemeDB.fallback_font,Vector2(28.0,32.0),
            "KIM CANG HO THE  /  QUYEN TU",HORIZONTAL_ALIGNMENT_LEFT,-1,24,
            Color("fff2d4"))
        draw_string(ThemeDB.fallback_font,Vector2(28.0,58.0),
            "FIST07 R2 | GOLD-PLASMA WARD + GUARDED-HIT RESPONSE / 4 SECONDS",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e9cca1"))
        draw_string(ThemeDB.fallback_font,Vector2(28.0,682.0),
            "GODOT 4.7.2 COMPATIBILITY | GUARD ONLY | DEMO BLOCKS | NO RIG",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f7dab7"))
