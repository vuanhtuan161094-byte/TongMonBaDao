extends SceneTree
## Independent Godot process verifies the saved recruit, HS-09 assignment and canonical state.

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
	if ok:
		return true
	push_error("TRI03_RECRUIT_HS09_RELOAD_FAIL: "+reason)
	quit(1)
	return false

func _run() -> void:
	var save_path := OS.get_environment("TMB_TRI03_FLOW_SAVE_PATH")
	if not _check(not save_path.is_empty(),"isolated flow save path was not supplied"):
		return
	var manifest_path := save_path+".expected.json"
	var manifest_file := FileAccess.open(manifest_path,FileAccess.READ)
	if not _check(manifest_file != null,"first Godot process did not write its expected-state manifest"):
		return
	var parsed := JSON.new()
	var parse_error := parsed.parse(manifest_file.get_as_text())
	manifest_file.close()
	if not _check(parse_error == OK and parsed.data is Dictionary,"expected-state manifest is invalid"):
		return
	var expected: Dictionary = parsed.data
	var state := SaveService.new().load_from_path(save_path)
	if not _check(state != null,"second Godot process could not load the SaveService file"):
		return
	var disciple_id := StringName(str(expected.get("disciple_id","")))
	var disciple: DiscipleState = state.disciples.get(disciple_id)
	if not _check(disciple != null
		and state.disciples.size() == int(expected.get("roster_count",-1))
		and str(disciple.worksite_building_id) == str(expected.get("worksite_id",""))
		and str(disciple.work_group_id) == str(expected.get("work_group_id","")),
		"independent reload lost or duplicated recruited disciple / assignment"):
		return
	if not _check(state.recruitment_candidates.size() == int(expected.get("candidate_count",-1))
		and state.sect.disciple_recruitment_tokens == int(expected.get("recruitment_tokens",-1)),
		"independent reload changed the candidate queue or recruitment order balance"):
		return
	if not _check(state.buildings.size() == int(expected.get("building_count",-1))
		and SectResidenceSystemV1.all_houses(state).size() == int(expected.get("residence_count",-1))
		and SectHallSystemV1.hall(state).level == int(expected.get("hall_level",-1)),
		"independent reload changed buildings, Residence count or Hall level"):
		return
	var house_id := str(expected.get("g1_house_id",""))
	var house = state.buildings.get(house_id)
	var site := Vector2i(int(expected.get("g1_site_x",-999)),int(expected.get("g1_site_y",-999)))
	var build_request_id := str(expected.get("g1_build_request_id",""))
	var build_receipts: Variant = state.sect.hall_governance.get("residence_build_receipts",{})
	var expected_cost: Variant = expected.get("g1_cost",{})
	var warehouse := WarehouseSystem.new()
	if not _check(house is BuildingState
		and house.status == BuildingSystem.STATUS_CONSTRUCTING
		and SectResidenceSiteV1.origin_of(house) == site
		and int(house.production_state.get("construction_finish_tick",-1)) == int(expected.get("g1_finish_tick",-2))
		and SectResidenceSystemV1.construction_remaining_ticks(state,house)
			== int(expected.get("g1_duration_ticks",-1))
		and build_receipts is Dictionary
		and build_receipts.get(build_request_id,"") == house_id
		and expected_cost is Dictionary
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD)) == int(expected.get("g1_wood_after",-1))
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE)) == int(expected.get("g1_ore_after",-1))
		and state.sect.spirit_stones == int(expected.get("g1_stones_after",-1)),
		"independent reload lost the paid New Game Residence site, timer, exactly-once receipt or resource debit"):
		return
	if not _check(SectHallSystemV1.validate(state).is_empty()
		and state.validate_invariants().is_empty(),
		"independent reload left canonical Hall / Residence / simulation invariants invalid"):
		return
	print("TRI03_RECRUIT_HS09_CROSS_PROCESS_RELOAD_PASS disciple=%s roster=%d worksite=%s tokens=%d candidates=%d house=%s site=%s timer=%d receipt=%s" % [
		str(disciple_id),state.disciples.size(),str(disciple.worksite_building_id),
		state.sect.disciple_recruitment_tokens,state.recruitment_candidates.size(),
		house_id,str(site),SectResidenceSystemV1.construction_remaining_ticks(state,house),build_request_id
	])
	for path in [save_path,save_path+".bak",save_path+".tmp",manifest_path]:
		if FileAccess.file_exists(path):
			var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			if error != OK:
				push_error("TRI03_RECRUIT_HS09_RELOAD_CLEANUP_FAIL: %s (%d)" % [path,error])
				quit(2)
				return
	quit(0)
