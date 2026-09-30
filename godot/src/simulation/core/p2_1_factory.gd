class_name P21Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P16Factory.create_state(seed_value)
    CultivationSystem.new().initialize(state)
    return state
