extends Control
## FIST15 Huyet Hai Quyen Vuc — original authored 2D-light alpha sprites.
## Isolated VIEW-ONLY lab, no status/damage/consume receipts ever fabricated.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.ultimate.human"
const EFFECT := "consume_poison"
const ELEMENT := "nether"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const RANGE := 5.0
const RADIUS := 3.0
const CAST_TIME := 1.15
const COOLDOWN := 34.0
const PROJECTILE_SPEED := 8.0
const DURATION := 0.0
const HIT_COUNT_DECLARED := false
const RELEASE_AT := 1.15
const FIRST_ARRIVAL := 1.48
const LAST_ARRIVAL := 1.80
const FIELD_END := 2.28
const LOOP_END := 3.35
const BG:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const CHARGE:Texture2D=preload("res://labs/combat_lab/fist15/assets/generated/f15_charge.png")
const SEA:Texture2D=preload("res://labs/combat_lab/fist15/assets/generated/f15_sea.png")
const FALL:Texture2D=preload("res://labs/combat_lab/fist15/assets/generated/f15_fall.png")
const HIT:Texture2D=preload("res://labs/combat_lab/fist15/assets/generated/f15_hit.png")
var elapsed:float=0.0
var paused:bool=false
static func phase_at(t:float)->String:
    if t<.92:return "concentrate_white_core"
    if t<RELEASE_AT:return "blood_sea_unfurls"
    if t<FIRST_ARRIVAL:return "vertical_spirit_fists"
    if t<LAST_ARRIVAL+.24:return "three_target_impacts"
    if t<FIELD_END:return "blood_sea_dissolve"
    return "finished"
static func caster_at()->Vector2:return Vector2(430,541)
static func foe_at(i:int,t:float)->Vector2:
    var origins:=[Vector2(694,531),Vector2(830,547),Vector2(953,530)]
    if i<0 or i>=3:return Vector2(-9999,-9999)
    return origins[i]+Vector2(
      (-19.0+float(i)*12)*smoothstep(.30,1.48,t)+10*sin(t*1.30+i*.8)*smoothstep(1.3,1.8,t),0)
static func contact_at(i:int,t:float)->Vector2:
    return foe_at(i,t)+Vector2(-7,-87)
static func field_at(t:float)->Vector2:
    return (foe_at(0,t)+foe_at(1,t)+foe_at(2,t))/3.0+Vector2(0,-76)
static func arrival_at(i:int)->float:
    return FIRST_ARRIVAL+float(i)*.16
static func drop_at(i:int,t:float)->Vector2:
    var a:=arrival_at(i)
    var f:=smoothstep(RELEASE_AT,a,clampf(t,RELEASE_AT,a))
    return contact_at(i,t)+Vector2(0,-245*(1.0-f))
static func drop_visibility(i:int,t:float)->float:
    var at:=arrival_at(i)
    if t<RELEASE_AT or t>=at+.14:return 0
    return smoothstep(RELEASE_AT,RELEASE_AT+.06,t)*(1-smoothstep(at,at+.14,t))
static func hit_visibility(i:int,t:float)->float:
    var at:=arrival_at(i)
    if t<at or t>=at+.36:return 0
    return smoothstep(at,at+.045,t)*(1-smoothstep(at+.14,at+.36,t))
static func field_opacity(t:float)->float:
    if t<.86 or t>=FIELD_END:return 0
    return smoothstep(.86,1.29,t)*(1-smoothstep(1.90,FIELD_END,t))
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(true)
    print("VFX_FIST15_R1_READY name=Huyet_Hai_Quyen_Vuc three_targets=3 duration=0 status_icons=0 code_art_original=true")
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0,delta),LOOP_END)
    queue_redraw()
func _unhandled_input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode==KEY_P:paused=not paused
        elif e.keycode==KEY_SPACE:elapsed=0
func _tile(tex:Texture2D,n:int,index:int,pos:Vector2,scale:float,alpha:float)->void:
    if alpha<=.002:return
    var i:=clampi(index,0,n-1)
    var cell:=320.0
    draw_set_transform(pos,0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(Vector2(-160,-160),Vector2(cell,cell)),
        Rect2(float(i%4)*cell,float(int(i/4))*cell,cell,cell),Color(1,1,1,clampf(alpha,0,1)))
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
func _flip(tex:Texture2D,n:int,f:float,at:Vector2,scale:float,alpha:float)->void:
    if alpha<=.002:return
    var x:=clampf(f,0,float(n-1))
    var lo:=clampi(int(floor(x)),0,n-1)
    var hi:=mini(lo+1,n-1)
    var interp:=smoothstep(0,1,x-float(lo))
    _tile(tex,n,lo,at,scale,alpha*(1-interp))
    if hi!=lo:_tile(tex,n,hi,at,scale,alpha*interp)
func _actor(feet:Vector2)->void:
    draw_texture_rect_region(CASTER,Rect2(feet-Vector2(69,151),Vector2(138,169)),
        Rect2(0,0,320,384),Color.WHITE)
func _foe(feet:Vector2,t:float)->void:
    var frames:=maxi(1,WALK.get_frame_count("walk"))
    var tex:Texture2D=WALK.get_frame_texture("walk",int(floor((t+.1)*13))%frames)
    draw_texture_rect(tex,Rect2(feet-Vector2(72,139),Vector2(144,139)),false,Color.WHITE)
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(Vector2.ZERO,Vector2(1280,720)),false,Color.WHITE)
    var field:=field_at(t)
    # Atmospheric tide BEHIND actors — not a persistent status field.
    if t>=.86 and t<FIELD_END:
        _flip(SEA,12,(t-.86)*7.3,field+Vector2(0,24),2.05,field_opacity(t)*.76)
    if t<RELEASE_AT:
        var q:=clampf(t/RELEASE_AT,0,1)
        _flip(CHARGE,10,q*9,caster_at()+Vector2(54,-106),.76,smoothstep(0,.14,t)*(1-smoothstep(1.05,RELEASE_AT,t)))
    # 3 descending Wudang-light-inspired fists; all TARGET-BOUND and below safe UI.
    for i in range(3):
        var a:=arrival_at(i)
        var dv:=drop_visibility(i,t)
        if dv>.002:
            var q:=clampf((t-RELEASE_AT)/(a-RELEASE_AT),0,1)
            _flip(FALL,17,q*16,drop_at(i,t)+Vector2(0,-69),.88,dv*.92)
    _actor(caster_at())
    for i in range(3):_foe(foe_at(i,t),t)
    for i in range(3):
        var hit:=hit_visibility(i,t)
        if hit>.002:
            var q:=clampf((t-arrival_at(i))/.36,0,1)
            _flip(HIT,8,q*7,contact_at(i,t),.50,hit*.95)
