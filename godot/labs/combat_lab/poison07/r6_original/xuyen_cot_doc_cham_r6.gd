extends Control
## POI07 R6 — independent original sprite master LAB, isolated view-only, no gameplay authority.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_01.human"
const ELEMENT := "nether"
const EFFECT := "damage"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_RANGE := 7.5
const DECLARED_CAST := 0.45
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_COOLDOWN := 9.0
const DECLARED_POISON_STACKS := 0
const CAST_END := 0.45
const CONTACT_AT := 1.39
const CONTACT_END := 1.87
const FADE_END := 2.34
const LOOP_SECONDS := 2.95
const CASTER := Vector2(272.0,537.0)
const TARGET := Vector2(960.0,538.0)
const PALM := Vector2(342.0,427.0)
const CHEST := Vector2(960.0,471.0)
const HERO := "res://labs/combat_lab/poison07/r6_original/assets/bone_needle_r6_12.png"
const CHARGE := "res://labs/combat_lab/poison07/r6_original/assets/bone_charge_r6_10.png"
const PUNCTURE := "res://labs/combat_lab/poison07/r6_original/assets/bone_puncture_r6_12.png"
const HERO_SIZE := Vector2(256,160)
const CHARGE_SIZE := Vector2(192,192)
const PUNCTURE_SIZE := Vector2(256,256)
const VISIBLE_TIP_X := 210.0 # original painted hero tip x, stable pivot across all poses
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
var elapsed := 0.0
var paused := false
var hero_frames: Array[AtlasTexture] = []
var charge_frames: Array[AtlasTexture] = []
var puncture_frames: Array[AtlasTexture] = []

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < CONTACT_AT: return "straight_flight"
    if t < CONTACT_END: return "puncture"
    if t < FADE_END: return "dissolve"
    return "idle"

static func flight_progress_at(t: float) -> float:
    return clampf((t-CAST_END)/(CONTACT_AT-CAST_END),0.0,1.0)

static func flight_tip_at(t: float) -> Vector2:
    return PALM.lerp(CHEST,flight_progress_at(t))

static func charge_frame_float(t: float) -> float:
    return clampf(t/CAST_END*9.0,0,9)

static func hero_frame_float(t: float) -> float:
    return clampf((t-CAST_END)/(CONTACT_AT-CAST_END)*11.0,0,11)

static func impact_frame_float(t: float) -> float:
    return clampf((t-CONTACT_AT)/(FADE_END-CONTACT_AT)*11.0,0,11)

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for path in [HERO,CHARGE,PUNCTURE]:
        if not ResourceLoader.exists(path):
            push_error("POI07_R6_MISSING: " + path)
            set_process(false)
            return
    var ht := load(HERO) as Texture2D
    var ct := load(CHARGE) as Texture2D
    var it := load(PUNCTURE) as Texture2D
    if ht==null or ct==null or it==null:
        push_error("POI07_R6_RESOURCE_LOAD_ERROR")
        set_process(false)
        return
    if ht.get_size()!=Vector2(1024,480) or ct.get_size()!=Vector2(768,576) or it.get_size()!=Vector2(1024,768):
        push_error("POI07_R6_ATLAS_SIZE_INVALID")
        set_process(false)
        return
    for i in range(12):
        hero_frames.append(_make_frame(ht,i,HERO_SIZE))
        puncture_frames.append(_make_frame(it,i,PUNCTURE_SIZE))
    for i in range(10):
        charge_frames.append(_make_frame(ct,i,CHARGE_SIZE))
    set_process(true)
    print("VFX_POI07_R6_READY hero=12 charge=10 impact=12 target_cap=1 source=original_sprite no_rig=true view_only=true")
    queue_redraw()

func _make_frame(atlas: Texture2D,i: int,cell: Vector2) -> AtlasTexture:
    var frame := AtlasTexture.new()
    frame.atlas=atlas
    frame.region=Rect2(Vector2(float(i%4)*cell.x,float(floori(float(i)/4.0))*cell.y),cell)
    frame.filter_clip=true
    return frame

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0,delta),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        elif event.keycode==KEY_P:
            paused=not paused

func _paint(texture: Texture2D,at: Vector2,scale: float,alpha: float,theta: float=0.0) -> void:
    if alpha < 0.002:return
    draw_set_transform(at,theta,Vector2.ONE*scale)
    var size := texture.get_size()
    draw_texture_rect(texture,Rect2(-size*0.5,size),false,Color(1,1,1,alpha))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _flipbook(frames: Array[AtlasTexture],pos: Vector2,scale: float,alpha: float,f: float,theta: float=0.0) -> void:
    var first := clampi(int(floor(f)),0,frames.size()-1)
    var next := mini(first+1,frames.size()-1)
    var q := smoothstep(0,1,clampf(f-float(first),0,1))
    _paint(frames[first],pos,scale,alpha*(1-q),theta)
    if next!=first:_paint(frames[next],pos,scale,alpha*q,theta)

func _actor(pos: Vector2,scale: float,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,Rect2(pos-Vector2(160,351)*scale,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _draw() -> void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if hero_frames.size()!=12 or charge_frames.size()!=10 or puncture_frames.size()!=12:return
    var t := elapsed
    # Caster's original hand-painted needle splinters: only charge layer behind caster.
    if t < CAST_END:
        var rise := smoothstep(0.025,0.29,t)
        _flipbook(charge_frames,PALM-Vector2(7,0),1.12,rise,charge_frame_float(t))
    # Needle art is an independent original 12-pose transparent sprite with no arc motion.
    if t >= CAST_END and t < CONTACT_AT:
        var q := flight_progress_at(t)
        var angle := (CHEST-PALM).angle()
        var axis := Vector2(cos(angle),sin(angle))
        var scale := 1.32
        var tip_offset := (VISIBLE_TIP_X-HERO_SIZE.x*0.5)*scale
        var tip := flight_tip_at(t)
        var trail_tip := PALM.lerp(CHEST,maxf(0,q-0.043))
        _flipbook(hero_frames,trail_tip-axis*tip_offset,scale*0.91,0.19,hero_frame_float(t-0.03),angle)
        _flipbook(hero_frames,tip-axis*tip_offset,scale,0.99,hero_frame_float(t),angle)
    _actor(CASTER,0.47,Color.WHITE)
    # Puncture under the target silhouette is a subtle physical-depth cue.
    if t>=CONTACT_AT and t<FADE_END:
        var intro := smoothstep(CONTACT_AT,CONTACT_AT+0.04,t)
        var out := 1.0-smoothstep(CONTACT_END,FADE_END,t)
        _flipbook(puncture_frames,CHEST,0.78,0.20*intro*out,impact_frame_float(t))
    _actor(TARGET,0.47,Color("d9d3e2"))
    # Face stays readable; micro-puncture sits at chest and never creates fake HP/DoT.
    if t>=CONTACT_AT and t<FADE_END:
        var gain := smoothstep(CONTACT_AT,CONTACT_AT+0.04,t)*(1.0-smoothstep(CONTACT_END,FADE_END,t))
        _flipbook(puncture_frames,CHEST,0.98,gain,impact_frame_float(t))
        if t<CONTACT_AT+0.17:
            var stab := 1.0-smoothstep(CONTACT_AT+0.04,CONTACT_AT+0.17,t)
            var theta := (CHEST-PALM).angle()
            var axis := Vector2(cos(theta),sin(theta))
            _flipbook(hero_frames,CHEST-axis*21.0,0.27,stab*0.4,11,theta)
