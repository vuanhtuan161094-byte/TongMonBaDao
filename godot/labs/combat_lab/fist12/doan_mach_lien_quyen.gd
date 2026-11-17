extends Control
## FIST12 Doan Mach Lien Quyen — Nether, one-target 6s MARK.
## Original ENERGY LIGHT alpha sprites / 3 braided currents / local mark application.
## View-only Godot 4.7.2 LAB: synthetic timing, NO combat damage/status writes.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_02.human"
const ART_REVISION := "R2_BRAIDED_ENERGY_MERIDIAN"
const EFFECT := "mark"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const DECLARED_DURATION := 6.0
const DECLARED_POWER := 1.15
const DECLARED_PROJECTILE_SPEED := 0.0
const WAVE_START := 0.45
const CONTACT_START := 0.92
const CONTACT_END := 1.32
const MARK_START := 0.92
const MARK_END := 6.92
const FADE_END := 7.22
const LOOP_END := 7.60
const ATLAS_RAW_RGBA_BYTES := 11468800
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CHARGE: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_charge.png")
const WAVE: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_meridian_waves.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_contact.png")
const MARK: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_six_second_mark.png")
const CASTER_START := Vector2(433.0,552.0)
const FOE_START := Vector2(785.0,552.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "huyet_qi_charge"
    if t < CONTACT_START: return "meridian_light_stream"
    if t < CONTACT_END: return "lab_only_mark_application"
    if t < MARK_END: return "six_second_vein_mark"
    if t < FADE_END: return "vein_mark_fade"
    return "idle"

static func charge_alpha(t: float) -> float:
    if t < 0.0 or t >= CAST_TIME: return 0.0
    return smoothstep(0.0,0.16,t)*(1.0-smoothstep(.37,CAST_TIME,t))

static func wave_alpha(t: float) -> float:
    if t < WAVE_START or t >= CONTACT_START: return 0.0
    return smoothstep(WAVE_START,WAVE_START+.085,t)*(1.0-smoothstep(CONTACT_START-.09,CONTACT_START,t))

static func contact_alpha(t: float) -> float:
    if t < CONTACT_START or t >= CONTACT_END: return 0.0
    return smoothstep(CONTACT_START,CONTACT_START+.045,t)*(1.0-smoothstep(CONTACT_START+.15,CONTACT_END,t))

static func mark_alpha(t: float) -> float:
    if t < MARK_START or t >= FADE_END: return 0.0
    return smoothstep(MARK_START,MARK_START+.16,t)*(1.0-smoothstep(MARK_END,FADE_END,t))

static func caster_at(t: float) -> Vector2:
    return CASTER_START+Vector2(28.0*smoothstep(.36,1.11,t)-16.0*smoothstep(1.52,2.18,t),0.0)

static func foe_at(t: float) -> Vector2:
    # Independently walking opponent: all VFX markers FOLLOW actor world pose.
    return FOE_START+Vector2(-52.0*smoothstep(.18,1.13,t)+31.0*smoothstep(2.95,4.10,t)-22.0*smoothstep(5.10,6.36,t),0.0)

static func target_position(index: int,t: float) -> Vector2:
    if index != 0: return Vector2(-10000.0,-10000.0)
    return foe_at(t)

static func mark_at(index: int,t: float) -> Vector2:
    return target_position(index,t)+Vector2(0.0,-84.0)

static func wave_at(t: float) -> Vector2:
    # LAB visual travel is cosmetic; catalogue speed=0 (not a projectile).
    var p:=clampf((t-WAVE_START)/(CONTACT_START-WAVE_START),0.0,1.0)
    var interp:=smoothstep(0.0,1.0,p)
    var src:=caster_at(t)+Vector2(39.0,-105.0)
    var dst:=mark_at(0,t)-Vector2(25.0,0.0)
    return src.lerp(dst,interp)

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST12_R2_READY skill=",SKILL_ID,
             " effect=mark status_duration=6 target=1 particle=alpha_sprite",
             " no_gif=true no_rig=true no_gameplay_writes=true")

func _process(delta: float) -> void:
    if paused: return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode==KEY_P:
        paused=not paused

func _frame(tex: Texture2D, frame: int, cell: float, at: Vector2, factor: float, opacity: float, anchor: Vector2) -> void:
    draw_set_transform(at,0.0,Vector2.ONE*factor)
    draw_texture_rect_region(tex,
        Rect2(-anchor,Vector2(cell,cell)),
        Rect2(float(frame%4)*cell,float(int(frame/4))*cell,cell,cell),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2, tint: Color, walking: bool) -> void:
    var tex:=WALK if walking else IDLE
    var cols:=maxi(1,int(tex.get_width()/320))
    var index:=int(floor(elapsed*7.0))%cols if walking else 0
    draw_texture_rect_region(tex,
        Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(float(index)*320.0,0.0,320.0,384.0),tint)

func _draw() -> void:
    var t:=elapsed
    var caster:=caster_at(t)
    var foe:=foe_at(t)
    var gather:=charge_alpha(t)
    var stream:=wave_alpha(t)
    var touch:=contact_alpha(t)
    var sigil:=mark_alpha(t)
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0.0,0.0,1280.0,720.0),false,Color.WHITE)
        draw_rect(Rect2(0.0,0.0,1280.0,72.0),Color("14141f",.78))
    if gather>.002:
        var k:=clampi(int(floor(t/CAST_TIME*8.0)),0,7)
        _frame(CHARGE,k,256.0,caster+Vector2(34.0,-100.0),.90,gather,Vector2(128.0,128.0))
    if stream>.002:
        var k:=clampi(int(floor((t-WAVE_START)/(CONTACT_START-WAVE_START)*12.0)),0,11)
        # Braided currents, not three invented impact receipts.
        _frame(WAVE,k,320.0,wave_at(t),1.06,stream,Vector2(160.0,160.0))
    var caster_walk:=t>=.35 and t<1.11
    var foe_walk:=t>=.18 and t<1.13 or t>=2.95 and t<4.10 or t>=5.10 and t<6.36
    if not vfx_only_benchmark:
        _actor(caster,Color.WHITE,caster_walk)
        _actor(foe,Color("b8c4d5"),foe_walk)
    if touch>.002:
        var k:=clampi(int(floor((t-CONTACT_START)/(CONTACT_END-CONTACT_START)*8.0)),0,7)
        _frame(CONTACT,k,320.0,mark_at(0,t),0.96,touch,Vector2(160.0,160.0))
    if sigil>.002:
        var k:=posmod(int(floor((t-MARK_START)*7.2)),8)
        _frame(MARK,k,192.0,mark_at(0,t),.93,sigil*(.91+.05*sin(t*5.4)),Vector2(96.0,103.0))
    if not vfx_only_benchmark:
        draw_string(ThemeDB.fallback_font,Vector2(26,33),
            "DOAN MACH LIEN QUYEN / HUYET QUYEN",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("ffe9f1"))
        draw_string(ThemeDB.fallback_font,Vector2(26,56),
            "FIST12 R2 | BRAIDED PLASMA LIGHT / 6S VEIN MARK / LAB ONLY",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffb2d6"))
        if t>=MARK_START and t<MARK_END:
            draw_string(ThemeDB.fallback_font,Vector2(1040,32),
                "MARK %.1f s"%(MARK_END-t),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ff86bd"))
        draw_string(ThemeDB.fallback_font,Vector2(26,684),
            "GODOT 4.7.2 | SINGLE TARGET MARK | ENERGY-FIRST | NO GIF/NO RIG/NO LIVE PvE",
            HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ead1df"))