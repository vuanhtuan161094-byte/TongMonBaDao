extends SceneTree

# W2 foundation regression: historical unpaid wages remain durable, are paid
# only from genuine Warehouse sales, and cannot be paid twice after cold reload.
# This is a receipt transaction fixture, not a claim that LT2/W2/T2 is balanced.
const SAVE_PATH := "user://sx_w2_wage_arrears_save_test.json"
var economy := EconomySystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("SX W2 ARREARS FAIL: " + why)
        quit(1)
        return false
    return true

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(26111003)
    if not _check(bool(economy.enable_v1(state).get("ok",false)),"economy/warehouse unavailable"):
        return
    if not _check(bool(economy.configure_v1(state,"wage_per_batch",4).get("ok",false)),"cannot set bounded test wage"):
        return
    var ids: Array = state.disciples.keys()
    ids.sort()
    if not _check(ids.size() >= 2,"need two real disciples"):
        return
    var first: DiscipleState = state.disciples[ids[0]]
    var second: DiscipleState = state.disciples[ids[1]]
    var first_money := first.spirit_stones
    var second_money := second.spirit_stones
    # Simulate existing unpaid wage receipts in a QA-only fixture. No resource
    # is created; the real producer-to-wage authority is covered by O9/GP02.
    state.sect.spirit_stones = 0
    var wage1 := economy.settle_work_wage(state,first,"qa_completed_job_1")
    var wage2 := economy.settle_work_wage(state,second,"qa_completed_job_2")
    if not _check(bool(wage1.get("ok",false)) and bool(wage2.get("ok",false))
        and int(wage1.get("receipt",{}).get("paid",-1)) == 0
        and int(economy.unpaid_work_wages(state).get("total",-1)) == 8,
        "unpaid receipts not durable"):
        return
    if not _check(not bool(economy.pay_work_wage_arrears(state,"no-funds").get("ok",false))
        and state.sect.spirit_stones == 0 and first.spirit_stones == first_money
        and second.spirit_stones == second_money,"zero balance generated personal Stones"):
        return

    var wood_before := warehouse.quantity(state,&"linh_moc")
    if not _check(wood_before >= 4,"no authentic starter Warehouse wood"):
        return
    if not _check(bool(economy.sell_to_npc_v1(state,&"linh_moc",2,"w2-real-stock-1").get("ok",false)),
        "sale of real Warehouse wood rejected"):
        return
    if not _check(warehouse.quantity(state,&"linh_moc") == wood_before-2
        and state.sect.spirit_stones == 4,"sale generated incorrect cashflow"):
        return
    var partial := economy.pay_work_wage_arrears(state,"arrears-first")
    if not _check(bool(partial.get("ok",false)) and int(partial.get("receipt",{}).get("paid",0)) == 4
        and state.sect.spirit_stones == 0
        and first.spirit_stones == first_money+4
        and second.spirit_stones == second_money
        and int(economy.unpaid_work_wages(state).get("total",-1)) == 4,
        "first debt not transferred exact-once"):
        return

    var saver := SaveService.new()
    if not _check(saver.save_to_path(state,SAVE_PATH) == OK,"cold Save failed"):
        return
    var loaded := saver.load_from_path(SAVE_PATH)
    if not _check(loaded != null and int(economy.unpaid_work_wages(loaded).get("total",-1)) == 4,
        "unpaid wages not preserved on cold reload"):
        return
    var first_loaded: DiscipleState = loaded.disciples[first.id]
    var second_loaded: DiscipleState = loaded.disciples[second.id]
    var replay := economy.pay_work_wage_arrears(loaded,"arrears-first")
    if not _check(bool(replay.get("already_settled",false)) and loaded.sect.spirit_stones == 0
        and first_loaded.spirit_stones == first_money+4 and second_loaded.spirit_stones == second_money,
        "cold replay duplicated wage payment"):
        return
    if not _check(bool(economy.sell_to_npc_v1(loaded,&"linh_moc",2,"w2-real-stock-2").get("ok",false)),
        "second authentic sale rejected"):
        return
    var final_payment := economy.pay_work_wage_arrears(loaded,"arrears-second")
    if not _check(bool(final_payment.get("ok",false))
        and int(economy.unpaid_work_wages(loaded).get("total",-1)) == 0
        and second_loaded.spirit_stones == second_money+4
        and loaded.sect.spirit_stones == 0
        and warehouse.quantity(loaded,&"linh_moc") == wood_before-4,
        "second debt incorrectly paid or real wood not consumed"):
        return
    var day := economy.daily_market_cashflow(loaded)
    if not _check(int(day.get("income",-1)) == 8 and int(day.get("wages",-1)) == 8,
        "daily cashflow backdated or omitted deferred wages"):
        return
    var invariants := loaded.validate_invariants()
    if not _check(invariants.is_empty(),"state invalid: "+str(invariants)):
        return
    if not _check(saver.save_to_path(loaded,SAVE_PATH) == OK,"final Save failed"):
        return
    var final_state := saver.load_from_path(SAVE_PATH)
    if not _check(final_state != null and int(economy.unpaid_work_wages(final_state).get("total",-1)) == 0
        and bool(economy.pay_work_wage_arrears(final_state,"arrears-second").get("already_settled",false))
        and final_state.sect.spirit_stones == 0,
        "final cold reload duplicated settlement"):
        return
    _cleanup()
    print("SX W2 WAGE ARREARS REAL-STOCK CASHFLOW COLD SAVE EXACTLY ONCE: PASS")
    quit(0)

func _cleanup() -> void:
    for suffix in ["",".bak",".tmp"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
