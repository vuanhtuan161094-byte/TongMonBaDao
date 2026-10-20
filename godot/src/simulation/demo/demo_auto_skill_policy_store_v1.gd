class_name DemoAutoSkillPolicyStoreV1
extends RefCounted

const SAVE_PATH := "user://demo_sandbox/auto_skill_policy_v1.json"
const SAVE_SCHEMA := "tmb_demo_auto_skill_store_v1"

static func path_for_active_save() -> String:
	var active_save := str(ProjectSettings.get_setting("runtime/live_save_path", ""))
	if not active_save.begins_with("user://demo_sandbox/"):
		return ""
	if active_save.get_file().begins_with("jxqy2_"):
		return "user://demo_sandbox/jxqy2_auto_skill_policy_v1.json"
	return SAVE_PATH

static func load_policy(actor_id: String, owned_skill_ids: Array) -> Dictionary:
	var source_path := path_for_active_save()
	if source_path.is_empty():
		return AutoSkillPolicyV2.default_policy(owned_skill_ids)
	if not FileAccess.file_exists(source_path):
		return AutoSkillPolicyV2.default_policy(owned_skill_ids)
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(source_path))
	if not (parsed is Dictionary) or str(parsed.get("schema", "")) != SAVE_SCHEMA:
		return AutoSkillPolicyV2.default_policy(owned_skill_ids)
	var policies: Dictionary = parsed.get("actors", {})
	if not (policies.get(actor_id, null) is Dictionary):
		return AutoSkillPolicyV2.default_policy(owned_skill_ids)
	var normalized := AutoSkillPolicyV2.normalize(policies[actor_id], owned_skill_ids)
	if not bool(normalized.get("ok", false)):
		push_warning("DEMO auto-skill policy ignored for %s: %s" % [actor_id, str(normalized.get("reason", "invalid"))])
		return AutoSkillPolicyV2.default_policy(owned_skill_ids)
	return normalized["policy"]

static func save_policy(actor_id: String, owned_skill_ids: Array, policy_value: Dictionary) -> Dictionary:
	if actor_id.is_empty():
		return {"ok": false, "reason": "missing_auto_skill_actor_id"}
	var source_path := path_for_active_save()
	if source_path.is_empty():
		return {"ok": false, "reason": "auto_skill_policy_is_demo_save_only"}
	var normalized := AutoSkillPolicyV2.normalize(policy_value, owned_skill_ids)
	if not bool(normalized.get("ok", false)):
		return normalized
	var actors: Dictionary = {}
	if FileAccess.file_exists(source_path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(source_path))
		if parsed is Dictionary and str(parsed.get("schema", "")) == SAVE_SCHEMA and parsed.get("actors", {}) is Dictionary:
			actors = (parsed["actors"] as Dictionary).duplicate(true)
	actors[actor_id] = normalized["policy"]
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://demo_sandbox"))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return {"ok": false, "reason": "auto_skill_store_directory_failed", "detail": directory_error}
	var file := FileAccess.open(source_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": "auto_skill_store_open_failed", "detail": FileAccess.get_open_error()}
	file.store_string(JSON.stringify({"schema": SAVE_SCHEMA, "actors": actors}, "\t", false))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return {"ok": false, "reason": "auto_skill_store_write_failed", "detail": error}
	return {"ok": true, "policy": normalized["policy"], "path": source_path}
