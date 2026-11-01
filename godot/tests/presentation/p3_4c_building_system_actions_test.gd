extends SceneTree

var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.4C could not load live map scene.")
        return

    ui = packed_scene.instantiate() as Control
    if ui == null:
        _fail("P3.4C could not instantiate live map scene.")
        return

    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null:
        _fail("P3.4C did not expose real SimulationState.")
        return

    var policy_ok: bool = await _verify_main_hall_policies()
    if not policy_ok:
        return

    var lodging_ok: bool = await _verify_lodging_expansion()
    if not lodging_ok:
        return

    var medicine_ok: bool = await _verify_medicine_priority()
    if not medicine_ok:
        return

    var craft_ok: bool = await _verify_real_forge_craft()
    if not craft_ok:
        return

    var missing_ok: bool = await _verify_missing_material_failure()
    if not missing_ok:
        return

    var warehouse_ok: bool = await _verify_warehouse_baseline_read_only()
    if not warehouse_ok:
        return

    print("P3.4C BUILDING SYSTEM ACTIONS TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _verify_main_hall_policies() -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_MAIN_HALL)
    await process_frame

    ui.call("_set_work_policy_from_building", WorkforceSystem.POLICY_PRODUCTION)
    await process_frame
    if state.sect.work_policy != WorkforceSystem.POLICY_PRODUCTION:
        return _fail("Main Hall did not mutate real workforce policy.")

    ui.call("_set_needs_priority_from_building", NeedsSystem.PRIORITY_MEDICINE)
    await process_frame
    if state.sect.needs_priority != NeedsSystem.PRIORITY_MEDICINE:
        return _fail("Main Hall did not mutate real needs priority.")

    ui.call("_set_equipment_policy_from_building", EquipmentSystem.POLICY_COMBAT)
    await process_frame
    if state.sect.equipment_policy != EquipmentSystem.POLICY_COMBAT:
        return _fail("Main Hall did not mutate real equipment policy.")

    return true

func _verify_lodging_expansion() -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_RESIDENCE)
    await process_frame

    if SectHallSystemV1.installed(state):
        # DD-02 replaces the old 8-supply perpetual +1 bed with a canonical
        # Residence BuildingState; legacy saves retain the old contract.
        var before_supply := state.sect.supply_stock
        var before_beds := SectResidenceSystemV1.total_beds(state)
        if NeedsSystem.new().expand_lodging(state, 1):
            return _fail("Hall V2 still permits legacy +1 lodging exploit.")
        if state.sect.supply_stock != before_supply or SectResidenceSystemV1.total_beds(state) != before_beds:
            return _fail("Blocked legacy expansion changed authoritative state.")
        ui.call("_open_dai_dien_housing_v1")
        await process_frame
        var housing := ui.get_node_or_null("DaiDienScreenV1") as DaiDienScreenV1
        if housing == null or housing.active_tab != 5:
            return _fail("Residence map button did not open real Hall housing UI.")
        housing._close()
        await process_frame
        return true

    state.sect.supply_stock = 24
    var before_supply := state.sect.supply_stock
    var before_capacity := state.sect.lodging_capacity
    var before_expansions := int(state.sect.needs_stats.get("lodging_expansions", 0))

    ui.call("_expand_lodging_from_building")
    await process_frame

    if state.sect.supply_stock != before_supply - NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT:
        return _fail("Residence expansion did not consume the real supply cost.")
    if state.sect.lodging_capacity != before_capacity + 1:
        return _fail("Residence expansion did not increase real lodging capacity.")
    if int(state.sect.needs_stats.get("lodging_expansions", 0)) != before_expansions + 1:
        return _fail("Residence expansion did not update real needs statistics.")

    return true

func _verify_medicine_priority() -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_MEDICINE)
    await process_frame

    ui.call("_set_needs_priority_from_building", NeedsSystem.PRIORITY_SUPPLIES)
    await process_frame
    if state.sect.needs_priority != NeedsSystem.PRIORITY_SUPPLIES:
        return _fail("Medicine Hall did not mutate real logistics priority.")

    var controls := ui.get("building_management_container") as VBoxContainer
    if controls == null or controls.get_child_count() == 0:
        return _fail("Medicine Hall did not expose real priority controls.")

    return true

func _verify_real_forge_craft() -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_FORGE)
    await process_frame

    var recipe_id := &"thanh_thiet_kiem"
    var recipe := EquipmentSystem.new().recipe(recipe_id)
    var materials: Dictionary = recipe.get("materials", {})

    for material_id in EquipmentSystem.MATERIAL_NAMES.keys():
        state.sect.forge_materials[str(material_id)] = 0
    for raw_id in materials.keys():
        state.sect.forge_materials[str(raw_id)] = int(materials[raw_id])

    state.sect.forge_support_points = 1
    var before_items := state.sect.equipment_items.size()
    var before_index := state.sect.equipment_forge_index

    ui.call("_craft_from_building", recipe_id)
    await process_frame

    if state.sect.equipment_items.size() != before_items + 1:
        return _fail("Forge craft did not create a real equipment item.")
    if state.sect.equipment_forge_index != before_index + 1:
        return _fail("Forge craft did not advance the real forge index.")
    if state.sect.forge_support_points != 0:
        return _fail("Forge craft did not consume the real support point.")

    for raw_id in materials.keys():
        if int(state.sect.forge_materials.get(str(raw_id), -1)) != 0:
            return _fail("Forge craft did not consume recipe material %s." % str(raw_id))

    var item_id := "equip_%06d" % state.sect.equipment_forge_index
    if not state.sect.equipment_items.has(item_id):
        return _fail("Forge craft result is missing from real equipment_items.")
    var item: Dictionary = state.sect.equipment_items[item_id]
    if StringName(item.get("location", "")) != EquipmentSystem.LOCATION_STORAGE:
        return _fail("P3.4C manual craft must place the real item in storage.")

    return true

func _verify_missing_material_failure() -> bool:
    var recipe_id := &"hoa_van_ngoc"
    for material_id in EquipmentSystem.MATERIAL_NAMES.keys():
        state.sect.forge_materials[str(material_id)] = 0

    var before_items := state.sect.equipment_items.size()
    var before_index := state.sect.equipment_forge_index
    ui.call("_craft_from_building", recipe_id)
    await process_frame

    if state.sect.equipment_items.size() != before_items:
        return _fail("Forge created equipment despite missing materials.")
    if state.sect.equipment_forge_index != before_index:
        return _fail("Forge index changed despite failed craft.")

    var feedback := str(ui.get("building_management_feedback"))
    if not feedback.contains("Không đủ nguyên liệu"):
        return _fail("Forge missing-material failure was not explained to the player.")

    return true

func _verify_warehouse_baseline_read_only() -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_WAREHOUSE)
    await process_frame
    var controls := ui.get("building_management_container") as VBoxContainer
    if controls == null:
        return _fail("Warehouse building-management container is missing.")
    if controls.get_child_count() != 0:
        return _fail("P3.4C baseline unexpectedly added warehouse mutation controls.")
    return true

func _fail(message: String) -> bool:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
    return false
