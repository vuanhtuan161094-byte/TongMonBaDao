extends Control
## FIST13 R6 painted Quyền Tu hero. Cosmetic mark visual only.
## The returning qi is an ART-ONLY release motion, not healing, projectile or extra hit.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_03.human"
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
const MARK_START := 0.84
const MARK_END := 6.84
const FADE_END := 7.12
const LOOP_END := 7.55
const BG:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const CHARGE:Texture2D=preload("res://labs/combat_lab/fist13/assets/generated/f13_charge.png")
const CONTACT:Texture2D=preload("res://labs/combat_lab/fist13/assets/generated/f13_contact.png")
const MARK:Texture2D=preload("res://labs/combat_lab/fist13/assets/generated/f13_mark.png")
var elapsed:float=0.0
var paused:bool=false
static func phase_at(t:float)->String:
    if t<CAST_TIME:return "gather"
    if t<MARK_START:return "inward_contact"
    if t<MARK_END:return "one_mark_six_seconds"
    if t<FADE_END:return "fade"
    return "idle"
static func foe_at(t:float)->Vector2:
    return Vector2(802.0-62.0*smoothstep(.18,1.07,t)+39.0*smoothstep(2.6,4.4,t)-29.0*smoothstep(5.1,6.4,t),545.0)
static func caster_at(t:float)->Vector2:
    return Vector2(430.0+38.0*smoothstep(.34,.61,t)*(1.0-smoothstep(.95,1.25,t)),548.0)
static func mark_at(index:int,t:float)->Vector2:
    if index!=0:return Vector2(-9999.0,-9999.0)
    return foe_at(t)+Vector2(-3.0,-74.0)
static func mark_opacity(t:float)->float:
    if t<MARK_START or t>=FADE_END:return 0.0
    return smoothstep(MARK_START,MARK_START+.11,t)*(1.0-smoothstep(MARK_END,FADE_END,t))
static func fist_at(t:float)->Vector2:
    var q:=smoothstep(CAST_TIME,MARK_START,clampf(t,CAST_TIME,MARK_START))
    return (caster_at(t)+Vector2(56,-100)).lerp(mark_at(0,t),q)
static func return_qi_at(t:float)->Vector2:
    var q:=smoothstep(MARK_START,1.24,clampf(t,MARK_START,1.24))
    return mark_at(0,t).lerp(caster_at(t)+Vector2(54,-102),q)
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    print("VFX_FIST13_R7_READY painted_fist=true returning_qi=true moving_target=true one_mark_6s=true")
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0),LOOP_END)
    queue_redraw()
func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_SPACE:elapsed=0.0
        elif e.keycode==KEY_P:paused=not paused
func _cell(tex:Texture2D,index:int,at:Vector2,scale:float,opacity:float)->void:
    var c:=320.0
    draw_set_transform(at,0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-Vector2(160,160),Vector2(c,c)),Rect2(float(index%4)*c,float(int(index/4))*c,c,c),Color(1,1,1,clampf(opacity,0,1)))
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
func _flip(tex:Texture2D,p:float,n:int,at:Vector2,scale:float,opacity:float)->void:
    if opacity<=.002:return
    var idx:=clampf(p,0,float(n-1))
    var lo:=clampi(int(floor(idx)),0,n-1)
    var hi:=mini(lo+1,n-1)
    var q:=smoothstep(0,1,idx-float(lo))
    _cell(tex,lo,at,scale,opacity*(1-q))
    if hi!=lo:_cell(tex,hi,at,scale,opacity*q)
func _caster(pos:Vector2)->void:
    draw_texture_rect_region(IDLE,Rect2(pos-Vector2(69,151),Vector2(138,169)),Rect2(0,0,320,384),Color.WHITE)
func _monster(pos:Vector2,t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(floor(t*13))%maxi(n,1))
    draw_texture_rect(tex,Rect2(pos-Vector2(76,139),Vector2(152,139)),false,Color.WHITE)
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
    var hand:=caster_at(t)+Vector2(54,-103)
    if t<.51:
        var gain:=smoothstep(.02,.14,t)*(1.0-smoothstep(.40,.51,t))
        _flip(CHARGE,7.0*t/CAST_TIME,8,hand,.78,gain)
    # Meaningful fist silhouette advances toward an already selected enemy.
    # This is a non-projectile presentation of the original MARK cast.
    if t>=CAST_TIME and t<MARK_START:
        var q:=clampf((t-CAST_TIME)/(MARK_START-CAST_TIME),0,1)
        var alpha:=smoothstep(CAST_TIME,CAST_TIME+.065,t)
        _flip(CONTACT,q*11.0,12,fist_at(t),.77+q*.08,alpha*.97)
    # One faint BACKWARD blood-qi echo returns to caster; strictly cosmetic.
    # There is still only one mark and no new damage, hit, heal or status.
    if t>=MARK_START and t<1.24:
        var rq:=clampf((t-MARK_START)/.40,0,1)
        var ra:float=(1.0-smoothstep(.68,1.0,rq))*.63
        _flip(CHARGE,(1.0-rq)*7.0,8,return_qi_at(t),.46,ra)
    _caster(caster_at(t))
    _monster(foe_at(t),t)
    if t>=MARK_START and t<1.13:
        var flash:=smoothstep(MARK_START,MARK_START+.045,t)*(1.0-smoothstep(.92,1.13,t))
        _flip(CONTACT,11.0,12,mark_at(0,t),.40,flash*.57)
    var ink:=mark_opacity(t)
    if ink>.002:
        var p:=fposmod((t-MARK_START)*6.0,8.0)
        _flip(MARK,p,8,mark_at(0,t),.42,ink*.65)
        # A smaller floating scar on the SAME target keeps the mark readable.
        _flip(MARK,p,8,foe_at(t)+Vector2(-3,-169),.58,ink*.98)
