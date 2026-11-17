extends Control
## POI15 Hóa Độc Tán R1: poison circle radius2.3 target_limit3 and 6s status.
## LAB display only. No Combat V2 damage/status application, no actual receipts.
const SKILL_ID := "tmb.skill.poison.duoc_doc.active_04.human"
const EFFECT := "poison"
const ELEMENT := "wood"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RANGE := 7.0
const DECLARED_RADIUS := 2.3
const DECLARED_CAST := 0.6
const DECLARED_COOLDOWN := 13.0
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DAMAGE_RATIO := 0.86
const DECLARED_POISON_STACKS := 1
const DECLARED_DURATION := 6.0
const DECLARED_POWER := 0.015
const CHARGE_END := 0.60
const FIELD_PEAK := 0.96
const MARK_START := 1.05
const MARK_END := MARK_START + DECLARED_DURATION
const VISUAL_FADE := 1.65
const LOOP_SECONDS := 7.44
const PALM := Vector2(346,421)
const CASTER_FOOT := Vector2(295,551)
const AOE_CENTER := Vector2(889,519)
const LAB_CIRCLE_RADIUS_PX := 165.0 # ART-ONLY; NOT mapping world radius2.3 to pixels
const ASSET_ROOT := "res://labs/combat_lab/poison15_hoa_doc_tan/r1/assets/"
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const MONSTER_BASE_POSITIONS := [
    Vector2(812,564),Vector2(964,548),Vector2(887,477),Vector2(1155,551)
]
var elapsed := 0.0
var paused := false
var charge_frames: Array[AtlasTexture] = []
var field_frames: Array[AtlasTexture] = []
var mark_frames: Array[AtlasTexture] = []

static func monster_foot(i:int,t:float)->Vector2:
    var base:Vector2=MONSTER_BASE_POSITIONS[clampi(i,0,3)]
    return base+Vector2((21.0+2*i)*sin(t*(1.12+.10*i)+i*1.1),
                         (7.0+i)*cos(t*(.89+.07*i)+i*.62))

static func monster_chest(i:int,t:float)->Vector2:
    return monster_foot(i,t)+Vector2(0,-76)

static func is_inside_visual_circle(p:Vector2)->bool:
    # Visual fixture only; actual area targeting is owned by Combat V2.
    return p.distance_to(AOE_CENTER)<=LAB_CIRCLE_RADIUS_PX

static func selected_demo_targets(t:float)->Array[int]:
    var selected:Array[int]=[]
    for i in range(MONSTER_BASE_POSITIONS.size()):
        if is_inside_visual_circle(monster_foot(i,t)) and selected.size()<TARGET_LIMIT:
            selected.append(i)
    return selected

static func status_active(t:float)->bool:
    return t>=MARK_START and t<MARK_END

static func status_alpha(t:float)->float:
    if not status_active(t):return 0.0
    return 1.0-smoothstep(MARK_END-.26,MARK_END,t)

static func phase_at(t:float)->String:
    if t<CHARGE_END:return "charge"
    if t<MARK_START:return "cloud_contact"
    if t<MARK_END:return "poison_mark_duration"
    return "idle"

func _atlas_frame(tex:Texture2D,i:int,cell:Vector2)->AtlasTexture:
    var a:=AtlasTexture.new()
    a.atlas=tex
    a.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    a.filter_clip=true
    return a

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for row in [["charge",8,Vector2(192,192),Vector2(768,384)],
                ["field",12,Vector2(320,320),Vector2(1280,960)],
                ["mark",8,Vector2(128,128),Vector2(512,256)]]:
        var path:String=ASSET_ROOT+"poi15_"+String(row[0])+"_"+("%02d"%int(row[1]))+".png"
        if not ResourceLoader.exists(path):
            push_error("POI15_MISSING_ORIGINAL_RGBA "+path)
            set_process(false)
            return
        var tex:=load(path) as Texture2D
        if tex==null or tex.get_size()!=row[3]:
            push_error("POI15_BAD_ATLAS_DIMENSIONS "+path)
            set_process(false)
            return
        for j in range(int(row[1])):
            var f:=_atlas_frame(tex,j,row[2])
            match String(row[0]):
                "charge":charge_frames.append(f)
                "field":field_frames.append(f)
                "mark":mark_frames.append(f)
    set_process(true)
    print("POI15_HOA_DOC_TAN_R1_READY effect=poison shape=circle targets=3 radius_world=2.3 duration=6.0 stacks=1 no_gameplay_receipts=true moving_targets=true original_rgba=28 no_gif=true")
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
        Rect2(foot-Vector2(160,351)*.47,Vector2(320,384)*.47),
        Rect2(0,0,320,384))

func _draw_monster(i:int,t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15.0+i*3)%maxi(1,n))
    _paint(tex,monster_foot(i,t)-Vector2(0,69.5),Vector2(152,139),1.0)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=8 or field_frames.size()!=12 or mark_frames.size()!=8:return
    _draw_disciple(CASTER_FOOT)
    if t<CHARGE_END+.05:
        var appear:=smoothstep(.02,.16,t)*(1.0-smoothstep(CHARGE_END-.035,CHARGE_END+.05,t))
        _flip(charge_frames,PALM,Vector2(178,177),clampf(t/CHARGE_END*7.0,0.0,7.0),appear*.96)
    # The spreading poison appears as pigmented LIGHT behind monster actors.
    if t>=CHARGE_END and t<VISUAL_FADE:
        var q:=clampf((t-CHARGE_END)/(VISUAL_FADE-CHARGE_END),0,1)
        var enter:=smoothstep(0,.17,q)
        var leave:=1.0-smoothstep(.66,1.0,q)
        _flip(field_frames,AOE_CENTER,Vector2(400,342),q*11.0,enter*leave*.94)
    # Visual poison wisps appear from three independent moving enemy bodies.
    # Fourth enemy is deliberately OUTSIDE; never gets mark or invented status.
    var chosen:Array[int]=selected_demo_targets(t)
    if status_active(t):
        var qmark:=fposmod((t-MARK_START)*1.5,1.0)*7.0
        var fade:=status_alpha(t)
        for idx in chosen:
            _flip(mark_frames,monster_chest(idx,t)+Vector2(0,6),
                  Vector2(125,135),qmark,fade*.39)
    for i in range(MONSTER_BASE_POSITIONS.size()):
        _draw_monster(i,t)
    if status_active(t):
        var qmark2:=fposmod((t-MARK_START)*1.5,1.0)*7.0
        var fade2:=status_alpha(t)
        for idx in chosen:
            _flip(mark_frames,monster_chest(idx,t)+Vector2(0,-9),
                  Vector2(97,118),qmark2,fade2*.81)
