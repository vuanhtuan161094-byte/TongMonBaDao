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
    var medicine_candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state, DiscipleGeneratorV2.SOURCE_ORDINARY, 99442)
    if not verify(medicine_candidate != null, "real second medicine user generated through open recruitment"):
        quit(1)
        return
    state.recruitment_candidates[medicine_candidate.id] = medicine_candidate
    var medicine_recruitment := RecruitmentSystem.new().accept_candidate(state, medicine_candidate.id)
    if not verify(bool(medicine_recruitment.get("ok", false)), "second medicine user accepted through recruitment"):
        quit(1)
        return
    var medicine_id: StringName = medicine_candidate.id
    var medicine_disciple: DiscipleState = state.disciples[medicine_id]
    if not verify(DiscipleRealmProgressV2.progression_ready(medicine_disciple),
        "second authentic recruit owns the V2 progression needed by graded pills"):
        quit(1)
        return
    verify(not B3MedicalAutoplayV1.busy(state, medicine_disciple),
        "freshly recruited medicine user is idle while alchemy worker remains assigned")
    var hp_before := maxf(medicine_disciple.max_hp - 80.0, 1.0)
    medicine_disciple.hp = hp_before
    var taken := B3MedicalAutoplayV1.use_pill(owner, medicine_id, pill, B3PillSatietyV1.next_sequence(medicine_disciple))
    if not verify(bool(taken.get("ok", false)), "medicine consumed via original B3 durable owner: " + str(taken)):
        quit(1)
        return
    verify(is_equal_approx(medicine_disciple.hp, minf(medicine_disciple.max_hp, hp_before + 55.0)),
        "grade-1 pill heals +55, cannot exceed Max HP")
    verify(warehouse.quantity(state, pill) == stock_before,
        "one medicine debit and no double payout")
    verify(B3PillSatietyV1.spent_today(state, medicine_disciple) == 10,
        "shared B3 budget preserved")
    verify(B3PillSatietyV1.validate(state, medicine_disciple).is_empty(),
        "B3 accepts versioned graded receipt")
    var receipt_sequence := int(medicine_disciple.b3_pill_state.get("sequence", 0))
    var replay := B3MedicalAutoplayV1.use_pill(owner, medicine_id, pill, receipt_sequence)
    verify(bool(replay.get("replay", false)), "idempotent medicine replay")

    # Repeat the real timed transaction for the Tu Vi family.
    verify(warehouse.add(state, &"thanh_linh_thao", 2) and
        warehouse.add(state, &"linh_coc", 1), "fixture contains two actual TQD inputs")
    var tuvi_recipe := MedicineCatalogueV2.recipe_id("tuvi", 1)
    var tuvi_pill := MedicineCatalogueV2.item_id("tuvi", 1, 1)
    var tuvi_before_stock := warehouse.quantity(state, tuvi_pill)
    var tuvi_job := B3MedicalAutoplayV1.craft(owner, tuvi_recipe, 2, medicine_id)
    if verify(bool(tuvi_job.get("ok", false)), "real graded Tu Vi recipe paid"):
        var tuvi_finish := int(tuvi_job.get("finish_tick", -1))
        var completed := owner.update_to(START + tuvi_finish * 60)
        if verify(bool(completed.get("ok", false)), "Tu Vi job elapsed and settled"):
            verify(warehouse.quantity(state, tuvi_pill) == tuvi_before_stock + 1,
                "Tu Vi grade recorded separately from original TQD")
            var cultivation_before: Dictionary = medicine_disciple.v2_realm_progress["cultivation"].duplicate(true)
            var used_tuvi := B3MedicalAutoplayV1.use_pill(owner, medicine_id, tuvi_pill, B3PillSatietyV1.next_sequence(medicine_disciple))
            if verify(bool(used_tuvi.get("ok", false)), "new Tu Vi pill commits through original B3"):
                verify(warehouse.quantity(state, tuvi_pill) == tuvi_before_stock,
                    "exactly one graded Tu Vi pill consumed")
                verify(B3PillSatietyV1.spent_today(state, medicine_disciple) == 35,
                    "healing and Tu Vi pills share B3 10+25 satiety")
                verify(B3PillSatietyV1.validate(state, medicine_disciple).is_empty(),
                    "dynamic Tu Vi receipt is compatible with B3 validation")
                verify(str(medicine_disciple.v2_realm_progress["cultivation"]) != str(cultivation_before),
                    "real V2 cultivation progress changed")
    # Fix the SX01 root blocker: specialized Tu Vi may safely take a pill
    # without being commandeered into the autonomous hunting actor pool.
    medicine_disciple.current_action = &"CULTIVATE"
    verify(B3MedicalAutoplayV1.busy(state, medicine_disciple),
        "B3 CARE remains strict: Chuyên Tu cannot be auto-deployed")
    verify(B3PillSatietyV1.safe_cultivation_pill_window(state, medicine_disciple),
        "dedicated B3 pill use has a narrower safe Chuyên Tu window")
    verify(not B3PillSatietyV1.manual_use_is_activity_blocked(state, medicine_disciple, tuvi_pill),
        "manual Tu Vi medicine is not disabled during the safe Chuyên Tu window")
    verify(B3PillSatietyV1.manual_use_is_activity_blocked(state, medicine_disciple, &"hoi_xuan_dan"),
        "healing medicine remains blocked while Chuyên Tu is active")
    verify(warehouse.add(state, tuvi_pill, 1),
        "fixture additional Tu Vi pill for specialized case")
    medicine_disciple.work_cycle_state = {"phase": "travel_out"}
    verify(B3PillSatietyV1.manual_use_is_activity_blocked(state, medicine_disciple, tuvi_pill),
        "manual Tu Vi medicine stays disabled while a production cycle is active")
    verify(not B3PillSatietyV1.safe_cultivation_pill_window(state, medicine_disciple),
        "an active production cycle denies Chuyên Tu pill")
    var blocked := B3MedicalAutoplayV1.use_pill(owner, medicine_id, tuvi_pill, B3PillSatietyV1.next_sequence(medicine_disciple))
    verify(not bool(blocked.get("ok", false)) and warehouse.quantity(state, tuvi_pill) == tuvi_before_stock + 1,
        "busy actor neither consumes item nor gains Tu Vi")
    medicine_disciple.work_cycle_state.clear()
    var specialized := B3MedicalAutoplayV1.use_pill(owner, medicine_id, tuvi_pill, B3PillSatietyV1.next_sequence(medicine_disciple))
    verify(bool(specialized.get("ok", false)), "Chuyên Tu receives actual graded Tu Vi medicine")
    verify(medicine_disciple.current_action == &"CULTIVATE",
        "Chuyên Tu stays active after pill without starting another job")
    verify(B3PillSatietyV1.spent_today(state, medicine_disciple) == 60,
        "specialized pill shares same day meter and costs exactly 25")

    receipt_sequence = int(medicine_disciple.b3_pill_state.get("sequence", 0))
    var final_reload := LiveGameRuntimeV2.new()
    if verify(bool(final_reload.start(save_path, owner.state.runtime_last_wall_unix).get("ok", false)),
        "reload after durable medicine use"):
        var persisted := final_reload.state()
        var pd: DiscipleState = persisted.disciples[medicine_id]
        verify(warehouse.quantity(persisted, pill) == stock_before,
            "persistent Warehouse shows exactly one used medicine")
        verify(int(pd.b3_pill_state.get("sequence", 0)) == receipt_sequence,
            "persistent B3 receipt sequence unchanged")
        verify(B3PillSatietyV1.validate(persisted, pd).is_empty(),
            "new quality receipt validates after save/load")

    if not failed:
        print("SX02 MEDICINE REAL JOB + CANONICAL B3 + SAVE PASS (%d checks)" % checks)
    quit(1 if failed else 0)
