extends SceneTree

const TEST_SEED := 616161
const CONTINUATION_TICKS := 1200
const SAVE_PATH := "user://p1_2_recruitment_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state_a := P12Factory.create_state(TEST_SEED)
    var state_b := P12Factory.create_state(TEST_SEED)
    var recruitment := RecruitmentSystem.new()

    if not state_a.p1_goal_personality_enabled or not state_a.p1_recruitment_enabled:
        _fail("P1.2 factory did not enable the required P1 systems.")
        return
    if state_a.disciples.size() != 6 or state_a.sect.disciple_capacity != 8:
        _fail("P1.2 initial population/capacity contract failed.")
        return
    if state_a.recruitment_candidates.size() != 3:
        _fail("P1.2 must start with exactly three recruitment candidates.")
        return
    if not _candidate_pools_equivalent(state_a, state_b):
        _fail("Same-seed candidate generation is not deterministic.")
        return

    var initial_ids := _candidate_ids(state_a)
    var first_id: StringName = initial_ids[0]
    var second_id: StringName = initial_ids[1]

    var accept_a := recruitment.accept_candidate(state_a, first_id)
    var accept_b := recruitment.accept_candidate(state_b, first_id)
    if not bool(accept_a.get("ok", false)) or not bool(accept_b.get("ok", false)):
        _fail("Player accept decision failed for a valid candidate.")
        return

    var accepted: DiscipleState = state_a.disciples.get(first_id)
    if accepted == null:
        _fail("Accepted candidate did not become a disciple.")
        return
    if accepted.wallet != 0:
        _fail("Recruitment created money instead of preserving the economy invariant.")
        return
    if accepted.personality_id == &"" or accepted.active_goal == &"":
        _fail("Accepted candidate did not inherit personality/goal behavior.")
        return

    var reject_a := recruitment.reject_candidate(state_a, second_id)
    var reject_b := recruitment.reject_candidate(state_b, second_id)
    if not bool(reject_a.get("ok", false)) or not bool(reject_b.get("ok", false)):
        _fail("Player reject decision failed for a valid candidate.")
        return

    recruitment.ensure_candidate_pool(state_a, 3)
    recruitment.ensure_candidate_pool(state_b, 3)
    if not _candidate_pools_equivalent(state_a, state_b):
        _fail("Candidate replenishment diverged after identical player decisions.")
        return

    var remaining_ids := _candidate_ids(state_a)
    var second_accept_id: StringName = remaining_ids[0]
    if not bool(recruitment.accept_candidate(state_a, second_accept_id).get("ok", false)):
        _fail("Second valid acceptance failed before capacity was full.")
        return
    if not bool(recruitment.accept_candidate(state_b, second_accept_id).get("ok", false)):
        _fail("Deterministic control failed second acceptance.")
        return

    if state_a.disciples.size() != state_a.sect.disciple_capacity:
        _fail("Population did not reach the configured capacity.")
        return

    var blocked_ids := _candidate_ids(state_a)
    if blocked_ids.is_empty():
        _fail("Capacity test requires at least one pending candidate.")
        return
    var blocked := recruitment.accept_candidate(state_a, blocked_ids[0])
    if bool(blocked.get("ok", false)) or str(blocked.get("reason", "")) != "capacity_full":
        _fail("Recruitment did not stop when sect capacity was full.")
        return

    if state_a.total_money() != state_a.initial_total_money:
        _fail("Recruitment changed total money.")
        return

    var stats: Dictionary = state_a.recruitment_stats
    if int(stats.get("accepted", 0)) != 2 or int(stats.get("rejected", 0)) != 1:
        _fail("Recruitment decision history counters are incorrect.")
        return

    var player_accept := P12Factory.create_state(TEST_SEED)
    var player_reject := P12Factory.create_state(TEST_SEED)
    var choice_id: StringName = _candidate_ids(player_accept)[0]
    recruitment.accept_candidate(player_accept, choice_id)
    recruitment.reject_candidate(player_reject, choice_id)
    if player_accept.disciples.has(choice_id) == player_reject.disciples.has(choice_id):
        _fail("Accept/reject player choices did not create different population outcomes.")
        return

    var invariant_errors := state_a.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.2 invariant failure before save: %s" % " | ".join(invariant_errors))
        return

    var service := SaveService.new()
    var save_error := service.save_to_path(state_a, SAVE_PATH)
    if save_error != OK:
        _fail("P1.2 save failed with error %d." % save_error)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("P1.2 save could not be loaded.")
        return
    if not _recruitment_state_equivalent(state_a, loaded):
        _fail("P1.2 recruitment state was not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)

    if not _states_equivalent(state_a, loaded):
        _fail("P1.2 deterministic continuation diverged after save/load.")
        return

    invariant_errors = loaded.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.2 resumed invariant failure: %s" % " | ".join(invariant_errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    print("P1.2 RECRUITMENT + PLAYER CHOICE TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " disciples=", loaded.disciples.size(), " capacity=", loaded.sect.disciple_capacity, " accepted=", loaded.recruitment_stats.get("accepted", 0), " rejected=", loaded.recruitment_stats.get("rejected", 0))
    quit(0)

func _candidate_ids(state: SimulationState) -> Array[StringName]:
    var raw: Array = state.recruitment_candidates.keys()
    raw.sort()
    var result: Array[StringName] = []
    for value in raw:
        result.append(StringName(value))
    return result

func _candidate_pools_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.recruitment_generation_index != b.recruitment_generation_index:
        return false
    if a.recruitment_candidates.size() != b.recruitment_candidates.size():
        return false
    for candidate_id in a.recruitment_candidates.keys():
        var left: CandidateState = a.recruitment_candidates[candidate_id]
        var right: CandidateState = b.recruitment_candidates.get(candidate_id)
        if right == null or not _candidates_equivalent(left, right):
            return false
    return true

func _candidates_equivalent(a: CandidateState, b: CandidateState) -> bool:
    return (
        a.id == b.id
        and a.display_name == b.display_name
        and a.personality_id == b.personality_id
        and a.generated_index == b.generated_index
        and absf(a.combat_power - b.combat_power) <= 0.000000001
        and absf(a.risk_bias - b.risk_bias) <= 0.000000001
        and absf(a.spend_bias - b.spend_bias) <= 0.000000001
        and absf(a.survival_bias - b.survival_bias) <= 0.000000001
    )

func _recruitment_state_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.p1_recruitment_enabled != b.p1_recruitment_enabled:
        return false
    if a.sect.disciple_capacity != b.sect.disciple_capacity:
        return false
    if a.recruitment_generation_index != b.recruitment_generation_index:
        return false
    if a.recruitment_stats != b.recruitment_stats:
        return false
    return _candidate_pools_equivalent(a, b)

func _states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.tick != b.tick or a.seed != b.seed or a.rng_state != b.rng_state:
        return false
    if a.initial_total_money != b.initial_total_money or a.total_money() != b.total_money():
        return false
    if a.p1_goal_personality_enabled != b.p1_goal_personality_enabled:
        return false
    if not _recruitment_state_equivalent(a, b):
        return false
    if a.sect.to_dict() != b.sect.to_dict():
        return false
    if a.disciples.size() != b.disciples.size():
        return false

    for disciple_id in a.disciples.keys():
        var left: DiscipleState = a.disciples[disciple_id]
        var right: DiscipleState = b.disciples.get(disciple_id)
        if right == null:
            return false
        if left.personality_id != right.personality_id or left.active_goal != right.active_goal:
            return false
        if left.goal_changed_tick != right.goal_changed_tick:
            return false
        if left.current_action != right.current_action or left.region_id != right.region_id or left.target_region_id != right.target_region_id:
            return false
        if left.wallet != right.wallet or absf(left.combat_power - right.combat_power) > 0.000000001:
            return false
        if absf(left.hp - right.hp) > 0.000000001 or absf(left.stamina - right.stamina) > 0.000000001:
            return false
        if absf(left.risk_bias - right.risk_bias) > 0.000000001 or absf(left.spend_bias - right.spend_bias) > 0.000000001 or absf(left.survival_bias - right.survival_bias) > 0.000000001:
            return false
        if left.inventory != right.inventory or left.pending_loot != right.pending_loot or left.metrics != right.metrics:
            return false

    return true

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
