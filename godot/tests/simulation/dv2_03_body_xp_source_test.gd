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

func _production_source(rate: float) -> Dictionary:
    return {
        "source_id":"qa-heavy-production",
        "source_kind":"production",
        "base_body_xp_per_minute":rate,
        "floor_costs":_costs_all(100000.0),
        "modifiers":[],
        "active_work_verified":true
    }

func _training_source(rate: float, paid: bool = true) -> Dictionary:
    return {
        "source_id":"qa-dedicated-body-training",
        "source_kind":"body_training",
        "base_body_xp_per_minute":rate,
        "floor_costs":_costs_all(100000.0),
        "modifiers":[],
        "training_access_verified":true,
        "training_cost_committed":paid
    }

func _expedition_source(rate: float) -> Dictionary:
    return {
        "source_id":"qa-expedition-load",
        "source_kind":"expedition",
        "base_body_xp_per_minute":rate,
        "floor_costs":_costs_all(100000.0),
        "modifiers":[],
        "active_expedition_verified":true
    }

func _run() -> void:
    var state := P37Factory.create_state(90231)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,state.disciples.size()+1
    )
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,733
    )
    state.recruitment_candidates[candidate.id] = candidate
    if not _assert(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),"V2 recruitment failed."):
        return

    var disciple: DiscipleState = state.disciples[candidate.id]
    disciple.constitution = 100.0
    disciple.region_id = &"sect"
    disciple.hp = disciple.max_hp

    # Fixture rates are intentionally arbitrary; this test proves source
    # accounting, NOT production balance.
    state.tick = 1
    var before := float(disciple.v2_realm_progress["body"]["xp"])
    var production := DiscipleBodyXpSourceV2.commit_minute(
        state,disciple,_production_source(10.0),"qa:1:production"
    )
    if not _assert(bool(production.get("ok",false)) and
        str(production.get("source_kind",""))=="production" and
        _close(float(production.get("gained",0.0)),12.0) and
        _close(float(disciple.v2_realm_progress["body"]["xp"])-before,12.0),
        "Production Body source did not apply Căn Cốt exactly once."):
        return

    var duplicate := DiscipleBodyXpSourceV2.commit_minute(
        state,disciple,_training_source(30.0),"qa:1:duplicate"
    )
    if not _assert(not bool(duplicate.get("ok",true)) and
        str(duplicate.get("reason",""))=="body_xp_tick_already_awarded",
        "One disciple received two natural Body sources in one minute."):
        return

    state.tick = 2
    var unpaid := DiscipleBodyXpSourceV2.commit_minute(
        state,disciple,_training_source(30.0,false),"qa:2:unpaid"
    )
    if not _assert(not bool(unpaid.get("ok",true)) and
        str(unpaid.get("reason",""))=="body_training_cost_not_committed",
        "Dedicated Rèn Thân granted EXP before its minute cost was committed."):
        return

    var training_before := float(disciple.v2_realm_progress["body"]["xp"])
    var training := DiscipleBodyXpSourceV2.commit_minute(
        state,disciple,_training_source(30.0,true),"qa:2:training"
    )
    if not _assert(bool(training.get("ok",false)) and
        str(training.get("source_kind",""))=="body_training" and
        _close(float(training.get("gained",0.0)),36.0) and
        _close(float(disciple.v2_realm_progress["body"]["xp"])-training_before,36.0),
        "Dedicated Body training source did not commit the verified paid minute."):
        return

    # Expedition is a separate outside-map source and cannot be claimed in sect.
    state.tick = 3
    var wrong_place := DiscipleBodyXpSourceV2.commit_minute(
        state,disciple,_expedition_source(20.0),"qa:3:sect-expedition"
    )
    if not _assert(not bool(wrong_place.get("ok",true)) and
        str(wrong_place.get("reason",""))=="expedition_body_source_requires_outside_map",
        "Expedition Body source was accepted inside the sect."):
        return

    disciple.region_id = &"outer_region"
    var expedition_before := float(disciple.v2_realm_progress["body"]["xp"])
    var expedition := DiscipleBodyXpSourceV2.commit_minute(
        state,disciple,_expedition_source(20.0),"qa:3:expedition"
    )
    if not _assert(bool(expedition.get("ok",false)) and
        str(expedition.get("source_kind",""))=="expedition" and
        _close(float(expedition.get("gained",0.0)),24.0) and
        _close(float(disciple.v2_realm_progress["body"]["xp"])-expedition_before,24.0),
        "Outside-map expedition Body source failed."):
        return

    # Preview is read-only.
    state.tick = 4
    disciple.region_id = &"sect"
    var preview_before := float(disciple.v2_realm_progress["body"]["xp"])
    var preview := DiscipleBodyXpSourceV2.preview_minute(
        state,disciple,_production_source(7.0)
    )
    if not _assert(bool(preview.get("ok",false)) and
        bool(preview.get("preview",false)) and
        _close(float(preview.get("gained",0.0)),8.4) and
        _close(float(disciple.v2_realm_progress["body"]["xp"]),preview_before),
        "Body source preview mutated progression or calculated the wrong gain."):
        return

    # Fixed +X Body EXP stays fixed and bypasses Căn Cốt.
    var fixed := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",100.0,"fixed",_costs_all(100000.0)
    )
    if not _assert(bool(fixed.get("ok",false)) and
        _close(float(fixed.get("gained",0.0)),100.0),
        "Fixed Body EXP was multiplied by Căn Cốt."):
        return

    var bad_kind := _production_source(10.0)
    bad_kind["source_kind"] = "combat_kill"
    if not _assert(not bool(DiscipleBodyXpSourceV2.validate_source(
        bad_kind).get("ok",true)),
        "Unapproved Body source kind passed validation."):
        return

    # Save/load preserves anti-double-credit state.
    var saved := DiscipleState.from_dict(
        JSON.parse_string(JSON.stringify(disciple.to_dict()))
    )
    if not _assert(int(saved.v2_realm_progress.get("last_body_xp_tick",-1))==3,
        "last_body_xp_tick did not survive save/load."):
        return

    print("DV2-03 BODY EXP SOURCE CONTRACT: PASS")
    quit(0)
