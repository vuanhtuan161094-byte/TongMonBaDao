class_name PveInjuryTreatmentV1
extends RefCounted

# PVE-CARE02 — an Injury service, NOT an HP heal.
# Uses the existing 0/1 Injury and persisted recovery tick. A paid appointment
# shortens that tick; the canonical scheduler alone completes recovery.
# This is an opt-in QA candidate. No second injury timer, save schema, or wallet.
const TREATMENT_TICKS := 30
const FREE_RECOVERY_TICKS := 120
const COST_BY_REALM := {1:1500,2:3000}

static func quote(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if state == null or disciple == null or not PveR12BalanceV1.active(state) \
            or not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"injury_treatment_pilot_disabled"}
    var realm := int(disciple.v2_realm_progress.get("cultivation",{}).get("realm",0))
    if not COST_BY_REALM.has(realm):
        return {"ok":false,"reason":"injury_treatment_realm_not_sourced"}
    return {"ok":true,"realm":realm,"cost":int(COST_BY_REALM[realm]),
        "duration_ticks":TREATMENT_TICKS}

static func start(state: SimulationState, disciple_id: StringName,
        request_id: String) -> Dictionary:
    if state == null or not state.disciples.has(disciple_id) \
            or request_id.is_empty() or request_id.length() > 160:
        return {"ok":false,"reason":"invalid_injury_treatment_request"}
    var receipt_id := "injury-treatment:"+request_id
    var receipts: Dictionary = state.sect.economy_a_receipts
    if receipts.has(receipt_id):
        var prior = receipts[receipt_id]
        if not (prior is Dictionary) or str(prior.get("disciple_id","")) != str(disciple_id):
            return {"ok":false,"reason":"conflicting_injury_treatment_replay"}
        return {"ok":true,"already_settled":true,"receipt":prior.duplicate(true)}
    var actor: DiscipleState = state.disciples[disciple_id]
    var offered := quote(state,actor)
    if not bool(offered.get("ok",false)):
        return offered
    if actor.injury_level != 1 or actor.injury_recover_at_tick <= state.tick:
        return {"ok":false,"reason":"no_active_injury_to_treat"}
    if actor.injury_recover_at_tick <= state.tick+TREATMENT_TICKS:
        return {"ok":false,"reason":"free_recovery_earlier_or_equal"}
    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty() \
            or not [&"EVALUATE",&"IDLE",&"HOLD"].has(actor.current_action) \
            or not actor.work_cycle_state.is_empty() \
            or not actor.work_progress.is_empty() \
            or not actor.worksite_building_id.is_empty() \
            or not actor.active_job_id.is_empty() \
            or not actor.v63_study_job.is_empty():
        return {"ok":false,"reason":"injured_disciple_has_occupied_job"}
    var buildings := BuildingSystem.new()
    if buildings.disciple_has_active_spirit_plot(state,disciple_id) \
            or buildings.disciple_has_active_timed_recipe(state,disciple_id) \
            or not buildings.active_resource_timer_for_worker(state,disciple_id).is_empty() \
            or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor):
        return {"ok":false,"reason":"injured_disciple_has_reserved_work"}
    for prior_value in receipts.values():
        if not (prior_value is Dictionary):
            continue
        var prior: Dictionary = prior_value
        if str(prior.get("kind","")) == "injury_treatment" \
                and str(prior.get("disciple_id","")) == str(disciple_id) \
                and int(prior.get("due_tick",0)) > state.tick:
            return {"ok":false,"reason":"injury_treatment_already_in_progress"}
    var cost := int(offered["cost"])
    if actor.spirit_stones < cost:
        return {"ok":false,"reason":"insufficient_personal_spirit_stones"}
    if state.sect.spirit_stones > EconomySystem.V2_MAX_STONES-cost:
        return {"ok":false,"reason":"sect_spirit_stone_overflow"}
    # Canonical personal→Sect transfer, not a new faucet or global money sink.
    # Injury recovery still consumes 30 simulation minutes, and HP is UNCHANGED.
    var old_due := actor.injury_recover_at_tick
    var hp_before := actor.hp
    actor.spirit_stones -= cost
    state.sect.spirit_stones += cost
    actor.injury_recover_at_tick = state.tick+TREATMENT_TICKS
    actor.current_action = &"HOLD"
    var receipt := {"kind":"injury_treatment","disciple_id":str(disciple_id),
        "realm":int(offered["realm"]),"cost":cost,"started_tick":state.tick,
        "due_tick":actor.injury_recover_at_tick,"natural_due_tick":old_due,
        "hp_restored":0,"hp_at_start":hp_before}
    receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    return {"ok":true,"already_settled":false,
        "save_required":true,"receipt":receipt.duplicate(true)}

static func treatment_in_progress(state: SimulationState,
        disciple: DiscipleState) -> bool:
    if state == null or disciple == null or disciple.injury_level != 1:
        return false
    if not PveR12BalanceV1.active(state):
        return false
    for raw in state.sect.economy_a_receipts.values():
        if not (raw is Dictionary):
            continue
        var receipt: Dictionary = raw
        if str(receipt.get("kind","")) == "injury_treatment" \
                and str(receipt.get("disciple_id","")) == str(disciple.id) \
                and int(receipt.get("started_tick",-1)) <= state.tick \
                and int(receipt.get("due_tick",0)) > state.tick:
            return true
    return false
