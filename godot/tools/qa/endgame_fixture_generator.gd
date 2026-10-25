extends SceneTree

const SEED := 20261025
const SAVE_PATH := "res://qa/endgame_qa_save.json"
const REPORT_PATH := "res://qa/endgame_qa_report.json"
const TARGET_POPULATION := 130 # Original tested fixture remains the default.
const SIMULATED_MINUTES := 120
const ALLOWED_POPULATIONS := [130,200,500]
var roster_target := TARGET_POPULATION
var qa_save_path := SAVE_PATH
var qa_report_path := REPORT_PATH
const TARGET_COUNTS := {
	"mine": 30,
	"linh_forest": 30,
	"spirit_field": 40,
	"alchemy_hall": 1,
	"dan_tien_dai": 1,
	"ren_than_duong": 1
}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	# Explicit opt-in 130/200/500 stress profiles. NEVER overwrite the
	# owner's currently playing isolated 130 roster or the committed base
	# fixture when running a larger load test.
	for arg in OS.get_cmdline_user_args():
		if not str(arg).begins_with("--tmb-roster="):
			continue
		var chosen := str(arg).trim_prefix("--tmb-roster=")
		if not chosen.is_valid_int() or not ALLOWED_POPULATIONS.has(int(chosen)):
			_fail("invalid_qa_population",{"allowed":ALLOWED_POPULATIONS,"received":chosen})
			return
		roster_target = int(chosen)
	if roster_target != TARGET_POPULATION:
		qa_save_path = "res://qa/endgame_qa_save_%d.json" % roster_target
		qa_report_path = "res://qa/endgame_qa_report_%d.json" % roster_target
	_preserve_existing_save_files()
	var state := P37Factory.create_state(SEED)
	var runtime := LiveGameRuntimeV2.new()
	var configured: Dictionary = runtime._configure_live_state(state)
	if not bool(configured.get("ok", false)):
		_fail("live_state_configuration_failed", configured)
		return
	var now := int(Time.get_unix_time_from_system())
	var attached: Dictionary = runtime.owner.attach(state, now)
	if not bool(attached.get("ok", false)):
		_fail("canonical_runtime_attach_failed", attached)
		return
	runtime.save_path = qa_save_path
	runtime.owner.durable_path = qa_save_path

	var buildings := BuildingSystem.new()
	_build_required_buildings(state, buildings)
	_buildings_at_supported_max(state)
	if not WarehouseSystem.new().initialize(state):
		_fail("canonical_warehouse_initialize_failed", {})
		return
	# Deterministic QA setup may seed the existing canonical capacity field; it
	# does not claim natural progression or add a parallel housing system. Keep
	# the real NeedsSystem restraint healthy so a dense endgame save is not
	# intentionally overcrowded by the default starter lodging capacity.
	state.sect.lodging_capacity = roster_target
	var recruitment_started_msec := Time.get_ticks_msec()
	if not _recruit_roster(state):
		return
	var recruitment_msec := Time.get_ticks_msec() - recruitment_started_msec
	if not _assign_operators(state, buildings):
		return

	# Exercise only the canonical online simulation scheduler. The fixture starts
	# from a deterministic seeded state, then advances real workforce, production,
	# warehouse and needs systems for two game hours before saving.
	var timer := Time.get_ticks_msec()
	runtime.scheduler().run_ticks(SIMULATED_MINUTES)
	var simulation_msec := Time.get_ticks_msec() - timer
	state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
	state.runtime_unconsumed_wall_seconds = 0.0

	var state_errors := state.validate_invariants()
	var building_errors := buildings.validate_invariants(state)
	var warehouse_errors := WarehouseSystem.new().validate_invariants(state)
	if not state_errors.is_empty() or not building_errors.is_empty() or not warehouse_errors.is_empty():
		_fail("endgame_invariants_failed", {
			"simulation": state_errors,
			"buildings": building_errors,
			"warehouse": warehouse_errors
		})
		return

	var save_started_msec := Time.get_ticks_msec()
	var saved_error: Error = runtime.owner.saves.save_to_path(state, qa_save_path)
	var save_msec := Time.get_ticks_msec() - save_started_msec
	if saved_error != OK:
		_fail("save_service_write_failed", {"error": saved_error})
		return
	var reload_started_msec := Time.get_ticks_msec()
	var loaded := SaveService.new().load_from_path(qa_save_path)
	var reload_msec := Time.get_ticks_msec() - reload_started_msec
	if loaded == null:
		_fail("save_service_reload_failed", {})
		return
	var loaded_errors := loaded.validate_invariants()
	if not loaded_errors.is_empty():
		_fail("reloaded_state_invariants_failed", loaded_errors)
		return
	if not _roundtrip_matches(state, loaded):
		_fail("save_reload_state_mismatch", {})
		return

	var report := _build_report(state, loaded, simulation_msec)
	report["recruitment_milliseconds"] = recruitment_msec
	report["save_milliseconds"] = save_msec
	report["reload_milliseconds"] = reload_msec
	var saved_file := FileAccess.open(qa_save_path,FileAccess.READ)
	if saved_file != null:
		report["save_size_bytes"] = saved_file.get_length()
		saved_file.close()
	var report_file := FileAccess.open(qa_report_path, FileAccess.WRITE)
	if report_file == null:
		_fail("report_write_failed", {"error": FileAccess.get_open_error()})
		return
	report_file.store_string(JSON.stringify(report, "\t", true))
	report_file.flush()
	report_file.close()
	print("TMB_ENDGAME_FIXTURE " + JSON.stringify(report))
	quit(0)

func _build_required_buildings(state: SimulationState, buildings: BuildingSystem) -> void:
	for raw_type in TARGET_COUNTS:
		var building_type := StringName(raw_type)
		var required := int(TARGET_COUNTS[raw_type])
		var existing := _buildings_of_type(state, building_type)
		for index in range(existing.size() + 1, required + 1):
			var building := buildings.create_building(building_type, index)
			if building == null:
				push_error("No canonical building constructor for %s" % str(building_type))
				return
			if building_type == BuildingSystem.TYPE_ALCHEMY_HALL:
				building.production_state = buildings._default_alchemy_state()
			elif building_type == BuildingSystem.TYPE_GUIDANCE_PLATFORM:
				building.production_state = {
					"main_guide_id": "", "assistant_guide_ids": [],
					"snapshot_day_index": -1, "snapshot_main_charisma": 0.0,
					"enhanced_heaven_count": 0, "daily_arrival_target": 0,
					"daily_arrivals_generated": 0
				}
			state.buildings[str(building.id)] = building
			state.building_event_count += 1
	buildings.initialize(state)
	for raw_type in TARGET_COUNTS:
		if _buildings_of_type(state, StringName(raw_type)).size() != int(TARGET_COUNTS[raw_type]):
			push_error("Endgame fixture building count mismatch for %s" % raw_type)

func _buildings_at_supported_max(state: SimulationState) -> void:
	var building_system := BuildingSystem.new()
	for value in state.buildings.values():
		var building := value as BuildingState
		if building == null:
			continue
		# Seed only levels reachable under authored upgrade gates. Several
		# definitions advertise max_level=100 while upgrades are explicitly
		# disabled or their milestone content is not authored yet.
		building.level = _supported_level_ceiling(building, building_system)
		building.status = BuildingSystem.STATUS_ACTIVE
		building.upgrade_target_level = 0
		building.upgrade_started_tick = -1
		building.upgrade_required_work = 0.0
		building.upgrade_progress = 0.0
		building.unlocked_milestones.clear()
		for milestone in BuildingSystem.MILESTONE_LEVELS:
			if milestone <= building.level:
				building.unlocked_milestones.append(milestone)

func _supported_level_ceiling(building: BuildingState, building_system: BuildingSystem) -> int:
	var definition := building_system.definition_for(building)
	if definition.is_empty() or building.building_type == BuildingSystem.TYPE_BODY_TRAINING:
		return 1
	if not bool(definition.get("upgrade_enabled", true)):
		return 1
	var requires_component := bool(definition.get("requires_milestone_component", true))
	for target_level in range(2, building.max_level + 1):
		if BuildingSystem.MILESTONE_LEVELS.has(target_level) and requires_component:
			if building_system._milestone_component(building.building_type, target_level).is_empty():
				return target_level - 1
	return building.max_level

func _recruit_roster(state: SimulationState) -> bool:
	# Capacity 130 is an explicit synthetic endgame fixture seed, sized to the
	# requested 100 active sites plus 30 reserved expedition candidates. Every
	# disciple still comes from the production candidate/recruitment pipeline.
	state.sect.disciple_capacity = roster_target
	var recruitment := RecruitmentSystem.new()
	while state.disciples.size() < roster_target:
		var candidate := recruitment.generate_candidate(state, DiscipleGeneratorV2.SOURCE_ORDINARY)
		if candidate == null:
			_fail("canonical_candidate_generation_failed", {"population": state.disciples.size()})
			return false
		var accepted: Dictionary = recruitment.accept_candidate(state, candidate.id)
		if not bool(accepted.get("ok", false)):
			_fail("canonical_candidate_acceptance_failed", accepted)
			return false
	return true

func _assign_operators(state: SimulationState, buildings: BuildingSystem) -> bool:
	var workers: Array = state.disciples.keys()
	workers.sort()
	var offset := 0
	var assignment_map := {
		"mine": StringName("mining_crew"),
		"linh_forest": StringName("forestry_crew"),
		"spirit_field": StringName("herbalism_crew")
	}
	var workforce := WorkforceSystem.new()
	for raw_type in ["mine", "linh_forest", "spirit_field"]:
		var targets := _buildings_of_type(state, StringName(raw_type))
		targets.sort_custom(func(a: BuildingState, b: BuildingState) -> bool: return str(a.id) < str(b.id))
		for building in targets:
			if offset >= workers.size() or not workforce.assign_group(state, workers[offset], assignment_map[raw_type]):
				_fail("canonical_workforce_group_assignment_failed", {"type": raw_type, "building": str(building.id)})
				return false
			if not workforce.assign_worksite(state, workers[offset], building.id):
				_fail("canonical_worksite_assignment_failed", {"type": raw_type, "building": str(building.id), "disciple": str(workers[offset])})
				return false
			offset += 1
	if offset != 100:
		return false
	# Hold the remaining authentic disciples in a deterministic idle roster.
	# Without this explicit QA-only assignment the live scheduler autonomously
	# sends them to generic work, so the save would not prove a 30-member hunt
	# reserve or show an honest idle crowd in P3.2.
	for index in range(offset,workers.size()):
		var id := StringName(workers[index])
		if not workforce.issue_command(state,id,WorkforceSystem.COMMAND_HOLD,"",1000000):
			_fail("canonical_hunt_reserve_hold_failed", {"disciple":str(id)})
			return false
		state.disciples[id].current_action = &"HOLD"
	return true

func _buildings_of_type(state: SimulationState, building_type: StringName) -> Array[BuildingState]:
	var result: Array[BuildingState] = []
	for value in state.buildings.values():
		if value is BuildingState and (value as BuildingState).building_type == building_type:
			result.append(value)
	return result

func _roundtrip_matches(before: SimulationState, after: SimulationState) -> bool:
	if before.tick != after.tick or before.disciples.size() != after.disciples.size() or before.buildings.size() != after.buildings.size():
		return false
	if before.sect.warehouse_resources != after.sect.warehouse_resources:
		return false
	if before.disciples.keys().size() != after.disciples.keys().size():
		return false
	for id in before.buildings.keys():
		if not after.buildings.has(id):
			return false
		var a: BuildingState = before.buildings[id]
		var b: BuildingState = after.buildings[id]
		if a.level != b.level or a.metrics != b.metrics or a.production_state != b.production_state:
			return false
	for id in before.disciples.keys():
		if not after.disciples.has(id):
			return false
		var a: DiscipleState = before.disciples[id]
		var b: DiscipleState = after.disciples[id]
		if a.work_cycle_state != b.work_cycle_state or a.current_action != b.current_action:
			return false
	return true

func _build_report(state: SimulationState, loaded: SimulationState, simulation_msec: int) -> Dictionary:
	var counts := {}
	var levels := {}
	var level_ranges := {}
	var batches := 0
	var units := 0
	for value in state.buildings.values():
		var building := value as BuildingState
		counts[str(building.building_type)] = int(counts.get(str(building.building_type), 0)) + 1
		levels[str(building.building_type)] = building.level
		var type_key := str(building.building_type)
		if not level_ranges.has(type_key):
			level_ranges[type_key] = {"minimum": building.level, "maximum": building.level, "count_at_supported_ceiling": 0}
		else:
			level_ranges[type_key]["minimum"] = mini(int(level_ranges[type_key]["minimum"]), building.level)
			level_ranges[type_key]["maximum"] = maxi(int(level_ranges[type_key]["maximum"]), building.level)
		if building.level == _supported_level_ceiling(building, BuildingSystem.new()):
			level_ranges[type_key]["count_at_supported_ceiling"] = int(level_ranges[type_key]["count_at_supported_ceiling"]) + 1
		batches += int(building.metrics.get("production_batches", 0))
		units += int(building.metrics.get("units_produced", 0))
	for type_key in level_ranges:
		var example: BuildingState = _buildings_of_type(state, StringName(type_key))[0]
		level_ranges[type_key]["supported_ceiling"] = _supported_level_ceiling(example, BuildingSystem.new())
	var cycle_workers := 0
	var active_plots := 0
	for value in state.disciples.values():
		var disciple := value as DiscipleState
		if not disciple.work_cycle_state.is_empty():
			cycle_workers += 1
	for value in state.buildings.values():
		var building := value as BuildingState
		for plot in building.production_state.get("plots", []):
			if StringName(plot.get("status", "")) == BuildingSystem.PLOT_GROWING:
				active_plots += 1
	var warehouse := WarehouseSystem.new()
	var stocks := {}
	for resource_id in [BuildingSystem.MATERIAL_ORE, BuildingSystem.MATERIAL_WOOD, BuildingSystem.MATERIAL_HERB]:
		stocks[resource_id] = warehouse.quantity(state, StringName(resource_id))
	return {
		"fixture": "TMB deterministic P3.2 endgame QA seed; synthetic starting capacity, buildings, level and roster are explicit",
		"seed": SEED,
		"tick": state.tick,
		"simulated_minutes": SIMULATED_MINUTES,
		"simulation_step_milliseconds": simulation_msec,
		"population": state.disciples.size(),
		"population_profile": roster_target,
		"lodging_capacity": state.sect.lodging_capacity,
		"synthetic_qa_seed_fields": ["disciple_capacity", "lodging_capacity", "canonical_building_instances", "canonical_building_levels", "ordinary_v2_recruitment_roster"],
		"disciples_assigned_to_real_producer_sites": 100,
		"disciple_capacity_seeded": state.sect.disciple_capacity,
		"buildings_by_type": counts,
		"building_levels_by_type": levels,
		"building_level_ranges_and_supported_ceilings": level_ranges,
		"active_work_cycles": cycle_workers,
		"growing_field_plots": active_plots,
		"production_batches": batches,
		"units_produced": units,
		"warehouse": stocks,
		"state_invariants": state.validate_invariants(),
		"building_invariants": BuildingSystem.new().validate_invariants(state),
		"warehouse_invariants": WarehouseSystem.new().validate_invariants(state),
		"save_path": ProjectSettings.globalize_path(qa_save_path),
		"save_sha256": FileAccess.get_sha256(qa_save_path),
		"reload_tick": loaded.tick,
		"reload_population": loaded.disciples.size(),
		"reload_buildings": loaded.buildings.size(),
		"save_reload_exact_counts_and_work_progress": true
	}

func _preserve_existing_save_files() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(qa_save_path.get_base_dir()))
	var paths := [qa_save_path, qa_save_path + ".tmp", qa_save_path + ".bak", qa_report_path]
	var existing := paths.filter(func(path: String) -> bool: return FileAccess.file_exists(path))
	if existing.is_empty():
		return
	var stamp := Time.get_datetime_string_from_system(false, true).replace(":", "-").replace("T", "_")
	var folder := "res://qa/backups/%s" % stamp
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for path in existing:
		var target := folder.path_join(path.get_file())
		var input := FileAccess.open(path, FileAccess.READ)
		if input == null:
			continue
		var bytes := input.get_buffer(input.get_length())
		input.close()
		var output := FileAccess.open(target, FileAccess.WRITE)
		if output != null:
			output.store_buffer(bytes)
			output.close()

func _fail(reason: String, detail: Variant) -> void:
	printerr("TMB_ENDGAME_FIXTURE_FAIL " + JSON.stringify({"reason": reason, "detail": detail}))
	quit(1)
