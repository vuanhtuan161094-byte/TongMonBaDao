class_name AlchemyRecipeRegistry
extends RefCounted

const RECIPE_HOI_XUAN_DAN := &"hoi_xuan_dan"

const DEFINITIONS := {
    "hoi_xuan_dan": {
        "name": "Hồi Xuân Đan",
        # Bulk consumer balance: one Lv1 four-plot Thanh Linh Thảo field
        # supplies roughly one continuously-working 6-minute Alchemy line.
        "inputs": {"thanh_linh_thao": 500},
        "output_resource_id": "hoi_xuan_dan",
        "output_quantity": 1,
        "required_profession_level": 0,
        "base_cycle_ticks": 6,
        "cultivation_realm_tier": 2,
        "body_realm_tier": 0
    }
}

func has(recipe_id: StringName) -> bool:
    return DEFINITIONS.has(str(recipe_id))

func definition(recipe_id: StringName) -> Dictionary:
    return DEFINITIONS.get(str(recipe_id), {})

func inputs(recipe_id: StringName) -> Dictionary:
    var raw = definition(recipe_id).get("inputs", {})
    return raw.duplicate(true) if raw is Dictionary else {}

func output_resource_id(recipe_id: StringName) -> StringName:
    return StringName(definition(recipe_id).get("output_resource_id", ""))

func output_quantity(recipe_id: StringName) -> int:
    return maxi(int(definition(recipe_id).get("output_quantity", 0)), 0)

func required_profession_level(recipe_id: StringName) -> int:
    return maxi(int(definition(recipe_id).get("required_profession_level", 0)), 0)

func base_cycle_ticks(recipe_id: StringName) -> int:
    return maxi(int(definition(recipe_id).get("base_cycle_ticks", 1)), 1)

func cultivation_realm_tier(recipe_id: StringName) -> int:
    return clampi(int(definition(recipe_id).get("cultivation_realm_tier", 0)), 0, DiscipleRealmProgressV2.MAX_REALM)

func body_realm_tier(recipe_id: StringName) -> int:
    return clampi(int(definition(recipe_id).get("body_realm_tier", 0)), 0, DiscipleRealmProgressV2.MAX_REALM)

func validate_definitions() -> Array[String]:
    var errors: Array[String] = []
    var resources := ResourceRegistry.new()
    for raw_id in DEFINITIONS.keys():
        var recipe_id := StringName(raw_id)
        var requirements := inputs(recipe_id)
        if requirements.is_empty():
            errors.append("Alchemy recipe %s has no inputs." % recipe_id)
        for raw_resource in requirements.keys():
            if not resources.has(StringName(raw_resource)) or int(requirements[raw_resource]) <= 0:
                errors.append("Alchemy recipe %s has invalid input %s." % [recipe_id, raw_resource])
        var output_id := output_resource_id(recipe_id)
        if output_id == &"" or not resources.has(output_id) or output_quantity(recipe_id) <= 0:
            errors.append("Alchemy recipe %s has invalid output." % recipe_id)
        var cultivation_tier := cultivation_realm_tier(recipe_id)
        var body_tier := body_realm_tier(recipe_id)
        if cultivation_tier <= 0 or cultivation_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Alchemy recipe %s has invalid Tu Vi tier." % recipe_id)
        if body_tier < 0 or body_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Alchemy recipe %s has invalid Luyện Thể tier." % recipe_id)
        if cultivation_tier > 0 and resources.cultivation_realm_tier(output_id) != cultivation_tier:
            errors.append("Alchemy recipe %s tier mismatches output resource." % recipe_id)
    return errors
