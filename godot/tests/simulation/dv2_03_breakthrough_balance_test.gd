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

func _run() -> void:
    var valid := DiscipleBreakthroughBalanceV2.validate()
    if not _assert(bool(valid.get("ok",false)),
        "Canonical breakthrough balance failed validation."):
        return

    if not _assert(
        DiscipleBreakthroughBalanceV2.CULTIVATION_BASE_CHANCE_PERCENT.size()==29 and
        DiscipleBreakthroughBalanceV2.cultivation_base_chance_percent(1)==25 and
        DiscipleBreakthroughBalanceV2.cultivation_base_chance_percent(10)==25 and
        DiscipleBreakthroughBalanceV2.cultivation_base_chance_percent(11)==25 and
        DiscipleBreakthroughBalanceV2.cultivation_base_chance_percent(20)==25 and
        DiscipleBreakthroughBalanceV2.cultivation_base_chance_percent(21)==25 and
        DiscipleBreakthroughBalanceV2.cultivation_base_chance_percent(29)==25,
        "Selected canonical Tu Vi gate chances changed unexpectedly."):
        return

    for realm in range(1,30):
        if not _assert(
            DiscipleBreakthroughBalanceV2.cultivation_base_chance(realm)>=0.0 and
            DiscipleBreakthroughBalanceV2.body_gate_is_deterministic(realm),
            "One of the 29 major gates is missing canonical authority."):
            return
    if not _assert(
        DiscipleBreakthroughBalanceV2.cultivation_base_chance(30)<0.0 and
        not DiscipleBreakthroughBalanceV2.body_gate_is_deterministic(30),
        "Realm 30 incorrectly exposes a next-realm gate."):
        return

    var state := P37Factory.create_state(99117)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,state.disciples.size()+1
    )
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,811
    )
    state.recruitment_candidates[candidate.id] = candidate
    if not _assert(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),"Cannot recruit V2 gate fixture."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    var costs := DiscipleProgressionBalanceV2.floor_costs()

    # Realm 1 uses the current B1 base chance of 25%; the deterministic RNG
    # may legitimately succeed or fail. Verify either branch without inventing
    # a guaranteed breakthrough.
    disciple.v2_realm_progress["cultivation"]["realm"] = 1
    disciple.v2_realm_progress["cultivation"]["floor"] = 10
    disciple.v2_realm_progress["cultivation"]["xp"] = float(costs["1:10"])
    disciple.v2_realm_progress["cultivation"]["gate_failures"] = 0
    var cult := DiscipleRealmProgressV2.attempt_canonical_cultivation_breakthrough(
        disciple,GameRng.new(191),true,"qa-canonical-cult-1"
    )
    var succeeded := bool(cult.get("success",false))
    if not _assert(bool(cult.get("ok",false)) and
        _close(float(cult.get("chance",0.0)),0.25) and
        int(cult.get("realm",0)) == (2 if succeeded else 1) and
        int(cult.get("same_gate_failures",-1)) == (0 if succeeded else 1) and
        int(cult.get("floor",0)) == (1 if succeeded else 10),
        "Canonical realm-1 Tu Vi gate did not apply the 25% base chance and real success/failure branch."):
        return

    # At realm 10 the wrapper must expose 25% before pity, regardless
    # of whether this deterministic QA RNG happens to pass or fail.
    disciple.v2_realm_progress["cultivation"]["realm"] = 10
    disciple.v2_realm_progress["cultivation"]["floor"] = 10
    disciple.v2_realm_progress["cultivation"]["xp"] = float(costs["10:10"])
    disciple.v2_realm_progress["cultivation"]["gate_failures"] = 0
    var cross_tier := DiscipleRealmProgressV2.attempt_canonical_cultivation_breakthrough(
        disciple,GameRng.new(711),true,"qa-canonical-cult-10"
    )
    if not _assert(bool(cross_tier.get("ok",false)) and
        _close(float(cross_tier.get("chance",-1.0)),0.25),
        "Realm 10->11 did not consume canonical 25% base chance."):
        return

    # Body gate is 100% deterministic once requirements are externally verified.
    disciple.v2_realm_progress["body"]["realm"] = 1
    disciple.v2_realm_progress["body"]["floor"] = 10
    disciple.v2_realm_progress["body"]["xp"] = float(costs["1:10"])
    var denied := DiscipleRealmProgressV2.commit_canonical_body_gate(
        disciple,false,"qa-body-denied"
    )
    if not _assert(not bool(denied.get("ok",true)),
        "Canonical Body gate ignored missing Thối Thể requirements."):
        return
    var body := DiscipleRealmProgressV2.commit_canonical_body_gate(
        disciple,true,"qa-body-1"
    )
    if not _assert(bool(body.get("ok",false)) and
        int(body.get("realm",0))==2 and
        int(disciple.v2_realm_progress["body"]["gate_failures"])==0,
        "Canonical Body gate was not deterministic after requirements."):
        return

    print("DV2-03 CANONICAL 29-GATE BREAKTHROUGH BALANCE: PASS")
    quit(0)
