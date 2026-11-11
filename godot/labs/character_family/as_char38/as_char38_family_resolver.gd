extends RefCounted

const REGISTRY_PATH := "res://labs/character_family/as_char38/as_char38_registry.json"
const SEXES := ["male", "female"]
const NOVICE_GROUP_IDS := {
	"male": "tmb.as_char38.novice.male",
	"female": "tmb.as_char38.novice.female"
}


func load_registry() -> Dictionary:
	if not FileAccess.file_exists(REGISTRY_PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	return parsed if parsed is Dictionary else {}


func resolve_identity(snapshot: Dictionary, registry: Dictionary = {}) -> Dictionary:
	# Presentation adapter receives a read-only identity snapshot; it never mutates game state.
	var disciple_id := str(snapshot.get("disciple_id", snapshot.get("id", ""))).strip_edges()
	var sex_id := str(snapshot.get("sex_id", "")).strip_edges().to_lower()
	if not SEXES.has(sex_id):
		return {"status": "INVALID_OR_MISSING_SEX", "disciple_id": disciple_id, "render_group_id": ""}
	if disciple_id.is_empty():
		return {"status": "MISSING_DISCIPLE_ID", "sex_id": sex_id, "render_group_id": ""}

	var data := registry if not registry.is_empty() else load_registry()
	var requested := str(snapshot.get("v63_combat_branch_id", "")).strip_edges()
	var selected: Dictionary = {}
	for candidate: Dictionary in data.get("groups", []):
		if str(candidate.get("group_kind", "")) != "branch":
			continue
		var candidate_path := str(candidate.get("v63_path_candidate_id", ""))
		if not requested.is_empty() and (
			requested == str(candidate.get("group_id", ""))
			or requested == str(candidate.get("design_group_id", ""))
			or requested == candidate_path
		):
			selected = candidate
			break
		if (
			str(snapshot.get("school_id", "")) == str(candidate.get("school_id", ""))
			and str(snapshot.get("branch_id", "")) == str(candidate.get("branch_design_slug", ""))
		):
			selected = candidate
			break

	var fallback_id: String = NOVICE_GROUP_IDS[sex_id]
	var seed := _stable_appearance_seed(snapshot, sex_id, disciple_id)
	if selected.is_empty() and requested.is_empty() and str(snapshot.get("branch_id", "")).is_empty():
		return {
			"status": "NOVICE_BASE_STATIC_IDLE_CANDIDATE",
			"disciple_id": disciple_id,
			"sex_id": sex_id,
			"requested_branch_id": "",
			"selected_group_id": fallback_id,
			"render_group_id": fallback_id,
			"appearance_seed": seed,
			"simulation_mutated": false
		}
	if selected.is_empty():
		return {
			"status": "UNKNOWN_BRANCH_FALLBACK_NOVICE",
			"disciple_id": disciple_id,
			"sex_id": sex_id,
			"requested_branch_id": requested,
			"selected_group_id": "",
			"render_group_id": fallback_id,
			"appearance_seed": seed,
			"simulation_mutated": false
		}
	return {
		"status": "ART_PENDING_FALLBACK_NOVICE",
		"disciple_id": disciple_id,
		"sex_id": sex_id,
		"requested_branch_id": requested if not requested.is_empty() else str(selected.get("design_group_id", "")),
		"selected_group_id": str(selected.get("group_id", "")),
		"render_group_id": fallback_id,
		"branch_art_status": str(selected.get("art_status", "ART_PENDING")),
		"appearance_seed": seed,
		"simulation_mutated": false
	}


func group_by_id(group_id: String, registry: Dictionary = {}) -> Dictionary:
	var data := registry if not registry.is_empty() else load_registry()
	for group: Dictionary in data.get("groups", []):
		if str(group.get("group_id", "")) == group_id:
			return group
	return {}


func _stable_appearance_seed(snapshot: Dictionary, sex_id: String, disciple_id: String) -> int:
	# Uses only stable public identity/profile/cosmetic inputs. Hidden latent seeds are not read.
	var payload := "%s|%s|%d|%d" % [
		disciple_id,
		sex_id,
		int(snapshot.get("profile_seed", 0)),
		int(snapshot.get("cosmetic_seed", 0))
	]
	var value: int = 2166136261
	for byte_value: int in payload.to_utf8_buffer():
		value = int((value ^ byte_value) * 16777619) & 0x7fffffff
	return value
