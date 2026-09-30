class_name P22Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P21Factory.create_state(seed_value)
    SpiritualRootSystem.new().initialize(state)
    return state
