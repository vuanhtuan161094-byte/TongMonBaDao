extends RefCounted
class_name ShadowGlbAssetAudit

## Read-only validation for a user-supplied imported 3D character.
## This script never creates a model or substitutes a missing animation.
const REQUIRED_CLIPS := ["stand", "walk", "attack1", "hit", "dead"]
const OPTIONAL_CLIPS := ["run"]
const REQUIRED_BONE_GROUPS := ["hips", "spine", "head", "arm", "leg", "foot"]

static func inspect_model_path(model_path: String) -> Dictionary:
	var normalized_path := model_path.strip_edges()
	if normalized_path.is_empty() or not normalized_path.begins_with("res://"):
		return _result("BLOCKED_BY_TRIPO_ASSET", "Choose an owner-provided GLB/FBX inside the project.")
	if not FileAccess.file_exists(normalized_path):
		return _result("BLOCKED_BY_TRIPO_ASSET", "Model file is missing: " + normalized_path)
	var extension := normalized_path.get_extension().to_lower()
	if extension not in ["glb", "gltf", "fbx"]:
		return _result("INVALID_MODEL_FORMAT", "Expected .glb, .gltf, or .fbx.")
	if not ResourceLoader.exists(normalized_path):
		return _result("GODOT_IMPORT_PENDING", "Source exists; let Godot finish importing it before preview.")
	var packed := ResourceLoader.load(normalized_path) as PackedScene
	if packed == null:
		return _result("INVALID_IMPORTED_SCENE", "Godot did not import this file as a PackedScene.")
	var instance := packed.instantiate()
	if instance == null:
		return _result("INVALID_IMPORTED_SCENE", "Imported PackedScene could not be instantiated.")
	var report := inspect_scene(instance)
	instance.free()
	report["model_path"] = normalized_path
	report["source_sha256"] = FileAccess.get_sha256(ProjectSettings.globalize_path(normalized_path))
	return report

static func inspect_scene(scene_root: Node) -> Dictionary:
	if scene_root == null:
		return _result("INVALID_IMPORTED_SCENE", "Scene root is null.")
	var found := {"skeletons": [], "players": [], "meshes": []}
	_collect_nodes(scene_root, found)
	var skeletons: Array = found["skeletons"]
	var players: Array = found["players"]
	var meshes: Array = found["meshes"]
	if meshes.is_empty():
		return _result("INVALID_MODEL_NO_MESH", "Imported scene has no MeshInstance3D.")
	if skeletons.size() != 1:
		return _result("BLOCKED_BY_RIG", "Expected exactly one Skeleton3D; found %d." % skeletons.size())
	if players.size() != 1:
		return _result("BLOCKED_BY_ANIMATION", "Expected exactly one AnimationPlayer; found %d." % players.size())

	var skeleton := skeletons[0] as Skeleton3D
	var bone_names: Array[String] = []
	var groups: Dictionary = {}
	var foot_bone_indices: Array[int] = []
	for bone_index in range(skeleton.get_bone_count()):
		var bone_name := skeleton.get_bone_name(bone_index)
		bone_names.append(bone_name)
		var normalized := _normalize_bone_name(bone_name)
		for group_name in REQUIRED_BONE_GROUPS:
			if _bone_matches_group(normalized, group_name):
				groups[group_name] = true
		if normalized.contains("foot") or normalized.contains("ankle"):
			foot_bone_indices.append(bone_index)
	var missing_groups: Array[String] = []
	for group_name in REQUIRED_BONE_GROUPS:
		if not groups.has(group_name):
			missing_groups.append(group_name)
	var rig_complete := skeleton.get_bone_count() >= 12 and missing_groups.is_empty()

	var player := players[0] as AnimationPlayer
	var actual_clips: Array[String] = []
	var clip_by_canonical: Dictionary = {}
	for animation_key in player.get_animation_list():
		var key_text := str(animation_key)
		actual_clips.append(key_text)
		var segments := key_text.split("/")
		var leaf := str(segments[segments.size() - 1]).to_lower()
		clip_by_canonical[leaf] = key_text
	var clip_states: Dictionary = {}
	var missing_clips: Array[String] = []
	for clip_name in REQUIRED_CLIPS:
		if clip_by_canonical.has(clip_name):
			var real_key := str(clip_by_canonical[clip_name])
			var animation := player.get_animation(real_key)
			clip_states[clip_name] = {
				"state": "EXISTS",
				"actual_name": real_key,
				"duration_seconds": animation.length if animation != null else 0.0
			}
		else:
			clip_states[clip_name] = {"state": "MISSING", "actual_name": ""}
			missing_clips.append(clip_name)
	for clip_name in OPTIONAL_CLIPS:
		if clip_by_canonical.has(clip_name):
			var real_key := str(clip_by_canonical[clip_name])
			var animation := player.get_animation(real_key)
			clip_states[clip_name] = {
				"state": "EXISTS",
				"actual_name": real_key,
				"duration_seconds": animation.length if animation != null else 0.0
			}
		else:
			clip_states[clip_name] = {"state": "MISSING_OPTIONAL", "actual_name": ""}

	var status := "READY_FOR_VISUAL_REVIEW"
	var detail := "Imported rig and required native clips are present; visual acceptance is still pending."
	if not rig_complete:
		status = "RIG_INCOMPLETE"
		detail = "Missing humanoid bone groups: " + ", ".join(missing_groups)
	elif not missing_clips.is_empty():
		status = "CLIPS_INCOMPLETE"
		detail = "Required native clips missing: " + ", ".join(missing_clips)
	return {
		"status": status,
		"detail": detail,
		"mesh_count": meshes.size(),
		"skeleton_count": skeletons.size(),
		"animation_player_count": players.size(),
		"bone_count": skeleton.get_bone_count(),
		"bone_names": bone_names,
		"bone_groups": groups.keys(),
		"missing_bone_groups": missing_groups,
		"foot_bone_indices": foot_bone_indices,
		"actual_clips": actual_clips,
		"clip_states": clip_states,
		"missing_required_clips": missing_clips,
		"authored_eight_way": false,
		"direction_method": "CAMERA_AZIMUTH",
		"owner_visual_acceptance": "PENDING"
	}

static func validate_bake_manifest(data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if int(data.get("schema_version", -1)) != 1:
		errors.append("schema_version must equal 1")
	var source: Variant = data.get("source", {})
	if not (source is Dictionary):
		errors.append("source must be an object")
	else:
		var digest := str(source.get("sha256", ""))
		if digest.length() != 64 or digest.to_lower() != digest or not _is_hex_digest(digest):
			errors.append("source.sha256 must be a lowercase SHA-256 hex digest")
	if int(data.get("fps", 0)) < 1 or int(data.get("fps", 0)) > 60:
		errors.append("fps must be between 1 and 60")
	var cell_size: Variant = data.get("cell_size", [])
	if not (cell_size is Array) or cell_size.size() != 2 or int(cell_size[0]) < 1 or int(cell_size[1]) < 1:
		errors.append("cell_size must be [width, height] with positive integers")
	var directions: Variant = data.get("directions", [])
	if not (directions is Array) or directions.is_empty():
		errors.append("directions must be a non-empty array")
	var clips: Variant = data.get("clips", [])
	if not (clips is Array) or clips.is_empty():
		errors.append("clips must be a non-empty array")
	else:
		for clip in clips:
			if not (clip is Dictionary):
				errors.append("each clip must be an object")
				continue
			if str(clip.get("name", "")).is_empty() or int(clip.get("frame_count", 0)) < 1:
				errors.append("each clip needs a name and positive frame_count")
			if not (clip.get("pages", []) is Array) or clip.get("pages", []).is_empty():
				errors.append("each clip needs at least one atlas page")
	return errors

## Stable JSON representation used by exported manifests and schema tests.
## Sorting applies recursively through the JSON printer so equivalent dictionaries
## produce identical bytes and SHA-256 values across repeated exports.
static func canonical_json(data: Variant) -> String:
	return JSON.stringify(data, "", true) + "\n"

static func required_clip_summary(actual_clips: Array) -> Dictionary:
	var actual_by_leaf: Dictionary = {}
	for entry in actual_clips:
		var text := str(entry)
		var components := text.split("/")
		actual_by_leaf[str(components[components.size() - 1]).to_lower()] = text
	var states: Dictionary = {}
	var missing: Array[String] = []
	for required in REQUIRED_CLIPS:
		var required_key := str(required)
		if actual_by_leaf.has(required_key):
			states[required_key] = {"state": "EXISTS", "actual_name": actual_by_leaf[required_key]}
		else:
			states[required_key] = {"state": "MISSING", "actual_name": ""}
			missing.append(required_key)
	for optional in OPTIONAL_CLIPS:
		var optional_key := str(optional)
		states[optional_key] = {"state": "EXISTS", "actual_name": actual_by_leaf[optional_key]} if actual_by_leaf.has(optional_key) else {"state": "MISSING_OPTIONAL", "actual_name": ""}
	return {"states": states, "missing_required": missing}

static func _collect_nodes(node: Node, found: Dictionary) -> void:
	if node is Skeleton3D:
		found["skeletons"].append(node)
	if node is AnimationPlayer:
		found["players"].append(node)
	if node is MeshInstance3D:
		found["meshes"].append(node)
	for child in node.get_children():
		_collect_nodes(child, found)

static func _normalize_bone_name(value: String) -> String:
	return value.to_lower().replace("_", "").replace("-", "").replace(":", "").replace(".", "")

static func _bone_matches_group(name: String, group_name: String) -> bool:
	match group_name:
		"hips": return name.contains("hips") or name.contains("pelvis")
		"spine": return name.contains("spine") or name.contains("chest")
		"head": return name.contains("head")
		"arm": return name.contains("arm") or name.contains("hand")
		"leg": return name.contains("leg") or name.contains("thigh") or name.contains("knee")
		"foot": return name.contains("foot") or name.contains("ankle")
	return false

static func _is_hex_digest(value: String) -> bool:
	for character in value:
		if not (character >= "0" and character <= "9") and not (character >= "a" and character <= "f"):
			return false
	return true

static func _result(status: String, detail: String) -> Dictionary:
	return {
		"status": status,
		"detail": detail,
		"mesh_count": 0,
		"skeleton_count": 0,
		"animation_player_count": 0,
		"bone_count": 0,
		"bone_names": [],
		"bone_groups": [],
		"missing_bone_groups": REQUIRED_BONE_GROUPS.duplicate(),
		"foot_bone_indices": [],
		"actual_clips": [],
		"clip_states": {},
		"missing_required_clips": REQUIRED_CLIPS.duplicate(),
		"authored_eight_way": false,
		"direction_method": "CAMERA_AZIMUTH",
		"owner_visual_acceptance": "PENDING"
	}

