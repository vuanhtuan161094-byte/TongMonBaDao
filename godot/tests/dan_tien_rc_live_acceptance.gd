extends SceneTree

# Engine-driven live acceptance for the real P3.2 scene. Run with the official
# Godot 4.7.2 desktop renderer to produce visible, 1280x720 gameplay captures.
var assertion_count := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
	assertion_count += 1
	if ok:
		return true
	push_error("DAN_TIEN_RC_FAIL: " + message)
	quit(1)
	return false

func _run() -> void:
	var evidence_dir := OS.get_environment("TMB_DANTIEN_EVIDENCE_DIR")
	var save_path := OS.get_environment("TMB_DANTIEN_SAVE_PATH")
	if not _check(not evidence_dir.is_empty() and not save_path.is_empty(), "separate QA evidence and save paths must be configured"):
		return
	DirAccess.make_dir_recursive_absolute(evidence_dir)
	DisplayServer.window_set_size(Vector2i(1280, 720))

	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if not _check(packed != null, "real P3.2 production scene loads"):
		return
	var ui := packed.instantiate() as Control
	if not _check(ui != null, "real P3.2 production scene instantiates"):
		return
	root.add_child(ui)
	for _frame in range(5):
		await process_frame

	var state := ui.get("state") as SimulationState
	if not _check(state != null, "P3.2 scene exposes its canonical SimulationState"):
		return
	var buildings := BuildingSystem.new()
	var recruitment := RecruitmentSystem.new()
	var platform := buildings.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
	if not _check(platform != null and platform.level == 1, "New Game creates the Lv1 starting Dẫn Tiên facility"):
		return
	if not _check(state.disciples.size() == 6 and state.sect.disciple_capacity == 8, "New Game roster/capacity is six of eight"):
		return
	if not _check(state.recruitment_candidates.size() == 3, "New Game starts with three candidates"):
		return

	# Pick the actual Source A building from the live isometric world, then route
	# a desktop mouse click through P3.2 input instead of calling its panel method.
	var iso_world := ui.get("iso_world") as SectIsometricWorldV1
	if not _check(iso_world != null, "P3.2 production isometric world is mounted"):
		return
	var guidance_point := _find_guidance_pick_point(iso_world)
	if not _check(guidance_point.x >= 0.0, "Dẫn Tiên building is pickable in the live map viewport"):
		return
	await _mouse_click(guidance_point)
	if not _check(StringName(ui.get("selected_building")) == SectMapPresentation.DEST_GUIDANCE, "map mouse input opens Dẫn Tiên operation panel"):
		return
	await process_frame
	if not await _capture("dan_tien_building_1280x720.png"):
		return
	var open_button := ui.find_child("OpenDanTienScreenV2", true, false) as Button
	if not _check(open_button != null and not open_button.disabled, "Dẫn Tiên recruitment entry is visible and actionable"):
		return
	await _mouse_click(open_button.get_global_rect().get_center())
	for _frame in range(3):
		await process_frame
	var screen := ui.get_node_or_null("DanTienScreenV2") as DanTienScreenV2
	if not _check(screen != null, "real D7 recruitment screen opens from the building entry"):
		return
	if not _check(str(screen.get("_count_label").text).contains("Đệ tử 6/8") and str(screen.get("_count_label").text).contains("Ứng viên 3/30"), "screen shows roster capacity and bounded candidate queue"):
		return
	var candidate_ids := _sorted_ids(state.recruitment_candidates)
	var female_candidate_id := StringName("")
	for raw_candidate_id in candidate_ids:
		var candidate: CandidateState = state.recruitment_candidates[StringName(raw_candidate_id)]
		if str(candidate.sex_id) == "female":
			female_candidate_id = candidate.id
			break
	if female_candidate_id != StringName(""):
		var female_row := screen.find_child("DanTienCandidate_%s" % str(female_candidate_id), true, false) as Button
		if not _check(female_row != null, "female candidate row is present for Source A review"):
			return
		await _mouse_click(female_row.get_global_rect().get_center())
		for _frame in range(3):
			await process_frame
		var source_candidate: CandidateState = state.recruitment_candidates[female_candidate_id]
		var source_scene := DiscipleSourceAVisualPool.scene_path_for_disciple(source_candidate.to_disciple())
		if not source_scene.is_empty():
			if not _check(_has_source_a_preview(screen), "verified Source A portrait renders for the selected candidate"):
				return
			if not await _capture("dan_tien_recruitment_1280x720.png"):
				return
			var source_rect := _find_source_a_rect(screen)
			var dialog := screen.find_child("DanTienDialog", true, false) as Control
			print("DAN_TIEN_SOURCE_A scene=%s dialog_rect=%s portrait_rect=%s" % [source_scene, str(dialog.get_global_rect()) if dialog != null else "missing", str(source_rect)])
			if not _check(dialog != null and dialog.get_global_rect().encloses(source_rect), "Source A portrait is fully clipped inside the recruitment dialog"):
				return
	if not await _capture("dan_tien_recruitment_1280x720.png"):
		return
	print("DAN_TIEN_UI_CAPTURE map_click=1 panel=1 d7=1 viewport=%s source_a_preview=%s" % [str(root.size), str(_has_source_a_preview(screen))])

	# Exercise the real selector signal and its eligibility filtering, then carry
	# the assignment through the SaveService roundtrip below.
	var eligible_guide_id := StringName("")
	for raw_id in _sorted_ids(state.disciples):
		var disciple: DiscipleState = state.disciples[StringName(raw_id)]
		if recruitment.guidance_guide_eligible(state, disciple.id):
			eligible_guide_id = disciple.id
			break
	if not _check(eligible_guide_id != StringName(""), "fresh roster exposes at least one eligible guide"):
		return
	var guide_select := screen.get("_guide_select") as OptionButton
	var main_options: Array = screen.get("_main_options")
	var guide_option_index := main_options.find(eligible_guide_id)
	if not _check(guide_select != null and guide_option_index > 0, "eligible guide is selectable in the actual Dẫn Tiên control"):
		return
	guide_select.select(guide_option_index)
	guide_select.item_selected.emit(guide_option_index)
	await process_frame
	var guide_snapshot := recruitment.guidance_state_snapshot(state)
	if not _check(str(guide_snapshot.get("main_guide_id", "")) == str(eligible_guide_id), "guide selector event assigns the eligible disciple through RecruitmentSystem"):
		return
	var ineligible_guide_id := StringName("")
	for raw_id in _sorted_ids(state.disciples):
		var disciple: DiscipleState = state.disciples[StringName(raw_id)]
		if disciple.id != eligible_guide_id:
			ineligible_guide_id = disciple.id
			break
	var ineligible_disciple: DiscipleState = state.disciples.get(ineligible_guide_id)
	if ineligible_disciple != null:
		ineligible_disciple.direct_command["test_busy"] = true
		screen.call("_refresh_guide_selectors")
		main_options = screen.get("_main_options")
		if not _check(not main_options.has(ineligible_guide_id), "busy disciple is omitted from selectable guide options"):
			return
		ineligible_disciple.direct_command.erase("test_busy")
		screen.call("_refresh_guide_selectors")

	# Accept one real selected candidate from the UI; prove immutable ID/profile.
	var accepted_id := StringName(screen.get("selected_candidate_id"))
	var accepted_before: CandidateState = state.recruitment_candidates[accepted_id]
	var birth_before := accepted_before.v2_birth_profile.duplicate(true)
	var accept_button := _find_button_with_text(screen, "NHẬN ĐỆ TỬ")
	if not _check(accept_button != null and not accept_button.disabled, "first candidate is admissible at six of eight capacity"):
		return
	await _mouse_click(accept_button.get_global_rect().get_center())
	for _frame in range(2):
		await process_frame
	var accepted: DiscipleState = state.disciples.get(accepted_id)
	if not _check(accepted != null and accepted.v2_birth_profile == birth_before, "accept preserves candidate ID and V2 birth profile"):
		return
	if not _check(state.disciples.size() == 7 and not state.recruitment_candidates.has(accepted_id), "accept changes roster once and removes candidate once"):
		return
	ui.call("_open_disciple", accepted_id)
	await process_frame
	var virtual_positions: Dictionary = ui.get("actor_virtual_positions")
	if not _check(virtual_positions.has(str(accepted_id)), "accepted canonical ID is present in the P3.2 map registry"):
		return

	# Reject a second offer only after the UI's explicit second confirmation.
	var remaining_ids := _sorted_ids(state.recruitment_candidates)
	var rejected_id := StringName(remaining_ids[0])
	screen.call("_select_candidate", rejected_id)
	await process_frame
	var reject_button := _find_button_with_text(screen, "TỪ CHỐI")
	if not _check(reject_button != null, "reject action is visible"):
		return
	await _mouse_click(reject_button.get_global_rect().get_center())
	await process_frame
	reject_button = _find_button_with_text(screen, "XÁC NHẬN TỪ CHỐI")
	if not _check(reject_button != null, "first reject click requests confirmation"):
		return
	for _frame in range(8):
		await process_frame
	reject_button = _find_button_with_text(screen, "XÁC NHẬN TỪ CHỐI")
	if not _check(reject_button != null, "confirmation remains visible until the second click"):
		return
	await _mouse_click(reject_button.get_global_rect().get_center())
	await process_frame
	var rejection_input_method := "mouse"
	if state.recruitment_candidates.has(rejected_id):
		reject_button = _find_button_with_text(screen, "XÁC NHẬN TỪ CHỐI")
		if reject_button != null:
			reject_button.grab_focus()
			await _press_key(KEY_ENTER)
			rejection_input_method = "keyboard_fallback"
			await process_frame
	if not _check(not state.recruitment_candidates.has(rejected_id), "confirmed rejection removes only the selected candidate"):
		return

	var start_day_result := recruitment.begin_guidance_day(state, true)
	if not _check(bool(start_day_result.get("ok", false)), "initial free-arrival and quality snapshot resolves before the paid order"):
		return
	screen.call("_refresh_all")
	var token_before := state.sect.disciple_recruitment_tokens
	var candidate_count_before := state.recruitment_candidates.size()
	var candidate_ids_before_order := _sorted_ids(state.recruitment_candidates)
	var order_button := screen.get("_token_button") as Button
	if not _check(order_button != null and not order_button.disabled, "paid recruitment order is enabled with queue space"):
		return
	var paid_candidate_id := StringName("")
	var order_input_method := "mouse"
	await _mouse_click(order_button.get_global_rect().get_center())
	await process_frame
	if state.sect.disciple_recruitment_tokens == token_before:
		order_button = screen.get("_token_button") as Button
		if order_button != null:
			order_button.grab_focus()
			await _press_key(KEY_ENTER)
		order_input_method = "keyboard_fallback"
		await process_frame
	if not _check(state.sect.disciple_recruitment_tokens == token_before - 1 and state.recruitment_candidates.size() == candidate_count_before + 1, "one order spends exactly one token and creates one candidate"):
		return

	var next_ids := _sorted_ids(state.recruitment_candidates)
	var paid_ids: Array[String] = []
	for raw_id in next_ids:
		if not candidate_ids_before_order.has(raw_id):
			paid_ids.append(raw_id)
	if not _check(paid_ids.size() == 1 and state.recruitment_candidates.has(StringName(paid_ids[0])), "paid order has exactly one identifiable candidate in the live queue"):
		return
	paid_candidate_id = StringName(paid_ids[0])
	var capacity_candidate_id := StringName(next_ids[0])
	if not _check(state.recruitment_candidates.has(capacity_candidate_id), "an actual queued candidate is available to fill the final lodging slot"):
		return
	screen.call("_select_candidate", capacity_candidate_id)
	await process_frame
	var final_slot_accept := _find_button_with_text(screen, "NHẬN ĐỆ TỬ")
	if not _check(final_slot_accept != null and not final_slot_accept.disabled, "the last available lodging slot still permits one admission"):
		return
	await _mouse_click(final_slot_accept.get_global_rect().get_center())
	await process_frame
	final_slot_accept = _find_button_with_text(screen, "NHẬN ĐỆ TỬ")
	if not _check(state.disciples.size() == state.sect.disciple_capacity and final_slot_accept != null and final_slot_accept.disabled, "at full lodging capacity a further admission is disabled in the real UI"):
		return

	var next_day := (int(floor(float(state.tick) / RecruitmentSystem.GUIDANCE_DAY_TICKS)) + 1) * RecruitmentSystem.GUIDANCE_DAY_TICKS
	state.tick = next_day
	var day_result := recruitment.begin_guidance_day(state, true)
	if not _check(bool(day_result.get("ok", false)), "next-day quality/arrival snapshot advances"):
		return
	var day_snapshot := recruitment.guidance_state_snapshot(state)
	if not _check(int(day_snapshot.get("snapshot_day_index", -1)) == recruitment.guidance_day_index(state), "Dẫn Tiên snapshot records the new simulation day"):
		return
	var candidate_ids_before_save := _sorted_ids(state.recruitment_candidates)
	var token_count_before_save := state.sect.disciple_recruitment_tokens
	var profile_before_save := accepted.v2_birth_profile.duplicate(true)
	var facility_id := platform.id
	var expected_path := OS.get_environment("TMB_DANTIEN_EXPECTED_PATH")
	if not _check(not expected_path.is_empty(), "cross-process reload expectation path is configured"):
		return
	var expected_file := FileAccess.open(expected_path, FileAccess.WRITE)
	if not _check(expected_file != null, "cross-process reload expectation file opens"):
		return
	expected_file.store_string(JSON.stringify({
		"accepted_id": str(accepted_id),
		"accepted_profile": profile_before_save,
		"candidate_ids": candidate_ids_before_save,
		"disciple_ids": _sorted_ids(state.disciples),
		"capacity": state.sect.disciple_capacity,
		"tokens": token_count_before_save,
		"guide_id": str(guide_snapshot.get("main_guide_id", "")),
		"platform_id": str(facility_id),
		"production_state": platform.production_state.duplicate(true)
	}, "", true))
	expected_file.close()
	if not _check(SaveService.new().save_to_path(state, save_path) == OK, "canonical SaveService saves Dẫn Tiên state"):
		return
	var loaded := SaveService.new().load_from_path(save_path)
	if not _check(loaded != null, "canonical SaveService reloads Dẫn Tiên state"):
		return
	if not _check(_sorted_ids(loaded.recruitment_candidates) == candidate_ids_before_save and loaded.sect.disciple_recruitment_tokens == token_count_before_save, "candidate queue and order count survive reload exactly"):
		return
	if not _check(loaded.disciples.has(accepted_id) and loaded.disciples[accepted_id].v2_birth_profile == profile_before_save and not loaded.recruitment_candidates.has(accepted_id), "accepted identity/profile survives reload without duplication"):
		return
	if not _check(loaded.sect.disciple_capacity == 8 and loaded.disciples.size() == 8 and loaded.buildings.has(str(facility_id)), "full capacity and Dẫn Tiên building survive reload"):
		return
	var loaded_platform: BuildingState = loaded.buildings[str(facility_id)]
	if not _check(loaded_platform.production_state == platform.production_state, "guide/quality snapshot survives reload"):
		return

	# Deterministic isolated QA stock is used only to exercise the real upgrade UI;
	# no free materials or balance changes are applied to a player profile.
	if screen != null and is_instance_valid(screen):
		screen.call("_close_screen")
	await process_frame
	ui.call("_open_building", SectMapPresentation.DEST_GUIDANCE)
	for _frame in range(2):
		await process_frame
	var level_one_cost := buildings.upgrade_cost(platform)
	_seed_cost_stock_for_test(state, buildings, level_one_cost)
	ui.call("_refresh_all")
	var building_scroll := ui.find_child("BuildingOperationScroll", true, false) as ScrollContainer
	if building_scroll != null:
		building_scroll.scroll_vertical = int(building_scroll.get_v_scroll_bar().max_value)
	for _frame in range(2):
		await process_frame
	var upgrade_button := ui.find_child("DanTienUpgradeButton", true, false) as Button
	if not _check(upgrade_button != null and not upgrade_button.disabled and upgrade_button.text.contains("Lv2"), "Lv1 to Lv2 control reads backend cost and eligibility"):
		return
	if not await _capture("dan_tien_upgrade_panel_1280x720.png"):
		return
	var resource_before := _resource_snapshot(state, buildings, level_one_cost)
	await _mouse_click(upgrade_button.get_global_rect().get_center())
	await process_frame
	if not _check(platform.is_upgrading() and platform.upgrade_target_level == 2, "live upgrade button starts BuildingSystem transaction"):
		return
	if not _check(_resource_delta_matches(state, buildings, level_one_cost, resource_before), "upgrade transaction debits the exact backend cost once"):
		return
	var repeated := buildings.start_upgrade(state, platform.id)
	if not _check(not bool(repeated.get("ok", true)) and str(repeated.get("reason", "")) == "already_upgrading" and _resource_delta_matches(state, buildings, level_one_cost, resource_before), "busy upgrade retry cannot debit a second time"):
		return
	if not _check(SaveService.new().save_to_path(state, save_path) == OK, "in-progress upgrade saves"):
		return
	var upgrading_reload := SaveService.new().load_from_path(save_path)
	if not _check(upgrading_reload != null and upgrading_reload.buildings[str(platform.id)].is_upgrading(), "in-progress upgrade restores from SaveService"):
		return
	var restored_platform: BuildingState = upgrading_reload.buildings[str(platform.id)]
	for _tick in range(int(ceil(restored_platform.upgrade_required_work - restored_platform.upgrade_progress))):
		buildings.process_tick(upgrading_reload)
	if not _check(restored_platform.level == 2 and not restored_platform.is_upgrading(), "saved upgrade completes once after remaining work"):
		return

	if not _check(_test_upgrade_threshold(9, 10, evidence_dir), "Lv9 to Lv10 transition passes from an isolated threshold fixture"):
		return
	if not _check(_test_upgrade_threshold(19, 20, evidence_dir), "Lv19 to Lv20 transition passes from an isolated threshold fixture"):
		return
	var level_twenty_state := P37Factory.create_state(2026110120)
	var level_twenty_building := BuildingSystem.new().primary_building(level_twenty_state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
	level_twenty_building.level = 20
	var blocked := BuildingSystem.new().can_start_upgrade(level_twenty_state, level_twenty_building.id)
	if not _check(not bool(blocked.get("ok", true)) and str(blocked.get("reason", "")) == "guidance_sect_gate_pending", "Lv21 is blocked pending approved Đại Điện/Tông Môn authority"):
		return

	var max_state := P37Factory.create_state(20261101100)
	var max_building := BuildingSystem.new().primary_building(max_state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
	max_building.level = max_building.max_level
	var max_check := BuildingSystem.new().can_start_upgrade(max_state, max_building.id)
	if not _check(not bool(max_check.get("ok", true)) and str(max_check.get("reason", "")) == "max_level", "Lv100 maximum rejects any further Dẫn Tiên upgrade"):
		return
	print("DAN_TIEN_RC_PASS assertions=%d map_mouse=1 recruit_accept=1 reject_confirm=1(%s) paid_order=1(%s) full_capacity=1 save_reload=1 upgrade_l1_l2=1 thresholds=9_10,19_20 gate_21=blocked max_100=blocked construction=accurately_labeled_starting_facility" % [assertion_count, rejection_input_method, order_input_method])
	quit(0)

func _find_guidance_pick_point(world: SectIsometricWorldV1) -> Vector2:
	for y in range(88, 650, 12):
		for x in range(12, 812, 12):
			var picked := world.pick_at_screen(Vector2(x, y))
			if StringName(picked.get("destination", "")) == SectMapPresentation.DEST_GUIDANCE:
				return Vector2(x, y)
	return Vector2(-1, -1)

func _mouse_click(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	Input.parse_input_event(motion)
	await process_frame
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = position
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = position
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame

func _press_key(keycode: Key) -> void:
	var down := InputEventKey.new()
	down.keycode = keycode
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var up := InputEventKey.new()
	up.keycode = keycode
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame

func _capture(file_name: String) -> bool:
	for _frame in range(2):
		await process_frame
	var image := root.get_texture().get_image()
	if not _check(image != null and image.get_size() == Vector2i(1280, 720), "Godot rendered frame is exactly 1280x720"):
		return false
	var path := OS.get_environment("TMB_DANTIEN_EVIDENCE_DIR").path_join(file_name)
	if not _check(image.save_png(path) == OK, "rendered frame saves to the configured QA evidence folder"):
		return false
	print("DAN_TIEN_SCREENSHOT path=%s sha256=%s" % [file_name, FileAccess.get_sha256(path)])
	return true

func _find_button_with_text(parent: Node, value: String) -> Button:
	if parent is Button and (parent as Button).text == value:
		return parent as Button
	for child in parent.get_children():
		var match := _find_button_with_text(child, value)
		if match != null:
			return match
	return null

func _has_source_a_preview(parent: Node) -> bool:
	if parent is TextureRect and (parent as TextureRect).texture != null:
		return true
	for child in parent.get_children():
		if _has_source_a_preview(child):
			return true
	return false

func _find_source_a_rect(parent: Node) -> Rect2:
	if parent is TextureRect and (parent as TextureRect).texture != null:
		return (parent as TextureRect).get_global_rect()
	for child in parent.get_children():
		var found := _find_source_a_rect(child)
		if found.size != Vector2.ZERO:
			return found
	return Rect2()

func _sorted_ids(value: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for raw_id in value.keys():
		ids.append(str(raw_id))
	ids.sort()
	return ids

func _seed_cost_stock_for_test(state: SimulationState, buildings: BuildingSystem, cost: Dictionary) -> void:
	for raw_id in cost.keys():
		var resource_id := StringName(str(raw_id))
		var needed := int(cost[raw_id])
		if str(resource_id) == "spirit_stones":
			state.sect.spirit_stones += needed
		else:
			var available := buildings.warehouse.available_quantity(state, resource_id)
			if available < needed:
				buildings.warehouse.add(state, resource_id, needed - available)

func _resource_snapshot(state: SimulationState, buildings: BuildingSystem, cost: Dictionary) -> Dictionary:
	var snapshot := {}
	for raw_id in cost.keys():
		var id := str(raw_id)
		snapshot[id] = state.sect.spirit_stones if id == "spirit_stones" else buildings.warehouse.available_quantity(state, StringName(id))
	return snapshot

func _resource_delta_matches(state: SimulationState, buildings: BuildingSystem, cost: Dictionary, before: Dictionary) -> bool:
	for raw_id in cost.keys():
		var id := str(raw_id)
		var after := state.sect.spirit_stones if id == "spirit_stones" else buildings.warehouse.available_quantity(state, StringName(id))
		if int(before.get(id, -1)) - after != int(cost[raw_id]):
			return false
	return true

func _test_upgrade_threshold(start_level: int, target_level: int, evidence_dir: String) -> bool:
	var state := P37Factory.create_state(2026110100 + start_level)
	var buildings := BuildingSystem.new()
	var platform := buildings.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
	platform.level = start_level
	var cost := buildings.upgrade_cost(platform)
	_seed_cost_stock_for_test(state, buildings, cost)
	var before := _resource_snapshot(state, buildings, cost)
	var started := buildings.start_upgrade(state, platform.id)
	if not bool(started.get("ok", false)) or int(started.get("target_level", 0)) != target_level:
		return false
	if not _resource_delta_matches(state, buildings, cost, before):
		return false
	var path := evidence_dir.path_join("dan_tien_upgrade_%d_%d.save" % [start_level, target_level])
	if SaveService.new().save_to_path(state, path) != OK:
		return false
	var loaded := SaveService.new().load_from_path(path)
	if loaded == null:
		return false
	var restored: BuildingState = loaded.buildings[str(platform.id)]
	for _tick in range(int(ceil(restored.upgrade_required_work))):
		buildings.process_tick(loaded)
	if restored.level != target_level or restored.is_upgrading():
		return false
	if buildings.guidance_base_daily_arrivals_for_level(start_level) != buildings.guidance_base_daily_arrivals(platform):
		return false
	if target_level == 10 and buildings.guidance_base_daily_arrivals_for_level(target_level) != 8:
		return false
	if target_level == 20 and buildings.guidance_base_daily_arrivals_for_level(target_level) != 11:
		return false
	if target_level == 20 and buildings.guidance_elder_slots_for_level(target_level) != 2:
		return false
	return true
