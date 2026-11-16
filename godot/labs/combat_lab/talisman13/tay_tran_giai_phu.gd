extends Control
## PAF03 Tẩy Trần Giải Phù — instant visual-only WIND CLEANSE on ONE WALK ally.
## Illustration of a pre-existing dark curse is not an actual gameplay status.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.active_03.human"
const EFFECT := "cleanse"
const ELEMENT := "wind"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const HIT_COUNT := 1
const DECLARED_RANGE := 8.5
const DECLARED_RADIUS := 0.0
const DECLARED_CAST_TIME := 0.5
const DECLARED_COOLDOWN := 12.2
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 0.0
const DECLARED_DAMAGE_RATIO := 0.0
const HAND := Vector2(392,424)
const CASTER := Vector2(304,548)
const CLEANSE_RECEIPT_SIMULATED := 0.85
const VFX_FADE_END := 1.53
const MOVIE_LOOP := 2.0
const CHARGE:Texture2D=preload("res://labs/combat_lab/talisman13/assets/paf03_charge.webp")
const WIND:Texture2D=preload("res://labs/combat_lab/talisman13/assets/paf03_transfer.webp")
const CURSE:Texture2D=preload("res://labs/combat_lab/talisman13/assets/paf03_curse.webp")
const CLEANSE:Texture2D=preload("res://labs/combat_lab/talisman13/assets/paf03_cleanse.webp")
const RESIDUE:Texture2D=preload("res://labs/combat_lab/talisman13/assets/paf03_residue.webp")
const BACKDROP:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const ALLY:SpriteFrames=preload("res://assets/actors/1113028_1/animations.tres")
var time:=0.0
var paused:=false
var _light:Texture2D
static func target_foot(index:int,t:float)->Vector2:
    if index!=0:return Vector2.INF
    return Vector2(909.0+47.0*sin(t*1.6-.8),516.0+8.0*sin(t*2.03+.5))
static func target_contact(index:int,t:float)->Vector2:
    return target_foot(index,t)+Vector2(0,-88)
static func cleanse_applied_in_demo(t:float)->bool:
    return t>=CLEANSE_RECEIPT_SIMULATED
static func charge_gain(t:float)->float:
    if t<.03 or t>=.56:return 0.0
    return smoothstep(.03,.17,t)*(1.0-smoothstep(.43,.56,t))
static func transfer_gain(t:float)->float:
    if t<.47 or t>=.92:return 0.0
    return smoothstep(.47,.59,t)*(1.0-smoothstep(.80,.92,t))
static func cleanse_gain(t:float)->float:
    if t<CLEANSE_RECEIPT_SIMULATED or t>=1.28:return 0.0
    return smoothstep(CLEANSE_RECEIPT_SIMULATED,.92,t)*(1.0-smoothstep(1.12,1.28,t))
static func curse_gain(t:float)->float:
    if t>=.96:return 0.0
    return 1.0-smoothstep(.79,.96,t)
static func residue_gain(t:float)->float:
    if t<1.08 or t>=VFX_FADE_END:return 0.0
    return smoothstep(1.08,1.19,t)*(1.0-smoothstep(1.38,VFX_FADE_END,t))
static func phase(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge"
    if t<CLEANSE_RECEIPT_SIMULATED:return "wind_purifying_transfer"
    if t<1.28:return "instant_cleanse_on_moving_ally"
    if t<VFX_FADE_END:return "residual_light"
    return "visual_finished_no_persistent_cleanse"
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(x,y)-Vector2(47.5,47.5))/47.5
            var a:=clampf(exp(-8.9*p.length_squared())*(1.0-smoothstep(.77,1.0,p.length())),0,1)
            im.set_pixel(x,y,Color(1,1,1,a))
    _light=ImageTexture.create_from_image(im)
    print("VFX_PAF03_READY id=",SKILL_ID," target=ONE_WALK_ALLY cleanse_instant=true duration_zero=true projectile_zero=true gameplay_writes=false")
    set_process(true)
func _process(delta:float)->void:
    if paused:return
    time=fposmod(time+maxf(delta,0.0),MOVIE_LOOP)
    queue_redraw()
func _glow(p:Vector2,r:float,color:Color)->void:
    if color.a>.003:draw_texture_rect(_light,Rect2(p-Vector2.ONE*r,Vector2.ONE*r*2),false,color)
func _cell(tex:Texture2D,i:int,w:int,h:int,rect:Rect2,col:Color)->void:
    draw_texture_rect_region(tex,rect,Rect2(i%4*w,int(i/4)*h,w,h),col)
func _flip(tex:Texture2D,frames:int,w:int,h:int,p:float,rect:Rect2,col:Color)->void:
    var frame:=clampf(p,0,1)*float(frames-1)
    var i:=int(floor(frame))
    var j:=mini(i+1,frames-1)
    var alpha:=frame-float(i)
    if i==j or alpha<.006:_cell(tex,i,w,h,rect,col)
    else:
        _cell(tex,i,w,h,rect,Color(col.r,col.g,col.b,col.a*sqrt(1.0-alpha)))
        _cell(tex,j,w,h,rect,Color(col.r,col.g,col.b,col.a*sqrt(alpha)))
func _draw()->void:
    var t:=time
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    var foot:=target_foot(0,t)
    var count:=ALLY.get_frame_count("walk")
    var ally_texture:Texture2D=ALLY.get_frame_texture("walk",int(t*13)%maxi(1,count))
    _glow(foot+Vector2(0,-5),47,Color("83e9c4",.055))
    draw_texture_rect(ally_texture,Rect2(foot-Vector2(62,127),Vector2(124,127)),false)
    # An invented dark stain is a *visual illustration only*; no game debuff is applied.
    var bad:=curse_gain(t)
    if bad>.004:
        var p:=target_contact(0,t)+Vector2(7,-2)
        _flip(CURSE,8,128,128,clampf(t/.84,0,1),
              Rect2(p-Vector2(63,67),Vector2(126,126)),Color(1,1,1,bad*.66))
    var wind:=transfer_gain(t)
    if wind>.004:
        var end:=target_contact(0,t)
        var vec:=end-HAND
        draw_set_transform(HAND,vec.angle(),Vector2.ONE)
        _flip(WIND,16,512,256,clampf((t-.47)/.45,0,1),
              Rect2(0,-80,vec.length(),160),Color(1,1,1,wind*.94))
        draw_set_transform(Vector2.ZERO)
    var arrival:=cleanse_gain(t)
    if arrival>.003:
        var p:=target_contact(0,t)
        _flip(CLEANSE,14,320,320,clampf((t-CLEANSE_RECEIPT_SIMULATED)/.43,0,1),
              Rect2(p-Vector2(131,133),Vector2(262,262)),Color(1,1,1,arrival*.96))
        _glow(p,39,Color("e4fff1",arrival*.20))
    var tail:=residue_gain(t)
    if tail>.003:
        var p:=target_contact(0,t)
        _flip(RESIDUE,8,256,256,clampf((t-1.08)/.45,0,1),
              Rect2(p-Vector2(112,117),Vector2(224,224)),Color(1,1,1,tail*.88))
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(72,163),Vector2(144,163)),
                             Rect2(0,0,320,384),Color("e5d7ca"))
    var c:=charge_gain(t)
    if c>.003:
        var center:=HAND+Vector2(37,-28)
        var size:=233.0+25.0*smoothstep(.08,.47,t)
        _flip(CHARGE,12,320,320,clampf(t/.53,0,1),
              Rect2(center-Vector2.ONE*size*.5,Vector2.ONE*size),Color(1,1,1,c*.94))
        _glow(HAND+Vector2(5,-5),38,Color("c6fff0",c*.23))
