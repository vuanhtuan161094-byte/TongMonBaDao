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

func _run() -> void:
    var state := P37Factory.create_state(61173)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,state.disciples.size()+1
    )
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,417
    )
    state.recruitment_candidates[candidate.id] = candidate
    if not _assert(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),"Cannot recruit V2 policy candidate."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]

    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = {
        "cultivation":{
            "authority_id":"qa-policy-cultivation",
            "action":"CULTIVATE",
            "base_tuvi_per_minute":10.0,
            "cultivate_multiplier":2.0,
            "floor_costs":_costs([1,2],1000.0),
            "sources":[]
        },
        "body":{
            "authority_id":"qa-body-costs-only",
            "training_mechanic":"unresolved",
            "floor_costs":_costs([1,2],1000.0),
            "sources":[]
        }
    }
    disciple.region_id = &"sect"
    disciple.hp = disciple.max_hp
    disciple.current_action = &"EVALUATE"

    # Balanced currently has only one authorized training action: Chuyên Tu.
    var balanced := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    if not _assert(bool(balanced.get("ok",false)) and
        str(balanced.get("track",""))=="cultivation" and
        str(balanced.get("action",""))=="CULTIVATE" and
        str(balanced.get("reason",""))=="only_trainable_track",
        "Balanced policy treated unresolved Luyện Thể as a trainable action."):
        return

    # Body focus is a preserved enum only; player cannot activate it yet.
    var body_policy := DiscipleTrainingPolicyV2.set_policy(
        state,disciple.id,"body_focus"
    )
    if not _assert(not bool(body_policy.get("ok",true)) and
        str(body_policy.get("reason",""))=="body_training_consumer_not_ready" and
        DiscipleTrainingPolicyV2.current_policy(disciple)=="balanced",
        "body_focus became active before Luyện Thể training was designed."):
        return

    var cultivate_policy := DiscipleTrainingPolicyV2.set_policy(
        state,disciple.id,"cultivation_focus"
    )
    var choice := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    if not _assert(bool(cultivate_policy.get("ok",false)) and
        bool(choice.get("ok",false)) and
        str(choice.get("track",""))=="cultivation",
        "Cultivation focus cannot select approved Chuyên Tu."):
        return

    # Manual blocks autonomous action but still allows explicit Chuyên Tu.
    var set_manual := DiscipleTrainingPolicyV2.set_policy(
        state,disciple.id,"manual"
    )
    var manual_choice := DiscipleTrainingPolicyV2.choose_auto_action(state,disciple)
    var before := disciple.v2_realm_progress.duplicate(true)
    var request := DiscipleTrainingActionV2.request_training(
        state,disciple.id,"cultivation"
    )
    if not _assert(bool(set_manual.get("ok",false)) and
        not bool(manual_choice.get("ok",true)) and
        bool(request.get("ok",false)) and
        disciple.current_action==&"CULTIVATE" and
        disciple.v2_realm_progress==before,
        "Manual mode blocked explicit Chuyên Tu or granted immediate EXP."):
        return

    var serialized: Dictionary = JSON.parse_string(
        JSON.stringify(disciple.to_dict())
    )
    var restored := DiscipleState.from_dict(serialized)
    if not _assert(DiscipleTrainingPolicyV2.current_policy(restored)=="manual",
        "Training policy did not survive save/load."):
        return

    print("DV2-03D1 CULTIVATION POLICY + BODY TRAINING BLOCK: PASS")
    quit(0)
