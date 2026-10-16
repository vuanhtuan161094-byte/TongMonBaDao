extends SceneTree

# ECON-V2 BULK PRODUCTION — authored focused contract.
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
    if not _verify_field_stock_pause_and_resume():
        return
    if not _verify_advanced_ore_plan_snapshot():
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
    var milestones := {
        1: 1.0, 10: 2.0, 20: 5.0, 30: 10.0, 40: 30.0,
        50: 100.0, 60: 300.0, 75: 1000.0, 90: 3000.0, 100: 10000.0
    }
    for level in milestones.keys():
        if not _check(is_equal_approx(plans.common_yield_factor(level), milestones[level]),
            "common yield misses level %d milestone" % level):
            return false
    for level in range(2, 101):
        var current := plans.common_yield_factor(level)
        var previous := plans.common_yield_factor(level - 1)
        if not _check(current > previous and current / previous < 1.16,
            "common yield has a non-monotone or abrupt level jump at %d" % level):
            return false
    if not _check(
        is_equal_approx(plans.building_speed_factor(100), 1.495)
        and plans.scaled_yield(ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1,100) == 100000000
        and plans.scaled_yield(ProductionPlanRegistry.PLAN_FOREST_LINH_MOC_T1,100) == 80000000,
        "Lv100 batch yield or independent speed factor is wrong"):
        return false

    var state := P37Factory.create_state(940701)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(field != null,"yield probe has no Field"):
        return false
    for level in [1, 20, 75, 100]:
        field.level = level
        if not _check(is_equal_approx(buildings.spirit_field_yield_factor(field),
            plans.common_yield_factor(level)),
            "Field multiplied the common-yield milestone twice at Lv%d" % level):
            return false
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

func _verify_field_stock_pause_and_resume() -> bool:
    var state := P37Factory.create_state(940704)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(field != null and field.level == 1,"stock probe has no Lv1 Field"):
        return false
    state.sect.spirit_stones = 100000
    var data := buildings._ensure_spirit_field_state(state,field)
    if not _check(buildings._select_crop(state,field,data) != &"",
        "affordable Field cannot select an initial crop"):
        return false
    for crop_id in [SpiritCropRegistry.CROP_LINH_COC,SpiritCropRegistry.CROP_THANH_LINH_THAO]:
        var resource_id := crops.output_resource_id(crop_id)
        var target := maxi(crops.stock_target(crop_id),
            plans.scaled_yield(crops.production_plan_id(crop_id),field.level) * 10)
        if not _check(warehouse.add(state,resource_id,target),"cannot fill stock target"):
            return false
    if not _check(buildings._select_crop(state,field,data) == &"",
        "Field continued planting after every unlocked crop reached stock target"):
        return false
    if not _check(warehouse.consume(state,crops.output_resource_id(SpiritCropRegistry.CROP_LINH_COC),1),
        "cannot consume one Linh Cốc to reopen production"):
        return false
    return _check(buildings._select_crop(state,field,data) == SpiritCropRegistry.CROP_LINH_COC,
        "Field did not resume after stock fell below target")

func _verify_advanced_ore_plan_snapshot() -> bool:
    var state := P37Factory.create_state(940705)
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if not _check(mine != null,"advanced ore probe has no Mine"):
        return false
    if not _check(bool(EconomySystem.new().enable_v1(state).get("ok",false)),
        "advanced ore probe lacks canonical economy"):
        return false
    var advanced := ProductionPlanRegistry.PLAN_MINE_HUYEN_THIET_T2
    if not _check(not buildings.set_resource_production_plan(state,mine.id,advanced),
        "Huyen Thiet plan unlocked before Mine Lv30"):
        return false
    mine.level = 30
    if not _check(buildings.set_resource_production_plan(state,mine.id,advanced)
        and buildings.selected_resource_production_plan(mine) == advanced
        and plans.scaled_yield(advanced,100) == 10,
        "Huyen Thiet plan or rare-yield isolation is wrong"):
        return false
    var worker_ids := buildings.active_worker_ids(state,mine)
    if not _check(not worker_ids.is_empty(),"advanced ore probe has no canonical miner"):
        return false
    var worker: DiscipleState = state.disciples[worker_ids[0]]
    var started := buildings._start_resource_timer(state,mine,worker,1.0,BuildingSystem.PROF_MINING,1.0)
    var jobs := buildings.resource_timer_jobs(mine)
    if not _check(bool(started.get("ok",false)) and jobs.size() == 1
        and str(jobs[0].get("production_plan_id","")) == str(advanced)
        and str(jobs[0].get("resource_id","")) == "huyen_thiet"
        and int(jobs[0].get("output_quantity",-1)) == 10,
        "advanced ore timer did not snapshot real plan and output"):
        return false
    if not _check(buildings.set_resource_production_plan(state,mine.id,
        ProductionPlanRegistry.PLAN_MINE_THANH_THIET_T1)
        and str(buildings.resource_timer_jobs(mine)[0].get("resource_id","")) == "huyen_thiet",
        "changing future Mine plan rewrote a committed batch"):
        return false
    return true
