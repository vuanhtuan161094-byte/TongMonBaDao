extends Control
## Original multi-tier VFX-only Godot LAB, sequential Human/Immortal/Divine.
## No GIF, rig, actual Combat V2 hit, poison status, or gameplay enablement.
const SCHOOL := "poison"
const EFFECT := "damage"
const ELEMENT := "metal"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const TIER_NAMES := ["human","immortal","divine"]
const SKILL_IDS := ["tmb.skill.poison.basic.human","tmb.skill.poison.basic.immortal.base","tmb.skill.poison.basic.divine.base"]
const DAMAGE_RATIOS := [1.0,1.18,1.34]
const COOLDOWNS := [1.6,1.54,1.47]
const RANGES := [6.0,6.24,6.42]
const PROJECTILE_SPEEDS := [12.0,13.44,13.44]
const CASTS := [0.0,0.0,0.0]
const DURATIONS := [0.0,0.0,0.0]
const ROOT := "res://labs/combat_lab/poison_basic_tiers_v3/assets/"
const CHARGE_CELL := Vector2(192,192)
const FLIGHT_CELL := Vector2(288,160)
const IMPACT_CELL := Vector2(256,256)
const PALM := Vector2(342,426)
const CASTER := Vector2(273,540)
const BASE_FOOT := Vector2(997,563)
const CAST_END := 0.15
const DEMO_CONTACT := 0.70
const IMPACT_END := 1.03
const PER_TIER := 1.26
const LOOP_SECONDS := PER_TIER*3.0
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed := 0.0
var is_paused := false
var atlas := []

static func monster_foot(t:float)->Vector2:
    return BASE_FOOT + Vector2(48.0*sin(t*1.7+0.4),12.0*cos(t*.92+.42))

static func monster_chest(t:float)->Vector2:
    return monster_foot(t)+Vector2(-5,-78)

static func tier_of(t:float)->int:
    return clampi(int(floor(fposmod(t,LOOP_SECONDS)/PER_TIER)),0,2)

static func local_time(t:float)->float:
    return fposmod(t,PER_TIER)

static func aim_angle(from:Vector2,to:Vector2)->float:
    var d:=to-from
    return 0.0 if d.length_squared()<.000001 else d.angle()

static func flight_pos(t:float,from:Vector2,to:Vector2)->Vector2:
    return from.lerp(to,clampf((t-CAST_END)/(DEMO_CONTACT-CAST_END),0.0,1.0))

static func phase_at(t:float)->String:
    var q:=local_time(t)
    if q<CAST_END:return "charge"
    if q<DEMO_CONTACT:return "flight"
    if q<IMPACT_END:return "contact"
    return "idle"

static func atlas_path(tier:String,phase:String,count:int)->String:
    return ROOT+tier+"/"+tier+"_"+phase+"_"+("%02d"%count)+".png"

func _one(tex:Texture2D,index:int,cell:Vector2)->AtlasTexture:
    var a:=AtlasTexture.new()
    a.atlas=tex
    a.region=Rect2(Vector2(float(index%4)*cell.x,float(index/4)*cell.y),cell)
    a.filter_clip=true
    return a

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for tier in TIER_NAMES:
        var item:Dictionary={}
        for row in [["charge",6,CHARGE_CELL,Vector2(768,384)],["flight",8,FLIGHT_CELL,Vector2(1152,320)],["contact",8,IMPACT_CELL,Vector2(1024,512)]]:
            var path:=atlas_path(tier,String(row[0]),int(row[1]))
            if not ResourceLoader.exists(path):
                push_error("POISON_BASIC_TIERS_MISSING_RGBA "+path)
                set_process(false)
                return
            var tex:=load(path) as Texture2D
            if tex==null or tex.get_size()!=row[3]:
                push_error("POISON_BASIC_TIERS_ATLAS_DIMENSIONS "+path)
                set_process(false)
                return
            var frames:Array=[]
            for i in range(int(row[1])):
                frames.append(_one(tex,i,row[2]))
            item[String(row[0])]=frames
        atlas.append(item)
    set_process(true)
    print("VFX_POISON_BASIC_TIERS_V3_READY tiers=human,immortal,divine distinct_original_RGBA=true no_gif=true moving_target=true damage_single_only=true")
    queue_redraw()

func _process(dt:float)->void:
    if is_paused:return
    elapsed=fposmod(elapsed+maxf(0.0,dt),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        if e.keycode==KEY_P:
            is_paused=not is_paused

func _paint(tex:Texture2D,center:Vector2,sz:Vector2,alpha:float)->void:
    if alpha<0.001:return
    draw_texture_rect(tex,Rect2(center-sz*.5,sz),false,Color(1,1,1,alpha))

func _flip(frames:Array,center:Vector2,sz:Vector2,phase_index:float,alpha:float)->void:
    var n:=frames.size()
    var lo:=clampi(int(floor(phase_index)),0,n-1)
    var hi:=mini(n-1,lo+1)
    var frac:=smoothstep(0.0,1.0,clampf(phase_index-float(lo),0.0,1.0))
    _paint(frames[lo] as Texture2D,center,sz,alpha*(1.0-frac))
    if hi!=lo:_paint(frames[hi] as Texture2D,center,sz,alpha*frac)

func _draw_monster(t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var frame:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15.0)%maxi(n,1))
    _paint(frame,monster_foot(t)-Vector2(0,69.5),Vector2(152,139),1)

func _draw()->void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if atlas.size()!=3:return
    var idx:=tier_of(elapsed)
    var t:=local_time(elapsed)
    var src:Dictionary=atlas[idx]
    if t<CAST_END+.03:
        var fade:=smoothstep(0.0,.05,t)*(1.0-smoothstep(CAST_END-.02,CAST_END+.03,t))
        _flip(src["charge"],PALM,Vector2(156+idx*24,156+idx*24),clampf(t/CAST_END*5.0,0.0,5.0),fade)
    if t>=CAST_END and t<DEMO_CONTACT+.02:
        var q:=clampf((t-CAST_END)/(DEMO_CONTACT-CAST_END),0.0,1.0)
        var fade:=1.0-smoothstep(DEMO_CONTACT-.025,DEMO_CONTACT+.02,t)
        var center:=flight_pos(t,PALM,monster_chest(elapsed))
        draw_set_transform(center,aim_angle(PALM,monster_chest(elapsed)),Vector2.ONE)
        _flip(src["flight"],Vector2.ZERO,Vector2(265+idx*68,150+idx*34),q*7.0,fade*.96)
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
    # Actual existing game sprite fixture, not any generated human concept.
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384))
    _draw_monster(elapsed)
    if t>=DEMO_CONTACT and t<IMPACT_END:
        var q:=clampf((t-DEMO_CONTACT)/(IMPACT_END-DEMO_CONTACT),0.0,1.0)
        var fade:=smoothstep(0.0,.12,q)*(1.0-smoothstep(.55,1.0,q))
        _flip(src["contact"],monster_chest(elapsed)+Vector2(0,16),Vector2(170+idx*79,170+idx*79),q*7.0,fade*.88)
