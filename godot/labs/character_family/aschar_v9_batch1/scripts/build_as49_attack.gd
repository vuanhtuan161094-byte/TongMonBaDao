extends SceneTree

const CELL := Vector2i(400, 440)
const TARGET := Vector2i(360, 420)
const BASELINE := 430

func _initialize() -> void:
	var sources := [
		"AS49_attack_front_f00_windup.png",
		"AS49_attack_front_f01_draw.png",
		"AS49_attack_front_f02_release.png",
		"AS49_attack_front_f03_recovery.png",
	]
	var atlas := Image.create(CELL.x * sources.size(), CELL.y, false, Image.FORMAT_RGBA8)
	var frames: Array[Dictionary] = []
	var unique := {}
	for i in range(sources.size()):
		var source_rel: String = "res://assets/frames/AS49/attack_front/" + sources[i]
		var source_abs := ProjectSettings.globalize_path(source_rel)
		var source := Image.load_from_file(source_abs)
		if source == null or source.is_empty():
			push_error("SOURCE_LOAD_FAIL=" + source_rel)
			quit(2)
			return
		if source.detect_alpha() != Image.ALPHA_BLEND:
			push_error("SOURCE_NOT_RGBA=" + source_rel)
			quit(3)
			return
		var bounds := source.get_used_rect()
		if bounds.size.x == 0 or bounds.size.y == 0:
			push_error("EMPTY_ALPHA=" + source_rel)
			quit(4)
			return
		var crop := source.get_region(bounds)
		var scale := minf(float(TARGET.x) / crop.get_width(), float(TARGET.y) / crop.get_height())
		var size := Vector2i(maxi(1, int(round(crop.get_width() * scale))), maxi(1, int(round(crop.get_height() * scale))))
		crop.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
		var cel := Image.create(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
		cel.blit_rect(crop, Rect2i(Vector2i.ZERO, size), Vector2i((CELL.x - size.x) / 2, BASELINE - size.y))
		var registered_rel := "res://assets/frames/AS49/attack_front_registered/attack_front_%02d.png" % i
		var registered_abs := ProjectSettings.globalize_path(registered_rel)
		DirAccess.make_dir_recursive_absolute(registered_abs.get_base_dir())
		var save_error := cel.save_png(registered_abs)
		if save_error != OK:
			push_error("REGISTERED_SAVE_FAIL=" + str(save_error))
			quit(5)
			return
		atlas.blit_rect(cel, Rect2i(Vector2i.ZERO, CELL), Vector2i(i * CELL.x, 0))
		var cel_hash := sha256(cel.get_data())
		unique[cel_hash] = true
		frames.append({
			"source": source_rel.replace("res://", ""),
			"source_sha256": sha256(FileAccess.get_file_as_bytes(source_abs)),
			"source_canvas": source.get_size(),
			"source_alpha_bounds": {"x": bounds.position.x, "y": bounds.position.y, "w": bounds.size.x, "h": bounds.size.y},
			"registered": registered_rel.replace("res://", ""),
			"registered_sha256": cel_hash,
			"registered_size": CELL,
			"foot_baseline_y": BASELINE,
			"pose_locked": false,
		})
	if unique.size() != sources.size():
		push_error("DUPLICATE_REGISTERED_FRAME")
		quit(6)
		return
	var atlas_rel := "res://assets/atlases/AS49_attack_front_atlas.png"
	var atlas_abs := ProjectSettings.globalize_path(atlas_rel)
	var atlas_error := atlas.save_png(atlas_abs)
	if atlas_error != OK:
		push_error("ATLAS_SAVE_FAIL=" + str(atlas_error))
		quit(7)
		return
	var manifest := {
		"schema": "tmb.aschar.v9.batch1.candidate.v1",
		"identity": "AS-CHAR-49 Kiếm Tu Nữ",
		"candidate_status": "OWNER_ART_APPROVAL_PENDING",
		"body_mode": "monolithic whole-body sprite per frame; no rig/bones/body split",
		"clip": "Attack_Front",
		"pose_sequence": ["windup", "draw initiation", "release/contact pose", "recovery"],
		"fps": 7.0,
		"loop": false,
		"frame_count": sources.size(),
		"canvas": CELL,
		"foot_baseline_y": BASELINE,
		"weapon": "not drawn in body; separate overlay pending approved sword choice and measured grip metadata",
		"atlas": atlas_rel.replace("res://", ""),
		"atlas_sha256": sha256(FileAccess.get_file_as_bytes(atlas_abs)),
		"frames": frames,
		"prompt_provenance": "AS49_V9_ATTACK_PROMPTS.md",
	}
	var manifest_file := FileAccess.open("res://meta/AS49_V9_ATTACK_MANIFEST.json", FileAccess.WRITE)
	manifest_file.store_string(JSON.stringify(manifest, "  ") + "\n")
	manifest_file.close()
	print("AS49_ATTACK_ATLAS=PASS frames=4 unique=4 rgba=true baseline=430 weapon_overlay=separate owner_art_pending")
	quit(0)

func sha256(bytes: PackedByteArray) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(bytes)
	return hashing.finish().hex_encode()
