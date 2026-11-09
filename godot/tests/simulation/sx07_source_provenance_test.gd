extends SceneTree

# SX-07 source contract: no mock drops, grants, money, or duplicate Warehouse.
var checks := 0
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, msg: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("SX07 SOURCE FAIL: "+msg)

func _has_route(data: Dictionary) -> bool:
    for key in ["spirit_fields","mines","forests","npc_markets",
                "instanced_maps","continuous_pve_p0"]:
        if not data.get(key,[]).is_empty():
            return true
    return false

func _run() -> void:
    var registry := AlchemyRecipeRegistry.new()
    var authored := MedicineCatalogueV2.authored_recipes()
    _check(authored.size() == 8,"only eight early recipes are authored")
    _check(MedicineCatalogueV2.all_recipe_ids().size() == 119,"119 recipe identities")
    _check(MedicineCatalogueV2.all_item_ids().size() == 476,"476 quality identities")
    _check(registry.validate_definitions().is_empty(),"all authored recipes have real input sources")
    for recipe in authored:
        var recipe_data := registry.definition(recipe)
        _check(not recipe_data.is_empty(),"authored recipe exists: "+str(recipe))
        var src := MedicineResourceSourceV1.routes_for_recipe(recipe)
        _check(bool(src.get("ok",false)),"source exists: "+str(recipe)+" / "+str(src))
        _check(int(recipe_data.get("output_quantity",0)) > 0,"real positive output: "+str(recipe))
        _check(int(recipe_data.get("base_cycle_ticks",0)) > 0,"real work duration: "+str(recipe))
    var pending := 0
    for id in MedicineCatalogueV2.all_recipe_ids():
        if authored.has(id):
            continue
        pending += 1
        _check(not registry.has(id),"unsourced recipe blocked: "+str(id))
        _check(not bool(MedicineResourceSourceV1.routes_for_recipe(id).get("ok",false)),
            "unsourced route blocked: "+str(id))
    _check(pending == 111,"111 proposed recipes stay unavailable")
    var known := ResourceRegistry.new()
    for ingredient in [&"thanh_linh_thao",&"linh_coc",&"tu_van_thao",
                       &"thanh_thiet",&"huyen_thiet",&"linh_moc",
                       &"tinh_lang_bi",&"linh_tuy"]:
        _check(known.has(ingredient),"canonical ingredient ID: "+str(ingredient))
        _check(_has_route(MedicineResourceSourceV1.routes_for_ingredient(ingredient)),
            "canonical source route: "+str(ingredient))
    _check(not bool(MedicineResourceSourceV1.routes_for_ingredient(
        &"sx07_fake").get("ok",false)),"unknown input cannot get a source")
    var ore := MedicineResourceSourceV1.routes_for_ingredient(&"huyen_thiet")
    _check(ore.get("mines",[]).size() > 0 and
        int(ore["mines"][0].get("required_building_level",0)) == 10,
        "Huyen Thiet requires Mine Lv10")
    var wood := MedicineResourceSourceV1.routes_for_ingredient(&"linh_moc")
    _check(wood.get("forests",[]).size() > 0,"Linh Moc comes from real forest work")
    var herb := MedicineResourceSourceV1.routes_for_ingredient(&"tu_van_thao")
    _check(herb.get("spirit_fields",[]).size() > 0 and
        int(herb["spirit_fields"][0].get("field_level",0)) == 10,
        "Tu Van Thao needs Field Lv10")
    _check(not bool(MedicineResourceSourceV1.routes_for_requirements(
        {"unknown_ingredient_for_sx07":1}).get("ok",false)),
        "unregistered BOM fails closed")

    # No production is executed. Check the live planner's complete BOM after
    # paid quality catalysts are added, for all 8 recipes and 4 qualities.
    var state := P37Factory.create_state(570070)
    var system := BuildingSystem.new()
    var hall := system.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    _check(hall != null,"canonical Alchemy Hall is present")
    if hall != null:
        hall.level = 20
        for recipe in authored:
            for grade in range(1,5):
                hall.production_state["v57_selected_quality"] = grade
                var plan := system._v57_alchemy_plan(state,hall,recipe,10)
                _check(bool(plan.get("ok",false)),
                    "Q%d grade plan exists for %s" % [grade,recipe])
                if bool(plan.get("ok",false)):
                    var route := MedicineResourceSourceV1.routes_for_requirements(
                        plan.get("requirements",{}))
                    _check(bool(route.get("ok",false)),
                        "Q%d grade BOM has real sources: %s / %s" % [grade,recipe,route])
                    var cost := system.alchemy_batch_cost_reference(
                        state,hall.id,recipe,10)
                    _check(bool(cost.get("ok",false)),
                        "Q%d cost reference has positive priced inputs: %s / %s" % [
                            grade,recipe,cost])
                    _check(int(cost.get("output_quantity",0)) ==
                        (6 if str(MedicineCatalogueV2.parse_recipe(recipe).get("family","")) ==
                            MedicineCatalogueV2.FAMILY_BREAK else 39),
                        "Q%d batch quantity uses real profession bonus: %s" % [grade,recipe])
    print("SX07 SOURCE CONTRACT %d checks; failures=%d" % [checks,failures])
    quit(1 if failures > 0 else 0)
