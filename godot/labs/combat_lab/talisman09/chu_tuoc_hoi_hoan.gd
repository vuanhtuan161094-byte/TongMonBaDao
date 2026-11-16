extends Control
## HF04 Chu Tước Hồi Hoàn. Separate original painterly isolated Combat LAB.
## A SINGLE circle-effect event is VISUALLY represented, not applied to AI/HP.
const SKILL_ID := "tmb.skill.talisman.hoa_phu.active_04.human"
const ELEMENT := "fire"
const EFFECT := "damage"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const HIT_COUNT := 1
const DECLARED_CAST_TIME := .5
const DECLARED_COOLDOWN := 13.6
const DECLARED_RANGE := 8.5
const DECLARED_RADIUS := 2.35
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 0.0

const CASTER := Vector2(297,548)
const HAND := Vector2(397,421)
const CIRCLE_CENTER := Vector2(953,461)
const TARGET_BASE := [Vector2(815,518),Vector2(956,531),Vector2(1094,511)]
const DEMO_PHOENIX_START := .58
const DEMO_CONTACT := 1.60
const DEMO_HIT_END := 1.92
const DEMO_FADE_END := 2.55
const DEMO_LOOP := 3.12
const ORBIT_START := .78
const ORBIT_END := 2.24

const CHARGE:Texture2D = preload("res://labs/combat_lab/talisman09/assets/tal09_r1_charge.webp")
const PHOENIX:Texture2D = preload("res://labs/combat_lab/talisman09/assets/tal09_r1_phoenix.webp")
const ORBIT:Texture2D = preload("res://labs/combat_lab/talisman09/assets/tal09_r1_orbit.webp")
const CONTACT:Texture2D = preload("res://labs/combat_lab/talisman09/assets/tal09_r1_contact.webp")
const BACKDROP:Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER:SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")

var time := .0
var paused := false
var _light:Texture2D

static func target_foot(index:int,t:float)->Vector2:
    if index<0 or index>=TARGET_LIMIT:return Vector2.INF
    var b:Vector2=TARGET_BASE[index]
    # Three DIFFERENT walking stand-in actors; genuine current-position anchors.
    return b+Vector2(36.0*sin(1.85*t+.64*float(index)+.2),
                     10.0*sin(1.55*t+float(index)*.87))

static func target_contact(index:int,t:float)->Vector2:
    return target_foot(index,t)+Vector2(-5.0,-76.0)

static func phase(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge"
    if t<DEMO_PHOENIX_START:return "release"
    if t<DEMO_CONTACT:return "phoenix_orbit"
    if t<DEMO_HIT_END:return "circle_contact"
    if t<DEMO_FADE_END:return "ember_fade"
    return "idle"

static func charge_gain(t:float)->float:
    if t<.02 or t>=.68:return .0
    return smoothstep(.02,.19,t)*(1.0-smoothstep(.49,.68,t))

static func bird_gain(t:float)->float:
    if t<DEMO_PHOENIX_START or t>=2.04:return .0
    return smoothstep(DEMO_PHOENIX_START,.71,t)*(1.0-smoothstep(1.64,2.04,t))

static func bird_center(t:float)->Vector2:
    # An energy-bird orbits the zone: it does NOT constitute a real projectile.
    var q:=clampf((t-DEMO_PHOENIX_START)/1.46,.0,1.0)
    var a:=(-.85+q*1.65)*TAU
    return CIRCLE_CENTER+Vector2(158*cos(a),-81+62*sin(a))

static func bird_angle(t:float)->float:
    var t0:=clampf(t-.004,DEMO_PHOENIX_START,2.04)
    var t1:=clampf(t+.004,DEMO_PHOENIX_START,2.04)
    return (bird_center(t1)-bird_center(t0)).angle()*.20

static func orbit_gain(t:float)->float:
    if t<ORBIT_START or t>=ORBIT_END:return .0
    return smoothstep(ORBIT_START,.98,t)*(1.0-smoothstep(1.87,ORBIT_END,t))

static func contact_gain(t:float)->float:
    if t<DEMO_CONTACT or t>=DEMO_HIT_END:return .0
    return smoothstep(DEMO_CONTACT,DEMO_CONTACT+.042,t) * (1.0-smoothstep(1.73,DEMO_HIT_END,t))

static func charge_frame(t:float)->int:
    return clampi(int(floor(clampf(t/DECLARED_CAST_TIME,0,1)*11.99)),0,11)

static func bird_frame(t:float)->int:
    return clampi(int(floor(clampf((t-DEMO_PHOENIX_START)/1.45,0,1)*15.99)),0,15)

static func orbit_frame(t:float)->int:
    return clampi(int(floor(clampf((t-ORBIT_START)/(ORBIT_END-ORBIT_START),0,1)*11.99)),0,11)

static func hit_frame(t:float)->int:
    return clampi(int(floor(clampf((t-DEMO_CONTACT)/.31,0,1)*9.99)),0,9)

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(x,y)-Vector2(47.5,47.5))/47.5
            var a:=clampf(exp(-8.5*p.length_squared())*(1.0-smoothstep(.78,1,p.length())),0,1)
            im.set_pixel(x,y,Color(1,1,1,a))
    _light=ImageTexture.create_from_image(im)
    print("VFX_TAL09_READY id=",SKILL_ID," stage=HF04_R1_CHU_TUOC_REAL_SPRITES actor_walk=3 contract=circle_cap3_one_hit projectile_speed=0 view_only=true")
    set_process(true)

func _process(delta:float)->void:
    if paused:return
    time=fposmod(time+maxf(delta,0),DEMO_LOOP)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if not e is InputEventKey or not e.pressed or e.echo:return
    if e.keycode==KEY_SPACE:time=.0
    if e.keycode==KEY_P:paused=not paused

func _halo(at:Vector2,r:float,c:Color)->void:
    if c.a<.003:return
    draw_texture_rect(_light,Rect2(at-Vector2.ONE*r,Vector2.ONE*r*2),false,c)

func _atlas(tex:Texture2D,index:int,cw:int,ch:int,region:Rect2,color:Color)->void:
    draw_texture_rect_region(tex,region,Rect2(float(index%4*cw),float(int(index/4)*ch),float(cw),float(ch)),color)

func _draw()->void:
    var t:=time
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    # All substantial painted energy stays behind the moving WALK actors.
    var o:=orbit_gain(t)
    if o>.003:
        var q:=orbit_frame(t)
        _atlas(ORBIT,q,640,340,Rect2(CIRCLE_CENTER-Vector2(322,149),Vector2(644,298)),Color(1,1,1,o*.94))
    var bird:=bird_gain(t)
    if bird>.003:
        var p:=bird_center(t)
        var span:=lerpf(.67,.93,smoothstep(.63,1.2,t))
        draw_set_transform(p,bird_angle(t),Vector2.ONE*span)
        _atlas(PHOENIX,bird_frame(t),512,320,Rect2(-271,-193,542,337),Color(1,1,1,bird*.99))
        draw_set_transform(Vector2.ZERO)
        _halo(p,48,Color("ff8c33",bird*.19))
    # Three monsters are truly moving, max cap3; one simultaneous circle
    # flash only. No fake projectiles or separated fake hits.
    var f:=MONSTER.get_frame_count("walk")
    var hit:=contact_gain(t)
    for k in range(TARGET_LIMIT):
        var foot:=target_foot(k,t)
        var tex:Texture2D=MONSTER.get_frame_texture("walk",int(t*15+float(k)*2.0)%maxi(1,f))
        draw_texture_rect(tex,Rect2(foot-Vector2(61,128),Vector2(122,128)),
            false,Color.WHITE.lerp(Color("ffb378"),hit*.36))
    if hit>.003:
        var idx:=hit_frame(t)
        for k in range(TARGET_LIMIT):
            var at:=target_contact(k,t)
            _atlas(CONTACT,idx,256,256,Rect2(at-Vector2(91,99),Vector2(182,182)),Color(1,1,1,hit*.82))
            _halo(at,23,Color("ff6a2e",hit*.35))
            _halo(at,7,Color("fffbdd",hit*.68))
    draw_texture_rect_region(CASTER_ART,
        Rect2(CASTER-Vector2(72,163),Vector2(144,163)),
        Rect2(0,0,320,384),Color("f6d6bd"))
    var charge:=charge_gain(t)
    if charge>.003:
        var s:=lerpf(223.,292.,smoothstep(.08,.48,t))
        var cen:=HAND+Vector2(16,-17)
        _atlas(CHARGE,charge_frame(t),320,320,
             Rect2(cen-Vector2.ONE*s*.5,Vector2.ONE*s),Color(1,1,1,charge*.96))
        _halo(HAND+Vector2(10,-4),38,Color("ffd86b",charge*.24))
    var ash:=smoothstep(1.80,2.02,t)*(1.0-smoothstep(2.30,DEMO_FADE_END,t))
    if ash>.003:
        for k in range(11):
            var a:=float(k)*2.399963
            var p:=CIRCLE_CENTER+Vector2(cos(a)*(75.+float(k%4)*38.),
                sin(a)*(39.+float(k%3)*21.)-(t-1.8)*38.)
            _halo(p,2.9,Color("ffc364",ash*.27))
