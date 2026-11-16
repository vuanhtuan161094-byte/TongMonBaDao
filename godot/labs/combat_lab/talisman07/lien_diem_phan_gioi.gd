extends Control
## HF02 Liên Diệm Phần Giới — independent sprite-first CIRCLE Combat Lab.
## View-only demonstration: no real hit/HP/target acquisition, DoT or PvE.
const SKILL_ID := "tmb.skill.talisman.hoa_phu.active_02.human"
const EFFECT := "damage"
const ELEMENT := "fire"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const HIT_COUNT := 1
const DECLARED_CAST_TIME := 0.62
const DECLARED_COOLDOWN := 10.8
const DECLARED_RANGE := 8.5
const DECLARED_RADIUS := 2.1
const DECLARED_PROJECTILE_SPEED := 0.0

const CASTER := Vector2(329.0, 547.0)
const HAND := Vector2(406.0, 429.0)
const CIRCLE_CENTER := Vector2(925.0, 523.0)
const BLOOM_START := 0.79
const DEMO_HIT_AT := 1.37
const CONTACT_END := 1.72
const FADE_END := 2.62
const LOOP_SECONDS := 3.30

const LOTUS:Texture2D = preload("res://labs/combat_lab/talisman07/assets/tal07_r5_lotus_atlas.webp")
const SEALS:Texture2D = preload("res://labs/combat_lab/talisman07/assets/tal07_r5_seal_atlas.webp")
const GROUND:Texture2D = preload("res://labs/combat_lab/talisman07/assets/tal07_ground_flipbook.webp")
const CONTACT:Texture2D = preload("res://labs/combat_lab/talisman07/assets/tal07_r5_contact_atlas.webp")
const BACKDROP:Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES:SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")

var elapsed := 0.0
var paused := false
var _glow:Texture2D

static func phase_at(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge"
    if t<BLOOM_START:return "ground_awaken"
    if t<DEMO_HIT_AT:return "lotus_bloom"
    if t<CONTACT_END:return "demo_hit"
    if t<FADE_END:return "embers_fade"
    return "idle"

static func demo_target_foot(index:int,t:float)->Vector2:
    # Three PRE-LOCKED monster IDs in a deterministic view-only cluster.
    # The three stand-ins move during charge, hit and fade.
    var offset:=Vector2.ZERO
    match index:
        0:offset=Vector2(-96.0,12.0)
        1:offset=Vector2(6.0,-21.0)
        2:offset=Vector2(102.0,22.0)
        _:return Vector2.INF
    return CIRCLE_CENTER+offset+Vector2(25.0*sin(t*(1.28+float(index)*.19)+float(index)*1.9),
        8.0*sin(t*(1.43+float(index)*.15)+float(index)*1.37))

static func demo_target_contact(index:int,t:float)->Vector2:
    return demo_target_foot(index,t)+Vector2(-5,-79)

static func inside_demo_circle(index:int,t:float)->bool:
    # Pixel projection only for this video harness; 2.1 is a canonical world radius.
    var d:=demo_target_foot(index,t)-CIRCLE_CENTER
    return Vector2(d.x,d.y*2.2).length()<=181.0

static func charge_gain(t:float)->float:
    if t<.02 or t>=.94:return 0.0
    return smoothstep(.02,.18,t)*(1.0-smoothstep(.65,.94,t))

static func bloom_gain(t:float)->float:
    if t<BLOOM_START or t>=FADE_END:return 0.0
    return smoothstep(BLOOM_START,1.09,t)*(1.0-smoothstep(1.74,FADE_END,t))

static func ground_gain(t:float)->float:
    if t<.64 or t>=FADE_END:return 0.0
    return smoothstep(.64,.88,t)*(1.0-smoothstep(1.94,FADE_END,t))

static func hit_gain(index:int,t:float)->float:
    var shift:=float(index)*.028
    var start:=DEMO_HIT_AT+shift
    var end:=CONTACT_END+shift
    if t<start or t>=end:return 0.0
    return smoothstep(start,start+.035,t)*(1.0-smoothstep(start+.09,end,t))

static func lotus_index(t:float)->int:
    return clampi(int(floor(clampf((t-BLOOM_START)/1.39,0,1)*11.99)),0,11)

static func seal_index(t:float)->int:
    return clampi(int(floor(clampf(t/DECLARED_CAST_TIME,0,1)*11.99)),0,11)

static func ground_index(t:float)->int:
    return clampi(int(floor(clampf((t-.64)/1.63,0,1)*7.99)),0,7)

static func contact_index(t:float)->int:
    return clampi(int(floor(clampf((t-DEMO_HIT_AT)/.52,0,1)*7.99)),0,7)

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(80,80,false,Image.FORMAT_RGBA8)
    for y in range(80):
        for x in range(80):
            var p:Vector2=(Vector2(x,y)-Vector2(39.5,39.5))/39.5
            im.set_pixel(x,y,Color(1.0,1.0,1.0,
                clampf(exp(-7.5*p.length_squared())*(1.0-smoothstep(.76,1.0,p.length())),0.0,1.0)))
    _glow=ImageTexture.create_from_image(im)
    print("VFX_TAL07_READY id=",SKILL_ID," rework=R5 source_painted_owner_fire=true frames=12/12/8/8 moving_monsters=3 circle=true view_only=true")
    set_process(true)

func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if not e is InputEventKey or not e.pressed or e.echo:return
    if e.keycode==KEY_SPACE:elapsed=0.0
    elif e.keycode==KEY_P:paused=not paused

func _halo(center:Vector2,r:float,c:Color)->void:
    if c.a<=.003:return
    draw_texture_rect(_glow,Rect2(center-Vector2.ONE*r,Vector2.ONE*(r*2.0)),false,c)

func _draw_caster()->void:
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(72,163),Vector2(144,163)),
        Rect2(0,0,320,384),Color("e5c8bb"))

func _draw_monster(index:int,t:float)->void:
    var f:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",(int(t*15.0)+index*3)%maxi(1,f))
    var foot:=demo_target_foot(index,t)
    var h:=hit_gain(index,t)
    var tint:=Color.WHITE.lerp(Color(1.0,.71,.51,1.0),h*.47)
    draw_texture_rect(tex,Rect2(foot-Vector2(76,139),Vector2(152,139)),false,tint)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    # Back-to-front: ground scorch; painterly lotus; local impacts; real actor sprites.
    var gg:=ground_gain(t)
    if gg>.003:
        var gf:=ground_index(t)
        draw_texture_rect_region(GROUND,
            Rect2(CIRCLE_CENTER-Vector2(248,77),Vector2(496,154)),
            Rect2(float(gf%4)*512.0,float(int(gf/4))*256.0,512,256),
            Color(1,1,1,gg*.44))
    var lg:=bloom_gain(t)
    if lg>.003:
        var lf:=lotus_index(t)
        draw_texture_rect_region(LOTUS,
            Rect2(CIRCLE_CENTER-Vector2(270,390),Vector2(540,460)),
            Rect2(float(lf%4)*512.0,float(int(lf/4))*384.0,512,384),
            Color(1,1,1,lg*.96))
        _halo(CIRCLE_CENTER+Vector2(0,-72),89,Color("ff9635",lg*.11))
    for i in range(TARGET_LIMIT):
        var hg:=hit_gain(i,t)
        if hg>.003:
            var f:=contact_index(t)
            var pos:=demo_target_contact(i,t)+Vector2(0,9)
            draw_texture_rect_region(CONTACT,
                Rect2(pos-Vector2(74,73),Vector2(148,146)),
                Rect2(float(f%4)*256.0,float(int(f/4))*256.0,256,256),
                Color(1,1,1,hg*.96))
    _draw_caster()
    for i in range(TARGET_LIMIT):
        _draw_monster(i,t)
    # The art remains visible behind the actor; only small hot body flashes overlay.
    for i in range(TARGET_LIMIT):
        var hg:=hit_gain(i,t)
        if hg>.003:
            var pos:=demo_target_contact(i,t)+Vector2(0,8)
            _halo(pos,35,Color("f9592a",hg*.31))
            _halo(pos,17,Color("ffcc72",hg*.65))
            _halo(pos,7,Color("fff6d9",hg*.70))
    var charge:=charge_gain(t)
    if charge>.003:
        var f:=seal_index(t)
        var at:=HAND+Vector2(27,-18-13*smoothstep(.14,.60,t))
        draw_set_transform(at,-.16+.09*sin(t*7.0),Vector2.ONE)
        draw_texture_rect_region(SEALS,Rect2(-82,-82,164,164),
            Rect2(float(f%4)*256.0,float(int(f/4))*256.0,256,256),Color(1,1,1,charge))
        draw_set_transform(Vector2.ZERO)
        _halo(HAND+Vector2(8,-6),54,Color("ffb23c",charge*.30))
        for k in range(7):
            var a:=float(k)*2.399
            var q:=clampf(t/.62,0.0,1.0)
            var p:=HAND+Vector2(cos(a)*(86-69*q),sin(a)*(59-43*q))
            _halo(p,4.0,Color("ffd280",charge*.35))
    # Delayed, non-damaging ember motes; no long-lasting burn status.
    var ember:=smoothstep(DEMO_HIT_AT,DEMO_HIT_AT+.14,t)*(1.0-smoothstep(1.95,FADE_END,t))
    if ember>.003:
        for k in range(17):
            var angle:=float(k)*2.399
            var radius:=33+float(k%6)*19+(t-DEMO_HIT_AT)*32
            var p:=CIRCLE_CENTER+Vector2(cos(angle)*radius,
                sin(angle)*radius*.42-34-(t-DEMO_HIT_AT)*37)
            _halo(p,3.5+float(k%3),Color("ffc17c",ember*.18))
