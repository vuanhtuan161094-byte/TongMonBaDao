extends SceneTree

# DV2-03: production Body XP is earned only in a verified active mining
# minute, not during travel/haul, idle assignment or legacy work.
func _init() -> void:
    call_deferred("_run")

func _require(ok: bool, reason: String) -> bool:
    if not ok:
        push_error(reason)
        quit(1)
        return false
    return true

func _run() -> void:
    var state := P37Factory.create_state(903141)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity, state.disciples.size() + 1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state, DiscipleGeneratorV2.SOURCE_ORDINARY, 709
    )
    state.recruitment_candidates[candidate.id] = candidate
    if not _require(bool(RecruitmentSystem.new().accept_candidate(
        state, candidate.id
    ).get("ok", false)), "Production test could not recruit authentic V2 disciple."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    if not _require(DiscipleRealmProgressV2.owns_v2_progression(disciple),
        "Recruit created a non-V2 disciple."):
        return
    var workforce := WorkforceSystem.new()
    for member in state.disciples.values():
        if member != disciple:
            member.work_group_id = &""
            member.worksite_building_id = &""
    if not _require(workforce.assign_group(state, disciple.id, &"mining_crew"),
        "Failed to assign mining group."):
        return
    var mine := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_MINE)
    if not _require(mine != null and workforce.assign_worksite(state, disciple.id, mine.id),
        "Could not assign real mine slot."):
        return

    var before := float(disciple.v2_realm_progress["body"]["xp"])
    var gain_total := 0.0
    var active_mining_minutes := 0
    var non_mining_minutes := 0
    var saw_completed_cycle := false
    for minute in range(1, 36):
        state.tick = minute
        disciple.current_action = &"WORK_MINING"
        var result := workforce.perform_work(state, disciple, WorkforceSystem.PROF_MINING)
        if not _require(bool(result.get("ok", false)), "Real mine work failed."):
            return
        if str(result.get("phase", "")) == "mining":
            active_mining_minutes += 1
            var award: Dictionary = result.get("body_xp_result", {})
            if not _require(bool(award.get("ok", false)) and
                str(award.get("source_kind", "")) == DiscipleBodyXpSourceV2.SOURCE_PRODUCTION,
                "Active mining minute was not granted genuine Body XP."):
                return
            var expected := DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE * (
                1.0 + 0.0020 * disciple.constitution
            )
            if not _require(absf(float(award.get("gained", -1.0)) - expected) < 0.0001,
                "Mining Body XP differs from canonical rate / Can Cot."):
                return
            gain_total += float(award["gained"])
        else:
            non_mining_minutes += 1
            if not _require(not result.has("body_xp_result"),
                "Travel or hauling incorrectly generated Body XP."):
                return
        if bool(result.get("completed", false)):
            saw_completed_cycle = true

    if not _require(saw_completed_cycle and active_mining_minutes > 0 and non_mining_minutes > 0,
        "Real mine phase transition coverage is incomplete."):
        return
    if not _require(absf(float(disciple.v2_realm_progress["body"]["xp"]) - before - gain_total) < 0.0001,
        "Only active mining minutes should accumulate Body XP."):
        return

    state.tick = 36
    var before_forge := float(disciple.v2_realm_progress["body"]["xp"])
    disciple.current_action = &"WORK_FORGING"
    var forging := workforce.perform_work(state, disciple, WorkforceSystem.PROF_FORGING)
    if not _require(bool(forging.get("ok", false)) and
        absf(float(disciple.v2_realm_progress["body"]["xp"]) - before_forge) < 0.0001,
        "Unapproved forging activity created Body XP."):
        return

    var saved := DiscipleState.from_dict(disciple.to_dict())
    if not _require(int(saved.v2_realm_progress.get("last_body_xp_tick", -1)) ==
        int(disciple.v2_realm_progress.get("last_body_xp_tick", -2)),
        "Body XP source dedup tick was not persisted."):
        return
    print("DV2-03 P3.7 ACTIVE MINING BODY XP INTEGRATION: PASS")
    quit(0)
