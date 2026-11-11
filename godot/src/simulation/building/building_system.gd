class_name BuildingSystem
extends RefCounted

const TYPE_MAIN_HALL := &"main_hall"
const TYPE_RESIDENCE := &"residence"
const TYPE_MINE := &"mine"
const TYPE_LINH_FOREST := &"linh_forest"
const TYPE_ALCHEMY_HALL := &"alchemy_hall"
const TYPE_SPIRIT_FIELD := &"spirit_field"
const TYPE_GUIDANCE_PLATFORM := &"dan_tien_dai"
const TYPE_BODY_TRAINING := &"ren_than_duong"

const PROF_MINING := &"mining"
const PROF_FORESTRY := &"forestry"
const PROF_ALCHEMY := &"alchemy"
const PROF_HERBALISM := &"herbalism"

const STATUS_ACTIVE := &"active"
const STATUS_UPGRADING := &"upgrading"
# DD-09: House construction is an actual persisted lifecycle, distinct from
# upgrades; houses are not rentable until construction is completed.
const STATUS_CONSTRUCTING := &"constructing"
const VALID_STATUSES := [STATUS_ACTIVE, STATUS_UPGRADING, STATUS_CONSTRUCTING]

const MILESTONE_LEVELS := [10, 20, 30, 50, 75, 100]

# Named resources remain explicit. P3.7B uses WarehouseSystem as the sole
# stackable-resource authority; legacy buckets are fallback-only for old direct states.
const MATERIAL_WOOD := "linh_moc"
const MATERIAL_ORE := "thanh_thiet"
# Only mineral resources already registered in ResourceRegistry are selectable.
# Existing saves remain Thanh Thiết by default. Huyền Thiết unlocks at Mine Lv10.
const MINE_ORE_OPTIONS := {
    "thanh_thiet": {"required_level": 1, "batch_percent": 100},
    "ore_r01_c2": {"required_level": 1, "batch_percent": 100},
    "huyen_thiet": {"required_level": 10, "batch_percent": 50},
    "ore_r02_c2": {"required_level": 10, "batch_percent": 50}
}
# Existing real forestry timer/carry-cycle output is controlled per BUILDING,
# not a new production authority. Legacy Forest defaults to Linh Moc.
const FOREST_MATERIAL_OPTIONS := {
    "linh_moc":{"required_level":1,"batch_percent":100},
    "forest_r01_wood2":{"required_level":1,"batch_percent":100},
    "forest_r02_wood":{"required_level":10,"batch_percent":100},
    "forest_r02_wood2":{"required_level":10,"batch_percent":100}
}

# SX-V55 opt-in replaces only NEW authentic Economy-A timer/plot envelopes.
# Historic PR #8 five owner-approved plans; one existing BuildingSystem authority.
# Existing carry cycles, timed jobs, planted plots and previously purchased
# resources retain their frozen quantities and finish ticks across cold Save.
const SX_V55_BULK_POLICY := "sx_v55_bulk_production"
const SX_V55_COMMON_SCALE := 1000
const SX_V55_COMMON_IDS := ["linh_moc","thanh_thiet","thanh_linh_thao"]
const SX_V55_BULK_PLANS := {
    "thanh_thiet":{"producer":"mine","cycle_ticks":60,"yield":10000,"plan_id":"mine_thanh_thiet_t1"},
    "linh_moc":{"producer":"linh_forest","cycle_ticks":60,"yield":8000,"plan_id":"forest_linh_moc_t1"},
    "linh_coc":{"producer":"spirit_field","cycle_ticks":60,"yield":2500,"plan_id":"field_linh_coc_t1"},
    "thanh_linh_thao":{"producer":"spirit_field","cycle_ticks":90,"yield":2000,"plan_id":"field_thanh_linh_thao_t1"},
    "tu_van_thao":{"producer":"spirit_field","cycle_ticks":180,"yield":1000,"plan_id":"field_tu_van_thao_t1"}
}

func sx_v55_bulk_enabled(state: SimulationState) -> bool:
    return state != null and state.sect.economy_a_enabled and state.sect.p3_7_resources_enabled \
        and bool(state.sect.economy_a_policy.get(SX_V55_BULK_POLICY,false))

# One opt-in per EXISTING save, not a second scheduler or producer. It neither
# debits nor grants anything. The 30-realm LT2/W2/T2 policy remains disabled.
func sx_v55_enable_bulk(state: SimulationState) -> Dictionary:
    if state == null or not state.p3_7_buildings_enabled or not state.sect.economy_a_enabled \
        or not state.sect.p3_7_resources_enabled:
        return {"ok":false,"reason":"canonical_economy_required"}
    if sx_v55_bulk_enabled(state):
        return {"ok":true,"already_enabled":true}
    var registry := ResourceRegistry.new()
    for resource_id in SX_V55_BULK_PLANS.keys():
        if not registry.has(StringName(resource_id)):
            return {"ok":false,"reason":"missing_real_resource","id":resource_id}
        var plan: Dictionary = SX_V55_BULK_PLANS[resource_id]
        var producer := StringName(plan.get("producer",""))
        if producer == TYPE_SPIRIT_FIELD:
            if not crop_registry.has(StringName(resource_id)):
                return {"ok":false,"reason":"missing_real_crop","id":resource_id}
        elif producer == TYPE_MINE and not MINE_ORE_OPTIONS.has(resource_id):
            return {"ok":false,"reason":"missing_mine_source","id":resource_id}
        elif producer == TYPE_LINH_FOREST and not FOREST_MATERIAL_OPTIONS.has(resource_id):
            return {"ok":false,"reason":"missing_forest_source","id":resource_id}
        if primary_building(state,producer) == null:
            return {"ok":false,"reason":"missing_real_worksite","id":resource_id}
    var next_policy := state.sect.economy_a_policy.duplicate(true)
    next_policy[SX_V55_BULK_POLICY] = true
    state.sect.economy_a_policy = next_policy
    state.sect.economy_a_event_count += 1
    return {"ok":true,"enabled":true,"existing_jobs_unchanged":true}

# Selection and ownership are governed by existing Mine/Forest/Field rules.
# Nonbasic r1/r2 sources keep their old per-ID yield until independently
# approved; no r3+ generic mapping, generated resource or fake source is added.
func sx_v55_plan(state: SimulationState, producer: BuildingState, item_id: StringName) -> Dictionary:
    if not sx_v55_bulk_enabled(state) or producer == null:
        return {}
    var plan: Dictionary = SX_V55_BULK_PLANS.get(str(item_id),{})
    if plan.is_empty() or StringName(plan.get("producer","")) != producer.building_type:
        return {}
    if producer.building_type == TYPE_SPIRIT_FIELD:
        if not crop_registry.eligible_crop_ids(producer.level).has(item_id):
            return {}
    elif producer.building_type == TYPE_MINE:
        if mine_selected_ore(producer) != item_id:
            return {}
    elif producer.building_type == TYPE_LINH_FOREST:
        if forest_selected_material(producer) != item_id:
            return {}
    return plan

# Bulk mode changes the *cost of NEW orders only*. Already-started Alchemy
# and other jobs keep their frozen input receipt; rare/catalyst/heart unchanged.
func sx_v55_common_requirements(state: SimulationState, original: Dictionary) -> Dictionary:
    var result := original.duplicate(true)
    if not sx_v55_bulk_enabled(state):
        return result
    for raw_id in result.keys():
        if str(raw_id) in SX_V55_COMMON_IDS:
            result[raw_id] = maxi(int(result[raw_id]),0) * SX_V55_COMMON_SCALE
    return result

# V5.5-D tab 04_NangCap342: the approved monetary DENOMINATION is ×1,000
# (Hall Lv1→2 = 580,000, Field = 21,000, Mine/Forest = 24,000).
# Apply only to NEW explicitly QA-gated r1/r2 upgrade requests. Never
# migrate/charge an in-flight legacy upgrade or change Warehouse material IDs.
func sx_v55_upgrade_cost(state: SimulationState, building: BuildingState) -> Dictionary:
    var cost := sx_v55_common_requirements(state,upgrade_cost(building))
    if not cost.is_empty() and EconomySystem.new().sx_v55_r12_enabled(state):
        var base_stones := maxi(0,int(cost.get("spirit_stones",0)))
        if base_stones > int(EconomySystem.V2_MAX_STONES/SX_V55_COMMON_SCALE):
            return {}
        cost["spirit_stones"] = base_stones*SX_V55_COMMON_SCALE
    return cost

# Stock policy follows only real scaled consumers, not the size of the
# producer batch. Linh Cốc and Tử Vân Thảo use their original unscaled
# sinks/recipes; multiplying their stock goals would perpetually overplant.
func sx_v55_crop_stock_target(state: SimulationState, crop_id: StringName) -> int:
    var target := crop_registry.stock_target(crop_id)
    if sx_v55_bulk_enabled(state) and crop_id == SpiritCropRegistry.CROP_THANH_LINH_THAO:
        target *= SX_V55_COMMON_SCALE
    return target

const MATERIAL_TAM_MACH_BAN := "tam_mach_ban"
const MATERIAL_HERB := "thanh_linh_thao"
const MATERIAL_LINH_TUYEN_HEART := "linh_tuyen_chi_tam"
const MATERIAL_LINH_TUYEN_FRAGMENT := "linh_tuyen_chi_tam_manh"
const LINH_TUYEN_FRAGMENT_PER_HEART := 100
const LINH_TUYEN_FRAGMENT_BASE_CHANCE := 0.05

# Legacy A2 phase names remain only for old-save migration.
const SPIRIT_PHASE_GROWING := &"growing"
const SPIRIT_PHASE_HARVEST_READY := &"harvest_ready"

const FIELD_POLICY_AUTO_DEMAND := &"auto_demand"
const FIELD_POLICY_PRIORITY := &"priority"
const FIELD_POLICY_FIXED := &"fixed"
const VALID_FIELD_POLICIES := [FIELD_POLICY_AUTO_DEMAND, FIELD_POLICY_PRIORITY, FIELD_POLICY_FIXED]

const PLOT_EMPTY := &"empty"
const PLOT_GROWING := &"growing"

# Milestone specialty components. Spirit Field reuses one clear component
# across all major thresholds, with quantity increasing by milestone level.
const MILESTONE_COMPONENTS := {
    "mine": {
        # A real repeatable component source is now available at the NPC market.
        # Keep the original one-board cost at Lv10; higher gates use one board
        # provisionally, not nonexistent resources or automatic free unlocks.
        10: MATERIAL_TAM_MACH_BAN,
        20: MATERIAL_TAM_MACH_BAN,
        30: MATERIAL_TAM_MACH_BAN,
        50: MATERIAL_TAM_MACH_BAN,
        75: MATERIAL_TAM_MACH_BAN,
        100: MATERIAL_TAM_MACH_BAN
    },
    "spirit_field": {
        10: MATERIAL_LINH_TUYEN_HEART,
        20: MATERIAL_LINH_TUYEN_HEART,
        30: MATERIAL_LINH_TUYEN_HEART,
        50: MATERIAL_LINH_TUYEN_HEART,
        75: MATERIAL_LINH_TUYEN_HEART,
        100: MATERIAL_LINH_TUYEN_HEART
    }
}

const DEFINITIONS := {
    "main_hall": {
        "name": "Tông Môn Đại Điện",
        "max_level": 100,
        "worker_group_id": "",
        "base_worker_slots": 0,
        "worker_slot_every": 0,
        # DD-01 early implementation prices are provisional; never imply approved long-term balance.
        "base_wood_cost": 25,
        "base_ore_cost": 20,
        "base_stone_cost": 500,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "upgrade_enabled": true,
        "requires_milestone_component": false
    },
    "residence": {
        "name": "Đệ Tử Xá", "max_level": 100,
        "worker_group_id": "", "base_worker_slots": 0,
        "worker_slot_every": 0,
        "base_wood_cost": 35, "base_ore_cost": 25,
        "base_stone_cost": 500, "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0, "upgrade_enabled": true,
        "requires_milestone_component": false
    },
    "mine": {
        "name": "Mỏ Linh Khoáng",
        "max_level": 100,
        "worker_group_id": "mining_crew",
        "profession_id": "mining",
        "job_model": "carry_cycle",
        "resource_id": MATERIAL_ORE,
        "cycle_phases": ["travel_out", "mining", "haul_back"],
        "cycle_work_phase": "mining",
        "base_worker_slots": 2,
        "worker_slot_every": 5,
        "base_wood_cost": 4,
        "base_ore_cost": 6,
        "base_stone_cost": 20,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "work_distance": 8.0,
        "haul_distance": 6.0,
        "base_work_duration": 4.0,
        "base_batch_units": 2
    },
    "linh_forest": {
        "name": "Linh Lâm",
        "max_level": 100,
        "worker_group_id": "forestry_crew",
        "profession_id": "forestry",
        "job_model": "carry_cycle",
        "resource_id": MATERIAL_WOOD,
        "cycle_phases": ["travel_out", "harvesting", "haul_back"],
        "cycle_work_phase": "harvesting",
        "base_worker_slots": 2,
        "worker_slot_every": 5,
        "work_distance": 8.0,
        "haul_distance": 6.0,
        "base_work_duration": 4.0,
        "base_batch_units": 2,
        # Bounded provisional economy: reuse the existing Mine upgrade cost
        # curve until Linh Lâm-specific balancing is approved. These costs are
        # actually consumed by start_upgrade; never display a free/fake button.
        "base_wood_cost": 4,
        "base_ore_cost": 6,
        "base_stone_cost": 20,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "upgrade_enabled": true,
        "requires_milestone_component": false
    },
    "alchemy_hall": {
        "name": "Luyện Đan Điện",
        "max_level": 100,
        "worker_group_id": "alchemy_crew",
        "profession_id": "alchemy",
        "job_model": "timed_recipe",
        "base_worker_slots": 2,
        "worker_slot_every": 10,
        # SX-02: a real advancement path is required for product quality;
        # costs are provisional, common-material-only until milestone content is authored.
        "base_wood_cost": 6,
        "base_ore_cost": 4,
        "base_stone_cost": 12,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "upgrade_enabled": true,
        "requires_milestone_component": false
    },
    "spirit_field": {
        "name": "Linh Điền",
        "max_level": 100,
        "worker_group_id": "herbalism_crew",
        "profession_id": "herbalism",
        "job_model": "plot_timer",
        "base_worker_slots": 4,
        "worker_slot_every": 5,
        "base_wood_cost": 6,
        "base_ore_cost": 3,
        "base_stone_cost": 18,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "work_distance": 7.0,
        "haul_distance": 5.0,
        "base_tend_duration": 3.0,
        "base_harvest_duration": 3.0,
        "base_growth_duration": 12.0,
        "base_batch_units": 3,
        "resource_id": MATERIAL_HERB
    },
    "ren_than_duong": {
        "name": "Rèn Thân Đường",
        "max_level": 100,
        "worker_group_id": "body_training_crew",
        "base_worker_slots": 2,
        "worker_slot_every": 0,
        "requires_milestone_component": false
    },
    "dan_tien_dai": {
        "name": "Dẫn Tiên Đài",
        "max_level": 100,
        "worker_group_id": "",
        "base_worker_slots": 0,
        "worker_slot_every": 0,
        "base_wood_cost": 5,
        "base_ore_cost": 4,
        "base_stone_cost": 24,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "requires_milestone_component": false
    }
}

var equipment := EquipmentSystem.new()
var warehouse := WarehouseSystem.new()
var crop_registry := SpiritCropRegistry.new()
var alchemy_registry := AlchemyRecipeRegistry.new()
var profession_modifiers := ProfessionModifierSystem.new()

# V5.7 P0: derived-only worksite index for large rosters. Never persisted.
# Rebuild on the simulation minute / authoritative workforce or building revision.
# Small rosters retain the original scan for exact fixture compatibility.
const WORKSITE_INDEX_MIN_ROSTER := 96
var _worksite_index_state_id: int = -1
var _worksite_index_tick: int = -1
var _worksite_index_workforce_revision: int = -1
var _worksite_index_building_revision: int = -1
var _worksite_index_disciple_count: int = -1
var _worksite_index_building_count: int = -1
var _worksite_index: Dictionary = {}



func initialize(state: SimulationState) -> void:
    if not state.sect.workforce_enabled:
        return
    state.p3_7_buildings_enabled = true

    if not state.sect.work_groups.has("herbalism_crew"):
        state.sect.work_groups["herbalism_crew"] = {
            "name": "Đội Linh Thực",
            "priorities": {"herbalism": 3}
        }
        state.sect.workforce_event_count += 1

    if not state.sect.work_groups.has("forestry_crew"):
        state.sect.work_groups["forestry_crew"] = {
            "name": "Đội Lâm Nghiệp",
            "priorities": {"forestry": 3}
        }
        state.sect.workforce_event_count += 1

    if not state.sect.work_groups.has("alchemy_crew"):
        state.sect.work_groups["alchemy_crew"] = {
            "name": "Đội Luyện Đan",
            "priorities": {"alchemy": 3}
        }
        state.sect.workforce_event_count += 1

    if primary_building(state, TYPE_MINE) == null:
        var mine := create_building(TYPE_MINE, 1)
        state.buildings[str(mine.id)] = mine
        state.building_event_count += 1

    if primary_building(state, TYPE_LINH_FOREST) == null:
        var forest := create_building(TYPE_LINH_FOREST, 1)
        state.buildings[str(forest.id)] = forest
        state.building_event_count += 1

    if primary_building(state, TYPE_ALCHEMY_HALL) == null:
        var alchemy_hall := create_building(TYPE_ALCHEMY_HALL, 1)
        alchemy_hall.production_state = _default_alchemy_state()
        state.buildings[str(alchemy_hall.id)] = alchemy_hall
        state.building_event_count += 1

    if primary_building(state, TYPE_SPIRIT_FIELD) == null:
        var field := create_building(TYPE_SPIRIT_FIELD, 1)
        state.buildings[str(field.id)] = field
        state.building_event_count += 1

    if primary_building(state, TYPE_GUIDANCE_PLATFORM) == null:
        var guidance := create_building(TYPE_GUIDANCE_PLATFORM, 1)
        guidance.production_state = {
            "main_guide_id": "",
            "assistant_guide_ids": [],
            "snapshot_day_index": -1,
            "snapshot_main_charisma": 0.0,
            "enhanced_heaven_count": 0,
            "daily_arrival_target": 0,
            "daily_arrivals_generated": 0
        }
        state.buildings[str(guidance.id)] = guidance
        state.building_event_count += 1

    for field in _buildings_of_type(state, TYPE_SPIRIT_FIELD):
        _ensure_spirit_field_state(state, field)
    for hall in _buildings_of_type(state, TYPE_ALCHEMY_HALL):
        _ensure_alchemy_state(hall)

# Add the selected V2 training facility only in the V2 live runtime, not in
# older P3.7 factories/test fixtures. Repeat-safe on old loaded live saves.
func ensure_body_training_facility(state: SimulationState) -> BuildingState:
    if not state.p3_7_buildings_enabled:
        return null
    # A previously saved building must survive a workforce-disabled
    # compatibility state without creating any new resources or assignments.
    var facility := primary_building(state, TYPE_BODY_TRAINING)
    if facility != null:
        return facility
    if not state.sect.workforce_enabled:
        return null
    if not state.sect.work_groups.has("body_training_crew"):
        state.sect.work_groups["body_training_crew"] = {
            "name": "Đội Rèn Thân",
            "priorities": {}
        }
        state.sect.workforce_event_count += 1
    facility = create_building(TYPE_BODY_TRAINING, 1)
    state.buildings[str(facility.id)] = facility
    state.building_event_count += 1
    return facility

# DD-01 live-runtime only. Never create a second Hall from a UI map token.
func ensure_main_hall(state: SimulationState) -> BuildingState:
    if state == null or not state.p3_7_buildings_enabled:
        return null
    var existing := primary_building(state, TYPE_MAIN_HALL)
    if existing != null:
        return existing
    var hall := create_building(TYPE_MAIN_HALL, 1)
    if hall == null or state.buildings.has(str(hall.id)):
        return null
    state.buildings[str(hall.id)] = hall
    state.building_event_count += 1
    return hall

# V5.7: Real paid producer annexes. Request IDs and debits are persisted on
# each authoritative BuildingState; retry never creates a duplicate site.
const PAID_PRODUCER_TYPES := [
    TYPE_MINE, TYPE_LINH_FOREST, TYPE_ALCHEMY_HALL, TYPE_SPIRIT_FIELD
]
const MAX_PRODUCER_INSTANCES := 48

func production_annex_cost(building_type: StringName, ordinal: int) -> Dictionary:
    if not PAID_PRODUCER_TYPES.has(building_type) or ordinal < 2 or ordinal > MAX_PRODUCER_INSTANCES:
        return {}
    var def: Dictionary = DEFINITIONS.get(str(building_type),{})
    if def.is_empty():
        return {}
    var factor := 1.0+0.25*float(ordinal-2)
    return {
        MATERIAL_WOOD: maxi(1,ceili(float(def.get("base_wood_cost",1))*factor)),
        MATERIAL_ORE: maxi(1,ceili(float(def.get("base_ore_cost",1))*factor)),
        "spirit_stones":maxi(1,ceili(float(def.get("base_stone_cost",1))*factor))
    }

func preview_production_annex(state: SimulationState, building_type: StringName) -> Dictionary:
    if state == null or not state.p3_7_buildings_enabled or not state.sect.p3_7_resources_enabled             or not state.sect.economy_a_enabled:
        return {"ok":false,"reason":"production_annex_requires_economy"}
    if not PAID_PRODUCER_TYPES.has(building_type):
        return {"ok":false,"reason":"invalid_producer_type"}
    var hall := SectHallSystemV1.hall(state)
    if hall == null:
        return {"ok":false,"reason":"main_hall_missing"}
    var highest := 0
    for site in _buildings_of_type(state,building_type):
        highest = maxi(highest,site.instance_index)
    var ordinal := highest+1
    var maximum := mini(MAX_PRODUCER_INSTANCES,maxi(2,1+int(hall.level/2)))
    if ordinal > maximum:
        return {"ok":false,"reason":"producer_hall_level_cap","maximum":maximum}
    var id := "%s_%03d" % [str(building_type),ordinal]
    if state.buildings.has(id):
        return {"ok":false,"reason":"producer_id_conflict"}
    var cost := production_annex_cost(building_type,ordinal)
    var materials := cost.duplicate(true)
    materials.erase("spirit_stones")
    if not warehouse.can_consume_requirements(state,materials):
        return {"ok":false,"reason":"producer_materials_missing","cost":cost}
    if state.sect.spirit_stones < int(cost.get("spirit_stones",0)):
        return {"ok":false,"reason":"producer_stones_missing","cost":cost}
    return {"ok":true,"building_type":str(building_type),"ordinal":ordinal,"cost":cost}

func build_paid_production_annex(state: SimulationState, building_type: StringName,
        request_id: String) -> Dictionary:
    if state == null or request_id.is_empty() or request_id.length() > 128:
        return {"ok":false,"reason":"invalid_producer_request"}
    for raw in state.buildings.values():
        if not (raw is BuildingState):
            continue
        var site: BuildingState = raw
        if str(site.production_state.get("v57_build_request_id","")) != request_id:
            continue
        if site.building_type != building_type:
            return {"ok":false,"reason":"producer_request_conflict"}
        return {"ok":true,"already_settled":true,"building_id":str(site.id),
            "cost":site.production_state.get("v57_paid_cost",{}).duplicate(true)}
    var preview := preview_production_annex(state,building_type)
    if not bool(preview.get("ok",false)):
        return preview
    var cost: Dictionary = preview["cost"]
    var materials := cost.duplicate(true)
    materials.erase("spirit_stones")
    var built := create_building(building_type,int(preview["ordinal"]))
    if built == null or state.buildings.has(str(built.id)):
        return {"ok":false,"reason":"producer_id_conflict"}
    var price := int(cost["spirit_stones"])
    if state.sect.spirit_stones < price or not warehouse.consume_requirements(state,materials):
        return {"ok":false,"reason":"producer_payment_failed"}
    state.sect.spirit_stones -= price
    if building_type == TYPE_ALCHEMY_HALL:
        built.production_state = _default_alchemy_state()
    elif building_type == TYPE_SPIRIT_FIELD:
        _ensure_spirit_field_state(state,built)
    built.production_state["v57_build_request_id"] = request_id
    built.production_state["v57_paid_cost"] = cost.duplicate(true)
    state.buildings[str(built.id)] = built
    state.building_event_count += 1
    return {"ok":true,"already_settled":false,"building_id":str(built.id),
        "ordinal":int(preview["ordinal"]),"cost":cost.duplicate(true)}

func create_building(building_type: StringName, instance_index: int = 1) -> BuildingState:
    var definition: Dictionary = DEFINITIONS.get(str(building_type), {})
    if definition.is_empty():
        return null
    var id := "%s_%03d" % [str(building_type), maxi(instance_index, 1)]
    return BuildingState.new({
        "id": id,
        "building_type": str(building_type),
        "name": str(definition.get("name", building_type)),
        "instance_index": maxi(instance_index, 1),
        "level": 1,
        "max_level": int(definition.get("max_level", 100)),
        "status": str(STATUS_ACTIVE),
        "worker_group_id": str(definition.get("worker_group_id", ""))
    })

func primary_building(state: SimulationState, building_type: StringName) -> BuildingState:
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if building is BuildingState and building.building_type == building_type:
            return building
    return null

func mine_selected_ore(mine: BuildingState) -> StringName:
    if mine == null or mine.building_type != TYPE_MINE:
        return StringName(MATERIAL_ORE)
    var requested := str(mine.production_state.get("selected_ore_id", MATERIAL_ORE))
    if not MINE_ORE_OPTIONS.has(requested):
        return StringName(MATERIAL_ORE)
    var option: Dictionary = MINE_ORE_OPTIONS[requested]
    if mine.level < int(option.get("required_level", 1)):
        return StringName(MATERIAL_ORE)
    return StringName(requested)

func mine_ore_batch_units(mine: BuildingState, ore_id: StringName) -> int:
    var normal := _resource_job_batch_units(mine)
    if mine == null or mine.building_type != TYPE_MINE:
        return normal
    var option: Dictionary = MINE_ORE_OPTIONS.get(str(ore_id), {})
    if option.is_empty():
        return normal
    return maxi(1, int(floor(float(normal) * float(option.get("batch_percent", 100)) / 100.0)))

func select_mine_ore(state: SimulationState, mine_id: StringName, ore_id: StringName) -> Dictionary:
    if state == null or not state.buildings.has(str(mine_id)):
        return {"ok": false, "reason": "mine_missing"}
    var mine: BuildingState = state.buildings[str(mine_id)]
    if mine.building_type != TYPE_MINE:
        return {"ok": false, "reason": "wrong_building_type"}
    var choice: Dictionary = MINE_ORE_OPTIONS.get(str(ore_id), {})
    if choice.is_empty() or not ResourceRegistry.DEFINITIONS.has(str(ore_id)):
        return {"ok": false, "reason": "ore_not_supported"}
    if mine.level < int(choice.get("required_level", 1)):
        return {"ok": false, "reason": "mine_level_required", "required_level": int(choice.get("required_level", 1))}
    if mine_selected_ore(mine) == ore_id:
        return {"ok": true, "changed": false}
    var data := mine.production_state.duplicate(true)
    data["selected_ore_id"] = str(ore_id)
    mine.production_state = data
    state.building_event_count += 1
    # Existing timed jobs and in-flight carry cycles keep their original ore.
    return {"ok": true, "changed": true}

# SX-07B: worksite-level output selection; already running timers/carry-cycles
# keep their saved resource_id and output_quantity regardless of changes.
func forest_selected_material(forest: BuildingState) -> StringName:
    if forest == null or forest.building_type != TYPE_LINH_FOREST:
        return StringName(MATERIAL_WOOD)
    var choice := str(forest.production_state.get("selected_forest_material_id",MATERIAL_WOOD))
    var option: Dictionary = FOREST_MATERIAL_OPTIONS.get(choice,{})
    if option.is_empty() or forest.level < int(option.get("required_level",1)):
        return StringName(MATERIAL_WOOD)
    return StringName(choice)

func forest_material_batch_units(forest: BuildingState, resource_id: StringName) -> int:
    var original := _resource_job_batch_units(forest)
    var option: Dictionary = FOREST_MATERIAL_OPTIONS.get(str(resource_id),{})
    if option.is_empty():
        return original
    return maxi(1,int(floor(float(original)*float(option.get("batch_percent",100))/100.0)))

func select_forest_material(state: SimulationState, forest_id: StringName, item_id: StringName) -> Dictionary:
    if state == null or not state.buildings.has(str(forest_id)):
        return {"ok":false,"reason":"forest_missing"}
    var forest: BuildingState = state.buildings[str(forest_id)]
    if forest.building_type != TYPE_LINH_FOREST:
        return {"ok":false,"reason":"wrong_building_type"}
    var choice: Dictionary = FOREST_MATERIAL_OPTIONS.get(str(item_id),{})
    if choice.is_empty() or not ResourceRegistry.DEFINITIONS.has(str(item_id)):
        return {"ok":false,"reason":"forest_resource_not_supported"}
    if forest.level < int(choice.get("required_level",1)):
        return {"ok":false,"reason":"forest_level_required",
            "required_level":int(choice.get("required_level",1))}
    if forest_selected_material(forest) == item_id:
        return {"ok":true,"changed":false}
    var data := forest.production_state.duplicate(true)
    data["selected_forest_material_id"] = str(item_id)
    forest.production_state = data
    state.building_event_count += 1
    return {"ok":true,"changed":true}

func worker_slots(building: BuildingState) -> int:
    var definition := definition_for(building)
    if definition.is_empty():
        return 0
    var base_slots := maxi(int(definition.get("base_worker_slots", 0)), 0)
    var every := maxi(int(definition.get("worker_slot_every", 0)), 0)
    if every <= 0:
        return base_slots
    return base_slots + int(floor(float(building.level) / float(every)))

func spirit_plot_slots(building: BuildingState) -> int:
    if building == null or building.building_type != TYPE_SPIRIT_FIELD:
        return 0
    return 4 + int(floor(float(building.level) / 5.0))

func guidance_elder_slots(building: BuildingState) -> int:
    if building == null or building.building_type != TYPE_GUIDANCE_PLATFORM:
        return 0
    return guidance_elder_slots_for_level(building.level)

func guidance_elder_slots_for_level(level: int) -> int:
    return clampi(1 + int(floor(float(maxi(level, 1)) / 20.0)), 1, 6)

func guidance_base_daily_arrivals(building: BuildingState) -> int:
    if building == null or building.building_type != TYPE_GUIDANCE_PLATFORM:
        return 0
    return guidance_base_daily_arrivals_for_level(building.level)

func guidance_base_daily_arrivals_for_level(level: int) -> int:
    # Dẫn Tiên should visibly scale with infrastructure without gating Mị Lực.
    # Current balance: 5/day at Lv1, +3 every 10 levels, 35/day at Lv100.
    return 5 + 3 * int(floor(float(maxi(level, 1)) / 10.0))

func spirit_field_speed_factor(field: BuildingState) -> float:
    return 1.0 + 0.005 * float(maxi(field.level - 1, 0))

func spirit_field_cycle_time_factor(field: BuildingState) -> float:
    var factor := 1.0
    if field.level >= 10:
        factor *= 0.90
    if field.level >= 75:
        factor *= 0.85
    return factor

func spirit_field_yield_factor(field: BuildingState) -> float:
    var factor := 1.0 + 0.005 * float(maxi(field.level - 1, 0))
    if field.level >= 20:
        factor *= 1.10
    if field.level >= 75:
        factor *= 1.10
    if field.level >= 100:
        factor *= 1.20
    return factor

func spirit_field_xp_factor(field: BuildingState) -> float:
    var factor := 1.0
    if field.level >= 30:
        factor *= 1.10
    if field.level >= 100:
        factor *= 1.20
    return factor

func assigned_worker_ids(state: SimulationState, building: BuildingState) -> Array[StringName]:
    var result: Array[StringName] = []
    if state == null or building == null or building.worker_group_id == &"":
        return result
    if state.disciples.size() >= WORKSITE_INDEX_MIN_ROSTER and state.buildings.get(str(building.id)) == building:
        _refresh_worksite_index(state)
        for worker_id in _worksite_index.get(str(building.id), []):
            result.append(StringName(worker_id))
        return result
    # Preserve original semantics for old/small saves and detached QA buildings.
    var primary := primary_building(state, building.building_type)
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id != building.worker_group_id:
            continue
        if disciple.worksite_building_id == building.id:
            result.append(disciple.id)
        elif disciple.worksite_building_id == &"" and primary != null and primary.id == building.id:
            result.append(disciple.id)
    return result

# A single sorted roster traversal replaces a repeated full-roster scan for
# every worksite query. Exact assignment order remains ID-ascending, so the
# first worker_slot_count disciples retain their historical job slots.
func _refresh_worksite_index(state: SimulationState) -> void:
    var instance_id := state.get_instance_id()
    if (
        _worksite_index_state_id == instance_id
        and _worksite_index_tick == state.tick
        and _worksite_index_workforce_revision == state.sect.workforce_event_count
        and _worksite_index_building_revision == state.building_event_count
        and _worksite_index_disciple_count == state.disciples.size()
        and _worksite_index_building_count == state.buildings.size()
    ):
        return
    var by_building: Dictionary = {}
    var primary_by_type: Dictionary = {}
    var fallback_by_group: Dictionary = {}
    var building_ids: Array = state.buildings.keys()
    building_ids.sort()
    for raw_id in building_ids:
        var site = state.buildings[raw_id]
        if not (site is BuildingState):
            continue
        var key := str(site.id)
        by_building[key] = []
        var kind := str(site.building_type)
        if not primary_by_type.has(kind):
            primary_by_type[kind] = key
            var group := str(site.worker_group_id)
            if not group.is_empty():
                if not fallback_by_group.has(group):
                    fallback_by_group[group] = []
                fallback_by_group[group].append(key)
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id == &"":
            continue
        var worksite := str(disciple.worksite_building_id)
        if not worksite.is_empty():
            if by_building.has(worksite):
                var assigned_site = state.buildings.get(worksite)
                if assigned_site is BuildingState and assigned_site.worker_group_id == disciple.work_group_id:
                    by_building[worksite].append(disciple.id)
            continue
        for primary_id in fallback_by_group.get(str(disciple.work_group_id), []):
            by_building[str(primary_id)].append(disciple.id)
    _worksite_index = by_building
    _worksite_index_state_id = instance_id
    _worksite_index_tick = state.tick
    _worksite_index_workforce_revision = state.sect.workforce_event_count
    _worksite_index_building_revision = state.building_event_count
    _worksite_index_disciple_count = state.disciples.size()
    _worksite_index_building_count = state.buildings.size()

func active_worker_ids(state: SimulationState, building: BuildingState) -> Array[StringName]:
    var assigned := assigned_worker_ids(state, building)
    var slots := worker_slots(building)
    if assigned.size() <= slots:
        return assigned
    var result: Array[StringName] = []
    for index in range(slots):
        result.append(assigned[index])
    return result

func can_disciple_work(state: SimulationState, building: BuildingState, disciple: DiscipleState) -> bool:
    if disciple != null and (not disciple.active_pve_encounter_id.is_empty() or disciple.active_job_id != &"" or not disciple.v63_study_job.is_empty()):
        return false
    if not state.p3_7_buildings_enabled or building == null:
        return false
    if disciple.region_id != &"sect":
        return false
    return active_worker_ids(state, building).has(disciple.id)

func building_for_profession(state: SimulationState, profession_id: StringName, disciple: DiscipleState = null) -> BuildingState:
    var building_type := building_type_for_profession(profession_id)
    if building_type == &"":
        return null
    return _building_for_disciple(state, building_type, disciple)

func building_type_for_profession(profession_id: StringName) -> StringName:
    var types: Array = DEFINITIONS.keys()
    types.sort()
    for raw_type in types:
        var definition: Dictionary = DEFINITIONS[raw_type]
        if StringName(definition.get("profession_id", "")) == profession_id:
            return StringName(raw_type)
    return &""

func worker_group_for_profession(profession_id: StringName) -> StringName:
    var building_type := building_type_for_profession(profession_id)
    if building_type == &"":
        return &""
    var definition: Dictionary = DEFINITIONS.get(str(building_type), {})
    return StringName(definition.get("worker_group_id", ""))

func is_building_profession(profession_id: StringName) -> bool:
    return building_type_for_profession(profession_id) != &""

func work_available(state: SimulationState, profession_id: StringName, disciple: DiscipleState = null) -> bool:
    match profession_id:
        PROF_MINING, PROF_FORESTRY:
            var producer := building_for_profession(state, profession_id, disciple)
            return producer != null and (disciple == null or (can_disciple_work(state, producer, disciple) and not disciple_has_active_timed_recipe(state,disciple.id)))
        PROF_ALCHEMY:
            if disciple == null:
                for hall in _buildings_of_type(state, TYPE_ALCHEMY_HALL):
                    if _alchemy_has_startable_worker(state, hall):
                        return true
                return false
            return bool(alchemy_can_start(state, disciple).get("ok", false))
        PROF_HERBALISM:
            if disciple != null:
                var field := _building_for_disciple(state, TYPE_SPIRIT_FIELD, disciple)
                return field != null and can_disciple_work(state, field, disciple) and not disciple_has_active_spirit_plot(state, disciple.id, field) and _field_has_startable_plot(state, field)
            for field in _buildings_of_type(state, TYPE_SPIRIT_FIELD):
                if _field_has_startable_plot(state, field):
                    return true
            return false
        _:
            return true

func disciple_has_active_spirit_plot(state: SimulationState, disciple_id: StringName, field: BuildingState = null) -> bool:
    var fields: Array = []
    if field != null:
        fields = [field]
    elif state.disciples.has(disciple_id):
        var disciple: DiscipleState = state.disciples[disciple_id]
        var field_group := StringName(DEFINITIONS.get(str(TYPE_SPIRIT_FIELD),{}).get("worker_group_id",""))
        if disciple.worksite_building_id != &"":
            var assigned = state.buildings.get(str(disciple.worksite_building_id))
            if assigned is BuildingState:
                if assigned.building_type == TYPE_SPIRIT_FIELD:
                    fields = [assigned]
                elif disciple.work_group_id != field_group:
                    # An explicit worksite in another profession cannot own a
                    # live Spirit Field plot. Avoid rescanning unrelated fields
                    # for every evaluating disciple in a large roster.
                    return false
                else:
                    # Keep the defensive legacy scan for inconsistent group /
                    # worksite pairs instead of hiding a persisted reservation.
                    fields = _buildings_of_type(state,TYPE_SPIRIT_FIELD)
            else:
                fields = _buildings_of_type(state,TYPE_SPIRIT_FIELD)
        elif disciple.work_group_id == field_group and field_group != &"":
            # Empty worksite IDs are assigned only to the primary building by
            # assigned_worker_ids(); inspect that authority directly.
            var primary := primary_building(state,TYPE_SPIRIT_FIELD)
            if primary != null:
                fields = [primary]
        elif disciple.work_group_id != &"":
            return false
        else:
            # Legacy/unassigned states may retain a plot without an explicit
            # crew assignment, so preserve the full lookup for those records.
            fields = _buildings_of_type(state,TYPE_SPIRIT_FIELD)
    else:
        fields = _buildings_of_type(state,TYPE_SPIRIT_FIELD)
    for current_field in fields:
        if current_field == null:
            continue
        var data := _ensure_spirit_field_state(state, current_field)
        for raw_plot in data.get("plots", []):
            if raw_plot is Dictionary and StringName(raw_plot.get("status", "")) == PLOT_GROWING and str(raw_plot.get("assigned_worker_id", "")) == str(disciple_id):
                return true
    return false

func set_spirit_field_policy(state: SimulationState, field_id: StringName, mode: StringName, fixed_crop_id: StringName = &"", priority_weights: Dictionary = {}) -> bool:
    if not state.buildings.has(str(field_id)):
        return false
    var field: BuildingState = state.buildings[str(field_id)]
    if field.building_type != TYPE_SPIRIT_FIELD or not VALID_FIELD_POLICIES.has(mode):
        return false
    if mode != FIELD_POLICY_AUTO_DEMAND and field.level < 10:
        return false
    if mode == FIELD_POLICY_FIXED:
        if not crop_registry.has(fixed_crop_id) or int(crop_registry.definition(fixed_crop_id).get("required_field_level", 1)) > field.level:
            return false
    var data := _ensure_spirit_field_state(state, field)
    var normalized_weights: Dictionary = {}
    if mode == FIELD_POLICY_PRIORITY:
        var keys: Array = priority_weights.keys()
        keys.sort()
        for raw_id in keys:
            var crop_id := StringName(raw_id)
            var weight := maxi(int(priority_weights[raw_id]), 0)
            if weight > 0 and crop_registry.has(crop_id) and int(crop_registry.definition(crop_id).get("required_field_level", 1)) <= field.level:
                normalized_weights[str(crop_id)] = weight
        if normalized_weights.is_empty():
            return false
    data["policy_mode"] = str(mode)
    data["fixed_crop_id"] = str(fixed_crop_id) if mode == FIELD_POLICY_FIXED else ""
    data["priority_weights"] = normalized_weights
    field.production_state = data
    state.building_event_count += 1
    return true

# Player-authored per-plot preference. A growing plot cannot be changed.
# A blank preference delegates to the existing field-wide crop policy.
func set_spirit_plot_crop(state: SimulationState, field_id: StringName, plot_id: StringName, crop_id: StringName) -> Dictionary:
    if state == null or not state.buildings.has(str(field_id)):
        return {"ok":false,"reason":"field_missing"}
    var field: BuildingState = state.buildings[str(field_id)]
    if field.building_type != TYPE_SPIRIT_FIELD:
        return {"ok":false,"reason":"wrong_building"}
    if crop_id != &"" and not crop_registry.eligible_crop_ids(field.level).has(crop_id):
        return {"ok":false,"reason":"crop_locked_or_unknown"}
    var data := _ensure_spirit_field_state(state,field)
    var plot_found := false
    for raw_plot in data.get("plots",[]):
        if raw_plot is Dictionary and str(raw_plot.get("plot_id","")) == str(plot_id):
            if StringName(raw_plot.get("status","")) != PLOT_EMPTY:
                return {"ok":false,"reason":"plot_already_growing"}
            plot_found = true
            break
    if not plot_found:
        return {"ok":false,"reason":"plot_missing"}
    var preferences: Dictionary = data.get("plot_crop_preferences",{}).duplicate(true)
    if crop_id == &"":
        preferences.erase(str(plot_id))
    else:
        preferences[str(plot_id)] = str(crop_id)
    data["plot_crop_preferences"] = preferences
    field.production_state = data
    state.building_event_count += 1
    return {"ok":true,"plot_id":str(plot_id),"crop_id":str(crop_id)}

func cancel_spirit_plot(state: SimulationState, field_id: StringName, plot_id: StringName) -> bool:
    if not state.buildings.has(str(field_id)):
        return false
    var field: BuildingState = state.buildings[str(field_id)]
    if field.building_type != TYPE_SPIRIT_FIELD:
        return false
    var data := _ensure_spirit_field_state(state, field)
    var plots: Array = data.get("plots", [])
    for index in range(plots.size()):
        if str(plots[index].get("plot_id", "")) != str(plot_id):
            continue
        if StringName(plots[index].get("status", "")) != PLOT_GROWING:
            return false
        plots[index] = _empty_plot(str(plot_id))
        data["plots"] = plots
        field.production_state = data
        state.building_event_count += 1
        return true
    return false

func upgrade_cost(building: BuildingState) -> Dictionary:
    if building == null or building.level >= building.max_level:
        return {}
    var definition := definition_for(building)
    var level := float(building.level)
    var factor := 1.0 + 0.15 * level + 0.01 * level * level
    var target_level := building.level + 1
    var milestone_mult := 2.0 if MILESTONE_LEVELS.has(target_level) else 1.0
    var cost := {
        MATERIAL_WOOD: maxi(1, int(ceil(float(definition.get("base_wood_cost", 1)) * factor * milestone_mult))),
        MATERIAL_ORE: maxi(1, int(ceil(float(definition.get("base_ore_cost", 1)) * factor * milestone_mult))),
        "spirit_stones": maxi(1, int(ceil(float(definition.get("base_stone_cost", 1)) * factor * milestone_mult)))
    }
    if MILESTONE_LEVELS.has(target_level):
        var component := _milestone_component(building.building_type, target_level)
        if component != "":
            cost[component] = _milestone_component_quantity(building.building_type, target_level)
    return cost

func upgrade_required_work(building: BuildingState) -> float:
    var definition := definition_for(building)
    var target_level := building.level + 1
    var work := float(definition.get("base_upgrade_work", 8.0)) + float(definition.get("upgrade_work_per_level", 2.0)) * float(target_level)
    if MILESTONE_LEVELS.has(target_level):
        work *= 1.75
    return maxf(work, 1.0)

func can_start_upgrade(state: SimulationState, building_id: StringName) -> Dictionary:
    if not state.p3_7_buildings_enabled or not state.buildings.has(str(building_id)):
        return {"ok": false, "reason": "missing_building"}
    var building: BuildingState = state.buildings[str(building_id)]
    if building.is_upgrading():
        return {"ok": false, "reason": "already_upgrading"}
    if building.status != STATUS_ACTIVE:
        return {"ok": false, "reason": "building_not_active"}
    if building.level >= building.max_level:
        return {"ok": false, "reason": "max_level"}

    # Do not manufacture upgrade economics for facilities whose coefficients
    # and milestone content are not yet authored.
    if not bool(definition_for(building).get("upgrade_enabled", true)):
        return {"ok": false, "reason": "upgrade_content_pending"}
    if building.building_type == TYPE_BODY_TRAINING:
        return {"ok": false, "reason": "body_training_upgrade_content_pending"}
    if SectHallSystemV1.installed(state) and building.building_type != TYPE_MAIN_HALL:
        var governing_hall := SectHallSystemV1.hall(state)
        if governing_hall == null:
            return {"ok": false, "reason": "governing_hall_missing"}
        var max_authorized := mini(100, maxi(10, governing_hall.level * 2 + 8))
        if building.level + 1 > max_authorized:
            return {"ok": false, "reason": "main_hall_level_gate", "maximum": max_authorized}
    var target_level := building.level + 1
    # No authoritative Đại Điện/Tông Môn progression gate exists for Dẫn Tiên
    # above Lv20. Keep the explicitly tested Lv20 threshold reachable, then
    # fail closed without inventing a sect-rank formula or charging a guessed cost.
    if building.building_type == TYPE_GUIDANCE_PLATFORM and target_level > 20:
        return {"ok": false, "reason": "guidance_sect_gate_pending", "target_level": target_level}
    var requires_milestone_component := bool(definition_for(building).get("requires_milestone_component", true))
    if MILESTONE_LEVELS.has(target_level) and requires_milestone_component and _milestone_component(building.building_type, target_level) == "":
        return {"ok": false, "reason": "milestone_component_not_defined", "target_level": target_level}

    var cost := sx_v55_upgrade_cost(state,building)
    # No price envelope is NOT a free upgrade. Also fail closed if the
    # QA-denominated amount cannot fit the canonical Stone limit.
    if cost.is_empty():
        return {"ok":false,"reason":"upgrade_cost_unavailable"}
    var material_ids: Array = cost.keys()
    material_ids.erase("spirit_stones")
    material_ids.sort()
    for material_id in material_ids:
        var need := int(cost.get(material_id, 0))
        var have := _resource_available(state, StringName(material_id))
        if have < need:
            return {"ok": false, "reason": "missing_material", "material_id": str(material_id), "need": need, "have": have}
    var stone_need := int(cost.get("spirit_stones", 0))
    if state.sect.spirit_stones < stone_need:
        return {"ok": false, "reason": "missing_spirit_stones", "need": stone_need, "have": state.sect.spirit_stones}
    return {"ok": true, "cost": cost}

func start_upgrade(state: SimulationState, building_id: StringName, request_id: String = "") -> Dictionary:
    # DD-08: Hall/Residence require an explicit stable request ID; ordinary
    # older P3.7 buildings retain the original no-ID API unchanged.
    # Replay after completion is idempotent, not a second paid next-level action.
    var stored_building = state.buildings.get(str(building_id)) if state != null else null
    var governed: bool = SectHallSystemV1.installed(state) and stored_building is BuildingState \
        and stored_building.building_type in [TYPE_MAIN_HALL, TYPE_RESIDENCE]
    if governed:
        if request_id.is_empty():
            return {"ok": false, "reason": "upgrade_request_id_required"}
        if request_id.length() > 120:
            return {"ok": false, "reason": "upgrade_request_id_too_long"}
        var previous = state.sect.hall_governance.get("upgrade_receipts", {})
        if not (previous is Dictionary):
            return {"ok": false, "reason": "malformed_upgrade_receipts"}
        if previous.has(request_id):
            var prior = previous[request_id]
            if not (prior is Dictionary) or str(prior.get("building_id", "")) != str(building_id):
                return {"ok": false, "reason": "conflicting_upgrade_request"}
            return {"ok": true, "already_settled": true,
                "building_id": str(building_id),
                "target_level": int(prior.get("target_level", 0)),
                "receipt": prior.duplicate(true)}
    var check := can_start_upgrade(state, building_id)
    if not bool(check.get("ok", false)):
        return check
    var building: BuildingState = state.buildings[str(building_id)]
    var cost: Dictionary = check.get("cost", {})
    var material_requirements := cost.duplicate(true)
    material_requirements.erase("spirit_stones")
    if not _consume_resources(state, material_requirements):
        return {"ok": false, "reason": "materials_changed"}
    state.sect.spirit_stones -= int(cost.get("spirit_stones", 0))

    building.status = STATUS_UPGRADING
    building.upgrade_target_level = building.level + 1
    building.upgrade_started_tick = state.tick
    building.upgrade_required_work = upgrade_required_work(building)
    building.upgrade_progress = 0.0
    state.building_event_count += 1
    if governed:
        var receipts: Dictionary = state.sect.hall_governance.get("upgrade_receipts", {}).duplicate(true)
        receipts[request_id] = {
            "building_id": str(building.id),
            "target_level": building.upgrade_target_level,
            "started_tick": state.tick,
            "cost": cost.duplicate(true)
        }
        state.sect.hall_governance["upgrade_receipts"] = receipts
    return {
        "ok": true,
        "building_id": str(building.id),
        "target_level": building.upgrade_target_level,
        "required_work": building.upgrade_required_work,
        "cost": cost.duplicate(true)
    }

func process_tick(state: SimulationState) -> void:
    if not state.p3_7_buildings_enabled:
        return
    # ECO-01 uses the existing Hall BuildingState and scheduler clock. Run
    # only once per authoritative simulation tick, including offline replay.
    if state.sect.economy_a_enabled:
        Eco01OriginVein.new().process_tick(state)
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if not (building is BuildingState):
            continue
        if building.status == STATUS_CONSTRUCTING and building.building_type == TYPE_RESIDENCE:
            SectResidenceSystemV1.complete_due_construction(state, building)
        if building.is_upgrading():
            building.upgrade_progress += 1.0
            if building.upgrade_progress + 0.000001 >= building.upgrade_required_work:
                _complete_upgrade(state, building)
        if building.building_type == TYPE_SPIRIT_FIELD:
            _process_spirit_field_plots(state, building)
        elif building.building_type == TYPE_ALCHEMY_HALL:
            _process_alchemy_jobs(state, building)
        if state.sect.economy_a_enabled and (building.building_type == TYPE_MINE or building.building_type == TYPE_LINH_FOREST):
            _process_resource_timers(state,building)

func _default_alchemy_state() -> Dictionary:
    return {"recipe_enabled": true, "recipe_id": str(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN), "job_sequence": 0, "jobs": []}

func _ensure_alchemy_state(hall: BuildingState) -> Dictionary:
    if hall == null or hall.building_type != TYPE_ALCHEMY_HALL:
        return {}
    var raw := hall.production_state
    var data: Dictionary = raw.duplicate(true) if raw is Dictionary else {}
    data["recipe_enabled"] = bool(data.get("recipe_enabled", true))
    var recipe_id := StringName(data.get("recipe_id", str(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN)))
    if not alchemy_registry.has(recipe_id):
        recipe_id = AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN
    data["recipe_id"] = str(recipe_id)
    data["job_sequence"] = maxi(int(data.get("job_sequence", 0)), 0)
    var jobs: Array = []
    var seen_workers: Dictionary = {}
    var raw_jobs = data.get("jobs", [])
    if raw_jobs is Array:
        for raw_job in raw_jobs:
            if not (raw_job is Dictionary):
                continue
            var worker_id := str(raw_job.get("worker_id", ""))
            var job_id := str(raw_job.get("job_id", ""))
            var current_recipe := StringName(raw_job.get("recipe_id", ""))
            if worker_id == "" or job_id == "" or seen_workers.has(worker_id) or not alchemy_registry.has(current_recipe):
                continue
            var started_tick := int(raw_job.get("started_tick", 0))
            var finish_tick := int(raw_job.get("finish_tick", started_tick + 1))
            if finish_tick <= started_tick:
                continue
            var inputs_raw = raw_job.get("inputs", {})
            var inputs: Dictionary = inputs_raw.duplicate(true) if inputs_raw is Dictionary else {}
            jobs.append({
                "job_id": job_id,
                "recipe_id": str(current_recipe),
                "worker_id": worker_id,
                "started_tick": started_tick,
                "finish_tick": finish_tick,
                "inputs": inputs,
                "output_resource_id": str(raw_job.get("output_resource_id", alchemy_registry.output_resource_id(current_recipe))),
                "output_quantity": maxi(int(raw_job.get("output_quantity", alchemy_registry.output_quantity(current_recipe))), 1),
                "profession_xp_gain": maxf(float(raw_job.get("profession_xp_gain", 0.0)), 0.0),
                "economy_a_wage_eligible": bool(raw_job.get("economy_a_wage_eligible", false))
            })
            seen_workers[worker_id] = true
    data["jobs"] = jobs
    hall.production_state = data
    return data

func alchemy_jobs(state: SimulationState, hall: BuildingState = null) -> Array:
    var target := hall if hall != null else primary_building(state, TYPE_ALCHEMY_HALL)
    if target == null:
        return []
    return Array(_ensure_alchemy_state(target).get("jobs", [])).duplicate(true)

# V5.7 P0: a read-only snapshot of in-flight job ownership. Rebuild after
# any authoritative building mutation, on a new minute, or on a new state.
# The cache is NOT serialized and never settles resources or wages.
var _timed_job_cache_state_id: int = -1
var _timed_job_cache_tick: int = -1
var _timed_job_cache_building_revision: int = -1
var _timed_job_cache_building_count: int = -1
var _timed_alchemy_by_worker: Dictionary = {}
var _timed_resource_by_worker: Dictionary = {}

func _refresh_timed_job_index(state: SimulationState) -> void:
    if (
        _timed_job_cache_state_id == state.get_instance_id()
        and _timed_job_cache_tick == state.tick
        and _timed_job_cache_building_revision == state.building_event_count
        and _timed_job_cache_building_count == state.buildings.size()
    ):
        return
    var alchemy: Dictionary = {}
    var resource: Dictionary = {}
    # Keep historical building iteration order when resolving malformed
    # duplicate job owners; do not change source transaction semantics.
    for raw_site in state.buildings.values():
        if not (raw_site is BuildingState):
            continue
        var site: BuildingState = raw_site
        if site.building_type == TYPE_ALCHEMY_HALL:
            for raw_job in alchemy_jobs(state, site):
                if not (raw_job is Dictionary):
                    continue
                var key := str(raw_job.get("worker_id", ""))
                if not key.is_empty() and not alchemy.has(key):
                    alchemy[key] = raw_job.duplicate(true)
        elif state.sect.economy_a_enabled and site.building_type in [TYPE_MINE, TYPE_LINH_FOREST]:
            for raw_job in resource_timer_jobs(site):
                if not (raw_job is Dictionary):
                    continue
                var key := str(raw_job.get("worker_id", ""))
                if not key.is_empty() and not resource.has(key):
                    resource[key] = raw_job.duplicate(true)
    _timed_alchemy_by_worker = alchemy
    _timed_resource_by_worker = resource
    _timed_job_cache_state_id = state.get_instance_id()
    _timed_job_cache_tick = state.tick
    _timed_job_cache_building_revision = state.building_event_count
    _timed_job_cache_building_count = state.buildings.size()

func active_alchemy_job_for_worker(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if state.disciples.size() >= WORKSITE_INDEX_MIN_ROSTER:
        _refresh_timed_job_index(state)
        return _timed_alchemy_by_worker.get(str(disciple_id), {}).duplicate(true)
    for hall in _buildings_of_type(state, TYPE_ALCHEMY_HALL):
        for raw_job in alchemy_jobs(state, hall):
            if raw_job is Dictionary and str(raw_job.get("worker_id", "")) == str(disciple_id):
                return (raw_job as Dictionary).duplicate(true)
    return {}

func disciple_has_active_timed_recipe(state: SimulationState, disciple_id: StringName) -> bool:
    return not active_alchemy_job_for_worker(state, disciple_id).is_empty() or not active_resource_timer_for_worker(state, disciple_id).is_empty()

# Selection affects future jobs only; running jobs retain their frozen recipe.
func set_alchemy_recipe(state: SimulationState, hall_id: StringName, recipe_id: StringName) -> bool:
    if not state.buildings.has(str(hall_id)) or not alchemy_registry.has(recipe_id): return false
    var hall: BuildingState = state.buildings[str(hall_id)]
    if hall.building_type != TYPE_ALCHEMY_HALL: return false
    var data := _ensure_alchemy_state(hall)
    data["recipe_id"] = str(recipe_id)
    hall.production_state = data
    # Explicit recipe selection (including existing B3 craft command) is fixed.
    # The new demand planner never overrides a user's selected recipe.
    if SX01PillPolicy.active(state):
        SX01PillPolicy.configure(state, "recipe_mode", "fixed")
    state.building_event_count += 1
    return true

func set_alchemy_recipe_enabled(state: SimulationState, hall_id: StringName, enabled: bool) -> bool:
    if not state.buildings.has(str(hall_id)):
        return false
    var hall: BuildingState = state.buildings[str(hall_id)]
    if hall.building_type != TYPE_ALCHEMY_HALL:
        return false
    var data := _ensure_alchemy_state(hall)
    data["recipe_enabled"] = enabled
    hall.production_state = data
    state.building_event_count += 1
    return true

# V5.7 explicit quality mode is opt-in per real Alchemy Hall. Zero keeps
# old save behavior; grades 1..4 craft 36+ profession bonus in 3 base minutes.
# Rare catalysts are actual Warehouse IDs with earned/paid source routes.
const V57_QUALITY_HALL_LEVEL := [1,5,10,20]
const V57_QUALITY_PROF_LEVEL := [0,2,5,10]
const V57_QUALITY_CATALYSTS := {
    1:{},
    2:{"tu_van_thao":1},
    3:{"huyen_thiet":1,"linh_tuy":1},
    # Never consume Linh Tuyen Heart fragments meant for Field milestones.
    4:{"tu_van_thao":2,"huyen_thiet":2,"tinh_lang_bi":1}
}

func set_alchemy_quality(state: SimulationState, hall_id: StringName, quality: int) -> Dictionary:
    if state == null or quality < 0 or quality > 4 or not state.buildings.has(str(hall_id)):
        return {"ok":false,"reason":"invalid_quality_selection"}
    var hall: BuildingState = state.buildings[str(hall_id)]
    if hall.building_type != TYPE_ALCHEMY_HALL:
        return {"ok":false,"reason":"wrong_building_type"}
    var data := _ensure_alchemy_state(hall)
    var recipe := StringName(data.get("recipe_id",""))
    if quality > 0 and MedicineCatalogueV2.parse_recipe(recipe).is_empty():
        return {"ok":false,"reason":"quality_requires_graded_recipe"}
    if quality > 0 and hall.level < int(V57_QUALITY_HALL_LEVEL[quality-1]):
        return {"ok":false,"reason":"quality_requires_hall_upgrade"}
    data["v57_selected_quality"] = quality
    hall.production_state = data
    if SX01PillPolicy.active(state):
        SX01PillPolicy.configure(state,"recipe_mode","fixed")
    state.building_event_count += 1
    return {"ok":true,"selected_quality":quality}

func _v57_alchemy_plan(state: SimulationState, hall: BuildingState,
        recipe_id: StringName, profession_level: int) -> Dictionary:
    var requirements := alchemy_registry.inputs(recipe_id)
    var requested := int(hall.production_state.get("v57_selected_quality",0))
    if requested == 0:
        var output := alchemy_registry.output_resource_id(recipe_id)
        var parsed_legacy_mode := MedicineCatalogueV2.parse_recipe(recipe_id)
        if not parsed_legacy_mode.is_empty():
            # New jobs must explicitly pay catalysts for Q2-Q4, never receive
            # automatically promoted high-grade outputs from a Q1 ingredient BOM.
            output = MedicineCatalogueV2.item_id(
                str(parsed_legacy_mode["family"]),int(parsed_legacy_mode["realm"]),1)
        return {"ok":true,"requirements":sx_v55_common_requirements(state,requirements),
            "output_quantity":alchemy_registry.output_quantity(recipe_id),
            "cycle_ticks":alchemy_registry.base_cycle_ticks(recipe_id),
            "output_resource_id":str(output)}
    var parsed := MedicineCatalogueV2.parse_recipe(recipe_id)
    if parsed.is_empty() or requested < 1 or requested > 4:
        return {"ok":false,"reason":"invalid_quality_recipe"}
    if hall.level < int(V57_QUALITY_HALL_LEVEL[requested-1])             or profession_level < int(V57_QUALITY_PROF_LEVEL[requested-1]):
        return {"ok":false,"reason":"quality_not_unlocked"}
    # V5.6-G grade-mode BOM: 36 output pills consume earned mineral/wood
    # as well as herbs, unlike the historical one-pill recipe.
    if str(parsed["family"]) == MedicineCatalogueV2.FAMILY_HEAL:
        requirements["linh_moc"] = int(requirements.get("linh_moc",0))+1
    elif str(parsed["family"]) == MedicineCatalogueV2.FAMILY_TUVI:
        requirements["thanh_thiet"] = int(requirements.get("thanh_thiet",0))+2
        requirements["linh_moc"] = int(requirements.get("linh_moc",0))+1
    for raw_id in V57_QUALITY_CATALYSTS[requested].keys():
        requirements[raw_id] = int(requirements.get(raw_id,0)) + int(V57_QUALITY_CATALYSTS[requested][raw_id])
    var result_id := MedicineCatalogueV2.item_id(str(parsed["family"]),int(parsed["realm"]),requested)
    if result_id == &"":
        return {"ok":false,"reason":"quality_output_missing"}
    return {
        "ok":true,"requirements":sx_v55_common_requirements(state,requirements),
        "output_resource_id":str(result_id),
        "output_quantity":(6 if str(parsed["family"]) == MedicineCatalogueV2.FAMILY_BREAK else 36) + (
            int(profession_level/20) if str(parsed["family"]) == MedicineCatalogueV2.FAMILY_BREAK
            else 3*int(profession_level/10)
        ),
        "cycle_ticks":3,
        "selected_quality":requested
    }

# SX-07 cost estimate for QA/UI, not a second price authority. Uses
# ResourceRegistry resale reference values and the current actual wage policy.
# Field planting, opportunity costs, tax and NPC buy premium are EXCLUDED.
# Never use it to credit money or to authorize a recipe.
func alchemy_batch_cost_reference(state: SimulationState, hall_id: StringName,
        recipe_id: StringName, profession_level: int) -> Dictionary:
    if state == null or not state.buildings.has(str(hall_id)):
        return {"ok":false,"reason":"unknown_hall"}
    var hall: BuildingState = state.buildings[str(hall_id)]
    if hall.building_type != TYPE_ALCHEMY_HALL or not alchemy_registry.has(recipe_id):
        return {"ok":false,"reason":"unavailable_recipe"}
    var plan := _v57_alchemy_plan(state,hall,recipe_id,profession_level)
    if not bool(plan.get("ok",false)):
        return plan
    var proof := MedicineResourceSourceV1.routes_for_requirements(plan.get("requirements",{}))
    if not bool(proof.get("ok",false)):
        return {"ok":false,"reason":"unverified_source",
            "ingredient_id":str(proof.get("ingredient_id",""))}
    var resources := ResourceRegistry.new()
    var material_value := 0
    var unpriced: Array[String] = []
    for id in plan["requirements"].keys():
        var amount := int(plan["requirements"][id])
        var reference := int(resources.definition(StringName(id)).get("market_value",0))
        if amount <= 0:
            return {"ok":false,"reason":"invalid_bom_quantity"}
        if reference <= 0:
            unpriced.append(str(id))
        else:
            material_value += amount*reference
    var wage := maxi(int(state.sect.economy_a_policy.get("wage_per_batch",2)),0) \
        if state.sect.economy_a_enabled else 0
    var quantity := int(plan.get("output_quantity",0))
    if quantity <= 0:
        return {"ok":false,"reason":"invalid_output_quantity"}
    return {"ok":unpriced.is_empty(),"pricing_status":"REFERENCE_ONLY" if unpriced.is_empty() else "MISSING_REFERENCE_PRICES",
        "missing_reference_prices":unpriced,
        "materials_reference_lt":material_value,"wage_policy_lt":wage,
        "total_reference_lt":material_value+wage,
        "output_quantity":quantity,"per_pill_reference_lt":float(material_value+wage)/float(quantity),
        "cycle_ticks":int(plan.get("cycle_ticks",0)),
        "source_provenance":proof,
        "excludes":["crop_planting_stones","opportunity_cost","tax","npc_buy_premium"]}

func alchemy_can_start(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if disciple == null or disciple.region_id != &"sect":
        return {"ok": false, "reason": "invalid_worker"}
    var hall := _building_for_disciple(state, TYPE_ALCHEMY_HALL, disciple)
    if hall == null or not can_disciple_work(state, hall, disciple):
        return {"ok": false, "reason": "no_active_alchemy_slot"}
    var data := _ensure_alchemy_state(hall)
    if not bool(data.get("recipe_enabled", true)):
        return {"ok": false, "reason": "recipe_policy_disabled"}
    if disciple_has_active_timed_recipe(state, disciple.id):
        return {"ok": false, "reason": "worker_busy_alchemy"}
    var recipe_id := SX01PillPolicy.planned_recipe(state, hall) if SX01PillPolicy.active(state) else StringName(data.get("recipe_id", str(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN)))
    if recipe_id == &"":
        return {"ok": false, "reason": "sx01_target_or_ingredients_unavailable"}
    if hall.level < alchemy_registry.required_hall_level(recipe_id):
        return {"ok": false, "reason": "alchemy_hall_level_too_low"}
    # The availability read-model and the actual work transaction must enforce
    # the SAME profession gate. Otherwise tier-2 recipes appear actionable for
    # an untrained worker, only to be rejected after the player presses WORK.
    var profession_level := WorkforceSystem.new().profession_level_for_state(state, disciple, PROF_ALCHEMY)
    if profession_level < alchemy_registry.required_profession_level(recipe_id):
        return {"ok": false, "reason": "profession_level_too_low"}
    var plan := _v57_alchemy_plan(state,hall,recipe_id,profession_level)
    if not bool(plan.get("ok",false)):
        return plan
    var requirements: Dictionary = plan["requirements"]
    # Source gate for new batches: even a QA-injected Warehouse stack cannot
    # authorize a recipe with an orphan, unproven ingredient. Old pending
    # jobs settle from their original frozen transaction, unchanged.
    if not MedicineCatalogueV2.parse_recipe(recipe_id).is_empty():
        var proof := MedicineResourceSourceV1.routes_for_requirements(requirements)
        if not bool(proof.get("ok",false)):
            return {"ok":false,"reason":"recipe_source_unavailable",
                "ingredient_id":str(proof.get("ingredient_id",""))}
    if not warehouse.can_consume_requirements(state,requirements):
        return {"ok": false, "reason": "insufficient_or_reserved_inputs"}
    return {"ok": true, "hall_id": str(hall.id), "recipe_id": str(recipe_id),
        "requirements": requirements,"plan":plan}

func perform_alchemy_step(state: SimulationState, disciple: DiscipleState, profession_level: int, work_speed: float, profession_xp_gain: float) -> Dictionary:
    var check := alchemy_can_start(state, disciple)
    if not bool(check.get("ok", false)):
        return {"ok": false, "completed": false, "reason": str(check.get("reason", "cannot_start"))}
    var hall: BuildingState = state.buildings[str(check.get("hall_id", ""))]
    var data := _ensure_alchemy_state(hall)
    var recipe_id := StringName(check.get("recipe_id", ""))
    if profession_level < alchemy_registry.required_profession_level(recipe_id):
        return {"ok": false, "completed": false, "reason": "profession_level_too_low"}
    var requirements: Dictionary = check.get("requirements", {}).duplicate(true)
    if not warehouse.consume_requirements(state, requirements):
        return {"ok": false, "completed": false, "reason": "input_commit_failed"}
    # Only the newly committed job uses this choice; older snapshots keep their
    # recipe_id/output and cannot change when the next target changes.
    if str(data.get("recipe_id", "")) != str(recipe_id):
        data["recipe_id"] = str(recipe_id)
    var sequence := int(data.get("job_sequence", 0)) + 1
    var alchemy_factor := 1.0 - SectHallSystemV1.role_effect(state, SectHallSystemV1.OFFICE_ALCHEMIST)
    var plan: Dictionary = check.get("plan",{})
    var duration := maxi(1,int(ceil(float(plan.get("cycle_ticks",alchemy_registry.base_cycle_ticks(recipe_id))) * alchemy_factor / maxf(work_speed,0.25))))
    var output_id := StringName(plan.get("output_resource_id",""))
    if output_id == &"":
        output_id = alchemy_registry.output_resource_id(recipe_id)
    var job := {
        "job_id": "%s_job_%06d" % [str(hall.id), sequence],
        "recipe_id": str(recipe_id),
        "worker_id": str(disciple.id),
        "started_tick": state.tick,
        "finish_tick": state.tick + duration,
        "inputs": requirements.duplicate(true),
        "output_resource_id": str(output_id),
        "output_quantity": int(plan.get("output_quantity",alchemy_registry.output_quantity(recipe_id))),
        "profession_xp_gain": maxf(profession_xp_gain, 0.0),
        "economy_a_wage_eligible": state.sect.economy_a_enabled and DiscipleRealmProgressV2.owns_v2_progression(disciple)
    }
    var jobs: Array = data.get("jobs", [])
    jobs.append(job)
    data["jobs"] = jobs
    data["job_sequence"] = sequence
    hall.production_state = data
    state.building_event_count += 1
    return {"ok": true, "completed": false, "started": true, "job": job.duplicate(true), "building_id": str(hall.id), "finish_tick": int(job["finish_tick"])}

func _alchemy_has_startable_worker(state: SimulationState, hall: BuildingState) -> bool:
    for worker_id in active_worker_ids(state, hall):
        if state.disciples.has(worker_id) and bool(alchemy_can_start(state, state.disciples[worker_id]).get("ok", false)):
            return true
    return false

func _process_alchemy_jobs(state: SimulationState, hall: BuildingState) -> void:
    var data := _ensure_alchemy_state(hall)
    var jobs: Array = data.get("jobs", [])
    if jobs.is_empty():
        return
    var remaining: Array = []
    var changed := false
    for raw_job in jobs:
        var job: Dictionary = raw_job
        if state.tick < int(job.get("finish_tick", state.tick + 1)):
            remaining.append(job)
            continue
        var output_id := StringName(job.get("output_resource_id", ""))
        var output_quantity := maxi(int(job.get("output_quantity", 0)), 0)
        if output_id == &"" or output_quantity <= 0 or not _deposit_resource(state, hall, str(output_id), output_quantity):
            remaining.append(job)
            continue
        var worker_id := StringName(job.get("worker_id", ""))
        if state.disciples.has(worker_id):
            var worker: DiscipleState = state.disciples[worker_id]
            var xp_gain := maxf(float(job.get("profession_xp_gain", 0.0)), 0.0)
            if xp_gain > 0.0:
                worker.profession_xp[str(PROF_ALCHEMY)] = float(worker.profession_xp.get(str(PROF_ALCHEMY), 0.0)) + xp_gain
            worker.metrics["work_completions"] = int(worker.metrics.get("work_completions", 0)) + 1
            worker.metrics["alchemy_completions"] = int(worker.metrics.get("alchemy_completions", 0)) + 1
            state.sect.workforce_event_count += 1
            if state.sect.economy_a_enabled and bool(job.get("economy_a_wage_eligible", false)):
                EconomySystem.new().settle_work_wage(state, worker, str(job.get("job_id", "")))
        changed = true
    if changed:
        data["jobs"] = remaining
        hall.production_state = data
        state.building_event_count += 1

func perform_mining_step(state: SimulationState, disciple: DiscipleState, work_speed: float, profession_xp_gain: float = 0.0) -> Dictionary:
    return perform_resource_job_step(state, disciple, work_speed, PROF_MINING, profession_xp_gain)

func perform_forestry_step(state: SimulationState, disciple: DiscipleState, work_speed: float, profession_xp_gain: float = 0.0) -> Dictionary:
    return perform_resource_job_step(state, disciple, work_speed, PROF_FORESTRY, profession_xp_gain)

# Generic carry-cycle producer used by Mine and Linh Lâm. Spirit Field remains
# plot/timer authority and intentionally does not use this envelope.
func perform_resource_job_step(state: SimulationState, disciple: DiscipleState, work_speed: float, profession_id: StringName, profession_xp_gain: float = 0.0) -> Dictionary:
    var producer := building_for_profession(state, profession_id, disciple)
    if producer == null or not can_disciple_work(state, producer, disciple):
        var slot_reason := "no_active_building_slot"
        if profession_id == PROF_MINING:
            slot_reason = "no_active_mine_slot"
        elif profession_id == PROF_FORESTRY:
            slot_reason = "no_active_linh_forest_slot"
        return {"ok": false, "completed": false, "reason": slot_reason}

    # Old TRAVEL/EXTRACT/HAUL cycles drain to canonical Warehouse without
    # resetting carried_units. Only *new* V2 jobs use the opt-in timer.
    if state.sect.economy_a_enabled and DiscipleRealmProgressV2.owns_v2_progression(disciple) and disciple.work_cycle_state.is_empty():
        return _start_resource_timer(state,producer,disciple,work_speed,profession_id,profession_xp_gain)
    var definition := definition_for(producer)
    if str(definition.get("job_model", "")) != "carry_cycle":
        return {"ok": false, "completed": false, "reason": "unsupported_job_model"}

    var phases = definition.get("cycle_phases", [])
    if not (phases is Array) or phases.size() < 3:
        return {"ok": false, "completed": false, "reason": "invalid_job_definition"}
    var start_phase := StringName(phases[0])
    var work_phase := StringName(definition.get("cycle_work_phase", ""))
    var resource_id := mine_selected_ore(producer) if producer.building_type == TYPE_MINE else forest_selected_material(producer)
    if work_phase == &"" or resource_id == &"":
        return {"ok": false, "completed": false, "reason": "invalid_job_definition"}

    var cycle := disciple.work_cycle_state.duplicate(true)
    var cycle_profession := StringName(cycle.get("profession_id", cycle.get("profession", "")))
    if cycle_profession != profession_id or str(cycle.get("building_id", "")) != str(producer.id):
        cycle = {
            "profession": str(profession_id),
            "profession_id": str(profession_id),
            "building_id": str(producer.id),
            "resource_id": str(resource_id),
            "phase": str(start_phase),
            "progress": 0.0,
            "carried_units": 0
        }
    else:
        # Preserve the ore being carried when the next-cycle selection changes.
        # A legacy cycle without resource_id still defaults to canonical ore.
        resource_id = StringName(cycle.get("resource_id", str(resource_id)))
        cycle["profession"] = str(profession_id)
        cycle["profession_id"] = str(profession_id)
        cycle["resource_id"] = str(resource_id)

    var phase := StringName(cycle.get("phase", str(start_phase)))
    var progress := maxf(float(cycle.get("progress", 0.0)), 0.0)
    var result := {
        "ok": true,
        "completed": false,
        "phase": str(phase),
        "profession_id": str(profession_id),
        "building_id": str(producer.id),
        "resource_id": str(resource_id),
        "stamina_cost": 1.0
    }

    if phase == &"travel_out":
        progress += _movement_speed(state, disciple)
        if progress + 0.000001 >= float(definition.get("work_distance", 8.0)):
            phase = work_phase
            progress = 0.0
    elif phase == work_phase:
        progress += maxf(work_speed, 0.25)
        result["stamina_cost"] = 3.0
        if progress + 0.000001 >= _resource_job_duration(producer):
            phase = &"haul_back"
            progress = 0.0
            cycle["carried_units"] = mine_ore_batch_units(producer, resource_id) if producer.building_type == TYPE_MINE else forest_material_batch_units(producer,resource_id)
    elif phase == &"haul_back":
        progress += _movement_speed(state, disciple) * _haul_speed_multiplier(disciple)
        if progress + 0.000001 >= float(definition.get("haul_distance", 6.0)):
            var produced := maxi(int(cycle.get("carried_units", 0)), 1)
            _deposit_resource(state, producer, str(resource_id), produced)
            phase = &"complete"
            progress = 0.0
            cycle["carried_units"] = 0
            result["completed"] = true
            result["produced"] = produced
            result["deposited_to"] = "sect_main_warehouse"
    else:
        phase = start_phase
        progress = 0.0
        cycle["carried_units"] = 0

    result["next_phase"] = str(phase)
    result["progress"] = progress
    if bool(result.get("completed", false)):
        disciple.work_cycle_state.clear()
    else:
        cycle["phase"] = str(phase)
        cycle["progress"] = progress
        disciple.work_cycle_state = cycle
    return result

func perform_spirit_field_step(state: SimulationState, disciple: DiscipleState, work_speed: float, learning_factor: float = 1.0) -> Dictionary:
    var field := _building_for_disciple(state, TYPE_SPIRIT_FIELD, disciple)
    if field == null or not can_disciple_work(state, field, disciple):
        return {"ok": false, "completed": false, "reason": "no_active_spirit_field_slot"}
    if disciple_has_active_spirit_plot(state, disciple.id, field):
        return {"ok": false, "completed": false, "reason": "worker_already_has_plot"}

    var data := _ensure_spirit_field_state(state, field)
    var plots: Array = data.get("plots", [])
    var planned := _first_startable_spirit_plot(state,field,data)
    if planned.is_empty():
        return {"ok": false, "completed": false, "reason": "no_affordable_or_needed_crop"}
    var plot_index := int(planned.get("index",-1))
    var crop_id := StringName(planned.get("crop_id",""))

    # ECO-03: use the exact authored crop cost. A failed preflight cannot
    # debit cash, reserve a plot or leave an orphan seed receipt.
    var seed_preflight := EconomySystem.new().field_seed_preflight_v1(state,crop_id)
    if not bool(seed_preflight.get("ok",false)):
        return {"ok":false,"completed":false,
            "reason":str(seed_preflight.get("reason","invalid_field_seed"))}
    var plant_cost := int(seed_preflight.get("cost",0))
    var plant_sequence := int(data.get("plant_sequence",0))+1
    var seed_receipt_id := "field-seed:%s:%d" % [str(field.id),plant_sequence]
    if state.sect.economy_a_enabled and state.sect.economy_a_receipts.has(seed_receipt_id):
        return {"ok":false,"completed":false,"reason":"duplicate_field_seed_sequence"}
    var bulk_crop_plan := sx_v55_plan(state,field,crop_id)

    state.sect.spirit_stones -= plant_cost
    var affinity := _crop_affinity_factor(disciple, crop_id)
    var total_speed := maxf(work_speed, 0.25) * spirit_field_speed_factor(field) * affinity
    var base_crop_cycle := int(bulk_crop_plan.get("cycle_ticks",crop_registry.base_cycle_ticks(crop_id)))
    var base_crop_yield := int(bulk_crop_plan.get("yield",crop_registry.base_yield(crop_id)))
    var duration := maxi(1, int(ceil(float(base_crop_cycle) * spirit_field_cycle_time_factor(field) / total_speed)))
    var routine_yield := maxi(1, int(round(float(base_crop_yield) * spirit_field_yield_factor(field))))
    var base_crop_xp := crop_registry.base_work_xp(crop_id)
    if not bulk_crop_plan.is_empty():
        # 49 EXP/active hour baseline; one XP receipt after real harvest.
        base_crop_xp = 49.0 * float(base_crop_cycle) / 60.0
    var rare_factor := profession_modifiers.rare_event_factor(state, disciple)
    var plot_id := str(plots[plot_index].get("plot_id", "plot_%03d" % [plot_index + 1]))

    plots[plot_index] = {
        "plot_id": plot_id,
        "crop_id": str(crop_id),
        "status": str(PLOT_GROWING),
        "started_tick": state.tick,
        "finish_tick": state.tick + duration,
        "assigned_worker_id": str(disciple.id),
        "paid_spirit_stones": plant_cost,
        "routine_yield": routine_yield,
        "production_plan_id": str(bulk_crop_plan.get("plan_id","")),
        "rare_factor": rare_factor,
        "economy_a_wage_job_id": "%s_plot_%06d" % [str(field.id), plant_sequence] if state.sect.economy_a_enabled and DiscipleRealmProgressV2.owns_v2_progression(disciple) else "",
        # New plots lock exact EXP at sowing, but credit it only after real
        # output reaches Warehouse. Legacy in-flight plots lack this key and
        # have already credited EXP at sowing; do not reward them twice.
        "profession_xp_gain": base_crop_xp * maxf(learning_factor,0.0) * spirit_field_xp_factor(field)
    }
    if not bulk_crop_plan.is_empty():
        var cash_snapshot := EconomySystem.new().sx_v55_r12_work_snapshot(
            state,disciple,field.building_type,str(bulk_crop_plan.get("plan_id","")),duration)
        if not cash_snapshot.is_empty():
            var frozen_plot: Dictionary = plots[plot_index]
            frozen_plot["sx_v55_r12_work"] = cash_snapshot
            plots[plot_index] = frozen_plot
    data["plots"] = plots
    data["plant_sequence"] = plant_sequence
    field.production_state = data
    state.building_event_count += 1
    if state.sect.economy_a_enabled:
        # The plot's paid_spirit_stones is temporary while growing. Keep
        # permanent, exactly-once seed cost evidence after actual harvest.
        # Never backfill this into old/in-flight saves or charge twice.
        state.sect.economy_a_receipts[seed_receipt_id] = {
            "kind":"field_seed","site_id":str(field.id),
            "plot_id":plot_id,"crop_id":str(crop_id),
            "worker_id":str(disciple.id),"cost":plant_cost,
            "wage_due_estimate":int(seed_preflight.get("wage_due_estimate",0)),
            "day":int(state.tick/EconomySystem.V2_DAY_TICKS),"tick":state.tick
        }
        state.sect.economy_a_event_count += 1

    return {
        "ok": true,
        "started": true,
        "completed": false,
        "work_kind": "start_crop",
        "building_id": str(field.id),
        "plot_id": plot_id,
        "crop_id": str(crop_id),
        "finish_tick": state.tick + duration,
        "paid_spirit_stones": plant_cost,
        "base_work_xp": base_crop_xp,
        "field_xp_factor": spirit_field_xp_factor(field),
        "xp_gain_pending": base_crop_xp * maxf(learning_factor,0.0) * spirit_field_xp_factor(field),
        "stamina_cost": 0.0
    }

# ECONOMY-A duration/quantity pilot; real authority = saved building jobs +
# the existing SimulationScheduler.process_tick. Animations never settle goods.
func resource_timer_jobs(building: BuildingState) -> Array:
    if building == null:
        return []
    var value = building.production_state.get("economy_a_jobs",[])
    return value.duplicate(true) if value is Array else []

func active_resource_timer_for_worker(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not state.sect.economy_a_enabled:
        return {}
    if state.disciples.size() >= WORKSITE_INDEX_MIN_ROSTER:
        _refresh_timed_job_index(state)
        return _timed_resource_by_worker.get(str(disciple_id), {}).duplicate(true)
    for raw_building in state.buildings.values():
        if not (raw_building is BuildingState):
            continue
        var building: BuildingState = raw_building
        if building.building_type != TYPE_MINE and building.building_type != TYPE_LINH_FOREST:
            continue
        for raw_job in resource_timer_jobs(building):
            if raw_job is Dictionary and str(raw_job.get("worker_id","")) == str(disciple_id):
                return (raw_job as Dictionary).duplicate(true)
    return {}

func _start_resource_timer(state: SimulationState, producer: BuildingState, actor: DiscipleState, speed: float, profession_id: StringName, xp_gain: float) -> Dictionary:
    if not state.sect.p3_7_resources_enabled or not can_disciple_work(state,producer,actor):
        return {"ok":false,"reason":"missing_canonical_job_slot"}
    if disciple_has_active_timed_recipe(state,actor.id) or disciple_has_active_spirit_plot(state,actor.id) or actor.work_group_id == &"body_training_crew":
        return {"ok":false,"reason":"another_active_job"}
    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"worker_not_available"}
    var definition := definition_for(producer)
    if StringName(definition.get("profession_id","")) != profession_id:
        return {"ok":false,"reason":"wrong_job_profession"}
    var policy := state.sect.economy_a_policy
    var base_duration := clampi(int(policy.get("resource_duration_ticks",10)),1,1440)
    var selected_resource := mine_selected_ore(producer) if producer.building_type == TYPE_MINE else forest_selected_material(producer)
    var bulk_plan := sx_v55_plan(state,producer,selected_resource)
    if not bulk_plan.is_empty():
        base_duration = int(bulk_plan.get("cycle_ticks",base_duration))
    var steward_factor := 1.0 - SectHallSystemV1.role_effect(state, SectHallSystemV1.OFFICE_STEWARD)
    # Apply the same level-dependent extraction speed in both old carry-cycle
    # and new V2 timer jobs. Pin the resulting duration at job creation so
    # upgrades never retroactively shorten an already paid/started timer.
    var raw_work_duration := maxf(float(definition.get("base_work_duration", 4.0)), 0.1)
    var building_time_factor := _resource_job_duration(producer) / raw_work_duration
    var duration := maxi(1,int(ceil(float(base_duration) * building_time_factor * steward_factor / maxf(speed,0.25))))
    var output_units := mine_ore_batch_units(producer,selected_resource) if producer.building_type == TYPE_MINE else forest_material_batch_units(producer,selected_resource)
    if not bulk_plan.is_empty():
        # Same normal +0.5% per facility level; old jobs retain their snapshots.
        output_units = maxi(1,int(round(float(bulk_plan.get("yield",0)) * (
            1.0 + 0.005 * float(maxi(producer.level-1,0))))))
    var xp_snapshot := maxf(xp_gain,0.0)
    if not bulk_plan.is_empty():
        # V5.5-D early-phase target ~49 profession EXP/active hour at Lv1.
        xp_snapshot *= 4.9
    var data := producer.production_state.duplicate(true)
    var jobs := resource_timer_jobs(producer)
    var sequence := maxi(int(data.get("economy_a_sequence",0)),0)+1
    var job := {
        "job_id":"%s:v1:%d" % [str(producer.id),sequence],
        "worker_id":str(actor.id),"profession_id":str(profession_id),
        "resource_id":str(selected_resource),
        "output_quantity":output_units,
        "production_plan_id":str(bulk_plan.get("plan_id","")),
        "profession_xp_gain":xp_snapshot,
        "started_tick":state.tick,"finish_tick":state.tick+duration
    }
    if not bulk_plan.is_empty():
        var cash_snapshot := EconomySystem.new().sx_v55_r12_work_snapshot(
            state,actor,producer.building_type,str(bulk_plan.get("plan_id","")),duration)
        if not cash_snapshot.is_empty():
            job["sx_v55_r12_work"] = cash_snapshot
    jobs.append(job)
    data["economy_a_sequence"] = sequence
    data["economy_a_jobs"] = jobs
    producer.production_state = data
    state.building_event_count += 1
    return {"ok":true,"started":true,"completed":false,"job_id":str(job["job_id"]),"finish_tick":int(job["finish_tick"]),"phase":"timed","profession_id":str(profession_id),"building_id":str(producer.id),"stamina_cost":0.0}

func cancel_resource_timer(state: SimulationState, disciple_id: StringName) -> bool:
    if not state.sect.economy_a_enabled:
        return false
    for raw_building in state.buildings.values():
        if not (raw_building is BuildingState):
            continue
        var building: BuildingState = raw_building
        if building.building_type != TYPE_MINE and building.building_type != TYPE_LINH_FOREST:
            continue
        var jobs := resource_timer_jobs(building)
        for index in range(jobs.size()):
            if jobs[index] is Dictionary and str(jobs[index].get("worker_id","")) == str(disciple_id):
                jobs.remove_at(index)
                var data := building.production_state.duplicate(true)
                data["economy_a_jobs"] = jobs
                building.production_state = data
                state.building_event_count += 1
                return true
    return false

func _process_resource_timers(state: SimulationState, building: BuildingState) -> void:
    var jobs := resource_timer_jobs(building)
    if jobs.is_empty():
        return
    var remaining: Array = []
    var changed := false
    for raw_job in jobs:
        if not (raw_job is Dictionary):
            remaining.append(raw_job)
            continue
        var job: Dictionary = raw_job
        var worker_id := StringName(job.get("worker_id",""))
        if not state.disciples.has(worker_id):
            remaining.append(job)
            continue
        var worker: DiscipleState = state.disciples[worker_id]
        if worker.active_pve_encounter_id != "":
            remaining.append(job)
            continue
        if state.tick < int(job.get("finish_tick",state.tick+1)):
            if StringName(job.get("profession_id","")) == PROF_MINING:
                _award_timed_mining_body_minute(state,worker,building)
            remaining.append(job)
            continue
        var resource_id := StringName(job.get("resource_id",""))
        var units := int(job.get("output_quantity",0))
        var job_id := str(job.get("job_id",""))
        var cash_snapshot: Dictionary = job.get("sx_v55_r12_work",{})
        if not cash_snapshot.is_empty():
            # A coherent forged amount/time must not bypass the real producer.
            var authentic_plan: Dictionary = SX_V55_BULK_PLANS.get(str(resource_id),{})
            if authentic_plan.is_empty() \
                    or str(authentic_plan.get("plan_id","")) != str(job.get("production_plan_id","")) \
                    or str(authentic_plan.get("producer","")) != str(building.building_type) \
                    or int(cash_snapshot.get("minutes",-1)) != int(job.get("finish_tick",0))-int(job.get("started_tick",0)) \
                    or str(cash_snapshot.get("plan_id","")) != str(job.get("production_plan_id","")) \
                    or str(cash_snapshot.get("site","")) != str(building.building_type) \
                    or not bool(EconomySystem.new().sx_v55_r12_can_settle(state,worker,job_id,cash_snapshot).get("ok",false)):
                remaining.append(job)
                continue
        if job_id.is_empty() or units <= 0 or not warehouse.add(state,resource_id,units):
            remaining.append(job)
            continue
        building.metrics["production_batches"] = int(building.metrics.get("production_batches",0))+1
        building.metrics["units_produced"] = int(building.metrics.get("units_produced",0))+units
        var profession := str(job.get("profession_id",""))
        worker.profession_xp[profession] = float(worker.profession_xp.get(profession,0.0))+maxf(float(job.get("profession_xp_gain",0.0)),0.0)
        worker.metrics["work_completions"] = int(worker.metrics.get("work_completions",0))+1
        worker.metrics["%s_completions" % profession] = int(worker.metrics.get("%s_completions" % profession,0))+1
        state.sect.workforce_event_count += 1
        if cash_snapshot.is_empty():
            EconomySystem.new().settle_work_wage(state,worker,job_id)
        else:
            EconomySystem.new().sx_v55_r12_settle(state,worker,job_id,cash_snapshot)
        changed = true
    if changed:
        var data := building.production_state.duplicate(true)
        data["economy_a_jobs"] = remaining
        building.production_state = data
        state.building_event_count += 1

func _award_timed_mining_body_minute(state: SimulationState, worker: DiscipleState, mine: BuildingState) -> void:
    if not state.sect.v2_training_enabled or not DiscipleRealmProgressV2.owns_v2_progression(worker):
        return
    var body_rule = state.sect.v2_training_rules.get("body",null)
    if not (body_rule is Dictionary):
        return
    DiscipleBodyXpSourceV2.commit_minute(state,worker,{
        "source_id":"p3_7_mine_active_extraction:%s" % str(mine.id),
        "source_kind":DiscipleBodyXpSourceV2.SOURCE_PRODUCTION,
        "base_body_xp_per_minute":DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE,
        "floor_costs":body_rule.get("floor_costs",{}),
        "modifiers":[],"active_work_verified":true
    },"dv2:mine:active:%s:%d" % [str(worker.id),state.tick])

func cancel_work_cycle(state: SimulationState, disciple: DiscipleState, settle_carried: bool = true) -> int:
    if disciple.work_cycle_state.is_empty():
        return 0
    var cycle := disciple.work_cycle_state
    var profession := StringName(cycle.get("profession_id", cycle.get("profession", "")))
    var deposited := 0
    if settle_carried:
        var carried := maxi(int(cycle.get("carried_units", 0)), 0)
        var building_id := StringName(cycle.get("building_id", ""))
        var producer = state.buildings.get(str(building_id))
        if carried > 0 and producer is BuildingState:
            var definition := definition_for(producer)
            var expected_profession := StringName(definition.get("profession_id", ""))
            var resource_id := StringName(cycle.get("resource_id", definition.get("resource_id", "")))
            if (
                str(definition.get("job_model", "")) == "carry_cycle"
                and profession == expected_profession
                and resource_id != &""
            ):
                _deposit_resource(state, producer, str(resource_id), carried)
                deposited = carried
    disciple.work_cycle_state.clear()
    return deposited

func clear_work_cycle(disciple: DiscipleState, profession_id: StringName = &"") -> void:
    if profession_id == &"" or StringName(disciple.work_cycle_state.get("profession", "")) == profession_id:
        disciple.work_cycle_state.clear()

func definition_for(building: BuildingState) -> Dictionary:
    if building == null:
        return {}
    return DEFINITIONS.get(str(building.building_type), {})

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.p3_7_buildings_enabled:
        if not state.buildings.is_empty() or state.building_event_count != 0:
            errors.append("P3.7 building data exists while the authority is disabled.")
        return errors
    if not state.sect.workforce_enabled:
        errors.append("P3.7 buildings require workforce authority.")
    if state.building_event_count < 0:
        errors.append("Building event count is negative.")

    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if not (building is BuildingState):
            errors.append("Building %s has invalid state type." % str(raw_id))
            continue
        if str(building.id) != str(raw_id):
            errors.append("Building key/id mismatch for %s." % str(raw_id))
        if definition_for(building).is_empty():
            errors.append("Building %s has unknown type %s." % [building.id, building.building_type])
        if building.level < 1 or building.level > building.max_level:
            errors.append("Building %s has invalid level." % building.id)
        if not VALID_STATUSES.has(building.status):
            errors.append("Building %s has invalid status." % building.id)
        if building.status == STATUS_CONSTRUCTING and building.building_type != TYPE_RESIDENCE:
            errors.append("Building %s has unsupported construction status." % building.id)
        if building.is_upgrading():
            if building.upgrade_target_level != building.level + 1:
                errors.append("Building %s has invalid upgrade target." % building.id)
            if building.upgrade_required_work <= 0.0 or building.upgrade_progress < 0.0:
                errors.append("Building %s has invalid upgrade progress." % building.id)
        elif building.upgrade_target_level != 0 or building.upgrade_required_work > 0.0 or building.upgrade_progress > 0.0:
            errors.append("Building %s has stale upgrade state." % building.id)
        for milestone in building.unlocked_milestones:
            if not MILESTONE_LEVELS.has(milestone) or milestone > building.level:
                errors.append("Building %s has invalid milestone %d." % [building.id, milestone])

        if state.sect.economy_a_enabled and (building.building_type == TYPE_MINE or building.building_type == TYPE_LINH_FOREST):
            var resource_ids: Dictionary = {}
            var resource_workers: Dictionary = {}
            for raw_timer in resource_timer_jobs(building):
                if not (raw_timer is Dictionary):
                    errors.append("Economy-A invalid resource timer.")
                    continue
                var timer: Dictionary = raw_timer
                var timer_id := str(timer.get("job_id",""))
                var timer_worker := str(timer.get("worker_id",""))
                if timer_id.is_empty() or resource_ids.has(timer_id) or timer_worker.is_empty() or resource_workers.has(timer_worker) or not state.disciples.has(StringName(timer_worker)):
                    errors.append("Economy-A invalid/duplicate resource timer owner.")
                resource_ids[timer_id] = true
                resource_workers[timer_worker] = true
                if int(timer.get("finish_tick",0)) <= int(timer.get("started_tick",-1)):
                    errors.append("Economy-A invalid resource timer deadline.")
                var earned_id := str(timer.get("resource_id",""))
                var valid_earned_id := MINE_ORE_OPTIONS.has(earned_id) \
                    if building.building_type == TYPE_MINE else FOREST_MATERIAL_OPTIONS.has(earned_id)
                var output_option: Dictionary = MINE_ORE_OPTIONS.get(earned_id,{}) \
                    if building.building_type == TYPE_MINE else FOREST_MATERIAL_OPTIONS.get(earned_id,{})
                if not valid_earned_id or not ResourceRegistry.DEFINITIONS.has(earned_id) \
                        or int(timer.get("output_quantity",0)) <= 0 \
                        or building.level < int(output_option.get("required_level",1)):
                    errors.append("Economy-A invalid frozen resource output identity/quantity.")
        if building.building_type == TYPE_ALCHEMY_HALL:
            var alchemy_data := _ensure_alchemy_state(building)
            var seen_job_ids: Dictionary = {}
            var seen_workers: Dictionary = {}
            for raw_job in alchemy_data.get("jobs", []):
                if not (raw_job is Dictionary):
                    errors.append("Alchemy Hall %s contains invalid job data." % building.id)
                    continue
                var job_id := str(raw_job.get("job_id", ""))
                var worker_id := str(raw_job.get("worker_id", ""))
                if job_id == "" or seen_job_ids.has(job_id):
                    errors.append("Alchemy Hall %s has invalid/duplicate job id." % building.id)
                seen_job_ids[job_id] = true
                if worker_id == "" or seen_workers.has(worker_id) or not state.disciples.has(StringName(worker_id)):
                    errors.append("Alchemy Hall %s has invalid/duplicate worker reservation." % building.id)
                seen_workers[worker_id] = true
                if int(raw_job.get("finish_tick", 0)) <= int(raw_job.get("started_tick", -1)):
                    errors.append("Alchemy Hall %s has invalid job timer." % building.id)

        if building.building_type == TYPE_SPIRIT_FIELD:
            var data = building.production_state
            if not (data is Dictionary) or not data.has("plots"):
                errors.append("Spirit Field %s has no canonical plot state." % building.id)
            else:
                var policy := StringName(data.get("policy_mode", ""))
                if not VALID_FIELD_POLICIES.has(policy):
                    errors.append("Spirit Field %s has invalid crop policy." % building.id)
                var plots = data.get("plots", [])
                if not (plots is Array) or plots.size() != spirit_plot_slots(building):
                    errors.append("Spirit Field %s has invalid plot count." % building.id)
                else:
                    var seen_plot_ids: Dictionary = {}
                    for raw_plot in plots:
                        if not (raw_plot is Dictionary):
                            errors.append("Spirit Field %s contains invalid plot data." % building.id)
                            continue
                        var plot_id := str(raw_plot.get("plot_id", ""))
                        var plot_status := StringName(raw_plot.get("status", ""))
                        if plot_id == "" or seen_plot_ids.has(plot_id):
                            errors.append("Spirit Field %s has invalid/duplicate plot id." % building.id)
                        seen_plot_ids[plot_id] = true
                        if plot_status != PLOT_EMPTY and plot_status != PLOT_GROWING:
                            errors.append("Spirit Field %s plot %s has invalid status." % [building.id, plot_id])
                        if plot_status == PLOT_GROWING:
                            var crop_id := StringName(raw_plot.get("crop_id", ""))
                            if not crop_registry.has(crop_id):
                                errors.append("Spirit Field %s plot %s has unknown crop." % [building.id, plot_id])
                            if int(raw_plot.get("finish_tick", 0)) <= int(raw_plot.get("started_tick", -1)):
                                errors.append("Spirit Field %s plot %s has invalid timer." % [building.id, plot_id])
                            if int(raw_plot.get("paid_spirit_stones", -1)) < 0:
                                errors.append("Spirit Field %s plot %s has invalid paid cost." % [building.id, plot_id])

    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.work_cycle_state.is_empty():
            continue
        var profession := StringName(disciple.work_cycle_state.get("profession_id", disciple.work_cycle_state.get("profession", "")))
        var building_id := str(disciple.work_cycle_state.get("building_id", ""))
        var phase := StringName(disciple.work_cycle_state.get("phase", ""))
        if not state.buildings.has(building_id):
            errors.append("%s references missing work-cycle building." % disciple.display_name)
        else:
            var cycle_building = state.buildings[building_id]
            if cycle_building is BuildingState:
                var cycle_definition := definition_for(cycle_building)
                var expected_profession := StringName(cycle_definition.get("profession_id", ""))
                var job_model := str(cycle_definition.get("job_model", ""))
                if job_model == "carry_cycle":
                    if profession != expected_profession:
                        errors.append("%s work-cycle profession/building mismatch." % disciple.display_name)
                    var valid_phases = cycle_definition.get("cycle_phases", [])
                    if not (valid_phases is Array) or not valid_phases.has(str(phase)):
                        errors.append("%s has invalid resource-job phase." % disciple.display_name)
                    var expected_resource := StringName(cycle_definition.get("resource_id", ""))
                    var cycle_resource := StringName(disciple.work_cycle_state.get("resource_id", str(expected_resource)))
                    # A committed Mine/Forest carry cycle keeps the resource
                    # frozen when worksite selection changes. Never treat a
                    # selection change as an opportunity to swap carried loot.
                    var valid_resource := cycle_resource == expected_resource
                    if cycle_building.building_type == TYPE_MINE:
                        valid_resource = MINE_ORE_OPTIONS.has(str(cycle_resource)) \
                            and ResourceRegistry.DEFINITIONS.has(str(cycle_resource)) \
                            and cycle_building.level >= int(MINE_ORE_OPTIONS.get(
                                str(cycle_resource),{}).get("required_level",1))
                    elif cycle_building.building_type == TYPE_LINH_FOREST:
                        valid_resource = FOREST_MATERIAL_OPTIONS.has(str(cycle_resource)) \
                            and ResourceRegistry.DEFINITIONS.has(str(cycle_resource)) \
                            and cycle_building.level >= int(FOREST_MATERIAL_OPTIONS.get(
                                str(cycle_resource),{}).get("required_level",1))
                    if expected_resource == &"" or not valid_resource:
                        errors.append("%s has invalid resource-job output identity." % disciple.display_name)
                elif profession == PROF_HERBALISM:
                    # Legacy pre-plot Field cycle compatibility only.
                    if not [&"travel_out", &"tending", &"harvesting", &"haul_back"].has(phase):
                        errors.append("%s has invalid herbalism work-cycle phase." % disciple.display_name)
                else:
                    errors.append("%s has unsupported P3.7 work-cycle profession." % disciple.display_name)
        if float(disciple.work_cycle_state.get("progress", 0.0)) < 0.0 or int(disciple.work_cycle_state.get("carried_units", 0)) < 0:
            errors.append("%s has invalid work-cycle progress." % disciple.display_name)
    return errors

func _complete_upgrade(state: SimulationState, building: BuildingState) -> void:
    building.level = clampi(building.upgrade_target_level, 1, building.max_level)
    if MILESTONE_LEVELS.has(building.level) and not building.unlocked_milestones.has(building.level):
        building.unlocked_milestones.append(building.level)
        building.unlocked_milestones.sort()
    building.status = STATUS_ACTIVE
    building.upgrade_target_level = 0
    building.upgrade_started_tick = -1
    building.upgrade_required_work = 0.0
    building.upgrade_progress = 0.0
    building.metrics["upgrade_completions"] = int(building.metrics.get("upgrade_completions", 0)) + 1
    state.building_event_count += 1
    if SectHallSystemV1.installed(state) and building.building_type in [TYPE_MAIN_HALL, TYPE_RESIDENCE]:
        SectResidenceSystemV1.refresh_capacity(state)

func _process_spirit_field_plots(state: SimulationState, field: BuildingState) -> void:
    var data := _ensure_spirit_field_state(state, field)
    var plots: Array = data.get("plots", [])
    var changed := false
    for index in range(plots.size()):
        var plot: Dictionary = plots[index]
        if StringName(plot.get("status", "")) != PLOT_GROWING:
            continue
        if state.tick < int(plot.get("finish_tick", state.tick + 1)):
            continue
        if not _resolve_spirit_plot(state, field, plot):
            continue
        plots[index] = _empty_plot(str(plot.get("plot_id", "plot_%03d" % [index + 1])))
        changed = true
    if changed:
        data["plots"] = plots
        field.production_state = data
        state.building_event_count += 1

func lucky_harvest_multiplier(rare_factor: float, roll: float) -> int:
    var factor := maxf(rare_factor, 0.0)
    var value := clampf(roll, 0.0, 0.999999999)
    var p4 := 0.002 * factor
    var p3 := 0.008 * factor
    var p2 := 0.030 * factor
    if value < p4:
        return 4
    if value < p4 + p3:
        return 3
    if value < p4 + p3 + p2:
        return 2
    return 1

func spirit_field_plots(state: SimulationState, field: BuildingState) -> Array:
    if field == null or field.building_type != TYPE_SPIRIT_FIELD:
        return []
    return Array(_ensure_spirit_field_state(state, field).get("plots", [])).duplicate(true)

func _resolve_spirit_plot(state: SimulationState, field: BuildingState, plot: Dictionary) -> bool:
    var crop_id := StringName(plot.get("crop_id", ""))
    if not crop_registry.has(crop_id):
        return false
    var roll := _stable_plot_roll(state.seed, str(field.id), str(plot.get("plot_id", "")), int(plot.get("started_tick", 0)))
    var lucky := lucky_harvest_multiplier(float(plot.get("rare_factor", 1.0)), roll)
    var quantity := maxi(int(plot.get("routine_yield", crop_registry.base_yield(crop_id))), 1) * lucky
    var cash_snapshot: Dictionary = plot.get("sx_v55_r12_work",{})
    var wage_job_id := str(plot.get("economy_a_wage_job_id", ""))
    var worker_id := StringName(plot.get("assigned_worker_id", ""))
    if not cash_snapshot.is_empty():
        var authentic_plan: Dictionary = SX_V55_BULK_PLANS.get(str(crop_id),{})
        if authentic_plan.is_empty() \
                or str(authentic_plan.get("plan_id","")) != str(plot.get("production_plan_id","")) \
                or str(authentic_plan.get("producer","")) != str(field.building_type) \
                or int(cash_snapshot.get("minutes",-1)) != int(plot.get("finish_tick",0))-int(plot.get("started_tick",0)) \
                or str(cash_snapshot.get("plan_id","")) != str(plot.get("production_plan_id","")) \
                or str(cash_snapshot.get("site","")) != str(field.building_type) \
                or not state.disciples.has(worker_id) \
                or not bool(EconomySystem.new().sx_v55_r12_can_settle(
                    state,state.disciples[worker_id],wage_job_id,cash_snapshot).get("ok",false)):
            return false
    if not _deposit_resource(state, field, str(crop_registry.output_resource_id(crop_id)), quantity):
        return false
    # New engine versions settle actual profession EXP at harvest once.
    # Old in-flight plots have no profession_xp_gain and were already paid on
    # planting in the pre-migration model; skip without guessing historical XP.
    var completed_worker := StringName(plot.get("assigned_worker_id",""))
    if plot.has("profession_xp_gain") and state.disciples.has(completed_worker):
        var harvested_worker: DiscipleState = state.disciples[completed_worker]
        var xp_gain := maxf(float(plot.get("profession_xp_gain",0.0)),0.0)
        harvested_worker.profession_xp[str(PROF_HERBALISM)] = float(harvested_worker.profession_xp.get(str(PROF_HERBALISM),0.0)) + xp_gain
        harvested_worker.metrics["work_completions"] = int(harvested_worker.metrics.get("work_completions",0))+1
        harvested_worker.metrics["herbalism_completions"] = int(harvested_worker.metrics.get("herbalism_completions",0))+1
        state.sect.workforce_event_count += 1
    if state.sect.economy_a_enabled and wage_job_id != "" and state.disciples.has(worker_id):
        if cash_snapshot.is_empty():
            EconomySystem.new().settle_work_wage(state, state.disciples[worker_id], wage_job_id)
        else:
            EconomySystem.new().sx_v55_r12_settle(
                state,state.disciples[worker_id],wage_job_id,cash_snapshot)

    var fragment_roll := _stable_plot_roll(state.seed, "%s|linh_tuyen_fragment" % str(field.id), str(plot.get("plot_id", "")), int(plot.get("started_tick", 0)))
    if linh_tuyen_fragment_drop(float(plot.get("rare_factor", 1.0)), fragment_roll) > 0:
        _add_linh_tuyen_fragment(state)
        convert_linh_tuyen_fragments(state)
    return true

func linh_tuyen_fragment_drop(rare_factor: float, roll: float) -> int:
    var chance := clampf(LINH_TUYEN_FRAGMENT_BASE_CHANCE * maxf(rare_factor, 0.0), 0.0, 1.0)
    return 1 if clampf(roll, 0.0, 0.999999999) < chance else 0

func convert_linh_tuyen_fragments(state: SimulationState) -> int:
    if not state.sect.p3_7_resources_enabled:
        return 0
    var fragment_count := warehouse.quantity(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT))
    var hearts := int(floor(float(fragment_count) / float(LINH_TUYEN_FRAGMENT_PER_HEART)))
    if hearts <= 0:
        return 0
    if not warehouse.consume(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT), hearts * LINH_TUYEN_FRAGMENT_PER_HEART, true):
        return 0
    if not warehouse.add(state, StringName(MATERIAL_LINH_TUYEN_HEART), hearts):
        warehouse.add(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT), hearts * LINH_TUYEN_FRAGMENT_PER_HEART)
        return 0
    return hearts

func _add_linh_tuyen_fragment(state: SimulationState) -> void:
    if state.sect.p3_7_resources_enabled:
        warehouse.add(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT), 1)
    else:
        state.sect.forge_materials[MATERIAL_LINH_TUYEN_FRAGMENT] = int(state.sect.forge_materials.get(MATERIAL_LINH_TUYEN_FRAGMENT, 0)) + 1

func _ensure_spirit_field_state(state: SimulationState, field: BuildingState) -> Dictionary:
    if field == null or field.building_type != TYPE_SPIRIT_FIELD:
        return {}
    var desired_slots := spirit_plot_slots(field)
    var current = field.production_state
    if current is Dictionary and current.has("plots"):
        var data: Dictionary = current.duplicate(true)
        if not VALID_FIELD_POLICIES.has(StringName(data.get("policy_mode", ""))):
            data["policy_mode"] = str(FIELD_POLICY_AUTO_DEMAND)
        data["fixed_crop_id"] = str(data.get("fixed_crop_id", ""))
        var weights = data.get("priority_weights", {})
        data["priority_weights"] = weights.duplicate(true) if weights is Dictionary else {}
        data["plant_sequence"] = maxi(int(data.get("plant_sequence", 0)), 0)
        var plots: Array = []
        var raw_plots = data.get("plots", [])
        if raw_plots is Array:
            for index in range(raw_plots.size()):
                plots.append(_normalize_plot(raw_plots[index], index))
        while plots.size() < desired_slots:
            plots.append(_empty_plot("plot_%03d" % [plots.size() + 1]))
        if plots.size() > desired_slots:
            plots.resize(desired_slots)
        data["plots"] = plots
        field.production_state = data
        return data

    var legacy: Dictionary = current.duplicate(true) if current is Dictionary else {}
    var migrated := {
        "policy_mode": str(FIELD_POLICY_AUTO_DEMAND),
        "fixed_crop_id": "",
        "priority_weights": {},
        "plot_crop_preferences": {},
        "plant_sequence": 0,
        "plots": []
    }
    var plots: Array = []
    for index in range(desired_slots):
        plots.append(_empty_plot("plot_%03d" % [index + 1]))
    var legacy_phase := StringName(legacy.get("phase", ""))
    if legacy_phase == SPIRIT_PHASE_GROWING or legacy_phase == SPIRIT_PHASE_HARVEST_READY:
        var crop_id := StringName(legacy.get("resource_id", str(SpiritCropRegistry.CROP_THANH_LINH_THAO)))
        if not crop_registry.has(crop_id):
            crop_id = SpiritCropRegistry.CROP_THANH_LINH_THAO
        var progress := maxf(float(legacy.get("growth_progress", 0.0)), 0.0)
        var required := maxf(float(legacy.get("growth_required", crop_registry.base_cycle_ticks(crop_id))), 1.0)
        var remaining := 1 if legacy_phase == SPIRIT_PHASE_HARVEST_READY else maxi(1, int(ceil(required - progress)))
        plots[0] = {
            "plot_id": "plot_001",
            "crop_id": str(crop_id),
            "status": str(PLOT_GROWING),
            "started_tick": state.tick - int(floor(progress)),
            "finish_tick": state.tick + remaining,
            "assigned_worker_id": str(legacy.get("planted_by", "")),
            "paid_spirit_stones": 0,
            "routine_yield": crop_registry.base_yield(crop_id),
            "rare_factor": 1.0
        }
    migrated["plots"] = plots
    field.production_state = migrated
    state.building_event_count += 1
    return migrated

func _normalize_plot(value: Variant, index: int) -> Dictionary:
    if not (value is Dictionary):
        return _empty_plot("plot_%03d" % [index + 1])
    var plot_id := str(value.get("plot_id", "plot_%03d" % [index + 1]))
    var status := StringName(value.get("status", "empty"))
    if status != PLOT_GROWING:
        return _empty_plot(plot_id)
    var crop_id := StringName(value.get("crop_id", ""))
    if not crop_registry.has(crop_id):
        return _empty_plot(plot_id)
    var normalized := {
        "plot_id": plot_id,
        "crop_id": str(crop_id),
        "status": str(PLOT_GROWING),
        "started_tick": int(value.get("started_tick", 0)),
        "finish_tick": int(value.get("finish_tick", 1)),
        "assigned_worker_id": str(value.get("assigned_worker_id", "")),
        "paid_spirit_stones": maxi(int(value.get("paid_spirit_stones", 0)), 0),
        "routine_yield": maxi(int(value.get("routine_yield", crop_registry.base_yield(crop_id))), 1),
        "production_plan_id": str(value.get("production_plan_id","")),
        "rare_factor": maxf(float(value.get("rare_factor", 1.0)), 0.0),
        "economy_a_wage_job_id": str(value.get("economy_a_wage_job_id", ""))
    }
    if value.has("profession_xp_gain"):
        normalized["profession_xp_gain"] = maxf(float(value.get("profession_xp_gain",0.0)),0.0)
    # Keep new, explicitly gated economic snapshots immutable during plot
    # normalization; old crops without this key retain their old wages/EXP.
    if value.get("sx_v55_r12_work",{}) is Dictionary \
            and not (value.get("sx_v55_r12_work",{}) as Dictionary).is_empty():
        normalized["sx_v55_r12_work"] = value["sx_v55_r12_work"].duplicate(true)
    return normalized

func _empty_plot(plot_id: String) -> Dictionary:
    return {
        "plot_id": plot_id,
        "crop_id": "",
        "status": str(PLOT_EMPTY),
        "started_tick": -1,
        "finish_tick": -1,
        "assigned_worker_id": "",
        "paid_spirit_stones": 0,
        "routine_yield": 0,
        "rare_factor": 1.0
    }

func _first_empty_plot_index(plots: Array) -> int:
    for index in range(plots.size()):
        if plots[index] is Dictionary and StringName(plots[index].get("status", "")) == PLOT_EMPTY:
            return index
    return -1

func _field_has_startable_plot(state: SimulationState, field: BuildingState) -> bool:
    var data := _ensure_spirit_field_state(state, field)
    return not _first_startable_spirit_plot(state,field,data).is_empty()

func _first_startable_spirit_plot(state: SimulationState,field: BuildingState,data: Dictionary) -> Dictionary:
    var plots: Array = data.get("plots",[])
    for index in range(plots.size()):
        var plot = plots[index]
        if not (plot is Dictionary) or StringName(plot.get("status","")) != PLOT_EMPTY:
            continue
        var crop_id := _select_crop(state,field,data,str(plot.get("plot_id","")))
        if crop_id != &"":
            return {"index":index,"crop_id":str(crop_id)}
    return {}

func _select_crop(state: SimulationState, field: BuildingState, data: Dictionary, plot_id: String = "") -> StringName:
    var eligible: Array[StringName] = []
    for crop_id in crop_registry.eligible_crop_ids(field.level):
        if state.sect.spirit_stones >= crop_registry.cost(crop_id):
            eligible.append(crop_id)
    if eligible.is_empty():
        return &""

    # A tile's explicit crop wins over the general field policy. Insufficient
    # Stones leaves that particular tile idle instead of planting something else.
    var preferences: Dictionary = data.get("plot_crop_preferences",{})
    var chosen := StringName(preferences.get(plot_id,""))
    if chosen != &"":
        return chosen if eligible.has(chosen) else &""

    var mode := StringName(data.get("policy_mode", str(FIELD_POLICY_AUTO_DEMAND)))
    if mode == FIELD_POLICY_FIXED:
        var fixed_id := StringName(data.get("fixed_crop_id", ""))
        return fixed_id if eligible.has(fixed_id) else &""

    if mode == FIELD_POLICY_PRIORITY:
        var weights = data.get("priority_weights", {})
        if weights is Dictionary:
            var total := 0
            var weighted_ids: Array[StringName] = []
            for crop_id in eligible:
                var weight := maxi(int(weights.get(str(crop_id), 0)), 0)
                if weight > 0:
                    total += weight
                    weighted_ids.append(crop_id)
            if total > 0:
                weighted_ids.sort_custom(func(a: StringName, b: StringName) -> bool: return str(a) < str(b))
                var cursor := int(data.get("plant_sequence", 0)) % total
                var running := 0
                for crop_id in weighted_ids:
                    running += maxi(int(weights.get(str(crop_id), 0)), 0)
                    if cursor < running:
                        return crop_id

    # A player's fixed graded recipe needs real ingredients, not the stock
    # targets of the two legacy pills. AUTO_DEMAND may plant a missing crop
    # only after the actual alchemy hall unlock; FIXED and PRIORITY above
    # retain their complete precedence. No resource is granted here.
    if mode == FIELD_POLICY_AUTO_DEMAND and state.sect.p3_7_resources_enabled:
        var legacy_demand := SX01PillPolicy.active(state) \
            and bool(state.sect.sx01_pill_policy.get("auto_production", false)) \
            and str(state.sect.sx01_pill_policy.get("recipe_mode", "fixed")) == "demand"
        if not legacy_demand:
            var graded_hall := primary_building(state, TYPE_ALCHEMY_HALL)
            if graded_hall != null:
                var graded_recipe := StringName(graded_hall.production_state.get("recipe_id", ""))
                var graded_rule := MedicineCatalogueV2.recipe_definition(graded_recipe)
                if not graded_rule.is_empty() and graded_hall.level >= int(graded_rule.get("required_hall_level", 1)):
                    var needed_crop := _select_missing_graded_recipe_crop(state, eligible, graded_recipe)
                    if needed_crop != &"":
                        return needed_crop

    # SX-01 only owns the existing AUTO_DEMAND route. Never override a
    # player's FIXED or PRIORITY field strategy, or mint crop outputs.
    if mode == FIELD_POLICY_AUTO_DEMAND and SX01PillPolicy.active(state) \
        and bool(state.sect.sx01_pill_policy.get("auto_production", false)) \
        and str(state.sect.sx01_pill_policy.get("recipe_mode", "fixed")) == "demand":
        var hall := primary_building(state, TYPE_ALCHEMY_HALL)
        var pill_plan := SX01PillPolicy.stock_plan(state, hall)
        var herb_needed := (int(pill_plan["deficit_hxd"]) * 3 + int(pill_plan["deficit_tqd"]) * 2) * (
            SX_V55_COMMON_SCALE if sx_v55_bulk_enabled(state) else 1)
        var grain_needed := int(pill_plan["deficit_tqd"])
        # Already-paid Alchemy jobs consumed their inputs at start, so we only
        # reserve future demand. Growing plots are pending, not stock.
        for existing_field in _buildings_of_type(state, TYPE_SPIRIT_FIELD):
            for raw_plot in spirit_field_plots(state, existing_field):
                if not (raw_plot is Dictionary) or str(raw_plot.get("status", "")) != str(PLOT_GROWING):
                    continue
                if str(raw_plot.get("crop_id", "")) == "thanh_linh_thao":
                    herb_needed -= int(raw_plot.get("routine_yield", 0))
                elif str(raw_plot.get("crop_id", "")) == "linh_coc":
                    grain_needed -= int(raw_plot.get("routine_yield", 0))
        herb_needed = maxi(0, herb_needed - warehouse.available_quantity(state, &"thanh_linh_thao"))
        grain_needed = maxi(0, grain_needed - warehouse.available_quantity(state, &"linh_coc"))
        var can_herb := eligible.has(&"thanh_linh_thao") and herb_needed > 0
        var can_grain := eligible.has(&"linh_coc") and grain_needed > 0
        if can_herb and can_grain:
            return &"thanh_linh_thao" if float(herb_needed) / 3.0 >= float(grain_needed) / 5.0 else &"linh_coc"
        if can_herb:
            return &"thanh_linh_thao"
        if can_grain:
            return &"linh_coc"
        return &""

    # AUTO_DEMAND must stop at the real stock target. Previously it
    # unconditionally chose a crop and drained Stones forever after storage
    # was full. Include growing output to avoid overplanting four parallel plots.
    var best := &""
    var best_score := 0.0
    for crop_id in eligible:
        var target := float(sx_v55_crop_stock_target(state,crop_id))
        var quantity := float(warehouse.quantity(state, crop_registry.output_resource_id(crop_id))) if state.sect.p3_7_resources_enabled else 0.0
        for field_item in _buildings_of_type(state,TYPE_SPIRIT_FIELD):
            for pending in _ensure_spirit_field_state(state,field_item).get("plots",[]):
                if pending is Dictionary and str(pending.get("status","")) == str(PLOT_GROWING) and str(pending.get("crop_id","")) == str(crop_id):
                    quantity += float(pending.get("routine_yield",0))
        var score := (target - quantity) / maxf(target, 1.0)
        if score > best_score or (is_equal_approx(score,best_score) and best != &"" and str(crop_id) < str(best)):
            best_score = score
            best = crop_id
    return best

# Read-only planning from the actual chosen recipe, on-hand Warehouse
# stock and already-growing plots. Deficit/yield normalizes unlike crops;
# stable ID tie-break preserves deterministic Save/Reload behavior.
func _select_missing_graded_recipe_crop(state: SimulationState,
        eligible: Array[StringName], recipe_id: StringName) -> StringName:
    var requirements := sx_v55_common_requirements(state,AlchemyRecipeRegistry.new().inputs(recipe_id))
    if requirements.is_empty():
        return &""
    var growing: Dictionary = {}
    for existing_field in _buildings_of_type(state, TYPE_SPIRIT_FIELD):
        for raw_plot in spirit_field_plots(state, existing_field):
            if not (raw_plot is Dictionary) or str(raw_plot.get("status", "")) != str(PLOT_GROWING):
                continue
            var planted_id := StringName(raw_plot.get("crop_id", ""))
            if not crop_registry.has(planted_id):
                continue
            var output_id := str(crop_registry.output_resource_id(planted_id))
            growing[output_id] = int(growing.get(output_id, 0)) + maxi(int(raw_plot.get("routine_yield", 0)), 0)
    var selected: StringName = &""
    var best_deficit_per_yield := 0.0
    for crop_id in eligible:
        var resource_id := crop_registry.output_resource_id(crop_id)
        var needed := int(requirements.get(str(resource_id), 0))
        if needed <= 0:
            continue
        var have := warehouse.available_quantity(state, resource_id)
        var outstanding := maxi(0, needed - have - int(growing.get(str(resource_id), 0)))
        if outstanding <= 0:
            continue
        var score := float(outstanding) / float(maxi(crop_registry.base_yield(crop_id), 1))
        if selected == &"" or score > best_deficit_per_yield or (is_equal_approx(score, best_deficit_per_yield) and str(crop_id) < str(selected)):
            selected = crop_id
            best_deficit_per_yield = score
    return selected

func _crop_affinity_factor(disciple: DiscipleState, crop_id: StringName) -> float:
    var affinity := crop_registry.affinity_elements(crop_id)
    if affinity.is_empty():
        return 1.0
    for raw_element in disciple.spiritual_root_elements:
        if affinity.has(str(raw_element)):
            return 1.05
    return 1.0

func _stable_plot_roll(seed_value: int, building_id: String, plot_id: String, started_tick: int) -> float:
    var text := "%d|%s|%s|%d" % [seed_value, building_id, plot_id, started_tick]
    var value := 17
    for index in range(text.length()):
        value = int((value * 131 + text.unicode_at(index)) % 2147483629)
    return float(value % 1000000) / 1000000.0

func _buildings_of_type(state: SimulationState, building_type: StringName) -> Array[BuildingState]:
    var result: Array[BuildingState] = []
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if building is BuildingState and building.building_type == building_type:
            result.append(building)
    return result

func _building_for_disciple(state: SimulationState, building_type: StringName, disciple: DiscipleState) -> BuildingState:
    if disciple != null and disciple.worksite_building_id != &"":
        var assigned = state.buildings.get(str(disciple.worksite_building_id))
        if assigned is BuildingState and assigned.building_type == building_type:
            return assigned
        return null
    return primary_building(state, building_type)

func _deposit_resource(state: SimulationState, building: BuildingState, resource_id: String, quantity: int) -> bool:
    if quantity <= 0:
        return false
    if state.sect.p3_7_resources_enabled:
        # A full Warehouse is expected backpressure for timed jobs, not a lost delivery.
        if quantity > WarehouseSystem.MAX_SAFE_STACK - warehouse.quantity(state, StringName(resource_id)):
            return false
        if not warehouse.add(state, StringName(resource_id), quantity):
            push_error("BuildingSystem: failed to deposit canonical resource %s x%d." % [resource_id, quantity])
            return false
    else:
        state.sect.forge_materials[resource_id] = int(state.sect.forge_materials.get(resource_id, 0)) + quantity
    building.metrics["production_batches"] = int(building.metrics.get("production_batches", 0)) + 1
    building.metrics["units_produced"] = int(building.metrics.get("units_produced", 0)) + quantity
    state.building_event_count += 1
    SectHallSystemV1.record_prestige(state, 1)
    if building.building_type == TYPE_ALCHEMY_HALL:
        SectHallSystemV1.record_office_event(state, SectHallSystemV1.OFFICE_ALCHEMIST, true)
    elif building.building_type in [TYPE_MINE, TYPE_LINH_FOREST, TYPE_SPIRIT_FIELD]:
        SectHallSystemV1.record_office_event(state, SectHallSystemV1.OFFICE_STEWARD, true)
    return true

func _resource_available(state: SimulationState, resource_id: StringName) -> int:
    if state.sect.p3_7_resources_enabled:
        return warehouse.available_quantity(state, resource_id)
    return maxi(int(state.sect.forge_materials.get(str(resource_id), 0)), 0)

func _consume_resources(state: SimulationState, requirements: Dictionary) -> bool:
    if state.sect.p3_7_resources_enabled:
        return warehouse.consume_requirements(state, requirements)
    var ids: Array = requirements.keys()
    ids.sort()
    for raw_id in ids:
        if int(state.sect.forge_materials.get(str(raw_id), 0)) < int(requirements[raw_id]):
            return false
    for raw_id in ids:
        var key := str(raw_id)
        var next := int(state.sect.forge_materials.get(key, 0)) - int(requirements[raw_id])
        if next <= 0:
            state.sect.forge_materials.erase(key)
        else:
            state.sect.forge_materials[key] = next
    return true

func _movement_speed(state: SimulationState, disciple: DiscipleState) -> float:
    # World/work movement is a canonical physical speed. Combat path style
    # controls positioning tactics, not how fast a disciple walks to a job.
    var movement_profile := {"move_speed": 2.7}
    movement_profile = equipment.apply_style_modifiers(state, disciple, movement_profile)
    return maxf(float(movement_profile.get("move_speed", 2.7)), 0.5)

func _haul_speed_multiplier(_disciple: DiscipleState) -> float:
    return 1.0

func _resource_job_duration(building: BuildingState) -> float:
    var base := float(definition_for(building).get("base_work_duration", 4.0))
    var facility_multiplier := maxf(0.50, 1.0 - float(maxi(building.level - 1, 0)) * 0.005)
    return maxf(base * facility_multiplier, 1.0)

func _resource_job_batch_units(building: BuildingState) -> int:
    var base := maxi(int(definition_for(building).get("base_batch_units", 2)), 1)
    return base + int(floor(float(building.level) / 10.0))

## Read-only canonical production preview for presentation. Simulation and UI
## share the same batch/duration rules; this does not reserve or grant stock.
func resource_job_work_duration(building: BuildingState) -> float:
    return _resource_job_duration(building)

func resource_job_batch_units(building: BuildingState) -> int:
    return _resource_job_batch_units(building)

# Keep old helper names for regression/debug compatibility.
func _mining_duration(mine: BuildingState) -> float:
    return _resource_job_duration(mine)

func _mining_batch_units(mine: BuildingState) -> int:
    return _resource_job_batch_units(mine)

func _milestone_component(building_type: StringName, target_level: int) -> String:
    var table = MILESTONE_COMPONENTS.get(str(building_type), {})
    if not (table is Dictionary):
        return ""
    return str(table.get(target_level, ""))

func _milestone_component_quantity(building_type: StringName, target_level: int) -> int:
    if building_type == TYPE_SPIRIT_FIELD and MILESTONE_LEVELS.has(target_level):
        return maxi(int(ceil(float(target_level) / 10.0)), 1)
    return 1
