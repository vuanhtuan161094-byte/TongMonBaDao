extends SceneTree

# SX01-06 authoring guard, not a substitute for real Godot economy/play tests.
var checks := 0
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("SX57 CONTRACT FAIL: "+message)

func _run() -> void:
    var catalogue := MedicineCatalogueV2
    _check(catalogue.all_recipe_ids().size() == 119,"119 stable recipe IDs")
    _check(catalogue.all_item_ids().size() == 476,"476 grade item IDs")
    _check(catalogue.authored_recipes().size() == 8,
        "eight low-tier recipes with existing gameplay sources, never 119 pretend recipes")
    _check(catalogue.V56_B3_Q1_XP.size() == 30,"Q1 30-realm potency table")
    _check(catalogue.potency_for_version(catalogue.item_id("tuvi",1,1),3) == 1166,
        "approved Tu Vi B3 level-one fixed XP")
    _check(catalogue.potency_for_version(catalogue.item_id("body",1,1),3) == 1166,
        "Body B3 same validated stage XP")
    _check(catalogue.potency_for_version(catalogue.item_id("tuvi",1,1),2) == 10000,
        "V2 receipt potency remains unchanged")
    _check(catalogue.potency_for_version(catalogue.item_id("tuvi",2,1),1) == 16500,
        "V1 receipt potency remains unchanged")
    _check(catalogue.potency_for_version(catalogue.item_id("break",1,4),3) == 45,
        "Q4 breakthrough bonus 45 percentage points")
    _check(catalogue.item_id("break",30,1) == &"",
        "no Breakthrough Pill for terminal realm")
    _check(int(catalogue.definition(catalogue.item_id("heal",1,1))["satiety_cost"]) == 0,
        "new heal pill never spends cultivation/body budget")
    _check(B3PillSatietyV1.CAPACITY == 2000000,"shared daily budget is 2 million")
    _check(DiscipleBreakthroughBalanceV2.CULTIVATION_BASE_CHANCE_PERCENT.size() == 29,
        "exactly 29 Tu Vi gates")
    for chance in DiscipleBreakthroughBalanceV2.CULTIVATION_BASE_CHANCE_PERCENT:
        _check(int(chance) == 25,"base breakthrough always 25 percent")
    _check(DiscipleBreakthroughBalanceV2.BODY_GATE_MODE == "deterministic_requirements",
        "Body gates require materials but no RNG")
    var registry := ResourceRegistry.new()
    for item in catalogue.all_item_ids():
        _check(registry.has(item),"medicine item registered "+str(item))
    var alchemy := AlchemyRecipeRegistry.new()
    var broken := alchemy.validate_definitions()
    _check(broken.is_empty(),"all eight authored recipes have registered inputs/outputs: "+str(broken))
    for recipe in catalogue.authored_recipes():
        _check(not alchemy.inputs(recipe).is_empty(),"actual recipe needs nonfree inputs")
        _check(alchemy.output_quantity(recipe) > 0,"actual recipe has positive batch output")
    _check(not BuildingSystem.V57_QUALITY_CATALYSTS[4].has("linh_tuyen_chi_tam_manh"),
        "Q4 no longer competes with Field milestone hearts")
    print("SX57 STATIC CONTRACT: %d checks, %d failures" % [checks,failures])
    quit(1 if failures > 0 else 0)
