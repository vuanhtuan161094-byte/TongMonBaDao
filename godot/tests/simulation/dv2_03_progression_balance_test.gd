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
    var valid := DiscipleProgressionBalanceV2.validate()
    if not _assert(bool(valid.get("ok",false)),
        "Canonical progression balance failed validation."):
        return

    var costs := DiscipleProgressionBalanceV2.floor_costs()
    if not _assert(costs.size()==300,
        "Canonical progression table must contain exactly 300 floor costs."):
        return

    var expected_r1 := [420,450,480,510,540,600,660,720,780,840]
    var r1_sum := 0
    for floor_index in range(1,11):
        var value := int(costs["1:%d" % floor_index])
        r1_sum += value
        if not _assert(value==int(expected_r1[floor_index-1]),
            "Realm 1 floor cost mismatch at floor %d." % floor_index):
            return
    if not _assert(r1_sum==6000,
        "Realm 1 floor costs do not sum to 6,000."):
        return

    for realm in range(1,31):
        var sum := 0
        var previous := 0
        for floor_index in range(1,11):
            var value := int(costs["%d:%d" % [realm,floor_index]])
            sum += value
            if not _assert(value>=previous,
                "Floor costs must be nondecreasing inside realm %d." % realm):
                return
            previous = value
        if not _assert(sum==DiscipleProgressionBalanceV2.realm_total_xp(realm),
            "Realm %d floor sum does not match realm authority." % realm):
            return

    if not _assert(
        DiscipleProgressionBalanceV2.realm_total_xp(1)==6000 and
        DiscipleProgressionBalanceV2.realm_total_xp(10)==51600 and
        DiscipleProgressionBalanceV2.realm_total_xp(20)==562900 and
        DiscipleProgressionBalanceV2.realm_total_xp(30)==6144100,
        "Selected realm totals changed unexpectedly."):
        return

    if not _assert(
        DiscipleProgressionBalanceV2.cumulative_xp_through_realm(10)==220400 and
        DiscipleProgressionBalanceV2.cumulative_xp_through_realm(20)==2625600 and
        DiscipleProgressionBalanceV2.cumulative_xp_through_realm(30)==28878100,
        "Cumulative progression totals changed unexpectedly."):
        return

    if not _assert(
        _close(DiscipleProgressionBalanceV2.BASE_TUVI_PER_MINUTE,20.0) and
        _close(DiscipleProgressionBalanceV2.CULTIVATE_MULTIPLIER,2.0) and
        _close(DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE,5.0) and
        _close(DiscipleProgressionBalanceV2.BODY_EXPEDITION_REFERENCE_PER_MINUTE,15.0) and
        _close(DiscipleProgressionBalanceV2.BODY_TRAINING_REFERENCE_PER_MINUTE,30.0),
        "Canonical source-rate benchmarks changed unexpectedly."):
        return

    # These are raw baseline benchmarks before foundation stats, buffs, gates,
    # pills, Tinh Nguyên, materials or downtime.
    if not _assert(
        _close(DiscipleProgressionBalanceV2.benchmark_minutes_for_realm(1,20.0),300.0) and
        _close(DiscipleProgressionBalanceV2.benchmark_minutes_for_realm(1,40.0),150.0) and
        _close(DiscipleProgressionBalanceV2.benchmark_minutes_for_realm(1,30.0),200.0),
        "Realm-1 benchmark times changed unexpectedly."):
        return

    var cultivation_rule := DiscipleProgressionBalanceV2.cultivation_rule()
    var body_rule := DiscipleProgressionBalanceV2.body_progression_rule()
    if not _assert(
        int(cultivation_rule["floor_costs"]["30:10"])==
            int(body_rule["floor_costs"]["30:10"]) and
        str(body_rule.get("training_mechanic",""))=="typed_source_contract",
        "Cultivation/Body progression cost authority diverged unexpectedly."):
        return

    print("DV2-03 CANONICAL 300-FLOOR PROGRESSION BALANCE: PASS")
    quit(0)
