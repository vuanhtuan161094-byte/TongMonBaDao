extends Control
## R9 replacement candidate for FIST12 main Combat Lab; stays art-only and isolated.
## Independent image-authored RGBA flipbooks, NOT generated from R5-R8 art.
## No Combat V2, HP, status, AI, SaveService or PvE writes. No rig.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_02.human"
const ART_REVISION := "R9_THREE_INDEPENDENT_CRIMSON_QI_PUNCH_ATLASES"
const EFFECT := "mark"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const DECLARED_DURATION := 6.0
const DECLARED_PROJECTILE_SPEED := 0.0
const WAVE_START := 0.45
const CONTACT_START := 0.92
const CONTACT_END := 1.32
const MARK_START := 0.92
const MARK_END := 6.92
const FADE_END := 7.22
const LOOP_END := 7.60
const ATLAS_RAW_RGBA_BYTES := 19660800
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CHARGE: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_charge.png")
const WAVE: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_meridian_waves.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_contact.png")
const MARK: Texture2D = preload("res://labs/combat_lab/fist12/assets/generated/f12_six_second_mark.png")
const CASTER_START := Vector2(433.0,552.0)
const FOE_START := Vector2(785.0,552.0)
var elapsed := 0.0
var paused := false

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "huyet_qi_charge"
    if t < CONTACT_START: return "three_cinematic_punches"
    if t < CONTACT_END: return "one_visual_mark_application"
    if t < MARK_END: return "six_second_vein_mark"
    if t < FADE_END: return "vein_mark_fade"
    return "idle"

static func charge_alpha(t: float) -> float:
    if t < 0.0 or t >= CAST_TIME: return 0.0
    return smoothstep(0.0,0.16,t)*(1.0-smoothstep(.37,CAST_TIME,t))

static func wave_alpha(t: float) -> float:
    if t < WAVE_START or t >= CONTACT_START: return 0.0
    return smoothstep(WAVE_START,WAVE_START+.035,t)*(1.0-smoothstep(CONTACT_START-.038,CONTACT_START,t))

static func contact_alpha(t: float) -> float:
    if t < CONTACT_START or t >= CONTACT_END: return 0.0
    return smoothstep(CONTACT_START,CONTACT_START+.032,t)*(1.0-smoothstep(CONTACT_START+.15,CONTACT_END,t))

static func mark_alpha(t: float) -> float:
    if t < MARK_START or t >= FADE_END: return 0.0
    return smoothstep(MARK_START,MARK_START+.12,t)*(1.0-smoothstep(MARK_END,FADE_END,t))

static func caster_at(t: float) -> Vector2:
    # LAB choreography only; character has no approved Quan Tu punch animation.
    var rush:=132.0*smoothstep(.35,.54,t)*(1.0-smoothstep(.97,1.29,t))
    return CASTER_START+Vector2(rush,0.0)

static func foe_at(t: float) -> Vector2:
    # Independently moving target, including long-lived mark in later patrols.
    return FOE_START+Vector2(-52.0*smoothstep(.18,1.13,t)+31.0*smoothstep(2.95,4.10,t)-22.0*smoothstep(5.10,6.36,t),0.0)

static func target_position(index: int,t: float) -> Vector2:
    if index != 0: return Vector2(-10000.0,-10000.0)
    return foe_at(t)

static func mark_at(index: int,t: float) -> Vector2:
    return target_position(index,t)+Vector2(0.0,-87.0)

static func beat_at(t:float) -> int:
    return clampi(int(floor((t-WAVE_START)/(CONTACT_START-WAVE_START)*3.0)),0,2)

static func pressure_pose(t:float) -> int:
    var beat:=beat_at(t)
    var delta:=CONTACT_START-WAVE_START
    var u:=clampf((t-WAVE_START)/delta*3.0-float(beat),0.0,0.999)
    return beat*8+clampi(int(floor(u*8.0)),0,7)

static func wave_at(t:float) -> Vector2:
    var beat:=beat_at(t)
    var offsets:=[Vector2(-51.0,-19.0),Vector2(-45.0,13.0),Vector2(-43.0,-3.0)]
    return mark_at(0,t)+offsets[beat]

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    print("VFX_FIST12_R9_READY skill=",SKILL_ID," pose_count=48 actor_placeholder=true one_mark_6s=true technical_only=true")
    queue_redraw()

func _process(delta:float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    queue_redraw()

func _unhandled_input(event:InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        elif event.keycode==KEY_P:
            paused=not paused

func _frame(tex:Texture2D,idx:int,at:Vector2,scale:float,opacity:float,anchor:Vector2) -> void:
    var cell:=320.0
    draw_set_transform(at,0.0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-anchor,Vector2(cell,cell)),
        Rect2(float(idx%4)*cell,float(int(idx/4))*cell,cell,cell),
        Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet:Vector2,tint:Color,walking:bool) -> void:
    var tex:=WALK if walking else IDLE
    var columns:=maxi(1,int(tex.get_width()/320))
    var idx:=int(floor(elapsed*7.0))%columns if walking else 0
    draw_texture_rect_region(tex,Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(float(idx)*320.0,0.0,320.0,384.0),tint)

func _draw() -> void:
    var t:=elapsed
    var caster:=caster_at(t)
    var foe:=foe_at(t)
    var gather:=charge_alpha(t)
    var stream:=wave_alpha(t)
    var touch:=contact_alpha(t)
    var sigil:=mark_alpha(t)
    draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
    draw_rect(Rect2(0,0,1280,72),Color("14141f",.78))
    if gather>.002:
        var k:=clampi(int(floor(t/CAST_TIME*8.0)),0,7)
        _frame(CHARGE,k,caster+Vector2(41.0,-102.0),.62,gather,Vector2(160,160))
    if t>=.39 and t<.71:
        _actor(caster-Vector2(29,0),Color(0.9,.25,.37,.18),true)
    var caster_walk:=t>=.35 and t<1.32
    var foe_walk:=t>=.18 and t<1.13 or t>=2.95 and t<4.10 or t>=5.10 and t<6.36
    _actor(caster,Color.WHITE,caster_walk)
    _actor(foe,Color("b8c4d5"),foe_walk)
    if stream>.002:
        # Three genuinely different painted flipbooks; one cinematic mark receipt.
        var beat:=beat_at(t)
        var scale:float=[.66,.72,.84][beat]
        _frame(WAVE,pressure_pose(t),wave_at(t),scale,stream,Vector2(160,160))
        # Small local hand release ties energy to caster; actor itself is unchanged.
        var frac:=fposmod((t-WAVE_START)/(CONTACT_START-WAVE_START)*3.0,1.0)
        _frame(CHARGE,clampi(int(frac*8.0),0,7),caster+Vector2(55.0,-103.0),.23,
            stream*(1.0-smoothstep(.67,1.0,frac)),Vector2(160,160))
    if touch>.002:
        var k:=clampi(int(floor((t-CONTACT_START)/(CONTACT_END-CONTACT_START)*8.0)),0,7)
        _frame(CONTACT,k,mark_at(0,t)+Vector2(0,17),.63,touch,Vector2(160,160))
    if sigil>.002:
        var k:=posmod(int(floor((t-MARK_START)*7.0)),8)
        _frame(MARK,k,mark_at(0,t),.38,sigil,Vector2(160,160))
    draw_string(ThemeDB.fallback_font,Vector2(26,33),
        "DOAN MACH LIEN QUYEN / HUYET QUYEN",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("ffe9f1"))
    draw_string(ThemeDB.fallback_font,Vector2(26,56),
        "FIST12 R9 | INDEPENDENT VFX SOURCE | LAB ONLY / ART NOT APPROVED",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffb2d6"))
    if t>=MARK_START and t<MARK_END:
        draw_string(ThemeDB.fallback_font,Vector2(1040,32),
            "MARK %.1f s"%(MARK_END-t),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ff86bd"))
    draw_string(ThemeDB.fallback_font,Vector2(26,684),
        "GODOT 4.7.2 | 3 COSMETIC PUNCHES / ONE MARK 6S | NO RIG / PVE HOLD",
        HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ead1df"))