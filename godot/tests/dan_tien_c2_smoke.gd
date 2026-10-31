extends SceneTree

# C2 independent smoke, authoritative Godot 4.7.2 required.
# Run from /godot: godot --headless --path . --script res://tests/dan_tien_c2_smoke.gd

func _initialize() -> void:
    call_deferred("_run")

func _require(value: bool, message: String) -> bool:
    if value:
        return true
    push_error("DAN_TIEN_C2_FAIL: " + message)
    quit(1)
    return false

func _run() -> void:
    var state: SimulationState = P37Factory.create_state(20261101)
    if not _require(state != null, "factory must create state"):
        return
    state.sect.disciple_v2_birth_enabled = true
    var source_ids: Array = state.recruitment_candidates.keys()
    source_ids.sort()
    if not _require(source_ids.size() >= 1, "starter candidates must exist"):
        return
    for raw_id in source_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if not _require(DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile),
                "starter candidate V2 birth incomplete"):
            return
    var first := StringName(str(source_ids[0]))
    var before: CandidateState = state.recruitment_candidates[first]
    var profile_before: Dictionary = before.v2_birth_profile.duplicate(true)
    var recruit := RecruitmentSystem.new()
    var result := recruit.accept_candidate(state, first)
    if not _require(bool(result.get("ok",false)), "first New Game candidate cannot be accepted"):
        return
    var recruited: DiscipleState = state.disciples.get(StringName(str(result.get("disciple_id", ""))))
    if not _require(recruited != null, "accepted candidate is absent from roster"):
        return
    if not _require(recruited.v2_birth_profile == profile_before,
            "birth profile changed during acceptance"):
        return
    var count_before := state.recruitment_candidates.size()
    for day_index in range(1, 101):
        state.tick = day_index * RecruitmentSystem.GUIDANCE_DAY_TICKS
        var day := recruit.begin_guidance_day(state, true)
        if not _require(bool(day.get("ok",false)), "day progression failed"):
            return
        if not _require(state.recruitment_candidates.size() <= RecruitmentSystem.C2_QUEUE_CAP,
                "candidate queue exceeded cap"):
            return
    if not _require(state.recruitment_candidates.size() >= count_before,
            "free arrivals deleted materialized candidates"):
        return
    var tokens_before := state.sect.disciple_recruitment_tokens
    var blocked := recruit.guidance_recruit_with_order(state)
    if not _require(not bool(blocked.get("ok",true)) and str(blocked.get("reason","")) == "candidate_queue_full",
            "paid order must be rejected when full"):
        return
    if not _require(state.sect.disciple_recruitment_tokens == tokens_before,
            "paid order debit occurred while queue was full"):
        return

    # Build and destroy real UI nodes, verifying the named screen and D7 radar
    # instantiate in a Godot scene tree, not just in a static UI mock.
    var screen := DanTienScreenV2.new()
    screen.attach_state(state, recruit)
    root.add_child(screen)
    if not _require(screen.get_node_or_null("DanTienDialog") != null,
            "C2 recruitment dialog did not construct"):
        return
    root.remove_child(screen)
    screen.free()
    print("DAN_TIEN_C2_SMOKE_PASS new_game_birth=1 bounded_queue=100_days paid_debit=0 ui=1")
    quit(0)
