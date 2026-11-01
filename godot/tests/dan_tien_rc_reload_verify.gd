extends SceneTree

var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		push_error("DAN_TIEN_RELOAD_FAIL: " + message)
		quit(1)
		return false
	return true

func _same(left: Variant, right: Variant) -> bool:
	if left is Dictionary and right is Dictionary:
		if left.size() != right.size():
			return false
		for key in left:
			if not right.has(key) or not _same(left[key], right[key]):
				return false
		return true
	if left is Array and right is Array:
		if left.size() != right.size():
			return false
		for index in range(left.size()):
			if not _same(left[index], right[index]):
				return false
		return true
	if typeof(left) in [TYPE_INT, TYPE_FLOAT] and typeof(right) in [TYPE_INT, TYPE_FLOAT]:
		return is_equal_approx(float(left), float(right))
	return left == right

func _run() -> void:
	var save_path := OS.get_environment("TMB_DANTIEN_SAVE_PATH")
	var expected_path := OS.get_environment("TMB_DANTIEN_EXPECTED_PATH")
	if not _check(not save_path.is_empty() and not expected_path.is_empty(), "QA save and expectation paths are configured"):
		return
	var expected_file := FileAccess.open(expected_path, FileAccess.READ)
	if not _check(expected_file != null, "first-process expectation file survived process exit"):
		return
	var parse := JSON.new()
	if not _check(parse.parse(expected_file.get_as_text()) == OK and parse.data is Dictionary, "cross-process expectation JSON is valid"):
		return
	expected_file.close()
	var expected: Dictionary = parse.data
	var loaded := SaveService.new().load_from_path(save_path)
	if not _check(loaded != null, "second Godot process loads the exact SaveService file"):
		return
	var disciple_ids: Array[String] = []
	for raw_id in loaded.disciples.keys():
		disciple_ids.append(str(raw_id))
	disciple_ids.sort()
	var candidate_ids: Array[String] = []
	for raw_id in loaded.recruitment_candidates.keys():
		candidate_ids.append(str(raw_id))
	candidate_ids.sort()
	if not _check(disciple_ids == expected.get("disciple_ids", []) and candidate_ids == expected.get("candidate_ids", []), "roster and queued candidate IDs survive a fresh-process reload exactly"):
		return
	var accepted_id := StringName(str(expected.get("accepted_id", "")))
	if not _check(loaded.disciples.has(accepted_id) and not loaded.recruitment_candidates.has(accepted_id), "accepted disciple is not duplicated back into the candidate queue"):
		return
	if not _check(_same(loaded.disciples[accepted_id].v2_birth_profile, expected.get("accepted_profile", {})), "accepted immutable birth profile survives process restart"):
		return
	if not _check(loaded.sect.disciple_capacity == int(expected.get("capacity", -1)) and loaded.sect.disciple_recruitment_tokens == int(expected.get("tokens", -1)), "capacity and remaining recruitment orders survive process restart"):
		return
	var platform_id := str(expected.get("platform_id", ""))
	if not _check(loaded.buildings.has(platform_id), "starting Dẫn Tiên building survives process restart"):
		return
	var platform: BuildingState = loaded.buildings[platform_id]
	if not _check(_same(platform.production_state, expected.get("production_state", {})), "daily quality snapshot and guide selection survive process restart"):
		return
	var unique_ids := {}
	for id in disciple_ids + candidate_ids:
		if not _check(not unique_ids.has(id), "candidate/roster identifiers remain globally unique"):
			return
		unique_ids[id] = true
	print("DAN_TIEN_RELOAD_PASS assertions=%d ids=%d candidates=%d orders=%d capacity=%d guide=%s snapshot_day=%d" % [
		checks, disciple_ids.size(), candidate_ids.size(), loaded.sect.disciple_recruitment_tokens,
		loaded.sect.disciple_capacity, str(expected.get("guide_id", "")),
		int(platform.production_state.get("snapshot_day_index", -1))
	])
	quit(0)
