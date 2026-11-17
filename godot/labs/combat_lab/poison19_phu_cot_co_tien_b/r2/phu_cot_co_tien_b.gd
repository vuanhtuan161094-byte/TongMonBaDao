extends Control
## POI19 — Phụ Cốt Cổ · Tiên B (Phệ Cổ).
## R2: 6 independently painted RGBA layers: violet jade orchid, ritual pearl, veil, folding flower, foot seal, persistent mark.
## VIEW-ONLY genuine Godot 4.7.2 LAB, not a Combat V2 receipt. No insect anatomy, rig, GIF, copied sprites.
const SKILL_ID := "tmb.skill.poison.co_doc.active_01.immortal.b"
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
const ASSET_ROOT := "res://labs/combat_lab/poison19_phu_cot_co_tien_b/r2/assets/"
var clock := 0.0
var paused := false
var gather_frames: Array[AtlasTexture] = []
var seed_frames: Array[AtlasTexture] = []
var fold_frames: Array[AtlasTexture] = []
var mark_frames: Array[AtlasTexture] = []
var ground_frames: Array[AtlasTexture] = []
var veil_frames: Array[AtlasTexture] = []

static func target_foot(t: float) -> Vector2:
    return TARGET_BASE + Vector2(31.0 * sin(2.0 * t + .2), 8.5 * cos(1.3 * t))

static func decoy_foot(t: float) -> Vector2:
    return DECOY_BASE + Vector2(15.0 * sin(2.7 * t + 1.1), 7.0 * cos(t * 1.5))

static func mark_anchor_at(t: float) -> Vector2:
    # Small luminous orchid FLOATS above chosen WALK enemy, not glued to clothing.
    return target_foot(t) + Vector2(0.0,-167.0)

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
    if t < CAST_END: return "charging_jade_seed"
    if t < RELEASE_AT: return "seed_release"
    if t < CONTACT_AT: return "jade_seed_flight_lab"
    if t < IMPACT_FADE_AT: return "jade_orchid_folding_contact"
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
    for entry in [["gather",12,Vector2(320,320),Vector2(1280,960)],
                  ["seed",16,Vector2(384,256),Vector2(1536,1024)],
                  ["fold",16,Vector2(384,384),Vector2(1536,1536)],
                  ["mark",12,Vector2(320,320),Vector2(1280,960)],
                  ["ground",12,Vector2(384,256),Vector2(1536,768)],
                  ["veil",12,Vector2(384,320),Vector2(1536,960)]]:
        var path: String=ASSET_ROOT+"poi19_"+String(entry[0])+"_"+("%02d"%int(entry[1]))+".png"
        if not ResourceLoader.exists(path):
            push_error("POI19_R2_MISSING_ATLAS "+path)
            set_process(false)
            return
        var texture:=load(path) as Texture2D
        if texture==null or texture.get_size()!=entry[3]:
            push_error("POI19_R2_BAD_ATLAS "+path)
            set_process(false)
            return
        for j in range(int(entry[1])):
            var frame:=_atlas(texture,j,entry[2])
            match String(entry[0]):
                "gather": gather_frames.append(frame)
                "seed": seed_frames.append(frame)
                "fold": fold_frames.append(frame)
                "mark": mark_frames.append(frame)
                "ground": ground_frames.append(frame)
                "veil": veil_frames.append(frame)
    set_process(true)
    print("POI19_PHU_COT_CO_TIENB_R2_READY immortal_b=true original_rgba_poses=80 atlas_layers=6 moving_target_mark=true decoy_unmarked=true gameplay_receipt=false owner_art_pending=true no_rig_no_gif=true")
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
    if gather_frames.size()!=12 or seed_frames.size()!=16 or fold_frames.size()!=16 or mark_frames.size()!=12 or ground_frames.size()!=12 or veil_frames.size()!=12:
        _draw_monster(target_foot(t),t)
        _draw_monster(decoy_foot(t),t+0.22)
        _draw_disciple()
        return
    # Back-to-front layered VFX. Small ritual target-foot locator, NEVER AoE.
    if t>=CONTACT_AT and t<MARK_FADE_END:
        var gain:=mark_gain(t)
        var ground_beat:=fposmod((t-CONTACT_AT)*4.0,12.0)
        _pose(ground_frames,target_foot(t)+Vector2(0,-6),Vector2(278,117),ground_beat,.70*gain)
    # Ribbons are localized behind the one targeted WALK monster.
    if t>=CONTACT_AT and t<2.65:
        var veil_u:=clampf((t-CONTACT_AT)/(2.65-CONTACT_AT),0,1)
        var veil_alpha:=.84*(1.0-smoothstep(.50,1.0,veil_u))
        _pose(veil_frames,target_foot(t)+Vector2(0,-86),Vector2(226,191),veil_u*11,veil_alpha)
    if t>=CONTACT_AT and t<IMPACT_FADE_AT:
        var fold_u:=clampf((t-CONTACT_AT)/(IMPACT_FADE_AT-CONTACT_AT),0,1)
        var fold_alpha:=.92*(1.0-smoothstep(.79,1.0,fold_u))
        _pose(fold_frames,target_foot(t)+Vector2(0,-75),Vector2(264,264),fold_u*15,fold_alpha)
    _draw_monster(target_foot(t),t)
    _draw_monster(decoy_foot(t),t+0.22)
    _draw_disciple()
    if t<RELEASE_AT:
        var charge_alpha:=smoothstep(0,.10,t)*(1-smoothstep(CAST_END,RELEASE_AT,t))
        _pose(gather_frames,CASTER_FOOT+Vector2(47,-91),Vector2(230,224),clampf(t/CAST_END*11,0,11),.98*charge_alpha)
    if t>=CAST_END and t<CONTACT_AT:
        var fade:=smoothstep(CAST_END,RELEASE_AT+.05,t)
        var flight:=flight_fraction(t)
        for k in range(3,0,-1):
            var past_t:=maxf(RELEASE_AT,t-.045*float(k))
            _pose(seed_frames,projectile_pos(past_t),Vector2(220,155),float((int(past_t*20)+k)%16),fade*(.125-.027*k))
        _pose(seed_frames,projectile_pos(t),Vector2(325,220),clampf(flight*15,0,15),fade*.97)
    # Foreground small living orchid status mark, over head on selected monster.
    if t>=CONTACT_AT and t<MARK_FADE_END:
        var mark_alpha:=mark_gain(t)
        var mark_f:=fposmod((t-CONTACT_AT)*5.0,12.0)
        _pose(mark_frames,mark_anchor_at(t),Vector2(170,170),mark_f,mark_alpha*.94)
