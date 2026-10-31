extends SceneTree

# SX02 static metadata and contract checks. No seeded free materials or
# source bypass in the production runtime.
var failures := 0
var checks := 0

func _init() -> void:
    call_deferred("run")

func expect(ok: bool, reason: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("SX02 CATALOGUE FAIL: " + reason)

func run() -> void:
    var resource := ResourceRegistry.new()
    var recipes := AlchemyRecipeRegistry.new()
    var catalog := MedicineCatalogueV2.new()
    var ids := MedicineCatalogueV2.all_item_ids()
    expect(ids.size() == 240, "30 realms x 2 medicine families x 4 qualities")
    expect(MedicineCatalogueV2.authored_recipes().size() == 4,
        "only genuinely sourced tier-1/2 recipes authored")
    expect(MedicineCatalogueV2.validate_catalogue().is_empty(), "catalogue internally valid")
    expect(recipes.validate_definitions().is_empty(), "recipe inputs and warehouse outputs valid")
    expect(resource.validate_definitions().is_empty(), "canonical resource definitions valid")
    for item_id in ids:
        expect(resource.has(item_id), "resource registry owns " + str(item_id))
        var desc := MedicineCatalogueV2.definition(item_id)
        expect(int(desc.get("potency", 0)) > 0, "positive potency " + str(item_id))
    for realm in range(1, 31):
        var previous_hp := 0
        var previous_tuvi := 0
        for quality in range(1, 5):
            var heal := MedicineCatalogueV2.item_id("heal", realm, quality)
            var tuvi := MedicineCatalogueV2.item_id("tuvi", realm, quality)
            var h := MedicineCatalogueV2.definition(heal)
            var t := MedicineCatalogueV2.definition(tuvi)
            expect(int(h["realm_rank"]) == realm and int(h["quality"]) == quality,
                "heal identity rank/grade")
            expect(int(t["realm_rank"]) == realm and int(t["quality"]) == quality,
                "tuvi identity rank/grade")
            expect(int(h["potency"]) > previous_hp and int(t["potency"]) > previous_tuvi,
                "within-realm quality increases both potencies")
            previous_hp = int(h["potency"])
            previous_tuvi = int(t["potency"])
    expect(MedicineCatalogueV2.definition(MedicineCatalogueV2.item_id("heal", 1, 1))["potency"] == 55,
        "tier 1 low-grade heal starts at legacy baseline without mutating legacy ID")
    expect(MedicineCatalogueV2.definition(MedicineCatalogueV2.item_id("tuvi", 1, 1))["potency"] == 10000,
        "tier 1 low-grade Tu Vi starts at legacy baseline")
    expect(not recipes.has(MedicineCatalogueV2.recipe_id("heal", 30)),
        "no unsourced realm-30 recipe")
    expect(not recipes.has(MedicineCatalogueV2.recipe_id("tuvi", 3)),
        "no unsourced realm-3 recipe")
    expect(recipes.has(MedicineCatalogueV2.recipe_id("heal", 1)),
        "real sourced rank-1 healing recipe")
    expect(recipes.has(MedicineCatalogueV2.recipe_id("tuvi", 2)),
        "real source-gated rank-2 Tu Vi recipe")
    expect(recipes.inputs(MedicineCatalogueV2.recipe_id("heal", 2)).has("tu_van_thao"),
        "rank-2 recipe needs named higher-grade Field herb")
    expect(MedicineCatalogueV2.produced_quality(0, 1) == 1,
        "fresh Alchemy Hall yields lower grade")
    expect(MedicineCatalogueV2.produced_quality(2, 5) == 2,
        "trained Alchemist and developed hall unlock medium grade")
    expect(MedicineCatalogueV2.produced_quality(10, 20) == 4,
        "quality four needs both Alchemist and building")
    expect(MedicineCatalogueV2.output_for_job(MedicineCatalogueV2.recipe_id("heal", 1), 10, 20) ==
        MedicineCatalogueV2.item_id("heal", 1, 4), "commit fixes grade identity at job start")
    if failures == 0:
        print("SX02 CATALOGUE PASS (%d checks)" % checks)
    quit(1 if failures > 0 else 0)
