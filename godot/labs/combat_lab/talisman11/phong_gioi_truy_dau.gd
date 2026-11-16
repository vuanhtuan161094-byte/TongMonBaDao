extends Control
## Phong Giới Truy Dấu PAF01 — isolated visual LAB only.
## A mark on ONE moving enemy for 6s. NOT an attack / projectile / AoE.
## Visual timestamps are demo-only. Runtime mark receipts remain unknown.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.active_01.human"
const ELEMENT := "wind"
const EFFECT := "mark"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const HIT_COUNT := 1
const DECLARED_RANGE := 8.5
const DECLARED_CAST_TIME := 0.5
const DECLARED_COOLDOWN := 9.4
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 6.0
const DECLARED_RADIUS := 0.0
const DECLARED_DAMAGE_RATIO := 0.72
const HAND := Vector2(390,424)
const CASTER := Vector2(304,548)
const MARK_RECEIPT_SIMULATED := 1.15
const MARK_EXPIRES_SIMULATED := 7.15
const MOVIE_LOOP := 8.0
const RELEASE_START := .51
const RELEASE_END := 1.12
const CONTACT_END := 1.52

const CHARGE:Texture2D=preload("res://labs/combat_lab/talisman11/assets/tal11_r1_charge.webp")
const STREAM:Texture2D=preload("res://labs/combat_lab/talisman11/assets/tal11_r1_stream.webp")
const CONTACT:Texture2D=preload("res://labs/combat_lab/talisman11/assets/tal11_r1_contact.webp")
const MARK:Texture2D=preload("res://labs/combat_lab/talisman11/assets/tal11_r1_mark.webp")
const BACKDROP:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")

var time:=0.0
var paused:=false
var _light:Texture2D

static func target_foot(index:int,t:float)->Vector2:
    if index!=0:return Vector2.INF
    return Vector2(916.0+41.0*sin(.94*t-1.10),519.0+13.0*sin(1.27*t+.18))

static func target_contact(index:int,t:float)->Vector2:
    return target_foot(index,t)+Vector2(0,-89)

static func mark_icon(index:int,t:float)->Vector2:
    return target_foot(index,t)+Vector2(0,-164.0+3.0*sin(t*2.1))

static func phase(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge"
    if t<MARK_RECEIPT_SIMULATED:return "visual_wind_transfer"
    if t<CONTACT_END:return "mark_receipt_light"
    if t<MARK_EXPIRES_SIMULATED:return "six_second_mark_sustain"
    return "mark_expiry_fade"

static func charge_gain(t:float)->float:
    if t<.02 or t>=.60:return 0.0
    return smoothstep(.02,.19,t)*(1.0-smoothstep(.44,.60,t))

static func stream_gain(t:float)->float:
    if t<RELEASE_START or t>=RELEASE_END:return 0.0
    return smoothstep(RELEASE_START,.71,t)*(1.0-smoothstep(1.00,RELEASE_END,t))

static func contact_gain(t:float)->float:
    if t<MARK_RECEIPT_SIMULATED or t>=CONTACT_END:return 0.0
    return smoothstep(MARK_RECEIPT_SIMULATED,1.23,t)*(1.0-smoothstep(1.36,CONTACT_END,t))

static func mark_gain(t:float)->float:
    if t<MARK_RECEIPT_SIMULATED:return 0.0
    if t<MARK_EXPIRES_SIMULATED:
        return smoothstep(MARK_RECEIPT_SIMULATED,1.33,t)
    return 1.0-smoothstep(MARK_EXPIRES_SIMULATED,7.51,t)

static func mark_active(t:float)->bool:
    # Actual status gate is the catalogue duration, NOT its alpha tail.
    return t>=MARK_RECEIPT_SIMULATED and t<MARK_EXPIRES_SIMULATED

static func charge_frame(t:float)->int:
    return clampi(int(clampf(t/.55,0,1)*11.99),0,11)
static func stream_frame(t:float)->int:
    return clampi(int(clampf((t-RELEASE_START)/(RELEASE_END-RELEASE_START),0,1)*15.99),0,15)
static func contact_frame(t:float)->int:
    return clampi(int(clampf((t-MARK_RECEIPT_SIMULATED)/(CONTACT_END-MARK_RECEIPT_SIMULATED),0,1)*11.99),0,11)
static func mark_frame(t:float)->int:
    return clampi(int(fposmod(t*11.0,20.0)),0,19)

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(x,y)-Vector2(47.5,47.5))/47.5
            var a:=clampf(exp(-8.8*p.length_squared())*(1.0-smoothstep(.78,1.0,p.length())),0,1)
            im.set_pixel(x,y,Color(1,1,1,a))
    _light=ImageTexture.create_from_image(im)
    print("VFX_TAL11_READY id=",SKILL_ID," PhongAn PAF01_R2_FLYING_ORIGINAL_PAPER view_only=true target_moving=true mark_duration=6.0 projectile_speed=0 no_damage_receipts=true")
    set_process(true)

func _process(delta:float)->void:
    if paused:return
    time=fposmod(time+maxf(delta,0.0),MOVIE_LOOP)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if not e is InputEventKey or not e.pressed or e.echo:return
    if e.keycode==KEY_SPACE:time=0
    if e.keycode==KEY_P:paused=not paused

func _glow(pos:Vector2,r:float,color:Color)->void:
    if color.a<.004:return
    draw_texture_rect(_light,Rect2(pos-Vector2.ONE*r,Vector2.ONE*r*2),false,color)

func _cell(tex:Texture2D,i:int,w:int,h:int,dst:Rect2,col:Color)->void:
    draw_texture_rect_region(tex,dst,Rect2(i%4*w,int(i/4)*h,w,h),col)

func _blended(tex:Texture2D,frames:int,w:int,h:int,f:float,dst:Rect2,col:Color)->void:
    var pos:=clampf(f,0,float(frames-1))
    var i:=int(floor(pos))
    var j:=mini(frames-1,i+1)
    var b:=pos-float(i)
    if i==j or b<.005:
        _cell(tex,i,w,h,dst,col)
    else:
        _cell(tex,i,w,h,dst,Color(col.r,col.g,col.b,col.a*sqrt(1.0-b)))
        _cell(tex,j,w,h,dst,Color(col.r,col.g,col.b,col.a*sqrt(b)))

func _draw()->void:
    var t:=time
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    # Genuine independent walking actor: apply no HP, damage or gameplay mark.
    var foot:=target_foot(0,t)
    var n:=MONSTER.get_frame_count("walk")
    var texture:Texture2D=MONSTER.get_frame_texture("walk",int(t*15)%maxi(1,n))
    draw_texture_rect(texture,Rect2(foot-Vector2(61,129),Vector2(122,129)),false)
    # Source-painted marking trace is view-only. Catalogue projectile_speed
    # is ZERO; this does not instantiate or claim a real gameplay projectile.
    var wind:=stream_gain(t)
    if wind>.003:
        var start:=HAND+Vector2(6,-16)
        var end:=target_contact(0,t)
        var vec:=end-start
        draw_set_transform(start,vec.angle(),Vector2.ONE)
        _blended(STREAM,16,512,256,clampf((t-RELEASE_START)/(RELEASE_END-RELEASE_START),0,1)*15.0,
            Rect2(0,-90,vec.length(),180),Color(1,1,1,wind*.98))
        draw_set_transform(Vector2.ZERO)
        _glow(end,30,Color("79f9ec",wind*.14))
    # Tiny arrival imprint on target chest (one mark application, zero damage).
    var arrival:=contact_gain(t)
    if arrival>.003:
        var p:=target_contact(0,t)
        _blended(CONTACT,12,256,256,clampf((t-MARK_RECEIPT_SIMULATED)/(CONTACT_END-MARK_RECEIPT_SIMULATED),0,1)*11,
            Rect2(p-Vector2(72,74),Vector2(144,144)),Color(1,1,1,arrival*.78))
        _glow(p,24,Color("b8fff2",arrival*.32))
    # The wind seal tracks current WALK actor position for exactly six 
    # simulated status seconds. Long sustain ≠ six-second cast.
    var m:=mark_gain(t)
    if m>.003:
        var p:=mark_icon(0,t)
        var size:=146.0+4.0*sin(t*3.4)
        _blended(MARK,20,256,256,fposmod(t*7.9,19.0),
            Rect2(p-Vector2.ONE*size*.5,Vector2.ONE*size),
            Color(1,1,1,m*.96))
        _glow(p,45,Color("76eada",m*.12))
        # One small stable wind-linked tag cue; no invented shield/stun/DoT.
        _glow(target_contact(0,t)+Vector2(0,11),17,Color("74d7d1",m*.085))
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(72,163),Vector2(144,163)),
        Rect2(0,0,320,384),Color("e5d7ca"))
    var c:=charge_gain(t)
    if c>.003:
        var scale:=lerpf(225.0,271.0,smoothstep(.08,.47,t))
        var p:=HAND+Vector2(9,-18)
        _blended(CHARGE,12,320,320,clampf(t/.55,0,1)*11,
            Rect2(p-Vector2.ONE*scale*.5,Vector2.ONE*scale),
            Color(1,1,1,c*.96))
        _glow(HAND+Vector2(8,-6),41,Color("a5faee",c*.24))
