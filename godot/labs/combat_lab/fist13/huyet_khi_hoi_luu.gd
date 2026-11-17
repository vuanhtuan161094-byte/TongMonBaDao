extends Control
## FIST13 R3: real first-party illustrated material atlas and native target-bound mark.
## Concept montage imagery is never imported. VFX cosmetic only; no combat mutation.
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
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    print("VFX_FIST13_R3_READY painted_material=true moving_monster=true one_mark_six_seconds=true")
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0),LOOP_END)
    queue_redraw()
func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_SPACE:elapsed=0.0
        elif e.keycode==KEY_P:paused=not paused
func _flip(tex:Texture2D,index:float,at:Vector2,scale:float,opacity:float)->void:
    if opacity<=.002:return
    var lo:=clampi(int(floor(index)),0,int(tex.get_height()/320)*4-1)
    var hi:=mini(lo+1,int(tex.get_height()/320)*4-1)
    var q:=smoothstep(0,1,clampf(index-float(lo),0,1))
    _cell(tex,lo,at,scale,opacity*(1-q))
    if hi!=lo:_cell(tex,hi,at,scale,opacity*q)
func _cell(tex:Texture2D,index:int,at:Vector2,scale:float,opacity:float)->void:
    var c:=320.0
    draw_set_transform(at,0.0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-Vector2(160,160),Vector2(c,c)),
        Rect2(float(index%4)*c,float(int(index/4))*c,c,c),Color(1,1,1,clampf(opacity,0,1)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
func _caster(pos:Vector2)->void:
    draw_texture_rect_region(IDLE,Rect2(pos-Vector2(69,151),Vector2(138,169)),Rect2(0,0,320,384),Color.WHITE)
func _monster(pos:Vector2,t:float)->void:
    var n:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(floor(t*13.0))%maxi(n,1))
    draw_texture_rect(tex,Rect2(pos-Vector2(76,139),Vector2(152,139)),false,Color.WHITE)
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
    var hand:=caster_at(t)+Vector2(51,-99)
    if t<.52:
        var gain:=smoothstep(0,.12,t)*(1.0-smoothstep(.39,.52,t))
        _flip(CHARGE,clampf(t/CAST_TIME*7,0,7),hand,.70,gain*.96)
    # Inward flow: 1 target-relative compressive painted whorl. No projectile.
    if t>=.45 and t<1.17:
        var q:=clampf((t-.45)/.39,0,1)
        var opacity:=smoothstep(.45,.55,t)*(1.0-smoothstep(.91,1.17,t))
        _flip(CONTACT,11*q,mark_at(0,t),.64,opacity)
    _caster(caster_at(t))
    _monster(foe_at(t),t)
    if t>=MARK_START and t<1.17:
        var flash:=smoothstep(MARK_START,MARK_START+.07,t)*(1.0-smoothstep(.93,1.17,t))
        _flip(CONTACT,11,mark_at(0,t),.41,flash*.47)
    var sign:=mark_opacity(t)
    if sign>.002:
        _flip(MARK,fposmod((t-MARK_START)*5.6,8.0),mark_at(0,t),.76,sign*.97)
