extends SceneTree

# DV2-03E3.1 real runtime regression: slot transfer, protected scheduled
# training, explicit job/heal overrides, finite-stone multi-minute economy,
# no phantom reward on UI/player command, deterministic save/load.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if ok:
        return true
    push_error(message)
    quit(1)
    return false

func _recruit(state: SimulationState, index: int) -> DiscipleState:
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,index
    )
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    var member: DiscipleState = state.disciples[candidate.id]
    member.region_id = &"sect"
    member.current_action = &"EVALUATE"
    return member

func _seed() -> Dictionary:
    var state := P37Factory.create_state(47311)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.spirit_stones = 12
    var hall := BuildingSystem.new().ensure_body_training_facility(state)
    if hall == null:
        return {}
    var a := _recruit(state,701)
    var b := _recruit(state,702)
    var c := _recruit(state,703)
    if a == null or b == null or c == null:
        return {}
    return {"state":state,"hall":hall,"a":a,"b":b,"c":c}

func _reserve_and_queue(state: SimulationState, member: DiscipleState) -> bool:
    var slot := DiscipleBodyTrainingFacilityV2.reserve_slot(state,member.id)
    if not bool(slot.get("ok",false)):
        return false
    var command := DiscipleTrainingActionV2.request_training(state,member.id,"body")
    if not bool(command.get("ok",false)):
        return false
    var policy := DiscipleTrainingPolicyV2.set_policy(state,member.id,"body_focus")
    return bool(policy.get("ok",false))

func _run() -> void:
    if not _test_slot_switch_and_commands():
        return
    if not _test_scheduler_training_and_shortage():
        return
    print("DV2-03E3.1 SLOT TRANSFER + EXCLUSIVE SCHEDULE + MULTI-MINUTE LEDGER: PASS")
    quit(0)

func _test_slot_switch_and_commands() -> bool:
    var fx := _seed()
    if not _check(not fx.is_empty(),"Cannot create authentic E3.1 V2 fixture."):
        return false
    var state: SimulationState = fx["state"]
    var hall: BuildingState = fx["hall"]
    var a: DiscipleState = fx["a"]
    var b: DiscipleState = fx["b"]
    var c: DiscipleState = fx["c"]
    var buildings := BuildingSystem.new()
    var workforce := WorkforceSystem.new()
    if not _check(_reserve_and_queue(state,a) and _reserve_and_queue(state,b),
        "Cannot reserve both real Rèn Thân places."):
        return false
    if not _check(buildings.active_worker_ids(state,hall).size() == 2,
        "Two slots did not count actual two trainees."):
        return false

    # Bad/blocked track request must not kick anyone out of a paid building.
    var rejected := DiscipleTrainingActionV2.request_training(state,a.id,"nonexistent")
    if not _check(not bool(rejected.get("ok",true)) and
        DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,a) and
        a.current_action == &"TRAIN_BODY","Invalid track evicted a trainee."):
        return false

    # Actual backend Chuyên Tu request, not only UI, is an atomic transfer.
    var cult := DiscipleTrainingActionV2.request_training(state,a.id,"cultivation")
    if not _check(bool(cult.get("ok",false)) and a.current_action == &"CULTIVATE" and
        a.work_group_id == &"" and a.worksite_building_id == &"" and
        buildings.active_worker_ids(state,hall).size() == 1 and
        state.sect.spirit_stones == 12,
        "Chuyên Tu left a ghost Rèn Thân slot or modified wallet."):
        return false
    if not _check(_reserve_and_queue(state,c) and
        buildings.active_worker_ids(state,hall).has(c.id) and
        buildings.active_worker_ids(state,hall).size() == 2,
        "Third real V2 disciple could not reuse released place."):
        return false

    var stored := SimulationState.from_dict(
        JSON.parse_string(JSON.stringify(state.to_dict()))
    )
    var restored_hall := buildings.primary_building(stored,BuildingSystem.TYPE_BODY_TRAINING)
    var restored_a: DiscipleState = stored.disciples[a.id]
    if not _check(restored_hall != null and
        buildings.active_worker_ids(stored,restored_hall).size() == 2 and
        not buildings.active_worker_ids(stored,restored_hall).has(a.id) and
        restored_a.current_action == &"CULTIVATE" and
        restored_a.work_group_id == &"" and stored.sect.spirit_stones == 12,
        "Slot transfer/cultivation not saved and restored canonically."):
        return false

    # Player can explicitly change jobs. A rejected bad job never evicts.
    var invalid_work := workforce.issue_command(
        state,b.id,WorkforceSystem.COMMAND_WORK,"illegal_profession",40
    )
    if not _check(not invalid_work and
        DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,b),
        "Invalid job command evicted a trainee."):
        return false
    var changed_work := workforce.issue_command(
        state,b.id,WorkforceSystem.COMMAND_WORK,str(WorkforceSystem.PROF_FORGING),40
    )
    if not _check(changed_work and not
        DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,b) and
        b.work_group_id == &"" and
        str(b.v2_realm_progress.get("training_policy","")) == "manual" and
        buildings.active_worker_ids(state,hall).size() == 1,
        "Explicit production order did not release the Body slot."):
        return false
    return true

func _test_scheduler_training_and_shortage() -> bool:
    var fx := _seed()
    if not _check(not fx.is_empty(),"Cannot construct E3.1 scheduler fixture."):
        return false
    var state: SimulationState = fx["state"]
    var hall: BuildingState = fx["hall"]
    var a: DiscipleState = fx["a"]
    var b: DiscipleState = fx["b"]
    var c: DiscipleState = fx["c"]
    var buildings := BuildingSystem.new()
    var workforce := WorkforceSystem.new()

    # Old personal production preferences must not hijack dedicated training.
    if not _check(workforce.set_work_preference(
        state,a.id,WorkforceSystem.PROF_FORGING,4
    ),"Cannot author preexisting forging preference."):
        return false
    if not _check(_reserve_and_queue(state,a) and _reserve_and_queue(state,b),
        "Two trainees were not legitimately queued."):
        return false
    state.sect.spirit_stones = 6
    for candidate_tick in range(1,21):
        state.tick = candidate_tick
        if workforce.schedule_phase(state,a) == &"work":
            if not _check(workforce.next_action(state,a) == &"TRAIN_BODY",
                "Production phase stole dedicated Body trainee despite old forge priority."):
                return false
            break
        if candidate_tick == 20:
            return _check(false,"No workforce production phase found.")
    # Reset E3.1 direct requests for the actual scheduler sequence.
    state.tick = 0
    a.current_action = &"TRAIN_BODY"
    b.current_action = &"TRAIN_BODY"
    c.current_action = &"HOLD"
    var before_a := float(a.v2_realm_progress["body"]["xp"])
    var before_b := float(b.v2_realm_progress["body"]["xp"])
    var scheduler := SimulationScheduler.new(state)
    for minute in range(1,6):
        scheduler.step()
        if not _check(state.tick == minute and state.sect.spirit_stones ==
            6-2*int(ceil(float(minute)/2.0)),
            "Multi-minute paid consumption diverged from actual active training."):
            return false
    if not _check(state.sect.spirit_stones == 0 and
        int(hall.production_state.get("paid_training_minutes",-1)) == 6 and
        int(hall.production_state.get("spent_spirit_stones",-1)) == 6 and
        float(a.v2_realm_progress["body"]["xp"]) > before_a and
        float(b.v2_realm_progress["body"]["xp"]) > before_b,
        "Two trainees did not commit exactly three authorized minutes each."):
        return false

    var exact_a := float(a.v2_realm_progress["body"]["xp"])
    var exact_b := float(b.v2_realm_progress["body"]["xp"])
    for unused in range(6):
        scheduler.step()
        if not _check(state.sect.spirit_stones == 0 and
            float(a.v2_realm_progress["body"]["xp"]) == exact_a and
            float(b.v2_realm_progress["body"]["xp"]) == exact_b,
            "No-stone training caused negative wallet or unpaid Body EXP."):
            return false
        if not _check(buildings.active_worker_ids(state,hall).size() == 2 and
            a.current_action != &"WORK_FORGING" and
            b.current_action != &"WORK_FORGING",
            "Out-of-stone training fabricated free slots or sent a trainee forging."):
            return false

    var loaded := SimulationState.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
    var loaded_hall := buildings.primary_building(loaded,BuildingSystem.TYPE_BODY_TRAINING)
    if not _check(loaded_hall != null and loaded.sect.spirit_stones == 0 and
        int(loaded_hall.production_state.get("paid_training_minutes",-1)) == 6 and
        buildings.active_worker_ids(loaded,loaded_hall).size() == 2,
        "Paid multi-minute audit and occupied positions were not persisted."):
        return false

    # Urgent healing is not overridden by the training reservation.
    a.hp = a.max_hp * 0.4
    a.current_action = &"EVALUATE"
    if not _check(workforce.next_action(state,a) == &"" and
        DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,a),
        "Reserved trainee could not enter urgent healing path."):
        return false
    return true
