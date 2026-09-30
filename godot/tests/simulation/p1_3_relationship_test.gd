extends SceneTree

const TEST_SEED := 717171
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p1_3_relationship_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var relationships := RelationshipSystem.new()
    var state_a := P13Factory.create_state(TEST_SEED)
    var state_b := P13Factory.create_state(TEST_SEED)

    if not state_a.p1_goal_personality_enabled or not state_a.p1_recruitment_enabled or not state_a.p1_relationships_enabled:
        _fail("P1.3 factory did not enable the required P1 systems.")
        return

    var relationship_count := relationships.relationship_count(state_a)
    var possible_edges := state_a.disciples.size() * (state_a.disciples.size() - 1)
    if relationship_count <= 0 or relationship_count >= possible_edges:
        _fail("P1.3 relationship graph is not sparse.")
        return
    if not _relationship_states_equivalent(state_a, state_b):
        _fail("Same-seed P1.3 relationship generation diverged.")
        return

    if not _verify_behavior_impact():
        return
    if not _verify_personality_and_directionality():
        return
    if not _verify_recruitment_integration():
        return

    var ids: Array = state_a.disciples.keys()
    ids.sort()
    var source_id := StringName(ids[0])
    var target_id := StringName(ids[1])
    if not relationships.assign_companion(state_a, source_id, target_id):
        _fail("Player companion assignment failed in deterministic state A.")
        return
    if not relationships.assign_companion(state_b, source_id, target_id):
        _fail("Player companion assignment failed in deterministic state B.")
        return

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)

    if not _states_equivalent(state_a, state_b):
        _fail("P1.3 same-seed deterministic simulation diverged.")
        return

    var invariant_errors := state_a.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.3 invariant failure: %s" % " | ".join(invariant_errors))
        return

    var service := SaveService.new()
    var save_error := service.save_to_path(state_a, SAVE_PATH)
    if save_error != OK:
        _fail("P1.3 save failed with error %d." % save_error)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("P1.3 save could not be loaded.")
        return
    if not loaded.p1_relationships_enabled:
        _fail("P1.3 feature flag was not preserved by save/load.")
        return
    if not _relationship_states_equivalent(state_a, loaded):
        _fail("P1.3 relationships/player assignments were not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)

    if not _states_equivalent(state_a, loaded):
        _fail("P1.3 deterministic continuation diverged after save/load.")
        return

    invariant_errors = loaded.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.3 resumed invariant failure: %s" % " | ".join(invariant_errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    print("P1.3 RELATIONSHIP + BEHAVIOR IMPACT TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " disciples=", loaded.disciples.size(), " relationships=", relationships.relationship_count(loaded), " events=", loaded.relationship_event_count, " assignments=", loaded.companion_assignments.size())
    quit(0)

func _verify_behavior_impact() -> bool:
    var state := P13Factory.create_state(TEST_SEED + 1)
    var relationships := RelationshipSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    var target: DiscipleState = state.disciples.get(&"tran_mac")

    actor.combat_power = 16.0
    actor.risk_bias = 0.5
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.region_id = &"sect"
    actor.target_region_id = &""
    target.region_id = &"thanh_truc_lam"
    target.target_region_id = &""

    state.relationships[str(actor.id)] = {}
    var relation := relationships.get_relation(state, actor.id, target.id, true)
    relation.affinity = 75.0
    relation.trust = 75.0
    relation.respect = 75.0

    var without_assignment := decisions.choose_region(state, actor)
    if without_assignment != &"bach_thach_khe":
        _fail("P1.3 neutral behavior probe expected Bạch Thạch Khê before player companion assignment, got %s." % without_assignment)
        return false

    if not relationships.assign_companion(state, actor.id, target.id):
        _fail("P1.3 player companion assignment was rejected.")
        return false
    var with_assignment := decisions.choose_region(state, actor)
    if with_assignment != &"thanh_truc_lam":
        _fail("P1.3 player companion assignment did not measurably change region choice, got %s." % with_assignment)
        return false

    relationships.clear_companion(state, actor.id)
    var after_clear := decisions.choose_region(state, actor)
    if after_clear != &"bach_thach_khe":
        _fail("P1.3 clearing player companion assignment did not restore the unassigned choice.")
        return false

    relation.affinity = 50.0
    relation.trust = 50.0
    relation.respect = 50.0
    var neutral := relationships.region_social_modifier(state, actor, &"thanh_truc_lam")
    relation.affinity = 100.0
    var affinity_effect := relationships.region_social_modifier(state, actor, &"thanh_truc_lam")
    relation.affinity = 50.0
    relation.trust = 100.0
    var trust_effect := relationships.region_social_modifier(state, actor, &"thanh_truc_lam")
    relation.trust = 50.0
    relation.respect = 100.0
    var respect_effect := relationships.region_social_modifier(state, actor, &"thanh_truc_lam")

    if absf(neutral) > 0.000001 or affinity_effect <= 0.0 or trust_effect <= 0.0 or respect_effect <= 0.0:
        _fail("Affinity/trust/respect do not all have measurable behavior weight.")
        return false

    return true

func _verify_personality_and_directionality() -> bool:
    var state := P13Factory.create_state(TEST_SEED + 2)
    var relationships := RelationshipSystem.new()
    var cautious: DiscipleState = state.disciples.get(&"tran_mac")
    var reckless: DiscipleState = state.disciples.get(&"co_truong_phong")
    var target: DiscipleState = state.disciples.get(&"bach_nguyet")

    var cautious_relation := relationships.get_relation(state, cautious.id, target.id, true)
    var reckless_relation := relationships.get_relation(state, reckless.id, target.id, true)
    for relation in [cautious_relation, reckless_relation]:
        relation.affinity = 50.0
        relation.trust = 50.0
        relation.respect = 50.0
        relation.interactions = 0

    relationships.apply_event(state, cautious.id, target.id, &"admire_strength")
    relationships.apply_event(state, reckless.id, target.id, &"admire_strength")
    if reckless_relation.respect <= cautious_relation.respect:
        _fail("P1.3 personality did not change relationship response to the same event.")
        return false

    var reverse := relationships.get_relation(state, target.id, cautious.id, true)
    var reverse_before := reverse.to_dict()
    relationships.apply_event(state, cautious.id, target.id, &"conflict")
    if reverse.to_dict() != reverse_before:
        _fail("P1.3 directed relationship mutated the reverse direction implicitly.")
        return false

    return true

func _verify_recruitment_integration() -> bool:
    var state := P13Factory.create_state(TEST_SEED + 3)
    var recruitment := RecruitmentSystem.new()
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    var candidate_id := StringName(ids[0])
    var result := recruitment.accept_candidate(state, candidate_id)
    if not bool(result.get("ok", false)):
        _fail("P1.3 could not recruit a valid P1.2 candidate.")
        return false
    var source_map: Dictionary = state.relationships.get(str(candidate_id), {})
    if source_map.is_empty():
        _fail("New recruit did not enter the sparse relationship network.")
        return false
    return true

func _relationship_states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.p1_relationships_enabled != b.p1_relationships_enabled:
        return false
    if a.relationship_event_count != b.relationship_event_count:
        return false
    if a.companion_assignments != b.companion_assignments:
        return false
    if a.relationships.size() != b.relationships.size():
        return false

    var source_ids: Array = a.relationships.keys()
    source_ids.sort()
    for source_id in source_ids:
        var left_map: Dictionary = a.relationships[source_id]
        var right_map: Dictionary = b.relationships.get(source_id, {})
        if left_map.size() != right_map.size():
            return false
        var target_ids: Array = left_map.keys()
        target_ids.sort()
        for target_id in target_ids:
            var left: RelationshipState = left_map[target_id]
            var right: RelationshipState = right_map.get(target_id)
            if right == null:
                return false
            if left.source_id != right.source_id or left.target_id != right.target_id:
                return false
            if absf(left.affinity - right.affinity) > 0.000000001:
                return false
            if absf(left.trust - right.trust) > 0.000000001:
                return false
            if absf(left.respect - right.respect) > 0.000000001:
                return false
            if left.interactions != right.interactions or left.last_event_tick != right.last_event_tick or left.last_event != right.last_event:
                return false
    return true

func _states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.tick != b.tick or a.seed != b.seed or a.rng_state != b.rng_state:
        return false
    if a.initial_total_money != b.initial_total_money or a.total_money() != b.total_money():
        return false
    if a.p1_goal_personality_enabled != b.p1_goal_personality_enabled or a.p1_recruitment_enabled != b.p1_recruitment_enabled:
        return false
    if a.sect.to_dict() != b.sect.to_dict():
        return false
    if a.disciples.size() != b.disciples.size():
        return false
    if not _relationship_states_equivalent(a, b):
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
