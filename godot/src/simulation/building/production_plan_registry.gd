class_name ProductionPlanRegistry
extends RefCounted

# Economy V2 canonical bulk-production authority.
# One simulation tick = one simulation minute.
const PLAN_MINE_THANH_THIET_T1 := &"mine_thanh_thiet_t1"
const PLAN_MINE_HUYEN_THIET_T2 := &"mine_huyen_thiet_t2"
const PLAN_FOREST_LINH_MOC_T1 := &"forest_linh_moc_t1"
const PLAN_FIELD_LINH_COC_T1 := &"field_linh_coc_t1"
const PLAN_FIELD_THANH_LINH_THAO_T1 := &"field_thanh_linh_thao_t1"
const PLAN_FIELD_TU_VAN_THAO_T1 := &"field_tu_van_thao_t1"

# Legacy common-material consumers were authored when production batches were
# single digits. Economy V2 bulk units intentionally scale only abundant common
# materials; rare/discrete drops and milestone components stay unscaled.
const COMMON_CONSUMER_SCALE := 1000
const COMMON_BULK_RESOURCES := [
    &"linh_moc",
    &"thanh_thiet",
    &"thanh_linh_thao"
]

const DEFINITIONS := {
    "mine_thanh_thiet_t1": {
        "producer_type": "mine",
        "profession_id": "mining",
        "output_resource_id": "thanh_thiet",
        "base_cycle_ticks": 60,
        "base_yield": 10000,
        "required_building_level": 1,
        "cultivation_realm_tier": 2,
        "body_realm_tier": 0,
        "common_yield": true
    },
    "mine_huyen_thiet_t2": {
        "producer_type": "mine",
        "profession_id": "mining",
        "output_resource_id": "huyen_thiet",
        "base_cycle_ticks": 120,
        "base_yield": 10,
        "required_building_level": 30,
        "cultivation_realm_tier": 3,
        "body_realm_tier": 0,
        "common_yield": false
    },
    "forest_linh_moc_t1": {
        "producer_type": "linh_forest",
        "profession_id": "forestry",
        "output_resource_id": "linh_moc",
        "base_cycle_ticks": 60,
        "base_yield": 8000,
        "required_building_level": 1,
        "cultivation_realm_tier": 1,
        "body_realm_tier": 0,
        "common_yield": true
    },
    "field_linh_coc_t1": {
        "producer_type": "spirit_field",
        "profession_id": "herbalism",
        "crop_id": "linh_coc",
        "output_resource_id": "linh_coc",
        "base_cycle_ticks": 60,
        "base_yield": 2500,
        "required_building_level": 1,
        "cultivation_realm_tier": 2,
        "body_realm_tier": 0,
        "common_yield": true
    },
    "field_thanh_linh_thao_t1": {
        "producer_type": "spirit_field",
        "profession_id": "herbalism",
        "crop_id": "thanh_linh_thao",
        "output_resource_id": "thanh_linh_thao",
        "base_cycle_ticks": 90,
        "base_yield": 2000,
        "required_building_level": 1,
        "cultivation_realm_tier": 2,
        "body_realm_tier": 1,
        "common_yield": true
    },
    "field_tu_van_thao_t1": {
        "producer_type": "spirit_field",
        "profession_id": "herbalism",
        "crop_id": "tu_van_thao",
        "output_resource_id": "tu_van_thao",
        "base_cycle_ticks": 180,
        "base_yield": 1000,
        "required_building_level": 30,
        "cultivation_realm_tier": 3,
        "body_realm_tier": 4,
        "common_yield": true
    }
}

func has(plan_id: StringName) -> bool:
    return DEFINITIONS.has(str(plan_id))

func definition(plan_id: StringName) -> Dictionary:
    return DEFINITIONS.get(str(plan_id), {})

func plan_for_resource_producer(building_type: StringName) -> StringName:
    match building_type:
        &"mine":
            return PLAN_MINE_THANH_THIET_T1
        &"linh_forest":
            return PLAN_FOREST_LINH_MOC_T1
        _:
            return &""

func plan_for_crop(crop_id: StringName) -> StringName:
    match crop_id:
        &"linh_coc":
            return PLAN_FIELD_LINH_COC_T1
        &"thanh_linh_thao":
            return PLAN_FIELD_THANH_LINH_THAO_T1
        &"tu_van_thao":
            return PLAN_FIELD_TU_VAN_THAO_T1
        _:
            return &""

func producer_type(plan_id: StringName) -> StringName:
    return StringName(definition(plan_id).get("producer_type", ""))

func profession_id(plan_id: StringName) -> StringName:
    return StringName(definition(plan_id).get("profession_id", ""))

func output_resource_id(plan_id: StringName) -> StringName:
    return StringName(definition(plan_id).get("output_resource_id", ""))

func base_cycle_ticks(plan_id: StringName) -> int:
    return maxi(int(definition(plan_id).get("base_cycle_ticks", 0)), 0)

func base_yield(plan_id: StringName) -> int:
    return maxi(int(definition(plan_id).get("base_yield", 0)), 0)

func required_building_level(plan_id: StringName) -> int:
    return maxi(int(definition(plan_id).get("required_building_level", 1)), 1)

func cultivation_realm_tier(plan_id: StringName) -> int:
    return clampi(int(definition(plan_id).get("cultivation_realm_tier", 0)), 0, DiscipleRealmProgressV2.MAX_REALM)

func body_realm_tier(plan_id: StringName) -> int:
    return clampi(int(definition(plan_id).get("body_realm_tier", 0)), 0, DiscipleRealmProgressV2.MAX_REALM)

# Owner-approved normal-level scaling: +0.5% facility speed per level after Lv1.
func building_speed_factor(level: int) -> float:
    return 1.0 + 0.005 * float(maxi(level - 1, 0))

# Pilot common-output curve. Adjacent levels interpolate geometrically between
# the owner's milestones, avoiding a one-level jump at each milestone.
# This affects routine units per batch only; speed, profession and rare rolls
# retain their separate authorities.
const COMMON_YIELD_MILESTONES := {
    1: 1.0, 10: 2.0, 20: 5.0, 30: 10.0, 40: 30.0,
    50: 100.0, 60: 300.0, 75: 1000.0, 90: 3000.0, 100: 10000.0
}
const COMMON_YIELD_LEVELS := [1, 10, 20, 30, 40, 50, 60, 75, 90, 100]

func common_yield_factor(level: int) -> float:
    var bounded_level := clampi(level, 1, 100)
    if bounded_level == 100:
        return COMMON_YIELD_MILESTONES[100]
    for index in range(COMMON_YIELD_LEVELS.size() - 1):
        var lower: int = COMMON_YIELD_LEVELS[index]
        var upper: int = COMMON_YIELD_LEVELS[index + 1]
        if bounded_level <= upper:
            var fraction := float(bounded_level - lower) / float(upper - lower)
            var low_factor: float = COMMON_YIELD_MILESTONES[lower]
            var high_factor: float = COMMON_YIELD_MILESTONES[upper]
            return low_factor * pow(high_factor / low_factor, fraction)
    return 1.0

func scaled_yield(plan_id: StringName, building_level: int) -> int:
    var base := base_yield(plan_id)
    if base <= 0:
        return 0
    var factor := common_yield_factor(building_level) if bool(definition(plan_id).get("common_yield", false)) else 1.0
    # Keep conversion and later warehouse accounting within the exact safe stack.
    var units := minf(float(base) * factor, float(WarehouseSystem.MAX_SAFE_STACK))
    return maxi(int(round(units)), 1)

func scale_common_requirement(resource_id: StringName, legacy_quantity: int) -> int:
    var quantity := maxi(legacy_quantity, 0)
    if quantity <= 0:
        return 0
    return quantity * COMMON_CONSUMER_SCALE if COMMON_BULK_RESOURCES.has(resource_id) else quantity

func validate_definitions() -> Array[String]:
    var errors: Array[String] = []
    var resources := ResourceRegistry.new()
    for raw_id in DEFINITIONS.keys():
        var plan_id := StringName(raw_id)
        var data: Dictionary = DEFINITIONS[raw_id]
        if producer_type(plan_id) == &"" or profession_id(plan_id) == &"":
            errors.append("Production plan %s has invalid producer/profession." % plan_id)
        var output_id := output_resource_id(plan_id)
        if output_id == &"" or not resources.has(output_id):
            errors.append("Production plan %s has invalid output resource." % plan_id)
        if base_cycle_ticks(plan_id) <= 0 or base_yield(plan_id) <= 0:
            errors.append("Production plan %s has invalid duration/yield." % plan_id)
        var raw_required_level := int(data.get("required_building_level", 0))
        if raw_required_level < 1 or raw_required_level > 100:
            errors.append("Production plan %s has invalid building-level unlock." % plan_id)
        var cultivation_tier := int(data.get("cultivation_realm_tier", -1))
        var body_tier := int(data.get("body_realm_tier", -1))
        if cultivation_tier < 0 or cultivation_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Production plan %s has invalid Tu Vi tier." % plan_id)
        if body_tier < 0 or body_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Production plan %s has invalid Luyện Thể tier." % plan_id)
        if cultivation_tier > 0 and resources.cultivation_realm_tier(output_id) != cultivation_tier:
            errors.append("Production plan %s Tu Vi tier mismatches output resource." % plan_id)
        if body_tier > 0 and resources.body_realm_tier(output_id) != body_tier:
            errors.append("Production plan %s Luyện Thể tier mismatches output resource." % plan_id)
        if data.has("crop_id"):
            var crop_id := StringName(data.get("crop_id", ""))
            if crop_id == &"":
                errors.append("Production plan %s has empty crop id." % plan_id)
    return errors
