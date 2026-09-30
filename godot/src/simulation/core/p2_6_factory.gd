class_name P26Factory
extends RefCounted

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P25Factory.create_state(seed)
    EquipmentSystem.new().initialize(state)
    return state
