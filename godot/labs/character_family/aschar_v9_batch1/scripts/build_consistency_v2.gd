extends SceneTree

const CELL := Vector2i(400, 440)
const TARGET_FOOT_ROW := 429 # visible shoe pixel; pivot line remains y=430
const CLIPS := [
	{"identity":"AS48", "name":"Walk_Front", "folder":"walk_front", "stem":"walk_front", "loop":true, "fps":8.0, "special_frame":-1},
	{"identity":"AS48", "name":"Attack_Front", "folder":"attack_front", "stem":"attack_front", "loop":false, "fps":7.0, "special_frame":0},
	{"identity":"AS49", "name":"Walk_Front", "folder":"walk_front", "stem":"walk_front", "loop":true, "fps":8.0, "special_frame":-1},
	{"identity":"AS49", "name":"Attack_Front", "folder":"attack_front", "stem":"attack_front", "loop":false, "fps":7.0, "special_frame":-1},
]

func _initialize() -> void:
	var report := {"schema":"tmb.aschar.v9.consistency.registration.v2", "status":"CANDIDATE_TECHNICAL", "method":"registered-cell alignment only; no inter-frame interpolation; original source PNGs preserved", "cell":CELL, "foot_pivot_line_y":430, "target_visible_foot_row":TARGET_FOOT_ROW, "clips":[]}
	for spec_variant in CLIPS:
		var spec: Dictionary = spec_variant
		var atlas := Image.create(CELL.x * 4, CELL.y, false, Image.FORMAT_RGBA8)
		var clip_report := {"identity":spec.identity, "clip":spec.name, "fps":spec.fps, "loop":spec.loop, "frames":[]}
		var unique := {}
		for i in range(4):
			var source_rel := "res://assets/frames/%s/%s_registered/%s_%02d.png" % [spec.identity, spec.folder, spec.stem, i]
			var source_abs := ProjectSettings.globalize_path(source_rel)
			var source := Image.load_from_file(source_abs)
			if source == null or source.is_empty() or source.get_size() != CELL:
				push_error("SOURCE_LOAD_OR_SIZE_FAIL=" + source_rel)
				quit(2)
				return
			if source.detect_alpha() != Image.ALPHA_BLEND:
				push_error("SOURCE_ALPHA_FAIL=" + source_rel)
				quit(3)
				return
			var bounds := source.get_used_rect()
			if bounds.size == Vector2i.ZERO:
				push_error("SOURCE_EMPTY=" + source_rel)
				quit(4)
				return
			var corrected := Image.create(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
			var transform := {"kind":"translate_only", "dx":0, "dy":0, "scale":1.0}
			if spec.identity == "AS48" and spec.name == "Attack_Front" and i == 0:
				# The crouched windup was authored ~15% smaller and its shoe row was 41 px high.
				# Scale the whole monolithic cel uniformly to the adjacent attack height, then anchor to the shared foot line.
				var crop := source.get_region(bounds)
				var target_height := 338
				var factor := float(target_height) / float(bounds.size.y)
				var new_size := Vector2i(maxi(1, int(round(float(bounds.size.x) * factor))), target_height)
				crop.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
				var dx := int((CELL.x - new_size.x) / 2) - bounds.position.x
				var dy := (TARGET_FOOT_ROW + 1 - new_size.y) - bounds.position.y
				corrected.blit_rect(crop, Rect2i(Vector2i.ZERO, new_size), Vector2i(dx + bounds.position.x, dy + bounds.position.y))
				transform = {"kind":"uniform_whole_cel_scale_and_foot_anchor", "dx":dx, "dy":dy, "scale":factor, "target_height_px":target_height}
			else:
				var bottom := bounds.position.y + bounds.size.y - 1
				var dy := TARGET_FOOT_ROW - bottom
				corrected.blit_rect(source, Rect2i(Vector2i.ZERO, CELL), Vector2i(0, dy))
				transform["dy"] = dy
			var out_rel := "res://assets/frames/%s/%s_consistency_v2/%s_%02d.png" % [spec.identity, spec.folder, spec.stem, i]
			var out_abs := ProjectSettings.globalize_path(out_rel)
			DirAccess.make_dir_recursive_absolute(out_abs.get_base_dir())
			var err := corrected.save_png(out_abs)
			if err != OK:
				push_error("OUTPUT_SAVE_FAIL=" + out_rel + " err=" + str(err))
				quit(5)
				return
			var out_bounds := corrected.get_used_rect()
			var out_sha := sha256(FileAccess.get_file_as_bytes(out_abs))
			unique[out_sha] = true
			atlas.blit_rect(corrected, Rect2i(Vector2i.ZERO, CELL), Vector2i(i * CELL.x, 0))
			clip_report.frames.append({
				"index":i,
				"source_registered":source_rel.replace("res://", ""),
				"source_sha256":sha256(FileAccess.get_file_as_bytes(source_abs)),
				"output":out_rel.replace("res://", ""),
				"output_sha256":out_sha,
				"source_alpha_bbox":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],
				"output_alpha_bbox":[out_bounds.position.x,out_bounds.position.y,out_bounds.size.x,out_bounds.size.y],
				"visible_foot_row":out_bounds.position.y + out_bounds.size.y - 1,
				"transform":transform,
			})
		if unique.size() != 4:
			push_error("DUPLICATE_OUTPUT_FRAME=" + spec.identity + "/" + spec.name)
			quit(6)
			return
		var atlas_rel := "res://assets/atlases/%s_%s_consistency_v2_atlas.png" % [spec.identity, spec.folder]
		var atlas_abs := ProjectSettings.globalize_path(atlas_rel)
		var atlas_err := atlas.save_png(atlas_abs)
		if atlas_err != OK:
			push_error("ATLAS_SAVE_FAIL=" + atlas_rel)
			quit(7)
			return
		clip_report["atlas"] = atlas_rel.replace("res://", "")
		clip_report["atlas_sha256"] = sha256(FileAccess.get_file_as_bytes(atlas_abs))
		clip_report["unique_frames"] = unique.size()
		report.clips.append(clip_report)
	for clip_variant in report.clips:
		for frame_variant in clip_variant.frames:
			if abs(int(frame_variant.visible_foot_row) - TARGET_FOOT_ROW) > 1:
				push_error("FOOT_ANCHOR_FAIL=" + str(clip_variant.identity) + "/" + str(clip_variant.clip) + "/" + str(frame_variant.index) + " row=" + str(frame_variant.visible_foot_row))
				quit(8)
				return
	var report_path := ProjectSettings.globalize_path("res://meta/ASCHAR_V9_CONSISTENCY_V2.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		push_error("REPORT_OPEN_FAIL")
		quit(9)
		return
	report_file.store_string(JSON.stringify(report, "  ") + "\n")
	report_file.close()
	print("ASCHAR_V9_CONSISTENCY_BUILD=PASS clips=4 frames=16 unique=16 source_preserved=true baseline=429 no_interframe_interpolation=true")
	quit(0)

func sha256(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish().hex_encode()
