class_name P14Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P13Factory.create_state(seed_value)
    state.p1_memory_enabled = true
    return state
