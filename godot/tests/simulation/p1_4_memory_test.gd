extends SceneTree

const TEST_SEED := 818181
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p1_4_memory_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var memory_system := MemorySystem.new()
    var state_a := P14Factory.create_state(TEST_SEED)
    var state_b := P14Factory.create_state(TEST_SEED)

    if not state_a.p1_goal_personality_enabled or not state_a.p1_recruitment_enabled or not state_a.p1_relationships_enabled or not state_a.p1_memory_enabled:
        _fail("P1.4 factory did not enable the required P1 systems.")
        return

    if not _verify_memory_changes_behavior():
        return
    if not _verify_personality_shapes_memory():
        return
    if not _verify_consolidation_and_cap():
        return
    if not _verify_player_linked_memory_persists_after_clear():
        return

    var relationships := RelationshipSystem.new()
    var ids: Array = state_a.disciples.keys()
    ids.sort()
    var source_id := StringName(ids[0])
    var target_id := StringName(ids[1])
    relationships.assign_companion(state_a, source_id, target_id)
    relationships.assign_companion(state_b, source_id, target_id)

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)

    if memory_system.memory_count(state_a) <= 0:
        _fail("P1.4 simulation did not form any consequential memories.")
        return
    if not _states_equivalent(state_a, state_b):
        _fail("P1.4 same-seed deterministic simulation diverged.")
        return

    var invariant_errors := state_a.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.4 invariant failure: %s" % " | ".join(invariant_errors))
        return

    var service := SaveService.new()
    var save_error := service.save_to_path(state_a, SAVE_PATH)
    if save_error != OK:
        _fail("P1.4 save failed with error %d." % save_error)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("P1.4 save could not be loaded.")
        return
    if not loaded.p1_memory_enabled:
        _fail("P1.4 memory feature flag was not preserved by save/load.")
        return
    if not _memory_states_equivalent(state_a, loaded):
        _fail("P1.4 memory state was not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)

    if not _states_equivalent(state_a, loaded):
        _fail("P1.4 deterministic continuation diverged after save/load.")
        return

    invariant_errors = loaded.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.4 resumed invariant failure: %s" % " | ".join(invariant_errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    print("P1.4 MEMORY + CONSEQUENCE TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " disciples=", loaded.disciples.size(), " memories=", memory_system.memory_count(loaded), " memory_events=", loaded.memory_event_count, " cap=", MemorySystem.MAX_MEMORIES_PER_DISCIPLE)
    quit(0)

func _verify_memory_changes_behavior() -> bool:
    var state := P14Factory.create_state(TEST_SEED + 1)
    var memory_system := MemorySystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")

    state.relationships = {}
    state.companion_assignments = {}
    state.memories = {}
    actor.combat_power = 24.0
    actor.risk_bias = 0.20
    actor.survival_bias = 0.80
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.region_id = &"sect"
    actor.target_region_id = &""

    var baseline := decisions.choose_region(state, actor)
    if baseline != &"thanh_truc_lam":
        _fail("P1.4 behavior probe expected Thanh Trúc Lâm before memory influence, got %s." % baseline)
        return false

    memory_system.record_event(state, actor.id, MemorySystem.EVENT_PERSONAL_VICTORY, &"", &"hac_phong_coc")
    var after_victory := decisions.choose_region(state, actor)
    if after_victory != &"hac_phong_coc":
        _fail("A positive place memory did not change the region decision.")
        return false

    memory_system.record_event(state, actor.id, MemorySystem.EVENT_PERSONAL_DEFEAT, &"", &"hac_phong_coc")
    var after_defeat := decisions.choose_region(state, actor)
    if after_defeat == &"hac_phong_coc":
        _fail("A strong defeat memory did not push behavior away from the remembered region.")
        return false

    return true

func _verify_personality_shapes_memory() -> bool:
    var state := P14Factory.create_state(TEST_SEED + 2)
    var memory_system := MemorySystem.new()
    var cautious: DiscipleState = state.disciples.get(&"tran_mac")
    var reckless: DiscipleState = state.disciples.get(&"co_truong_phong")

    state.memories = {}
    var cautious_negative := memory_system.record_event(state, cautious.id, MemorySystem.EVENT_PERSONAL_DEFEAT, &"", &"hach_phong_coc")
    if cautious_negative == null:
        cautious_negative = memory_system.record_event(state, cautious.id, MemorySystem.EVENT_PERSONAL_DEFEAT, &"", &"hac_phong_coc")
    var reckless_negative := memory_system.record_event(state, reckless.id, MemorySystem.EVENT_PERSONAL_DEFEAT, &"", &"hac_phong_coc")
    if cautious_negative == null or reckless_negative == null:
        _fail("P1.4 personality probe could not create defeat memories.")
        return false
    if cautious_negative.importance <= reckless_negative.importance:
        _fail("Survival-oriented personality did not retain negative experience more strongly.")
        return false

    state.memories = {}
    var cautious_positive := memory_system.record_event(state, cautious.id, MemorySystem.EVENT_PERSONAL_VICTORY, &"", &"hac_phong_coc")
    var reckless_positive := memory_system.record_event(state, reckless.id, MemorySystem.EVENT_PERSONAL_VICTORY, &"", &"hac_phong_coc")
    if reckless_positive.importance <= cautious_positive.importance:
        _fail("Risk-oriented personality did not retain positive victory experience more strongly.")
        return false

    return true

func _verify_consolidation_and_cap() -> bool:
    var state := P14Factory.create_state(TEST_SEED + 3)
    var memory_system := MemorySystem.new()
    var owner: DiscipleState = state.disciples.get(&"bach_nguyet")
    state.memories = {}

    var first := memory_system.record_event(state, owner.id, MemorySystem.EVENT_PERSONAL_VICTORY, &"", &"thanh_truc_lam")
    var second := memory_system.record_event(state, owner.id, MemorySystem.EVENT_PERSONAL_VICTORY, &"", &"thanh_truc_lam")
    if first == null or second == null or first != second or first.occurrences != 2:
        _fail("Repeated experience did not consolidate into one stronger memory.")
        return false

    var target_ids: Array = state.disciples.keys()
    target_ids.sort()
    var events := [MemorySystem.EVENT_SHARED_VICTORY, MemorySystem.EVENT_WITNESS_RETREAT, MemorySystem.EVENT_WITNESS_DEFEAT]
    var regions := [&"thanh_truc_lam", &"bach_thach_khe", &"hac_phong_coc"]
    for event_id in events:
        for raw_target_id in target_ids:
            var target_id := StringName(raw_target_id)
            if target_id == owner.id:
                continue
            for region_id in regions:
                memory_system.record_event(state, owner.id, event_id, target_id, region_id)

    if memory_system.memory_count(state, owner.id) > MemorySystem.MAX_MEMORIES_PER_DISCIPLE:
        _fail("P1.4 memory cap was exceeded.")
        return false
    return true

func _verify_player_linked_memory_persists_after_clear() -> bool:
    var state := P14Factory.create_state(TEST_SEED + 4)
    var memory_system := MemorySystem.new()
    var relationships := RelationshipSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    var target: DiscipleState = state.disciples.get(&"tran_mac")

    state.relationships = {}
    state.memories = {}
    state.companion_assignments = {}
    actor.combat_power = 24.0
    actor.risk_bias = 0.20
    actor.survival_bias = 0.50
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.region_id = &"sect"
    actor.target_region_id = &""
    target.region_id = &"hac_phong_coc"
    target.target_region_id = &""

    var baseline := decisions.choose_region(state, actor)
    if baseline != &"thanh_truc_lam":
        _fail("P1.4 player-memory probe baseline was not neutral enough.")
        return false

    if not relationships.assign_companion(state, actor.id, target.id):
        _fail("P1.4 player-memory probe could not assign a companion.")
        return false
    memory_system.record_event(state, actor.id, MemorySystem.EVENT_SHARED_VICTORY, target.id, target.region_id, true)
    relationships.clear_companion(state, actor.id)

    var after_clear := decisions.choose_region(state, actor)
    if after_clear != &"hac_phong_coc":
        _fail("Player-created shared experience did not leave a lasting behavioral memory after companion assignment was cleared.")
        return false

    return true

func _memory_states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.p1_memory_enabled != b.p1_memory_enabled or a.memory_event_count != b.memory_event_count:
        return false
    if a.memories.size() != b.memories.size():
        return false

    var owner_ids: Array = a.memories.keys()
    owner_ids.sort()
    for owner_id in owner_ids:
        var left_memories: Array = a.memories[owner_id]
        var right_memories: Array = b.memories.get(owner_id, [])
        if left_memories.size() != right_memories.size():
            return false
        for index in range(left_memories.size()):
            var left: MemoryState = left_memories[index]
            var right: MemoryState = right_memories[index]
            if left.id != right.id or left.owner_id != right.owner_id or left.event_id != right.event_id:
                return false
            if left.target_id != right.target_id or left.region_id != right.region_id or left.player_linked != right.player_linked:
                return false
            if left.occurrences != right.occurrences or left.created_tick != right.created_tick or left.last_event_tick != right.last_event_tick:
                return false
            if absf(left.valence - right.valence) > 0.000000001 or absf(left.importance - right.importance) > 0.000000001:
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
            if right == null:
                return false
            if left.to_dict() != right.to_dict():
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
    if not _relationship_states_equivalent(a, b) or not _memory_states_equivalent(a, b):
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
        if left.inventory != right.inventory or left.pending_loot != right.pending_loot or left.metrics != right.metrics:
            return false

    return true

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
