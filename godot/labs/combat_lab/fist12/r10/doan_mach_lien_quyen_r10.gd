extends Control
## FIST12 R10: THREE distinct painterly pressure poses, ONE cosmetic MARK.
## Technical LAB alone, no real hit receipt, no generated damage or healing.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_02.human"
const ART_REVISION := "R10_THREE_DIRECTIONAL_QI_PUNCHES"
const EFFECT := "mark"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const DECLARED_DURATION := 6.0
const DECLARED_PROJECTILE_SPEED := 0.0
const PRESSURE_START := 0.45
const CONTACT_TIME := 0.92
const CONTACT_END := 1.28
const MARK_START := 0.92
const MARK_END := 6.92
const FADE_END := 7.22
const LOOP_END := 7.60
const ATLAS_RAW_RGBA_BYTES := 19660800
const BG:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
const CHARGE:Texture2D=preload("res://labs/combat_lab/fist12/assets/r10_generated/r10_charge.png")
const WAVE:Texture2D=preload("res://labs/combat_lab/fist12/assets/r10_generated/r10_punches.png")
const CONTACT:Texture2D=preload("res://labs/combat_lab/fist12/assets/r10_generated/r10_contact.png")
const MARK:Texture2D=preload("res://labs/combat_lab/fist12/assets/r10_generated/r10_mark.png")
const BEATS:=PackedFloat32Array([.45,.60,.76,.92])
const CASTER_START := Vector2(433,552)
const FOE_START := Vector2(785,552)
var elapsed:float=0
var paused:bool=false
static func phase_at(t:float)->String:
    if t<CAST_TIME:return "compressed_hand_qi"
    if t<CONTACT_TIME:return "three_directional_punch_accents"
    if t<CONTACT_END:return "one_local_mark_contact"
    if t<MARK_END:return "one_mark_six_seconds"
    if t<FADE_END:return "mark_fade"
    return "idle"
static func caster_at(t:float)->Vector2:
    # Existing WAVING/WALK standalone placeholder; no rig or fake 3 punches.
    var rush:=107.0*smoothstep(.38,.58,t)*(1.0-smoothstep(1.00,1.32,t))
    return CASTER_START+Vector2(rush,0)
static func foe_at(t:float)->Vector2:
    return FOE_START+Vector2(-52.0*smoothstep(.18,1.13,t)+31.0*smoothstep(2.95,4.10,t)-22.0*smoothstep(5.10,6.36,t),0)
static func target_position(index:int,t:float)->Vector2:
    if index!=0:return Vector2(-10000,-10000)
    return foe_at(t)
static func mark_at(index:int,t:float)->Vector2:
    return target_position(index,t)+Vector2(29,-63)
static func impact_at(t:float)->Vector2:
    # Keeps every local light burst BELOW enemy face and toward incoming side.
    return foe_at(t)+Vector2(-51,-78)
static func beat_at(t:float)->int:
    if t<BEATS[1]:return 0
    if t<BEATS[2]:return 1
    return 2
static func beat_progress(t:float)->float:
    var b:=beat_at(t)
    return clampf((t-BEATS[b])/(BEATS[b+1]-BEATS[b]),0,1)
static func beat_position(t:float)->Vector2:
    var b:=beat_at(t)
    var source:=caster_at(t)+Vector2(46,-106)
    var dest:=impact_at(t)+[Vector2(-14,14),Vector2(12,-10),Vector2(0,0)][b]
    return source.lerp(dest,smoothstep(0,1,beat_progress(t)))
static func mark_alpha(t:float)->float:
    if t<MARK_START or t>=FADE_END:return 0
    return smoothstep(MARK_START,MARK_START+.10,t)*(1.0-smoothstep(MARK_END,FADE_END,t))
static func charge_alpha(t:float)->float:
    if t<0 or t>=CAST_TIME:return 0
    return smoothstep(.01,.14,t)*(1.0-smoothstep(.38,CAST_TIME,t))
static func punch_alpha(t:float)->float:
    if t<PRESSURE_START or t>=CONTACT_TIME:return 0
    var p:=beat_progress(t)
    return smoothstep(0,.13,p)*(1.0-smoothstep(.88,1.0,p))
static func contact_alpha(t:float)->float:
    if t<CONTACT_TIME or t>=CONTACT_END:return 0
    return smoothstep(CONTACT_TIME,CONTACT_TIME+.034,t)*(1.0-smoothstep(CONTACT_TIME+.13,CONTACT_END,t))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    print("VFX_FIST12_R10_READY skill=",SKILL_ID," distinct_fist_poses=3 one_mark=6s face_occlusion=avoided owner_pending=true")
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0,delta),LOOP_END)
    queue_redraw()
func _unhandled_input(event:InputEvent)->void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:elapsed=0.0
        elif event.keycode==KEY_P:paused=not paused
func _tile(tex:Texture2D,index:int,at:Vector2,scale:float,opacity:float)->void:
    if opacity<=.003:return
    var cell:=320.0
    draw_set_transform(at,0.0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-Vector2(160,160),Vector2(cell,cell)),
       Rect2(float(index%4)*cell,float(int(index/4))*cell,cell,cell),Color(1,1,1,clampf(opacity,0,1)))
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
func _flip(tex:Texture2D,index:float,max_frames:int,at:Vector2,scale:float,alpha:float)->void:
    if alpha<=.002:return
    var pos:=clampf(index,0,float(max_frames-1))
    var lo:=clampi(int(floor(pos)),0,max_frames-1)
    var hi:=mini(lo+1,max_frames-1)
    var blend:=smoothstep(0.0,1.0,pos-float(lo))
    _tile(tex,lo,at,scale,alpha*(1.0-blend))
    if hi!=lo:_tile(tex,hi,at,scale,alpha*blend)
func _actor(feet:Vector2,tint:Color,walking:bool)->void:
    var tex:=WALK if walking else IDLE
    var columns:=maxi(1,int(tex.get_width()/320))
    var idx:=int(floor(elapsed*7.0))%columns if walking else 0
    draw_texture_rect_region(tex,Rect2(feet-Vector2(68,151),Vector2(136,169)),
        Rect2(float(idx)*320,0,320,384),tint)
func _draw()->void:
    var t:=elapsed
    var caster:=caster_at(t)
    var foe:=foe_at(t)
    draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
    draw_rect(Rect2(0,0,1280,67),Color("14141f",.65))
    if t<CAST_TIME:
        _flip(CHARGE,7.0*t/CAST_TIME,8,caster+Vector2(43,-104),.75,charge_alpha(t))
    var caster_walk:=t>=.38 and t<1.32
    var foe_walk:=t>=.18 and t<1.13 or t>=2.95 and t<4.10 or t>=5.10 and t<6.36
    # Draw the pressure body behind receiver, do not cover the face.
    if t>=PRESSURE_START and t<CONTACT_TIME:
        var beat:=beat_at(t)
        var p:=beat_progress(t)
        _flip(WAVE,float(beat*8)+p*7,24,beat_position(t),[.76,.84,1.04][beat],punch_alpha(t))
        # Quiet source hand compression helps visually connect the moving arm.
        if p<.52:
            _flip(CHARGE,p*7,8,caster+Vector2(48,-103),.22,(1.0-p)*.48)
    _actor(caster,Color.WHITE,caster_walk)
    _actor(foe,Color("b8c4d5"),foe_walk)
    if t>=CONTACT_TIME and t<CONTACT_END:
        var q:=clampf((t-CONTACT_TIME)/(CONTACT_END-CONTACT_TIME),0,1)
        _flip(CONTACT,q*7,8,impact_at(t),.58,contact_alpha(t)*.96)
    if t>=MARK_START and t<FADE_END:
        # A single compact mark, on upper CHEST/SHOULDER, below the target's face.
        var pose:=fposmod((t-MARK_START)*5.8,8.0)
        _flip(MARK,pose,8,mark_at(0,t),.53,mark_alpha(t)*.94)
    draw_string(ThemeDB.fallback_font,Vector2(24,31),
        "DOAN MACH LIEN QUYEN | 3 DIRECTIONAL QI ACCENTS",
        HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("fff0ef"))
    draw_string(ThemeDB.fallback_font,Vector2(24,53),
        "R10 | QUYEN TU | LAB ONLY / OWNER ART PENDING",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("ffc0d8"))
    if t>=MARK_START and t<MARK_END:
        draw_string(ThemeDB.fallback_font,Vector2(1090,32),
            "MARK %.1fs"%(MARK_END-t),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ff9cbd"))
    draw_string(ThemeDB.fallback_font,Vector2(24,686),
        "GODOT 4.7.2 | 3 VISUAL BEATS / 1 MARK / 6s | NO RIG | PVE HOLD",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e3d1da"))
