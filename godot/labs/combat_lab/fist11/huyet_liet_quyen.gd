extends Control
## FIST11 Huyet Liet Quyen: original first-party nether fist VFX.
## LAB preview only. No damage writes / no rig / no GIF / no actual Combat V2 receipts.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_01.human"
const ART_REVISION := "R2_COMPACT_CRIMSON_FIST"
const EFFECT := "damage"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_RANGE := 2.8
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const PROJECTILE_SPEED := 8.0
const DECLARED_DURATION := 0.0
const DECLARED_RADIUS := 0.0
const CHARGE_END := 0.45
const RELEASE_END := 0.45
const CONTACT_AT := 0.80
const IMPACT_END := 1.13
const FADE_END := 1.36
const LOOP_END := 1.85
const ATLAS_RAW_RGBA_BYTES := 9109504
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CHARGE: Texture2D = preload("res://labs/combat_lab/fist11/assets/generated/f11_charge.png")
const FLIGHT: Texture2D = preload("res://labs/combat_lab/fist11/assets/generated/f11_flight_fist.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist11/assets/generated/f11_contact.png")
const CASTER_START := Vector2(445.0,551.0)
const ENEMY_START := Vector2(810.0,551.0)
@export var vfx_only_benchmark := false
var elapsed := 0.0
var paused := false

static func phase_at(t: float) -> String:
    if t < CHARGE_END: return "charge"
    if t < CONTACT_AT: return "flight"
    if t < FADE_END: return "contact_and_fade"
    return "idle"

static func charge_alpha(t: float) -> float:
    if t < 0.0 or t >= RELEASE_END: return 0.0
    return smoothstep(0.02,0.30,t)*(1.0-smoothstep(.39,RELEASE_END,t))

static func flight_at(t: float) -> float:
    return clampf((t-RELEASE_END)/(CONTACT_AT-RELEASE_END),0.0,1.0)

static func impact_alpha(t: float) -> float:
    if t<CONTACT_AT or t>=FADE_END:return 0.0
    return smoothstep(CONTACT_AT,CONTACT_AT+.055,t)*(1.0-smoothstep(IMPACT_END,FADE_END,t))

static func caster_at(t: float) -> Vector2:
    return CASTER_START+Vector2(16.0*smoothstep(.10,.68,t),0.0)

static func enemy_at(t: float) -> Vector2:
    return ENEMY_START+Vector2(-42.0*smoothstep(.23,.84,t)+9.0*smoothstep(1.02,1.37,t),0.0)

static func target_at(index: int,t: float) -> Vector2:
    if index!=0:return Vector2(-10000.0,-10000.0)
    return enemy_at(t)

static func hand_at(t: float) -> Vector2:
    return caster_at(t)+Vector2(45.0,-118.0)

static func contact_at(index: int,t: float) -> Vector2:
    if index!=0:return Vector2(-10000.0,-10000.0)
    return target_at(index,t)+Vector2(0.0,-111.0)

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    queue_redraw()
    if not vfx_only_benchmark:
        print("VFX_FIST11_R2_READY skill=",SKILL_ID," effect=damage target_cap=1 moving=true view_only=true no_rig=true no_gif=true")

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if vfx_only_benchmark or not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode==KEY_P:paused=not paused

func _frame(tex: Texture2D,k: int,cell: float,at: Vector2,scale: float,alpha: float) -> void:
    var col:=k%4
    var row:=int(k/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-Vector2.ONE*cell*.5,Vector2.ONE*cell),
        Rect2(float(col)*cell,float(row)*cell,cell,cell),Color(1,1,1,clampf(alpha,0,1)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color,walk: bool) -> void:
    var tex:=WALK if walk else IDLE
    var cells:=maxi(1,int(tex.get_width()/320))
    var col:=int(floor(elapsed*7.0))%cells if walk else 0
    draw_texture_rect_region(tex,
        Rect2(feet-Vector2(68.0,151.0),Vector2(136.0,169.0)),
        Rect2(float(col)*320.0,0.0,320.0,384.0),tint)

func _draw() -> void:
    var t:=elapsed
    var caster:=caster_at(t)
    var victim:=enemy_at(t)
    if not vfx_only_benchmark:
        draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
        draw_rect(Rect2(0,0,1280,75),Color("14121e",.80))
    if t<RELEASE_END:
        var charge:=charge_alpha(t)
        if charge>.005:
            var k:=clampi(int(floor(t/RELEASE_END*8.0)),0,7)
            _frame(CHARGE,k,256.0,hand_at(t),.69+.08*t/RELEASE_END,charge)
    if t>=RELEASE_END and t<CONTACT_AT:
        var q:=flight_at(t)
        var tip:=hand_at(RELEASE_END).lerp(contact_at(0,t),smoothstep(0.0,1.0,q))
        var k:=clampi(int(floor(q*12.0)),0,11)
        _frame(FLIGHT,k,320.0,tip,.91+.11*q,.92)
    var burst:=impact_alpha(t)
    if burst>.006:
        var k:=clampi(int(floor((t-CONTACT_AT)/(FADE_END-CONTACT_AT)*8.0)),0,7)
        _frame(CONTACT,k,256.0,contact_at(0,t),1.09,burst)
    if not vfx_only_benchmark:
        _actor(caster,Color.WHITE,t>=.12 and t<.70)
        _actor(victim,Color("c4c6d6"),t>=.22 and t<1.22)
        draw_string(ThemeDB.fallback_font,Vector2(28,32),
            "HUYET LIET QUYEN / HUYET QUYEN",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("ffe1dc"))
        draw_string(ThemeDB.fallback_font,Vector2(28,57),
            "FIST11 R2 | COMPACT CRIMSON FIST | SINGLE TARGET | LAB ONLY",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f0a3b2"))
        draw_string(ThemeDB.fallback_font,Vector2(28,684),
            "GODOT 4.7.2 | NETHER DAMAGE VISUAL ONLY | WALK TRACKING | NO RIG",
            HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("ecbec7"))