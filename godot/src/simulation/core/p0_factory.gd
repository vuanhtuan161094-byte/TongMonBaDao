class_name P0Factory
extends RefCounted

static func create_state(seed_value: int = 1337) -> SimulationState:
    var state := SimulationState.new()
    state.seed = seed_value

    for definition in P0Content.REGIONS:
        var region := RegionState.new(definition)
        state.regions[region.id] = region

    for definition in P0Content.DISCIPLES:
        var disciple := DiscipleState.new(definition)
        state.disciples[disciple.id] = disciple

    state.initial_total_money = state.total_money()
    return state
