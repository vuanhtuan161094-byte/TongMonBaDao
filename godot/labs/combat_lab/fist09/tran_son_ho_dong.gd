extends Control
## FIST09 / Tran Son Ho Dong: illustrated mountain defense, ONE target.
## Earth GUARD 4 seconds. Original atlas generated from first-party project art.
## Preview receipts ONLY, no gameplay writes, no rig, no fake damage.
const SKILL_ID := "tmb.skill.fist.kim_cang.active_04.human"
const ART_REVISION := "R5_FEATHERED_PAINTED_BULWARK"
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
const CAST_BURST_END := 0.78
const FADE_END := 4.88
const LOOP_END := 5.35
const BLOCK_TIME := 0.26
const ATLAS_RAW_RGBA_BYTES := 6553600
const DEMO_BLOCKS := [1.30,3.13]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CAST: Texture2D = preload("res://labs/combat_lab/fist09/assets/generated/f9_mountain_cast.png")
const STATUS: Texture2D = preload("res://labs/combat_lab/fist09/assets/generated/f9_status_slabs.png")
const BLOCK: Texture2D = preload("res://labs/combat_lab/fist09/assets/generated/f9_guard_block.png")
const CASTER_START := Vector2(450.0,550.0)
const ENEMY_START := Vector2(830.0,550.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false
var manual_blocks: Array[float] = []

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "charge"
    if t < CAST_BURST_END: return "cast_retract"
    if t < GUARD_END: return "sustained_guard"
    if t < FADE_END: return "guard_fade"
    return "idle"

static func cast_alpha(t: float) -> float:
    if t<0.0 or t>=CAST_BURST_END: return 0.0
    return smoothstep(0.0,.22,t)*(1.0-smoothstep(.58,CAST_BURST_END,t))

static func guard_alpha(t: float) -> float:
    if t<GUARD_START or t>=FADE_END: return 0.0
    return smoothstep(GUARD_START,.60,t)*(1.0-smoothstep(GUARD_END,FADE_END,t))

static func block_alpha(t: float, at: float) -> float:
    if at<GUARD_START or at>=GUARD_END: return 0.0
    var age:=t-at
    if age<0.0 or age>=BLOCK_TIME:return 0.0
    return smoothstep(0.0,.041,age)*(1.0-smoothstep(.095,BLOCK_TIME,age))

static func protected_at(t: float) -> Vector2:
    return CASTER_START+Vector2(56.0*smoothstep(.54,1.40,t)-17.0*smoothstep(2.6,3.55,t),0.0)

static func enemy_at(t: float) -> Vector2:
    return ENEMY_START+Vector2(-67.0*smoothstep(.31,1.28,t)+21.0*smoothstep(1.6,2.72,t),0.0)

static func target_position(index: int,t: float) -> Vector2:
    if index!=0:return Vector2(-10000.0,-10000.0)
    return protected_at(t)

static func contact_at(index: int,t: float) -> Vector2:
    return target_position(index,t)+Vector2(67.0,-109.0)

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST09_R5_READY skill=",SKILL_ID," effect=guard cap=1 moving_target=true no_rig=true view_only=true")

func _process(delta: float) -> void:
    if paused:return
    var previous:=elapsed
    elapsed=fposmod(elapsed+maxf(0.0,delta),LOOP_END)
    if elapsed<previous:manual_blocks.clear()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        manual_blocks.clear()
        queue_redraw()
    elif event.keycode==KEY_P: paused=not paused
    elif event.keycode==KEY_H and elapsed>=GUARD_START and elapsed<GUARD_END:
        manual_blocks.append(elapsed)
        if manual_blocks.size()>6:manual_blocks.pop_front()
        queue_redraw()

func _frame(tex: Texture2D,frame: int, cell: float, at: Vector2,
        scale_factor: float, opacity: float, anchor: Vector2) -> void:
    var col:=frame%4
    var row:=int(frame/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-anchor,Vector2(cell,cell)),
        Rect2(float(col)*cell,float(row)*cell,cell,cell),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color,walking: bool) -> void:
    var tex:=WALK if walking else IDLE
    var width_cells:=maxi(1,int(tex.get_width()/320))
    var n:=int(floor(elapsed*7.0))%width_cells if walking else 0
    draw_texture_rect_region(tex,
        Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(float(n)*320.0,0.0,320.0,384.0),tint)

func _block_age(t: float) -> float:
    var result:=-1.0
    for at in DEMO_BLOCKS:
        if block_alpha(t,at)>0.0:result=maxf(result,t-at)
    for at in manual_blocks:
        if block_alpha(t,at)>0.0:result=maxf(result,t-at)
    return result

func _draw() -> void:
    var t:=elapsed
    var protected:=protected_at(t)
    var enemy:=enemy_at(t)
    var burst:=cast_alpha(t)
    var state:=guard_alpha(t)
    var impact_age:=_block_age(t)
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280,76),Color("141620",.76))
    # The large original mountain composition is CAST-ONLY; never a
    # 4-second bright permanent fortress obscuring the battlefield.
    if burst>.002:
        var k:=clampi(int(floor(t/CAST_BURST_END*8.0)),0,7)
        _frame(CAST,k,320.0,protected+Vector2(0,-143),1.36,burst,Vector2(160,167))
    # A small readable two-plate sign breathes with the moving recipient.
    if state>.002:
        var k:=posmod(int(floor((t-GUARD_START)*5.8)),8)
        _frame(STATUS,k,192.0,protected+Vector2(0,-93),1.43,
            state*(.92+.05*sin(t*6.9)),Vector2(96,98))
    var caster_walk:=t>=.54 and t<1.40 or t>=2.6 and t<3.55
    var enemy_walk:=t>=.31 and t<1.28 or t>=1.60 and t<2.72
    if not vfx_only_benchmark:
        _actor(protected,Color.WHITE,caster_walk)
        _actor(enemy,Color("b9c2cf"),enemy_walk)
    # The only contact event is a LAB-simulated defended hit on the
    # protected moving actor. Never an outgoing strike or damage return.
    if impact_age>=0.0 and t>=GUARD_START and t<GUARD_END:
        var k:=clampi(int(floor(impact_age/BLOCK_TIME*8.0)),0,7)
        var a:=block_alpha(t,t-impact_age)
        _frame(BLOCK,k,256.0,contact_at(0,t),1.18,a,Vector2(132,132))
        if not vfx_only_benchmark:
            _actor(protected,Color(1.0,.97,.84,clampf(a*.16,0.0,.16)),caster_walk)
    if not vfx_only_benchmark:
        if t>=GUARD_START and t<GUARD_END:
            draw_string(ThemeDB.fallback_font,Vector2(1008,32),
                "MOUNTAIN WARD / LAB",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("f9df9a"))
            draw_string(ThemeDB.fallback_font,Vector2(1008,54),
                "%.1f s remaining"%(GUARD_END-t),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e7dcb7"))
        draw_string(ThemeDB.fallback_font,Vector2(28,33),
            "TRAN SON HO DONG / KIM CANG",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("fff0d4"))
        draw_string(ThemeDB.fallback_font,Vector2(28,59),
            "FIST09 R5 | FEATHERED BULWARK -> GUARD -> DEFLECT",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("eccba3"))
        draw_string(ThemeDB.fallback_font,Vector2(28,683),
            "GODOT 4.7.2 | EARTH GUARD 4S | MOVING WALK | LAB ONLY / NO RIG",
            HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e8d5ad"))
