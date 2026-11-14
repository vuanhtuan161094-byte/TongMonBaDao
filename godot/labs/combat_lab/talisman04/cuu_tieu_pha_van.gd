extends Control
## TAL04 Cửu Tiêu Phá Vân: exactly one LINE strike and at most two target cues.
## Original ten-pose turbulent cloud/qi tear. Visual only; no true gameplay damage.
const SKILL_ID := "tmb.skill.talisman.loi_phu.active_04.human"
const EFFECT := "damage"
const ELEMENT := "lightning"
const SHAPE := "line"
const TARGET_LIMIT := 2
const DECLARED_CAST_TIME := .50
const DECLARED_COOLDOWN := 13.6
const DECLARED_RANGE := 9.0
const DECLARED_PROJECTILE_SPEED := 0.0
const CASTER := Vector2(311,544)
const HAND := Vector2(382,427)
const TARGETS := [Vector2(836,541),Vector2(1084,541)]
const CONTACTS := [Vector2(834,449),Vector2(1084,449)]
const RELEASE_AT := .55
const CONTACT_AT := 1.44
const FADE_END := 2.73
const LOOP_SECONDS := 3.16
const CLOUD_POSES := [
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_00.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_01.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_02.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_03.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_04.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_05.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_06.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_07.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_08.svg"),
    preload("res://labs/combat_lab/talisman04/assets/cloud_rift_09.svg"),
]
const PAINTED_CLOUD:Texture2D=preload("res://labs/combat_lab/talisman04/assets/tal04_r3_cloud_flipbook.webp")
const PAINTED_MASTER:Texture2D=preload("res://labs/combat_lab/talisman04/assets/tal04_r3_cloud_master.webp")
const PAINTED_IMPACT:Texture2D=preload("res://labs/combat_lab/talisman04/assets/tal04_r3_local_fracture.webp")
const PAINTED_RECT:=Rect2(360.0,298.0,828.0,268.0)
const TALISMAN:Texture2D=preload("res://labs/combat_lab/talisman01/assets/thunder_talisman_atlas.webp")
const FLOOR:Texture2D=preload("res://labs/combat_lab/talisman02/assets/talisman_foot_array.webp")
const IMPACT:Texture2D=PAINTED_IMPACT
const BG:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed:=0.0
var paused:=false
var _hero:Sprite2D
var _cell:AtlasTexture
var _glow:Texture2D
static func phase_at(t:float)->String:
    if t<.50:return "gather"
    if t<RELEASE_AT:return "break_seal"
    if t<CONTACT_AT:return "cloud_tear"
    if t<1.79:return "demo_contact"
    if t<FADE_END:return "dissolve"
    return "idle"
static func cloud_index(t:float)->int:
    if t<RELEASE_AT or t>1.83:return -1
    return clampi(int(floor(smoothstep(RELEASE_AT,CONTACT_AT,t)*9.99)),0,9)
static func floor_gain(t:float)->float:
    if t<.07 or t>1.05:return 0.0
    return smoothstep(.07,.30,t)*(1.0-smoothstep(.63,1.05,t))
static func contact_gain(t:float,idx:int)->float:
    if idx<0 or idx>=TARGET_LIMIT:return 0.0
    var start:=CONTACT_AT+float(idx)*.075
    if t<start or t>start+.43:return 0.0
    return smoothstep(start,start+.065,t)*(1.0-smoothstep(start+.16,start+.43,t))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    _glow=_make_glow()
    _cell=AtlasTexture.new()
    _cell.atlas=TALISMAN
    _cell.region=Rect2(0,0,300,360)
    _hero=Sprite2D.new()
    _hero.texture=_cell
    _hero.z_index=4
    _hero.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    add_child(_hero)
    set_process(true)
    _update_hero()
    queue_redraw()
    print("VFX_TAL04_READY id=",SKILL_ID," cloud_poses=",CLOUD_POSES.size()," target_limit=",TARGET_LIMIT," view_only=true")
func _make_glow()->Texture2D:
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            im.set_pixel(x,y,Color(1,1,1,clampf(exp(-5.5*p.length_squared())*(1.0-smoothstep(.77,1.0,p.length())),0,1)))
    return ImageTexture.create_from_image(im)
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    _update_hero()
    queue_redraw()
func _unhandled_input(event:InputEvent)->void:
    if not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        _update_hero()
    elif event.keycode==KEY_P:
        paused=not paused
func _update_hero()->void:
    var t:=elapsed
    var a:=smoothstep(.08,.21,t)*(1.0-smoothstep(.67,1.02,t))
    _hero.visible=a>.008
    if not _hero.visible:return
    var f:=clampi(int(floor(clampf(t/.84,0,1)*11.9)),0,11)
    _cell.region=Rect2(float(f%3)*300,float(f/3)*360,300,360)
    _hero.position=HAND+Vector2(28,-28)
    _hero.scale=Vector2.ONE*(.45+0.05*sin(t*9.0))
    _hero.rotation=-.21+.08*sin(t*7.2)
    _hero.modulate=Color(1,1,1,a)
func _halo(at:Vector2,r:float,col:Color)->void:
    if col.a<.005:return
    draw_texture_rect(_glow,Rect2(at-Vector2.ONE*r,Vector2.ONE*(r*2)),false,col)
static func rupture_point(q:float,t:float)->Vector2:
    var p:=clampf(q,0,1)
    var envelope:=sin(PI*p)
    var crooked:=7.0*sin(p*62.0+t*22.0)*envelope+9.0*sin(p*119.0-t*33.0)*envelope
    return Vector2(428.0+741.0*p,422.0-24.0*sin(PI*p)+crooked)
func _draw_rupture(t:float,gain:float)->void:
    var reach:=smoothstep(RELEASE_AT,CONTACT_AT,t)
    if gain<.01 or reach<.02:return
    var prev:=rupture_point(0.0,t)
    for s in range(43):
        var q:=reach*float(s+1)/43.0
        var point:=rupture_point(q,t)
        var weight:=gain*(.50+.5*sin(PI*q))
        draw_line(prev,point,Color("8055da",weight*.29),14.0,true)
        draw_line(prev,point,Color("bb9dff",weight*.51),4.4,true)
        draw_line(prev,point,Color("fff4ff",weight*.86),1.55,true)
        if s%7==0:_halo(point,24.0,Color("ae80f1",weight*.12))
        prev=point
    # The cloud rends UP and DOWN at four irregular locations, not a flat ribbon.
    for j in range(4):
        var q:=.21+float(j)*.20
        if reach<q+.01:continue
        var root:=rupture_point(q,t)
        var sign:float=-1.0 if j%2==0 else 1.0
        var p1:=root+Vector2(19.0,sign*(38.0+10.0*float(j%3)))
        var p2:=p1+Vector2(-13.0,sign*(29.0+float(j)*6.0))
        draw_line(root,p1,Color("7750c9",gain*.30),8.0,true)
        draw_line(p1,p2,Color("7750c9",gain*.24),5.0,true)
        draw_line(root,p1,Color("f5ddff",gain*.72),1.5,true)
        draw_line(p1,p2,Color("e7c6ff",gain*.49),1.05,true)
func _actor(pos:Vector2)->void:
    draw_texture_rect_region(ACTOR,Rect2(pos.x-72,pos.y-163,144,163),Rect2(0,0,320,384),Color("d1c6dd"))
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false)
    var ground:=floor_gain(t)
    if ground>.005:
        draw_texture_rect(_glow,Rect2(CASTER.x-116,CASTER.y-49,232,102),false,Color("8e69ce",ground*.18))
        draw_texture_rect(FLOOR,Rect2(CASTER.x-110,CASTER.y-52,220,106),false,Color(1,1,1,ground*.69))
        for j in range(6):
            var a:=float(j)*TAU/6.0+t*.95
            var pos:=CASTER+Vector2(cos(a)*81.0,8.0+sin(a)*34.0)
            _halo(pos,8.0,Color("e4c4ff",ground*.25))
    var f:=cloud_index(t)
    if f>=0:
        var gain:=smoothstep(RELEASE_AT,RELEASE_AT+.12,t)*(1.0-smoothstep(1.57,1.83,t))
        # Ragged cloud-wound art has its own ten animated shapes, independent of TAL02 ink calligraphy.
        var region:=Rect2(float(f%4)*1024.0,float(int(f/4))*256.0,1024.0,256.0)
        draw_texture_rect_region(PAINTED_CLOUD,PAINTED_RECT,region,Color(1,1,1,gain*.86))
        # A small conductor accent follows the painted tear, never replaces it.
        _draw_rupture(t,gain*.08)
        _halo(HAND+Vector2(17,-6),40,Color("aa77e2",gain*.19))
    # Render painted cloud BEFORE actors; targets remain readable at gameplay 1x.
    _actor(CASTER)
    for i in range(TARGET_LIMIT):
        _actor(TARGETS[i])
    for i in range(TARGET_LIMIT):
        var g:=contact_gain(t,i)
        if g<.005:continue
        var spot:Vector2=CONTACTS[i]
        _halo(spot,108.0,Color("7652db",g*.33))
        _halo(spot,44.0,Color("faf1ff",g*.72))
        var size:=Vector2.ONE*(202.0+51.0*(1.0-g))
        draw_texture_rect(IMPACT,Rect2(spot-size*.5,size),false,Color(1,1,1,g*.94))
    var haze:=smoothstep(1.6,1.9,t)*(1.0-smoothstep(2.2,FADE_END,t))
    if haze>.005:
        for k in range(17):
            var a:=float(k)*2.399
            var pos:=Vector2(812.0+float(k%2)*245.0+31.0*cos(a),462.0+26.0*sin(a)-(t-1.6)*33.0)
            _halo(pos,28.0,Color("a87bdf",haze*.13))
