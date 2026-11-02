class_name P37Factory
extends RefCounted

const INITIAL_BUILD_WOOD := 40
const INITIAL_BUILD_ORE := 40

static func create_state(seed: int = 1337) -> SimulationState:
    var state := P212Factory.create_state(seed)
    FoundationSystem.new().enable_open_points(state)
    assert(FoundationSystem.new().enable_d7(state),"P37Factory requires complete deterministic foundation birth provenance.")
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if DiscipleRealmProgressV2.progression_ready(disciple):
            var hp_sync := DiscipleRealmProgressV2.sync_live_hp(disciple)
            assert(bool(hp_sync.get("ok",false)),"P37Factory must derive initial HP from D7 RealmCore stats.")
    state.sect.guidance_recruitment_enabled = true
    state.sect.forge_materials[BuildingSystem.MATERIAL_WOOD] = int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_WOOD, 0)) + INITIAL_BUILD_WOOD
    state.sect.forge_materials[BuildingSystem.MATERIAL_ORE] = int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0)) + INITIAL_BUILD_ORE
    BuildingSystem.new().initialize(state)
    WarehouseSystem.new().initialize(state)
    # New Game only. Existing saves are not passed through P37Factory, so their
    # historic map composition remains unchanged unless the player starts over.
    state.sect.world_layout_version = 2

    var workforce := WorkforceSystem.new()
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        workforce.ensure_p3_7_disciple_profile(state, state.disciples[raw_id])

    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    # New Game only: complete the initial P2.12 candidates with their original
    # immutable profile seeds before LiveGameRuntimeV2 enables V2 admission.
    # No existing save runs through this factory. Never mutate their D7/quality.
    for raw_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if not DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            var envelope := DiscipleBirthProfileV2.create_envelope(candidate)
            assert(not envelope.is_empty(), "C2 New Game candidate missing deterministic birth provenance.")
            candidate.v2_birth_profile = DiscipleBirthRollV2.populate(envelope, candidate)
            assert(DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile),
                "C2 New Game must not expose an un-recruitable birth profile.")
        workforce.ensure_p3_7_candidate_profile(state, candidate)
        DiscipleBirthRollV2.sync_profession_talent(candidate.v2_birth_profile, candidate)

    return state
