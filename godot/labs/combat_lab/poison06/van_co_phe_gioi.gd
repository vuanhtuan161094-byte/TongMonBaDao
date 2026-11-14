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
const PAINTED_REALM := [
    preload("res://labs/combat_lab/poison06/assets/realm_painted_00.png"),
    preload("res://labs/combat_lab/poison06/assets/realm_painted_01.png"),
    preload("res://labs/combat_lab/poison06/assets/realm_painted_02.png"),
    preload("res://labs/combat_lab/poison06/assets/realm_painted_03.png"),
    preload("res://labs/combat_lab/poison06/assets/realm_painted_04.png"),
    preload("res://labs/combat_lab/poison06/assets/realm_painted_05.png"),
    preload("res://labs/combat_lab/poison06/assets/realm_painted_06.png"),
    preload("res://labs/combat_lab/poison06/assets/realm_painted_07.png"),
]
const PAINTED_CHARGE := [
    preload("res://labs/combat_lab/poison06/assets/charge_painted_00.png"),
    preload("res://labs/combat_lab/poison06/assets/charge_painted_01.png"),
    preload("res://labs/combat_lab/poison06/assets/charge_painted_02.png"),
    preload("res://labs/combat_lab/poison06/assets/charge_painted_03.png"),
    preload("res://labs/combat_lab/poison06/assets/charge_painted_04.png"),
    preload("res://labs/combat_lab/poison06/assets/charge_painted_05.png"),
    preload("res://labs/combat_lab/poison06/assets/charge_painted_06.png"),
    preload("res://labs/combat_lab/poison06/assets/charge_painted_07.png"),
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
    print("VFX_POI06_R6_READY id=",SKILL_ID," gu_frames=",GU.size()," brand_frames=",BRANDS.size(),
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
        _halo(REALM,253.0,Color("8473c7",open*0.23))
        _halo(REALM,177.0,Color("b9efb8",open*0.23))
        _halo(REALM,92.0,Color("1b2a42",open*0.38))
        _halo(REALM,47.0,Color("efffdf",open*0.30))
        draw_texture_rect(_glow,Rect2(616.0,475.0,580.0,155.0),false,Color("a4dbb5",open*0.37))
        draw_texture_rect(_glow,Rect2(706.0,493.0,412.0,93.0),false,Color("c2a1f9",open*0.23))
        # Primary painted raster sprite: 8 independent 480x320 transparent realm frames.
        # Light strokes below are a minor glancing highlight; NEVER a HUD circle.
        var realm_frame := posmod(int(floor((t-RIFT_OPEN)*12.5)),PAINTED_REALM.size())
        _paint(PAINTED_REALM[(realm_frame+4)%PAINTED_REALM.size()],
            REALM+Vector2(-5.0,1.0),1.45,-0.019*sin(t*1.6),
            Color(1.0,1.0,1.0,open*0.96))
        _paint(PAINTED_REALM[realm_frame],REALM,1.24,0.026*sin(t*2.1),
            Color(1.0,1.0,1.0,open*0.93))
        # A third narrow luminous crest, retaining a visible dark center.
        _paint(PAINTED_REALM[(realm_frame+2)%PAINTED_REALM.size()],
            REALM+Vector2(8.0,-3.0),0.77,0.035*sin(t*2.8),
            Color("f1ffe5",open*0.55))
        _petal_sparks(REALM,193.0,open,t,24)
        _crown_burst(t,open)
    # Soft white-hot streams converge INTO A JAGGED RING at the caster's palm.
    var charge := smoothstep(0.03,0.53,t)*(1.0-smoothstep(1.06,1.35,t))
    if charge>0.006:
        var q := converged_at(t)
        _halo(HAND,95.0,Color("b7baff",charge*0.24))
        _halo(HAND,61.0,Color("c8ffd5",charge*0.28))
        # Nine moving stars follow short tangent trails toward the open ring;
        # unlike POI05 R2 they do NOT intersect as electrical spaghetti.
        for i in range(9):
            var k := float(i)
            var a := k*2.399 + 0.53*t
            var distance := 108.0-65.0*q+float(i%3)*3.0
            var pos := HAND+Vector2(cos(a)*distance,sin(a)*distance*0.66)
            var tang := Vector2(-sin(a),cos(a)*0.66)
            var intensity := charge*(0.43+0.10*float(i%3))
            draw_line(pos-tang*17.0,pos,Color("a3a1e1",intensity*0.35),7.0,true)
            draw_line(pos-tang*13.0,pos,Color("baffd4",intensity*0.65),2.9,true)
            draw_line(pos-tang*9.0,pos,Color("fcffe1",intensity*0.88),1.2,true)
            _halo(pos,10.0,Color("f5ffe0",intensity*0.51))
        # The hand seal is baked as 8 raster frames, not a static SVG ring.
        var charge_frame := posmod(int(floor(t*9.0)),PAINTED_CHARGE.size())
        _paint(PAINTED_CHARGE[charge_frame],HAND,0.78+0.10*q,
            0.04*sin(t*2.9),Color(1.0,1.0,1.0,charge*0.99))
        _paint(PAINTED_CHARGE[(charge_frame+3)%PAINTED_CHARGE.size()],
            HAND,0.67+0.07*q,-0.045*sin(t*2.7),
            Color("edffe5",charge*0.75))
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
            _light_thread(source,chest,coupling*(0.59+0.075*float(idx)),
                t+float(idx)*0.37,Color("93ebb5"),5.0)
    # Repaint all dummy actors over background VFX, protecting the readability.
    _actor(CASTER,0.47,Color.WHITE)
    # Front hand glints must survive character compositing, not mask the face.
    if charge>0.008:
        var visible_frame := posmod(int(floor(t*9.0)),PAINTED_CHARGE.size())
        _paint(PAINTED_CHARGE[visible_frame],HAND+Vector2(1.0,2.0),0.63,
            0.03*sin(t*2.3),Color(1.0,1.0,1.0,charge*0.65))
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
                if j%3==0:
                    _halo(pos,46.0 if j==0 else 28.0,Color("b6ffd2",fade*(0.32 if j==0 else 0.20)))
                _paint(GU[frame],pos,size,tilt,
                    Color("efffe6",fade*(0.92 if j==0 else 0.66)))
    # Three compact original brands, no actual poison_stacks or DoT simulation.
    for idx in range(3):
        var gain := impact_gain(t,idx)
        if gain<0.006:continue
        var at: Vector2 = TARGETS[idx]+Vector2(2.0,-72.0)
        var frame := posmod(int(floor((t-3.05)*11.0))+idx,BRANDS.size())
        _halo(at,76.0,Color("c9ffb8",gain*0.28))
        _paint(BRANDS[frame],at,0.39,0.075*sin(t*4.0+float(idx)),
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
        "POI06 R6  |  LAYERED ALPHA SPRITE REALM / CHARGE  |  ART QA",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("b4c6cf"))
    draw_string(ThemeDB.fallback_font,Vector2(32,691),
        "GODOT 4.7.2 COMPATIBILITY  |  ART-ONLY  |  NO GAMEPLAY POISON/HP CHANGE",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("bbc5c7"))
    draw_string(ThemeDB.fallback_font,Vector2(1182,691),
        "%0.2fs" % t,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("c6cbbf"))
func _crown_burst(t: float,open: float) -> void:
    # A brief central flash at full realm opening, not a persistent UI ring.
    var pulse := smoothstep(2.14,2.38,t)*(1.0-smoothstep(2.61,3.07,t))*open
    if pulse<0.005: return
    _halo(REALM,97.0,Color("e7ffda",pulse*0.31))
    _halo(REALM,35.0,Color("fffce4",pulse*0.51))
    for j in range(9):
        var k := float(j)
        var a := k*2.399+t*1.9
        var p := REALM+Vector2(cos(a)*54.0,sin(a)*38.0)
        var tip := p+Vector2(cos(a+0.35)*67.0,sin(a+0.35)*38.0)
        var mid := p.lerp(tip,0.53)+Vector2(6.0*sin(t*9.0+k),-8.0*sin(t*7.0+k))
        draw_line(p,mid,Color("9ac7aa",pulse*0.45),7.0,true)
        draw_line(mid,tip,Color("bca6f7",pulse*0.40),5.0,true)
        draw_line(p,mid,Color("feffde",pulse*0.55),1.6,true)
        _halo(tip,11.0,Color("c9ffd0",pulse*0.36))

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
