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
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER := Vector2(272.0, 537.0)
const TARGET := Vector2(960.0, 538.0)
const PALM := Vector2(342.0, 427.0)
const CHEST := Vector2(960.0, 471.0)
const NEEDLE_SIZE := Vector2(384.0,192.0)
const IMPACT_SIZE := Vector2(256.0,256.0)
var elapsed := 0.0
var paused := false
var needle_frames: Array[AtlasTexture] = []
var impact_frames: Array[AtlasTexture] = []

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < CONTACT_AT: return "travel"
    if t < CONTACT_END: return "single_contact"
    if t < FADE_END: return "fade"
    return "idle"

static func needle_frame_at(t: float) -> int:
    if t < CAST_END: return clampi(int(floor(t / CAST_END * 4.0)), 0, 3)
    if t < CONTACT_AT: return clampi(4 + int(floor((t - CAST_END) / (CONTACT_AT - CAST_END) * 5.0)), 4, 8)
    return clampi(9 + int(floor((t - CONTACT_AT) / (FADE_END - CONTACT_AT) * 3.0)),9,11)

static func impact_frame_at(t: float) -> int:
    return clampi(int(floor((t-CONTACT_AT) / (FADE_END-CONTACT_AT) * 8.0)),0,7)

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    if not ResourceLoader.exists(ATLAS_PATH) or not ResourceLoader.exists(CONTACT_PATH):
        push_error("POI07_TEXTURE_MISSING: run tools/vfx/generate_poi07_poison_needle.py")
        set_process(false)
        return
    var needle_atlas := load(ATLAS_PATH) as Texture2D
    var impact_atlas := load(CONTACT_PATH) as Texture2D
    if needle_atlas == null or impact_atlas == null:
        push_error("POI07_TEXTURE_INVALID")
        set_process(false)
        return
    if needle_atlas.get_size() != Vector2(1536,576) or impact_atlas.get_size()!=Vector2(1024,512):
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
    set_process(true)
    print("VFX_POI07_READY frames=12 contact=8 single_target=true gameplay=false")
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
    if needle_frames.size()!=12 or impact_frames.size()!=8: return
    var t := elapsed
    if t < CAST_END:
        var q := smoothstep(0.03,CAST_END,t)
        _sprite(needle_frames[needle_frame_at(t)],PALM,0.25+0.17*q,0.72*q)
    elif t < CONTACT_AT:
        var q := smoothstep(CAST_END,CONTACT_AT,t)
        var at := PALM.lerp(CHEST,q)+Vector2(0.0,-36.0*sin(PI*q))
        var previous_q := clampf(q-0.058,0,1)
        var previous := PALM.lerp(CHEST,previous_q)+Vector2(0,-36*sin(PI*previous_q))
        var direction := (CHEST-PALM).angle()
        _sprite(needle_frames[needle_frame_at(t)],previous,0.55,0.17,direction)
        _sprite(needle_frames[needle_frame_at(t)],at,0.63,0.96,direction)
    _actor(CASTER,0.47,Color.WHITE)
    _actor(TARGET,0.47,Color("d9d3e2"))
    if t >= CONTACT_AT and t < FADE_END:
        var opacity := smoothstep(CONTACT_AT,CONTACT_AT+0.08,t) * (1.0-smoothstep(CONTACT_END,FADE_END,t))
        _sprite(impact_frames[impact_frame_at(t)],CHEST,0.62,opacity*0.94)
        _sprite(needle_frames[needle_frame_at(t)],CHEST+Vector2(-36,0),0.26,opacity*0.22)
