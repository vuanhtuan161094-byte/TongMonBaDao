class_name P1Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P0Factory.create_state(seed_value)
    state.p1_goal_personality_enabled = true

    var goals := GoalSystem.new()
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        goals.update_goal(state, disciple)

    return state
