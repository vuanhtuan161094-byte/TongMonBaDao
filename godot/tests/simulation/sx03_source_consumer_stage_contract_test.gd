extends SceneTree

# BAL-04 / SX-03 read-only regression gate:
# - Catalogued source IDs must connect to authored consumers.
# - Only genuinely authored alchemy recipes count as craftable.
# - Field level and resource cost are not bypassed to fabricate a late tier.
# - No resources, money, XP, save or user state are created/mutated.
#
# This test does NOT approve numeric balance or prove Windows/Android gameplay.
# Run on official Godot 4.7.2 at the exact candidate SHA.

var checks := 0
var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _expect(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures.append(label)
        push_error("SX03 source-consumer FAIL: " + label)


func _run() -> void:
    var resources := ResourceRegistry.new()
    var crops := SpiritCropRegistry.new()
    var recipes := AlchemyRecipeRegistry.new()
    var produced: Dictionary = {}
    var consumed: Dictionary = {}
    var crop_outputs: Dictionary = {}

    # These are live production entry points, not historical/imaginary sources.
    for building_type in [BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST]:
        var building_row: Dictionary = BuildingSystem.DEFINITIONS.get(str(building_type), {})
        var output_id := str(building_row.get("resource_id", ""))
        _expect(not building_row.is_empty() and str(building_row.get("job_model", "")) == "carry_cycle",
            "live carry-cycle producer exists: " + str(building_type))
        _expect(not output_id.is_empty() and resources.has(StringName(output_id)),
            "live mine/forest output is a valid warehouse resource: " + output_id)
        produced[output_id] = "building:" + str(building_type)

    for crop_id in crops.all_crop_ids():
        var output_id := str(crops.output_resource_id(crop_id))
        var row: Dictionary = crops.definition(crop_id)
        _expect(resources.has(StringName(output_id)), "crop output resolves in ResourceRegistry: " + output_id)
        _expect(crops.cost(crop_id) > 0 and crops.base_cycle_ticks(crop_id) > 0
            and crops.base_yield(crop_id) > 0, "crop has real paid positive cycle/yield: " + str(crop_id))
        _expect(int(row.get("required_field_level", 0)) >= 1
            and int(row.get("required_field_level", 0)) <= 100,
            "crop has reachable nominal field-level gate: " + str(crop_id))
        _expect(crops.eligible_crop_ids(int(row["required_field_level"])).has(crop_id),
            "crop unlocks at its authored field level: " + str(crop_id))
        if int(row["required_field_level"]) > 1:
            _expect(not crops.eligible_crop_ids(int(row["required_field_level"]) - 1).has(crop_id),
                "crop cannot appear below its level gate: " + str(crop_id))
        produced[output_id] = "spirit_field:" + str(crop_id)
        crop_outputs[output_id] = true

    # Only legacy and actually authored SX02 recipes count as current consumers.
    # Higher-tier medicine identities are catalogued future content, NOT loot
    # and NOT craftable unless a real source and an authored recipe are added.
    var authored: Array[StringName] = []
    for raw_id in AlchemyRecipeRegistry.DEFINITIONS.keys():
        authored.append(StringName(raw_id))
    for recipe_id in MedicineCatalogueV2.authored_recipes():
        authored.append(recipe_id)

    _expect(not authored.is_empty(), "at least one real current recipe exists")
    for recipe_id in authored:
        var recipe: Dictionary = recipes.definition(recipe_id)
        var inputs := recipes.inputs(recipe_id)
        var output_id := recipes.output_resource_id(recipe_id)
        _expect(not recipe.is_empty() and not inputs.is_empty(),
            "authored recipe has actual ingredients: " + str(recipe_id))
        _expect(resources.has(output_id) and recipes.output_quantity(recipe_id) > 0,
            "authored recipe has a real registered product: " + str(recipe_id))
        _expect(recipes.base_cycle_ticks(recipe_id) > 0
            and recipes.required_hall_level(recipe_id) >= 1
            and recipes.required_profession_level(recipe_id) >= 0,
            "authored recipe has a positive completion time and numeric work gates: " + str(recipe_id))
        for raw_input in inputs.keys():
            var ingredient := str(raw_input)
            _expect(int(inputs[raw_input]) > 0 and resources.has(StringName(ingredient)),
                "recipe input is positive and valid: " + str(recipe_id) + " / " + ingredient)
            _expect(produced.has(ingredient),
                "every current alchemy ingredient is produced by real mine/forest/field: "
                + str(recipe_id) + " / " + ingredient)
            consumed[ingredient] = int(consumed.get(ingredient, 0)) + 1

        # A craftable SKU must have a B3-recognized effect family, not just a name.
        var medicine := MedicineCatalogueV2.definition(output_id)
        _expect(B3PillSatietyV1.COSTS.has(str(output_id))
            or str(medicine.get("pill_family", "")) in
                [MedicineCatalogueV2.FAMILY_HEAL, MedicineCatalogueV2.FAMILY_TUVI],
            "crafted medicine has a functioning B3 heal/tuvi consumer: " + str(recipe_id))

    for crop_output in crop_outputs.keys():
        _expect(consumed.has(str(crop_output)),
            "every currently farmable crop has at least one implemented recipe consumer: "
            + str(crop_output))

    # Future catalogue identity is not permission to forge high-tier medicine.
    for realm in range(1, MedicineCatalogueV2.MAX_REALM + 1):
        for family in [MedicineCatalogueV2.FAMILY_HEAL, MedicineCatalogueV2.FAMILY_TUVI]:
            var id := MedicineCatalogueV2.recipe_id(family, realm)
            var actual := recipes.has(id)
            var authored_realm := MedicineCatalogueV2.AUTHORED_RECIPE_REALMS.has(realm)
            _expect(actual == authored_realm,
                "future medicine cannot be silently crafted without authored inputs: "
                + str(id))

    # Route discovery is read-only and must never imply a continuous-world
    # P0 source for a legacy instanced HuntingMapV2 encounter.
    for recipe_id in authored:
        var sourced := MedicineResourceSourceV1.routes_for_recipe(recipe_id)
        _expect(bool(sourced.get("ok",false)),
            "authored medicine recipe has actual Field/instanced-map source guidance: " + str(recipe_id))
        _expect(not MedicineResourceSourceV1.guidance_text(recipe_id).is_empty(),
            "player-facing source guidance exists for authored recipe: " + str(recipe_id))
    var advanced_herb := MedicineResourceSourceV1.routes_for_ingredient(&"tu_van_thao")
    var advanced_fields: Array = advanced_herb.get("spirit_fields",[])
    _expect(advanced_fields.size() == 1 and
        int(advanced_fields[0].get("field_level",0)) == 10,
        "Tử Vân remains genuinely Field Lv10, not an automatic unlock")
    var instanced_sources: Array = advanced_herb.get("instanced_maps",[])
    var legacy_map_found := false
    for map_source in instanced_sources:
        if str(map_source.get("region_id","")) == "bach_thach_khe":
            legacy_map_found = true
    _expect(legacy_map_found,
        "Existing Bạch Thạch Khê instanced reward is discoverable and distinct from 20-camp P0")

    # A genuine HP0 in the P0 continuous world already has a chance to
    # award Thanh Linh Thảo from Trúc Thử. The UI must disclose this route
    # without claiming that Tử Vân Thảo also drops in that world.
    var p0_herb := MedicineResourceSourceV1.routes_for_ingredient(&"thanh_linh_thao")
    var continuous_sources: Array = p0_herb.get("continuous_pve_p0", [])
    var p0_herb_found := false
    for p0_source in continuous_sources:
        if str(p0_source.get("species_id", "")) == "truc_thu" \
                and int(p0_source.get("camp_count", 0)) == 20 \
                and is_equal_approx(float(p0_source.get("chance_per_species_kill", 0.0)), 0.05) \
                and int(p0_source.get("amount", 0)) == 1:
            p0_herb_found = true
    _expect(p0_herb_found, "P0 Trúc Thử real 5% per kill Thanh Linh source is discoverable")
    _expect((advanced_herb.get("continuous_pve_p0", []) as Array).is_empty(),
        "No fictional P0 Tử Vân Thảo drop is advertised")
    var r1_routes := MedicineResourceSourceV1.routes_for_recipe(
        MedicineCatalogueV2.recipe_id("heal", 1))
    var r1_inputs: Array = r1_routes.get("inputs", [])
    var r1_uses_world := false
    for ingredient in r1_inputs:
        if str(ingredient.get("ingredient_id", "")) == "thanh_linh_thao" \
                and not (ingredient.get("source", {}).get("continuous_pve_p0", []) as Array).is_empty():
            r1_uses_world = true
    _expect(r1_uses_world, "Realm-1 healing recipe links actual P0 world herb source")
    _expect(MedicineResourceSourceV1.guidance_text(
        MedicineCatalogueV2.recipe_id("heal", 1)).contains("Trúc Thử"),
        "Mobile alchemy source label includes the real loot-ready monster")
    _expect(not bool(MedicineResourceSourceV1.routes_for_recipe(
        MedicineCatalogueV2.recipe_id("tuvi",3)).get("ok",false)),
        "An unsourced realm-3 pill never gets a fabricated acquisition route")

    _expect(B3PillSatietyV1.CAPACITY == 1000000,
        "owner-locked daily pill satiety budget remains 1,000,000")
    _expect(recipes.validate_definitions().is_empty(),
        "all authored alchemy recipe IDs and product IDs remain valid")
    _expect(crops.validate_definitions().is_empty(),
        "all existing field crop definitions remain valid")

    # BAL-04A owner-approved milestones: no implicit level-9 Tử Vân
    # access, and level-10 access still depends on an actual paid upgrade.
    _expect(not crops.eligible_crop_ids(9).has(SpiritCropRegistry.CROP_TU_VAN_THAO),
        "stage-2 herb cannot be farmed at Field Lv9")
    _expect(crops.eligible_crop_ids(10).has(SpiritCropRegistry.CROP_TU_VAN_THAO),
        "stage-2 herb is eligible at Field Lv10")
    _expect(BuildingSystem.MILESTONE_COMPONENTS["spirit_field"][10] ==
        BuildingSystem.MATERIAL_LINH_TUYEN_HEART,
        "Field Lv10 is still gated by real milestone heart")
    _expect(BuildingSystem.LINH_TUYEN_FRAGMENT_PER_HEART == 100
        and is_equal_approx(BuildingSystem.LINH_TUYEN_FRAGMENT_BASE_CHANCE, 0.05),
        "100 real 5%-drop fragments are still needed per heart")
    _expect(MedicineAllocationV2.MIN_LEGACY_AUTO_HEAL_RATIO == 0.02,
        "legacy auto recovery uses the 2% HP-worth-it rule")

    var high_realm := 20
    var legacy_hp := NeedsSystem.HEALING_PILL_HP
    var same_realm_core_hp := 190.0 * pow(1.65, float(high_realm - 1))
    print("SX03 BAL04A legacy Hoi Xuan effect at realm %d = %.5f%% of core HP; auto skips it."
        % [high_realm, 100.0 * legacy_hp / same_realm_core_hp])
    var future_tuvi := MedicineCatalogueV2.definition(
        MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_TUVI, high_realm, 1))
    var first_floor := DiscipleProgressionBalanceV2.floor_cost(high_realm, 1)
    _expect(int(future_tuvi.get("potency", 0)) ==
        roundi(float(DiscipleProgressionBalanceV2.realm_total_xp(high_realm)) * 0.001),
        "high-tier preview potency references actual per-realm XP requirement")
    _expect(int(future_tuvi.get("potency", 0)) < first_floor,
        "future high-tier q1 medicine cannot skip a full local floor")
    print("SX03 BAL04A proposed-future Tu Vi r20 dose = %.2f%% of floor-1 EXP;"
        % [100.0 * float(future_tuvi.get("potency", 0)) / float(maxi(first_floor, 1))])
    # No new recipes for r3..30 were created to make this test green.

    if failures.is_empty():
        print("SX03 SOURCE-CONSUMER CONTRACT PASS (%d checks); BAL-04A stage bounds checked." % checks)
    else:
        print("SX03 SOURCE-CONSUMER CONTRACT FAIL (%d/%d); BAL-04A stage bounds checked."
            % [failures.size(), checks])
    quit(1 if not failures.is_empty() else 0)
