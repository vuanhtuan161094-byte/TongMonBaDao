extends Control
## FIST07 R5: illustrated burst-once + quiet long GUARD state + receipt-only block.
## Godot layers ORIGINAL raster sprites; no code-sculpted shields / no rig.
## LAB-only moving WALK stand-ins, not a live gameplay binding.
const SKILL_ID := "tmb.skill.fist.kim_cang.active_02.human"
const ART_REVISION := "R6_JX_CAST_ONCE_QUIET_STATUS"
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
const FADE_END := 4.84
const CAST_BURST_END := 0.78
const LOOP_END := 5.28
const HIT_DURATION := 0.24
const ATLAS_RAW_RGBA_BYTES := 6553600
const DEMO_BLOCK_TIMES := [1.29, 3.12]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CAST: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/r5_cast_guardian.png")
const STATUS: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/r5_quiet_status.png")
const BLOCK: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/r5_guard_contact.png")
const ICON: Texture2D = preload("res://labs/combat_lab/fist07/assets/generated/r5_demo_buff_icon.png")
const START_FEET := Vector2(466.0, 550.0)
const ENEMY_START := Vector2(835.0, 550.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false
var manual_blocks: Array[float] = []

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "cast_burst"
    if t < CAST_BURST_END: return "cast_retract_status_on"
    if t < GUARD_END: return "quiet_sustained_guard"
    if t < FADE_END: return "status_fade"
    return "idle"

static func guard_alpha(t: float) -> float:
    if t < GUARD_START or t >= FADE_END: return 0.0
    return smoothstep(GUARD_START, GUARD_START+0.11, t) * (1.0 - smoothstep(GUARD_END, FADE_END, t))

static func cast_alpha(t: float) -> float:
    if t < 0.0 or t >= CAST_BURST_END: return 0.0
    if t < .18: return smoothstep(0.0,.18,t)
    return 1.0 - smoothstep(.63,CAST_BURST_END,t)

static func block_alpha(t: float, event_at: float) -> float:
    if event_at < GUARD_START or event_at >= GUARD_END: return 0.0
    var age := t-event_at
    if age < 0.0 or age >= HIT_DURATION: return 0.0
    return smoothstep(0.0,0.035,age) * (1.0-smoothstep(.080,HIT_DURATION,age))

static func protected_position_at(t: float) -> Vector2:
    # A real WALK sheet plays during this LAB-only translation, never IDLE spoof.
    return START_FEET + Vector2(68.0*smoothstep(.60,1.47,t) - 19.0*smoothstep(2.63,3.45,t),0.0)

static func demo_target_position(index: int,t: float) -> Vector2:
    if index != 0: return Vector2(-10000.0,-10000.0)
    return protected_position_at(t)

static func enemy_position_at(t: float) -> Vector2:
    return ENEMY_START + Vector2(-78.0*smoothstep(.30,1.29,t)+22.0*smoothstep(1.6,2.72,t),0.0)

static func demo_target_contact(index: int,t: float) -> Vector2:
    return demo_target_position(index,t)+Vector2(50.0,-106.0)

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST07_R6_READY illustrated_source=true effect=guard three_clocks=true moving_walk=true no_rig=true view_only=true")

func _process(delta: float) -> void:
    if paused:return
    var last:=elapsed
    elapsed=fposmod(elapsed+maxf(0.0,delta),LOOP_END)
    if elapsed<last:manual_blocks.clear()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode == KEY_SPACE:
        elapsed=0.0
        manual_blocks.clear()
        queue_redraw()
    elif event.keycode == KEY_P:
        paused=not paused
    elif event.keycode == KEY_H and elapsed>=GUARD_START and elapsed<GUARD_END:
        manual_blocks.append(elapsed)
        if manual_blocks.size()>6:manual_blocks.pop_front()
        queue_redraw()

func _frame(tex: Texture2D,index: int,cell: float,at: Vector2,scale_factor: float,opacity: float,pivot: Vector2) -> void:
    var col:=index%4
    var row:=int(index/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-pivot,Vector2(cell,cell)),
        Rect2(float(col)*cell,float(row)*cell,cell,cell),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color,walking: bool) -> void:
    var texture := WALK if walking else IDLE
    var width_cells:=maxi(1,int(texture.get_width()/320))
    var index:=int(floor(elapsed*7.0)) % width_cells if walking else 0
    draw_texture_rect_region(texture,
        Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(float(index)*320.0,0.0,320.0,384.0),tint)

func _block_age(t: float) -> float:
    var most_recent:=-1.0
    for at in DEMO_BLOCK_TIMES:
        if block_alpha(t,at) > 0.0: most_recent=maxf(most_recent,t-at)
    for at in manual_blocks:
        if block_alpha(t,at) > 0.0: most_recent=maxf(most_recent,t-at)
    return most_recent

func _draw() -> void:
    var t:=elapsed
    var protected:=protected_position_at(t)
    var enemy:=enemy_position_at(t)
    var active:=guard_alpha(t)
    var burst:=cast_alpha(t)
    var age:=_block_age(t)
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280,75),Color("141724",.76))
    # CAST ONLY: full divine guardian and painted dome appear on activation,
    # retract by .78sec; NOT repeated across the four-second protection.
    if burst > 0.005:
        var cf:=clampi(int(floor(t/CAST_BURST_END*8.0)),0,7)
        _frame(CAST,cf,320.0,protected+Vector2(0,-133),1.12,burst,Vector2(160,174))
    # SUSTAINED STATUS: small original painted feet/shoulder marks at LOW light,
    # follows the genuine WALK frame, no permanent arena-sized dome.
    if active > 0.004:
        var sf:=posmod(int(floor((t-GUARD_START)*5.7)),8)
        _frame(STATUS,sf,192.0,protected+Vector2(0,-89),1.03,
            active*(.68+.05*sin(t*7.0)),Vector2(96,100))
    var actor_walking:=t>=.60 and t<1.47 or t>=2.63 and t<3.45
    var enemy_walking:=t>=.30 and t<1.29 or t>=1.6 and t<2.72
    if not vfx_only_benchmark:
        _actor(protected,Color.WHITE,actor_walking)
        _actor(enemy,Color("b9c2cf"),enemy_walking)
    # Only DEMO protected-hit receipts trigger the short GOLD reaction.
    # No enemy damage, damage numbers, status mutation or artificial hit.
    if age>=0.0 and t>=GUARD_START and t<GUARD_END:
        var f:=clampi(int(floor(age/HIT_DURATION*8.0)),0,7)
        var intensity:=block_alpha(t,t-age)
        _frame(BLOCK,f,256.0,demo_target_contact(0,t),.80,intensity,Vector2(160,125))
        if not vfx_only_benchmark:
            _actor(protected,Color(1.0,0.97,0.79,clampf(intensity*.18,0.0,.18)),actor_walking)
    if not vfx_only_benchmark:
        # LAB-only status widget is evidence for the readable long buff; it is
        # NOT a live HUD and cannot claim receipt synchronization.
        if t>=GUARD_START and t<GUARD_END:
            draw_texture_rect(ICON,Rect2(985,13,44,44),false,Color.WHITE)
            draw_string(ThemeDB.fallback_font,Vector2(1039,33),
                "GUARD / LAB",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("ffe5a6"))
            draw_string(ThemeDB.fallback_font,Vector2(1040,54),
                "%.1f s remaining" % (GUARD_END-t),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e7d7af"))
        draw_string(ThemeDB.fallback_font,Vector2(26,34),
            "KIM CANG HO THE  /  JX-STYLE 4S GUARD",
            HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("fff1d9"))
        draw_string(ThemeDB.fallback_font,Vector2(27,59),
            "FIST07 R6 | CAST GUARDIAN → SMALL BUFF → REACTIVE BLOCK",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("edd7b2"))
        draw_string(ThemeDB.fallback_font,Vector2(27,683),
            "GODOT 4.7.2 COMPAT | MOVING WALK TARGET | LAB RECEIPTS ONLY | NO RIG",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e4d0a1"))
