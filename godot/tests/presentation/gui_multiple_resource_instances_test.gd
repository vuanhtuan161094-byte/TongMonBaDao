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
            actor.work_group_id == &""
            and actor.worksite_building_id == &""
            and actor.direct_command.is_empty()
            and actor.work_cycle_state.is_empty()
            and actor.region_id == &"sect"
            and actor.active_pve_encounter_id.is_empty()
            and actor.current_action in [&"EVALUATE",&"IDLE",&"HOLD"]
        ):
            worker_id = actor.id
            break
    if worker_id == &"":
        _fail("no idle actor in fresh state to validate second instance")
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
    if secondary_timer.is_empty() or str(secondary_timer.get("building_id","")) != str(second.id):
        _fail("secondary operator started timer at primary building or not at all")
        return
    # A second instance survives the canonical serializer, no shadow map.
    var saved := SimulationState.from_dict(state.to_dict())
    if (
        not saved.buildings.has(str(second.id))
        or (saved.disciples[worker_id] as DiscipleState).worksite_building_id != second.id
        or buildings.active_resource_timer_for_worker(saved,worker_id).is_empty()
    ):
        _fail("roundtrip lost secondary instance, one worker, or its real timer")
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
