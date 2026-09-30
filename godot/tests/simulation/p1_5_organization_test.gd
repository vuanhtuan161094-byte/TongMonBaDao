extends SceneTree

const TEST_SEED := 919191
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p1_5_organization_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var organization := OrganizationSystem.new()
    var state_a := P15Factory.create_state(TEST_SEED)
    var state_b := P15Factory.create_state(TEST_SEED)

    if not state_a.p1_goal_personality_enabled or not state_a.p1_recruitment_enabled or not state_a.p1_relationships_enabled or not state_a.p1_memory_enabled or not state_a.p1_organization_enabled:
        _fail("P1.5 factory did not enable the required P1 systems.")
        return
    if not _organization_states_equivalent(state_a, state_b):
        _fail("Same-seed P1.5 organization setup diverged.")
        return
    if state_a.teams.size() != 2:
        _fail("P1.5 initial organization must create exactly two teams.")
        return
    for team_value in state_a.teams.values():
        var team: TeamState = team_value
        if team.member_ids.size() > OrganizationSystem.MAX_TEAM_SIZE:
            _fail("P1.5 seeded a team above the configured size cap.")
            return

    if not _verify_leader_and_relationship_impact():
        return
    if not _verify_memory_can_counter_leader():
        return
    if not _verify_role_impacts():
        return
    if not _verify_player_move_and_recruitment():
        return

    var ids: Array = state_a.disciples.keys()
    ids.sort()
    var role_id := StringName(ids[0])
    organization.assign_role(state_a, role_id, OrganizationSystem.ROLE_HUNTER)
    organization.assign_role(state_b, role_id, OrganizationSystem.ROLE_HUNTER)

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)

    if not _states_equivalent(state_a, state_b):
        _fail("P1.5 same-seed deterministic simulation diverged.")
        return

    var invariant_errors := state_a.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.5 invariant failure: %s" % " | ".join(invariant_errors))
        return

    var service := SaveService.new()
    var save_error := service.save_to_path(state_a, SAVE_PATH)
    if save_error != OK:
        _fail("P1.5 save failed with error %d." % save_error)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("P1.5 save could not be loaded.")
        return
    if not loaded.p1_organization_enabled:
        _fail("P1.5 organization feature flag was not preserved by save/load.")
        return
    if not _organization_states_equivalent(state_a, loaded):
        _fail("P1.5 teams/leaders/roles were not preserved by save/load.")
        return
    if state_a.to_dict() != loaded.to_dict():
        _fail("P1.5 canonical persisted state was not preserved immediately after save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)

    # Save/load determinism is defined by the canonical persisted simulation
    # state. This avoids false negatives caused by runtime-only Dictionary key
    # representation while checking every field that can survive a save.
    if state_a.to_dict() != loaded.to_dict():
        _fail("P1.5 canonical persisted state diverged after save/load continuation.")
        return

    invariant_errors = loaded.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.5 resumed invariant failure: %s" % " | ".join(invariant_errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    print("P1.5 ORGANIZATION + PLAYER MANAGEMENT TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " disciples=", loaded.disciples.size(), " teams=", loaded.teams.size(), " roles=", loaded.role_assignments.size(), " org_changes=", loaded.organization_change_count)
    quit(0)

func _verify_leader_and_relationship_impact() -> bool:
    var state := P15Factory.create_state(TEST_SEED + 1)
    var organization := OrganizationSystem.new()
    var relationships := RelationshipSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    var safe_leader: DiscipleState = state.disciples.get(&"tran_mac")
    var medium_leader: DiscipleState = state.disciples.get(&"lam_an")

    state.teams = {}
    state.disciple_team_ids = {}
    state.role_assignments = {}
    state.memories = {}
    state.companion_assignments = {}
    state.relationships = {}

    actor.combat_power = 16.0
    actor.risk_bias = 0.35
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.region_id = &"sect"
    actor.target_region_id = &""
    safe_leader.region_id = &"thanh_truc_lam"
    safe_leader.target_region_id = &""
    medium_leader.region_id = &"bach_thach_khe"
    medium_leader.target_region_id = &""

    var team := organization.create_team(state, &"probe_team", "Probe Team")
    organization.assign_member(state, actor.id, team.id)
    organization.assign_member(state, safe_leader.id, team.id)
    organization.assign_member(state, medium_leader.id, team.id)

    state.p1_relationships_enabled = false
    organization.assign_leader(state, team.id, safe_leader.id)
    var safe_choice := decisions.choose_region(state, actor)
    organization.assign_leader(state, team.id, medium_leader.id)
    var medium_choice := decisions.choose_region(state, actor)
    state.p1_relationships_enabled = true

    if safe_choice != &"thanh_truc_lam" or medium_choice != &"bach_thach_khe":
        _fail("Changing team leader did not measurably change the member's region decision.")
        return false

    organization.assign_leader(state, team.id, safe_leader.id)
    var relation := relationships.get_relation(state, actor.id, safe_leader.id, true)
    relation.affinity = 50.0
    relation.trust = 100.0
    relation.respect = 100.0
    var safe_region: RegionState = state.regions[&"thanh_truc_lam"]
    var high_authority := organization.region_organization_modifier(state, actor, safe_region)
    relation.trust = 0.0
    relation.respect = 0.0
    var low_authority := organization.region_organization_modifier(state, actor, safe_region)

    if high_authority <= low_authority or high_authority <= 0.0 or low_authority >= 0.0:
        _fail("Trust/respect did not measurably control leadership influence.")
        return false
    return true

func _verify_memory_can_counter_leader() -> bool:
    var state := P15Factory.create_state(TEST_SEED + 2)
    var organization := OrganizationSystem.new()
    var relationships := RelationshipSystem.new()
    var memories := MemorySystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    var leader: DiscipleState = state.disciples.get(&"tran_mac")

    state.teams = {}
    state.disciple_team_ids = {}
    state.role_assignments = {}
    state.relationships = {}
    state.memories = {}
    state.companion_assignments = {}
    actor.region_id = &"sect"
    leader.region_id = &"thanh_truc_lam"
    leader.target_region_id = &""

    var team := organization.create_team(state, &"memory_team", "Memory Team")
    organization.assign_member(state, actor.id, team.id)
    organization.assign_member(state, leader.id, team.id)
    organization.assign_leader(state, team.id, leader.id)

    var relation := relationships.get_relation(state, actor.id, leader.id, true)
    relation.affinity = 50.0
    relation.trust = 70.0
    relation.respect = 70.0
    var safe_region: RegionState = state.regions[&"thanh_truc_lam"]
    var leadership_effect := organization.region_organization_modifier(state, actor, safe_region)
    if leadership_effect <= 0.0:
        _fail("Memory probe requires initially positive leadership influence.")
        return false

    for _i in range(10):
        memories.record_event(state, actor.id, MemorySystem.EVENT_WITNESS_DEFEAT, leader.id, safe_region.id)
    var memory_effect := memories.region_memory_modifier(state, actor, safe_region.id)
    if memory_effect >= 0.0 or leadership_effect + memory_effect >= leadership_effect:
        _fail("Negative history with a leader did not counter positive leadership influence.")
        return false
    return true

func _verify_role_impacts() -> bool:
    var state := P15Factory.create_state(TEST_SEED + 3)
    var organization := OrganizationSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")

    state.relationships = {}
    state.memories = {}
    state.companion_assignments = {}
    state.teams = {}
    state.disciple_team_ids = {}
    state.role_assignments = {}
    actor.region_id = &"sect"
    actor.target_region_id = &""
    actor.hp = actor.max_hp
    actor.stamina = 60.0
    actor.wallet = 100
    actor.clear_inventory()
    actor.active_goal = GoalSystem.GOAL_GROWTH

    var neutral := decisions.evaluate(state, actor)
    if StringName(neutral.get("action", "")) != &"HUNT":
        _fail("Role probe baseline must choose HUNT before player assignment.")
        return false
    var neutral_hunt := float(neutral.get("scores", {}).get("HUNT", 0.0))

    organization.assign_role(state, actor.id, OrganizationSystem.ROLE_LOGISTICS)
    var logistics := decisions.evaluate(state, actor)
    if StringName(logistics.get("action", "")) != &"BUY":
        _fail("Logistics role did not change the controlled action from HUNT to BUY.")
        return false

    organization.assign_role(state, actor.id, OrganizationSystem.ROLE_HUNTER)
    var hunter := decisions.evaluate(state, actor)
    if float(hunter.get("scores", {}).get("HUNT", 0.0)) <= neutral_hunt:
        _fail("Hunter role did not measurably increase hunting utility.")
        return false

    var guard: DiscipleState = state.disciples.get(&"tran_mac")
    var team := organization.create_team(state, &"guard_team", "Guard Team")
    organization.assign_member(state, actor.id, team.id)
    organization.assign_member(state, guard.id, team.id)
    organization.assign_leader(state, team.id, actor.id)
    guard.region_id = &"sect"
    guard.target_region_id = &"thanh_truc_lam"
    organization.clear_role(state, actor.id)
    organization.assign_role(state, guard.id, OrganizationSystem.ROLE_GUARD)
    var safe_region: RegionState = state.regions[&"thanh_truc_lam"]
    var with_guard := organization.region_organization_modifier(state, actor, safe_region)
    organization.clear_role(state, guard.id)
    var without_guard := organization.region_organization_modifier(state, actor, safe_region)
    if with_guard <= without_guard:
        _fail("Guard role did not provide measurable regional support to a teammate.")
        return false
    return true

func _verify_player_move_and_recruitment() -> bool:
    var state := P15Factory.create_state(TEST_SEED + 4)
    var organization := OrganizationSystem.new()
    var relationships := RelationshipSystem.new()
    var recruitment := RecruitmentSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    var leader_a: DiscipleState = state.disciples.get(&"tran_mac")
    var leader_b: DiscipleState = state.disciples.get(&"lam_an")

    state.teams = {}
    state.disciple_team_ids = {}
    state.role_assignments = {}
    state.relationships = {}
    state.memories = {}
    state.companion_assignments = {}
    actor.combat_power = 16.0
    actor.risk_bias = 0.35
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.region_id = &"sect"
    actor.target_region_id = &""
    leader_a.region_id = &"thanh_truc_lam"
    leader_b.region_id = &"bach_thach_khe"

    var team_a := organization.create_team(state, &"move_a", "Move A")
    var team_b := organization.create_team(state, &"move_b", "Move B")
    organization.assign_member(state, leader_a.id, team_a.id)
    organization.assign_leader(state, team_a.id, leader_a.id)
    organization.assign_member(state, leader_b.id, team_b.id)
    organization.assign_leader(state, team_b.id, leader_b.id)
    organization.assign_member(state, actor.id, team_a.id)

    for leader in [leader_a, leader_b]:
        var relation := relationships.get_relation(state, actor.id, leader.id, true)
        relation.affinity = 50.0
        relation.trust = 100.0
        relation.respect = 100.0

    var choice_a := decisions.choose_region(state, actor)
    if not organization.assign_member(state, actor.id, team_b.id):
        _fail("Player could not move a disciple between teams.")
        return false
    var choice_b := decisions.choose_region(state, actor)
    if choice_a == choice_b:
        _fail("Moving a disciple between teams did not change organizational behavior.")
        return false

    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    var candidate_id := StringName(candidate_ids[0])
    var recruit_result := recruitment.accept_candidate(state, candidate_id)
    if not bool(recruit_result.get("ok", false)):
        _fail("P1.5 could not recruit a valid P1.2 candidate.")
        return false
    if not organization.assign_member(state, candidate_id, team_a.id):
        _fail("New recruit could not be assigned to a team.")
        return false
    if not organization.assign_role(state, candidate_id, OrganizationSystem.ROLE_LOGISTICS):
        _fail("New recruit could not receive an organizational role.")
        return false
    if organization.team_for_disciple(state, candidate_id) == null or organization.role_for_disciple(state, candidate_id) != OrganizationSystem.ROLE_LOGISTICS:
        _fail("New recruit organization assignment was not retained.")
        return false
    return true

func _organization_states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.p1_organization_enabled != b.p1_organization_enabled:
        return false
    if a.organization_change_count != b.organization_change_count:
        return false
    if a.disciple_team_ids != b.disciple_team_ids or a.role_assignments != b.role_assignments:
        return false
    if a.teams.size() != b.teams.size():
        return false
    var team_ids: Array = a.teams.keys()
    team_ids.sort()
    for team_id in team_ids:
        var left: TeamState = a.teams[team_id]
        var right: TeamState = b.teams.get(team_id)
        if right == null or left.to_dict() != right.to_dict():
            return false
    return true

func _memory_states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.p1_memory_enabled != b.p1_memory_enabled or a.memory_event_count != b.memory_event_count:
        return false
    if a.memories.size() != b.memories.size():
        return false
    for owner_id in a.memories.keys():
        var left_memories: Array = a.memories[owner_id]
        var right_memories: Array = b.memories.get(owner_id, [])
        if left_memories.size() != right_memories.size():
            return false
        for index in range(left_memories.size()):
            var left: MemoryState = left_memories[index]
            var right: MemoryState = right_memories[index]
            if left.to_dict() != right.to_dict():
                return false
    return true

func _relationship_states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.p1_relationships_enabled != b.p1_relationships_enabled:
        return false
    if a.relationship_event_count != b.relationship_event_count or a.companion_assignments != b.companion_assignments:
        return false
    if a.relationships.size() != b.relationships.size():
        return false
    for source_id in a.relationships.keys():
        var left_map: Dictionary = a.relationships[source_id]
        var right_map: Dictionary = b.relationships.get(source_id, {})
        if left_map.size() != right_map.size():
            return false
        for target_id in left_map.keys():
            var left: RelationshipState = left_map[target_id]
            var right: RelationshipState = right_map.get(target_id)
            if right == null or left.to_dict() != right.to_dict():
                return false
    return true

func _states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.tick != b.tick or a.seed != b.seed or a.rng_state != b.rng_state:
        return false
    if a.initial_total_money != b.initial_total_money or a.total_money() != b.total_money():
        return false
    if a.sect.to_dict() != b.sect.to_dict():
        return false
    if a.p1_goal_personality_enabled != b.p1_goal_personality_enabled or a.p1_recruitment_enabled != b.p1_recruitment_enabled:
        return false
    if not _relationship_states_equivalent(a, b) or not _memory_states_equivalent(a, b) or not _organization_states_equivalent(a, b):
        return false
    if a.disciples.size() != b.disciples.size():
        return false

    for disciple_id in a.disciples.keys():
        var left: DiscipleState = a.disciples[disciple_id]
        var right: DiscipleState = b.disciples.get(disciple_id)
        if right == null:
            return false
        if left.personality_id != right.personality_id or left.active_goal != right.active_goal or left.goal_changed_tick != right.goal_changed_tick:
            return false
        if left.current_action != right.current_action or left.region_id != right.region_id or left.target_region_id != right.target_region_id:
            return false
        if left.wallet != right.wallet or absf(left.combat_power - right.combat_power) > 0.000000001:
            return false
        if absf(left.hp - right.hp) > 0.000000001 or absf(left.stamina - right.stamina) > 0.000000001:
            return false
        if absf(left.risk_bias - right.risk_bias) > 0.000000001 or absf(left.spend_bias - right.spend_bias) > 0.000000001 or absf(left.survival_bias - right.survival_bias) > 0.000000001:
            return false
        if left.inventory != right.inventory or left.pending_loot != right.pending_loot or left.metrics != right.metrics:
            return false
    return true

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
