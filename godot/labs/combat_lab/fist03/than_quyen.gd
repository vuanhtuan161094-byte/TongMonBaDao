extends Control
## Art-first preview. 'Than Quyen' is an original visual title, NOT a skill ID.
## Binding inspiration: Human Ba Quyen ultimate / Son Ha Chan Thien.
## No simulation mutations. Contact times and target reactions are illustrative
## only; production must bind exclusively to genuine Combat V2 hit receipts.
const DISPLAY_NAME := "Thần Quyền"
const ART_REVISION := "V3_CONTENT_EDGE_FEATHER"
const CANONICAL_SKILL_ID := "tmb.skill.fist.ba_quyen.ultimate.human"
const CANONICAL_SKILL_NAME := "Sơn Hà Chấn Thiên"
const EFFECT := "damage"
const ELEMENT := "fire"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RADIUS := 3.0
const CAST_TIME := 1.15
const DECLARED_RANGE := 5.0
const DECLARED_PROJECTILE_SPEED := 8.0
const HIT_TIME := 1.69
const FADE_END := 2.89
const LOOP_END := 3.28
const CONTACT_OFFSETS := [0.0,0.055,0.105]
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const CHARGE: Texture2D = preload("res://labs/combat_lab/fist03/assets/generated/charge.png")
const HERO: Texture2D = preload("res://labs/combat_lab/fist03/assets/generated/godfist.png")
const EXPLOSION: Texture2D = preload("res://labs/combat_lab/fist03/assets/generated/impact.png")
const DUST: Texture2D = preload("res://labs/combat_lab/fist03/assets/generated/dust.png")
const CASTER := Vector2(318.0,554.0)
const HIT_CENTER := Vector2(912.0,491.0)
const VICTIMS := [Vector2(764.0,548.0),Vector2(907.0,553.0),Vector2(1046.0,547.0)]
var elapsed := 0.0
var paused := false
var glow_tex: Texture2D

static func phase_at(t: float) -> String:
    if t < 0.39:
        return "gather"
    if t < CAST_TIME:
        return "manifest"
    if t < HIT_TIME:
        return "spirit_fist_flight"
    if t < FADE_END:
        return "three_target_contact_and_embers"
    return "clear"

static func source_can_hit(t: float) -> bool:
    return t >= HIT_TIME and t < FADE_END

static func hit_flash(t: float, index: int) -> float:
    if index < 0 or index >= TARGET_LIMIT:
        return 0.0
    var start: float = HIT_TIME + float(CONTACT_OFFSETS[index])
    var local: float = t-start
    if local < 0.0 or local >= 0.32:
        return 0.0
    return smoothstep(0.0,0.035,local) * (1.0-smoothstep(0.095,0.32,local))

static func impact_envelope(t: float) -> float:
    if t < HIT_TIME or t >= FADE_END:
        return 0.0
    return smoothstep(HIT_TIME,HIT_TIME+0.05,t) * (1.0-smoothstep(2.01,FADE_END,t))

func _ready() -> void:
    custom_minimum_size=Vector2(1280.0,720.0)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    glow_tex=_soft_texture()
    set_process(true)
    queue_redraw()
    print("VFX_THAN_QUYEN_ART_V1_READY concept_only=true source=",CANONICAL_SKILL_ID,
        " effect=damage shape=circle targets=3 no_rig=true no_gameplay_writes=true")

func _soft_texture() -> Texture2D:
    var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var v := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var alpha := exp(-5.6*v.length_squared())*(1.0-smoothstep(0.74,1.0,v.length()))
            img.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(alpha,0.0,1.0)))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if paused:
        return
    elapsed = fposmod(elapsed+maxf(delta,0.0),LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE:
        elapsed=0.0
        queue_redraw()
    elif event.keycode == KEY_P:
        paused=not paused

func _glow(at: Vector2,radius: float,tint: Color) -> void:
    draw_texture_rect(glow_tex,Rect2(at-Vector2.ONE*radius,Vector2.ONE*radius*2.0),false,tint)

func _atlas(tex: Texture2D,idx: int,at: Vector2,scale: float,opacity: float,
        pivot: Vector2=Vector2(192.0,192.0)) -> void:
    var col := idx%4
    var row := int(idx/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale)
    draw_texture_rect_region(tex,Rect2(-pivot,Vector2(384.0,384.0)),
        Rect2(float(col)*384.0,float(row)*384.0,384.0,384.0),
        Color(1.0,1.0,1.0,opacity))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,tint: Color) -> void:
    # Existing static character is a battle-scale STAND-IN, never rigged or kicked.
    draw_texture_rect_region(ACTOR,
        Rect2(feet-Vector2(67.0,147.0),Vector2(134.0,164.0)),
        Rect2(0.0,0.0,320.0,384.0),tint)

func _victim_recoil(t: float,index: int) -> float:
    var offset: float = t-HIT_TIME-float(CONTACT_OFFSETS[index])
    if offset < 0.0 or offset > 0.42:
        return 0.0
    return 19.0 * smoothstep(0.015,0.12,offset) * (1.0-smoothstep(0.20,0.42,offset))

func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BG,Rect2(0.0,0.0,1280.0,720.0),false,Color.WHITE)
    draw_rect(Rect2(0,0,1280,80),Color("14131d",0.76))
    _glow(CASTER+Vector2(0,20),57.0,Color("382a26",0.25))
    for i in range(VICTIMS.size()):
        _glow(VICTIMS[i]+Vector2(0,12),53.0,Color("33272b",0.23))
    # GATHER: first-party softly lit fist sprite rather than generic magic circle.
    if t < CAST_TIME:
        var q := clampf(t/CAST_TIME,0.0,1.0)
        var idx := clampi(int(floor(q*8.0)),0,7)
        var rise := smoothstep(0.05,0.48,t)
        var at := CASTER+Vector2(76.0,-106.0-19.0*rise)
        _glow(at,92.0+55.0*q,Color("ffc17e",0.08+0.18*q))
        _atlas(CHARGE,idx,at,0.83+0.19*q,0.56+0.34*q)
    # Release: the illustrated fist travels in an identifiable direction.
    if t >= CAST_TIME and t < HIT_TIME+0.12:
        var q := clampf((t-CAST_TIME)/(HIT_TIME-CAST_TIME),0.0,1.0)
        var ease := 1.0-pow(1.0-q,2.4)
        var pos := Vector2(439.0,390.0).lerp(HIT_CENTER+Vector2(28,-19),ease)
        if t >= HIT_TIME:
            pos+=Vector2(12*(t-HIT_TIME)/0.12,4.0)
        var opacity := 1.0-smoothstep(HIT_TIME,HIT_TIME+0.12,t)
        # Two translucent image-origin trailing poses, not identical vector sticks.
        for j in range(2,0,-1):
            var old := clampf(q-float(j)*0.12,0.0,1.0)
            var lag_pos := Vector2(439,390).lerp(HIT_CENTER+Vector2(28,-19),1.0-pow(1.0-old,2.4))
            _atlas(HERO,clampi(int(old*11.0),0,11),lag_pos,1.05+0.15*q,0.09*opacity)
        _glow(pos,140.0,Color("f8b36c",0.18*opacity))
        _atlas(HERO,clampi(int(q*12.0),0,11),pos,1.08+0.25*q,opacity)
    # ONCE at demonstrative contact: baked rock-burst sprite behind enemy actors.
    var blast := impact_envelope(t)
    if blast > 0.003:
        var k := clampi(int(floor((t-HIT_TIME)/(FADE_END-HIT_TIME)*12.0)),0,11)
        var expansion := 1.03+0.28*smoothstep(HIT_TIME,FADE_END,t)
        _glow(HIT_CENTER+Vector2(0,16),177.0,Color("f8a657",blast*0.15))
        _atlas(EXPLOSION,k,HIT_CENTER+Vector2(0,31),expansion,blast*0.93,Vector2(194.0,258.0))
        var m := clampi(int(floor((t-HIT_TIME)/(FADE_END-HIT_TIME)*8.0)),0,7)
        _atlas(DUST,m,HIT_CENTER+Vector2(0,78),1.37,blast*0.78,Vector2(192.0,277.0))
    # Actors: actual model remains readable; only view-only hit-reacts at 3 positions.
    _actor(CASTER,Color("f0e6d9"))
    for i in range(VICTIMS.size()):
        var impact := hit_flash(t,i)
        var other: Vector2 = (VICTIMS[i] as Vector2)+Vector2(_victim_recoil(t,i),0.0)
        _actor(other,Color(1.0,1.0,1.0,1.0).lerp(Color("fff1d8"),impact*0.62))
        if impact > 0.005:
            var flash: Vector2 = other+Vector2(-17.0,-78.0)
            _glow(flash,53.0,Color("ffe4a0",impact*0.68))
            _glow(flash,19.0,Color("fffdf2",impact*0.73))
            for n in range(7):
                var ang := float(n)*2.399+float(i)*0.31
                var r := 20.0+39.0*(1.0-impact)
                var a: Vector2 = flash+Vector2(cos(ang),sin(ang))*r
                var b: Vector2 = a+Vector2(cos(ang),sin(ang))*(9.0+8.0*impact)
                draw_line(a,b,Color("ffcf79",impact*0.63),1.4,true)
    draw_string(ThemeDB.fallback_font,Vector2(27,36),
        "THAN QUYEN  |  SON HA CHAN THIEN ART STUDY",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("fff0ce"))
    draw_string(ThemeDB.fallback_font,Vector2(28,61),
        "FIST03 V3 | PAINTED FIST - 3 TARGET REACTIONS - VIEW-ONLY",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("d9bda2"))
    draw_string(ThemeDB.fallback_font,Vector2(27,683),
        "GODOT 4.7.2 COMPATIBILITY | 40 PAINTED ATLAS FRAMES | NO RIG / NO HP WRITES",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("ffe0ad"))