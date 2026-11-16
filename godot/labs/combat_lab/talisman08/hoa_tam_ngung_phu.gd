extends Control
## HF03 Hỏa Tâm Ngưng Phù — independent view-only sprite-first Combat Lab.
## No Combat V2 hit/HP, target selection, SaveService, real PvE or extra hit.
const SKILL_ID := "tmb.skill.talisman.hoa_phu.active_03.human"
const ELEMENT := "fire"
const EFFECT := "damage"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const HIT_COUNT := 1
const DECLARED_CAST_TIME := 0.50
const DECLARED_COOLDOWN := 12.2
const DECLARED_RANGE := 8.5
const DECLARED_PROJECTILE_SPEED := 9.0
const DECLARED_DURATION := 0.0
const CASTER := Vector2(329,547)
const HAND := Vector2(404,427)
const TARGET_BASE := Vector2(906,527)
const DEMO_LAUNCH := 0.52
const DEMO_CONTACT := 1.30
const DEMO_CONTACT_END := 1.81
const DEMO_FADE_END := 2.36
const DEMO_LOOP := 2.85

const CHARGE:Texture2D=preload("res://labs/combat_lab/talisman08/assets/tal08_r1_charge.webp")
const MISSILE:Texture2D=preload("res://labs/combat_lab/talisman08/assets/tal08_r1_projectile.webp")
const IMPACT:Texture2D=preload("res://labs/combat_lab/talisman08/assets/tal08_r1_contact.webp")
const BACKDROP:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")

var time:=0.0
var paused:=false
var _light:Texture2D

static func target_foot(t:float)->Vector2:
    # Same PRESELECTED enemy stand-in, moves during entire animation.
    return TARGET_BASE+Vector2(32.0*sin(t*1.21+.25),10.0*sin(t*1.53+.6))

static func target_contact(t:float)->Vector2:
    return target_foot(t)+Vector2(-6.0,-79.0)

static func phase(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge"
    if t<DEMO_LAUNCH:return "release"
    if t<DEMO_CONTACT:return "travel"
    if t<DEMO_CONTACT_END:return "contact"
    if t<DEMO_FADE_END:return "embers"
    return "idle"

static func charge_gain(t:float)->float:
    if t<0.02 or t>0.62:return 0.0
    return smoothstep(.02,.13,t)*(1.0-smoothstep(.48,.62,t))

static func flight_q(t:float)->float:
    return clampf((t-DEMO_LAUNCH)/(DEMO_CONTACT-DEMO_LAUNCH),0.0,1.0)

static func flight_gain(t:float)->float:
    if t<DEMO_LAUNCH or t>=DEMO_CONTACT:return 0.0
    var q:=flight_q(t)
    return smoothstep(.0,.075,q)*(1.0-smoothstep(.94,1.0,q))

static func missile_at(t:float)->Vector2:
    var q:=flight_q(t)
    var u:=1.0-q
    var p0:=HAND+Vector2(27,-25)
    var p3:=target_contact(t)  # Current enemy position, not static pre-hit point.
    var p1:=p0+Vector2(145,-116)
    var p2:=p3+Vector2(-180,-94)
    return u*u*u*p0+3.0*u*u*q*p1+3.0*u*q*q*p2+q*q*q*p3

static func missile_direction(t:float)->float:
    var a:=missile_at(maxf(DEMO_LAUNCH,t-.004))
    var b:=missile_at(minf(DEMO_CONTACT,t+.004))
    return (b-a).angle()

static func contact_gain(t:float)->float:
    if t<DEMO_CONTACT or t>=DEMO_CONTACT_END:return 0.0
    return smoothstep(DEMO_CONTACT,DEMO_CONTACT+.035,t)*(1.0-smoothstep(1.48,DEMO_CONTACT_END,t))

static func charge_frame(t:float)->int:
    return clampi(int(floor(clampf(t/DECLARED_CAST_TIME,0,1)*11.99)),0,11)

static func flight_frame(t:float)->int:
    return clampi(int(floor(flight_q(t)*15.99)),0,15)

static func impact_frame(t:float)->int:
    return clampi(int(floor(clampf((t-DEMO_CONTACT)/.48,0,1)*9.99)),0,9)

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var pos:Vector2=(Vector2(x,y)-Vector2(47.5,47.5))/47.5
            var alpha:=clampf(exp(-7.7*pos.length_squared())*(1.0-smoothstep(.74,1.0,pos.length())),0.0,1.0)
            im.set_pixel(x,y,Color(1,1,1,alpha))
    _light=ImageTexture.create_from_image(im)
    print("VFX_TAL08_READY id=",SKILL_ID," art=HF03_R1_FIRE_HEART view_only=true locked_monsters=1 real_projectile_speed=9 no_damage_receipts=true")
    set_process(true)

func _process(delta:float)->void:
    if paused:return
    time=fposmod(time+maxf(delta,0.0),DEMO_LOOP)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if not e is InputEventKey or not e.pressed or e.echo:return
    if e.keycode==KEY_SPACE:time=0.0
    if e.keycode==KEY_P:paused=not paused

func _glow(at:Vector2,r:float,c:Color)->void:
    if c.a<.003:return
    draw_texture_rect(_light,Rect2(at-Vector2.ONE*r,Vector2.ONE*r*2),false,c)

func _draw()->void:
    var t:=time
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    var hit:=contact_gain(t)
    if hit>.003:
        var idx:=impact_frame(t)
        var at:=target_contact(t)+Vector2(0,4)
        draw_texture_rect_region(IMPACT,Rect2(at-Vector2(154,123),Vector2(308,246)),
            Rect2(float(idx%4)*320.0,float(int(idx/4))*256.0,320,256),
            Color(1,1,1,hit*.92))
        _glow(at+Vector2(0,11),104,Color("fd7031",hit*.12))
    # Flight sprite is always BEHIND actual living WALK actor.
    var gain:=flight_gain(t)
    if gain>.003:
        var q:=flight_q(t)
        var p:=missile_at(t)
        var idx:=flight_frame(t)
        draw_set_transform(p,missile_direction(t),Vector2.ONE*lerpf(.85,1.05,q))
        draw_texture_rect_region(MISSILE,Rect2(-112,-65,224,130),
            Rect2(float(idx%4)*320.0,float(int(idx/4))*192.0,320,192),
            Color(1,1,1,gain*.96))
        draw_set_transform(Vector2.ZERO)
        _glow(p,27,Color("ffad43",gain*.19))
    draw_texture_rect_region(CASTER_ART,
        Rect2(CASTER-Vector2(72,163),Vector2(144,163)),
        Rect2(0,0,320,384),Color("e5c8bb"))
    var f:=MONSTER.get_frame_count("walk")
    var texture:Texture2D=MONSTER.get_frame_texture("walk",int(t*15.0)%maxi(1,f))
    var foot:=target_foot(t)
    var tint:=Color.WHITE.lerp(Color(1.0,.75,.57),hit*.44)
    draw_texture_rect(texture,Rect2(foot-Vector2(76,139),Vector2(152,139)),false,tint)
    # Localized white-hot body contact over the moving actor, no fake HP/damage.
    if hit>.003:
        var pt:=target_contact(t)
        _glow(pt,26,Color("ff7d36",hit*.30))
        _glow(pt,12,Color("ffe08c",hit*.54))
        _glow(pt,5,Color("fffbe9",hit*.66))
    var cg:=charge_gain(t)
    if cg>.003:
        var frame:=charge_frame(t)
        var size:=lerpf(230.0,268.0,smoothstep(.1,.46,t))
        var center:=HAND+Vector2(9,-23)
        draw_texture_rect_region(CHARGE,
            Rect2(center-Vector2.ONE*size*.5,Vector2.ONE*size),
            Rect2(float(frame%4)*320.0,float(int(frame/4))*320.0,320,320),
            Color(1,1,1,cg))
        _glow(HAND+Vector2(13,-8),37,Color("ffdb6b",cg*.24))
    # Bounded fire-ash flecks: visual residue, never a persistent burn debuff.
    var ash:=smoothstep(1.60,1.82,t)*(1.0-smoothstep(2.08,DEMO_FADE_END,t))
    if ash>.003:
        for k in range(13):
            var angle:=float(k)*2.399
            var p:=target_contact(t)+Vector2(cos(angle)*(13.0+float(k%5)*14.0),
                sin(angle)*(10.0+float(k%4)*9.0)-(t-1.6)*45.0)
            _glow(p,2.5+float(k%2),Color("ffb551",ash*.32))
