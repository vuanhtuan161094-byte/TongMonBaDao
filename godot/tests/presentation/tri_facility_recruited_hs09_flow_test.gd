extends SceneTree
## Real New Game -> paid map construction -> B1 Dẫn Tiên -> recruit -> HS-09
## assignment -> Save/Reload. UI events run in Godot; this is not physical mouse QA.
# Real source: the map/build catalogue uses VIS-11 residence_A, not retired
# Source A model 510076. Validate source identity and native composited pixels.
const VIS11_ART = preload("res://src/presentation/p3/tmb_building_art_ab_v7.gd")
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
		"recruit reveal does not expose this real disciple's six canonical stats and AS-CHAR portrait"):
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

func _verify_vis11_residence_catalog_art(art: Control) -> bool:
	if not _require(art != null and art.is_visible_in_tree()
		and str(art.get("facility_kind")) == "residence",
		"visible build catalogue does not contain the actual Residence art control"):
		return false
	var expected_art: Texture2D = VIS11_ART.texture_for(&"residence",&"A")
	var mounted_art: Texture2D = art.get("_art") as Texture2D
	if not _require(expected_art != null and mounted_art == expected_art
		and expected_art.get_width() == VIS11_ART.size_for(&"residence").x
		and expected_art.get_height() == VIS11_ART.size_for(&"residence").y,
		"build catalogue does not mount the actual VIS-11 residence_A.png texture"):
		return false
	var rect := art.get_global_rect()
	var left := maxi(0,int(floor(rect.position.x)))
	var top := maxi(0,int(floor(rect.position.y)))
	var right := mini(1280,int(ceil(rect.position.x+rect.size.x)))
	var bottom := mini(720,int(ceil(rect.position.y+rect.size.y)))
	if not _require(right-left >= 20 and bottom-top >= 20,
		"VIS-11 Residence control is clipped/offscreen in the native 1280x720 viewport"):
		return false
	# Compare the same viewport rectangle with only the art control hidden.
	# A loaded resource and a successful export are not proof that its pixels
	# actually reached the player. All other controls remain unchanged.
	await RenderingServer.frame_post_draw
	var shown := root.get_texture().get_image()
	art.hide()
	await RenderingServer.frame_post_draw
	var hidden := root.get_texture().get_image()
	art.show()
	await RenderingServer.frame_post_draw
	if not _require(shown != null and hidden != null
		and shown.get_size() == Vector2i(1280,720)
		and hidden.get_size() == Vector2i(1280,720),
		"cannot obtain paired native screenshots for Residence art pixel proof"):
		return false
	var changed_pixels := 0
	for y in range(top,bottom):
		for x in range(left,right):
			var a := shown.get_pixel(x,y)
			var b := hidden.get_pixel(x,y)
			if absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b) > 0.15:
				changed_pixels += 1
	if not _require(changed_pixels >= 35,
		"VIS-11 Residence art did not paint actual native build-catalogue pixels (delta=%d)" % changed_pixels):
		return false
	print("TRI03_VIS11_RESIDENCE_NATIVE_PIXEL_PASS texture=residence_A.png delta=%d rect=%s" % [changed_pixels,str(rect)])
	return true

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
	# VIS-11 replaced historical Source A 510076. Validate the actual A
	# texture and a real 1280x720 on/off pixel delta, not legacy metadata.
	if not await _verify_vis11_residence_catalog_art(catalog_art):
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
	# The actual P3.2 scene is ART-05 (world layout V2): the Build Catalogue
	# auto-selects a canonical MASTERPLAN lot. Player terrain clicks are
	# deliberately ignored. A free-placement assertion is a stale QA contract.
	var target := Vector2i(game.get("build_mode_site"))
	var confirm := _find_button(game,"ConfirmMapConstruction")
	if not _require(int(state.sect.world_layout_version) == 2
		and SectResidenceSiteV1.MASTERPLAN_ANNEX_SITES.has(target)
		and bool(SectResidenceSiteV1.check(state,target).get("ok",false))
		and str(game.call("_residence_site_actor_conflict_reason",target)).is_empty()
		and confirm != null and not confirm.disabled,
		"ART-05 Build Catalogue did not auto-select one safe canonical MASTERPLAN annex lot: %s" % str(target)):
		return false
	# The same real runtime forbids free-placement in the fixed districts.
	# Verify the override cannot mutate the chosen planned lot.
	var unplanned_attempt := SectResidenceSiteV1.UNSELECTED
	for candidate in SectResidenceSiteV1.available_plots(state):
		if candidate != target:
			unplanned_attempt = candidate
			break
	if not _require(unplanned_attempt != SectResidenceSiteV1.UNSELECTED,
		"no alternate legal Residence site available for fixed-plan lock regression"):
		return false
	game.call("_select_build_mode_site",unplanned_attempt)
	if not _require(Vector2i(game.get("build_mode_site")) == target and not confirm.disabled,
		"ART-05 masterplan let arbitrary terrain override the selected building lot"):
		return false
	# Put one actual loaded disciple over the SELECTED planned lot in QA
	# presentation ONLY. The real collision guard must disable paid confirmation
	# and explain why. No SimulationState/building/warehouse mutation is allowed.
	var live_nodes: Dictionary = game.get("actor_nodes")
	var positions: Dictionary = game.get("actor_virtual_positions")
	var live_keys: Array = live_nodes.keys()
	live_keys.sort()
	var fixture_key := ""
	var fixture_original_virtual := Vector2.ZERO
	var fixture_original_actor_position := Vector2.ZERO
	for raw_key in live_keys:
		var key := str(raw_key)
		var live_actor := live_nodes[raw_key] as Control
		if live_actor == null or not is_instance_valid(live_actor) \
			or not state.disciples.has(StringName(key)) or not positions.has(key):
			continue
		fixture_key = key
		fixture_original_virtual = Vector2(positions[key])
		fixture_original_actor_position = live_actor.position
		var target_foot := SectIsometricWorldV1.LEGACY_ANCHOR \
			+ SectIsometricWorldV1.project(Vector2(target)) \
			- SectIsometricWorldV1.project(Vector2(SectIsometricWorldV1.CENTER_CELL))
		var target_top_left := target_foot-DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
		positions[key] = target_top_left
		game.set("actor_virtual_positions",positions)
		live_actor.position = target_top_left
		break
	if not _require(not fixture_key.is_empty()
		and _plot_overlaps_actor_cell(target,_actor_ground_cells())
		and str(game.call("_residence_site_actor_conflict_reason",target)) == "house_plot_actor_occupied",
		"real actor could not exercise occupied MASTERPLAN Residence collision"):
		return false
	# Do not force a UI refresh in QA: real production actor polling must
	# observe occupancy and disable the live button on its own.
	await create_timer(0.65).timeout
	var blocked_label := game.get("build_mode_site_label") as Label
	var blocked_text := blocked_label.text if blocked_label != null else "<missing>"
	var unchanged := state.buildings.size() == buildings_before \
		and state.building_event_count == event_count_before \
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD)) == wood_before \
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE)) == ore_before \
		and state.sect.spirit_stones == stones_before
	if not _require(confirm.disabled and blocked_text.contains("đang đứng") and unchanged
		and Vector2i(game.get("build_mode_site")) == target,
		"occupied fixed Residence plot did not disable paid build and explain actor collision: %s" % blocked_text):
		return false
	print("TRI03_MASTERPLAN_ACTOR_COLLISION_PASS site=%s actor=%s no_charge=true disabled=true" % [
		str(target),fixture_key])
	if not await _capture_frame("02a_actor_occupied_plot_rejected.png"):
		return false
	# Restore ALL transient actor placement before any real paid transaction or
	# Save/Reload. The same planned site must become valid and enabled again.
	var restored_positions: Dictionary = game.get("actor_virtual_positions")
	restored_positions[fixture_key] = fixture_original_virtual
	game.set("actor_virtual_positions",restored_positions)
	var restored_actor := (game.get("actor_nodes") as Dictionary).get(fixture_key) as Control
	if restored_actor != null:
		restored_actor.position = fixture_original_actor_position
	# Moving away must also re-enable the existing planned-lot confirmation.
	await create_timer(0.65).timeout
	if not _require(not confirm.disabled
		and Vector2i(game.get("build_mode_site")) == target
		and str(game.call("_residence_site_actor_conflict_reason",target)).is_empty()
		and not _plot_overlaps_actor_cell(target,_actor_ground_cells()),
		"QA actor collision fixture contaminated the real planned lot"):
		return false
	print("TRI03_G1_MASTERPLAN_VIS11_PASS planned=%s ignored_manual=%s actor_collision=true" % [
		str(target),str(unplanned_attempt)])
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
	# The outer 1280x570 viewport intersects tabs, right zoom/target controls
	# and trim margins. Pick a genuinely clickable interior map surface for
	# BOTH blocked and legal sites, not a tile on the top 10px border.
	if not Rect2(Vector2(435,160),Vector2(450,420)).has_point(screen_point):
		return Vector2(-1,-1)
	# Use the real panel extent (392x558) instead of the stale 510px
	# test-only exclusion. Do not send map taps behind an interactive panel.
	if bool(map_game.call("_point_over_build_mode_panel",screen_point)):
		return Vector2(-1,-1)
	if Vector2i(map_game.call("_cell_at_map_screen",screen_point)) != site:
		return Vector2(-1,-1)
	return screen_point

func _send_map_click(screen_point: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = screen_point
	down.pressed = true
	var mapped_before := Vector2i(game.call("_cell_at_map_screen",screen_point))
	var selected_before := Vector2i(game.get("build_mode_site"))
	print("TRI03_POINTER_GUARDS active=%s kind=%s popup=%s building=%s panel_hit=%s summary=%s panning=%s dragged=%s" % [
		str(game.get("build_mode_active")),str(game.get("build_mode_kind")),
		str(game.call("_popup_is_open")),str(game.call("_building_operation_is_open")),
		str(game.call("_point_over_build_mode_panel",screen_point)),
		str(game.call("_disciple_summary_is_open")),str(game.get("mouse_panning")),
		str(game.get("mouse_pointer_dragged"))])
	game.call("_input",down)
	print("TRI03_POINTER_DOWN panning=%s dragged=%s selected=%s" % [
		str(game.get("mouse_panning")),str(game.get("mouse_pointer_dragged")),
		str(game.get("build_mode_site"))])
	var mapped_after_down := Vector2i(game.call("_cell_at_map_screen",screen_point))
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = screen_point
	up.pressed = false
	game.call("_input",up)
	var mapped_after_up := Vector2i(game.call("_cell_at_map_screen",screen_point))
	print("TRI03_POINTER_TRACE screen=%s selected_before=%s mapped_before=%s mapped_down=%s mapped_up=%s selected_after=%s up_pressed=%s up_button=%s panning_after=%s dragged_after=%s" % [
		str(screen_point),str(selected_before),str(mapped_before),str(mapped_after_down),
		str(mapped_after_up),str(game.get("build_mode_site")),str(up.pressed),
		str(up.button_index),str(game.get("mouse_panning")),str(game.get("mouse_pointer_dragged"))])

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
