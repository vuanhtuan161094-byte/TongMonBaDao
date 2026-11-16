extends Control
## FIST11 / Huyet Liet Quyen, Huyet Quyen Human active_01.
## First-party DERIVATIVE painted art. View-only Combat Lab, not Combat V2.
## Source-authoritative Nether single-target DAMAGE; fake LAB impact has no HP.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_01.human"
const ART_REVISION := "R1_PAINTED_CRIMSON_FIST"
const EFFECT := "damage"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const DECLARED_DURATION := 0.0
const DECLARED_POWER := 0.0
const DECLARED_PROJECTILE_SPEED := 8.0
const FLIGHT_START := 0.45
const CONTACT_TIME := 0.82 # LAB synthetic; not a Combat V2 receipt
const CONTACT_END := 1.32
const FADE_END := 1.54
const LOOP_END := 2.20
const RAW_RGBA_BUDGET := 10158080
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CHARGE: Texture2D = preload("res://labs/combat_lab/fist11/assets/generated/f11_charge.png")
const FLIGHT: Texture2D = preload("res://labs/combat_lab/fist11/assets/generated/f11_blood_fist.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist11/assets/generated/f11_contact.png")
const CASTER_START := Vector2(436.0, 551.0)
const FOE_START := Vector2(786.0, 551.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "gather_blood_qi"
    if t < CONTACT_TIME: return "single_target_blood_fist_flight"
    if t < CONTACT_END: return "lab_only_impact"
    if t < FADE_END: return "red_ink_dissipate"
    return "idle"

static func charge_alpha(t: float) -> float:
    if t<0.0 or t>=CAST_TIME:return 0.0
    return smoothstep(0.0,0.15,t)*(1.0-smoothstep(0.37,CAST_TIME,t))

static func flight_alpha(t: float) -> float:
    if t < FLIGHT_START or t>=CONTACT_TIME:return 0.0
    return smoothstep(FLIGHT_START,FLIGHT_START+0.045,t)*(1.0-smoothstep(CONTACT_TIME-0.09,CONTACT_TIME,t))

static func contact_alpha(t: float) -> float:
    if t < CONTACT_TIME or t>=CONTACT_END:return 0.0
    return smoothstep(CONTACT_TIME,CONTACT_TIME+0.035,t)*(1.0-smoothstep(CONTACT_TIME+0.14,CONTACT_END,t))

static func caster_at(t: float) -> Vector2:
    return CASTER_START+Vector2(31.0*smoothstep(0.38,0.94,t)-17.0*smoothstep(1.08,1.62,t),0.0)

static func foe_at(t: float) -> Vector2:
    # Independently walking, nonstationary target throughout charge/contact.
    return FOE_START+Vector2(-56.0*smoothstep(.18,1.05,t)+15.0*smoothstep(1.35,1.90,t),0.0)

static func target_position(index: int,t: float) -> Vector2:
    if index!=0:return Vector2(-10000.0,-10000.0)
    return foe_at(t)

static func contact_at(index: int,t: float) -> Vector2:
    return target_position(index,t)+Vector2(0.0,-103.0)

static func punch_at(t: float) -> Vector2:
    var p:=clampf((t-FLIGHT_START)/(CONTACT_TIME-FLIGHT_START),0.,1.)
    var power:=smoothstep(0.0,1.0,p)
    var source:=caster_at(t)+Vector2(43.0,-102.0)
    var dest:=contact_at(0,t)-Vector2(14.0,0.0)
    return source.lerp(dest,power)

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST11_R1_READY skill=",SKILL_ID," impact=SIMULATED_LAB_ONLY nether=true cap=1 no_rig=true")

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0.,delta),LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode == KEY_SPACE:
        elapsed=0.
        queue_redraw()
    elif event.keycode==KEY_P:paused=not paused

func _frame(tex: Texture2D,frame: int, cell: float, pos: Vector2, scale_factor: float, opacity: float, anchor: Vector2) -> void:
    draw_set_transform(pos,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-anchor,Vector2(cell,cell)),Rect2(float(frame%4)*cell,float(int(frame/4))*cell,cell,cell),Color(1.,1.,1.,clampf(opacity,0.,1.)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2, tint: Color, walking: bool) -> void:
    var tex:=WALK if walking else IDLE
    var columns:=maxi(1,int(tex.get_width()/320))
    var idx:=int(floor(elapsed*7.0))%columns if walking else 0
    draw_texture_rect_region(tex,Rect2(feet-Vector2(68,151),Vector2(136,169)),Rect2(float(idx)*320.0,0,320,384),tint)

func _draw() -> void:
    var t:=elapsed
    var caster:=caster_at(t)
    var foe:=foe_at(t)
    var charge:=charge_alpha(t)
    var flight:=flight_alpha(t)
    var hit:=contact_alpha(t)
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280,72),Color("14141f",.76))
    if charge>.002:
        var k:=clampi(int(floor(t/CAST_TIME*8.)),0,7)
        _frame(CHARGE,k,256.,caster+Vector2(29,-100),.78,charge,Vector2(128,128))
    if flight>.002:
        var k:=clampi(int(floor((t-FLIGHT_START)/(CONTACT_TIME-FLIGHT_START)*12.)),0,11)
        _frame(FLIGHT,k,256.,punch_at(t),1.17,flight,Vector2(128,128))
    var moving_caster:=t>=.38 and t<.94
    var moving_foe:=t>=.18 and t<1.05 or t>=1.35 and t<1.90
    if not vfx_only_benchmark:
        _actor(caster,Color.WHITE,moving_caster)
        _actor(foe,Color("b8c4d5"),moving_foe)
    # LAB-only demonstration of one moving foe contact; DOES NOT alter HP.
    if hit>.002:
        var k:=clampi(int(floor((t-CONTACT_TIME)/(CONTACT_END-CONTACT_TIME)*10.)),0,9)
        _frame(CONTACT,k,320.,contact_at(0,t),1.09,hit,Vector2(160,160))
    if not vfx_only_benchmark:
        draw_string(ThemeDB.fallback_font,Vector2(26,33),"HUYET LIET QUYEN / FIST11",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("ffe5eb"))
        draw_string(ThemeDB.fallback_font,Vector2(26,56),"R1 | BLOOD QI -> SINGLE FIST -> CONTACT / HUMAN",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("f5a9ba"))
        draw_string(ThemeDB.fallback_font,Vector2(26,681),"GODOT 4.7.2 | NETHER DAMAGE 1 TARGET | MOVING WALK | LAB ONLY / NO RIG",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("f2d4e1"))