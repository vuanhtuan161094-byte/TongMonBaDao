class_name P211Factory
extends RefCounted

const INITIAL_YAO_CORES := 8

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P210Factory.create_state(seed)
    state.sect.technique_materials[BloodlineSystem.MATERIAL_ID] = int(state.sect.technique_materials.get(BloodlineSystem.MATERIAL_ID, 0)) + INITIAL_YAO_CORES
    BloodlineSystem.new().initialize(state)
    return state
