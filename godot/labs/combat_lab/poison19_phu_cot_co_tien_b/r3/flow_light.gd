extends Control
## POI19 R3 - REAL-TIME GODOT ENERGY MATERIAL (not an atlas preview).
## 60 Hz-independent smooth math; isolated, sprite-free emitted light paths
## over original POI19 80-pose RGBA. Only one selected WALK target.
## No skeletal rig, poster crop, damage, poison or real Combat V2 receipt.
const RELEASE_AT := 0.55
const CONTACT_AT := 1.35
const CONTACT_FADE := 2.10
const MARK_END := 7.85
const CLEAN_AT := 8.10
const CASTER_HAND := Vector2(352.0,449.0)
const TARGET_BASE := Vector2(895.0,548.0)

var visual_time: float = 0.0
var selected_foot: Vector2 = TARGET_BASE
var orchid_mark: Vector2 = Vector2(895.0,381.0)
var selected_projectile: Vector2 = CASTER_HAND
var mark_opacity: float = 0.0

static func target_at(t: float) -> Vector2:
    return TARGET_BASE + Vector2(31.0*sin(2.0*t+0.2),8.5*cos(1.3*t))

static func flight_u(t: float) -> float:
    var u: float=clampf((t-RELEASE_AT)/(CONTACT_AT-RELEASE_AT),0.0,1.0)
    return u*u*(3.0-2.0*u)

static func flight_at(t: float) -> Vector2:
    var u: float=flight_u(t)
    var dest: Vector2=target_at(t)+Vector2(-13.0,-70.0)
    return CASTER_HAND.lerp(dest,u)+Vector2(0.0,-66.0*sin(PI*u))

static func mark_visible(t: float) -> bool:
    return t >= CONTACT_AT and t < CLEAN_AT

static func affects_decoy(_t: float) -> bool:
    return false

func _ready() -> void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_preset(Control.PRESET_FULL_RECT)
    var additive:=CanvasItemMaterial.new()
    additive.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD
    material=additive
    print("POI19_R3_REAL_TIME_GODOT_LIGHT_LAYER_READY additive=true temporal_trails=true sprite_source=r2 selected_only=true")

func set_visual_state(t: float,foot: Vector2,mark: Vector2,shot: Vector2,mark_gain: float) -> void:
    visual_time=t
    selected_foot=foot
    orchid_mark=mark
    selected_projectile=shot
    mark_opacity=clampf(mark_gain,0.0,1.0)
    queue_redraw()

func _stroke(a: Vector2,b: Vector2,gain: float,width: float) -> void:
    if gain<=0.008 or a.distance_squared_to(b)<0.05:
        return
    # Four optical zones: invisible soft halo, colored luminescent body,
    # narrow turquoise silk, tiny concentrated warm-white inner emission.
    draw_line(a,b,Color(0.40,0.13,0.95,0.075*gain),width*4.4,true)
    draw_line(a,b,Color(0.71,0.29,1.0,0.16*gain),width*2.0,true)
    draw_line(a,b,Color(0.29,0.97,0.82,0.24*gain),width*.90,true)
    draw_line(a,b,Color(1.0,0.89,0.99,0.20*gain),maxf(.75,width*.31),true)

func _glow(where: Vector2,size: float,power: float) -> void:
    if power<=0.003:return
    draw_circle(where,size*3.6,Color(.52,.18,1.0,.028*power))
    draw_circle(where,size*2.1,Color(.30,.79,.91,.058*power))
    draw_circle(where,size,Color(.98,.79,1.0,.13*power))
    draw_circle(where,maxf(1.6,size*.34),Color(1.0,.98,.85,.26*power))

static func _bezier(a: Vector2,b: Vector2,c: Vector2,d: Vector2,u: float) -> Vector2:
    var v: float=1.0-u
    return a*v*v*v+b*(3.0*v*v*u)+c*(3.0*v*u*u)+d*u*u*u

func _charge(t: float) -> void:
    var q: float=smoothstep(0.0,.12,t)*(1.0-smoothstep(.39,.55,t))
    var glow_center:=CASTER_HAND
    _glow(glow_center,9.0+8.0*t,q*.88)
    for strand in range(3):
        var f: float=float(strand)
        var start:=glow_center+Vector2(-53.0+24.0*f,-57.0+18.0*f)
        var ctrl1:=start+Vector2(12.0,-24.0-7.0*f)
        var ctrl2:=glow_center+Vector2(-19.0+10.0*f,17.0-8.0*f)
        var prev: Vector2=_bezier(start,ctrl1,ctrl2,glow_center,0.0)
        for k in range(1,21):
            var u: float=float(k)/20.0
            var pos:=_bezier(start,ctrl1,ctrl2,glow_center,u)
            pos+=Vector2(0,3.0*sin(5.0*u+3.3*t+f*1.7)*sin(PI*u))
            _stroke(prev,pos,q*(.18+.75*u),3.3)
            prev=pos
    for k in range(5):
        var phi: float=2.4*float(k)+7.0*t
        var r: float=25.0-9.0*t
        _glow(glow_center+Vector2(cos(phi)*r,sin(phi)*r*.65),2.0,q*.22)

func _flight(t: float) -> void:
    var gate: float=smoothstep(.53,.64,t)*(1.0-smoothstep(1.29,1.38,t))
    var head: Vector2=selected_projectile
    # Native Godot gradient polylines, NOT dozens of disconnected bright rungs.
    # 3 independent translucent feather strands follow the true past projectile
    # positions; colors/alpha change smoothly per point, unlike baked PNG trails.
    for strand in range(3):
        var f: float=float(strand)
        var points:=PackedVector2Array()
        var halo:=PackedColorArray()
        var body:=PackedColorArray()
        var core:=PackedColorArray()
        for k in range(29):
            var tt: float=t-.016*float(k)
            if tt<RELEASE_AT:break
            var p: Vector2=flight_at(tt)
            var tangent: Vector2=flight_at(minf(tt+.015,CONTACT_AT))-flight_at(maxf(RELEASE_AT,tt-.015))
            var normal: Vector2=Vector2(-tangent.y,tangent.x).normalized()
            var tail: float=float(k)/29.0
            var separation: float=(f-1.0)*(3.7+2.2*sin(PI*tail))
            var silk: float=2.0*sin(1.55*t+2.1*tail+f*2.09)*sin(PI*tail)
            p+=normal*(separation+silk)
            var gain: float=pow(1.0-tail,1.42)*gate
            var prominence: float=1.0 if strand==1 else .48
            points.append(p)
            halo.append(Color(.43,.16,.98,.14*gain*prominence))
            body.append(Color(.52,.36,1.0,.30*gain*prominence))
            core.append(Color(.63,.98,.88,.31*gain*prominence))
        if points.size()>1:
            draw_polyline_colors(points,halo,21.0,true)
            draw_polyline_colors(points,body,10.6,true)
            draw_polyline_colors(points,core,2.4,true)
    _glow(head,9.0,gate*.95)
    for i in range(4):
        var sample_t: float=maxf(RELEASE_AT,t-.066*float(i+1))
        var pp: Vector2=flight_at(sample_t)
        var phase: float=2.399*float(i)+t*5.2
        _glow(pp+Vector2(cos(phase)*8.0,sin(phase)*8.0),2.5,gate*.23)

func _contact(t: float) -> void:
    var u: float=clampf((t-CONTACT_AT)/(CONTACT_FADE-CONTACT_AT),0.0,1.0)
    var fade: float=(1.0-smoothstep(.47,1.0,u))*.96
    var center: Vector2=selected_foot+Vector2(0.0,-85.0)
    _glow(center,12.0*(1.0-u)+5.0,fade*.65)
    # 3 curved strands WRAP ONE moving enemy and contract toward its center.
    # No 4 m AoE outline, no hard sprite circle, no damage visual.
    for strand in range(3):
        var f: float=float(strand)
        var prev: Vector2=Vector2.ZERO
        for k in range(23):
            var v: float=float(k)/22.0
            var angle: float=PI*(.89*v+.46*f)+u*3.4+f*.7
            var radius: float=(66.0-37.0*u)*(1.0-.45*v)
            var point:=center+Vector2(cos(angle)*radius,sin(angle)*radius*.68)
            point+=Vector2(0.0,-9.0*sin(2.4*v+u*3.0+f))
            if k>0:
                _stroke(prev,point,fade*(.41+.56*v),4.4-f*.65)
            prev=point
    for k in range(6):
        var phase: float=2.399*float(k)+2.7*u
        var rad: float=58.0-27.0*u
        _glow(center+Vector2(cos(phase)*rad,sin(phase)*rad*.73),3.0,fade*.37)

func _sustain(t: float) -> void:
    if mark_opacity<=.003:return
    var pulse: float=.82+.18*sin(2.0*PI*(t-CONTACT_AT)*1.6)
    var anchor:=orchid_mark
    # Narrow moving wisps pass through the SMALL status flower, not a giant UI glyph.
    for side in range(2):
        var f: float=float(side)
        var prev: Vector2=Vector2.ZERO
        for k in range(15):
            var u: float=float(k)/14.0
            var x: float=(-1.0 if side==0 else 1.0)*(14.0+12.0*sin(u*PI+1.4*t+f))
            var y: float=21.0-44.0*u+3.0*sin(t*2.0+7.0*u)
            var point:=anchor+Vector2(x,y)
            if k>0:
                _stroke(prev,point,mark_opacity*pulse*.36*sin(PI*u),1.7)
            prev=point
    _glow(anchor,10.8,mark_opacity*.74*pulse)
    # Small upward sparks. Not real poison stacks and not independent targets.
    for k in range(4):
        var f: float=float(k)
        var phase: float=t*.42+f*.38
        var loc:=anchor+Vector2(22.0*sin(2.399*f+2.0*t),
                               -10.0-29.0*fmod(phase,1.0))
        _glow(loc,2.4,mark_opacity*.15*(1.0-fmod(phase,1.0)))

func _draw() -> void:
    if visual_time < .55:
        _charge(visual_time)
    if visual_time>=.54 and visual_time<CONTACT_AT:
        _flight(visual_time)
    if visual_time>=CONTACT_AT and visual_time<CONTACT_FADE:
        _contact(visual_time)
    if mark_visible(visual_time):
        _sustain(visual_time)
