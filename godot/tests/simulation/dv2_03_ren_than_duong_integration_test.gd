extends SceneTree

# V2 dedicated body training: building, deterministic slots, paid economic
# transaction before source grant, dedup, scheduler, policy and save/load.
func _init() -> void:
    call_deferred("_run")

func _assert(ok: bool, reason: String) -> bool:
    if not ok:
        push_error(reason)
        quit(1)
        return false
    return true

func _near(a: float, b: float) -> bool:
    return absf(a-b) < 0.0001

func _recruit(state: SimulationState, index: int) -> DiscipleState:
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,index
    )
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    return state.disciples[candidate.id]

func _run() -> void:
    var state := P37Factory.create_state(47710)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.spirit_stones = 10 # QA-only economic fixture; no production mint.
    var buildings := BuildingSystem.new()
    var facility := buildings.ensure_body_training_facility(state)
    if not _assert(facility != null and facility.level == 1 and
        facility.building_type == BuildingSystem.TYPE_BODY_TRAINING and
        buildings.worker_slots(facility) == 2 and
        buildings.ensure_body_training_facility(state) == facility,
        "Rèn Thân Đường absent, wrong slots or not repeat-safe."):
        return
    if not _assert(not bool(buildings.can_start_upgrade(state,facility.id).get("ok",true)),
        "Unapproved Rèn Thân building upgrade was enabled."):
        return

    var a := _recruit(state,301)
    var b := _recruit(state,302)
    var c := _recruit(state,303)
    if not _assert(a != null and b != null and c != null, "Cannot recruit three V2 disciples."):
        return

    var reserved_a := DiscipleBodyTrainingFacilityV2.reserve_slot(state,a.id)
    var reserved_b := DiscipleBodyTrainingFacilityV2.reserve_slot(state,b.id)
    var denied_c := DiscipleBodyTrainingFacilityV2.reserve_slot(state,c.id)
    if not _assert(bool(reserved_a.get("ok",false)) and bool(reserved_b.get("ok",false)) and
        not bool(denied_c.get("ok",true)) and
        str(denied_c.get("reason","")) == "body_training_slots_full" and
        c.work_group_id != facility.worker_group_id and
        buildings.active_worker_ids(state,facility).size() == 2,
        "Real training building permitted overbook or mutated third disciple."):
        return

    var body_policy := DiscipleTrainingPolicyV2.set_policy(state,a.id,"body_focus")
    var auto := DiscipleTrainingPolicyV2.choose_auto_action(state,a)
    if not _assert(bool(body_policy.get("ok",false)) and
        bool(auto.get("ok",false)) and str(auto.get("action","")) == "TRAIN_BODY",
        "Body focus cannot select a legitimate paid training slot."):
        return

    a.constitution = 100.0
    a.current_action = &"EVALUATE"
    var before_xp := float(a.v2_realm_progress["body"]["xp"])
    var preview := DiscipleTrainingActionV2.preview_training(state,a,"body")
    var request := DiscipleTrainingActionV2.request_training(state,a.id,"body")
    if not _assert(bool(preview.get("ok",false)) and bool(request.get("ok",false)) and
        a.current_action == &"TRAIN_BODY" and
        _near(float(a.v2_realm_progress["body"]["xp"]),before_xp) and
        state.sect.spirit_stones == 10,
        "Training request granted immediate EXP or charged before elapsed minute."):
        return

    state.tick = 1
    var paid := DiscipleTrainingActionV2.resolve(state,a,"TRAIN_BODY")
    var expected := 1500.0 * 1.20
    if not _assert(bool(paid.get("ok",false)) and
        str(paid.get("source_kind","")) == "body_training" and
        _near(float(paid.get("gained",0.0)),expected) and
        _near(float(a.v2_realm_progress["body"]["xp"])-before_xp,expected) and
        state.sect.spirit_stones == 9 and
        int(facility.production_state.get("paid_training_minutes",-1)) == 1,
        "Paid training minute failed to debit exactly one stone before canonical Body EXP."):
        return

    var again := DiscipleTrainingActionV2.resolve(state,a,"TRAIN_BODY")
    if not _assert(not bool(again.get("ok",true)) and
        str(again.get("reason","")) == "body_xp_tick_already_awarded" and
        state.sect.spirit_stones == 9 and
        _near(float(a.v2_realm_progress["body"]["xp"])-before_xp,expected),
        "Same-minute training charged or granted twice."):
        return

    b.current_action = &"TRAIN_BODY"
    var paid_b := DiscipleTrainingActionV2.resolve(state,b,"TRAIN_BODY")
    if not _assert(bool(paid_b.get("ok",false)) and state.sect.spirit_stones == 8 and
        int(facility.production_state.get("paid_training_minutes",-1)) == 2,
        "Second legal training slot did not grant independent paid Body minute."):
        return

    # One canonical state round-trip; preserve slot reservations, paid audit
    # counters and the persisted anti-duplicate tick.
    var saved := SimulationState.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
    var restored_building := buildings.primary_building(saved,BuildingSystem.TYPE_BODY_TRAINING)
    var restored_a: DiscipleState = saved.disciples[a.id]
    if not _assert(restored_building != null and
        buildings.active_worker_ids(saved,restored_building).size() == 2 and
        int(restored_building.production_state.get("spent_spirit_stones",-1)) == 2 and
        int(restored_a.v2_realm_progress.get("last_body_xp_tick",-1)) == 1 and
        saved.sect.spirit_stones == 8,
        "Save/load lost training reservation, treasury or paid-minute accounting."):
        return

    # Actual scheduler action = minute 2, with unrelated actors deliberately
    # holding so the stone delta has only one explicit training consumer.
    for member in saved.disciples.values():
        member.current_action = &"HOLD"
    restored_a.current_action = &"TRAIN_BODY"
    var before_tick_xp := float(restored_a.v2_realm_progress["body"]["xp"])
    var scheduler := SimulationScheduler.new(saved)
    scheduler.step()
    var recorded: Dictionary = restored_a.last_decision.get("v2_body_training_result",{})
    if not _assert(saved.tick == 2 and bool(recorded.get("ok",false)) and
        saved.sect.spirit_stones == 7 and
        _near(float(restored_a.v2_realm_progress["body"]["xp"])-before_tick_xp,expected),
        "Scheduler did not commit exactly one paid real Body minute."):
        return

    # No resources: fail closed, neither Body EXP nor debit nor debt is created.
    saved.sect.spirit_stones = 0
    restored_a.current_action = &"TRAIN_BODY"
    var no_stones_before := float(restored_a.v2_realm_progress["body"]["xp"])
    scheduler.step()
    var broke: Dictionary = restored_a.last_decision.get("v2_body_training_result",{})
    if not _assert(not bool(broke.get("ok",true)) and
        str(broke.get("reason","")) == "insufficient_training_spirit_stones" and
        saved.sect.spirit_stones == 0 and
        _near(float(restored_a.v2_realm_progress["body"]["xp"]),no_stones_before),
        "Unpaid Rèn Thân incorrectly granted EXP."):
        return
    print("DV2-03 REN THAN DUONG TWO SLOTS + PAID BODY XP + SAVE/SCHEDULER: PASS")
    quit(0)
