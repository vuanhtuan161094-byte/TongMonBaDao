extends SceneTree

const SAVE_PATH := "user://master_recovery_visual_capture.json"
const DISCIPLE_GENERATION_START := 73021
const PASS_MARKER := "MASTER RECOVERY 1280x720 VISUAL CAPTURE PASS"

var ui: Control
var output_dir := ""

func _init() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("MASTER RECOVERY VISUAL CAPTURE FAIL: " + message)
	_cleanup()
	quit(1)

func _cleanup() -> void:
	if ui != null:
		for timer_name in ["runtime_poll_timer","autosave_timer"]:
			var timer := ui.get(timer_name) as Timer
			if timer != null:
				timer.stop()
		ui.set("runtime_ready",false)
		ui.queue_free()
		ui = null
	for path in [SAVE_PATH,SAVE_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	ProjectSettings.set_setting("runtime/live_save_path",null)

func _wait_frames(count: int = 8) -> void:
	for _index in range(count):
		await process_frame

func _capture(name: String) -> bool:
	await _wait_frames(5)
	var viewport := root.get_viewport()
	if viewport == null or viewport.size != Vector2i(1280,720):
		push_error("viewport is not 1280x720: %s" % ("null" if viewport == null else str(viewport.size)))
		return false
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty() or image.get_width() != 1280 or image.get_height() != 720:
		push_error("capture image has wrong size for " + name)
		return false
	var path := output_dir.path_join(name + ".png")
	if image.save_png(path) != OK:
		push_error("could not save screenshot: " + path)
		return false
	print("CAPTURE_PASS name=%s size=1280x720 path=%s" % [name,path])
	return true

func _new_real_v2(state: SimulationState) -> DiscipleState:
	state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
	var generation_index := DISCIPLE_GENERATION_START
	var candidate_id := StringName("candidate_%04d" % generation_index)
	while state.disciples.has(candidate_id) or state.recruitment_candidates.has(candidate_id):
		generation_index += 1
		candidate_id = StringName("candidate_%04d" % generation_index)
	var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
		state,DiscipleGeneratorV2.SOURCE_ORDINARY,generation_index
	)
	if candidate == null or candidate.v2_birth_profile.is_empty():
		return null
	state.recruitment_candidates[candidate.id] = candidate
	var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
	return state.disciples.get(candidate.id) if accepted.get("ok",false) else null

func _first_building(state: SimulationState, building_type: StringName) -> BuildingState:
	var matches: Array[BuildingState] = []
	for value in state.buildings.values():
		if value is BuildingState and (value as BuildingState).building_type == building_type:
			matches.append(value)
	matches.sort_custom(func(a: BuildingState,b: BuildingState) -> bool: return str(a.id)<str(b.id))
	return matches[0] if not matches.is_empty() else null

func _open_and_capture_building(destination: StringName, instance: BuildingState, screenshot_name: String) -> bool:
	if instance == null:
		push_error("canonical building is missing for " + screenshot_name)
		return false
	ui.call("_open_building",destination,instance.id)
	return await _capture(screenshot_name)

func _run() -> void:
	output_dir = OS.get_environment("TMB_MASTER_RECOVERY_CAPTURE_DIR").strip_edges()
	if output_dir.is_empty():
		output_dir = ProjectSettings.globalize_path("res://../outputs/MASTER_RECOVERY_INTEGRATION_20261023/screenshots")
	DirAccess.make_dir_recursive_absolute(output_dir)
	ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if packed == null:
		_fail("could not load the actual P3.2 main scene")
		return
	ui = packed.instantiate() as Control
	if ui == null:
		_fail("could not instantiate the actual P3.2 main scene")
		return
	root.add_child(ui)
	await _wait_frames(15)
	if not bool(ui.get("runtime_ready")):
		_fail("main runtime did not start")
		return
	var state := ui.get("state") as SimulationState
	var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
	if state == null or runtime == null or runtime.owner.state != state:
		_fail("main screen lost the canonical live runtime binding")
		return
	print("CAPTURE_CONTEXT source_sha=%s viewport=%s state_tick=%d buildings=%d disciples=%d" % [
		str(OS.get_environment("TMB_MASTER_RECOVERY_SOURCE_SHA")),str(root.get_viewport().size),state.tick,state.buildings.size(),state.disciples.size()
	])
	if not await _capture("01_main_map_source_a"):
		_fail("main map capture failed")
		return
	ui.call("_zoom_at",Vector2(640,350),1.4,false)
	ui.call("_pan_camera",Vector2(-38.0,-22.0))
	if not await _capture("02_main_map_pan_zoom"):
		_fail("pan/zoom map capture failed")
		return
	ui.call("_reset_camera",false)
	if not await _open_and_capture_building(
		SectMapPresentation.DEST_MINE,_first_building(state,BuildingSystem.TYPE_MINE),"03_mine_production"):
		_fail("Mine production capture failed")
		return
	if not await _open_and_capture_building(
		SectMapPresentation.DEST_LINH_FOREST,_first_building(state,BuildingSystem.TYPE_LINH_FOREST),"04_linh_lam_production"):
		_fail("Linh Lâm production capture failed")
		return
	if not await _open_and_capture_building(
		SectMapPresentation.DEST_SPIRIT_FIELD,_first_building(state,BuildingSystem.TYPE_SPIRIT_FIELD),"05_linh_dien_production"):
		_fail("Linh Điền production capture failed")
		return
	ui.call("_open_building",SectMapPresentation.DEST_WAREHOUSE)
	if not await _capture("06_canonical_warehouse"):
		_fail("Warehouse capture failed")
		return
	var disciple := _new_real_v2(state)
	if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
		_fail("could not prepare a real V2 profile via canonical recruitment")
		return
	ui.call("_open_disciple_deep_screen",disciple.id,"Thuộc tính")
	if not await _capture("07_v2_disciple_profile_luc_duy"):
		_fail("V2 disciple profile capture failed")
		return
	if not WorkforceSystem.new().issue_command(state,disciple.id,WorkforceSystem.COMMAND_HOLD,"",1000000):
		_fail("real V2 disciple could not enter an idle state for CARE admission")
		return
	var begun := B3HuntWorld.begin(runtime.owner,disciple.id)
	if not bool(begun.get("ok",false)):
		_fail("CARE hunt could not begin: " + str(begun))
		return
	var auto_result := B3MedicalAutoplayV1.configure(runtime.owner,disciple.id,true)
	if not bool(auto_result.get("ok",false)):
		_fail("canonical CARE AUTO could not be enabled: " + str(auto_result))
		return
	ui.call("_open_b3_hunt_panel",disciple.id)
	if not await _capture("08_care_combat_v5_source_a"):
		_fail("CARE V5 combat capture failed")
		return
	ui.call("_return_from_b3_hunt")
	if not await _capture("09_main_map_after_hunt_return"):
		_fail("CARE return-to-sect capture failed")
		return
	var captured_stats := {
		"tick":state.tick,"disciple_id":str(disciple.id),"disciple_name":disciple.display_name,
		"hp":disciple.hp,"max_hp":disciple.max_hp,"injury":disciple.injury_level,
		"paid_kills":int(state.sect.b3_hunt.get("slot",{}).get("paid_generation",0)),
		"warehouse_total":WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE),
		"auto":bool(state.sect.b3_hunt.get("care",{}).get("auto_hunt",false)),
		"world_id":str(state.sect.b3_hunt.get("world_id","")),"save_path":SAVE_PATH
	}
	var report_path := output_dir.path_join("capture_state.json")
	var report_file := FileAccess.open(report_path,FileAccess.WRITE)
	if report_file == null:
		_fail("could not write capture state report")
		return
	report_file.store_string(JSON.stringify(captured_stats,"\t"))
	report_file.close()
	print("CAPTURE_STATE " + JSON.stringify(captured_stats))
	# Captures show the active saved hunt panel; the test fixture is temporary and
	# no personal save is kept in the workspace profile after exit.
	_cleanup()
	print(PASS_MARKER)
	quit(0)
