class_name SimulationState
extends RefCounted

const SAVE_VERSION := 1

var tick: int = 0
var seed: int = 1337
var rng_state: int = 0
var disciples: Dictionary = {}
var regions: Dictionary = {}
var sect: SectState = SectState.new()
var initial_total_money: int = 0

# P1.1 is opt-in so the locked P0 baseline remains behavior-identical.
var p1_goal_personality_enabled: bool = false

# P1.2 is independently opt-in so P0/P1.1 remain stable regression baselines.
var p1_recruitment_enabled: bool = false
var recruitment_candidates: Dictionary = {}
var recruitment_generation_index: int = 0
var recruitment_stats: Dictionary = {
    "accepted": 0,
    "rejected": 0
}

# P1.3 keeps a sparse directed social graph. Keys are source id -> target id.
# Missing edges mean neutral/no meaningful relationship and cost no storage.
var p1_relationships_enabled: bool = false
var relationships: Dictionary = {}
var companion_assignments: Dictionary = {}
var relationship_event_count: int = 0

func total_money() -> int:
    var total := sect.treasury
    for disciple in disciples.values():
        total += disciple.wallet
    return total

func validate_invariants() -> Array[String]:
    var errors: Array[String] = []

    if sect.treasury < 0:
        errors.append("Sect treasury is negative.")
    if sect.disciple_capacity <= 0:
        errors.append("Sect disciple capacity must be positive.")
    if disciples.size() > sect.disciple_capacity:
        errors.append("Sect population exceeds disciple capacity.")

    for disciple in disciples.values():
        if disciple.hp < 0.0 or disciple.hp > disciple.max_hp + 0.001:
            errors.append("%s has invalid HP %.2f/%.2f" % [disciple.display_name, disciple.hp, disciple.max_hp])
        if disciple.stamina < 0.0 or disciple.stamina > 100.001:
            errors.append("%s has invalid stamina %.2f" % [disciple.display_name, disciple.stamina])
        if disciple.wallet < 0:
            errors.append("%s has negative wallet." % disciple.display_name)
        if disciple.region_id != &"sect" and not regions.has(disciple.region_id):
            errors.append("%s references missing region %s" % [disciple.display_name, disciple.region_id])
        for quantity in disciple.inventory.values():
            if int(quantity) < 0:
                errors.append("%s has negative inventory quantity." % disciple.display_name)

    for candidate_value in recruitment_candidates.values():
        var candidate: CandidateState = candidate_value
        if disciples.has(candidate.id):
            errors.append("Recruitment candidate %s duplicates an existing disciple id." % candidate.id)
        if candidate.combat_power <= 0.0:
            errors.append("Recruitment candidate %s has invalid combat power." % candidate.id)
        for bias in [candidate.risk_bias, candidate.spend_bias, candidate.survival_bias]:
            if bias < 0.0 or bias > 1.0:
                errors.append("Recruitment candidate %s has an invalid personality bias." % candidate.id)
                break

    for raw_source_id in relationships.keys():
        var source_id := StringName(raw_source_id)
        if not disciples.has(source_id):
            errors.append("Relationship source %s is not an active disciple." % source_id)
            continue
        var source_map = relationships[raw_source_id]
        if not (source_map is Dictionary):
            errors.append("Relationship source %s has invalid storage." % source_id)
            continue
        for raw_target_id in source_map.keys():
            var target_id := StringName(raw_target_id)
            if source_id == target_id:
                errors.append("Self relationship is not allowed for %s." % source_id)
                continue
            if not disciples.has(target_id):
                errors.append("Relationship target %s is not an active disciple." % target_id)
                continue
            var relation: RelationshipState = source_map[raw_target_id]
            for value in [relation.affinity, relation.trust, relation.respect]:
                if value < 0.0 or value > 100.0:
                    errors.append("Relationship %s -> %s has an out-of-range value." % [source_id, target_id])
                    break

    for raw_source_id in companion_assignments.keys():
        var source_id := StringName(raw_source_id)
        var target_id := StringName(companion_assignments[raw_source_id])
        if source_id == target_id or not disciples.has(source_id) or not disciples.has(target_id):
            errors.append("Invalid companion assignment %s -> %s." % [source_id, target_id])

    if initial_total_money > 0 and total_money() != initial_total_money:
        errors.append("Money conservation failed: expected %d, got %d" % [initial_total_money, total_money()])

    return errors

func to_dict() -> Dictionary:
    var disciple_rows: Array = []
    for disciple in disciples.values():
        disciple_rows.append(disciple.to_dict())

    var region_rows: Array = []
    for region in regions.values():
        region_rows.append(region.to_dict())

    var candidate_rows: Array = []
    var candidate_ids: Array = recruitment_candidates.keys()
    candidate_ids.sort()
    for candidate_id in candidate_ids:
        var candidate: CandidateState = recruitment_candidates[candidate_id]
        candidate_rows.append(candidate.to_dict())

    var relationship_rows: Array = []
    var source_ids: Array = relationships.keys()
    source_ids.sort()
    for raw_source_id in source_ids:
        var source_map: Dictionary = relationships[raw_source_id]
        var target_ids: Array = source_map.keys()
        target_ids.sort()
        for raw_target_id in target_ids:
            var relation: RelationshipState = source_map[raw_target_id]
            relationship_rows.append(relation.to_dict())

    return {
        "save_version": SAVE_VERSION,
        "tick": tick,
        "seed": seed,
        "rng_state": str(rng_state),
        "initial_total_money": initial_total_money,
        "p1_goal_personality_enabled": p1_goal_personality_enabled,
        "p1_recruitment_enabled": p1_recruitment_enabled,
        "recruitment_generation_index": recruitment_generation_index,
        "recruitment_stats": recruitment_stats.duplicate(true),
        "recruitment_candidates": candidate_rows,
        "p1_relationships_enabled": p1_relationships_enabled,
        "relationships": relationship_rows,
        "companion_assignments": companion_assignments.duplicate(true),
        "relationship_event_count": relationship_event_count,
        "sect": sect.to_dict(),
        "disciples": disciple_rows,
        "regions": region_rows
    }

static func from_dict(data: Dictionary) -> SimulationState:
    var state := SimulationState.new()
    state.tick = int(data.get("tick", 0))
    state.seed = int(data.get("seed", 1337))
    state.rng_state = int(data.get("rng_state", 0))
    state.initial_total_money = int(data.get("initial_total_money", 0))
    state.p1_goal_personality_enabled = bool(data.get("p1_goal_personality_enabled", false))
    state.p1_recruitment_enabled = bool(data.get("p1_recruitment_enabled", false))
    state.recruitment_generation_index = int(data.get("recruitment_generation_index", 0))
    state.p1_relationships_enabled = bool(data.get("p1_relationships_enabled", false))
    state.relationship_event_count = int(data.get("relationship_event_count", 0))
    state.sect = SectState.from_dict(data.get("sect", {}))

    var saved_recruitment_stats = data.get("recruitment_stats", {})
    if saved_recruitment_stats is Dictionary:
        state.recruitment_stats["accepted"] = int(saved_recruitment_stats.get("accepted", 0))
        state.recruitment_stats["rejected"] = int(saved_recruitment_stats.get("rejected", 0))

    for row in data.get("regions", []):
        var region := RegionState.from_dict(row)
        state.regions[region.id] = region

    for row in data.get("disciples", []):
        var disciple := DiscipleState.from_dict(row)
        state.disciples[disciple.id] = disciple

    for row in data.get("recruitment_candidates", []):
        if row is Dictionary:
            var candidate := CandidateState.from_dict(row)
            state.recruitment_candidates[candidate.id] = candidate

    for row in data.get("relationships", []):
        if row is Dictionary:
            var relation := RelationshipState.from_dict(row)
            if relation.source_id == &"" or relation.target_id == &"" or relation.source_id == relation.target_id:
                continue
            var source_key := str(relation.source_id)
            var source_map: Dictionary = state.relationships.get(source_key, {})
            source_map[str(relation.target_id)] = relation
            state.relationships[source_key] = source_map

    var saved_companions = data.get("companion_assignments", {})
    if saved_companions is Dictionary:
        var keys: Array = saved_companions.keys()
        keys.sort()
        for key in keys:
            state.companion_assignments[str(key)] = str(saved_companions[key])

    return state
