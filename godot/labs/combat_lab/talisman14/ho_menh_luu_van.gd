extends Control
## PAF04 Hộ Mệnh Lưu Văn — self-only WIND GUARD, glass energy visual-only.
## Four-second defense is an independent hypothetical STATUS, not a 4s casting movie.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.active_04.human"
const EFFECT := "guard"
const ELEMENT := "wind"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const HIT_COUNT := 1
const DECLARED_RANGE := 8.5
const DECLARED_CAST_TIME := 0.5
const DECLARED_COOLDOWN := 13.6
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 4.0
const DECLARED_RADIUS := 0.0
const DECLARED_DAMAGE_RATIO := 0.0
const DECLARED_GUARD_POWER := 0.16
const GUARD_MODE := "mitigation"
const SELF_GUARD_RECEIPT_SIMULATED := 0.82
const VFX_FADE_END := 1.48
const MOVIE_LOOP := 2.0
const CHARGE:Texture2D=preload("res://labs/combat_lab/talisman14/assets/paf04_charge.webp")
const GLASS_BACK:Texture2D=preload("res://labs/combat_lab/talisman14/assets/paf04_glass_back.webp")
const GLASS_FRONT:Texture2D=preload("res://labs/combat_lab/talisman14/assets/paf04_glass_front.webp")
const LOCK:Texture2D=preload("res://labs/combat_lab/talisman14/assets/paf04_lock.webp")
const SHIMMER:Texture2D=preload("res://labs/combat_lab/talisman14/assets/paf04_shimmer.webp")
const BADGE:Texture2D=preload("res://labs/combat_lab/talisman14/assets/paf04_badge.webp")
const BACKDROP:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER:SpriteFrames=preload("res://assets/actors/1113028_1/animations.tres")
var time:=0.0
var paused:=false
var _light:Texture2D

static func self_foot(index:int,t:float)->Vector2:
    if index!=0:return Vector2.INF
    return Vector2(781.0+62.0*sin(t*1.80-.50),516.0+8.0*sin(t*2.01))
static func self_contact(index:int,t:float)->Vector2:
    return self_foot(index,t)+Vector2(0,-90)
static func self_guard_active_in_demo(t:float)->bool:
    return t>=SELF_GUARD_RECEIPT_SIMULATED and t<(SELF_GUARD_RECEIPT_SIMULATED+DECLARED_DURATION)
static func charge_gain(t:float)->float:
    if t<.03 or t>=.58:return 0.0
    return smoothstep(.03,.15,t)*(1.0-smoothstep(.44,.58,t))
static func crystal_gain(t:float)->float:
    if t<.55 or t>=VFX_FADE_END:return 0.0
    return smoothstep(.55,.79,t)*(1.0-smoothstep(1.26,VFX_FADE_END,t))
static func lock_gain(t:float)->float:
    if t<SELF_GUARD_RECEIPT_SIMULATED or t>=1.30:return 0.0
    return smoothstep(SELF_GUARD_RECEIPT_SIMULATED,.92,t)*(1.0-smoothstep(1.13,1.30,t))
static func shimmer_gain(t:float)->float:
    if t<.68 or t>=1.67:return 0.0
    return smoothstep(.68,.90,t)*(1.0-smoothstep(1.40,1.67,t))
static func phase(t:float)->String:
    if t<DECLARED_CAST_TIME:return "self_charge"
    if t<SELF_GUARD_RECEIPT_SIMULATED:return "glass_forming"
    if t<1.30:return "self_guard_lock"
    if t<VFX_FADE_END:return "glass_light_residue"
    return "status_only_no_cast_animation"
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for yy in range(96):
        for xx in range(96):
            var pos:Vector2=(Vector2(xx,yy)-Vector2(47.5,47.5))/47.5
            var a:=clampf(exp(-8.3*pos.length_squared())*(1.0-smoothstep(.8,1.0,pos.length())),0.0,1.0)
            im.set_pixel(xx,yy,Color(1.0,1.0,1.0,a))
    _light=ImageTexture.create_from_image(im)
    print("VFX_PAF04_READY skill=",SKILL_ID," moving_caster=SELF guard_status_4s=SEPARATE projectile=ZERO combat_writes=FALSE")
    set_process(true)
func _process(delta:float)->void:
    if paused:return
    time=fposmod(time+maxf(0.0,delta),MOVIE_LOOP)
    queue_redraw()
func _glow(pos:Vector2,radius:float,col:Color)->void:
    if col.a>.001:
        draw_texture_rect(_light,Rect2(pos-Vector2.ONE*radius,Vector2.ONE*radius*2),false,col)
func _cell(tex:Texture2D,i:int,w:int,h:int,rect:Rect2,col:Color)->void:
    draw_texture_rect_region(tex,rect,Rect2(i%4*w,int(i/4)*h,w,h),col)
func _flip(tex:Texture2D,frames:int,w:int,h:int,p:float,rect:Rect2,col:Color)->void:
    var frame:=clampf(p,0.0,1.0)*float(frames-1)
    var a:=int(floor(frame))
    var b:=mini(a+1,frames-1)
    var f:=frame-float(a)
    if a==b or f<.005:_cell(tex,a,w,h,rect,col)
    else:
        _cell(tex,a,w,h,rect,Color(col.r,col.g,col.b,col.a*sqrt(1.0-f)))
        _cell(tex,b,w,h,rect,Color(col.r,col.g,col.b,col.a*sqrt(f)))
func _draw()->void:
    var t:=time
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    var foot:=self_foot(0,t)
    var chest:=self_contact(0,t)
    var count:=CASTER.get_frame_count("walk")
    var hero:Texture2D=CASTER.get_frame_texture("walk",int(t*13.0)%maxi(1,count))
    _glow(foot+Vector2(0,-4),57,Color("6ffff0",.045))
    var cg:=crystal_gain(t)
    var lock:=lock_gain(t)
    var shimmer:=shimmer_gain(t)
    var area:=Rect2(foot-Vector2(154,312),Vector2(308,359))
    if cg>.005:
        _flip(GLASS_BACK,16,352,448,clampf((t-.55)/.93,0,1),
              area,Color(1,1,1,cg*.95))
    if lock>.005:
        var centre:=chest
        _flip(LOCK,14,320,320,clampf((t-SELF_GUARD_RECEIPT_SIMULATED)/.48,0,1),
              Rect2(centre-Vector2(154,154),Vector2(308,308)),
              Color(1,1,1,lock*.75))
        _glow(centre,62,Color("bcfff0",lock*.18))
    # Original first-party sprite character is neither generated nor rigged by VFX.
    draw_texture_rect(hero,Rect2(foot-Vector2(62,127),Vector2(124,127)),false)
    if cg>.005:
        _flip(GLASS_FRONT,16,352,448,clampf((t-.55)/.93,0,1),
              area,Color(1,1,1,cg*.86))
    if shimmer>.005:
        _flip(SHIMMER,8,256,256,clampf((t-.68)/.98,0,1),
              Rect2(chest-Vector2(167,152),Vector2(334,316)),
              Color(1,1,1,shimmer*.90))
    var charge:=charge_gain(t)
    if charge>.005:
        _flip(CHARGE,12,320,320,clampf(t/.55,0,1),
              Rect2(chest+Vector2(-112,-138),Vector2(225,225)),
              Color(1,1,1,charge*.95))
        _glow(chest+Vector2(0,-33),50,Color("f8ffda",charge*.12))
    # Persistent four-second mitigation is NOT four seconds of large guard FX.
    # This compact status badge is only a LAB visual cue; actual status is gated.
    if self_guard_active_in_demo(t):
        var badge_at:=foot+Vector2(71,-155)
        _flip(BADGE,8,128,128,clampf((t-SELF_GUARD_RECEIPT_SIMULATED)/.5,0,1),
              Rect2(badge_at-Vector2(19,19),Vector2(38,38)),
              Color(1,1,1,.72))
