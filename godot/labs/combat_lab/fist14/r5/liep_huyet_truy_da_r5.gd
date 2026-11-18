extends Control
## FIST14 R5 V4 G3.5 LAB only. Uses original authored RGBA poses; no gameplay calls.
const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_04.human"
const EFFECT := "mark"
const ELEMENT := "nether"
const SHAPE := "single_target"
const TARGET_LIMIT := 1
const CAST_TIME := 0.45
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const DECLARED_DURATION := 6.0
const PROJECTILE_SPEED := 0.0
const HIT_COUNT_DECLARED := false
const SIMULATED_CONTACT_TIME := 0.90
const CONTACT_END := 1.04
const RECOIL_END := 1.27
const MARK_END := SIMULATED_CONTACT_TIME + DECLARED_DURATION
const FADE_END := MARK_END + 0.30
const DEMO_LOOP_SECONDS := 8.0
const CELL := Vector2(2048.0, 1024.0)

const ATTACK_ATLAS: Texture2D = preload("res://labs/combat_lab/fist14/r5/assets/f14_r5_attack_pose_atlas.png")
const CONTACT_ATLAS: Texture2D = preload("res://labs/combat_lab/fist14/r5/assets/f14_r5_contact_recoil_atlas.png")
const MARK_ATLAS: Texture2D = preload("res://labs/combat_lab/fist14/r5/assets/f14_r5_meridian_mark_atlas.png")
const BG_DARK: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const BG_LIGHT: Texture2D = preload("res://art/source_a_env02a/env01_assets/terrain/stone_courtyard.png")
const CASTER: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const WALK: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")

const SOURCE_SIZE := [Vector2(1536, 1024), Vector2(1774, 887), Vector2(1774, 887), Vector2(1774, 887), Vector2(1774, 887)]
const FOCUS_SOURCE := [Vector2(1130, 570), Vector2(1470, 590), Vector2(1470, 500), Vector2(1460, 470), Vector2(1210, 530)]
const SOURCE_CELL_OFFSET := [Vector2(256, 0), Vector2(137, 68), Vector2(137, 68), Vector2(137, 68), Vector2(137, 68)]
const ATTACK_COLUMNS := 2
const CONTACT_COLUMNS := 2
const MARK_SOURCE_SIZE := Vector2(1774, 887)
const MARK_SOURCE_CELL_OFFSET := Vector2(137, 68)
const MARK_FOCUS_SOURCE := Vector2(885, 450)

var elapsed := 0.0
var paused := false

static func phase_at(t: float) -> String:
	if t < CAST_TIME:
		return "charge"
	if t < SIMULATED_CONTACT_TIME:
		return "target_local_punch"
	if t < CONTACT_END:
		return "one_visual_contact"
	if t < RECOIL_END:
		return "recoil"
	if t < MARK_END:
		return "one_mark_sustain"
	if t < FADE_END:
		return "mark_fade"
	return "idle"

static func caster_feet_at(_t: float) -> Vector2:
	return Vector2(424.0, 548.0)

static func target_feet_at(t: float) -> Vector2:
	var approach := smoothstep(0.14, 1.02, clampf(t, 0.14, 1.02))
	var return_step := smoothstep(3.4, 5.8, clampf(t, 3.4, 5.8))
	return Vector2(858.0 - 78.0 * approach + 18.0 * return_step, 548.0)

static func target_chest_at(t: float) -> Vector2:
	return target_feet_at(t) + Vector2(0.0, -70.0)

static func caster_hand_at(t: float) -> Vector2:
	return caster_feet_at(t) + Vector2(28.0, -62.0)

static func target_anchor_at(target_index: int, t: float) -> Vector2:
	if target_index != 0:
		return Vector2(-9999.0, -9999.0)
	return target_chest_at(t)

static func contact_anchor_at(t: float) -> Vector2:
	return target_anchor_at(0, t) + Vector2(0.0, 18.0)

static func mark_anchor_at(target_index: int, t: float) -> Vector2:
	if target_index != 0:
		return Vector2(-9999.0, -9999.0)
	return target_feet_at(t) + Vector2(18.0, -67.0)

static func mark_opacity(t: float) -> float:
	if t < SIMULATED_CONTACT_TIME or t >= FADE_END:
		return 0.0
	return 1.0 - smoothstep(MARK_END, FADE_END, t)

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if ATTACK_ATLAS.get_size() != Vector2(4096.0, 2048.0):
		push_error("FIST14_R5_ATTACK_ATLAS_SIZE_FAIL")
		get_tree().quit(4)
		return
	if CONTACT_ATLAS.get_size() != Vector2(4096.0, 1024.0):
		push_error("FIST14_R5_CONTACT_ATLAS_SIZE_FAIL")
		get_tree().quit(4)
		return
	if MARK_ATLAS.get_size() != Vector2(2048.0, 1024.0):
		push_error("FIST14_R5_MARK_ATLAS_SIZE_FAIL")
		get_tree().quit(4)
		return
	print("FIST14_R5_G35_NATIVE_READY view_only=true one_target=true no_projectile=true no_rig=true")

func _process(delta: float) -> void:
	if paused:
		return
	elapsed += maxf(0.0, delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			elapsed = 0.0
		elif event.keycode == KEY_P:
			paused = not paused

func _draw_pose(texture: Texture2D, frame: int, columns: int, anchor: Vector2, scale: float, opacity: float, source_size: Vector2, source_offset: Vector2, focus_source: Vector2) -> void:
	if opacity <= 0.002:
		return
	var cell_origin := Vector2(float(frame % columns) * CELL.x, float(int(frame / columns)) * CELL.y)
	var focus_cell := source_offset + focus_source
	var destination := Rect2(anchor - focus_cell * scale, CELL * scale)
	var region := Rect2(cell_origin, CELL)
	draw_texture_rect_region(texture, destination, region, Color(1.0, 1.0, 1.0, clampf(opacity, 0.0, 1.0)), false, true)

func _draw_actor(feet: Vector2) -> void:
	draw_texture_rect_region(CASTER, Rect2(feet - Vector2(69.0, 151.0), Vector2(138.0, 169.0)), Rect2(0, 0, 320, 384), Color.WHITE)

func _draw_target(feet: Vector2, t: float) -> void:
	var count := WALK.get_frame_count("walk")
	var texture: Texture2D = WALK.get_frame_texture("walk", int(floor(t * 13.0)) % maxi(1, count))
	draw_texture_rect(texture, Rect2(feet - Vector2(76.0, 139.0), Vector2(152.0, 139.0)), false, Color.WHITE)

func _draw() -> void:
	var run_index := int(floor(elapsed / DEMO_LOOP_SECONDS)) % 2
	var t := fposmod(elapsed, DEMO_LOOP_SECONDS)
	var background := BG_DARK if run_index == 0 else BG_LIGHT
	draw_texture_rect(background, Rect2(0.0, 0.0, 1280.0, 720.0), run_index == 1, Color.WHITE)
	var caster := caster_feet_at(t)
	var target := target_feet_at(t)
	var anchor := target_anchor_at(0, t)

	# Original fist sprites are back-layered under the characters until contact.
	if t >= 0.10 and t < CAST_TIME:
		var charge_alpha := smoothstep(0.10, 0.17, t) * (1.0 - smoothstep(0.38, CAST_TIME, t))
		_draw_pose(ATTACK_ATLAS, 0, ATTACK_COLUMNS, caster_hand_at(t), 0.09, charge_alpha, SOURCE_SIZE[0], SOURCE_CELL_OFFSET[0], FOCUS_SOURCE[0])
	elif t >= CAST_TIME and t < SIMULATED_CONTACT_TIME:
		if t < 0.62:
			var release_alpha := smoothstep(CAST_TIME, 0.50, t) * (1.0 - smoothstep(0.57, 0.62, t))
			_draw_pose(ATTACK_ATLAS, 1, ATTACK_COLUMNS, anchor, 0.105, release_alpha, SOURCE_SIZE[1], SOURCE_CELL_OFFSET[1], FOCUS_SOURCE[1])
		else:
			var peak_alpha := 1.0 - smoothstep(0.84, SIMULATED_CONTACT_TIME, t)
			_draw_pose(ATTACK_ATLAS, 2, ATTACK_COLUMNS, anchor, 0.10, peak_alpha, SOURCE_SIZE[2], SOURCE_CELL_OFFSET[2], FOCUS_SOURCE[2])

	_draw_actor(caster)
	_draw_target(target, t)

	if t >= SIMULATED_CONTACT_TIME and t < CONTACT_END:
		var contact_alpha := 1.0 - smoothstep(SIMULATED_CONTACT_TIME + 0.06, CONTACT_END, t)
		_draw_pose(CONTACT_ATLAS, 0, CONTACT_COLUMNS, contact_anchor_at(t), 0.075, contact_alpha, SOURCE_SIZE[3], SOURCE_CELL_OFFSET[3], FOCUS_SOURCE[3])
	elif t >= CONTACT_END and t < RECOIL_END:
		var recoil_alpha := 1.0 - smoothstep(CONTACT_END, RECOIL_END, t)
		_draw_pose(CONTACT_ATLAS, 1, CONTACT_COLUMNS, contact_anchor_at(t), 0.085, recoil_alpha, SOURCE_SIZE[4], SOURCE_CELL_OFFSET[4], FOCUS_SOURCE[4])

	var mark_alpha := mark_opacity(t)
	if mark_alpha > 0.002:
		_draw_pose(MARK_ATLAS, 0, 1, mark_anchor_at(0, t), 0.052, mark_alpha, MARK_SOURCE_SIZE, MARK_SOURCE_CELL_OFFSET, MARK_FOCUS_SOURCE)
