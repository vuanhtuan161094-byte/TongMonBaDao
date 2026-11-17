extends Node2D

var identity := "AS48"
var rendered_frames := 0
var current_clip := "Walk_Front"
var before_large: AnimatedSprite2D
var after_large: AnimatedSprite2D
var before_map: AnimatedSprite2D
var after_map: AnimatedSprite2D

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("identity="):
			identity = arg.trim_prefix("identity=")
	if identity not in ["AS48", "AS49"]:
		push_error("UNSUPPORTED_IDENTITY=" + identity)
		get_tree().quit(2)
		return
	var before_path := "res://assets/spriteframes/%s_V9_candidate.tres" % identity
	var after_path := "res://assets/spriteframes/%s_V9_consistency_v2.tres" % identity
	var before_frames: SpriteFrames = load(before_path)
	var after_frames: SpriteFrames = load(after_path)
	if before_frames == null or after_frames == null:
		push_error("SPRITEFRAMES_LOAD_FAIL before=" + str(before_frames) + " after=" + str(after_frames))
		get_tree().quit(3)
		return
	before_large = _make_actor(before_frames, Vector2(320, 470), 0.50)
	after_large = _make_actor(after_frames, Vector2(960, 470), 0.50)
	before_map = _make_actor(before_frames, Vector2(320, 619), 0.17)
	after_map = _make_actor(after_frames, Vector2(960, 619), 0.17)
	for actor in [before_large, after_large, before_map, after_map]:
		actor.animation_finished.connect(_on_attack_finished.bind(actor))
		actor.play("Walk_Front")
	queue_redraw()
	print("CONSISTENCY_REVIEW_START identity=", identity, " walk_fps=8 attack_fps=7 output=before_vs_registered_v2 split_view=true")

func _make_actor(frames: SpriteFrames, actor_position: Vector2, actor_scale: float) -> AnimatedSprite2D:
	var actor := AnimatedSprite2D.new()
	actor.sprite_frames = frames
	actor.position = actor_position
	actor.scale = Vector2(actor_scale, actor_scale)
	actor.centered = true
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(actor)
	return actor

func _process(_delta: float) -> void:
	rendered_frames += 1
	if rendered_frames == 90:
		_capture("%s_CONSISTENCY_WALK_NATIVE_1280x720.png" % identity)
	elif rendered_frames == 180:
		current_clip = "Attack_Front"
		_play_clip(current_clip)
		queue_redraw()
	elif rendered_frames == 184:
		_capture("%s_CONSISTENCY_ATTACK_WINDUP_NATIVE_1280x720.png" % identity)
	elif rendered_frames == 210:
		_capture("%s_CONSISTENCY_ATTACK_NATIVE_1280x720.png" % identity)
	elif rendered_frames == 359:
		_capture("%s_CONSISTENCY_FINAL_NATIVE_1280x720.png" % identity)
	elif rendered_frames >= 360:
		print("CONSISTENCY_REVIEW_END identity=", identity, " frames=", rendered_frames, " capture_fps=60 walk_authored_fps=8 attack_authored_fps=7")
		get_tree().quit(0)

func _play_clip(name: String) -> void:
	for actor in [before_large, after_large, before_map, after_map]:
		actor.play(name)

func _on_attack_finished(actor: AnimatedSprite2D) -> void:
	if current_clip == "Attack_Front":
		actor.play("Attack_Front")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("1d2229"), true)
	draw_rect(Rect2(34, 28, 1212, 664), Color("282e37"), true)
	draw_rect(Rect2(34, 28, 1212, 5), Color("c9a96a"), true)
	draw_line(Vector2(640, 78), Vector2(640, 682), Color("68717d"), 2.0)
	draw_line(Vector2(88, 575), Vector2(552, 575), Color("b9a477"), 2.0)
	draw_line(Vector2(728, 575), Vector2(1192, 575), Color("b9a477"), 2.0)
	draw_line(Vector2(88, 655), Vector2(552, 655), Color("8a9299"), 1.0)
	draw_line(Vector2(728, 655), Vector2(1192, 655), Color("8a9299"), 1.0)
	var char_name := "KIẾM TU NAM" if identity == "AS48" else "KIẾM TU NỮ"
	draw_string(ThemeDB.fallback_font, Vector2(72, 71), "%s · %s" % [identity, char_name], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("f2e7c9"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 108), "%s · WALK 8 FPS / ATTACK 7 FPS · GODOT 4.7.2" % current_clip.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("becbd2"))
	draw_string(ThemeDB.fallback_font, Vector2(226, 150), "BEFORE · ORIGINAL REGISTER", HORIZONTAL_ALIGNMENT_CENTER, 270, 18, Color("e7baab"))
	draw_string(ThemeDB.fallback_font, Vector2(860, 150), "AFTER · FOOT-ANCHORED V2", HORIZONTAL_ALIGNMENT_CENTER, 300, 18, Color("a9d8cb"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 208), "SOURCE CEL PRESERVED · NO RIG · NO FRAME INTERPOLATION", HORIZONTAL_ALIGNMENT_CENTER, 700, 13, Color("d2c6ae"))
	draw_string(ThemeDB.fallback_font, Vector2(94, 700), "MAGNIFIED 0.50×", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("aab1b8"))
	draw_string(ThemeDB.fallback_font, Vector2(731, 700), "MAP SCALE 0.17×", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("aab1b8"))

func _capture(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path("res://captures/" + file_name)
	var error := image.save_png(path)
	print("NATIVE_VIEWPORT_CAPTURE=", file_name, " size=", image.get_size(), " error=", error)
