class_name RecruitmentSystem
extends RefCounted

const DEFAULT_POOL_SIZE := 3

const SURNAMES := ["Lâm", "Trần", "Bạch", "Cố", "Triệu", "Tần", "Mạc", "Tô", "Lý", "Vương", "Đỗ", "Hạ"]
const GIVEN_NAMES := ["An", "Minh", "Phong", "Nguyệt", "Vũ", "Thanh", "Nhi", "Mặc", "Huyền", "Linh", "Trúc", "Thiên"]
const ARCHETYPE_IDS := ["daring", "cautious", "balanced", "frugal_guarded", "reckless", "prudent"]
const ARCHETYPES := {
    "daring": {"risk": 0.80, "spend": 0.50, "survival": 0.35},
    "cautious": {"risk": 0.20, "spend": 0.32, "survival": 0.86},
    "balanced": {"risk": 0.50, "spend": 0.50, "survival": 0.55},
    "frugal_guarded": {"risk": 0.28, "spend": 0.22, "survival": 0.74},
    "reckless": {"risk": 0.92, "spend": 0.58, "survival": 0.22},
    "prudent": {"risk": 0.42, "spend": 0.62, "survival": 0.82}
}

func ensure_candidate_pool(state: SimulationState, target_count: int = DEFAULT_POOL_SIZE) -> void:
    if not state.p1_recruitment_enabled:
        return

    var desired := maxi(target_count, 0)
    while state.recruitment_candidates.size() < desired:
        var candidate := generate_candidate(state)
        if candidate == null:
            return

func generate_candidate(state: SimulationState) -> CandidateState:
    if not state.p1_recruitment_enabled:
        return null

    var generation_index := state.recruitment_generation_index + 1
    var rng := GameRng.new(_candidate_seed(state.seed, generation_index))
    var surname := str(SURNAMES[rng.randi_range(0, SURNAMES.size() - 1)])
    var given_name := str(GIVEN_NAMES[rng.randi_range(0, GIVEN_NAMES.size() - 1)])
    var archetype_id := str(ARCHETYPE_IDS[rng.randi_range(0, ARCHETYPE_IDS.size() - 1)])
    var profile: Dictionary = ARCHETYPES[archetype_id]

    var candidate := CandidateState.new({
        "id": "candidate_%04d" % generation_index,
        "name": "%s %s" % [surname, given_name],
        "combat_power": rng.randf_range(14.0, 24.0),
        "risk_bias": clampf(float(profile["risk"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "spend_bias": clampf(float(profile["spend"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "survival_bias": clampf(float(profile["survival"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "personality_id": archetype_id,
        "generated_index": generation_index
    })

    if state.sect.spiritual_roots_enabled:
        SpiritualRootSystem.new().ensure_candidate_root(state, candidate)

    state.recruitment_generation_index = generation_index
    state.recruitment_candidates[candidate.id] = candidate
    return candidate

func accept_candidate(state: SimulationState, candidate_id: StringName) -> Dictionary:
    if not state.p1_recruitment_enabled:
        return _result(false, "recruitment_disabled")
    if not state.recruitment_candidates.has(candidate_id):
        return _result(false, "candidate_missing")
    if state.disciples.size() >= state.sect.disciple_capacity:
        return _result(false, "capacity_full")
    if state.disciples.has(candidate_id):
        return _result(false, "duplicate_disciple_id")

    var candidate: CandidateState = state.recruitment_candidates[candidate_id]
    var disciple := candidate.to_disciple()
    if state.sect.spiritual_roots_enabled:
        SpiritualRootSystem.new().ensure_disciple_root(state, disciple)
    state.disciples[disciple.id] = disciple
    state.recruitment_candidates.erase(candidate_id)
    state.recruitment_stats["accepted"] = int(state.recruitment_stats.get("accepted", 0)) + 1

    if state.p1_goal_personality_enabled:
        GoalSystem.new().update_goal(state, disciple)
    if state.p1_relationships_enabled:
        RelationshipSystem.new().introduce_new_disciple(state, disciple)

    var result := _result(true, "accepted")
    result["disciple_id"] = str(disciple.id)
    return result

func reject_candidate(state: SimulationState, candidate_id: StringName) -> Dictionary:
    if not state.p1_recruitment_enabled:
        return _result(false, "recruitment_disabled")
    if not state.recruitment_candidates.has(candidate_id):
        return _result(false, "candidate_missing")

    state.recruitment_candidates.erase(candidate_id)
    state.recruitment_stats["rejected"] = int(state.recruitment_stats.get("rejected", 0)) + 1
    return _result(true, "rejected")

func can_accept_more(state: SimulationState) -> bool:
    return state.p1_recruitment_enabled and state.disciples.size() < state.sect.disciple_capacity

func _candidate_seed(base_seed: int, generation_index: int) -> int:
    return base_seed + generation_index * 104729 + 7919

func _result(ok: bool, reason: String) -> Dictionary:
    return {"ok": ok, "reason": reason}
