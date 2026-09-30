class_name P25Factory
extends RefCounted

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P24Factory.create_state(seed)
    CombatSkillSystem.new().initialize(state)
    return state
