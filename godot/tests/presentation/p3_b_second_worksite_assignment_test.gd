extends SceneTree

# Gate B: actual player selection of paid Mine/Forest annexes and persisted
# workforce slot routing. Uses only New Game funds and the canonical producers.
const SAVE_PATH := "user://p3_b_second_worksite_assignment_test.json"

var ui: Control
var state: SimulationState
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("Live P3.2 scene missing.")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not bool(ui.get("runtime_ready")):
        _fail("Fresh canonical runtime missing.")
        return
    _stop_timers(ui)
    if not state.sect.economy_a_enabled:
        _fail("New Game production Economy-A not enabled.")
        return

    var first_mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var first_forest := buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    if first_mine == null or first_forest == null:
        _fail("Original producer buildings missing.")
        return
    var mine_workers := buildings.active_worker_ids(state, first_mine)
    if mine_workers.is_empty():
        _fail("Starter Mine has no real workforce.")
        return
    var miner_id: StringName = mine_workers[0]
    var funds_before := state.sect.spirit_stones
    var wood_before := warehouse.quantity(state, &"linh_moc")
    var ore_before := warehouse.quantity(state, &"thanh_thiet")

    var mine_preview := buildings.preview_production_annex(state, BuildingSystem.TYPE_MINE)
    if not bool(mine_preview.get("ok",false)):
        _fail("Cannot afford genuine second Mine: " + str(mine_preview))
        return
    var mine_cost: Dictionary = mine_preview["cost"]
    var mine_built := buildings.build_paid_production_annex(state, BuildingSystem.TYPE_MINE, "qa:b:mine:2")
    if not bool(mine_built.get("ok",false)):
        _fail("Real Mine annex purchase rejected: " + str(mine_built))
        return
    var mine_id := StringName(mine_built.get("building_id",""))
    var mine_two: BuildingState = state.buildings.get(str(mine_id)) as BuildingState
    if mine_two == null or mine_two.id == first_mine.id or (
        state.sect.spirit_stones != funds_before - int(mine_cost.get("spirit_stones",0))
        or warehouse.quantity(state,&"linh_moc") != wood_before - int(mine_cost.get("linh_moc",0))
        or warehouse.quantity(state,&"thanh_thiet") != ore_before - int(mine_cost.get("thanh_thiet",0))
    ):
        _fail("Paid Mine annex did not debit exact authoritative cost.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_MINE, mine_id)
    await process_frame
    if StringName(ui.get("selected_production_instance_id")) != mine_id:
        _fail("Player Mine panel did not select the paid instance.")
        return
    var mine_picker := ui.find_child("MineWorksite_%s" % str(miner_id),true,false) as Button
    var mine_upgrade := ui.find_child("Upgrade_mine",true,false) as Button
    if mine_picker == null or mine_picker.disabled or mine_upgrade == null:
        _fail("Mine annex has no live worker/upgrade controls.")
        return
    mine_picker.pressed.emit()
    await process_frame
    await process_frame
    if (state.disciples[miner_id] as DiscipleState).worksite_building_id != mine_id or (
        not buildings.active_worker_ids(state,mine_two).has(miner_id)
        or buildings.active_worker_ids(state,first_mine).has(miner_id)
    ):
        _fail("Mine site selection did not move the actual worker slot.")
        return
    var mining := ui.find_child("Work_mining_%s" % str(miner_id),true,false) as Button
    if mining == null or mining.disabled:
        _fail("Mine annex selected worker cannot receive real Mine command.")
        return
    var xp_before := float((state.disciples[miner_id] as DiscipleState).profession_xp.get("mining",0.0))
    var stock_before := warehouse.quantity(state,&"thanh_thiet")
    mining.pressed.emit()
    await process_frame
    var scheduler := (ui.get("runtime_session") as LiveGameRuntimeV2).scheduler()
    var job: Dictionary = {}
    for _n in range(12):
        scheduler.step()
        job = buildings.active_resource_timer_for_worker(state,miner_id)
        if not job.is_empty():
            break
    if job.is_empty() or not buildings.resource_timer_jobs(mine_two).has(job) or (
        int(job.get("finish_tick",0)) <= state.tick
        or warehouse.quantity(state,&"thanh_thiet") != stock_before
        or not is_equal_approx(float((state.disciples[miner_id] as DiscipleState).profession_xp.get("mining",0.0)),xp_before)
    ):
        _fail("Second Mine did not create a real unpaid timed job without early stock/EXP.")
        return

    var forest_preview := buildings.preview_production_annex(state, BuildingSystem.TYPE_LINH_FOREST)
    if not bool(forest_preview.get("ok",false)):
        _fail("Cannot afford genuine second Forest: " + str(forest_preview))
        return
    var forest_built := buildings.build_paid_production_annex(state,BuildingSystem.TYPE_LINH_FOREST,"qa:b:forest:2")
    if not bool(forest_built.get("ok",false)):
        _fail("Real Forest annex purchase rejected: " + str(forest_built))
        return
    var forest_id := StringName(forest_built.get("building_id",""))
    var forest_two: BuildingState = state.buildings.get(str(forest_id)) as BuildingState
    if forest_two == null or forest_two.id == first_forest.id:
        _fail("Forest annex did not create a distinct real BuildingState.")
        return
    var forester_id: StringName = &""
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var next_id := StringName(raw_id)
        if next_id == miner_id:
            continue
        var member: DiscipleState = state.disciples[next_id]
        if member.work_group_id != &"mining_crew" and member.active_pve_encounter_id.is_empty():
            forester_id = next_id
            break
    if forester_id == &"":
        _fail("No real non-mining disciple for the Forest annex.")
        return
    ui.call("_open_building",SectMapPresentation.DEST_LINH_FOREST,forest_id)
    await process_frame
    var group_button := ui.find_child("Group_forestry_crew_%s" % str(forester_id),true,false) as Button
    if group_button == null or group_button.disabled:
        _fail("Forest annex has no real workforce group control.")
        return
    group_button.pressed.emit()
    await process_frame
    await process_frame
    var forest_picker := ui.find_child("ForestWorksite_%s" % str(forester_id),true,false) as Button
    if forest_picker == null or forest_picker.disabled:
        _fail("Forest annex has no enabled per-instance worksite control.")
        return
    forest_picker.pressed.emit()
    await process_frame
    await process_frame
    var assigned: DiscipleState = state.disciples[forester_id]
    if assigned.worksite_building_id != forest_id or (
        not buildings.active_worker_ids(state,forest_two).has(forester_id)
        or buildings.active_worker_ids(state,first_forest).has(forester_id)
    ):
        _fail("Forest worksite button did not transfer actual worker ownership.")
        return
    var forestry := ui.find_child("Work_forestry_%s" % str(forester_id),true,false) as Button
    if forestry == null or forestry.disabled:
        _fail("Player cannot order production at selected Forest annex.")
        return

    if SaveService.new().save_to_path(state,SAVE_PATH) != OK:
        _fail("Canonical second-worksite SaveService failed.")
        return
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if loaded == null or not loaded.disciples.has(miner_id) or not loaded.disciples.has(forester_id):
        _fail("Second-worksite cold Save/Load rejected.")
        return
    var loaded_mine: BuildingState = loaded.buildings.get(str(mine_id)) as BuildingState
    var loaded_forest: BuildingState = loaded.buildings.get(str(forest_id)) as BuildingState
    if loaded_mine == null or loaded_forest == null or (
        (loaded.disciples[miner_id] as DiscipleState).worksite_building_id != mine_id
        or (loaded.disciples[forester_id] as DiscipleState).worksite_building_id != forest_id
        or not buildings.active_worker_ids(loaded,loaded_mine).has(miner_id)
        or not buildings.active_worker_ids(loaded,loaded_forest).has(forester_id)
    ):
        _fail("Cold Save/Load lost canonical worker ownership of paid annexes.")
        return

    ui.queue_free()
    await process_frame
    _cleanup()
    print("GATE B PAID MULTI-SITE MINE/FOREST WORKER + TIMER + SAVE: PASS")
    quit(0)

func _stop_timers(node: Node) -> void:
    if node is Timer:
        (node as Timer).stop()
    for child in node.get_children():
        _stop_timers(child)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> void:
    push_error("GATE B MULTI-SITE: " + message)
    if ui != null and is_instance_valid(ui):
        ui.queue_free()
    _cleanup()
    quit(1)
