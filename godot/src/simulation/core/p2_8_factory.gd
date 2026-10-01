class_name P28Factory
extends RefCounted

const INITIAL_RECRUITMENT_TOKENS := 3

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P27Factory.create_state(seed)
    state.sect.disciple_generation_v2_enabled = true
    state.sect.disciple_recruitment_tokens = INITIAL_RECRUITMENT_TOKENS

    # Fresh P2.8 states replace only the waiting legacy candidate pool.
    # Existing disciples remain untouched: V2 never rerolls an already-lived identity.
    state.recruitment_candidates.clear()
    state.recruitment_generation_index = 0
    RecruitmentSystem.new().ensure_candidate_pool(state, RecruitmentSystem.DEFAULT_POOL_SIZE)
    return state
