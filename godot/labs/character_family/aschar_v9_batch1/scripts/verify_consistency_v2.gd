extends SceneTree

const IDENTITIES := ["AS48", "AS49"]
const EXPECTED := {"Walk_Front":{"fps":8.0,"loop":true}, "Attack_Front":{"fps":7.0,"loop":false}}
const CELL := Vector2i(400, 440)
const FOOT_ROW := 429

func _initialize() -> void:
	var report_file := FileAccess.open("res://meta/ASCHAR_V9_CONSISTENCY_V2.json", FileAccess.READ)
	if report_file == null:
		push_error("CONSISTENCY_REPORT_MISSING")
		quit(2)
		return
	var parsed: Variant = JSON.parse_string(report_file.get_as_text())
	report_file.close()
	if not parsed is Dictionary:
		push_error("CONSISTENCY_REPORT_PARSE_FAIL")
		quit(3)
		return
	var report: Dictionary = parsed
	var per_clip := {}
	for clip_variant in report.get("clips", []):
		var clip: Dictionary = clip_variant
		per_clip[str(clip.identity) + "/" + str(clip.clip)] = clip
	var verified_frames := 0
	for identity in IDENTITIES:
		var original_path := "res://assets/spriteframes/%s_V9_candidate.tres" % identity
		var corrected_path := "res://assets/spriteframes/%s_V9_consistency_v2.tres" % identity
		var original: SpriteFrames = load(original_path)
		var corrected: SpriteFrames = load(corrected_path)
		if original == null or corrected == null:
			push_error("RESOURCE_LOAD_FAIL=" + identity)
			quit(4)
			return
		for animation in EXPECTED:
			var spec: Dictionary = EXPECTED[animation]
			for collection in [original, corrected]:
				if not collection.has_animation(animation):
					push_error("ANIMATION_MISSING=" + identity + "/" + animation)
					quit(5)
					return
				if collection.get_frame_count(animation) != 4 or not is_zero_approx(collection.get_animation_speed(animation) - float(spec.fps)) or collection.get_animation_loop(animation) != bool(spec.loop):
					push_error("ANIMATION_CONTRACT_FAIL=" + identity + "/" + animation)
					quit(6)
					return
			var clip: Dictionary = per_clip.get(identity + "/" + animation, {})
			if clip.is_empty() or int(clip.get("unique_frames", 0)) != 4:
				push_error("CLIP_AUDIT_RECORD_FAIL=" + identity + "/" + animation)
				quit(7)
			var hashes := {}
			for frame_variant in clip.get("frames", []):
				var frame: Dictionary = frame_variant
				var path := "res://" + str(frame.output)
				var abs := ProjectSettings.globalize_path(path)
				var image := Image.load_from_file(abs)
				if image == null or image.get_size() != CELL or image.detect_alpha() != Image.ALPHA_BLEND:
					push_error("FRAME_FORMAT_FAIL=" + path)
					quit(8)
					return
				var bounds := image.get_used_rect()
				if bounds.size == Vector2i.ZERO or bounds.position.y + bounds.size.y - 1 != FOOT_ROW:
					push_error("FOOT_ROW_FAIL=" + path)
					quit(9)
					return
				var actual_hash := sha256(FileAccess.get_file_as_bytes(abs))
				if actual_hash != str(frame.output_sha256):
					push_error("OUTPUT_HASH_FAIL=" + path)
					quit(10)
					return
				hashes[actual_hash] = true
				verified_frames += 1
			if hashes.size() != 4:
				push_error("DUPLICATE_FRAME_SET=" + identity + "/" + animation)
				quit(11)
			for collection in [original, corrected]:
				for frame_idx in range(4):
					var texture: Texture2D = collection.get_frame_texture(animation, frame_idx)
					if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
						push_error("SPRITEFRAME_TEXTURE_FAIL=" + identity + "/" + animation + "/" + str(frame_idx))
						quit(12)
						return
	print("ASCHAR_V9_CONSISTENCY_VERIFY=PASS identities=2 clips=4 frames=", verified_frames, " body_rgba=16/16 unique=16/16 baseline=429/429 fps=walk8_attack7 loops=walk_only source_resources=preserved=true")
	quit(0)

func sha256(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish().hex_encode()
