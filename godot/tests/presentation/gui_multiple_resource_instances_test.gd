extends SceneTree

# TEST ONLY: introduce an extra BuildingState without calling any player
# construction command. Proves UI selects the exact real instance and does not
# change original Mine when the second instance owns a different operator.
const SAVE_PATH := "user://gui_multiple_resource_instances_test.json"
var ui: Control
var state: SimulationState
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _clear_test_save()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("landscape scene absent")
        return
    ui = packed.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        _fail("real simulation missing")
        return
    var first := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if first == null:
        _fail("canonical primary mine absent")
        return
    var first_occupants := buildings.assigned_worker_ids(state,first)
    var first_snapshot := first.to_dict()

    # create_building is a test fixture factory, NOT a lawful construction.
    var second := buildings.create_building(BuildingSystem.TYPE_MINE,2)
    if second == null or state.buildings.has(str(second.id)):
        _fail("secondary test fixture ID unavailable")
        return
    state.buildings[str(second.id)] = second
    var preview := ResourceBuildingExpansionPolicyV2.preview(
        state,BuildingSystem.TYPE_MINE,10
    )
    if bool(preview.get("ok",true)) or int(preview.get("current_count",0)) != 2:
        _fail("adding fixture accidentally authorized player construction")
        return
    # G1.7: the central operations board must list both genuine instance
    # IDs and open the SECOND one without falling back to the first Mine.
    ui.call("_show_sect_hub")
    ui.call("_show_sect_production_board")
    await process_frame
    var board := ui.find_child("SectOperationsHub",true,false) as Panel
    var first_card := ui.find_child("SectProductionCard_%s" % str(first.id),true,false)
    var second_card := ui.find_child("SectProductionCard_%s" % str(second.id),true,false)
    var open_second := ui.find_child("SectProductionOpen_%s" % str(second.id),true,false) as Button
    if board == null or not board.visible or first_card == null or second_card == null or open_second == null:
        _fail("sect production board omitted one of two real Mine instances")
        return
    # G1.8: secondary Mine is unassigned, so it MUST appear in the owner's
    # actionable queue. Viewing / filtering must not write a state or migrate
    # legacy Field production merely to render the overview.
    var state_before_dashboard := state.to_dict()
    var second_attention := ui.call("_sect_production_attention",second) as Dictionary
    if not bool(second_attention.get("needs_action",false)):
        _fail("new secondary Mine was not classified as needs-worker")
        return
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if field != null:
        ui.call("_sect_production_attention",field)
        ui.call("_sect_production_status",field)
    if state.to_dict() != state_before_dashboard:
        _fail("production attention board wrote gameplay data while being viewed")
        return
    var attention_filter := ui.find_child("SectProductionAttentionOnly",true,false) as Button
    if attention_filter == null:
        _fail("no actionable-only production filter on the hub")
        return
    attention_filter.pressed.emit()
    await process_frame
    var actionable_open := ui.find_child("SectProductionOpen_%s" % str(second.id),true,false) as Button
    var actionable_label := ui.find_child("SectProductionStatus_%s" % str(second.id),true,false) as Label
    if (
        actionable_open == null or actionable_label == null
        or not actionable_label.text.contains("CẦN XỬ LÝ")
        or not actionable_label.text.contains("Chưa có đệ tử")
    ):
        _fail("actionable filter failed to show the unassigned secondary Mine")
        return
    if state.to_dict() != state_before_dashboard:
        _fail("production alert filter mutated canonical state")
        return
    attention_filter = ui.find_child("SectProductionAttentionOnly",true,false) as Button
    attention_filter.pressed.emit()
    await process_frame
    var all_label := ui.find_child("SectProductionPageInfo",true,false) as Label
    if all_label == null or not all_label.text.contains("công trình"):
        _fail("sect production board page count missing")
        return
    ui.call("_sect_production_filter_changed",BuildingSystem.TYPE_MINE)
    await process_frame
    var filtered_label := ui.find_child("SectProductionPageInfo",true,false) as Label
    if filtered_label == null or not filtered_label.text.contains("2 công trình"):
        _fail("Mine board filter omitted a real Mine instance")
        return
    open_second = ui.find_child("SectProductionOpen_%s" % str(second.id),true,false) as Button
    if open_second == null or open_second.disabled:
        _fail("filtered second Mine cannot be opened by ID")
        return
    open_second.pressed.emit()
    await process_frame
    if StringName(ui.get("selected_production_instance_id")) != second.id:
        _fail("sect board open went to primary instead of selected second Mine")
        return
    if first.to_dict() != first_snapshot:
        _fail("opening secondary Mine from board wrote primary production state")
        return

    ui.call("_open_building",SectMapPresentation.DEST_MINE)
    await process_frame
    var chooser := ui.find_child("WorkforceInstanceChooser",true,false) as OptionButton
    if chooser == null or chooser.item_count != 2 or chooser.disabled:
        _fail("instance selector did not list two authentic BuildingState IDs")
        return
    chooser.select(1)
    chooser.emit_signal("item_selected",1)
    await process_frame
    if StringName(ui.get("selected_production_instance_id")) != second.id:
        _fail("secondary Mine selection did not remember exact canonical ID")
        return
    var owner_label := ui.find_child("WorkforceOwner",true,false) as Label
    if owner_label == null or not owner_label.text.contains("Chưa có"):
        _fail("secondary Mine showed primary operator")
        return
    var worker_id: StringName = &""
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if (
            # Only authentic V2 workers can create a new Economy-A timer.
            # Legacy workers intentionally follow the old carry/haul cycle.
            DiscipleRealmProgressV2.owns_v2_progression(actor)
            and actor.hp / maxf(actor.max_hp, 1.0) >= 0.72
            and actor.work_group_id == &""
            and actor.worksite_building_id == &""
            and actor.direct_command.is_empty()
            and actor.work_cycle_state.is_empty()
            and actor.region_id == &"sect"
            and actor.active_pve_encounter_id.is_empty()
            and actor.current_action in [&"EVALUATE",&"IDLE",&"HOLD"]
            and not buildings.disciple_has_active_timed_recipe(state,actor.id)
            and not buildings.disciple_has_active_spirit_plot(state,actor.id)
            and not DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor)
        ):
            worker_id = actor.id
            break
    if worker_id == &"" and state.sect.disciple_v2_birth_enabled:
        # Real canonical recruitment, in the isolated QA save only.
        # Never fabricate V2 identity or bypass accept_candidate().
        state.sect.disciple_capacity = state.disciples.size() + 1
        var recruitment := RecruitmentSystem.new()
        var candidate: CandidateState = recruitment.generate_candidate(
            state,DiscipleGeneratorV2.SOURCE_ORDINARY
        )
        if candidate != null:
            var accepted: Dictionary = recruitment.accept_candidate(state,candidate.id)
            if bool(accepted.get("ok",false)) and state.disciples.has(candidate.id):
                var recruited: DiscipleState = state.disciples[candidate.id]
                if DiscipleRealmProgressV2.owns_v2_progression(recruited):
                    worker_id = recruited.id
    if worker_id == &"":
        _fail("no eligible authentic V2 worker to test Economy-A timer for second Mine")
        return
    var before_resources := state.sect.spirit_stones
    var result := workforce.transfer_production_worker(state,worker_id,second.id,true)
    if not bool(result.get("ok",false)):
        _fail("real backend cannot assign idle worker to second instance")
        return
    ui.call("_refresh_building_operation_content")
    await process_frame
    var assigned := buildings.assigned_worker_ids(state,second)
    if assigned.size() != 1 or assigned[0] != worker_id:
        _fail("secondary operator assignment did not persist exact site")
        return
    if (
        buildings.assigned_worker_ids(state,first) != first_occupants
        or first.to_dict() != first_snapshot
        or state.sect.spirit_stones != before_resources
    ):
        _fail("secondary assignment mutated primary Mine or secretly charged resources")
        return
    var valid := state.validate_invariants()
    if not valid.is_empty():
        _fail("two real BuildingState instances violated save invariants: "+str(valid))
        return
    # Run the existing scheduler against the explicitly assigned SECOND Mine;
    # the location must not silently revert to primary_building().
    if not state.sect.economy_a_enabled:
        var enabled := EconomySystem.new().enable_v1(state)
        if not bool(enabled.get("ok",false)):
            _fail("Economy-A timer unavailable for second Mine regression")
            return
    if not workforce.issue_command(state,worker_id,WorkforceSystem.COMMAND_WORK,"mining",40):
        _fail("secondary Mine cannot receive canonical WORK command")
        return
    var scheduler := SimulationScheduler.new(state)
    var secondary_timer: Dictionary = {}
    for _tick in range(8):
        scheduler.step()
        secondary_timer = buildings.active_resource_timer_for_worker(state,worker_id)
        if not secondary_timer.is_empty():
            break
    # Canonical timer snapshots are owned by BuildingState.production_state.
    # Their persisted Dictionary intentionally has no "building_id" field;
    # that key only exists on the immediate _start_resource_timer() result.
    # Prove the exact saved job is on the SECOND Mine, never on the first.
    var timed_job_id: String = str(secondary_timer.get("job_id",""))
    var second_owns_job := false
    for raw_job in buildings.resource_timer_jobs(second):
        if (
            raw_job is Dictionary
            and str(raw_job.get("job_id","")) == timed_job_id
            and str(raw_job.get("worker_id","")) == str(worker_id)
        ):
            second_owns_job = true
    var primary_owns_same_job := false
    for raw_job in buildings.resource_timer_jobs(first):
        if raw_job is Dictionary and str(raw_job.get("job_id","")) == timed_job_id:
            primary_owns_same_job = true
    if secondary_timer.is_empty() or timed_job_id.is_empty() or not second_owns_job or primary_owns_same_job:
        var selected: DiscipleState = state.disciples[worker_id]
        _fail("second Mine canonical job owner mismatch; second=%s primary_duplicate=%s v2=%s action=%s command=%s cycle=%s timer=%s" % [
            str(second_owns_job),str(primary_owns_same_job),
            str(DiscipleRealmProgressV2.owns_v2_progression(selected)),
            str(selected.current_action),str(selected.direct_command),
            str(selected.work_cycle_state),str(secondary_timer)
        ])
        return
    # G1 map cue binds to SECOND Mine instance and its own timer.
    # It cannot silently read first Mine or write to SimulationState.
    var before_map_cues := state.to_dict()
    var secondary_snapshot := ui.call("_map_worksite_snapshot",second) as Dictionary
    if (
        not str(secondary_snapshot.get("detail","")).contains("×%d" % int(secondary_timer.get("output_quantity",0)))
        or float(secondary_snapshot.get("progress",-1.0)) < 0.0
        or not bool(secondary_snapshot.get("active",false))
        or str(secondary_snapshot.get("worker","")) != state.disciples[worker_id].display_name
        or int(secondary_snapshot.get("received",-1)) != int(second.metrics.get("units_produced",0))
    ):
        _fail("second Mine map cue is not bound to its real persisted timer")
        return
    # A timer starts at zero elapsed minutes, but remains a real
    # active batch and must not be deprioritized as an idle worksite.
    if (
        int(secondary_timer.get("started_tick",-1)) == state.tick
        and absf(float(secondary_snapshot.get("progress",-1.0))) > 0.001
    ):
        _fail("a new Mine batch did not report genuine zero-percent progress")
        return
    ui.call("_refresh_map_worksite_cues")
    var second_cue := ui.find_child("MapWorksite_%s" % str(second.id),true,false) as SectProductionWorksiteCue
    if second_cue == null:
        _fail("map did not show its real second Mine instance")
        return
    var expected_anchor := SectIsometricWorldV1.virtual_legacy_point(BuildingSystem.TYPE_MINE,second.id)
    # The map badge remains ~202×110 screen pixels at any zoom and
    # stays in the camera viewport, with its true instance anchor cached.
    var stored_anchors := ui.get("map_worksite_anchors") as Dictionary
    var stored_offsets := ui.get("map_worksite_screen_offsets") as Dictionary
    var actual_zoom := (ui.get("map_layer") as Control).scale.x
    var expected_pos := expected_anchor + Vector2(stored_offsets.get(str(second.id),Vector2.ZERO)) / actual_zoom
    var badge_screen := SectMapCamera.world_to_screen(second_cue.position,
        (ui.get("map_layer") as Control).position,actual_zoom)
    if (
        Vector2(stored_anchors.get(str(second.id),Vector2.ZERO)).distance_to(expected_anchor) > 0.5
        or second_cue.position.distance_to(expected_pos) > 0.5
        or absf(second_cue.scale.x*actual_zoom-1.0) > 0.001
        or not SectMapCamera.VIEW_RECT.grow(-6.0).encloses(
            Rect2(badge_screen,SectProductionWorksiteCue.CARD_SIZE)
        )
    ):
        _fail("second Mine badge failed exact instance anchor, screen-size or viewport contract")
        return
    var worker_label := second_cue.find_child("WorksiteWorker",false,false) as Label
    var received_label := second_cue.find_child("WorksiteReceived",false,false) as Label
    var percent_label := second_cue.find_child("WorksitePercentage",false,false) as Label
    if (
        worker_label == null or received_label == null or percent_label == null
        or not worker_label.text.contains(state.disciples[worker_id].display_name)
        or not received_label.text.contains(str(int(second.metrics.get("units_produced",0))))
        or not percent_label.text.contains("%")
    ):
        _fail("second Mine map card omitted actual worker/settled quantity/percentage")
        return
    var actor_foot := Vector2(ui.call("_production_actor_world_foot",
        state.disciples[worker_id],SectMapPresentation.DEST_MINE,0,
        ui.call("_active_resource_work_cues")))
    if actor_foot.distance_to(expected_anchor + Vector2(12,14)) > 0.5:
        _fail("working disciple was visually assigned to the primary Mine instead of exact ID")
        return
    # Zooming does not make the production overlay scale with the terrain.
    var layer := ui.get("map_layer") as Control
    var old_scale := layer.scale
    layer.scale = Vector2.ONE * 1.5
    ui.call("_reflow_map_worksite_cues")
    if absf(second_cue.scale.x*layer.scale.x-1.0) > 0.001:
        _fail("map production card magnified with map zoom")
        return
    layer.scale = old_scale
    ui.call("_reflow_map_worksite_cues")
    if state.to_dict() != before_map_cues:
        _fail("map production progress mutated simulation state")
        return

    # The board reads the exact stored timer on the exact selected instance.
    ui.call("_show_sect_hub")
    ui.call("_show_sect_production_board")
    ui.call("_sect_production_filter_changed",BuildingSystem.TYPE_MINE)
    await process_frame
    var second_status := ui.find_child("SectProductionStatus_%s" % str(second.id),true,false) as Label
    var first_status := ui.find_child("SectProductionStatus_%s" % str(first.id),true,false) as Label
    var expected_remaining := maxi(0,int(secondary_timer.get("finish_tick",state.tick))-state.tick)
    if (
        second_status == null or first_status == null
        or not second_status.text.contains("×%d" % int(secondary_timer.get("output_quantity",0)))
        or not second_status.text.contains("còn %d phút" % expected_remaining)
        or first_status.text.contains(str(timed_job_id))
    ):
        _fail("production board did not show secondary canonical timer/status")
        return
    if not state.validate_invariants().is_empty():
        _fail("opening production dashboard mutated canonical state")
        return
    # A second instance survives the canonical serializer, no shadow map.
    var saved := SimulationState.from_dict(state.to_dict())
    var restored_second: BuildingState = saved.buildings.get(str(second.id)) as BuildingState
    var restored_owns_job := false
    for raw_job in buildings.resource_timer_jobs(restored_second):
        if (
            raw_job is Dictionary
            and str(raw_job.get("job_id","")) == timed_job_id
            and str(raw_job.get("worker_id","")) == str(worker_id)
        ):
            restored_owns_job = true
    if (
        not saved.buildings.has(str(second.id))
        or (saved.disciples[worker_id] as DiscipleState).worksite_building_id != second.id
        or buildings.active_resource_timer_for_worker(saved,worker_id).is_empty()
        or not restored_owns_job
    ):
        _fail("roundtrip lost secondary instance, worker, or its canonical persisted timer")
        return
    print("GUI MULTI-INSTANCE ID ROUTING TEST PASS (NO PLAYER CONSTRUCTION)")
    if ui != null:
        ui.queue_free()
    quit(0)

func _clear_test_save() -> void:
    for suffix in ["",".bak",".tmp"]:
        var p: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(p):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func _fail(message: String) -> void:
    push_error("GUI MULTI-INSTANCE TEST FAILED: "+message)
    if ui != null:
        ui.queue_free()
    quit(1)
