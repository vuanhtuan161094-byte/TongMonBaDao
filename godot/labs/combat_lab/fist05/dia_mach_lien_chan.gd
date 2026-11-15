extends Control
## FIST05 Dia Mach Lien Chan: isolated painted earth-seismic VFX showcase.
## View-only: victim contact and moving-target positions are LAB choreography,
## never a Combat V2 hit, gameplay damage, HP write or generated status.
const SKILL_ID := "tmb.skill.fist.ba_quyen.active_04.human"
const DISPLAY_NAME := "Địa Mạch Liên Chấn"
const ART_REVISION := "V2_ORGANIC_GROUND_ALPHA"
const EFFECT := "damage"
const ELEMENT := "fire"
const SHAPE := "circle"
const TARGET_LIMIT := 3
const DECLARED_RADIUS := 3.0
const CAST_TIME := 0.45
const DECLARED_RANGE := 4.0
const PROJECTILE_SPEED := 8.0
const RIFT_START := 0.45
const CONTACT_TIME := 1.01
const ERUPTION_END := 1.72
const FADE_END := 2.56
const LOOP_END := 3.00
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const CHARGE: Texture2D = preload("res://labs/combat_lab/fist05/assets/generated/charge.png")
const FAULT: Texture2D = preload("res://labs/combat_lab/fist05/assets/generated/fault.png")
const ERUPTION: Texture2D = preload("res://labs/combat_lab/fist05/assets/generated/eruption.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist05/assets/generated/contact.png")
const CASTER := Vector2(325.0, 557.0)
const IMPACT_GROUND := Vector2(899.0, 559.0)
const TARGETS := [Vector2(746.0, 547.0), Vector2(909.0, 554.0), Vector2(1061.0, 546.0)]
var elapsed := 0.0
var paused := false
var glow_tex: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_TIME:
        return "charge"
    if t < CONTACT_TIME:
        return "seismic_fault_travel"
    if t < ERUPTION_END:
        return "triple_target_eruption"
    if t < FADE_END:
        return "rubble_fade"
    return "clear"

static func contact_alpha(t: float, target_index: int) -> float:
    if target_index < 0 or target_index >= TARGET_LIMIT:
        return 0.0
    var t0: float = CONTACT_TIME + 0.022 * float(target_index)
    var age := t - t0
    if age < 0.0 or age >= 0.35:
        return 0.0
    return smoothstep(0.0, 0.045, age) * (1.0-smoothstep(0.10, 0.35, age))

static func eruption_alpha(t: float) -> float:
    if t < CONTACT_TIME or t >= FADE_END:
        return 0.0
    return smoothstep(CONTACT_TIME, CONTACT_TIME+0.07, t) * (1.0-smoothstep(ERUPTION_END, FADE_END, t))

static func target_position(index: int, t: float) -> Vector2:
    if index < 0 or index >= TARGETS.size():
        return Vector2.ZERO
    var foot: Vector2 = TARGETS[index]
    # Moving preview targets: positions are sampled at contact, not a real seek/hit.
    return foot + Vector2(10.0*sin(1.67*t+index*1.81), 2.3*sin(.91*t+index))

static func target_recoil(t: float, index: int) -> float:
    var age := t-CONTACT_TIME-.022*float(index)
    if age < 0.0 or age > 0.47:
        return 0.0
    return 18.0*smoothstep(0.025,0.13,age)*(1.0-smoothstep(0.18,0.47,age))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0,720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    glow_tex = _soft()
    set_process(true)
    queue_redraw()
    print("VFX_FIST05_READY id=",SKILL_ID," effect=damage element=fire shape=circle targets=3 cast=0.45 painted_frames=40 view_only=true no_rig=true")

func _soft() -> Texture2D:
    var img := Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var alpha := exp(-5.8*p.length_squared())*(1.0-smoothstep(.78,1.0,p.length()))
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
        paused = not paused

func _glow(at: Vector2, radius: float, color: Color) -> void:
    draw_texture_rect(glow_tex,Rect2(at-Vector2.ONE*radius,Vector2.ONE*radius*2.0),false,color)

func _atlas(tex: Texture2D, index: int, at: Vector2, scale_factor: float, opacity: float,
        pivot: Vector2 = Vector2(192.0,284.0)) -> void:
    var col := index%4
    var row := int(index/4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-pivot,Vector2(384.0,384.0)),
        Rect2(float(col)*384.0,float(row)*384.0,384.0,384.0),
        Color(1.0,1.0,1.0,opacity))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2,color: Color) -> void:
    # Original character rig/animation remains unchanged. This is a scale stand-in.
    draw_texture_rect_region(ACTOR,Rect2(feet-Vector2(67.0,149.0),Vector2(134.0,167.0)),
        Rect2(0.0,0.0,320.0,384.0),color)

func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BG,Rect2(0,0,1280.0,720.0),false,Color.WHITE)
    draw_rect(Rect2(0,0,1280.0,80.0),Color("19151c",0.72))
    _glow(CASTER+Vector2(0,16),58.0,Color("3b3025",0.18))
    for i in range(TARGET_LIMIT):
        _glow(target_position(i,t)+Vector2(0,10),53.0,Color("352a2a",0.16))
    if t < CAST_TIME:
        var q := clampf(t/CAST_TIME,0.0,1.0)
        var frame := clampi(int(floor(q*8.0)),0,7)
        _glow(CASTER+Vector2(2,-4),93.0,Color("ffab5c",0.08+0.09*q))
        _atlas(CHARGE,frame,CASTER+Vector2(5,-8),0.79+0.15*q,.65+.33*q)
    # A single connected ground fissure advances from caster to the enemy pack.
    if t >= RIFT_START and t < ERUPTION_END:
        var q := clampf((t-RIFT_START)/(CONTACT_TIME-RIFT_START),0.0,1.0)
        for piece in range(3):
            var progress := clampf(q*1.55-float(piece)*0.23,0.0,1.0)
            if progress < 0.04:
                continue
            var center := CASTER.lerp(IMPACT_GROUND,(float(piece)+0.6)/3.45)
            var idx := clampi(int(floor(progress*12.0)),0,11)
            var fade := 1.0-smoothstep(CONTACT_TIME+.18,ERUPTION_END,t)
            _atlas(FAULT,idx,center,0.69+0.19*progress,fade*(0.55+0.40*progress))
        var final_progress := clampf((t-(RIFT_START+.22))/(CONTACT_TIME-(RIFT_START+.22)),0.0,1.0)
        if final_progress > 0.05:
            _atlas(FAULT,clampi(int(final_progress*12.0),0,11),IMPACT_GROUND+Vector2(0,4),
                1.30,0.56*(1.0-smoothstep(CONTACT_TIME+.15,ERUPTION_END,t)))
    # Staggered rocky eruption within the single target-area contact; drawn BEHIND targets.
    var burst := eruption_alpha(t)
    if burst > 0.004:
        var index := clampi(int(floor((t-CONTACT_TIME)/(FADE_END-CONTACT_TIME)*12.0)),0,11)
        _glow(IMPACT_GROUND+Vector2(0,-19),168.0,Color("f7a35d",burst*.13))
        _atlas(ERUPTION,index,IMPACT_GROUND+Vector2(0,-5),1.42,burst*.96)
        _atlas(FAULT,clampi(int(floor((t-CONTACT_TIME)/(FADE_END-CONTACT_TIME)*12.0)),0,11),
            IMPACT_GROUND,1.34,burst*.37)
    # The three target positions drift independently; only illustrative contact flashes.
    _actor(CASTER,Color("f2e7d7"))
    for i in range(TARGET_LIMIT):
        var flash := contact_alpha(t,i)
        var feet: Vector2 = target_position(i,t)+Vector2(target_recoil(t,i),0)
        _actor(feet,Color.WHITE.lerp(Color("fff2dd"),flash*.58))
        if flash > .006:
            var at := feet+Vector2(-15.0,-84.0)
            _glow(at,59.0,Color("ffd89e",flash*.56))
            _glow(at,22.0,Color("ffffed",flash*.49))
            _atlas(CONTACT,clampi(int((t-CONTACT_TIME-.022*i)/.35*8.0),0,7),
                feet+Vector2(-9,-8),.55,flash*.72)
    draw_string(ThemeDB.fallback_font,Vector2(27.0,34.0),
        "DIA MACH LIEN CHAN  /  BA QUYEN",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("ffe9bd"))
    draw_string(ThemeDB.fallback_font,Vector2(28.0,60.0),
        "FIST05  |  FIRE / CIRCLE / THREE MOVING TARGETS / ORIGINAL EARTH-RIFT SPRITES",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e4c39e"))
    draw_string(ThemeDB.fallback_font,Vector2(28,684),
        "GODOT 4.7.2 COMPATIBILITY | VIEW-ONLY HIT CUES | 40 RGBA FRAMES | NO RIG",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f1d1ad"))
