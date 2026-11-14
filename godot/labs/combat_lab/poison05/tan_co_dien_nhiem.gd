extends Control
## POI05 — Tán Cổ Diễn Nhiễm, original twelve-frame chrysalis dispersal.
## Three preview actors only; NO hit, poison, new status, save, Combat V2 or rig.
const SKILL_ID := "tmb.skill.poison.co_doc.active_04.human"
const EFFECT := "poison"
const SHAPE := "circle"
const DECLARED_RADIUS := 2.5
const DECLARED_TARGET_LIMIT := 3
const DECLARED_CAST_TIME := 0.55
const DECLARED_RANGE := 7.0
const DECLARED_DURATION := 7.0
const DECLARED_POISON_STACKS := 1
const CASTER := Vector2(276.0,535.0)
const TARGETS := [Vector2(771.0,530.0),Vector2(911.0,520.0),Vector2(1054.0,537.0)]
const CORE := Vector2(913.0,340.0)
const CAST_END := 0.55
const ARRIVAL := 1.28
const BLOOM_END := 1.82
const HOLD_END := 2.86
const FADE_END := 3.64
const LOOP_SECONDS := 4.10
const COCOON := [
    preload("res://labs/combat_lab/poison05/assets/cocoon_00.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_01.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_02.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_03.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_04.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_05.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_06.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_07.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_08.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_09.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_10.svg"),
    preload("res://labs/combat_lab/poison05/assets/cocoon_11.svg"),
]
const SCARAB := [
    preload("res://labs/combat_lab/poison05/assets/spore_scarab_0.svg"),
    preload("res://labs/combat_lab/poison05/assets/spore_scarab_1.svg"),
    preload("res://labs/combat_lab/poison05/assets/spore_scarab_2.svg"),
    preload("res://labs/combat_lab/poison05/assets/spore_scarab_3.svg"),
]
const MARK: Texture2D = preload("res://labs/combat_lab/poison05/assets/spore_infection_mark.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed := 0.0
var paused := false
var _soft_disc: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < ARRIVAL: return "travel"
    if t < BLOOM_END: return "burst"
    if t < HOLD_END: return "spread"
    if t < FADE_END: return "dissolve"
    return "idle"

static func travel_at(t: float) -> float:
    return smoothstep(CAST_END, ARRIVAL, t)

static func cocoon_frame_at(t: float) -> int:
    if t < ARRIVAL: return clampi(int(floor(t * 4.0)),0,2)
    var u := clampf((t-ARRIVAL)/(BLOOM_END-ARRIVAL),0.0,1.0)
    return clampi(3 + int(floor(u*9.0)),3,11)

static func spread_gain(t: float) -> float:
    if t < ARRIVAL or t >= FADE_END: return 0.0
    return smoothstep(ARRIVAL,BLOOM_END,t)*(1.0-smoothstep(HOLD_END,FADE_END,t))

static func scarab_depart(t: float, idx: int) -> float:
    var start := ARRIVAL + 0.14 + float(idx)*0.075
    return smoothstep(start,start+0.56,t)

static func scarab_position(t: float, idx: int) -> Vector2:
    var q := scarab_depart(t,idx)
    var from := CORE + Vector2(-6.0,16.0)
    var to: Vector2 = TARGETS[idx]+Vector2(3.0,-62.0)
    var wave := (1.0-q)*sin(q*PI*3.0+float(idx)*1.8)*19.0
    return from.lerp(to,q)+Vector2(0,-38.0*sin(PI*q)+wave)

static func mark_gain(t: float, idx: int) -> float:
    var at := ARRIVAL + 0.66 + float(idx)*0.075
    if t < at or t >= FADE_END: return 0.0
    return smoothstep(at,at+0.20,t)*(1.0-smoothstep(HOLD_END,FADE_END,t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280,720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _soft_disc = _make_radial()
    set_process(true)
    queue_redraw()
    print("VFX_POI05_READY id=",SKILL_ID,
        " cocoon_frames=",COCOON.size()," scarab_frames=",SCARAB.size(),
        " target_caps=",DECLARED_TARGET_LIMIT," gameplay_mutation=false")

func _make_radial() -> Texture2D:
    var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a := exp(-5.6*p.length_squared())*(1.0-smoothstep(0.66,1.0,p.length()))
            img.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(a,0.0,1.0)))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0.0,delta),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode==KEY_P:
        paused=not paused

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("101722"))
    draw_rect(Rect2(0,0,1280,85),Color("14242e"))
    draw_texture_rect(_soft_disc,Rect2(66,137,1100,540),false,Color("455962",0.13))
    for i in range(11):
        var y := 267.0 + float(i)*36.0
        draw_line(Vector2(64,y),Vector2(1220,y+15),Color("647a86",0.083),1.0)
    for i in range(13):
        var x := 77.0+float(i)*92.0
        draw_line(Vector2(x,250),Vector2(x+102,669),Color("748487",0.064),1.0)
    for i in range(72):
        var k := float(i)
        draw_circle(Vector2(84+fposmod(k*171.39,1082),275+fposmod(k*63.75,330)),0.9,Color("c1d0b4",0.11))
    _halow(CASTER+Vector2(4,7),60,Color("0a111c",0.67))
    for p in TARGETS:
        _halow(p+Vector2(0,8),46,Color("0c1120",0.56))
    var t := elapsed
    # BACKGROUND image-backed petals & branching infection channels, before dummy actors.
    var charge := smoothstep(0.04,0.41,t)*(1.0-smoothstep(CAST_END,CAST_END+0.14,t))
    var from := CASTER+Vector2(66,-115)
    var u := travel_at(t)
    var traveling := from.lerp(CORE,u)+Vector2(0,-91*sin(PI*u))
    if charge>0.004:
        _halow(from,72,Color("b9ffb5",charge*0.32))
        _paint(COCOON[cocoon_frame_at(t)],from,Vector2.ONE*(0.21+0.04*charge),0.09*sin(t*7),Color(1,1,1,charge*0.99))
        for i in range(7):
            var a := float(i)*2.399+t*2.7
            _halow(from+Vector2(cos(a)*35,sin(a)*25),7,Color("cdffb4",charge*0.33))
    if t>=CAST_END and t < ARRIVAL+0.14:
        var flight := smoothstep(CAST_END,CAST_END+0.15,t)*(1.0-smoothstep(ARRIVAL-0.07,ARRIVAL+0.14,t))
        for j in range(4):
            var delayed := t-0.067*float(j+1)
            if delayed > CAST_END and delayed < ARRIVAL:
                var q := travel_at(delayed)
                var at := from.lerp(CORE,q)+Vector2(0,-91*sin(PI*q))
                _paint(COCOON[clampi(cocoon_frame_at(delayed),0,2)],at,Vector2.ONE*(0.18-float(j)*0.023),0,
                    Color("9bc9d0",flight*(0.18-float(j)*0.031)))
        _halow(traveling,95,Color("baf9b1",flight*0.25))
        _paint(COCOON[cocoon_frame_at(t)],traveling,Vector2.ONE*(0.30+0.035*u),0.11*sin(t*9),Color(1,1,1,flight))
    var spread := spread_gain(t)
    if spread > 0.006:
        _halow(CORE,168,Color("6676ac",spread*0.16))
        # Seven broken jade chitin filaments, NOT a flat neon AoE ring.
        for target_idx in range(3):
            var path := PackedVector2Array()
            var p0 := CORE + Vector2((float(target_idx)-1.0)*12,14)
            var to: Vector2 = TARGETS[target_idx]+Vector2(0,-61)
            for step in range(20):
                var q := float(step)/19.0
                var wave := sin(q*PI*3.0+float(target_idx)*2.3+t*2.1)*15.0*sin(PI*q)
                var pos := p0.lerp(to,q)+Vector2(0,-31.0*sin(PI*q)+wave)
                path.append(pos)
            draw_polyline(path,Color("2b3c58",spread*0.48),9.0,true)
            draw_polyline(path,Color("94c6aa",spread*0.38),4.0,true)
            draw_polyline(path,Color("ebffd9",spread*0.28),1.3,true)
    # The actual caster/three preview target sprites remain visually readable.
    _actor(CASTER,0.47,Color.WHITE)
    for idx in range(3):
        _actor(TARGETS[idx],0.43,[Color("c1ccca"),Color("b6c8df"),Color("c3b9d3")][idx])
    # FOREGROUND unique twelve-pose core dispersal, 4-pose gu spirits & small talon marks.
    if t>=ARRIVAL and t<FADE_END:
        var bloom := clampf((t-ARRIVAL)/(BLOOM_END-ARRIVAL),0,1)
        var stage := cocoon_frame_at(t)
        var alpha := minf(1.0,smoothstep(ARRIVAL,ARRIVAL+0.13,t))*(1.0-smoothstep(1.92,2.25,t))
        var size := (0.24+0.12*bloom)*(1.0+0.021*sin(t*13))
        _halow(CORE,88+58*bloom,Color("c2ffb8",alpha*0.31))
        _paint(COCOON[stage],CORE,Vector2.ONE*size,0.13*sin(t*4.8),Color(1,1,1,alpha*0.92))
        if t>=ARRIVAL and t<ARRIVAL+0.26:
            var pulse := (t-ARRIVAL)/0.26
            _halow(CORE,60+146*pulse,Color("f0ffd4",(1-pulse)*0.52))
        for i in range(3):
            var born := ARRIVAL+0.14+float(i)*0.075
            if t>=born and t<born+1.25:
                var q := scarab_depart(t,i)
                var at: Vector2 = scarab_position(t,i)
                var fade := 1.0-smoothstep(born+0.87,born+1.25,t)
                var frame := int(floor((t-born)*18.0))%SCARAB.size()
                _halow(at,42,Color("a2ffd1",alpha*fade*0.18))
                _paint(SCARAB[frame],at,Vector2.ONE*(0.26+0.045*q),0.15*sin(t*18+float(i)),
                    Color(1,1,1,alpha*fade*0.92))
                for j in range(2):
                    var past := t-0.07*float(j+1)
                    if past>=born:
                        var prev := scarab_position(past,i)
                        _paint(SCARAB[clampi(frame,0,3)],prev,Vector2.ONE*.16,0,
                            Color("87baba",alpha*fade*(0.14-0.046*float(j))))
    # Secondary image-backed gu seeds spread in three staggered schools of motion.
    # They are particles only, NOT extra target/poison procs.
    if t>=ARRIVAL+0.16 and t<HOLD_END:
        var fleet := smoothstep(ARRIVAL+0.16,ARRIVAL+0.48,t)*(1.0-smoothstep(2.44,HOLD_END,t))
        for wing in range(12):
            var trail_idx := wing%3
            var rank := int(wing/3)
            var start := ARRIVAL+0.17+float(rank)*0.09+float(trail_idx)*0.045
            var progress := smoothstep(start,start+0.68,t)
            var a := float(wing)*2.399
            var origin := CORE+Vector2(cos(a)*26.0,sin(a)*19.0)
            var finish: Vector2 = TARGETS[trail_idx]+Vector2(cos(a)*33.0,-76.0+sin(a)*26.0)
            var flutter := Vector2(23.0*sin(progress*PI*2.0+a),-30.0*sin(PI*progress))
            var position := origin.lerp(finish,progress)+flutter
            var glyph := int(floor((t-start)*21.0+float(wing)))%4
            var spore_size := 0.064+0.019*float(rank%3)
            _paint(SCARAB[glyph],position,Vector2.ONE*spore_size,0.22*sin(t*13.0+a),
                Color("baffd2",fleet*(0.27+0.07*sin(a)*sin(a))))
    for idx in range(3):
        var mark_alpha := mark_gain(t,idx)
        if mark_alpha<0.006:continue
        var at: Vector2 = TARGETS[idx]+Vector2(5,-68)
        var time_local := t-(ARRIVAL+0.66+float(idx)*0.075)
        var s := 0.145+0.015*sin(time_local*8)
        _halow(at,57,Color("b9ffb8",mark_alpha*0.14))
        _paint(MARK,at,Vector2.ONE*s,0.14*sin(time_local*4+float(idx)),Color(1,1,1,mark_alpha*0.71))
        for j in range(6):
            var a := float(j)*2.399+float(idx)*0.3
            var r := 36+19*sin(t*2.5+float(j))
            var p: Vector2 = at+Vector2(cos(a)*r,sin(a)*r*.75)
            _halow(p,5,Color("ddffb4",mark_alpha*0.31))
    # Fade all visual effects by 3.64s; no real poison source/status modifications.
    draw_string(ThemeDB.fallback_font,Vector2(31,39),
        "TAN CO DIEN NHIEM  /  CO DOC",HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("e8ffed"))
    draw_string(ThemeDB.fallback_font,Vector2(32,67),
        "12 AUTHORED GU COCOON FRAMES / 4 BEETLE WING POSES / 3 PREVIEW TARGETS",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("a4c3c1"))
    draw_string(ThemeDB.fallback_font,Vector2(34,686),
        "VFX-POI-05  |  GODOT 4.7.2 COMPATIBILITY  |  VIEW-ONLY  /  NOT A REAL POISON PROC",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("afc6bb"))
    draw_string(ThemeDB.fallback_font,Vector2(1179,686),
        "%0.2fs" % elapsed,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("a4c2be"))

func _paint(tex: Texture2D,center: Vector2,scale: Vector2,rotation: float,color: Color) -> void:
    draw_set_transform(center,rotation,scale)
    var size := tex.get_size()
    draw_texture_rect(tex,Rect2(-size/2.0,size),false,color)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(center: Vector2,scale: float,tint: Color) -> void:
    var region := Rect2(0,0,320,384)
    var corner := center-Vector2(160,351)*scale
    draw_texture_rect_region(ACTOR,Rect2(corner,Vector2(320,384)*scale),region,tint)

func _halow(center: Vector2,radius: float,color: Color) -> void:
    draw_texture_rect(_soft_disc,Rect2(center-Vector2.ONE*radius,Vector2.ONE*radius*2),false,color)
