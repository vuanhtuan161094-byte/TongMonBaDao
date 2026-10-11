extends SceneTree

# O1: main landscape scene must project P3.7 stock/usable quantities.
# Real mining, craft, reserve/lock and disk reload; never seed a fake reward.
const SAVE_PATH := "user://p3_o1_canonical_warehouse_ui_test.json"
const RECIPE_ID := &"thanh_thiet_kiem"

var ui: Control
var state: SimulationState
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("O1 could not load landscape entry scene.")
        return
    ui = scene.instantiate() as Control
    if ui == null:
        _fail("O1 could not instantiate entry scene.")
        return
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not state.sect.p3_7_resources_enabled:
        _fail("O1 scene has no canonical P3.7 state.")
        return
    _stop_timers(ui)
    if not _check_opening_ui():
        return
    if not _check_real_mine_deposit():
        return
    if not _check_reserve_lock_craft_and_reload():
        return
    if not state.sect.forge_materials.is_empty() or not state.sect.technique_materials.is_empty():
        _fail("O1 created a second, legacy material authority.")
        return
    print("P3 O1 CANONICAL WAREHOUSE UI TEST PASS")
    ui.set("runtime_ready", false)
    ui.queue_free()
    await process_frame
    ui = null
    _cleanup_save()
    quit(0)

func _check_opening_ui() -> bool:
    var iron := warehouse.quantity(state, &"thanh_thiet")
    var wood := warehouse.quantity(state, &"linh_moc")
    if iron < P37Factory.INITIAL_BUILD_ORE or wood < P37Factory.INITIAL_BUILD_WOOD:
        return _fail("O1 opening starter materials missing from canonical Warehouse.")
    var label: Label = ui.get("resource_label") as Label
    if label == null or not label.text.contains("Thiết %d/%d" % [iron, iron]):
        return _fail("O1 top bar does not show truthful total/usable iron.")
    var legacy_detail := str(ui.call("_building_detail", SectMapPresentation.DEST_WAREHOUSE))
    if not legacy_detail.contains("Thanh Thiết: %d (dùng %d)" % [iron, iron]):
        return _fail("O1 base warehouse popup disagrees with WarehouseSystem.")
    var detail := str(ui.call("_warehouse_operation_text"))
    if not detail.contains("Thanh Thiết: %d (dùng %d)" % [iron, iron]):
        return _fail("O1 operations Warehouse panel disagrees with WarehouseSystem.")
    if not str(ui.call("_mine_operation_text")).contains("Thanh Thiết tồn (dùng): %d (dùng %d)" % [iron, iron]):
        return _fail("O1 Mine panel does not show truthful stock.")
    if not str(ui.call("_forge_operation_text")).contains("Thanh Thiết %d (dùng %d)" % [iron, iron]):
        return _fail("O1 Forge panel does not show truthful stock.")
    var preview := str(ui.call("_recipe_material_status", RECIPE_ID))
    if not preview.contains("Thanh Thiết tồn %d / dùng %d / cần 3" % [iron, iron]):
        return _fail("O1 recipe preview does not show canonical stock and need.")
    if not EquipmentSystem.new().can_craft(state, RECIPE_ID) or not preview.contains("Đủ nguyên liệu"):
        return _fail("O1 initial recipe preview disagrees with real can_craft.")
    return true

func _check_real_mine_deposit() -> bool:
    var mine := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null:
        return _fail("O1 canonical Mine is absent.")
    var active := BuildingSystem.new().active_worker_ids(state, mine)
    if active.is_empty():
        return _fail("O1 Mine has no real eligible worker.")
    var worker: DiscipleState = state.disciples[active[0]]
    worker.work_cycle_state.clear()
    worker.hp = worker.max_hp
    worker.stamina = 100.0
    var before := warehouse.quantity(state, &"thanh_thiet")
    var earned := false
    for _step in range(40):
        var outcome := workforce.perform_work(state, worker, WorkforceSystem.PROF_MINING)
        if not bool(outcome.get("ok", false)):
            return _fail("O1 real Mine work step failed: %s" % str(outcome))
        if bool(outcome.get("completed", false)):
            if str(outcome.get("deposited_to", "")) != "sect_main_warehouse":
                return _fail("O1 Mine reward was not deposited to Sect Warehouse.")
            earned = true
            break
    var after := warehouse.quantity(state, &"thanh_thiet")
    if not earned or after <= before:
        return _fail("O1 did not earn and deposit a real Mine output.")
    ui.call("_refresh_all")
    var label: Label = ui.get("resource_label") as Label
    if not label.text.contains("Thiết %d/%d" % [after, after]):
        return _fail("O1 UI did not refresh after actual Mine deposit.")
    if not str(ui.call("_mine_operation_text")).contains("Thanh Thiết tồn (dùng): %d (dùng %d)" % [after, after]):
        return _fail("O1 Mine panel stayed stale after actual output.")
    if not str(ui.call("_warehouse_operation_text")).contains("Thanh Thiết: %d (dùng %d)" % [after, after]):
        return _fail("O1 Warehouse panel stayed stale after actual output.")
    return true

func _check_reserve_lock_craft_and_reload() -> bool:
    var iron := warehouse.quantity(state, &"thanh_thiet")
    var wood := warehouse.quantity(state, &"linh_moc")
    var initial_equipment := state.sect.equipment_items.size()
    if not warehouse.set_rule(state, &"thanh_thiet", iron - 2, false):
        return _fail("O1 could not reserve canonical iron.")
    ui.call("_refresh_all")
    var preview := str(ui.call("_recipe_material_status", RECIPE_ID))
    if warehouse.available_quantity(state, &"thanh_thiet") != 2 or not preview.contains("Thanh Thiết tồn %d / dùng 2 / cần 3" % iron):
        return _fail("O1 reserved stock was not distinguished from usable stock.")
    if EquipmentSystem.new().can_craft(state, RECIPE_ID) or preview.contains("Đủ nguyên liệu"):
        return _fail("O1 preview bypassed the reserve rule.")
    ui.call("_craft_from_building", RECIPE_ID)
    if state.sect.equipment_items.size() != initial_equipment or warehouse.quantity(state, &"thanh_thiet") != iron:
        return _fail("O1 reserved material was consumed by a denied craft.")
    if not warehouse.set_rule(state, &"thanh_thiet", 0, false):
        return _fail("O1 could not release reserve.")
    if not EquipmentSystem.new().can_craft(state, RECIPE_ID):
        return _fail("O1 real equipment authority rejected an eligible recipe.")
    ui.call("_craft_from_building", RECIPE_ID)
    if warehouse.quantity(state, &"thanh_thiet") != iron - 3 or warehouse.quantity(state, &"linh_moc") != wood - 1:
        return _fail("O1 real craft did not consume the exact Warehouse requirement.")
    if state.sect.equipment_items.size() != initial_equipment + 1:
        return _fail("O1 craft did not create exactly one equipment item.")
    var remainder := iron - 3
    if not warehouse.set_rule(state, &"thanh_thiet", 0, true):
        return _fail("O1 could not lock remaining iron.")
    ui.call("_refresh_all")
    var label: Label = ui.get("resource_label") as Label
    if not label.text.contains("Thiết %d/0" % remainder):
        return _fail("O1 top bar did not show locked inventory as unusable.")
    if not str(ui.call("_warehouse_operation_text")).contains("Thanh Thiết: %d (dùng 0)" % remainder):
        return _fail("O1 warehouse panel did not show resource lock.")
    var locked_preview := str(ui.call("_recipe_material_status", RECIPE_ID))
    if not locked_preview.contains("Thanh Thiết tồn %d / dùng 0 / cần 3" % remainder):
        return _fail("O1 locked recipe preview does not agree with can_craft.")
    ui.call("_craft_from_building", RECIPE_ID)
    if warehouse.quantity(state, &"thanh_thiet") != remainder or state.sect.equipment_items.size() != initial_equipment + 1:
        return _fail("O1 locked material craft changed real state.")
    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        return _fail("O1 could not save warehouse and equipment state.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("O1 could not reload canonical Warehouse.")
    if warehouse.quantity(loaded, &"thanh_thiet") != remainder or warehouse.available_quantity(loaded, &"thanh_thiet") != 0:
        return _fail("O1 lock/stock did not persist exactly.")
    if loaded.sect.equipment_items.size() != initial_equipment + 1:
        return _fail("O1 crafted equipment duplicated or vanished on reload.")
    if not loaded.sect.forge_materials.is_empty() or not loaded.sect.technique_materials.is_empty():
        return _fail("O1 save reload reintroduced legacy duplicate stock.")
    state = loaded
    ui.set("state", loaded)
    ui.call("_refresh_all")
    if not (ui.get("resource_label") as Label).text.contains("Thiết %d/0" % remainder):
        return _fail("O1 UI does not reflect persisted Warehouse after reload.")
    var errors := loaded.validate_invariants()
    if not errors.is_empty():
        return _fail("O1 reloaded state violates invariants: %s" % " | ".join(errors))
    return true

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
    if ui != null:
        ui.set("runtime_ready", false)
        ui.queue_free()
    _cleanup_save()
    quit(1)
    return false
