extends SceneTree

const TEST_SEED := 37013701
const SAVE_PATH := "user://p3_7a_building_authority_test.json"

var building_system := BuildingSystem.new()
var workforce := WorkforceSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_legacy_baseline_is_opt_in():
        return
    if not _verify_factory_and_mine_authority():
        return
    if not _verify_timed_upgrade_consumes_real_resources():
        return
    if not _verify_milestone_completion():
        return
    if not _verify_mining_travel_work_haul_cycle():
        return
    if not _verify_worker_slot_gate():
        return
    if not _verify_save_load_and_deterministic_continuation():
        return

    print("P3.7A BUILDING AUTHORITY + MINE CYCLE TEST PASS")
    _cleanup()
    quit(0)

func _verify_legacy_baseline_is_opt_in() -> bool:
    var legacy := P212Factory.create_state(TEST_SEED)
    if legacy.p3_7_buildings_enabled:
        return _fail("P2.12 unexpectedly enabled P3.7 buildings.")
    if not legacy.buildings.is_empty() or legacy.building_event_count != 0:
        return _fail("P2.12 unexpectedly contains P3.7 building runtime state.")
    if legacy.to_dict().has("p3_7_buildings_enabled") or legacy.to_dict().has("buildings"):
        return _fail("P2.12 serialization leaked opt-in P3.7 building fields.")
    return true

func _verify_factory_and_mine_authority() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 1)
    if not state.p3_7_buildings_enabled:
        return _fail("P3.7 factory did not enable building authority.")

    var mine := building_system.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null:
        return _fail("P3.7 factory did not create the primary Mine.")
    if mine.level != 1 or mine.max_level != 100:
        return _fail("Mine did not start at the canonical Lv.1/100 cap.")
    if mine.worker_group_id != &"mining_crew":
        return _fail("Mine is not bound to the real P2.7 mining crew.")
    if building_system.worker_slots(mine) != 2:
        return _fail("Lv.1 Mine did not expose the expected two real worker slots.")

    var errors := _all_invariants(state)
    if not errors.is_empty():
        return _fail("P3.7 factory invariant failure: %s" % " | ".join(errors))
    return true

func _verify_timed_upgrade_consumes_real_resources() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 2)
    var mine := building_system.primary_building(state, BuildingSystem.TYPE_MINE)
    var cost := building_system.upgrade_cost(mine)
    if cost.is_empty():
        return _fail("Mine Lv.1 returned no upgrade cost.")

    var wood_before := int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_WOOD, 0))
    var ore_before := int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0))
    var stones_before := state.sect.spirit_stones
    var p0_money_before := state.total_money()

    var result := building_system.start_upgrade(state, mine.id)
    if not bool(result.get("ok", false)):
        return _fail("Mine upgrade could not start with seeded real resources: %s" % str(result))

    if mine.level != 1 or not mine.is_upgrading() or mine.upgrade_target_level != 2:
        return _fail("Mine upgrade applied the level instantly instead of entering timed construction.")
    if int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_WOOD, 0)) != wood_before - int(cost.get(BuildingSystem.MATERIAL_WOOD, 0)):
        return _fail("Mine upgrade did not consume the exact real Linh Mộc cost.")
    if int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0)) != ore_before - int(cost.get(BuildingSystem.MATERIAL_ORE, 0)):
        return _fail("Mine upgrade did not consume the exact real Khoáng cost.")
    if state.sect.spirit_stones != stones_before - int(cost.get("spirit_stones", 0)):
        return _fail("Mine upgrade did not consume the exact sect Spirit Stone cost.")
    if state.total_money() != p0_money_before:
        return _fail("P3.7 construction illegally changed the locked P0 money economy.")

    var required_ticks := int(ceil(mine.upgrade_required_work))
    if required_ticks <= 1:
        return _fail("Mine timed upgrade completed too quickly to prove construction duration.")

    for _i in range(required_ticks - 1):
        building_system.process_tick(state)
    if mine.level != 1 or not mine.is_upgrading():
        return _fail("Mine completed before its required construction work elapsed.")

    building_system.process_tick(state)
    if mine.level != 2 or mine.is_upgrading():
        return _fail("Mine did not apply Lv.2 exactly when construction completed.")
    if int(mine.metrics.get("upgrade_completions", 0)) != 1:
        return _fail("Mine completion metric was not recorded.")
    if not bool(building_system.can_start_upgrade(state, mine.id).get("ok", false)):
        return _fail("Mine has an unintended post-upgrade cooldown.")
    return true

func _verify_milestone_completion() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 3)
    var mine := building_system.primary_building(state, BuildingSystem.TYPE_MINE)
    mine.level = 9

    var check := building_system.can_start_upgrade(state, mine.id)
    if not bool(check.get("ok", false)):
        return _fail("Seeded resources were insufficient for the Lv.9 -> Lv.10 milestone probe: %s" % str(check))

    var result := building_system.start_upgrade(state, mine.id)
    if not bool(result.get("ok", false)):
        return _fail("Lv.10 milestone upgrade could not start.")

    while mine.is_upgrading():
        building_system.process_tick(state)

    if mine.level != 10 or not mine.unlocked_milestones.has(10):
        return _fail("Mine Lv.10 completion did not persist the milestone unlock.")
    return true

func _verify_mining_travel_work_haul_cycle() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 4)
    var mine := building_system.primary_building(state, BuildingSystem.TYPE_MINE)
    var workers := building_system.active_worker_ids(state, mine)
    if workers.is_empty():
        return _fail("Mine has no active worker from the real mining crew.")

    var actor: DiscipleState = state.disciples[workers[0]]
    actor.region_id = &"sect"
    actor.hp = actor.max_hp
    actor.stamina = 100.0
    actor.work_cycle_state.clear()
    actor.direct_command.clear()

    var ore_before := int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0))
    var xp_before := workforce.profession_xp(actor, WorkforceSystem.PROF_MINING)
    var seen_phases: Dictionary = {}
    var completed := false
    var produced := 0

    for _i in range(40):
        var ore_step_before := int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0))
        var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_MINING)
        if not bool(result.get("ok", false)):
            return _fail("Active Mine worker could not continue the physical mining cycle: %s" % str(result))
        seen_phases[str(result.get("phase", ""))] = true

        if bool(result.get("completed", false)):
            completed = true
            produced = int(result.get("produced", 0))
            if str(result.get("deposited_to", "")) != "sect_main_warehouse":
                return _fail("Mining batch did not report deposit to the canonical main Sect Warehouse.")
            break

        if int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0)) != ore_step_before:
            return _fail("Ore entered storage before the haul/deposit phase completed.")

    if not completed or produced <= 0:
        return _fail("Mining did not complete travel -> work -> haul/deposit within the bounded probe.")
    for expected_phase in ["travel_out", "mining", "haul_back"]:
        if not seen_phases.has(expected_phase):
            return _fail("Mining cycle never exposed phase %s." % expected_phase)

    if int(state.sect.forge_materials.get(BuildingSystem.MATERIAL_ORE, 0)) != ore_before + produced:
        return _fail("Completed mining batch did not add the exact produced amount to sect storage.")
    if workforce.profession_xp(actor, WorkforceSystem.PROF_MINING) <= xp_before:
        return _fail("Completed physical mining batch did not grant Mining profession XP.")
    if StringName(actor.work_cycle_state.get("phase", "")) != &"travel_out":
        return _fail("Mining cycle did not reset to travel_out after deposit.")
    return true

func _verify_worker_slot_gate() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 5)
    var mine := building_system.primary_building(state, BuildingSystem.TYPE_MINE)
    var assigned := building_system.assigned_worker_ids(state, mine)
    if assigned.size() < 2:
        return _fail("Worker-slot probe needs the two canonical P2.7 miners.")

    var ids: Array = state.disciples.keys()
    ids.sort()
    var extra: DiscipleState = null
    for raw_id in ids:
        var candidate: DiscipleState = state.disciples[raw_id]
        if not assigned.has(candidate.id):
            extra = candidate
            break
    if extra == null:
        return _fail("Worker-slot probe could not find an extra disciple.")

    extra.work_group_id = &"mining_crew"
    extra.region_id = &"sect"
    extra.stamina = 100.0
    var active := building_system.active_worker_ids(state, mine)
    if active.size() != building_system.worker_slots(mine):
        return _fail("Mine active worker count ignored its real slot count.")
    if active.has(extra.id):
        return _fail("Deterministic worker-slot ordering unexpectedly displaced the canonical miners.")

    var result := workforce.perform_work(state, extra, WorkforceSystem.PROF_MINING)
    if bool(result.get("ok", false)) or str(result.get("reason", "")) != "no_active_mine_slot":
        return _fail("Extra miner bypassed the Mine worker-slot gate.")
    return true

func _verify_save_load_and_deterministic_continuation() -> bool:
    var state_a := P37Factory.create_state(TEST_SEED + 6)
    var mine_a := building_system.primary_building(state_a, BuildingSystem.TYPE_MINE)
    var start := building_system.start_upgrade(state_a, mine_a.id)
    if not bool(start.get("ok", false)):
        return _fail("Persistence probe could not start a Mine upgrade.")

    var workers := building_system.active_worker_ids(state_a, mine_a)
    if workers.is_empty():
        return _fail("Persistence probe has no Mine worker.")
    var actor_a: DiscipleState = state_a.disciples[workers[0]]
    actor_a.region_id = &"sect"
    actor_a.hp = actor_a.max_hp
    actor_a.stamina = 100.0
    workforce.perform_work(state_a, actor_a, WorkforceSystem.PROF_MINING)
    building_system.process_tick(state_a)
    building_system.process_tick(state_a)

    var save := SaveService.new()
    if save.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P3.7A save failed.")
    var loaded := save.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("P3.7A save did not load.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P3.7A building/work-cycle state diverged across exact save/load.")

    var loaded_mine := building_system.primary_building(loaded, BuildingSystem.TYPE_MINE)
    if loaded_mine == null or not loaded_mine.is_upgrading():
        return _fail("Mid-construction Mine state was not restored.")
    var loaded_actor: DiscipleState = loaded.disciples[actor_a.id]
    if loaded_actor.work_cycle_state.is_empty():
        return _fail("Mid-cycle mining state was not restored.")

    SimulationScheduler.new(state_a).run_ticks(40)
    SimulationScheduler.new(loaded).run_ticks(40)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P3.7A deterministic continuation diverged after save/load.")

    var errors := _all_invariants(loaded)
    if not errors.is_empty():
        return _fail("P3.7A invariant failure after continuation: %s" % " | ".join(errors))
    _cleanup()
    return true

func _all_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    errors.append_array(EquipmentSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    errors.append_array(TraitSystem.new().validate_invariants(state))
    errors.append_array(RootRefinementSystem.new().validate_invariants(state))
    errors.append_array(BloodlineSystem.new().validate_invariants(state))
    errors.append_array(PhysiqueSystem.new().validate_invariants(state))
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
