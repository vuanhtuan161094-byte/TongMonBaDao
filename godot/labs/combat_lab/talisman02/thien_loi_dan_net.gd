extends Control
## VFX TAL02: Thiên Lôi Dẫn Nét — line damage; 3 real possible targets max.
## Dedicated progressive ink-stroke flipbook, no generic TAL01 recolor.
## LAB VIEW ONLY; hits below are DEMO times, not Combat V2 receipts.
const SKILL_ID := "tmb.skill.talisman.loi_phu.active_02.human"
const EFFECT := "damage"
const ELEMENT := "lightning"
const SHAPE := "line"
const TARGET_LIMIT := 3
const DECLARED_CAST_TIME := 0.62
const DECLARED_COOLDOWN := 10.8
const DECLARED_RANGE := 9.5
const DECLARED_PROJECTILE_SPEED := 0.0
const CASTER := Vector2(287.0,544.0)
const HAND := Vector2(358.0,424.0)
const TARGETS := [Vector2(772.0,540.0),Vector2(950.0,540.0),Vector2(1130.0,540.0)]
const CONTACTS := [Vector2(772.0,455.0),Vector2(950.0,455.0),Vector2(1130.0,455.0)]
const RELEASE_AT := 0.62
const CONTACT_AT := 1.39
const FADE_END := 2.72
const LOOP_SECONDS := 3.13
const STROKES := [
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_00.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_01.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_02.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_03.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_04.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_05.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_06.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_07.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_08.svg"),
    preload("res://labs/combat_lab/talisman02/assets/ink_stroke_09.svg"),
]
const TALISMAN: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_talisman_atlas.webp")
const FLOOR: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_cast_sigil.svg")
const IMPACT: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_impact_burst.png")
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed:=0.0
var paused:=false
var _halo_texture:Texture2D
var _seal:Sprite2D
var _cell:AtlasTexture
static func phase_at(t:float)->String:
    if t<RELEASE_AT: return "inscribe"
    if t<CONTACT_AT: return "draw_line"
    if t<1.76: return "demo_contact"
    if t<FADE_END: return "dissolve"
    return "idle"
static func stroke_index(t:float)->int:
    if t<RELEASE_AT or t>=1.76: return -1
    return clampi(int(floor(smoothstep(RELEASE_AT,CONTACT_AT,t)*9.99)),0,9)
static func foot_gain(t:float)->float:
    if t<0.07 or t>=1.12: return 0.0
    return smoothstep(0.07,0.32,t)*(1.0-smoothstep(0.68,1.12,t))
static func contact_gain(t:float,idx:int)->float:
    if idx<0 or idx>=TARGET_LIMIT: return 0.0
    var at:=CONTACT_AT+float(idx)*0.055
    if t<at or t>at+0.38: return 0.0
    return smoothstep(at,at+0.07,t)*(1.0-smoothstep(at+0.12,at+0.38,t))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    _halo_texture=_make_halo()
    _cell=AtlasTexture.new()
    _cell.atlas=TALISMAN
    _cell.region=Rect2(0.0,0.0,300.0,360.0)
    _seal=Sprite2D.new()
    _seal.texture=_cell
    _seal.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    _seal.z_index=3
    add_child(_seal)
    set_process(true)
    _update_hero()
    queue_redraw()
    print("VFX_TAL02_READY id=",SKILL_ID," stroke_poses=",STROKES.size()," max_targets=",TARGET_LIMIT," view_only=true no_rig=true")
func _make_halo()->Texture2D:
    var img:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a:=exp(-6.0*p.length_squared())*(1.0-smoothstep(.75,1.0,p.length()))
            img.set_pixel(x,y,Color(1,1,1,clampf(a,0.0,1.0)))
    return ImageTexture.create_from_image(img)
func _process(delta:float)->void:
    if paused: return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    _update_hero()
    queue_redraw()
func _unhandled_input(event:InputEvent)->void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        _update_hero()
    elif event.keycode==KEY_P:
        paused=not paused
func _update_hero()->void:
    var t:=elapsed
    var gain:=smoothstep(0.09,0.30,t)*(1.0-smoothstep(0.77,1.40,t))
    _seal.visible=gain>0.005
    if not _seal.visible:return
    var f:=clampi(int(floor(clampf(t/1.28,0.0,1.0)*11.9)),0,11)
    _cell.region=Rect2(float(f%3)*300.0,float(f/3)*360.0,300.0,360.0)
    _seal.position=HAND+Vector2(29.0,-27.0+5.0*sin(t*5.0))
    _seal.scale=Vector2.ONE*(0.42+0.05*sin(t*8.0))
    _seal.rotation=-0.16+0.06*sin(t*6.0)
    _seal.modulate=Color(1.0,1.0,1.0,gain)
func _halo(at:Vector2,radius:float,tint:Color)->void:
    if tint.a<.005:return
    draw_texture_rect(_halo_texture,Rect2(at-Vector2.ONE*radius,Vector2.ONE*(radius*2.0)),false,tint)
func _actor(at:Vector2,alpha:float=1.0)->void:
    draw_texture_rect_region(ACTOR,Rect2(at.x-72.0,at.y-163.0,144.0,163.0),Rect2(0,0,320,384),Color(0.82,0.78,0.90,alpha))
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false)
    var foot:=foot_gain(t)
    if foot>.005:
        draw_texture_rect(_halo_texture,Rect2(CASTER.x-112.0,CASTER.y-51.0,224.0,100.0),false,Color("8268d9",foot*.19))
        draw_texture_rect(FLOOR,Rect2(CASTER.x-108.0,CASTER.y-47.0,216.0,102.0),false,Color(0.93,0.83,1.0,foot*.70))
        for j in range(7):
            var a:=float(j)*TAU/7.0+t*.72
            _halo(CASTER+Vector2(cos(a)*78.0,4.0+sin(a)*32.0),8.0,Color("d1adff",foot*.20))
    _actor(CASTER)
    for i in range(TARGET_LIMIT):
        _actor(TARGETS[i],0.90)
    var index:=stroke_index(t)
    if index>=0:
        var gain:=smoothstep(RELEASE_AT,RELEASE_AT+.13,t)*(1.0-smoothstep(1.54,1.76,t))
        _halo(HAND+Vector2(31,-26),69.0,Color("a878fa",gain*.36))
        # All ten poses are independently shaped, progressive alpha glyph-brush artwork.
        draw_texture_rect(STROKES[index],Rect2(385.0,329.0,811.0,211.0),false,Color(1.0,1.0,1.0,gain))
        # One continuous lightning calligraphy path along the declared line, no fake 360-degree AoE.
    for i in range(TARGET_LIMIT):
        var g:=contact_gain(t,i)
        if g<.005:continue
        var spot:Vector2=CONTACTS[i]
        _halo(spot,83.0,Color("9063ed",g*.39))
        _halo(spot,38.0,Color("f8eaff",g*.76))
        var size:=Vector2(163.0,163.0)*(1.0+0.22*(1.0-g))
        draw_texture_rect(IMPACT,Rect2(spot-size*.5,size),false,Color(1.0,1.0,1.0,g*.90))
    var mist:=smoothstep(1.55,1.86,t)*(1.0-smoothstep(2.05,FADE_END,t))
    if mist>0.01:
        for k in range(22):
            var q:=float(k),a:=q*2.399
            var x:=660.0+float(k%3)*183.0+14.0*cos(a)
            var y:=454.0+27.0*sin(a)-(t-1.55)*23.0
            _halo(Vector2(x,y),17.0,Color("b8a0f0",mist*.12))
