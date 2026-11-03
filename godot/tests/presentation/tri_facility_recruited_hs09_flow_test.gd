extends SceneTree
## Real New Game -> paid map construction -> B1 Dẫn Tiên -> recruit -> HS-09
## assignment -> Save/Reload. UI events run in Godot; this is not physical mouse QA.
const SAVE_PREFIX := "user://tri03_recruited_hs09_flow_"

var game: Control
var state: SimulationState
var save_path := ""
var capture_dir := ""
var g1_build_request_id := ""
var g1_house_id := ""
var g1_house_site := SectResidenceSiteV1.UNSELECTED
var g1_build_cost: Dictionary = {}
var g1_wood_after := -1
var g1_ore_after := -1
var g1_stones_after := -1

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
	var available_plots := SectResidenceSiteV1.available_plots(state)
	if not _require(not available_plots.is_empty(),
		"fresh game has no collision-free Residence plots"):
		return
	for sample_index in [0,int(available_plots.size()/2),available_plots.size()-1]:
		var plot: Vector2i = available_plots[sample_index]
		if not _require(not SectResidenceSiteV1.path_to_door(state,plot).is_empty(),
			"sampled legal Residence lot has no path to its exterior door: %s" % str(plot)):
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
	var expected_stats := "Tư %.0f · Cốt %.0f · Duyên %.0f · Tuệ %.0f · Mị %.0f · Tiềm %.0f" % [
		recruited.aptitude,recruited.constitution,recruited.fortune,recruited.comprehension,
		recruited.charisma,recruited.potential
	]
	if not _require(disciple_model.get("stats","") == expected_stats
		and disciple_model.get("portrait") is Texture2D,
		"recruit reveal does not expose this real disciple's six canonical stats and Source A portrait"):
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
		"residence_count":SectResidenceSystemV1.all_houses(state).size(),
		"g1_house_id":g1_house_id,
		"g1_site_x":g1_house_site.x,
		"g1_site_y":g1_house_site.y,
		"g1_finish_tick":int(state.buildings[g1_house_id].production_state.get("construction_finish_tick",-1)),
		"g1_duration_ticks":SectResidenceSystemV1.construction_duration_ticks(2),
		"g1_build_request_id":g1_build_request_id,
		"g1_cost":g1_build_cost,
		"g1_wood_after":g1_wood_after,
		"g1_ore_after":g1_ore_after,
		"g1_stones_after":g1_stones_after
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
	var warehouse := WarehouseSystem.new()
	var wood_before := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD))
	var ore_before := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE))
	var stones_before := state.sect.spirit_stones
	g1_build_cost = SectResidenceSystemV1.build_cost(state).duplicate(true)
	var real_gate := SectResidenceSystemV1.can_construct(state)
	if not _require(bool(real_gate.get("ok",false)),
		"canonical New Game stock cannot pay for its first optional Residence expansion: %s" % str(real_gate)):
		return false
	if not _require(wood_before >= int(g1_build_cost.get(BuildingSystem.MATERIAL_WOOD,0))
		and ore_before >= int(g1_build_cost.get(BuildingSystem.MATERIAL_ORE,0))
		and stones_before >= int(g1_build_cost.get("spirit_stones",0)),
		"real New Game Warehouse/treasury is below the displayed Residence cost"):
		return false
	game.call("_enter_build_mode")
	await process_frame
	var catalog := _find_button(game,"BuildCatalogResidence")
	var catalog_art := game.find_child("BuildCatalogResidenceArt",true,false) as Control
	var description := game.get("build_mode_description") as Label
	if not await _capture_frame("01_new_game_build_catalog_ready.png"):
		return false
	if not _require(catalog_art != null
		and bool(catalog_art.get("_original_source"))
		and str(catalog_art.get("_source_model_id")) == "510076",
		"player build catalog did not render the SHA-gated Source A Residence model 510076"):
		return false
	if not _require(catalog != null and not catalog.disabled
		and catalog.tooltip_text.contains("Đủ điều kiện")
		and catalog.tooltip_text.contains("40/40 Mộc")
		and catalog.tooltip_text.contains("40/30 Thiết")
		and catalog.tooltip_text.contains("500/500 Linh Thạch")
		and description != null and description.text.contains("Đại Điện Lv1")
		and description.text.contains("mở ở Lv1"),
		"New Game build catalog does not explain current access/cost: tooltip=%s description=%s" % [
			catalog.tooltip_text if catalog != null else "<missing>",
			description.text if description != null else "<missing>"]):
		return false
	if not await _press(catalog,"choose paid Residence from the real build catalog"):
		return false
	await process_frame
	if not _require(str(game.get("build_mode_kind")) == "construct",
		"Residence catalog did not enter the canonical map placement mode"):
		return false
	var iso := game.get("iso_world") as SectIsometricWorldV1
	var camera := iso.get("camera") as Camera2D if iso != null else null
	if not _require(iso != null and camera != null,
		"P3.2 map camera is unavailable during real construction"):
		return false
	var actor_cells := _actor_ground_cells()
	var actor_plot := SectResidenceSiteV1.UNSELECTED
	var actor_plot_point := Vector2.ZERO
	for candidate in SectResidenceSiteV1.available_plots(state):
		if not _plot_overlaps_actor_cell(candidate,actor_cells):
			continue
		var candidate_point := _visible_residence_plot_screen_point(candidate,camera,game)
		if candidate_point.x < 0.0:
			continue
		actor_plot = candidate
		actor_plot_point = candidate_point
		break
	if not _require(actor_plot != SectResidenceSiteV1.UNSELECTED,
		"fresh map has no visible legal plot occupied by a real disciple actor for collision QA"):
		return false
	_send_map_click(actor_plot_point)
	await process_frame
	var blocked_confirm := _find_button(game,"ConfirmMapConstruction")
	var blocked_label := game.get("build_mode_site_label") as Label
	if not _require(Vector2i(game.get("build_mode_site")) == actor_plot
		and blocked_confirm != null and blocked_confirm.disabled
		and blocked_label != null and blocked_label.text.contains("đang đứng")
		and state.buildings.size() == buildings_before
		and state.building_event_count == event_count_before
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD)) == wood_before
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE)) == ore_before
		and state.sect.spirit_stones == stones_before,
		"live disciple collision did not block placement without charging or mutating state"):
		return false
	if not await _capture_frame("02a_actor_occupied_plot_rejected.png"):
		return false
	var target := SectResidenceSiteV1.UNSELECTED
	var screen_point := Vector2.ZERO
	for candidate in SectResidenceSiteV1.available_plots(state):
		if _plot_overlaps_actor_cell(candidate,actor_cells):
			continue
		var candidate_screen := _visible_residence_plot_screen_point(candidate,camera,game)
		if candidate_screen.x < 0.0:
			continue
		target = candidate
		screen_point = candidate_screen
		break
	if not _require(target != SectResidenceSiteV1.UNSELECTED,
		"could not find a legal, visible New Game plot for the actual P3.2 input path"):
		return false
	_send_map_click(screen_point)
	await process_frame
	if not _require(Vector2i(game.get("build_mode_site")) == target,
		"map pointer event did not choose the visible legal plot"):
		return false
	var confirm := _find_button(game,"ConfirmMapConstruction")
	if not _require(confirm != null and not confirm.disabled,
		"a real valid New Game plot did not enable the paid construction button"):
		return false
	if not await _capture_frame("02_new_game_residence_valid_placement.png"):
		return false
	g1_build_request_id = "map-house:%d:%d:%d:new" % [state.tick,target.x,target.y]
	if not await _press(confirm,"confirm canonical paid Residence construction"):
		return false
	await process_frame
	var built: BuildingState = state.buildings.get("residence_002")
	var cost := g1_build_cost
	var wood_after := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD))
	var ore_after := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE))
	var stones_after := state.sect.spirit_stones
	var receipts: Dictionary = state.sect.hall_governance.get("residence_build_receipts",{})
	var duration := SectResidenceSystemV1.construction_duration_ticks(2)
	var operation_text := str(game.call("_residence_operation_text"))
	if not _require(built != null and built.status == BuildingSystem.STATUS_CONSTRUCTING
		and SectResidenceSiteV1.origin_of(built) == target
		and int(built.production_state.get("construction_finish_tick",-1)) == state.tick+duration
		and SectResidenceSystemV1.construction_remaining_ticks(state,built) == duration
		and operation_text.contains("Đang thi công")
		and operation_text.contains("còn %d nhịp" % duration),
		"real UI build did not create the selected paid House with its canonical timer/site"):
		return false
	if not _require(state.buildings.size() == buildings_before+1
		and state.building_event_count == event_count_before+1
		and receipts.get(g1_build_request_id,"") == "residence_002"
		and wood_after == wood_before-int(cost[BuildingSystem.MATERIAL_WOOD])
		and ore_after == ore_before-int(cost[BuildingSystem.MATERIAL_ORE])
		and stones_after == stones_before-int(cost["spirit_stones"]),
		"canonical construction did not debit exact resources once and write one durable receipt"):
		return false
	g1_house_id = str(built.id)
	g1_house_site = target
	g1_wood_after = wood_after
	g1_ore_after = ore_after
	g1_stones_after = stones_after
	var replay := SectResidenceSystemV1.construct(state,g1_build_request_id,target)
	if not _require(bool(replay.get("already_settled",false))
		and state.buildings.size() == buildings_before+1
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD)) == wood_after
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE)) == ore_after
		and state.sect.spirit_stones == stones_after,
		"replaying the real map construction duplicated the House or charged again"):
		return false
	if not await _capture_frame("03_new_game_paid_residence_constructing.png"):
		return false
	var close_building := _find_button(game,"CloseBuildingOperation")
	if close_building != null and not close_building.disabled:
		if not await _press(close_building,"close the new House operation panel"):
			return false
	if not _require(state.buildings.size() == buildings_before+1
		and SectResidenceSystemV1.all_houses(state).size() == 2
		and SectHallSystemV1.validate(state).is_empty(),
		"closing the UI changed the paid Residence or canonical Hall/bed invariants"):
		return false
	print("TRI03_G1_NEW_GAME_BUILD_PASS house=%s site=%d,%d cost=%s actor_blocked=1 exactly_once=1 timer=%d route=1" % [
			 g1_house_id,g1_house_site.x,g1_house_site.y,str(g1_build_cost),SectResidenceSystemV1.construction_duration_ticks(2)])
	return true

func _actor_ground_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var positions: Dictionary = game.get("actor_virtual_positions")
	for raw_id in positions.keys():
		if not state.disciples.has(StringName(str(raw_id))):
			continue
		var top_left: Vector2 = positions[raw_id]
		var foot := top_left+DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
		var map_point := foot-SectIsometricWorldV1.LEGACY_ANCHOR \
			+ SectIsometricWorldV1.project(Vector2(SectIsometricWorldV1.CENTER_CELL))
		var fractional := SectIsometricWorldV1.inverse(map_point)
		result.append(Vector2i(roundi(fractional.x),roundi(fractional.y)))
	return result

func _plot_overlaps_actor_cell(site: Vector2i, actor_cells: Array[Vector2i]) -> bool:
	var footprint := Rect2i(site,SectResidenceSiteV1.HOUSE_FOOTPRINT)
	var door := SectResidenceSiteV1.doorway(site)
	for cell in actor_cells:
		if footprint.has_point(cell) or door == cell:
			return true
	return false

func _visible_residence_plot_screen_point(site: Vector2i, camera: Camera2D,
		map_game: Control) -> Vector2:
	var world_point := SectIsometricWorldV1.project(Vector2(site))
	var local_view := SectIsometricWorldV1.VIEW_SIZE*0.5 + (world_point-camera.position)*camera.zoom.x
	var screen_point := local_view+SectIsometricWorldV1.MAP_SCREEN_OFFSET
	if not SectMapCamera.is_map_screen_point(screen_point):
		return Vector2(-1,-1)
	if Rect2(Vector2(18,144),Vector2(392,510)).has_point(screen_point):
		return Vector2(-1,-1)
	if Vector2i(map_game.call("_cell_at_map_screen",screen_point)) != site:
		return Vector2(-1,-1)
	return screen_point

func _send_map_click(screen_point: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = screen_point
	down.pressed = true
	game.call("_input",down)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = screen_point
	up.pressed = false
	game.call("_input",up)

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
