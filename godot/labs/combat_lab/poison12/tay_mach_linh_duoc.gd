extends Control
## POI12 Human: Tẩy Mạch Linh Dược — DAMAGE single-target Mộc; not heal!
## First-party code-painted raster atlas, VIEW ONLY, three moving-demo stages.
const SKILL_ID := "tmb.skill.poison.duoc_doc.active_01.human"
const EFFECT := "damage"
const ELEMENT := "wood"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST := 0.45
const DECLARED_COOLDOWN := 8.0
const DECLARED_RANGE := 7.5
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_DAMAGE_RATIO := 1.35
const DECLARED_DURATION := 0.0
const CAST_END := 0.45
const DEMO_CONTACT := 0.98
const IMPACT_END := 1.65
const LOOP_SECONDS := 2.30
const PALM := Vector2(342.0,426.0)
const CASTER := Vector2(273.0,540.0)
const BASE_FOOT := Vector2(997.0,563.0)
const CHARGE_PATH := "res://labs/combat_lab/poison12/assets/poi12_charge_08_r2.png"
const FLIGHT_PATH := "res://labs/combat_lab/poison12/assets/poi12_flight_12_r2.png"
const IMPACT_PATH := "res://labs/combat_lab/poison12/assets/poi12_contact_10_r2.png"
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

static func monster_foot(t: float)->Vector2:
    return BASE_FOOT+Vector2(39.0*sin(t*1.15+.30),11.0*cos(t*.92+.42))

static func monster_chest(t:float)->Vector2:
    return monster_foot(t)+Vector2(-5.0,-79.0)

static func demo_flight_at(t:float)->Vector2:
    # Visual lock to ONE walking demo monster; not target acquisition or hit authority.
    var q:=clampf((t-CAST_END)/(DEMO_CONTACT-CAST_END),0.0,1.0)
    return PALM.lerp(monster_chest(t),q)

static func phase_at(t:float)->String:
    if t<CAST_END:return "medicinal_charge"
    if t<DEMO_CONTACT:return "one_elixir_projectile"
    if t<IMPACT_END:return "botanical_local_impact"
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
            push_error("POI12_MISSING_ALPHA: "+p)
            set_process(false)
            return
    var a:=load(CHARGE_PATH) as Texture2D
    var b:=load(FLIGHT_PATH) as Texture2D
    var c:=load(IMPACT_PATH) as Texture2D
    if a==null or b==null or c==null or a.get_size()!=Vector2(768,384) or b.get_size()!=Vector2(1152,480) or c.get_size()!=Vector2(1024,768):
        push_error("POI12_BAD_ATLAS_GEOMETRY")
        set_process(false)
        return
    for i in range(8):charge_frames.append(_frame(a,i,CHARGE_CELL))
    for i in range(12):flight_frames.append(_frame(b,i,FLIGHT_CELL))
    for i in range(10):impact_frames.append(_frame(c,i,IMPACT_CELL))
    set_process(true)
    print("VFX_POI12_R1_READY revision=r2_cured_flat_polygon original_code_painted=true charge=8 flight=12 impact=10 damage_only=true moving_monster=true")
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
        if e.keycode==KEY_P:
            paused=not paused

func _paint(tex:Texture2D,pos:Vector2,size:Vector2,alpha:float)->void:
    if alpha<=0.001:return
    draw_texture_rect(tex,Rect2(pos-size*.5,size),false,Color(1,1,1,alpha))

func _flip(frames:Array[AtlasTexture],pos:Vector2,size:Vector2,index:float,alpha:float)->void:
    var lo:=clampi(int(floor(index)),0,frames.size()-1)
    var hi:=mini(lo+1,frames.size()-1)
    var u:=smoothstep(0.0,1.0,clampf(index-float(lo),0.0,1.0))
    _paint(frames[lo],pos,size,alpha*(1.0-u))
    if lo!=hi:_paint(frames[hi],pos,size,alpha*u)

func _draw_monster(t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15.0)%maxi(n,1))
    _paint(tex,monster_foot(t)-Vector2(0,69.5),Vector2(152,139),1.0)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=8 or flight_frames.size()!=12 or impact_frames.size()!=10:return
    if t<CAST_END+.07:
        var appear:=smoothstep(0.015,.15,t)
        var depart:=1.0-smoothstep(CAST_END-.02,CAST_END+.07,t)
        var i:=clampf(t/CAST_END*7.0,0.0,7.0)
        _flip(charge_frames,PALM,Vector2(242,219),i,appear*depart*.95)
    if t>=CAST_END and t<DEMO_CONTACT+.03:
        var q:=clampf((t-CAST_END)/(DEMO_CONTACT-CAST_END),0.0,1.0)
        var out:=1.0-smoothstep(DEMO_CONTACT-.045,DEMO_CONTACT+.03,t)
        var pos:=demo_flight_at(t)
        _flip(flight_frames,pos-Vector2(22,0),Vector2(253,161),q*11.0,out*.23)
        _flip(flight_frames,pos,Vector2(350,214),q*11.0,out*.93)
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384))
    _draw_monster(t)
    if t>=DEMO_CONTACT and t<IMPACT_END:
        var q:=clampf((t-DEMO_CONTACT)/(IMPACT_END-DEMO_CONTACT),0.0,1.0)
        var strength:=smoothstep(0.0,.11,q)*(1.0-smoothstep(.48,1.0,q))
        # Local head-clear botanical light follows the same single moving dummy.
        _flip(impact_frames,monster_chest(t)+Vector2(0,18),Vector2(316,304),q*9.0,strength*.88)
