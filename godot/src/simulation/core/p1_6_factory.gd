class_name P16Factory
extends RefCounted

const INITIAL_MEDICINE := 18
const INITIAL_SUPPLIES := 24
const INITIAL_LODGING := 6

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := P15Factory.create_state(seed_value)
    var needs := NeedsSystem.new()
    needs.initialize(state, INITIAL_MEDICINE, INITIAL_SUPPLIES, INITIAL_LODGING)

    var organization := OrganizationSystem.new()
    var logistics_id: StringName = &"lam_an" if state.disciples.has(&"lam_an") else &""
    if logistics_id == &"":
        var ids: Array = state.disciples.keys()
        ids.sort()
        if not ids.is_empty():
            logistics_id = StringName(ids[0])
    if logistics_id != &"":
        organization.assign_role(state, logistics_id, OrganizationSystem.ROLE_LOGISTICS)
    return state
