extends Control
## POI17 Yểm Ảnh Bộ - shared Human POISON MOBILITY VFX only.
## One caster moves across LAB (NO actual PvE movement authority).
## Recognizable paired footprints / approved actor afterimages / dark jade wake.
const SKILL_ID := "tmb.skill.poison.mobility.human"
const EFFECT := "mobility"
const ELEMENT := "metal"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_RANGE := 11.0
const DECLARED_CAST := 0.1
const DECLARED_COOLDOWN := 10.0
const DECLARED_DURATION := 1.0
const DECLARED_PROJECTILE_SPEED := 0.0
const DECLARED_DAMAGE_RATIO := 0.05 # Catalogue metadata: no attack receipt!
const DECLARED_POWER := 0.0
const DECLARED_POISON_STACKS := 0
const CAST_END := 0.10
const MOVE_END := 1.10
const VFX_SETTLE_END := 1.52
const LOOP_SECONDS := 1.80
const START_FOOT := Vector2(286,545)
const END_FOOT := Vector2(805,539)
const MONSTER_BASE := Vector2(1060,547)
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const ASSET_ROOT := "res://labs/combat_lab/poison17_yem_anh_bo/r1/assets/"
var clock := 0.0
var paused := false
var gather_frames:Array[AtlasTexture]=[]
var stride_frames:Array[AtlasTexture]=[]
var footprint_frames:Array[AtlasTexture]=[]
var landing_frames:Array[AtlasTexture]=[]

static func motion_fraction(t:float)->float:
    if t<=CAST_END:return 0.0
    if t>=MOVE_END:return 1.0
    var q:=clampf((t-CAST_END)/(MOVE_END-CAST_END),0,1)
    # One continuous accelerating then settling BODY step, not teleporting.
    return q*q*(3.0-2.0*q)

static func caster_foot(t:float)->Vector2:
    return START_FOOT.lerp(END_FOOT,motion_fraction(t))

static func moving_monster_foot(t:float)->Vector2:
    return MONSTER_BASE+Vector2(27.0*sin(t*1.53+.2),9.0*cos(t*1.08))

static func visual_phase(t:float)->String:
    if t<CAST_END:return "gather_footprint"
    if t<MOVE_END:return "step_afterimages"
    if t<VFX_SETTLE_END:return "landing_shadow_seal"
    return "clear"

static func step_history(t:float)->Array[Vector2]:
    var pts:Array[Vector2]=[]
    for lag in [0.12,0.26,0.40]:
        var history_t:=maxf(0.0,t-lag)
        if t>CAST_END+.07 and history_t<minf(t,MOVE_END):
            pts.append(caster_foot(history_t))
    return pts

static func demo_mobility_active(t:float)->bool:
    return t>=CAST_END and t<MOVE_END

static func has_damage_receipt(_t:float)->bool:
    return false

func _atlas(tex:Texture2D,i:int,cell:Vector2)->AtlasTexture:
    var f:=AtlasTexture.new()
    f.atlas=tex
    f.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    f.filter_clip=true
    return f

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for row in [["gather",8,Vector2(256,224),Vector2(1024,448)],
                ["stride",12,Vector2(320,160),Vector2(1280,480)],
                ["footprint",12,Vector2(256,192),Vector2(1024,576)],
                ["landing",8,Vector2(256,224),Vector2(1024,448)]]:
        var file:String=ASSET_ROOT+"poi17_"+String(row[0])+"_"+("%02d"%int(row[1]))+".png"
        if not ResourceLoader.exists(file):
            push_error("POI17_MISSING_SOURCE_RGBA "+file)
            set_process(false)
            return
        var tex:=load(file) as Texture2D
        if tex==null or tex.get_size()!=row[3]:
            push_error("POI17_BAD_ATLAS "+file)
            set_process(false)
            return
        for j in range(int(row[1])):
            var frame:=_atlas(tex,j,row[2])
            match String(row[0]):
                "gather":gather_frames.append(frame)
                "stride":stride_frames.append(frame)
                "footprint":footprint_frames.append(frame)
                "landing":landing_frames.append(frame)
    set_process(true)
    print("POI17_YEM_ANH_BO_R1_READY original_shadow_steps=true historical_actor_echoes=true moving_actor=true moving_monster_negative_control=true declared_mobility_duration_1s=true no_attack_receipt=true original_rgba_poses=40 no_gif_no_rig=true")
    queue_redraw()

func _process(delta:float)->void:
    if paused:return
    clock=fposmod(clock+maxf(delta,0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(ev:InputEvent)->void:
    if ev is InputEventKey and ev.pressed and not ev.echo:
        if ev.keycode==KEY_SPACE:
            clock=0
            queue_redraw()
        if ev.keycode==KEY_P:paused=not paused

func _paint(tex:Texture2D,center:Vector2,sz:Vector2,alpha:float)->void:
    if alpha<=.0005:return
    draw_texture_rect(tex,Rect2(center-sz*.5,sz),false,Color(1,1,1,clampf(alpha,0,1)))

func _pose(frames:Array[AtlasTexture],center:Vector2,sz:Vector2,index:float,alpha:float)->void:
    if frames.is_empty():return
    var i:=clampi(int(floor(index)),0,frames.size()-1)
    var j:=mini(i+1,frames.size()-1)
    var mix:=smoothstep(0.0,1.0,clampf(index-float(i),0,1))
    _paint(frames[i],center,sz,alpha*(1-mix))
    if i!=j:_paint(frames[j],center,sz,alpha*mix)

func _draw_disciple(foot:Vector2,tint:Color=Color.WHITE)->void:
    draw_texture_rect_region(DISCIPLE_ART,
      Rect2(foot-Vector2(160,351)*.47,Vector2(320,384)*.47),
      Rect2(0,0,320,384),tint)

func _draw_monster(t:float)->void:
    var total:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15.0)%maxi(total,1))
    _paint(tex,moving_monster_foot(t)-Vector2(0,69),Vector2(152,139),.97)

func _draw()->void:
    var t:=clock
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if gather_frames.size()!=8 or stride_frames.size()!=12 or footprint_frames.size()!=12 or landing_frames.size()!=8:return
    _draw_monster(t) # Negative-case: NEVER receive contact, damage or poison.
    var caster:=caster_foot(t)
    # 3 visible afterimages at three actual past positions of the SAME caster.
    if t>=CAST_END+.06 and t<VFX_SETTLE_END:
        var hist:=step_history(t)
        for k in range(hist.size()):
            var q:=1.0-clampf((t-MOVE_END)/.45,0,1)
            var alpha:float=(.21-.045*float(k))*q
            _draw_disciple(hist[k],Color(.17,.82,.63,alpha))
            _pose(footprint_frames,hist[k]+Vector2(-7,-10),Vector2(182,135),
                  float((k*3+int(t*16))%12),(.85-.19*float(k))*q)
    if t>=CAST_END and t<MOVE_END:
        var q:=clampf((t-CAST_END)/(MOVE_END-CAST_END),0,1)
        var trail_alpha:=smoothstep(0.0,.09,q)*(1.0-smoothstep(.85,1.0,q))
        _pose(stride_frames,caster+Vector2(-124,-76),Vector2(360,170),q*11,trail_alpha*.93)
        _pose(footprint_frames,caster+Vector2(-28,-15),Vector2(178,125),q*11,trail_alpha*.78)
    # Real approved actor in front of its own afterimage wake, no skeletal rig.
    _draw_disciple(caster)
    if t<CAST_END+.12:
        var g:=smoothstep(0,.045,t)*(1-smoothstep(CAST_END-.02,CAST_END+.12,t))
        _pose(gather_frames,caster+Vector2(-4,-22),Vector2(252,216),
              clampf(t/CAST_END*7,0,7),g*.95)
    if t>=MOVE_END and t<VFX_SETTLE_END:
        var q2:=clampf((t-MOVE_END)/(VFX_SETTLE_END-MOVE_END),0,1)
        var opa:float=smoothstep(0,.06,q2)*(1.0-smoothstep(.62,1.0,q2))
        _pose(landing_frames,caster+Vector2(0,-20),Vector2(262,210),q2*7,opa*.91)
