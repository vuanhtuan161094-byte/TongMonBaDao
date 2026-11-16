extends Control
## POI10 – Doc Khi Phe Tam Human. Source-painted expanding venom light / localized 6s cosmetic mark.
## An isolated visual lab: this script NEVER applies status or damage. No rig.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_04.human"
const ELEMENT := "nether"
const EFFECT := "poison"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RADIUS := 2.6
const DECLARED_RANGE := 7.0
const DECLARED_CAST := 0.65
const DECLARED_COOLDOWN := 12.0
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_DURATION := 6.0
const DECLARED_POISON_STACKS := 1
const DECLARED_DAMAGE_RATIO := 0.9
const CAST_END := 0.65
const AREA_ARRIVE := 1.30
const FIRST_HIT := 1.47
const HIT_SPACING := 0.11
const LOCAL_CONTACT := 0.43
const FADE_DURATION := 0.35
const LOOP_SECONDS := 8.55
const PALM := Vector2(341,426)
const CASTER := Vector2(270,540)
const AREA_CENTER := Vector2(1023,520)
const CHARGE_PATH := "res://labs/combat_lab/poison10/r1_painted/assets/devour_charge_r1_12.png"
const CORONA_PATH := "res://labs/combat_lab/poison10/r1_painted/assets/devour_corona_r1_12.png"
const CONTACT_PATH := "res://labs/combat_lab/poison10/r1_painted/assets/devour_contact_r1_10.png"
const MARK_PATH := "res://labs/combat_lab/poison10/r1_painted/assets/devour_mark_r1_12.png"
const CHARGE_CELL := Vector2(224,192)
const CORONA_CELL := Vector2(224,224)
const CONTACT_CELL := Vector2(192,160)
const MARK_CELL := Vector2(160,160)
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
var elapsed := 0.0
var paused := false
var charge_frames: Array[AtlasTexture] = []
var corona_frames: Array[AtlasTexture] = []
var contact_frames: Array[AtlasTexture] = []
var mark_frames: Array[AtlasTexture] = []

static func target_at(i: int,t: float) -> Vector2:
    # Deterministic moving stand-ins are LAB props, never actual PvE targeting.
    var base := Vector2(895.0,490.0)
    if i==1: base=Vector2(1032.0,548.0)
    if i==2: base=Vector2(1160.0,604.0)
    var phase := float(i)*1.7
    return base+Vector2(11.0*sin(t*.90+phase),7.0*cos(t*1.12+phase))

static func chest_at(i: int,t: float) -> Vector2:
    return target_at(i,t)+Vector2(0,-40)

static func hit_time(i: int) -> float:
    return FIRST_HIT+HIT_SPACING*float(i)

static func pulse_at(t: float) -> Vector2:
    # Single primary energy wave from the palm to a point in the three-victim area.
    var f := clampf((t-CAST_END)/(AREA_ARRIVE-CAST_END),0,1)
    return PALM.lerp(AREA_CENTER,f)

static func mark_alpha_at(i: int,t: float) -> float:
    var contact := hit_time(i)
    var ending := contact+DECLARED_DURATION
    if t<contact or t>=ending+FADE_DURATION:return 0.0
    return smoothstep(contact,contact+.085,t)*(1.0-smoothstep(ending,ending+FADE_DURATION,t))

static func phase_at(t: float) -> String:
    if t<CAST_END:return "venom_charge"
    if t<AREA_ARRIVE:return "expanding_toxic_wave_flight"
    if t<hit_time(2)+LOCAL_CONTACT:return "three_local_contacts"
    if t<hit_time(2)+DECLARED_DURATION:return "one_6s_mark_each"
    if t<hit_time(2)+DECLARED_DURATION+FADE_DURATION:return "mark_fade"
    return "idle"

static func charge_frame(t: float) -> float:
    return clampf(t/CAST_END*11,0,11)

static func corona_frame(t: float) -> float:
    return clampf((t-AREA_ARRIVE)/.88*11,0,11)

static func contact_frame(i: int,t: float) -> float:
    return clampf((t-hit_time(i))/LOCAL_CONTACT*9,0,9)

static func mark_frame(i: int,t: float) -> float:
    # Moving artwork pulse is COSMETIC only; not six fake status receipts.
    return fposmod((t-hit_time(i))*2.2+float(i)*1.5,12.0)

func _frame(tex: Texture2D,i: int,cell: Vector2) -> AtlasTexture:
    var atlas:=AtlasTexture.new()
    atlas.atlas=tex
    atlas.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    atlas.filter_clip=true
    return atlas

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for path in [CHARGE_PATH,CORONA_PATH,CONTACT_PATH,MARK_PATH]:
        if not ResourceLoader.exists(path):
            push_error("POI10_ASSET_MISSING: "+path)
            set_process(false)
            return
    var a:=load(CHARGE_PATH) as Texture2D
    var b:=load(CORONA_PATH) as Texture2D
    var c:=load(CONTACT_PATH) as Texture2D
    var d:=load(MARK_PATH) as Texture2D
    if a==null or b==null or c==null or d==null:
        push_error("POI10_TEXTURE_LOAD_ERROR")
        set_process(false)
        return
    if a.get_size()!=Vector2(896,576) or b.get_size()!=Vector2(896,672) or c.get_size()!=Vector2(768,480) or d.get_size()!=Vector2(640,480):
        push_error("POI10_TEXTURE_DIMENSIONS_INVALID")
        set_process(false)
        return
    for i in range(12):
        charge_frames.append(_frame(a,i,CHARGE_CELL))
        corona_frames.append(_frame(b,i,CORONA_CELL))
        mark_frames.append(_frame(d,i,MARK_CELL))
    for i in range(10):
        contact_frames.append(_frame(c,i,CONTACT_CELL))
    set_process(true)
    print("VFX_POI10_R1_READY charge=12 corona=12 contact=10 mark=12 cap=3 moving=true painterly=true view_only=true")
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

func _paint(tex: Texture2D,at: Vector2,scale: float,alpha: float,angle: float=0.0) -> void:
    if alpha<=0.001:return
    draw_set_transform(at,angle,Vector2.ONE*scale)
    var size:=tex.get_size()
    draw_texture_rect(tex,Rect2(-size*.5,size),false,Color(1,1,1,alpha))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _flip(frames: Array[AtlasTexture],pos: Vector2,scale: float,alpha: float,index: float,angle: float=0.0) -> void:
    var j:=clampi(int(floor(index)),0,frames.size()-1)
    var k:=mini(j+1,frames.size()-1)
    var t:=smoothstep(0,1,clampf(index-float(j),0,1))
    _paint(frames[j],pos,scale,alpha*(1.0-t),angle)
    if k!=j:_paint(frames[k],pos,scale,alpha*t,angle)

func _actor(pos: Vector2,scale: float,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,Rect2(pos-Vector2(160,351)*scale,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _draw() -> void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=12 or corona_frames.size()!=12 or contact_frames.size()!=10 or mark_frames.size()!=12:return
    var t:=elapsed
    if t<CAST_END:
        var rise:=smoothstep(.02,.52,t)
        _flip(charge_frames,PALM-Vector2(7,0),.95,rise,charge_frame(t))
    if t>=CAST_END and t<AREA_ARRIVE:
        var f:=clampf((t-CAST_END)/(AREA_ARRIVE-CAST_END),0,1)
        _flip(charge_frames,pulse_at(t),.66+.22*f,.95,charge_frame(CAST_END))
        _flip(charge_frames,PALM.lerp(AREA_CENTER,maxf(0.0,f-.08)),.54,.15,charge_frame(CAST_END))
    # Ground/area level shadow of irregular radial corona, behind the moving characters.
    if t>=AREA_ARRIVE and t<2.23:
        var rise:=smoothstep(AREA_ARRIVE,AREA_ARRIVE+.10,t)
        var fall:=1.0-smoothstep(1.84,2.23,t)
        _flip(corona_frames,AREA_CENTER+Vector2(0,63),1.55,rise*fall*.45,corona_frame(t))
    _actor(CASTER,.47,Color.WHITE)
    for i in range(TARGET_LIMIT):
        var body:=target_at(i,t)
        var alpha:=mark_alpha_at(i,t)
        if alpha>0:
            _flip(mark_frames,chest_at(i,t)+Vector2(0,9),.70,alpha*.17,mark_frame(i,t))
        _actor(body,.41,Color("d9d1de") if i!=1 else Color("c4d0d8"))
        if alpha>0:
            _flip(mark_frames,chest_at(i,t)+Vector2(0,9),.72,alpha*.73,mark_frame(i,t))
        var h:=hit_time(i)
        if t>=h and t<h+LOCAL_CONTACT:
            var bright:=smoothstep(h,h+.045,t)*(1.0-smoothstep(h+.19,h+LOCAL_CONTACT,t))
            _flip(contact_frames,chest_at(i,t),.79,bright*.98,contact_frame(i,t))
    # One bright poison devour bloom remains center-biased, is short, and cannot obscure faces forever.
    if t>=AREA_ARRIVE and t<2.20:
        var rise:=smoothstep(AREA_ARRIVE,AREA_ARRIVE+.06,t)
        var fall:=1.0-smoothstep(1.69,2.20,t)
        _flip(corona_frames,AREA_CENTER+Vector2(0,18),.84,rise*fall*.54,corona_frame(t))