extends Control
## POI10 R2 — new first-party painted crimson-violet/jade poison-flower energy.
## Separate attack VFX from ONE shared icon indicating poisoned state; LAB VIEW ONLY.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_04.human"
const EFFECT := "poison"
const ELEMENT := "nether"
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
const BLOOM_START := 1.26  # LAB visual arrival, NOT a Combat V2 hit receipt.
const FIRST_CONTACT := 1.51 # LAB synthetic point-in-time, NOT authoritative.
const CONTACT_GAP := 0.08
const CONTACT_VISUAL_SECONDS := 0.32
const BLOOM_END := 2.32
const LOOP_SECONDS := 8.55
const PALM := Vector2(341,426)
const CASTER := Vector2(273,540)
const AREA_CENTER := Vector2(1005,534)
const CHARGE_PATH := "res://labs/combat_lab/poison10/r2_remake/assets/poison10_r2_charge_10.png"
const BLOOM_PATH := "res://labs/combat_lab/poison10/r2_remake/assets/poison10_r2_bloom_12.png"
const CONTACT_PATH := "res://labs/combat_lab/poison10/r2_remake/assets/poison10_r2_contact_08.png"
const CHARGE_CELL := Vector2(192,192)
const BLOOM_CELL := Vector2(384,256)
const CONTACT_CELL := Vector2(192,160)
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const PoisonBadge = preload("res://labs/combat_lab/shared_poison_status/poison_status_badge.gd")
var elapsed := 0.0
var paused := false
var charge_frames: Array[AtlasTexture] = []
var bloom_frames: Array[AtlasTexture] = []
var contact_frames: Array[AtlasTexture] = []

static func monster_foot(index: int, t: float) -> Vector2:
    var base := Vector2(862,535)
    if index==1: base=Vector2(1020,555)
    if index==2: base=Vector2(1164,587)
    return base+Vector2(21*sin(t*.86+float(index)*1.07),12*cos(t*1.04+float(index)*1.24))

static func monster_chest(index: int, t: float) -> Vector2:
    return monster_foot(index,t)+Vector2(-5,-79)

static func poison_badge_anchor(index: int, t: float) -> Vector2:
    return monster_foot(index,t)+Vector2(-5,-127)

static func mock_contact_time(index: int) -> float:
    return FIRST_CONTACT + float(index)*CONTACT_GAP

static func demo_status_remaining(index: int,t: float) -> float:
    var contact := mock_contact_time(index)
    if t<contact:return 0.0
    return maxf(0.0,DECLARED_DURATION-(t-contact))

static func charge_index_at(t: float) -> float:
    return clampf(t/CAST_END*9.0,0,9)

static func bloom_index_at(t: float) -> float:
    return clampf((t-BLOOM_START)/(BLOOM_END-BLOOM_START)*11,0,11)

static func contact_index_at(index: int,t: float) -> float:
    return clampf((t-mock_contact_time(index))/CONTACT_VISUAL_SECONDS*7,0,7)

static func demo_flight_at(t: float) -> Vector2:
    # One cosmetic bud carried into the predefined demo area; no target logic.
    return PALM.lerp(AREA_CENTER,clampf((t-CAST_END)/(BLOOM_START-CAST_END),0,1))

static func phase_at(t: float) -> String:
    if t<CAST_END:return "seed_charge"
    if t<BLOOM_START:return "one_cosmetic_bud_flight"
    if t<FIRST_CONTACT:return "poison_lotus_peak"
    if t<BLOOM_END:return "local_contacts"
    if t<mock_contact_time(2)+DECLARED_DURATION:return "shared_status_badges"
    return "idle"

func _atlas_frame(tex: Texture2D,i: int,cell: Vector2) -> AtlasTexture:
    var frame := AtlasTexture.new()
    frame.atlas=tex
    frame.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    frame.filter_clip=true
    return frame

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for path in [CHARGE_PATH,BLOOM_PATH,CONTACT_PATH,PoisonBadge.ICON_PATH]:
        if not ResourceLoader.exists(path):
            push_error("POI10_R2_MISSING_ALPHA_ATLAS: "+path)
            set_process(false)
            return
    var c := load(CHARGE_PATH) as Texture2D
    var b := load(BLOOM_PATH) as Texture2D
    var h := load(CONTACT_PATH) as Texture2D
    if c==null or b==null or h==null or c.get_size()!=Vector2(768,576) or b.get_size()!=Vector2(1536,768) or h.get_size()!=Vector2(768,320):
        push_error("POI10_R2_ATLAS_IMPORT_INVALID")
        set_process(false)
        return
    for i in range(10):charge_frames.append(_atlas_frame(c,i,CHARGE_CELL))
    for i in range(12):bloom_frames.append(_atlas_frame(b,i,BLOOM_CELL))
    for i in range(8):contact_frames.append(_atlas_frame(h,i,CONTACT_CELL))
    set_process(true)
    print("VFX_POI10_R2_READY art=FIRST_PARTY_PAINTED charge=10 bloom=12 contact=8 shared_poison_badge=true monsters=3 moving=true gameplay=false")
    queue_redraw()

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0),LOOP_SECONDS)
    queue_redraw()

func _draw_frame(tex: Texture2D, pos: Vector2, size: Vector2, opacity: float) -> void:
    if opacity<=0.002:return
    draw_texture_rect(tex,Rect2(pos-size*.5,size),false,Color(1,1,1,opacity))

func _draw_flipbook(frames: Array[AtlasTexture],pos: Vector2, size: Vector2,index: float,opacity: float)->void:
    var i:=clampi(int(floor(index)),0,frames.size()-1)
    var j:=mini(i+1,frames.size()-1)
    var q:=smoothstep(0,1,clampf(index-float(i),0,1))
    _draw_frame(frames[i],pos,size,opacity*(1-q))
    if i!=j:_draw_frame(frames[j],pos,size,opacity*q)

func _draw_monster(index:int,t:float)->void:
    var count:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",(int(t*15)+index*3)%maxi(1,count))
    _draw_frame(tex,monster_foot(index,t)-Vector2(0,69.5),Vector2(152,139),1)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=10 or bloom_frames.size()!=12 or contact_frames.size()!=8:return
    # One independent bud, rich painted material rather than line-drawn rings.
    if t<CAST_END:
        var gain:=smoothstep(0.03,.40,t)
        _draw_flipbook(charge_frames,PALM,Vector2(176,176),charge_index_at(t),gain*.95)
    if t>=CAST_END and t<BLOOM_START:
        _draw_flipbook(charge_frames,demo_flight_at(t),Vector2(150,150),9.0,.93)
    # Painted lotus unfurls behind targets; no 6-second large bloom or extra status silhouettes.
    if t>=BLOOM_START and t<BLOOM_END:
        var fade:=1.0-smoothstep(1.85,BLOOM_END,t)
        _draw_flipbook(bloom_frames,AREA_CENTER+Vector2(0,-64),Vector2(500,342),bloom_index_at(t),fade*.97)
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384))
    for i in range(TARGET_LIMIT):
        _draw_monster(i,t)
        var moment:=mock_contact_time(i)
        if t>=moment and t<moment+CONTACT_VISUAL_SECONDS:
            var alpha:=smoothstep(moment,moment+.035,t)*(1.0-smoothstep(moment+.15,moment+CONTACT_VISUAL_SECONDS,t))
            _draw_flipbook(contact_frames,monster_chest(i,t),Vector2(112,94),contact_index_at(i,t),alpha)
        # ONE small reusable visual marker per poisoned target, driven here by simulated demo state.
        PoisonBadge.draw_for(self,poison_badge_anchor(i,t),DECLARED_POISON_STACKS,demo_status_remaining(i,t),t)