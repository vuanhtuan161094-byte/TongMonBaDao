extends Control
## FIST07 R3 — OWNER ILLUSTRATED SOURCE SPRITES, not programmatic line-art.
## Gold guardian, open dome, Kim Cang banners and earthlight are the actual
## illustrated owner reference extracted and pre-baked into RGBA frames.
## This is a view-only lab: Earth GUARD / ONE recipient / 4 seconds / 0.45 cast.
const SKILL_ID := "tmb.skill.fist.kim_cang.active_02.human"
const ART_REVISION := "R3_OWNER_REFERENCE_PAINTED_SPRITES"
const EFFECT := "guard"
const ELEMENT := "earth"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 5.5
const DECLARED_DURATION := 4.0
const DECLARED_POWER := 0.35
const PROJECTILE_SPEED := 0.0
const GUARD_START := 0.45
const GUARD_END := 4.45
const FADE_END := 4.85
const LOOP_END := 5.28
const HIT_DURATION := 0.24
const ATLAS_RAW_RGBA_BYTES := 8650752
const DEMO_BLOCK_TIMES := [1.29, 3.12]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WARD: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/gold_ward.png")
const BLOCK: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/guarded_hit.png")
const CASTER := Vector2(465.0, 553.0)
const DUMMY := Vector2(827.0, 553.0)
const WARD_CENTER := CASTER + Vector2(0.0, -118.0)
const BLOCK_ANCHOR := CASTER + Vector2(56.0, -105.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false
var manual_blocks: Array[float] = []

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "ward_manifest"
    if t < GUARD_END: return "guard_active"
    if t < FADE_END: return "ward_dissolve"
    return "clear"

static func guard_alpha(t: float) -> float:
    if t < GUARD_START or t >= FADE_END:
        return 0.0
    return smoothstep(GUARD_START, GUARD_START+0.09,t) * (1.0-smoothstep(GUARD_END, FADE_END,t))

static func block_alpha(t: float, block_at: float) -> float:
    if block_at < GUARD_START or block_at > GUARD_END:
        return 0.0
    var age := t-block_at
    if age < 0.0 or age >= HIT_DURATION:
        return 0.0
    return smoothstep(0.0,0.026,age)*(1.0-smoothstep(0.07,HIT_DURATION,age))

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST07_R3_READY skill=",SKILL_ID,
            " source=owner_illustrated_reference hero=gold_guardian_dome",
            " guard=true earth=true cast=0.45 sustain=4 no_rig=true view_only=true")

func _process(delta: float) -> void:
    if paused: return
    var before := elapsed
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    if elapsed<before:
        manual_blocks.clear()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        manual_blocks.clear()
        queue_redraw()
    elif event.keycode==KEY_P:
        paused=not paused
    elif event.keycode==KEY_H and elapsed>=GUARD_START and elapsed<GUARD_END:
        manual_blocks.append(elapsed)
        if manual_blocks.size()>6:
            manual_blocks.pop_front()
        queue_redraw()

## Geometry here positions already-PAINTED atlas pixels; it draws no shield
## outlines, loops, sparks or 'effects' via geometry primitives.
func _frame(tex: Texture2D, frame: int, cell: float, at: Vector2,
        scale_factor: float, opacity: float, pivot: Vector2) -> void:
    var col := frame%4
    var row := int(frame/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-pivot,Vector2(cell,cell)),
        Rect2(float(col)*cell,float(row)*cell,cell,cell),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _ward_front_foot(frame: int, at: Vector2, scale_factor: float, opacity: float) -> void:
    # Gold lotus floor ornament comes from the SAME painted atlas. It appears
    # IN FRONT of actor feet, while the guardian and dome remain behind.
    var col := frame%4
    var row := int(frame/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(WARD,Rect2(Vector2(-160,103),Vector2(320,57)),
        Rect2(Vector2(float(col)*320,float(row)*320+263),Vector2(320,57)),
        Color(1.0,1.0,1.0,clampf(opacity*.70,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,
        Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(0,0,320,384),tint)

func _recent_block_age(t: float) -> float:
    var recent := -1.0
    for at in DEMO_BLOCK_TIMES:
        if block_alpha(t,at)>0.0:
            recent=maxf(recent,t-at)
    for at in manual_blocks:
        if block_alpha(t,at)>0.0:
            recent=maxf(recent,t-at)
    return recent

func _draw() -> void:
    var t := elapsed
    var shield := guard_alpha(t)
    var ward_frame := 0
    var visible := 0.0
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280.0,720.0),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280.0,76.0),Color("151522",0.70))
    # Painted source layers: "Kim Cang" guardian + magical glass ward.
    if t<CAST_TIME:
        var q := clampf(t/CAST_TIME,0.0,1.0)
        ward_frame=clampi(int(floor(q*4.0)),0,3)
        visible=.46+.54*q
    elif t<FADE_END:
        if t<GUARD_END:
            ward_frame=4+posmod(int(floor((t-GUARD_START)*6.5)),8)
        else:
            ward_frame=12+clampi(int(floor((t-GUARD_END)/(FADE_END-GUARD_END)*4.0)),0,3)
        visible=shield*(.92+.08*sin(t*6.1))
    if visible>.002:
        _frame(WARD,ward_frame,320.0,WARD_CENTER,1.08,visible,Vector2(160.0,160.0))
    # The 3.5-head actor is NOT part of the poster sprite, and never rigged.
    var age := _recent_block_age(t)
    var intensity := 0.0
    if age>=0.0:
        intensity=smoothstep(0.0,0.026,age)*(1.0-smoothstep(.07,HIT_DURATION,age))
    if not vfx_only_benchmark:
        _actor(CASTER,Color.WHITE.lerp(Color("fff8c9"),intensity*.19))
        _actor(DUMMY,Color("bac2c8"))
    if visible>.002:
        _ward_front_foot(ward_frame,WARD_CENTER,1.08,visible)
    # A real painted starburst at the SHIELDED ACTOR's point of contact,
    # only for LAB-simulated guard receipts; never hit the opposite dummy.
    if age>=0.0 and t>=GUARD_START and t<GUARD_END:
        var n:=clampi(int(floor(age/HIT_DURATION*8.0)),0,7)
        _frame(BLOCK,n,256.0,BLOCK_ANCHOR,.96,intensity,
            Vector2(160.0,128.0))
    if not vfx_only_benchmark:
        draw_string(ThemeDB.fallback_font,Vector2(28,33),
            "KIM CANG HO THE / QUYEN TU",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("fff4dc"))
        draw_string(ThemeDB.fallback_font,Vector2(28,58),
            "FIST07 R3 | OWNER-ILLUSTRATED GOLD GUARDIAN + TRUE SPRITE WARD",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("eed19f"))
        draw_string(ThemeDB.fallback_font,Vector2(28,683),
            "GODOT 4.7.2 | GUARD 4s | H = BLOCK REACTION | NO RIG / NO DAMAGE",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f5d9a9"))
