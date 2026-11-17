extends Control
## POI20 first-party in-engine white-core jade two-serpent energy.
## Drawn at native Godot frames on dedicated additive CanvasItem child.
## Lab-only: never applies poison, damage, status or a gameplay receipt.
const CONTACT_AT := 1.35
const CAST_AT := 0.43
const RELEASE_AT := 0.55
const SUSTAIN_END := 9.85
const FADE_END := 10.17
const CASTER_HAND := Vector2(352.0,449.0)
const TARGET_BASE := Vector2(895.0,548.0)
var visual_time: float = 0.0
var selected_foot: Vector2 = TARGET_BASE
var projectile_head: Vector2 = CASTER_HAND
var status_anchor: Vector2 = Vector2(895.0,370.0)
var status_alpha: float = 0.0

static func target_at(t: float)->Vector2:
    return TARGET_BASE+Vector2(31.0*sin(2.0*t+.2),8.5*cos(1.3*t))

static func flight_fraction(t: float)->float:
    var u: float=clampf((t-RELEASE_AT)/(CONTACT_AT-RELEASE_AT),0.0,1.0)
    return u*u*(3.0-2.0*u)

static func flight_at(t: float)->Vector2:
    var u: float=flight_fraction(t)
    var aim: Vector2=target_at(t)+Vector2(-12.0,-79.0)
    return CASTER_HAND.lerp(aim,u)+Vector2(0.0,-50.0*sin(PI*u))

static func is_visual_marked(t: float)->bool:
    return t>=CONTACT_AT and t<FADE_END

static func affects_decoy(_t: float)->bool:
    return false

func _ready()->void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_preset(Control.PRESET_FULL_RECT)
    var additive:=CanvasItemMaterial.new()
    additive.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD
    material=additive
    print("POI20_GODOT_ADD_SILVER_JADE_FLOW_READY light_only=true moving_single_target=true gameplay_receipt=false")

func set_state(t: float,target: Vector2,head: Vector2,mark: Vector2,gain: float)->void:
    visual_time=t
    selected_foot=target
    projectile_head=head
    status_anchor=mark
    status_alpha=clampf(gain,0.0,1.0)
    queue_redraw()

func halo(at: Vector2,opacity: float,radius: float)->void:
    if opacity<.004:return
    draw_circle(at,radius*3.3,Color(.31,.53,.81,.024*opacity))
    draw_circle(at,radius*1.7,Color(.30,.89,.72,.080*opacity))
    draw_circle(at,radius*.72,Color(.92,1.0,.95,.17*opacity))
    draw_circle(at,maxf(1.0,radius*.24),Color(1.0,.99,.89,.40*opacity))

func line_light(points: PackedVector2Array,power: float,width: float)->void:
    if points.size()<2 or power<.003:return
    var outside:=PackedColorArray()
    var middle:=PackedColorArray()
    var core:=PackedColorArray()
    for i in range(points.size()):
        var u: float=float(i)/float(points.size()-1)
        var fall: float=pow(maxf(0.0,1.0-u),1.2)
        outside.append(Color(.31,.22,.83,.085*power*fall))
        middle.append(Color(.24,.92,.70,.28*power*fall))
        core.append(Color(.99,1.0,.95,.39*power*fall))
    draw_polyline_colors(points,outside,width*4.1,true)
    draw_polyline_colors(points,middle,width*1.75,true)
    draw_polyline_colors(points,core,maxf(.8,width*.42),true)

func _charge(t: float)->void:
    var gain: float=smoothstep(.01,.12,t)*(1.0-smoothstep(.40,.56,t))
    halo(CASTER_HAND,gain,13.0)
    for branch in range(2):
        var side: float=-1.0 if branch==0 else 1.0
        var path:=PackedVector2Array()
        for k in range(24):
            var u: float=float(k)/23.0
            var x: float=CASTER_HAND.x-67.0+67.0*u
            var y: float=CASTER_HAND.y+side*35.0*(1.0-u)
            y+=side*11.0*sin(u*TAU*1.30+t*4.2)*sin(PI*u)
            path.append(Vector2(x,y))
        line_light(path,gain*.65,3.2)

func _flight(t: float)->void:
    var gate: float=smoothstep(.53,.65,t)*(1.0-smoothstep(1.29,1.39,t))
    for strand in range(3):
        var curve:=PackedVector2Array()
        var strand_shift: float=float(strand)-1.0
        for k in range(29):
            var tt: float=t-float(k)*.0155
            if tt<RELEASE_AT:break
            var p: Vector2=flight_at(tt)
            var tangent: Vector2=flight_at(minf(tt+.02,CONTACT_AT))-flight_at(maxf(RELEASE_AT,tt-.02))
            var normal: Vector2=Vector2(-tangent.y,tangent.x).normalized()
            var u: float=float(k)/28.0
            p+=normal*(strand_shift*3.2+2.3*sin(u*TAU+t*2.3+strand*1.72)*sin(PI*u))
            curve.append(p)
        line_light(curve,gate*(1.0 if strand==1 else .48),4.0)
    halo(projectile_head,gate,10.5)

func _wrapping(t: float)->void:
    var u:float=clampf((t-CONTACT_AT)/.98,0.0,1.0)
    var gain:float=(1.0-smoothstep(.63,1.0,u))
    var origin:Vector2=selected_foot+Vector2(0,-93)
    # R1B semantic: two flowing S-shaped snakes rise along torso; no orbit rings.
    for strand in range(2):
        var side:float=-1.0 if strand==0 else 1.0
        var ribbon:=PackedVector2Array()
        for k in range(35):
            var v:float=float(k)/34.0
            var xx:float=side*(19.0+21.0*sin(PI*v))
            xx+=20.0*sin(2.0*PI*(v*1.15+u*.46)+1.6*strand)*sin(PI*v)
            var yy:float=86.0-174.0*v+6.5*sin(5.5*v+u*3.1+strand)
            ribbon.append(origin+Vector2(xx,yy))
        line_light(ribbon,gain*.96,5.8)
        halo(ribbon[ribbon.size()-1],gain*.70,7.5)
    halo(origin+Vector2(0,-32),gain*.52,8.0)

func _sustain(t: float)->void:
    if status_alpha<.003:return
    var pulse:float=.80+.20*sin(2.0*PI*(t-CONTACT_AT)*1.12)
    var origin:Vector2=selected_foot+Vector2(0,-94)
    for strand in range(2):
        var side:float=-1.0 if strand==0 else 1.0
        var curve:=PackedVector2Array()
        for k in range(34):
            var v:float=float(k)/33.0
            var phase:float=2*PI*v*1.23+t*1.34+strand*PI*.69
            var xx:float=side*(20.0+18.0*sin(PI*v))
            xx+=12.0*sin(phase)*sin(PI*v)
            var yy:float=72.0-158.0*v+3.5*sin(phase*.8)
            curve.append(origin+Vector2(xx,yy))
        line_light(curve,status_alpha*pulse*.59,3.3)
        halo(curve[curve.size()-1],status_alpha*pulse*.30,5.2)
    halo(status_anchor,status_alpha*pulse*.68,10.4)
    for k in range(2):
        var z:float=fposmod(t*.31+k*.43,1.0)
        halo(status_anchor+Vector2((k*2-1)*13+5*sin(t*2),-8-30*z),
            status_alpha*(1.0-z)*.19,2.6)

func _draw()->void:
    if visual_time<RELEASE_AT:
        _charge(visual_time)
    if visual_time>=RELEASE_AT and visual_time<CONTACT_AT:
        _flight(visual_time)
    if visual_time>=CONTACT_AT and visual_time<CONTACT_AT+.98:
        _wrapping(visual_time)
    if is_visual_marked(visual_time):
        _sustain(visual_time)
