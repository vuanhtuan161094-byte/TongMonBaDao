extends SceneTree

const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const QA_SEED_SAVE := "res://qa/endgame_qa_save.json"
const CAPTURE_SUBPATH := "outputs/endgame_qa_20261025/gameplay"
const EXPECTED_COUNTS := {
	"mine": 30,
	"linh_forest": 30,
	"spirit_field": 40,
	"alchemy_hall": 1,
	"dan_tien_dai": 1,
	"ren_than_duong": 1
}
const CAPTURE_TARGETS := [
	{"type": "mine", "id": "mine_021", "file": "mine_021_selected.png"},
	{"type": "linh_forest", "id": "linh_forest_021", "file": "linh_forest_021_selected.png"},
	{"type": "spirit_field", "id": "spirit_field_035", "file": "spirit_field_035_selected.png"}
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var capture_dir := _capture_directory()
	DirAccess.make_dir_recursive_absolute(capture_dir)
	var seed_path := ProjectSettings.globalize_path(QA_SEED_SAVE)
	var capture_save_path := capture_dir.path_join("endgame_capture_save_%d.json" % int(Time.get_unix_time_from_system()))
	if not FileAccess.file_exists(seed_path):
		_fail("deterministic_endgame_seed_save_missing", {"path": seed_path})
		return
	var seed_file := FileAccess.open(seed_path, FileAccess.READ)
	var capture_save := FileAccess.open(capture_save_path, FileAccess.WRITE)
	if seed_file == null or capture_save == null:
		if seed_file != null: seed_file.close()
		if capture_save != null: capture_save.close()
		_fail("isolated_playable_capture_save_unavailable", {"path": capture_save_path})
		return
	capture_save.store_buffer(seed_file.get_buffer(seed_file.get_length()))
	capture_save.flush()
	var copy_error := capture_save.get_error()
	capture_save.close()
	seed_file.close()
	if copy_error != OK or SaveService.new().load_from_path(capture_save_path) == null:
		_fail("isolated_playable_capture_save_copy_invalid", {"path": capture_save_path, "error": copy_error})
		return
	ProjectSettings.set_setting("runtime/live_save_path", capture_save_path)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(Vector2i(1280, 720))
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_fail("production_p3_2_main_scene_missing")
		return
	var scene := packed.instantiate() as Control
	root.add_child(scene)
	await process_frame
	await process_frame
	if not bool(scene.get("runtime_ready")) or scene.get("state") == null or scene.get("iso_world") == null:
		_fail("production_p3_2_runtime_or_map_not_ready")
		return
	var initial: SimulationState = scene.get("state")
	var initial_counts := _count_buildings(initial)
	if not _counts_match(initial_counts):
		_fail("loaded_endgame_building_counts_do_not_match", initial_counts)
		return
	if initial.disciples.size() != 130:
		_fail("loaded_endgame_population_mismatch", {"population": initial.disciples.size()})
		return

	var evidence := {
		"main_scene": MAIN_SCENE,
		"isolated_save_path": capture_save_path,
		"fixture_seed": 20261025,
		"loaded_population": initial.disciples.size(),
		"building_counts": initial_counts,
		"camera_pan": false,
		"camera_zoom": false,
		"selected_building_ids": [],
		"production_panel_visible_for_each_selection": true,
		"fresh_p3_2_scene_reloaded_from_same_save": false,
		"overview_visible_actor_status_labels": _visible_actor_status_label_count(scene),
		"save_ok": false,
		"reload_exact_counts_and_warehouse": false,
		"input_method": "Input.parse_input_event through the production P3.2 scene handlers",
		"screenshots": [],
		"video_mode_available": DisplayServer.get_name() != "headless"
	}
	if not await _capture_frame("00_endgame_full_map.png", evidence):
		_fail("initial_p3_2_frame_capture_failed", evidence)
		return

	var old_position: Vector2 = scene.map_layer.position
	var old_zoom := float(scene.map_zoom)
	await _pan_with_mouse(scene, Vector2(560, 340), Vector2(44, 30))
	evidence["camera_pan"] = not scene.map_layer.position.is_equal_approx(old_position)
	await _wheel_zoom(scene, Vector2(640, 350), true)
	evidence["camera_zoom"] = not is_equal_approx(float(scene.map_zoom), old_zoom)
	await process_frame
	if not await _capture_frame("01_endgame_camera_pan_zoom.png", evidence):
		_fail("camera_frame_capture_failed", evidence)
		return

	for target: Dictionary in CAPTURE_TARGETS:
		var row := _find_building_row(scene.iso_world, str(target["id"]))
		if row.is_empty():
			evidence["production_panel_visible_for_each_selection"] = false
			_fail("canonical_building_marker_missing", {"id": target["id"]})
			return
		# The P3.2 focus input uses the legacy overlay coordinate that maps to
		# the same canonical cell in the isometric SubViewport.
		var legacy_focus: Vector2 = SectIsometricWorldV1.virtual_legacy_point(
			StringName(target["type"]), StringName(target["id"])
		)
		scene._focus_world_point(legacy_focus)
		await create_timer(0.42).timeout
		var point: Vector2 = SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5
		var pre_click_pick: Dictionary = scene.iso_world.pick_at_screen(point)
		if str(pre_click_pick.get("building_id", "")) != str(target["id"]):
			evidence["production_panel_visible_for_each_selection"] = false
			_fail("focused_camera_does_not_hit_requested_canonical_building", {
				"requested": target["id"],
				"picked": pre_click_pick,
				"camera_position": scene.iso_world.camera.position,
				"map_position": scene.map_layer.position,
				"screen_point": point
			})
			return
		var click_flow: Dictionary = await _click_with_mouse(scene, point)
		if scene.selected_production_instance_id != StringName(target["id"]):
			evidence["production_panel_visible_for_each_selection"] = false
			_fail("production_scene_click_did_not_select_requested_instance", {
				"requested": target["id"],
				"selected": str(scene.selected_production_instance_id),
				"screen_point": point,
				"click_flow": click_flow
			})
			return
		var panel_visible: bool = scene.building_operation_panel.visible
		evidence["production_panel_visible_for_each_selection"] = bool(evidence["production_panel_visible_for_each_selection"]) and panel_visible
		(evidence["selected_building_ids"] as Array).append(str(scene.selected_production_instance_id))
		if not await _capture_frame(str(target["file"]), evidence):
			_fail("selected_building_frame_capture_failed", {"id": target["id"]})
			return
		scene._close_building_operation_panel(true)
		await process_frame

	var save_result: Dictionary = scene.runtime_session.save()
	evidence["save_ok"] = bool(save_result.get("ok", false))
	if not bool(evidence["save_ok"]):
		_fail("p3_2_save_service_call_failed", save_result)
		return
	var reloaded := SaveService.new().load_from_path(capture_save_path)
	if reloaded == null:
		_fail("p3_2_save_service_load_failed", {})
		return
	var reloaded_counts := _count_buildings(reloaded)
	evidence["reload_exact_counts_and_warehouse"] = _counts_match(reloaded_counts) \
		and reloaded.disciples.size() == 130 \
		and reloaded.sect.warehouse_resources == scene.state.sect.warehouse_resources \
		and reloaded.buildings.size() == scene.state.buildings.size()
	if not bool(evidence["reload_exact_counts_and_warehouse"]):
		_fail("p3_2_save_reload_changed_gameplay_state", {
			"before": {"buildings": _count_buildings(scene.state), "population": scene.state.disciples.size(), "warehouse": scene.state.sect.warehouse_resources},
			"after": {"buildings": reloaded_counts, "population": reloaded.disciples.size(), "warehouse": reloaded.sect.warehouse_resources}
		})
		return
	evidence["reloaded_tick"] = reloaded.tick
	evidence["reloaded_warehouse"] = reloaded.sect.warehouse_resources.duplicate(true)
	evidence["active_work_cycles_after_reload"] = _active_work_cycles(reloaded)
	evidence["save_sha256"] = FileAccess.get_sha256(capture_save_path)
	evidence["invariants_after_reload"] = reloaded.validate_invariants()
	if not (evidence["invariants_after_reload"] as Array).is_empty():
		_fail("p3_2_reload_invariants_failed", evidence["invariants_after_reload"])
		return
	if int(evidence["overview_visible_actor_status_labels"]) > 0:
		_fail("endgame_overview_status_labels_obscure_map", {"visible_count": evidence["overview_visible_actor_status_labels"]})
		return

	# Re-open the real P3.2 scene from the same SaveService file so this proof
	# covers presentation/runtime rehydration, not only decoding a JSON object.
	scene.queue_free()
	await process_frame
	await process_frame
	scene = packed.instantiate() as Control
	root.add_child(scene)
	await process_frame
	await process_frame
	if not bool(scene.get("runtime_ready")) or scene.get("state") == null:
		_fail("p3_2_scene_failed_to_reopen_from_endgame_save", {})
		return
	var reopened_state: SimulationState = scene.get("state")
	evidence["fresh_p3_2_scene_reloaded_from_same_save"] = _counts_match(_count_buildings(reopened_state)) \
		and reopened_state.disciples.size() == 130 \
		and reopened_state.sect.warehouse_resources == reloaded.sect.warehouse_resources \
		and reopened_state.buildings.size() == reloaded.buildings.size()
	if not bool(evidence["fresh_p3_2_scene_reloaded_from_same_save"]):
		_fail("fresh_p3_2_scene_reload_changed_endgame_save", {
			"reopened_buildings": _count_buildings(reopened_state),
			"reopened_population": reopened_state.disciples.size(),
			"reopened_warehouse": reopened_state.sect.warehouse_resources
		})
		return
	if not await _capture_frame("05_fresh_p3_2_save_reload.png", evidence):
		_fail("fresh_p3_2_reload_frame_capture_failed", evidence)
		return

	# Keep the genuine main-scene viewport rendering for additional AVI frames.
	var fps_samples: Array[float] = []
	for _frame in range(180):
		await process_frame
		fps_samples.append(float(Engine.get_frames_per_second()))
	var fps_sum := 0.0
	var fps_min := INF
	var fps_max := 0.0
	for sample in fps_samples:
		fps_sum += sample
		fps_min = minf(fps_min,sample)
		fps_max = maxf(fps_max,sample)
	evidence["render_fps_180_frames"] = {
		"sample_count": fps_samples.size(),
		"mean": fps_sum / maxf(float(fps_samples.size()),1.0),
		"min": fps_min,
		"max": fps_max,
		"godot_static_memory_bytes": int(Performance.get_monitor(Performance.MEMORY_STATIC))
	}
	var report_path := capture_dir.path_join("endgame_gameplay_evidence.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		_fail("gameplay_report_write_failed", {"error": FileAccess.get_open_error()})
		return
	report_file.store_string(JSON.stringify(evidence, "\t", true))
	report_file.flush()
	report_file.close()
	print("TMB_ENDGAME_GAMEPLAY_EVIDENCE " + JSON.stringify(evidence))
	quit(0)

func _pan_with_mouse(scene: Control, start: Vector2, delta: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = start
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var motion := InputEventMouseMotion.new()
	motion.position = start + delta
	motion.relative = delta
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = start + delta
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame

func _wheel_zoom(_scene: Control, point: Vector2, zoom_in: bool) -> void:
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP if zoom_in else MOUSE_BUTTON_WHEEL_DOWN
	wheel.position = point
	wheel.pressed = true
	Input.parse_input_event(wheel)
	await process_frame

func _click_with_mouse(scene: Control, point: Vector2) -> Dictionary:
	var result := {
		"popup_open_before": scene._popup_is_open(),
		"panel_open_before": scene._building_operation_is_open()
	}
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = point
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	result["mouse_panning_after_press"] = bool(scene.mouse_panning)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = point
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame
	result["mouse_panning_after_release"] = bool(scene.mouse_panning)
	result["selected_after_release"] = str(scene.selected_production_instance_id)
	result["panel_open_after_release"] = scene._building_operation_is_open()
	result["popup_open_after_release"] = scene._popup_is_open()
	return result

func _find_building_row(iso: SectIsometricWorldV1, building_id: String) -> Dictionary:
	for row in iso.display_instances:
		if str(row.get("building_id", "")) == building_id and bool(row.get("managed", false)):
			return row
	return {}

func _capture_frame(file_name: String, evidence: Dictionary) -> bool:
	await process_frame
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		return false
	var path := _capture_directory().path_join(file_name)
	if image.save_png(path) != OK:
		return false
	(evidence["screenshots"] as Array).append({"file": path, "sha256": FileAccess.get_sha256(path), "size": image.get_size()})
	return true

func _visible_actor_status_label_count(scene: Control) -> int:
	var labels := scene.get("actor_status_labels") as Dictionary
	var visible := 0
	for raw_id in labels:
		var label := labels[raw_id] as Label
		if label != null and is_instance_valid(label) and label.visible:
			visible += 1
	return visible

func _capture_directory() -> String:
	var project_root := ProjectSettings.globalize_path("res://")
	var repository_root := project_root.get_base_dir()
	return repository_root.path_join(CAPTURE_SUBPATH)

func _count_buildings(state: SimulationState) -> Dictionary:
	var result := {}
	for value in state.buildings.values():
		var building := value as BuildingState
		if building == null:
			continue
		result[str(building.building_type)] = int(result.get(str(building.building_type), 0)) + 1
	return result

func _counts_match(counts: Dictionary) -> bool:
	for key in EXPECTED_COUNTS:
		if int(counts.get(key, 0)) != int(EXPECTED_COUNTS[key]):
			return false
	return counts.size() == EXPECTED_COUNTS.size()

func _active_work_cycles(state: SimulationState) -> int:
	var count := 0
	for value in state.disciples.values():
		var disciple := value as DiscipleState
		if disciple != null and not disciple.work_cycle_state.is_empty():
			count += 1
	return count

func _fail(reason: String, detail: Variant = {}) -> void:
	printerr("TMB_ENDGAME_GAMEPLAY_FAIL " + JSON.stringify({"reason": reason, "detail": detail}))
	quit(1)
