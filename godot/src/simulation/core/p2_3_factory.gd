class_name P23Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P22Factory.create_state(seed_value)
    TechniqueSystem.new().initialize(state)
    return state
