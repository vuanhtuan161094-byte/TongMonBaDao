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

# DV2-03 persistent wall-clock bridge.
# One simulation tick is one simulation minute; elapsed real seconds are
# accumulated here so online/offline use the exact same scheduler.
var runtime_clock_version: int = 1
var runtime_last_wall_unix: int = 0
var runtime_unconsumed_wall_seconds: float = 0.0

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

# P1.4 stores only meaningful, bounded memories per disciple.
# Keys are owner id -> Array[MemoryState]. Missing owners have no stored memories.
var p1_memory_enabled: bool = false
var memories: Dictionary = {}
var memory_event_count: int = 0

# P1.5 adds bounded teams, leadership and player-assigned organizational roles.
# disciple_team_ids provides O(1) team lookup so decisions never scan the whole sect.
var p1_organization_enabled: bool = false
var teams: Dictionary = {}
var disciple_team_ids: Dictionary = {}
var role_assignments: Dictionary = {}
var organization_change_count: int = 0

# P3.7 building authority is opt-in so every locked P0-P2 baseline remains behavior-identical.
var p3_7_buildings_enabled: bool = false
var buildings: Dictionary = {}
var building_event_count: int = 0

func total_money() -> int:
    var total := sect.treasury
    for disciple in disciples.values():
        total += disciple.wallet
    return total

func validate_invariants() -> Array[String]:
    var errors: Array[String] = []
    var care_error := B3MedicalAutoplayV1.validate(self)
    if not care_error.is_empty(): errors.append(care_error)
    if sect.v63_archive_opt_in or not sect.v63_archived_codices.is_empty() or not sect.v63_archive_research_progress.is_empty() or not sect.v63_archive_operation_receipts.is_empty() or not sect.v63_codex_drop_receipts.is_empty():
        errors.append_array(V63SectArchiveSystem.validate_state(self))

    if sect.treasury < 0:
        errors.append("Sect treasury is negative.")
    if sect.disciple_capacity <= 0:
        errors.append("Sect disciple capacity must be positive.")
    if disciples.size() > sect.disciple_capacity:
        errors.append("Sect population exceeds disciple capacity.")

    for disciple in disciples.values():
        if disciple.injury_level < 0 or disciple.injury_level > 1:
            errors.append("%s has invalid Injury level." % disciple.display_name)
        if disciple.injury_level == 0 and disciple.injury_recover_at_tick != 0:
            errors.append("%s has stale Injury recovery tick." % disciple.display_name)
        if disciple.injury_level == 1 and (disciple.injury_recover_at_tick <= 0 or disciple.region_id != &"sect"):
            errors.append("%s has invalid Injury recovery owner/tick." % disciple.display_name)
        if not disciple.active_pve_encounter_id.is_empty() and not sect.v2_pve_active_runs.has(disciple.active_pve_encounter_id) and not B3HuntWorld.owns_reservation(self,disciple):
            errors.append("%s has missing active PvE reservation snapshot." % disciple.display_name)
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

    for raw_owner_id in memories.keys():
        var owner_id := StringName(raw_owner_id)
        if not disciples.has(owner_id):
            errors.append("Memory owner %s is not an active disciple." % owner_id)
            continue
        var owner_memories = memories[raw_owner_id]
        if not (owner_memories is Array):
            errors.append("Memory owner %s has invalid storage." % owner_id)
            continue
        if owner_memories.size() > MemorySystem.MAX_MEMORIES_PER_DISCIPLE:
            errors.append("Memory owner %s exceeds the memory cap." % owner_id)
        for value in owner_memories:
            var memory: MemoryState = value
            if memory.owner_id != owner_id:
                errors.append("Memory %s has mismatched owner." % memory.id)
            if memory.target_id != &"" and not disciples.has(memory.target_id):
                errors.append("Memory %s references missing target %s." % [memory.id, memory.target_id])
            if memory.region_id != &"" and not regions.has(memory.region_id):
                errors.append("Memory %s references missing region %s." % [memory.id, memory.region_id])
            if memory.valence < -1.0 or memory.valence > 1.0:
                errors.append("Memory %s has invalid valence." % memory.id)
            if memory.importance < 0.0 or memory.importance > 100.0:
                errors.append("Memory %s has invalid importance." % memory.id)
            if memory.occurrences <= 0:
                errors.append("Memory %s has invalid occurrence count." % memory.id)

    var seen_team_members: Dictionary = {}
    for raw_team_id in teams.keys():
        var team: TeamState = teams[raw_team_id]
        if team.id == &"":
            errors.append("Organization contains a team with an empty id.")
            continue
        if team.member_ids.size() > OrganizationSystem.MAX_TEAM_SIZE:
            errors.append("Team %s exceeds the member cap." % team.id)
        if team.leader_id != &"" and not team.member_ids.has(team.leader_id):
            errors.append("Team %s leader is not a team member." % team.id)
        for member_id in team.member_ids:
            if not disciples.has(member_id):
                errors.append("Team %s references missing disciple %s." % [team.id, member_id])
                continue
            if seen_team_members.has(str(member_id)):
                errors.append("Disciple %s belongs to multiple teams." % member_id)
            seen_team_members[str(member_id)] = str(team.id)
            if str(disciple_team_ids.get(str(member_id), "")) != str(team.id):
                errors.append("Disciple %s team lookup is inconsistent." % member_id)

    for raw_disciple_id in disciple_team_ids.keys():
        var disciple_id := StringName(raw_disciple_id)
        var team_id := str(disciple_team_ids[raw_disciple_id])
        if not disciples.has(disciple_id):
            errors.append("Team lookup references missing disciple %s." % disciple_id)
            continue
        var team: TeamState = teams.get(team_id)
        if team == null or not team.member_ids.has(disciple_id):
            errors.append("Team lookup %s -> %s is inconsistent." % [disciple_id, team_id])

    for raw_disciple_id in role_assignments.keys():
        var disciple_id := StringName(raw_disciple_id)
        var role_id := StringName(role_assignments[raw_disciple_id])
        if not disciples.has(disciple_id):
            errors.append("Role assignment references missing disciple %s." % disciple_id)
        elif not OrganizationSystem.VALID_ROLES.has(role_id):
            errors.append("Disciple %s has invalid role %s." % [disciple_id, role_id])

    if initial_total_money > 0 and total_money() != initial_total_money:
        errors.append("Money conservation failed: expected %d, got %d" % [initial_total_money, total_money()])
    if runtime_clock_version < 1:
        errors.append("Runtime clock version is invalid.")
    if runtime_last_wall_unix < 0:
        errors.append("Runtime last wall timestamp is negative.")
    if is_nan(runtime_unconsumed_wall_seconds) or is_inf(runtime_unconsumed_wall_seconds) or runtime_unconsumed_wall_seconds < 0.0:
        errors.append("Runtime unconsumed wall seconds are invalid.")

    # Keep state invariant validation independent of the economy service class
    # so GDScript class parsing does not create a SimulationState cycle.
    if sect.economy_a_enabled:
        if not sect.p3_7_resources_enabled or not p3_7_buildings_enabled:
            errors.append("Economy-A requires canonical Warehouse and buildings.")
        if sect.spirit_stones < 0 or sect.economy_a_market_units_sold < 0:
            errors.append("Economy-A invalid Sect balance or market quota.")
        for economy_actor in disciples.values():
            if (economy_actor as DiscipleState).spirit_stones < 0:
                errors.append("Economy-A negative disciple Stone balance.")
    var b3_error := B3HuntWorld.validate(self)
    if not b3_error.is_empty():
        errors.append(b3_error)
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

    var memory_rows: Array = []
    var memory_owner_ids: Array = memories.keys()
    memory_owner_ids.sort()
    for raw_owner_id in memory_owner_ids:
        var owner_memories: Array = memories[raw_owner_id]
        var ordered_memories: Array = owner_memories.duplicate()
        ordered_memories.sort_custom(func(left: MemoryState, right: MemoryState) -> bool: return str(left.id) < str(right.id))
        for value in ordered_memories:
            var memory: MemoryState = value
            memory_rows.append(memory.to_dict())

    var team_rows: Array = []
    var team_ids: Array = teams.keys()
    team_ids.sort()
    for team_id in team_ids:
        var team: TeamState = teams[team_id]
        team_rows.append(team.to_dict())

    var building_rows: Array = []
    var building_ids: Array = buildings.keys()
    building_ids.sort()
    for building_id in building_ids:
        var building: BuildingState = buildings[building_id]
        building_rows.append(building.to_dict())

    var data := {
        "save_version": SAVE_VERSION,
        "tick": tick,
        "seed": seed,
        "rng_state": str(rng_state),
        "initial_total_money": initial_total_money,
        "runtime_clock_version": runtime_clock_version,
        "runtime_last_wall_unix": runtime_last_wall_unix,
        "runtime_unconsumed_wall_seconds": runtime_unconsumed_wall_seconds,
        "p1_goal_personality_enabled": p1_goal_personality_enabled,
        "p1_recruitment_enabled": p1_recruitment_enabled,
        "recruitment_generation_index": recruitment_generation_index,
        "recruitment_stats": recruitment_stats.duplicate(true),
        "recruitment_candidates": candidate_rows,
        "p1_relationships_enabled": p1_relationships_enabled,
        "relationships": relationship_rows,
        "companion_assignments": companion_assignments.duplicate(true),
        "relationship_event_count": relationship_event_count,
        "p1_memory_enabled": p1_memory_enabled,
        "memories": memory_rows,
        "memory_event_count": memory_event_count,
        "p1_organization_enabled": p1_organization_enabled,
        "teams": team_rows,
        "disciple_team_ids": disciple_team_ids.duplicate(true),
        "role_assignments": role_assignments.duplicate(true),
        "organization_change_count": organization_change_count,
        "sect": sect.to_dict(),
        "disciples": disciple_rows,
        "regions": region_rows
    }
    if p3_7_buildings_enabled or building_event_count > 0 or not buildings.is_empty():
        data["p3_7_buildings_enabled"] = p3_7_buildings_enabled
        data["buildings"] = building_rows
        data["building_event_count"] = building_event_count
    return data

static func from_dict(data: Dictionary) -> SimulationState:
    var state := SimulationState.new()
    state.tick = int(data.get("tick", 0))
    state.seed = int(data.get("seed", 1337))
    state.rng_state = int(data.get("rng_state", 0))
    state.initial_total_money = int(data.get("initial_total_money", 0))
    state.runtime_clock_version = maxi(int(data.get("runtime_clock_version", 1)), 1)
    state.runtime_last_wall_unix = maxi(int(data.get("runtime_last_wall_unix", 0)), 0)
    var raw_runtime_remainder = data.get("runtime_unconsumed_wall_seconds", 0.0)
    state.runtime_unconsumed_wall_seconds = maxf(float(raw_runtime_remainder), 0.0)
    state.p1_goal_personality_enabled = bool(data.get("p1_goal_personality_enabled", false))
    state.p1_recruitment_enabled = bool(data.get("p1_recruitment_enabled", false))
    state.recruitment_generation_index = int(data.get("recruitment_generation_index", 0))
    state.p1_relationships_enabled = bool(data.get("p1_relationships_enabled", false))
    state.relationship_event_count = int(data.get("relationship_event_count", 0))
    state.p1_memory_enabled = bool(data.get("p1_memory_enabled", false))
    state.memory_event_count = int(data.get("memory_event_count", 0))
    state.p1_organization_enabled = bool(data.get("p1_organization_enabled", false))
    state.organization_change_count = int(data.get("organization_change_count", 0))
    state.p3_7_buildings_enabled = bool(data.get("p3_7_buildings_enabled", false))
    state.building_event_count = maxi(int(data.get("building_event_count", 0)), 0)
    if not (data.get("sect",{}).get("b3_hunt",{}) is Dictionary):
        return null
    state.sect = SectState.from_dict(data.get("sect", {}))

    var saved_recruitment_stats = data.get("recruitment_stats", {})
    if saved_recruitment_stats is Dictionary:
        state.recruitment_stats["accepted"] = int(saved_recruitment_stats.get("accepted", 0))
        state.recruitment_stats["rejected"] = int(saved_recruitment_stats.get("rejected", 0))

    for row in data.get("regions", []):
        var region := RegionState.from_dict(row)
        state.regions[region.id] = region

    for row in data.get("disciples", []):
        if not (row.get("b3_pill_state",{}) is Dictionary): return null
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

    for row in data.get("memories", []):
        if row is Dictionary:
            var memory := MemoryState.from_dict(row)
            if memory.owner_id == &"" or memory.event_id == &"":
                continue
            var owner_key := str(memory.owner_id)
            var owner_memories: Array = state.memories.get(owner_key, [])
            owner_memories.append(memory)
            state.memories[owner_key] = owner_memories

    for row in data.get("teams", []):
        if row is Dictionary:
            var team := TeamState.from_dict(row)
            if team.id != &"":
                state.teams[str(team.id)] = team

    var saved_team_ids = data.get("disciple_team_ids", {})
    if saved_team_ids is Dictionary:
        var keys: Array = saved_team_ids.keys()
        keys.sort()
        for key in keys:
            state.disciple_team_ids[str(key)] = str(saved_team_ids[key])

    var saved_roles = data.get("role_assignments", {})
    if saved_roles is Dictionary:
        var role_keys: Array = saved_roles.keys()
        role_keys.sort()
        for key in role_keys:
            state.role_assignments[str(key)] = str(saved_roles[key])

    for row in data.get("buildings", []):
        if row is Dictionary:
            var building: BuildingState = BuildingState.from_dict(row)
            if building.id != &"":
                state.buildings[str(building.id)] = building

    var care_error := B3MedicalAutoplayV1.validate(state)
    if not care_error.is_empty():
        push_error("B3 CARE: incompatible save: "+care_error)
        return null
    # Reconstruct GP-02C1 PvE reservation BEFORE SimulationRuntimeOwnerV2
    # advances any offline minutes. Reject contested snapshots fail-closed.
    var legacy_pve := HuntingPveRunV2.reconcile_loaded_v2_pve(state)
    if not bool(legacy_pve.get("ok",false)):
        push_error("GP-02C1: incompatible saved PvE: %s" % str(legacy_pve.get("reason","unknown")))
        return null
    var b3_error := B3HuntWorld.validate(state)
    if not b3_error.is_empty():
        push_error("B3: incompatible saved world: "+b3_error)
        return null
    return state

