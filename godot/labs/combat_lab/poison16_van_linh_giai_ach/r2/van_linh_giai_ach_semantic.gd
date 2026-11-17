extends Control
## POI16 Vạn Linh Giải Ách — ultimate 3-ally area HEAL visualization only.
## Canonical combat remains unchanged, no HP receipts or persistent status.
const SKILL_ID := "tmb.skill.poison.duoc_doc.ultimate.human"
const EFFECT := "heal"
const ELEMENT := "wood"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RANGE := 6.5
const DECLARED_RADIUS := 2.5
const DECLARED_CAST := 1.2
const DECLARED_COOLDOWN := 46.0
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DURATION := 0.0
const DECLARED_DAMAGE_RATIO := 0.05
const DECLARED_POWER := 0.16
const CAST_END := 1.20
const BLOOM_PEAK := 1.63
const DEMO_RESOLVE := 1.75
const BLESSING_START := 1.51
const BLESSING_END := 2.23
const FADE_START := 2.07
const FADE_END := 2.65
const LOOP_SECONDS := 2.95
const PALM := Vector2(338,421)
const CASTER_FOOT := Vector2(290,551)
const AOE_CENTER := Vector2(860,521)
const LAB_RADIUS_PX := 205.0 # VFX FIXTURE: WORLD RADIUS 2.5 IS NOT PIXELS
const MONSTER_BASE := Vector2(480,552)
const ALLY_BASE_POSITIONS := [
    Vector2(702,552), Vector2(856,543), Vector2(1013,553), Vector2(1220,552)
]
const ASSET_ROOT := "res://labs/combat_lab/poison16_van_linh_giai_ach/r2/assets/"
const HERB_CORE := Vector2(859,348)
const STREAM_START := 1.39
const STREAM_END := 2.12
const SEAL_START := 1.64
const SEAL_END := 2.29
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed := 0.0
var paused := false
var seed_frames: Array[AtlasTexture] = []
var herb_frames: Array[AtlasTexture] = []
var stream_frames: Array[AtlasTexture] = []
var seal_frames: Array[AtlasTexture] = []
var fade_frames: Array[AtlasTexture] = []

static func ally_foot(i:int,t:float)->Vector2:
    var index:=clampi(i,0,ALLY_BASE_POSITIONS.size()-1)
    var base:Vector2=ALLY_BASE_POSITIONS[index]
    return base+Vector2(11.0*t+5.0*sin(t*2.1+float(index)*.77),
                        (7.0+float(index))*cos(t*.84+float(index)*.59))

static func ally_chest(i:int,t:float)->Vector2:
    return ally_foot(i,t)+Vector2(0,-99)

static func monster_foot(t:float)->Vector2:
    return MONSTER_BASE+Vector2(31*sin(1.22*t+.3),7*cos(t*.97))

static func lab_within_visual_area(pos:Vector2)->bool:
    return pos.distance_to(AOE_CENTER)<=LAB_RADIUS_PX

static func selected_demo_allies(t:float)->Array[int]:
    # Lab fixture only. Real world->pixel AOE is owned by actual Combat V2.
    var selected:Array[int]=[]
    for i in range(ALLY_BASE_POSITIONS.size()):
        if lab_within_visual_area(ally_foot(i,t)) and selected.size()<TARGET_LIMIT:
            selected.append(i)
    return selected

static func phase_at(t:float)->String:
    if t<CAST_END:return "charge"
    if t<DEMO_RESOLVE:return "bloom"
    if t<FADE_START:return "ally_blessing"
    if t<FADE_END:return "fade"
    return "idle"

static func active_cosmetic_heal(t:float)->bool:
    return t>=DEMO_RESOLVE and t<FADE_START

static func field_alpha(t:float)->float:
    if t<CAST_END or t>FADE_START:return 0.0
    return smoothstep(CAST_END,CAST_END+.18,t)*(1.0-smoothstep(FADE_START-.25,FADE_START,t))

func _atlas(tex:Texture2D,i:int,cell:Vector2)->AtlasTexture:
    var f:=AtlasTexture.new()
    f.atlas=tex
    f.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    f.filter_clip=true
    return f

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for row in [["seed",8,Vector2(192,192),Vector2(768,384)],
                ["herb",12,Vector2(384,320),Vector2(1536,960)],
                ["stream",10,Vector2(384,128),Vector2(1536,384)],
                ["seal",10,Vector2(128,128),Vector2(512,384)],
                ["fade",8,Vector2(256,224),Vector2(1024,448)]]:
        var path:String=ASSET_ROOT+"poi16_r2_"+String(row[0])+"_"+("%02d"%int(row[1]))+".png"
        if not ResourceLoader.exists(path):
            push_error("POI16_R2_MISSING_SEMANTIC_RGBA "+path)
            set_process(false)
            return
        var tex:=load(path) as Texture2D
        if tex==null or tex.get_size()!=row[3]:
            push_error("POI16_R2_BAD_SEMANTIC_ATLAS "+path)
            set_process(false)
            return
        for j in range(int(row[1])):
            var f:=_atlas(tex,j,row[2])
            match String(row[0]):
                "seed":seed_frames.append(f)
                "herb":herb_frames.append(f)
                "stream":stream_frames.append(f)
                "seal":seal_frames.append(f)
                "fade":fade_frames.append(f)
    set_process(true)
    print("POI16_SEMANTIC_R2_READY heal_circle_threefold_leaves=true independent_transferring_streams=3 medicinal_seals=3 moving_allies=true outside_ally_unaffected=true rgba_poses=48 no_gif=true no_rig=true")
    queue_redraw()

func _process(dt:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0.0,dt),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        if e.keycode==KEY_P:paused=not paused

func _paint(tex:Texture2D,center:Vector2,sz:Vector2,opacity:float)->void:
    if opacity<=.0005:return
    draw_texture_rect(tex,Rect2(center-sz*.5,sz),false,Color(1,1,1,opacity))

func _flip(frames:Array[AtlasTexture],center:Vector2,sz:Vector2,idx:float,opacity:float)->void:
    var lo:=clampi(int(floor(idx)),0,frames.size()-1)
    var hi:=mini(lo+1,frames.size()-1)
    var a:=smoothstep(0.0,1.0,clampf(idx-float(lo),0.0,1.0))
    _paint(frames[lo],center,sz,opacity*(1.0-a))
    if hi!=lo:_paint(frames[hi],center,sz,opacity*a)

func _draw_disciple(foot:Vector2)->void:
    draw_texture_rect_region(DISCIPLE_ART,
        Rect2(foot-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384))

func _draw_monster(t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15.0)%maxi(n,1))
    _paint(tex,monster_foot(t)-Vector2(0,69.5),Vector2(152,139),.98)


# Semantic recognizable output: one medicine-heart -> three real spatial links
# (not screen decoration) -> exactly three target-attached herb seals.
static func semantic_targets(t:float)->Array[Vector2]:
    var pts:Array[Vector2]=[]
    for i in selected_demo_allies(t):
        pts.append(ally_chest(i,t)+Vector2(0,-12))
    return pts

static func link_length(i:int,t:float)->float:
    return HERB_CORE.distance_to(ally_chest(i,t)+Vector2(0,-12))

static func semantic_phase_at(t:float)->String:
    if t<CAST_END:return "medicine_seed"
    if t<STREAM_START:return "three_leaf_herb"
    if t<SEAL_START:return "three_healing_links"
    if t<SEAL_END:return "three_herbal_seals"
    if t<FADE_END:return "energy_dissolves"
    return "clear"

func _draw_live_link(origin:Vector2,target:Vector2,index:float,opacity:float)->void:
    if opacity<.002:return
    var delta:=target-origin
    var distance:=delta.length()
    if distance<8.0:return
    # The source light stream is a real 384x128 original RGBA atlas sprite.
    # A per-target CanvasItem transform connects the origin to a MOVING chest.
    draw_set_transform(origin,delta.angle(),Vector2(distance/384.0,0.70))
    _flip(stream_frames,Vector2(192,0),Vector2(384,128),index,opacity)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if seed_frames.size()!=8 or herb_frames.size()!=12 or stream_frames.size()!=10 or seal_frames.size()!=10 or fade_frames.size()!=8:return
    _draw_disciple(CASTER_FOOT)
    _draw_monster(t)
    var chosen:Array[int]=selected_demo_allies(t)
    # True luminous three-leaf spiritual herb at medicine altar.
    # Source petal silhouettes live in RGBA; no GUI flower or line is drawn.
    if t>=CAST_END and t<FADE_START:
        var herb_q:=clampf((t-CAST_END)/(FADE_START-CAST_END),0.0,1.0)
        var herb_alpha:=smoothstep(CAST_END,CAST_END+.13,t)*(1.0-smoothstep(FADE_START-.22,FADE_START,t))
        _flip(herb_frames,HERB_CORE,Vector2(460,379),herb_q*11.0,herb_alpha*.99)
    # Three moving silk-energy streams are transformed and endpoint-locked.
    if t>=STREAM_START and t<STREAM_END:
        var stream_q:=clampf((t-STREAM_START)/(STREAM_END-STREAM_START),0.0,1.0)
        var stream_alpha:=smoothstep(0.0,.12,stream_q)*(1.0-smoothstep(.85,1.0,stream_q))
        for i in chosen:
            _draw_live_link(HERB_CORE,ally_chest(i,t)+Vector2(0,-12),stream_q*9.0,stream_alpha*.99)
    # Three different recipient centers, all moving. No 4th / enemy link.
    if t>=SEAL_START and t<SEAL_END:
        var seal_q:=clampf((t-SEAL_START)/(SEAL_END-SEAL_START),0.0,1.0)
        var seal_alpha:=smoothstep(0.0,.15,seal_q)*(1.0-smoothstep(.80,1.0,seal_q))
        for i in chosen:
            _flip(seal_frames,ally_chest(i,t)+Vector2(0,-14),Vector2(147,156),seal_q*9.0,seal_alpha*.48)
    if t>=FADE_START and t<FADE_END:
        var fade_q:=clampf((t-FADE_START)/(FADE_END-FADE_START),0.0,1.0)
        var fade_alpha:=smoothstep(0.0,.12,fade_q)*(1.0-smoothstep(.55,1.0,fade_q))
        _flip(fade_frames,HERB_CORE,Vector2(432,353),fade_q*7.0,fade_alpha*.62)
    # Original approved frozen actor art between back bloom and front seal.
    for i in range(ALLY_BASE_POSITIONS.size()):
        _draw_disciple(ally_foot(i,t))
    if t<CAST_END+.05:
        var charge_alpha:=smoothstep(.02,.19,t)*(1.0-smoothstep(CAST_END-.07,CAST_END+.05,t))
        _flip(seed_frames,PALM,Vector2(200,199),clampf(t/CAST_END*7.0,0.0,7.0),charge_alpha*.99)
    if t>=SEAL_START and t<SEAL_END:
        var q:=clampf((t-SEAL_START)/(SEAL_END-SEAL_START),0.0,1.0)
        var alpha:=smoothstep(0.0,.14,q)*(1.0-smoothstep(.80,1.0,q))
        for i in chosen:
            _flip(seal_frames,ally_chest(i,t)+Vector2(0,-14),Vector2(99,115),q*9.0,alpha*.96)
    if t>=FADE_START and t<FADE_END:
        var q2:=clampf((t-FADE_START)/(FADE_END-FADE_START),0.0,1.0)
        var end_alpha:=smoothstep(0.0,.09,q2)*(1.0-smoothstep(.52,1.0,q2))
        for i in chosen:
            _flip(fade_frames,ally_chest(i,t)+Vector2(0,-22),Vector2(183,174),q2*7.0,end_alpha*.80)
