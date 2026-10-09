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

func _costs_all(price: float) -> Dictionary:
    var values: Dictionary = {}
    for realm in range(1,31):
        for floor_index in range(1,11):
            values["%d:%d" % [realm,floor_index]] = price
    return values

func _rules(price: float = 1000.0) -> Dictionary:
    return {
        "cultivation":{
            "authority_id":"qa-tuvi-per-minute",
            "action":"CULTIVATE",
            "base_tuvi_per_minute":80.0,
            "cultivate_multiplier":2.0,
            "floor_costs":_costs_all(price),
            "sources":[]
        },
        "body":{
            "authority_id":"qa-body-per-minute",
            "action":"TRAIN_BODY",
            "base_body_xp_per_minute":50.0,
            "floor_costs":_costs_all(price),
            "sources":[]
        }
    }

func _run() -> void:
    var state := P37Factory.create_state(7715)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,state.disciples.size()+1
    )
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,207
    )
    if not _assert(candidate != null and
        DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile),
        "Unable to create genuine V2 candidate."):
        return
    state.recruitment_candidates[candidate.id] = candidate
    if not _assert(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),"V2 recruitment failed."):
        return
    var student: DiscipleState = state.disciples[candidate.id]
    student.aptitude = 100.0
    student.constitution = 100.0
    var start := DiscipleRealmProgressV2.current(student)
    if not _assert(int(start["cultivation_global_floor"])==1 and
        int(start["body_global_floor"])==1 and
        _close(float(start["cultivation"]["xp"]),0.0) and
        _close(float(start["body"]["xp"]),0.0),
        "New production V2 recruit must start 1/1 with zero EXP."):
        return

    # New content schema is per simulation minute, not per technical action.
    var catalogue := {
        "version":2,
        "catalogue_id":"qa-minute-authority",
        "tracks":{
            "cultivation":{
                "authority_id":"qa-all-tuvi",
                "base_tuvi_per_minute":80.0,
                "cultivate_multiplier":2.0,
                "floor_costs":_costs_all(1000.0)
            },
            "body":{
                "authority_id":"qa-all-body",
                "base_body_xp_per_minute":50.0,
                "floor_costs":_costs_all(1000.0)
            }
        }
    }
    var catalogue_ok := DiscipleTrainingContentV2.validate_catalogue(catalogue)
    if not _assert(bool(catalogue_ok.get("ok",false)) and
        int(catalogue_ok.get("floors",0))==600,
        "Complete per-minute 600-floor catalogue was rejected."):
        return
    var authored := DiscipleTrainingContentV2.build_rules(catalogue)
    if not _assert(bool(authored.get("ok",false)) and
        _close(float(authored["rules"]["cultivation"]["base_tuvi_per_minute"]),80.0) and
        _close(float(authored["rules"]["body"]["base_body_xp_per_minute"]),50.0),
        "Per-minute content failed to build runtime rules."):
        return
    var old_schema := catalogue.duplicate(true)
    old_schema["tracks"]["cultivation"].erase("base_tuvi_per_minute")
    old_schema["tracks"]["cultivation"]["base_xp_per_action"] = 80.0
    if not _assert(not bool(DiscipleTrainingContentV2.validate_catalogue(
        old_schema).get("ok",true)),
        "Retired per-action Tu Vi schema still passed validation."):
        return

    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = _rules()
    var scheduler := SimulationScheduler.new(state)

    # Ordinary activity still receives one minute of natural Tu Vi.
    student.region_id = &"sect"
    student.current_action = &"HOLD"
    var tuvi_before := float(student.v2_realm_progress["cultivation"]["xp"])
    scheduler.step()
    if not _assert(state.tick==1 and
        _close(float(student.v2_realm_progress["cultivation"]["xp"])-tuvi_before,100.0),
        "Ordinary activity did not receive 80/min × 1.25 Tu Chat = 100 Tu Vi."):
        return
    var passive: Dictionary = student.last_decision.get("v2_passive_tuvi_result",{})
    if not _assert(bool(passive.get("ok",false)) and
        str(passive.get("unit",""))=="tuvi_per_minute" and
        not bool(passive.get("specialized",true)),
        "Passive Tu Vi receipt does not expose per-minute authority."):
        return

    # Chuyên Tu accelerates the SAME passive source; it is not a second grant.
    student.current_action = &"CULTIVATE"
    var before_special := float(student.v2_realm_progress["cultivation"]["xp"])
    scheduler.step()
    var specialized_gain := float(student.v2_realm_progress["cultivation"]["xp"])-before_special
    var cult_receipt: Dictionary = student.last_decision.get("v2_training_result",{})
    if not _assert(_close(specialized_gain,200.0) and
        bool(cult_receipt.get("ok",false)) and
        bool(cult_receipt.get("specialized",false)) and
        _close(float(cult_receipt.get("gained",0.0)),200.0),
        "Chuyên Tu did not apply exactly one accelerated passive-minute grant."):
        return
    var duplicate_passive := DiscipleTuViFlowV2.resolve_minute(
        state,student,true
    )
    if not _assert(not bool(duplicate_passive.get("ok",true)) and
        str(duplicate_passive.get("reason",""))=="passive_tuvi_tick_already_awarded",
        "Same simulation minute could award passive Tu Vi twice."):
        return
    student.current_action = &"CULTIVATE"
    var direct_cultivate := DiscipleTrainingActionV2.resolve(
        state,student,"CULTIVATE"
    )
    if not _assert(not bool(direct_cultivate.get("ok",true)) and
        str(direct_cultivate.get("reason",""))=="cultivation_resolves_via_passive_time",
        "CULTIVATE still owns a second direct EXP grant."):
        return

    # A player request changes only the next action. It never grants instantly.
    student.current_action = &"EVALUATE"
    var body_before_request := float(student.v2_realm_progress["body"]["xp"])
    var tuvi_before_request := float(student.v2_realm_progress["cultivation"]["xp"])
    var requested := DiscipleTrainingActionV2.request_training(
        state,student.id,"body"
    )
    if not _assert(bool(requested.get("ok",false)) and
        student.current_action==&"TRAIN_BODY" and
        _close(float(student.v2_realm_progress["body"]["xp"]),body_before_request) and
        _close(float(student.v2_realm_progress["cultivation"]["xp"]),tuvi_before_request),
        "Body request granted EXP immediately."):
        return

    # One TRAIN_BODY minute legitimately earns both passive Tu Vi and body EXP.
    scheduler.step()
    var body_delta := float(student.v2_realm_progress["body"]["xp"])-body_before_request
    var tuvi_delta := float(student.v2_realm_progress["cultivation"]["xp"])-tuvi_before_request
    if not _assert(_close(body_delta,60.0) and _close(tuvi_delta,100.0),
        "TRAIN_BODY minute must earn passive Tu Vi + explicit Body EXP together."):
        return
    var body_receipt: Dictionary = student.last_decision.get("v2_body_training_result",{})
    if not _assert(bool(body_receipt.get("ok",false)) and
        _close(float(body_receipt.get("gained",0.0)),60.0) and
        _close(float(body_receipt.get("base_body_xp_per_minute",0.0)),50.0),
        "Body per-minute receipt is invalid."):
        return

    # Work has no extra generic Tu Vi source; scheduler passive is the only one.
    state.sect.workforce_enabled = true
    var workforce := WorkforceSystem.new()
    var work_extra := workforce._grant_p3_7_work_cultivation(
        state,student,WorkforceSystem.PROF_MINING
    )
    if not _assert(_close(work_extra,0.0),
        "V2 work still grants a second generic Tu Vi source."):
        return

    # Bad authored rates fail at the command boundary.
    var broken: Dictionary = state.sect.v2_training_rules["body"].duplicate(true)
    broken["base_body_xp_per_minute"] = -1.0
    state.sect.v2_training_rules["body"] = broken
    student.current_action = &"EVALUATE"
    var bad_request := DiscipleTrainingActionV2.request_training(
        state,student.id,"body"
    )
    if not _assert(not bool(bad_request.get("ok",true)) and
        str(bad_request.get("reason",""))=="invalid_training_base_rate",
        "Invalid per-minute Body rate passed preflight."):
        return
    state.sect.v2_training_rules = _rules()

    # Save/load preserves both minute-rate content and independent dedup markers.
    var saved_sect := SectState.from_dict(
        JSON.parse_string(JSON.stringify(state.sect.to_dict()))
    )
    var saved_student := DiscipleState.from_dict(
        JSON.parse_string(JSON.stringify(student.to_dict()))
    )
    if not _assert(saved_sect.v2_training_enabled and
        _close(float(saved_sect.v2_training_rules["cultivation"]["base_tuvi_per_minute"]),80.0) and
        int(saved_student.v2_realm_progress.get("last_passive_tuvi_tick",-1))==state.tick and
        int(saved_student.v2_realm_progress.get("last_training_tick",-1))==state.tick,
        "Per-minute rules or Tu Vi/Body dedup state failed save/load."):
        return

    print("DV2-03 PER-MINUTE PASSIVE TU VI + EXPLICIT BODY TRAINING: PASS")
    quit(0)
