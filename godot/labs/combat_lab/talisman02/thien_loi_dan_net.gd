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
const HAND := Vector2(338.0,445.0) # Painted caster-palm anchor at native 1x
const TARGETS := [Vector2(772.0,540.0),Vector2(950.0,540.0),Vector2(1130.0,540.0)]
const CONTACTS := [Vector2(772.0,455.0),Vector2(950.0,455.0),Vector2(1130.0,455.0)]
const PAINTED_LINE_RECT := Rect2(253.0,329.0,943.0,211.0) # R6 alpha-left at the palm; far end remains at x=1196
const RELEASE_AT := 0.62
const CONTACT_AT := 1.39
const FADE_END := 2.72
const LOOP_SECONDS := 3.13
const PAINTED_STROKES: Texture2D = preload("res://labs/combat_lab/talisman02/assets/tal02_thunder_flipbook.webp")
const PAINTED_MASTER: Texture2D = preload("res://labs/combat_lab/talisman02/assets/tal02_thunder_master.webp")
const PAINTED_FOOT: Texture2D = preload("res://labs/combat_lab/talisman02/assets/talisman_foot_array.webp")
const PAINTED_IMPACT: Texture2D = preload("res://labs/combat_lab/talisman02/assets/tal02_fracture_impact.webp")
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
const FLOOR: Texture2D = PAINTED_FOOT
const IMPACT: Texture2D = PAINTED_IMPACT
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
    _seal.position=HAND+Vector2(24.0,-15.0+4.0*sin(t*5.0))
    _seal.scale=Vector2.ONE*(0.35+0.03*sin(t*8.0))
    _seal.rotation=-0.16+0.06*sin(t*6.0)
    _seal.modulate=Color(1.0,1.0,1.0,gain)
func _halo(at:Vector2,radius:float,tint:Color)->void:
    if tint.a<.005:return
    draw_texture_rect(_halo_texture,Rect2(at-Vector2.ONE*radius,Vector2.ONE*(radius*2.0)),false,tint)
static func line_point(q:float,t:float,lane:int=0)->Vector2:
    var p:=clampf(q,0.0,1.0)
    var e:=sin(PI*p)
    var zig:=8.0*sin(p*67.0+t*21.0)*e+5.0*sin(p*119.0-t*37.0)*e
    var curve:=22.0*sin(PI*p)+11.0*sin(p*12.7+t*1.8)*e
    return Vector2(HAND.x+(1133.0-HAND.x)*p,HAND.y+curve+zig+float(lane)*11.0*e)
func _draw_living_line(t:float,gain:float)->void:
    var reach:=smoothstep(RELEASE_AT,CONTACT_AT,t)
    if gain<0.01 or reach<0.01:return
    var end:=line_point(reach,t)
    _halo(end,83.0,Color("8b62ef",gain*.44))
    _halo(end,43.0,Color("e9baff",gain*.65))
    _halo(end,15.0,Color("fff8ff",gain*.91))
    for lane in range(2):
        var prev:=HAND
        if lane==1:prev+=Vector2(0.0,10.0)
        for step in range(43):
            var q:=reach*float(step+1)/43.0
            var nxt:=line_point(q,t,lane)
            var intensity:=gain*(1.0 if lane==0 else .29)*(0.45+0.55*pow(q,0.35))
            draw_line(prev,nxt,Color("6c48d2",intensity*.23),12.0 if lane==0 else 5.0,true)
            draw_line(prev,nxt,Color("b79aff",intensity*.72),4.2 if lane==0 else 2.3,true)
            draw_line(prev,nxt,Color("fff4ff",intensity*.96),1.70 if lane==0 else .90,true)
            if step%6==0:
                _halo(nxt,22.0 if lane==0 else 12.0,Color("946fe3",intensity*.14))
            prev=nxt
    # Only two brief tangential forks, no equal-weight parallel neon cables.
    for b in range(2):
        var q:=.37+float(b)*.29
        if reach<q+.01:continue
        var source:=line_point(q,t)
        var side:float=-1.0 if b%2==0 else 1.0
        var dest:=source+Vector2(32.0,side*(41.0+12.0*float(b)))
        var mid:=source.lerp(dest,.52)+Vector2(8.0,-side*7.0)
        draw_line(source,mid,Color("9864e9",gain*.26),6.0,true)
        draw_line(mid,dest,Color("9864e9",gain*.24),4.0,true)
        draw_line(source,mid,Color("f1dfff",gain*.62),1.3,true)
        draw_line(mid,dest,Color("ead5ff",gain*.44),1.0,true)
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
        _halo(HAND+Vector2(14,-8),45.0,Color("a878fa",gain*.25))
        # All ten poses are independently shaped, progressive alpha glyph-brush artwork.
        # PAINTED ART R3 is the PRIMARY visible stroke, not a line-only SVG approximation.
        # 4 columns x 3 rows of actual animated transparent 1024x256 raster art.
        var source_rect := Rect2(float(index % 4) * 1024.0, float(int(index / 4)) * 256.0, 1024.0, 256.0)
        draw_texture_rect_region(PAINTED_STROKES,PAINTED_LINE_RECT,source_rect,Color(1.0,1.0,1.0,gain*.99))
        # The runtime conductor is now a quiet subordinate flicker, not the hero art.
        _draw_living_line(t,gain*.10)
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
            var q:=float(k)
            var a:=q*2.399
            var x:=660.0+float(k%3)*183.0+14.0*cos(a)
            var y:=454.0+27.0*sin(a)-(t-1.55)*23.0
            _halo(Vector2(x,y),17.0,Color("b8a0f0",mist*.12))
