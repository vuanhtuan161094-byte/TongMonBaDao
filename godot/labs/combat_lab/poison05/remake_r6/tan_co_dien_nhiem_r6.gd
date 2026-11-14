extends Control
## POI-05 R8 — Tán Cổ Diễn Nhiễm. Independent original Tu Tien xianxia remake.
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
const SWARM := [
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_0.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_1.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_2.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_3.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_4.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_5.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_6.svg"),
    preload("res://labs/combat_lab/poison05/remake_r6/assets/gu_swarm_7.svg"),
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
    print("VFX_POI05_R9_READY id=",SKILL_ID,
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
        _halo(from,103.0,Color("b4a2ff",charge*0.47))
        _halo(from+Vector2(-5.0,0.0),61.0,Color("b0ffb1",charge*0.43))
        var seed_pos := from+Vector2(4.0*sin(t*6.0),6.0*sin(t*4.2))
        _paint(SEED[seed_frame(t)],seed_pos,0.24+0.085*charge,0.12*sin(t*6.0),
            Color(1.0,1.0,1.0,charge*0.92))
        for j in range(9):
            var angle := float(j)*2.399+t*2.7
            var at := from+Vector2(cos(angle)*33.0,sin(angle)*21.0)
            _halo(at,5.0,Color("c8a3ff" if j%2==0 else "dcffd5",charge*0.43))
        # Broken converging spiritual qi: light follows the jade seed, never a neon ring.
        for i in range(3):
            var phi := float(i)*2.399+t*1.4
            var p0 := from+Vector2(cos(phi)*75.0,sin(phi)*45.0)
            var bend := from+Vector2(cos(phi+0.7)*47.0,sin(phi+0.7)*36.0)
            var path := PackedVector2Array([p0,bend,from])
            draw_polyline(path,Color("643b92",charge*0.65),9.0,true)
            draw_polyline(path,Color("bca3f3",charge*0.54),3.8,true)
            draw_polyline(path,Color("d9ffe0",charge*0.40),1.3,true)
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
        _halo(current,118.0,Color("967af1",a*0.37))
        _halo(current,86.0,Color("b7ffd0",a*0.31))
        # Short irregular luminous tail, attached to exact flight curve.
        for tail in range(3):
            var lag := 0.035+float(tail)*0.04
            if t>CAST_END+lag:
                var tail_a := main_point(t-lag)
                var tail_b := main_point(t-lag-0.032)
                draw_line(tail_b,tail_a,Color("8254cb",a*(0.48-float(tail)*0.10)),12.0-float(tail)*2.5,true)
                draw_line(tail_b,tail_a,Color("d6ffdc",a*(0.65-float(tail)*0.12)),2.2,true)
        _paint(GU[gu_frame(t)],current,0.39+0.040*q,
            0.075*sin(t*7.0),Color(1.0,1.0,1.0,a))
    # At arrival only a fleeting fractured spirit burst, no neon AOE disc.
    if t>=ARRIVAL and t<1.83:
        var burst := smoothstep(ARRIVAL,ARRIVAL+0.15,t)*(1.0-smoothstep(1.62,1.83,t))
        _halo(BIRTH,148.0,Color("aa79f3",burst*0.42))
        _halo(BIRTH,91.0,Color("e8ffdc",burst*0.39))
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
    # R9 — the SINGLE dark-jade spirit opens, then visibly fragments into
    # three distinct SWARMS of 8-frame jade moth-gu. No three giant centipedes.
    # Stage design is view-only, with no additional game target/proc events.
    if t>=1.41 and t<3.28:
        for idx in range(3):
            var start := escort_start(idx)
            var q := escort_progress(t,idx)
            var alpha := smoothstep(start,start+0.14,t)*(1.0-smoothstep(2.44+float(idx)*0.06,2.97+float(idx)*0.07,t))
            if alpha < 0.006: continue
            var lead := escort_point(t,idx)
            var frame := posmod(int(floor((t-start)*21.0))+idx*2,SWARM.size())
            var size := (0.235+0.046*q)*(1.0+0.06*sin(t*9.0+float(idx)*1.4))
            var tilt := -0.18+0.15*sin(t*7.5+float(idx)*2.3)
            _halo(lead,76.0,Color("b8a2f3",alpha*0.23))
            _halo(lead,47.0,Color("c4ffd7",alpha*0.25))
            for j in range(2):
                var old := t-0.060*float(j+1)
                if old>start:
                    _paint(SWARM[posmod(int(floor((old-start)*21.0))+idx*2,SWARM.size())],
                        escort_point(old,idx),size*(0.76-0.18*float(j)),tilt,
                        Color("b8d1d2",alpha*(0.16-0.045*float(j))))
            _paint(SWARM[frame],lead,size,tilt,Color(1,1,1,alpha*0.95))
            # Six subordinate illustrated GU spores per visible path; small,
            # staggered, wandering and fading, never static radius markers.
            for j in range(6):
                var rank := float(j)
                var delay := 0.10+0.062*rank+float(idx)*0.026
                var q2 := smoothstep(start+delay,start+0.68+delay,t)
                if q2 <= 0.002: continue
                var angle := float(idx)*2.09+rank*2.399
                var origin := BIRTH+Vector2(cos(angle)*34.0,sin(angle)*24.0)
                var to: Vector2 = TARGETS[idx]+Vector2(cos(angle)*(31.0+rank*2.0),-86.0+sin(angle)*26.0)
                var flutter := Vector2(14.0*sin(t*8.0+rank*2.1)*sin(PI*q2),
                    -29.0*sin(PI*q2))
                var at := origin.lerp(to,q2)+flutter
                var faint := alpha*(0.43+0.16*sin(t*12.0+rank*2.0)*sin(t*12.0+rank*2.0))
                var little := 0.070+0.013*float(j%3)
                _paint(SWARM[posmod(frame+j+idx,SWARM.size())],at,little,
                    0.23*sin(t*12.0+angle),Color("c0ffd5",faint))
    # Infection visual at chest/arms, staggered in ART only. 7s canonical gameplay duration NOT simulated.
    for idx in range(3):
        var gain := mark_gain(t,idx)
        if gain<0.006:continue
        var center: Vector2 = TARGETS[idx]+Vector2(3.0,-57.0)
        var born := escort_start(idx)+0.62
        var local := maxf(0.0,t-born)
        var turn := int(floor(local*14.0))%MARK.size()
        var size := 0.285+0.022*sin(t*5.2+float(idx)*2.0)
        var a := -0.08+0.15*sin(t*4.2+float(idx)*1.5)
        _halo(center,82.0,Color("b38bea",gain*0.21))
        _paint(MARK[turn],center,size,a,Color(1,1,1,gain*0.82))
        # Xianxia parasitic veins crawl upwards as *open* filaments, never protective rings.
        var parasite_gain := gain*(1.0-smoothstep(2.90,3.57,t))
        if parasite_gain>0.012:
            for strand in range(3):
                var vein := PackedVector2Array()
                var k := float(strand)
                var root := center+Vector2((k-1.0)*18.0,24.0+k*4.0)
                for p_idx in range(15):
                    var q := float(p_idx)/14.0
                    var sideways := (k-1.0)*(14.0+11.0*q)
                    var wiggle := 9.0*sin(q*7.0+local*5.0+k*2.3+float(idx)*1.7)
                    var p := root+Vector2(sideways*q+wiggle,-58.0*q+6.0*sin(q*4.4))
                    vein.append(p)
                draw_polyline(vein,Color("271d42",parasite_gain*0.50),6.8,true)
                draw_polyline(vein,Color("ac83eb" if strand==0 else "87dfb6",parasite_gain*0.49),2.7,true)
                draw_polyline(vein,Color("e9ffe5",parasite_gain*0.30),0.9,true)
                var tip: Vector2 = vein[vein.size()-1]
                _halo(tip,10.0,Color("cbf9bd",parasite_gain*0.27))
            # A few tiny insects move *into* each character, not a second actual hit.
            for mote in range(3):
                var k := float(mote)
                var q := fposmod(local*0.75+k*0.29,1.0)
                var pt := center+Vector2((-1.0+k)*22.0+6.0*sin(local*8.0+k*2.2),
                    21.0-52.0*q)
                var mote_gain := parasite_gain*sin(PI*q)*0.42
                _paint(SWARM[posmod(int(floor(t*21.0))+mote+idx,SWARM.size())],pt,0.089+0.018*sin(k*1.9),
                    -0.37+0.16*sin(t*10.0+k),Color("c5ffd3",mote_gain))
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
        "R9  |  GHOST-GU SPLITS INTO JADE-MOTH SWARM  |  8 ORIGINAL WING POSES",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("b6bdcf"))
    draw_string(ThemeDB.fallback_font,Vector2(31,688),
        "VFX-POI05 R9  |  ORIGINAL XIANXIA SPIRIT ART  |  LAB ONLY / NO ACTUAL POISON",
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
