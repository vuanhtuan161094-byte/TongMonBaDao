extends SceneTree

const SAVE_PATH := "user://tmb_master_v3_current_capture.json"
const DISCIPLE_GENERATION_START := 73021
const MAX_BATTLE_WALL_SECONDS := 600
const PASS_MARKER := "TMB MASTER V3 CURRENT P3.2 CAPTURE PASS"

var ui: Control
var runtime: LiveGameRuntimeV2
var state: SimulationState
var disciple: DiscipleState
var output_dir := ""
var capture_states: Array[Dictionary] = []

func _init() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("TMB MASTER V3 CAPTURE FAIL: " + message)
	_cleanup()
	quit(1)

func _cleanup() -> void:
	if ui != null:
		for timer_name in ["runtime_poll_timer", "autosave_timer"]:
			var timer := ui.get(timer_name) as Timer
			if timer != null:
				timer.stop()
		ui.set("runtime_ready", false)
		ui.queue_free()
		ui = null
	for path in [SAVE_PATH, SAVE_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	ProjectSettings.set_setting("runtime/live_save_path", null)

func _wait_frames(count: int = 5) -> void:
	for _i in range(count):
		await process_frame

func _snapshot(screen_name: String, viewport: Vector2i, extra: Dictionary = {}) -> Dictionary:
	var battle_now := 0.0
	var event_types: Array[String] = []
	var paid_kills := 0
	var warehouse_total := 0
	var auto_hunt := false
	var world_id := ""
	if state != null:
		paid_kills = int(state.sect.b3_hunt.get("slot", {}).get("paid_generation", 0))
		warehouse_total = WarehouseSystem.new().quantity(state, B3PilotContent.RESOURCE)
		auto_hunt = bool(state.sect.b3_hunt.get("care", {}).get("auto_hunt", false))
		world_id = str(state.sect.b3_hunt.get("world_id", ""))
		if not state.sect.b3_hunt.is_empty():
			var restored := B3HuntWorld.restore(state)
			if bool(restored.get("ok", false)):
				var battle := restored["battle"] as MapBattleV2
				battle_now = battle.now
				for event in battle.events:
					var kind := str((event as Dictionary).get("type", ""))
					if not event_types.has(kind):
						event_types.append(kind)
	var result := {
		"screen": screen_name,
		"scene": "res://scenes/p3/p3_2_landscape_sect.tscn",
		"viewport": [viewport.x, viewport.y],
		"tick": state.tick if state != null else -1,
		"wall_unix": state.runtime_last_wall_unix if state != null else 0,
		"battle_seconds": battle_now,
		"disciple_id": str(disciple.id) if disciple != null else "",
		"hp": disciple.hp if disciple != null else 0.0,
		"max_hp": disciple.max_hp if disciple != null else 0.0,
		"injury": disciple.injury_level if disciple != null else 0,
		"paid_kills": paid_kills,
		"warehouse_pilot_stock": warehouse_total,
		"auto": auto_hunt,
		"world_id": world_id,
		"event_types": event_types,
		"extra": extra
	}
	return result

func _capture(name: String, extra: Dictionary = {}) -> bool:
	await _wait_frames()
	var viewport := root.get_viewport()
	if viewport == null or viewport.size != Vector2i(1280, 720):
		push_error("TMB MASTER V3 capture viewport is not 1280x720")
		return false
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty() or image.get_width() != 1280 or image.get_height() != 720:
		push_error("TMB MASTER V3 capture got an invalid image for " + name)
		return false
	var path := output_dir.path_join(name + ".png")
	if image.save_png(path) != OK:
		push_error("TMB MASTER V3 capture could not write " + path)
		return false
	var row := _snapshot(name, viewport.size, extra)
	row["image_path"] = path
	capture_states.append(row)
	print("CURRENT_CAPTURE_PASS name=%s size=1280x720 tick=%d battle=%.2f paid=%d" % [
		name, int(row["tick"]), float(row["battle_seconds"]), int(row["paid_kills"])
	])
	return true

func _new_real_v2() -> DiscipleState:
	state.sect.disciple_capacity = maxi(state.sect.disciple_capacity, state.disciples.size() + 1)
	var generation_index := DISCIPLE_GENERATION_START
	var candidate_id := StringName("candidate_%04d" % generation_index)
	while state.disciples.has(candidate_id) or state.recruitment_candidates.has(candidate_id):
		generation_index += 1
		candidate_id = StringName("candidate_%04d" % generation_index)
	var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
		state, DiscipleGeneratorV2.SOURCE_ORDINARY, generation_index
	)
	if candidate == null or candidate.v2_birth_profile.is_empty():
		return null
	state.recruitment_candidates[candidate.id] = candidate
	var accepted := RecruitmentSystem.new().accept_candidate(state, candidate.id)
	return state.disciples.get(candidate.id) if accepted.get("ok", false) else null

func _first_building(building_type: StringName) -> BuildingState:
	var matches: Array[BuildingState] = []
	for value in state.buildings.values():
		if value is BuildingState and (value as BuildingState).building_type == building_type:
			matches.append(value)
	matches.sort_custom(func(a: BuildingState, b: BuildingState) -> bool: return str(a.id) < str(b.id))
	return matches[0] if not matches.is_empty() else null

func _open_building_and_capture(destination: StringName, building_type: StringName, name: String) -> bool:
	var building := _first_building(building_type)
	if building == null:
		return false
	ui.call("_open_building", destination, building.id)
	return await _capture(name, {"building_id": str(building.id), "building_type": str(building_type)})

func _step_to(runtime_now: int) -> bool:
	for _i in range(2000):
		var result := runtime.poll(runtime_now, 10)
		if not bool(result.get("ok", false)):
			push_error("canonical runtime poll failed: " + str(result))
			return false
		if runtime.state().runtime_unconsumed_wall_seconds < 0.25:
			return true
	return false

func _event_present(battle: MapBattleV2, kind: String) -> bool:
	for event in battle.events:
		if str((event as Dictionary).get("type", "")) == kind:
			return true
	return false

func _run() -> void:
	output_dir = OS.get_environment("TMB_MASTER_V3_CAPTURE_DIR").strip_edges()
	if output_dir.is_empty():
		output_dir = ProjectSettings.globalize_path("res://../outputs/TMB_MASTER_V3_20261024/00_current_capture")
	DirAccess.make_dir_recursive_absolute(output_dir)
	for path in [SAVE_PATH, SAVE_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if packed == null:
		_fail("actual P3.2 main scene did not load")
		return
	ui = packed.instantiate() as Control
	if ui == null:
		_fail("actual P3.2 main scene did not instantiate")
		return
	root.add_child(ui)
	await _wait_frames(15)
	if not bool(ui.get("runtime_ready")):
		_fail("actual P3.2 runtime did not become ready")
		return
	runtime = ui.get("runtime_session") as LiveGameRuntimeV2
	state = ui.get("state") as SimulationState
	if runtime == null or state == null or runtime.owner.state != state:
		_fail("P3.2 is not bound to the canonical live runtime")
		return
	for timer_name in ["runtime_poll_timer", "autosave_timer"]:
		var timer := ui.get(timer_name) as Timer
		if timer != null:
			timer.stop()
	print("CAPTURE_CONTEXT source_sha=%s engine=%s scene=res://scenes/p3/p3_2_landscape_sect.tscn seed=%d tick=%d viewport=%s" % [
		OS.get_environment("TMB_MASTER_V3_SOURCE_SHA"), Engine.get_version_info().string,
		LiveGameRuntimeV2.DEFAULT_SEED, state.tick, root.get_viewport().size
	])
	if not await _capture("00_current_map_main"):
		_fail("main map image did not capture")
		return
	ui.call("_zoom_at", Vector2(640, 350), 1.35, false)
	ui.call("_pan_camera", Vector2(-26.0, -16.0))
	if not await _capture("01_current_map_pan_zoom"):
		_fail("map pan/zoom image did not capture")
		return
	ui.call("_reset_camera", false)
	if not await _open_building_and_capture(SectMapPresentation.DEST_MINE, BuildingSystem.TYPE_MINE, "02_current_mine"):
		_fail("Mỏ screen did not capture")
		return
	if not await _open_building_and_capture(SectMapPresentation.DEST_LINH_FOREST, BuildingSystem.TYPE_LINH_FOREST, "03_current_linh_lam"):
		_fail("Linh Lâm screen did not capture")
		return
	if not await _open_building_and_capture(SectMapPresentation.DEST_SPIRIT_FIELD, BuildingSystem.TYPE_SPIRIT_FIELD, "04_current_linh_dien"):
		_fail("Linh Điền screen did not capture")
		return
	ui.call("_open_building", SectMapPresentation.DEST_WAREHOUSE)
	if not await _capture("05_current_warehouse"):
		_fail("Kho screen did not capture")
		return

	disciple = _new_real_v2()
	if disciple == null:
		_fail("could not recruit a real V2 disciple for capture")
		return
	ui.call("_open_disciple_deep_screen", disciple.id, "Thuộc tính")
	if not await _capture("06_current_v2_disciple_profile", {"recruitment_source": "canonical ordinary", "generation_index": DISCIPLE_GENERATION_START}):
		_fail("V2 disciple profile did not capture")
		return
	if not WorkforceSystem.new().issue_command(state, disciple.id, WorkforceSystem.COMMAND_HOLD, "", 1000000):
		_fail("V2 disciple could not enter an idle state")
		return
	var equipment := EquipmentSystem.new()
	var weapon := equipment.craft(state, &"thanh_thiet_kiem", false)
	if weapon.is_empty() or not equipment.manual_equip(state, disciple.id, StringName(weapon.get("id", ""))):
		_fail("canonical test weapon craft/equip failed")
		return
	if not CombatSkillSystem.new().learn_skill(state, disciple, &"thanh_phong_tram"):
		_fail("canonical Combat V2 skill learn failed")
		return
	# This diagnostic number follows the accepted P3.2 CARE integration fixture.
	disciple.v2_realm_progress["cultivation"]["xp"] = 2468.0
	var begun := B3HuntWorld.begin(runtime.owner, disciple.id)
	if not bool(begun.get("ok", false)):
		_fail("CARE hunt could not start for the selected real V2 disciple: " + str(begun))
		return
	var auto := B3MedicalAutoplayV1.configure(runtime.owner, disciple.id, true)
	if not bool(auto.get("ok", false)):
		_fail("canonical CARE AUTO could not be enabled: " + str(auto))
		return
	ui.call("_open_b3_hunt_panel", disciple.id)
	ui.call("_refresh_b3_hunt_panel")
	var initial := B3HuntWorld.restore(state)
	if not bool(initial.get("ok", false)):
		_fail("CARE B3 battle snapshot did not restore")
		return
	if not await _capture("07_current_combat_v5_start"):
		_fail("combat start did not capture")
		return

	var sim_now := int(state.runtime_last_wall_unix)
	var hit_captured := false
	var skill_hit_captured := false
	var loot_captured := false
	var paid_before := int(state.sect.b3_hunt["slot"]["paid_generation"])
	for _second in range(1, MAX_BATTLE_WALL_SECONDS + 1):
		sim_now += 1
		if not _step_to(sim_now):
			_fail("canonical runtime clock did not drain capture step")
			return
		ui.call("_refresh_b3_hunt_panel")
		var restored := B3HuntWorld.restore(state)
		if not bool(restored.get("ok", false)):
			_fail("CARE battle restore failed while progressing capture")
			return
		var battle := restored["battle"] as MapBattleV2
		if not hit_captured and _event_present(battle, "hit") and battle.now > 0.0:
			if not await _capture("08_current_combat_after_real_hit"):
				_fail("real hit image did not capture")
				return
			hit_captured = true
		if not skill_hit_captured and _event_present(battle, "skill_hit") and battle.now > 0.0:
			if not await _capture("09_current_combat_after_real_skill_hit"):
				_fail("real skill hit image did not capture")
				return
			skill_hit_captured = true
		if int(state.sect.b3_hunt["slot"]["paid_generation"]) > paid_before:
			var receipt := state.sect.b3_hunt.get("receipt", {}) as Dictionary
			if str(receipt.get("state", "")).to_upper() != "COMMITTED":
				_fail("kill generation advanced without a committed canonical loot receipt")
				return
			if not await _capture("10_current_combat_after_paid_loot", {"receipt": receipt.duplicate(true)}):
				_fail("paid loot image did not capture")
				return
			loot_captured = true
			break
	if not hit_captured or not loot_captured:
		_fail("capture did not reach actual hit and paid-loot states; hit=%s loot=%s" % [hit_captured, loot_captured])
		return
	if not skill_hit_captured:
		print("PENDING_SKILL_HIT_CAPTURE: learned skill did not release in the live B3 pilot window")
	ui.call("_return_from_b3_hunt")
	if not await _capture("11_current_main_after_hunt_return"):
		_fail("return-to-sect image did not capture")
		return

	var saved := runtime.owner.saves.load_from_path(SAVE_PATH)
	if saved == null:
		_fail("canonical SaveService could not reload the post-loot capture save")
		return
	var committed_count := int(saved.sect.b3_hunt.get("slot", {}).get("paid_generation", 0))
	var saved_stock := WarehouseSystem.new().quantity(saved, B3PilotContent.RESOURCE)
	if committed_count <= 0 or saved_stock < 1:
		_fail("SaveService reload missed the real kill or canonical Warehouse stock")
		return
	var metadata := {
		"source_sha": OS.get_environment("TMB_MASTER_V3_SOURCE_SHA"),
		"engine": Engine.get_version_info().string,
		"scene": "res://scenes/p3/p3_2_landscape_sect.tscn",
		"viewport": [1280, 720],
		"renderer": "OpenGL 3.3 Compatibility / Intel Iris Plus (see engine log)",
		"seed": LiveGameRuntimeV2.DEFAULT_SEED,
		"capture_states": capture_states,
		"verified_save_load": {"paid_generation": committed_count, "warehouse_pilot_stock": saved_stock},
		"skill_hit_captured": skill_hit_captured
	}
	var metadata_file := FileAccess.open(output_dir.path_join("capture_state_manifest.json"), FileAccess.WRITE)
	if metadata_file == null:
		_fail("capture-state manifest could not be written")
		return
	metadata_file.store_string(JSON.stringify(metadata, "\t"))
	metadata_file.close()
	_cleanup()
	print(PASS_MARKER)
	quit(0)
