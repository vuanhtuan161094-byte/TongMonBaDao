extends SceneTree

# O9 M2 integration rehearsal:
# fresh P3.2 -> real Mine + Linh Lam provenance -> one shared Forge craft ->
# real Field herb -> timed Alchemy -> save/reload with Mine + Forest + Field +
# Alchemy simultaneously active -> exact-once resume -> real pill use ->
# autonomous repeat. No test-only payout path is used.
const SAVE_PATH := "user://p3_o9_m2_production_rehearsal_test.json"
const RECIPE_ID := &"thanh_thiet_kiem"

var ui: Control
var state: SimulationState
var scheduler: SimulationScheduler
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var equipment_system := EquipmentSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var hall := buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if mine == null or forest == null or field == null or hall == null:
        _fail("O9 fresh runtime is missing one or more M2 production buildings.")
        return

    var starter_iron := warehouse.quantity(state, &"thanh_thiet")
    var starter_wood := warehouse.quantity(state, &"linh_moc")
    if starter_iron < 40 or starter_wood < 40:
        _fail("O9 fresh canonical starter material baseline is missing.")
        return
    if not warehouse.set_rule(state, &"thanh_thiet", starter_iron, false):
        _fail("O9 could not reserve starter Thanh Thiet.")
        return
    if not warehouse.set_rule(state, &"linh_moc", starter_wood, false):
        _fail("O9 could not reserve starter Linh Moc.")
        return
    if warehouse.available_quantity(state, &"thanh_thiet") != 0 or warehouse.available_quantity(state, &"linh_moc") != 0:
        _fail("O9 provenance floors did not isolate newly produced ore/wood.")
        return

    var miner_id := _first_group_member(&"mining_crew")
    var forest_worker_id := _first_group_member(&"forge_hall")
    var field_worker_id := _first_unassigned()
    if miner_id == &"" or forest_worker_id == &"" or field_worker_id == &"":
        _fail("O9 fresh roster cannot allocate Mine, Forest and Field workers.")
        return

    if not await _open_building(SectMapPresentation.DEST_LINH_FOREST):
        return
    if not await _press("Group_forestry_crew_%s" % str(forest_worker_id)):
        return

    if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if not await _press("FieldGroup_%s" % str(field_worker_id)):
        return

    var alchemist_id := _first_unassigned()
    if alchemist_id == &"" or alchemist_id == field_worker_id:
        _fail("O9 fresh roster has no distinct fourth worker for Alchemy.")
        return
    if not await _open_building(SectMapPresentation.DEST_ALCHEMY_HALL):
        return
    if not await _press("Group_alchemy_crew_%s" % str(alchemist_id)):
        return

    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if bool(hall.production_state.get("recipe_enabled", true)):
        if not await _press("AlchemyRecipeToggle"):
            return
    if bool(hall.production_state.get("recipe_enabled", true)):
        _fail("O9 could not disable standing Alchemy during setup.")
        return

    for raw_id in state.disciples.keys():
        var id := StringName(raw_id)
        if not workforce.issue_command(state, id, WorkforceSystem.COMMAND_HOLD, "", 2000):
            _fail("O9 could not isolate disciple %s." % str(id))
            return

    if not await _complete_explicit_batch(SectMapPresentation.DEST_MINE, "Work_mining_%s" % str(miner_id), miner_id, mine, &"thanh_thiet", 1):
        return
    if not await _complete_explicit_batch(SectMapPresentation.DEST_MINE, "Work_mining_%s" % str(miner_id), miner_id, mine, &"thanh_thiet", 2):
        return
    if not await _complete_explicit_batch(SectMapPresentation.DEST_LINH_FOREST, "Work_forestry_%s" % str(forest_worker_id), forest_worker_id, forest, &"linh_moc", 1):
        return

    if warehouse.available_quantity(state, &"thanh_thiet") != 4:
        _fail("O9 two real Mine cycles must expose exactly 4 newly produced ore.")
        return
    if warehouse.available_quantity(state, &"linh_moc") != 2:
        _fail("O9 one real Forest cycle must expose exactly 2 newly produced wood.")
        return

    if not await _open_building(SectMapPresentation.DEST_FORGE):
        return
    var craft := ui.find_child("Craft_%s" % str(RECIPE_ID), true, false) as Button
    if craft == null or craft.disabled:
        _fail("O9 newly produced Mine+Forest stock did not enable Thanh Thiet Kiem.")
        return
    var item_count_before := state.sect.equipment_items.size()
    var item_ids_before: Array[String] = []
    for raw_item_id in state.sect.equipment_items.keys():
        item_ids_before.append(str(raw_item_id))
    var iron_before_craft := warehouse.quantity(state, &"thanh_thiet")
    var wood_before_craft := warehouse.quantity(state, &"linh_moc")
    craft.emit_signal("pressed")
    await process_frame
    if warehouse.quantity(state, &"thanh_thiet") != iron_before_craft - 3:
        _fail("O9 Forge did not consume exactly 3 newly produced Thanh Thiet.")
        return
    if warehouse.quantity(state, &"linh_moc") != wood_before_craft - 1:
        _fail("O9 Forge did not consume exactly 1 newly produced Linh Moc.")
        return
    if warehouse.quantity(state, &"thanh_thiet") < starter_iron or warehouse.quantity(state, &"linh_moc") < starter_wood:
        _fail("O9 Forge crossed a reserved starter-material floor.")
        return
    if state.sect.equipment_items.size() != item_count_before + 1:
        _fail("O9 shared Mine+Forest consumer did not create exactly one item.")
        return

    var crafted_item_id: StringName = &""
    for raw_item_id in state.sect.equipment_items.keys():
        var candidate_item: Dictionary = state.sect.equipment_items[str(raw_item_id)]
        if not item_ids_before.has(str(raw_item_id)) and str(candidate_item.get("recipe_id","")) == str(RECIPE_ID):
            crafted_item_id = StringName(raw_item_id)
            break
    if crafted_item_id == &"":
        _fail("O9 could not identify the unique item created by the real Forge transaction.")
        return
    var crafted_item: Dictionary = state.sect.equipment_items[str(crafted_item_id)]
    if StringName(crafted_item.get("location", "")) != EquipmentSystem.LOCATION_STORAGE:
        _fail("O9 Forge must put the real crafted item into Sect Warehouse.")
        return
    var buyer_id: StringName = &""
    var buyer_wallet := -1
    for raw_disciple_id in state.disciples.keys():
        var candidate_disciple: DiscipleState = state.disciples[raw_disciple_id]
        if candidate_disciple.wallet > buyer_wallet:
            buyer_id = candidate_disciple.id
            buyer_wallet = candidate_disciple.wallet
    if buyer_id == &"":
        _fail("O9 lacks a real disciple to receive Sect equipment.")
        return
    var buyer: DiscipleState = state.disciples[buyer_id]
    var buyer_wallet_before := buyer.wallet
    var treasury_before_purchase := state.sect.treasury
    # List the actual crafted Warehouse item and recall it through Warehouse UI.
    if not await _open_building(SectMapPresentation.DEST_WAREHOUSE):
        return
    var inventory_picker := ui.find_child("EquipmentInventoryItemPicker",true,false) as OptionButton
    var inventory_move := ui.find_child("EquipmentInventoryMove",true,false) as Button
    var inventory_option := -1
    if inventory_picker != null:
        for option_index in range(inventory_picker.item_count):
            if str(inventory_picker.get_item_metadata(option_index)) == str(crafted_item_id):
                inventory_option = option_index
                break
    if inventory_picker == null or inventory_move == null or inventory_option < 0:
        _fail("O9 Warehouse UI did not list the real forged item.")
        return
    inventory_picker.select(inventory_option)
    inventory_picker.emit_signal("item_selected",inventory_option)
    if inventory_move.disabled or inventory_move.text != "Đưa lên Phường Thị":
        _fail("O9 Warehouse item had no real list-to-shop action.")
        return
    var inventory_detail := ui.find_child("EquipmentInventoryItemDetail",true,false) as Label
    if inventory_detail == null or not inventory_detail.text.contains(str(crafted_item.get("price",0))):
        _fail("O9 Warehouse UI did not show the canonical listing price.")
        return
    inventory_move.emit_signal("pressed")
    inventory_move.emit_signal("pressed")
    await process_frame
    crafted_item = state.sect.equipment_items.get(str(crafted_item_id),{})
    if (
        StringName(crafted_item.get("location","")) != EquipmentSystem.LOCATION_SHOP
        or buyer.wallet != buyer_wallet_before
        or state.sect.treasury != treasury_before_purchase
        or state.sect.equipment_items.size() != item_count_before + 1
    ):
        _fail("O9 listing changed money or duplicated the forged item.")
        return

    # A shop listing cannot be received for free through the manual issue API.
    if equipment_system.manual_equip(state, buyer_id, crafted_item_id):
        _fail("O9 unpaid shop item was equipped directly.")
        return
    if buyer.wallet != buyer_wallet_before or state.sect.treasury != treasury_before_purchase:
        _fail("O9 rejected unpaid issue changed funds.")
        return

    inventory_picker = ui.find_child("EquipmentInventoryItemPicker",true,false) as OptionButton
    inventory_move = ui.find_child("EquipmentInventoryMove",true,false) as Button
    inventory_option = -1
    if inventory_picker != null:
        for option_index in range(inventory_picker.item_count):
            if str(inventory_picker.get_item_metadata(option_index)) == str(crafted_item_id):
                inventory_option = option_index
                break
    if inventory_picker == null or inventory_move == null or inventory_option < 0:
        _fail("O9 listed item disappeared from Warehouse controls before recall.")
        return
    inventory_picker.select(inventory_option)
    inventory_picker.emit_signal("item_selected",inventory_option)
    if inventory_move.disabled or inventory_move.text != "Thu hồi hàng chưa bán về Kho":
        _fail("O9 shop listing did not expose an unsold-item recall action.")
        return
    inventory_move.emit_signal("pressed")
    await process_frame
    crafted_item = state.sect.equipment_items.get(str(crafted_item_id),{})
    if (
        StringName(crafted_item.get("location","")) != EquipmentSystem.LOCATION_STORAGE
        or str(crafted_item.get("owner_id","")) != ""
        or state.sect.equipment_items.size() != item_count_before + 1
        or buyer.wallet != buyer_wallet_before
        or state.sect.treasury != treasury_before_purchase
    ):
        _fail("O9 recall did not return the same unsold item to Warehouse without payment.")
        return

    ui.call("_open_disciple_deep_screen",buyer_id,"Trang bị")
    await process_frame
    var weapon_picker := ui.find_child("EquipmentPicker_weapon",true,false) as OptionButton
    var equip_button := ui.find_child("EquipmentEquip_weapon",true,false) as Button
    if weapon_picker == null or equip_button == null:
        _fail("O9 live disciple profile did not expose the actual equipment controls.")
        return
    var crafted_option := -1
    for option_index in range(weapon_picker.item_count):
        if str(weapon_picker.get_item_metadata(option_index)) == str(crafted_item_id):
            crafted_option = option_index
            break
    if crafted_option < 0:
        _fail("O9 forged warehouse item is missing from the disciple's weapon picker.")
        return
    weapon_picker.select(crafted_option)
    weapon_picker.emit_signal("item_selected",crafted_option)
    if equip_button.disabled or equip_button.text != "Mặc":
        _fail("O9 warehouse item must be issued free, not purchased.")
        return
    equip_button.emit_signal("pressed")
    await process_frame
    var equipped_item: Dictionary = state.sect.equipment_items.get(str(crafted_item_id),{})
    if (
        StringName(equipped_item.get("location","")) != EquipmentSystem.LOCATION_EQUIPPED
        or str(equipped_item.get("owner_id","")) != str(buyer_id)
        or str(buyer.equipped_items.get(str(EquipmentSystem.SLOT_WEAPON),"")) != str(crafted_item_id)
        or buyer.wallet != buyer_wallet_before
        or state.sect.treasury != treasury_before_purchase
    ):
        _fail("O9 free warehouse issue changed funds or failed ownership.")
        return

    var purchase_wallet := buyer.wallet
    var purchase_treasury := state.sect.treasury
    # Warehouse issue locks the slot by default. Unlock, then relock.
    var slot_lock_button := ui.find_child("EquipmentAuto_weapon",true,false) as Button
    if slot_lock_button == null or slot_lock_button.text != "Mở tự động":
        _fail("O9 free warehouse issue did not lock the selected slot.")
        return
    slot_lock_button.emit_signal("pressed")
    await process_frame
    if bool(buyer.locked_equipment_slots.get(str(EquipmentSystem.SLOT_WEAPON),false)):
        _fail("O9 auto-policy action did not unlock the slot.")
        return
    slot_lock_button = ui.find_child("EquipmentAuto_weapon",true,false) as Button
    if slot_lock_button == null or slot_lock_button.text != "Khóa ô":
        _fail("O9 unlocked slot did not expose its relock action.")
        return
    slot_lock_button.emit_signal("pressed")
    await process_frame
    if not bool(buyer.locked_equipment_slots.get(str(EquipmentSystem.SLOT_WEAPON),false)):
        _fail("O9 player relock action failed.")
        return

    var unequip_button := ui.find_child("EquipmentUnequip_weapon",true,false) as Button
    if unequip_button == null or unequip_button.disabled:
        _fail("O9 equipped item did not expose unequip-to-storage.")
        return
    unequip_button.emit_signal("pressed")
    await process_frame
    equipped_item = state.sect.equipment_items.get(str(crafted_item_id),{})
    if (
        StringName(equipped_item.get("location","")) != EquipmentSystem.LOCATION_STORAGE
        or str(equipped_item.get("owner_id","")) != ""
        or buyer.equipped_items.has(str(EquipmentSystem.SLOT_WEAPON))
        or state.sect.equipment_items.size() != item_count_before + 1
    ):
        _fail("O9 unequip did not return the same unique item to storage.")
        return

    weapon_picker = ui.find_child("EquipmentPicker_weapon",true,false) as OptionButton
    equip_button = ui.find_child("EquipmentEquip_weapon",true,false) as Button
    var stored_option := -1
    if weapon_picker != null:
        for option_index in range(weapon_picker.item_count):
            if str(weapon_picker.get_item_metadata(option_index)) == str(crafted_item_id):
                stored_option = option_index
                break
    if weapon_picker == null or equip_button == null or stored_option < 0:
        _fail("O9 storage item did not return to the real equipment picker.")
        return
    weapon_picker.select(stored_option)
    weapon_picker.emit_signal("item_selected",stored_option)
    if equip_button.disabled or equip_button.text != "Mặc":
        _fail("O9 canonical storage item did not expose a no-cost manual equip action.")
        return
    equip_button.emit_signal("pressed")
    await process_frame
    equipped_item = state.sect.equipment_items.get(str(crafted_item_id),{})
    if (
        StringName(equipped_item.get("location","")) != EquipmentSystem.LOCATION_EQUIPPED
        or str(equipped_item.get("owner_id","")) != str(buyer_id)
        or str(buyer.equipped_items.get(str(EquipmentSystem.SLOT_WEAPON),"")) != str(crafted_item_id)
        or not bool(buyer.locked_equipment_slots.get(str(EquipmentSystem.SLOT_WEAPON),false))
        or buyer.wallet != purchase_wallet
        or state.sect.treasury != purchase_treasury
        or state.sect.equipment_items.size() != item_count_before + 1
    ):
        _fail("O9 storage re-equip changed funds, duplicated the item, or failed to lock ownership.")
        return

    if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if not await _press("FieldPlant_%s" % str(field_worker_id)):
        return
    var grain_before := warehouse.quantity(state, &"linh_coc")
    var herb_before := warehouse.quantity(state, &"thanh_linh_thao")
    for _i in range(100):
        scheduler.step()
        if warehouse.quantity(state, &"linh_coc") > grain_before:
            break
    if warehouse.quantity(state, &"linh_coc") <= grain_before:
        _fail("O9 real Field never completed its first crop.")
        return

    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if not buildings.disciple_has_active_spirit_plot(state, field_worker_id, field):
        if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
            return
        if not await _press("FieldPlant_%s" % str(field_worker_id)):
            return
    for _i in range(140):
        scheduler.step()
        if warehouse.quantity(state, &"thanh_linh_thao") >= herb_before + 3:
            break
    if warehouse.quantity(state, &"thanh_linh_thao") != herb_before + 3:
        _fail("O9 real Field did not produce the exact first 3-herb Alchemy input.")
        return

    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var active_plot := _plot_for_worker(field, field_worker_id)
    if active_plot.is_empty():
        if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
            return
        if not await _press("FieldPlant_%s" % str(field_worker_id)):
            return
        for _i in range(8):
            scheduler.step()
            active_plot = _plot_for_worker(field, field_worker_id)
            if not active_plot.is_empty():
                break
    if active_plot.is_empty():
        _fail("O9 could not arm a real Spirit Field plot for the save boundary.")
        return

    if not await _open_building(SectMapPresentation.DEST_MINE):
        return
    if not await _press("Work_mining_%s" % str(miner_id)):
        return
    if not await _open_building(SectMapPresentation.DEST_LINH_FOREST):
        return
    if not await _press("Work_forestry_%s" % str(forest_worker_id)):
        return
    for _i in range(12):
        scheduler.step()
        if not state.disciples[miner_id].work_cycle_state.is_empty() and not state.disciples[forest_worker_id].work_cycle_state.is_empty():
            break
    if state.disciples[miner_id].work_cycle_state.is_empty() or state.disciples[forest_worker_id].work_cycle_state.is_empty():
        _fail("O9 scheduler never reached simultaneous Mine and Forest carry cycles.")
        return

    # Re-check the Field after carry commands consumed real scheduler ticks.
    active_plot = _plot_for_worker(field, field_worker_id)
    if active_plot.is_empty():
        if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
            return
        if not await _press("FieldPlant_%s" % str(field_worker_id)):
            return
        for _i in range(6):
            scheduler.step()
            active_plot = _plot_for_worker(field, field_worker_id)
            if not active_plot.is_empty():
                break
    if active_plot.is_empty():
        _fail("O9 could not keep a real Spirit Field plot active beside carry cycles.")
        return
    if state.disciples[miner_id].work_cycle_state.is_empty() or state.disciples[forest_worker_id].work_cycle_state.is_empty():
        _fail("O9 carry cycles completed before Field could join the shared save boundary.")
        return

    if not await _open_building(SectMapPresentation.DEST_ALCHEMY_HALL):
        return
    if not await _press("AlchemyRecipeToggle"):
        return
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if not bool(hall.production_state.get("recipe_enabled", false)):
        _fail("O9 could not re-enable standing Alchemy.")
        return
    var herb_before_job := warehouse.quantity(state, &"thanh_linh_thao")
    var pill_before_job := warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID)
    if not await _press("Work_alchemy_%s" % str(alchemist_id)):
        return
    var jobs: Array = []
    for _i in range(4):
        scheduler.step()
        hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
        jobs = buildings.alchemy_jobs(state, hall)
        if not jobs.is_empty():
            break
    if jobs.size() != 1:
        _fail("O9 did not create exactly one timed Alchemy job before save.")
        return
    if warehouse.quantity(state, &"thanh_linh_thao") != herb_before_job - 3:
        _fail("O9 timed Alchemy did not commit exactly 3 herbs once.")
        return
    if warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != pill_before_job:
        _fail("O9 minted a pill before the timed job finished.")
        return
    if state.disciples[miner_id].work_cycle_state.is_empty() or state.disciples[forest_worker_id].work_cycle_state.is_empty():
        _fail("O9 carry-cycle work completed before the four-system save boundary.")
        return
    active_plot = _plot_for_worker(field, field_worker_id)
    if active_plot.is_empty():
        _fail("O9 Spirit Field plot completed before the four-system save boundary.")
        return

    var saved_tick := state.tick
    var saved_iron := warehouse.quantity(state, &"thanh_thiet")
    var saved_wood := warehouse.quantity(state, &"linh_moc")
    var saved_herb := warehouse.quantity(state, &"thanh_linh_thao")
    var saved_pill := warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID)
    var saved_items := state.sect.equipment_items.size()
    var saved_buyer_wallet: int = int(state.disciples[buyer_id].wallet)
    var saved_buyer_treasury := state.sect.treasury
    var saved_equipment_owner := str(state.sect.equipment_items[str(crafted_item_id)].get("owner_id",""))
    var saved_weapon_locked := bool(state.disciples[buyer_id].locked_equipment_slots.get(str(EquipmentSystem.SLOT_WEAPON),false))
    var saved_mine_cycle: Dictionary = state.disciples[miner_id].work_cycle_state.duplicate(true)
    var saved_forest_cycle: Dictionary = state.disciples[forest_worker_id].work_cycle_state.duplicate(true)
    var saved_plot: Dictionary = active_plot.duplicate(true)
    var saved_job: Dictionary = (jobs[0] as Dictionary).duplicate(true)
    var mine_batches_at_save := int(mine.metrics.get("production_batches", 0))
    var forest_batches_at_save := int(forest.metrics.get("production_batches", 0))
    var field_batches_at_save := int(field.metrics.get("production_batches", 0))
    var mine_units_at_save := int(mine.metrics.get("units_produced", 0))
    var forest_units_at_save := int(forest.metrics.get("units_produced", 0))
    var field_units_at_save := int(field.metrics.get("units_produced", 0))
    var saved_field_yield := int(saved_plot.get("routine_yield", 0))

    var active_save: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not bool(active_save.get("ok",false)):
        _fail("O9 canonical async SaveService barrier failed for active four-system state.")
        return
    if not FileAccess.file_exists(SAVE_PATH):
        _fail("O9 active four-system save was not written.")
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return

    mine = buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    forest = buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if state.tick != saved_tick:
        _fail("O9 reload changed the simulation tick before continuation.")
        return
    if (
        warehouse.quantity(state, &"thanh_thiet") != saved_iron
        or warehouse.quantity(state, &"linh_moc") != saved_wood
        or warehouse.quantity(state, &"thanh_linh_thao") != saved_herb
        or warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != saved_pill
        or state.sect.equipment_items.size() != saved_items
        or state.disciples[buyer_id].wallet != saved_buyer_wallet
        or state.sect.treasury != saved_buyer_treasury
        or str(state.sect.equipment_items.get(str(crafted_item_id),{}).get("location","")) != str(EquipmentSystem.LOCATION_EQUIPPED)
        or str(state.sect.equipment_items.get(str(crafted_item_id),{}).get("owner_id","")) != saved_equipment_owner
        or str(state.disciples[buyer_id].equipped_items.get(str(EquipmentSystem.SLOT_WEAPON),"")) != str(crafted_item_id)
        or bool(state.disciples[buyer_id].locked_equipment_slots.get(str(EquipmentSystem.SLOT_WEAPON),false)) != saved_weapon_locked
    ):
        _fail("O9 reload changed Warehouse/item/equipped ownership state before scheduler continuation.")
        return
    if not _same_cycle(saved_mine_cycle, state.disciples[miner_id].work_cycle_state):
        _fail("O9 reload lost/restarted the exact Mine carry cycle.")
        return
    if not _same_cycle(saved_forest_cycle, state.disciples[forest_worker_id].work_cycle_state):
        _fail("O9 reload lost/restarted the exact Forest carry cycle.")
        return
    var reloaded_plot := _plot_for_worker(field, field_worker_id)
    if not _same_plot(saved_plot, reloaded_plot):
        _fail("O9 reload lost/restarted the exact Spirit Field plot.")
        return
    jobs = buildings.alchemy_jobs(state, hall)
    if jobs.size() != 1 or not _same_job(saved_job, jobs[0]):
        _fail("O9 reload lost/restarted the exact timed Alchemy job.")
        return

    var mine_resumed := false
    var forest_resumed := false
    var field_resumed := false
    var alchemy_resumed := false
    for _i in range(320):
        scheduler.step()

        if not mine_resumed and int(mine.metrics.get("production_batches", 0)) > mine_batches_at_save:
            if int(mine.metrics.get("production_batches", 0)) != mine_batches_at_save + 1 or int(mine.metrics.get("units_produced", 0)) != mine_units_at_save + 2:
                _fail("O9 saved Mine cycle did not settle exactly once.")
                return
            mine_resumed = true

        if not forest_resumed and int(forest.metrics.get("production_batches", 0)) > forest_batches_at_save:
            if int(forest.metrics.get("production_batches", 0)) != forest_batches_at_save + 1 or int(forest.metrics.get("units_produced", 0)) != forest_units_at_save + 2:
                _fail("O9 saved Forest cycle did not settle exactly once.")
                return
            forest_resumed = true

        if not field_resumed and int(field.metrics.get("production_batches", 0)) > field_batches_at_save:
            if int(field.metrics.get("production_batches", 0)) != field_batches_at_save + 1 or int(field.metrics.get("units_produced", 0)) != field_units_at_save + saved_field_yield:
                _fail("O9 saved Spirit Field plot did not harvest its snapshotted yield exactly once.")
                return
            field_resumed = true

        if not alchemy_resumed and warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) > saved_pill:
            if warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != saved_pill + 1:
                _fail("O9 saved Alchemy job minted more than one pill at first completion.")
                return
            alchemy_resumed = true

        if mine_resumed and forest_resumed and field_resumed and alchemy_resumed:
            break

    if not mine_resumed or not forest_resumed or not field_resumed or not alchemy_resumed:
        _fail("O9 did not resume all four saved production states.")
        return

    var target: DiscipleState = state.disciples[field_worker_id]
    target.hp = maxf(1.0, target.max_hp - 60.0)
    var hp_before := target.hp
    var medicine_before := state.sect.medicine_stock
    var wallet_before := target.wallet
    var treasury_before := state.sect.treasury
    var pills_before_use := warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID)
    if pills_before_use <= 0:
        _fail("O9 resumed Alchemy left no canonical pill for Dược Phòng.")
        return
    if not await _open_building(SectMapPresentation.DEST_MEDICINE):
        return
    var use := ui.find_child("UsePill_%s" % str(target.id), true, false) as Button
    if use == null or use.disabled:
        _fail("O9 Dược Phòng exposes no enabled Hồi Xuân Đan action.")
        return
    use.emit_signal("pressed")
    await process_frame
    if not is_equal_approx(target.hp, minf(target.max_hp, hp_before + NeedsSystem.HEALING_PILL_HP)):
        _fail("O9 Hồi Xuân Đan did not heal exactly +55 HP capped.")
        return
    if warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != pills_before_use - 1:
        _fail("O9 Dược Phòng did not consume exactly one canonical pill.")
        return
    if state.sect.medicine_stock != medicine_before or target.wallet != wallet_before or state.sect.treasury != treasury_before:
        _fail("O9 pill use mutated legacy medicine or money authority.")
        return

    var mine_auto_base := int(mine.metrics.get("production_batches", 0))
    var forest_auto_base := int(forest.metrics.get("production_batches", 0))
    var field_auto_base := int(field.metrics.get("production_batches", 0))
    var mine_auto := false
    var forest_auto := false
    var field_auto := false
    var alchemy_auto := false
    for raw_job in buildings.alchemy_jobs(state, hall):
        if raw_job is Dictionary and str(raw_job.get("job_id", "")) != str(saved_job.get("job_id", "")):
            alchemy_auto = true

    for _i in range(520):
        scheduler.step()
        if int(mine.metrics.get("production_batches", 0)) > mine_auto_base:
            mine_auto = true
        if int(forest.metrics.get("production_batches", 0)) > forest_auto_base:
            forest_auto = true
        if int(field.metrics.get("production_batches", 0)) > field_auto_base:
            field_auto = true
        if not alchemy_auto:
            for raw_job in buildings.alchemy_jobs(state, hall):
                if raw_job is Dictionary and str(raw_job.get("job_id", "")) != str(saved_job.get("job_id", "")):
                    alchemy_auto = true
                    break
        if mine_auto and forest_auto and field_auto and alchemy_auto:
            break

    if not mine_auto or not forest_auto or not field_auto or not alchemy_auto:
        _fail("O9 autonomous repeat did not cover Mine + Forest + Field + standing Alchemy.")
        return

    ui.call("_refresh_all")
    var warehouse_text := str(ui.call("_warehouse_operation_text"))
    for token in ["Thanh Thiết", "Linh Mộc", "Thanh Linh Thảo", "Hồi Xuân Đan"]:
        if not warehouse_text.contains(token):
            # GP-PLAY01/G0: retain the strict O9 failure, but distinguish a
            # genuinely lost source from zero stock consumed by standing
            # Alchemy and intentionally suppressed by the Warehouse UI.
            # Read-only diagnostics: no gameplay grants, timer or Save edits.
            var stock_diag: Dictionary = {}
            for item_id in [&"thanh_thiet",&"linh_moc",&"thanh_linh_thao",NeedsSystem.HEALING_PILL_ID]:
                stock_diag[str(item_id)] = {
                    "quantity":warehouse.quantity(state,item_id),
                    "available":warehouse.available_quantity(state,item_id),
                    "rule":warehouse.rule(state,item_id)
                }
            var plots_diag: Array = []
            var field_diag := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
            if field_diag != null:
                for raw_plot in buildings.spirit_field_plots(state,field_diag):
                    if raw_plot is Dictionary:
                        plots_diag.append({
                            "crop":str(raw_plot.get("crop_id","")),
                            "status":str(raw_plot.get("status","")),
                            "finish_tick":int(raw_plot.get("finish_tick",0)),
                            "quantity":int(raw_plot.get("routine_yield",0))
                        })
            var jobs_diag: Array = []
            var hall_diag := buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
            if hall_diag != null:
                for raw_job in buildings.alchemy_jobs(state,hall_diag):
                    if raw_job is Dictionary:
                        jobs_diag.append({
                            "recipe":str(raw_job.get("recipe_id","")),
                            "finish_tick":int(raw_job.get("finish_tick",0)),
                            "inputs":raw_job.get("inputs",{})
                        })
            print("GP_PLAY01_G0_O9_SOURCE_DIAG "+JSON.stringify({
                "tick":state.tick,"missing_ui_token":token,
                "actual_warehouse":stock_diag,"field_plots":plots_diag,
                "alchemy_jobs":jobs_diag,
                "warehouse_display":warehouse_text.left(2400)
            }))
            _fail("O9 Warehouse projection is missing %s." % token)
            return

    var final_tick := state.tick
    var final_iron := warehouse.quantity(state, &"thanh_thiet")
    var final_wood := warehouse.quantity(state, &"linh_moc")
    var final_herb := warehouse.quantity(state, &"thanh_linh_thao")
    var final_pill := warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID)
    var final_items := state.sect.equipment_items.size()
    var final_save: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not bool(final_save.get("ok",false)):
        _fail("O9 canonical async SaveService barrier failed before final reload.")
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return
    if (
        state.tick != final_tick
        or warehouse.quantity(state, &"thanh_thiet") != final_iron
        or warehouse.quantity(state, &"linh_moc") != final_wood
        or warehouse.quantity(state, &"thanh_linh_thao") != final_herb
        or warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != final_pill
        or state.sect.equipment_items.size() != final_items
    ):
        _fail("O9 final reload replayed or lost production/consumption state.")
        return
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    for raw_job in buildings.alchemy_jobs(state, hall):
        if raw_job is Dictionary and str(raw_job.get("job_id", "")) == str(saved_job.get("job_id", "")):
            _fail("O9 completed saved Alchemy job reappeared after final reload.")
            return

    var errors := state.validate_invariants()
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    if not errors.is_empty():
        _fail("O9 final M2 state violates invariants: %s" % " | ".join(errors))
        return

    print("P3 O9 M2 MULTI-PRODUCER REHEARSAL PASS")
    _dispose_scene()
    await process_frame
    _cleanup_save()
    quit(0)

func _complete_explicit_batch(destination: StringName, button_name: String, worker_id: StringName, building: BuildingState, resource_id: StringName, ordinal: int) -> bool:
    if not await _open_building(destination):
        return false
    if not await _press(button_name):
        return false
    var batches_before := int(building.metrics.get("production_batches", 0))
    var quantity_before := warehouse.quantity(state, resource_id)
    for _i in range(80):
        scheduler.step()
        if int(building.metrics.get("production_batches", 0)) > batches_before:
            break
    if int(building.metrics.get("production_batches", 0)) != batches_before + 1:
        return _fail("O9 explicit batch %d at %s did not complete exactly once." % [ordinal, str(destination)])
    if warehouse.quantity(state, resource_id) != quantity_before + 2:
        return _fail("O9 explicit batch %d at %s did not deposit exactly 2 canonical units." % [ordinal, str(destination)])
    if not workforce.issue_command(state, worker_id, WorkforceSystem.COMMAND_HOLD, "", 2000):
        return _fail("O9 could not hold %s after explicit provenance batch." % str(worker_id))
    return true

func _first_group_member(group_id: StringName) -> StringName:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id == &"sect" and disciple.work_group_id == group_id:
            return disciple.id
    return &""

func _first_unassigned() -> StringName:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id == &"sect" and disciple.work_group_id == &"":
            return disciple.id
    return &""

func _plot_for_worker(field: BuildingState, disciple_id: StringName) -> Dictionary:
    for raw_plot in buildings.spirit_field_plots(state, field):
        if raw_plot is Dictionary and StringName(raw_plot.get("status", "")) == BuildingSystem.PLOT_GROWING and str(raw_plot.get("assigned_worker_id", "")) == str(disciple_id):
            return (raw_plot as Dictionary).duplicate(true)
    return {}

func _same_cycle(expected: Dictionary, actual: Dictionary) -> bool:
    if expected.is_empty() or actual.is_empty():
        return false
    for key in ["profession_id", "building_id", "resource_id", "phase", "carried_units"]:
        if str(actual.get(key, "")) != str(expected.get(key, "")):
            return false
    return is_equal_approx(float(actual.get("progress", -1.0)), float(expected.get("progress", -2.0)))

func _same_plot(expected: Dictionary, actual: Dictionary) -> bool:
    if expected.is_empty() or actual.is_empty():
        return false
    for key in ["plot_id", "crop_id", "status", "started_tick", "finish_tick", "assigned_worker_id", "paid_spirit_stones", "routine_yield"]:
        if str(actual.get(key, "")) != str(expected.get(key, "")):
            return false
    return true

func _same_job(expected: Dictionary, actual_variant) -> bool:
    if not (actual_variant is Dictionary):
        return false
    var actual: Dictionary = actual_variant
    for key in ["job_id", "recipe_id", "worker_id", "started_tick", "finish_tick", "output_resource_id", "output_quantity"]:
        if str(actual.get(key, "")) != str(expected.get(key, "")):
            return false
    return actual.get("inputs", {}) == expected.get("inputs", {})

func _open_building(destination: StringName) -> bool:
    var hit := ui.find_child("BuildingHit_%s" % str(destination), true, false) as Button
    if hit == null:
        return _fail("O9 missing player-facing map hit target for %s." % str(destination))
    hit.emit_signal("pressed")
    await process_frame
    if StringName(ui.get("selected_building")) != destination:
        return _fail("O9 map click did not open %s." % str(destination))
    return true

func _press(node_name: String) -> bool:
    var button := ui.find_child(node_name, true, false) as Button
    if button == null:
        return _fail("O9 missing player-facing button: %s" % node_name)
    if button.disabled:
        return _fail("O9 required button is disabled: %s" % node_name)
    button.emit_signal("pressed")
    await process_frame
    return true

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O9 could not load P3.2 landscape main scene.")
    ui = scene.instantiate() as Control
    if ui == null:
        return _fail("O9 could not instantiate P3.2 landscape main scene.")
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        return _fail("O9 scene returned no live SimulationState.")
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if runtime == null:
        return _fail("O9 scene returned no LiveGameRuntimeV2.")
    scheduler = runtime.scheduler()
    if scheduler == null:
        return _fail("O9 runtime returned no scheduler.")
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
    for suffix in ["", ".tmp", ".bak"]:
        var path: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error(message)
    _dispose_scene()
    _cleanup_save()
    quit(1)
    return false
