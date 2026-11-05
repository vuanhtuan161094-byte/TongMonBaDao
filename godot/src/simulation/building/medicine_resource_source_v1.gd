class_name MedicineResourceSourceV1
extends RefCounted

# Read-only source provenance for actual, authored alchemy recipe ingredients.
# It never unlocks a map, grants loot, bypasses Field upgrades or changes PvE.
# IMPORTANT: HuntingMapV2's instanced encounter regions are NOT the 20-camp
# PVE-P0 continuous world. Show these routes as distinct gameplay modes.

static func routes_for_ingredient(resource_id: StringName) -> Dictionary:
    if not ResourceRegistry.new().has(resource_id):
        return {"ok":false,"reason":"unknown_ingredient"}
    var crop_sources: Array[Dictionary] = []
    var crop_registry := SpiritCropRegistry.new()
    for crop_id in crop_registry.all_crop_ids():
        if crop_registry.output_resource_id(crop_id) != resource_id:
            continue
        crop_sources.append({
            "kind":"spirit_field",
            "crop_id":str(crop_id),
            "field_level":int(crop_registry.definition(crop_id).get("required_field_level", 1))
        })

    # Existing HuntingMapV2 encounter rewards are real code but belong to a
    # different route than continuous PVE-P0. Do NOT treat these as P0 drops.
    var instance_map_sources: Array[Dictionary] = []
    var map_ids: Array = HuntingMapV2.REGION_CONTENT.keys()
    map_ids.sort()
    for raw_id in map_ids:
        var map_data: Dictionary = HuntingMapV2.REGION_CONTENT[raw_id]
        var guaranteed: Dictionary = map_data.get("resources", {})
        var rare_id := str(map_data.get("rare", ""))
        var is_normal := int(guaranteed.get(str(resource_id), 0)) > 0
        var is_rare := rare_id == str(resource_id)
        if not is_normal and not is_rare:
            continue
        instance_map_sources.append({
            "kind":"instanced_hunting_map",
            "region_id":str(raw_id),
            "name":str(map_data.get("name", raw_id)),
            "rare":is_rare
        })
    return {"ok":true,"ingredient_id":str(resource_id),
        "spirit_fields":crop_sources,"instanced_maps":instance_map_sources}

static func routes_for_recipe(recipe_id: StringName) -> Dictionary:
    var registry := AlchemyRecipeRegistry.new()
    if not registry.has(recipe_id):
        return {"ok":false,"reason":"recipe_not_authored"}
    var requirements := registry.inputs(recipe_id)
    if requirements.is_empty():
        return {"ok":false,"reason":"recipe_has_no_inputs"}
    var inputs: Array[Dictionary] = []
    var ingredient_ids: Array = requirements.keys()
    ingredient_ids.sort()
    for raw_id in ingredient_ids:
        var source := routes_for_ingredient(StringName(raw_id))
        if not bool(source.get("ok",false)):
            return source
        if source.get("spirit_fields",[]).is_empty() and source.get("instanced_maps",[]).is_empty():
            return {"ok":false,"reason":"ingredient_without_authored_source","ingredient_id":str(raw_id)}
        inputs.append({"ingredient_id":str(raw_id),"quantity":int(requirements[raw_id]),
            "source":source})
    return {"ok":true,"recipe_id":str(recipe_id),"inputs":inputs}

static func guidance_text(recipe_id: StringName) -> String:
    var routes := routes_for_recipe(recipe_id)
    if not bool(routes.get("ok",false)):
        return "Chưa có công thức hoặc nguồn nguyên liệu đã biên soạn."
    var resources := ResourceRegistry.new()
    var notes: Array[String] = []
    for raw_row in routes.get("inputs",[]):
        var row: Dictionary = raw_row
        var source: Dictionary = row.get("source",{})
        var choices: Array[String] = []
        for crop in source.get("spirit_fields",[]):
            choices.append("Linh Điền Lv%d" % int(crop.get("field_level",1)))
        for hunting_map in source.get("instanced_maps",[]):
            choices.append("Săn theo cấp: %s%s" % [
                str(hunting_map.get("name","")),
                " (hiếm)" if bool(hunting_map.get("rare",false)) else ""
            ])
        notes.append("%s ×%d: %s" % [
            resources.display_name(StringName(row.get("ingredient_id",""))),
            int(row.get("quantity",0)),
            "; ".join(choices)
        ])
    return "\n".join(notes) + "\nBản đồ săn theo cấp khác với PvE liên tục 20 khu."
