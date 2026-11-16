extends Control
## POI11 Human Ultimate — Vạn Độc Xuyên Tâm, VIEW ONLY.
## Original first-party painted spear-storm, separate shared poisoned badge.
## The catalogue does not declare hit_count: no extra gameplay hit is inferred.
const SKILL_ID := "tmb.skill.poison.doc_cham.ultimate.human"
const EFFECT := "poison"
const ELEMENT := "nether"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RADIUS := 3.0
const DECLARED_RANGE := 8.0
const DECLARED_CAST := 1.15
const DECLARED_COOLDOWN := 36.0
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_DURATION := 8.0
const DECLARED_POISON_STACKS := 2
const DECLARED_DAMAGE_RATIO := 1.8
const CAST_END := 1.15
const AREA_ARRIVE := 1.90
const CROWN_END := 3.08
const FIRST_CONTACT := 2.20
const CONTACT_GAP := 0.08
const CONTACT_VISUAL_SECONDS := 0.40
const LOOP_SECONDS := 11.00
const PALM := Vector2(341.0,426.0)
const AREA_CENTER := Vector2(1002.0,518.0)
const CASTER := Vector2(273.0,540.0)
const CHARGE_PATH := "res://labs/combat_lab/poison11/r1_original/assets/poison11_charge_10.png"
const CROWN_PATH := "res://labs/combat_lab/poison11/r1_original/assets/poison11_crown_12.png"
const CONTACT_PATH := "res://labs/combat_lab/poison11/r1_original/assets/poison11_contact_08.png"
const CHARGE_CELL := Vector2(192,192)
const CROWN_CELL := Vector2(320,224)
const CONTACT_CELL := Vector2(192,160)
const BACKDROP:Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES:SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const PoisonBadge = preload("res://labs/combat_lab/shared_poison_status/poison_status_badge.gd")
var elapsed:=0.0
var paused:=false
var charge_frames:Array[AtlasTexture]=[]
var crown_frames:Array[AtlasTexture]=[]
var contact_frames:Array[AtlasTexture]=[]

static func monster_foot(i:int,t:float)->Vector2:
    var base:=Vector2(858.0,526.0)
    if i==1:base=Vector2(1007.0,563.0)
    if i==2:base=Vector2(1156.0,591.0)
    return base+Vector2(24.0*sin(t*.82+float(i)*1.19),12.0*cos(t*1.03+float(i)*1.51))

static func monster_chest(i:int,t:float)->Vector2:
    return monster_foot(i,t)+Vector2(-5.0,-79.0)

static func poison_badge_anchor(i:int,t:float)->Vector2:
    return monster_foot(i,t)+Vector2(-5.0,-127.0)

static func mock_contact_time(i:int)->float:
    return FIRST_CONTACT+float(i)*CONTACT_GAP

static func demo_status_remaining(i:int,t:float)->float:
    var h:=mock_contact_time(i)
    if t<h:return 0.0
    return maxf(0.0,DECLARED_DURATION-(t-h))

static func flight_position(t:float)->Vector2:
    return PALM.lerp(AREA_CENTER,clampf((t-CAST_END)/(AREA_ARRIVE-CAST_END),0.0,1.0))

static func charge_index(t:float)->float:
    return clampf((t/CAST_END)*9.0,0.0,9.0)

static func crown_index(t:float)->float:
    return clampf(pow(clampf((t-AREA_ARRIVE)/(CROWN_END-AREA_ARRIVE),0.0,1.0),0.65)*11.0,0.0,11.0)

static func contact_index(i:int,t:float)->float:
    return clampf((t-mock_contact_time(i))/CONTACT_VISUAL_SECONDS*7.0,0.0,7.0)

static func phase_at(t:float)->String:
    if t<CAST_END:return "charge"
    if t<AREA_ARRIVE:return "one_cosmetic_spear_approach"
    if t<FIRST_CONTACT:return "poison_piercer_crown"
    if t<CROWN_END:return "localized_piercing_contacts"
    if t<mock_contact_time(2)+DECLARED_DURATION:return "shared_poison_status_only"
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
    for path in [CHARGE_PATH,CROWN_PATH,CONTACT_PATH,PoisonBadge.ICON_PATH]:
        if not ResourceLoader.exists(path):
            push_error("POI11_MISSING_ALPHA_ASSET: "+path)
            set_process(false)
            return
    var c:=load(CHARGE_PATH) as Texture2D
    var s:=load(CROWN_PATH) as Texture2D
    var h:=load(CONTACT_PATH) as Texture2D
    if c==null or s==null or h==null or c.get_size()!=Vector2(768,576) or s.get_size()!=Vector2(1280,672) or h.get_size()!=Vector2(768,320):
        push_error("POI11_BAD_ATLAS_IMPORT")
        set_process(false)
        return
    for i in range(10):charge_frames.append(_frame(c,i,CHARGE_CELL))
    for i in range(12):crown_frames.append(_frame(s,i,CROWN_CELL))
    for i in range(8):contact_frames.append(_frame(h,i,CONTACT_CELL))
    set_process(true)
    print("VFX_POI11_R1_READY original_spears=true frames=30 moving_monsters=3 shared_poison_badge=true view_only=true")
    queue_redraw()

func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0,delta),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_SPACE:
            elapsed=0.0
            queue_redraw()
        elif e.keycode==KEY_P:
            paused=not paused

func _paint(tex:Texture2D,pos:Vector2,size:Vector2,alpha:float)->void:
    if alpha<=0.002:return
    draw_texture_rect(tex,Rect2(pos-size*.5,size),false,Color(1,1,1,alpha))

func _flip(frames:Array[AtlasTexture],pos:Vector2,size:Vector2,index:float,alpha:float)->void:
    var lo:=clampi(int(floor(index)),0,frames.size()-1)
    var hi:=mini(lo+1,frames.size()-1)
    var blendq:=smoothstep(0.0,1.0,clampf(index-float(lo),0,1))
    _paint(frames[lo],pos,size,alpha*(1-blendq))
    if hi!=lo:_paint(frames[hi],pos,size,alpha*blendq)

func _monster(i:int,t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",(int(t*15)+i*3)%maxi(1,n))
    _paint(tex,monster_foot(i,t)-Vector2(0,69.5),Vector2(152,139),1.0)

func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false,Color.WHITE)
    if charge_frames.size()!=10 or crown_frames.size()!=12 or contact_frames.size()!=8:return
    if t<CAST_END:
        var rise:=smoothstep(.03,.79,t)
        _flip(charge_frames,PALM,Vector2(186,170),charge_index(t),rise*.96)
    if t>=CAST_END and t<AREA_ARRIVE:
        var q:=clampf((t-CAST_END)/(AREA_ARRIVE-CAST_END),0.0,1.0)
        _flip(crown_frames,flight_position(t),Vector2(220+65*q,154+45*q),clampf(q*10.0,0.0,11.0),.92)
    # The unique needle-crown paints the *area* behind three actually moving monsters.
    if t>=AREA_ARRIVE and t<CROWN_END:
        var up:=smoothstep(AREA_ARRIVE,2.08,t)
        var out:=1.0-smoothstep(2.68,CROWN_END,t)
        var span:=lerpf(390.0,545.0,smoothstep(AREA_ARRIVE,2.40,t))
        _flip(crown_frames,AREA_CENTER+Vector2(0,-77),Vector2(span,span*.74),crown_index(t),up*out*.95)
        # Secondary center flash from the *same* original painted contact source, NOT a new hit.
        if t<2.58:
            var core_gain:=smoothstep(1.94,2.13,t)*(1.0-smoothstep(2.30,2.58,t))
            _flip(contact_frames,AREA_CENTER+Vector2(0,-58),Vector2(142,106),3.0,core_gain*.59)
    draw_texture_rect_region(CASTER_ART,Rect2(CASTER-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384))
    for i in range(TARGET_LIMIT):
        _monster(i,t)
        var hit:=mock_contact_time(i)
        if t>=hit and t<hit+CONTACT_VISUAL_SECONDS:
            var alpha:=smoothstep(hit,hit+.035,t)*(1.0-smoothstep(hit+.15,hit+CONTACT_VISUAL_SECONDS,t))
            _flip(contact_frames,monster_chest(i,t),Vector2(177,143),contact_index(i,t),alpha*.99)
        # Shared icon from POI10: display one status per target, not an eight-second attack effect.
        PoisonBadge.draw_for(self,poison_badge_anchor(i,t),DECLARED_POISON_STACKS,demo_status_remaining(i,t),t)