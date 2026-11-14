extends SceneTree
## VIS02 live B1 interaction/capture harness. Candidate selection and decisions
## are routed through Godot input into the actual controls; gameplay authority,
## runtime save and cold reload remain the production implementations.

const TARGET_CANDIDATE_ID := "candidate_830031"
const PROFILE_NAME := "vis02_qa_save.json"

var game: Control
var output_dir := ""
var save_path := ""
var phase := "create"
var captured := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Rasterized Godot display required; headless is not a visual capture.")
		return
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		_fail("Provide evidence output directory after --.")
		return
	output_dir = str(args[0]).simplify_path()
	phase = str(args[1]) if args.size() > 1 else "create"
	if not ["create","reload"].has(phase):
		_fail("Phase must be create or reload.")
		return
	var profile_dir := output_dir.path_join("profile")
	if DirAccess.make_dir_recursive_absolute(output_dir) != OK or DirAccess.make_dir_recursive_absolute(profile_dir) != OK:
		_fail("Cannot create VIS02 evidence/profile directory.")
		return
	save_path = profile_dir.path_join(PROFILE_NAME)
	if save_path == LiveGameRuntimeV2.DEFAULT_SAVE_PATH or save_path.contains("tong_mon_ba_dao_live_v2.json"):
		_fail("QA path resolved to the player default save; aborting before runtime startup.")
		return
	if phase == "create":
		_cleanup_qa_save()
	elif not FileAccess.file_exists(save_path):
		_fail("Cold reload requested but isolated QA save is missing.")
		return
	ProjectSettings.set_setting("runtime/live_save_path",save_path)
	DisplayServer.window_set_size(Vector2i(1280,720))
	var pack := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if pack == null:
		_fail("Missing actual P3.2 OneGame scene.")
		return
	game = pack.instantiate() as Control
	root.add_child(game)
	for _i in range(16):
		await process_frame
	if not bool(game.get("runtime_ready")):
		_fail("Actual game runtime failed startup: "+str(game.get("runtime_failure_reason")))
		return
	var state: SimulationState = game.get("state")
	if state == null:
		_fail("Actual authoritative SimulationState missing.")
		return
	if phase == "reload":
		await _verify_cold_reload(state)
		return
	await _run_recruitment_flow(state)

func _run_recruitment_flow(state: SimulationState) -> void:
	var generator := DiscipleGeneratorOpenPoints.new()
	var divine: CandidateState = null
	var found_generation := -1
	# Use the ordinary unmodified Gacha generator; no forced quality or stat edits.
	for index in range(1,1200):
		var gen_index := 830000+index
		var candidate := generator.generate_candidate(state,DiscipleGeneratorV2.SOURCE_GACHA,gen_index)
		if candidate != null and candidate.disciple_quality == DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
			divine = candidate
			found_generation = gen_index
			break
	if divine == null:
		_fail("Naturally rolled Nghịch Thiên not found within search cap.")
		return
	if str(divine.id) != TARGET_CANDIDATE_ID:
		_fail("Expected naturally generated %s, got %s at generation %d; do not change recruitment odds." % [TARGET_CANDIDATE_ID,str(divine.id),found_generation])
		return
	if state.recruitment_candidates.has(divine.id):
		_fail("Target candidate ID collides with the real initial queue.")
		return
	# Add one authentic ordinary-roll decoy so the target begins unselected and
	# the tested state necessarily takes the UI selection path.
	var decoy: CandidateState = null
	for gen_index in range(found_generation-1,maxi(830000,found_generation-80),-1):
		var possible := generator.generate_candidate(state,DiscipleGeneratorV2.SOURCE_GACHA,gen_index)
		if possible != null and possible.id != divine.id and not state.recruitment_candidates.has(possible.id):
			decoy = possible
			break
	if decoy == null:
		_fail("Could not generate a second authentic candidate for real UI selection.")
		return
	state.recruitment_candidates[decoy.id] = decoy
	state.recruitment_candidates[divine.id] = divine
	game.call("_open_dan_tien_screen_v2")
	await _frames(10)
	var screen := _find_live_adapter()
	if screen == null or screen.find_child("CandidateProfile",true,false) == null:
		_fail("Missing actual Dẫn Tiên B1 live adapter/profile.")
		return
	if screen.find_child("CandidateSearch",true,false) == null or screen.find_child("CandidateProfileScroll",true,false) == null:
		_fail("Dẫn Tiên candidate controls are not mounted.")
		return
	var initial_view := screen.get("_active_view") as Control
	var view_model: Dictionary = initial_view.get("_vm") if initial_view != null else {}
	var visible_candidate_ids: Array[String] = []
	for row in view_model.get("candidates",[]):
		visible_candidate_ids.append(str(row.get("id","")))
	print("VIS02_CANDIDATE_QUEUE ids=%s view_selected=%s host_selected=%s target_id=%s decoy_id=%s" % [
		JSON.stringify(visible_candidate_ids),str(initial_view.call("_candidate_id")) if initial_view != null else "none",
		str(screen.get("_host").get("selected_candidate_id")),TARGET_CANDIDATE_ID,str(decoy.id)])
	if not await _capture("00_dan_tien_before_selection.png"):
		return
	var host := screen.get("_host") as Control
	var active_view := screen.get("_active_view") as Control
	if host == null or active_view == null:
		_fail("Actual B1 selection host/view is unavailable.")
		return
	# First choose a non-target card through the real viewport input path. This
	# guarantees the target transition is an actual UI selection, even if queue
	# ordering initially focuses candidate_830031.
	var visible_picks := _candidate_pick_buttons(screen)
	var selected_away := false
	for button in visible_picks:
		if button.disabled:
			continue
		if not await _click_control(button):
			continue
		await _frames(4)
		screen = _find_live_adapter()
		host = screen.get("_host") as Control if screen != null else null
		active_view = screen.get("_active_view") as Control if screen != null else null
		if host != null and active_view != null and str(host.get("selected_candidate_id")) != TARGET_CANDIDATE_ID \
			and str(active_view.call("_candidate_id")) == str(host.get("selected_candidate_id")):
			selected_away = true
			break
	if not selected_away:
		_fail("Godot viewport input did not move selection to another candidate card.")
		return
	if not await _capture("01_other_candidate_selected_by_ui.png"):
		return
	# Advance through the real B1 pager. Searching by display name is ambiguous
	# because generated candidates may share names; the pager selects by the
	# canonical queue order and therefore proves the exact candidate identity.
	var pager_steps := 0
	while pager_steps < visible_candidate_ids.size()+2:
		screen = _find_live_adapter()
		host = screen.get("_host") as Control if screen != null else null
		active_view = screen.get("_active_view") as Control if screen != null else null
		if host == null or active_view == null:
			_fail("B1 candidate pager host/view disappeared during selection.")
			return
		if str(host.get("selected_candidate_id")) == TARGET_CANDIDATE_ID \
			and str(active_view.call("_candidate_id")) == TARGET_CANDIDATE_ID:
			break
		var next_candidate := screen.find_child("NextCandidate",true,false) as Button
		var previous_id := str(host.get("selected_candidate_id"))
		if next_candidate == null or next_candidate.disabled or not await _click_control(next_candidate):
			_fail("B1 pager did not accept Godot viewport input while locating %s." % TARGET_CANDIDATE_ID)
			return
		await _frames(4)
		screen = _find_live_adapter()
		host = screen.get("_host") as Control if screen != null else null
		active_view = screen.get("_active_view") as Control if screen != null else null
		var next_id := str(host.get("selected_candidate_id")) if host != null else "none"
		print("VIS02_PAGER_TRACE step=%d previous=%s next=%s view=%s" % [pager_steps+1,previous_id,next_id,
			str(active_view.call("_candidate_id")) if active_view != null else "none"])
		if next_id == previous_id:
			_fail("B1 NextCandidate click did not advance the canonical selection.")
			return
		pager_steps += 1
	screen = _find_live_adapter()
	host = screen.get("_host") as Control if screen != null else null
	active_view = screen.get("_active_view") as Control if screen != null else null
	var target_selected := host != null and active_view != null \
		and str(host.get("selected_candidate_id")) == TARGET_CANDIDATE_ID \
		and str(active_view.call("_candidate_id")) == TARGET_CANDIDATE_ID
	print("VIS02_SELECT_RESULT host_selected=%s view_selected=%s target=%s" % [
		str(host.get("selected_candidate_id")) if host != null else "none",
		str(active_view.call("_candidate_id")) if active_view != null else "none",str(target_selected)])
	if not target_selected:
		_fail("Godot viewport mouse input did not select the exact %s candidate through B1." % TARGET_CANDIDATE_ID)
		return
	if not await _capture("02_candidate_830031_selected.png"):
		return
	var accept := screen.find_child("AcceptCandidate",true,false) as Button
	if accept == null or accept.disabled or not await _click_control(accept):
		_fail("First real B1 accept action could not be clicked.")
		return
	await _frames(3)
	screen = _find_live_adapter()
	accept = screen.find_child("AcceptCandidate",true,false) as Button if screen != null else null
	if accept == null or accept.disabled or not await _click_control(accept):
		_fail("Second confirmation did not route through the actual B1 accept action.")
		return
	await _frames(3)
	var recruited_id := str(divine.id)
	if not state.disciples.has(StringName(recruited_id)) or state.recruitment_candidates.has(StringName(recruited_id)):
		_fail("Authoritative RecruitmentSystem did not consume the selected candidate exactly once.")
		return
	var joined: DiscipleState = state.disciples[StringName(recruited_id)]
	if joined.disciple_quality != DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
		_fail("Natural quality changed during UI recruitment.")
		return
	if not await _capture("02_recruit_reveal_early.png"):
		return
	await create_timer(0.25).timeout
	if not await _capture("03_recruit_reveal_middle.png"):
		return
	await create_timer(0.50).timeout
	if not await _capture("04_recruit_reveal_complete.png"):
		return
	screen = _find_live_adapter()
	var profile_button := screen.find_child("RecruitedDiscipleProfile",true,false) as Button if screen != null else null
	if profile_button == null or not await _click_control(profile_button):
		_fail("Recruited disciple profile was not opened through the B1 profile button.")
		return
	await _frames(9)
	var panel := game.find_child("DiscipleDeepScreen",true,false) as Panel
	if panel == null:
		_fail("The recruited disciple's real profile did not open.")
		return
	if panel.find_child("VIS02QualityEdge",true,false) == null or panel.find_child("VIS02SoftBacklight",true,false) == null or panel.find_child("VIS02AstralMotes",true,false) == null:
		_fail("Divine profile quality visuals are missing from the selected disciple.")
		return
	if not await _capture("05_divine_profile_full_early.png"):
		return
	await create_timer(0.65).timeout
	if not await _capture("06_divine_profile_full_late.png"):
		return
	var toggle := panel.find_child("VISReducedMotionToggle",true,false) as Button
	if toggle == null or not await _click_control(toggle):
		_fail("Reduced motion button did not accept actual viewport input.")
		return
	await _frames(3)
	panel = game.find_child("DiscipleDeepScreen",true,false) as Panel
	toggle = panel.find_child("VISReducedMotionToggle",true,false) as Button if panel != null else null
	if toggle == null or str(toggle.text).find("GIẢM") == -1:
		_fail("Reduced motion did not persist across the real profile refresh.")
		return
	if not await _capture("07_divine_profile_reduced.png"):
		return
	if not await _click_control(toggle):
		_fail("Motion toggle could not be restored through the UI.")
		return
	await _frames(3)
	panel = game.find_child("DiscipleDeepScreen",true,false) as Panel
	toggle = panel.find_child("VISReducedMotionToggle",true,false) as Button if panel != null else null
	if toggle == null or str(toggle.text).find("TẮT") == -1:
		_fail("Off motion mode did not apply to the actual profile.")
		return
	if not await _capture("08_divine_profile_off.png"):
		return
	var common_id := common_founder_id(state)
	if common_id == &"":
		_fail("No baseline disciple is available for the common-profile comparison.")
		return
	game.call("_open_disciple_deep_screen",common_id,"Tổng Quan",true)
	await _frames(5)
	if not await _capture("09_real_common_profile_baseline.png"):
		return
	var before_save_count := state.disciples.size()
	var saved: Dictionary = await game.call("_save_runtime_async_barrier")
	if not bool(saved.get("ok",false)) or not FileAccess.file_exists(save_path):
		_fail("Production SaveService barrier failed for the isolated profile: "+str(saved))
		return
	var receipt := {"candidate_id":recruited_id,"disciple_id":recruited_id,
		"quality":str(joined.disciple_quality),"disciples_before_reload":before_save_count,
		"candidate_consumed":not state.recruitment_candidates.has(StringName(recruited_id)),
		"save_path":save_path,"save_sha256":FileAccess.get_sha256(save_path),
		"source_sha":OS.get_environment("GITHUB_SHA")}
	var file := FileAccess.open(output_dir.path_join("vis02_create_receipt.json"),FileAccess.WRITE)
	if file == null:
		_fail("Cannot write VIS02 create receipt.")
		return
	file.store_string(JSON.stringify(receipt,"  "))
	file.close()
	var report := {"phase":"create","evidence_kind":"Godot_4_7_2_real_P32_scene_and_actual_B1_controls",
		"input_method":"Viewport.push_input_mouse_left_not_physical_mouse",
		"candidate_id":TARGET_CANDIDATE_ID,"candidate_generation":found_generation,
		"recruited_disciple_id":recruited_id,"screenshot_count":captured,"save_path":save_path,
		"save_sha256":FileAccess.get_sha256(save_path),"renderer":RenderingServer.get_video_adapter_name(),
		"viewport":[root.size.x,root.size.y],"physical_mouse":false}
	_write_report("vis02_create_report.json",report)
	print("VIS02_CREATE_SAVE PASS "+JSON.stringify(report))
	await _dispose_game()
	quit(0)

func _verify_cold_reload(state: SimulationState) -> void:
	var receipt_path := output_dir.path_join("vis02_create_receipt.json")
	if not FileAccess.file_exists(receipt_path):
		_fail("Create-phase receipt is missing; refusing to call this a cold reload.")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(receipt_path))
	if not (parsed is Dictionary):
		_fail("Create-phase receipt is invalid.")
		return
	var receipt: Dictionary = parsed
	var disciple_id := StringName(str(receipt.get("disciple_id","")))
	var expected_count := int(receipt.get("disciples_before_reload",-1))
	if disciple_id == &"" or not state.disciples.has(disciple_id) or state.disciples.size() != expected_count:
		_fail("Cold Reload lost or duplicated the recruited disciple; expected count %d actual %d." % [expected_count,state.disciples.size()])
		return
	if state.recruitment_candidates.has(StringName(str(receipt.get("candidate_id","")))):
		_fail("Cold Reload restored an already-consumed recruitment candidate.")
		return
	var joined: DiscipleState = state.disciples[disciple_id]
	if str(joined.disciple_quality) != str(receipt.get("quality","")):
		_fail("Cold Reload changed the recruit quality.")
		return
	# Reopen the disciple directory through the actual bottom navigation and
	# select the persisted recruit through its roster entry after the cold load.
	var bottom := game.find_child("PlayerBottomBar",true,false) as Control
	var disciples_nav: Button = null
	if bottom != null:
		for child in bottom.get_children():
			if child is Button and str((child as Button).text).strip_edges() == "Đệ Tử":
				disciples_nav = child as Button
				break
	if disciples_nav == null or not await _click_control(disciples_nav):
		_fail("Could not open the disciple roster through the real bottom navigation after cold reload.")
		return
	await _frames(5)
	var profile_opened := false
	for roster_index in range(expected_count):
		var deep := game.find_child("DiscipleDeepScreen",true,false) as Panel
		var roster_entry := deep.find_child("DeepRosterEntry_%d" % roster_index,true,false) as Button if deep != null else null
		if roster_entry == null:
			_fail("Reloaded disciple roster is missing entry %d." % roster_index)
			return
		if not await _click_control(roster_entry):
			_fail("Reloaded disciple roster entry %d did not accept viewport input." % roster_index)
			return
		await _frames(3)
		profile_opened = StringName(str(game.get("selected_id"))) == disciple_id
		print("VIS02_RELOAD_PROFILE_TRACE index=%d selected=%s target=%s" % [roster_index,str(game.get("selected_id")),str(disciple_id)])
		if profile_opened:
			break
	if not profile_opened:
		_fail("Cold-reloaded disciple was not selectable through the actual roster controls.")
		return
	if root.size != Vector2i(1280,720) or not await _capture("10_cold_reload_disciple_profile.png"):
		return
	var save_result: Dictionary = await game.call("_save_runtime_async_barrier")
	if not bool(save_result.get("ok",false)):
		_fail("Production save barrier failed after cold reload: "+str(save_result))
		return
	var report := {"phase":"cold_reload_second_process","evidence_kind":"independent_Godot_process_loaded_same_QA_profile",
		"disciple_id":str(disciple_id),"quality":str(joined.disciple_quality),
		"disciples_expected":expected_count,"disciples_actual":state.disciples.size(),
		"candidate_consumed":true,"save_path":save_path,"save_sha256":FileAccess.get_sha256(save_path),
		"screenshot_count":captured,"viewport":[root.size.x,root.size.y],"physical_mouse":false}
	_write_report("vis02_cold_reload_report.json",report)
	print("VIS02_COLD_RELOAD PASS "+JSON.stringify(report))
	await _dispose_game()
	quit(0)

func _find_live_adapter() -> Control:
	return game.find_child("TriFacilityB1LiveAdapterV1",true,false) as Control if game != null else null

func _candidate_pick_buttons(screen: Control) -> Array[Button]:
	var result: Array[Button] = []
	_collect_candidate_buttons(screen,result)
	return result

func _collect_candidate_buttons(node: Node, output: Array[Button]) -> void:
	for child in node.get_children():
		if child is Button and (child as Button).name.begins_with("CandidatePick_"):
			output.append(child as Button)
		_collect_candidate_buttons(child,output)

func _click_control(control: Control) -> bool:
	if control == null or not is_instance_valid(control) or not control.is_visible_in_tree() or not control.get_global_rect().has_area():
		return false
	var button := control as BaseButton
	if button == null or button.disabled:
		return false
	var ancestor := control.get_parent()
	while ancestor != null:
		if ancestor is ScrollContainer:
			(ancestor as ScrollContainer).ensure_control_visible(control)
			await process_frame
		ancestor = ancestor.get_parent()
	var rect := control.get_global_rect()
	var visible_rect := rect.intersection(Rect2(Vector2.ZERO,Vector2(root.size)))
	if not visible_rect.has_area():
		return false
	var position := visible_rect.get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion,true)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = position
	press.pressed = true
	root.push_input(press,true)
	await process_frame
	press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = position
	press.pressed = false
	root.push_input(press,true)
	await process_frame
	return true

func _capture(filename: String) -> bool:
	await _frames(4)
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != Vector2i(1280,720):
		return _fail("Actual Godot viewport is not 1280x720: "+filename)
	if image.save_png(output_dir.path_join(filename)) != OK:
		return _fail("Could not write Godot viewport capture: "+filename)
	captured += 1
	print("VIS02_REAL_VIEWPORT_SCREENSHOT_OK "+filename)
	return true

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _write_report(filename: String, report: Dictionary) -> void:
	var file := FileAccess.open(output_dir.path_join(filename),FileAccess.WRITE)
	if file == null:
		push_error("VIS02_REPORT_WRITE_FAILED "+filename)
		return
	file.store_string(JSON.stringify(report,"  "))
	file.close()

func _cleanup_qa_save() -> void:
	for suffix in ["",".tmp",".bak"]:
		var path: String = save_path+str(suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)

func _dispose_game() -> void:
	if game != null and is_instance_valid(game):
		game.set("runtime_ready",false)
		game.queue_free()
		await process_frame
		await process_frame

func _fail(reason: String) -> bool:
	push_error("VIS02_REAL_CAPTURE: "+reason)
	if game != null and is_instance_valid(game):
		game.set("runtime_ready",false)
		game.queue_free()
	quit(1)
	return false

func common_founder_id(state: SimulationState) -> StringName:
	for raw_id in state.disciples.keys():
		var actor: DiscipleState = state.disciples[StringName(raw_id)]
		if actor.disciple_quality != DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
			return actor.id
	return &""
