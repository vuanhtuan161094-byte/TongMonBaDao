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

    var expected_r1 := [700000,750000,800000,850000,900000,1000000,1100000,1200000,1300000,1400000]
    var r1_sum := 0
    for floor_index in range(1,11):
        var value := int(costs["1:%d" % floor_index])
        r1_sum += value
        if not _assert(value==int(expected_r1[floor_index-1]),
            "Realm 1 floor cost mismatch at floor %d." % floor_index):
            return
    if not _assert(r1_sum==10000000,
        "Realm 1 floor costs do not sum to 10,000,000."):
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
        DiscipleProgressionBalanceV2.realm_total_xp(1)==10000000 and
        DiscipleProgressionBalanceV2.realm_total_xp(10)==86000000 and
        DiscipleProgressionBalanceV2.realm_total_xp(20)==938200000 and
        DiscipleProgressionBalanceV2.realm_total_xp(30)==10240200000,
        "Selected realm totals changed unexpectedly."):
        return

    if not _assert(
        DiscipleProgressionBalanceV2.cumulative_xp_through_realm(10)==367400000 and
        DiscipleProgressionBalanceV2.cumulative_xp_through_realm(20)==4376300000 and
        DiscipleProgressionBalanceV2.cumulative_xp_through_realm(30)==48130600000,
        "Cumulative progression totals changed unexpectedly."):
        return

    if not _assert(
        _close(DiscipleProgressionBalanceV2.BASE_TUVI_PER_MINUTE,1000.0) and
        _close(DiscipleProgressionBalanceV2.CULTIVATE_MULTIPLIER,2.0) and
        _close(DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE,250.0) and
        _close(DiscipleProgressionBalanceV2.BODY_EXPEDITION_REFERENCE_PER_MINUTE,750.0) and
        _close(DiscipleProgressionBalanceV2.BODY_TRAINING_REFERENCE_PER_MINUTE,1500.0),
        "Canonical source-rate benchmarks changed unexpectedly."):
        return

    # These are raw baseline benchmarks before foundation stats, buffs, gates,
    # pills, Tinh Nguyên, materials or downtime.
    if not _assert(
        _close(DiscipleProgressionBalanceV2.benchmark_minutes_for_realm(1,1000.0),10000.0) and
        _close(DiscipleProgressionBalanceV2.benchmark_minutes_for_realm(1,2000.0),5000.0) and
        _close(DiscipleProgressionBalanceV2.benchmark_minutes_for_realm(1,1500.0),6666.666666666667),
        "Realm-1 benchmark times changed unexpectedly."):
        return

    var canonical_catalogue := DiscipleTrainingContentV2.canonical_catalogue()
    var canonical_built := DiscipleTrainingContentV2.build_rules(canonical_catalogue)
    if not _assert(bool(canonical_built.get("ok",false)) and
        _close(float(canonical_built["rules"]["cultivation"]["base_tuvi_per_minute"]),1000.0) and
        _close(float(canonical_built["rules"]["cultivation"]["cultivate_multiplier"]),2.0) and
        str(canonical_built["rules"]["body"].get("training_mechanic",""))=="typed_source_contract",
        "Canonical balance cannot round-trip through training content registry."):
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
