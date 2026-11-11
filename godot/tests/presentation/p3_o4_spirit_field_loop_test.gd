extends SceneTree

# O4: real player-facing Spirit Field loop through the live 1280x720 P3.2 scene.
# UI assignment/order -> authoritative plot payment/timer -> canonical harvest ->
# field/warehouse agreement -> mid/post-cycle persistence and denial rules.
const SAVE_PATH := "res://.godot/qa/rc52_perf_fix_20261029/p3_o4_spirit_field_loop.json"

var ui: Control
var state: SimulationState
var scheduler: SimulationScheduler
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var crops := SpiritCropRegistry.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        _fail("O4 live scene has no authoritative Spirit Field.")
        return
    if ui.find_child("BuildingToken_spirit_field", true, false) == null:
        _fail("O4 landscape map has no Linh Điền entry.")
        return
    if field.level != 1 or buildings.worker_slots(field) != 4 or buildings.spirit_plot_slots(field) != 4:
        _fail("O4 fresh Lv1 Spirit Field must expose 4 workers / 4 plots.")
        return
    if state.sect.spirit_stones != 500:
        _fail("O4 fresh opening must use the existing canonical 500 Sect Spirit Stones; stones=%d roots=%s techniques=%s save_exists=%s" % [
            state.sect.spirit_stones,str(state.sect.spiritual_roots_enabled),str(state.sect.techniques_enabled),str(FileAccess.file_exists(SAVE_PATH))])
        return

    ui.call("_open_building", SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    if StringName(ui.get("selected_building")) != SectMapPresentation.DEST_SPIRIT_FIELD:
        _fail("O4 Linh Điền token did not open its management panel.")
        return
    if ui.find_child("Upgrade_%s" % str(field.id),true,false) == null or ui.find_child("FieldProfessionXpGuide",true,false) == null:
        _fail("O4 UI has no paid Field upgrade or honest per-crop profession XP guide.")
        return
    if not await _press_button("PlotCropCycle_plot_001"):
        return
    if str(field.production_state.get("plot_crop_preferences",{}).get("plot_001","")) != "linh_coc":
        _fail("O4 real crop-selection button did not persist individual Plot 01 policy.")
        return

    var target_id := _find_unassigned_disciple()
    if target_id == &"":
        _fail("O4 fresh opening has no unassigned disciple for field assignment.")
        return

    for raw_id in state.disciples.keys():
        var hold_id := StringName(raw_id)
        if hold_id == target_id:
            continue
        if not workforce.issue_command(state, hold_id, WorkforceSystem.COMMAND_HOLD, "", 300):
            _fail("O4 could not isolate non-target disciple %s." % str(hold_id))
            return

    if not await _press_button("FieldGroup_%s" % str(target_id)):
        return
    var target: DiscipleState = state.disciples[target_id]
    if target.work_group_id != &"herbalism_crew":
        _fail("O4 UI failed to assign the real disciple to Đội Linh Thực.")
        return
    if not buildings.active_worker_ids(state, field).has(target_id):
        _fail("O4 assigned disciple did not own a real active Spirit Field slot.")
        return

    var plant := ui.find_child("FieldPlant_%s" % str(target_id), true, false) as Button
    if plant == null or plant.disabled:
        _fail("O4 eligible field worker has no enabled Gieo trồng action.")
        return

    var stones_before := state.sect.spirit_stones
    plant.emit_signal("pressed")
    await process_frame
    if workforce.command_kind(target) != WorkforceSystem.COMMAND_WORK or workforce.command_target(target) != WorkforceSystem.PROF_HERBALISM:
        _fail("O4 Gieo trồng button did not issue the canonical herbalism command.")
        return

    var plot := {}
    for _i in range(8):
        scheduler.step()
        ui.call("_refresh_all")
        plot = _plot_for_worker(field, target_id)
        if not plot.is_empty():
            break
    if plot.is_empty():
        _fail("O4 scheduler did not create a real growing plot.")
        return

    var crop_id := StringName(plot.get("crop_id", ""))
    if crop_id != &"linh_coc":
        _fail("O4 planting ignored Plot 01 player-selected crop.")
        return
    var output_id := crops.output_resource_id(crop_id)
    # GP2: the live map cue must name the REAL selected crop, not the generic
    # "Linh thảo" caption. Read-only: the planted plot is an actual paid
    # scheduler job and the warehouse receipt is still pending.
    var map_crop := ui.call("_map_worksite_snapshot", field) as Dictionary
    var crop_name := crops.display_name(crop_id)
    if not str(map_crop.get("detail", "")).contains(crop_name + " ×"):
        _fail("GP2 live map Field ETA mislabeled real crop %s; detail=%s" % [
            crop_name, str(map_crop.get("detail", ""))
        ])
        return
    if not str(map_crop.get("display_detail", "")).contains(crop_name):
        _fail("GP2 compact map Field cue lost selected crop %s." % crop_name)
        return
    if int(map_crop.get("received", -1)) != int(field.metrics.get("units_produced", 0)):
        _fail("GP2 field map falsely counted a growing plot as Warehouse receipt.")
        return
    var paid := int(plot.get("paid_spirit_stones", 0))
    if not [3, 4].has(paid) or paid != crops.cost(crop_id):
        _fail("O4 fresh crop did not use the canonical Lv1 planting cost.")
        return
    if state.sect.spirit_stones != stones_before - paid:
        _fail("O4 planting did not debit Sect Spirit Stones exactly once.")
        return
    if str(plot.get("assigned_worker_id", "")) != str(target_id):
        _fail("O4 canonical plot did not reserve the selected worker.")
        return
    if workforce.command_kind(target) != &"":
        _fail("O4 completed start-crop action left a stale direct command.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    var duplicate_button := ui.find_child("FieldPlant_%s" % str(target_id), true, false) as Button
    if duplicate_button == null or not duplicate_button.disabled:
        _fail("O4 UI allows a second plot for a worker already reserved by one.")
        return
    if workforce.issue_command(state, target_id, WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_HERBALISM), 40):
        _fail("O4 backend accepted duplicate field work for a reserved worker.")
        return

    ui.call("_open_disciple_quick_assignment",target_id)
    await process_frame
    var active_withdraw_button := ui.find_child("QuickAssignmentWithdraw",true,false) as Button
    if active_withdraw_button == null or not active_withdraw_button.disabled or not active_withdraw_button.tooltip_text.contains("Linh Điền"):
        _fail("O4 Quick Assignment did not keep a growing Field worker reserved or explain the lock.")
        return
    ui.call("_open_building",SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame

    var output_before := warehouse.quantity(state, output_id)
    var batches_before := int(field.metrics.get("production_batches", 0))
    var units_before := int(field.metrics.get("units_produced", 0))
    var saved_finish := int(plot.get("finish_tick", -1))
    var saved_stones := state.sect.spirit_stones

    await ui.call("_autosave_runtime")
    if not FileAccess.file_exists(SAVE_PATH):
        _fail("O4 mid-growth runtime save was not written.")
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return

    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    target = state.disciples[target_id]
    plot = _plot_for_worker(field, target_id)
    if plot.is_empty() or int(plot.get("finish_tick", -2)) != saved_finish:
        _fail("O4 save/reload lost or restarted the real growing plot.")
        return
    if state.sect.spirit_stones != saved_stones:
        _fail("O4 reload charged the planting cost a second time.")
        return
    if target.region_id != &"sect":
        _fail("O4 reserved field worker left the sect during growth.")
        return

    var harvested := false
    var harvest_delta := 0
    for _i in range(80):
        scheduler.step()
        ui.call("_refresh_all")
        var now := warehouse.quantity(state, output_id)
        if now > output_before:
            harvested = true
            harvest_delta = now - output_before
            break
        if target.region_id != &"sect":
            _fail("O4 reserved worker escaped to another AI activity before harvest.")
            return
    if not harvested:
        _fail("O4 real plot did not harvest within the bounded canonical timer.")
        return
    if buildings.disciple_has_active_spirit_plot(state, target_id, field):
        _fail("O4 harvest did not release the plot/worker reservation.")
        return
    if int(field.metrics.get("production_batches", 0)) != batches_before + 1:
        _fail("O4 harvest did not record exactly one production batch.")
        return
    if int(field.metrics.get("units_produced", 0)) - units_before != harvest_delta:
        _fail("O4 warehouse delta disagrees with authoritative Field production metrics.")
        return
    if harvest_delta <= 0:
        _fail("O4 harvest produced no canonical resource.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    var field_text := str(ui.call("_spirit_field_operation_text"))
    var warehouse_text := str(ui.call("_warehouse_operation_text"))
    var output_name := ResourceRegistry.new().display_name(output_id)
    var output_total := warehouse.quantity(state, output_id)
    var output_available := warehouse.available_quantity(state, output_id)
    var field_pair := "%d (dùng %d)" % [output_total, output_available]
    var warehouse_line := "• %s ×%s · dùng được %s" % [
        output_name,
        str(ui.call("_compact_number", output_total)),
        str(ui.call("_compact_number", output_available))
    ]
    if (
        not field_text.contains("%s: %s" % [output_name, field_pair])
        or not warehouse_text.contains(warehouse_line)
    ):
        _fail("O4 Linh Điền/Kho did not render the same canonical %s stock (%d total, %d usable)." % [
            output_name, output_total, output_available
        ])
        return

    ui.call("_open_disciple_quick_assignment",target_id)
    await process_frame
    var withdraw_button := ui.find_child("QuickAssignmentWithdraw",true,false) as Button
    if withdraw_button == null or withdraw_button.disabled:
        _fail("O4 idle post-harvest worker has no enabled Rút khỏi việc action.")
        return
    withdraw_button.emit_signal("pressed")
    await process_frame
    if target.work_group_id != &"" or target.worksite_building_id != &"":
        _fail("O4 quick withdrawal did not release the canonical crew and worksite.")
        return
    if not workforce.issue_command(state, target_id, WorkforceSystem.COMMAND_HOLD, "", 120):
        _fail("O4 could not hold the released worker for duplicate-harvest probe.")
        return

    var post_harvest_qty := warehouse.quantity(state, output_id)
    var post_harvest_batches := int(field.metrics.get("production_batches", 0))
    await ui.call("_autosave_runtime")
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return

    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    target = state.disciples[target_id]
    if target.work_group_id != &"" or target.worksite_building_id != &"":
        _fail("O4 Save/Reload did not preserve the explicit worker withdrawal.")
        return
    if warehouse.quantity(state, output_id) != post_harvest_qty:
        _fail("O4 post-harvest reload duplicated or lost crop output.")
        return
    scheduler.run_ticks(20)
    if warehouse.quantity(state, output_id) != post_harvest_qty or int(field.metrics.get("production_batches", 0)) != post_harvest_batches:
        _fail("O4 completed plot harvested more than once.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    if target.work_group_id != &"herbalism_crew":
        if not await _press_button("FieldGroup_%s" % str(target_id)):
            return
    state.sect.spirit_stones = 0
    ui.call("_refresh_building_operation_content")
    var no_funds := ui.find_child("FieldPlant_%s" % str(target_id), true, false) as Button
    if no_funds == null or not no_funds.disabled:
        _fail("O4 UI did not block Gieo trồng at zero Sect Spirit Stones.")
        return
    if workforce.issue_command(state, target_id, WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_HERBALISM), 40):
        _fail("O4 backend accepted unpaid Spirit Field work.")
        return
    if not _all_plots_empty(field):
        _fail("O4 insufficient-funds denial created a plot.")
        return

    var errors := state.validate_invariants()
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    if not errors.is_empty():
        _fail("O4 final state violates invariants: %s" % " | ".join(errors))
        return

    print("P3 O4 REAL SPIRIT FIELD LOOP TEST PASS")
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

func _plot_for_worker(field: BuildingState, disciple_id: StringName) -> Dictionary:
    for raw_plot in buildings.spirit_field_plots(state, field):
        if (
            raw_plot is Dictionary
            and StringName(raw_plot.get("status", "")) == BuildingSystem.PLOT_GROWING
            and str(raw_plot.get("assigned_worker_id", "")) == str(disciple_id)
        ):
            return (raw_plot as Dictionary).duplicate(true)
    return {}

func _all_plots_empty(field: BuildingState) -> bool:
    for raw_plot in buildings.spirit_field_plots(state, field):
        if raw_plot is Dictionary and StringName(raw_plot.get("status", "")) != BuildingSystem.PLOT_EMPTY:
            return false
    return true

func _press_button(node_name: String) -> bool:
    var button := ui.find_child(node_name, true, false) as Button
    if button == null:
        return _fail("O4 missing player-facing button: %s" % node_name)
    if button.disabled:
        return _fail("O4 required button is unexpectedly disabled: %s" % node_name)
    button.emit_signal("pressed")
    await process_frame
    return true

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O4 could not load landscape entry scene.")
    ui = scene.instantiate() as Control
    if ui == null:
        return _fail("O4 could not instantiate landscape entry scene.")
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        return _fail("O4 scene returned no live SimulationState.")
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if runtime == null:
        return _fail("O4 scene returned no LiveGameRuntimeV2.")
    scheduler = runtime.scheduler()
    if scheduler == null:
        return _fail("O4 live runtime returned no scheduler.")
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
    for path in [SAVE_PATH,SAVE_PATH+".tmp",SAVE_PATH+".bak"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_PATH.get_base_dir()))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error(message)
    _dispose_scene()
    _cleanup_save()
    quit(1)
    return false
