extends Control
## POI07 — Xuyen Cot Doc Cham, original alpha flipbook, VIEW-ONLY. No game-authority writes.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_01.human"
const ELEMENT := "nether"
const EFFECT := "damage"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST := 0.45
const DECLARED_RANGE := 7.5
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_COOLDOWN := 9.0
const DECLARED_POISON_STACKS := 0
const CAST_END := 0.45
const CONTACT_AT := 1.39
const CONTACT_END := 1.86
const FADE_END := 2.35
const LOOP_SECONDS := 2.90
const ATLAS_PATH := "res://labs/combat_lab/poison07/assets/doc_cham_needle_12.png"
const CONTACT_PATH := "res://labs/combat_lab/poison07/assets/doc_cham_contact_08.png"
const CHARGE_R4_PATH := "res://labs/combat_lab/poison07/assets/doc_cham_charge_r4_12.png"
const CONTACT_R4_PATH := "res://labs/combat_lab/poison07/assets/doc_cham_contact_r4_12.png"
const R4_CELL := Vector2(320.0,320.0)
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER := Vector2(272.0, 537.0)
const TARGET := Vector2(960.0, 538.0)
const PALM := Vector2(342.0, 427.0)
const CHEST := Vector2(960.0, 471.0)
const NEEDLE_SIZE := Vector2(384.0,192.0)
const TIP_X_FROM_CENTRE := 138.0 # painted alpha tip at local x≈330; cell half-width=192
const IMPACT_SIZE := Vector2(256.0,256.0)
var elapsed := 0.0
var paused := false
var needle_frames: Array[AtlasTexture] = []
var impact_frames: Array[AtlasTexture] = []
var charge_r4_frames: Array[AtlasTexture] = []
var contact_r4_frames: Array[AtlasTexture] = []

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < CONTACT_AT: return "travel"
    if t < CONTACT_END: return "single_contact"
    if t < FADE_END: return "fade"
    return "idle"

static func flight_progress_at(t: float) -> float:
    # Deliberately constant-speed straight projectile: no bezier/arc/sine rise.
    return clampf((t - CAST_END) / (CONTACT_AT - CAST_END), 0.0, 1.0)

static func flight_tip_at(t: float) -> Vector2:
    return PALM.lerp(CHEST, flight_progress_at(t))

static func needle_frame_at(t: float) -> int:
    if t < CAST_END: return clampi(int(floor(t / CAST_END * 4.0)), 0, 3)
    if t < CONTACT_AT: return clampi(4 + int(floor((t - CAST_END) / (CONTACT_AT - CAST_END) * 5.0)), 4, 8)
    return clampi(9 + int(floor((t - CONTACT_AT) / (FADE_END - CONTACT_AT) * 3.0)),9,11)

static func charge_r4_frame_at(t: float) -> int:
    return clampi(int(floor(clampf(t / CAST_END,0.0,1.0)*12.0)),0,11)

static func impact_r4_frame_at(t: float) -> int:
    return clampi(int(floor(clampf((t-CONTACT_AT)/(FADE_END-CONTACT_AT),0.0,1.0)*12.0)),0,11)

static func impact_frame_at(t: float) -> int:
    return clampi(int(floor((t-CONTACT_AT) / (FADE_END-CONTACT_AT) * 8.0)),0,7)

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    if not ResourceLoader.exists(ATLAS_PATH) or not ResourceLoader.exists(CONTACT_PATH) or not ResourceLoader.exists(CHARGE_R4_PATH) or not ResourceLoader.exists(CONTACT_R4_PATH):
        push_error("POI07_TEXTURE_MISSING: run tools/vfx/generate_poi07_poison_needle.py")
        set_process(false)
        return
    var needle_atlas := load(ATLAS_PATH) as Texture2D
    var impact_atlas := load(CONTACT_PATH) as Texture2D
    var charge_r4_atlas := load(CHARGE_R4_PATH) as Texture2D
    var contact_r4_atlas := load(CONTACT_R4_PATH) as Texture2D
    if needle_atlas == null or impact_atlas == null or charge_r4_atlas == null or contact_r4_atlas == null:
        push_error("POI07_TEXTURE_INVALID")
        set_process(false)
        return
    if needle_atlas.get_size() != Vector2(1536,576) or impact_atlas.get_size()!=Vector2(1024,512) or charge_r4_atlas.get_size()!=Vector2(1280,960) or contact_r4_atlas.get_size()!=Vector2(1280,960):
        push_error("POI07_ATLAS_DIMENSION_MISMATCH")
        set_process(false)
        return
    for i in range(12):
        var frame := AtlasTexture.new()
        frame.atlas=needle_atlas
        frame.region=Rect2(Vector2(float(i%4)*384.0,float(i/4)*192.0), NEEDLE_SIZE)
        needle_frames.append(frame)
    for i in range(8):
        var frame := AtlasTexture.new()
        frame.atlas=impact_atlas
        frame.region=Rect2(Vector2(float(i%4)*256.0,float(i/4)*256.0), IMPACT_SIZE)
        impact_frames.append(frame)
    for i in range(12):
        var ch := AtlasTexture.new()
        ch.atlas = charge_r4_atlas
        ch.region = Rect2(Vector2(float(i%4)*320.0,float(i/4)*320.0),R4_CELL)
        charge_r4_frames.append(ch)
        var hit := AtlasTexture.new()
        hit.atlas = contact_r4_atlas
        hit.region = Rect2(Vector2(float(i%4)*320.0,float(i/4)*320.0),R4_CELL)
        contact_r4_frames.append(hit)
    set_process(true)
    print("VFX_POI07_READY frames=12 contact=8 charge_r4=12 body_contact_r4=12 single_target=true gameplay=false")
    queue_redraw()

func _process(delta: float) -> void:
    if paused: return
    elapsed=fposmod(elapsed+maxf(delta,0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        elif event.keycode==KEY_P:
            paused=not paused

func _sprite(tex: Texture2D, center: Vector2, scale: float, alpha: float, angle: float=0.0) -> void:
    if alpha <= 0.001: return
    draw_set_transform(center,angle,Vector2.ONE*scale)
    var size := tex.get_size()
    draw_texture_rect(tex,Rect2(-size/2.0,size),false,Color(1.0,1.0,1.0,alpha))
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _actor(center: Vector2, scale: float, tint: Color) -> void:
    draw_texture_rect_region(ACTOR, Rect2(center-Vector2(160,351)*scale,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _draw() -> void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if needle_frames.size()!=12 or impact_frames.size()!=8 or charge_r4_frames.size()!=12 or contact_r4_frames.size()!=12: return
    var t := elapsed
    if t < CAST_END:
        var q := smoothstep(0.03,CAST_END,t)
        var charge_scale := 0.25+0.17*q
        _sprite(charge_r4_frames[charge_r4_frame_at(t)],PALM-Vector2(8,0),0.61,q*0.93)
        _sprite(needle_frames[needle_frame_at(t)],PALM-Vector2(TIP_X_FROM_CENTRE*charge_scale,0),charge_scale,0.62*q)
    elif t < CONTACT_AT:
        var q := flight_progress_at(t)
        var at := flight_tip_at(t)
        var previous := PALM.lerp(CHEST,maxf(0.0,q-0.058))
        var direction := (CHEST-PALM).angle()
        var along := Vector2(cos(direction),sin(direction))
        # Tip, not cell centre, follows the hand→chest route; avoids overshooting.
        _sprite(needle_frames[needle_frame_at(t)],previous-along*(TIP_X_FROM_CENTRE*0.55),0.55,0.17,direction)
        _sprite(needle_frames[needle_frame_at(t)],at-along*(TIP_X_FROM_CENTRE*0.63),0.63,0.96,direction)
    _actor(CASTER,0.47,Color.WHITE)
    var contact_alpha := 0.0
    if t >= CONTACT_AT and t < FADE_END:
        contact_alpha = smoothstep(CONTACT_AT-0.015,CONTACT_AT+0.025,t)*(1.0-smoothstep(CONTACT_END,FADE_END,t))
        _sprite(contact_r4_frames[impact_r4_frame_at(t)],CHEST,0.63,contact_alpha*0.30)
    _actor(TARGET,0.47,Color("d9d3e2"))
    if t >= CONTACT_AT and t < FADE_END:
        var opacity := smoothstep(CONTACT_AT,CONTACT_AT+0.045,t) * (1.0-smoothstep(CONTACT_END,FADE_END,t))
        _sprite(impact_frames[impact_frame_at(t)],CHEST,0.35,opacity*0.30)
        _sprite(contact_r4_frames[impact_r4_frame_at(t)],CHEST,0.57,contact_alpha*1.0)
        # Real sprite tip remains embedded briefly during the single visual contact.
        # At t>=1.68 it dissolves; no additional hit or status cue.
        var puncture_hold := 1.0-smoothstep(CONTACT_AT+0.16,CONTACT_AT+0.34,t)
        var stab_scale := 0.22
        var axis := (CHEST-PALM).normalized()
        _sprite(needle_frames[needle_frame_at(t)],CHEST-axis*(TIP_X_FROM_CENTRE*stab_scale),stab_scale,contact_alpha*puncture_hold*0.54,(CHEST-PALM).angle())
