extends Control
## Talisman school 01 — Điện Quang Khai Phù (Human).
## Original 12-pose ink/fiber/foil atlas + one moving white-violet electric filament.
## VFX ONLY. Single demo target; no damage, status, target or SaveService writes.
const SKILL_ID := "tmb.skill.talisman.loi_phu.active_01.human"
const EFFECT := "damage"
const ELEMENT := "lightning"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const DECLARED_CAST_TIME := 0.50
const DECLARED_COOLDOWN := 9.40
const DECLARED_RANGE := 8.50
const DECLARED_PROJECTILE_SPEED := 10.0
const CASTER := Vector2(329.0, 544.0)
const HAND := Vector2(399.0, 417.0)
const VICTIM := Vector2(961.0, 541.0)
const IMPACT := Vector2(949.0, 454.0)
const CHARGE_END := 0.50
const RELEASE_END := 0.72
const CONTACT_AT := 1.43
const CONTACT_END := 1.76
const FADE_END := 2.66
const LOOP_SECONDS := 3.13
const ATLAS: Texture2D = preload("res://labs/combat_lab/talisman01/assets/thunder_talisman_atlas.png")
const BACKDROP: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const STANDIN_ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
var elapsed := 0.0
var paused := false
var _talisman: Sprite2D
var _cell: AtlasTexture
var _glow: Texture2D

static func phase_at(t: float) -> String:
    if t < CHARGE_END: return "ink_charge"
    if t < RELEASE_END: return "seal_release"
    if t < CONTACT_AT: return "electric_flight"
    if t < CONTACT_END: return "demo_contact"
    if t < FADE_END: return "dissolve"
    return "idle"

static func travel_q(t: float) -> float:
    if t <= RELEASE_END: return 0.0
    return smoothstep(RELEASE_END, CONTACT_AT, t)

static func bolt_position(t: float) -> Vector2:
    var q := travel_q(t)
    return HAND.lerp(IMPACT, q) + Vector2(0.0, -117.0 * sin(PI * q))

static func contact_gain(t: float) -> float:
    if t < CONTACT_AT or t >= CONTACT_END: return 0.0
    return smoothstep(CONTACT_AT, CONTACT_AT + 0.066, t) * (1.0 - smoothstep(CONTACT_AT+0.11, CONTACT_END, t))

static func seal_gain(t: float) -> float:
    if t <= 0.025 or t >= 0.99: return 0.0
    return smoothstep(0.025, 0.18, t) * (1.0 - smoothstep(0.68, 0.99, t))

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0, 720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _glow = _soft_circle()
    _cell = AtlasTexture.new()
    _cell.atlas = ATLAS
    _cell.region = Rect2(0.0, 0.0, 300.0, 360.0)
    _talisman = Sprite2D.new()
    _talisman.texture = _cell
    _talisman.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _talisman.z_index = 4
    add_child(_talisman)
    _update_seal()
    set_process(true)
    queue_redraw()
    print("VFX_TAL01_READY id=", SKILL_ID, " view_only=true no_rig=true atlas_poses=12")

func _soft_circle() -> Texture2D:
    var im := Image.create(96, 96, false, Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p := (Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var falloff := exp(-5.5 * p.length_squared()) * (1.0-smoothstep(0.74,1.0,p.length()))
            im.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(falloff,0.0,1.0)))
    return ImageTexture.create_from_image(im)

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed + maxf(delta,0.0), LOOP_SECONDS)
    _update_seal()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        _update_seal()
    elif event.keycode == KEY_P:
        paused = not paused

func _update_seal() -> void:
    var t := elapsed
    var gain := seal_gain(t)
    _talisman.visible = gain > 0.003
    if not _talisman.visible: return
    var q := clampf(t / 0.86, 0.0, 1.0)
    var f := clampi(int(floor(q * 11.99)),0,11)
    _cell.region = Rect2(float(f%3)*300.0, float(f/3)*360.0, 300.0, 360.0)
    _talisman.position = HAND + Vector2(-3.0, -85.0-15.0*sin(minf(q,1.0)*PI))
    _talisman.rotation = -0.12 + 0.085 * sin(t*9.0) - 0.24 * smoothstep(0.52,0.94,t)
    _talisman.scale = Vector2(0.44+0.052*q, 0.44+0.047*q)
    _talisman.modulate = Color(1.0,1.0,1.0,gain)

func _halo(at: Vector2, radius: float, tint: Color) -> void:
    if tint.a <= 0.002: return
    draw_texture_rect(_glow, Rect2(at-Vector2.ONE*radius,Vector2.ONE*radius*2.0),false,tint)

func _draw_actor(at: Vector2, tint: Color) -> void:
    draw_texture_rect_region(STANDIN_ACTOR,Rect2(at.x-72.0,at.y-163.0,144.0,163.0),Rect2(0,0,320,384),tint)

func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false,Color.WHITE)
    # Low, translucent ground shade prevents a circle-as-AOE misunderstanding.
    draw_texture_rect(_glow,Rect2(217.0,524.0,233.0,47.0),false,Color("7062b8",0.18))
    draw_texture_rect(_glow,Rect2(849.0,524.0,232.0,47.0),false,Color("786687",0.13))
    var charge := seal_gain(t)
    if charge > 0.004:
        _halo(HAND+Vector2(0,-85),109.0,Color("7f6de3",charge*0.22))
        _halo(HAND+Vector2(0,-85),55.0,Color("c5b4ff",charge*0.30))
        # Unequal sparks converge onto actual parchment, not a floating UI circle.
        for i in range(7):
            var a := float(i)*2.399+0.40*t
            var pull := smoothstep(0.02,CHARGE_END,t)
            var r := 91.0-53.0*pull+float(i%3)*4.0
            var center := HAND+Vector2(0,-85)
            var p := center+Vector2(cos(a)*r,sin(a)*r*0.71)
            var shift := Vector2(-sin(a),cos(a)*.71)
            var amp := charge*(0.51+0.1*float(i%3))
            draw_line(p-shift*17.0,p,Color("8a77d0",amp*.25),6.0,true)
            draw_line(p-shift*11.0,p,Color("d2b7f4",amp*.63),2.0,true)
            _halo(p,9.0,Color("f6edff",amp*.70))
    # Real actor silhouettes remain above terrain and under energy.
    _draw_actor(CASTER,Color("d8cee1"))
    _draw_actor(VICTIM,Color("a6b8cc"))
    if t >= RELEASE_END and t < CONTACT_AT:
        _draw_bolt(t)
    if t >= CONTACT_AT and t < FADE_END:
        _draw_contact(t)
    if t >= 1.80 and t < FADE_END:
        var dust := 1.0-smoothstep(1.83,FADE_END,t)
        for i in range(9):
            var k := float(i)
            var spin := k*2.399 + 0.2
            var spread := 22.0+(t-1.8)*(41.0+5.0*float(i%3))
            var at := IMPACT+Vector2(cos(spin)*spread,sin(spin)*spread*0.72)
            _halo(at,5.0,Color("bcb2ef",dust*.17))

func _jitter_pos(q: float,seed: float) -> Vector2:
    var pt := HAND.lerp(IMPACT,q)+Vector2(0.0,-117.0*sin(PI*q))
    var envelope := sin(PI*q)
    return pt + Vector2(0.0, (4.0*sin(q*58.0+seed)+2.5*sin(q*97.0+seed*2.2))*envelope)

func _draw_bolt(t: float) -> void:
    var q := travel_q(t)
    var tail := maxf(0.0,q-0.19)
    var gain := smoothstep(RELEASE_END,RELEASE_END+0.12,t)*(1.0-smoothstep(CONTACT_AT-0.10,CONTACT_AT,t)*0.19)
    var head := bolt_position(t)
    _halo(head,54.0,Color("8b7add",gain*.34))
    _halo(head,25.0,Color("dbc7ff",gain*.49))
    _halo(head,9.0,Color("fffaf9",gain*.79))
    for i in range(17):
        var a := tail+(q-tail)*float(i)/17.0
        var b := tail+(q-tail)*float(i+1)/17.0
        var pa := _jitter_pos(a,2.4)
        var pb := _jitter_pos(b,2.4)
        var r := (float(i)+1.0)/18.0
        var alpha := gain*(0.20+0.8*r)
        draw_line(pa,pb,Color("725bdf",alpha*.19),22.0,true)
        draw_line(pa,pb,Color("ab91f1",alpha*.34),9.0,true)
        draw_line(pa,pb,Color("d9d2ff",alpha*.83),3.4,true)
        draw_line(pa,pb,Color("fff9f1",alpha),1.45,true)
    # Only 2 restrained forks around the moving head, avoiding repetitive spoked lightning.
    if q>0.32:
        for j in range(2):
            var fork_q := q-0.07-float(j)*0.053
            if fork_q < tail: continue
            var root := _jitter_pos(fork_q,2.4)
            var fork_tip := root+Vector2(-31.0+6.0*float(j),(-29.0 if j==0 else 31.0))
            var middle := root.lerp(fork_tip,0.47)+Vector2(4,-7.0 if j==0 else 7.0)
            draw_line(root,middle,Color("9f8bdc",gain*.24),8.0,true)
            draw_line(middle,fork_tip,Color("a99bef",gain*.17),5.0,true)
            draw_line(root,middle,Color("f5eeff",gain*.65),1.4,true)
            draw_line(middle,fork_tip,Color("eae2ff",gain*.4),1.1,true)

func _draw_contact(t: float) -> void:
    var hit := contact_gain(t)
    var residual := smoothstep(CONTACT_AT,CONTACT_AT+0.18,t)*(1.0-smoothstep(1.86,FADE_END,t))
    if hit>0.004:
        _halo(IMPACT,129.0,Color("8673d8",hit*.22))
        _halo(IMPACT,67.0,Color("ab9bfa",hit*.39))
        _halo(IMPACT,27.0,Color("fffcff",hit*.79))
        # Single localized electrical cut, never another fake hit.
        for i in range(6):
            var a := float(i)*PI/3.0+0.10
            var p1 := IMPACT + Vector2(cos(a)*17.0,sin(a)*18.0)
            var p2 := IMPACT + Vector2(cos(a)* (51.0+float(i%3)*9.0),sin(a)*(47.0+float(i%2)*8.0))
            draw_line(p1,p2,Color("bba4f7",hit*.36),6.5,true)
            draw_line(p1,p2,Color("ffecff",hit*.77),1.7,true)
    if residual>0.001:
        var fall := residual*.65
        for k in range(3):
            var f := float(k)
            var p1 := IMPACT+Vector2(-22.0+f*21.0,-32.0-f*7.0)
            var p2 := IMPACT+Vector2(-29.0+f*26.0,22.0+f*3.0)
            draw_line(p1,p2,Color("a08add",fall*.35),5.0,true)
            draw_line(p1,p2,Color("e9dff9",fall*.68),1.1,true)
