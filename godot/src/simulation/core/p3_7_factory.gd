class_name P37Factory
extends RefCounted

const INITIAL_BUILD_WOOD := 40
const INITIAL_BUILD_ORE := 40

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P212Factory.create_state(seed)
    state.sect.forge_materials[BuildingSystem.MATERIAL_WOOD] = int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_WOOD, 0)) + INITIAL_BUILD_WOOD
    state.sect.forge_materials[BuildingSystem.MATERIAL_ORE] = int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0)) + INITIAL_BUILD_ORE
    BuildingSystem.new().initialize(state)
    WarehouseSystem.new().initialize(state)

    var workforce := WorkforceSystem.new()
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        workforce.ensure_p3_7_disciple_profile(state, state.disciples[raw_id])

    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        workforce.ensure_p3_7_candidate_profile(state, state.recruitment_candidates[raw_id])

    return state
