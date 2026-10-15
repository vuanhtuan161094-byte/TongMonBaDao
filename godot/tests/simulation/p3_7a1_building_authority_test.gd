extends SceneTree

const TEST_SEED := 370071
const SAVE_PATH := "user://p3_7a1_building_authority_test.json"

var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var equipment := EquipmentSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_opt_in_boundary():
        return
    if not _verify_initial_mine_authority():
        return
    if not _verify_worker_slot_enforcement():
        return
    if not _verify_timed_upgrade_and_cost():
        return
    if not _verify_milestone_requires_real_component():
        return
    if not _verify_mining_travel_work_haul_cycle():
        return
    if not _verify_movement_speed_affects_mining_throughput():
        return
    if not _verify_save_load_and_deterministic_continuation():
        return
    print("P3.7A1 BUILDING AUTHORITY + MINE BACKEND TEST PASS")
    _cleanup()
    quit(0)

func _verify_opt_in_boundary() -> bool:
    var legacy := P212Factory.create_state(TEST_SEED)
    if legacy.p3_7_buildings_enabled:
        return _fail("P2.12 unexpectedly enables P3.7 building authority.")
    if not legacy.buildings.is_empty() or legacy.building_event_count != 0:
        return _fail("P2.12 unexpectedly contains P3.7 building state.")
    if legacy.sect.p3_7_resources_enabled or not legacy.sect.warehouse_resources.is_empty():
        return _fail("P2.12 unexpectedly enables P3.7 warehouse authority.")
    return true

func _verify_initial_mine_authority() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 1)
    if not state.p3_7_buildings_enabled:
        return _fail("P3.7 factory did not enable building authority.")
    if not state.sect.p3_7_resources_enabled:
        return _fail("P3.7 factory did not enable canonical warehouse authority.")
    if not state.sect.forge_materials.is_empty() or not state.sect.technique_materials.is_empty():
        return _fail("P3.7 factory left duplicate legacy material buckets populated.")
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null:
        return _fail("P3.7 factory did not create the authoritative Mine.")
    if mine.level != 1 or mine.max_level != 100 or mine.status != BuildingSystem.STATUS_ACTIVE:
        return _fail("Initial Mine level/status contract is invalid.")
    if mine.worker_group_id != &"mining_crew":
        return _fail("Mine is not linked to the existing mining workforce group.")
    if buildings.worker_slots(mine) != 1:
        return _fail("Mine Lv1 worker-slot contract is invalid.")
    var active := buildings.active_worker_ids(state, mine)
    if active.size() != 1:
        return _fail("Fresh Mine did not bind exactly one valid mining worker.")
    return _validate(state)

func _verify_worker_slot_enforcement() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 10)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var owners := buildings.active_worker_ids(state, mine)
    if owners.size() != 1:
        return _fail("Mine fresh instance must start with one worker.")
    var first_id: StringName = owners[0]
    var second: DiscipleState = null
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var candidate: DiscipleState = state.disciples[raw_id]
        if candidate.work_group_id == &"" and candidate.id != first_id:
            second = candidate
            break
    if second == null:
        return _fail("Need unassigned worker to verify single Mine slot.")

    # A second group-only or explicit worksite assignment cannot create a
    # shadow/waiting mining worker.
    if workforce.assign_group(state, second.id, &"mining_crew"):
        return _fail("Full Mine accepted a shadow mining_crew assignment.")
    var blocked := workforce.assign_mine_worker(state, second.id, mine.id)
    if bool(blocked.get("ok", false)) or str(blocked.get("reason", "")) != "mine_full":
        return _fail("Full Mine accepted an unauthorized second operator.")
    if buildings.assigned_worker_ids(state, mine).size() != 1:
        return _fail("Failed Mine allocation mutated canonical assignment.")
    _normalize_worker(second)
    var not_working := workforce.perform_work(state, second, WorkforceSystem.PROF_MINING)
    if bool(not_working.get("ok", false)) or str(not_working.get("reason", "")) != "no_active_mine_slot":
        return _fail("Unassigned worker can still extract from full Mine.")

    # Independent second Mine is allowed and owns one different disciple.
    var second_mine := buildings.create_building(BuildingSystem.TYPE_MINE, 2)
    state.buildings[str(second_mine.id)] = second_mine
    var assigned := workforce.assign_mine_worker(state, second.id, second_mine.id)
    if not bool(assigned.get("ok", false)):
        return _fail("Second Mine could not accept a separate real worker.")
    if buildings.active_worker_ids(state, second_mine) != [second.id]:
        return _fail("Second Mine did not store its own one-worker assignment.")
    if buildings.active_worker_ids(state, mine) != [first_id]:
        return _fail("Second Mine assignment displaced first Mine worker.")
    return _validate(state)

func _verify_timed_upgrade_and_cost() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 2)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var cost := buildings.upgrade_cost(mine)
    var wood_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_WOOD))
    var ore_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
    var stones_before := state.sect.spirit_stones

    var started := buildings.start_upgrade(state, mine.id)
    if not bool(started.get("ok", false)):
        return _fail("Mine Lv1 -> Lv2 upgrade could not start with seeded resources.")
    if mine.level != 1 or mine.status != BuildingSystem.STATUS_UPGRADING or mine.upgrade_target_level != 2:
        return _fail("Upgrade button applied level immediately instead of entering timed construction.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_WOOD)) != wood_before - int(cost.get(BuildingSystem.MATERIAL_WOOD, 0)):
        return _fail("Timed upgrade did not consume the exact Linh Mộc cost.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE)) != ore_before - int(cost.get(BuildingSystem.MATERIAL_ORE, 0)):
        return _fail("Timed upgrade did not consume the exact Khoáng cost.")
    if state.sect.spirit_stones != stones_before - int(cost.get("spirit_stones", 0)):
        return _fail("Timed upgrade did not consume the exact Linh Thạch cost.")

    var required := int(ceil(mine.upgrade_required_work))
    for _i in range(maxi(required - 1, 0)):
        buildings.process_tick(state)
    if mine.level != 1:
        return _fail("Mine level changed before construction time completed.")

    buildings.process_tick(state)
    if mine.level != 2 or mine.status != BuildingSystem.STATUS_ACTIVE:
        return _fail("Mine did not apply Lv2 exactly when construction completed.")
    if int(mine.metrics.get("upgrade_completions", 0)) != 1:
        return _fail("Mine upgrade completion metric was not recorded.")

    var next_check := buildings.can_start_upgrade(state, mine.id)
    if not bool(next_check.get("ok", false)):
        return _fail("Mine has a fake post-upgrade cooldown; Lv3 should be immediately startable when resources are sufficient.")
    return _validate(state)

func _verify_milestone_requires_real_component() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 20)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    mine.level = 9
    warehouse.add(state, StringName(BuildingSystem.MATERIAL_WOOD), 1000)
    warehouse.add(state, StringName(BuildingSystem.MATERIAL_ORE), 1000)
    state.sect.spirit_stones = 1000
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_TAM_MACH_BAN)) != 0:
        return _fail("Milestone probe unexpectedly started with Tầm Mạch Bàn.")

    var blocked := buildings.can_start_upgrade(state, mine.id)
    if bool(blocked.get("ok", false)) or str(blocked.get("material_id", "")) != BuildingSystem.MATERIAL_TAM_MACH_BAN:
        return _fail("Mine Lv9 -> Lv10 did not require the real Tầm Mạch Bàn milestone component.")

    warehouse.add(state, StringName(BuildingSystem.MATERIAL_TAM_MACH_BAN), 1)
    var started := buildings.start_upgrade(state, mine.id)
    if not bool(started.get("ok", false)):
        return _fail("Mine Lv9 -> Lv10 could not start after supplying Tầm Mạch Bàn.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_TAM_MACH_BAN)) != 0:
        return _fail("Mine milestone upgrade did not consume Tầm Mạch Bàn.")

    var required := int(ceil(mine.upgrade_required_work))
    for _i in range(required):
        buildings.process_tick(state)
    if mine.level != 10 or not mine.unlocked_milestones.has(10):
        return _fail("Mine Lv10 milestone did not unlock after timed construction.")
    if buildings.worker_slots(mine) != 1:
        return _fail("Mine Lv10 must retain exactly one operator.")
    return _validate(state)

func _verify_mining_travel_work_haul_cycle() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 3)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var workers := buildings.active_worker_ids(state, mine)
    if workers.is_empty():
        return _fail("Mine has no active worker for the mining-cycle test.")
    var actor: DiscipleState = state.disciples[workers[0]]
    _normalize_worker(actor)
    var ore_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
    var xp_before := workforce.profession_xp(actor, WorkforceSystem.PROF_MINING)
    var phases: Dictionary = {}

    var completed := false
    for _i in range(40):
        var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_MINING)
        if not bool(result.get("ok", false)):
            return _fail("P3.7 mining work step unexpectedly failed.")
        phases[str(result.get("phase", ""))] = true
        phases[str(result.get("next_phase", ""))] = true
        if bool(result.get("completed", false)):
            completed = true
            if str(result.get("deposited_to", "")) != "sect_main_warehouse":
                return _fail("Mining batch did not route through the canonical main warehouse destination.")
            break

    if not completed:
        return _fail("Mining did not complete travel -> work -> haul within the expected bounded steps.")
    for required_phase in ["travel_out", "mining", "haul_back"]:
        if not phases.has(required_phase):
            return _fail("Mining cycle never entered phase %s." % required_phase)
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE)) <= ore_before:
        return _fail("Mining batch completed without depositing real Thanh Thiết.")
    if workforce.profession_xp(actor, WorkforceSystem.PROF_MINING) <= xp_before:
        return _fail("Mining batch completed without granting real Mining profession XP.")
    if int(mine.metrics.get("production_batches", 0)) <= 0 or int(mine.metrics.get("units_produced", 0)) <= 0:
        return _fail("Mine building metrics did not record real production.")
    return _validate(state)

func _verify_movement_speed_affects_mining_throughput() -> bool:
    var fast_state := P37Factory.create_state(TEST_SEED + 4)
    var slow_state := P37Factory.create_state(TEST_SEED + 4)
    var fast_mine := buildings.primary_building(fast_state, BuildingSystem.TYPE_MINE)
    var slow_mine := buildings.primary_building(slow_state, BuildingSystem.TYPE_MINE)
    var fast_ids := buildings.active_worker_ids(fast_state, fast_mine)
    var slow_ids := buildings.active_worker_ids(slow_state, slow_mine)
    if fast_ids.is_empty() or slow_ids.is_empty():
        return _fail("Movement-speed test has no active miner.")

    var fast: DiscipleState = fast_state.disciples[fast_ids[0]]
    var slow: DiscipleState = slow_state.disciples[slow_ids[0]]
    _normalize_worker(fast)
    _normalize_worker(slow)

    slow_state.sect.equipment_items["slow_armor_probe"] = {
        "id": "slow_armor_probe",
        "recipe_id": "tinh_lang_giap",
        "name": "Trọng Giáp Thử Nghiệm",
        "slot": "armor",
        "quality": "pham",
        "path": "body",
        "element": "earth",
        "stats": {"move_speed": -0.25},
        "price": 1,
        "location": "storage",
        "owner_id": ""
    }
    if not equipment.manual_equip(slow_state, slow.id, &"slow_armor_probe", true):
        return _fail("Could not equip movement-speed probe armor.")

    var fast_steps := _steps_until_deposit(fast_state, fast)
    var slow_steps := _steps_until_deposit(slow_state, slow)
    if fast_steps <= 0 or slow_steps <= 0:
        return _fail("Movement-speed mining probe did not finish.")
    if slow_steps <= fast_steps:
        return _fail("Lower movement speed did not increase mining travel/haul cycle time.")
    return _validate(slow_state)

func _verify_save_load_and_deterministic_continuation() -> bool:
    var state_a := P37Factory.create_state(TEST_SEED + 5)
    var mine := buildings.primary_building(state_a, BuildingSystem.TYPE_MINE)
    if not bool(buildings.start_upgrade(state_a, mine.id).get("ok", false)):
        return _fail("Persistence probe could not start building upgrade.")
    buildings.process_tick(state_a)
    buildings.process_tick(state_a)

    var workers := buildings.active_worker_ids(state_a, mine)
    if workers.is_empty():
        return _fail("Persistence probe has no miner.")
    var actor: DiscipleState = state_a.disciples[workers[0]]
    _normalize_worker(actor)
    workforce.perform_work(state_a, actor, WorkforceSystem.PROF_MINING)
    workforce.perform_work(state_a, actor, WorkforceSystem.PROF_MINING)
    if actor.work_cycle_state.is_empty():
        return _fail("Persistence probe did not create a mining work-cycle state.")

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P3.7A1 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("P3.7A1 load failed.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P3.7A1 exact save/load state diverged mid-upgrade/mid-work-cycle: %s" % _first_difference(state_a.to_dict(), loaded.to_dict(), "state"))

    SimulationScheduler.new(state_a).run_ticks(60)
    SimulationScheduler.new(loaded).run_ticks(60)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P3.7A1 deterministic continuation diverged after save/load.")
    return _validate(loaded)

func _steps_until_deposit(state: SimulationState, disciple: DiscipleState) -> int:
    disciple.work_cycle_state.clear()
    disciple.stamina = 100.0
    for step in range(1, 50):
        var result := workforce.perform_work(state, disciple, WorkforceSystem.PROF_MINING)
        if not bool(result.get("ok", false)):
            return -1
        if bool(result.get("completed", false)):
            return step
    return -1

func _normalize_worker(disciple: DiscipleState) -> void:
    disciple.comprehension = 0.0
    disciple.constitution = 0.0
    FoundationSystem.new().recompute_disciple_quality(disciple)
    disciple.profession_xp[str(WorkforceSystem.PROF_MINING)] = 0.0
    # Keep the persistence probe in a canonical P3.7 profile state; this test
    # is about building/work-cycle persistence, not profile migration.
    disciple.profession_traits = [str(WorkforceSystem.TRAIT_FORGE)]
    disciple.profession_trait_grades = {str(WorkforceSystem.TRAIT_FORGE): 1}
    disciple.cultivation_path_xp.clear()
    disciple.work_cycle_state.clear()
    disciple.stamina = 100.0
    disciple.hp = disciple.max_hp

func _validate(state: SimulationState) -> bool:
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
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    if not errors.is_empty():
        return _fail("Invariant failure: %s" % " | ".join(errors))
    return true

func _first_difference(left: Variant, right: Variant, path: String) -> String:
    if typeof(left) != typeof(right):
        return "%s type %s != %s" % [path, type_string(typeof(left)), type_string(typeof(right))]
    if left is Dictionary:
        var left_keys: Array = left.keys()
        var right_keys: Array = right.keys()
        left_keys.sort()
        right_keys.sort()
        if left_keys != right_keys:
            return "%s keys %s != %s" % [path, left_keys, right_keys]
        for key in left_keys:
            var nested := _first_difference(left[key], right[key], "%s.%s" % [path, str(key)])
            if nested != "":
                return nested
        return ""
    if left is Array:
        if left.size() != right.size():
            return "%s size %d != %d" % [path, left.size(), right.size()]
        for index in range(left.size()):
            var nested := _first_difference(left[index], right[index], "%s[%d]" % [path, index])
            if nested != "":
                return nested
        return ""
    if left != right:
        return "%s %s != %s" % [path, str(left), str(right)]
    return ""

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
