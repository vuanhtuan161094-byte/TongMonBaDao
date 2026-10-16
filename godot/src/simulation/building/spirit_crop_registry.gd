class_name SpiritCropRegistry
extends RefCounted

const CROP_THANH_LINH_THAO := &"thanh_linh_thao"
const CROP_LINH_COC := &"linh_coc"
const CROP_TU_VAN_THAO := &"tu_van_thao"

var production_plans := ProductionPlanRegistry.new()

const DEFINITIONS := {
    "thanh_linh_thao": {
        "name": "Thanh Linh Thảo",
        "output_resource_id": "thanh_linh_thao",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "cultivation_realm_tier": 2,
        "body_realm_tier": 1,
        "required_field_level": 1,
        "plant_cost_spirit_stones": 4,
        "production_plan_id": "field_thanh_linh_thao_t1",
        "base_work_xp": 10.0,
        "stock_target": 4000,
        "affinity_elements": ["wood", "water"],
        "tags": ["herb", "alchemy"]
    },
    "linh_coc": {
        "name": "Linh Cốc",
        "output_resource_id": "linh_coc",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "cultivation_realm_tier": 2,
        "body_realm_tier": 0,
        "required_field_level": 1,
        "plant_cost_spirit_stones": 3,
        "production_plan_id": "field_linh_coc_t1",
        "base_work_xp": 8.0,
        "stock_target": 5000,
        "affinity_elements": ["earth", "water"],
        "tags": ["spirit_grain", "food"]
    },
    "tu_van_thao": {
        "name": "Tử Vân Thảo",
        "output_resource_id": "tu_van_thao",
        "realm_grade": "truc_co",
        "realm_rank": 2,
        "cultivation_realm_tier": 3,
        "body_realm_tier": 4,
        "required_field_level": 30,
        "plant_cost_spirit_stones": 14,
        "production_plan_id": "field_tu_van_thao_t1",
        "base_work_xp": 16.0,
        "stock_target": 2000,
        "affinity_elements": ["wood"],
        "tags": ["herb", "alchemy", "advanced_crop"]
    }
}

func has(crop_id: StringName) -> bool:
    return DEFINITIONS.has(str(crop_id))

func definition(crop_id: StringName) -> Dictionary:
    return DEFINITIONS.get(str(crop_id), {})

func all_crop_ids() -> Array[StringName]:
    var result: Array[StringName] = []
    var ids: Array = DEFINITIONS.keys()
    ids.sort()
    for raw_id in ids:
        result.append(StringName(raw_id))
    return result

func production_plan_id(crop_id: StringName) -> StringName:
    return StringName(definition(crop_id).get("production_plan_id", ""))

func cultivation_realm_tier(crop_id: StringName) -> int:
    return clampi(int(definition(crop_id).get("cultivation_realm_tier", 0)), 0, DiscipleRealmProgressV2.MAX_REALM)

func body_realm_tier(crop_id: StringName) -> int:
    return clampi(int(definition(crop_id).get("body_realm_tier", 0)), 0, DiscipleRealmProgressV2.MAX_REALM)

func cultivation_realm_name(crop_id: StringName) -> String:
    var realm := cultivation_realm_tier(crop_id)
    return DiscipleRealmProgressV2.realm_name("cultivation", realm) if realm > 0 else ""

func body_realm_name(crop_id: StringName) -> String:
    var realm := body_realm_tier(crop_id)
    return DiscipleRealmProgressV2.realm_name("body", realm) if realm > 0 else ""

func eligible_crop_ids(field_level: int) -> Array[StringName]:
    var result: Array[StringName] = []
    for crop_id in all_crop_ids():
        if int(definition(crop_id).get("required_field_level", 1)) <= field_level:
            result.append(crop_id)
    return result

func display_name(crop_id: StringName) -> String:
    return str(definition(crop_id).get("name", crop_id))

func output_resource_id(crop_id: StringName) -> StringName:
    return StringName(definition(crop_id).get("output_resource_id", crop_id))

func cost(crop_id: StringName) -> int:
    return maxi(int(definition(crop_id).get("plant_cost_spirit_stones", 0)), 0)

func base_cycle_ticks(crop_id: StringName) -> int:
    return maxi(production_plans.base_cycle_ticks(production_plan_id(crop_id)), 1)

func base_yield(crop_id: StringName) -> int:
    return maxi(production_plans.base_yield(production_plan_id(crop_id)), 1)

func base_work_xp(crop_id: StringName) -> float:
    return maxf(float(definition(crop_id).get("base_work_xp", 0.0)), 0.0)

func stock_target(crop_id: StringName) -> int:
    return maxi(int(definition(crop_id).get("stock_target", 1)), 1)

func affinity_elements(crop_id: StringName) -> Array[String]:
    var result: Array[String] = []
    var raw = definition(crop_id).get("affinity_elements", [])
    if raw is Array:
        for item in raw:
            result.append(str(item))
    result.sort()
    return result

func validate_definitions() -> Array[String]:
    var errors: Array[String] = []
    var resources := ResourceRegistry.new()
    for crop_id in all_crop_ids():
        var data := definition(crop_id)
        var output_id := output_resource_id(crop_id)
        if str(data.get("name", "")) == "":
            errors.append("Crop %s has no display name." % crop_id)
        if not resources.has(output_id):
            errors.append("Crop %s references unknown output resource %s." % [crop_id, output_id])
        if int(data.get("required_field_level", 0)) < 1:
            errors.append("Crop %s has invalid field-level requirement." % crop_id)
        var cultivation_tier := int(data.get("cultivation_realm_tier",-1))
        var body_tier := int(data.get("body_realm_tier",-1))
        if cultivation_tier < 0 or cultivation_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Crop %s has invalid cultivation-realm tier alignment." % crop_id)
        if body_tier < 0 or body_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Crop %s has invalid body-realm tier alignment." % crop_id)
        if cultivation_tier > 0 and cultivation_realm_name(crop_id).is_empty():
            errors.append("Crop %s cultivation realm has no canonical name." % crop_id)
        if body_tier > 0 and body_realm_name(crop_id).is_empty():
            errors.append("Crop %s body realm has no canonical name." % crop_id)
        var plan_id := production_plan_id(crop_id)
        if not production_plans.has(plan_id):
            errors.append("Crop %s has no canonical ProductionPlan." % crop_id)
        else:
            if production_plans.producer_type(plan_id) != &"spirit_field":
                errors.append("Crop %s ProductionPlan has wrong producer type." % crop_id)
            if production_plans.output_resource_id(plan_id) != output_resource_id(crop_id):
                errors.append("Crop %s ProductionPlan output mismatches crop output." % crop_id)
            if production_plans.required_building_level(plan_id) != int(data.get("required_field_level", 1)):
                errors.append("Crop %s ProductionPlan unlock mismatches field level." % crop_id)
            if production_plans.cultivation_realm_tier(plan_id) != cultivation_realm_tier(crop_id):
                errors.append("Crop %s ProductionPlan Tu Vi tier mismatch." % crop_id)
            if production_plans.body_realm_tier(plan_id) != body_realm_tier(crop_id):
                errors.append("Crop %s ProductionPlan Luyện Thể tier mismatch." % crop_id)
        if cost(crop_id) <= 0:
            errors.append("Crop %s has invalid Spirit Stone cost." % crop_id)
        if base_cycle_ticks(crop_id) <= 0 or base_yield(crop_id) <= 0:
            errors.append("Crop %s has invalid ProductionPlan cycle/yield." % crop_id)
        if stock_target(crop_id) <= 0:
            errors.append("Crop %s has invalid stock target." % crop_id)
    return errors
