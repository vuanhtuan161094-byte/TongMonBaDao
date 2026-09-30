class_name P13Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P12Factory.create_state(seed_value)
    state.p1_relationships_enabled = true

    var relationships := RelationshipSystem.new()
    relationships.seed_initial_network(state)
    return state
