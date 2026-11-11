extends SceneTree

# ECO-01: real paid job time, Hall persistence, personal wage transfer, Sect
# revenue and no-NPC/zero-tax safety. Only bootstrap cash is forced to zero
# (QA stress setup). The vein must earn everything after that.
const SAVE_PATH := "user://qa_eco01_origin_vein_loop.json"
const OFFLINE_PATH := "user://qa_eco01_origin_vein_offline.json"
const BASE_UNIX := 2000009000
var vein := Eco01OriginVein.new()
var economy := EconomySystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("ECO01 ORIGIN VEIN FAIL: "+why)
        _cleanup()
        quit(1)
        return false
    return true

func _run() -> void:
    _cleanup()
    if not _test_save_replay_and_cooldown():
        return
    if not _test_offline_replay():
        return
    _cleanup()
    print("ECO01 ORIGIN VEIN: 0 LT REAL JOB 60T, WAGE, 1/1440T, 6/30, COLD SAVE, OFFLINE EXACT-ONCE: PASS")
    quit(0)

func _test_save_replay_and_cooldown() -> bool:
    var state := P37Factory.create_state(1081081)
    if not _check(bool(economy.enable_v1(state).get("ok",false))
        and BuildingSystem.new().ensure_main_hall(state) != null,
        "source must be authentic Economy-A Hall"): return false
    state.sect.spirit_stones = 0
    if not _check(state.disciples.size() == 6 and not economy.sx_v55_r12_enabled(state),
        "must preserve six-person r1/r2 player economy HOLD"): return false
    var workers := vein.eligible_workers(state)
    if not _check(not workers.is_empty() and state.sect.spirit_stones == 0,
        "no real free starter vein worker from 0 LT"): return false
    var worker_id := workers[0]
    var actor: DiscipleState = state.disciples[worker_id]
    var original_personal := actor.spirit_stones
    var begin := vein.start(state,worker_id)
    var job_id := str(begin.get("job_id",""))
    if not _check(bool(begin.get("ok",false)) and job_id.begins_with(Eco01OriginVein.JOB_PREFIX)
        and actor.active_job_id == StringName(job_id)
        and int(begin.get("finish_tick",-1)) == state.tick+60
        and not bool(vein.start(state,worker_id).get("ok",false)),
        "start must claim exactly one worker slot"): return false
    if not _check(not WorkforceSystem.new().issue_command(state,worker_id,WorkforceSystem.COMMAND_WORK,"mining")
        and not WorkforceSystem.new().assign_group(state,worker_id,&"herbalism_crew")
        and not bool(WorkforceSystem.new().perform_work(state,actor,WorkforceSystem.PROF_MINING).get("ok",false)),
        "concurrent work/command/transfer was permitted"): return false
    var scheduler := SimulationScheduler.new(state)
    scheduler.run_ticks(29)
    if not _check(state.sect.spirit_stones == 0
        and bool(vein.snapshot(state).get("busy",false))
        and not state.sect.economy_a_receipts.has(Eco01OriginVein.RECEIPT_PREFIX+job_id),
        "cash granted before a completed genuine 60-minute job"): return false
    var saver := SaveService.new()
    if not _check(saver.save_to_path(state,SAVE_PATH) == OK,
        "cold in-flight Save failed"): return false
    state = saver.load_from_path(SAVE_PATH)
    if not _check(state != null and state.sect.spirit_stones == 0
        and bool(vein.snapshot(state).get("busy",false)),
        "cold reload lost the job or minted cash"): return false
    scheduler = SimulationScheduler.new(state)
    scheduler.run_ticks(30)
    if not _check(state.sect.spirit_stones == 0
        and not state.sect.economy_a_receipts.has(Eco01OriginVein.RECEIPT_PREFIX+job_id),
        "59-minute early settlement"): return false
    scheduler.step()
    actor = state.disciples[worker_id]
    var wage: Dictionary = state.sect.economy_a_receipts.get("wage:"+job_id,{})
    var receipt: Dictionary = state.sect.economy_a_receipts.get(Eco01OriginVein.RECEIPT_PREFIX+job_id,{})
    if not _check(not bool(vein.snapshot(state).get("busy",true))
        and int(receipt.get("gross",-1)) == 1000
        and int(receipt.get("wage_paid",-1)) == 2
        and int(receipt.get("sect_net",-1)) == 998
        and int(wage.get("paid",-1)) == 2
        and actor.spirit_stones == original_personal+2
        and state.sect.spirit_stones == 998 and actor.active_job_id == &"",
        "earned payout, existing wage, or worker cleanup incorrect"): return false
    var money_after := state.sect.spirit_stones
    var receipts_after := state.sect.economy_a_receipts.duplicate(true)
    vein.process_tick(state)
    scheduler.run_ticks(15)
    if not _check(state.sect.spirit_stones == money_after
        and state.sect.economy_a_receipts == receipts_after
        and not bool(vein.start(state,worker_id).get("ok",false)),
        "same-day replay or cooldown bypass"): return false

    # Jump ONLY the QA clock boundary; the previous genuine job duration was
    # advanced with the actual scheduler. No bonus tick or external credit.
    var ready := int(vein.snapshot(state).get("next_ready_tick",-1))
    state.tick = ready-1
    if not _check(not bool(vein.start(state,worker_id).get("ok",false)),
        "24h cap bypassed one tick early"): return false
    state.tick = ready
    # The original worker can legitimately have started another real Mine or
    # Forest timer after first settlement. Choose an actually idle disciple,
    # never override an existing job merely to make this QA pass.
    var ready_workers := vein.eligible_workers(state)
    if not _check(not ready_workers.is_empty(),
        "all real workers occupied at cooldown: "+str(state.disciples.size())): return false
    var second_worker_id := ready_workers[0]
    var second := vein.start(state,second_worker_id)
    var second_id := str(second.get("job_id",""))
    if not _check(bool(second.get("ok",false))
        and second_id != job_id
        and not bool(vein.start(state,second_worker_id).get("ok",false)),
        "cannot start one new eligible worker after cooldown: "+str(second)): return false
    if not _check(bool(vein.cancel(state,second_worker_id,second_id).get("ok",false))
        and state.sect.spirit_stones == money_after
        and not state.sect.economy_a_receipts.has(Eco01OriginVein.RECEIPT_PREFIX+second_id),
        "aborted job generated cash"): return false
    var third := vein.start(state,second_worker_id)
    if not _check(bool(third.get("ok",false)),
        "after cancellation a genuine worker should be recoverable: "+str(third)): return false
    var total_before := state.sect.spirit_stones
    var worker_before := (state.disciples[second_worker_id] as DiscipleState).spirit_stones
    var origin_count_before := 0
    for key in state.sect.economy_a_receipts.keys():
        if str(key).begins_with(Eco01OriginVein.RECEIPT_PREFIX):
            origin_count_before += 1
    for member in state.disciples.values():
        total_before += (member as DiscipleState).spirit_stones
    scheduler = SimulationScheduler.new(state)
    scheduler.run_ticks(60)
    var total_after := state.sect.spirit_stones
    var origin_count_after := 0
    for key in state.sect.economy_a_receipts.keys():
        if str(key).begins_with(Eco01OriginVein.RECEIPT_PREFIX):
            origin_count_after += 1
    for member in state.disciples.values():
        total_after += (member as DiscipleState).spirit_stones
    var third_id := str(third.get("job_id",""))
    var earned: Dictionary = state.sect.economy_a_receipts.get(
        Eco01OriginVein.RECEIPT_PREFIX+third_id,{})
    var third_wage: Dictionary = state.sect.economy_a_receipts.get("wage:"+third_id,{})
    # Other legitimate P2/legacy personal cash events can run in parallel
    # during 60 actual scheduler ticks (observed +8 LT). Audit ECO-01
    # exactly-one receipt and money transfer rather than falsely assigning
    # unrelated P2 income to this job.
    if not _check(origin_count_after == origin_count_before+1
        and int(earned.get("gross",-1)) == 1000
        and int(earned.get("wage_paid",-1)) == 2
        and int(third_wage.get("paid",-1)) == 2
        and (state.disciples[second_worker_id] as DiscipleState).spirit_stones == worker_before+2
        and total_after-total_before >= 1000,
        "second day source receipt/wage not conserved; delta=%d receipt=%s" % [
            total_after-total_before,str(earned)]): return false
    if not _check(saver.save_to_path(state,SAVE_PATH) == OK,
        "post-settlement Save failed"): return false
    var loaded := saver.load_from_path(SAVE_PATH)
    if not _check(loaded != null and loaded.sect.spirit_stones == state.sect.spirit_stones
        and loaded.sect.economy_a_receipts == state.sect.economy_a_receipts,
        "cold Save lost cash / changed receipts"): return false
    vein.process_tick(loaded)
    if not _check(loaded.sect.spirit_stones == state.sect.spirit_stones
        and not bool(vein.start(loaded,worker_id).get("ok",false)),
        "cold replay paid twice"): return false

    # An owned roster count alone must NEVER multiply a Sect daily vein cap.
    # QA-only extra actors; this does not pretend to buy 30 funded worksite slots.
    loaded.sect.disciple_capacity = 30
    var recruiter := RecruitmentSystem.new()
    while loaded.disciples.size() < 30:
        var candidate := recruiter.generate_candidate(loaded)
        if not _check(candidate != null,"cannot generate genuine QA recruit"): return false
        if not _check(bool(recruiter.accept_candidate(loaded,candidate.id).get("ok",false)),
            "cannot admit QA 30-member roster"): return false
    if not _check(loaded.disciples.size() == 30
        and not vein.eligible_workers(loaded).is_empty()
        and not bool(vein.start(loaded,vein.eligible_workers(loaded)[0]).get("ok",false))
        and loaded.sect.spirit_stones == state.sect.spirit_stones,
        "30 owned actors multiplied daily Sect cash"): return false
    print("ECO01_6_30_ROSTER_COOLDOWN_SAME_SECT_CASH: PASS")
    return _check(loaded.validate_invariants().is_empty(),
        "canonical 30 roster invariant failure")

func _test_offline_replay() -> bool:
    var first := LiveGameRuntimeV2.new()
    var started := first.start(OFFLINE_PATH,BASE_UNIX,1081082)
    if not _check(bool(started.get("ok",false)) and bool(started.get("created",false)),
        "LiveGameRuntimeV2 NewGame unavailable"): return false
    var state: SimulationState = first.state()
    state.sect.spirit_stones = 0
    var available := vein.eligible_workers(state)
    if not _check(not available.is_empty(),"no authentic live worker for offline test"): return false
    var worker := available[0]
    var begin := vein.start(state,worker)
    if not _check(bool(begin.get("ok",false)),"cannot start real live vein job"): return false
    var id := str(begin.get("job_id",""))
    if not _check(bool(first.save(BASE_UNIX).get("ok",false)),
        "save in-flight job to real LiveGameRuntimeV2 path failed"): return false
    var resumed := LiveGameRuntimeV2.new()
    var reload := resumed.start(OFFLINE_PATH,BASE_UNIX+60*60,1081082)
    if not _check(bool(reload.get("ok",false)) and bool(reload.get("loaded",false))
        and int(reload.get("catch_up_steps",-1)) == 60,
        "canonical runtime offline replay was not 60 sim minutes"): return false
    state = resumed.state()
    if not _check(state.sect.spirit_stones == 998
        and int(state.sect.economy_a_receipts.get(Eco01OriginVein.RECEIPT_PREFIX+id,{}).get("gross",-1)) == 1000,
        "offline 60 min did not settle exactly one real job"): return false
    var cash := state.sect.spirit_stones
    var ledger := state.sect.economy_a_receipts.duplicate(true)
    if not _check(bool(resumed.save(BASE_UNIX+60*60).get("ok",false)),
        "post-offline real runtime Save failed"): return false
    var again := LiveGameRuntimeV2.new()
    var reopened := again.start(OFFLINE_PATH,BASE_UNIX+60*60,1081082)
    if not _check(bool(reopened.get("ok",false))
        and int(reopened.get("catch_up_steps",-1)) == 0
        and again.state().sect.spirit_stones == cash
        and again.state().sect.economy_a_receipts == ledger,
        "same-time second cold reload duplicated 1,000 LT"): return false
    print("ECO01_OFFLINE_60M_COLD_SAVE_ONCE: PASS")
    return _check(again.state().validate_invariants().is_empty(),
        "post-offline canonical state invariants failed")

func _cleanup() -> void:
    for base in [SAVE_PATH,OFFLINE_PATH]:
        for suffix in ["",".bak",".tmp"]:
            if FileAccess.file_exists(base+suffix):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(base+suffix))
