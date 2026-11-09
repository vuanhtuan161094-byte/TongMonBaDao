extends SceneTree

# SX-04 focused transactional regression. Uses real B3 owner and canonical
# Warehouse; fixture grants test-only medicine, never runtime free medicine.
const START := 1800000000
var checks := 0
var failed := false

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failed = true
        push_error("SX57 CONSUME FAIL: "+message)

func _run() -> void:
    var path := "user://sx57_body_break_%d.json" % Time.get_ticks_usec()
    var live := LiveGameRuntimeV2.new()
    if not bool(live.start(path,START,930211).get("ok",false)):
        _check(false,"live V2 runtime")
        quit(1)
        return
    var prep := B3DemoSetup.prepare(live)
    if not bool(prep.get("ok",false)):
        _check(false,"real V2 recruit setup")
        quit(1)
        return
    var state := live.state()
    var id := StringName(prep["disciple_id"])
    var d: DiscipleState = state.disciples[id]
    var warehouse := WarehouseSystem.new()
    _check(bool(B3PillSatietyV1.enable(state,d).get("ok",false)),
        "enable shared CARE meter")
    WorkforceSystem.new().issue_command(state,id,WorkforceSystem.COMMAND_HOLD,"",1000000)
    d.current_action = &"EVALUATE"
    var body_item := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_BODY,1,1)
    _check(warehouse.add(state,body_item,1),"add one test Body pill")
    var tuvi_before: Dictionary = d.v2_realm_progress["cultivation"].duplicate(true)
    var body_before: Dictionary = d.v2_realm_progress["body"].duplicate(true)
    var taken := B3PillSatietyV1.consume(state,d,body_item,B3PillSatietyV1.next_sequence(d))
    _check(bool(taken.get("ok",false)),"Body pill commits using B3")
    _check(str(d.v2_realm_progress["body"]) != str(body_before),"Body EXP progressed")
    _check(str(d.v2_realm_progress["cultivation"]) == str(tuvi_before),
        "Body pill never grants Tu Vi")
    _check(B3PillSatietyV1.spent_today(state,d) == 50,"shared budget debited 50")
    _check(warehouse.quantity(state,body_item) == 0,"one Body pill spent")
    _check(B3PillSatietyV1.validate(state,d).is_empty(),"V3 receipt is valid")
    var replay := B3PillSatietyV1.consume(state,d,body_item,1)
    _check(bool(replay.get("replay",false)),"Body pill retry cannot duplicate XP")
    var break_item := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_BREAK,1,4)
    _check(warehouse.add(state,break_item,1),"add one test Q4 breakthrough pill")
    var gate_xp := DiscipleProgressionBalanceV2.floor_cost(1,10)
    d.v2_realm_progress["cultivation"]["realm"] = 1
    d.v2_realm_progress["cultivation"]["floor"] = 10
    d.v2_realm_progress["cultivation"]["xp"] = float(gate_xp)
    d.v2_realm_progress["cultivation"]["gate_failures"] = 0
    d.current_action = &"EVALUATE"
    var preview := CultivationGateV57.preview(state,id,break_item)
    _check(bool(preview.get("ok",false)) and is_equal_approx(float(preview.get("chance",0)),0.70),
        "25% base plus Q4 45pp is exactly 70%")
    var rng_before := state.rng_state
    var gate := CultivationGateV57.attempt(state,id,"sx57:QA:first",break_item)
    _check(bool(gate.get("ok",false)) and warehouse.quantity(state,break_item) == 0,
        "breakthrough Q4 consumed exactly once regardless of success")
    _check(state.rng_state == rng_before,
        "manual gate does not corrupt live scheduler RNG stream")
    _check(not bool(CultivationGateV57.attempt(state,id,"sx57:QA:first",break_item).get("ok",false)),
        "repeated gate event denied without another item debit")
    if bool(gate.get("success",false)):
        _check(int(d.v2_realm_progress["cultivation"]["realm"]) == 2,
            "success advances one major realm only")
    else:
        _check(int(d.v2_realm_progress["cultivation"]["realm"]) == 1             and int(d.v2_realm_progress["cultivation"]["floor"]) == 10,
            "failure remains on source realm floor 10")
        _check(is_equal_approx(float(d.v2_realm_progress["cultivation"]["xp"]),
            0.90*float(gate_xp)),"failed gate debits 10% of floor-10 cost")
    _check(SaveService.new().save_to_path(state,path) == OK,
        "V3 Body receipt and breakthrough history save")
    var loaded := SaveService.new().load_from_path(path)
    _check(loaded != null,"cold reload of transactions")
    if loaded != null:
        var ld: DiscipleState = loaded.disciples[id]
        _check(B3PillSatietyV1.validate(loaded,ld).is_empty(),
            "V3 Body receipt survives cold reload")
        _check(warehouse.quantity(loaded,break_item) == 0,
            "cold reload cannot restore used breakthrough pill")
    print("SX57 BODY + Q4 GATE TRANSACTION %d checks, %d failures" % [checks,int(failed)])
    quit(1 if failed else 0)
