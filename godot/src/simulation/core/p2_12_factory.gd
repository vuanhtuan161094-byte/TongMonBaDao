class_name P212Factory
extends RefCounted

const EXTRA_YAO_CORES := 8
const INITIAL_LINH_TUY := 8

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P211Factory.create_state(seed)
    state.sect.technique_materials[PhysiqueSystem.TEMPER_MATERIAL_ID] = int(state.sect.technique_materials.get(PhysiqueSystem.TEMPER_MATERIAL_ID, 0)) + EXTRA_YAO_CORES
    state.sect.technique_materials[PhysiqueSystem.TRANSFORM_MATERIAL_ID] = int(state.sect.technique_materials.get(PhysiqueSystem.TRANSFORM_MATERIAL_ID, 0)) + INITIAL_LINH_TUY
    PhysiqueSystem.new().initialize(state)
    return state
