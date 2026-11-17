extends Control
## FIST14 R1 Hunter's Blood-Talon: original procedural illustrated 2D RGBA.
## LAB synthetic mark only, view-only: no Combat V2 changes, no fake hit count.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_04.human"
const EFFECT := "mark"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const DECLARED_DURATION := 6.0
const PROJECTILE_SPEED := 0.0
const CONTACT_TIME := 0.82
const CONTACT_END := 1.13
const MARK_START := 0.82
const MARK_END := 6.82
const FADE_END := 7.11
const LOOP_END := 7.43
const CHARGE:Texture2D=preload("res://labs/combat_lab/fist14/assets/generated/f14_charge.png")
const TALON:Texture2D=preload("res://labs/combat_lab/fist14/assets/generated/f14_talon.png")
const CONTACT:Texture2D=preload("res://labs/combat_lab/fist14/assets/generated/f14_contact.png")
const MARK:Texture2D=preload("res://labs/combat_lab/fist14/assets/generated/f14_mark.png")
const BG:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed:float=0.0
var paused:bool=false
static func phase_at(t:float)->String:
    if t<CAST_TIME:return "blood_hunt_claw_gather"
    if t<CONTACT_TIME:return "one_hunter_talon_lunge"
    if t<CONTACT_END:return "one_cosmetic_mark_contact"
    if t<MARK_END:return "six_second_hunting_scar"
    if t<FADE_END:return "scar_dissipation"
    return "idle"
static func caster_at(t:float)->Vector2:
    return Vector2(431+26*smoothstep(.37,.69,t)*(1-smoothstep(1.18,1.49,t)),550)
static func foe_at(t:float)->Vector2:
    return Vector2(806-67*smoothstep(.16,1.13,t)+32*smoothstep(2.4,4.0,t)-23*smoothstep(5.0,6.4,t),545)
static func target_position(index:int,t:float)->Vector2:
    if index!=0:return Vector2(-9999,-9999)
    return foe_at(t)
static func mark_at(index:int,t:float)->Vector2:
    return target_position(index,t)+Vector2(19,-65)
static func contact_at(t:float)->Vector2:
    return mark_at(0,t)+Vector2(-43,5)
static func talon_at(t:float)->Vector2:
    var q:=smoothstep(CAST_TIME,CONTACT_TIME,clampf(t,CAST_TIME,CONTACT_TIME))
    return (caster_at(t)+Vector2(61,-107)).lerp(contact_at(t),q)
static func mark_opacity(t:float)->float:
    if t<MARK_START or t>=FADE_END:return 0.0
    return smoothstep(MARK_START,MARK_START+.12,t)*(1-smoothstep(MARK_END,FADE_END,t))
static func contact_opacity(t:float)->float:
    if t<CONTACT_TIME or t>=CONTACT_END:return 0.0
    return smoothstep(CONTACT_TIME,CONTACT_TIME+.035,t)*(1-smoothstep(CONTACT_TIME+.13,CONTACT_END,t))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    print("VFX_FIST14_R2_READY original_code_raster_rgba=true hunter_three_talon=true one_mark_6s=true no_rig=true")
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0,delta),LOOP_END)
    queue_redraw()
func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_SPACE:elapsed=0
        elif e.keycode==KEY_P:paused=not paused
func _cell(tex:Texture2D,idx:int,pos:Vector2,scale:float,opacity:float)->void:
    if opacity<=.002:return
    var c:=320.0
    draw_set_transform(pos,0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-Vector2(160,160),Vector2(c,c)),
       Rect2(float(idx%4)*c,float(int(idx/4))*c,c,c),Color(1,1,1,clampf(opacity,0,1)))
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
func _flip(tex:Texture2D,n:int,p:float,at:Vector2,scale:float,alpha:float)->void:
    if alpha<=.002:return
    var q:=clampf(p,0,float(n-1))
    var lo:=clampi(int(floor(q)),0,n-1)
    var hi:=mini(lo+1,n-1)
    var f:=smoothstep(0,1,q-float(lo))
    _cell(tex,lo,at,scale,alpha*(1-f))
    if hi!=lo:_cell(tex,hi,at,scale,alpha*f)
func _caster(feet:Vector2)->void:
    draw_texture_rect_region(IDLE,Rect2(feet-Vector2(69,151),Vector2(138,169)),
       Rect2(0,0,320,384),Color.WHITE)
func _monster(feet:Vector2,t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(floor(t*13.0))%maxi(1,n))
    draw_texture_rect(tex,Rect2(feet-Vector2(76,139),Vector2(152,139)),false,Color.WHITE)
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
    var caster:=caster_at(t)
    var foe:=foe_at(t)
    if t<.51:
        var gain:=smoothstep(0,.12,t)*(1-smoothstep(.39,.51,t))
        _flip(CHARGE,8,7*t/CAST_TIME,caster+Vector2(55,-111),.82,gain*.99)
    # Exactly one cosmetic hunting hand follows ONE enemy's current position.
    # Presentation arc is neither a gameplay homing projectile nor 3 hits.
    if t>=CAST_TIME and t<CONTACT_TIME:
        var q:=clampf((t-CAST_TIME)/(CONTACT_TIME-CAST_TIME),0,1)
        var gain:=smoothstep(0,.075,q)*(1-smoothstep(.90,1,q))
        _flip(TALON,12,q*10.6,talon_at(t),1.04,gain*.98)
    _caster(caster)
    _monster(foe,t)
    if t>=CONTACT_TIME and t<CONTACT_END:
        var q:=clampf((t-CONTACT_TIME)/(CONTACT_END-CONTACT_TIME),0,1)
        _flip(CONTACT,8,q*7,contact_at(t),.62,contact_opacity(t))
    var status:=mark_opacity(t)
    if status>.002:
        # Three scratches visually form ONE status, anchored below face.
        _flip(MARK,8,fposmod((t-MARK_START)*5.2,8),mark_at(0,t),.76,status*.98)
