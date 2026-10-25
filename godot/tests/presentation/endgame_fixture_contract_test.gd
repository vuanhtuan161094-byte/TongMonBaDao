extends SceneTree

const SAVE_PATH := "res://qa/endgame_qa_save.json"
const EXPECTED_COUNTS := {
	"mine": 30,
	"linh_forest": 30,
	"spirit_field": 40,
	"alchemy_hall": 1,
	"dan_tien_dai": 1,
	"ren_than_duong": 1
}
const EXPECTED_SUPPORTED_LEVELS := {
	"mine": 19,
	"linh_forest": 1,
	"spirit_field": 100,
	"alchemy_hall": 1,
	"dan_tien_dai": 100,
	"ren_than_duong": 1
}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_fail("endgame_fixture_save_missing_run_tools_qa_endgame_fixture_generator_first")
		return
	var state := SaveService.new().load_from_path(SAVE_PATH)
	if state == null:
		_fail("endgame_fixture_save_service_reload_failed")
		return
	if state.disciples.size() != 130 or state.sect.disciple_capacity != 130:
		_fail("endgame_real_recruitment_roster_count_mismatch", {"population": state.disciples.size(), "capacity": state.sect.disciple_capacity})
	if state.sect.lodging_capacity < state.disciples.size():
		_fail("qa_endgame_roster_starts_over_lodging_capacity", {"population": state.disciples.size(), "lodging_capacity": state.sect.lodging_capacity})
		return
	if not state.validate_invariants().is_empty():
		_fail("endgame_state_invariants_failed", state.validate_invariants())
		return
	var building_system := BuildingSystem.new()
	var building_errors := building_system.validate_invariants(state)
	if not building_errors.is_empty():
		_fail("endgame_building_invariants_failed", building_errors)
		return
	var warehouse := WarehouseSystem.new()
	var warehouse_errors := warehouse.validate_invariants(state)
	if not warehouse_errors.is_empty():
		_fail("endgame_warehouse_invariants_failed", warehouse_errors)
		return
	var counts := {}
	var level_counts := {}
	var assigned_by_site := {}
	var batches := 0
	for value in state.buildings.values():
		var building := value as BuildingState
		if building == null:
			_fail("endgame_noncanonical_building_record")
			return
		var key := str(building.building_type)
		counts[key] = int(counts.get(key, 0)) + 1
		level_counts[key] = int(level_counts.get(key, 0)) + (1 if building.level == EXPECTED_SUPPORTED_LEVELS.get(key, -1) else 0)
		batches += int(building.metrics.get("production_batches", 0))
	for raw_id in state.disciples.keys():
		var disciple := state.disciples[raw_id] as DiscipleState
		if disciple == null or disciple.worksite_building_id == &"":
			continue
		var site_id := str(disciple.worksite_building_id)
		if not state.buildings.has(site_id):
			_fail("endgame_worker_references_missing_real_site", {"disciple": str(raw_id), "site": site_id})
			return
		assigned_by_site[site_id] = int(assigned_by_site.get(site_id, 0)) + 1
	if counts != EXPECTED_COUNTS:
		_fail("endgame_canonical_building_counts_mismatch", counts)
		return
	for key in EXPECTED_COUNTS:
		if int(level_counts.get(key, 0)) != int(EXPECTED_COUNTS[key]):
			_fail("building_not_at_code_supported_level_ceiling", {"type": key, "expected_level": EXPECTED_SUPPORTED_LEVELS[key], "count_at_ceiling": level_counts.get(key, 0)})
			return
	if assigned_by_site.size() != 100:
		_fail("endgame_not_all_100_producer_instances_have_workers", {"assigned_sites": assigned_by_site.size()})
		return
	for site_id in assigned_by_site:
		if int(assigned_by_site[site_id]) != 1:
			_fail("one_active_job_site_assignment_not_unique", {"site": site_id, "workers": assigned_by_site[site_id]})
			return
	if batches <= 0:
		_fail("real_endgame_production_never_completed", {"production_batches": batches})
		return
	for resource_id in state.sect.warehouse_resources:
		if int(state.sect.warehouse_resources[resource_id]) < 0:
			_fail("negative_canonical_warehouse_resource", {"resource": resource_id})
			return
	var next_mine := building_system.can_start_upgrade(state, &"mine_001")
	if bool(next_mine.get("ok", false)) or str(next_mine.get("reason", "")) != "milestone_component_not_defined":
		_fail("mine_fixture_claimed_unsupported_level", next_mine)
		return
	var next_field := building_system.can_start_upgrade(state, &"spirit_field_001")
	if bool(next_field.get("ok", false)) or str(next_field.get("reason", "")) != "max_level":
		_fail("spirit_field_fixture_not_at_true_max_level", next_field)
		return
	var output := {
		"population": state.disciples.size(),
		"lodging_capacity": state.sect.lodging_capacity,
		"real_building_counts": counts,
		"supported_level_counts": level_counts,
		"producer_sites_with_one_worker": assigned_by_site.size(),
		"production_batches": batches,
		"tick": state.tick,
		"warehouse": state.sect.warehouse_resources,
		"save_sha256": FileAccess.get_sha256(SAVE_PATH)
	}
	print("TMB_ENDGAME_FIXTURE_CONTRACT PASS " + JSON.stringify(output))
	quit(0)

func _fail(reason: String, detail: Variant = {}) -> void:
	printerr("TMB_ENDGAME_FIXTURE_CONTRACT FAIL " + JSON.stringify({"reason": reason, "detail": detail}))
	quit(1)
