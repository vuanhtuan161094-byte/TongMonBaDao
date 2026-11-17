extends Control
## POI20: Xà Ảnh Quấn Mạch · Tiên A (Liên Tâm)
## Original first-party 60 poses, 5 atlases + live Godot additive energy flow.
## Visual-only Combat Lab, NOT real poison/HP or V6.3 gameplay receipt.
const FLOW=preload("res://labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/flow_light.gd")
const SKILL_ID:="tmb.skill.poison.co_doc.active_02.immortal.a"
const EFFECT:="poison"
const ELEMENT:="wood"
const SHAPE:="single_target"
const TARGET_LIMIT:=1
const POISON_STACKS:=2
const DECLARED_RANGE:=7.8
const DECLARED_CAST:=.43
const DECLARED_COOLDOWN:=8.64
const DECLARED_DURATION:=8.5
const DECLARED_PROJECTILE_SPEED:=8.96
const CAST_END:=.43
const RELEASE_AT:=.55
const CONTACT_AT:=1.35 # Only a LAB visual stand-in, NOT a Combat V2 receipt.
const MARK_END:=CONTACT_AT+DECLARED_DURATION # t9.85
const FADE_END:=10.17
const LOOP_SECONDS:=10.65
const CASTER_FOOT:=Vector2(296,545)
const TARGET_BASE:=Vector2(895,548)
const DECOY_BASE:=Vector2(1090,556)
const CASTER_HAND:=Vector2(352,449)
const BACKGROUND: Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE_ART: Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const ASSET_ROOT:="res://labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/assets/"
var clock: float=0.0
var paused: bool=false
var gather_frames: Array[AtlasTexture]=[]
var flight_frames: Array[AtlasTexture]=[]
var coil_back_frames: Array[AtlasTexture]=[]
var coil_front_frames: Array[AtlasTexture]=[]
var mark_frames: Array[AtlasTexture]=[]
var energy_flow: Control

static func target_foot(t:float)->Vector2:
    return TARGET_BASE+Vector2(31*sin(2*t+.2),8.5*cos(1.3*t))
static func decoy_foot(t:float)->Vector2:
    return DECOY_BASE+Vector2(15*sin(2.7*t+1.1),7*cos(t*1.5))
static func flight_fraction(t:float)->float:
    var u:float=clampf((t-RELEASE_AT)/(CONTACT_AT-RELEASE_AT),0,1)
    return u*u*(3-2*u)
static func projectile_pos(t:float)->Vector2:
    var u:float=flight_fraction(t)
    return CASTER_HAND.lerp(target_foot(t)+Vector2(-12,-79),u)+Vector2(0,-50*sin(PI*u))
static func mark_anchor_at(t:float)->Vector2:
    return target_foot(t)+Vector2(0,-167)
static func mark_gain(t:float)->float:
    if t<CONTACT_AT or t>=FADE_END:return 0.0
    return smoothstep(CONTACT_AT,CONTACT_AT+.15,t)*(1.0-smoothstep(MARK_END,FADE_END,t))
static func phase_at(t:float)->String:
    if t<CAST_END:return "charge"
    if t<RELEASE_AT:return "release"
    if t<CONTACT_AT:return "serpent_flight"
    if t<2.38:return "serpent_coils_one_target"
    if t<MARK_END:return "single_target_double_venom_veins"
    if t<FADE_END:return "poison_status_fade"
    return "clear"
static func has_gameplay_receipt(_t:float)->bool:
    return false
static func affects_decoy(_t:float)->bool:
    return false

func _atlas(texture:Texture2D,index:int,cell:Vector2)->AtlasTexture:
    var a:=AtlasTexture.new()
    a.atlas=texture
    a.region=Rect2(Vector2(float(index%4)*cell.x,float(index/4)*cell.y),cell)
    a.filter_clip=true
    return a

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for entry in [
        ["gather",8,Vector2(256,256),Vector2(1024,512)],
        ["flight",16,Vector2(384,256),Vector2(1536,1024)],
        ["coil_back",12,Vector2(320,320),Vector2(1280,960)],
        ["coil_front",12,Vector2(320,320),Vector2(1280,960)],
        ["mark",12,Vector2(256,256),Vector2(1024,768)]
    ]:
        var name:String=entry[0]
        var count:int=entry[1]
        var cell:Vector2=entry[2]
        var path:String=ASSET_ROOT+"poi20_"+name+"_"+("%02d"%count)+".png"
        if not ResourceLoader.exists(path):
            push_error("POI20_MISSING_ATLAS "+path)
            set_process(false)
            return
        var texture:=load(path) as Texture2D
        if texture==null or texture.get_size()!=entry[3]:
            push_error("POI20_BAD_ATLAS "+path)
            set_process(false)
            return
        for i in range(count):
            var frame:=_atlas(texture,i,cell)
            match name:
                "gather":gather_frames.append(frame)
                "flight":flight_frames.append(frame)
                "coil_back":coil_back_frames.append(frame)
                "coil_front":coil_front_frames.append(frame)
                "mark":mark_frames.append(frame)
    energy_flow=FLOW.new()
    energy_flow.name="POI20NativeSilverJadeEnergy"
    add_child(energy_flow)
    energy_flow.set_state(clock,target_foot(clock),projectile_pos(clock),mark_anchor_at(clock),mark_gain(clock))
    set_process(true)
    queue_redraw()
    print("POI20_XA_ANH_TIEN_A_R1_READY 60_source_rgba_poses=true 5_atlases=true native_additive=true single_moving_target=true gameplay_receipt=false owner_art_pending=true")

func _process(delta:float)->void:
    if paused:return
    clock=fposmod(clock+maxf(delta,0.0),LOOP_SECONDS)
    if energy_flow!=null:
        energy_flow.set_state(clock,target_foot(clock),projectile_pos(clock),mark_anchor_at(clock),mark_gain(clock))
    queue_redraw()

func _unhandled_input(ev:InputEvent)->void:
    if ev is InputEventKey and ev.pressed and not ev.echo:
        if ev.keycode==KEY_SPACE:
            clock=0
            if energy_flow!=null:
                energy_flow.set_state(clock,target_foot(clock),projectile_pos(clock),mark_anchor_at(clock),mark_gain(clock))
            queue_redraw()
        elif ev.keycode==KEY_P:
            paused=not paused

func _paint(tex:Texture2D,pos:Vector2,dim:Vector2,alpha:float)->void:
    if alpha<=.002:return
    draw_texture_rect(tex,Rect2(pos-dim*.5,dim),false,Color(1,1,1,clampf(alpha,0,1)))
func _pose(frames:Array[AtlasTexture],pos:Vector2,dim:Vector2,p:float,alpha:float)->void:
    if frames.is_empty() or alpha<=.002:return
    var i:int=clampi(floori(p),0,frames.size()-1)
    var j:int=mini(i+1,frames.size()-1)
    var mix:float=smoothstep(0,1,clampf(p-float(i),0,1))
    _paint(frames[i],pos,dim,alpha*(1-mix))
    if i!=j:_paint(frames[j],pos,dim,alpha*mix)
func _disciple()->void:
    draw_texture_rect_region(DISCIPLE_ART,Rect2(CASTER_FOOT-Vector2(160,351)*.47,Vector2(320,384)*.47),
        Rect2(0,0,320,384),Color.WHITE)
func _monster(pos:Vector2,t:float)->void:
    var count:int=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15)%maxi(1,count))
    _paint(tex,pos-Vector2(0,69),Vector2(152,139),.97)

func _draw()->void:
    var t:float=clock
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if gather_frames.size()!=8 or flight_frames.size()!=16 or coil_back_frames.size()!=12 or coil_front_frames.size()!=12 or mark_frames.size()!=12:
        _monster(target_foot(t),t)
        _monster(decoy_foot(t),t+.22)
        _disciple()
        return
    var target:Vector2=target_foot(t)
    # BACK snake behind moving monster, not an opaque decal over the actor.
    if t>=CONTACT_AT and t<FADE_END:
        var onset:float=smoothstep(CONTACT_AT,CONTACT_AT+.2,t)
        var alpha:float=mark_gain(t)
        var cycle:float=fposmod((t-CONTACT_AT)*5.5,12)
        _pose(coil_back_frames,target+Vector2(0,-91),Vector2(236,246),cycle,onset*alpha*.75)
    _monster(target,t)
    _monster(decoy_foot(t),t+.22)
    _disciple()
    # Only a small front coil; no target-face-covering solid sticker.
    if t>=CONTACT_AT and t<FADE_END:
        var cycle_front:float=fposmod((t-CONTACT_AT)*5.4+2,12)
        _pose(coil_front_frames,target+Vector2(0,-91),Vector2(217,222),cycle_front,mark_gain(t)*.58)
        _pose(mark_frames,mark_anchor_at(t),Vector2(134,134),
            fposmod((t-CONTACT_AT)*3.8,12),mark_gain(t)*.87)
    if t<RELEASE_AT:
        var q:float=smoothstep(0,.12,t)*(1.0-smoothstep(CAST_END,RELEASE_AT,t))
        _pose(gather_frames,CASTER_HAND,Vector2(198,198),
            clampf(t/CAST_END*7,0,7),q*.87)
    if t>=RELEASE_AT and t<CONTACT_AT:
        var q:float=smoothstep(.55,.66,t)*(1.0-smoothstep(1.30,1.40,t))
        var u:float=flight_fraction(t)
        for n in range(2,0,-1):
            var tt:float=maxf(RELEASE_AT,t-.055*float(n))
            _pose(flight_frames,projectile_pos(tt),Vector2(208,139),fposmod(tt*14,16),q*(.15-.035*n))
        _pose(flight_frames,projectile_pos(t),Vector2(255,166),u*15,q*.82)
