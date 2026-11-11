class_name Eco01OriginVein
extends RefCounted

# ECO-01: one real, free-to-start capital recovery worksite at the canonical
# Sect Hall. NO new inventory, SaveService, clock or SectState schema.
# BuildingState.production_state persists its active job and last payout; the
# existing Sect economy_a_receipts is the canonical anti-replay/money ledger.
const KEY := "eco01_origin_vein"
const JOB_PREFIX := "eco01:vein:"
const RECEIPT_PREFIX := "eco01:origin:"
const JOB_TICKS := 60
const COOLDOWN_TICKS := 1440
const GROSS_STONES := 1000

static func owns_worker(disciple: DiscipleState) -> bool:
    return disciple != null and str(disciple.active_job_id).begins_with(JOB_PREFIX)

func _hall(state: SimulationState) -> BuildingState:
    if state == null or not state.p3_7_buildings_enabled:
        return null
    return BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_MAIN_HALL)

func _data(hall: BuildingState) -> Dictionary:
    var raw = hall.production_state.get(KEY,{})
    return raw.duplicate(true) if raw is Dictionary else {}

func _last_paid_tick(state: SimulationState, data: Dictionary) -> int:
    var latest := int(data.get("last_paid_tick",-COOLDOWN_TICKS))
    for key in state.sect.economy_a_receipts.keys():
        if not str(key).begins_with(RECEIPT_PREFIX):
            continue
        var raw = state.sect.economy_a_receipts[key]
        if raw is Dictionary and str(raw.get("kind","")) == "eco01_origin_vein":
            latest = maxi(latest,int(raw.get("tick",-COOLDOWN_TICKS)))
    return latest

func snapshot(state: SimulationState) -> Dictionary:
    var hall := _hall(state)
    if hall == null:
        return {"ok":false,"reason":"canonical_main_hall_missing"}
    var data := _data(hall)
    var active = data.get("job",{})
    var last := _last_paid_tick(state,data)
    var ready_tick := maxi(0,last+COOLDOWN_TICKS)
    if active is Dictionary and not active.is_empty():
        return {
            "ok":true,"busy":true,"job_id":str(active.get("job_id","")),
            "worker_id":str(active.get("worker_id","")),
            "finish_tick":int(active.get("finish_tick",0)),
            "remaining_ticks":maxi(0,int(active.get("finish_tick",0))-state.tick),
            "next_ready_tick":ready_tick,
            "gross":GROSS_STONES
        }
    return {
        "ok":true,"busy":false,"ready":state.tick >= ready_tick,
        "next_ready_tick":ready_tick,
        "remaining_ticks":maxi(0,ready_tick-state.tick),
        "gross":GROSS_STONES
    }

func eligible_workers(state: SimulationState) -> Array[StringName]:
    var eligible: Array[StringName] = []
    if state == null:
        return eligible
    var ids: Array = state.disciples.keys()
    ids.sort()
    for key in ids:
        var actor: DiscipleState = state.disciples[key]
        if _worker_ready(state,actor):
            eligible.append(actor.id)
    return eligible

func _worker_ready(state: SimulationState, actor: DiscipleState) -> bool:
    if actor == null or actor.region_id != &"sect" or actor.injury_level != 0 \
            or not actor.active_pve_encounter_id.is_empty() or actor.active_job_id != &"" \
            or not actor.v63_study_job.is_empty() or not actor.work_cycle_state.is_empty() \
            or not actor.direct_command.is_empty():
        return false
    if PveInjuryTreatmentV1.treatment_in_progress(state,actor):
        return false
    if DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor):
        return false
    var buildings := BuildingSystem.new()
    return not buildings.disciple_has_active_timed_recipe(state,actor.id) \
        and not buildings.disciple_has_active_spirit_plot(state,actor.id)

func start(state: SimulationState, worker_id: StringName) -> Dictionary:
    var hall := _hall(state)
    if hall == null or not state.sect.economy_a_enabled:
        return {"ok":false,"reason":"canonical_economy_or_main_hall_missing"}
    if not state.sect.workforce_enabled or not state.disciples.has(worker_id):
        return {"ok":false,"reason":"real_worker_missing"}
    var actor: DiscipleState = state.disciples[worker_id]
    if not _worker_ready(state,actor):
        return {"ok":false,"reason":"worker_busy_or_unavailable"}
    var data := _data(hall)
    var pending = data.get("job",{})
    if pending is Dictionary and not pending.is_empty():
        return {"ok":false,"reason":"sect_vein_job_busy"}
    var next_ready := _last_paid_tick(state,data)+COOLDOWN_TICKS
    if state.tick < next_ready:
        return {"ok":false,"reason":"sect_vein_cooldown","next_ready_tick":next_ready}
    var sequence := maxi(0,int(data.get("sequence",0)))+1
    var id := "%s%s:%d:%d" % [JOB_PREFIX,str(hall.id),state.tick,sequence]
    data["sequence"] = sequence
    data["job"] = {
        "job_id":id, "worker_id":str(actor.id),
        "started_tick":state.tick,"finish_tick":state.tick+JOB_TICKS,
        "gross":GROSS_STONES,"site_id":str(hall.id)
    }
    var production := hall.production_state.duplicate(true)
    production[KEY] = data
    hall.production_state = production
    actor.active_job_id = StringName(id)
    # Force the canonical Workforce EVALUATE -> HOLD path on the next tick.
    actor.current_action = &"EVALUATE"
    state.building_event_count += 1
    state.sect.workforce_event_count += 1
    return {"ok":true,"job_id":id,"finish_tick":state.tick+JOB_TICKS,
        "worker_id":str(actor.id),"gross":GROSS_STONES}

func cancel(state: SimulationState, worker_id: StringName, job_id: String) -> Dictionary:
    var hall := _hall(state)
    if hall == null:
        return {"ok":false,"reason":"canonical_main_hall_missing"}
    var data := _data(hall)
    var job = data.get("job",{})
    if not (job is Dictionary) or job.is_empty() or str(job.get("job_id","")) != job_id \
            or str(job.get("worker_id","")) != str(worker_id) or state.tick >= int(job.get("finish_tick",0)):
        return {"ok":false,"reason":"active_job_mismatch"}
    _drop_job(state,hall,data,job)
    return {"ok":true,"cancelled":true,"gross":0}

func _drop_job(state: SimulationState, hall: BuildingState,
        data: Dictionary, job: Dictionary) -> void:
    var worker_id := StringName(str(job.get("worker_id","")))
    var actor = state.disciples.get(worker_id)
    if actor is DiscipleState and str(actor.active_job_id) == str(job.get("job_id","")):
        actor.active_job_id = &""
        actor.current_action = &"EVALUATE"
    data["job"] = {}
    var production := hall.production_state.duplicate(true)
    production[KEY] = data
    hall.production_state = production
    state.building_event_count += 1
    state.sect.workforce_event_count += 1

func process_tick(state: SimulationState) -> void:
    var hall := _hall(state)
    if hall == null or not state.sect.economy_a_enabled:
        return
    var data := _data(hall)
    var pending = data.get("job",{})
    if not (pending is Dictionary) or pending.is_empty():
        return
    var job: Dictionary = pending
    var id := str(job.get("job_id",""))
    var started := int(job.get("started_tick",-1))
    var finished := int(job.get("finish_tick",-1))
    var worker_id := StringName(str(job.get("worker_id","")))
    var worker = state.disciples.get(worker_id)
    var valid := id == ("%s%s:%d:%d" % [
            JOB_PREFIX,str(hall.id),started,int(data.get("sequence",0))]) \
        and str(job.get("site_id","")) == str(hall.id) \
        and started >= 0 and finished-started == JOB_TICKS \
        and state.tick >= started and int(job.get("gross",-1)) == GROSS_STONES \
        and worker is DiscipleState and str(worker.active_job_id) == id \
        and worker.region_id == &"sect" and worker.injury_level == 0 \
        and worker.active_pve_encounter_id.is_empty() \
        and worker.v63_study_job.is_empty()
    if not valid:
        _drop_job(state,hall,data,job)
        return
    if state.tick < finished:
        return
    var receipt_id := RECEIPT_PREFIX+id
    var wage_receipt_id := "wage:"+id
    if state.sect.economy_a_receipts.has(receipt_id) \
            or state.sect.economy_a_receipts.has(wage_receipt_id) \
            or finished < _last_paid_tick(state,data)+COOLDOWN_TICKS:
        _drop_job(state,hall,data,job)
        return
    if state.sect.spirit_stones > EconomySystem.V2_MAX_STONES-GROSS_STONES:
        # Overflow cannot be a valid settlement; keep the job for a later
        # tick, with no half-created wage or cash receipt.
        return
    state.sect.spirit_stones += GROSS_STONES
    var wage := EconomySystem.new().settle_work_wage(state,worker,id)
    if not bool(wage.get("ok",false)) or bool(wage.get("already_settled",false)):
        # Only the canonical EconomySystem may pay a worker; never partial.
        state.sect.spirit_stones -= GROSS_STONES
        return
    var wage_paid := int(wage.get("receipt",{}).get("paid",0))
    var receipt := {
        "kind":"eco01_origin_vein","job_id":id,
        "worker_id":str(worker.id),"site_id":str(hall.id),
        "gross":GROSS_STONES,"wage_paid":wage_paid,
        "sect_net":GROSS_STONES-wage_paid,
        "started_tick":started,"finish_tick":finished,"tick":state.tick
    }
    state.sect.economy_a_receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    data["last_paid_tick"] = state.tick
    _drop_job(state,hall,data,job)
