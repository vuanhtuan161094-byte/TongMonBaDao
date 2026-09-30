extends SceneTree

const TEST_SEED := 1020202
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p1_6_needs_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var needs := NeedsSystem.new()
    var state_a := P16Factory.create_state(TEST_SEED)
    var state_b := P16Factory.create_state(TEST_SEED)

    if not state_a.sect.needs_enabled or not state_b.sect.needs_enabled:
        _fail("P1.6 factory did not enable sect needs.")
        return
    if state_a.sect.to_dict() != state_b.sect.to_dict():
        _fail("Same-seed P1.6 initial needs state diverged.")
        return
    if _count_logistics(state_a) <= 0:
        _fail("P1.6 requires at least one seeded logistics disciple.")
        return

    if not _verify_medicine_shortage_changes_healing():
        return
    if not _verify_supply_shortage_changes_behavior():
        return
    if not _verify_logistics_priority_changes_output():
        return
    if not _verify_lodging_pressure_and_expansion():
        return

    needs.set_priority(state_a, NeedsSystem.PRIORITY_SUPPLIES)
    needs.set_priority(state_b, NeedsSystem.PRIORITY_SUPPLIES)

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)

    if not _states_equivalent(state_a, state_b):
        _fail("P1.6 same-seed deterministic simulation diverged.")
        return

    var invariant_errors := state_a.validate_invariants()
    invariant_errors.append_array(needs.validate_invariants(state_a))
    if not invariant_errors.is_empty():
        _fail("P1.6 invariant failure: %s" % " | ".join(invariant_errors))
        return

    var service := SaveService.new()
    var save_error := service.save_to_path(state_a, SAVE_PATH)
    if save_error != OK:
        _fail("P1.6 save failed with error %d." % save_error)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("P1.6 save could not be loaded.")
        return
    if not loaded.sect.needs_enabled:
        _fail("P1.6 needs feature flag was not preserved by save/load.")
        return
    if state_a.sect.to_dict() != loaded.sect.to_dict():
        _fail("P1.6 stock, lodging, priority or statistics were not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)

    if not _states_equivalent(state_a, loaded):
        _fail("P1.6 deterministic continuation diverged after save/load.")
        return

    invariant_errors = loaded.validate_invariants()
    invariant_errors.append_array(needs.validate_invariants(loaded))
    if not invariant_errors.is_empty():
        _fail("P1.6 resumed invariant failure: %s" % " | ".join(invariant_errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    print("P1.6 SECT NEEDS + RESOURCE CONSEQUENCE TEST PASS")
    print(
        "seed=", TEST_SEED,
        " ticks=", loaded.tick,
        " disciples=", loaded.disciples.size(),
        " medicine=", loaded.sect.medicine_stock,
        " supplies=", loaded.sect.supply_stock,
        " lodging=", loaded.sect.lodging_capacity,
        " needs_events=", loaded.sect.needs_event_count
    )
    quit(0)

func _verify_medicine_shortage_changes_healing() -> bool:
    var state := P16Factory.create_state(TEST_SEED + 1)
    var decisions := DecisionSystem.new()
    var needs := NeedsSystem.new()
    var economy := EconomySystem.new()
    var actor: DiscipleState = state.disciples.get(&"tran_mac")

    actor.region_id = &"sect"
    actor.target_region_id = &""
    actor.hp = 40.0
    actor.stamina = 100.0
    actor.wallet = maxi(actor.wallet, EconomySystem.HEAL_FEE + 10)
    actor.inventory.clear()

    state.sect.medicine_stock = 0
    var without_medicine := decisions.evaluate(state, actor)
    if str(without_medicine.get("action", "")) != "REST":
        _fail("P1.6 empty medicine stock did not force injured disciple away from HEAL.")
        return false

    state.sect.medicine_stock = 1
    var with_medicine := decisions.evaluate(state, actor)
    if str(with_medicine.get("action", "")) != "HEAL":
        _fail("P1.6 available medicine did not restore HEAL behavior.")
        return false

    var money_before := state.total_money()
    if not needs.heal_with_medicine(state, actor, economy):
        _fail("P1.6 medicine-backed healing failed despite medicine and wallet funds.")
        return false
    if state.sect.medicine_stock != 0:
        _fail("P1.6 healing did not consume one medicine.")
        return false
    if state.total_money() != money_before:
        _fail("P1.6 medicine-backed healing broke money conservation.")
        return false
    return true

func _verify_supply_shortage_changes_behavior() -> bool:
    var state := P16Factory.create_state(TEST_SEED + 2)
    var decisions := DecisionSystem.new()
    var needs := NeedsSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")

    state.relationships = {}
    state.memories = {}
    state.companion_assignments = {}
    state.teams = {}
    state.disciple_team_ids = {}
    state.role_assignments = {}
    actor.combat_power = 24.0
    actor.risk_bias = 0.50
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.region_id = &"sect"
    actor.target_region_id = &""

    state.sect.supply_stock = 20
    var supplied_choice := decisions.choose_region(state, actor)
    if supplied_choice != &"hac_phong_coc":
        _fail("P1.6 supply probe expected Hắc Phong Cốc when well supplied, got %s." % supplied_choice)
        return false

    state.sect.supply_stock = 0
    var shortage_choice := decisions.choose_region(state, actor)
    if shortage_choice != &"thanh_truc_lam":
        _fail("P1.6 zero supplies did not push the same disciple toward the safe region.")
        return false

    state.sect.supply_stock = 1
    if not needs.prepare_departure(state, actor):
        _fail("P1.6 could not consume an available departure supply.")
        return false
    if state.sect.supply_stock != 0:
        _fail("P1.6 departure did not consume one supply.")
        return false
    var supplied_cost := needs.consume_travel_stamina_cost(state, actor)

    if needs.prepare_departure(state, actor):
        _fail("P1.6 reported a supplied departure with empty stock.")
        return false
    var unsupplied_cost := needs.consume_travel_stamina_cost(state, actor)
    if unsupplied_cost <= supplied_cost:
        _fail("P1.6 unsupplied travel did not cost more stamina than supplied travel.")
        return false
    return true

func _verify_logistics_priority_changes_output() -> bool:
    var state := P16Factory.create_state(TEST_SEED + 3)
    var needs := NeedsSystem.new()
    var organization := OrganizationSystem.new()

    state.role_assignments = {}
    if not organization.assign_role(state, &"lam_an", OrganizationSystem.ROLE_LOGISTICS):
        _fail("P1.6 logistics priority probe could not assign a logistics worker.")
        return false

    state.sect.medicine_stock = 0
    state.sect.supply_stock = 0
    state.tick = NeedsSystem.LOGISTICS_INTERVAL
    needs.set_priority(state, NeedsSystem.PRIORITY_BALANCED)
    needs.process_logistics_tick(state)
    var balanced_medicine := state.sect.medicine_stock
    var balanced_supplies := state.sect.supply_stock

    state.sect.medicine_stock = 0
    state.sect.supply_stock = 0
    state.tick = NeedsSystem.LOGISTICS_INTERVAL * 2
    needs.set_priority(state, NeedsSystem.PRIORITY_MEDICINE)
    needs.process_logistics_tick(state)
    var medicine_focus_medicine := state.sect.medicine_stock
    var medicine_focus_supplies := state.sect.supply_stock

    state.sect.medicine_stock = 0
    state.sect.supply_stock = 0
    state.tick = NeedsSystem.LOGISTICS_INTERVAL * 3
    needs.set_priority(state, NeedsSystem.PRIORITY_SUPPLIES)
    needs.process_logistics_tick(state)
    var supply_focus_medicine := state.sect.medicine_stock
    var supply_focus_supplies := state.sect.supply_stock

    if medicine_focus_medicine <= balanced_medicine:
        _fail("P1.6 medicine priority did not measurably increase medicine output.")
        return false
    if supply_focus_supplies <= balanced_supplies:
        _fail("P1.6 supply priority did not measurably increase supply output.")
        return false
    if medicine_focus_supplies >= supply_focus_supplies or supply_focus_medicine >= medicine_focus_medicine:
        _fail("P1.6 logistics priorities do not create a real allocation tradeoff.")
        return false
    return true

func _verify_lodging_pressure_and_expansion() -> bool:
    var state := P16Factory.create_state(TEST_SEED + 4)
    var needs := NeedsSystem.new()
    var recruitment := RecruitmentSystem.new()

    for _i in range(2):
        var candidate_ids: Array = state.recruitment_candidates.keys()
        candidate_ids.sort()
        if candidate_ids.is_empty():
            _fail("P1.6 lodging probe ran out of recruitment candidates.")
            return false
        var result := recruitment.accept_candidate(state, StringName(candidate_ids[0]))
        if not bool(result.get("ok", false)):
            _fail("P1.6 lodging probe could not recruit up to sect capacity.")
            return false

    if state.disciples.size() != 8 or state.sect.lodging_capacity != 6:
        _fail("P1.6 lodging probe expected population 8 with lodging 6.")
        return false

    var crowded_multiplier := needs.rest_recovery_multiplier(state)
    if crowded_multiplier >= 1.0:
        _fail("P1.6 population above lodging capacity did not reduce rest recovery.")
        return false

    var actor: DiscipleState = state.disciples.get(&"lam_an")
    actor.stamina = 0.0
    actor.hp = 50.0
    needs.apply_rest(state, actor)
    var crowded_stamina := actor.stamina
    if crowded_stamina >= 48.0:
        _fail("P1.6 overcrowded rest recovered as much as full lodging rest.")
        return false

    state.sect.supply_stock = NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT * 2
    if not needs.expand_lodging(state, 2):
        _fail("P1.6 player could not spend supplies to expand lodging.")
        return false
    if state.sect.lodging_capacity != 8 or state.sect.supply_stock != 0:
        _fail("P1.6 lodging expansion did not consume supplies or add the requested slots.")
        return false
    if needs.rest_recovery_multiplier(state) < 0.999999:
        _fail("P1.6 lodging expansion did not remove the recovery penalty.")
        return false

    actor.stamina = 0.0
    needs.apply_rest(state, actor)
    if actor.stamina <= crowded_stamina:
        _fail("P1.6 lodging expansion did not measurably improve rest recovery.")
        return false
    return true

func _count_logistics(state: SimulationState) -> int:
    var count := 0
    for raw_role in state.role_assignments.values():
        if StringName(raw_role) == OrganizationSystem.ROLE_LOGISTICS:
            count += 1
    return count

func _organization_states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.p1_organization_enabled != b.p1_organization_enabled:
        return false
    if a.organization_change_count != b.organization_change_count:
        return false
    if a.disciple_team_ids != b.disciple_team_ids or a.role_assignments != b.role_assignments:
        return false
    if a.teams.size() != b.teams.size():
        return false
    for team_id in a.teams.keys():
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
