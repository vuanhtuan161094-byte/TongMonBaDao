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
            "authority_id":"qa-body-progress-costs-only",
            "training_mechanic":"typed_source_contract",
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

    # Content v3 locks Tu Vi/minute only. Body still carries progression costs
    # but deliberately has NO training rate/action contract.
    var catalogue := {
        "version":3,
        "catalogue_id":"qa-tuvi-minute-body-unresolved",
        "tracks":{
            "cultivation":{
                "authority_id":"qa-all-tuvi",
                "base_tuvi_per_minute":80.0,
                "cultivate_multiplier":2.0,
                "floor_costs":_costs_all(1000.0)
            },
            "body":{
                "authority_id":"qa-body-costs-only",
                "floor_costs":_costs_all(1000.0)
            }
        }
    }
    var catalogue_ok := DiscipleTrainingContentV2.validate_catalogue(catalogue)
    if not _assert(bool(catalogue_ok.get("ok",false)) and
        int(catalogue_ok.get("floors",0))==600,
        "Complete V3 catalogue was rejected."):
        return
    var authored := DiscipleTrainingContentV2.build_rules(catalogue)
    if not _assert(bool(authored.get("ok",false)) and
        _close(float(authored["rules"]["cultivation"]["base_tuvi_per_minute"]),80.0) and
        str(authored["rules"]["body"].get("training_mechanic",""))=="typed_source_contract" and
        not authored["rules"]["body"].has("base_body_xp_per_minute") and
        not authored["rules"]["body"].has("action"),
        "Body training was accidentally authored before design lock."):
        return

    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = _rules()
    var scheduler := SimulationScheduler.new(state)

    # Ordinary activity receives one minute of natural Tu Vi.
    student.region_id = &"sect"
    student.current_action = &"HOLD"
    var tuvi_before := float(student.v2_realm_progress["cultivation"]["xp"])
    scheduler.step()
    if not _assert(state.tick==1 and
        _close(float(student.v2_realm_progress["cultivation"]["xp"])-tuvi_before,100.0),
        "Ordinary activity did not receive 80/min × 1.25 Tu Chat = 100 Tu Vi."):
        return

    # Chuyên Tu accelerates the SAME passive Tu Vi source exactly once.
    student.current_action = &"CULTIVATE"
    var before_special := float(student.v2_realm_progress["cultivation"]["xp"])
    scheduler.step()
    var special_delta := float(student.v2_realm_progress["cultivation"]["xp"])-before_special
    if not _assert(_close(special_delta,200.0),
        "Chuyên Tu did not produce one accelerated passive-minute grant."):
        return
    var direct_cultivate := DiscipleTrainingActionV2.resolve(
        state,student,"CULTIVATE"
    )
    if not _assert(not bool(direct_cultivate.get("ok",true)) and
        str(direct_cultivate.get("reason",""))=="cultivation_resolves_via_passive_time",
        "CULTIVATE still exposes a second direct EXP grant."):
        return

    # Luyện Thể mechanic is deliberately NOT designed yet.
    student.current_action = &"EVALUATE"
    var body_before := float(student.v2_realm_progress["body"]["xp"])
    var body_request := DiscipleTrainingActionV2.request_training(
        state,student.id,"body"
    )
    if not _assert(not bool(body_request.get("ok",true)) and
        str(body_request.get("reason",""))=="body_training_consumer_not_ready" and
        student.current_action==&"EVALUATE" and
        _close(float(student.v2_realm_progress["body"]["xp"]),body_before),
        "Player could queue or gain an unapproved Body training action."):
        return

    # A stale/dev TRAIN_BODY token must fail closed. Passive Tu Vi still occurs
    # because Tu Vi absorption is independent of ordinary current activity.
    student.current_action = &"TRAIN_BODY"
    var body_before_stale := float(student.v2_realm_progress["body"]["xp"])
    var tuvi_before_stale := float(student.v2_realm_progress["cultivation"]["xp"])
    scheduler.step()
    var blocked: Dictionary = student.last_decision.get("v2_body_training_result",{})
    if not _assert(str(blocked.get("reason",""))=="body_training_consumer_not_ready" and
        _close(float(student.v2_realm_progress["body"]["xp"]),body_before_stale) and
        float(student.v2_realm_progress["cultivation"]["xp"])>tuvi_before_stale,
        "Stale TRAIN_BODY granted Body EXP or incorrectly stopped passive Tu Vi."):
        return

    # Generic Body progression math remains available to future authorized
    # sources, but no training source is fabricated here.
    var direct_body := DiscipleRealmProgressV2.grant_xp(
        student,"body",100.0,"fixed",_costs_all(1000.0)
    )
    if not _assert(bool(direct_body.get("ok",false)) and
        _close(float(direct_body.get("gained",0.0)),100.0),
        "Generic future Body-source grant API was broken by the training lock."):
        return

    # Save/load preserves Tu Vi source dedup and unresolved Body content.
    var saved_sect := SectState.from_dict(
        JSON.parse_string(JSON.stringify(state.sect.to_dict()))
    )
    var saved_student := DiscipleState.from_dict(
        JSON.parse_string(JSON.stringify(student.to_dict()))
    )
    if not _assert(saved_sect.v2_training_enabled and
        str(saved_sect.v2_training_rules["body"].get("training_mechanic",""))=="typed_source_contract" and
        int(saved_student.v2_realm_progress.get("last_passive_tuvi_tick",-1))==state.tick,
        "Tu Vi minute authority or unresolved Body state failed save/load."):
        return

    print("DV2-03 TU VI/MINUTE + LUYEN THE TRAINING BLOCK: PASS")
    quit(0)
