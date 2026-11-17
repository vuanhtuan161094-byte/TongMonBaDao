extends Control
## POI13 R2 energy-first / translucent 2.5D visual LAB; HEAL one moving ally.
## R1 original immutable; this has no Combat V2 events or real health receipts.
const SKILL_ID := "tmb.skill.poison.duoc_doc.active_02.human"
const EFFECT := "heal"
const ELEMENT := "wood"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST := 0.55
const DECLARED_COOLDOWN := 18.0
const DECLARED_RANGE := 6.5
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DAMAGE_RATIO := 0.05
const DECLARED_DURATION := 0.0
const CAST_END := 0.55
const DEMO_RESOLUTION := 0.98
const FADE_END := 1.56
const LOOP_SECONDS := 1.90
const PALM := Vector2(346,421)
const CASTER_FOOT := Vector2(295,551)
const ALLY_BASE := Vector2(758,551)
const MONSTER_BASE := Vector2(1085,559)
const ASSET_ROOT := "res://labs/combat_lab/poison13_heal_heart/r2/assets/"
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed := 0.0
var paused := false
var charge_frames: Array[AtlasTexture] = []
var aura_frames: Array[AtlasTexture] = []
var release_frames: Array[AtlasTexture] = []

static func ally_foot(t:float)->Vector2:
    return ALLY_BASE+Vector2(38.0*sin(t*1.35+.05),6.0*cos(t*.94))
static func ally_chest(t:float)->Vector2:
    return ally_foot(t)+Vector2(0.0,-101.0)
static func monster_foot(t:float)->Vector2:
    return MONSTER_BASE+Vector2(47.0*sin(t*1.85-.40),11.0*cos(t*1.1))
static func phase_at(t:float)->String:
    if t<CAST_END:return "charge"
    if t<DEMO_RESOLUTION:return "heart_energy"
    if t<FADE_END:return "rising_soft_energy"
    return "idle"
static func energy_fade(t:float)->float:
    if t<0.0 or t>=FADE_END:return 0.0
    if t<CAST_END:return smoothstep(0.0,.18,t)
    if t<DEMO_RESOLUTION:return smoothstep(CAST_END,CAST_END+.16,t)
    return 1.0-smoothstep(DEMO_RESOLUTION+.09,FADE_END,t)

func _make_frame(tex:Texture2D,i:int,cell:Vector2)->AtlasTexture:
    var a:=AtlasTexture.new()
    a.atlas=tex
    a.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    a.filter_clip=true
    return a

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for row in [["charge",8,Vector2(192,192),Vector2(768,384)],
                ["aura",12,Vector2(256,256),Vector2(1024,768)],
                ["release",10,Vector2(256,256),Vector2(1024,768)]]:
        var path:String=ASSET_ROOT+"poi13_r2_"+String(row[0])+"_"+("%02d"%int(row[1]))+".png"
        if not ResourceLoader.exists(path):
            push_error("POI13_R2_MISSING_TRANSLUCENT_ATLAS "+path)
            set_process(false)
            return
        var tex:=load(path) as Texture2D
        if tex==null or tex.get_size()!=row[3]:
            push_error("POI13_R2_BAD_ATLAS "+path)
            set_process(false)
            return
        for i in range(int(row[1])):
            var f:=_make_frame(tex,i,row[2])
            match String(row[0]):
                "charge":charge_frames.append(f)
                "aura":aura_frames.append(f)
                "release":release_frames.append(f)
    set_process(true)
    print("POI13_ENERGY_R2_READY layers=rear_vapor,front_translucent_light,luminescent_particles original_rgba=30 no_gif=true moving_ally=true moving_monster=true heal_single=true")
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

func _paint(tex:Texture2D,center:Vector2,size:Vector2,opacity:float)->void:
    if opacity<=.0005:return
    draw_texture_rect(tex,Rect2(center-size*.5,size),false,Color(1,1,1,opacity))

func _flip(frames:Array[AtlasTexture],center:Vector2,size:Vector2,index:float,opacity:float)->void:
    var lo:=clampi(int(floor(index)),0,frames.size()-1)
    var hi:=mini(lo+1,frames.size()-1)
    var u:=smoothstep(0.0,1.0,clampf(index-float(lo),0.0,1.0))
    _paint(frames[lo],center,size,opacity*(1.0-u))
    if lo!=hi:_paint(frames[hi],center,size,opacity*u)

func _draw_disciple(foot:Vector2)->void:
    draw_texture_rect_region(DISCIPLE_ART,
        Rect2(foot-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384))

func _draw_monster(t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15)%maxi(n,1))
    _paint(tex,monster_foot(t)-Vector2(0,69.5),Vector2(152,139),.96)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=8 or aura_frames.size()!=12 or release_frames.size()!=10:return
    _draw_disciple(CASTER_FOOT)
    # The broad breathing vapor sits BEHIND the ally to prevent sticker cutout.
    if t>=CAST_END and t<DEMO_RESOLUTION+.06:
        var q:=clampf((t-CAST_END)/(DEMO_RESOLUTION-CAST_END),0.0,1.0)
        var presence:=smoothstep(CAST_END,CAST_END+.12,t)*(1.0-smoothstep(DEMO_RESOLUTION-.03,DEMO_RESOLUTION+.06,t))
        _flip(aura_frames,ally_chest(t)+Vector2(0,-7),Vector2(296,326),q*11.0,presence*.82)
    if t>=DEMO_RESOLUTION and t<FADE_END:
        var q:=clampf((t-DEMO_RESOLUTION)/(FADE_END-DEMO_RESOLUTION),0.0,1.0)
        var presence:=smoothstep(0.0,.12,q)*(1.0-smoothstep(.58,1.0,q))
        _flip(release_frames,ally_chest(t)+Vector2(0,-21),Vector2(258,298),q*9.0,presence*.44)
    _draw_disciple(ally_foot(t))
    _draw_monster(t) # background enemy NEVER receives healing effects
    if t<CAST_END+.07:
        var opacity:=smoothstep(.02,.17,t)*(1.0-smoothstep(CAST_END-.04,CAST_END+.07,t))
        _flip(charge_frames,PALM,Vector2(175,174),clampf(t/CAST_END*7.0,0.0,7.0),opacity*.97)
    # Thin luminous energy and motes flow IN FRONT of torso; no leaf outline.
    if t>=CAST_END and t<DEMO_RESOLUTION+.06:
        var q2:=clampf((t-CAST_END)/(DEMO_RESOLUTION-CAST_END),0.0,1.0)
        var front:=smoothstep(CAST_END,CAST_END+.15,t)*(1.0-smoothstep(DEMO_RESOLUTION-.03,DEMO_RESOLUTION+.06,t))
        _flip(aura_frames,ally_chest(t)+Vector2(0,4),Vector2(212,246),q2*11.0,front*.73)
    if t>=DEMO_RESOLUTION and t<FADE_END:
        var q3:=clampf((t-DEMO_RESOLUTION)/(FADE_END-DEMO_RESOLUTION),0.0,1.0)
        var fade:=smoothstep(0.0,.13,q3)*(1.0-smoothstep(.58,1.0,q3))
        _flip(release_frames,ally_chest(t)+Vector2(0,-22),Vector2(235,276),q3*9.0,fade*.80)
