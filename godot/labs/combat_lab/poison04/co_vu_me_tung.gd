extends Control
## VFX-POI-04: Cổ Vụ Mê Tung — independently authored painted smoke sprites.
## Authentic canonical catalogue: poison/circle/radius 3/target_limit 3.
## View-only three DUMMIES. No combat, real hits, poison, SaveService or rig.
const SKILL_ID := "tmb.skill.poison.co_doc.active_03.human"
const EFFECT := "poison"
const SHAPE := "circle"
const DECLARED_RADIUS := 3.0
const DECLARED_TARGET_LIMIT := 3
const DECLARED_CAST_TIME := 0.65
const CASTER := Vector2(281.0, 509.0)
const ZONE := Vector2(895.0, 494.0)
const DUMMIES := [Vector2(787.0, 488.0),Vector2(896.0, 481.0),Vector2(1009.0, 490.0)]
const CAST_END := 0.65
const RELEASE_END := 0.79
const ARRIVE_AT := 1.35
const OPEN_END := 1.78
const HOLD_END := 3.20
const FADE_END := 4.05
const LOOP_SECONDS := 4.50
const FOG: Texture2D = preload("res://labs/combat_lab/poison04/assets/co_vu_painted_cloud.svg")
const WISP: Texture2D = preload("res://labs/combat_lab/poison04/assets/co_vu_smoke_tendril.svg")
const MOTH: Texture2D = preload("res://labs/combat_lab/poison04/assets/co_vu_gu_moth.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed := 0.0
var paused := false
var _radial: Texture2D
var _charge_cloud: Sprite2D
var _seed: Sprite2D
var _trails: Array[Sprite2D] = []
var _cloud_rear: Array[Sprite2D] = []
var _cloud_front: Array[Sprite2D] = []
var _wisps: Array[Sprite2D] = []
var _moths: Array[Sprite2D] = []
var _targets: Array[Sprite2D] = []

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < RELEASE_END: return "release"
    if t < ARRIVE_AT: return "flight"
    if t < OPEN_END: return "expand"
    if t < HOLD_END: return "sustain"
    if t < FADE_END: return "fade"
    return "idle"

static func flight_at(t: float) -> float:
    if t <= RELEASE_END: return 0.0
    var u := clampf((t - RELEASE_END) / (ARRIVE_AT - RELEASE_END), 0.0, 1.0)
    return u * u * (3.0 - 2.0 * u)

static func mist_gain(t: float) -> float:
    if t < ARRIVE_AT - 0.08 or t >= FADE_END: return 0.0
    return smoothstep(ARRIVE_AT - 0.08, OPEN_END, t) * (1.0 - smoothstep(HOLD_END, FADE_END, t))

static func seed_gain(t: float) -> float:
    if t < 0.18 or t >= ARRIVE_AT + 0.07: return 0.0
    return smoothstep(0.18,0.43,t) * (1.0 - smoothstep(ARRIVE_AT-0.08,ARRIVE_AT+0.07,t))

static func seed_at(t: float) -> Vector2:
    var start := CASTER + Vector2(68.0,-87.0)
    var end := ZONE + Vector2(-6.0,-31.0)
    var u := flight_at(t)
    return start.lerp(end,u) + Vector2(0.0,-92.0 * sin(PI*u))

static func preview_target_count() -> int:
    return DUMMIES.size()

func _ready() -> void:
    custom_minimum_size = Vector2(1280,720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _radial = _make_radial()
    _charge_cloud = _sprite(FOG,3,CanvasItemMaterial.BLEND_MODE_MIX)
    _seed = _sprite(MOTH,3,CanvasItemMaterial.BLEND_MODE_MIX)
    for i in range(6):
        _trails.append(_sprite(FOG,2,CanvasItemMaterial.BLEND_MODE_MIX))
    for i in range(4):
        _cloud_rear.append(_sprite(FOG,1,CanvasItemMaterial.BLEND_MODE_MIX))
    for i in range(5):
        _wisps.append(_sprite(WISP,1 if i < 3 else 3,CanvasItemMaterial.BLEND_MODE_MIX))
    for i in range(DUMMIES.size()):
        _targets.append(_target_actor(DUMMIES[i],i))
    for i in range(3):
        _cloud_front.append(_sprite(FOG,3,CanvasItemMaterial.BLEND_MODE_MIX))
    for i in range(6):
        _moths.append(_sprite(MOTH,4,CanvasItemMaterial.BLEND_MODE_MIX))
    _update_fx()
    set_process(true)
    queue_redraw()
    print("VFX_POI04_READY id=",SKILL_ID," dummy_targets=",DUMMIES.size()," view_only=true")

func _sprite(tex: Texture2D, z: int, blend: int) -> Sprite2D:
    var spr := Sprite2D.new()
    spr.texture = tex
    spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    spr.centered = true
    spr.z_index = z
    var mat := CanvasItemMaterial.new()
    mat.blend_mode = blend
    spr.material = mat
    add_child(spr)
    spr.visible = false
    return spr

func _target_actor(at: Vector2,index: int) -> Sprite2D:
    var spr := Sprite2D.new()
    var cut := AtlasTexture.new()
    cut.atlas = ACTOR
    cut.region = Rect2(0.0,0.0,320.0,384.0)
    spr.texture = cut
    spr.centered = false
    spr.scale = Vector2.ONE * 0.38
    spr.position = at - Vector2(160.0,351.0)*0.38
    spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    spr.modulate = [Color("c8d5c8"),Color("b3d3d8"),Color("c5bbd5")][index]
    spr.z_index = 2
    add_child(spr)
    return spr

func _make_radial() -> Texture2D:
    var image := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var alpha := exp(-5.5*p.length_squared())*(1.0-smoothstep(0.69,1.0,p.length()))
            image.set_pixel(x,y,Color(1,1,1,clampf(alpha,0.0,1.0)))
    return ImageTexture.create_from_image(image)

func _update_fx() -> void:
    var t := elapsed
    var seed_a := seed_gain(t)
    var charge := smoothstep(0.13,0.48,t)*(1.0-smoothstep(CAST_END,0.86,t))
    _charge_cloud.visible = charge > 0.005
    if _charge_cloud.visible:
        var hand := CASTER+Vector2(68,-87)
        _charge_cloud.position = hand+Vector2(6*sin(t*6.0),0)
        _charge_cloud.scale = Vector2(0.13+0.06*charge,0.13+0.05*charge)
        _charge_cloud.rotation = -0.25+0.09*sin(t*4.0)
        _charge_cloud.modulate = Color(1,1,1,0.60*charge)
    _seed.visible = seed_a > 0.007
    if _seed.visible:
        _seed.position = seed_at(t)
        var q := flight_at(t)
        _seed.scale = Vector2.ONE*(0.22+0.095*q)
        _seed.rotation = -0.2+0.14*sin(t*24.0)
        _seed.modulate = Color(1,1,1,seed_a*0.94)
    for i in range(_trails.size()):
        var lag := (float(i)+1.0)*0.045
        var prev_t := t-lag
        var trail := _trails[i]
        trail.visible = t>=RELEASE_END and t<ARRIVE_AT and prev_t>=RELEASE_END
        if trail.visible:
            trail.position = seed_at(prev_t)
            var sz := 0.18+float(i)*0.011
            trail.scale = Vector2(sz,sz*0.80)
            trail.rotation = float(i)*0.43-0.3
            trail.modulate = Color(1,1,1,seed_a*(0.24-float(i)*0.028))
    var mist := mist_gain(t)
    var opening := smoothstep(ARRIVE_AT-0.08,OPEN_END,t)
    for i in range(_cloud_rear.size()):
        var spr := _cloud_rear[i]
        spr.visible = mist>0.004
        if not spr.visible: continue
        var k := float(i)
        var offset_x := [-130.0,-46.0,72.0,149.0][i]
        var offset_y := [-12.0,-51.0,-34.0,-14.0][i]
        var wander := Vector2(14.0*sin(t*(0.88+0.19*k)+k*1.7),7.0*sin(t*(1.2+0.13*k)+k))
        spr.position = ZONE+Vector2(offset_x,offset_y)+wander
        var f := (0.54+0.05*k)*opening
        spr.scale = Vector2(f, (0.39+0.035*k)*opening)
        spr.rotation = (k-1.3)*0.075+0.055*sin(t*0.90+k)
        spr.modulate = Color(1,1,1,mist*(0.50+0.035*k))
    for i in range(_cloud_front.size()):
        var spr := _cloud_front[i]
        spr.visible = mist>0.005
        if not spr.visible: continue
        var k := float(i)
        var offs := Vector2([-116.0,4.0,133.0][i], [31.0,40.0,24.0][i])
        spr.position = ZONE+offs+Vector2(11.0*sin(t*0.78+k*2.1), 4.0*sin(t*1.3+k))
        spr.scale = Vector2((0.53+0.035*k)*opening,0.19*opening)
        spr.rotation = (k-1.0)*0.07+0.04*sin(t*0.8+k)
        spr.modulate = Color(1,1,1,mist*(0.25+0.025*k))
    for i in range(_wisps.size()):
        var spr := _wisps[i]
        spr.visible = mist>0.025
        if not spr.visible: continue
        var k := float(i)
        var dx := [-148.0,-70.0,5.0,85.0,153.0][i]
        var rise := minf(maxf((t-ARRIVE_AT)*15.0,0.0),28.0)
        spr.position = ZONE+Vector2(dx+14.0*sin(t*0.93+k*1.5),-66.0-rise+7.0*sin(t*1.35+k))
        spr.scale = Vector2(0.35+0.05*sin(k*1.5),0.31+0.045*sin(t*1.15+k))
        spr.rotation = -0.11+0.08*sin(t*0.74+k*1.9)
        spr.modulate = Color(1,1,1,mist*(0.32 if i<3 else 0.11))
    for i in range(_moths.size()):
        var spr := _moths[i]
        var k := float(i)
        var born := ARRIVE_AT+0.16+k*0.105
        var alive := t-born
        spr.visible = alive>=0.0 and alive<1.33 and mist>0.02
        if not spr.visible: continue
        var phase := clampf(alive/1.33,0.0,1.0)
        var px := (k-2.5)*65.0+20.0*sin(t*(2.0+0.13*k)+k)
        var py := -65.0-27.0*sin(PI*phase)-16.0*sin(t*1.7+k)
        spr.position = ZONE+Vector2(px,py)
        spr.scale = Vector2.ONE*(0.115+0.035*sin(k*2.1))
        spr.rotation = 0.24*sin(t*7.0+k*1.5)
        spr.modulate = Color(1,1,1,mist*0.34*sin(PI*phase))

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed+maxf(0.0,delta),LOOP_SECONDS)
    _update_fx()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        _update_fx()
        queue_redraw()
    elif event.keycode == KEY_P:
        paused = not paused

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("101622"))
    draw_rect(Rect2(0,0,1280,84),Color("142029"))
    draw_texture_rect(_radial,Rect2(70,150,1115,535),false,Color("374f51",0.12))
    for i in range(10):
        var y := 271.0+float(i)*37.0
        draw_line(Vector2(85,y),Vector2(1198,y+9),Color("7c8981",0.064),1.0)
    for i in range(13):
        var x := 85.0+float(i)*98.0
        draw_line(Vector2(x,250),Vector2(x+90,635),Color("747881",0.057),1.0)
    for i in range(62):
        var k := float(i)
        draw_circle(Vector2(92.0+fposmod(k*179.17,1089.0),272.0+fposmod(k*61.91,352.0)),0.77,Color("cad2b8",0.11))
    _halo(CASTER+Vector2(5,5),52.0,Color("071116",0.7))
    for pos in DUMMIES:
        _halo(pos+Vector2(4,4),47.0,Color("0b1019",0.66))
    var rc := Rect2(0,0,320,384)
    draw_texture_rect_region(ACTOR,Rect2(CASTER-Vector2(160,351)*0.43,Vector2(320,384)*0.43),rc,Color.WHITE)
    var t := elapsed
    var charge := smoothstep(0.13,0.50,t)*(1.0-smoothstep(CAST_END,0.87,t))
    if charge>0.004:
        var hand := CASTER+Vector2(68,-87)
        _halo(hand,68.0,Color("79dcac",charge*0.28))
        _halo(hand,18.0,Color("e9ffbd",charge*0.37))
        for i in range(7):
            var k := float(i)
            var a := k*2.399+t*3.0
            _halo(hand+Vector2(cos(a)*32.0,sin(a)*21.0),6.5,Color("b0b0fd" if i%3==0 else "a4ffd2",charge*0.27))
    if t>=RELEASE_END and t<ARRIVE_AT:
        var pos := seed_at(t)
        _halo(pos,68.0,Color("9bffbd",seed_gain(t)*0.14))
    var mist := mist_gain(t)
    if mist>0.004:
        var ground := ZONE+Vector2(0,27)
        draw_texture_rect(_radial,Rect2(ground-Vector2(275,83),Vector2(550,166)),false,Color("397b71",mist*0.30))
        draw_texture_rect(_radial,Rect2(ground-Vector2(228,55),Vector2(456,110)),false,Color("c1feae",mist*0.18))
        for i in range(16):
            var k := float(i)
            var a := k*2.399
            var p := ground+Vector2(cos(a)*minf(212.0,50.0+11.2*k),sin(a)*minf(62.0,17.0+3.6*k))
            var pulse := (0.73+0.27*sin(t*2.8+k))*mist
            _halo(p,6.5,Color("baffbf" if i%3!=0 else "bfa7ff",pulse*0.27))
        if t>=ARRIVE_AT and t<ARRIVE_AT+0.19:
            var u := (t-ARRIVE_AT)/0.19
            _halo(ZONE+Vector2(0,-8),82.0+79.0*u,Color("ddffc8",(1.0-u)*0.36))
    if t>=HOLD_END and t<FADE_END:
        var q := (t-HOLD_END)/(FADE_END-HOLD_END)
        for i in range(17):
            var k := float(i)
            var a := k*2.399
            var pt := ZONE+Vector2(cos(a)*(31.0+173.0*q),-46.0+sin(a)*(14.0+64.0*q)-46.0*q)
            _halo(pt,8.0,Color("e0ffd4",(1.0-q)*0.26))
    draw_string(ThemeDB.fallback_font,Vector2(32,38),
        "CO VU ME TUNG  |  CO DOC",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e5ffed"))
    draw_string(ThemeDB.fallback_font,Vector2(32,65),
        "ORIGINAL PAINTED POISON MIST / CIRCLE R=3 / UP TO 3 CANONICAL TARGETS",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("9db9b7"))
    draw_string(ThemeDB.fallback_font,Vector2(32,683),
        "VFX-POI-04  |  GODOT 4.7.2 COMPATIBILITY  |  LAB DUMMIES / NO REAL POISON",
        HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("b0cfc5"))
    draw_string(ThemeDB.fallback_font,Vector2(1168,684),
        "%0.2fs" % t,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("98b9b5"))

func _halo(center: Vector2,radius: float,tint: Color) -> void:
    draw_texture_rect(_radial,Rect2(center-Vector2.ONE*radius,Vector2.ONE*radius*2.0),false,tint)
