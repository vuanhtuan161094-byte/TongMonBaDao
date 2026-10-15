extends SceneTree

# O3: actual player-facing Mine loop through the real P3.2 scene.
# UI assignment/order -> SimulationScheduler -> travel/extract/haul ->
# canonical Warehouse -> UI -> mid-cycle and post-deposit persistence.
const SAVE_PATH := "user://p3_o3_mine_loop_test.json"

var ui: Control
var state: SimulationState
var scheduler: SimulationScheduler
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null:
        _fail("O3 live scene has no authoritative Mine.")
        return
    var initial_active := buildings.active_worker_ids(state, mine)
    if initial_active.size() != 1:
        _fail("O3 fresh Mine must have one real active worker.")
        return

    var target_id: StringName = initial_active[0]
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame

    # Withdraw the sole owner, then re-assign via the existing real UI.
    if not await _press_button("Group_mining_crew_%s" % str(target_id)):
        return
    if (state.disciples[target_id] as DiscipleState).work_group_id != &"":
        _fail("O3 UI failed to withdraw the target Mine worker.")
        return
    if not await _press_button("Group_mining_crew_%s" % str(target_id)):
        return

    var target: DiscipleState = state.disciples[target_id]
    if target.work_group_id != &"mining_crew" or not buildings.active_worker_ids(state, mine).has(target_id):
        _fail("O3 UI failed to assign the target to a real active Mine slot.")
        return

    # The scheduler owns every disciple. Freeze non-target actors through the
    # real HOLD command so unrelated hunts/forge-loot deposits cannot contaminate
    # the ore delta attributed to this isolated Mine cycle.
    for raw_id in state.disciples.keys():
        var hold_id := StringName(raw_id)
        if hold_id == target_id:
            continue
        if not workforce.issue_command(state, hold_id, WorkforceSystem.COMMAND_HOLD, "", 300):
            _fail("O3 could not isolate non-target disciple %s with canonical HOLD." % str(hold_id))
            return

    var work_button := ui.find_child("Work_mining_%s" % str(target_id), true, false) as Button
    if work_button == null or work_button.disabled:
        _fail("O3 active Mine worker does not have an enabled player-facing work command.")
        return

    var ore_before := warehouse.quantity(state, &"thanh_thiet")
    work_button.emit_signal("pressed")
    await process_frame
    if workforce.command_kind(target) != WorkforceSystem.COMMAND_WORK or workforce.command_target(target) != WorkforceSystem.PROF_MINING:
        _fail("O3 Mine button did not issue the canonical mining command.")
        return

    var seen: Dictionary = {}
    var reached_haul := false
    for _i in range(48):
        scheduler.step()
        ui.call("_refresh_all")
        var phase := StringName(target.work_cycle_state.get("phase", ""))
        if phase != &"":
            seen[str(phase)] = true
        if phase == &"haul_back" and int(target.work_cycle_state.get("carried_units", 0)) > 0:
            reached_haul = true
            break
    if not reached_haul:
        _fail("O3 scheduler did not reach the real haul_back phase.")
        return
    if warehouse.quantity(state, &"thanh_thiet") != ore_before:
        _fail("O3 deposited ore before the haul phase actually returned.")
        return
    var body: Label = ui.get("building_operation_body") as Label
    if body == null or not body.text.contains("Vận chuyển về kho"):
        _fail("O3 Mine UI does not expose the real haul phase.")
        return

    # Save/reload while carrying ore: no early or duplicate deposit.
    ui.call("_autosave_runtime")
    if not FileAccess.file_exists(SAVE_PATH):
        _fail("O3 mid-cycle runtime save was not written.")
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return

    mine = buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    target = state.disciples[target_id]
    if StringName(target.work_cycle_state.get("phase", "")) != &"haul_back":
        _fail("O3 mid-cycle save/reload lost the haul phase.")
        return
    if int(target.work_cycle_state.get("carried_units", 0)) <= 0:
        _fail("O3 mid-cycle save/reload lost carried ore.")
        return
    if warehouse.quantity(state, &"thanh_thiet") != ore_before:
        _fail("O3 reload duplicated carried ore before delivery.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    var completed := false
    for _i in range(48):
        var phase_before := StringName(target.work_cycle_state.get("phase", ""))
        if phase_before != &"":
            seen[str(phase_before)] = true
        scheduler.step()
        ui.call("_refresh_all")
        var now := warehouse.quantity(state, &"thanh_thiet")
        if now > ore_before:
            completed = true
            break
    if not completed:
        _fail("O3 real scheduler never deposited the Mine batch.")
        return

    for phase_name in ["travel_out", "mining", "haul_back"]:
        if not seen.has(phase_name):
            _fail("O3 player loop never observed canonical phase %s." % phase_name)
            return

    var expected_batch := buildings.mining_batch_units_for_worker(state, mine, target)
    var ore_after := warehouse.quantity(state, &"thanh_thiet")
    if ore_after != ore_before + expected_batch:
        _fail("O3 first isolated batch deposited %d ore; expected exactly %d." % [ore_after - ore_before, expected_batch])
        return
    if not target.work_cycle_state.is_empty() or workforce.command_kind(target) != &"":
        _fail("O3 completed batch left stale cycle/command state.")
        return

    ui.call("_refresh_all")
    var top: Label = ui.get("resource_label") as Label
    if top == null or not top.text.contains("Thiết %d/%d" % [ore_after, ore_after]):
        _fail("O3 top bar disagrees with canonical ore after real production.")
        return
    if not str(ui.call("_mine_operation_text")).contains("Thanh Thiết tồn (dùng): %d (dùng %d)" % [ore_after, ore_after]):
        _fail("O3 Mine panel disagrees with canonical ore.")
        return
    if not str(ui.call("_warehouse_operation_text")).contains("Thanh Thiết: %d (dùng %d)" % [ore_after, ore_after]):
        _fail("O3 Warehouse panel disagrees with canonical ore.")
        return

    # A completed batch must remain exact across another disk reload.
    ui.call("_autosave_runtime")
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return
    mine = buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    target = state.disciples[target_id]
    if warehouse.quantity(state, &"thanh_thiet") != ore_after:
        _fail("O3 post-deposit reload duplicated or lost ore.")
        return

    # Interruption: start another real cycle, enter extraction, then withdraw
    # through the UI. Cycle AND direct command must disappear immediately.
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    work_button = ui.find_child("Work_mining_%s" % str(target_id), true, false) as Button
    if work_button == null or work_button.disabled:
        _fail("O3 could not start interruption probe from the real Mine UI.")
        return
    work_button.emit_signal("pressed")
    await process_frame

    var reached_mining := false
    for _i in range(40):
        scheduler.step()
        ui.call("_refresh_all")
        if StringName(target.work_cycle_state.get("phase", "")) == &"mining":
            reached_mining = true
            break
    if not reached_mining:
        _fail("O3 interruption probe never reached extraction.")
        return

    var ore_before_interrupt := warehouse.quantity(state, &"thanh_thiet")
    if not await _press_button("Group_mining_crew_%s" % str(target_id)):
        return
    if target.work_group_id != &"" or not target.work_cycle_state.is_empty() or not target.direct_command.is_empty():
        _fail("O3 withdrawing a miner did not cancel group/cycle/command atomically.")
        return

    var disabled_work := ui.find_child("Work_mining_%s" % str(target_id), true, false) as Button
    if disabled_work == null or not disabled_work.disabled:
        _fail("O3 UI still allows mining without a real active Mine slot.")
        return
    if workforce.issue_command(state, target_id, WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_MINING), 40):
        _fail("O3 backend accepted a mining command without an active Mine slot.")
        return
    if not workforce.issue_command(state, target_id, WorkforceSystem.COMMAND_HOLD, "", 100):
        _fail("O3 could not isolate the withdrawn miner after interruption.")
        return

    for _i in range(50):
        scheduler.step()
    if warehouse.quantity(state, &"thanh_thiet") != ore_before_interrupt:
        _fail("O3 interrupted/removed assignment later produced phantom ore.")
        return

    # Occupied Mine: a second disciple must be refused before allocation,
    # not left in a hidden waiting crew.
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    if not await _press_button("Group_mining_crew_%s" % str(target_id)):
        return
    var candidate_id := &""
    var all_ids: Array = state.disciples.keys()
    all_ids.sort()
    for raw_id in all_ids:
        var probe_id := StringName(raw_id)
        var probe: DiscipleState = state.disciples[probe_id]
        if probe_id != target_id and probe.work_group_id == &"":
            candidate_id = probe_id
            break
    if candidate_id == &"":
        _fail("O3 needs another unassigned disciple to probe full Mine.")
        return
    if workforce.assign_group(state, candidate_id, &"mining_crew"):
        _fail("O3 accepted a second miner into the one-worker Mine.")
        return
    if bool(workforce.assign_mine_worker(state, candidate_id, mine.id).get("ok", false)):
        _fail("O3 atomic assignment bypassed one-worker Mine.")
        return
    if buildings.assigned_worker_ids(state, mine).size() != 1:
        _fail("O3 rejected second worker changed the Mine roster.")
        return
    if workforce.issue_command(state, candidate_id, WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_MINING), 40):
        _fail("O3 backend accepted work without an actual Mine slot.")
        return

    var errors := state.validate_invariants()
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    if not errors.is_empty():
        _fail("O3 final state violates invariants: %s" % " | ".join(errors))
        return

    print("P3 O3 REAL MINE LOOP TEST PASS")
    _dispose_scene()
    await process_frame
    _cleanup_save()
    quit(0)

func _mining_group_ids() -> Array[StringName]:
    var result: Array[StringName] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id == &"mining_crew":
            result.append(disciple.id)
    return result

func _press_button(node_name: String) -> bool:
    var button := ui.find_child(node_name, true, false) as Button
    if button == null:
        return _fail("O3 missing player-facing button: %s" % node_name)
    if button.disabled:
        return _fail("O3 required button is unexpectedly disabled: %s" % node_name)
    button.emit_signal("pressed")
    await process_frame
    return true

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O3 could not load landscape entry scene.")
    ui = scene.instantiate() as Control
    if ui == null:
        return _fail("O3 could not instantiate landscape entry scene.")
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        return _fail("O3 scene returned no live SimulationState.")
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if runtime == null:
        return _fail("O3 scene returned no LiveGameRuntimeV2.")
    scheduler = runtime.scheduler()
    if scheduler == null:
        return _fail("O3 live runtime returned no scheduler.")
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
