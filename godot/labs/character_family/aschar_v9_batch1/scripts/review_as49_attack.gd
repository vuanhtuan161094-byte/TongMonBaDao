extends Node2D

var rendered_frames := 0
var attack_actor: AnimatedSprite2D
var walk_actor: AnimatedSprite2D

func _ready() -> void:
	var sprite_frames: SpriteFrames = load("res://assets/spriteframes/AS49_V9_candidate.tres")
	attack_actor = AnimatedSprite2D.new()
	attack_actor.sprite_frames = sprite_frames
	attack_actor.animation = "Attack_Front"
	attack_actor.position = Vector2(450, 520)
	attack_actor.scale = Vector2(0.56, 0.56)
	add_child(attack_actor)
	attack_actor.play()
	attack_actor.animation_finished.connect(_replay_after_pause)
	walk_actor = AnimatedSprite2D.new()
	walk_actor.sprite_frames = sprite_frames
	walk_actor.animation = "Walk_Front"
	walk_actor.position = Vector2(960, 569)
	walk_actor.scale = Vector2(0.17, 0.17)
	add_child(walk_actor)
	walk_actor.play()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("211a20"), true)
	draw_rect(Rect2(36, 32, 1208, 656), Color("30242b"), true)
	draw_rect(Rect2(36, 32, 1208, 5), Color("c9a96a"), true)
	draw_line(Vector2(72, 111), Vector2(1208, 111), Color("7c6268"), 1.0)
	draw_line(Vector2(130, 638), Vector2(690, 638), Color("9c695e"), 2.0)
	draw_line(Vector2(780, 605), Vector2(1138, 605), Color("9c695e"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(72, 80), "AS-CHAR-49  |  KIẾM TU NỮ", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("f2e7c9"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 151), "ATTACK_FRONT  ·  BODY CEL  ·  SEPARATE WEAPON SLOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("e6a8b2"))
	draw_string(ThemeDB.fallback_font, Vector2(130, 190), "ATTACK MOTION REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d2b87c"))
	draw_string(ThemeDB.fallback_font, Vector2(815, 190), "MAP SCALE  ≈ 73 PX", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d2b87c"))
	draw_string(ThemeDB.fallback_font, Vector2(760, 248), "4 DISTINCT BODY POSES", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f2e7c9"))
	draw_string(ThemeDB.fallback_font, Vector2(760, 282), "windup → draw → release → recovery", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("cec0b4"))
	draw_string(ThemeDB.fallback_font, Vector2(760, 315), "SWORD OVERLAY / GRIP METADATA PENDING", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e3a991"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 665), "400×440 registered body · foot baseline y=430 · candidate only", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("cec0b4"))

func _process(_delta: float) -> void:
	rendered_frames += 1
	if rendered_frames == 8:
		_capture("AS49_ATTACK_FRONT_WINDUP_NATIVE_1280x720.png")
	elif rendered_frames == 17:
		_capture("AS49_ATTACK_FRONT_DRAW_NATIVE_1280x720.png")
	elif rendered_frames == 26:
		_capture("AS49_ATTACK_FRONT_RELEASE_NATIVE_1280x720.png")
	elif rendered_frames == 35:
		_capture("AS49_ATTACK_FRONT_RECOVERY_NATIVE_1280x720.png")

func _capture(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path("res://captures/" + file_name))
	print("NATIVE_VIEWPORT_CAPTURE=", file_name, " size=", image.get_size(), " error=", error)

func _replay_after_pause() -> void:
	await get_tree().create_timer(0.9).timeout
	attack_actor.play("Attack_Front")
