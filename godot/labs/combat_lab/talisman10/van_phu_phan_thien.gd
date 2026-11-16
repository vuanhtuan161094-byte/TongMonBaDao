extends Control
## HF05 Vạn Phù Phần Thiên | separate VFX only Godot 4.7.2 Compatibility LAB.
## Catalogue has ONE circle hit, up to 3 moving targets and ZERO projectiles.
## Paper storm / falling flame are COSMETIC only, not gameplay projectiles.
const SKILL_ID := "tmb.skill.talisman.hoa_phu.ultimate.human"
const ELEMENT := "fire"
const EFFECT := "damage"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const HIT_COUNT := 1
const DECLARED_CAST_TIME := 1.05
const DECLARED_COOLDOWN := 23.0
const DECLARED_RANGE := 9.5
const DECLARED_RADIUS := 2.8
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 0.0
const DAMAGE_RATIO := 1.58

const CASTER := Vector2(301,550)
const HAND := Vector2(394,421)
const CIRCLE_CENTER := Vector2(949,474)
const TARGET_BASE := [Vector2(809,514),Vector2(957,521),Vector2(1085,506)]
const CHARGE_END := 1.00
const STORM_START := .59
const STORM_END := 1.90
const RAIN_START := 1.19
const RAIN_END := 2.03
const CONTACT_START := 1.85
const CONTACT_END := 2.17
const FADE_END := 2.74
const DEMO_LOOP := 3.35

const CHARGE:Texture2D=preload("res://labs/combat_lab/talisman10/assets/tal10_r1_charge.webp")
const STORM:Texture2D=preload("res://labs/combat_lab/talisman10/assets/tal10_r1_storm.webp")
const RAIN:Texture2D=preload("res://labs/combat_lab/talisman10/assets/tal10_r1_rain.webp")
const IMPACT:Texture2D=preload("res://labs/combat_lab/talisman10/assets/tal10_r1_impact.webp")
const BACKDROP:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")

var time:=0.0
var paused:=false
var _light:Texture2D

static func target_foot(index:int,t:float)->Vector2:
    if index<0 or index>=TARGET_LIMIT:return Vector2.INF
    var b:Vector2=TARGET_BASE[index]
    return b+Vector2(37.0*sin(1.82*t+index*.88+.17),
                   13.0*sin(1.37*t+index*.62+.24))

static func target_contact(index:int,t:float)->Vector2:
    return target_foot(index,t)+Vector2(-5,-75)

static func phase(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge_and_storm"
    if t<RAIN_START:return "heavenly_seal_storm"
    if t<CONTACT_START:return "cosmetic_flame_rain"
    if t<CONTACT_END:return "one_circle_contact"
    if t<FADE_END:return "residue"
    return "idle"

static func charge_gain(t:float)->float:
    if t<.02 or t>=CHARGE_END:return 0.0
    return smoothstep(.02,.18,t)*(1.0-smoothstep(.78,CHARGE_END,t))

static func storm_gain(t:float)->float:
    if t<STORM_START or t>=STORM_END:return 0.0
    return smoothstep(STORM_START,.81,t)*(1.0-smoothstep(1.68,STORM_END,t))

static func rain_gain(t:float)->float:
    if t<RAIN_START or t>=RAIN_END:return 0.0
    return smoothstep(RAIN_START,1.37,t)*(1.0-smoothstep(1.87,RAIN_END,t))

static func impact_gain(t:float)->float:
    if t<CONTACT_START or t>=CONTACT_END:return 0.0
    return smoothstep(CONTACT_START,CONTACT_START+.04,t)*(1.0-smoothstep(2.02,CONTACT_END,t))

static func charge_frame(t:float)->int:
    return clampi(int(floor(clampf(t/CHARGE_END,0,1)*15.99)),0,15)

static func storm_frame(t:float)->int:
    return clampi(int(floor(clampf((t-STORM_START)/(STORM_END-STORM_START),0,1)*23.99)),0,23)

static func rain_frame(t:float)->int:
    return clampi(int(floor(clampf((t-RAIN_START)/(RAIN_END-RAIN_START),0,1)*19.99)),0,19)

static func impact_frame(t:float)->int:
    return clampi(int(floor(clampf((t-CONTACT_START)/.22,0,1)*11.99)),0,11)

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(x,y)-Vector2(47.5,47.5))/47.5
            var a:=clampf(exp(-8.6*p.length_squared())*(1.0-smoothstep(.78,1,p.length())),0,1)
            im.set_pixel(x,y,Color(1,1,1,a))
    _light=ImageTexture.create_from_image(im)
    print("VFX_TAL10_READY id=",SKILL_ID," art=HF05_R4_GIANT_SIGIL_ULTIMATE frames=16/24/20/12 moving_monsters=3 real_projectile_speed=0 circle_hit_count=1 view_only=true")
    set_process(true)

func _process(delta:float)->void:
    if paused:return
    time=fposmod(time+maxf(delta,0),DEMO_LOOP)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if not e is InputEventKey or not e.pressed or e.echo:return
    if e.keycode==KEY_SPACE:time=0.0
    if e.keycode==KEY_P:paused=not paused

func _halo(at:Vector2,r:float,c:Color)->void:
    if c.a<.002:return
    draw_texture_rect(_light,Rect2(at-Vector2.ONE*r,Vector2.ONE*r*2),false,c)

func _atlas(tex:Texture2D,index:int,cw:int,ch:int,rect:Rect2,col:Color)->void:
    draw_texture_rect_region(tex,rect,Rect2(float(index%4*cw),float(int(index/4)*ch),float(cw),float(ch)),col)

func _draw()->void:
    var t:=time
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    var storm:=storm_gain(t)
    if storm>.003:
        var p:=CIRCLE_CENTER+Vector2(0,-118+9*sin(t*6))
        _atlas(STORM,storm_frame(t),640,384,
            Rect2(p-Vector2(291,169),Vector2(582,338)),Color(1,1,1,storm*.98))
        _halo(CIRCLE_CENTER+Vector2(0,-160),96,Color("ffba59",storm*.17))
    var rain:=rain_gain(t)
    if rain>.003:
        var area:=CIRCLE_CENTER+Vector2(0,-77)
        _atlas(RAIN,rain_frame(t),640,440,
            Rect2(area-Vector2(267,192),Vector2(534,348)),Color(1,1,1,rain*.98))
    # R4: a single giant original illustrated master sigil stays recognizable
    # during the ONE circle pulse. Purely visual, behind WALK actors, not a hit.
    var royal_scroll:=smoothstep(1.63,1.84,t)*(1.0-smoothstep(2.04,2.20,t))
    if royal_scroll>.003:
        var q:=smoothstep(1.63,2.07,t)
        var hero_center:=CIRCLE_CENTER+Vector2(0,lerpf(-213.0,-150.0,q))
        var hero_size:=lerpf(335.0,440.0,q)
        _atlas(CHARGE,15,320,320,
            Rect2(hero_center-Vector2.ONE*hero_size*.5,Vector2.ONE*hero_size),
            Color(1,1,1,royal_scroll*.89))
        _halo(hero_center+Vector2(0,-26),72,Color("ffb74d",royal_scroll*.16))
    var hit:=impact_gain(t)
    if hit>.003:
        _atlas(IMPACT,impact_frame(t),640,320,
            Rect2(CIRCLE_CENTER-Vector2(311,166),Vector2(622,302)),Color(1,1,1,hit*.94))
        _halo(CIRCLE_CENTER+Vector2(0,-31),116,Color("ff8238",hit*.29))
    # Real three WALK monster sprites (different phases), deliberately drawn
    # AFTER broad fire effects, so faces/body do not disappear.
    var frames:=MONSTER.get_frame_count("walk")
    for k in range(TARGET_LIMIT):
        var foot:=target_foot(k,t)
        var texture:Texture2D=MONSTER.get_frame_texture("walk",(int(t*15)+k*3)%maxi(1,frames))
        draw_texture_rect(texture,Rect2(foot-Vector2(64,131),Vector2(128,131)),false,
            Color.WHITE.lerp(Color("ffcb88"),hit*.36))
    # ONE area hit, small local glints only. They never spawn hit receipts.
    if hit>.003:
        for k in range(TARGET_LIMIT):
            var at:=target_contact(k,t)
            _halo(at,26,Color("ff8c38",hit*.36))
            _halo(at,11,Color("ffe59f",hit*.80))
            _halo(at,5,Color("fff9dc",hit*.88))
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(72,163),Vector2(144,163)),
        Rect2(0,0,320,384),Color("f2d5bb"))
    var charge:=charge_gain(t)
    if charge>.003:
        var s:=lerpf(240.0,284.0,smoothstep(.21,.84,t))
        var p:=HAND+Vector2(11,-19)
        _atlas(CHARGE,charge_frame(t),320,320,Rect2(p-Vector2.ONE*s*.5,Vector2.ONE*s),
            Color(1,1,1,charge))
        _halo(HAND+Vector2(12,-6),45,Color("ffe48f",charge*.22))
    var ash:=smoothstep(2.05,2.26,t)*(1.0-smoothstep(2.52,FADE_END,t))
    if ash>.003:
        for k in range(15):
            var angle:=float(k)*2.39996
            var p:=CIRCLE_CENTER+Vector2(cos(angle)*(67+float(k%5)*27),
                 sin(angle)*(41+float(k%3)*19)-(t-2.0)*42)
            _halo(p,2.7,Color("ffc66e",ash*.26))
