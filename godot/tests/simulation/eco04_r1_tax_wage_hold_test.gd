extends SceneTree

# ECO-04 r1 economic gate. Distinguish read-only 0/30/70/100% QA arithmetic,
# genuine producer regression, and synthetic arrears fixtures. Never grant
# QA fixture funds/items to a player's save; public LT2/W2/T2 remains HOLD.
const SAVE_PATH := "user://qa_eco04_r1_tax_wage_hold.json"
var economy := EconomySystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("ECO04 R1 QA FAIL: "+why)
        quit(1)
        return false
    return true

func _total(state: SimulationState,worker: DiscipleState) -> int:
    return state.sect.spirit_stones+worker.spirit_stones

func _run() -> void:
    _clean()
    var state := P37Factory.create_state(411104)
    if not _check(bool(economy.enable_v1(state).get("ok",false))
        and not economy.sx_v55_r12_enabled(state)
        and not bool(economy.configure_v1(state,
            EconomySystem.SX_V55_R12_POLICY,true).get("ok",false)),
        "Player policy enabled private LT2/W2/T2"): return
    var reference = JSON.parse_string(FileAccess.get_file_as_string(
        "res://data/economy/v55d_30_realm_reference.json"))
    if not _check(reference is Dictionary
        and not bool(reference.get("runtime_activation",true))
        and int(reference["realms"][0]["lt2_per_minute"]) == 1000
        and int(reference["realms"][0]["w2_min_wage_per_job"]) == 2000,
        "r1 design authority changed or workbook accidentally activated"): return

    # All previews are pure and source-rate backed; no synthetic job gives
    # Stones. 1m produces 1000; 60/90/180m use authored work durations.
    var old_receipts := state.sect.economy_a_receipts.duplicate(true)
    var opening_stones := state.sect.spirit_stones
    for pct in [0,30,70,100]:
        for minutes in [1,60,90,180]:
            var quote := economy.sx_v55_r1_tax_preview_qa(minutes,pct,0)
            var gross := 1000*int(minutes)
            var tax := gross*int(pct)/100
            if not _check(bool(quote.get("ok",false))
                and int(quote.get("gross",-1)) == gross
                and int(quote.get("tax",-1)) == tax
                and int(quote.get("net",-1)) == gross-tax
                and int(quote.get("wage_due",-1)) == (1000 if minutes == 1 else 0)
                and int(quote.get("wage_paid",-1)) == 0
                and int(quote.get("sect_delta",-1)) == tax,
                "r1 tax math at pct="+str(pct)+" minutes="+str(minutes)): return
        var funded := economy.sx_v55_r1_tax_preview_qa(1,pct,1500)
        var expected_tax := 2000*int(pct)/100
        if not _check(bool(funded.get("ok",false))
            and int(funded.get("wage_due",-1)) == 1000
            and int(funded.get("wage_paid",-1)) == 1000
            and int(funded.get("taxable",-1)) == 2000
            and int(funded.get("tax",-1)) == expected_tax
            and int(funded.get("net",-1)) == 2000-expected_tax
            and int(funded.get("sect_delta",-1)) == expected_tax-1000
            and (2000-expected_tax)+(expected_tax-1000) == 1000,
            "Funded W2 floor or Sect/personal conservation pct="+str(pct)): return
    if not _check(not bool(economy.sx_v55_r1_tax_preview_qa(1,-1,1000).get("ok",false))
        and not bool(economy.sx_v55_r1_tax_preview_qa(1,101,1000).get("ok",false))
        and not bool(economy.sx_v55_r1_tax_preview_qa(0,70,1000).get("ok",false))
        and not bool(economy.sx_v55_r1_tax_preview_qa(60,70,
            EconomySystem.V2_MAX_STONES,EconomySystem.V2_MAX_STONES).get("ok",false))
        and state.sect.spirit_stones == opening_stones
        and state.sect.economy_a_receipts == old_receipts,
        "Read-only QA preview minted cash, accepted overflow or unlocked player tax"): return

    # Deliberately synthetic R1 1-minute wage receipt fixture: tests the
    # arrears *transfer only*, never claims a real one-minute producer settled.
    var id: StringName = state.disciples.keys()[0]
    var actor: DiscipleState = state.disciples[id]
    state.sect.spirit_stones = 600
    var before := _total(state,actor)
    var job := "eco04-unit-r1-short"
    state.sect.economy_a_receipts["sxv55-work:"+job] = {
        "kind":"sx_v55_work_income","job_id":job,
        "worker_id":str(id),"site":"mine","realm":1,
        "gross":1000,"tax_pct":70,"tick":state.tick
    }
    state.sect.economy_a_receipts["wage:"+job] = {
        "kind":"wage","job_id":job,"worker_id":str(id),
        "due":1000,"paid":0,"gross":1000,"w2_floor":2000,"tick":state.tick
    }
    var first := economy.pay_work_wage_arrears(state,"eco04-half")
    var f: Dictionary = first.get("receipt",{})
    if not _check(bool(first.get("ok",false))
        and int(f.get("gross_cleared",-1)) == 600
        and int(f.get("tax_withheld",-1)) == 420
        and int(f.get("paid",-1)) == 180
        and int(economy.unpaid_work_wages(state).get("total",-1)) == 400
        and _total(state,actor) == before,
        "Taxable partial W2 payment must transfer net only and preserve money"): return
    var after_first := _total(state,actor)
    var first_sect := state.sect.spirit_stones
    var first_personal := actor.spirit_stones
    var repeat := economy.pay_work_wage_arrears(state,"eco04-half")
    if not _check(bool(repeat.get("already_settled",false))
        and _total(state,actor) == after_first
        and first_sect == state.sect.spirit_stones
        and first_personal == actor.spirit_stones,
        "Duplicate arrears request moved Stone"): return
    if not _check(SaveService.new().save_to_path(state,SAVE_PATH) == OK,
        "Mid-arrears Save failed"): return
    state = SaveService.new().load_from_path(SAVE_PATH)
    if not _check(state != null,"Cold Reload failed"): return
    actor = state.disciples[id]
    var second := economy.pay_work_wage_arrears(state,"eco04-rest")
    var s: Dictionary = second.get("receipt",{})
    if not _check(bool(second.get("ok",false))
        and int(s.get("gross_cleared",-1)) == 400
        and int(s.get("tax_withheld",-1)) == 280
        and int(s.get("paid",-1)) == 120
        and int(economy.unpaid_work_wages(state).get("total",-1)) == 0
        and _total(state,actor) == before,
        "Cumulative taxation after Save/Load differs from 70%, or budget was minted"): return
    var last_sect := state.sect.spirit_stones
    var last_personal := actor.spirit_stones
    if not _check(bool(economy.pay_work_wage_arrears(state,
            "eco04-rest").get("already_settled",false))
        and state.sect.spirit_stones == last_sect
        and actor.spirit_stones == last_personal
        and state.validate_invariants().is_empty(),
        "Post-reload duplicate arrears or invariants failed"): return

    # Fail-closed forged W2 identity must not pay from Sect or alter worker.
    state.sect.economy_a_receipts["wage:eco04-forged"] = {
        "kind":"wage","job_id":"eco04-forged","worker_id":str(id),
        "due":500,"paid":0,"gross":1500,"w2_floor":2000,"tick":state.tick
    }
    var forged_before := _total(state,actor)
    var forged_sect := state.sect.spirit_stones
    if not _check(not bool(economy.pay_work_wage_arrears(state,
        "eco04-forged").get("ok",false))
        and _total(state,actor) == forged_before
        and state.sect.spirit_stones == forged_sect,
        "Unverified W2 settlement can debit Sect without source receipt"): return
    _clean()
    print("ECO04 R1 QA: 0/30/70/100% x 1/60/90/180m pure quote, funded W2, deferred T2 cumulative tax, cold Save, duplicate/forged guards, PUBLIC HOLD PASS")
    quit(0)

func _clean() -> void:
    for suffix in ["",".bak",".tmp"]:
        var path := SAVE_PATH+suffix
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
