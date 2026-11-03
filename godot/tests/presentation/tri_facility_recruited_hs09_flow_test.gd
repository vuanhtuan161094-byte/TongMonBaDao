extends SceneTree
## Real P3.2 map -> B1 Dẫn Tiên -> recruit -> HS-09 -> assign -> Save/Reload.
## UI buttons are activated by this harness; this is not physical mouse QA.
const SAVE_PREFIX := "user://tri03_recruited_hs09_flow_"

var game: Control
var state: SimulationState
var save_path := ""
var capture_dir := ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		capture_dir = str(args[0])
		DirAccess.make_dir_recursive_absolute(capture_dir)
	save_path = OS.get_environment("TMB_TRI03_FLOW_SAVE_PATH")
	if save_path.is_empty():
		save_path = SAVE_PREFIX + str(OS.get_process_id()) + ".json"
	if not save_path.begins_with(SAVE_PREFIX):
		_fail("test save path must stay under the unique user:// TRI-03 QA namespace")
		return
	_cleanup_save()
	ProjectSettings.set_setting("runtime/live_save_path",save_path)
	if not await _open_game():
		return
	if not await _capture_frame("00_new_game_sect_map.png"):
		return
	var runtime := game.get("runtime_session") as LiveGameRuntimeV2
	if not _require(runtime != null and runtime.save_path == save_path,
		"P3 scene did not bind SaveService to this isolated QA save path"):
		return
	if not _require(state.disciples.size() == 6 and state.sect.disciple_capacity == 8,
		"fresh P3.2 state must retain the canonical 6/8 roster"):
		return
	var starter_house := SectResidenceSystemV1.all_houses(state)[0]
	var starter_path := SectResidenceSiteV1.path_to_door(state,SectResidenceSiteV1.origin_of(starter_house),str(starter_house.id))
	var iso := game.get("iso_world") as SectIsometricWorldV1
	var starter_route_visible := not starter_path.is_empty() and iso != null
	for cell in starter_path:
		starter_route_visible = starter_route_visible and iso.preview_roads.has(cell)
	if not _require(starter_route_visible,
		"new-game residence has no validated, visibly rendered route from the sect gate"):
		return
	for plot in SectResidenceSiteV1.available_plots(state):
		if not _require(not SectResidenceSiteV1.path_to_door(state,plot).is_empty(),
			"a catalogued residence lot has no clear path to its door: %s" % str(plot)):
			return
	if not await _verify_natural_new_game_build_gate():
		return
	var token_count := state.sect.disciple_recruitment_tokens
	if not _require(token_count > 0,"new game has no real Chiêu Mộ Lệnh for player recruitment"):
		return
	var guidance_hit := _find_button(game,"BuildingHit_guidance")
	if not await _press(guidance_hit,"map Dẫn Tiên hit target"):
		return
	var open_guidance := _find_button(game,"OpenDanTienScreenV2")
	if not await _press(open_guidance,"Open Dẫn Tiên Đài"):
		return
	await process_frame
	var order := _find_button(game,"UseRecruitmentOrder")
	if not await _press(order,"Chiêu Mộ Lệnh"):
		return
	if not _require(state.sect.disciple_recruitment_tokens == token_count-1,
		"real B1 order button did not debit exactly one canonical token"):
		return
	if not await _capture_frame("03_dan_tien_candidates_after_order.png"):
		return
	var recruit_id := await _accept_visible_candidate()
	if recruit_id == &"":
		return
	var recruited: DiscipleState = state.disciples.get(recruit_id)
	if not _require(recruited != null and state.disciples.size() == 7,
		"B1 acceptance did not add exactly one real recruit"):
		return
	var candidates_after_accept := state.recruitment_candidates.size()
	var tokens_after_accept := state.sect.disciple_recruitment_tokens
	var adapter := game.get_node_or_null("DanTienScreenV2/TriFacilityB1LiveAdapterV1")
	var disciple_model: Dictionary = adapter.call("_recruited_disciple_model") if adapter != null else {}
	var expected_stats := "Tư %.0f · Cốt %.0f · Tâm %.0f · Tiềm %.0f · Tuệ %.0f · Duyên %.0f · Mị %.0f" % [
		recruited.aptitude,recruited.constitution,recruited.mind_nature,recruited.potential,
		recruited.comprehension,recruited.fortune,recruited.charisma
	]
	if not _require(disciple_model.get("stats","") == expected_stats
		and disciple_model.get("portrait") is Texture2D,
		"recruit reveal does not expose this real disciple's exact seven stats and Source A portrait"):
		return
	if not await _capture_frame("04_recruitment_success_reveal.png"):
		return
	var profile := _find_button(game,"RecruitedDiscipleProfile")
	if not await _press(profile,"XEM HỒ SƠ"):
		return
	await process_frame
	await process_frame
	# popup_layer is runtime-created and intentionally has no fixed scene path.
	var popup_layer := game.get("popup_layer") as Control
	var deep: Panel
	if popup_layer != null:
		deep = popup_layer.find_child("DiscipleDeepScreen",true,false) as Panel
	if not _require(deep != null and StringName(game.get("selected_id")) == recruit_id,
		"B1 XEM HỒ SƠ did not open the canonical HS-09 deep profile for this disciple"):
		return
	var overview_text := str(game.call("_disciple_overview_tab_text",state.disciples[recruit_id]))
	if not _require(overview_text.contains("Nhân tộc")
		and not overview_text.contains("male") and not overview_text.contains("female")
		and not overview_text.contains("human"),
		"HS-09 exposed an untranslated sex/race enum instead of player-facing labels"):
		return
	if not await _capture_frame("07_hs09_real_recruit_profile.png"):
		return
	if not _require(state.disciples.size() == 7
		and state.sect.disciple_recruitment_tokens == tokens_after_accept
		and state.recruitment_candidates.size() == candidates_after_accept,
		"opening HS-09 changed roster, recruitment tokens or candidate queue"):
		return
	var quick_assign := _find_button(deep,"DeepQuickAssignment")
	if not await _press(quick_assign,"HS-09 Phân công"):
		return
	await process_frame
	var assignment: Panel
	if popup_layer != null:
		assignment = popup_layer.find_child("DiscipleQuickAssignment",true,false) as Panel
	if not _require(assignment != null and StringName(game.get("selected_id")) == recruit_id,
		"HS-09 did not open canonical disciple assignment for the recruited disciple"):
		return
	var mine_status := assignment.find_child("QuickAssignStatus_mine_001",true,false) as Label
	if not _require(mine_status != null and mine_status.text.begins_with("MỎ KHOÁNG")
		and not mine_status.text.contains("mine_001"),
		"HS-09 assignment leaked a raw internal building ID to the player"):
		return
	if not await _capture_frame("08_hs09_assignment_real_recruit.png"):
		return
	var target_button: Button
	var target_building: BuildingState
	for building_type in [BuildingSystem.TYPE_SPIRIT_FIELD,BuildingSystem.TYPE_LINH_FOREST,BuildingSystem.TYPE_MINE]:
		var building := BuildingSystem.new().primary_building(state,building_type)
		if building == null:
			continue
		var candidate_button := _find_button(assignment,"QuickAssignTarget_%s" % str(building.id))
		if candidate_button != null and not candidate_button.disabled:
			target_button = candidate_button
			target_building = building
			break
	if not await _press(target_button,"eligible canonical worksite assignment"):
		return
	if not _require(recruited.worksite_building_id == target_building.id
		and recruited.work_group_id == target_building.worker_group_id,
		"assignment button did not update Workforce V2 group and worksite"):
		return
	var saved: Dictionary = await game.call("_save_runtime_async_barrier")
	if not _require(bool(saved.get("ok",false)),"SaveService async barrier failed: %s" % str(saved)):
		return
	if not _require(FileAccess.file_exists(save_path),
		"SaveService reported success but did not publish the isolated QA save file"):
		return
	var expected_worksite := str(recruited.worksite_building_id)
	var expected_group := str(recruited.work_group_id)
	var expected_path := save_path+".expected.json"
	var expected := {
		"disciple_id":str(recruit_id),
		"roster_count":state.disciples.size(),
		"worksite_id":expected_worksite,
		"work_group_id":expected_group,
		"candidate_count":state.recruitment_candidates.size(),
		"recruitment_tokens":state.sect.disciple_recruitment_tokens,
		"building_count":state.buildings.size(),
		"hall_level":SectHallSystemV1.hall(state).level,
		"residence_count":SectResidenceSystemV1.all_houses(state).size()
	}
	var expected_file := FileAccess.open(expected_path,FileAccess.WRITE)
	if not _require(expected_file != null,"could not write the isolated cross-process reload manifest"):
		return
	expected_file.store_string(JSON.stringify(expected,"\t"))
	expected_file.close()
	game.set("runtime_ready",false)
	root.remove_child(game)
	game.queue_free()
	game = null
	state = null
	await process_frame
	print("TRI03_RECRUIT_HS09_ASSIGN_SAVE_PREPARED recruit=%s roster=%d worksite=%s tokens=%d save=%s" % [
		str(recruit_id),expected["roster_count"],expected_worksite,tokens_after_accept,save_path
	])
	_close_game()
	quit(0)

func _verify_natural_new_game_build_gate() -> bool:
	var hall := SectHallSystemV1.hall(state)
	var houses := SectResidenceSystemV1.all_houses(state)
	if not _require(hall != null and hall.level == 1 and houses.size() == 1,
		"fresh game did not start from the canonical Hall Lv1 / one starter residence state"):
		return false
	var buildings_before := state.buildings.size()
	var event_count_before := state.building_event_count
	game.call("_enter_build_mode")
	await process_frame
	var catalog := _find_button(game,"BuildCatalogResidence")
	var catalog_art := game.find_child("BuildCatalogResidenceArt",true,false) as Control
	var open_hall := _find_button(game,"BuildModeOpenHall")
	var description := game.get("build_mode_description") as Label
	if not await _capture_frame("01_new_game_build_catalog_gate.png"):
		return false
	if not _require(catalog_art != null
		and bool(catalog_art.get("_original_source"))
		and str(catalog_art.get("_source_model_id")) == "510076",
		"player build catalog did not render the SHA-gated Source A Residence model 510076"):
		return false
	if not _require(catalog != null and catalog.disabled
		and catalog.tooltip_text.contains("Đại Điện Lv1/11")
		and catalog.tooltip_text.contains("40/500 Mộc")
		and description != null and description.text.contains("Đại Điện Lv1")
		and description.text.contains("mở ở Lv11"),
		"fresh build catalog failed to explain the real Hall Lv11 annex gate"):
		return false
	if not await _press(open_hall,"construction prerequisite route to Đại Điện"):
		return false
	await process_frame
	var adapter := game.get_node_or_null("DaiDienScreenV1/TriFacilityB1LiveAdapterV1")
	var hall_upgrade := _find_button(adapter,"UpgradeHall") if adapter != null else null
	var hall_model: Dictionary = adapter.call("_hall_model") if adapter != null else {}
	if not _require(hall_upgrade != null and int(hall_model.get("building_level",0)) == 1,
		"build-mode prerequisite did not route to the real canonical Hall upgrade screen"):
		return false
	if not await _capture_frame("02_new_game_hall_upgrade_path.png"):
		return false
	var hall_screen := game.get_node_or_null("DaiDienScreenV1")
	if hall_screen != null:
		hall_screen.queue_free()
		await process_frame
	if not _require(state.buildings.size() == buildings_before
		and state.building_event_count == event_count_before,
		"viewing the build gate/prerequisite mutated canonical buildings"):
		return false
	return true

func _accept_visible_candidate() -> StringName:
	var ids: Array = state.recruitment_candidates.keys()
	ids.sort()
	for raw_id in ids:
		var id := StringName(str(raw_id))
		var candidate: CandidateState = state.recruitment_candidates.get(id)
		if candidate == null or (state.sect.disciple_v2_birth_enabled
			and not DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile)):
			continue
		var pick := _find_button(game,"CandidatePick_%s" % str(id))
		if pick == null:
			var search := game.find_child("CandidateSearch",true,false) as LineEdit
			if search == null:
				continue
			search.text = candidate.display_name
			search.text_submitted.emit(search.text)
			await process_frame
			pick = _find_button(game,"CandidatePick_%s" % str(id))
		if pick == null:
			continue
		if not pick.disabled:
			pick.pressed.emit()
			await process_frame
		else:
			var screen := game.get_node_or_null("DanTienScreenV2")
			if screen == null or StringName(screen.get("selected_candidate_id")) != id:
				continue
		var accept := _find_button(game,"AcceptCandidate")
		if accept == null or accept.disabled:
			continue
		accept.pressed.emit()
		await process_frame
		accept = _find_button(game,"AcceptCandidate")
		if accept == null or not accept.text.contains("XÁC NHẬN"):
			_fail("B1 acceptance did not ask for its visible second confirmation")
			return &""
		accept.pressed.emit()
		await process_frame
		if state.disciples.has(id):
			return id
	_fail("no authentic visible candidate could be accepted through B1")
	return &""

func _open_game() -> bool:
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if not _require(packed != null,"cannot load P3.2 game entry scene"):
		return false
	game = packed.instantiate() as Control
	if not _require(game != null,"cannot instantiate P3.2 game entry scene"):
		return false
	root.add_child(game)
	await process_frame
	state = game.get("state") as SimulationState
	if not _require(state != null and bool(game.get("runtime_ready")),
		"P3.2 did not start its canonical live runtime"):
		return false
	_stop_timers(game)
	return true

func _press(button: Button, action: String) -> bool:
	if not _require(button != null and not button.disabled,"missing/disabled real UI control: %s" % action):
		return false
	button.pressed.emit()
	await process_frame
	return true

func _capture_frame(file_name: String) -> bool:
	if capture_dir.is_empty():
		return true
	await RenderingServer.frame_post_draw
	var frame := root.get_texture().get_image()
	if frame == null or frame.get_size() != Vector2i(1280,720):
		return _require(false,"Godot did not render a native 1280x720 frame for %s" % file_name)
	return _require(frame.save_png(capture_dir.path_join(file_name)) == OK,
		"could not save 1280x720 Godot frame: %s" % file_name)

func _find_button(node: Node, button_name: String) -> Button:
	if node == null:
		return null
	if node is Button and node.name == button_name:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child,button_name)
		if found != null:
			return found
	return null

func _stop_timers(node: Node) -> void:
	if node is Timer:
		(node as Timer).stop()
	for child in node.get_children():
		_stop_timers(child)

func _require(ok: bool,reason: String) -> bool:
	if ok:
		return true
	_fail(reason)
	return false

func _fail(reason: String) -> void:
	push_error("TRI03_RECRUIT_HS09_FAIL: "+reason)
	_close_game()
	_cleanup_save()
	quit(1)

func _close_game() -> void:
	if game != null and is_instance_valid(game):
		game.set("runtime_ready",false)
		if game.get_parent() != null:
			game.get_parent().remove_child(game)
		game.queue_free()
	game = null
	state = null

func _cleanup_save() -> void:
	var absolute := ProjectSettings.globalize_path(save_path)
	for suffix in ["",".bak",".tmp",".expected.json"]:
		if FileAccess.file_exists(absolute+suffix):
			DirAccess.remove_absolute(absolute+suffix)
	ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
