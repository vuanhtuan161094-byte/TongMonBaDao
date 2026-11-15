extends Control
## FIST05 V3 - ORIGINAL painted seismic line + one rock eruption. LAB VIEW ONLY.
## No rig / no HP writes / no V6.3 or PvE integration.
const SKILL_ID := "tmb.skill.fist.ba_quyen.active_04.human"
const DISPLAY_NAME := "Địa Mạch Liên Chấn"
const ART_REVISION := "V4_TALL_PAINTED_SPIRAL_SPARES"
const EFFECT := "damage"
const ELEMENT := "fire"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RADIUS := 3.0
const CAST_TIME := 0.45
const DECLARED_RANGE := 4.0
const PROJECTILE_SPEED := 8.0
const RIFT_START := 0.45
const CONTACT_TIME := 1.01
const ERUPTION_END := 1.72
const FADE_END := 2.56
const LOOP_END := 3.00
const ATLAS_SIZE := 256
const ATLAS_RAW_RGBA_BYTES := 7340032
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const CORE: Texture2D = preload("res://labs/combat_lab/fist05/assets/optimized_v3/seismic_main.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist05/assets/optimized_v3/seismic_hit.png")
const FAULT_PATH: Texture2D = preload("res://labs/combat_lab/fist05/assets/optimized_v3/seismic_path.png")
const CASTER := Vector2(325.0, 557.0)
const IMPACT_GROUND := Vector2(899.0, 559.0)
const TARGETS := [Vector2(746.0, 547.0), Vector2(909.0, 554.0), Vector2(1061.0, 546.0)]
# Benchmark draws the same REAL VFX textures but skips lab scenery/actors/titles.
# A shared engine resource cache means copies do not duplicate the 3 atlas textures.
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false

static func phase_at(t: float) -> String:
    if t < CAST_TIME:
        return "charge"
    if t < CONTACT_TIME:
        return "seismic_fault_travel"
    if t < ERUPTION_END:
        return "triple_target_eruption"
    if t < FADE_END:
        return "rubble_fade"
    return "clear"

static func contact_alpha(t: float, target_index: int) -> float:
    if target_index < 0 or target_index >= TARGET_LIMIT:
        return 0.0
    var t0 := CONTACT_TIME + 0.022 * float(target_index)
    var age := t - t0
    if age < 0.0 or age >= 0.35:
        return 0.0
    return smoothstep(0.0, 0.045, age) * (1.0 - smoothstep(0.10, 0.35, age))

static func eruption_alpha(t: float) -> float:
    if t < CONTACT_TIME or t >= FADE_END:
        return 0.0
    return smoothstep(CONTACT_TIME, CONTACT_TIME + 0.065, t) * (1.0 - smoothstep(ERUPTION_END, FADE_END, t))

static func fault_alpha(t: float) -> float:
    if t < RIFT_START or t >= FADE_END:
        return 0.0
    return 1.0 - smoothstep(1.48, FADE_END, t)

static func target_position(index: int, t: float) -> Vector2:
    if index < 0 or index >= TARGETS.size():
        return Vector2.ZERO
    var foot: Vector2 = TARGETS[index]
    return foot + Vector2(10.0 * sin(1.67 * t + index * 1.81), 2.3 * sin(.91 * t + index))

static func target_recoil(t: float, index: int) -> float:
    var age := t - CONTACT_TIME - 0.022 * float(index)
    if age < 0.0 or age > 0.47:
        return 0.0
    return 18.0 * smoothstep(0.025, 0.13, age) * (1.0 - smoothstep(0.18, 0.47, age))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0,720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST05_V4_READY source=", SKILL_ID,
            " atlas_frames=24 raw_rgba_bytes=", ATLAS_RAW_RGBA_BYTES,
            " shape=circle target_cap=3 no_rig=true view_only=true")

func _process(delta: float) -> void:
    if paused:
        return
    elapsed = fposmod(elapsed + maxf(delta,0.0), LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark:
        return
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        queue_redraw()
    elif event.keycode == KEY_P:
        paused = not paused

func _atlas(tex: Texture2D, index: int, at: Vector2, scale_factor: float,
        opacity: float, pivot: Vector2 = Vector2(128.0, 207.0)) -> void:
    var column := index % 4
    var row := int(index / 4)
    draw_set_transform(at,0.0,Vector2.ONE * scale_factor)
    draw_texture_rect_region(tex,Rect2(-pivot,Vector2(256.0,256.0)),
        Rect2(float(column)*256.0,float(row)*256.0,256.0,256.0),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color) -> void:
    # Unmodified scale dummy. Not a frame-by-frame martial artist animation.
    draw_texture_rect_region(ACTOR,Rect2(feet-Vector2(67.0,149.0),Vector2(134.0,167.0)),
        Rect2(0.0,0.0,320.0,384.0),tint)

func _fissure(t: float) -> void:
    var opacity := fault_alpha(t)
    if opacity < 0.004:
        return
    # One continuous strip, progressively revealed, not 3-4 repeated atlas tiles.
    var progress := clampf((t-RIFT_START)/(CONTACT_TIME-RIFT_START),0.0,1.0)
    if progress <= 0.006:
        return
    var src_width := 1024.0 * progress
    var dst_width := 650.0 * progress
    draw_texture_rect_region(FAULT_PATH,Rect2(329.0,457.0,dst_width,153.0),
        Rect2(0.0,0.0,src_width,256.0),Color(1,1,1,opacity*.94))

func _draw() -> void:
    var t := elapsed
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280.0,720.0),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280.0,80.0),Color("19151c",0.72))
    if t < CAST_TIME:
        var q := clampf(t/CAST_TIME,0.0,1.0)
        _atlas(CORE,clampi(int(floor(q*4.0)),0,3),CASTER + Vector2(0,10),
            .98,0.52 + .48*q)
    _fissure(t)
    var erupt := eruption_alpha(t)
    if erupt > .004:
        var idx := clampi(int(floor((t-CONTACT_TIME)/(FADE_END-CONTACT_TIME)*12.0)),0,11)
        _atlas(CORE,4+idx,IMPACT_GROUND+Vector2(0,5),1.16,erupt*.98)
    if not vfx_only_benchmark:
        _actor(CASTER,Color("f2e7d7"))
    for i in range(TARGET_LIMIT):
        var impact := contact_alpha(t,i)
        var feet := target_position(i,t) + Vector2(target_recoil(t,i),0.0)
        if not vfx_only_benchmark:
            _actor(feet,Color.WHITE.lerp(Color("fff2dd"),impact*.57))
        if impact > .004:
            var frame := clampi(int((t-CONTACT_TIME-.022*i)/.35*8.0),0,7)
            _atlas(CONTACT,frame,feet+Vector2(-10.0,-82.0),.72,impact*.95,
                Vector2(128.0,154.0))
    if not vfx_only_benchmark:
        draw_string(ThemeDB.fallback_font,Vector2(27.0,34.0),
            "DIA MACH LIEN CHAN  /  BA QUYEN",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("ffe9bd"))
        draw_string(ThemeDB.fallback_font,Vector2(28.0,60.0),
            "FIST05 V4 | 1 FISSURE + 1 ERUPTION | 3 HIT CUES | 7 MiB RAW ATLAS",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e4c39e"))
        draw_string(ThemeDB.fallback_font,Vector2(28.0,684.0),
            "GODOT 4.7.2 COMPATIBILITY | VIEW ONLY | 24 RGBA FRAMES | NO RIG",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f1d1ad"))
