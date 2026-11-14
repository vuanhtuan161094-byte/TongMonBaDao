extends Control
## POI-05 R6 — Tán Cổ Diễn Nhiễm. Independent original Tu Tien xianxia remake.
## One spectral chitin gu carries a living seed and divides into three VISUAL escorts.
## No fake gameplay hits/procs/status; real Combat V2/PvE remains HOLD.
## All motion is frame-by-frame (not skeletal/rigged).
const SKILL_ID := "tmb.skill.poison.co_doc.active_04.human"
const EFFECT := "poison"
const SHAPE := "circle"
const DECLARED_RADIUS := 2.5
const DECLARED_TARGET_LIMIT := 3
const DECLARED_CAST_TIME := 0.55
const CASTER := Vector2(248.0,543.0)
const TARGETS := [Vector2(751.0,537.0),Vector2(921.0,527.0),Vector2(1087.0,544.0)]
const BIRTH := Vector2(925.0,346.0)
const CAST_END := 0.55
const ARRIVAL := 1.32
const SPLIT_END := 1.65
const HOLD_END := 2.92
const FADE_END := 3.72
const LOOP_SECONDS := 4.20
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const GU := [
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_00.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_01.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_02.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_03.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_04.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_05.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_06.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_07.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_08.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_09.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_10.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_11.svg"),
]
const SEED := [
    preload("res://labs/combat_lab/poison05/remake_r6/assets/seed_0.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/seed_1.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/seed_2.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/seed_3.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/seed_4.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/seed_5.svg"),
]
const MARK := [
    preload("res://labs/combat_lab/poison05/remake_r6/assets/mark_0.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/mark_1.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/mark_2.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/mark_3.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/mark_4.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/mark_5.svg"),
]
var elapsed := 0.0
var paused := false
var _glow: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < ARRIVAL: return "flight"
    if t < SPLIT_END: return "split"
    if t < HOLD_END: return "infection"
    if t < FADE_END: return "dissolve"
    return "idle"

static func gu_frame(t: float, salt: int = 0) -> int:
    return posmod(int(floor(maxf(0.0,t)*19.0))+salt,12)

static func seed_frame(t: float) -> int:
    return clampi(int(floor(t/CAST_END*5.9)),0,5)

static func main_travel(t: float) -> float:
    return smoothstep(CAST_END,ARRIVAL,t)

static func escort_start(idx: int) -> float:
    return 1.42+float(idx)*0.095

static func escort_progress(t: float, idx: int) -> float:
    var start := escort_start(idx)
    return smoothstep(start,start+0.63,t)

static func main_point(t: float) -> Vector2:
    var q := main_travel(t)
    var origin := CASTER+Vector2(68.0,-95.0)
    return origin.lerp(BIRTH,q)+Vector2(0.0,-94.0*sin(PI*q)+9.0*sin(PI*4.0*q)*sin(PI*q))

static func escort_point(t: float, idx: int) -> Vector2:
    var q := escort_progress(t,idx)
    var from := BIRTH+Vector2((float(idx)-1.0)*14.0,12.0)
    var dest: Vector2 = TARGETS[idx]+Vector2(0.0,-73.0)
    var curl := Vector2((1.0-q)*27.0*sin(6.5*q+float(idx)*2.3),
        -64.0*sin(PI*q)+(1.0-q)*12.0*sin(PI*4.0*q+float(idx)))
    var orbit := maxf(0.0,t-(escort_start(idx)+0.60))
    curl+=Vector2(14.0*sin(orbit*10.0+float(idx)*1.7),7.0*cos(orbit*8.0+float(idx)))*smoothstep(0.0,0.14,orbit)
    return from.lerp(dest,q)+curl

static func mark_gain(t: float, idx: int) -> float:
    var begin := escort_start(idx)+0.62
    if t < begin or t >= FADE_END: return 0.0
    return smoothstep(begin,begin+0.16,t)*(1.0-smoothstep(HOLD_END,FADE_END,t))

static func visual_total(t: float) -> float:
    if t >= FADE_END:return 0.0
    return 1.0-smoothstep(HOLD_END,FADE_END,t)

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    _glow=_make_glow()
    set_process(true)
    queue_redraw()
    print("VFX_POI05_R6_READY id=",SKILL_ID,
        " gu_frames=",GU.size()," seed_frames=",SEED.size(),
        " mark_frames=",MARK.size()," declared_targets=",DECLARED_TARGET_LIMIT,
        " view_only=true no_rig=true")

func _make_glow() -> Texture2D:
    var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var v := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a := exp(-5.8*v.length_squared())*(1.0-smoothstep(0.65,1.0,v.length()))
            img.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(a,0.0,1.0)))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0.0,delta),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode == KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode == KEY_P:
        paused=not paused

func _draw() -> void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    draw_rect(Rect2(0,0,1280,88),Color("0c0e22",0.79))
    var t := elapsed
    var from := CASTER+Vector2(68.0,-95.0)
    var charge := smoothstep(0.04,0.36,t)*(1.0-smoothstep(CAST_END-0.06,CAST_END+0.13,t))
    # Dark xianxia ritual energy, centered at the caster's casting hand (NOT face).
    if charge>0.004:
        _halo(from,79.0,Color("b4a2ff",charge*0.29))
        _halo(from+Vector2(-5.0,0.0),48.0,Color("b0ffb1",charge*0.31))
        var seed_pos := from+Vector2(4.0*sin(t*6.0),6.0*sin(t*4.2))
        _paint(SEED[seed_frame(t)],seed_pos,0.20+0.075*charge,0.12*sin(t*6.0),
            Color(1.0,1.0,1.0,charge*0.92))
        for j in range(9):
            var angle := float(j)*2.399+t*2.7
            var at := from+Vector2(cos(angle)*33.0,sin(angle)*21.0)
            _halo(at,5.0,Color("c8a3ff" if j%2==0 else "dcffd5",charge*0.43))
    # Traveling spirit: chitin-plated CENTIPEDE, not a symmetrical flower or snake ribbon.
    if t >= CAST_END and t<ARRIVAL+0.12:
        var q := main_travel(t)
        var a := smoothstep(CAST_END,CAST_END+0.15,t)*(1.0-smoothstep(ARRIVAL-0.045,ARRIVAL+0.12,t))
        var current := main_point(t)
        for j in range(4):
            var old := t-0.06*float(j+1)
            if old>CAST_END and old<ARRIVAL:
                var pt := main_point(old)
                _paint(GU[gu_frame(old,j)],pt,0.265-float(j)*0.024,0.06*sin(old*7.0),
                    Color("a7aedb",a*(0.18-float(j)*0.034)))
        _halo(current,88.0,Color("967af1",a*0.21))
        _halo(current,62.0,Color("b7ffd0",a*0.16))
        _paint(GU[gu_frame(t)],current,0.39+0.040*q,
            0.075*sin(t*7.0),Color(1.0,1.0,1.0,a))
    # At arrival only a fleeting fractured spirit burst, no neon AOE disc.
    if t>=ARRIVAL and t<1.83:
        var burst := smoothstep(ARRIVAL,ARRIVAL+0.15,t)*(1.0-smoothstep(1.62,1.83,t))
        _halo(BIRTH,143.0,Color("aa79f3",burst*0.24))
        _halo(BIRTH,88.0,Color("e8ffdc",burst*0.31))
        for j in range(12):
            var angle := float(j)*2.399+0.14*sin(t*7.0+float(j))
            var r := 25.0+145.0*smoothstep(ARRIVAL,1.83,t)+float(j%3)*11.0
            var point := BIRTH+Vector2(cos(angle)*r,sin(angle)*r*0.56)
            _halo(point,5.0+float(j%3),Color("dbffcc" if j%3 else "ce9dff",burst*(0.25+0.07*float(j%3))))
    # Thin hooked crawling traces behind actors, not straight thick "electric tentacles".
    var spread := smoothstep(1.43,1.68,t)*(1.0-smoothstep(2.23,2.56,t))
    if spread>0.008:
        for idx in range(3):
            var path := PackedVector2Array()
            var end := escort_progress(t,idx)
            for step in range(12):
                var delayed_t := escort_start(idx)+maxf(0.0,end-0.35+float(step)*0.032)*0.63
                var q := clampf(end-0.35+float(step)*0.032,0.0,1.0)
                var first := BIRTH+Vector2((float(idx)-1.0)*14.0,12.0)
                var target: Vector2 = TARGETS[idx]+Vector2(0.0,-73.0)
                var wave := Vector2((1.0-q)*27.0*sin(6.5*q+float(idx)*2.3),
                    -64.0*sin(PI*q)+(1.0-q)*12.0*sin(PI*4.0*q+float(idx)))
                path.append(first.lerp(target,q)+wave)
            draw_polyline(path,Color("2d204b",spread*0.64),7.0,true)
            draw_polyline(path,Color("a77ae1",spread*0.43),3.1,true)
            draw_polyline(path,Color("caffdf",spread*0.35),1.2,true)
    # Actor silhouettes over the background effects for battle readability.
    _shadow(CASTER)
    _actor(CASTER,0.47,Color.WHITE)
    for idx in range(3):
        var center: Vector2 = TARGETS[idx]
        _shadow(center)
        _actor(center,0.445,[Color("c9d3df"),Color("c6d0cf"),Color("d6c6db")][idx])
    # Live illustrated gu sprite flipbooks, three branches, NOT forced real triple hits.
    if t>=1.41 and t<3.28:
        for idx in range(3):
            var start := escort_start(idx)
            var q := escort_progress(t,idx)
            var alpha := smoothstep(start,start+0.18,t)*(1.0-smoothstep(2.75+float(idx)*0.10,3.28,t))
            if alpha<0.008:continue
            var pt := escort_point(t,idx)
            var size := 0.32+0.065*q+0.017*sin(t*8.0+float(idx)*2.0)
            var tilt := -0.14+0.22*sin(t*6.0+float(idx)*1.4)
            _halo(pt,72.0,Color("bca0fc",alpha*0.19))
            _halo(pt,49.0,Color("d0ffcb",alpha*0.16))
            for j in range(3):
                var old := t-0.06*float(j+1)
                if old>start:
                    _paint(GU[gu_frame(old,idx+j)],escort_point(old,idx),
                        maxf(0.14,size-0.033*float(j+1)),tilt,
                        Color("a0c5cd",alpha*(0.17-0.040*float(j))))
            _paint(GU[gu_frame(t,idx*3)],pt,size,tilt,Color(1,1,1,alpha*0.89))
    # Infection visual at chest/arms, staggered in ART only. 7s canonical gameplay duration NOT simulated.
    for idx in range(3):
        var gain := mark_gain(t,idx)
        if gain<0.006:continue
        var center: Vector2 = TARGETS[idx]+Vector2(3.0,-73.0)
        var born := escort_start(idx)+0.62
        var local := maxf(0.0,t-born)
        var turn := int(floor(local*14.0))%MARK.size()
        var size := 0.34+0.03*sin(t*5.2+float(idx)*2.0)
        var a := -0.08+0.15*sin(t*4.2+float(idx)*1.5)
        _halo(center,70.0,Color("b38bea",gain*0.14))
        _paint(MARK[turn],center,size,a,Color(1,1,1,gain*0.79))
        if local<0.19:
            var spark := 1.0-local/0.19
            _halo(center,41.0+35.0*(1.0-spark),Color("e8ffda",spark*0.43))
        for j in range(7):
            var angle := float(j)*2.399+t*0.58+float(idx)
            var r := 29.0+22.0*sin(t*2.8+float(j))
            var pos := center+Vector2(cos(angle)*r,sin(angle)*r*.81)
            _halo(pos,5.5,Color("dbfbc8" if j%2 else "be8ff4",gain*0.37))
    # Final spiritual embers drift upward; all visual effects fully clear after FADE_END.
    if t>=HOLD_END and t<FADE_END:
        var u := (t-HOLD_END)/(FADE_END-HOLD_END)
        for j in range(34):
            var k := float(j)
            var idx := j%3
            var anchor: Vector2 = TARGETS[idx]+Vector2(-25.0,-77.0)
            var angle := k*2.399
            var pt := anchor+Vector2(cos(angle)*(13.0+87.0*u),
                sin(angle)*(17.0+60.0*u)-76.0*u)
            _halo(pt,4.5+2.0*(1.0-u),Color("d9c6ff" if j%2 else "cbffcf",(1.0-u)*0.29))
    draw_string(ThemeDB.fallback_font,Vector2(30,35),
        "TAN CO DIEN NHIEM  /  CO DOC",HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("ebf9ec"))
    draw_string(ThemeDB.fallback_font,Vector2(30,65),
        "R6  |  LIVING GHOST GU / JADE VENOM  |  3 VISUAL TARGETS  |  FRAME BY FRAME",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("b6bdcf"))
    draw_string(ThemeDB.fallback_font,Vector2(31,688),
        "VFX-POI05 R6  |  ORIGINAL XIANXIA SPIRIT ART  |  LAB ONLY / NO ACTUAL POISON",
        HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("c4bcd4"))
    draw_string(ThemeDB.fallback_font,Vector2(1162,688),
        "%0.2fs" % t,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("c9bdd8"))

func _paint(tex: Texture2D,center: Vector2,scale: float,rot: float,tint: Color) -> void:
    draw_set_transform(center,rot,Vector2.ONE*scale)
    var size := tex.get_size()
    draw_texture_rect(tex,Rect2(-size/2.0,size),false,tint)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(center: Vector2,scale: float,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,
        Rect2(center-Vector2(160,351)*scale,Vector2(320,384)*scale),
        Rect2(0,0,320,384),tint)

func _shadow(center: Vector2) -> void:
    _halo(center+Vector2(0,8),57.0,Color("080c17",0.62))

func _halo(center: Vector2,r: float,tint: Color) -> void:
    draw_texture_rect(_glow,Rect2(center-Vector2.ONE*r,Vector2.ONE*r*2.0),false,tint)
