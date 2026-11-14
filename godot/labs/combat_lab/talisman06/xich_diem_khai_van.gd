extends Control
## HF01 Hỏa Phù Xích Diệm Khai Văn: original painted flame; view-only
## All damage, cooldown, targets and hit receipts are Combat V2 authority.
const SKILL_ID := "tmb.skill.talisman.hoa_phu.active_01.human"
const EFFECT := "damage"
const ELEMENT := "fire"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST_TIME := 0.50
const DECLARED_COOLDOWN := 9.40
const DECLARED_RANGE := 8.50
const DECLARED_PROJECTILE_SPEED := 8.50
const HAND := Vector2(406.0,429.0)
const CASTER := Vector2(329.0,547.0)
const BASE_TARGET_FOOT := Vector2(971.0,551.0)
const FLIGHT_START := 0.64
const DEMO_HIT_AT := 1.46
const CONTACT_END := 1.80
const FADE_END := 2.66
const LOOP_SECONDS := 3.32
const SEAL:Texture2D=preload("res://labs/combat_lab/talisman06/assets/tal06_flame_seal_atlas.webp")
const COMET:Texture2D=preload("res://labs/combat_lab/talisman06/assets/tal06_fire_comet_atlas.webp")
const IMPACT:Texture2D=preload("res://labs/combat_lab/talisman06/assets/tal06_impact_atlas.webp")
const FOOT:Texture2D=preload("res://labs/combat_lab/talisman06/assets/tal06_foot_ember.webp")
const BACKDROP:Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CASTER_ART:Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES:SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var elapsed:=0.0
var paused:=false
var _glow:Texture2D
static func phase_at(t:float)->String:
    if t<DECLARED_CAST_TIME:return "charge"
    if t<FLIGHT_START:return "release"
    if t<DEMO_HIT_AT:return "projectile"
    if t<CONTACT_END:return "demo_hit"
    if t<FADE_END:return "embers_fade"
    return "idle"
static func target_foot(t:float)->Vector2:
    # A single previously selected target ID in a deterministic moving-actor
    # VISUAL QA fixture. No runtime target acquisition or guaranteed hit.
    return BASE_TARGET_FOOT+Vector2(58.0*sin(t*1.65+.2),
        7.0*sin(t*2.1+.45))
static func target_contact(t:float)->Vector2:
    return target_foot(t)+Vector2(-6.0,-82.0)
static func travel_q(t:float)->float:
    if t<=FLIGHT_START:return 0.0
    return smoothstep(FLIGHT_START,DEMO_HIT_AT,t)
static func projectile_pos(t:float)->Vector2:
    var q:=travel_q(t)
    return HAND.lerp(target_contact(t),q)+Vector2(0,-61.0*sin(PI*q))
static func hit_gain(t:float)->float:
    if t<DEMO_HIT_AT or t>=CONTACT_END:return 0.0
    return smoothstep(DEMO_HIT_AT,DEMO_HIT_AT+.052,t)*(1.0-smoothstep(DEMO_HIT_AT+.13,CONTACT_END,t))
static func scorch_gain(t:float)->float:
    if t<DEMO_HIT_AT or t>=FADE_END:return 0.0
    return smoothstep(DEMO_HIT_AT,DEMO_HIT_AT+.09,t)*(1.0-smoothstep(2.03,FADE_END,t))
static func seal_gain(t:float)->float:
    if t<.05 or t>DEMO_HIT_AT+.1:return 0.0
    return smoothstep(.05,.22,t)*(1.0-smoothstep(.70,1.04,t))
static func comet_index(t:float)->int:
    if t<FLIGHT_START or t>DEMO_HIT_AT+.04:return -1
    return clampi(int(floor(smoothstep(FLIGHT_START,DEMO_HIT_AT,t)*11.99)),0,11)
static func impact_index(t:float)->int:
    if t<DEMO_HIT_AT or t>FADE_END:return -1
    return clampi(int(floor(smoothstep(DEMO_HIT_AT,2.10,t)*7.99)),0,7)
func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    var im:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(x,y)-Vector2(47.5,47.5))/47.5
            im.set_pixel(x,y,Color(1,1,1,clampf(exp(-6*p.length_squared())*(1.0-smoothstep(.77,1.0,p.length())),0,1)))
    _glow=ImageTexture.create_from_image(im)
    print("VFX_TAL06_READY id=",SKILL_ID," paint_sprite=true moving_monster=true one_target=true view_only=true")
    set_process(true)
func _process(delta:float)->void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_SECONDS)
    queue_redraw()
func _unhandled_input(e:InputEvent)->void:
    if not e is InputEventKey or not e.pressed or e.echo:return
    if e.keycode==KEY_SPACE:elapsed=0.0
    elif e.keycode==KEY_P:paused=not paused
func _halo(center:Vector2,r:float,c:Color)->void:
    if c.a<=.004:return
    draw_texture_rect(_glow,Rect2(center-Vector2.ONE*r,Vector2.ONE*(r*2)),false,c)
func _actor(pos:Vector2)->void:
    draw_texture_rect_region(CASTER_ART,Rect2(pos-Vector2(72,163),Vector2(144,163)),
        Rect2(0,0,320,384),Color("e5c8bb"))
func _monster(pos:Vector2,t:float)->void:
    var frames:=MONSTER_FRAMES.get_frame_count("walk")
    var tex:Texture2D=MONSTER_FRAMES.get_frame_texture("walk",int(t*16.0)%maxi(1,frames))
    draw_texture_rect(tex,Rect2(pos-Vector2(78,137),Vector2(157,137)),false)
func _draw()->void:
    var t:=elapsed
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
    var foot_gain:=smoothstep(.04,.24,t)*(1.0-smoothstep(.62,1.08,t))
    if foot_gain>.004:
        draw_texture_rect(FOOT,Rect2(CASTER.x-123,CASTER.y-57,246,116),false,Color(1,1,1,foot_gain*.85))
        _halo(CASTER+Vector2(0,-3),94,Color("db662b",foot_gain*.18))
    var target:=target_foot(t)
    var scorch:=scorch_gain(t)
    if scorch>.004:
        var f:=impact_index(t)
        var source:=Rect2(float(f%4)*288.0,float(int(f/4))*224.0,288,224)
        draw_texture_rect_region(IMPACT,Rect2(target-Vector2(109,103),Vector2(218,119)),
            source,Color(1,1,1,scorch*.93))
        _halo(target+Vector2(0,-3),70,Color("e4742f",scorch*.18))
    # QA draws a preexisting frame-by-frame monster WALK atlas, never rigs.
    _actor(CASTER)
    _monster(target,t)
    var sg:=seal_gain(t)
    if sg>.004:
        var f:=clampi(int(floor(clampf(t/1.42,0,1)*11.99)),0,11)
        var sr:=Rect2(float(f%4)*256,float(int(f/4))*256,256,256)
        var at:=HAND+Vector2(25,-18-10.0*smoothstep(.08,.50,t))
        if t>FLIGHT_START:at=projectile_pos(t)-Vector2(17,23)*(1.0-travel_q(t))
        var siz:=lerpf(116,67,travel_q(t))
        draw_set_transform(at,-.18+.12*sin(t*6.0),Vector2.ONE)
        draw_texture_rect_region(SEAL,Rect2(-siz*.5,-siz*.5,siz,siz),sr,Color(1,1,1,sg*.97))
        draw_set_transform(Vector2.ZERO)
    var index:=comet_index(t)
    if index>=0:
        var q:=travel_q(t)
        var tip:=projectile_pos(t)
        var angle:=(target_contact(t)-HAND).angle()-.025*sin(q*PI)
        var alpha:=smoothstep(FLIGHT_START,FLIGHT_START+.10,t)*(1.0-smoothstep(DEMO_HIT_AT,DEMO_HIT_AT+.045,t))
        var rect:=Rect2(float(index%4)*384.0,float(int(index/4))*224.0,384,224)
        draw_set_transform(tip,angle,Vector2.ONE)
        draw_texture_rect_region(COMET,Rect2(-228,-82,292,164),rect,Color(1,1,1,alpha))
        draw_set_transform(Vector2.ZERO)
        _halo(tip,39,Color("ffb252",alpha*.28))
    var h:=hit_gain(t)
    if h>.004:
        var contact:=target_contact(t)+Vector2(0,21)
        var hitframe:=impact_index(t)
        var hitregion:=Rect2(float(hitframe%4)*288,float(int(hitframe/4))*224,288,224)
        # Brief authored molten hit splash at lower torso, separate from
        # persistent ground scar beneath the walking monster.
        draw_texture_rect_region(IMPACT,
            Rect2(contact-Vector2(61,65),Vector2(122,114)),
            hitregion,Color(1.0,1.0,1.0,h*.71))
        _halo(contact,48,Color("fe9d34",h*.37))
        _halo(contact,21,Color("fff2cf",h*.76))
    var ember:=smoothstep(DEMO_HIT_AT,DEMO_HIT_AT+.17,t)*(1.0-smoothstep(1.92,FADE_END,t))
    if ember>.004:
        for k in range(13):
            var a:=float(k)*2.399
            var rad:=15+float(k%5)*7+(t-DEMO_HIT_AT)*38
            var point:=target_contact(t)+Vector2(cos(a)*rad,sin(a)*rad*.50-(t-DEMO_HIT_AT)*46)
            _halo(point,5+float(k%3)*2,Color("f8bc70",ember*.18))
