extends Control
## POI09 — Bach Doc Tan Cham Human. Original painted fan-lotus / triple needle VFX.
## Isolated view-only Combat Lab. Three moving mock target positions. No damage, no poison writes.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_03.human"
const ELEMENT := "nether"
const EFFECT := "poison"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RADIUS := 2.8
const DECLARED_RANGE := 7.0
const DECLARED_CAST := 0.6
const DECLARED_COOLDOWN := 11.0
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_DURATION := 6.0
const DECLARED_POISON_STACKS := 1
const CAST_END := 0.60
const FIRST_HIT := 1.53
const HIT_SPACING := 0.08
const CONTACT_DURATION := 0.40
const FADE_DURATION := 0.32
const LOOP_SECONDS := 8.62
const CASTER := Vector2(265.0,544.0)
const PALM := Vector2(345.0,426.0)
const CHARGE_PATH := "res://labs/combat_lab/poison09/r1_painted/assets/poison_fan_charge_r1_12.png"
const NEEDLE_PATH := "res://labs/combat_lab/poison09/r1_painted/assets/poison_fan_needle_r1_12.png"
const CONTACT_PATH := "res://labs/combat_lab/poison09/r1_painted/assets/poison_fan_contact_r1_10.png"
const MARK_PATH := "res://labs/combat_lab/poison09/r1_painted/assets/poison_fan_mark_r1_12.png"
const CHARGE_CELL := Vector2(224.0,160.0)
const NEEDLE_CELL := Vector2(256.0,96.0)
const CONTACT_CELL := Vector2(192.0,160.0)
const NEEDLE_TIP_OFFSET := 86.0
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
var elapsed := 0.0
var paused := false
var charge_frames: Array[AtlasTexture] = []
var needle_frames: Array[AtlasTexture] = []
var contact_frames: Array[AtlasTexture] = []
var mark_frames: Array[AtlasTexture] = []

static func target_at(i: int,t: float) -> Vector2:
    # Three illustrative moving stand-ins in the local circle (not a gameplay target resolver).
    var base := Vector2(900.0,540.0)
    if i==1: base=Vector2(1040.0,550.0)
    if i==2: base=Vector2(1165.0,541.0)
    var phase := float(i)*1.75
    return base+Vector2(12.0*sin(t*1.13+phase),8.0*cos(t*0.94+phase))

static func chest_at(i: int,t: float) -> Vector2:
    return target_at(i,t)+Vector2(0.0,-67.0)

static func hit_time(i: int) -> float:
    return FIRST_HIT+HIT_SPACING*float(i)

static func start_time(i: int) -> float:
    return CAST_END+0.075*float(i)

static func flight_fraction(i: int,t: float) -> float:
    return clampf((t-start_time(i))/(hit_time(i)-start_time(i)),0.0,1.0)

static func needle_tip_at(i: int,t: float) -> Vector2:
    # Predict where the moving stand-in will be at the contact frame.
    return PALM.lerp(chest_at(i,hit_time(i)),flight_fraction(i,t))

static func mark_alpha_at(i: int,t: float) -> float:
    var contact := hit_time(i)
    var ending := contact+DECLARED_DURATION
    if t<contact or t>=ending+FADE_DURATION:return 0.0
    return smoothstep(contact,contact+0.07,t)*(1.0-smoothstep(ending,ending+FADE_DURATION,t))

static func phase_at(t: float) -> String:
    if t<CAST_END:return "lotus_charge"
    if t<FIRST_HIT:return "three_needles_in_flight"
    if t<hit_time(2)+CONTACT_DURATION:return "three_local_contacts"
    if t<hit_time(2)+DECLARED_DURATION:return "one_poison_mark_each"
    if t<hit_time(2)+DECLARED_DURATION+FADE_DURATION:return "mark_dissolve"
    return "idle"

static func charge_frame(t: float) -> float:
    return clampf(t/CAST_END*11.0,0.0,11.0)

static func needle_frame(i: int,t: float) -> float:
    return clampf(flight_fraction(i,t)*11.0,0.0,11.0)

static func contact_frame(i: int,t: float) -> float:
    return clampf((t-hit_time(i))/CONTACT_DURATION*9.0,0.0,9.0)

static func mark_frame(i: int,t: float) -> float:
    return fposmod((t-hit_time(i))*2.7+float(i)*1.3,12.0)

func _make_frame(atlas: Texture2D,i: int,cell: Vector2) -> AtlasTexture:
    var texture := AtlasTexture.new()
    texture.atlas=atlas
    texture.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    texture.filter_clip=true
    return texture

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for path in [CHARGE_PATH,NEEDLE_PATH,CONTACT_PATH,MARK_PATH]:
        if not ResourceLoader.exists(path):
            push_error("POI09_SOURCE_MISSING "+path)
            set_process(false)
            return
    var a:=load(CHARGE_PATH) as Texture2D
    var b:=load(NEEDLE_PATH) as Texture2D
    var c:=load(CONTACT_PATH) as Texture2D
    var d:=load(MARK_PATH) as Texture2D
    if a==null or b==null or c==null or d==null:
        push_error("POI09_RGBA_IMPORT_INVALID")
        set_process(false)
        return
    if a.get_size()!=Vector2(896,480) or b.get_size()!=Vector2(1024,288) or c.get_size()!=Vector2(768,480) or d.get_size()!=Vector2(768,480):
        push_error("POI09_ATLAS_SIZE_INVALID")
        set_process(false)
        return
    for i in range(12):
        charge_frames.append(_make_frame(a,i,CHARGE_CELL))
        needle_frames.append(_make_frame(b,i,NEEDLE_CELL))
        mark_frames.append(_make_frame(d,i,CONTACT_CELL))
    for i in range(10):
        contact_frames.append(_make_frame(c,i,CONTACT_CELL))
    set_process(true)
    print("VFX_POI09_R1_READY charge=12 needle=12 contact=10 mark=12 circle_radius=2.8 target_cap=3 moving_targets=true view_only=true")
    queue_redraw()

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        elif event.keycode==KEY_P:
            paused=not paused

func _sprite(tex: Texture2D,at: Vector2,scale: float,alpha: float,angle: float=0.0) -> void:
    if alpha<=0.001:return
    draw_set_transform(at,angle,Vector2.ONE*scale)
    var s:=tex.get_size()
    draw_texture_rect(tex,Rect2(-s*0.5,s),false,Color(1,1,1,alpha))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _flipbook(frames: Array[AtlasTexture],at: Vector2,scale: float,alpha: float,f: float,angle: float=0.0) -> void:
    var j:=clampi(int(floor(f)),0,frames.size()-1)
    var k:=mini(j+1,frames.size()-1)
    var q:=smoothstep(0.0,1.0,clampf(f-float(j),0,1))
    _sprite(frames[j],at,scale,alpha*(1-q),angle)
    if k!=j:_sprite(frames[k],at,scale,alpha*q,angle)

func _actor(at: Vector2,scale: float,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,Rect2(at-Vector2(160,351)*scale,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _draw() -> void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=12 or needle_frames.size()!=12 or contact_frames.size()!=10 or mark_frames.size()!=12:return
    var t:=elapsed
    if t<CAST_END:
        var rise:=smoothstep(0.05,0.52,t)
        _flipbook(charge_frames,PALM-Vector2(6,12),0.95,rise,charge_frame(t))
    # Three independent painted needle sprites, not a single projectile multiplied into an AoE event.
    for i in range(TARGET_LIMIT):
        if t>=start_time(i) and t<hit_time(i):
            var aim:=needle_tip_at(i,t)
            var theta:float=(chest_at(i,hit_time(i))-PALM).angle()
            var axis:=Vector2(cos(theta),sin(theta))
            var speed_scale:=0.79
            var pivot:=NEEDLE_TIP_OFFSET*speed_scale
            var q:=flight_fraction(i,t)
            var trailing:=PALM.lerp(chest_at(i,hit_time(i)),maxf(0.0,q-0.065))
            _flipbook(needle_frames,trailing-axis*pivot,0.73,0.11,needle_frame(i,t),theta)
            _flipbook(needle_frames,aim-axis*pivot,speed_scale,0.96,needle_frame(i,t),theta)
    _actor(CASTER,0.47,Color.WHITE)
    for i in range(TARGET_LIMIT):
        var body:=target_at(i,t)
        var alpha:=mark_alpha_at(i,t)
        if alpha>0:
            _flipbook(mark_frames,body+Vector2(0,-45),0.43,alpha*0.19,mark_frame(i,t))
        _actor(body,0.41,Color("d8d1db") if i!=1 else Color("c9d3e1"))
        if alpha>0:
            _flipbook(mark_frames,body+Vector2(0,-40),0.52,alpha*0.69,mark_frame(i,t))
        if t>=hit_time(i) and t<hit_time(i)+CONTACT_DURATION:
            var p:=hit_time(i)
            var hit_alpha:=smoothstep(p,p+0.05,t)*(1.0-smoothstep(p+0.24,p+CONTACT_DURATION,t))
            _flipbook(contact_frames,chest_at(i,t)+Vector2(0,12),0.63,hit_alpha*0.94,contact_frame(i,t))