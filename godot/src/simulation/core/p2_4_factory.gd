class_name P24Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P23Factory.create_state(seed_value)
    CultivationPathSystem.new().initialize(state)
    return state
