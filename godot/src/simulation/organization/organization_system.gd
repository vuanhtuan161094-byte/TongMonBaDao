class_name OrganizationSystem
extends RefCounted

const MAX_TEAM_SIZE := 6

# P1.5 roles are combat/adventure behavior roles only. They are NOT sect rank,
# profession, work group, hall position or later administrative authority.
# The legacy storage key remains `role_assignments` for save compatibility.
const ROLE_HUNTER := &"hunter"
const ROLE_LOGISTICS := &"logistics"
const ROLE_GUARD := &"guard"
const VALID_ROLES := [ROLE_HUNTER, ROLE_LOGISTICS, ROLE_GUARD]

func seed_initial_teams(state: SimulationState) -> void:
    if not state.p1_organization_enabled or not state.teams.is_empty():
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        return

    var team_a := create_team(state, &"team_001", "Đội Thanh Trúc")
    var team_b := create_team(state, &"team_002", "Đội Bạch Thạch")

    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var team_id := team_a.id if index % 2 == 0 else team_b.id
        assign_member(state, disciple_id, team_id)

    if not team_a.member_ids.is_empty():
        assign_leader(state, team_a.id, team_a.member_ids[0])
    if not team_b.member_ids.is_empty():
        assign_leader(state, team_b.id, team_b.member_ids[0])

func create_team(state: SimulationState, team_id: StringName, display_name: String) -> TeamState:
    if not state.p1_organization_enabled or team_id == &"":
        return null
    if state.teams.has(str(team_id)):
        return state.teams[str(team_id)]

    var team := TeamState.new({"id": str(team_id), "name": display_name})
    state.teams[str(team_id)] = team
    state.organization_change_count += 1
    return team

func assign_member(state: SimulationState, disciple_id: StringName, team_id: StringName) -> bool:
    if not state.p1_organization_enabled or not state.disciples.has(disciple_id):
        return false
    var team: TeamState = state.teams.get(str(team_id))
    if team == null:
        return false

    var current_team_id := StringName(state.disciple_team_ids.get(str(disciple_id), ""))
    if current_team_id == team_id and team.has_member(disciple_id):
        return true
    if team.member_ids.size() >= MAX_TEAM_SIZE:
        return false

    if current_team_id != &"":
        _remove_member_from_team(state, disciple_id, current_team_id)

    if not team.member_ids.has(disciple_id):
        team.member_ids.append(disciple_id)
    state.disciple_team_ids[str(disciple_id)] = str(team_id)
    state.organization_change_count += 1

    if team.leader_id == &"":
        assign_leader(state, team_id, disciple_id)
    else:
        _ensure_leader_relation(state, disciple_id, team.leader_id)
    return true

func remove_member(state: SimulationState, disciple_id: StringName) -> bool:
    if not state.p1_organization_enabled:
        return false
    var team_id := StringName(state.disciple_team_ids.get(str(disciple_id), ""))
    if team_id == &"":
        return false
    _remove_member_from_team(state, disciple_id, team_id)
    state.role_assignments.erase(str(disciple_id))
    state.organization_change_count += 1
    return true

func assign_leader(state: SimulationState, team_id: StringName, disciple_id: StringName) -> bool:
    if not state.p1_organization_enabled:
        return false
    var team: TeamState = state.teams.get(str(team_id))
    if team == null or not team.has_member(disciple_id):
        return false

    team.leader_id = disciple_id
    for member_id in team.member_ids:
        if member_id != disciple_id:
            _ensure_leader_relation(state, member_id, disciple_id)
    state.organization_change_count += 1
    return true

func assign_combat_role(state: SimulationState, disciple_id: StringName, role_id: StringName) -> bool:
    if not state.p1_organization_enabled or not state.disciples.has(disciple_id):
        return false
    if not VALID_ROLES.has(role_id):
        return false
    state.role_assignments[str(disciple_id)] = str(role_id)
    state.organization_change_count += 1
    return true

# Legacy P1.5 API retained for tests/saves/callers. New systems should use
# combat-role naming so later profession/rank state cannot be confused with it.
func assign_role(state: SimulationState, disciple_id: StringName, role_id: StringName) -> bool:
    return assign_combat_role(state, disciple_id, role_id)

func clear_combat_role(state: SimulationState, disciple_id: StringName) -> void:
    if state.role_assignments.erase(str(disciple_id)):
        state.organization_change_count += 1

func clear_role(state: SimulationState, disciple_id: StringName) -> void:
    clear_combat_role(state, disciple_id)

func team_for_disciple(state: SimulationState, disciple_id: StringName) -> TeamState:
    var team_id := str(state.disciple_team_ids.get(str(disciple_id), ""))
    if team_id == "":
        return null
    return state.teams.get(team_id)

func combat_role_for_disciple(state: SimulationState, disciple_id: StringName) -> StringName:
    return StringName(state.role_assignments.get(str(disciple_id), ""))

func role_for_disciple(state: SimulationState, disciple_id: StringName) -> StringName:
    return combat_role_for_disciple(state, disciple_id)

func apply_action_role_modifiers(state: SimulationState, disciple: DiscipleState, scores: Dictionary) -> void:
    if not state.p1_organization_enabled:
        return

    match combat_role_for_disciple(state, disciple.id):
        ROLE_HUNTER:
            scores["HUNT"] = float(scores.get("HUNT", 0.0)) + 18.0
            scores["REST"] = float(scores.get("REST", 0.0)) - 5.0
        ROLE_LOGISTICS:
            scores["HUNT"] = float(scores.get("HUNT", 0.0)) - 16.0
            scores["BUY"] = float(scores.get("BUY", 0.0)) + 40.0
            scores["SELL"] = float(scores.get("SELL", 0.0)) + 18.0
            scores["REST"] = float(scores.get("REST", 0.0)) + 10.0
        ROLE_GUARD:
            scores["HUNT"] = float(scores.get("HUNT", 0.0)) - 5.0
            scores["HEAL"] = float(scores.get("HEAL", 0.0)) + 10.0
            scores["REST"] = float(scores.get("REST", 0.0)) + 8.0
            scores["BUY"] = float(scores.get("BUY", 0.0)) + 5.0

func region_organization_modifier(state: SimulationState, disciple: DiscipleState, region: RegionState) -> float:
    if not state.p1_organization_enabled:
        return 0.0

    var modifier := _role_region_modifier(state, disciple, region)
    modifier += _leader_region_modifier(state, disciple, region.id)
    modifier += _guard_support_modifier(state, disciple, region.id)
    return clampf(modifier, -40.0, 50.0)

func _role_region_modifier(state: SimulationState, disciple: DiscipleState, region: RegionState) -> float:
    match combat_role_for_disciple(state, disciple.id):
        ROLE_HUNTER:
            return float(region.danger) * 5.0 + region.profit_modifier * 8.0
        ROLE_LOGISTICS:
            return -float(region.danger) * 8.0
        ROLE_GUARD:
            return float(4 - region.danger) * 5.0
        _:
            return 0.0

func _leader_region_modifier(state: SimulationState, disciple: DiscipleState, region_id: StringName) -> float:
    var team := team_for_disciple(state, disciple.id)
    if team == null or team.leader_id == &"" or team.leader_id == disciple.id:
        return 0.0

    var leader: DiscipleState = state.disciples.get(team.leader_id)
    if leader == null:
        return 0.0
    var leader_region := leader.target_region_id if leader.target_region_id != &"" else leader.region_id
    if leader_region != region_id:
        return 0.0

    var trust := 50.0
    var respect := 50.0
    if state.p1_relationships_enabled:
        var relation := RelationshipSystem.new().get_relation(state, disciple.id, leader.id, false)
        if relation != null:
            trust = relation.trust
            respect = relation.respect

    var authority := trust * 0.55 + respect * 0.45
    return 9.0 + (authority - 50.0) * 0.30

func _guard_support_modifier(state: SimulationState, disciple: DiscipleState, region_id: StringName) -> float:
    var team := team_for_disciple(state, disciple.id)
    if team == null:
        return 0.0

    var support := 0.0
    for member_id in team.member_ids:
        if member_id == disciple.id:
            continue
        if combat_role_for_disciple(state, member_id) != ROLE_GUARD:
            continue
        var guard: DiscipleState = state.disciples.get(member_id)
        if guard == null:
            continue
        var guard_region := guard.target_region_id if guard.target_region_id != &"" else guard.region_id
        if guard_region == region_id:
            support += 4.0
    return minf(support, 8.0)

func _remove_member_from_team(state: SimulationState, disciple_id: StringName, team_id: StringName) -> void:
    var team: TeamState = state.teams.get(str(team_id))
    if team == null:
        state.disciple_team_ids.erase(str(disciple_id))
        return

    team.member_ids.erase(disciple_id)
    state.disciple_team_ids.erase(str(disciple_id))
    if team.leader_id == disciple_id:
        team.leader_id = team.member_ids[0] if not team.member_ids.is_empty() else &""
        if team.leader_id != &"":
            for member_id in team.member_ids:
                if member_id != team.leader_id:
                    _ensure_leader_relation(state, member_id, team.leader_id)

func _ensure_leader_relation(state: SimulationState, member_id: StringName, leader_id: StringName) -> void:
    if not state.p1_relationships_enabled or member_id == leader_id:
        return
    RelationshipSystem.new().get_relation(state, member_id, leader_id, true)
