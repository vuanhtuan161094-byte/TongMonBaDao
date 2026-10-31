extends SceneTree

# SX02 integration: actual worker and input debit -> timed grade-labelled
# resource -> real B3 consume -> canonical save/reload. Run with Godot 4.7.2.
const START := 1800000000
var checks := 0
var failed := false

func _init() -> void:
    call_deferred("run")

func verify(ok: bool, reason: String) -> bool:
    checks += 1
    if not ok:
        failed = true
        push_error("SX02 RUNTIME FAIL: " + reason)
    return ok

func run() -> void:
    var save_path := "user://sx02_med_%d.json" % Time.get_ticks_usec()
    var runtime := LiveGameRuntimeV2.new()
    if not verify(bool(runtime.start(save_path, START, 930211).get("ok", false)),
        "start fresh canonical live save"):
        quit(1)
        return
    var setup := B3DemoSetup.prepare(runtime)
    if not verify(bool(setup.get("ok", false)), "authentic V2 recruit / no fake profile"):
        quit(1)
        return
    var owner := runtime.owner
    var state := runtime.state()
    var id := StringName(setup["disciple_id"])
    var d: DiscipleState = state.disciples[id]
    var warehouse := WarehouseSystem.new()
    var recipe := MedicineCatalogueV2.recipe_id("heal", 1)
    var pill := MedicineCatalogueV2.item_id("heal", 1, 1)
    var hall := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if not verify(hall != null, "real alchemy hall"):
        quit(1)
        return
    var herb_before := warehouse.quantity(state, &"thanh_linh_thao")
    var stock_before := warehouse.quantity(state, pill)
    # Isolated fixture injects ONLY inputs to trigger the real job.
    verify(warehouse.add(state, &"thanh_linh_thao", 3),
        "fixture adds exactly three legitimate herb IDs")
    var job := B3MedicalAutoplayV1.craft(owner, recipe, 1, id)
    if not verify(bool(job.get("ok", false)), "B3 durable craft accepts sourced rank-1 recipe"):
        quit(1)
        return
    var finish_tick := int(job.get("finish_tick", -1))
    verify(finish_tick > state.tick, "job spends actual canonical minutes")
    verify(warehouse.quantity(state, &"thanh_linh_thao") == herb_before,
        "paid three herbs once")
    verify(warehouse.quantity(state, pill) == stock_before,
        "no pill granted before completion")
    verify(bool(B3MedicalAutoplayV1.craft(owner, recipe, 1, id).get("replay", false)),
        "same craft receipt cannot double spend")

    var reloaded := LiveGameRuntimeV2.new()
    if not verify(bool(reloaded.start(save_path, START).get("ok", false)),
        "reload with the pending recipe"):
        quit(1)
        return
    owner = reloaded.owner
    state = reloaded.state()
    d = state.disciples[id]
    hall = BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    verify(BuildingSystem.new().alchemy_jobs(state, hall).size() == 1,
        "pending work receipt restored once from disk")
    var advance := owner.update_to(START + finish_tick * 60)
    if not verify(bool(advance.get("ok", false)), "canonical elapsed clock settles job"):
        quit(1)
        return
    verify(warehouse.quantity(state, pill) == stock_before + 1,
        "one grade-labelled medicine landed in Warehouse")
    var hp_before := maxf(d.max_hp - 80.0, 1.0)
    d.hp = hp_before
    var taken := B3MedicalAutoplayV1.use_pill(owner, id, pill, B3PillSatietyV1.next_sequence(d))
    if not verify(bool(taken.get("ok", false)), "medicine consumed via original B3 durable owner"):
        quit(1)
        return
    verify(is_equal_approx(d.hp, minf(d.max_hp, hp_before + 55.0)),
        "grade-1 pill heals +55, cannot exceed Max HP")
    verify(warehouse.quantity(state, pill) == stock_before,
        "one medicine debit and no double payout")
    verify(B3PillSatietyV1.spent_today(state, d) == 10,
        "shared B3 budget preserved")
    verify(B3PillSatietyV1.validate(state, d).is_empty(),
        "B3 accepts versioned graded receipt")
    var receipt_sequence := int(d.b3_pill_state.get("sequence", 0))
    var replay := B3MedicalAutoplayV1.use_pill(owner, id, pill, receipt_sequence)
    verify(bool(replay.get("replay", false)), "idempotent medicine replay")

    # Repeat the real timed transaction for the Tu Vi family.
    verify(warehouse.add(state, &"thanh_linh_thao", 2) and
        warehouse.add(state, &"linh_coc", 1), "fixture contains two actual TQD inputs")
    var tuvi_recipe := MedicineCatalogueV2.recipe_id("tuvi", 1)
    var tuvi_pill := MedicineCatalogueV2.item_id("tuvi", 1, 1)
    var tuvi_before_stock := warehouse.quantity(state, tuvi_pill)
    var tuvi_job := B3MedicalAutoplayV1.craft(owner, tuvi_recipe, 2, id)
    if verify(bool(tuvi_job.get("ok", false)), "real graded Tu Vi recipe paid"):
        var tuvi_finish := int(tuvi_job.get("finish_tick", -1))
        var completed := owner.update_to(START + tuvi_finish * 60)
        if verify(bool(completed.get("ok", false)), "Tu Vi job elapsed and settled"):
            verify(warehouse.quantity(state, tuvi_pill) == tuvi_before_stock + 1,
                "Tu Vi grade recorded separately from original TQD")
            var cultivation_before := d.v2_realm_progress["cultivation"].duplicate(true)
            var used_tuvi := B3MedicalAutoplayV1.use_pill(owner, id, tuvi_pill, B3PillSatietyV1.next_sequence(d))
            if verify(bool(used_tuvi.get("ok", false)), "new Tu Vi pill commits through original B3"):
                verify(warehouse.quantity(state, tuvi_pill) == tuvi_before_stock,
                    "exactly one graded Tu Vi pill consumed")
                verify(B3PillSatietyV1.spent_today(state, d) == 35,
                    "healing and Tu Vi pills share B3 10+25 satiety")
                verify(B3PillSatietyV1.validate(state, d).is_empty(),
                    "dynamic Tu Vi receipt is compatible with B3 validation")
                verify(str(d.v2_realm_progress["cultivation"]) != str(cultivation_before),
                    "real V2 cultivation progress changed")

    var final_reload := LiveGameRuntimeV2.new()
    if verify(bool(final_reload.start(save_path, owner.state.runtime_last_wall_unix).get("ok", false)),
        "reload after durable medicine use"):
        var persisted := final_reload.state()
        var pd: DiscipleState = persisted.disciples[id]
        verify(warehouse.quantity(persisted, pill) == stock_before,
            "persistent Warehouse shows exactly one used medicine")
        verify(int(pd.b3_pill_state.get("sequence", 0)) == receipt_sequence,
            "persistent B3 receipt sequence unchanged")
        verify(B3PillSatietyV1.validate(persisted, pd).is_empty(),
            "new quality receipt validates after save/load")

    if not failed:
        print("SX02 MEDICINE REAL JOB + CANONICAL B3 + SAVE PASS (%d checks)" % checks)
    quit(1 if failed else 0)
