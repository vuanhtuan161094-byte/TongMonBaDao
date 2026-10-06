extends SceneTree

const TEST_SEED := 370081
const SAVE_PATH := "user://p3_7b1_warehouse_test.json"

var warehouse := WarehouseSystem.new()
var registry := ResourceRegistry.new()
var buildings := BuildingSystem.new()
var equipment := EquipmentSystem.new()
var techniques := TechniqueSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_registry_identity_and_pham_luc():
        return
    if not _verify_p3_factory_uses_one_canonical_warehouse():
        return
    if not _verify_legacy_buckets_merge_once():
        return
    if not _verify_large_stack_reserve_and_lock():
        return
    if not _verify_building_consumes_canonical_warehouse():
        return
    if not _verify_forge_consumes_canonical_warehouse():
        return
    if not _verify_technique_materials_use_canonical_warehouse():
        return
    if not _verify_old_p3_save_auto_migrates_on_load():
        return
    if not _verify_p2_legacy_behavior_stays_isolated():
        return
    if not _verify_warehouse_save_load_exactness():
        return
    print("P3.7B1 RESOURCE REGISTRY + WAREHOUSE TEST PASS")
    _cleanup()
    quit(0)

func _verify_registry_identity_and_pham_luc() -> bool:
    var errors := registry.validate_definitions()
    if not errors.is_empty():
        return _fail("Resource registry definition failure: %s" % " | ".join(errors))
    if registry.display_name(&"thanh_thiet") != "Thanh Thiết":
        return _fail("Thanh Thiết lost explicit resource identity.")
    if registry.realm_grade(&"thanh_thiet") != ResourceRegistry.REALM_LUYEN_KHI:
        return _fail("Thanh Thiết realm grade is invalid.")
    if registry.realm_grade(&"huyen_thiet") != ResourceRegistry.REALM_TRUC_CO:
        return _fail("Huyền Thiết realm grade is invalid.")
    if registry.base_pham_luc(&"huyen_thiet") <= registry.base_pham_luc(&"thanh_thiet"):
        return _fail("Higher-grade mineral does not have higher stable Phẩm Lực.")
    if not registry.has_tag(&"linh_moc", ResourceRegistry.TAG_CONSTRUCTION_WOOD):
        return _fail("Linh Mộc is missing construction-wood identity.")
    if not registry.has_tag(&"thanh_thiet", ResourceRegistry.TAG_CONSTRUCTION_MINERAL):
        return _fail("Thanh Thiết is missing construction-mineral identity.")
    return true

func _verify_p3_factory_uses_one_canonical_warehouse() -> bool:
    var state := P37Factory.create_state(TEST_SEED)
    if not state.sect.p3_7_resources_enabled:
        return _fail("P37Factory did not enable canonical resource authority.")
    if not state.sect.forge_materials.is_empty() or not state.sect.technique_materials.is_empty():
        return _fail("P37Factory left duplicate legacy material stores populated.")
    if warehouse.quantity(state, &"linh_moc") < P37Factory.INITIAL_BUILD_WOOD:
        return _fail("Initial Linh Mộc did not migrate into canonical warehouse.")
    if warehouse.quantity(state, &"thanh_thiet") < P37Factory.INITIAL_BUILD_ORE:
        return _fail("Initial Thanh Thiết did not migrate into canonical warehouse.")
    return _validate(state)

func _verify_legacy_buckets_merge_once() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 1)
    state.sect.forge_materials["yeu_dan"] = 3
    state.sect.technique_materials["yeu_dan"] = 4
    BuildingSystem.new().initialize(state)
    warehouse.initialize(state)

    if warehouse.quantity(state, &"yeu_dan") != 7:
        return _fail("Legacy material buckets did not merge quantities exactly once.")
    if not state.sect.forge_materials.is_empty() or not state.sect.technique_materials.is_empty():
        return _fail("Legacy material buckets were not cleared after canonical migration.")

    var event_count := state.sect.warehouse_event_count
    warehouse.ensure_migrated(state)
    if warehouse.quantity(state, &"yeu_dan") != 7 or state.sect.warehouse_event_count != event_count:
        return _fail("Canonical migration ran twice and duplicated material value.")
    return _validate(state)

func _verify_large_stack_reserve_and_lock() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 2)
    var amount := 3_000_000
    if not warehouse.add(state, &"thanh_linh_thao", amount):
        return _fail("Warehouse rejected a normal multi-million resource stack.")
    if warehouse.quantity(state, &"thanh_linh_thao") != amount:
        return _fail("Multi-million resource stack quantity changed.")

    if not warehouse.set_rule(state, &"thanh_linh_thao", amount - 10, false):
        return _fail("Could not set warehouse reserve rule.")
    if warehouse.available_quantity(state, &"thanh_linh_thao") != 10:
        return _fail("Warehouse reserve minimum was not enforced.")
    if warehouse.consume(state, &"thanh_linh_thao", 11):
        return _fail("Warehouse consumed below the protected reserve.")
    if not warehouse.consume(state, &"thanh_linh_thao", 10):
        return _fail("Warehouse could not consume the exact unreserved quantity.")

    if not warehouse.set_rule(state, &"thanh_linh_thao", amount - 10, true):
        return _fail("Could not lock warehouse resource.")
    if warehouse.available_quantity(state, &"thanh_linh_thao") != 0:
        return _fail("Locked resource remained available to automatic consumers.")
    if warehouse.consume(state, &"thanh_linh_thao", 1):
        return _fail("Locked resource was consumed without explicit override.")
    return _validate(state)

func _verify_building_consumes_canonical_warehouse() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 3)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null:
        return _fail("Warehouse building probe has no Mine.")

    var wood_before := warehouse.quantity(state, &"linh_moc")
    var ore_before := warehouse.quantity(state, &"thanh_thiet")
    var cost := buildings.upgrade_cost(mine)

    warehouse.set_rule(state, &"linh_moc", 0, true)
    var blocked := buildings.can_start_upgrade(state, mine.id)
    if bool(blocked.get("ok", false)) or str(blocked.get("material_id", "")) != "linh_moc":
        return _fail("Building upgrade ignored warehouse lock rule.")

    warehouse.set_rule(state, &"linh_moc", 0, false)
    var started := buildings.start_upgrade(state, mine.id)
    if not bool(started.get("ok", false)):
        return _fail("Building upgrade could not consume canonical warehouse resources.")
    if warehouse.quantity(state, &"linh_moc") != wood_before - int(cost.get("linh_moc", 0)):
        return _fail("Building upgrade consumed wrong canonical Linh Mộc amount.")
    if warehouse.quantity(state, &"thanh_thiet") != ore_before - int(cost.get("thanh_thiet", 0)):
        return _fail("Building upgrade consumed wrong canonical Thanh Thiết amount.")
    if not state.sect.forge_materials.is_empty():
        return _fail("Building upgrade repopulated legacy forge_materials.")
    return _validate(state)

func _verify_forge_consumes_canonical_warehouse() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 4)
    var recipe_id := &"thanh_thiet_kiem"
    var recipe := equipment.recipe(recipe_id)
    var requirements: Dictionary = recipe.get("materials", {})
    if not equipment.can_craft(state, recipe_id):
        return _fail("Forge did not see materials in canonical warehouse.")

    var before: Dictionary = {}
    for raw_id in requirements.keys():
        before[str(raw_id)] = warehouse.quantity(state, StringName(raw_id))
    var item := equipment.craft(state, recipe_id, false)
    if item.is_empty():
        return _fail("Forge failed while canonical warehouse had sufficient materials.")
    for raw_id in requirements.keys():
        var resource_id := StringName(raw_id)
        if warehouse.quantity(state, resource_id) != int(before[str(raw_id)]) - int(requirements[raw_id]):
            return _fail("Forge consumed wrong canonical amount for %s." % resource_id)
    if not state.sect.forge_materials.is_empty():
        return _fail("Forge repopulated legacy material bucket under P3.7.")
    return _validate(state)

func _verify_technique_materials_use_canonical_warehouse() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 5)
    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        return _fail("Technique warehouse probe has no disciple.")
    var actor: DiscipleState = state.disciples[ids[0]]

    var before := warehouse.quantity(state, TechniqueSystem.MATERIAL_ESSENCE)
    actor.inventory[TechniqueSystem.MATERIAL_PREFIX + str(TechniqueSystem.MATERIAL_ESSENCE)] = 3
    var deposited := techniques.deposit_special_inventory(state, actor)
    if int(deposited.get("materials", 0)) != 3:
        return _fail("Technique loot did not deposit into canonical warehouse.")
    if warehouse.quantity(state, TechniqueSystem.MATERIAL_ESSENCE) != before + 3:
        return _fail("Technique material canonical quantity is wrong after deposit.")
    if not state.sect.technique_materials.is_empty():
        return _fail("Technique deposit repopulated legacy technique_materials.")

    actor.learned_techniques["duong_khi_quyet"] = {"level": 1, "xp": techniques.mastery_required(1)}
    var needed := int(techniques.upgrade_material_cost(&"duong_khi_quyet", 1).get(str(TechniqueSystem.MATERIAL_ESSENCE), 0))
    var before_upgrade := warehouse.quantity(state, TechniqueSystem.MATERIAL_ESSENCE)
    if before_upgrade < needed:
        warehouse.add(state, TechniqueSystem.MATERIAL_ESSENCE, needed - before_upgrade)
        before_upgrade = warehouse.quantity(state, TechniqueSystem.MATERIAL_ESSENCE)
    var upgraded := techniques.upgrade_technique(state, actor, &"duong_khi_quyet")
    if not bool(upgraded.get("ok", false)):
        return _fail("Technique upgrade could not consume canonical warehouse material.")
    if warehouse.quantity(state, TechniqueSystem.MATERIAL_ESSENCE) != before_upgrade - needed:
        return _fail("Technique upgrade consumed wrong canonical material amount.")
    return _validate(state)

func _verify_old_p3_save_auto_migrates_on_load() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 6)

    # Simulate an A1/A2-era save written before P3.7B1 existed.
    state.sect.p3_7_resources_enabled = false
    state.sect.warehouse_resources.clear()
    state.sect.warehouse_rules.clear()
    state.sect.warehouse_event_count = 0
    state.sect.forge_materials = {"linh_moc": 123, "yeu_dan": 2}
    state.sect.technique_materials = {"linh_tuy": 4, "yeu_dan": 3}

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        return _fail("Old-P3 warehouse migration save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("Old-P3 warehouse migration load failed.")
    if not loaded.sect.p3_7_resources_enabled:
        return _fail("Old P3.7 save was not upgraded to canonical warehouse authority.")
    if warehouse.quantity(loaded, &"linh_moc") != 123:
        return _fail("Old P3.7 Linh Mộc did not migrate exactly.")
    if warehouse.quantity(loaded, &"linh_tuy") != 4:
        return _fail("Old P3.7 Linh Tủy did not migrate exactly.")
    if warehouse.quantity(loaded, &"yeu_dan") != 5:
        return _fail("Overlapping old P3.7 Yêu Đan buckets did not merge exactly.")
    if not loaded.sect.forge_materials.is_empty() or not loaded.sect.technique_materials.is_empty():
        return _fail("Old P3.7 save retained duplicate legacy material buckets after load.")
    _cleanup()
    return _validate(loaded)

func _verify_p2_legacy_behavior_stays_isolated() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 7)
    if state.sect.p3_7_resources_enabled:
        return _fail("P2.12 unexpectedly enabled P3.7 canonical warehouse.")

    state.sect.forge_materials["thanh_thiet"] = 3
    state.sect.forge_materials["linh_moc"] = 1
    if not equipment.can_craft(state, &"thanh_thiet_kiem"):
        return _fail("P2 legacy forge no longer reads legacy forge_materials.")
    var item := equipment.craft(state, &"thanh_thiet_kiem", false)
    if item.is_empty():
        return _fail("P2 legacy forge behavior broke after P3.7 warehouse migration.")
    if not state.sect.warehouse_resources.is_empty():
        return _fail("P2 legacy forge leaked into P3.7 warehouse.")

    var ids: Array = state.disciples.keys()
    ids.sort()
    var actor: DiscipleState = state.disciples[ids[0]]
    actor.region_id = &"sect"
    actor.inventory[TechniqueSystem.MATERIAL_PREFIX + str(TechniqueSystem.MATERIAL_ESSENCE)] = 2
    techniques.deposit_special_inventory(state, actor)
    if int(state.sect.technique_materials.get(str(TechniqueSystem.MATERIAL_ESSENCE), 0)) != 2:
        return _fail("P2 legacy technique material deposit no longer uses legacy bucket.")
    if not state.sect.warehouse_resources.is_empty():
        return _fail("P2 legacy technique deposit leaked into P3.7 warehouse.")
    return true

func _verify_warehouse_save_load_exactness() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 8)
    warehouse.add(state, &"huyen_thiet", 5_000_000)
    warehouse.set_rule(state, &"huyen_thiet", 1_250_000, true)

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        return _fail("Canonical warehouse save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("Canonical warehouse load failed.")
    if state.to_dict() != loaded.to_dict():
        return _fail("Canonical warehouse exact save/load diverged.")
    if warehouse.quantity(loaded, &"huyen_thiet") != 5_000_000:
        return _fail("Large canonical stack changed after save/load.")
    var loaded_rule := warehouse.rule(loaded, &"huyen_thiet")
    if int(loaded_rule.get("reserve_min", 0)) != 1_250_000 or not bool(loaded_rule.get("locked", false)):
        return _fail("Warehouse reserve/lock rule changed after save/load.")
    _cleanup()
    return _validate(loaded)

func _validate(state: SimulationState) -> bool:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    errors.append_array(EquipmentSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    errors.append_array(TraitSystem.new().validate_invariants(state))
    errors.append_array(RootRefinementSystem.new().validate_invariants(state))
    errors.append_array(BloodlineSystem.new().validate_invariants(state))
    errors.append_array(PhysiqueSystem.new().validate_invariants(state))
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    if not errors.is_empty():
        return _fail("Invariant failure: %s" % " | ".join(errors))
    return true

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
