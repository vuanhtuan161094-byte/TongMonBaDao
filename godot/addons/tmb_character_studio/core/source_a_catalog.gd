@tool
class_name TmbSourceACatalog
extends RefCounted

const POOL_SCRIPT_PATH := "res://src/presentation/p3/disciple_source_a_visual_pool.gd"
const COMBAT_MANIFEST_PATH := "res://assets/combat_v5_source_a/visual_manifest.json"
const ACTOR_ROOT := "res://assets/actors"
const CLIPS := ["stand", "walk"]

var rigs: Array[Dictionary] = []
var rig_by_id: Dictionary = {}
var pool_status := "unverified"
var pool_error := ""
var combat_manifest_status := "unverified"
var _validation_cache: Dictionary = {}

func refresh() -> void:
	rigs.clear()
	rig_by_id.clear()
	pool_error = ""
	_validation_cache.clear()
	if not FileAccess.file_exists(POOL_SCRIPT_PATH):
		pool_status = "missing"
		pool_error = "DiscipleSourceAVisualPool chưa có trong nhánh/project này."
		_refresh_combat_manifest_status()
		return

	var pool_script := load(POOL_SCRIPT_PATH) as Script
	if pool_script == null:
		pool_status = "unverified"
		pool_error = "Không nạp được DiscipleSourceAVisualPool."
		_refresh_combat_manifest_status()
		return
	var constants := pool_script.get_script_constant_map()
	var raw_actors: Variant = constants.get("VERIFIED_ACTORS", null)
	if not (raw_actors is Array):
		pool_status = "unverified"
		pool_error = "Pool thiếu VERIFIED_ACTORS hoặc sai kiểu dữ liệu."
		_refresh_combat_manifest_status()
		return

	pool_status = "present"
	var seen: Dictionary = {}
	for raw_actor in raw_actors:
		if not (raw_actor is Dictionary):
			pool_status = "unverified"
			continue
		var actor: Dictionary = raw_actor
		var asset_id := str(actor.get("asset_id", "")).strip_edges()
		var sex := str(actor.get("sex", "")).strip_edges()
		var scene_path := str(actor.get("scene", "")).strip_edges()
		if asset_id.is_empty() or seen.has(asset_id):
			pool_status = "unverified"
			continue
		seen[asset_id] = true
		var entry := _inspect_actor(asset_id, sex, scene_path)
		rigs.append(entry)
		rig_by_id[asset_id] = entry
		var validation := validate_rig(asset_id)
		if bool(validation.get("ok", false)):
			entry["asset_status"] = "available"
		else:
			var has_missing_file := false
			for message in validation.get("errors", []):
				if str(message).begins_with("Thiếu"):
					has_missing_file = true
					break
			entry["asset_status"] = "missing" if has_missing_file else "unverified"
			for clip_name in CLIPS:
				if str(entry.get("clip_status", {}).get(clip_name, "")) == "present":
					entry["clip_status"][clip_name] = "unverified"
		rigs[rigs.size() - 1] = entry
		rig_by_id[asset_id] = entry
	_refresh_combat_manifest_status()

func get_rig(asset_id: String) -> Dictionary:
	return (rig_by_id.get(asset_id, {}) as Dictionary).duplicate(true)

func clip_status(asset_id: String, clip_name: String) -> String:
	var entry := get_rig(asset_id)
	if entry.is_empty() or not CLIPS.has(clip_name):
		return "unverified"
	return str(entry.get("clip_status", {}).get(clip_name, "unverified"))

func validate_rig(asset_id: String) -> Dictionary:
	if _validation_cache.has(asset_id):
		return (_validation_cache[asset_id] as Dictionary).duplicate(true)
	var entry := get_rig(asset_id)
	var errors: Array[String] = []
	if entry.is_empty():
		errors.append("Rig ID không có trong DiscipleSourceAVisualPool.")
		var missing_result := {"ok": false, "errors": errors}
		_validation_cache[asset_id] = missing_result
		return missing_result.duplicate(true)
	if str(entry.get("manifest_status", "")) != "valid":
		errors.append("asset.json thiếu hoặc không khớp ID/manifest.")
	if not _safe_actor_scene(asset_id, str(entry.get("scene_path", ""))):
		errors.append("Đường dẫn actor.tscn không nằm trong thư mục rig hợp lệ.")
	if not FileAccess.file_exists(str(entry.get("scene_path", ""))):
		errors.append("Thiếu actor.tscn.")
	var manifest: Dictionary = entry.get("asset_manifest", {})
	var expected_hashes: Dictionary = manifest.get("file_sha256", {})
	if expected_hashes.is_empty():
		errors.append("asset.json không có file_sha256.")
	else:
		for raw_name in expected_hashes.keys():
			var file_name := str(raw_name)
			if not _safe_asset_filename(file_name):
				errors.append("Tên file trong asset.json không hợp lệ: %s." % file_name)
				continue
			var path := "%s/%s/%s" % [ACTOR_ROOT, asset_id, file_name]
			if not FileAccess.file_exists(path):
				errors.append("Thiếu asset binary: %s." % path)
				continue
			var expected := str(expected_hashes[raw_name]).to_lower()
			var actual := FileAccess.get_sha256(ProjectSettings.globalize_path(path)).to_lower()
			if actual.is_empty() or actual != expected:
				errors.append("SHA-256 không khớp manifest: %s." % path)
	var result := {"ok": errors.is_empty(), "errors": errors}
	_validation_cache[asset_id] = result
	return result.duplicate(true)

func instantiate_actor(asset_id: String) -> Node2D:
	var result := validate_rig(asset_id)
	if not bool(result.get("ok", false)):
		return null
	var entry := get_rig(asset_id)
	var packed := load(str(entry.get("scene_path", ""))) as PackedScene
	if packed == null:
		return null
	var instance := packed.instantiate()
	if instance is Node2D:
		return instance as Node2D
	instance.queue_free()
	return null

func _inspect_actor(asset_id: String, sex: String, scene_path: String) -> Dictionary:
	var manifest_path := "%s/%s/asset.json" % [ACTOR_ROOT, asset_id]
	var scene_ok := _safe_actor_scene(asset_id, scene_path) and FileAccess.file_exists(scene_path)
	var parsed: Variant = null
	if FileAccess.file_exists(manifest_path):
		parsed = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var manifest: Dictionary = parsed if parsed is Dictionary else {}
	var manifest_valid := not manifest.is_empty() and str(manifest.get("id", "")) == asset_id
	var animation_path := "%s/%s/animations.tres" % [ACTOR_ROOT, asset_id]
	var animation_text := FileAccess.get_file_as_string(animation_path) if FileAccess.file_exists(animation_path) else ""
	var atlas_files_present := true
	var atlas_pages: Variant = manifest.get("atlas_pages", [])
	if not (atlas_pages is Array) or atlas_pages.is_empty():
		atlas_files_present = false
	else:
		for page in atlas_pages:
			if not (page is Dictionary):
				atlas_files_present = false
				continue
			var file_name := str(page.get("file", ""))
			if not _safe_asset_filename(file_name) or not FileAccess.file_exists("%s/%s/%s" % [ACTOR_ROOT, asset_id, file_name]):
				atlas_files_present = false
	var clip_metadata: Dictionary = {}
	var raw_clips: Variant = manifest.get("clips", [])
	if raw_clips is Array:
		for raw_clip in raw_clips:
			if raw_clip is Dictionary:
				clip_metadata[str(raw_clip.get("name", ""))] = raw_clip.duplicate(true)
	var clip_statuses: Dictionary = {}
	for clip_name in CLIPS:
		var has_manifest_clip := clip_metadata.has(clip_name)
		var has_animation := not animation_text.is_empty() and animation_text.contains('&"%s"' % clip_name)
		if not manifest_valid:
			clip_statuses[clip_name] = "unverified"
		elif not FileAccess.file_exists(animation_path) or not atlas_files_present:
			clip_statuses[clip_name] = "missing"
		elif has_manifest_clip and has_animation:
			clip_statuses[clip_name] = "present"
		elif not has_manifest_clip and not has_animation:
			clip_statuses[clip_name] = "missing"
		else:
			clip_statuses[clip_name] = "unverified"
	var status := "unverified"
	if not FileAccess.file_exists(manifest_path) or not scene_ok:
		status = "missing"
	elif manifest_valid and atlas_files_present and not animation_text.is_empty():
		status = "available"
	return {
		"asset_id": asset_id,
		"sex": sex,
		"scene_path": scene_path,
		"asset_manifest_path": manifest_path,
		"manifest_status": "valid" if manifest_valid else ("missing" if not FileAccess.file_exists(manifest_path) else "unverified"),
		"asset_status": status,
		"asset_manifest": manifest,
		"clip_status": clip_statuses,
		"clip_metadata": clip_metadata,
		"scene_available": scene_ok,
		"atlas_files_present": atlas_files_present,
		"animation_path": animation_path
	}

func _refresh_combat_manifest_status() -> void:
	if not FileAccess.file_exists(COMBAT_MANIFEST_PATH):
		combat_manifest_status = "missing"
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(COMBAT_MANIFEST_PATH))
	if not (parsed is Dictionary) or int(parsed.get("version", 0)) <= 0 or not (parsed.get("actors", {}) is Dictionary):
		combat_manifest_status = "unverified"
		return
	combat_manifest_status = "present"

func _safe_actor_scene(asset_id: String, scene_path: String) -> bool:
	if not _safe_asset_id(asset_id) or scene_path.contains(".."):
		return false
	return scene_path.begins_with("%s/%s/" % [ACTOR_ROOT, asset_id]) and scene_path.ends_with("/actor.tscn")

func _safe_asset_id(value: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[A-Za-z0-9_]{1,64}$")
	return regex.search(value) != null

func _safe_asset_filename(value: String) -> bool:
	return not value.is_empty() and not value.contains("/") and not value.contains("\\") and not value.contains("..")
