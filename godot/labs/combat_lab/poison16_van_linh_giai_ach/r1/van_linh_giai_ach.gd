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
const BLOOM_PEAK := 1.53
const DEMO_RESOLVE := 1.75
const BLESSING_START := 1.45
const BLESSING_END := 2.19
const FADE_START := 2.04
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
const ASSET_ROOT := "res://labs/combat_lab/poison16_van_linh_giai_ach/r1/assets/"
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed := 0.0
var paused := false
var charge_frames: Array[AtlasTexture] = []
var bloom_frames: Array[AtlasTexture] = []
var blessing_frames: Array[AtlasTexture] = []
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
    for row in [["charge",8,Vector2(192,192),Vector2(768,384)],
                ["bloom",12,Vector2(384,320),Vector2(1536,960)],
                ["blessing",10,Vector2(192,192),Vector2(768,576)],
                ["fade",8,Vector2(256,224),Vector2(1024,448)]]:
        var path:String=ASSET_ROOT+"poi16_"+String(row[0])+"_"+("%02d"%int(row[1]))+".png"
        if not ResourceLoader.exists(path):
            push_error("POI16_MISSING_TRUE_ALPHA "+path)
            set_process(false)
            return
        var tex:=load(path) as Texture2D
        if tex==null or tex.get_size()!=row[3]:
            push_error("POI16_BAD_RGBA_ATLAS "+path)
            set_process(false)
            return
        for j in range(int(row[1])):
            var f:=_atlas(tex,j,row[2])
            match String(row[0]):
                "charge":charge_frames.append(f)
                "bloom":bloom_frames.append(f)
                "blessing":blessing_frames.append(f)
                "fade":fade_frames.append(f)
    set_process(true)
    print("POI16_VAN_LINH_R1C_READY effect=heal type=ultimate circle=2.5 world cap=3 moving_allies=4 one_outside=true background_monster_walk=true original_alpha_poses=38 no_gif=true no_actual_receipts=true")
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

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=8 or bloom_frames.size()!=12 or blessing_frames.size()!=10 or fade_frames.size()!=8:return
    _draw_disciple(CASTER_FOOT)
    _draw_monster(t)
    var chosen:Array[int]=selected_demo_allies(t)
    # Broad 3-fold half-transparent field lies BEHIND and does not paint an icon.
    if t>=CAST_END and t<FADE_START:
        var q:=clampf((t-CAST_END)/(FADE_START-CAST_END),0,1)
        _flip(bloom_frames,AOE_CENTER+Vector2(0,-47),Vector2(562,430),q*11.0,field_alpha(t)*.99)
    if t>=BLESSING_START and t<BLESSING_END:
        var q:=clampf((t-BLESSING_START)/(BLESSING_END-BLESSING_START),0,1)
        var alpha:=smoothstep(0,.18,q)*(1.0-smoothstep(.78,1.0,q))
        for i in chosen:
            _flip(blessing_frames,ally_chest(i,t)+Vector2(0,-10),
                  Vector2(244,304),q*9.0,alpha*.91)
    if t>=FADE_START and t<FADE_END:
        var q:=clampf((t-FADE_START)/(FADE_END-FADE_START),0,1)
        var opacity:=smoothstep(0,.11,q)*(1.0-smoothstep(.52,1.0,q))
        _flip(fade_frames,AOE_CENTER+Vector2(0,-51),Vector2(510,400),q*7.0,opacity*.77)
    # Real frozen actor sprite is between back and front light.
    for i in range(ALLY_BASE_POSITIONS.size()):
        _draw_disciple(ally_foot(i,t))
    if t<CAST_END+.06:
        var a:=smoothstep(.02,.19,t)*(1.0-smoothstep(CAST_END-.05,CAST_END+.06,t))
        _flip(charge_frames,PALM,Vector2(240,229),clampf(t/CAST_END*7.0,0,7.0),a*.99)
    if t>=BLESSING_START and t<BLESSING_END:
        var q2:=clampf((t-BLESSING_START)/(BLESSING_END-BLESSING_START),0,1)
        var front:=smoothstep(0,.18,q2)*(1.0-smoothstep(.78,1.0,q2))
        for i in chosen:
            _flip(blessing_frames,ally_chest(i,t)+Vector2(0,-8),
                  Vector2(185,249),q2*9.0,front*.99)
    if t>=FADE_START and t<FADE_END:
        var q3:=clampf((t-FADE_START)/(FADE_END-FADE_START),0,1)
        var frontfade:=smoothstep(0,.10,q3)*(1.0-smoothstep(.50,1.0,q3))
        for i in chosen:
            _flip(blessing_frames,ally_chest(i,t)+Vector2(0,-19),
                  Vector2(138,204),9.0,frontfade*.23)
