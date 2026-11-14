extends Control
## POI06 | Vạn Cổ Phệ Giới — ORIGINAL XIANXIA LIGHT-FORM ULTIMATE
## View-only Combat Lab; no rig, no actual poison/damage/status/target writes.
const SKILL_ID := "tmb.skill.poison.co_doc.ultimate.human"
const EFFECT := "poison"
const SHAPE := "circle"
const DECLARED_RADIUS := 3.0
const DECLARED_TARGET_LIMIT := 3
const DECLARED_CAST_TIME := 1.10
const DECLARED_RANGE := 8.0
const DECLARED_DURATION := 8.0
const DECLARED_STACKS := 2
const CASTER := Vector2(272.0,537.0)
const HAND := Vector2(328.0,428.0)
const REALM := Vector2(913.0,344.0)
const TARGETS := [Vector2(764.0,544.0),Vector2(924.0,534.0),Vector2(1085.0,542.0)]
const CAST_END := 1.10
const RIFT_OPEN := 2.04
const REALM_FULL := 2.50
const INFECTION_END := 3.80
const FADE_END := 5.13
const LOOP_SECONDS := 5.55
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const GU := [
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_0.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_1.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_2.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_3.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_4.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_5.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_6.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_7.svg"),
]
const BRANDS := [
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_0.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_1.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_2.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_3.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_4.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_5.svg"),
]
var elapsed := 0.0
var paused := false
var _glow: Texture2D
static func phase_at(t: float) -> String:
    if t < CAST_END: return "convergence"
    if t < RIFT_OPEN: return "transmission"
    if t < REALM_FULL: return "realm_open"
    if t < INFECTION_END: return "consumption"
    if t < FADE_END: return "dissolve"
    return "idle"
static func converged_at(t: float) -> float:
    return smoothstep(0.0,CAST_END,t)
static func realm_gain(t: float) -> float:
    if t < RIFT_OPEN or t > FADE_END: return 0.0
    return smoothstep(RIFT_OPEN,REALM_FULL,t)*(1.0-smoothstep(INFECTION_END,FADE_END,t))
static func connection_gain(t: float) -> float:
    if t < 2.35 or t > FADE_END: return 0.0
    return smoothstep(2.35,2.88,t)*(1.0-smoothstep(3.82,FADE_END,t))
static func flight_at(t: float) -> Vector2:
    var q := smoothstep(CAST_END,RIFT_OPEN,t)
    return HAND.lerp(REALM,q)+Vector2(0.0,-91.0*sin(PI*q))
static func swarm_progress(t: float,idx: int,rank: int) -> float:
    var start := 2.36+float(idx)*0.075+float(rank)*0.045
    return smoothstep(start,start+0.84,t)
static func swarm_position(t: float,idx: int,rank: int) -> Vector2:
    var q := swarm_progress(t,idx,rank)
    var k := float(idx)*2.71+float(rank)*2.399
    var from := REALM+Vector2(cos(k)*20.0,sin(k)*18.0)
    var target: Vector2 = TARGETS[idx]+Vector2((-1.0+float(rank%3))*43.0,-82.0+sin(k)*28.0)
    var curvature := Vector2(23.0*sin(PI*2.0*q+k)*sin(PI*q),-62.0*sin(PI*q))
    return from.lerp(target,q)+curvature
static func impact_gain(t: float,idx: int) -> float:
    var start := 3.05+float(idx)*0.095
    if t < start or t >= FADE_END: return 0.0
    return smoothstep(start,start+0.17,t)*(1.0-smoothstep(3.92,FADE_END,t))
func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    _glow=_radial_texture()
    set_process(true)
    queue_redraw()
    print("VFX_POI06_READY id=",SKILL_ID," gu_frames=",GU.size()," brand_frames=",BRANDS.size(),
        " targets=",DECLARED_TARGET_LIMIT," gameplay=false no_rig=true")
func _radial_texture() -> Texture2D:
    var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a := exp(-6.4*p.length_squared())*(1.0-smoothstep(0.69,1.0,p.length()))
            img.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(a,0.0,1.0)))
    return ImageTexture.create_from_image(img)
func _process(delta: float) -> void:
    if paused: return
    elapsed=fposmod(elapsed+maxf(0.0,delta),LOOP_SECONDS)
    queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode==KEY_P:
        paused=not paused
func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BACKGROUND,Rect2(0.0,0.0,1280.0,720.0),false,Color.WHITE)
    draw_rect(Rect2(0.0,0.0,1280.0,82.0),Color("0e1229",0.77))
    # The realm rests ABOVE target heads; dark nebula goes behind all actors.
    var open := realm_gain(t)
    if open>0.008:
        _halo(REALM,229.0,Color("6d5db4",open*0.16))
        _halo(REALM,141.0,Color("b1d9ae",open*0.12))
        _halo(REALM,75.0,Color("0c1326",open*0.64))
        _braided_halo(REALM,156.0,105.0,open,t*0.64+0.3,9)
        _braided_halo(REALM,119.0,82.0,open*0.42,-t*0.39,6)
        _petal_sparks(REALM,173.0,open,t,16)
    # Soft white-hot streams converge INTO A JAGGED RING at the caster's palm.
    var charge := smoothstep(0.03,0.53,t)*(1.0-smoothstep(1.06,1.35,t))
    if charge>0.006:
        var q := converged_at(t)
        _halo(HAND,95.0,Color("b7baff",charge*0.24))
        _halo(HAND,61.0,Color("c8ffd5",charge*0.28))
        for i in range(9):
            var k := float(i)
            var a := k*2.399+0.2*t
            var origin := HAND+Vector2(cos(a)*(107.0-31.0*q),sin(a)*(70.0-14.0*q))
            var finish := HAND+Vector2(cos(a+2.1)*28.0,sin(a+2.1)*21.0)
            _light_thread(origin,finish,charge*(0.35+0.075*float(i%4)),t+k*0.17,
                Color("bbffdb" if i%3 else "c7b2fb"),8.0)
        _braided_halo(HAND,41.0+7.0*q,28.0+5.0*q,charge,t*1.3+0.5,6)
        _halo(HAND,18.0,Color("faffdc",charge*0.64))
    # One light-form projectile, no exaggerated centipede or fake target hit.
    var flight := smoothstep(CAST_END,CAST_END+0.14,t)*(1.0-smoothstep(RIFT_OPEN-0.07,RIFT_OPEN+0.12,t))
    if flight>0.005:
        var point := flight_at(t)
        for j in range(5):
            var old := t-float(j+1)*0.057
            if old>CAST_END and old<RIFT_OPEN:
                _halo(flight_at(old),36.0-float(j)*3.0,Color("afffc9",flight*(0.19-0.025*float(j))))
        _halo(point,82.0,Color("927de4",flight*0.29))
        _halo(point,48.0,Color("c3ffce",flight*0.42))
        _halo(point,13.0,Color("fcffe0",flight*0.79))
        for j in range(3):
            var a := float(j)*2.32+0.22*sin(t*7.0)
            _light_thread(point,point+Vector2(cos(a)*42.0,sin(a)*28.0),
                flight*0.46,t+float(j),Color("bbffd6"),4.0)
    # Short, thin target channels behind actors, visual only.
    var coupling := connection_gain(t)
    if coupling>0.01:
        for idx in range(3):
            var source := REALM+Vector2((-1.0+float(idx))*61.0,41.0)
            var chest: Vector2 = TARGETS[idx]+Vector2(0.0,-69.0)
            _light_thread(source,chest,coupling*(0.49+0.075*float(idx)),
                t+float(idx)*0.37,Color("93ebb5"),5.0)
    # Repaint all dummy actors over background VFX, protecting the readability.
    _actor(CASTER,0.47,Color.WHITE)
    for idx in range(3):
        var target: Vector2 = TARGETS[idx]
        _actor(target,0.45,[Color("d4d0db"),Color("bccfc8"),Color("c6c5d9")][idx])
    # Original 8-pose flame-GU frames, 24 small bodies, never physical big bugs.
    if t>=2.36 and t<4.58:
        for idx in range(3):
            for j in range(8):
                var q := swarm_progress(t,idx,j)
                if q<=0.002:continue
                var fade := (1.0-smoothstep(4.10,4.58,t))*smoothstep(2.36,2.74,t)
                var pos := swarm_position(t,idx,j)
                var frame := posmod(int(floor(t*17.0))+idx*3+j,GU.size())
                var size := 0.155 if j==0 else 0.066+0.014*float(j%3)
                var tilt := 0.23*sin(t*8.0+float(j)*1.4)
                if j==0:
                    _halo(pos,38.0,Color("adffd1",fade*0.21))
                _paint(GU[frame],pos,size,tilt,
                    Color(1.0,1.0,1.0,fade*(0.87 if j==0 else 0.52)))
    # Three compact original brands, no actual poison_stacks or DoT simulation.
    for idx in range(3):
        var gain := impact_gain(t,idx)
        if gain<0.006:continue
        var at: Vector2 = TARGETS[idx]+Vector2(2.0,-72.0)
        var frame := posmod(int(floor((t-3.05)*11.0))+idx,BRANDS.size())
        _halo(at,61.0,Color("c9ffb8",gain*0.14))
        _paint(BRANDS[frame],at,0.32,0.075*sin(t*4.0+float(idx)),
            Color(1.0,1.0,1.0,gain*0.74))
        var born := 3.05+float(idx)*0.095
        if t>=born and t<born+0.18:
            var wave := 1.0-(t-born)/0.18
            _halo(at,41.0+29.0*(1.0-wave),Color("fffbe0",wave*0.40))
    if t>3.75 and t<FADE_END:
        var u := clampf((t-3.75)/(FADE_END-3.75),0.0,1.0)
        for j in range(30):
            var k := float(j)*2.399
            var spot := REALM+Vector2(cos(k)*(40.0+149.0*u),
                sin(k)*(27.0+74.0*u)-105.0*u)
            _halo(spot,5.0+2.0*(1.0-u),
                Color("d4a7ff" if j%3==0 else "dcffd9",(1.0-u)*0.38))
    draw_string(ThemeDB.fallback_font,Vector2(31,35),
        "VAN CO PHE GIOI  /  CO DOC TUYET KY",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("eaffee"))
    draw_string(ThemeDB.fallback_font,Vector2(32,61),
        "POI06  |  JADE CONVERGENCE / OPEN ABYSS REALM / 3 VISUAL TARGETS",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("b4c6cf"))
    draw_string(ThemeDB.fallback_font,Vector2(32,691),
        "GODOT 4.7.2 COMPATIBILITY  |  ART-ONLY  |  NO GAMEPLAY POISON/HP CHANGE",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("bbc5c7"))
    draw_string(ThemeDB.fallback_font,Vector2(1182,691),
        "%0.2fs" % t,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("c6cbbf"))
func _braided_halo(center: Vector2,rx: float,ry: float,alpha: float,t: float,segments: int) -> void:
    for lane in range(segments):
        var k := float(lane)
        var begin := k*2.399+t*(0.39+0.06*float(lane%3))
        var span := 0.29+0.23*float(lane%4)
        var pts := PackedVector2Array()
        for n in range(19):
            var q := float(n)/18.0
            var angle := begin+q*span
            var wobble := 1.0+0.045*sin(angle*4.0+t*3.2+k*2.0)
            pts.append(center+Vector2(cos(angle)*rx*wobble,
                sin(angle)*ry*(0.92+0.08*sin(t*2.2+k))))
        var l := alpha*(0.65+0.08*float(lane%3))
        draw_polyline(pts,Color("51417e",l*0.30),12.0,true)
        draw_polyline(pts,Color("86cfb4" if lane%3 else "a899f2",l*0.48),6.0,true)
        draw_polyline(pts,Color("dbffda",l*0.69),2.15,true)
        if lane%2==0:
            var tip: Vector2 = pts[pts.size()-1]
            _halo(tip,12.0,Color("f8ffe5",l*0.40))
func _light_thread(origin: Vector2,target: Vector2,alpha: float,t: float,tint: Color,curve: float) -> void:
    var pts := PackedVector2Array()
    for i in range(17):
        var q := float(i)/16.0
        var side := curve*sin(PI*q)*sin(t*5.7+q*8.2)
        pts.append(origin.lerp(target,q)+Vector2(-side*0.40,side))
    draw_polyline(pts,Color("384267",alpha*0.33),10.0,true)
    draw_polyline(pts,Color(tint,alpha*0.50),5.0,true)
    draw_polyline(pts,Color("f6ffe9",alpha*0.71),1.65,true)
    var tip: Vector2 = pts[pts.size()-1]
    _halo(tip,8.0,Color(tint,alpha*0.39))
func _petal_sparks(center: Vector2,r: float,alpha: float,t: float,count: int) -> void:
    for i in range(count):
        var k := float(i)
        var a := k*2.399+t*(0.58+0.03*float(i%3))
        var span := r*(0.64+0.29*sin(k*3.3+t)*sin(k*3.3+t))
        var p := center+Vector2(cos(a)*span,sin(a)*span*0.65)
        _halo(p,5.0+3.0*float(i%3),
            Color("e9ffd1" if i%3 else "cdbaff",alpha*(0.18+0.06*float(i%3))))
func _paint(tex: Texture2D,center: Vector2,size: float,angle: float,tint: Color) -> void:
    draw_set_transform(center,angle,Vector2.ONE*size)
    var dim := tex.get_size()
    draw_texture_rect(tex,Rect2(-dim/2.0,dim),false,tint)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
func _actor(center: Vector2,scale: float,tint: Color) -> void:
    _halo(center+Vector2(0.0,9.0),51.0,Color("080d1d",0.60))
    draw_texture_rect_region(ACTOR,
        Rect2(center-Vector2(160.0,351.0)*scale,Vector2(320.0,384.0)*scale),
        Rect2(0.0,0.0,320.0,384.0),tint)
func _halo(center: Vector2,r: float,tint: Color) -> void:
    draw_texture_rect(_glow,Rect2(center-Vector2.ONE*r,Vector2.ONE*r*2.0),false,tint)
