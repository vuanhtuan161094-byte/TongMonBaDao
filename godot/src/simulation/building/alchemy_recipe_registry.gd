class_name AlchemyRecipeRegistry
extends RefCounted

const RECIPE_HOI_XUAN_DAN := &"hoi_xuan_dan"

const RECIPE_TU_KHI_DAN := &"tu_khi_dan"

const DEFINITIONS := {
    "tu_khi_dan": {
        "name":"Tụ Khí Đan", "inputs":{"thanh_linh_thao":2,"linh_coc":1},
        "output_resource_id":"tu_khi_dan", "output_quantity":1,
        "required_profession_level":0, "base_cycle_ticks":6
    },
    "hoi_xuan_dan": {
        "name": "Hồi Xuân Đan",
        "inputs": {"thanh_linh_thao": 3},
        "output_resource_id": "hoi_xuan_dan",
        "output_quantity": 1,
        "required_profession_level": 0,
        "base_cycle_ticks": 6
    }
}

func has(recipe_id: StringName) -> bool:
    return DEFINITIONS.has(str(recipe_id)) or not MedicineCatalogueV2.recipe_definition(recipe_id).is_empty()

func definition(recipe_id: StringName) -> Dictionary:
    if DEFINITIONS.has(str(recipe_id)):
        return DEFINITIONS[str(recipe_id)]
    return MedicineCatalogueV2.recipe_definition(recipe_id)

func inputs(recipe_id: StringName) -> Dictionary:
    var raw = definition(recipe_id).get("inputs", {})
    return raw.duplicate(true) if raw is Dictionary else {}

func output_resource_id(recipe_id: StringName) -> StringName:
    return StringName(definition(recipe_id).get("output_resource_id", ""))

func output_quantity(recipe_id: StringName) -> int:
    return maxi(int(definition(recipe_id).get("output_quantity", 0)), 0)

func required_profession_level(recipe_id: StringName) -> int:
    return maxi(int(definition(recipe_id).get("required_profession_level", 0)), 0)

func required_hall_level(recipe_id: StringName) -> int:
    return maxi(int(definition(recipe_id).get("required_hall_level", 1)), 1)

func base_cycle_ticks(recipe_id: StringName) -> int:
    return maxi(int(definition(recipe_id).get("base_cycle_ticks", 1)), 1)

func validate_definitions() -> Array[String]:
    var errors: Array[String] = []
    var resources := ResourceRegistry.new()
    var authored: Array = DEFINITIONS.keys()
    for new_recipe in MedicineCatalogueV2.authored_recipes():
        authored.append(str(new_recipe))
    for raw_id in authored:
        var recipe_id := StringName(raw_id)
        var requirements := inputs(recipe_id)
        if requirements.is_empty():
            errors.append("Alchemy recipe %s has no inputs." % recipe_id)
        for raw_resource in requirements.keys():
            if not resources.has(StringName(raw_resource)) or int(requirements[raw_resource]) <= 0:
                errors.append("Alchemy recipe %s has invalid input %s." % [recipe_id, raw_resource])
        if not MedicineCatalogueV2.parse_recipe(recipe_id).is_empty():
            var provenance := MedicineResourceSourceV1.routes_for_recipe(recipe_id)
            if not bool(provenance.get("ok",false)):
                errors.append("Alchemy recipe %s source missing: %s" % [
                    recipe_id,str(provenance.get("ingredient_id",provenance.get("reason","unknown")))
                ])
        var output_id := output_resource_id(recipe_id)
        if output_id == &"" or not resources.has(output_id) or output_quantity(recipe_id) <= 0:
            errors.append("Alchemy recipe %s has invalid output." % recipe_id)
    return errors
