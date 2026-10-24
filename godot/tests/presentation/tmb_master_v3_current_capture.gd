extends SceneTree

const SAVE_PATH := "user://tmb_master_v3_current_capture.json"
const DISCIPLE_GENERATION_START := 73021
const MAX_BATTLE_WALL_SECONDS := 600
const PASS_MARKER := "TMB MASTER V3 CURRENT P3.2 CAPTURE PASS"

var ui: Control
var runtime: LiveGameRuntimeV2
var state: SimulationState
var disciple: DiscipleState
var disciple_generation_index := 0
var output_dir := ""
var capture_states: Array[Dictionary] = []
var settled_mine_capture := false
var s1_burn_captured := false
var s1_weaken_captured := false

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
	var event_refs: Array[Dictionary] = []
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
				for event_index in range(battle.events.size()):
					var event_row: Dictionary = battle.events[event_index]
					var event_kind := str(event_row.get("type", ""))
					if event_kind in ["hit","skill_cast","skill_hit","status_applied","status_tick","kill"]:
						event_refs.append({
							"event_index":event_index,"type":event_kind,"time":float(event_row.get("time",0.0)),
							"caster":str(event_row.get("caster",event_row.get("actor_id",""))),
							"target":str(event_row.get("target","")),
							"skill_id":str(event_row.get("skill_id","")),
							"status":str(event_row.get("status",""))
						})
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
		"event_refs": event_refs,
		"fps": Engine.get_frames_per_second(),
		"static_memory_bytes": int(Performance.get_monitor(Performance.MEMORY_STATIC)),
		"captured_at_utc": Time.get_datetime_string_from_system(true),
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
	row["image_path"] = name + ".png"
	capture_states.append(row)
	print("CURRENT_CAPTURE_PASS name=%s size=1280x720 tick=%d battle=%.2f paid=%d" % [
		name, int(row["tick"]), float(row["battle_seconds"]), int(row["paid_kills"])
	])
	return true

func _new_real_v2(target_sex: String = "male") -> DiscipleState:
	state.sect.disciple_capacity = maxi(state.sect.disciple_capacity, state.disciples.size() + 1)
	var generation_index := DISCIPLE_GENERATION_START
	var generator := DiscipleGeneratorOpenPoints.new()
	for _attempt in range(128):
		var candidate_id := StringName("candidate_%04d" % generation_index)
		while state.disciples.has(candidate_id) or state.recruitment_candidates.has(candidate_id):
			generation_index += 1
			candidate_id = StringName("candidate_%04d" % generation_index)
		var candidate := generator.generate_candidate(
			state, DiscipleGeneratorV2.SOURCE_ORDINARY, generation_index
		)
		if candidate == null or candidate.v2_birth_profile.is_empty():
			return null
		if str(candidate.sex_id) != target_sex:
			generation_index += 1
			continue
		state.recruitment_candidates[candidate.id] = candidate
		var accepted := RecruitmentSystem.new().accept_candidate(state, candidate.id)
		if bool(accepted.get("ok", false)):
			disciple_generation_index = generation_index
			return state.disciples.get(candidate.id) as DiscipleState
		return null
	return null

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

func _step_battle_capture(runtime_now: int) -> bool:
	for _i in range(2000):
		var result := runtime.poll(runtime_now,1)
		if not bool(result.get("ok",false)):
			push_error("canonical runtime poll failed during capture: " + str(result))
			return false
		ui.call("_refresh_b3_hunt_panel")
		var restored := B3HuntWorld.restore(state)
		if not bool(restored.get("ok",false)):
			push_error("CARE battle restore failed during frame capture")
			return false
		var battle := restored["battle"] as MapBattleV2
		if not s1_weaken_captured:
			var weaken_target := _active_s1_status_target(battle,"weaken")
			if not weaken_target.is_empty():
				var arena := ui.get("b3_hunt_arena") as Control
				var presenter := arena.get("presenter") as B3CareCombatV5Presenter
				if not await _capture("13_current_combat_s1_real_weaken",{
					"target_id":str(weaken_target["actor_id"]),
					"remaining_seconds":float(weaken_target["remaining"]),
					"status":weaken_target["status"].duplicate(true),
					"feedback":presenter.latest_s1_status_feedback(),
					"disciple_id":str(disciple.id)
				}):
					push_error("real S1 weaken image did not capture")
					return false
				s1_weaken_captured = true
		if not s1_burn_captured:
			var burn_target := _active_burn_target(battle)
			if not burn_target.is_empty():
				var arena := ui.get("b3_hunt_arena") as Control
				var presenter := arena.get("presenter") as B3CareCombatV5Presenter
				var feedback := presenter.latest_s1_status_feedback()
				if feedback.contains("Hỏa Cầu") and feedback.contains("BỎNG"):
					if not await _capture("10_current_combat_s1_real_burn",{
						"target_id":str(burn_target["actor_id"]),
						"remaining_seconds":float(burn_target["remaining"]),
						"status":burn_target["status"].duplicate(true),
						"feedback":feedback,
						"disciple_id":str(disciple.id)
					}):
						push_error("real S1 burn image did not capture")
						return false
					s1_burn_captured = true
		if runtime.state().runtime_unconsumed_wall_seconds < 0.25:
			return true
	return false

func _event_present(battle: MapBattleV2, kind: String) -> bool:
	for event in battle.events:
		if str((event as Dictionary).get("type", "")) == kind:
			return true
	return false

func _press_button(node_name: String) -> bool:
	var button := ui.find_child(node_name, true, false) as Button
	if button == null or button.disabled:
		push_error("P3.2 capture could not press actual UI button: " + node_name)
		return false
	button.emit_signal("pressed")
	await process_frame
	return true

func _settle_real_mine_capture() -> bool:
	var buildings := BuildingSystem.new()
	var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
	if mine == null:
		push_error("P3.2 capture has no canonical Mine instance")
		return false
	var active := buildings.active_worker_ids(state, mine)
	if active.size() < 2:
		push_error("P3.2 capture Mine lacks two real active workers for isolation")
		return false
	var target_id: StringName = active[0]
	var other_id: StringName = active[1]
	ui.call("_open_building", SectMapPresentation.DEST_MINE)
	await _wait_frames(2)
	if not await _press_button("Group_mining_crew_%s" % str(other_id)):
		return false
	if not await _press_button("Group_mining_crew_%s" % str(target_id)):
		return false
	if not await _press_button("Group_mining_crew_%s" % str(target_id)):
		return false
	for raw_id in state.disciples.keys():
		var hold_id := StringName(raw_id)
		if hold_id == target_id:
			continue
		if not WorkforceSystem.new().issue_command(
				state,hold_id,WorkforceSystem.COMMAND_HOLD,"",1000000):
			push_error("P3.2 capture could not isolate unrelated worker " + str(hold_id))
			return false
	var target: DiscipleState = state.disciples[target_id]
	var work_button := ui.find_child("Work_mining_%s" % str(target_id),true,false) as Button
	if work_button == null or work_button.disabled:
		push_error("P3.2 capture has no enabled canonical Mine work action")
		return false
	var warehouse := WarehouseSystem.new()
	var ore_before := warehouse.quantity(state,&"thanh_thiet")
	work_button.emit_signal("pressed")
	await process_frame
	if WorkforceSystem.new().command_kind(target) != WorkforceSystem.COMMAND_WORK:
		push_error("P3.2 Mine action did not create the real worker command")
		return false
	var scheduler := runtime.scheduler()
	if scheduler == null:
		push_error("P3.2 capture could not access its canonical runtime scheduler")
		return false
	var seen := {}
	var reached_haul := false
	for _i in range(48):
		scheduler.step()
		ui.call("_refresh_all")
		var phase := str(target.work_cycle_state.get("phase",""))
		if not phase.is_empty():
			seen[phase] = true
		if phase == "haul_back" and int(target.work_cycle_state.get("carried_units",0)) > 0:
			reached_haul = true
			break
	if not reached_haul or warehouse.quantity(state,&"thanh_thiet") != ore_before:
		push_error("P3.2 real Mine did not pass haul_back before depositing")
		return false
	var deposited := false
	for _i in range(48):
		scheduler.step()
		ui.call("_refresh_all")
		if warehouse.quantity(state,&"thanh_thiet") > ore_before:
			deposited = true
			break
	var definition: Dictionary = BuildingSystem.DEFINITIONS[str(BuildingSystem.TYPE_MINE)]
	var expected_batch := maxi(int(definition.get("base_batch_units",1)),1) + int(floor(float(mine.level)/10.0))
	var ore_after := warehouse.quantity(state,&"thanh_thiet")
	if not deposited or ore_after != ore_before + expected_batch:
		push_error("P3.2 real Mine batch mismatch: before=%d after=%d expected_delta=%d" % [
			ore_before,ore_after,expected_batch])
		return false
	for phase_name in ["travel_out","mining","haul_back"]:
		if not seen.has(phase_name):
			push_error("P3.2 real Mine did not visit phase " + phase_name)
			return false
	ui.call("_refresh_all")
	return await _capture("08_current_mine_after_real_settlement",{
		"building_id":str(mine.id),
		"worker_id":str(target_id),
		"warehouse_before":ore_before,
		"warehouse_after":ore_after,
		"expected_batch":expected_batch,
		"observed_phases":seen.keys()
	})

func _active_burn_target(battle: MapBattleV2) -> Dictionary:
	if battle == null:
		return {}
	for raw_id in battle.actors.keys():
		var actor: Dictionary = battle.actors[raw_id]
		if str(actor.get("side","")) != "monster":
			continue
		var statuses: Dictionary = actor.get("status_effects",{})
		var burn: Dictionary = statuses.get("burn",{})
		var remaining := float(burn.get("until",-1.0))-battle.now
		if not burn.is_empty() and remaining > 0.000001:
			return {"actor_id":str(raw_id),"remaining":remaining,"status":burn.duplicate(true)}
	return {}

func _active_s1_status_target(battle: MapBattleV2, status_id: String) -> Dictionary:
	if battle == null:
		return {}
	for raw_id in battle.actors.keys():
		var actor: Dictionary = battle.actors[raw_id]
		var statuses: Dictionary = actor.get("status_effects",{})
		var effect: Dictionary = statuses.get(status_id,{})
		var remaining := float(effect.get("until",-1.0))-battle.now
		if not effect.is_empty() and remaining > 0.000001:
			return {"actor_id":str(raw_id),"remaining":remaining,"status":effect.duplicate(true)}
	return {}

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

	disciple = _new_real_v2("male")
	if disciple == null:
		_fail("could not recruit a real V2 disciple for capture")
		return
	ui.call("_open_disciple_deep_screen", disciple.id, "Thuộc tính")
	var disciple_sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple))
	if disciple_sex != "male":
		_fail("canonical V2 profile capture did not resolve to a male disciple")
		return
	var male_generation_index := disciple_generation_index
	if not await _capture("06_current_v2_male_profile", {"recruitment_source": "canonical ordinary", "generation_index": male_generation_index, "visual_sex": disciple_sex}):
		_fail("V2 disciple profile did not capture")
		return
	var male_disciple := disciple
	var female_disciple := _new_real_v2("female")
	if female_disciple == null:
		_fail("could not recruit a real female V2 disciple for the profile capture")
		return
	var female_generation_index := disciple_generation_index
	disciple = female_disciple
	ui.call("_open_disciple_deep_screen", disciple.id, "Thuộc tính")
	var female_sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple))
	if female_sex != "female":
		_fail("canonical V2 female profile capture did not resolve to a female disciple")
		return
	if not await _capture("07_current_v2_female_profile", {"recruitment_source": "canonical ordinary", "generation_index": disciple_generation_index, "visual_sex": female_sex}):
		_fail("female V2 disciple profile did not capture")
		return
	disciple = male_disciple
	disciple_generation_index = male_generation_index
	ui.call("_open_disciple_deep_screen", disciple.id, "Thuộc tính")
	await process_frame
	if not WorkforceSystem.new().issue_command(state, disciple.id, WorkforceSystem.COMMAND_HOLD, "", 1000000):
		_fail("V2 disciple could not enter an idle state")
		return
	var equipment := EquipmentSystem.new()
	var weapon := equipment.craft(state, &"thanh_thiet_kiem", false)
	if weapon.is_empty() or not equipment.manual_equip(state, disciple.id, StringName(weapon.get("id", ""))):
		_fail("canonical test weapon craft/equip failed")
		return
	if not CombatSkillSystem.new().learn_skill(state,disciple,&"hoa_cau"):
		_fail("canonical Combat V2 Hỏa Cầu skill learn failed")
		return
	if not CombatSkillSystem.new().learn_skill(state,disciple,&"chan_son_quyen"):
		_fail("canonical Combat V2 Chấn Sơn Quyền skill learn failed")
		return
	if not await _settle_real_mine_capture():
		_fail("real Mine production did not settle into the canonical Warehouse; inspect capture log")
		return
	settled_mine_capture = true
	ui.call("_close_building_operation_panel",true)
	await process_frame
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
	if not await _capture("09_current_combat_v5_start"):
		_fail("combat start did not capture")
		return

	var sim_now := int(state.runtime_last_wall_unix)
	var hit_captured := false
	var skill_hit_captured := false
	var loot_captured := false
	var paid_before := int(state.sect.b3_hunt["slot"]["paid_generation"])
	var generation_before_respawn := int(state.sect.b3_hunt["slot"]["generation"])
	for _second in range(1, MAX_BATTLE_WALL_SECONDS + 1):
		sim_now += 1
		if not await _step_battle_capture(sim_now):
			_fail("canonical runtime clock did not drain capture step")
			return
		ui.call("_refresh_b3_hunt_panel")
		var restored := B3HuntWorld.restore(state)
		if not bool(restored.get("ok", false)):
			_fail("CARE battle restore failed while progressing capture")
			return
		var battle := restored["battle"] as MapBattleV2
		var weaken_target := _active_s1_status_target(battle,"weaken")
		if not s1_weaken_captured and not weaken_target.is_empty():
			var status_arena := ui.get("b3_hunt_arena") as Control
			var status_presenter := status_arena.get("presenter") as B3CareCombatV5Presenter
			if not await _capture("13_current_combat_s1_real_weaken",{
				"target_id":str(weaken_target["actor_id"]),
				"remaining_seconds":float(weaken_target["remaining"]),
				"status":weaken_target["status"].duplicate(true),
				"feedback":status_presenter.latest_s1_status_feedback(),
				"disciple_id":str(disciple.id)
			}):
				_fail("real S1 weaken image did not capture")
				return
			s1_weaken_captured = true
		var burn_target := _active_burn_target(battle)
		if not s1_burn_captured and not burn_target.is_empty():
			var s1_arena := ui.get("b3_hunt_arena") as Control
			var s1_presenter := s1_arena.get("presenter") as B3CareCombatV5Presenter
			var feedback := s1_presenter.latest_s1_status_feedback()
			if feedback.contains("Hỏa Cầu") and feedback.contains("BỎNG"):
				if not await _capture("10_current_combat_s1_real_burn",{
					"target_id":str(burn_target["actor_id"]),
					"remaining_seconds":float(burn_target["remaining"]),
					"status":burn_target["status"].duplicate(true),
					"feedback":feedback,
					"disciple_id":str(disciple.id)
				}):
					_fail("real S1 burn image did not capture")
					return
				s1_burn_captured = true
		if not hit_captured and _event_present(battle, "hit") and battle.now > 0.0:
			if not await _capture("11_current_combat_after_real_hit"):
				_fail("real hit image did not capture")
				return
			hit_captured = true
		if not skill_hit_captured and _event_present(battle, "skill_hit") and battle.now > 0.0:
			if not await _capture("12_current_combat_after_real_skill_hit"):
				_fail("real skill hit image did not capture")
				return
			skill_hit_captured = true
		if int(state.sect.b3_hunt["slot"]["paid_generation"]) > paid_before:
			var receipt := state.sect.b3_hunt.get("receipt", {}) as Dictionary
			if str(receipt.get("state", "")).to_upper() != "COMMITTED":
				_fail("kill generation advanced without a committed canonical loot receipt")
				return
			if not await _capture("14_current_combat_after_paid_loot", {"receipt": receipt.duplicate(true)}):
				_fail("paid loot image did not capture")
				return
			loot_captured = true
			break
	if not hit_captured or not loot_captured or not s1_burn_captured:
		_fail("capture missed real hit, S1 burn, or paid-loot evidence; hit=%s burn=%s loot=%s" % [hit_captured,s1_burn_captured,loot_captured])
		return
	var safe_respawn_captured := false
	for _second in range(1,32):
		sim_now += 1
		if not _step_to(sim_now):
			_fail("canonical runtime clock did not reach the same-world respawn gate")
			return
		var respawned := B3HuntWorld.restore(state)
		if not bool(respawned.get("ok",false)):
			_fail("CARE world failed to restore while waiting for the expired monster status to clear")
			return
		var respawn_battle := respawned["battle"] as MapBattleV2
		var generation := int(state.sect.b3_hunt.get("slot",{}).get("generation",0))
		var old_monster_id := str(B3PilotContent.monster(
			str(state.sect.b3_hunt.get("world_id","")),generation_before_respawn).get("id",""))
		if generation > generation_before_respawn and not respawn_battle.actors.has(old_monster_id):
			var old_status_present := false
			for actor_raw in respawn_battle.actors.values():
				var actor: Dictionary = actor_raw
				var statuses: Dictionary = actor.get("status_effects",{})
				for status_raw in statuses.values():
					if str((status_raw as Dictionary).get("caster","")) == str(disciple.id):
						old_status_present = true
			if not old_status_present:
				ui.call("_refresh_b3_hunt_panel")
				if not await _capture("15_current_combat_same_world_after_respawn"):
					_fail("same-world post-respawn image did not capture")
					return
				safe_respawn_captured = true
				break
	if not safe_respawn_captured:
		_fail("same CARE world did not replace the downed monster and clear its S1 source before return")
		return
	ui.call("_return_from_b3_hunt")
	if not await _capture("16_current_main_after_hunt_return"):
		_fail("return-to-sect image did not capture")
		return

	var saved := runtime.owner.saves.load_from_path(SAVE_PATH)
	if saved == null:
		_fail("canonical SaveService could not reload the post-loot capture save")
		return
	var committed_count := int(saved.sect.b3_hunt.get("slot", {}).get("paid_generation", 0))
	var saved_stock := WarehouseSystem.new().quantity(saved, B3PilotContent.RESOURCE)
	var saved_returns := int(saved.sect.b3_hunt.get("returns",0))
	var saved_receipt: Dictionary = saved.sect.b3_hunt.get("receipt",{})
	var saved_world_id := str(saved.sect.b3_hunt.get("world_id",""))
	if committed_count != 1 or saved_stock != 1 or saved_returns != 1:
		_fail("SaveService reload missed the real kill or canonical Warehouse stock")
		return

	if not skill_hit_captured:
		_fail("real Combat V2 skill hit did not appear in the live CARE fight")
		return
	var metadata := {
		"source_sha": OS.get_environment("TMB_MASTER_V3_SOURCE_SHA"),
		"source_tree_sha": OS.get_environment("TMB_MASTER_V3_SOURCE_TREE_SHA"),
		"engine": Engine.get_version_info().string,
		"captured_at_utc": Time.get_datetime_string_from_system(true),
		"scene": "res://scenes/p3/p3_2_landscape_sect.tscn",
		"viewport": [1280, 720],
		"renderer": "OpenGL 3.3 Compatibility / Intel Iris Plus (see engine log)",
		"seed": LiveGameRuntimeV2.DEFAULT_SEED,
		"capture_states": capture_states,
		"verified_save_load": {
			"expected":{"paid_generation":1,"warehouse_pilot_stock":1,"returns":1},
			"actual":{"paid_generation":committed_count,"warehouse_pilot_stock":saved_stock,
				"returns":saved_returns,"world_id":saved_world_id,"receipt":saved_receipt.duplicate(true)}
		},
		"skill_hit_captured": skill_hit_captured,
		"demo_disciple":{"id":str(disciple.id),"generation_index":disciple_generation_index,"visual_sex":disciple_sex},
		"s1_demo_disciple":{"id":str(disciple.id),"generation_index":male_generation_index,
			"visual_sex":disciple_sex},
		"female_demo_disciple":{"id":str(female_disciple.id),"generation_index":female_generation_index,
			"visual_sex":female_sex},
		"settled_mine_capture":settled_mine_capture,
		"s1_burn_captured":s1_burn_captured,
		"s1_weaken_captured":s1_weaken_captured,
		"s1_status_visuals":{"burn_live_captured":s1_burn_captured,
			"weaken_live_captured":s1_weaken_captured,
			"learned_guard_skill_eligible":CombatSkillSystem.new().can_learn_skill(
				state,disciple,&"kim_cuong_ho_the"),
			"disciple_legacy_skill_stage":disciple.cultivation_stage_index}
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
