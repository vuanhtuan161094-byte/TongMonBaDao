extends SceneTree

# O7: Linh Lâm + generic carry-cycle Building Job acceptance.
# Starter wood is reserved as provenance; only Linh Lâm output may be spent.
const SAVE_PATH := "user://p3_o7_linh_forest_test.json"
const RECIPE_ID := &"thanh_thiet_kiem"

var ui: Control
var state: SimulationState
var scheduler: SimulationScheduler
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var equipment := EquipmentSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    var forest := buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    if forest == null:
        _fail("O7 fresh runtime has no authoritative Linh Lam.")
        return
    if forest.level != 1 or buildings.worker_slots(forest) != 2:
        _fail("O7 fresh Linh Lam must be Lv1 with exactly two active slots.")
        return
    if ui.find_child("BuildingToken_linh_forest", true, false) == null:
        _fail("O7 landscape has no real Linh Lam token.")
        return
    if buildings.building_type_for_profession(WorkforceSystem.PROF_FORESTRY) != BuildingSystem.TYPE_LINH_FOREST:
        _fail("O7 Forestry is not bound to Linh Lam by building authority.")
        return

    var starter_wood := warehouse.quantity(state, &"linh_moc")
    if starter_wood < 40:
        _fail("O7 fresh canonical starter Linh Moc baseline is missing.")
        return
    if not warehouse.set_rule(state, &"linh_moc", starter_wood, false):
        _fail("O7 could not reserve starter wood for provenance.")
        return
    if warehouse.available_quantity(state, &"linh_moc") != 0:
        _fail("O7 starter wood reserve did not isolate new production.")
        return

    var worker_id := _find_unassigned_disciple()
    if worker_id == &"":
        _fail("O7 fresh state has no unassigned disciple for Forestry.")
        return
    var worker: DiscipleState = state.disciples[worker_id]

    # Freeze unrelated actors; they must not alter the resource deltas used here.
    for raw_id in state.disciples.keys():
        var id := StringName(raw_id)
        if id == worker_id:
            continue
        if not workforce.issue_command(state, id, WorkforceSystem.COMMAND_HOLD, "", 800):
            _fail("O7 could not isolate unrelated disciple %s." % str(id))
            return

    if not await _open_forest():
        return
    if not await _press("Group_forestry_crew_%s" % str(worker_id)):
        return
    if worker.work_group_id != &"forestry_crew" or not buildings.active_worker_ids(state, forest).has(worker_id):
        _fail("O7 player UI did not assign the disciple to a real Linh Lam slot.")
        return

    # 1) Cancel before carry: travel/harvesting may progress but no wood payout.
    if not await _press("Work_forestry_%s" % str(worker_id)):
        return
    var starter_qty := warehouse.quantity(state, &"linh_moc")
    var reached_harvesting := false
    for _i in range(24):
        scheduler.step()
        ui.call("_refresh_all")
        var phase := StringName(worker.work_cycle_state.get("phase", ""))
        if phase == &"harvesting" and int(worker.work_cycle_state.get("carried_units", 0)) == 0:
            reached_harvesting = true
            break
    if not reached_harvesting:
        _fail("O7 pre-carry cancel probe never reached harvesting.")
        return
    if not await _open_forest():
        return
    if not await _press("Group_forestry_crew_%s" % str(worker_id)):
        return
    if warehouse.quantity(state, &"linh_moc") != starter_qty:
        _fail("O7 cancel-before-carry paid phantom Linh Moc.")
        return
    if not worker.work_cycle_state.is_empty() or not worker.direct_command.is_empty():
        _fail("O7 cancel-before-carry left stale cycle/command.")
        return

    # 2) Reassign and reach haul with exactly the authored 2 new wood.
    if not await _press("Group_forestry_crew_%s" % str(worker_id)):
        return
    if not await _press("Work_forestry_%s" % str(worker_id)):
        return
    var reached_haul := false
    for _i in range(32):
        scheduler.step()
        ui.call("_refresh_all")
        if (
            StringName(worker.work_cycle_state.get("phase", "")) == &"haul_back"
            and int(worker.work_cycle_state.get("carried_units", 0)) == 2
        ):
            reached_haul = true
            break
    if not reached_haul:
        _fail("O7 Forestry cycle did not reach haul_back with exactly 2 Linh Moc.")
        return
    if StringName(worker.work_cycle_state.get("profession_id", "")) != WorkforceSystem.PROF_FORESTRY:
        _fail("O7 generic Building Job lost profession_id.")
        return
    if StringName(worker.work_cycle_state.get("resource_id", "")) != &"linh_moc":
        _fail("O7 generic Building Job lost resource_id.")
        return
    if str(worker.work_cycle_state.get("building_id", "")) != str(forest.id):
        _fail("O7 generic Building Job lost building identity.")
        return

    # Mid-cycle persistence preserves carried output and phase without deposit.
    ui.call("_autosave_runtime")
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return
    forest = buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    worker = state.disciples[worker_id]
    if StringName(worker.work_cycle_state.get("phase", "")) != &"haul_back" or int(worker.work_cycle_state.get("carried_units", 0)) != 2:
        _fail("O7 reload lost/restarted the Forestry haul.")
        return
    if warehouse.quantity(state, &"linh_moc") != starter_qty:
        _fail("O7 reload deposited carried wood early.")
        return

    # Cancel during haul settles carried output once, through the same group UI.
    if not await _open_forest():
        return
    if not await _press("Group_forestry_crew_%s" % str(worker_id)):
        return
    if warehouse.quantity(state, &"linh_moc") != starter_qty + 2:
        _fail("O7 cancel-during-haul did not settle exactly 2 carried wood.")
        return
    if not worker.work_cycle_state.is_empty() or not worker.direct_command.is_empty():
        _fail("O7 haul cancellation left stale Forestry state.")
        return
    var after_settle := warehouse.quantity(state, &"linh_moc")
    scheduler.run_ticks(20)
    if warehouse.quantity(state, &"linh_moc") != after_settle:
        _fail("O7 settled carried output was deposited more than once.")
        return

    # Spend one of those newly produced wood through an existing real consumer.
    if warehouse.available_quantity(state, &"linh_moc") != 2:
        _fail("O7 provenance reserve does not expose exactly the produced wood.")
        return
    ui.call("_open_building", SectMapPresentation.DEST_FORGE)
    await process_frame
    var craft := ui.find_child("Craft_%s" % str(RECIPE_ID), true, false) as Button
    if craft == null or craft.disabled:
        _fail("O7 newly produced Linh Moc did not enable the existing Forge consumer.")
        return
    var wood_before_craft := warehouse.quantity(state, &"linh_moc")
    var items_before := state.sect.equipment_items.size()
    craft.emit_signal("pressed")
    await process_frame
    if warehouse.quantity(state, &"linh_moc") != wood_before_craft - 1:
        _fail("O7 Forge did not consume exactly one newly produced Linh Moc.")
        return
    if warehouse.quantity(state, &"linh_moc") < starter_wood:
        _fail("O7 Forge crossed the reserved starter-wood floor.")
        return
    if state.sect.equipment_items.size() != items_before + 1:
        _fail("O7 existing consumer did not create exactly one item.")
        return

    # 3) Complete a full Forestry cycle to prove XP and command completion.
    if not await _open_forest():
        return
    if worker.work_group_id != &"forestry_crew":
        if not await _press("Group_forestry_crew_%s" % str(worker_id)):
            return
    var xp_before := workforce.profession_xp(worker, WorkforceSystem.PROF_FORESTRY)
    var batches_before := int(forest.metrics.get("production_batches", 0))
    if not await _press("Work_forestry_%s" % str(worker_id)):
        return
    for _i in range(64):
        scheduler.step()
        ui.call("_refresh_all")
        if int(forest.metrics.get("production_batches", 0)) > batches_before:
            break
    if int(forest.metrics.get("production_batches", 0)) != batches_before + 1:
        _fail("O7 explicit Forestry cycle did not complete exactly once.")
        return
    if workforce.profession_xp(worker, WorkforceSystem.PROF_FORESTRY) <= xp_before:
        _fail("O7 completed Forestry cycle granted no profession XP.")
        return
    if int(worker.metrics.get("forestry_completions", 0)) <= 0:
        _fail("O7 completed Forestry cycle recorded no Forestry completion.")
        return
    if not worker.direct_command.is_empty() or not worker.work_cycle_state.is_empty():
        _fail("O7 completed Forestry cycle left stale command/cycle.")
        return

    # Keep the worker in crew. Scheduler must autonomously begin and complete
    # another legal cycle without another player work click.
    var auto_batches_before := int(forest.metrics.get("production_batches", 0))
    var auto_completed := false
    for _i in range(180):
        scheduler.step()
        if int(forest.metrics.get("production_batches", 0)) > auto_batches_before:
            auto_completed = true
            break
    if not auto_completed:
        _fail("O7 Forestry crew did not autonomously repeat a legal cycle.")
        return

    ui.call("_refresh_all")
    var forest_text := str(ui.call("_linh_forest_operation_text"))
    var qty := warehouse.quantity(state, &"linh_moc")
    var usable := warehouse.available_quantity(state, &"linh_moc")
    if not forest_text.contains("Linh Mộc tồn (dùng): %d (dùng %d)" % [qty, usable]):
        _fail("O7 Linh Lam panel disagrees with canonical Warehouse.")
        return
    if not str(ui.call("_warehouse_operation_text")).contains("Linh Mộc: %d (dùng %d)" % [qty, usable]):
        _fail("O7 Kho panel disagrees with canonical Linh Moc.")
        return

    var errors := state.validate_invariants()
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    if not errors.is_empty():
        _fail("O7 final state violates invariants: %s" % " | ".join(errors))
        return

    print("P3 O7 LINH FOREST GENERIC BUILDING JOB TEST PASS")
    _dispose_scene()
    await process_frame
    _cleanup_save()
    quit(0)

func _find_unassigned_disciple() -> StringName:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id == &"" and disciple.region_id == &"sect":
            return disciple.id
    return &""

func _open_forest() -> bool:
    var hit := ui.find_child("BuildingHit_linh_forest", true, false) as Button
    if hit == null:
        return _fail("O7 has no player-facing Linh Lam hit target.")
    hit.emit_signal("pressed")
    await process_frame
    if StringName(ui.get("selected_building")) != SectMapPresentation.DEST_LINH_FOREST:
        return _fail("O7 Linh Lam hit target did not open its panel.")
    return true

func _press(node_name: String) -> bool:
    var button := ui.find_child(node_name, true, false) as Button
    if button == null:
        return _fail("O7 missing player-facing button: %s" % node_name)
    if button.disabled:
        return _fail("O7 required button is disabled: %s" % node_name)
    button.emit_signal("pressed")
    await process_frame
    return true

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O7 could not load P3.2 landscape main scene.")
    ui = scene.instantiate() as Control
    if ui == null:
        return _fail("O7 could not instantiate P3.2 landscape main scene.")
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        return _fail("O7 scene returned no live SimulationState.")
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if runtime == null:
        return _fail("O7 scene returned no LiveGameRuntimeV2.")
    scheduler = runtime.scheduler()
    if scheduler == null:
        return _fail("O7 runtime returned no scheduler.")
    _stop_timers(ui)
    return true

func _dispose_scene() -> void:
    if ui == null:
        return
    ui.set("runtime_ready", false)
    ui.queue_free()
    ui = null
    state = null
    scheduler = null

func _stop_timers(node: Node) -> void:
    if node is Timer:
        (node as Timer).stop()
    for child in node.get_children():
        _stop_timers(child)

func _cleanup_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error(message)
    _dispose_scene()
    _cleanup_save()
    quit(1)
    return false
