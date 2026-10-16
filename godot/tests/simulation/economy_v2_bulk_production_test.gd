extends SceneTree

# ECON-V2 BULK PRODUCTION — authored focused contract.
# Runtime status remains PENDING until executed with official Godot 4.7.2.
var plans := ProductionPlanRegistry.new()
var buildings := BuildingSystem.new()
var crops := SpiritCropRegistry.new()
var alchemy := AlchemyRecipeRegistry.new()
var equipment := EquipmentSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("ECON-V2 BULK TEST FAIL: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    if not _verify_canonical_plans():
        return
    if not _verify_level_scaling_and_legacy_boundary():
        return
    if not _verify_fixed_point_timer_math():
        return
    if not _verify_bulk_consumers():
        return
    if not _verify_population_food_sink():
        return
    print("ECON-V2 BULK PRODUCTION TEST PASS")
    quit(0)

func _verify_canonical_plans() -> bool:
    if not _check(plans.validate_definitions().is_empty(),
        "ProductionPlan registry validation failed"):
        return false
    if not _check(
        plans.base_cycle_ticks(ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1) == 60
        and plans.base_yield(ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1) == 10000,
        "Mine T1 plan is not 10,000 Thanh Thiết / 60m"
    ):
        return false
    if not _check(
        plans.base_cycle_ticks(ProductionPlanRegistry.PLAN_FOREST_LINH_MOC_T1) == 60
        and plans.base_yield(ProductionPlanRegistry.PLAN_FOREST_LINH_MOC_T1) == 8000,
        "Forest T1 plan is not 8,000 Linh Mộc / 60m"
    ):
        return false
    if not _check(
        crops.base_cycle_ticks(SpiritCropRegistry.CROP_LINH_COC) == 60
        and crops.base_yield(SpiritCropRegistry.CROP_LINH_COC) == 2500,
        "Linh Cốc plan is not 2,500 / 60m"
    ):
        return false
    if not _check(
        crops.base_cycle_ticks(SpiritCropRegistry.CROP_THANH_LINH_THAO) == 90
        and crops.base_yield(SpiritCropRegistry.CROP_THANH_LINH_THAO) == 2000,
        "Thanh Linh Thảo plan is not 2,000 / 90m"
    ):
        return false
    if not _check(
        crops.base_cycle_ticks(SpiritCropRegistry.CROP_TU_VAN_THAO) == 180
        and crops.base_yield(SpiritCropRegistry.CROP_TU_VAN_THAO) == 1000,
        "Tử Vân Thảo plan is not 1,000 / 180m"
    ):
        return false

    if not _check(
        plans.cultivation_realm_tier(ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1) == 2
        and plans.cultivation_realm_tier(ProductionPlanRegistry.PLAN_FOREST_LINH_MOC_T1) == 1
        and crops.cultivation_realm_tier(SpiritCropRegistry.CROP_TU_VAN_THAO) == 3
        and crops.body_realm_tier(SpiritCropRegistry.CROP_TU_VAN_THAO) == 4,
        "ProductionPlan realm tiers do not align to canonical 30-realm authority"
    ):
        return false
    return _check(
        DiscipleRealmProgressV2.MAX_REALM == 30
        and DiscipleRealmProgressV2.MAX_FLOOR == 10,
        "character progression is no longer 30 realms x 10 floors"
    )

func _verify_level_scaling_and_legacy_boundary() -> bool:
    if not _check(is_equal_approx(plans.building_speed_factor(1),1.0)
        and is_equal_approx(plans.common_yield_factor(1),1.0),
        "Lv1 facility factor must be neutral"):
        return false
    if not _check(is_equal_approx(plans.building_speed_factor(3),1.01)
        and plans.scaled_yield(ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1,3) == 10100
        and plans.scaled_yield(ProductionPlanRegistry.PLAN_FOREST_LINH_MOC_T1,3) == 8080,
        "+0.5%/level speed/yield scaling is wrong"):
        return false
    if not _check(is_equal_approx(plans.building_speed_factor(100),1.495)
        and is_equal_approx(plans.common_yield_factor(100),1.495),
        "Lv100 normal-level factor must be x1.495"):
        return false

    var state := P37Factory.create_state(940701)
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if not _check(mine != null and buildings._resource_job_batch_units(mine) == 2,
        "legacy carry helper was incorrectly bulk-converted"):
        return false
    return _check(
        plans.scaled_yield(ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1,mine.level) == 10000,
        "V2 ProductionPlan cannot coexist with legacy carry helper"
    )

func _verify_fixed_point_timer_math() -> bool:
    # A 6-minute Alchemy recipe at profession speed x1.10 must not remain
    # permanently quantized to six minutes. Overshoot from the first batch
    # shortens the next batch while cancellation still banks nothing.
    var first := buildings._timed_duration_plan(6.0, 1.10, 0)
    var second := buildings._timed_duration_plan(
        6.0, 1.10, int(first.get("completion_remainder_bp", 0))
    )
    return _check(
        int(first.get("duration_ticks", -1)) == 6
        and int(first.get("completion_remainder_bp", -1)) == 6000
        and int(second.get("duration_ticks", -1)) == 5
        and int(second.get("completion_remainder_bp", -1)) == 1000,
        "fixed-point timer remainder does not preserve small profession-speed gains"
    )

func _verify_bulk_consumers() -> bool:
    var state := P37Factory.create_state(940702)
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if not _check(mine != null,"consumer probe has no Mine"):
        return false

    var legacy_recipe := equipment.crafting_requirements(state,&"thanh_thiet_kiem")
    if not _check(int(legacy_recipe.get("thanh_thiet",0)) == 3
        and int(legacy_recipe.get("linh_moc",0)) == 1,
        "legacy Forge costs changed before bulk mode"):
        return false

    if not _check(bool(EconomySystem.new().enable_v1(state).get("ok",false)),
        "cannot enable bulk economy for consumer probe"):
        return false
    var bulk_recipe := equipment.crafting_requirements(state,&"thanh_thiet_kiem")
    if not _check(int(bulk_recipe.get("thanh_thiet",0)) == 3000
        and int(bulk_recipe.get("linh_moc",0)) == 1000,
        "common Forge inputs are not scaled to bulk units"):
        return false
    var rare_recipe := equipment.crafting_requirements(state,&"huyen_thiet_quyen_sao")
    if not _check(int(rare_recipe.get("thanh_thiet",0)) == 3000
        and int(rare_recipe.get("tinh_lang_bi",0)) == 1,
        "rare/discrete Forge input was incorrectly bulk-scaled"):
        return false

    var legacy_upgrade := buildings.upgrade_cost(mine)
    var bulk_upgrade := buildings.upgrade_cost_for_state(state,mine)
    if not _check(
        int(bulk_upgrade.get(BuildingSystem.MATERIAL_WOOD,0))
            == int(legacy_upgrade.get(BuildingSystem.MATERIAL_WOOD,0)) * ProductionPlanRegistry.COMMON_CONSUMER_SCALE
        and int(bulk_upgrade.get(BuildingSystem.MATERIAL_ORE,0))
            == int(legacy_upgrade.get(BuildingSystem.MATERIAL_ORE,0)) * ProductionPlanRegistry.COMMON_CONSUMER_SCALE
        and int(bulk_upgrade.get("spirit_stones",0)) == int(legacy_upgrade.get("spirit_stones",0)),
        "building upgrade did not scale only common materials"
    ):
        return false

    var pill_inputs := alchemy.inputs(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN)
    return _check(
        int(pill_inputs.get("thanh_linh_thao",0)) == 500
        and alchemy.base_cycle_ticks(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN) == 6
        and alchemy.cultivation_realm_tier(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN) == 2,
        "Hồi Xuân Đan consumer/tier balance is wrong"
    )

func _verify_population_food_sink() -> bool:
    var state := P37Factory.create_state(940703)
    if not _check(state.sect.needs_enabled and state.sect.p3_7_resources_enabled,
        "food probe lacks Needs/Warehouse authority"):
        return false
    var population := state.disciples.size()
    if not _check(population > 0,"food probe has no disciples"):
        return false
    if not _check(warehouse.add(state,NeedsSystem.V2_FOOD_RESOURCE_ID,100),
        "cannot seed Linh Cốc food probe"):
        return false
    if not _check(warehouse.set_rule(state,NeedsSystem.V2_FOOD_RESOURCE_ID,88,false),
        "cannot set Linh Cốc reserve"):
        return false

    state.tick = NeedsSystem.V2_FOOD_INTERVAL
    NeedsSystem.new().process_logistics_tick(state)
    var expected_consumed := mini(population * NeedsSystem.V2_FOOD_PER_DISCIPLE,12)
    if not _check(
        warehouse.quantity(state,NeedsSystem.V2_FOOD_RESOURCE_ID) == 100-expected_consumed
        and warehouse.quantity(state,NeedsSystem.V2_FOOD_RESOURCE_ID) >= 88,
        "population food sink ignored canonical Warehouse reserve"
    ):
        return false
    return _check(
        int(state.sect.needs_stats.get("v2_linh_coc_consumed",0)) == expected_consumed
        and int(state.sect.needs_stats.get("v2_linh_coc_shortage",0)) == population * NeedsSystem.V2_FOOD_PER_DISCIPLE-expected_consumed,
        "food consumption/shortage audit counters are wrong"
    )
