extends SceneTree

const TEST_SEED := 1121212
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p2_1_cultivation_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state_a := P21Factory.create_state(TEST_SEED)
    var state_b := P21Factory.create_state(TEST_SEED)
    var cultivation := CultivationSystem.new()

    if not state_a.sect.cultivation_enabled or not state_a.sect.needs_enabled or not state_a.p1_organization_enabled:
        _fail("P2.1 factory did not preserve prior P1 systems and enable cultivation.")
        return
    if state_a.to_dict() != state_b.to_dict():
        _fail("Same-seed P2.1 initial state diverged.")
        return

    if not _verify_player_directive_and_personality():
        return
    if not _verify_progress_sources():
        return
    if not _verify_breakthrough_success_and_failure():
        return
    if not _verify_realm_power_changes_behavior_and_combat():
        return

    cultivation.set_directive(state_a, &"tran_mac", CultivationSystem.DIRECTIVE_CULTIVATE)
    cultivation.set_directive(state_b, &"tran_mac", CultivationSystem.DIRECTIVE_CULTIVATE)

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)

    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.1 same-seed deterministic simulation diverged.")
        return
    if _cultivation_invariants(state_a).size() > 0:
        _fail("P2.1 invariant failure: %s" % " | ".join(_cultivation_invariants(state_a)))
        return

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        _fail("P2.1 save failed.")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.cultivation_enabled:
        _fail("P2.1 save could not be restored with cultivation enabled.")
        return
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.1 cultivation state was not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)

    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.1 deterministic continuation diverged after save/load.")
        return
    var errors := _cultivation_invariants(loaded)
    if not errors.is_empty():
        _fail("P2.1 resumed invariant failure: %s" % " | ".join(errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    var highest_stage := 0
    var total_successes := 0
    var total_sessions := 0
    for disciple_value in loaded.disciples.values():
        var disciple: DiscipleState = disciple_value
        highest_stage = maxi(highest_stage, disciple.cultivation_stage_index)
        total_successes += int(disciple.metrics.get("breakthrough_successes", 0))
        total_sessions += int(disciple.metrics.get("cultivation_sessions", 0))

    print("P2.1 CULTIVATION + BREAKTHROUGH CONSEQUENCE TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " disciples=", loaded.disciples.size(), " cultivation_events=", loaded.sect.cultivation_event_count, " sessions=", total_sessions, " breakthroughs=", total_successes, " highest_stage=", highest_stage)
    quit(0)

func _verify_player_directive_and_personality() -> bool:
    var state := P21Factory.create_state(TEST_SEED + 1)
    var cultivation := CultivationSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")

    actor.region_id = &"sect"
    actor.target_region_id = &""
    actor.hp = actor.max_hp
    actor.stamina = 100.0
    actor.inventory.clear()
    actor.active_goal = GoalSystem.GOAL_PREPARE
    state.role_assignments.erase(str(actor.id))

    cultivation.set_directive(state, actor.id, CultivationSystem.DIRECTIVE_CULTIVATE)
    var cultivate_choice := decisions.evaluate(state, actor)
    if str(cultivate_choice.get("action", "")) != "CULTIVATE":
        _fail("P2.1 player cultivate priority did not change autonomous action to CULTIVATE.")
        return false

    cultivation.set_directive(state, actor.id, CultivationSystem.DIRECTIVE_FIELD)
    var field_choice := decisions.evaluate(state, actor)
    if str(field_choice.get("action", "")) != "HUNT":
        _fail("P2.1 player field priority did not change autonomous action back to HUNT.")
        return false

    var cautious: DiscipleState = state.disciples.get(&"tran_mac")
    var reckless: DiscipleState = state.disciples.get(&"co_truong_phong")
    for disciple in [cautious, reckless]:
        disciple.region_id = &"sect"
        disciple.hp = disciple.max_hp
        disciple.stamina = 100.0
        disciple.inventory.clear()
        disciple.active_goal = GoalSystem.GOAL_PREPARE
        disciple.cultivation_directive = CultivationSystem.DIRECTIVE_BALANCED
        state.role_assignments.erase(str(disciple.id))
    var cautious_scores: Dictionary = decisions.evaluate(state, cautious).get("scores", {})
    var reckless_scores: Dictionary = decisions.evaluate(state, reckless).get("scores", {})
    if float(cautious_scores.get("CULTIVATE", 0.0)) <= float(reckless_scores.get("CULTIVATE", 0.0)):
        _fail("P2.1 personality did not make cautious disciple value cultivation more than reckless disciple.")
        return false
    return true

func _verify_progress_sources() -> bool:
    var state := P21Factory.create_state(TEST_SEED + 2)
    var cultivation := CultivationSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.region_id = &"sect"
    actor.stamina = 100.0
    actor.cultivation_progress = 0.0

    var gained := cultivation.cultivate(state, actor)
    if absf(gained - CultivationSystem.CULTIVATE_GAIN) > 0.000001:
        _fail("P2.1 cultivation session did not add the configured cultivation amount.")
        return false
    if absf(actor.stamina - (100.0 - CultivationSystem.CULTIVATE_STAMINA_COST)) > 0.000001:
        _fail("P2.1 cultivation session did not consume stamina.")
        return false

    var before_combat_gain := actor.cultivation_progress
    cultivation.add_combat_win_progress(state, actor)
    if absf(actor.cultivation_progress - before_combat_gain - CultivationSystem.COMBAT_WIN_GAIN) > 0.000001:
        _fail("P2.1 combat victory progress source is not measurable.")
        return false
    return true

func _verify_breakthrough_success_and_failure() -> bool:
    var state := P21Factory.create_state(TEST_SEED + 3)
    var cultivation := CultivationSystem.new()
    var actor: DiscipleState = state.disciples.get(&"tran_mac")
    actor.region_id = &"sect"
    actor.hp = actor.max_hp
    actor.stamina = 100.0
    actor.cultivation_progress = cultivation.required_progress(actor)

    var hp_before := actor.max_hp
    var success := cultivation.resolve_breakthrough(state, actor, 0.0)
    if str(success.get("outcome", "")) != "success" or actor.cultivation_stage_index != 1:
        _fail("P2.1 controlled breakthrough success did not advance one stage.")
        return false
    if actor.cultivation_combat_bonus <= 0.0 or actor.max_hp <= hp_before:
        _fail("P2.1 successful breakthrough did not increase combat power bonus and max HP.")
        return false

    if not _advance_to_stage(state, actor, 8):
        return false
    var stage_before := actor.cultivation_stage_index
    actor.hp = actor.max_hp
    actor.stamina = 100.0
    actor.cultivation_progress = cultivation.required_progress(actor)
    state.tick = maxi(state.tick, actor.next_breakthrough_tick)
    var progress_before := actor.cultivation_progress
    var failure := cultivation.resolve_breakthrough(state, actor, 1.0)
    if str(failure.get("outcome", "")) != "failure" or actor.cultivation_stage_index != stage_before:
        _fail("P2.1 controlled breakthrough failure did not preserve the current stage.")
        return false
    if actor.cultivation_progress >= progress_before or actor.hp >= actor.max_hp or actor.stamina >= 100.0:
        _fail("P2.1 breakthrough failure did not cause cultivation/HP/stamina loss.")
        return false
    if actor.next_breakthrough_tick <= state.tick or actor.breakthrough_failures <= 0:
        _fail("P2.1 breakthrough failure did not create a real retry cooldown/failure record.")
        return false
    return true

func _verify_realm_power_changes_behavior_and_combat() -> bool:
    var state := P21Factory.create_state(TEST_SEED + 4)
    var cultivation := CultivationSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")

    state.relationships = {}
    state.memories = {}
    state.companion_assignments = {}
    state.teams = {}
    state.disciple_team_ids = {}
    state.role_assignments = {}
    state.sect.supply_stock = NeedsSystem.SUPPLY_CAP
    actor.region_id = &"sect"
    actor.target_region_id = &""
    actor.combat_power = 14.0
    actor.risk_bias = 0.50
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.cultivation_directive = CultivationSystem.DIRECTIVE_BALANCED

    var before_region := decisions.choose_region(state, actor)
    if before_region != &"thanh_truc_lam":
        _fail("P2.1 realm-power probe expected low-power disciple to choose Thanh Trúc Lâm.")
        return false
    if not _advance_to_stage(state, actor, 9):
        return false
    var after_region := decisions.choose_region(state, actor)
    if after_region != &"hac_phong_coc":
        _fail("P2.1 Trúc Cơ realm power did not unlock a harder profitable region choice.")
        return false

    var weak_state := P21Factory.create_state(TEST_SEED + 5)
    var strong_state := P21Factory.create_state(TEST_SEED + 5)
    var weak: DiscipleState = weak_state.disciples.get(&"bach_nguyet")
    var strong: DiscipleState = strong_state.disciples.get(&"bach_nguyet")
    for disciple in [weak, strong]:
        disciple.region_id = &"hac_phong_coc"
        disciple.combat_power = 1.0
        disciple.risk_bias = 0.94
        disciple.hp = disciple.max_hp
        disciple.stamina = 100.0
    if not _advance_to_stage(strong_state, strong, CultivationSystem.STAGES.size() - 1):
        return false
    strong.hp = strong.max_hp

    var weak_result := CombatSystem.new().resolve_encounter(weak_state, weak, GameRng.new(424242))
    var strong_result := CombatSystem.new().resolve_encounter(strong_state, strong, GameRng.new(424242))
    if str(weak_result.get("outcome", "")) == "win" or str(strong_result.get("outcome", "")) != "win":
        _fail("P2.1 realm combat bonus did not measurably change a controlled combat outcome.")
        return false
    return true

func _advance_to_stage(state: SimulationState, disciple: DiscipleState, target_stage: int) -> bool:
    var cultivation := CultivationSystem.new()
    while disciple.cultivation_stage_index < target_stage:
        state.tick = maxi(state.tick, disciple.next_breakthrough_tick)
        disciple.hp = disciple.max_hp
        disciple.stamina = 100.0
        disciple.cultivation_progress = cultivation.required_progress(disciple)
        var result := cultivation.resolve_breakthrough(state, disciple, 0.0)
        if str(result.get("outcome", "")) != "success":
            _fail("P2.1 test helper could not advance cultivation stage deterministically.")
            return false
    return true

func _cultivation_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    return errors

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
