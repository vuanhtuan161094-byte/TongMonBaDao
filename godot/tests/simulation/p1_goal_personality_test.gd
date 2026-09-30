extends SceneTree

const TEST_SEED := 515151
const DETERMINISM_TICKS := 1500
const CONTINUATION_TICKS := 1000
const SAVE_PATH := "user://p1_1_goal_personality_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state_a := P1Factory.create_state(TEST_SEED)
    var state_b := P1Factory.create_state(TEST_SEED)

    if not state_a.p1_goal_personality_enabled or not state_b.p1_goal_personality_enabled:
        _fail("P1.1 factory did not enable goal/personality behavior.")
        return

    var personalities: Dictionary = {}
    var initial_goals: Dictionary = {}
    for disciple_id in state_a.disciples.keys():
        var disciple_a: DiscipleState = state_a.disciples[disciple_id]
        var disciple_b: DiscipleState = state_b.disciples.get(disciple_id)
        if disciple_b == null:
            _fail("Same-seed state is missing disciple %s." % disciple_id)
            return
        if disciple_a.personality_id != disciple_b.personality_id or disciple_a.active_goal != disciple_b.active_goal:
            _fail("Same-seed personality/goal mismatch for %s." % disciple_a.display_name)
            return
        personalities[str(disciple_a.personality_id)] = true
        initial_goals[str(disciple_a.active_goal)] = true

    if personalities.size() < 4:
        _fail("P1.1 personality diversity is too low.")
        return
    if initial_goals.size() < 3:
        _fail("P1.1 goal formation did not produce meaningful initial diversity.")
        return

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)

    if not _states_equivalent(state_a, state_b):
        _fail("P1.1 same-seed deterministic state diverged.")
        return

    var invariant_errors := state_a.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.1 invariant failure: %s" % " | ".join(invariant_errors))
        return

    if not _verify_goal_changes_region_utility(state_a):
        return

    var service := SaveService.new()
    var save_error := service.save_to_path(state_a, SAVE_PATH)
    if save_error != OK:
        _fail("P1.1 save failed with error %d." % save_error)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("P1.1 save could not be loaded.")
        return

    if not loaded.p1_goal_personality_enabled:
        _fail("P1.1 feature flag was not preserved by save/load.")
        return

    for disciple_id in state_a.disciples.keys():
        var before: DiscipleState = state_a.disciples[disciple_id]
        var after: DiscipleState = loaded.disciples.get(disciple_id)
        if after == null:
            _fail("Loaded P1.1 state is missing disciple %s." % disciple_id)
            return
        if before.personality_id != after.personality_id:
            _fail("Personality was not preserved for %s." % before.display_name)
            return
        if before.active_goal != after.active_goal or before.goal_changed_tick != after.goal_changed_tick:
            _fail("Goal state was not preserved for %s." % before.display_name)
            return

    var resumed_control := SimulationScheduler.new(state_a)
    var resumed_loaded := SimulationScheduler.new(loaded)
    resumed_control.run_ticks(CONTINUATION_TICKS)
    resumed_loaded.run_ticks(CONTINUATION_TICKS)

    if not _states_equivalent(state_a, loaded):
        _fail("P1.1 deterministic continuation diverged after save/load.")
        return

    invariant_errors = loaded.validate_invariants()
    if not invariant_errors.is_empty():
        _fail("P1.1 resumed invariant failure: %s" % " | ".join(invariant_errors))
        return

    var absolute_save := ProjectSettings.globalize_path(SAVE_PATH)
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(absolute_save)

    print("P1.1 GOAL + PERSONALITY TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " personalities=", personalities.size(), " initial_goals=", initial_goals.size())
    quit(0)

func _verify_goal_changes_region_utility(state: SimulationState) -> bool:
    var glory := DiscipleState.new({
        "id": "goal_probe_glory",
        "name": "Goal Probe Glory",
        "wallet": 100,
        "combat_power": 24.0,
        "risk_bias": 0.5,
        "spend_bias": 0.5,
        "survival_bias": 0.5,
        "personality_id": "probe"
    })
    glory.active_goal = GoalSystem.GOAL_GLORY

    var security := DiscipleState.from_dict(glory.to_dict())
    security.id = &"goal_probe_security"
    security.display_name = "Goal Probe Security"
    security.active_goal = GoalSystem.GOAL_SECURITY

    var decisions := DecisionSystem.new()
    var glory_region := decisions.choose_region(state, glory)
    var security_region := decisions.choose_region(state, security)

    if glory_region != &"hac_phong_coc":
        _fail("GLORY goal should prefer Hắc Phong Cốc in the neutral probe, got %s." % glory_region)
        return false
    if security_region != &"thanh_truc_lam":
        _fail("SECURITY goal should prefer Thanh Trúc Lâm in the neutral probe, got %s." % security_region)
        return false
    if glory_region == security_region:
        _fail("Different goals did not create measurable region-choice behavior.")
        return false

    return true

func _states_equivalent(a: SimulationState, b: SimulationState) -> bool:
    if a.tick != b.tick or a.seed != b.seed or a.rng_state != b.rng_state:
        return false
    if a.initial_total_money != b.initial_total_money or a.total_money() != b.total_money():
        return false
    if a.p1_goal_personality_enabled != b.p1_goal_personality_enabled:
        return false
    if a.sect.to_dict() != b.sect.to_dict():
        return false
    if a.disciples.size() != b.disciples.size():
        return false

    for disciple_id in a.disciples.keys():
        var left: DiscipleState = a.disciples[disciple_id]
        var right: DiscipleState = b.disciples.get(disciple_id)
        if right == null:
            return false
        if left.personality_id != right.personality_id or left.active_goal != right.active_goal:
            return false
        if left.goal_changed_tick != right.goal_changed_tick:
            return false
        if left.current_action != right.current_action or left.region_id != right.region_id or left.target_region_id != right.target_region_id:
            return false
        if left.wallet != right.wallet:
            return false
        if absf(left.hp - right.hp) > 0.000000001 or absf(left.stamina - right.stamina) > 0.000000001:
            return false
        if left.inventory != right.inventory or left.pending_loot != right.pending_loot or left.metrics != right.metrics:
            return false

    return true

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
