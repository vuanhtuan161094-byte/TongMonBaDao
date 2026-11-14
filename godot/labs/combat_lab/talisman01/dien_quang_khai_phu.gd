extends Control
## VFX TAL01 R4 art-first rebuild. Original ImageGen painting is a baked 12-pose
## independent PNG atlas, with separately authored luminous lightning and impact.
## Strictly view-only. Never gives damage, poison, status or target ownership.
const SKILL_ID := "tmb.skill.talisman.loi_phu.active_01.human"
const EFFECT := "damage"
const ELEMENT := "lightning"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST_TIME := 0.50
const DECLARED_COOLDOWN := 9.40
const DECLARED_RANGE := 8.50
const DECLARED_PROJECTILE_SPEED := 10.0
const CASTER := Vector2(329.0, 544.0)
const HAND := Vector2(399.0, 417.0)
const VICTIM := Vector2(961.0, 541.0)
const IMPACT := Vector2(949.0, 454.0)
const CHARGE_END := 0.50
const RELEASE_END := 0.72
const CONTACT_AT := 1.43
const CONTACT_END := 1.76
const FADE_END := 2.66
const LOOP_SECONDS := 3.13
const ATLAS: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_talisman_atlas.webp")
const IMPACT_TEX: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_impact_burst.png")
const FOOT_SIGIL: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_cast_sigil.svg")
const CONTACT_SIGIL: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_contact_sigil.svg")
const BACKDROP: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const STANDIN_ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed := 0.0
var paused := false
var _talisman: Sprite2D
var _cell: AtlasTexture
var _glow: Texture2D

static func phase_at(t: float) -> String:
    if t < CHARGE_END: return "ink_charge"
    if t < RELEASE_END: return "seal_release"
    if t < CONTACT_AT: return "electric_flight"
    if t < CONTACT_END: return "demo_contact"
    if t < FADE_END: return "dissolve"
    return "idle"
static func travel_q(t: float) -> float:
    if t <= RELEASE_END: return 0.0
    return smoothstep(RELEASE_END, CONTACT_AT, t)
static func bolt_position(t: float) -> Vector2:
    var q := travel_q(t)
    return HAND.lerp(IMPACT,q)+Vector2(0.0,-72.0*sin(PI*q))
static func contact_gain(t: float) -> float:
    if t < CONTACT_AT or t >= CONTACT_END: return 0.0
    return smoothstep(CONTACT_AT,CONTACT_AT+0.042,t)*(1.0-smoothstep(CONTACT_AT+0.13,CONTACT_END,t))
static func ground_gain(t: float) -> float:
    if t < 0.04 or t >= 1.29: return 0.0
    return smoothstep(0.04,0.27,t)*(1.0-smoothstep(0.82,1.29,t))
static func ground_contact_gain(t: float) -> float:
    if t < CONTACT_AT or t >= FADE_END: return 0.0
    return smoothstep(CONTACT_AT,CONTACT_AT+0.09,t)*(1.0-smoothstep(1.90,FADE_END,t))
static func seal_gain(t: float) -> float:
    if t < 0.03 or t > CONTACT_AT + 0.11: return 0.0
    return smoothstep(0.03,0.19,t)*(1.0-smoothstep(CONTACT_AT-0.05,CONTACT_AT+0.11,t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0,720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _glow = _soft_circle()
    _cell = AtlasTexture.new()
    _cell.atlas = ATLAS
    _cell.region = Rect2(0.0,0.0,300.0,360.0)
    _talisman = Sprite2D.new()
    _talisman.texture = _cell
    _talisman.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _talisman.z_index = 4
    add_child(_talisman)
    _update_seal()
    set_process(true)
    queue_redraw()
    print("VFX_TAL01_READY id=",SKILL_ID," visual_only=true atlas=12 painting=true R4")
func _soft_circle() -> Texture2D:
    var im := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var falloff := exp(-4.9*p.length_squared())*(1.0-smoothstep(0.78,1.0,p.length()))
            im.set_pixel(x,y,Color(1,1,1,clampf(falloff,0.0,1.0)))
    return ImageTexture.create_from_image(im)
func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    _update_seal()
    queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        _update_seal()
    elif event.keycode==KEY_P:
        paused=not paused
func _update_seal() -> void:
    var t := elapsed
    var gain := seal_gain(t)
    _talisman.visible = gain > 0.002
    if not _talisman.visible: return
    var q := clampf(t/1.42,0.0,1.0)
    var f := clampi(int(floor(q*11.9)),0,11)
    _cell.region = Rect2(float(f%3)*300.0,float(f/3)*360.0,300.0,360.0)
    var lift := smoothstep(0.0,0.50,t)
    var center := HAND+Vector2(38.0,-19.0-13.0*lift)
    if t > RELEASE_END:
        var v := travel_q(t)
        # The physical talisman holds the *head* of the projectile, instead of
        # floating as an unrelated rectangle above a detached lightning line.
        center = bolt_position(t)+Vector2(0.0,-38.0*(1.0-v))
    _talisman.position = center
    _talisman.rotation = -0.08+0.07*sin(t*9.0)+(0.19 if t>RELEASE_END else 0.0)
    _talisman.scale = Vector2.ONE * (0.58 if t<RELEASE_END else lerpf(0.58,0.24,travel_q(t)))
    _talisman.modulate = Color(1.0,1.0,1.0,gain)
func _halo(at:Vector2, radius:float, tint:Color) -> void:
    if tint.a<0.002: return
    draw_texture_rect(_glow,Rect2(at-Vector2.ONE*radius,Vector2.ONE*(radius*2.0)),false,tint)
func _draw_actor(at:Vector2,tint:Color) -> void:
    draw_texture_rect_region(STANDIN_ACTOR,Rect2(at.x-72.0,at.y-163.0,144.0,163.0),Rect2(0,0,320,384),tint)
func _thread(a:Vector2,b:Vector2,t:float,k:float,bright:float, width:float=1.0) -> void:
    if bright <= 0.005: return
    var mid := a.lerp(b,0.5)+Vector2(0.0,6.0*sin(k*7.2+t*27.0))
    draw_line(a,mid,Color("7764cc",bright*.39),18.0*width,true)
    draw_line(mid,b,Color("7764cc",bright*.36),18.0*width,true)
    draw_line(a,mid,Color("b9a3ff",bright*.85),7.2*width,true)
    draw_line(mid,b,Color("b9a3ff",bright*.83),7.2*width,true)
    draw_line(a,mid,Color("fff5ff",bright*.99),2.25*width,true)
    draw_line(mid,b,Color("fff5ff",bright*.99),2.25*width,true)
func _path_point(q:float, t:float, lane:int) -> Vector2:
    var center := HAND.lerp(IMPACT,q)+Vector2(0.0,-72.0*sin(PI*q))
    var envelope := sin(PI*q)
    var jitter := 9.0*sin(q*43.0+t*19.0+float(lane)*2.33)+5.0*sin(q*87.0-t*31.0+float(lane))
    var offset := (float(lane)-1.0)*13.0*envelope
    return center+Vector2(0.0,(jitter+offset)*envelope)
func _draw_ground_seals(t:float) -> void:
    var g := ground_gain(t)
    if g > 0.004:
        var flicker := 0.90+0.08*sin(t*18.0)
        draw_texture_rect(_glow,Rect2(CASTER.x-128.0,CASTER.y-50.0,256.0,102.0),false,Color("7547b8",g*.22))
        draw_texture_rect(FOOT_SIGIL,Rect2(CASTER.x-130.0,CASTER.y-57.0,260.0,122.0),false,Color(1.0,1.0,1.0,g*flicker))
        for j in range(10):
            var a := float(j)*TAU/10.0+t*1.1
            var point := CASTER+Vector2(cos(a)*95.0,7.0+sin(a)*37.0)
            _halo(point,8.5,Color("d9aaff",g*(0.23+0.16*float(j%3)/2.0)))
    var h := ground_contact_gain(t)
    if h > 0.004:
        draw_texture_rect(_glow,Rect2(VICTIM.x-115.0,VICTIM.y-42.0,230.0,87.0),false,Color("9167d8",h*.22))
        draw_texture_rect(CONTACT_SIGIL,Rect2(VICTIM.x-95.0,VICTIM.y-47.0,190.0,96.0),false,Color(1.0,1.0,1.0,h*.85))
func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BACKDROP,Rect2(0.0,0.0,1280.0,720.0),false,Color.WHITE)
    # Restrained ground spill, not a permanent large opaque spell-circle disk.
    var energy := smoothstep(0.11,0.38,t)*(1.0-smoothstep(1.50,2.26,t))
    draw_texture_rect(_glow,Rect2(253.0,521.0,196.0,69.0),false,Color("9d6edc",energy*.33))
    draw_texture_rect(_glow,Rect2(838.0,519.0,229.0,70.0),false,Color("c8b2ff",contact_gain(t)*.25))
    # Converging filaments gather into the real talisman; no naked SVG paper.
    var charge := smoothstep(0.04,0.23,t)*(1.0-smoothstep(0.73,1.02,t))
    var seal_pos := HAND+Vector2(38.0,-32.0)
    if charge>0.005:
        _halo(seal_pos,124.0,Color("643fe4",charge*.58))
        _halo(seal_pos,82.0,Color("a07bf3",charge*.64))
        _halo(seal_pos,37.0,Color("ffe6ae",charge*.54))
        for j in range(9):
            var i := float(j)
            var a := i*2.399+t*2.3
            var radius := lerpf(126.0,51.0,smoothstep(0.07,0.50,t))
            var pos := seal_pos+Vector2(cos(a)*radius,sin(a)*radius*.78)
            var next := seal_pos+Vector2(cos(a+.21)*(radius-12.0),sin(a+.21)*(radius-12.0)*.78)
            _thread(pos,next,t,i,charge*(0.35+float(j%3)*.12),.55)
            _halo(pos,14.0,Color("d2a0ff",charge*.28))
        # Purple ritual line only partially wraps the talisman instead of using
        # an opaque circular interface glyph on the character.
        for j in range(2):
            var a0 := 1.2+float(j)*2.9+t*.65
            for k in range(10):
                var a := a0+float(k)*.089
                var b := a+.075
                var w := 66.0+8.0*sin(t*3.1+float(j))
                var p1 := seal_pos+Vector2(cos(a)*w,sin(a)*w*.76)
                var p2 := seal_pos+Vector2(cos(b)*w,sin(b)*w*.76)
                draw_line(p1,p2,Color("ddbeff",charge*.40*(1.0-float(k)*.034)),1.9,true)
    # Ground decals are intentionally painted BEFORE actors to preserve feet and silhouette.
    _draw_ground_seals(t)
    _draw_actor(CASTER,Color("d8cee1"))
    _draw_actor(VICTIM,Color("b6c3d7"))
    if t>=RELEASE_END and t<=CONTACT_AT+.09:
        _draw_bolt(t)
    if t>=CONTACT_AT and t<FADE_END:
        _draw_contact(t)
    if t>=1.75 and t<FADE_END:
        var tail := 1.0-smoothstep(1.77,FADE_END,t)
        for k in range(19):
            var z := float(k)
            var a := z*2.399+0.3
            var r := 18.0+(t-1.75)*(35.0+float(k%5)*10.0)
            var p := IMPACT+Vector2(cos(a)*r,sin(a)*r*.75)
            _halo(p,8.0,Color("e7baff",tail*.25))
func _draw_bolt(t:float) -> void:
    var q := travel_q(t)
    var linger := (1.0-smoothstep(CONTACT_AT,CONTACT_AT+.095,t)) if t>CONTACT_AT else 1.0
    var gain := smoothstep(RELEASE_END,RELEASE_END+.085,t)*linger
    if gain <= 0.002: return
    _halo(HAND,83.0,Color("a27be9",gain*.29))
    var tip := bolt_position(t) if t<CONTACT_AT else IMPACT
    _halo(tip,112.0,Color("8055f4",gain*.53))
    _halo(tip,63.0,Color("c69afa",gain*.86))
    _halo(tip,24.0,Color("fffffa",gain*.99))
    # Every path segment is backed by soft radial texture to avoid hard-edge
    # polyline noodles in Godot GL Compatibility.
    for lane in range(3):
        var prev := HAND
        for s in range(36):
            var x := float(s+1)/36.0*q
            var point := _path_point(x,t,lane)
            var intensity := gain*(1.65 if lane==1 else .85)*(0.50+0.50*sin(PI*x))
            _halo(point,39.0 if lane==1 else 24.0,Color("9669e9",intensity*.39))
            _thread(prev,point,t,float(s+lane*43),intensity,(1.16 if lane==1 else .52))
            prev=point
    for b in range(4):
        var z := q-(.12+float(b)*.14)
        if z<=.04: continue
        var root := _path_point(z,t,1)
        var sign := 1.0 if b%2==0 else -1.0
        var end := root+Vector2(-14.0,sign*(34.0+9.0*float(b)))
        _thread(root,end,t,float(b)+1.6,gain*.50,.50)
func _draw_contact(t:float) -> void:
    var hit := contact_gain(t)
    if hit > 0.003:
        _halo(IMPACT,198.0,Color("754ae7",hit*.44))
        _halo(IMPACT,98.0,Color("a87bfa",hit*.78))
        _halo(IMPACT,49.0,Color("ffeafd",hit*.98))
        # Alpha-authored shock fracture, not six identical vector spokes.
        var q := smoothstep(CONTACT_AT,CONTACT_END,t)
        var scale := lerpf(1.04,1.68,smoothstep(0.0,.58,q))
        var side := Vector2.ONE*(218.0*scale)
        draw_texture_rect(IMPACT_TEX,Rect2(IMPACT-side*.5,side),false,Color(1.0,1.0,1.0,hit*.99))
        for j in range(17):
            var i := float(j)
            var a := i*2.399+t*.3
            var r := 17.0+float(j%4)*11.0+q*80.0
            var pos := IMPACT+Vector2(cos(a)*r,sin(a)*r*.72)
            _halo(pos,15.0,Color("b99aff",hit*.55))
    var trail := smoothstep(CONTACT_AT,CONTACT_AT+.21,t)*(1.0-smoothstep(1.93,FADE_END,t))
    if trail>0.005:
        _halo(IMPACT,88.0,Color("7256aa",trail*.13))
        for j in range(5):
            var i := float(j)
            var a := i*2.399+0.6
            var root := IMPACT+Vector2(cos(a)*32.0,sin(a)*25.0)
            var end := root+Vector2(cos(a)*25.0,sin(a)*17.0)
            _thread(root,end,t,i+8.0,trail*.24,.33)
