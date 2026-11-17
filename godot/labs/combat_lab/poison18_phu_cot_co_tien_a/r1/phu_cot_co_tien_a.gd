extends Control
## POI18 — Phụ Cốt Cổ · Tiên A (Liên Tâm).
## Isolated VIEW-ONLY Godot lab. No real Combat V2 hit/status/movement receipt.
## First-party transparent art: winged gu insect, linked thorn-heart mark.
const SKILL_ID := "tmb.skill.poison.co_doc.active_01.immortal.a"
const EFFECT := "mark"
const ELEMENT := "wood"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_RANGE := 7.8
const DECLARED_CAST := 0.43
const DECLARED_COOLDOWN := 9.6
const DECLARED_DURATION := 6.5
const DECLARED_PROJECTILE_SPEED := 8.96
const CAST_END := 0.43
const RELEASE_AT := 0.55
const CONTACT_AT := 1.35 # LAB SIMULATED mark, NOT gameplay receipt.
const IMPACT_FADE_AT := 2.06
const MARK_END := CONTACT_AT + DECLARED_DURATION
const MARK_FADE_END := 8.10
const LOOP_SECONDS := 8.50
const CASTER_FOOT := Vector2(296.0, 545.0)
const TARGET_BASE := Vector2(895.0, 548.0)
const DECOY_BASE := Vector2(1090.0, 556.0)
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE_ART: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const ASSET_ROOT := "res://labs/combat_lab/poison18_phu_cot_co_tien_a/r1/assets/"
var clock := 0.0
var paused := false
var gather_frames: Array[AtlasTexture] = []
var gu_frames: Array[AtlasTexture] = []
var burst_frames: Array[AtlasTexture] = []
var seal_frames: Array[AtlasTexture] = []

static func target_foot(t: float) -> Vector2:
    return TARGET_BASE + Vector2(31.0 * sin(2.0 * t + .2), 8.5 * cos(1.3 * t))

static func decoy_foot(t: float) -> Vector2:
    return DECOY_BASE + Vector2(15.0 * sin(2.7 * t + 1.1), 7.0 * cos(t * 1.5))

static func flight_fraction(t: float) -> float:
    if t <= RELEASE_AT: return 0.0
    if t >= CONTACT_AT: return 1.0
    var u := clampf((t - RELEASE_AT) / (CONTACT_AT - RELEASE_AT), 0.0, 1.0)
    return u * u * (3.0 - 2.0 * u)

static func projectile_pos(t: float) -> Vector2:
    var origin := CASTER_FOOT + Vector2(56.0,-96.0)
    var dest := target_foot(t) + Vector2(-13.0,-70.0)
    var f := flight_fraction(t)
    return origin.lerp(dest,f) + Vector2(0,-66.0*sin(PI*f))

static func visual_phase(t: float) -> String:
    if t < CAST_END: return "charging_gu_egg"
    if t < RELEASE_AT: return "living_gu_release"
    if t < CONTACT_AT: return "gu_homing_lab_visual"
    if t < IMPACT_FADE_AT: return "linked_heart_burst"
    if t < MARK_END: return "single_target_mark"
    if t < MARK_FADE_END: return "mark_expire"
    return "clear"

static func mark_gain(t: float) -> float:
    if t < CONTACT_AT or t >= MARK_FADE_END: return 0.0
    var appearance := smoothstep(CONTACT_AT,CONTACT_AT+.12,t)
    var exit_gain := 1.0-smoothstep(MARK_END,MARK_FADE_END,t)
    return appearance*exit_gain

static func has_gameplay_receipt(_t: float) -> bool:
    return false

func _atlas(tex: Texture2D,i: int,cell: Vector2) -> AtlasTexture:
    var frame := AtlasTexture.new()
    frame.atlas=tex
    frame.region=Rect2(Vector2(float(i%4)*cell.x,float(i/4)*cell.y),cell)
    frame.filter_clip=true
    return frame

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for entry in [["gather",8,Vector2(256,256),Vector2(1024,512)],
                  ["gu",16,Vector2(320,256),Vector2(1280,1024)],
                  ["burst",12,Vector2(320,320),Vector2(1280,960)],
                  ["seal",12,Vector2(256,256),Vector2(1024,768)]]:
        var path: String=ASSET_ROOT+"poi18_"+String(entry[0])+"_"+("%02d"%int(entry[1]))+".png"
        if not ResourceLoader.exists(path):
            push_error("POI18_MISSING_ATLAS "+path)
            set_process(false)
            return
        var texture:=load(path) as Texture2D
        if texture==null or texture.get_size()!=entry[3]:
            push_error("POI18_BAD_ATLAS "+path)
            set_process(false)
            return
        for j in range(int(entry[1])):
            var frame:=_atlas(texture,j,entry[2])
            match String(entry[0]):
                "gather": gather_frames.append(frame)
                "gu": gu_frames.append(frame)
                "burst": burst_frames.append(frame)
                "seal": seal_frames.append(frame)
    set_process(true)
    print("POI18_PHU_COT_CO_TIENA_R1_READY immortal_a=true original_rgba_poses=48 moving_target_mark=true decoy_unmarked=true gameplay_receipt=false owner_art_pending=true no_rig_no_gif=true")
    queue_redraw()

func _process(delta: float) -> void:
    if paused: return
    clock=fposmod(clock+maxf(delta,0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(ev: InputEvent) -> void:
    if ev is InputEventKey and ev.pressed and not ev.echo:
        if ev.keycode==KEY_SPACE:
            clock=0
            queue_redraw()
        elif ev.keycode==KEY_P: paused=not paused

func _paint(tex: Texture2D, pos: Vector2,dim: Vector2,opacity: float) -> void:
    if opacity<=.001: return
    draw_texture_rect(tex,Rect2(pos-dim*.5,dim),false,Color(1,1,1,clampf(opacity,0,1)))

func _pose(frames: Array[AtlasTexture],pos: Vector2,dim: Vector2,frame_f: float,opacity: float) -> void:
    if frames.is_empty() or opacity<=0.001: return
    var i:=clampi(int(floor(frame_f)),0,frames.size()-1)
    var j:=mini(i+1,frames.size()-1)
    var mix:=smoothstep(0,1,clampf(frame_f-float(i),0,1))
    _paint(frames[i],pos,dim,opacity*(1-mix))
    if i!=j: _paint(frames[j],pos,dim,opacity*mix)

func _draw_disciple() -> void:
    draw_texture_rect_region(DISCIPLE_ART,Rect2(CASTER_FOOT-Vector2(160,351)*.47,Vector2(320,384)*.47),Rect2(0,0,320,384),Color.WHITE)

func _draw_monster(pos: Vector2,t: float) -> void:
    var count:=MONSTER_FRAMES.get_frame_count("walk")
    var texture: Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*15)%maxi(count,1))
    _paint(texture,pos-Vector2(0,69),Vector2(152,139),.97)

func _draw() -> void:
    var t:=clock
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    _draw_monster(target_foot(t),t)
    _draw_monster(decoy_foot(t),t+0.22)
    if gather_frames.size()!=8 or gu_frames.size()!=16 or burst_frames.size()!=12 or seal_frames.size()!=12:
        return
    _draw_disciple()
    if t<RELEASE_AT:
        var q:=smoothstep(0.0,.12,t)*(1.0-smoothstep(CAST_END,RELEASE_AT,t))
        _pose(gather_frames,CASTER_FOOT+Vector2(49,-89),Vector2(198,198),clampf(t/CAST_END*7,0,7),q*.94)
    if t>=CAST_END and t<CONTACT_AT:
        var fade:=smoothstep(CAST_END,RELEASE_AT+.06,t)
        var travel:=flight_fraction(t)
        for k in range(3,0,-1):
            var past_t:=maxf(RELEASE_AT,t-.09*float(k))
            var past:=projectile_pos(past_t)
            _pose(gu_frames,past,Vector2(164,133),float((int(past_t*22)+k)%16),fade*(.20-.035*k))
        _pose(gu_frames,projectile_pos(t),Vector2(196,154),clampf(travel*15,0,15),.95*fade)
    if t>=CONTACT_AT and t<IMPACT_FADE_AT:
        var q2:=clampf((t-CONTACT_AT)/(IMPACT_FADE_AT-CONTACT_AT),0,1)
        _pose(burst_frames,target_foot(t)+Vector2(0,-81),Vector2(241,231),q2*11,
             .96*(1-smoothstep(.78,1,q2)))
    if t>=CONTACT_AT and t<MARK_FADE_END:
        var q3:=mark_gain(t)
        var cycle:=fposmod((t-CONTACT_AT)*7.0,12.0)
        _pose(seal_frames,target_foot(t)+Vector2(0,-89),Vector2(137,137),cycle,.96*q3)
