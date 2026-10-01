class_name P210Factory
extends RefCounted

const INITIAL_ROOT_ESSENCE := 12

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P29Factory.create_state(seed)
    state.sect.technique_materials[RootRefinementSystem.MATERIAL_ID] = int(state.sect.technique_materials.get(RootRefinementSystem.MATERIAL_ID, 0)) + INITIAL_ROOT_ESSENCE
    RootRefinementSystem.new().initialize(state)
    return state
