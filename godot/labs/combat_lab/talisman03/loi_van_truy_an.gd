extends Control
## TAL03 Lôi Văn Truy Ấn. MARK receipt is a demo ONLY; Combat V2 remains authoritative.
const SKILL_ID := "tmb.skill.talisman.loi_phu.active_03.human"
const EFFECT := "mark"
const ELEMENT := "lightning"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST_TIME := 0.50
const DECLARED_COOLDOWN := 12.2
const DECLARED_RANGE := 8.5
const DECLARED_DURATION := 6.0
const CASTER := Vector2(307.0,541.0)
const HAND := Vector2(366.0,427.0)
const VICTIM := Vector2(948.0,541.0)
const STAMP := Vector2(946.0,471.0)
const RELEASE_AT := .50
const DEMO_MARK_AT := .88
const STAMP_INITIAL_RADIUS := 52.0
const STAMP_STEADY_RADIUS := 40.0
const FADE_BEGIN := 6.88
const FADE_END := 7.14
const LOOP_SECONDS := 7.80
const PAINTED_MARKS: Texture2D = preload("res://labs/combat_lab/talisman03/assets/tal03_mark_flipbook.webp")
const PAINTED_MASTER: Texture2D = preload("res://labs/combat_lab/talisman03/assets/tal03_mark_master.webp")
const PAINTED_FOOT: Texture2D = preload("res://labs/combat_lab/talisman02/assets/talisman_foot_array.webp")
const MARKS := [
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_00.svg"),
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_01.svg"),
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_02.svg"),
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_03.svg"),
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_04.svg"),
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_05.svg"),
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_06.svg"),
    preload("res://labs/combat_lab/talisman03/assets/rune_mark_07.svg"),
]
const TALISMAN:Texture2D=preload("res://labs/combat_lab/talisman01/assets/thunder_talisman_atlas.webp")
const GROUND:Texture2D=PAINTED_FOOT
const BG:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed:=0.0
var paused:=false
var _hero:Sprite2D
var _atlas:AtlasTexture
var _radial:Texture2D
static func phase_at(t:float)->String:
    if t<RELEASE_AT:return "inscribe"
    if t<DEMO_MARK_AT:return "seal_flight"
    if t<FADE_END:return "demo_mark_present"
    return "idle"
static func mark_gain(t:float)->float:
    if t<DEMO_MARK_AT or t>=FADE_END:return 0.0
    return smoothstep(DEMO_MARK_AT,1.04,t)*(1.0-smoothstep(FADE_BEGIN,FADE_END,t))
static func foot_gain(t:float)->float:
    if t<.03 or t>=1.01:return 0.0
    return smoothstep(.03,.29,t)*(1.0-smoothstep(.56,1.01,t))
static func stamp_frame(t:float)->int:
    if t<DEMO_MARK_AT:return -1
    if t<1.36:return clampi(int((t-DEMO_MARK_AT)/.48*7.9),0,7)
    return 5+int(floor(t*2.5))%3
static func seal_position(t:float)->Vector2:
    var q:=smoothstep(RELEASE_AT,DEMO_MARK_AT,t)
    return HAND.lerp(STAMP,q)+Vector2(0,-64.0*sin(PI*q))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    _radial=_make_radial()
    _atlas=AtlasTexture.new()
    _atlas.atlas=TALISMAN
    _atlas.region=Rect2(0,0,300,360)
    _hero=Sprite2D.new()
    _hero.texture=_atlas
    _hero.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    _hero.z_index=4
    add_child(_hero)
    set_process(true)
    _update_hero()
    queue_redraw()
    print("VFX_TAL03_READY id=",SKILL_ID," mark_duration=6 poses=",MARKS.size()," visual_only=true no_rig=true")
func _make_radial()->Texture2D:
    var img:=Image.create(80,80,false,Image.FORMAT_RGBA8)
    for y in range(80):
        for x in range(80):
            var p:Vector2=(Vector2(float(x),float(y))-Vector2(39.5,39.5))/39.5
            img.set_pixel(x,y,Color(1,1,1,clampf(exp(-6.0*p.length_squared())*(1.0-smoothstep(.73,1.0,p.length())),0.0,1.0)))
    return ImageTexture.create_from_image(img)
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0.0,delta),LOOP_SECONDS)
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
    var a:=smoothstep(.08,.20,t)*(1.0-smoothstep(.79,1.04,t))
    _hero.visible=a>.005
    if not _hero.visible:return
    var i:=clampi(int(floor(clampf(t/.95,0,1)*11.9)),0,11)
    _atlas.region=Rect2(float(i%3)*300.0,float(i/3)*360.0,300,360)
    _hero.position=(HAND+Vector2(27,-23)) if t<RELEASE_AT else seal_position(t)
    _hero.scale=Vector2.ONE*(.38 if t<RELEASE_AT else lerpf(.38,.17,smoothstep(RELEASE_AT,DEMO_MARK_AT,t)))
    _hero.rotation=-.08+.07*sin(t*5.0)
    _hero.modulate=Color(1,1,1,a)
func _halo(pos:Vector2,r:float,col:Color)->void:
    if col.a<.005:return
    draw_texture_rect(_radial,Rect2(pos-Vector2.ONE*r,Vector2.ONE*r*2.0),false,col)
func _actor(pos:Vector2)->void:
    draw_texture_rect_region(ACTOR,Rect2(pos.x-72,pos.y-163,144,163),Rect2(0,0,320,384),Color("d4c9e4"))
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false)
    var foot:=foot_gain(t)
    if foot>.004:
        draw_texture_rect(_radial,Rect2(CASTER.x-104,CASTER.y-44,208,88),false,Color("8e5ce4",foot*.18))
        draw_texture_rect(GROUND,Rect2(CASTER.x-97,CASTER.y-46,194,94),false,Color(1,1,1,foot*.58))
    _actor(CASTER)
    _actor(VICTIM)
    if t>=RELEASE_AT and t<DEMO_MARK_AT:
        var pos:=seal_position(t)
        var a:=smoothstep(RELEASE_AT,.56,t)*(1.0-smoothstep(.77,DEMO_MARK_AT,t))
        _halo(pos,61.0,Color("a477ea",a*.33))
        _halo(pos,19.0,Color("fff0d4",a*.72))
        for j in range(5):
            var old:=t-float(j+1)*.045
            if old<RELEASE_AT:continue
            _halo(seal_position(old),11.0-float(j),Color("b7a0ef",a*(.20-float(j)*.025)))
    var m:=mark_gain(t)
    if m>.004:
        var frame:=stamp_frame(t)
        var q:=smoothstep(DEMO_MARK_AT,1.29,t)
        # Keep the quiet six-second glyph at chest scale, not across the enemy face.
        var radius:=lerpf(STAMP_INITIAL_RADIUS,STAMP_STEADY_RADIUS,q)*(1.0+.027*sin(t*3.3))
        _halo(STAMP,radius*1.5,Color("ae75fa",m*.21))
        # The original painted gilded glyph is the visible mark; procedural arcs are not substituted for it.
        var source_rect := Rect2(float(frame % 4) * 320.0, float(int(frame / 4)) * 320.0, 320.0, 320.0)
        draw_texture_rect_region(PAINTED_MARKS,Rect2(STAMP-Vector2.ONE*radius,Vector2.ONE*radius*2.0),source_rect,Color(1,1,1,m*(.79+.08*sin(t*2.8))))
        # One visible seal, no scripted real damage, mark application or periodic ticks.
