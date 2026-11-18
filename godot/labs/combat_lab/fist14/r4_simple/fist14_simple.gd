extends Control
## FIST14 R4 simple LAB preview: one original sprite, no gameplay writes.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_04.human"
const EFFECT := "mark"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DURATION := 6.0
const RANGE := 2.8
const PROJECTILE_SPEED := 0.0
const HIT_COUNT_DECLARED := false
const RELEASE_TIME := 0.45
const CONTACT_TIME := 0.90
const CONTACT_END := 1.16
const LOOP_END := 1.65

const BG: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const IDLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER_FRAMES: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const FIST: Texture2D = preload("res://labs/combat_lab/fist14/r4_simple/assets/fist14_closed_fist.png")
const GLOW: Texture2D = preload("res://labs/combat_lab/fist14/r4_simple/assets/fist14_edge_glow.png")
const CONTACT: Texture2D = preload("res://labs/combat_lab/fist14/r4_simple/assets/fist14_local_contact.png")

var elapsed := 0.0
var paused := false

static func phase_at(t: float) -> String:
	if t < RELEASE_TIME: return "windup"
	if t < CONTACT_TIME: return "fist_travel"
	if t < CONTACT_END: return "local_contact"
	return "dissipate"

static func caster_at(_t: float) -> Vector2:
	return Vector2(431.0, 550.0)

static func foe_at(t: float) -> Vector2:
	return Vector2(806.0 - 34.0 * smoothstep(0.12, 1.35, t) + 17.0 * smoothstep(1.35, LOOP_END, t), 545.0)

static func fist_at(t: float) -> Vector2:
	var q := smoothstep(RELEASE_TIME, CONTACT_TIME, clampf(t, RELEASE_TIME, CONTACT_TIME))
	var start := caster_at(t) + Vector2(62.0, -92.0)
	var end := foe_at(t) + Vector2(-58.0, -80.0)
	return start.lerp(end, q)

static func contact_opacity(t: float) -> float:
	if t < CONTACT_TIME or t >= CONTACT_END: return 0.0
	return 1.0 - smoothstep(CONTACT_TIME + 0.07, CONTACT_END, t)

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("FIST14_R4_SIMPLE_NATIVE_READY view_only=true source_sprite=one mark_visual=false")

func _process(delta: float) -> void:
	if paused: return
	elapsed = fposmod(elapsed + maxf(0.0, delta), LOOP_END)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE: elapsed = 0.0
		elif event.keycode == KEY_P: paused = not paused

func _actor(feet: Vector2) -> void:
	draw_texture_rect_region(IDLE, Rect2(feet - Vector2(69, 151), Vector2(138, 169)),
		Rect2(0, 0, 320, 384), Color.WHITE)

func _monster(feet: Vector2, t: float) -> void:
	var count := MONSTER_FRAMES.get_frame_count("walk")
	var tex: Texture2D = MONSTER_FRAMES.get_frame_texture("walk", int(floor(t * 13.0)) % maxi(1, count))
	draw_texture_rect(tex, Rect2(feet - Vector2(76, 139), Vector2(152, 139)), false, Color.WHITE)

func _draw() -> void:
	draw_texture_rect(BG, Rect2(0, 0, 1280, 720), false, Color.WHITE)
	var caster := caster_at(elapsed)
	var foe := foe_at(elapsed)
	_actor(caster)
	_monster(foe, elapsed)
	if elapsed >= RELEASE_TIME and elapsed < CONTACT_TIME:
		var center := fist_at(elapsed)
		var q := clampf((elapsed - RELEASE_TIME) / (CONTACT_TIME - RELEASE_TIME), 0.0, 1.0)
		var alpha := smoothstep(0.0, 0.08, q) * (1.0 - smoothstep(0.92, 1.0, q))
		var size := Vector2(126.0, 148.0) * (1.0 + 0.05 * sin(q * PI))
		draw_texture_rect(GLOW, Rect2(center - size * 0.57, size * 1.14), false, Color(1, 1, 1, alpha * 0.34))
		# One short, thin wake behind the moving fist; this is presentation only.
		var previous := fist_at(maxf(RELEASE_TIME, elapsed - 0.09))
		draw_line(previous, center, Color(0.72, 0.035, 0.075, alpha * 0.42), 4.0, true)
		draw_texture_rect(FIST, Rect2(center - size * 0.5, size), false, Color(1, 1, 1, alpha))
	var flash_alpha := contact_opacity(elapsed)
	if flash_alpha > 0.002:
		var hit := foe + Vector2(-61.0, -82.0)
		draw_texture_rect(CONTACT, Rect2(hit - Vector2(43, 40), Vector2(86, 80)), false,
			Color(1, 1, 1, flash_alpha))
