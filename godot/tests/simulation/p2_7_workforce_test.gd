extends SceneTree

const TEST_SEED := 1727272
const SAVE_PATH := "user://p2_7_workforce_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var legacy := P26Factory.create_state(TEST_SEED)
    if legacy.sect.workforce_enabled:
        _fail("P2.6 must remain workforce-disabled.")
        return

    var state := P27Factory.create_state(TEST_SEED)
    if not state.sect.workforce_enabled or not state.sect.equipment_enabled:
        _fail("P2.7 factory did not preserve P2.6 and enable workforce.")
        return

    if not _verify_deterministic_profiles():
        return
    if not _verify_profession_progress_and_real_mining_output():
        return
    if not _verify_schedule_reserves_work_cultivation_and_recovery():
        return
    if not _verify_direct_command_overrides_and_returns_to_auto():
        return
    if not _verify_forge_work_changes_real_p2_6_craft():
        return
    if not _verify_recruitment_has_noncombat_value():
        return
    if not _verify_persistence_and_continuation():
        return

    print("P2.7 DISCIPLE LIFE + WORKFORCE TEST PASS")
    quit(0)

func _verify_deterministic_profiles() -> bool:
    var state_a := P27Factory.create_state(TEST_SEED + 1)
    var state_b := P27Factory.create_state(TEST_SEED + 1)
    var ids: Array = state_a.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var a: DiscipleState = state_a.disciples[raw_id]
        var b: DiscipleState = state_b.disciples[raw_id]
        if a.comprehension != b.comprehension or a.profession_traits != b.profession_traits or a.work_group_id != b.work_group_id:
            _fail("P2.7 same-seed disciple workforce profile diverged for %s." % raw_id)
            return false
    return true

func _verify_profession_progress_and_real_mining_output() -> bool:
    var novice_state := P27Factory.create_state(TEST_SEED + 2)
    var expert_state := P27Factory.create_state(TEST_SEED + 2)
    var workforce := WorkforceSystem.new()
    var novice: DiscipleState = novice_state.disciples.get(&"bach_nguyet")
    var expert: DiscipleState = expert_state.disciples.get(&"bach_nguyet")
    for actor in [novice, expert]:
        actor.comprehension = 0.50
        actor.profession_traits = []
        actor.profession_xp = {}
        actor.work_progress = {}
        actor.stamina = 100.0
    expert.profession_xp["mining"] = 380.0
    novice_state.sect.forge_materials["thanh_thiet"] = 0
    expert_state.sect.forge_materials["thanh_thiet"] = 0

    var novice_xp_before := workforce.profession_xp(novice, WorkforceSystem.PROF_MINING)
    for _i in range(4):
        workforce.perform_work(novice_state, novice, WorkforceSystem.PROF_MINING)
        workforce.perform_work(expert_state, expert, WorkforceSystem.PROF_MINING)

    var novice_yield := int(novice_state.sect.forge_materials.get("thanh_thiet", 0))
    var expert_yield := int(expert_state.sect.forge_materials.get("thanh_thiet", 0))
    if novice_yield <= 0:
        _fail("P2.7 mining work did not create real Thanh Thiết in P2.6 forge storage.")
        return false
    if expert_yield <= novice_yield:
        _fail("P2.7 experienced miner did not outperform the novice miner.")
        return false
    if workforce.profession_xp(novice, WorkforceSystem.PROF_MINING) <= novice_xp_before:
        _fail("P2.7 completed work did not increase profession XP.")
        return false
    return true

func _verify_schedule_reserves_work_cultivation_and_recovery() -> bool:
    var state := P27Factory.create_state(TEST_SEED + 3)
    var workforce := WorkforceSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.region_id = &"sect"
    actor.hp = actor.max_hp
    actor.stamina = 100.0
    actor.work_group_id = &""
    actor.work_preferences = {"mining":4}

    var seen := {}
    var work_tick := -1
    var cultivate_tick := -1
    var recovery_tick := -1
    for tick in range(0, WorkforceSystem.SCHEDULE_CYCLE):
        state.tick = tick
        var phase := str(workforce.schedule_phase(state, actor))
        seen[phase] = true
        if phase == "work" and work_tick < 0:
            work_tick = tick
        elif phase == "cultivate" and cultivate_tick < 0:
            cultivate_tick = tick
        elif phase == "recovery" and recovery_tick < 0:
            recovery_tick = tick
    if not seen.has("work") or not seen.has("cultivate") or not seen.has("recovery"):
        _fail("P2.7 balanced schedule did not reserve work/cultivation/recovery time.")
        return false

    state.tick = work_tick
    if workforce.next_action(state, actor) != &"WORK_MINING":
        _fail("P2.7 work schedule did not choose the assigned mining profession.")
        return false
    state.tick = cultivate_tick
    if workforce.next_action(state, actor) != &"CULTIVATE":
        _fail("P2.7 cultivation schedule did not interrupt routine work.")
        return false
    actor.stamina = 70.0
    state.tick = recovery_tick
    if workforce.next_action(state, actor) != &"REST":
        _fail("P2.7 recovery schedule did not reserve recovery behavior.")
        return false
    return true

func _verify_direct_command_overrides_and_returns_to_auto() -> bool:
    var state := P27Factory.create_state(TEST_SEED + 4)
    var workforce := WorkforceSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    actor.region_id = &"sect"
    actor.hp = actor.max_hp
    actor.stamina = 100.0
    actor.work_group_id = &""
    actor.work_preferences = {"mining":4, "forging":0}
    actor.profession_xp = {}
    actor.work_progress = {}

    var work_tick := _find_phase_tick(state, actor, &"work")
    state.tick = work_tick
    if workforce.next_action(state, actor) != &"WORK_MINING":
        _fail("P2.7 direct-command probe did not start from autonomous mining.")
        return false
    if not workforce.issue_command(state, actor.id, WorkforceSystem.COMMAND_WORK, "forging", 40):
        _fail("P2.7 Sect Master could not issue a direct profession command.")
        return false
    if workforce.next_action(state, actor) != &"WORK_FORGING":
        _fail("P2.7 direct Sect Master command did not override ordinary work preference.")
        return false

    for _i in range(8):
        workforce.perform_work(state, actor, WorkforceSystem.PROF_FORGING)
        if actor.direct_command.is_empty():
            break
    if not actor.direct_command.is_empty() or state.sect.forge_support_points <= 0:
        _fail("P2.7 completed direct work command did not complete/clear and produce forge support.")
        return false
    state.tick = work_tick
    if workforce.next_action(state, actor) != &"WORK_MINING":
        _fail("P2.7 disciple did not return to autonomous assignment after command completion.")
        return false
    return true

func _verify_forge_work_changes_real_p2_6_craft() -> bool:
    var base_state := P27Factory.create_state(TEST_SEED + 5)
    var supported_state := P27Factory.create_state(TEST_SEED + 5)
    _seed_materials(base_state)
    _seed_materials(supported_state)
    supported_state.sect.forge_support_points = 1
    var equipment := EquipmentSystem.new()
    var base_item := equipment.craft(base_state, &"thanh_thiet_kiem", false)
    var supported_item := equipment.craft(supported_state, &"thanh_thiet_kiem", false)
    if base_item.is_empty() or supported_item.is_empty():
        _fail("P2.7 forge-support probe could not craft controlled equipment.")
        return false
    var base_power := float(base_item.get("stats", {}).get("combat_power", 0.0))
    var supported_power := float(supported_item.get("stats", {}).get("combat_power", 0.0))
    if supported_power <= base_power or supported_state.sect.forge_support_points != 0:
        _fail("P2.7 forging work did not measurably improve and consume support on a real P2.6 craft.")
        return false
    return true

func _verify_recruitment_has_noncombat_value() -> bool:
    var state_a := P27Factory.create_state(TEST_SEED + 6)
    var state_b := P27Factory.create_state(TEST_SEED + 6)
    var recruitment := RecruitmentSystem.new()
    var candidate_a := recruitment.generate_candidate(state_a)
    var candidate_b := recruitment.generate_candidate(state_b)
    if candidate_a == null or candidate_b == null:
        _fail("P2.7 recruitment could not generate workforce-aware candidate.")
        return false
    if candidate_a.to_dict() != candidate_b.to_dict():
        _fail("P2.7 workforce candidate generation was not deterministic.")
        return false
    if candidate_a.comprehension <= 0.0 or candidate_a.comprehension > 1.0:
        _fail("P2.7 candidate lacks a valid non-combat learning aptitude.")
        return false
    if candidate_a.profession_traits.size() > 2:
        _fail("P2.7 candidate generated excessive profession traits.")
        return false
    return true

func _verify_persistence_and_continuation() -> bool:
    var state_a := P27Factory.create_state(TEST_SEED + 7)
    var state_b := P27Factory.create_state(TEST_SEED + 7)
    var workforce := WorkforceSystem.new()
    workforce.set_work_policy(state_a, WorkforceSystem.POLICY_PRODUCTION)
    workforce.set_work_policy(state_b, WorkforceSystem.POLICY_PRODUCTION)
    workforce.issue_command(state_a, &"bach_nguyet", WorkforceSystem.COMMAND_WORK, "mining", 25)
    workforce.issue_command(state_b, &"bach_nguyet", WorkforceSystem.COMMAND_WORK, "mining", 25)
    SimulationScheduler.new(state_a).run_ticks(120)
    SimulationScheduler.new(state_b).run_ticks(120)
    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.7 same-seed workforce simulation diverged.")
        return false

    var errors := _invariants(state_a)
    if not errors.is_empty():
        _fail("P2.7 invariant failure before save: %s" % " | ".join(errors))
        return false

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        _fail("P2.7 save failed.")
        return false
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.workforce_enabled:
        _fail("P2.7 save did not restore workforce state.")
        return false
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.7 workforce state was not preserved by save/load.")
        return false

    SimulationScheduler.new(state_a).run_ticks(160)
    SimulationScheduler.new(loaded).run_ticks(160)
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.7 deterministic continuation diverged after save/load.")
        return false

    errors = _invariants(loaded)
    if not errors.is_empty():
        _fail("P2.7 invariant failure after continuation: %s" % " | ".join(errors))
        return false
    _cleanup()
    return true

func _find_phase_tick(state: SimulationState, actor: DiscipleState, phase: StringName) -> int:
    var workforce := WorkforceSystem.new()
    for tick in range(0, WorkforceSystem.SCHEDULE_CYCLE):
        state.tick = tick
        if workforce.schedule_phase(state, actor) == phase:
            return tick
    return 0

func _seed_materials(state: SimulationState) -> void:
    state.sect.forge_materials = {"linh_moc":20, "thanh_thiet":20, "tinh_lang_bi":20, "yeu_dan":20}

func _invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    errors.append_array(EquipmentSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> void:
    _cleanup()
    push_error(message)
    quit(1)
