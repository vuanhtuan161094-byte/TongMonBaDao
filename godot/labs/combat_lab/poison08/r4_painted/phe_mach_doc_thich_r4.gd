extends Control
## POI08 R4 — Phệ Mạch Độc Thích | first-party image-backed RGBA sprite LAB
## Visual-only timing; no Combat V2/SaveService/PvE status writes or rig.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_02.human"
const ELEMENT := "nether"
const EFFECT := "poison"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_RANGE := 7.5
const DECLARED_CAST := 0.45
const DECLARED_PROJECTILE_SPEED := 8.0
const DECLARED_COOLDOWN := 9.0
const DECLARED_DURATION := 8.0
const DECLARED_POISON_STACKS := 1
const DECLARED_RADIUS := 0.0
const CAST_END := 0.45
const CONTACT_AT := 1.39
const CONTACT_END := 1.87
const MARK_END := CONTACT_AT + DECLARED_DURATION
const FADE_END := MARK_END + 0.33
const LOOP_SECONDS := 10.15
const PALM := Vector2(342.0,427.0)
const CHEST := Vector2(960.0,471.0)
const CASTER := Vector2(272.0,537.0)
const TARGET := Vector2(960.0,538.0)
const STATUS_POS := CHEST + Vector2(0.0,17.0)
const VISIBLE_TIP_X := 364.0
const BARB_PATH := "res://labs/combat_lab/poison08/r4_painted/assets/living_barb_r4_12.png"
const SEED_PATH := "res://labs/combat_lab/poison08/r4_painted/assets/thorn_seed_r4_10.png"
const BITE_PATH := "res://labs/combat_lab/poison08/r4_painted/assets/bite_contact_r4_08.png"
const MARK_PATH := "res://labs/combat_lab/poison08/r4_painted/assets/vein_mark_r4_12.png"
const BARB_CELL := Vector2(384,128)
const CELL_192 := Vector2(192,192)
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
var elapsed := 0.0
var paused := false
var barb_frames: Array[AtlasTexture] = []
var seed_frames: Array[AtlasTexture] = []
var bite_frames: Array[AtlasTexture] = []
var mark_frames: Array[AtlasTexture] = []

static func phase_at(t: float) -> String:
    if t < CAST_END: return "seed_charge"
    if t < CONTACT_AT: return "straight_barb"
    if t < CONTACT_END: return "one_contact"
    if t < MARK_END: return "one_mark_visual"
    if t < FADE_END: return "mark_fade"
    return "idle"

static func flight_q_at(t: float) -> float:
    return clampf((t-CAST_END)/(CONTACT_AT-CAST_END),0.0,1.0)

static func flight_tip_at(t: float) -> Vector2:
    return PALM.lerp(CHEST,flight_q_at(t))

static func seed_frame_at(t: float) -> float:
    return clampf(t/CAST_END*9.0,0.0,9.0)

static func barb_frame_at(t: float) -> float:
    return clampf((t-CAST_END)/(CONTACT_AT-CAST_END)*11.0,0.0,11.0)

static func bite_frame_at(t: float) -> float:
    return clampf((t-CONTACT_AT)/(CONTACT_END-CONTACT_AT)*7.0,0.0,7.0)

static func mark_frame_at(t: float) -> float:
    # Slow material pulse, not poison ticks. Eight-second visual hold.
    return fposmod(maxf(0.0,t-CONTACT_AT)*3.0,12.0)

static func mark_opacity_at(t: float) -> float:
    if t < CONTACT_AT or t >= FADE_END: return 0.0
    var on := smoothstep(CONTACT_AT,CONTACT_AT+0.07,t)
    var off := 1.0-smoothstep(MARK_END,FADE_END,t)
    return on*off

func _ready() -> void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    for path in [BARB_PATH,SEED_PATH,BITE_PATH,MARK_PATH]:
        if not ResourceLoader.exists(path):
            push_error("POI08_R4_TEXTURE_MISSING: "+path)
            set_process(false)
            return
    var a:=load(BARB_PATH) as Texture2D
    var b:=load(SEED_PATH) as Texture2D
    var c:=load(BITE_PATH) as Texture2D
    var d:=load(MARK_PATH) as Texture2D
    if a==null or b==null or c==null or d==null:
        push_error("POI08_R4_BAD_RGBA")
        set_process(false)
        return
    if a.get_size()!=Vector2(1536,384) or b.get_size()!=Vector2(768,576) or c.get_size()!=Vector2(768,384) or d.get_size()!=Vector2(768,576):
        push_error("POI08_R4_BAD_ATLAS_DIMENSIONS")
        set_process(false)
        return
    for i in range(12):
        barb_frames.append(_make_frame(a,i,BARB_CELL))
        mark_frames.append(_make_frame(d,i,CELL_192))
    for i in range(10):
        seed_frames.append(_make_frame(b,i,CELL_192))
    for i in range(8):
        bite_frames.append(_make_frame(c,i,CELL_192))
    set_process(true)
    print("VFX_POI08_R4_READY barb=12 seed=10 bite=8 mark=12 target_cap=1 source=first_party_painted view_only=true")
    queue_redraw()

func _make_frame(tex: Texture2D,i: int,cell: Vector2) -> AtlasTexture:
    var frame:=AtlasTexture.new()
    frame.atlas=tex
    frame.region=Rect2(Vector2(float(i%4)*cell.x,float(floori(float(i)/4.0))*cell.y),cell)
    frame.filter_clip=true
    return frame

func _process(delta: float) -> void:
    if paused: return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:
            elapsed=0
            queue_redraw()
        elif event.keycode==KEY_P:
            paused=not paused

func _paint(tex: Texture2D,at: Vector2,scale: float,opacity: float,angle: float=0.0) -> void:
    if opacity<=0.002:return
    draw_set_transform(at,angle,Vector2.ONE*scale)
    var s:=tex.get_size()
    draw_texture_rect(tex,Rect2(-s*0.5,s),false,Color(1,1,1,opacity))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _flipbook(frames: Array[AtlasTexture],pos: Vector2,scale: float,alpha: float,f: float,angle: float=0.0) -> void:
    var first:=clampi(int(floor(f)),0,frames.size()-1)
    var second:=mini(first+1,frames.size()-1)
    var blend_q:=smoothstep(0.0,1.0,clampf(f-float(first),0,1))
    _paint(frames[first],pos,scale,alpha*(1-blend_q),angle)
    if second!=first:_paint(frames[second],pos,scale,alpha*blend_q,angle)

func _actor(at: Vector2,scale: float,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,Rect2(at-Vector2(160,351)*scale,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _draw() -> void:
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    if barb_frames.size()!=12 or seed_frames.size()!=10 or bite_frames.size()!=8 or mark_frames.size()!=12:return
    var t:=elapsed
    if t<CAST_END:
        var strength:=smoothstep(0.03,0.37,t)
        _flipbook(seed_frames,PALM-Vector2(6,8),0.97,strength,seed_frame_at(t))
    elif t<CONTACT_AT:
        var theta:float=(CHEST-PALM).angle()
        var axis:=Vector2(cos(theta),sin(theta))
        var scale:=0.76
        var tip_offset:float=(VISIBLE_TIP_X-BARB_CELL.x*0.5)*scale
        var pos:=flight_tip_at(t)
        var previous:=PALM.lerp(CHEST,maxf(0.0,flight_q_at(t)-0.065))
        _flipbook(barb_frames,previous-axis*tip_offset,scale*0.90,0.17,barb_frame_at(maxf(CAST_END,t-0.04)),theta)
        _flipbook(barb_frames,pos-axis*tip_offset,scale,0.97,barb_frame_at(t),theta)
    _actor(CASTER,0.47,Color.WHITE)
    var mark_alpha:=mark_opacity_at(t)
    if mark_alpha>0.001:
        _flipbook(mark_frames,STATUS_POS,0.83,mark_alpha*0.28,mark_frame_at(t))
    _actor(TARGET,0.47,Color("d9d3e2"))
    if mark_alpha>0.001:
        # One unbroken mark signal, not repeated damage events or extra targets.
        _flipbook(mark_frames,STATUS_POS,0.87,mark_alpha*0.78,mark_frame_at(t))
    if t>=CONTACT_AT and t<CONTACT_END:
        var burst:=smoothstep(CONTACT_AT,CONTACT_AT+0.045,t)*(1.0-smoothstep(CONTACT_END-0.14,CONTACT_END,t))
        _flipbook(bite_frames,CHEST+Vector2(0,10),0.88,burst*0.91,bite_frame_at(t))
        # A single localized poison-thorn contact; no applied debuff in LAB.
        if t<CONTACT_AT+0.15:
            var angle:float=(CHEST-PALM).angle()
            var axis:=Vector2(cos(angle),sin(angle))
            _flipbook(barb_frames,CHEST-axis*22.0,0.25,burst*0.27,11.0,angle)
