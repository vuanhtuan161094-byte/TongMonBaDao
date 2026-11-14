extends Control
## Lôi Đình Chấn Quyền: isolated FIRE shockwave, original painted spirit artwork.
## Combat contract is read-only: damage/circle/3 targets; hits here are visual DEMO.
## Actors are static scale proxies, no rig, no fake leg/fist animation and no HP writes.
const SKILL_ID := "tmb.skill.fist.ba_quyen.active_03.human"
const SKILL_NAME := "Lôi Đình Chấn Quyền"
const ART_REVISION := "V3_CONTENT_ALPHA_FEATHER"
const EFFECT := "damage"
const ELEMENT := "fire"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RADIUS := 3.0
const CAST_TIME := 0.45
const DECLARED_RANGE := 4.0
const DECLARED_PROJECTILE_SPEED := 8.0
const HIT_TIME := 1.04
const FADE_END := 2.34
const LOOP_END := 2.73
const CONTACT_OFFSETS := [0.0,0.065,0.125]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const CHARGE: Texture2D = preload("res://labs/combat_lab/fist04/assets/generated/charge.png")
const HERO: Texture2D = preload("res://labs/combat_lab/fist04/assets/generated/thunder.png")
const IMPACT: Texture2D = preload("res://labs/combat_lab/fist04/assets/generated/impact.png")
const GRIT: Texture2D = preload("res://labs/combat_lab/fist04/assets/generated/grit.png")
const CASTER := Vector2(315.0,551.0)
const HIT_CENTER := Vector2(908.0,468.0)
const VICTIMS := [Vector2(758.0,551.0),Vector2(912.0,557.0),Vector2(1051.0,549.0)]
var elapsed := 0.0
var paused := false
var soft_tex: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_TIME: return "gather"
    if t < HIT_TIME: return "thunder_release"
    if t < FADE_END: return "circle_contact"
    return "clear"

static func hit_alpha(t: float,i: int) -> float:
    if i < 0 or i >= TARGET_LIMIT: return 0.0
    var u: float = t-HIT_TIME-float(CONTACT_OFFSETS[i])
    if u < 0.0 or u >= 0.29: return 0.0
    return smoothstep(0.0,0.034,u)*(1.0-smoothstep(0.075,0.29,u))

static func impact_alpha(t: float) -> float:
    if t < HIT_TIME or t >= FADE_END: return 0.0
    return smoothstep(HIT_TIME,HIT_TIME+0.052,t)*(1.0-smoothstep(1.34,FADE_END,t))

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    soft_tex=_feather()
    set_process(true)
    queue_redraw()
    print("VFX_FIST04_READY id=",SKILL_ID," effect=damage element=fire shape=circle targets=3 revision=",ART_REVISION," no_rig=true preview_only=true")

func _feather() -> Texture2D:
    var img:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p: Vector2=(Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a: float=exp(-5.7*p.length_squared())*(1.0-smoothstep(0.76,1.0,p.length()))
            img.set_pixel(x,y,Color(1,1,1,clampf(a,0.0,1.0)))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if paused: return
    elapsed=fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode==KEY_P: paused=not paused

func _halo(at: Vector2,r: float,tint: Color) -> void:
    draw_texture_rect(soft_tex,Rect2(at-Vector2.ONE*r,Vector2.ONE*r*2),false,tint)

func _sprite(tex: Texture2D,idx: int,at: Vector2,scale: float,alpha: float,pivot: Vector2=Vector2(192,192)) -> void:
    var col:=idx%4
    var row:=int(idx/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-pivot,Vector2(384,384)),
        Rect2(float(col)*384,float(row)*384,384,384),Color(1,1,1,alpha))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color) -> void:
    draw_texture_rect_region(ACTOR,Rect2(feet-Vector2(67,147),Vector2(134,164)),
        Rect2(0,0,320,384),tint)

func _recoil(t: float,i: int) -> float:
    var u: float=t-HIT_TIME-float(CONTACT_OFFSETS[i])
    if u<0 or u>0.36: return 0.0
    return 12.0*smoothstep(0.02,0.12,u)*(1.0-smoothstep(0.16,0.36,u))

func _draw() -> void:
    var t:=elapsed
    draw_texture_rect(BG,Rect2(0,0,1280,720),false,Color.WHITE)
    draw_rect(Rect2(0,0,1280,78),Color("171520",0.74))
    _halo(CASTER+Vector2(0,18),60,Color("29202b",0.23))
    for target in VICTIMS:
        _halo(target+Vector2(0,18),57,Color("30212c",0.18))
    if t < CAST_TIME:
        var q:=clampf(t/CAST_TIME,0.0,1.0)
        var idx:=clampi(int(floor(q*8.0)),0,7)
        var pos:=CASTER+Vector2(79,-119-9*sin(q*PI))
        _halo(pos,140,Color("ffc37c",.12+.24*q))
        _sprite(CHARGE,idx,pos,1.12+0.14*q,0.77+0.22*q)
    if t>=CAST_TIME and t<HIT_TIME+0.13:
        var q:=clampf((t-CAST_TIME)/(HIT_TIME-CAST_TIME),0.0,1.0)
        var ease:=1.0-pow(1.0-q,2.2)
        var at:=Vector2(415,411).lerp(HIT_CENTER+Vector2(0,-38),ease)
        var fade:=1.0-smoothstep(HIT_TIME,HIT_TIME+0.13,t)
        for j in range(2,0,-1):
            var lag:=clampf(q-float(j)*0.115,0.0,1.0)
            var past:=Vector2(415,411).lerp(HIT_CENTER+Vector2(0,-38),1.0-pow(1.0-lag,2.2))
            _sprite(HERO,clampi(int(lag*11),0,11),past,1.26,.16*fade)
        _halo(at,167,Color("ffbf81",.29*fade))
        _sprite(HERO,clampi(int(q*12.0),0,11),at,1.38,fade)
    var blast:=impact_alpha(t)
    if blast>0.004:
        var p:=clampf((t-HIT_TIME)/(FADE_END-HIT_TIME),0.0,1.0)
        var k:=clampi(int(floor(p*12)),0,11)
        _halo(HIT_CENTER+Vector2(0,38),202,Color("ffaf64",blast*.24))
        _sprite(IMPACT,k,HIT_CENTER+Vector2(0,86),1.69+.17*p,blast*.99,Vector2(192,258))
        _sprite(GRIT,clampi(int(floor(p*8)),0,7),HIT_CENTER+Vector2(0,100),1.55,blast*.75,Vector2(192,240))
    # ACTORS: the three receipt locations shown in this LAB are only demonstrative.
    _actor(CASTER,Color("f2e8df"))
    for i in range(VICTIMS.size()):
        var f:=hit_alpha(t,i)
        var target: Vector2=(VICTIMS[i] as Vector2)+Vector2(_recoil(t,i),0)
        _actor(target,Color("c9c2c8").lerp(Color("fff1d3"),f*.53))
        if f>0.005:
            var at:=target+Vector2(-18,-83)
            _halo(at,54,Color("ffe6a5",f*.56))
            _halo(at,17,Color("fffdef",f*.68))
            var local: float=clampf((t-HIT_TIME-float(CONTACT_OFFSETS[i]))/.29,0,1)
            _sprite(IMPACT,clampi(int(local*11),0,11),at,0.45,f*.46,Vector2(191,221))
            for j in range(5):
                var a: float=float(j)*2.399+float(i)*.71
                var first:=at+Vector2(cos(a),sin(a))*(11+22*local)
                var last:=first+Vector2(cos(a),sin(a))*(6+10*f)
                draw_line(first,last,Color("ffda84",f*.38),1.4,true)
    draw_string(ThemeDB.fallback_font,Vector2(28,34),
        "LOI DINH CHAN QUYEN / BA QUYEN",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("ffefce"))
    draw_string(ThemeDB.fallback_font,Vector2(28,58),
        "FIST04 V3 | FIRE SHOCKWAVE / CIRCLE / 3 TARGET VISUAL CONTACTS",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e3c4a7"))
    draw_string(ThemeDB.fallback_font,Vector2(28,683),
        "GODOT 4.7.2 | IMAGEGEN-DERIVED PAINTED SOURCE | VIEW-ONLY / NO RIG / NO HP WRITES",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("ffe2ab"))