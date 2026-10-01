class_name P27Factory
extends RefCounted

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P26Factory.create_state(seed)
    WorkforceSystem.new().initialize(state)
    return state
