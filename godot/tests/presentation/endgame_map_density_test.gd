extends SceneTree

const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const SAVE_PATH := "res://qa/endgame_qa_save.json"
const EXPECTED_PRODUCERS := {"mine": 30, "linh_forest": 30, "spirit_field": 40}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	ProjectSettings.set_setting("runtime/live_save_path", ProjectSettings.globalize_path(SAVE_PATH))
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_fail("production_p3_2_scene_missing")
		return
	var scene := packed.instantiate() as Control
	root.add_child(scene)
	await process_frame
	await process_frame
	if not bool(scene.get("runtime_ready")) or scene.get("state") == null or scene.get("iso_world") == null:
		_fail("production_p3_2_runtime_not_ready")
		return
	var state: SimulationState = scene.get("state")
	await create_timer(0.4).timeout
	var before := JSON.stringify(state.to_dict(), "", true)
	var world: SectIsometricWorldV1 = scene.get("iso_world")
	var seen_ids := {}
	var producer_rows := 0
	var cells := {}
	for raw_type in EXPECTED_PRODUCERS:
		var expected := int(EXPECTED_PRODUCERS[raw_type])
		for index in range(1, expected + 1):
			var building_id := "%s_%03d" % [raw_type, index]
			var cell := SectIsometricWorldV1.producer_cell(StringName(raw_type), index)
			if cell.x < 0 or cell.y < 0 or cell.x >= SectIsometricWorldV1.GRID.x or cell.y >= SectIsometricWorldV1.GRID.y:
				_fail("producer_site_outside_real_192_world", {"building": building_id, "cell": cell})
				return
			var cell_key := "%d,%d" % [cell.x, cell.y]
			if cells.has(cell_key):
				_fail("endgame_producer_site_cells_overlap", {"building": building_id, "cell": cell_key, "other": cells[cell_key]})
				return
			cells[cell_key] = building_id
			var target := SectIsometricWorldV1.virtual_legacy_point(StringName(raw_type), StringName(building_id))
			var transform := SectMapCamera.focus_transform(target)
			var screen := SectMapCamera.world_to_screen(target, transform["position"], float(transform["zoom"]))
			if not SectMapCamera.VIEW_RECT.has_point(screen):
				_fail("camera_cannot_focus_real_endgame_producer", {"building": building_id, "screen": screen})
				return
	for row in world.display_instances:
		if not bool(row.get("managed", false)):
			continue
		var id := str(row.get("building_id", ""))
		if id.is_empty():
			_fail("producer_display_row_missing_canonical_identity")
			return
		if seen_ids.has(id):
			_fail("duplicate_producer_display_identity", {"building": id})
			return
		seen_ids[id] = true
		producer_rows += 1
	if producer_rows != 100:
		_fail("endgame_scene_did_not_render_100_real_producer_instances", {"rows": producer_rows})
		return
	var idle_slots: Dictionary = scene.call("_idle_staging_ordinals", state.disciples.keys())
	var idle_rects: Array[Rect2] = []
	for raw_id in idle_slots.keys():
		var actor := scene.actor_nodes[str(raw_id)] as Control
		var actor_rect := actor.get_global_rect()
		for previous_rect in idle_rects:
			if actor_rect.intersects(previous_rect):
				_fail("idle_endgame_roster_sprites_overlap_after_staging", {"disciple": str(raw_id), "rect": actor_rect})
				return
		idle_rects.append(actor_rect)
	if idle_rects.size() != 30:
		_fail("synthetic_endgame_roster_idle_count_changed", {"idle_count": idle_rects.size()})
		return
	for actor_value in scene.actor_nodes.values():
		var actor := actor_value as Control
		if actor.visible:
			var actor_rect := actor.get_global_rect()
			if actor_rect.position.x < SectMapCamera.VIEW_RECT.position.x or actor_rect.position.y < SectMapCamera.VIEW_RECT.position.y or actor_rect.end.x > SectMapCamera.VIEW_RECT.end.x or actor_rect.end.y > SectMapCamera.VIEW_RECT.end.y:
				_fail("live_actor_rendered_over_fixed_hud", {"rect": actor_rect, "view": SectMapCamera.VIEW_RECT})
				return
	if _visible_status_labels(scene) != 0:
		_fail("overview_has_floating_status_label_overlap", {"visible": _visible_status_labels(scene)})
		return
	var first_id := StringName(state.disciples.keys()[0])
	var first_actor: Control = scene.actor_nodes[str(first_id)]
	scene._set_focus_target(first_actor.position + first_actor.size * 0.5, &"disciple", first_id, "focused disciple", false)
	if _visible_status_labels(scene) != 1:
		_fail("focused_disciple_status_not_readable", {"visible": _visible_status_labels(scene)})
		return
	scene._set_focus_target(Vector2.ZERO, &"building", &"mine_001", "focused mine", false)
	if _visible_status_labels(scene) != 0:
		_fail("building_selection_left_overlapping_disciple_labels", {"visible": _visible_status_labels(scene)})
		return
	var after := JSON.stringify(state.to_dict(), "", true)
	if before != after:
		_fail("map_camera_and_selection_mutated_simulation_state")
		return
	print("TMB_ENDGAME_MAP_DENSITY PASS " + JSON.stringify({"producer_instances": producer_rows, "unique_positions": cells.size(), "idle_roster_sprites_non_overlapping": idle_rects.size(), "actors_clipped_to_map_view": true, "visible_status_labels_on_overview": 0, "visible_focused_disciple_labels": 1, "simulation_state_unchanged": true}))
	quit(0)

func _visible_status_labels(scene: Control) -> int:
	var labels: Dictionary = scene.get("actor_status_labels")
	var visible := 0
	for key in labels:
		var label := labels[key] as Label
		if label != null and is_instance_valid(label) and label.visible:
			visible += 1
	return visible

func _fail(reason: String, detail: Variant = {}) -> void:
	printerr("TMB_ENDGAME_MAP_DENSITY FAIL " + JSON.stringify({"reason": reason, "detail": detail}))
	quit(1)
