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

    _expect(B3PillSatietyV1.CAPACITY == 1000000,
        "owner-locked daily pill satiety budget remains 1,000,000")
    _expect(recipes.validate_definitions().is_empty(),
        "all authored alchemy recipe IDs and product IDs remain valid")
    _expect(crops.validate_definitions().is_empty(),
        "all existing field crop definitions remain valid")

    # Explicit design alarms. These are NOT declared fixed by this test.
    var high_realm := 20
    var legacy_hp := NeedsSystem.HEALING_PILL_HP
    var same_realm_core_hp := 190.0 * pow(1.65, float(high_realm - 1))
    print("SX03 REVIEW_REQUIRED legacy Hoi Xuan effect at realm %d = %.5f%% of same-realm core HP."
        % [high_realm, 100.0 * legacy_hp / same_realm_core_hp])
    var future_tuvi := MedicineCatalogueV2.definition(
        MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_TUVI, high_realm, 1))
    var first_floor := DiscipleProgressionBalanceV2.floor_cost(high_realm, 1)
    print(("SX03 REVIEW_REQUIRED authored-future Tu Vi dose at realm %d = %.2f%% of floor-1 EXP;"
        + " no recipe may be fabricated from this catalogue entry.")
        % [high_realm, 100.0 * float(future_tuvi.get("potency", 0)) / float(maxi(first_floor, 1))])

    if failures.is_empty():
        print("SX03 SOURCE-CONSUMER CONTRACT PASS (%d checks); numeric-stage balance REVIEW_REQUIRED." % checks)
    else:
        print("SX03 SOURCE-CONSUMER CONTRACT FAIL (%d/%d); stage balance REVIEW_REQUIRED."
            % [failures.size(), checks])
    quit(1 if not failures.is_empty() else 0)
