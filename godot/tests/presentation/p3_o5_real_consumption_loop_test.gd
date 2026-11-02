extends SceneTree

# O5: real produced-resource consumption through the actual Mine/Forge panels,
# plus the already-authored timed Mine upgrade. Starter iron is reserved as a
# provenance boundary: only ore produced by Mine may be spent in this test.
const SAVE_PATH := "user://p3_o5_real_consumption_loop_test.json"
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

    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null:
        _fail("O5 live scene has no authoritative Mine.")
        return
    var active := buildings.active_worker_ids(state, mine)
    if active.is_empty():
        _fail("O5 fresh Mine has no active worker.")
        return
    var miner_id := active[0]
    var miner: DiscipleState = state.disciples[miner_id]

    # Freeze unrelated actors through canonical HOLD so only this Mine can
    # change Thanh Thiết during the provenance proof.
    for raw_id in state.disciples.keys():
        var id := StringName(raw_id)
        if id == miner_id:
            continue
        if not workforce.issue_command(state, id, WorkforceSystem.COMMAND_HOLD, "", 500):
            _fail("O5 could not HOLD unrelated disciple %s." % str(id))
            return

    var starter_iron := warehouse.quantity(state, &"thanh_thiet")
    var starter_wood := warehouse.quantity(state, &"linh_moc")
    var starter_stones := state.sect.spirit_stones
    var starter_items := state.sect.equipment_items.size()
    if starter_iron < 40 or starter_wood < 40:
        _fail("O5 fresh starter Warehouse baseline is missing.")
        return

    # This is a QA provenance boundary, not a production grant: reserve every
    # starter iron unit. Only future Mine output becomes spendable.
    if not warehouse.set_rule(state, &"thanh_thiet", starter_iron, false):
        _fail("O5 could not reserve starter iron for provenance isolation.")
        return
    if warehouse.available_quantity(state, &"thanh_thiet") != 0:
        _fail("O5 starter iron reserve did not isolate spendable ore.")
        return

    # Actual Forge UI must deny the recipe before any produced iron exists.
    ui.call("_open_building", SectMapPresentation.DEST_FORGE)
    await process_frame
    var craft := ui.find_child("Craft_%s" % str(RECIPE_ID), true, false) as Button
    if craft == null or not craft.disabled:
        _fail("O5 Forge UI did not deny craft while all starter iron is reserved.")
        return
    if equipment.can_craft(state, RECIPE_ID):
        _fail("O5 backend bypassed the starter-iron reserve.")
        return

    # Produce two real Lv1 Mine batches through the player-facing Mine button.
    for batch in range(2):
        if not await _mine_one_batch(miner_id, mine, batch + 1):
            return
    var after_two_batches := warehouse.quantity(state, &"thanh_thiet")
    var produced_for_craft := after_two_batches - starter_iron
    if produced_for_craft < 3:
        _fail("O5 Mine did not generate enough isolated ore for the recipe.")
        return
    if warehouse.available_quantity(state, &"thanh_thiet") != produced_for_craft:
        _fail("O5 spendable ore is not exactly the produced amount above reserve.")
        return

    # Lock denial must also be visible in the real Forge panel even though
    # enough produced ore now exists.
    if not warehouse.set_rule(state, &"thanh_thiet", starter_iron, true):
        _fail("O5 could not lock produced iron for denial probe.")
        return
    ui.call("_open_building", SectMapPresentation.DEST_FORGE)
    await process_frame
    craft = ui.find_child("Craft_%s" % str(RECIPE_ID), true, false) as Button
    if craft == null or not craft.disabled or equipment.can_craft(state, RECIPE_ID):
        _fail("O5 lock did not block an otherwise eligible Forge recipe.")
        return
    if not warehouse.set_rule(state, &"thanh_thiet", starter_iron, false):
        _fail("O5 could not unlock produced iron.")
        return

    # Press the actual craft button. Exactly 3 of the newly mined ore and 1
    # Linh Mộc must be consumed; exactly one storage item must be created.
    ui.call("_open_building", SectMapPresentation.DEST_FORGE)
    await process_frame
    craft = ui.find_child("Craft_%s" % str(RECIPE_ID), true, false) as Button
    if craft == null or craft.disabled:
        _fail("O5 Forge UI stayed disabled after legitimate produced ore became usable.")
        return
    var iron_before_craft := warehouse.quantity(state, &"thanh_thiet")
    var wood_before_craft := warehouse.quantity(state, &"linh_moc")
    craft.emit_signal("pressed")
    await process_frame

    if warehouse.quantity(state, &"thanh_thiet") != iron_before_craft - 3:
        _fail("O5 craft did not consume exactly 3 produced Thanh Thiết.")
        return
    if warehouse.quantity(state, &"linh_moc") != wood_before_craft - 1:
        _fail("O5 craft did not consume exactly 1 Linh Mộc.")
        return
    if warehouse.quantity(state, &"thanh_thiet") < starter_iron:
        _fail("O5 craft consumed reserved starter iron instead of produced ore.")
        return
    if state.sect.equipment_items.size() != starter_items + 1:
        _fail("O5 craft did not create exactly one equipment item.")
        return

    var crafted_id := &""
    for raw_id in state.sect.equipment_items.keys():
        var item: Dictionary = state.sect.equipment_items[raw_id]
        if (
            str(item.get("recipe_id", "")) == str(RECIPE_ID)
            and StringName(item.get("location", "")) == EquipmentSystem.LOCATION_STORAGE
        ):
            crafted_id = StringName(raw_id)
    if crafted_id == &"":
        _fail("O5 player craft did not create Thanh Thiết Kiếm in Sect storage.")
        return

    # Immediate retry must be denied because only one produced iron remains.
    ui.call("_open_building", SectMapPresentation.DEST_FORGE)
    await process_frame
    craft = ui.find_child("Craft_%s" % str(RECIPE_ID), true, false) as Button
    var iron_after_craft := warehouse.quantity(state, &"thanh_thiet")
    if craft == null or not craft.disabled:
        _fail("O5 immediate retry was not denied by the Forge UI.")
        return
    if state.sect.equipment_items.size() != starter_items + 1 or warehouse.quantity(state, &"thanh_thiet") != iron_after_craft:
        _fail("O5 denied retry changed item or resource state.")
        return

    # Mine three more legitimate batches. With the starter reserve still intact
    # this creates exactly enough spendable ore for the authored Lv1->2 Mine cost.
    for batch in range(3):
        if not await _mine_one_batch(miner_id, mine, batch + 3):
            return

    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    var upgrade := ui.find_child("Upgrade_mine", true, false) as Button
    if upgrade == null:
        _fail("O5 Mine panel has no real upgrade control.")
        return
    var cost := buildings.upgrade_cost(mine)
    var ore_need := int(cost.get(BuildingSystem.MATERIAL_ORE, 0))
    var wood_need := int(cost.get(BuildingSystem.MATERIAL_WOOD, 0))
    var stone_need := int(cost.get("spirit_stones", 0))
    if not bool(buildings.can_start_upgrade(state, mine.id).get("ok", false)) or upgrade.disabled:
        _fail("O5 authored fresh Mine upgrade is not legitimately affordable after real production.")
        return
    if warehouse.available_quantity(state, &"thanh_thiet") < ore_need:
        _fail("O5 produced ore did not fund the authored Mine upgrade.")
        return

    # Stop mining while timed upgrade advances.
    if not workforce.issue_command(state, miner_id, WorkforceSystem.COMMAND_HOLD, "", 500):
        _fail("O5 could not HOLD miner before upgrade.")
        return

    var iron_before_upgrade := warehouse.quantity(state, &"thanh_thiet")
    var wood_before_upgrade := warehouse.quantity(state, &"linh_moc")
    var stones_before_upgrade := state.sect.spirit_stones
    upgrade.emit_signal("pressed")
    await process_frame

    if not mine.is_upgrading() or mine.upgrade_target_level != 2:
        _fail("O5 Mine upgrade button did not start the authoritative timed upgrade.")
        return
    if warehouse.quantity(state, &"thanh_thiet") != iron_before_upgrade - ore_need:
        _fail("O5 Mine upgrade did not consume exact Thanh Thiết cost.")
        return
    if warehouse.quantity(state, &"linh_moc") != wood_before_upgrade - wood_need:
        _fail("O5 Mine upgrade did not consume exact Linh Mộc cost.")
        return
    if state.sect.spirit_stones != stones_before_upgrade - stone_need:
        _fail("O5 Mine upgrade did not consume exact Spirit Stone cost.")
        return
    if warehouse.quantity(state, &"thanh_thiet") < starter_iron:
        _fail("O5 Mine upgrade crossed the reserved starter-iron floor.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    var retry_upgrade := ui.find_child("Upgrade_mine", true, false) as Button
    if retry_upgrade == null or not retry_upgrade.disabled:
        _fail("O5 UI allows duplicate Mine upgrade while one is active.")
        return
    var duplicate := buildings.start_upgrade(state, mine.id)
    if bool(duplicate.get("ok", false)) or str(duplicate.get("reason", "")) != "already_upgrading":
        _fail("O5 backend accepted duplicate Mine upgrade.")
        return

    # Mid-upgrade persistence: progress survives, no cost is charged twice.
    scheduler.run_ticks(4)
    var mid_progress := mine.upgrade_progress
    if mid_progress <= 0.0 or not mine.is_upgrading():
        _fail("O5 timed Mine upgrade did not advance.")
        return
    var iron_paid := warehouse.quantity(state, &"thanh_thiet")
    var wood_paid := warehouse.quantity(state, &"linh_moc")
    var stones_paid := state.sect.spirit_stones
    var mid_upgrade_save: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not bool(mid_upgrade_save.get("ok",false)):
        _fail("O5 SaveService barrier failed before mid-upgrade reload: %s" % str(mid_upgrade_save))
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return

    mine = buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null or not mine.is_upgrading() or mine.upgrade_target_level != 2:
        _fail("O5 reload lost active Mine upgrade.")
        return
    if not is_equal_approx(mine.upgrade_progress, mid_progress):
        _fail("O5 reload restarted or altered Mine upgrade progress.")
        return
    if (
        warehouse.quantity(state, &"thanh_thiet") != iron_paid
        or warehouse.quantity(state, &"linh_moc") != wood_paid
        or state.sect.spirit_stones != stones_paid
    ):
        _fail("O5 reload charged Mine upgrade a second time.")
        return
    if not state.sect.equipment_items.has(str(crafted_id)):
        _fail("O5 reload lost the crafted equipment item.")
        return

    # Complete the real timer, then persist final level/item/stock exactly once.
    var completed := false
    for _i in range(40):
        scheduler.step()
        if mine.level == 2 and not mine.is_upgrading():
            completed = true
            break
    if not completed:
        _fail("O5 timed Mine upgrade did not complete.")
        return
    if warehouse.quantity(state, &"thanh_thiet") != iron_paid or state.sect.spirit_stones != stones_paid:
        _fail("O5 Mine upgrade completion charged resources again.")
        return

    var completed_upgrade_save: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not bool(completed_upgrade_save.get("ok",false)):
        _fail("O5 SaveService barrier failed before final reload: %s" % str(completed_upgrade_save))
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return
    mine = buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null or mine.level != 2 or mine.is_upgrading():
        _fail("O5 final reload did not preserve completed Mine Lv2.")
        return
    if state.sect.equipment_items.size() != starter_items + 1 or not state.sect.equipment_items.has(str(crafted_id)):
        _fail("O5 final reload duplicated or lost crafted equipment.")
        return
    if warehouse.quantity(state, &"thanh_thiet") != starter_iron:
        _fail("O5 conservation failed: five Mine batches minus craft/upgrade did not return to reserved starter iron.")
        return
    if warehouse.available_quantity(state, &"thanh_thiet") != 0:
        _fail("O5 final starter iron reserve was not preserved.")
        return

    var errors := state.validate_invariants()
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    if not errors.is_empty():
        _fail("O5 final state violates invariants: %s" % " | ".join(errors))
        return

    print("P3 O5 REAL PRODUCE-SPEND LOOP TEST PASS")
    _dispose_scene()
    await process_frame
    _cleanup_save()
    quit(0)

func _mine_one_batch(miner_id: StringName, mine: BuildingState, ordinal: int) -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    var button := ui.find_child("Work_mining_%s" % str(miner_id), true, false) as Button
    if button == null or button.disabled:
        return _fail("O5 batch %d has no enabled real Mine work button." % ordinal)

    var batches_before := int(mine.metrics.get("production_batches", 0))
    var ore_before := warehouse.quantity(state, &"thanh_thiet")
    button.emit_signal("pressed")
    await process_frame
    var miner: DiscipleState = state.disciples[miner_id]
    if workforce.command_kind(miner) != WorkforceSystem.COMMAND_WORK:
        return _fail("O5 batch %d did not issue canonical Mine work." % ordinal)

    for _i in range(48):
        scheduler.step()
        ui.call("_refresh_all")
        if int(mine.metrics.get("production_batches", 0)) > batches_before:
            break
    if int(mine.metrics.get("production_batches", 0)) != batches_before + 1:
        return _fail("O5 batch %d did not complete exactly one Mine production batch." % ordinal)
    var delta := warehouse.quantity(state, &"thanh_thiet") - ore_before
    if delta <= 0:
        return _fail("O5 batch %d produced no canonical Thanh Thiết." % ordinal)
    if workforce.command_kind(miner) != &"":
        return _fail("O5 batch %d left a stale Mine command." % ordinal)
    return true

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O5 could not load landscape entry scene.")
    ui = scene.instantiate() as Control
    if ui == null:
        return _fail("O5 could not instantiate landscape entry scene.")
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        return _fail("O5 scene returned no live SimulationState.")
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if runtime == null:
        return _fail("O5 scene returned no LiveGameRuntimeV2.")
    scheduler = runtime.scheduler()
    if scheduler == null:
        return _fail("O5 runtime returned no scheduler.")
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
