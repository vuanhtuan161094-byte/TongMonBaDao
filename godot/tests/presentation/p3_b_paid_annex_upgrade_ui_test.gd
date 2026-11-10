extends SceneTree

# Real player-paid second annex upgrade: exact stock debit, proper instance,
# timed level-up and two cold SaveService loads. No stock or stone grants.
const SAVE_PATH := "user://p3_b_paid_annex_upgrade_ui_test.json"
var ui: Control
var state: SimulationState
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for item in [
        [BuildingSystem.TYPE_MINE,SectMapPresentation.DEST_MINE],
        [BuildingSystem.TYPE_LINH_FOREST,SectMapPresentation.DEST_LINH_FOREST],
        [BuildingSystem.TYPE_SPIRIT_FIELD,SectMapPresentation.DEST_SPIRIT_FIELD]
    ]:
        if not await _case(StringName(item[0]),StringName(item[1])):
            return
    _cleanup()
    print("GATE B PAID MINE FOREST FIELD 002 UPGRADE, COST, TICK, COLD SAVE PASS")
    quit(0)

func _case(kind: StringName,dest: StringName) -> bool:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        return _fail("scene missing")
    ui = packed.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not bool(ui.get("runtime_ready")):
        return _fail("New Game runtime missing")
    _stop_timers(ui)
    var primary := buildings.primary_building(state,kind)
    if primary == null or primary.level != 1:
        return _fail("starter building missing: "+str(kind))
    ui.call("_open_building",dest)
    await process_frame
    var buy := ui.find_child("V57BuildProducer_%s" % str(kind),true,false) as Button
    var preview := buildings.preview_production_annex(state,kind)
    if buy == null or buy.disabled or not bool(preview.get("ok",false)):
        return _fail("annex not payable in real starter economy: "+str(kind)+" "+str(preview))
    var buy_cost: Dictionary = preview["cost"]
    var stones := state.sect.spirit_stones
    var wood := warehouse.quantity(state,&"linh_moc")
    var ore := warehouse.quantity(state,&"thanh_thiet")
    buy.pressed.emit()
    await process_frame
    var second_id := StringName("%s_002" % str(kind))
    var second: BuildingState = state.buildings.get(str(second_id)) as BuildingState
    if second == null or second.id == primary.id or (
        state.sect.spirit_stones != stones-int(buy_cost.get("spirit_stones",0))
        or warehouse.quantity(state,&"linh_moc") != wood-int(buy_cost.get("linh_moc",0))
        or warehouse.quantity(state,&"thanh_thiet") != ore-int(buy_cost.get("thanh_thiet",0))
    ):
        return _fail("paid annex cost/id mismatch: "+str(kind))
    ui.call("_open_building",dest,second_id)
    await process_frame
    var selected := StringName(ui.get("selected_production_instance_id"))
    var button_name := "Upgrade_mine" if kind == BuildingSystem.TYPE_MINE else "Upgrade_%s" % str(second_id)
    var upgrade := ui.find_child(button_name,true,false) as Button
    var can_upgrade := buildings.can_start_upgrade(state,second_id)
    if selected != second_id or upgrade == null or upgrade.disabled or not bool(can_upgrade.get("ok",false)):
        return _fail("selected paid upgrade unavailable: "+str(second_id)+" "+str(can_upgrade))
    var cost: Dictionary = buildings.upgrade_cost(second)
    stones = state.sect.spirit_stones
    wood = warehouse.quantity(state,&"linh_moc")
    ore = warehouse.quantity(state,&"thanh_thiet")
    upgrade.pressed.emit()
    await process_frame
    await process_frame
    if not second.is_upgrading() or second.level != 1 or primary.level != 1 or (
        second.upgrade_target_level != 2
        or state.sect.spirit_stones != stones-int(cost.get("spirit_stones",0))
        or warehouse.quantity(state,&"linh_moc") != wood-int(cost.get("linh_moc",0))
        or warehouse.quantity(state,&"thanh_thiet") != ore-int(cost.get("thanh_thiet",0))
    ):
        return _fail("wrong building level or upgrade charge: "+str(second_id))
    stones = state.sect.spirit_stones
    wood = warehouse.quantity(state,&"linh_moc")
    ore = warehouse.quantity(state,&"thanh_thiet")
    if bool(buildings.start_upgrade(state,second_id).get("ok",false)) or (
        state.sect.spirit_stones != stones or warehouse.quantity(state,&"linh_moc") != wood
        or warehouse.quantity(state,&"thanh_thiet") != ore
    ):
        return _fail("replay double-charged pending upgrade: "+str(second_id))
    var barrier: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not bool(barrier.get("ok",false)):
        return _fail("canonical SaveService barrier failed: "+str(second_id))
    var cold := SaveService.new().load_from_path(SAVE_PATH)
    if cold == null or not cold.buildings.has(str(second_id)):
        return _fail("cold Save missing paid site: "+str(second_id))
    var loaded: BuildingState = cold.buildings[str(second_id)]
    var original: BuildingState = cold.buildings[str(primary.id)]
    if not loaded.is_upgrading() or loaded.level != 1 or original.level != 1 or (
        loaded.upgrade_target_level != 2 or cold.sect.spirit_stones != stones
        or warehouse.quantity(cold,&"linh_moc") != wood or warehouse.quantity(cold,&"thanh_thiet") != ore
    ):
        return _fail("cold Save altered pending cost/upgrade: "+str(second_id))
    var ticks := ceili(loaded.upgrade_required_work)
    if ticks <= 0 or ticks > 100:
        return _fail("invalid paid upgrade duration: "+str(second_id))
    for _tick in range(ticks+1):
        cold.tick += 1
        buildings.process_tick(cold)
    if loaded.level != 2 or loaded.is_upgrading() or original.level != 1 or (
        int(loaded.metrics.get("upgrade_completions",0)) != 1
        or cold.sect.spirit_stones != stones
        or warehouse.quantity(cold,&"linh_moc") != wood or warehouse.quantity(cold,&"thanh_thiet") != ore
    ):
        return _fail("timer/ledger/instance mismatch after paid upgrade: "+str(second_id))
    if SaveService.new().save_to_path(cold,SAVE_PATH) != OK:
        return _fail("post-upgrade SaveService failed: "+str(second_id))
    var reloaded := SaveService.new().load_from_path(SAVE_PATH)
    if reloaded == null or not reloaded.buildings.has(str(second_id)) or (
        (reloaded.buildings[str(second_id)] as BuildingState).level != 2
        or (reloaded.buildings[str(primary.id)] as BuildingState).level != 1
        or reloaded.sect.spirit_stones != stones
    ):
        return _fail("post-upgrade cold Save lost paid result: "+str(second_id))
    ui.set("runtime_ready",false)
    ui.queue_free()
    await process_frame
    ui = null
    state = null
    return true

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

func _fail(message: String) -> bool:
    push_error("GATE B 002 UPGRADES: "+message)
    if ui != null and is_instance_valid(ui):
        ui.set("runtime_ready",false)
        ui.queue_free()
    _cleanup()
    quit(1)
    return false
