extends Control
## POI08: Phe Mach Doc Thich | Original single-target Nether poison | VIEW ONLY LAB.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_02.human"
const ELEMENT := "nether"
const EFFECT := "poison"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_RANGE := 7.5
const DECLARED_CAST := 0.45
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_COOLDOWN := 9.0
const DECLARED_DURATION := 8.0
const DECLARED_POISON_STACKS := 1
const DECLARED_RADIUS := 0.0
const CAST_END := 0.45
const CONTACT_AT := 1.39
const MARK_END := CONTACT_AT + DECLARED_DURATION
const FADE_END := MARK_END + 0.33
const LOOP_SECONDS := 10.15
const CASTER := Vector2(272.0,537.0)
const TARGET := Vector2(960.0,538.0)
const PALM := Vector2(342.0,427.0)
const CHEST := Vector2(960.0,471.0)
const TIP_X_FROM_CENTRE := 145.0
const THORN_PATH := "res://labs/combat_lab/poison08/assets/phe_mach_thorn_12.png"
const CHARGE_PATH := "res://labs/combat_lab/poison08/assets/phe_mach_charge_08.png"
const VEIN_PATH := "res://labs/combat_lab/poison08/assets/phe_mach_vein_12.png"
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
var elapsed := 0.0
var paused := false
var thorn_frames: Array[AtlasTexture] = []
var charge_frames: Array[AtlasTexture] = []
var vein_frames: Array[AtlasTexture] = []

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < CONTACT_AT: return "flight"
    if t < MARK_END: return "single_target_poison_visual"
    if t < FADE_END: return "fade"
    return "idle"

static func flight_q_at(t: float) -> float:
    return clampf((t - CAST_END) / (CONTACT_AT - CAST_END),0.0,1.0)

static func tip_at(t: float) -> Vector2:
    return PALM.lerp(CHEST,flight_q_at(t))

static func thorn_pose_at(t: float) -> int:
    return clampi(int(floor(maxf(0.0,t-CAST_END)/(CONTACT_AT-CAST_END)*12.0)),0,11)

static func charge_pose_at(t: float) -> int:
    return clampi(int(floor(clampf(t/CAST_END,0.0,1.0)*8.0)),0,7)

static func vein_pose_at(t: float) -> int:
    return posmod(int(floor(maxf(0.0,t-CONTACT_AT)*3.0)),12)

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for p in [THORN_PATH,CHARGE_PATH,VEIN_PATH]:
        if not ResourceLoader.exists(p):
            push_error("POI08_ATLAS_MISSING: "+p)
            set_process(false)
            return
    var a := load(THORN_PATH) as Texture2D
    var b := load(CHARGE_PATH) as Texture2D
    var c := load(VEIN_PATH) as Texture2D
    if a==null or b==null or c==null:
        push_error("POI08_BAD_TEXTURE")
        set_process(false)
        return
    if a.get_size()!=Vector2(1536,576) or b.get_size()!=Vector2(1024,512) or c.get_size()!=Vector2(1280,960):
        push_error("POI08_ATLAS_DIMENSIONS")
        set_process(false)
        return
    for i in range(12):
        var t := AtlasTexture.new()
        t.atlas=a
        t.region=Rect2(Vector2(float(i%4)*384.0,float(i/4)*192.0),Vector2(384,192))
        thorn_frames.append(t)
        var v := AtlasTexture.new()
        v.atlas=c
        v.region=Rect2(Vector2(float(i%4)*320.0,float(i/4)*320.0),Vector2(320,320))
        vein_frames.append(v)
    for i in range(8):
        var t := AtlasTexture.new()
        t.atlas=b
        t.region=Rect2(Vector2(float(i%4)*256.0,float(i/4)*256.0),Vector2(256,256))
        charge_frames.append(t)
    set_process(true)
    print("VFX_POI08_READY thorn=12 charge=8 vein=12 target_cap=1 view_only=true")
    queue_redraw()

func _process(delta: float) -> void:
    if paused: return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        elif event.keycode==KEY_P:
            paused=not paused

func _sprite(tex: Texture2D,center: Vector2,scale: float,opacity: float,rotation: float=0.0) -> void:
    if opacity<0.002:return
    draw_set_transform(center,rotation,Vector2.ONE*scale)
    var size := tex.get_size()
    draw_texture_rect(tex,Rect2(-size/2.0,size),false,Color(1,1,1,opacity))
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _actor(center: Vector2,scale: float,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,Rect2(center-Vector2(160,351)*scale,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _draw() -> void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if thorn_frames.size()!=12 or charge_frames.size()!=8 or vein_frames.size()!=12:return
    var t := elapsed
    if t<CAST_END:
        var q := smoothstep(0.04,CAST_END,t)
        _sprite(charge_frames[charge_pose_at(t)],PALM-Vector2(6,0),0.67,q*0.84)
        _sprite(thorn_frames[0],PALM-Vector2(56,0),0.23,q*0.36)
    elif t<CONTACT_AT:
        var q := flight_q_at(t)
        var dir := (CHEST-PALM).angle()
        var axis := Vector2(cos(dir),sin(dir))
        var current := tip_at(t)
        var old := PALM.lerp(CHEST,maxf(0.0,q-0.055))
        _sprite(thorn_frames[thorn_pose_at(t)],old-axis*(TIP_X_FROM_CENTRE*0.57),0.57,0.16,dir)
        _sprite(thorn_frames[thorn_pose_at(t)],current-axis*(TIP_X_FROM_CENTRE*0.69),0.69,0.97,dir)
    _actor(CASTER,0.47,Color.WHITE)
    var mark_alpha := 0.0
    if t>=CONTACT_AT and t<FADE_END:
        mark_alpha = smoothstep(CONTACT_AT-0.01,CONTACT_AT+0.05,t)*(1.0-smoothstep(MARK_END,FADE_END,t))
        var intro := smoothstep(CONTACT_AT,CONTACT_AT+0.12,t)
        var local_alpha := (0.72 if t < CONTACT_AT+0.32 else 0.48)
        _sprite(vein_frames[vein_pose_at(t)],CHEST,0.51,mark_alpha*local_alpha*0.30)
    _actor(TARGET,0.47,Color("d9d3e2"))
    if mark_alpha>0.0:
        var burst := 1.0-smoothstep(CONTACT_AT+0.15,CONTACT_AT+0.44,t)
        var gain := mark_alpha*(0.46+0.45*burst)
        _sprite(vein_frames[vein_pose_at(t)],CHEST,0.59,gain)
        if burst>0.0:
            var dir := (CHEST-PALM).angle()
            var axis := Vector2(cos(dir),sin(dir))
            _sprite(thorn_frames[11],CHEST-axis*(TIP_X_FROM_CENTRE*0.23),0.23,burst*mark_alpha*0.37,dir)
