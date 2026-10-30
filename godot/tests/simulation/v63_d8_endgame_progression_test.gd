extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("V63_D8_ENDGAME_PROGRESSION_FAIL: " + why)
        quit(1)
        return false
    return true

func _run() -> void:
    var balance := DiscipleProgressionBalanceV2.validate()
    if not _check(bool(balance.get("ok",false)),
        "canonical progression balance authority failed validation"):
        return
    var costs := DiscipleProgressionBalanceV2.floor_costs()
    if not _check(costs.size() == 300 and
        DiscipleRealmProgressV2.global_floor(30,10) == 300 and
        DiscipleRealmProgressV2.global_floor(31,1) == 0,
        "locked 30x10 ladder must expose exactly 300 legal floor coordinates"):
        return
    for realm in range(1,31):
        var sum := 0
        var previous := 0
        for floor_index in range(1,11):
            var key := "%d:%d" % [realm,floor_index]
            var cost := int(costs.get(key,0))
            if not _check(cost > 0,
                "canonical floor cost missing at " + key):
                return
            sum += cost
            if floor_index > 1 and not _check(cost >= previous,
                "canonical floor weighting regressed within " + str(realm)):
                return
            previous = cost
        if not _check(sum == DiscipleProgressionBalanceV2.realm_total_xp(realm),
            "ten canonical floor costs do not sum to authored realm total " + str(realm)):
            return
    var body_content := DiscipleBodyGateContentV2.validate()
    if not _check(bool(body_content.get("ok",false)) and
        DiscipleBodyGateContentV2.GATE_COUNT == 29 and int(body_content.get("count",0)) == 19 and
        not DiscipleBodyGateContentV2.CONTENT_AVAILABLE,
        "Body gate catalogue must remain metadata-only until real content is available"):
        return
    var state := P37Factory.create_state(30102030)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,30102031
    )
    if not _check(candidate != null,
        "could not create a valid V2 owner for the endgame content-gate check"):
        return
    state.recruitment_candidates[candidate.id] = candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),
        "generated V2 identity could not join its owning save"):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    disciple.region_id = &"sect"
    disciple.current_action = &"EVALUATE"
    var body: Dictionary = disciple.v2_realm_progress["body"]
    body["realm"] = 7
    body["floor"] = 10
    body["xp"] = float(costs["7:10"])
    if not _check(bool(DiscipleRealmProgressV2.sync_live_hp(disciple).get("ok",false)),
        "could not normalize isolated body gate fixture"):
        return
    var before_progress := disciple.v2_realm_progress.duplicate(true)
    var before_warehouse := state.sect.warehouse_resources.duplicate(true)
    var gate := DiscipleBodyGateTransactionV2.new()
    var preview := gate.preview_gate(state,disciple.id)
    if not _check(bool(preview.get("ok",false)) and
        not bool(preview.get("can_commit",true)) and
        str(preview.get("reason","")) == "content_unavailable",
        "Body realm 7 must stay blocked by missing approved content, even at floor 10"):
        return
    var committed := gate.commit_gate(state,disciple.id,"d8-body-gate7-block-check")
    if not _check(not bool(committed.get("ok",true)) and
        str(committed.get("reason","")) == "content_unavailable" and
        disciple.v2_realm_progress == before_progress and
        state.sect.warehouse_resources == before_warehouse and
        state.sect.v2_body_gate_receipts.is_empty(),
        "unavailable endgame gate mutated progression, Warehouse, or receipts"):
        return
    print("V63_D8_ENDGAME_PROGRESSION_PASS: canonical_ladder=300_catalog_coordinates; Body_gates_1_to_6_only; realm7_to_30=CONTENT_UNAVAILABLE; no_fabricated_xp_or_recipe")
    quit(0)
