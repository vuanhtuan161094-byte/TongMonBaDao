extends SceneTree
# SX02 regression: the UI/work-available preflight must enforce the same
# professional gate as the paid timed-recipe transaction. QA save is isolated.
const START := 1800000000
var checks := 0
var failed := false

func _init() -> void:
    call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failed = true
        push_error("SX02 ALCHEMY PREFLIGHT FAIL: " + message)

func _run() -> void:
    var path := "user://sx02_alchemy_gate_%d.json" % Time.get_ticks_usec()
    var runtime := LiveGameRuntimeV2.new()
    if not bool(runtime.start(path, START, 930211).get("ok", false)):
        _expect(false, "open isolated runtime")
        quit(1)
        return
    var setup := B3DemoSetup.prepare(runtime)
    if not bool(setup.get("ok", false)):
        _expect(false, "recruit real V2 actor")
        quit(1)
        return
    var state := runtime.state()
    var worker_id := StringName(setup["disciple_id"])
    var worker: DiscipleState = state.disciples[worker_id]
    var building := BuildingSystem.new()
    var workforce := WorkforceSystem.new()
    var warehouse := WarehouseSystem.new()
    var hall := building.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if hall == null:
        _expect(false, "real alchemy hall exists")
        quit(1)
        return

    # Explicit QA fixture: unlock the real Hall Lv10 gate without minting
    # any production item, then compare low-skilled vs qualified eligibility.
    hall.level = 10
    for raw_id in state.disciples.keys():
        if StringName(raw_id) != worker_id and (state.disciples[raw_id] as DiscipleState).work_group_id == &"alchemy_crew":
            _expect(workforce.assign_group(state, StringName(raw_id), &""),
                "vacate pre-existing alchemy slot in isolated QA state")
    _expect(workforce.assign_group(state, worker_id, &"alchemy_crew")
        and workforce.assign_worksite(state, worker_id, hall.id),
        "actual worker can be assigned to alchemy hall")
    var recipe := MedicineCatalogueV2.recipe_id("tuvi", 2)
    _expect(building.set_alchemy_recipe(state, hall.id, recipe),
        "canonical rank-2 Tu Vi recipe selected")
    var requirements := AlchemyRecipeRegistry.new().inputs(recipe)
    for raw_id in requirements.keys():
        var ingredient := StringName(raw_id)
        var needed := maxi(0, int(requirements[raw_id]) - warehouse.available_quantity(state, ingredient))
        if needed > 0:
            _expect(warehouse.add(state, ingredient, needed),
                "isolated QA fixture adds only approved recipe ingredients")
    var quantities_before := {}
    for raw_id in requirements.keys():
        quantities_before[str(raw_id)] = warehouse.quantity(state, StringName(raw_id))
    var pill := MedicineCatalogueV2.item_id("tuvi", 2, 1)
    var output_before := warehouse.quantity(state, pill)

    worker.profession_xp["alchemy"] = 0.0
    _expect(workforce.profession_level_for_state(state, worker, WorkforceSystem.PROF_ALCHEMY) == 0,
        "low-skilled actor has actual profession level zero")
    var blocked := building.alchemy_can_start(state, worker)
    _expect(not bool(blocked.get("ok", false))
        and str(blocked.get("reason", "")) == "profession_level_too_low",
        "UI preflight rejects a worker below the authored rank-2 gate")
    _expect(not building.work_available(state, WorkforceSystem.PROF_ALCHEMY, worker),
        "scheduler availability matches the denied work action")
    var denied := building.perform_alchemy_step(state, worker, 0, 1.0, 10.0)
    _expect(not bool(denied.get("ok", false)),
        "low-tier production refuses to start")
    for raw_id in requirements.keys():
        _expect(warehouse.quantity(state, StringName(raw_id)) == quantities_before[str(raw_id)],
            "denied job cannot debit " + str(raw_id))
    _expect(warehouse.quantity(state, pill) == output_before
        and building.alchemy_jobs(state, hall).is_empty(),
        "denied job creates no pill or timed work receipt")

    # Actual P3.7 skill curve: Lv3 is sqrt(216/24)=3.
    worker.profession_xp["alchemy"] = 216.0
    _expect(workforce.profession_level_for_state(state, worker, WorkforceSystem.PROF_ALCHEMY) == 3,
        "qualified worker reached the canonical P3.7 level gate")
    _expect(bool(building.alchemy_can_start(state, worker).get("ok", false)),
        "same real recipe is now actionable with actual skill and ingredients")
    var started := building.perform_alchemy_step(state, worker, 3, 1.0, 10.0)
    _expect(bool(started.get("ok", false)) and bool(started.get("started", false)),
        "qualified worker starts a canonical paid timed recipe")
    for raw_id in requirements.keys():
        _expect(warehouse.quantity(state, StringName(raw_id)) ==
            int(quantities_before[str(raw_id)]) - int(requirements[raw_id]),
            "one paid ingredient debit at job start: " + str(raw_id))
    _expect(warehouse.quantity(state, pill) == output_before,
        "production cannot deliver graded Tu Vi medicine before finish")
    if not failed:
        print("SX02 ALCHEMY PROFESSION PREFLIGHT / PAID JOB PASS (%d checks)" % checks)
    quit(1 if failed else 0)
