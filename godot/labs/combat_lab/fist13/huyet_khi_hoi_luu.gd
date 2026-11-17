extends Control
## FIST13 R1 view-only Godot Lab; CODE-PAINTED original alpha flipbooks.
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
const WALK:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/walk_4dir_APPROVED_UNCHANGED.png")
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
    return Vector2(790.0-60.0*smoothstep(.18,1.07,t)+38.0*smoothstep(2.6,4.4,t)-28.0*smoothstep(5.1,6.4,t),540.0)
static func caster_at(t:float)->Vector2:
    return Vector2(437.0+44.0*smoothstep(.34,.61,t)*(1.0-smoothstep(.95,1.25,t)),540.0)
static func mark_at(index:int,t:float)->Vector2:
    if index!=0:return Vector2(-9999.0,-9999.0)
    return foe_at(t)+Vector2(0.0,-90.0)
static func mark_opacity(t:float)->float:
    if t<MARK_START or t>=FADE_END:return 0.0
    return smoothstep(MARK_START,MARK_START+.12,t)*(1.0-smoothstep(MARK_END,FADE_END,t))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    print("VFX_FIST13_R1_READY code_art=true one_mark=true moving_target=true")
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    queue_redraw()
func _unhandled_input(event:InputEvent)->void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE:elapsed=0.0
        elif event.keycode==KEY_P:paused=not paused
func _page(tex:Texture2D,frame:int,at:Vector2,scale:float,opacity:float)->void:
    var cell:=320.0
    draw_set_transform(at,0.0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-Vector2(160,160),Vector2(cell,cell)),
        Rect2(float(frame%4)*cell,float(int(frame/4))*cell,cell,cell),Color(1,1,1,clampf(opacity,0,1)))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
func _actor(pos:Vector2,walk:bool,tint:Color)->void:
    var tex:=WALK if walk else IDLE
    var frames:=maxi(1,int(tex.get_width()/320))
    var index:=int(floor(elapsed*7.0))%frames if walk else 0
    draw_texture_rect_region(tex,Rect2(pos-Vector2(68,151),Vector2(136,169)),
        Rect2(float(index)*320.0,0.0,320.0,384.0),tint)
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
    draw_rect(Rect2(0,0,1280,67),Color(.07,.06,.12,.79))
    if t<.46:
        var alpha:=smoothstep(0.0,.14,t)*(1.0-smoothstep(.35,.46,t))
        if alpha>.002:_page(CHARGE,clampi(int(floor(t/.45*8)),0,7),caster_at(t)+Vector2(46,-96),.72,alpha)
    _actor(caster_at(t),t>.34 and t<1.25,Color.WHITE)
    var moving:bool=(t>.18 and t<1.07) or (t>2.6 and t<4.4) or (t>5.1 and t<6.4)
    _actor(foe_at(t),moving,Color(.86,.85,.96))
    if t>=.45 and t<1.12:
        var impact_alpha:=smoothstep(.45,.55,t)*(1.0-smoothstep(.9,1.12,t))
        var contact_frame:=clampi(int(floor((t-.45)/.39*12)),0,11)
        _page(CONTACT,contact_frame,mark_at(0,t),.8,impact_alpha)
    var sign_alpha:=mark_opacity(t)
    if sign_alpha>.002:
        _page(MARK,posmod(int(floor((t-MARK_START)*6)),8),mark_at(0,t),.43,sign_alpha)
    draw_string(ThemeDB.fallback_font,Vector2(26,30),"HUYET KHI HOI LUU | FIST13",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color(1,.86,.93))
    draw_string(ThemeDB.fallback_font,Vector2(26,52),"CODE-PAINTED RGBA | LAB ONLY | ART PENDING",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(1,.67,.8))
    draw_string(ThemeDB.fallback_font,Vector2(26,689),"ONE COSMETIC MARK / 6S / NO HEAL / PVE HOLD",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(.96,.8,.86))
