extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _assert(valid: bool, reason: String) -> bool:
    if not valid:
        push_error(reason)
        quit(1)
        return false
    return true

func _costs(realms: Array, price: float) -> Dictionary:
    var values: Dictionary = {}
    for realm_value in realms:
        var realm := int(realm_value)
        for floor_index in range(1,11):
            values["%d:%d" % [realm,floor_index]] = price
    return values

func _track(realm: int, floor_index: int, xp: float) -> Dictionary:
    return {
        "realm":realm,"floor":floor_index,"xp":xp,
        "gate_failures":0,"lifetime_failures":0,
        "auto_breakthrough":false,"breakthrough_history":[],
        "last_training_event_id":""
    }

func _run() -> void:
    var state := P37Factory.create_state(61173)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,state.disciples.size()+1
    )

    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,417
    )
    if not _assert(candidate != null,"Cannot create V2 policy candidate."):
        return
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not _assert(bool(accepted.get("ok",false)),
        "Cannot recruit V2 policy candidate."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    if not _assert(
        DiscipleTrainingPolicyV2.current_policy(disciple)=="balanced",
        "New V2 recruit does not default to balanced training policy."):
        return

    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = {
        "cultivation":{
            "authority_id":"qa-policy-cultivation",
            "action":"CULTIVATE",
            "base_xp_per_action":10.0,
            "floor_costs":_costs([1,2],1000.0),
            "sources":[]
        },
        "body":{
            "authority_id":"qa-policy-body",
            "action":"TRAIN_BODY",
            "base_xp_per_action":10.0,
            "floor_costs":_costs([1,2],1000.0),
            "sources":[]
        }
    }
    disciple.region_id = &"sect"
    disciple.hp = disciple.max_hp
    disciple.inventory.clear()
    disciple.direct_command.clear()
    disciple.work_cycle_state.clear()

    # Recruitment currently starts cultivation in Luyen Khi while Body starts
    # Pham Than, so balanced must train the lower 1..300 track.
    var lower_floor := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    if not _assert(bool(lower_floor.get("ok",false)) and
        str(lower_floor.get("track",""))=="body" and
        str(lower_floor.get("reason",""))=="lower_global_floor",
        "Balanced policy did not prioritize the lower global track."):
        return

    # At equal global floors, balanced compares only authored current-floor
    # progress ratios. No hidden Tu Vi-vs-Body weighting is allowed.
    disciple.v2_realm_progress["cultivation"] = _track(2,3,700.0)
    disciple.v2_realm_progress["body"] = _track(2,3,200.0)
    var lower_ratio := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    if not _assert(bool(lower_ratio.get("ok",false)) and
        str(lower_ratio.get("track",""))=="body" and
        str(lower_ratio.get("reason",""))=="lower_current_floor_progress",
        "Balanced policy did not prioritize the lower current-floor ratio."):
        return

    # Exact ties are deterministic and alternate by simulation tick; they are
    # not random and do not consume the gameplay RNG stream.
    disciple.v2_realm_progress["cultivation"]["xp"] = 500.0
    disciple.v2_realm_progress["body"]["xp"] = 500.0
    state.tick = 100
    var tie_a := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    var tie_again := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    state.tick = 101
    var tie_next := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    if not _assert(bool(tie_a.get("ok",false)) and
        tie_a == tie_again and
        str(tie_a.get("track","")) != str(tie_next.get("track","")) and
        str(tie_a.get("reason",""))=="deterministic_equal_progress_tie",
        "Exact balanced tie was random/non-deterministic or failed to alternate."):
        return

    # Focus means priority, not a hard deadlock. If the preferred track is
    # already full at a major gate, train the other legal track.
    var set_cult := DiscipleTrainingPolicyV2.set_policy(
        state,disciple.id,"cultivation_focus"
    )
    disciple.v2_realm_progress["cultivation"] = _track(2,10,1000.0)
    disciple.v2_realm_progress["body"] = _track(2,3,250.0)
    var fallback_body := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    if not _assert(bool(set_cult.get("ok",false)) and
        str(fallback_body.get("track",""))=="body" and
        str(fallback_body.get("reason",""))=="body_fallback",
        "Cultivation focus idled instead of falling back from a full major gate."):
        return

    var before_policy_xp := disciple.v2_realm_progress.duplicate(true)
    var set_manual := DiscipleTrainingPolicyV2.set_policy(
        state,disciple.id,"manual"
    )
    var manual_choice := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    if not _assert(bool(set_manual.get("ok",false)) and
        not bool(manual_choice.get("ok",true)) and
        str(manual_choice.get("reason",""))=="manual_training_policy" and
        disciple.v2_realm_progress["cultivation"]==before_policy_xp["cultivation"] and
        disciple.v2_realm_progress["body"]==before_policy_xp["body"],
        "Changing training policy granted EXP or manual policy still auto-trained."):
        return

    # Manual disables AI selection only; explicit player one-shot training
    # remains legal and still gives no immediate reward.
    disciple.v2_realm_progress["cultivation"] = _track(2,1,0.0)
    disciple.current_action = &"EVALUATE"
    var explicit_before := disciple.v2_realm_progress.duplicate(true)
    var requested := DiscipleTrainingActionV2.request_training(
        state,disciple.id,"cultivation"
    )
    if not _assert(bool(requested.get("ok",false)) and
        disciple.current_action==&"CULTIVATE" and
        disciple.v2_realm_progress==explicit_before,
        "Manual policy blocked explicit player training or request granted immediate EXP."):
        return

    # Policy persists through ordinary DiscipleState JSON save/load.
    var serialized: Dictionary = JSON.parse_string(
        JSON.stringify(disciple.to_dict())
    )
    var restored := DiscipleState.from_dict(serialized)
    if not _assert(
        DiscipleTrainingPolicyV2.current_policy(restored)=="manual",
        "V2 training policy did not survive save/load."):
        return

    # Autonomous workforce path: policy chooses the action on a cultivate
    # schedule slot, scheduler queues it first and only the NEXT step grants XP.
    DiscipleTrainingPolicyV2.set_policy(state,disciple.id,"body_focus")
    disciple.v2_realm_progress["cultivation"] = _track(2,1,0.0)
    disciple.v2_realm_progress["body"] = _track(2,1,0.0)
    disciple.v2_realm_progress["last_training_tick"] = -1
    disciple.current_action = &"EVALUATE"
    disciple.direct_command.clear()
    disciple.work_cycle_state.clear()
    state.sect.workforce_enabled = true
    var workforce := WorkforceSystem.new()
    var cultivate_tick := -1
    for tick_value in range(1,41):
        state.tick = tick_value
        if workforce.schedule_phase(state,disciple)==&"cultivate":
            cultivate_tick = tick_value
            break
    if not _assert(cultivate_tick > 0,
        "Could not find a workforce cultivate slot for policy test."):
        return
    state.tick = cultivate_tick-1
    var body_before := float(disciple.v2_realm_progress["body"]["xp"])
    var scheduler := SimulationScheduler.new(state)
    scheduler.step()
    if not _assert(disciple.current_action==&"TRAIN_BODY" and
        absf(float(disciple.v2_realm_progress["body"]["xp"])-body_before)<0.000001,
        "Autonomous policy granted EXP during action selection instead of scheduler resolution."):
        return
    scheduler.step()
    if not _assert(disciple.current_action==&"EVALUATE" and
        float(disciple.v2_realm_progress["body"]["xp"])>body_before,
        "Queued autonomous TRAIN_BODY did not commit EXP on its scheduler action."):
        return

    # DecisionSystem without a workforce-owned action uses the same policy.
    state.sect.workforce_enabled = false
    disciple.current_action = &"EVALUATE"
    disciple.hp = disciple.max_hp
    disciple.stamina = 100.0
    DiscipleTrainingPolicyV2.set_policy(state,disciple.id,"cultivation_focus")
    var decision := DecisionSystem.new().evaluate(state,disciple)
    var auto_decision: Dictionary = decision.get("v2_auto_training",{})
    if not _assert(str(decision.get("action",""))=="CULTIVATE" and
        str(decision.get("v2_training_policy",""))=="cultivation_focus" and
        str(auto_decision.get("track",""))=="cultivation",
        "DecisionSystem did not consume the canonical V2 training policy."):
        return

    print("DV2-03D1 AUTONOMOUS TU VI / LUYEN THE POLICY: PASS")
    quit()
