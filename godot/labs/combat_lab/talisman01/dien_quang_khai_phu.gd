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
    var gain := smoothstep(RELEASE_END,RELEASE_END+0.10,t)
    var head := bolt_position(t)
    # Light is born at the caster: a fading whole-path ion wake follows ONE moving head.
    # Prior R1 had a 0.19 short segment floating detached in the middle of the field.
    _halo(HAND,46.0,Color("a58ce2",gain*.26*(1.0-q*.35)))
    _halo(head,62.0,Color("8d73df",gain*.35))
    _halo(head,28.0,Color("dac3ff",gain*.55))
    _halo(head,11.0,Color("fff6ec",gain*.89))
    for i in range(31):
        var a := q*float(i)/31.0
        var b := q*float(i+1)/31.0
        var pa := _jitter_pos(a,2.4)
        var pb := _jitter_pos(b,2.4)
        var r := (float(i)+1.0)/31.0
        var grad := 0.12+0.88*pow(r,1.55)
        var alpha := gain*grad
        draw_line(pa,pb,Color("7860d6",alpha*.18),25.0,true)
        draw_line(pa,pb,Color("ad97ef",alpha*.40),11.0,true)
        draw_line(pa,pb,Color("e7d6fe",alpha*.91),3.6,true)
        draw_line(pa,pb,Color("fffaf4",alpha*.98),1.55,true)
    # Two brief, clearly secondary forks; the caster-to-head conductor stays dominant.
    if q>0.28:
        for j in range(2):
            var fork_q := q-0.048-float(j)*0.090
            if fork_q<=0.04: continue
            var root := _jitter_pos(fork_q,2.4)
            var tip := root+Vector2(-38.0+13.0*float(j),(-27.0 if j==0 else 31.0))
            var mid := root.lerp(tip,0.51)+Vector2(-4.0,(-8.0 if j==0 else 8.0))
            var branch_alpha := gain*(0.43-float(j)*0.11)
            draw_line(root,mid,Color("927ddd",branch_alpha*.25),9.0,true)
            draw_line(mid,tip,Color("8e78d7",branch_alpha*.17),7.0,true)
            draw_line(root,mid,Color("f3edff",branch_alpha),1.5,true)
            draw_line(mid,tip,Color("e2d3ff",branch_alpha*.69),1.0,true)

func _draw_contact(t: float) -> void:
    var hit := contact_gain(t)
    var remnant := smoothstep(CONTACT_AT,CONTACT_AT+0.19,t)*(1.0-smoothstep(1.83,FADE_END,t))
    if hit>0.003:
        _halo(IMPACT,109.0,Color("8572d8",hit*.22))
        _halo(IMPACT,57.0,Color("c3aeff",hit*.40))
        _halo(IMPACT,19.0,Color("fff7fa",hit*.82))
        # Three different local CURRENT PATHS, all moving and decaying.
        # No symmetrical starburst or static UI rings; preserve the victim's face.
        var currents: Array = [
            [Vector2(-52,-22),Vector2(-37,-29),Vector2(-19,-19),Vector2(-5,-26),Vector2(11,-12),Vector2(34,-8)],
            [Vector2(-9,-9),Vector2(9,-21),Vector2(21,-35),Vector2(30,-40)],
            [Vector2(-12,7),Vector2(3,19),Vector2(-2,30),Vector2(13,43)]
        ]
        for j in range(currents.size()):
            var pts: Array = currents[j]
            for k in range(pts.size()-1):
                var la: Vector2 = pts[k]
                var lb: Vector2 = pts[k+1]
                var p1 := IMPACT+la+Vector2(0.0,2.1*sin(t*43.0+float(k)*1.7+float(j)))
                var p2 := IMPACT+lb+Vector2(0.0,2.7*sin(t*48.0+float(k)*1.5+float(j)*2.2))
                var gain := hit*(1.0-0.17*float(j))
                draw_line(p1,p2,Color("977dd6",gain*.26),8.2,true)
                draw_line(p1,p2,Color("c7aeef",gain*.50),3.8,true)
                draw_line(p1,p2,Color("fff5ef",gain*.84),1.25,true)
        for j in range(6):
            var k := float(j)
            var angle := k*2.399+0.38
            var rr := 14.0+float(j%3)*5.0
            var p := IMPACT+Vector2(cos(angle)*rr,sin(angle)*rr*.79)
            var step := Vector2(cos(angle)* (8.0+float(j%4)*4.0),sin(angle)*(8.0+float(j%2)*5.0))
            _halo(p+step,7.0,Color("decaff",hit*.36))
            draw_line(p,p+step,Color("c7b0f3",hit*.24),4.0,true)
            draw_line(p,p+step,Color("fff1f6",hit*.54),1.0,true)
    if remnant>0.003:
        var tails: Array = [
            [Vector2(-11,8),Vector2(-1,21),Vector2(-12,33)],
            [Vector2(7,-9),Vector2(18,-1),Vector2(13,14)]
        ]
        for path in tails:
            for k in range(path.size()-1):
                var p1: Vector2=IMPACT+path[k]
                var p2: Vector2=IMPACT+path[k+1]
                draw_line(p1,p2,Color("a496e2",remnant*.16),4.6,true)
                draw_line(p1,p2,Color("edddff",remnant*.30),1.0,true)
