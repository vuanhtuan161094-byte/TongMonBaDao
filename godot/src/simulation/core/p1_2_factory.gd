class_name P12Factory
extends RefCounted

const INITIAL_CAPACITY := 8
const INITIAL_CANDIDATES := 3

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P1Factory.create_state(seed_value)
    state.p1_recruitment_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity, INITIAL_CAPACITY)

    var recruitment := RecruitmentSystem.new()
    recruitment.ensure_candidate_pool(state, INITIAL_CANDIDATES)
    return state
