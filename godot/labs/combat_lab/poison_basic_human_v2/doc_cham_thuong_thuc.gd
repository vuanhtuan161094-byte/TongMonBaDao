extends Control
## POISON BASIC Human R2; independent vivid RGBA sprite art, no GIF pixel extraction.
## VIEW ONLY: target/contact timestamps are cosmetic. No status or damage authority.
const SKILL_ID := "tmb.skill.poison.basic.human"
const EFFECT := "damage"
const ELEMENT := "metal"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST := 0.0
const DECLARED_COOLDOWN := 1.6
const DECLARED_RANGE := 6.0
const DECLARED_PROJECTILE_SPEED := 12.0
const DECLARED_DAMAGE_RATIO := 1.0
const DECLARED_DURATION := 0.0
const CAST_END := 0.15 # VISUAL_ONLY cosmetic formation, not Combat cast time
const DEMO_CONTACT := 0.68 # LAB_ONLY visual hit, not receipt
const IMPACT_END := 0.99 # visual fade, no status
const LOOP_SECONDS := 1.28
const PALM := Vector2(342.0,426.0)
const CASTER := Vector2(273.0,540.0)
const BASE_FOOT := Vector2(997.0,563.0)
const CHARGE_PATH := "res://labs/combat_lab/poison_basic_human_v2/assets/atlas/poison_basic_charge_06_rgba.png"
const FLIGHT_PATH := "res://labs/combat_lab/poison_basic_human_v2/assets/atlas/poison_basic_flight_08_rgba.png"
const IMPACT_PATH := "res://labs/combat_lab/poison_basic_human_v2/assets/atlas/poison_basic_contact_08_rgba.png"
const CHARGE_CELL := Vector2(192,192)
const FLIGHT_CELL := Vector2(288,160)
const IMPACT_CELL := Vector2(256,256)
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed := 0.0
var paused := false
var charge_frames: Array[AtlasTexture] = []
var flight_frames: Array[AtlasTexture] = []
var impact_frames: Array[AtlasTexture] = []

static func monster_foot(t:float)->Vector2:
    return BASE_FOOT+Vector2(48.0*sin(t*1.7+0.4),12.0*cos(t*.92+.42))

static func monster_chest(t:float)->Vector2:
    return monster_foot(t)+Vector2(-5.0,-78.0)

static func projectile_angle(from:Vector2,to:Vector2)->float:
    var d:=to-from
    return 0.0 if d.length_squared()<0.000001 else d.angle()

static func visual_flight_at(t:float,from:Vector2,to:Vector2)->Vector2:
    var q:=clampf((t-CAST_END)/(DEMO_CONTACT-CAST_END),0.0,1.0)
    return from.lerp(to,q)

static func phase_at(t:float)->String:
    if t<CAST_END:return "charge"
    if t<DEMO_CONTACT:return "flight"
    if t<IMPACT_END:return "contact"
    return "idle"

func _frame(tex:Texture2D,i:int,cell:Vector2)->AtlasTexture:
    var a:=AtlasTexture.new()
    a.atlas=tex
    a.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    a.filter_clip=true
    return a

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for p in [CHARGE_PATH,FLIGHT_PATH,IMPACT_PATH]:
        if not ResourceLoader.exists(p):
            push_error("POISON_BASIC_R2_MISSING_ORIGINAL_RGBA "+p)
            set_process(false)
            return
    var a:=load(CHARGE_PATH) as Texture2D
    var b:=load(FLIGHT_PATH) as Texture2D
    var c:=load(IMPACT_PATH) as Texture2D
    if a==null or b==null or c==null or a.get_size()!=Vector2(768,384) or b.get_size()!=Vector2(1152,320) or c.get_size()!=Vector2(1024,512):
        push_error("POISON_BASIC_R2_BAD_ATLAS_DIMENSIONS")
        set_process(false)
        return
    for i in range(6):charge_frames.append(_frame(a,i,CHARGE_CELL))
    for i in range(8):
        flight_frames.append(_frame(b,i,FLIGHT_CELL))
        impact_frames.append(_frame(c,i,IMPACT_CELL))
    set_process(true)
    print("VFX_POISON_BASIC_R2_READY source=true_rgba_painted gif_pixels=none charge=6 flight=8 contact=8 moving_target=true damage_single_only=true")
    queue_redraw()

func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        if e.keycode==KEY_P:paused=not paused

func _paint(tex:Texture2D,pos:Vector2,size:Vector2,alpha:float)->void:
    if alpha<.001:return
    draw_texture_rect(tex,Rect2(pos-size*.5,size),false,Color(1,1,1,alpha))

func _flip(frames:Array[AtlasTexture],pos:Vector2,size:Vector2,index:float,alpha:float)->void:
    var low:=clampi(int(floor(index)),0,frames.size()-1)
    var high:=mini(low+1,frames.size()-1)
    var a:=smoothstep(0.0,1.0,clampf(index-float(low),0.0,1.0))
    _paint(frames[low],pos,size,alpha*(1.0-a))
    if low!=high:_paint(frames[high],pos,size,alpha*a)

func _draw_monster(t:float)->void:
    var total:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15.0)%maxi(1,total))
    _paint(tex,monster_foot(t)-Vector2(0,69.5),Vector2(152,139),1.0)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=6 or flight_frames.size()!=8 or impact_frames.size()!=8:return
    if t<CAST_END+.03:
        var appear:=smoothstep(0.0,.045,t)
        var depart:=1.0-smoothstep(CAST_END-.03,CAST_END+.03,t)
        _flip(charge_frames,PALM,Vector2(155,155),clampf(t/CAST_END*5.0,0.0,5.0),appear*depart)
    if t>=CAST_END and t<DEMO_CONTACT+.02:
        var q:=clampf((t-CAST_END)/(DEMO_CONTACT-CAST_END),0.0,1.0)
        var opacity:=1.0-smoothstep(DEMO_CONTACT-.025,DEMO_CONTACT+.02,t)
        var center:=visual_flight_at(t,PALM,monster_chest(t))
        var angle:=projectile_angle(PALM,monster_chest(t))
        draw_set_transform(center,angle,Vector2.ONE)
        _flip(flight_frames,Vector2(-11,0),Vector2(250,145),q*7.0,opacity*.27)
        _flip(flight_frames,Vector2.ZERO,Vector2(275,160),q*7.0,opacity*.95)
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
    # The actor is the pre-existing game sprite fixture, never a generated GIF character.
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384))
    _draw_monster(t)
    if t>=DEMO_CONTACT and t<IMPACT_END:
        var q:=clampf((t-DEMO_CONTACT)/(IMPACT_END-DEMO_CONTACT),0.0,1.0)
        var strength:=smoothstep(0.0,.17,q)*(1.0-smoothstep(.61,1.0,q))
        _flip(impact_frames,monster_chest(t)+Vector2(0,16),Vector2(206,206),q*7.0,strength*.98)
