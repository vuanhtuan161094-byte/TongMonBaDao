extends Control
## PAF05 — Thái Huyền Phong Giới Phù, original visual-only Wind CIRCLE MARK.
## CANONICAL: circle radius2.1, up to 3 targets; cast .9s, mark lasts7s,
## cooldown23s, projectile0. All event receipts are LAB-only simulation.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.ultimate.human"
const EFFECT := "mark"
const ELEMENT := "wind"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const HIT_COUNT := 1
const DECLARED_RANGE := 9.0
const DECLARED_RADIUS := 2.1
const DECLARED_CAST_TIME := 0.9
const DECLARED_COOLDOWN := 23.0
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 7.0
const DECLARED_DAMAGE_RATIO := 0.56
const DECLARED_POWER := 1.22
const SIMULATED_MARK_RECEIPT := 1.33
const VISUAL_FADE_END := 2.35
const MOVIE_LOOP := 2.67
const CASTER_POS := Vector2(315, 554)
const HAND_POS := Vector2(392, 423)
const AREA_FOOT := Vector2(818, 534)
const CHARGE:Texture2D=preload("res://labs/combat_lab/talisman15/assets/paf05_charge.webp")
const WARD:Texture2D=preload("res://labs/combat_lab/talisman15/assets/paf05_ward.webp")
const HERO:Texture2D=preload("res://labs/combat_lab/talisman15/assets/paf05_hero.webp")
const CONTACT:Texture2D=preload("res://labs/combat_lab/talisman15/assets/paf05_contact.webp")
const RESIDUE:Texture2D=preload("res://labs/combat_lab/talisman15/assets/paf05_residue.webp")
const BADGE:Texture2D=preload("res://labs/combat_lab/talisman15/assets/paf05_badge.webp")
const BACKDROP:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var time:=0.0
var paused:=false
var _light:Texture2D

static func target_foot(index:int,t:float)->Vector2:
    if index<0 or index>=TARGET_LIMIT:return Vector2.INF
    return Vector2(697.0 + 116.0*float(index) + 25.0*sin(t*(1.4+.17*float(index))+.62*float(index)),
            518.0 + 10.0*sin(t*1.81+float(index)*1.43))
static func target_contact(index:int,t:float)->Vector2:
    return target_foot(index,t)+Vector2(0,-85)
static func badge_anchor(index:int,t:float)->Vector2:
    return target_foot(index,t)+Vector2(0,-147)
static func within_circle(index:int,t:float)->bool:
    if index<0 or index>=TARGET_LIMIT:return false
    var p:Vector2=target_foot(index,t)
    return p.distance_to(AREA_FOOT)<=170.0 # LAB projection of 2.1 units ONLY
static func simulated_mark_active(index:int,t:float)->bool:
    return within_circle(index,t) and t>=SIMULATED_MARK_RECEIPT and t<SIMULATED_MARK_RECEIPT+DECLARED_DURATION
static func charge_gain(t:float)->float:
    if t<.035 or t>=1.00:return 0.0
    return smoothstep(.035,.22,t)*(1.0-smoothstep(.81,1.00,t))
static func field_gain(t:float)->float:
    if t<.73 or t>=2.28:return 0.0
    return smoothstep(.73,1.12,t)*(1.0-smoothstep(1.92,2.28,t))
static func hero_gain(t:float)->float:
    if t<.70 or t>=VISUAL_FADE_END:return 0.0
    return smoothstep(.70,1.05,t)*(1.0-smoothstep(2.02,VISUAL_FADE_END,t))
static func contact_gain(t:float)->float:
    if t<SIMULATED_MARK_RECEIPT or t>=1.81:return 0.0
    return smoothstep(SIMULATED_MARK_RECEIPT,1.46,t)*(1.0-smoothstep(1.66,1.81,t))
static func residue_gain(t:float)->float:
    if t<1.64 or t>=2.53:return 0.0
    return smoothstep(1.64,1.85,t)*(1.0-smoothstep(2.23,2.53,t))
static func visual_phase(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge"
    if t<SIMULATED_MARK_RECEIPT:return "wind_seal_forming"
    if t<1.81:return "circle_mark_contact"
    if t<VISUAL_FADE_END:return "wind_seal_residue"
    return "mark_status_only"
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var img:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for yy in range(96):
        for xx in range(96):
            var p:Vector2=(Vector2(xx,yy)-Vector2(47.5,47.5))/47.5
            var alpha:=clampf(exp(-8.0*p.length_squared())*(1.0-smoothstep(.73,1.0,p.length())),0.0,1.0)
            img.set_pixel(xx,yy,Color(1.0,1.0,1.0,alpha))
    _light=ImageTexture.create_from_image(img)
    print("VFX_PAF05_READY id=",SKILL_ID," circle_cap=3 moving_monsters=3 mark7s_status_only=true view_only=true receipt=SIMULATED")
    set_process(true)
func _process(delta:float)->void:
    if paused:return
    time=fposmod(time+maxf(delta,0.0),MOVIE_LOOP)
    queue_redraw()
func _cell(tex:Texture2D,k:int,w:int,h:int,rect:Rect2,color:Color)->void:
    draw_texture_rect_region(tex,rect,Rect2(k%4*w,int(k/4)*h,w,h),color)
func _flip(tex:Texture2D,n:int,w:int,h:int,progress:float,rect:Rect2,color:Color)->void:
    var idx:=clampf(progress,0.,1.)*float(n-1)
    var a:=int(floor(idx))
    var b:=mini(a+1,n-1)
    var sub:=idx-float(a)
    if a==b or sub<.006:_cell(tex,a,w,h,rect,color)
    else:
        _cell(tex,a,w,h,rect,Color(color.r,color.g,color.b,color.a*sqrt(1.-sub)))
        _cell(tex,b,w,h,rect,Color(color.r,color.g,color.b,color.a*sqrt(sub)))
func _draw()->void:
    var t:=time
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    var floor:Vector2=AREA_FOOT
    var field:=field_gain(t)
    if field>.003:
        _flip(WARD,16,512,512,clampf((t-.73)/1.48,0,1),
              Rect2(floor-Vector2(244,139),Vector2(488,238)),Color(1,1,1,field*.85))
    # R2 art repair: aerial seal BEHIND all WALK monsters; targets readable at native 1x.
    var hero:=hero_gain(t)
    if hero>.003:
        _flip(HERO,20,480,480,clampf((t-.70)/1.62,0.,1.),
              Rect2(floor-Vector2(190,359),Vector2(380,307)),Color(1,1,1,hero*.91))
    var count:=MONSTER.get_frame_count("walk")
    for k in range(TARGET_LIMIT):
        var p:=target_foot(k,t)
        var texture:Texture2D=MONSTER.get_frame_texture("walk",(int(t*14.0)+k*3)%maxi(1,count))
        draw_texture_rect(texture,Rect2(p-Vector2(48,124),Vector2(96,124)),false)
    var hit:=contact_gain(t)
    if hit>.003:
        for k in range(TARGET_LIMIT):
            if not within_circle(k,t):continue
            var p:=target_contact(k,t)
            _flip(CONTACT,12,256,256,clampf((t-SIMULATED_MARK_RECEIPT)/.48,0,1),
                  Rect2(p-Vector2(59,67),Vector2(118,130)),Color(1,1,1,hit*.91))
            draw_texture_rect(_light,Rect2(p-Vector2(25,25),Vector2(50,50)),false,Color("fff6d6",hit*.14))
    var residual:=residue_gain(t)
    if residual>.003:
        _flip(RESIDUE,8,256,256,clampf((t-1.64)/.88,0,1),
              Rect2(floor-Vector2(160,193),Vector2(320,235)),Color(1,1,1,residual*.76))
    # The 7-second MARK is a separate small HUD-like enemy cue, not a 7s movie.
    for k in range(TARGET_LIMIT):
        if simulated_mark_active(k,t):
            var p:=badge_anchor(k,t)
            _flip(BADGE,8,128,128,fposmod(t*2.4+float(k)*.3,1.0),
                  Rect2(p-Vector2(19,19),Vector2(38,38)),Color(1,1,1,.75))
    draw_texture_rect_region(CASTER,Rect2(CASTER_POS-Vector2(72,163),Vector2(144,163)),Rect2(0,0,320,384),Color("f3e8dc"))
    var charge:=charge_gain(t)
    if charge>.003:
        _flip(CHARGE,12,320,320,clampf(t/.88,0,1),
              Rect2(HAND_POS+Vector2(-148,-164),Vector2(296,296)),Color(1,1,1,charge*.92))
        draw_texture_rect(_light,Rect2(HAND_POS-Vector2(33,33),Vector2(66,66)),false,Color("d5fff0",charge*.21))
