extends Control
## FIST02 - Phi Than Lien Cuoc, Guard / Fire / one recipient only.
## View-only no rig. Two heel sweeps are animation, NOT damage or a status hit.
const SKILL_ID := "tmb.skill.fist.ba_quyen.active_02.human"
const EFFECT := "guard"
const ELEMENT := "fire"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const DECLARED_RANGE := 5.5
const DECLARED_DURATION := 4.0
const DECLARED_POWER := 0.35
const PROJECTILE_SPEED := 0.0
const KICK_ONE_END := 0.19
const GUARD_START := 0.45
const GUARD_END := 4.45
const FADE_END := 4.94
const LOOP_END := 5.32
const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const HEELS: Texture2D = preload("res://labs/combat_lab/fist02/assets/painted_v1/heel_motion.png")
const SHIELD: Texture2D = preload("res://labs/combat_lab/fist02/assets/painted_v1/guard_crossflow.png")
const DUST: Texture2D = preload("res://labs/combat_lab/fist02/assets/painted_v1/footfall_dust.png")
const CASTER := Vector2(441.0, 540.0)
const OTHER := Vector2(787.0, 540.0)
var elapsed := 0.0
var paused := false
var glow_tex: Texture2D

static func phase_at(t: float) -> String:
    if t < KICK_ONE_END: return "kick_one"
    if t < GUARD_START: return "kick_two"
    if t < GUARD_END: return "guard"
    if t < FADE_END: return "dissolve"
    return "idle"

static func guard_strength(t: float) -> float:
    if t < GUARD_START or t >= FADE_END: return 0.0
    return smoothstep(GUARD_START, GUARD_START + 0.10, t) * (1.0 - smoothstep(GUARD_END, FADE_END, t))

static func heel_strength(t: float) -> float:
    if t < 0.02 or t >= 0.55: return 0.0
    return smoothstep(0.02, 0.10, t) * (1.0 - smoothstep(0.40, 0.55, t))

static func caster_shift(t: float) -> float:
    if t < GUARD_START: return 37.0 * smoothstep(0.02, GUARD_START, t)
    return 37.0 * (1.0 - smoothstep(GUARD_START, 0.77, t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0, 720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    glow_tex = _radial()
    print("VFX_FIST02_READY effect=guard target_limit=1 frames=28 cast=0.45 duration=4 no_rig=true view_only=true")
    set_process(true)
    queue_redraw()

func _radial() -> Texture2D:
    var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p := (Vector2(float(x),float(y)) - Vector2(47.5,47.5))/47.5
            var z := exp(-6.0*p.length_squared()) * (1.0-smoothstep(0.77,1.0,p.length()))
            img.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(z,0.0,1.0)))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed + maxf(0.0,delta), LOOP_END)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            elapsed = 0.0
            queue_redraw()
        elif event.keycode == KEY_P: paused = not paused

func _halo(position: Vector2, radius: float, alpha: float, tint: Color) -> void:
    draw_texture_rect(glow_tex,Rect2(position-Vector2.ONE*radius,Vector2.ONE*radius*2.0),
        false,Color(tint.r,tint.g,tint.b,alpha))

func _atlas(tex: Texture2D, frame: int, at: Vector2, scale_factor: float,
        opacity: float, anchor: Vector2 = Vector2(160.0,160.0)) -> void:
    var col := frame % 4
    var row := int(frame / 4)
    draw_set_transform(at,0.0,Vector2.ONE*scale_factor)
    draw_texture_rect_region(tex,Rect2(-anchor,Vector2(320.0,320.0)),
        Rect2(float(col)*320.0,float(row)*320.0,320.0,320.0),
        Color(1.0,1.0,1.0,opacity))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _actor(feet: Vector2, tint: Color) -> void:
    draw_texture_rect_region(ACTOR,
        Rect2(feet-Vector2(70.0,154.0),Vector2(140.0,169.0)),
        Rect2(0.0,0.0,320.0,384.0),tint)

func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BG,Rect2(0.0,0.0,1280.0,720.0),false,Color.WHITE)
    draw_rect(Rect2(0.0,0.0,1280.0,76.0),Color("111522",0.72))
    var shift := caster_shift(t)
    var caster_now := CASTER+Vector2(shift,0.0)
    _halo(CASTER+Vector2(0,15),51.0,0.16,Color("504031"))
    _halo(OTHER+Vector2(0,15),51.0,0.15,Color("35313b"))
    var dust_alpha := 1.0-smoothstep(0.28,0.82,t)
    if t < 0.82 and dust_alpha > 0.003:
        var idx := clampi(int(floor(t/0.82*8.0)),0,7)
        _atlas(DUST,idx,caster_now+Vector2(0,20),0.76,dust_alpha*0.86,Vector2(160,218))
    var guard := guard_strength(t)
    if guard > 0.003:
        var f := posmod(int(floor((t-GUARD_START)*6.0)),8)
        _halo(CASTER+Vector2(0,-99),157.0,guard*0.21,Color("ffd29a"))
        _atlas(SHIELD,f,CASTER+Vector2(0,-103),1.17,guard*(0.94+0.05*sin(t*7.0)))
    var heel := heel_strength(t)
    if heel > 0.003:
        var frame := clampi(int(floor(t/CAST_TIME*12.0)),0,11)
        var at := Vector2(594+shift*0.55,459-16*sin(PI*t/CAST_TIME))
        _halo(at,94.0,heel*0.23,Color("f6a85c"))
        _atlas(HEELS,frame,at,1.17,heel*0.99,Vector2(260,160))
    # Existing actor is composition stand-in, not an approved fist-kick frame.
    _actor(caster_now,Color("eee1cd"))
    _actor(OTHER,Color("bac2cc"))
    if heel>0.003:
        _halo(caster_now+Vector2(69,-90),17.0,heel*0.24,Color("fff1bd"))
    draw_string(ThemeDB.fallback_font,Vector2(28,33),
        "PHI THAN LIEN CUOC  /  BA QUYEN",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("fff0d1"))
    draw_string(ThemeDB.fallback_font,Vector2(28,59),
        "FIST02 R2 | TWIN HELIX FOOTWORK + 4 S SINGLE TARGET GUARD",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e8c6a4"))
    draw_string(ThemeDB.fallback_font,Vector2(28,680),
        "GODOT 4.7.2 COMPATIBILITY | VIEW ONLY | GUARD IS NOT A DAMAGE HIT",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f1d1b0"))
