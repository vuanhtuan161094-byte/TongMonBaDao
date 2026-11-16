extends Control
## FIST08 / PHAN CHAN QUYEN: original painterly GOLD pressure channels.
## Canonical EARTH GUARD single recipient, NO outgoing rebound damage.
## The dragon-pigment crest manifests only in cast; the long state is subtle.
## All shape art is authored offline into three alpha atlas pages, NOT GDScript lines.
const SKILL_ID := "tmb.skill.fist.kim_cang.active_03.human"
const ART_REVISION := "R2_BRIGHT_COUNTERFORCE_CONTACT"
const EFFECT := "guard"
const ELEMENT := "earth"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 5.5
const DECLARED_DURATION := 4.0
const PROJECTILE_SPEED := 0.0
const GUARD_START := 0.45
const GUARD_END := 4.45
const CAST_BURST_END := 0.79
const FADE_END := 4.84
const LOOP_END := 5.28
const HIT_DURATION := 0.28
const ATLAS_RAW_RGBA_BYTES := 7602176
const DEMO_GUARD_CONTACTS := [1.29, 3.09]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CAST: Texture2D = preload("res://labs/combat_lab/fist08/assets/generated/f8_cast_ward.png")
const STATUS: Texture2D = preload("res://labs/combat_lab/fist08/assets/generated/f8_quiet_recoil.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist08/assets/generated/f8_counter_contact.png")
const START_FEET := Vector2(456.0, 548.0)
const OTHER_FEET := Vector2(835.0, 548.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false
var manual_contacts: Array[float] = []

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "charge"
    if t < CAST_BURST_END: return "cast_retract"
    if t < GUARD_END: return "guard_quiet"
    if t < FADE_END: return "guard_fade"
    return "idle"

static func cast_alpha(t: float) -> float:
    if t < 0.0 or t >= CAST_BURST_END: return 0.0
    return smoothstep(0.0, .18, t) * (1.0 - smoothstep(.60, CAST_BURST_END, t))

static func status_alpha(t: float) -> float:
    if t < GUARD_START or t >= FADE_END: return 0.0
    return smoothstep(GUARD_START, .60, t) * (1.0 - smoothstep(GUARD_END,FADE_END,t))

static func contact_alpha(t: float, at: float) -> float:
    if at < GUARD_START or at >= GUARD_END: return 0.0
    var age:=t-at
    if age<0.0 or age>=HIT_DURATION:return 0.0
    return smoothstep(0.0,.032,age)*(1.0-smoothstep(.09,HIT_DURATION,age))

static func protected_feet_at(t: float) -> Vector2:
    return START_FEET+Vector2(60.0*smoothstep(.62,1.55,t)-21.0*smoothstep(2.61,3.46,t),0.0)

static func enemy_feet_at(t: float) -> Vector2:
    return OTHER_FEET+Vector2(-61.0*smoothstep(.30,1.30,t)+18.0*smoothstep(1.67,2.77,t),0.0)

static func demo_target_position(index: int,t: float) -> Vector2:
    if index != 0: return Vector2(-10000.0,-10000.0)
    return protected_feet_at(t)

static func demo_target_contact(index: int,t: float) -> Vector2:
    return demo_target_position(index,t)+Vector2(45.0,-106.0)

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST08_R2_READY art_source=FIRST_PARTY_GOLD_RECOIL effect=guard moving_walk=true no_rig=true no_damage=true view_only=true")

func _process(delta: float) -> void:
    if paused: return
    var before:=elapsed
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    if elapsed<before:manual_contacts.clear()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        manual_contacts.clear()
        queue_redraw()
    elif event.keycode==KEY_P:paused=not paused
    elif event.keycode==KEY_H and elapsed>=GUARD_START and elapsed<GUARD_END:
        manual_contacts.append(elapsed)
        if manual_contacts.size()>6:manual_contacts.pop_front()
        queue_redraw()

func _frame(tex: Texture2D, index: int, cell: float, at: Vector2, scale_factor: float, opacity: float, anchor: Vector2) -> void:
    var col:=index%4
    var row:=int(index/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-anchor,Vector2(cell,cell)),
        Rect2(float(col)*cell,float(row)*cell,cell,cell),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color,walking: bool) -> void:
    var tex:=WALK if walking else IDLE
    var frames:=maxi(1,int(tex.get_width()/320))
    var f:=int(floor(elapsed*8.0))%frames if walking else 0
    draw_texture_rect_region(tex,
        Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(float(f)*320.0,0.0,320.0,384.0),tint)

func _recent_contact(t: float) -> float:
    var result:=-1.0
    for at in DEMO_GUARD_CONTACTS:
        if contact_alpha(t,at)>0.0: result=maxf(result,t-at)
    for at in manual_contacts:
        if contact_alpha(t,at)>0.0: result=maxf(result,t-at)
    return result

func _draw() -> void:
    var t:=elapsed
    var feet:=protected_feet_at(t)
    var other:=enemy_feet_at(t)
    var burst:=cast_alpha(t)
    var guard:=status_alpha(t)
    var age:=_recent_contact(t)
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280,76),Color("151622",.76))
    # Short 0.79-sec cinematic cast: large gold recoil spirit, NEVER permanent.
    if burst>.003:
        var f:=clampi(int(floor(t/CAST_BURST_END*8.0)),0,7)
        _frame(CAST,f,320.0,feet+Vector2(0,-118),1.13,burst,Vector2(160,178))
    # Real 4-second state is compact, follows a moving WALK actor.
    if guard>.003:
        var f:=posmod(int(floor((t-GUARD_START)*6.0)),8)
        _frame(STATUS,f,192.0,feet+Vector2(0,-88),1.04,
            guard*(.96+.04*sin(t*6.8)),Vector2(96,96))
    var walking:=t>=.62 and t<1.55 or t>=2.61 and t<3.46
    var enemy_walking:=t>=.30 and t<1.30 or t>=1.67 and t<2.77
    if not vfx_only_benchmark:
        _actor(feet,Color.WHITE,walking)
        _actor(other,Color("c4c9d4"),enemy_walking)
    # Only an INCOMING DEMO guarded-hit triggers outgoing visual force streaks.
    # Never an actual reflection of combat damage; engine owns hit/HP/guard.
    if age>=0.0 and t>=GUARD_START and t<GUARD_END:
        var q:=clampi(int(floor(age/HIT_DURATION*10.0)),0,9)
        var alpha:=contact_alpha(t,t-age)
        _frame(CONTACT,q,256.0,demo_target_contact(0,t),1.07,alpha,Vector2(120,127))
        if not vfx_only_benchmark:
            _actor(feet,Color(1.0,.95,.80,clampf(alpha*.15,0.0,.15)),walking)
    if not vfx_only_benchmark:
        if t>=GUARD_START and t<GUARD_END:
            draw_string(ThemeDB.fallback_font,Vector2(1000,32),
                "PHAN CHAN / GUARD",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ffe2aa"))
            draw_string(ThemeDB.fallback_font,Vector2(1000,52),
                "%.1f s"%(GUARD_END-t),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("fff5cf"))
        draw_string(ThemeDB.fallback_font,Vector2(26,34),
            "PHAN CHAN QUYEN / KIM CANG",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("fff1d5"))
        draw_string(ThemeDB.fallback_font,Vector2(26,60),
            "FIST08 | CAST RECOIL GOLD → QUIET GUARD → INCOMING BLOCK",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e9cca2"))
        draw_string(ThemeDB.fallback_font,Vector2(26,685),
            "GODOT 4.7.2 COMPAT | REAL WALK | LAB BLOCK ONLY | NO RIG / DAMAGE",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e9cc9c"))
