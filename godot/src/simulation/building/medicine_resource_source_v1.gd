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

    # Existing canonical worksite deliveries. A mine can select ores only
    # after the actual Mine level is reached; the Forest is an earned job.
    var mine_sources: Array[Dictionary] = []
    if BuildingSystem.MINE_ORE_OPTIONS.has(str(resource_id)):
        var option: Dictionary = BuildingSystem.MINE_ORE_OPTIONS[str(resource_id)]
        mine_sources.append({"kind":"mine","building_type":"mine",
            "required_building_level":int(option.get("required_level",1)),
            "worker_profession":"mining","settlement":"sect_main_warehouse"})
    var forest_sources: Array[Dictionary] = []
    if BuildingSystem.FOREST_MATERIAL_OPTIONS.has(str(resource_id)):
        var forest_option: Dictionary = BuildingSystem.FOREST_MATERIAL_OPTIONS[str(resource_id)]
        forest_sources.append({"kind":"linh_forest","building_type":"linh_forest",
            "required_building_level":int(forest_option.get("required_level",1)),
            "worker_profession":"forestry","settlement":"sect_main_warehouse"})

    # Paid daily merchant inventory is a real source but NOT farming; it needs
    # actual Spirit Stones and daily merchant stock. Do not label as PvE loot.
    var npc_sources: Array[Dictionary] = []
    if EconomySystem.V2_MARKET_CATALOG.has(str(resource_id)):
        var base_price := int(EconomySystem.V57_BODY_GATE_BASE_PRICES.get(
            str(resource_id),ResourceRegistry.new().definition(resource_id).get("market_value",0)))
        if base_price > 0:
            npc_sources.append({"kind":"npc_market","requires_spirit_stones":true,
                "base_price":base_price,"daily_stock_limited":true})

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
    # The canonical P0 world is a separate continuous route: only an
    # authoritative kill reward with a real, loot-ready species can provide
    # the resource. Discover existing drop tables; never synthesize loot.
    var continuous_pve_sources: Array[Dictionary] = []
    var world_zone := PveMultiCampPopulationV1.ZONE
    if HuntingMapV2.REGION_CONTENT.has(world_zone):
        var world_species: Dictionary = HuntingMapV2.REGION_CONTENT[world_zone].get("normal", {})
        var species_ids: Array = PvePerKillRewardV1.DROP_TABLES.keys()
        species_ids.sort()
        for raw_species in species_ids:
            var species_id := str(raw_species)
            if not world_species.has(species_id) or not MonsterCatalogueV2.SPECIES.has(species_id):
                continue
            var species: Dictionary = MonsterCatalogueV2.SPECIES[species_id]
            if not bool(species.get("loot_ready", false)):
                continue
            for raw_drop in PvePerKillRewardV1.DROP_TABLES[species_id]:
                if not (raw_drop is Dictionary):
                    continue
                var drop: Dictionary = raw_drop
                var chance := float(drop.get("chance", 0.0))
                var amount := int(drop.get("amount", 0))
                if str(drop.get("id", "")) != str(resource_id) or chance <= 0.0 or chance > 1.0 or amount <= 0:
                    continue
                continuous_pve_sources.append({
                    "kind": "continuous_pve_p0",
                    "region_id": world_zone,
                    "camp_count": PveMultiCampPopulationV1.CAMP_COUNT,
                    "species_id": species_id,
                    "species_name": str(species.get("name", species_id)),
                    "chance_per_species_kill": chance,
                    "amount": amount
                })
    return {"ok":true,"ingredient_id":str(resource_id),
        "spirit_fields":crop_sources,"mines":mine_sources,
        "forests":forest_sources,"npc_markets":npc_sources,
        "instanced_maps":instance_map_sources,
        "continuous_pve_p0":continuous_pve_sources}

static func routes_for_recipe(recipe_id: StringName) -> Dictionary:
    var registry := AlchemyRecipeRegistry.new()
    if not registry.has(recipe_id):
        return {"ok":false,"reason":"recipe_not_authored"}
    var requirements := registry.inputs(recipe_id)
    if requirements.is_empty():
        return {"ok":false,"reason":"recipe_has_no_inputs"}
    var checked := routes_for_requirements(requirements)
    if not bool(checked.get("ok",false)):
        checked["recipe_id"] = str(recipe_id)
        return checked
    checked["recipe_id"] = str(recipe_id)
    return checked

# Checks the REAL input snapshot of the new batch, including Q2-Q4 catalysts
# and Mine/Forest/Field inputs. It does NOT deduct stock or mint rewards.
static func routes_for_requirements(requirements: Dictionary) -> Dictionary:
    if requirements.is_empty():
        return {"ok":false,"reason":"recipe_has_no_inputs"}
    var inputs: Array[Dictionary] = []
    var ingredient_ids: Array = requirements.keys()
    ingredient_ids.sort()
    for raw_id in ingredient_ids:
        var source := routes_for_ingredient(StringName(raw_id))
        if not bool(source.get("ok",false)):
            return source
        if source.get("spirit_fields",[]).is_empty() and source.get("mines",[]).is_empty() \
                and source.get("forests",[]).is_empty() and source.get("npc_markets",[]).is_empty() \
                and source.get("instanced_maps",[]).is_empty() and source.get("continuous_pve_p0",[]).is_empty():
            return {"ok":false,"reason":"ingredient_without_authored_source","ingredient_id":str(raw_id)}
        inputs.append({"ingredient_id":str(raw_id),"quantity":int(requirements[raw_id]),
            "source":source})
    return {"ok":true,"inputs":inputs}

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
        for mine in source.get("mines",[]):
            choices.append("Mỏ Lv%d, việc khai thác có giao Kho" % int(mine.get("required_building_level",1)))
        for forest in source.get("forests",[]):
            choices.append("Linh Lâm, việc khai thác có giao Kho")
        for shop in source.get("npc_markets",[]):
            choices.append("Phường Thị: dùng LT thật, chịu giới hạn nguồn hàng/ngày")
        for hunting_map in source.get("instanced_maps",[]):
            choices.append("Săn theo cấp: %s%s" % [
                str(hunting_map.get("name","")),
                " (hiếm)" if bool(hunting_map.get("rare",false)) else ""
            ])
        for p0_route in source.get("continuous_pve_p0",[]):
            choices.append("PvE liên tục %d khu: hạ %s (%.1f%% mỗi lần hạ đúng loài, ×%d)" % [
                int(p0_route.get("camp_count",0)),
                str(p0_route.get("species_name","")),
                100.0 * float(p0_route.get("chance_per_species_kill",0.0)),
                int(p0_route.get("amount",0))
            ])
        notes.append("%s ×%d: %s" % [
            resources.display_name(StringName(row.get("ingredient_id",""))),
            int(row.get("quantity",0)),
            "; ".join(choices)
        ])
    return "\n".join(notes) + "\nBản đồ săn theo cấp và PvE liên tục là hai chế độ khác nhau; chỉ thắng trận/hạ quái thật mới nhận vật phẩm."
