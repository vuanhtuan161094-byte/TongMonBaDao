extends SceneTree

# GUI-WORKFORCE V1: one-worker Mine/Forest/Field player flow on the actual
# 1280x720 landscape scene. Requires official Godot 4.7.2 runtime.
const SAVE_PATH := "user://gui_workforce_v1_e2e.json"
const ROUNDTRIP := "user://gui_workforce_v1_roundtrip.json"
var ui: Control
var state: SimulationState
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
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
        _fail("live game state absent")
        return
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if mine == null or forest == null or field == null:
        _fail("one of three real resource buildings absent")
        return

    ui.call("_open_building",SectMapPresentation.DEST_MINE)
    await process_frame
    var panel := ui.find_child("BuildingOperationPanel",true,false) as Panel
    if panel == null or not panel.visible or panel.position.x+panel.size.x > 1280.0:
        _fail("right-side operation panel exceeds Android landscape")
        return
    if not state.sect.economy_a_enabled:
        if not await _press("WorkforceEnableTimer"):
            return
        if not state.sect.economy_a_enabled:
            _fail("timer enable button did not use canonical EconomySystem")
            return
    var miner_id := _free_disciple()
    if miner_id == &"" or not await _choose(miner_id):
        return
    var miner: DiscipleState = state.disciples[miner_id]
    if not buildings.active_worker_ids(state,mine).has(miner_id) or miner.worksite_building_id != mine.id:
        _fail("Mine picker failed to assign canonical one-worker slot")
        return
    if not await _press("WorkforceStart"):
        return
    var ore_before := warehouse.quantity(state,&"thanh_thiet")
    var scheduler := SimulationScheduler.new(state)
    var mining_job := {}
    for _i in range(6):
        scheduler.step()
        ui.call("_refresh_all")
        mining_job = buildings.active_resource_timer_for_worker(state,miner_id)
        if not mining_job.is_empty():
            break
    if mining_job.is_empty():
        _fail("Mine start did not create real timed production")
        return
    ui.call("_open_building",SectMapPresentation.DEST_MINE)
    await process_frame
    var remove := ui.find_child("WorkforceRemove",true,false) as Button
    if remove == null or not remove.disabled:
        _fail("busy Mine worker can be removed during committed timer")
        return
    if not await _press("WorkforceChoose"):
        return
    var picker := ui.find_child("WorkforcePicker",true,false) as Panel
    if picker == null or picker.position.x+picker.size.x > 1280.0:
        _fail("picker outside 1280x720")
        return
    var other_id := _free_disciple()
    if other_id == &"":
        _fail("no free replacement candidate")
        return
    _filter_picker(other_id)
    await process_frame
    var blocked := ui.find_child("WorkforcePick_%s" % str(other_id),true,false) as Button
    if blocked == null or not blocked.disabled:
        _fail("Mine replacement accepted while timer is committed")
        return
    if not await _press("WorkforcePickerClose"):
        return
    if not buildings.active_worker_ids(state,mine).has(miner_id):
        _fail("busy replacement mutated Mine occupancy")
        return
    var job_finish := int(mining_job.get("finish_tick",state.tick))
    if job_finish <= state.tick:
        _fail("Mine finish tick invalid")
        return
    scheduler.run_ticks(job_finish-state.tick)
    if warehouse.quantity(state,&"thanh_thiet") != ore_before+int(mining_job.get("output_quantity",0)):
        _fail("Mine completion did not deposit one real batch into Warehouse")
        return
    var receipt := "wage:%s" % str(mining_job.get("job_id",""))
    if not state.sect.economy_a_receipts.has(receipt) or float(miner.profession_xp.get("mining",0.0)) <= 0.0:
        _fail("Mine completion did not provide earned wage receipt/profession XP")
        return

    ui.call("_open_building",SectMapPresentation.DEST_LINH_FOREST)
    await process_frame
    var forester_id := _free_disciple()
    if forester_id == &"" or not await _choose(forester_id):
        return
    if buildings.active_worker_ids(state,forest).size() != 1 or not buildings.active_worker_ids(state,forest).has(forester_id):
        _fail("Forest picker did not assign one worker")
        return
    var wood_job := {}
    for _i in range(8):
        scheduler.step()
        ui.call("_refresh_all")
        wood_job = buildings.active_resource_timer_for_worker(state,forester_id)
        if not wood_job.is_empty():
            break
    if wood_job.is_empty():
        _fail("Forest picker did not start real timer")
        return

    ui.call("_open_building",SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    var farmer_id := _free_disciple()
    if farmer_id == &"" or not await _choose(farmer_id):
        return
    if buildings.active_worker_ids(state,field).size() != 1 or not buildings.active_worker_ids(state,field).has(farmer_id):
        _fail("Field picker did not assign one worker")
        return
    var first := false
    for _i in range(8):
        scheduler.step()
        ui.call("_refresh_all")
        if buildings.disciple_has_active_spirit_plot(state,farmer_id,field):
            first = true
            break
    if not first:
        _fail("Field did not start genuine paid plot")
        return
    var farmer: DiscipleState = state.disciples[farmer_id]
    var stones := state.sect.spirit_stones
    var second := buildings.perform_spirit_field_step(state,farmer,1.0)
    if not bool(second.get("ok",false)) or state.sect.spirit_stones >= stones:
        _fail("same Field worker could not grow second paid plot")
        return
    if SaveService.new().save_to_path(state,ROUNDTRIP) != OK:
        _fail("physical SaveService write failed")
        return
    var restored := SaveService.new().load_from_path(ROUNDTRIP)
    if restored == null:
        _fail("physical SaveService read failed")
        return
    var restored_field := buildings.primary_building(restored,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not buildings.active_worker_ids(restored,restored_field).has(farmer_id) or not buildings.disciple_has_active_spirit_plot(restored,farmer_id,restored_field):
        _fail("saved Field operator and active plots were not recovered")
        return
    var saved_forest_job := buildings.active_resource_timer_for_worker(restored,forester_id)
    if saved_forest_job.is_empty():
        _fail("saved Forest timer was lost")
        return
    var saved_wood := warehouse.quantity(restored,&"linh_moc")
    var settle_until := int(saved_forest_job.get("finish_tick",restored.tick))
    if settle_until <= restored.tick:
        _fail("saved Forest timer has invalid finish tick")
        return
    var recovered_scheduler := SimulationScheduler.new(restored)
    recovered_scheduler.run_ticks(settle_until-restored.tick)
    if warehouse.quantity(restored,&"linh_moc") != saved_wood+int(saved_forest_job.get("output_quantity",0)):
        _fail("offline-restored Forest batch was not deposited exactly once")
        return
    if not restored.validate_invariants().is_empty():
        _fail("loaded state invariants failed")
        return
    print("GUI-WORKFORCE V1 REAL LANDSCAPE END-TO-END PASS")
    _dispose()
    quit(0)

func _free_disciple() -> StringName:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw in ids:
        var d: DiscipleState = state.disciples[raw]
        if d.work_group_id == &"" and d.worksite_building_id == &"" and d.work_cycle_state.is_empty() and d.direct_command.is_empty() and d.region_id == &"sect" and d.active_pve_encounter_id.is_empty() and d.current_action in [&"EVALUATE",&"IDLE",&"HOLD"]:
            return d.id
    # Real generator/recruitment path for a compact test roster with no idle
    # seat; never fabricate a disciple by directly adding to the state.
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = state.disciples.size()+1
    var generated := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,781300+state.disciples.size())
    if generated != null:
        state.recruitment_candidates[generated.id] = generated
        var accepted := RecruitmentSystem.new().accept_candidate(state,generated.id)
        if bool(accepted.get("ok",false)):
            return generated.id
    return &""

func _filter_picker(id: StringName) -> void:
    var input := ui.find_child("WorkforcePickerSearch",true,false) as LineEdit
    input.text = str(id)
    input.emit_signal("text_changed",str(id))

func _choose(id: StringName) -> bool:
    if not await _press("WorkforceChoose"):
        return false
    _filter_picker(id)
    await process_frame
    return await _press("WorkforcePick_%s" % str(id))

func _press(name: String) -> bool:
    var button := ui.find_child(name,true,false) as Button
    if button == null or button.disabled:
        _fail("missing enabled UI control: "+name)
        return false
    button.emit_signal("pressed")
    await process_frame
    return true

func _dispose() -> void:
    if ui != null:
        ui.queue_free()

func _cleanup() -> void:
    for p in [SAVE_PATH,ROUNDTRIP]:
        for suffix in ["",".tmp",".bak"]:
            if FileAccess.file_exists(p+suffix):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(p+suffix))

func _fail(reason: String) -> void:
    push_error("GUI-WORKFORCE V1 FAIL: "+reason)
    _dispose()
    quit(1)
