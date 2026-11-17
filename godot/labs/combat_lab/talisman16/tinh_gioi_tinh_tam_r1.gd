extends Control
## PAF06 R1 – Tĩnh Giới Tĩnh Tâm (passive always on).
## Quiet resident wind-energy; a persistent look, NOT a new cast/skill_hit.
## Three original transparent painted layers + genuine CPUParticles2D.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.passive_01.human"
const EFFECT := "passive"
const AI_PROFILE := "passive_always_on"
const ELEMENT := "wind"
const TARGET_LIMIT := 1
const CAST_TIME := 0.0
const COOLDOWN := 0.0
const DURATION := 0.0
const PROJECTILE_SPEED := 0.0
const COOLDOWN_RECOVERY_FACTOR := 0.015
const NO_CAST_NO_DAMAGE := true
const CYCLE := 3.0
const ATLAS_FRAME_COUNT := 24
const CELL := 320
const ATLAS_COLS := 6
const HERO_FEET := Vector2(632.0, 565.0)
const AURA_ANCHOR := Vector2(632.0, 467.0)
const BACKDROP: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const DECOY: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const AURA_BACK: Texture2D = preload("res://labs/combat_lab/talisman16/assets/paf06_back.webp")
const AURA_FRONT: Texture2D = preload("res://labs/combat_lab/talisman16/assets/paf06_front.webp")
const QUIET_HEART: Texture2D = preload("res://labs/combat_lab/talisman16/assets/paf06_heart.webp")

@export var passive_equipped: bool = true
var time_s: float = 0.0
var spirit_motes: CPUParticles2D
var particle_texture: Texture2D

static func decoy_foot(t: float) -> Vector2:
	return Vector2(948.0 + 26.0 * sin(t * 1.23), 541.0 + 9.0 * sin(t * 1.78))

static func pose_index(t: float) -> int:
	return posmod(int(floor(maxf(0.0, t) / CYCLE * ATLAS_FRAME_COUNT)), ATLAS_FRAME_COUNT)

static func pose_mix(t: float) -> float:
	return fposmod(maxf(0.0, t) / CYCLE * float(ATLAS_FRAME_COUNT), 1.0)

static func atlas_region(index: int) -> Rect2:
	var k: int = posmod(index, ATLAS_FRAME_COUNT)
	return Rect2((k % ATLAS_COLS) * CELL, int(k / ATLAS_COLS) * CELL, CELL, CELL)

func _make_soft_texture() -> Texture2D:
	var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	for y in range(48):
		for x in range(48):
			var d: float = Vector2(x - 23.5, y - 23.5).length() / 23.5
			var a: float = exp(-10.0 * d * d) * (1.0 - smoothstep(.72, 1.0, d))
			img.set_pixel(x, y, Color(1.0, 1.0, .91, a))
	return ImageTexture.create_from_image(img)

func _ready() -> void:
	custom_minimum_size = Vector2(1280.0, 720.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	particle_texture = _make_soft_texture()
	spirit_motes = CPUParticles2D.new()
	spirit_motes.amount = 16
	spirit_motes.texture = particle_texture
	spirit_motes.position = AURA_ANCHOR + Vector2(0.0, 18.0)
	spirit_motes.lifetime = 1.36
	spirit_motes.direction = Vector2(0.0, -1.0)
	spirit_motes.spread = 28.0
	spirit_motes.gravity = Vector2.ZERO
	spirit_motes.initial_velocity_min = 12.0
	spirit_motes.initial_velocity_max = 41.0
	spirit_motes.damping_min = 9.0
	spirit_motes.damping_max = 23.0
	spirit_motes.scale_amount_min = .11
	spirit_motes.scale_amount_max = .31
	spirit_motes.color = Color(.76, 1.0, .82, .73)
	spirit_motes.emitting = passive_equipped
	add_child(spirit_motes)
	set_process(true)
	print("PAF06_R1_READY passive_always_on=true original_rgba_layers=3 actual_particles=true fake_cast=false fake_hit=false")

func set_passive_equipped(enabled: bool) -> void:
	passive_equipped = enabled
	if spirit_motes != null:
		spirit_motes.emitting = enabled
	queue_redraw()

func _process(delta: float) -> void:
	time_s += maxf(0.0, delta)
	queue_redraw()

func _draw_atlas_blend(tex: Texture2D, destination: Rect2, alpha: float) -> void:
	var i0: int = pose_index(time_s)
	var i1: int = (i0 + 1) % ATLAS_FRAME_COUNT
	var mix_amount: float = pose_mix(time_s)
	# Two authored different alpha poses crossfade. No wave displacement,
	# no static sprite being inflated or warped as a fake animation.
	draw_texture_rect_region(tex, destination, atlas_region(i0), Color(1, 1, 1, alpha * (1.0 - mix_amount)))
	draw_texture_rect_region(tex, destination, atlas_region(i1), Color(1, 1, 1, alpha * mix_amount))

func _draw() -> void:
	draw_texture_rect(BACKDROP, Rect2(0, 0, 1280, 720), false)
	var moving: Vector2 = decoy_foot(time_s)
	var walk_frames: int = maxi(1, DECOY.get_frame_count("walk"))
	var walk_frame: int = int(time_s * 11.0) % walk_frames
	var enemy: Texture2D = DECOY.get_frame_texture("walk", walk_frame)
	draw_texture_rect(enemy, Rect2(moving - Vector2(48, 124), Vector2(96, 124)), false)
	if passive_equipped:
		_draw_atlas_blend(AURA_BACK, Rect2(AURA_ANCHOR - Vector2(118, 133), Vector2(236, 248)), .85)
	draw_texture_rect_region(ACTOR, Rect2(HERO_FEET - Vector2(72, 163), Vector2(144, 163)), Rect2(0, 0, 320, 384), Color(.97, .94, .88, 1.0))
	if passive_equipped:
		_draw_atlas_blend(AURA_FRONT, Rect2(AURA_ANCHOR - Vector2(107, 124), Vector2(214, 230)), .76)
		_draw_atlas_blend(QUIET_HEART, Rect2(AURA_ANCHOR - Vector2(67, 79), Vector2(134, 150)), .88)
