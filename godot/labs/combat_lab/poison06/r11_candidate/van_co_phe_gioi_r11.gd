extends Control
## R11 owner-accepted preview, VIEW-ONLY Godot 4.7.2 Compatibility LAB.
## Original 48-frame sprite atlas required; R10 is unmodified and remains fallback.
const SKILL_ID := "tmb.skill.poison.co_doc.ultimate.human"
const EFFECT := "poison"
const SHAPE := "circle"
const DECLARED_RADIUS := 3.0
const DECLARED_TARGET_LIMIT := 3
const DECLARED_CAST_TIME := 1.10
const DECLARED_RANGE := 8.0
const DECLARED_DURATION := 8.0
const DECLARED_STACKS := 2
const ATLAS_PATH := "res://labs/combat_lab/poison06/r11_candidate/assets/realm_vortex_r11_48.png"
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const BACKGROUND: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const CELL := Vector2(256.0, 256.0)
const COLS := 8
const FRAME_COUNT := 48
const CAST_END := 1.10
const RIFT_OPEN := 2.04
const CONTACT_END := 3.80
const FADE_END := 5.13
const LOOP_SECONDS := 5.55
const HAND := Vector2(328.0, 428.0)
const CASTER := Vector2(272.0, 537.0)
const REALM := Vector2(913.0, 287.0)
const TARGETS := [Vector2(764,544), Vector2(924,534), Vector2(1085,542)]
const BRANDS := [
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_0.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_1.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_2.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_3.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_4.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_brand_5.svg")
]
const GU := [
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_0.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_1.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_2.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_3.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_4.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_5.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_6.svg"),
    preload("res://labs/combat_lab/poison06/assets/abyss_gu_7.svg")
]
var elapsed := 0.0
var paused := false
var _frames: Array[AtlasTexture] = []
var _atlas: Texture2D

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < RIFT_OPEN: return "flight"
    if t < CONTACT_END: return "realm_and_visual_contact"
    if t < FADE_END: return "fade"
    return "idle"

static func frame_float_at(t: float) -> float:
    # Continuous atlas time. Crossfade prevents 48 pose changes from looking
    # like 8 FPS slides. Endpoints blend forward into the next phase frame.
    if t < CAST_END: return clampf(t / CAST_END * 8.0, 0.0, 8.0)
    if t < RIFT_OPEN: return 8.0 + clampf((t - CAST_END) / (RIFT_OPEN - CAST_END) * 8.0, 0.0, 8.0)
    if t < CONTACT_END: return 16.0 + clampf((t - RIFT_OPEN) / (CONTACT_END - RIFT_OPEN) * 20.0, 0.0, 20.0)
    if t < FADE_END: return 36.0 + clampf((t - CONTACT_END) / (FADE_END - CONTACT_END) * 12.0, 0.0, 12.0)
    return 47.0

static func frame_index_at(t: float) -> int:
    return clampi(int(floor(frame_float_at(t))), 0, FRAME_COUNT - 1)

func _ready() -> void:
    custom_minimum_size = Vector2(1280,720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    if not ResourceLoader.exists(ATLAS_PATH):
        push_error("POI06_R11_ATLAS_MISSING: exact owner-accepted R11 PNG must be uploaded before Godot native QA.")
        set_process(false)
        return
    _atlas = load(ATLAS_PATH) as Texture2D
    if _atlas == null or _atlas.get_size() != Vector2(2048,1536):
        push_error("POI06_R11_ATLAS_INVALID: expected native 2048x1536 RGBA atlas.")
        set_process(false)
        return
    for i in range(FRAME_COUNT):
        var frame := AtlasTexture.new()
        frame.atlas = _atlas
        frame.region = Rect2(Vector2(float(i % COLS) * CELL.x, float(floori(float(i) / float(COLS))) * CELL.y), CELL)
        _frames.append(frame)
    set_process(true)
    queue_redraw()
    print("POI06_R11_READY atlas=48 alpha=true gameplay=false no_rig=true")

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed + maxf(delta, 0.0), LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            elapsed = 0.0
            queue_redraw()
        elif event.keycode == KEY_P:
            paused = not paused

func _paint(tex: Texture2D, center: Vector2, scale: float, alpha: float, angle: float = 0.0) -> void:
    if alpha <= 0.002: return
    draw_set_transform(center, angle, Vector2.ONE * scale)
    var dim := tex.get_size()
    draw_texture_rect(tex, Rect2(-dim / 2.0, dim), false, Color(1,1,1,alpha))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _paint_flipbook(frame_clock: float, center: Vector2, scale: float, alpha: float, angle: float = 0.0) -> void:
    var first := clampi(int(floor(frame_clock)), 0, FRAME_COUNT - 1)
    var second := mini(first + 1, FRAME_COUNT - 1)
    var between := smoothstep(0.0, 1.0, clampf(frame_clock - float(first), 0.0, 1.0))
    _paint(_frames[first], center, scale, alpha * (1.0 - between), angle)
    if second != first:
        _paint(_frames[second], center, scale, alpha * between, angle)

func _actor(center: Vector2, scale: float, tint: Color) -> void:
    draw_texture_rect_region(ACTOR, Rect2(center - Vector2(160,351) * scale, Vector2(320,384) * scale), Rect2(0,0,320,384), tint)

func _draw() -> void:
    var t := elapsed
    draw_texture_rect(BACKGROUND, Rect2(0,0,1280,720), false, Color.WHITE)
    if _frames.size() != FRAME_COUNT:
        draw_string(ThemeDB.fallback_font, Vector2(44,180), "R11 ATLAS MISSING — NOT A GODOT ART PASS", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.RED)
        return
    if t < CAST_END:
        var q := smoothstep(0.05, CAST_END, t)
        _paint_flipbook(frame_float_at(t), HAND, 0.30 + 0.33 * q, q * 0.84)
    elif t < RIFT_OPEN:
        var q := smoothstep(CAST_END, RIFT_OPEN, t)
        var point := HAND.lerp(REALM, q) + Vector2(0.0,-73.0 * sin(PI*q))
        _paint_flipbook(frame_float_at(t), point, 0.40 + 0.38*q, 0.92)
        for j in range(1,4):
            var old_q := clampf(q - 0.08*float(j), 0.0, 1.0)
            var old := HAND.lerp(REALM, old_q) + Vector2(0.0,-73.0*sin(PI*old_q))
            _paint_flipbook(8.0 + old_q*7.0, old, 0.28+0.28*old_q, 0.20-0.043*float(j))
    elif t < FADE_END:
        var opacity := smoothstep(RIFT_OPEN,RIFT_OPEN+0.27,t) * (1.0-smoothstep(4.18,FADE_END,t))
        var growth := smoothstep(RIFT_OPEN,2.66,t)
        _paint_flipbook(frame_float_at(t), REALM, 0.78+1.00*growth, opacity)
        _paint_flipbook(maxf(0.0,frame_float_at(t)-3.0), REALM + Vector2(-17,-9), 0.56+0.61*growth, opacity*0.23,-0.035)
    _actor(CASTER, 0.47, Color.WHITE)
    for idx in range(3):
        var target: Vector2 = TARGETS[idx]
        _actor(target, 0.45, [Color("d4d0db"),Color("bccfc8"),Color("c6c5d9")][idx])
        var start := 3.05 + float(idx)*0.095
        var gain := smoothstep(start,start+0.16,t) * (1.0-smoothstep(3.93,4.43,t))
        if gain > 0.001:
            var chest: Vector2 = target+Vector2(0,-72)
            var fi := posmod(int(floor((t-start)*11.0)), BRANDS.size())
            _paint(BRANDS[fi], chest, 0.29+gain*0.08,gain*0.71)
            for j in range(2):
                var a := t*3.8+float(j)*2.8+float(idx)
                _paint(GU[posmod(int(floor(t*14.0))+idx+j,GU.size())],chest+Vector2(cos(a)*32.0,sin(a)*21.0),0.09,gain*0.43)
    # QA identifiers belong in exact-SHA artifact metadata, not across the battle view.
