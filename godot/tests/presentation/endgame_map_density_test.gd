extends SceneTree

const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const SOURCE_SAVE_PATH := "res://qa/endgame_qa_save.json"
const SAVE_PATH := "user://endgame_map_density_test_save.json"
const EXPECTED_PRODUCERS := {"mine": 30, "linh_forest": 30, "spirit_field": 40}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("TMB_ENDGAME_MAP_DENSITY STAGE begin")
	var source_save := FileAccess.get_file_as_string(SOURCE_SAVE_PATH)
	if source_save.is_empty():
		_fail("canonical_endgame_source_fixture_missing")
		return
	var isolated_state: Variant = JSON.parse_string(source_save)
	if not (isolated_state is Dictionary) or not isolated_state.has("runtime_last_wall_unix"):
		_fail("canonical_endgame_source_fixture_clock_missing")
		return
	# Camera/pooling checks must start from the same endgame simulation snapshot
	# without applying hours of offline ticks first. Offline clock behavior is
	# covered by the focused runtime-clock regressions on their own.
	isolated_state["runtime_last_wall_unix"] = int(Time.get_unix_time_from_system())
	var isolated_save := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if isolated_save == null:
		_fail("isolated_map_density_save_unavailable")
		return
	isolated_save.store_string(JSON.stringify(isolated_state))
	isolated_save.close()
	print("TMB_ENDGAME_MAP_DENSITY STAGE isolated_fixture_ready offline_catchup=0")
	ProjectSettings.set_setting("runtime/live_save_path", ProjectSettings.globalize_path(SAVE_PATH))
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_fail("production_p3_2_scene_missing")
		return
	print("TMB_ENDGAME_MAP_DENSITY STAGE scene_resource_loaded")
	var scene := packed.instantiate() as Control
	print("TMB_ENDGAME_MAP_DENSITY STAGE scene_instantiated")
	root.add_child(scene)
	print("TMB_ENDGAME_MAP_DENSITY STAGE scene_added")
	await process_frame
	await process_frame
	print("TMB_ENDGAME_MAP_DENSITY STAGE ready_frames_complete")
	if not bool(scene.get("runtime_ready")) or scene.get("state") == null or scene.get("iso_world") == null:
		_fail("production_p3_2_runtime_not_ready")
		return
	var state: SimulationState = scene.get("state")
	await create_timer(0.4).timeout
	print("TMB_ENDGAME_MAP_DENSITY STAGE runtime_ready")
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
	var idle_positions: Array[Vector2] = []
	var courtyard: Vector2 = scene.call("_iso_actor_point",&"courtyard")
	var max_idle_radius := 0.0
	var min_idle_spacing := INF
	for raw_id in idle_slots.keys():
		var virtual_position: Vector2 = scene.actor_virtual_positions[str(raw_id)]
		var foot_position := virtual_position + DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
		var offset: Vector2 = foot_position - courtyard
		max_idle_radius = maxf(max_idle_radius,offset.length())
		for previous_position in idle_positions:
			var distance := foot_position.distance_to(previous_position)
			min_idle_spacing = minf(min_idle_spacing,distance)
			if distance < 0.1:
				_fail("idle_endgame_roster_contains_exact_stack", {"disciple": str(raw_id), "position": foot_position})
				return
		idle_positions.append(foot_position)
	if idle_positions.size() != 30:
		_fail("synthetic_endgame_roster_idle_count_changed", {"idle_count": idle_positions.size()})
		return
	if max_idle_radius > 9.0 * sqrt(float(idle_positions.size())) + 0.1:
		_fail("idle_endgame_roster_not_compact", {"max_radius":max_idle_radius,"expected_max":9.0*sqrt(float(idle_positions.size()))})
		return
	if min_idle_spacing <= 0.1:
		_fail("idle_endgame_roster_contains_exact_stack", {"min_spacing":min_idle_spacing})
		return
	if scene.actor_virtual_positions.size() != state.disciples.size():
		_fail("canonical_roster_missing_virtual_map_positions", {"positions": scene.actor_virtual_positions.size(), "roster": state.disciples.size()})
		return
	if scene.actor_nodes.size() > SectEndgameVisualBudgetV1.actor_cap(scene.map_zoom):
		_fail("materialized_actors_exceeded_camera_lod_cap", {"nodes": scene.actor_nodes.size(), "cap": SectEndgameVisualBudgetV1.actor_cap(scene.map_zoom)})
		return
	if scene.actor_nodes.size() > 1:
		_fail("production_map_rendered_multiple_disciples", {"nodes": scene.actor_nodes.size()})
		return
	for raw_id in scene.actor_nodes.keys():
		if str(raw_id) != str(scene.get("selected_id")):
			_fail("production_map_rendered_an_unselected_disciple", {"actor": str(raw_id), "selected": str(scene.get("selected_id"))})
			return
	if scene.actor_nodes.size() >= state.disciples.size():
		_fail("virtualization_did_not_reduce_materialized_roster", {"nodes": scene.actor_nodes.size(), "roster": state.disciples.size()})
		return
	var state_before_clearing_selection := JSON.stringify(state.to_dict(),"",true)
	scene.set("selected_id",&"")
	scene.call("_refresh_world_actor_visibility")
	if scene.actor_nodes.size() != 0:
		_fail("production_map_rendered_disciples_without_a_selection", {"nodes": scene.actor_nodes.size()})
		return
	if JSON.stringify(state.to_dict(),"",true) != state_before_clearing_selection:
		_fail("hiding_unselected_production_actors_changed_simulation_state")
		return
	for actor_value in scene.actor_nodes.values():
		var actor := actor_value as Control
		if actor.visible:
			var actor_rect := actor.get_global_rect()
			if actor_rect.position.x < SectMapCamera.VIEW_RECT.position.x or actor_rect.position.y < SectMapCamera.VIEW_RECT.position.y or actor_rect.end.x > SectMapCamera.VIEW_RECT.end.x or actor_rect.end.y > SectMapCamera.VIEW_RECT.end.y:
				_fail("live_actor_rendered_over_fixed_hud", {"disciple":str(actor.disciple_id),"instance_id":actor.get_instance_id(),"actor_position":actor.position,"virtual_position":scene.actor_virtual_positions.get(str(actor.disciple_id),Vector2.ZERO),"rect":actor_rect,"view":SectMapCamera.VIEW_RECT})
				return
	if _visible_status_labels(scene) != 0:
		_fail("overview_has_floating_status_label_overlap", {"visible": _visible_status_labels(scene)})
		return
	var hidden_id: StringName = &""
	for raw_id in state.disciples.keys():
		var candidate_id := StringName(raw_id)
		if not scene.actor_nodes.has(str(candidate_id)):
			hidden_id = candidate_id
			break
	if hidden_id == &"":
		_fail("fixture_did_not_have_a_virtualized_disciple")
		return
	_select_and_focus_virtual_disciple(scene,hidden_id)
	if scene.get("selected_id") != hidden_id or scene.get("focused_id") != hidden_id:
		_fail("virtual_disciple_could_not_be_selected", {"disciple": hidden_id})
		return
	if not scene.actor_nodes.has(str(hidden_id)):
		_fail("selected_virtual_disciple_was_not_materialized_after_camera_focus", {"disciple": hidden_id})
		return
	if scene.actor_nodes.size() != 1:
		_fail("selecting_a_disciple_did_not_keep_production_rendering_bounded_to_one", {"nodes": scene.actor_nodes.size(), "selected": str(hidden_id)})
		return
	var second_hidden_id: StringName = &""
	for raw_id in state.disciples.keys():
		var candidate_id := StringName(raw_id)
		if candidate_id != hidden_id and not scene.actor_nodes.has(str(candidate_id)):
			second_hidden_id = candidate_id
			break
	if second_hidden_id == &"":
		_fail("fixture_did_not_have_a_second_virtualized_disciple")
		return
	_select_and_focus_virtual_disciple(scene,second_hidden_id)
	if scene.actor_nodes.size() != 1 or not scene.actor_nodes.has(str(second_hidden_id)):
		_fail("selection_change_did_not_recycle_to_exactly_one_production_actor", {"nodes": scene.actor_nodes.size(), "selected": str(second_hidden_id)})
		return
	var rebound_actor := scene.actor_nodes.get(str(second_hidden_id)) as ModularDiscipleActor
	if rebound_actor == null or rebound_actor.disciple_id != second_hidden_id:
		_fail("recycled_actor_did_not_rebind_to_the_selected_disciple", {"disciple": second_hidden_id})
		return
	await create_timer(0.4).timeout
	if not rebound_actor.position.is_equal_approx(scene.actor_virtual_positions[str(second_hidden_id)]):
		_fail("recycled_actor_was_moved_by_a_stale_identity_tween", {"disciple":str(second_hidden_id),"actor_position":rebound_actor.position,"virtual_position":scene.actor_virtual_positions[str(second_hidden_id)]})
		return
	for raw_id in scene.actor_nodes.keys():
		var actor := scene.actor_nodes[raw_id] as ModularDiscipleActor
		if actor == null or actor.disciple_id != StringName(raw_id) or actor.get_parent() != scene.map_layer:
			_fail("materialized_actor_identity_or_parent_mismatch", {"key": str(raw_id)})
			return
	for actor in scene.actor_pool:
		if actor == null or actor.disciple_id != &"" or actor.get_parent() != null or actor.baked_visual_active():
			_fail("pooled_actor_retained_identity_or_source_art", {"disciple": actor.disciple_id if actor != null else "<null>"})
			return
		if scene.actor_position_tweens.has(actor.get_instance_id()):
			_fail("pooled_actor_retained_a_live_position_tween", {"instance_id":actor.get_instance_id()})
			return
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
	var final_materialized_count: int = scene.actor_nodes.size()
	var final_pool_count: int = scene.actor_pool.size()
	var pooled_actor_refs: Array[WeakRef] = []
	for actor in scene.actor_pool:
		pooled_actor_refs.append(weakref(actor))
	scene.queue_free()
	await process_frame
	for actor_ref in pooled_actor_refs:
		if actor_ref.get_ref() != null:
			_fail("scene_teardown_leaked_pooled_actor")
			return
	print("TMB_ENDGAME_MAP_DENSITY PASS " + JSON.stringify({"producer_instances": producer_rows, "unique_positions": cells.size(), "idle_roster_sprites_may_overlap_but_positions_are_unique": idle_positions.size(), "idle_max_radius":max_idle_radius,"idle_min_spacing":min_idle_spacing,"virtual_map_positions": state.disciples.size(), "materialized_actor_nodes": final_materialized_count, "actor_pool": final_pool_count, "pool_freed_on_scene_teardown": true, "selected_virtual_disciple": str(hidden_id), "recycled_to": str(second_hidden_id), "actors_clipped_to_map_view": true, "visible_status_labels_on_overview": 0, "visible_focused_disciple_labels": 1, "simulation_state_unchanged": true}))
	quit(0)

func _visible_status_labels(scene: Control) -> int:
	var labels: Dictionary = scene.get("actor_status_labels")
	var visible := 0
	for key in labels:
		var label := labels[key] as Label
		if label != null and is_instance_valid(label) and label.visible:
			visible += 1
	return visible

func _select_and_focus_virtual_disciple(scene: Control, disciple_id: StringName) -> void:
	scene.call("_open_disciple",disciple_id)
	var point: Vector2 = scene.call("_disciple_map_point",disciple_id)
	var transform: Dictionary = SectMapCamera.focus_transform(point)
	scene.call("_apply_camera",float(transform["zoom"]),Vector2(transform["position"]),false)
	scene.call("_refresh_world_actor_visibility")

func _fail(reason: String, detail: Variant = {}) -> void:
	printerr("TMB_ENDGAME_MAP_DENSITY FAIL " + JSON.stringify({"reason": reason, "detail": detail}))
	quit(1)
