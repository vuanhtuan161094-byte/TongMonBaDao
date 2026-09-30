extends SceneTree

const TEST_SEED := 1222222
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p2_2_spiritual_roots_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var roots := SpiritualRootSystem.new()
    var state_a := P22Factory.create_state(TEST_SEED)
    var state_b := P22Factory.create_state(TEST_SEED)

    if not state_a.sect.spiritual_roots_enabled or not state_a.sect.cultivation_enabled:
        _fail("P2.2 factory did not preserve P2.1 cultivation and enable spiritual roots.")
        return
    if state_a.to_dict() != state_b.to_dict():
        _fail("Same-seed P2.2 initial root assignment diverged.")
        return
    if not roots.validate_invariants(state_a).is_empty():
        _fail("P2.2 initial root assignment violated invariants.")
        return

    if not _verify_p21_path_stays_unchanged():
        return
    if not _verify_root_changes_cultivation_speed():
        return
    if not _verify_root_changes_breakthrough_chance():
        return
    if not _verify_mixed_root_has_no_realm_cap():
        return
    if not _verify_recruitment_rng_and_root_transfer():
        return

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)

    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.2 same-seed deterministic simulation diverged.")
        return

    var errors := _all_invariants(state_a)
    if not errors.is_empty():
        _fail("P2.2 invariant failure: %s" % " | ".join(errors))
        return

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        _fail("P2.2 save failed.")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.spiritual_roots_enabled:
        _fail("P2.2 save could not restore spiritual roots.")
        return
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.2 spiritual-root state was not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)

    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.2 deterministic continuation diverged after save/load.")
        return
    errors = _all_invariants(loaded)
    if not errors.is_empty():
        _fail("P2.2 resumed invariant failure: %s" % " | ".join(errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    var quality_counts: Dictionary = {}
    for disciple_value in loaded.disciples.values():
        var disciple: DiscipleState = disciple_value
        var key := str(disciple.spiritual_root_quality)
        quality_counts[key] = int(quality_counts.get(key, 0)) + 1

    print("P2.2 SPIRITUAL ROOT + GROWTH CONSEQUENCE TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " disciples=", loaded.disciples.size(), " root_events=", loaded.sect.spiritual_root_event_count, " qualities=", quality_counts)
    quit(0)

func _verify_p21_path_stays_unchanged() -> bool:
    var state := P21Factory.create_state(TEST_SEED + 1)
    var cultivation := CultivationSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")

    if state.sect.spiritual_roots_enabled or actor.spiritual_root_quality != &"":
        _fail("P2.1 path unexpectedly enabled P2.2 spiritual roots.")
        return false
    actor.region_id = &"sect"
    actor.stamina = 100.0
    actor.cultivation_progress = 0.0
    var gained := cultivation.cultivate(state, actor)
    if absf(gained - CultivationSystem.CULTIVATE_GAIN) > 0.000001:
        _fail("P2.2 changed the locked P2.1 base cultivation gain when roots are disabled.")
        return false
    return true

func _verify_root_changes_cultivation_speed() -> bool:
    var state := P22Factory.create_state(TEST_SEED + 2)
    var cultivation := CultivationSystem.new()
    var mixed: DiscipleState = state.disciples.get(&"tran_mac")
    var heaven: DiscipleState = state.disciples.get(&"co_truong_phong")

    mixed.spiritual_root_quality = SpiritualRootSystem.QUALITY_MIXED
    heaven.spiritual_root_quality = SpiritualRootSystem.QUALITY_HEAVEN
    for disciple in [mixed, heaven]:
        disciple.region_id = &"sect"
        disciple.stamina = 100.0
        disciple.cultivation_progress = 0.0
        disciple.combat_power = 18.0

    var mixed_gain := cultivation.cultivate(state, mixed)
    var heaven_gain := cultivation.cultivate(state, heaven)
    if absf(mixed_gain - 6.0) > 0.000001:
        _fail("Tạp linh căn did not apply the 0.75x cultivation multiplier.")
        return false
    if absf(heaven_gain - 11.6) > 0.000001:
        _fail("Thiên linh căn did not apply the 1.45x cultivation multiplier.")
        return false
    if heaven_gain <= mixed_gain:
        _fail("Higher root quality did not create measurable long-term growth value.")
        return false

    mixed.cultivation_progress = 0.0
    heaven.cultivation_progress = 0.0
    for _i in range(10):
        cultivation.add_progress(state, mixed, CultivationSystem.CULTIVATE_GAIN)
        cultivation.add_progress(state, heaven, CultivationSystem.CULTIVATE_GAIN)
    if heaven.cultivation_progress <= mixed.cultivation_progress:
        _fail("Equal current-power disciples did not diverge in long-term cultivation growth by root quality.")
        return false
    return true

func _verify_root_changes_breakthrough_chance() -> bool:
    var state := P22Factory.create_state(TEST_SEED + 3)
    var cultivation := CultivationSystem.new()
    var mixed: DiscipleState = state.disciples.get(&"tran_mac")
    var heaven: DiscipleState = state.disciples.get(&"co_truong_phong")

    for disciple in [mixed, heaven]:
        disciple.cultivation_stage_index = 8
        disciple.hp = disciple.max_hp
        disciple.stamina = 100.0
        disciple.next_breakthrough_tick = 0
    mixed.spiritual_root_quality = SpiritualRootSystem.QUALITY_MIXED
    heaven.spiritual_root_quality = SpiritualRootSystem.QUALITY_HEAVEN

    var mixed_chance := cultivation.breakthrough_success_chance(mixed, state)
    var heaven_chance := cultivation.breakthrough_success_chance(heaven, state)
    if heaven_chance <= mixed_chance:
        _fail("Higher root quality did not improve breakthrough chance.")
        return false
    if absf((heaven_chance - mixed_chance) - 0.18) > 0.000001:
        _fail("P2.2 breakthrough modifiers were not applied as configured.")
        return false
    return true

func _verify_mixed_root_has_no_realm_cap() -> bool:
    var state := P22Factory.create_state(TEST_SEED + 4)
    var actor: DiscipleState = state.disciples.get(&"lam_an")
    actor.spiritual_root_quality = SpiritualRootSystem.QUALITY_MIXED
    if not _advance_to_stage(state, actor, 9):
        return false
    if actor.cultivation_stage_index != 9:
        _fail("Tạp linh căn was incorrectly blocked below Trúc Cơ.")
        return false
    return true

func _verify_recruitment_rng_and_root_transfer() -> bool:
    var legacy := P21Factory.create_state(TEST_SEED + 5)
    var rooted := P22Factory.create_state(TEST_SEED + 5)
    var recruitment := RecruitmentSystem.new()
    var roots := SpiritualRootSystem.new()

    var legacy_next := recruitment.generate_candidate(legacy)
    var rooted_next := recruitment.generate_candidate(rooted)
    if legacy_next == null or rooted_next == null:
        _fail("P2.2 recruitment probe could not generate comparison candidates.")
        return false

    for key in ["id", "name", "combat_power", "risk_bias", "spend_bias", "survival_bias", "personality_id", "generated_index"]:
        if legacy_next.to_dict().get(key) != rooted_next.to_dict().get(key):
            _fail("Spiritual-root generation changed legacy candidate field %s." % key)
            return false
    if legacy_next.spiritual_root_quality != &"":
        _fail("Legacy P2.1 candidate unexpectedly received a spiritual root.")
        return false
    if not SpiritualRootSystem.VALID_QUALITIES.has(rooted_next.spiritual_root_quality):
        _fail("P2.2 future candidate did not receive a valid deterministic spiritual root.")
        return false

    var candidate_ids: Array = rooted.recruitment_candidates.keys()
    candidate_ids.sort()
    var candidate_id := StringName(candidate_ids[0])
    var candidate: CandidateState = rooted.recruitment_candidates[candidate_id]
    var expected_root := candidate.spiritual_root_quality
    var result := recruitment.accept_candidate(rooted, candidate_id)
    if not bool(result.get("ok", false)):
        _fail("P2.2 could not accept a valid rooted candidate.")
        return false
    var recruit: DiscipleState = rooted.disciples.get(candidate_id)
    if recruit == null or recruit.spiritual_root_quality != expected_root:
        _fail("Accepted candidate did not preserve spiritual-root quality.")
        return false

    recruit.region_id = &"sect"
    recruit.stamina = 100.0
    recruit.cultivation_progress = 0.0
    var gained := CultivationSystem.new().cultivate(rooted, recruit)
    var expected_gain := CultivationSystem.CULTIVATE_GAIN * roots.cultivation_multiplier(expected_root)
    if absf(gained - expected_gain) > 0.000001:
        _fail("Accepted candidate spiritual root did not affect real cultivation growth.")
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
            _fail("P2.2 test helper could not advance a root quality without a hard realm cap.")
            return false
    return true

func _all_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    return errors

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
