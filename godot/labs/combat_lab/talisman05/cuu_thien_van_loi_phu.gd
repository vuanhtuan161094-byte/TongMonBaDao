extends Control
## TAL05: Cửu Thiên Vạn Lôi Phù Human ULTIMATE. Original heavenly rune master + one principal storm bolt.
## Three contacts are DEMO visual timings, never Combat V2 damage/target/status authority.
const SKILL_ID := "tmb.skill.talisman.loi_phu.ultimate.human"
const EFFECT := "damage"
const ELEMENT := "lightning"
const SHAPE := "line"
const TARGET_LIMIT := 3
const DECLARED_CAST_TIME := 1.05
const DECLARED_COOLDOWN := 23.0
const DECLARED_RANGE := 11.0
const DECLARED_PROJECTILE_SPEED := 0.0
const CASTER := Vector2(281.0,540.0)
const HAND := Vector2(348.0,419.0)
const SKY := Vector2(922.0,252.0)
const TOP := Vector2(917.0,74.0)
const CENTER_HIT := Vector2(949.0,449.0)
const TARGETS := [Vector2(743.0,542.0),Vector2(949.0,542.0),Vector2(1152.0,542.0)]
const CONTACTS := [Vector2(743.0,449.0),CENTER_HIT,Vector2(1152.0,449.0)]
const CAST_END := 1.05
const STORM_BEGIN := 1.45
const CONTACT_AT := 1.87
const FADE_END := 3.78
const LOOP_SECONDS := 4.78
const SKY_FRAMES := [
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_00.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_01.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_02.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_03.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_04.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_05.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_06.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_07.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_08.svg"),
    preload("res://labs/combat_lab/talisman05/assets/heaven_rune_09.svg"),
]
const TALISMAN:Texture2D=preload("res://labs/combat_lab/talisman01/assets/thunder_talisman_atlas.webp")
const FLOOR:Texture2D=preload("res://labs/combat_lab/talisman01/assets/thunder_cast_sigil.svg")
const IMPACT:Texture2D=preload("res://labs/combat_lab/talisman01/assets/thunder_impact_burst.png")
const BG:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed:=0.0
var paused:=false
var _talisman:Sprite2D
var _cell:AtlasTexture
var _glow:Texture2D
static func phase_at(t:float)->String:
    if t<CAST_END:return "ritual_charge"
    if t<STORM_BEGIN:return "heaven_gate"
    if t<CONTACT_AT:return "thunder_descent"
    if t<2.36:return "demo_contact"
    if t<FADE_END:return "dissolve"
    return "idle"
static func foot_gain(t:float)->float:
    if t<.14 or t>=1.58:return 0.0
    return smoothstep(.14,.56,t)*(1.0-smoothstep(1.13,1.58,t))
static func sky_gain(t:float)->float:
    if t<.52 or t>=3.30:return 0.0
    return smoothstep(.52,1.25,t)*(1.0-smoothstep(2.45,3.30,t))
static func bolt_gain(t:float)->float:
    if t<STORM_BEGIN or t>2.32:return 0.0
    return smoothstep(STORM_BEGIN,1.68,t)*(1.0-smoothstep(2.03,2.32,t))
static func hit_gain(t:float,idx:int)->float:
    if idx<0 or idx>=TARGET_LIMIT:return 0.0
    var start:=CONTACT_AT+float(idx)*.055
    if t<start or t>start+.46:return 0.0
    return smoothstep(start,start+.075,t)*(1.0-smoothstep(start+.18,start+.46,t))
static func point_on_bolt(q:float,t:float)->Vector2:
    var p:=clampf(q,0.0,1.0)
    var e:=sin(PI*p)
    var x:=lerpf(TOP.x,CENTER_HIT.x,p)+17.0*sin(p*57.0+t*16.0)*e+9.0*sin(p*113.0-t*21.0)*e
    return Vector2(x,lerpf(TOP.y,CENTER_HIT.y,p))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    _glow=_make_glow()
    _cell=AtlasTexture.new()
    _cell.atlas=TALISMAN
    _cell.region=Rect2(0,0,300,360)
    _talisman=Sprite2D.new()
    _talisman.texture=_cell
    _talisman.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    _talisman.z_index=4
    add_child(_talisman)
    set_process(true)
    _update_hero()
    queue_redraw()
    print("VFX_TAL05_READY id=",SKILL_ID," heaven_poses=",SKY_FRAMES.size()," targets_max=",TARGET_LIMIT," visual_only=true")
func _make_glow()->Texture2D:
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a:=exp(-5.8*p.length_squared())*(1.0-smoothstep(.73,1.0,p.length()))
            im.set_pixel(x,y,Color(1,1,1,clampf(a,0,1)))
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
    var a:=sky_gain(t)*(1.0-smoothstep(2.27,2.99,t))
    _talisman.visible=a>.004
    if not _talisman.visible:return
    var frame:=clampi(int(floor(smoothstep(.52,1.87,t)*11.9)),0,11)
    _cell.region=Rect2(float(frame%3)*300.0,float(frame/3)*360.0,300,360)
    _talisman.position=SKY+Vector2(-8.0,-7.0+6.0*sin(t*4.0))
    _talisman.scale=Vector2.ONE*(.65+.055*sin(t*7.0))
    _talisman.rotation=-.05+.10*sin(t*3.7)
    _talisman.modulate=Color(1,1,1,a)
func _halo(at:Vector2,r:float,tint:Color)->void:
    if tint.a<.005:return
    draw_texture_rect(_glow,Rect2(at-Vector2.ONE*r,Vector2.ONE*(r*2)),false,tint)
func _actor(at:Vector2,alpha:float=1.0)->void:
    draw_texture_rect_region(ACTOR,Rect2(at.x-72,at.y-163,144,163),Rect2(0,0,320,384),Color(.83,.78,.90,alpha))
func _draw_storm(t:float)->void:
    var gain:=bolt_gain(t)
    if gain<.01:return
    var reach:=smoothstep(STORM_BEGIN,1.78,t)
    var tip:=point_on_bolt(reach,t)
    _halo(tip,127.0,Color("8c59e8",gain*.44))
    _halo(tip,69.0,Color("b89bf6",gain*.67))
    _halo(tip,26.0,Color("fff8ff",gain*.94))
    var prev:Vector2=TOP
    for k in range(45):
        var q:=reach*float(k+1)/45.0
        var point:=point_on_bolt(q,t)
        var weight:=gain*(.69+.31*sin(PI*q))
        draw_line(prev,point,Color("6f42c3",weight*.28),29.0,true)
        draw_line(prev,point,Color("a37bf1",weight*.57),12.2,true)
        draw_line(prev,point,Color("f5e7ff",weight*.91),4.2,true)
        draw_line(prev,point,Color("fffeff",weight*.98),1.7,true)
        if k%5==0:_halo(point,23.0,Color("e4c0ff",weight*.25))
        prev=point
    for b in range(2):
        var q:=.43+float(b)*.28
        if reach<q+.02:continue
        var root:=point_on_bolt(q,t)
        var sign:float=-1.0 if b%2==0 else 1.0
        var end:=root+Vector2(sign*(47.0+float(b)*18.0),50.0)
        var mid:=root.lerp(end,.56)+Vector2(-sign*8.0,4.0)
        draw_line(root,mid,Color("ad7de8",gain*.50),7.0,true)
        draw_line(mid,end,Color("ad7de8",gain*.39),5.0,true)
        draw_line(root,mid,Color("fff2ff",gain*.82),1.6,true)
        draw_line(mid,end,Color("e5d1ff",gain*.62),1.2,true)
    # The auxiliary horizontal line remains subordinate to the ONE primary sky bolt.
    var sweep:=smoothstep(1.72,1.93,t)*(1.0-smoothstep(2.16,2.47,t))
    if sweep>.006:
        for idx in [0,2]:
            var dst:Vector2=CONTACTS[idx]
            var middle:=CENTER_HIT.lerp(dst,.51)+Vector2(0,8.0*sin(t*17.0+float(idx)))
            draw_line(CENTER_HIT,middle,Color("8861d7",sweep*.41),12.0,true)
            draw_line(middle,dst,Color("8861d7",sweep*.36),9.0,true)
            draw_line(CENTER_HIT,middle,Color("e4c5ff",sweep*.83),2.3,true)
            draw_line(middle,dst,Color("f7e2ff",sweep*.76),2.0,true)
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false)
    var base:=foot_gain(t)
    if base>.006:
        draw_texture_rect(_glow,Rect2(CASTER.x-147,CASTER.y-64,294,130),false,Color("9569dd",base*.24))
        draw_texture_rect(FLOOR,Rect2(CASTER.x-140,CASTER.y-64,280,132),false,Color(1,1,1,base*.84))
        for j in range(13):
            var a:=float(j)*TAU/13.0+t*.80
            var p:=CASTER+Vector2(cos(a)*101.0,9.0+sin(a)*41.0)
            _halo(p,9.0,Color("dfbaff",base*.31))
    var gate:=sky_gain(t)
    if gate>.005:
        var frame:=clampi(int(floor(smoothstep(.52,1.35,t)*9.99)),0,9)
        _halo(SKY,226.0,Color("6b42ad",gate*.20))
        draw_texture_rect(SKY_FRAMES[frame],Rect2(SKY-Vector2.ONE*205.0,Vector2.ONE*410.0),false,Color(1,1,1,gate*.93))
        for j in range(14):
            var a:=float(j)*2.399+t*.45
            var p:=SKY+Vector2(cos(a)*158.0,sin(a)*145.0)
            _halo(p,10.0,Color("eacaff",gate*(.17+.04*float(j%3))))
    _actor(CASTER)
    for idx in range(TARGET_LIMIT):
        _actor(TARGETS[idx])
    _draw_storm(t)
    for i in range(TARGET_LIMIT):
        var h:=hit_gain(t,i)
        if h<.006:continue
        var pos:Vector2=CONTACTS[i]
        _halo(pos,118.0,Color("7950de",h*.35))
        _halo(pos,53.0,Color("fff5ff",h*.65))
        var size:=Vector2.ONE*(204.0+40.0*(1.0-h))
        draw_texture_rect(IMPACT,Rect2(pos-size*.5,size),false,Color(1,1,1,h*.91))
    var dusk:=smoothstep(2.28,2.53,t)*(1.0-smoothstep(3.03,FADE_END,t))
    if dusk>.01:
        for j in range(26):
            var a:=float(j)*2.399
            var x:=740.0+float(j%3)*205.0+cos(a)*43.0
            var y:=448.0+sin(a)*28.0-(t-2.28)*31.0
            _halo(Vector2(x,y),22.0,Color("b690d9",dusk*.14))
