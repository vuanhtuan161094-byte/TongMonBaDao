extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _assert(valid: bool, reason: String) -> bool:
    if not valid:
        push_error(reason)
        quit(1)
        return false
    return true

func _close(a: float, b: float) -> bool:
    return absf(a-b) < 0.00001

func _costs(realm: int, price: float) -> Dictionary:
    var values: Dictionary = {}
    for floor in range(1,11):
        values["%d:%d" % [realm,floor]] = price
    return values

func _run() -> void:
    var state := P37Factory.create_state(7715)
    var baseline_sect: Dictionary = state.sect.to_dict()
    if not _assert(not baseline_sect.has("v2_training_enabled") and
        not baseline_sect.has("v2_training_rules"),
        "Legacy P3.7 save was changed by the disabled V2 training route."):
        return
    state.sect.disciple_v2_birth_enabled = true
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,207)
    if not _assert(candidate != null and
        DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile),
        "Unable to create a genuine V2 disciple for real training actions."):
        return
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    state.recruitment_candidates[candidate.id] = candidate
    if not _assert(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),"Real V2 disciple recruitment failed."):
        return
    var student: DiscipleState = state.disciples[candidate.id]
    student.aptitude = 100.0
    student.constitution = 100.0
    if not _assert(bool(DiscipleRealmProgressV2.initialize(student).get("ok",false)),
        "V2 two-track initial profile cannot be created."):
        return
    var old_p2_xp := student.cultivation_progress
    var before := student.v2_realm_progress.duplicate(true)

    # An unapproved EXP catalog cannot mutate a V2 character.
    var refused := DiscipleTrainingActionV2.resolve(state,student,"CULTIVATE")
    if not _assert(not bool(refused.get("ok",true)) and
        student.v2_realm_progress == before,"V2 EXP was granted without opt-in."):
        return

    state.sect.v2_training_enabled = true
    student.current_action = &"HUNT"
    state.tick = 1
    var wrong_action := DiscipleTrainingActionV2.resolve(state,student,"CULTIVATE")
    if not _assert(not bool(wrong_action.get("ok",true)) and
        str(wrong_action.get("reason",""))=="training_action_not_current",
        "Player gained Tu Vi while performing HUNT rather than CULTIVATE."):
        return
    state.tick = 0
    state.sect.v2_training_rules = {
        "cultivation":{"authority_id":"qa-authored-tuvi-rate",
            "action":"CULTIVATE","base_xp_per_action":80.0,
            "floor_costs":_costs(1,100.0),"sources":[]},
        "body":{"authority_id":"qa-authored-body-rate",
            "action":"TRAIN_BODY","base_xp_per_action":50.0,
            "floor_costs":_costs(1,100.0),"sources":[]}
    }
    # No additional XP when the player merely opens a character panel.
    var read_only := DiscipleRealmProgressV2.current(student)
    if not _assert(read_only["ok"] and student.v2_realm_progress == before,
        "Viewing V2 progression changed the actual XP."):
        return
    var scheduler := SimulationScheduler.new(state)
    student.current_action = &"CULTIVATE"
    scheduler.step()
    if not _assert(state.tick==1 and
        int(student.v2_realm_progress["cultivation"]["floor"])==2 and
        _close(float(student.v2_realm_progress["cultivation"]["xp"]),0.0) and
        int(student.v2_realm_progress["body"]["floor"])==1 and
        _close(student.cultivation_progress,old_p2_xp),
        "Real CULTIVATE action did not earn +100 V2 Tu Vi (or double-granted P2)."):
        return
    var status: Dictionary = student.last_decision.get("v2_training_result",{})
    if not _assert(bool(status.get("ok",false)) and
        _close(float(status.get("gained",0.0)),100.0) and
        int(status.get("floors_earned",-1))==1,
        "V2 cultivate action has no legitimate event receipt."):
        return
    var after_tick := student.v2_realm_progress.duplicate(true)
    student.current_action = &"CULTIVATE"
    var dupe := DiscipleTrainingActionV2.resolve(state,student,"CULTIVATE")
    if not _assert(not bool(dupe.get("ok",true)) and
        str(dupe.get("reason",""))=="training_tick_already_awarded" and
        student.v2_realm_progress==after_tick,
        "Training awarded a second EXP grant for the SAME actor/tick/action."):
        return
    student.current_action = &"TRAIN_BODY"
    var fake_second_action := DiscipleTrainingActionV2.resolve(state,student,"TRAIN_BODY")
    if not _assert(not bool(fake_second_action.get("ok",true)) and
        student.v2_realm_progress==after_tick,
        "Switching action in the same tick illegally farmed both XP tracks."):
        return
    student.current_action = &"EVALUATE"

    var stamina_before := student.stamina
    var hp_before := student.hp
    student.current_action = &"TRAIN_BODY"
    scheduler.step()
    if not _assert(state.tick==2 and
        int(student.v2_realm_progress["body"]["floor"])==1 and
        _close(float(student.v2_realm_progress["body"]["xp"]),60.0) and
        int(student.v2_realm_progress["cultivation"]["floor"])==2 and
        _close(student.stamina,stamina_before) and _close(student.hp,hp_before),
        "TRAIN_BODY did not give +60 real body XP or invented HP/stamina costs."):
        return
    var body_event: Dictionary = student.last_decision.get("v2_body_training_result",{})
    if not _assert(bool(body_event.get("ok",false)) and
        body_event["track"]=="body" and int(body_event["tick"])==2,
        "Body action was not committed under its own independent event identity."):
        return

    # A validated live authored source may affect NATURAL EXP only.
    state.sect.v2_training_rules["body"]["sources"] = [
        {"source_id":"qa-training-place","channel":"body_xp_gain",
        "mode":"percent_add","value":0.20,"enabled":true}
    ]
    student.current_action = &"TRAIN_BODY"
    scheduler.step()
    if not _assert(int(student.v2_realm_progress["body"]["floor"])==2 and
        _close(float(student.v2_realm_progress["body"]["xp"]),30.0),
        "Named body modifier should raise +70 XP; 60+70=>floor 2 with 30 progress."):
        return

    var before_invalid := student.v2_realm_progress.duplicate(true)
    var invalid: Dictionary = state.sect.v2_training_rules["cultivation"].duplicate(true)
    invalid["floor_costs"].erase("1:10")
    state.sect.v2_training_rules["cultivation"] = invalid
    student.current_action = &"CULTIVATE"
    scheduler.step()
    var rejection: Dictionary = student.last_decision.get("v2_training_result",{})
    if not _assert(not bool(rejection.get("ok",true)) and
        student.v2_realm_progress==before_invalid and
        str(rejection.get("reason",""))=="xp_cost_content_not_authorized",
        "Unauthorized missing 300-floor XP content cannot award partial experience."):
        return

    # Save both authored EXP inputs and two independent character tracks.
    var json_state := JSON.stringify(state.sect.to_dict())
    var reloaded_sect := SectState.from_dict(JSON.parse_string(json_state))
    var reloaded_student := DiscipleState.from_dict(
        JSON.parse_string(JSON.stringify(student.to_dict()))
    )
    if not _assert(reloaded_sect.v2_training_enabled and
        reloaded_sect.v2_training_rules.has("body") and
        reloaded_student.v2_realm_progress==student.v2_realm_progress,
        "Actual training policy and V2 character floor/EXP lost on JSON save."):
        return
    if not _assert(str(reloaded_student.v2_realm_progress["body"]["last_training_event_id"])
        == str(student.v2_realm_progress["body"]["last_training_event_id"]),
        "Save/load forgot the last granted event ID and can duplicate XP."):
        return

    print("DV2-03 REAL SCHEDULER CULTIVATE/BODY ACTIONS + 15s TICKS + SAVE/DEDUP: PASS")
    quit(0)
