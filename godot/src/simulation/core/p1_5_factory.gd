class_name P15Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P14Factory.create_state(seed_value)
    state.p1_organization_enabled = true

    var organization := OrganizationSystem.new()
    organization.seed_initial_teams(state)
    return state
