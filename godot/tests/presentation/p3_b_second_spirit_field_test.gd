extends SceneTree

# Gate B: real paid second Spirit Field, player-selected worksite and plot,
# exact-once profession EXP + Warehouse harvest across a cold SaveService load.
# No stock/stones/XP are injected. Initial funds are canonical New Game funds.
const SAVE_PATH := "user://p3_b_second_spirit_field_test.json"

var ui: Control
var state: SimulationState
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var crops := SpiritCropRegistry.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("Real P3.2 scene unavailable.")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if state == null or runtime == null or not bool(ui.get("runtime_ready")):
        _fail("Fresh live simulation runtime unavailable.")
        return
    _stop_timers(ui)
    var scheduler: SimulationScheduler = runtime.scheduler()
    var original := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if original == null or not state.sect.economy_a_enabled:
        _fail("Canonical original Field or Economy-A is missing.")
        return
    var worker_id: StringName = &""
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var person: DiscipleState = state.disciples[raw_id]
        if person.work_group_id == &"" and person.region_id == &"sect":
            worker_id = person.id
            break
    if worker_id == &"":
        _fail("Fresh live roster has no real field-capable available disciple.")
        return
    for raw_id in ids:
        var id := StringName(raw_id)
        if id == worker_id:
            continue
        if not workforce.issue_command(state,id,WorkforceSystem.COMMAND_HOLD,"",300):
            _fail("Could not isolate background player-simulation work.")
            return

    var stones_before := state.sect.spirit_stones
    var wood_before := warehouse.quantity(state,&"linh_moc")
    var iron_before := warehouse.quantity(state,&"thanh_thiet")
    ui.call("_open_building",SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    var build_button := ui.find_child("V57BuildProducer_spirit_field",true,false) as Button
    var preview := buildings.preview_production_annex(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if build_button == null or build_button.disabled or not bool(preview.get("ok",false)):
        _fail("Real paid second Field UI unavailable: " + str(preview))
        return
    var cost: Dictionary = preview.get("cost",{})
    build_button.pressed.emit()
    await process_frame
    var field_id := &"spirit_field_002"
    var second: BuildingState = state.buildings.get(str(field_id)) as BuildingState
    if second == null or second == original or (
        state.sect.spirit_stones != stones_before-int(cost.get("spirit_stones",0))
        or warehouse.quantity(state,&"linh_moc") != wood_before-int(cost.get("linh_moc",0))
        or warehouse.quantity(state,&"thanh_thiet") != iron_before-int(cost.get("thanh_thiet",0))
    ):
        _fail("Real second Field purchase did not consume exact Warehouse and treasury inputs.")
        return

    ui.call("_open_building",SectMapPresentation.DEST_SPIRIT_FIELD,field_id)
    await process_frame
    if StringName(ui.get("selected_production_instance_id")) != field_id or (
        not str(ui.call("_spirit_field_operation_text")).contains("LINH ĐIỀN 02")
        or ui.find_child("Upgrade_%s" % str(field_id),true,false) == null
    ):
        _fail("Selected Field 002 does not show its own production and upgrade UI.")
        return
    var group := ui.find_child("FieldGroup_%s" % str(worker_id),true,false) as Button
    if group == null or group.disabled:
        _fail("Real second Field cannot assign a production worker.")
        return
    group.pressed.emit()
    await process_frame
    await process_frame
    var site := ui.find_child("FieldWorksite_%s" % str(worker_id),true,false) as Button
    if site == null or site.disabled:
        _fail("Real second Field has no eligible per-instance worksite picker.")
        return
    site.pressed.emit()
    await process_frame
    await process_frame
    var person: DiscipleState = state.disciples[worker_id]
    if person.worksite_building_id != field_id or (
        not buildings.active_worker_ids(state,second).has(worker_id)
        or buildings.active_worker_ids(state,original).has(worker_id)
    ):
        _fail("Field worksite selection did not transfer the real active slot.")
        return
    var plant := ui.find_child("FieldPlant_%s" % str(worker_id),true,false) as Button
    if plant == null or plant.disabled:
        _fail("Eligible Field 002 worker has no enabled real planting command.")
        return
    var xp_before := float(person.profession_xp.get("herbalism",0.0))
    var costs_before := state.sect.spirit_stones
    plant.pressed.emit()
    await process_frame

    var plot: Dictionary = {}
    for _i in range(24):
        scheduler.step()
        plot = _plot_for_worker(second, worker_id)
        if not plot.is_empty():
            break
    if plot.is_empty() or not _plot_for_worker(original, worker_id).is_empty():
        _fail("Planting did not create a growing plot owned by Field 002.")
        return
    var crop_id := StringName(plot.get("crop_id",""))
    var stock_id := crops.output_resource_id(crop_id)
    var stock_at_plant := warehouse.quantity(state,stock_id)
    var reserved_xp := float(plot.get("profession_xp_gain",-1.0))
    if not crops.has(crop_id) or reserved_xp <= 0.0 or (
        state.sect.spirit_stones != costs_before-crops.cost(crop_id)
        or not is_equal_approx(float(person.profession_xp.get("herbalism",0.0)),xp_before)
        or not buildings.disciple_has_active_spirit_plot(state,worker_id,second)
    ):
        _fail("Field 002 did not debit real planting fee or preserve unearned EXP.")
        return
    ui.call("_refresh_building_operation_content")
    await process_frame
    var blocked_site := ui.find_child("FieldWorksite_%s" % str(worker_id),true,false) as Button
    var blocked_group := ui.find_child("FieldGroup_%s" % str(worker_id),true,false) as Button
    if blocked_site == null or blocked_group == null or not blocked_site.disabled or not blocked_group.disabled:
        _fail("Active growing plot did not prevent reassignment to a second Field.")
        return

    var barrier: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not bool(barrier.get("ok",false)):
        _fail("Live SaveService async barrier failed on the growing plot.")
        return
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if loaded == null or not loaded.buildings.has(str(field_id)) or not loaded.disciples.has(worker_id):
        _fail("Cold SaveService lost Field 002 or its worker.")
        return
    var loaded_field: BuildingState = loaded.buildings[str(field_id)]
    var loaded_plot := _plot_for_worker_loaded(loaded,loaded_field,worker_id)
    var loaded_worker: DiscipleState = loaded.disciples[worker_id]
    if loaded_plot.is_empty() or loaded_worker.worksite_building_id != field_id or (
        str(loaded_plot.get("plot_id","")) != str(plot.get("plot_id",""))
        or int(loaded_plot.get("finish_tick",0)) != int(plot.get("finish_tick",0))
        or not is_equal_approx(float(loaded_plot.get("profession_xp_gain",0.0)),reserved_xp)
        or not is_equal_approx(float(loaded_worker.profession_xp.get("herbalism",0.0)),xp_before)
        or warehouse.quantity(loaded,stock_id) != stock_at_plant
    ):
        _fail("Cold Save/Load changed pending Field 002 crop or granted goods/EXP early.")
        return

    var loaded_scheduler := SimulationScheduler.new(loaded)
    var until_harvest := int(plot.get("finish_tick",0))-loaded.tick
    if until_harvest <= 0 or until_harvest > 100:
        _fail("Field 002 saved harvest time is invalid.")
        return
    loaded_scheduler.run_ticks(until_harvest)
    var received := warehouse.quantity(loaded,stock_id)-stock_at_plant
    var after_xp := float(loaded_worker.profession_xp.get("herbalism",0.0))
    if received < int(plot.get("routine_yield",0)) or received > int(plot.get("routine_yield",0))*4 or (
        not is_equal_approx(after_xp,xp_before+reserved_xp)
        or not _plot_for_worker_loaded(loaded,loaded_field,worker_id).is_empty()
    ):
        _fail("Field 002 harvest did not settle Warehouse and exact recorded profession EXP.")
        return
    loaded_scheduler.step()
    if warehouse.quantity(loaded,stock_id) != stock_at_plant+received or (
        not is_equal_approx(float(loaded_worker.profession_xp.get("herbalism",0.0)),after_xp)
    ):
        _fail("Field 002 repeated harvest duplicated Warehouse stock or profession EXP.")
        return

    ui.set("runtime_ready",false)
    ui.queue_free()
    await process_frame
    _cleanup()
    print("GATE B FIELD 002 PAID PLOT + REAL EXP + WAREHOUSE + COLD SAVE EXACT-ONCE: PASS")
    quit(0)

func _plot_for_worker(field: BuildingState,worker_id: StringName) -> Dictionary:
    return _plot_for_worker_loaded(state,field,worker_id)

func _plot_for_worker_loaded(current: SimulationState,field: BuildingState,worker_id: StringName) -> Dictionary:
    for raw in buildings.spirit_field_plots(current,field):
        if raw is Dictionary and StringName(raw.get("status","")) == BuildingSystem.PLOT_GROWING and str(raw.get("assigned_worker_id","")) == str(worker_id):
            return (raw as Dictionary).duplicate(true)
    return {}

func _stop_timers(node: Node) -> void:
    if node is Timer:
        (node as Timer).stop()
    for child in node.get_children():
        _stop_timers(child)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var file: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(file):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(reason: String) -> void:
    push_error("GATE B FIELD 002: "+reason)
    if ui != null and is_instance_valid(ui):
        ui.set("runtime_ready",false)
        ui.queue_free()
    _cleanup()
    quit(1)
