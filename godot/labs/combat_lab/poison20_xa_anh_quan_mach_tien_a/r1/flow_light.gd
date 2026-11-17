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
        outside.append(Color(.31,.22,.83,.09*power*fall))
        middle.append(Color(.24,.92,.70,.20*power*fall))
        core.append(Color(.99,1.0,.95,.23*power*fall))
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
    var u: float=clampf((t-CONTACT_AT)/.98,0.0,1.0)
    var gain: float=(1.0-smoothstep(.63,1.0,u))
    var center: Vector2=selected_foot+Vector2(0,-92)
    for strand in range(2):
        var pts:=PackedVector2Array()
        var side: float=float(strand)
        for k in range(37):
            var v: float=float(k)/36.0
            var angle: float=-2.65+v*TAU*1.20+u*2.1+side*PI*.48
            var radius: float=(66.0-15*u)*(1.0-.24*v)
            pts.append(center+Vector2(cos(angle)*radius,sin(angle)*radius*.77-20.0*v))
        line_light(pts,gain*.75,4.5)
    halo(center,gain*.75,12.0)

func _sustain(t: float)->void:
    if status_alpha<.003:return
    var pulse: float=.79+.21*sin(2.0*PI*(t-CONTACT_AT)*1.15)
    var center: Vector2=selected_foot+Vector2(0,-96)
    for strand in range(2):
        var side: float=-1.0 if strand==0 else 1.0
        var curve:=PackedVector2Array()
        for k in range(26):
            var u: float=float(k)/25.0
            var th: float=-1.05+u*TAU*.83+1.1*t+float(strand)*PI
            var rad: float=45.0+7.0*sin(1.7*t+u*5.5+strand)
            var p:=center+Vector2(cos(th)*rad*side,sin(th)*rad*.65-19*u)
            curve.append(p)
        line_light(curve,status_alpha*pulse*.24,2.0)
    halo(status_anchor,status_alpha*pulse*.57,9.5)
    # two soft particles above the target indicate DOUBLE poison-vein motif.
    for k in range(2):
        var z: float=fposmod(t*.28+k*.43,1.0)
        halo(status_anchor+Vector2((k*2-1)*13+6*sin(t*2),-11-34*z),
            status_alpha*(1.0-z)*.23,2.5)

func _draw()->void:
    if visual_time<RELEASE_AT:
        _charge(visual_time)
    if visual_time>=RELEASE_AT and visual_time<CONTACT_AT:
        _flight(visual_time)
    if visual_time>=CONTACT_AT and visual_time<CONTACT_AT+.98:
        _wrapping(visual_time)
    if is_visual_marked(visual_time):
        _sustain(visual_time)
