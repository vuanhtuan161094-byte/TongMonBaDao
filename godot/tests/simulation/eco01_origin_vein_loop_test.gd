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
    if not _test_fail_closed_guards():
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
        and _vein_receipts_equal(state.sect.economy_a_receipts,loaded.sect.economy_a_receipts),
        "cold Save mismatch: loaded=%s; cash=%d/%d; receipts_keys=%s expected_keys=%s" % [
            str(loaded != null),
            loaded.sect.spirit_stones if loaded != null else -1,
            state.sect.spirit_stones,
            str(loaded.sect.economy_a_receipts.keys()) if loaded != null else "null",
            str(state.sect.economy_a_receipts.keys())]): return false
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


func _test_fail_closed_guards() -> bool:
    # Exercise fail-closed settlement without granting a fictitious game source.
    # The 60-tick completion itself is covered by the full scheduler test.
    var state := P37Factory.create_state(1081083)
    if not _check(bool(economy.enable_v1(state).get("ok",false))
        and BuildingSystem.new().ensure_main_hall(state) != null,
        "negative cases require a real canonical Hall"): return false
    state.sect.spirit_stones = 0
    var candidates := vein.eligible_workers(state)
    if not _check(candidates.size() >= 2,
        "negative cases require two real eligible workers"): return false
    var worker_id := candidates[0]
    var other_worker_id := candidates[1]
    var first := vein.start(state,worker_id)
    var first_id := str(first.get("job_id",""))
    if not _check(bool(first.get("ok",false))
        and not bool(vein.start(state,other_worker_id).get("ok",false)),
        "different workers must not multiply the single Sect job"): return false

    # A corrupted persisted Hall job may never mint currency or a wage.
    var hall := BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_MAIN_HALL)
    var production: Dictionary = hall.production_state.duplicate(true)
    var vein_data: Dictionary = production.get(Eco01OriginVein.KEY,{}).duplicate(true)
    var forged: Dictionary = vein_data.get("job",{}).duplicate(true)
    forged["gross"] = 1001
    vein_data["job"] = forged
    production[Eco01OriginVein.KEY] = vein_data
    hall.production_state = production
    state.tick = int(first.get("finish_tick",-1))
    vein.process_tick(state)
    if not _check(state.sect.spirit_stones == 0
        and not bool(vein.snapshot(state).get("busy",true))
        and state.disciples[worker_id].active_job_id == &""
        and not state.sect.economy_a_receipts.has(Eco01OriginVein.RECEIPT_PREFIX+first_id)
        and not state.sect.economy_a_receipts.has("wage:"+first_id),
        "forged gross payout must fail closed and free the worker"): return false

    # A legitimate completed job at the currency ceiling stays pending,
    # without an incomplete money/wage receipt; settle only when affordable.
    var second := vein.start(state,worker_id)
    var second_id := str(second.get("job_id",""))
    if not _check(bool(second.get("ok",false)),
        "valid worker was not recovered after malformed Hall job"): return false
    state.tick = int(second.get("finish_tick",-1))
    var over_ceiling := EconomySystem.V2_MAX_STONES-Eco01OriginVein.GROSS_STONES+1
    state.sect.spirit_stones = over_ceiling
    vein.process_tick(state)
    if not _check(state.sect.spirit_stones == over_ceiling
        and bool(vein.snapshot(state).get("busy",false))
        and not state.sect.economy_a_receipts.has(Eco01OriginVein.RECEIPT_PREFIX+second_id)
        and not state.sect.economy_a_receipts.has("wage:"+second_id),
        "overflow created partial income or a wage receipt"): return false
    state.sect.spirit_stones = 0
    vein.process_tick(state)
    vein.process_tick(state)
    if not _check(state.sect.spirit_stones == 998
        and int(state.sect.economy_a_receipts.get(
            Eco01OriginVein.RECEIPT_PREFIX+second_id,{}).get("gross",-1)) == 1000
        and int(state.sect.economy_a_receipts.get("wage:"+second_id,{}).get("paid",-1)) == 2,
        "recovered settlement must pay exactly once with the real wage"): return false

    # Injury invalidates an in-flight job and cannot generate a ghost payout.
    var injured_state := P37Factory.create_state(1081084)
    if not _check(bool(economy.enable_v1(injured_state).get("ok",false))
        and BuildingSystem.new().ensure_main_hall(injured_state) != null,
        "injury guard missing canonical Hall"): return false
    injured_state.sect.spirit_stones = 0
    var injured_candidates := vein.eligible_workers(injured_state)
    if not _check(not injured_candidates.is_empty(),
        "injury guard missing actual idle worker"): return false
    var injured_id := injured_candidates[0]
    var injured_job := vein.start(injured_state,injured_id)
    var injured_job_id := str(injured_job.get("job_id",""))
    if not _check(bool(injured_job.get("ok",false)),
        "injury guard could not start authentic job"): return false
    injured_state.disciples[injured_id].injury_level = 1
    injured_state.tick = int(injured_job.get("finish_tick",-1))
    vein.process_tick(injured_state)
    if not _check(injured_state.sect.spirit_stones == 0
        and not bool(vein.snapshot(injured_state).get("busy",true))
        and injured_state.disciples[injured_id].active_job_id == &""
        and not injured_state.sect.economy_a_receipts.has(Eco01OriginVein.RECEIPT_PREFIX+injured_job_id)
        and not injured_state.sect.economy_a_receipts.has("wage:"+injured_job_id),
        "injured worker generated unearned money"): return false
    print("ECO01_FORGED_JOB_OVERFLOW_INJURY_SECOND_WORKER: PASS")
    return true

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
        and _vein_receipts_equal(ledger,again.state().sect.economy_a_receipts),
        "same-time second cold reload duplicated 1,000 LT"): return false
    print("ECO01_OFFLINE_60M_COLD_SAVE_ONCE: PASS")
    return _check(again.state().validate_invariants().is_empty(),
        "post-offline canonical state invariants failed")

# SaveService canonicalizes dictionary ordering and other unrelated
# receipts. Verify the full ECO-01 economic effect instead of requiring raw
# byte-equivalence for the whole game's heterogeneous receipt dictionary.
func _vein_receipts_equal(before: Dictionary, after: Dictionary) -> bool:
    var origin_before := 0
    var origin_after := 0
    for raw_id in before.keys():
        var id := str(raw_id)
        if not id.begins_with(Eco01OriginVein.RECEIPT_PREFIX):
            continue
        origin_before += 1
        if not after.has(id):
            return false
        var original = before[id]
        var restored = after[id]
        if not (original is Dictionary) or not (restored is Dictionary):
            return false
        for field in ["kind","job_id","worker_id","site_id"]:
            if not restored.has(field) or str(original.get(field,"")) != str(restored.get(field,"")):
                return false
        for field in ["gross","wage_paid","sect_net","started_tick","finish_tick","tick"]:
            # Existing Save JSON parser normalizes integers to exact floats;
            # numeric equality, not text formatting (1000 vs 1000.0), is
            # the persistence contract for these bounded integral amounts.
            if not restored.has(field) or int(original.get(field,-1)) != int(restored.get(field,-2)):
                return false
        var wage_id := "wage:"+str(original.get("job_id",""))
        if not before.has(wage_id) or not after.has(wage_id):
            return false
        var wage_before: Dictionary = before[wage_id]
        var wage_after: Dictionary = after[wage_id]
        for field in ["kind","job_id","worker_id"]:
            if not wage_after.has(field) or str(wage_before.get(field,"")) != str(wage_after.get(field,"")):
                return false
        for field in ["paid","due","tick"]:
            if not wage_after.has(field) or int(wage_before.get(field,-1)) != int(wage_after.get(field,-2)):
                return false
    for raw_id in after.keys():
        if str(raw_id).begins_with(Eco01OriginVein.RECEIPT_PREFIX):
            origin_after += 1
    return origin_before == origin_after

func _cleanup() -> void:
    for base in [SAVE_PATH,OFFLINE_PATH]:
        for suffix in ["",".bak",".tmp"]:
            if FileAccess.file_exists(base+suffix):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(base+suffix))
