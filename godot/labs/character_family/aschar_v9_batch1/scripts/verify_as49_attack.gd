extends SceneTree

func _initialize() -> void:
	var sprite_frames: SpriteFrames = load("res://assets/spriteframes/AS49_V9_candidate.tres")
	if sprite_frames == null:
		push_error("SPRITEFRAMES_LOAD_FAIL")
		quit(2)
		return
	for clip in ["Walk_Front", "Attack_Front"]:
		if not sprite_frames.has_animation(clip) or sprite_frames.get_frame_count(clip) != 4:
			push_error("CLIP_FRAME_COUNT_FAIL=" + clip)
			quit(3)
			return
		for i in range(4):
			var frame := sprite_frames.get_frame_texture(clip, i)
			if not frame is AtlasTexture or frame.region.size != Vector2(400, 440):
				push_error("FRAME_ATLAS_REGION_FAIL=%s:%d" % [clip, i])
				quit(4)
				return
	var attack_files := [
		"res://assets/frames/AS49/attack_front/AS49_attack_front_f00_windup.png",
		"res://assets/frames/AS49/attack_front/AS49_attack_front_f01_draw.png",
		"res://assets/frames/AS49/attack_front/AS49_attack_front_f02_release.png",
		"res://assets/frames/AS49/attack_front/AS49_attack_front_f03_recovery.png",
	]
	var hashes := {}
	for path in attack_files:
		var bytes := FileAccess.get_file_as_bytes(path)
		var image := Image.new()
		if bytes.is_empty() or image.load_png_from_buffer(bytes) != OK or image.is_empty() or image.detect_alpha() != Image.ALPHA_BLEND:
			push_error("RGBA_SOURCE_FAIL=" + path)
			quit(5)
			return
		var hash := sha256(bytes)
		hashes[hash] = true
	if hashes.size() != 4:
		push_error("DUPLICATE_SOURCE_FRAMES")
		quit(6)
		return
	print("AS49_ATTACK_VERIFY=PASS clips=2 frames=8 attack_sources=4 distinct=true rgba=true rig=none weapon_overlay=separate_pending")
	quit(0)

func sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()
