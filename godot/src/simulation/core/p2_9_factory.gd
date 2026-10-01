class_name P29Factory
extends RefCounted

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P28Factory.create_state(seed)
    TraitSystem.new().initialize(state)
    return state
