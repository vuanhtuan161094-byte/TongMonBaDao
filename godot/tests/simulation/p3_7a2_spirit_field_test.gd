extends SceneTree

const TEST_SEED := 370072
const SAVE_PATH := "user://p3_7a2_spirit_field_test.json"

var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_spirit_field_authority():
        return
    if not _verify_legacy_six_foundation_persistence():
        return
    if not _verify_plant_growth_harvest_lifecycle():
        return
    if not _verify_growth_does_not_hold_worker():
        return
    if not _verify_competing_workers_release_cleanly():
        return
    if not _verify_spirit_field_milestone_component():
        return
    if not _verify_growth_save_load_and_determinism():
        return
    print("P3.7A2 SPIRIT FIELD BACKEND TEST PASS")
    _cleanup()
    quit(0)

func _verify_spirit_field_authority() -> bool:
    var state := P37Factory.create_state(TEST_SEED)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        return _fail("P3.7 factory did not create the authoritative Spirit Field.")
    if field.level != 1 or field.max_level != 100:
        return _fail("Spirit Field level contract is invalid.")
    if field.worker_group_id != &"herbalism_crew":
        return _fail("Spirit Field is not bound to herbalism_crew.")
    if not state.sect.work_groups.has("herbalism_crew"):
        return _fail("P3.7 did not register the herbalism workforce group.")
    if buildings.worker_slots(field) != 2:
        return _fail("Spirit Field Lv1 worker-slot contract is invalid.")
    if not field.production_state.is_empty():
        return _fail("Fresh Spirit Field unexpectedly has active crop state.")
    return _validate(state)

func _verify_legacy_six_foundation_persistence() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 50)
    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        return _fail("Six-foundation persistence test has no disciple.")
    var actor: DiscipleState = state.disciples[ids[0]]
    actor.profile_seed = 0
    actor.recruitment_source = &""
    actor.race_id = &""
    actor.sex_id = &""
    actor.origin_id = &""
    actor.aptitude = 0.41
    actor.constitution = 0.62
    actor.fortune = 0.53
    actor.comprehension = 0.74
    actor.charisma = 0.36
    actor.potential = 0.88

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        return _fail("Six-foundation persistence probe save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("Six-foundation persistence probe load failed.")
    var restored: DiscipleState = loaded.disciples[actor.id]
    if not is_equal_approx(restored.aptitude, actor.aptitude):
        return _fail("Tư Chất was lost for legacy disciple save/load.")
    if not is_equal_approx(restored.constitution, actor.constitution):
        return _fail("Căn Cốt was lost for legacy disciple save/load.")
    if not is_equal_approx(restored.fortune, actor.fortune):
        return _fail("Cơ Duyên was lost for legacy disciple save/load.")
    if not is_equal_approx(restored.comprehension, actor.comprehension):
        return _fail("Thông Tuệ was lost for legacy disciple save/load.")
    if not is_equal_approx(restored.charisma, actor.charisma):
        return _fail("Mị Lực was lost for legacy disciple save/load.")
    if not is_equal_approx(restored.potential, actor.potential):
        return _fail("Tiềm Lực was lost for legacy disciple save/load.")
    _cleanup()
    return _validate(loaded)

func _verify_plant_growth_harvest_lifecycle() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 1)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var actor := _assign_herbalist(state)
    if actor == null:
        return false
    _normalize_worker(actor)

    var herb_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_HERB))
    var xp_before := workforce.profession_xp(actor, WorkforceSystem.PROF_HERBALISM)

    var planted := false
    for _i in range(24):
        var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
        if not bool(result.get("ok", false)):
            return _fail("Spirit Field planting step unexpectedly failed: %s" % str(result.get("reason", "")))
        if bool(result.get("completed", false)):
            if str(result.get("work_kind", "")) != "planting":
                return _fail("First Spirit Field completion was not planting.")
            planted = true
            break
    if not planted:
        return _fail("Spirit Field planting did not complete in bounded steps.")
    if StringName(field.production_state.get("phase", "")) != BuildingSystem.SPIRIT_PHASE_GROWING:
        return _fail("Planting did not start real building-owned crop growth.")
    if not actor.work_cycle_state.is_empty():
        return _fail("Worker remained trapped in work_cycle after planting.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_HERB)) != herb_before:
        return _fail("Planting incorrectly produced harvest immediately.")
    if workforce.profession_xp(actor, WorkforceSystem.PROF_HERBALISM) <= xp_before:
        return _fail("Planting did not grant real Herbalism profession XP.")
    if buildings.work_available(state, WorkforceSystem.PROF_HERBALISM):
        return _fail("Spirit Field remained work-available while crop was growing.")

    var required := int(ceil(float(field.production_state.get("growth_required", 0.0))))
    if required < 2:
        return _fail("Spirit Field growth duration is not a meaningful real duration.")
    for _i in range(required - 1):
        buildings.process_tick(state)
    if StringName(field.production_state.get("phase", "")) != BuildingSystem.SPIRIT_PHASE_GROWING:
        return _fail("Spirit Field crop became ready before growth time completed.")
    buildings.process_tick(state)
    if StringName(field.production_state.get("phase", "")) != BuildingSystem.SPIRIT_PHASE_HARVEST_READY:
        return _fail("Spirit Field crop did not become harvest-ready after real growth time.")
    if not buildings.work_available(state, WorkforceSystem.PROF_HERBALISM):
        return _fail("Harvest-ready Spirit Field did not become work-available.")

    var xp_after_planting := workforce.profession_xp(actor, WorkforceSystem.PROF_HERBALISM)
    var harvested := false
    for _i in range(30):
        var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
        if not bool(result.get("ok", false)):
            return _fail("Spirit Field harvest step unexpectedly failed: %s" % str(result.get("reason", "")))
        if bool(result.get("completed", false)):
            if str(result.get("work_kind", "")) != "harvest":
                return _fail("Second Spirit Field completion was not harvest.")
            if str(result.get("deposited_to", "")) != "sect_main_warehouse":
                return _fail("Spirit Field harvest did not route to main Sect Warehouse.")
            harvested = true
            break
    if not harvested:
        return _fail("Spirit Field harvest did not complete in bounded steps.")
    if not field.production_state.is_empty():
        return _fail("Spirit Field did not return to idle after harvest.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_HERB)) <= herb_before:
        return _fail("Spirit Field harvest produced no real Thanh Linh Thảo.")
    if workforce.profession_xp(actor, WorkforceSystem.PROF_HERBALISM) <= xp_after_planting:
        return _fail("Harvest did not grant real Herbalism profession XP.")
    if int(field.metrics.get("production_batches", 0)) != 1:
        return _fail("Spirit Field production batch metric is invalid.")
    return _validate(state)

func _verify_growth_does_not_hold_worker() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 2)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var actor := _assign_herbalist(state)
    if actor == null:
        return false
    _normalize_worker(actor)

    for _i in range(24):
        var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
        if bool(result.get("completed", false)):
            break
    if StringName(field.production_state.get("phase", "")) != BuildingSystem.SPIRIT_PHASE_GROWING:
        return _fail("Growth freedom probe did not start crop growth.")
    if not actor.work_cycle_state.is_empty():
        return _fail("Herbalist work cycle remained active during autonomous crop growth.")

    var stamina_before := actor.stamina
    NeedsSystem.new().apply_rest(state, actor)
    if actor.stamina <= stamina_before:
        return _fail("Herbalist could not perform another valid activity while crop grew.")

    var growth_before := float(field.production_state.get("growth_progress", 0.0))
    buildings.process_tick(state)
    if float(field.production_state.get("growth_progress", 0.0)) <= growth_before:
        return _fail("Crop growth depended on worker standing in the field.")
    return _validate(state)

func _verify_competing_workers_release_cleanly() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 21)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var workers: Array[DiscipleState] = []
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id == &"mining_crew":
            continue
        if not workforce.assign_group(state, actor.id, &"herbalism_crew"):
            return _fail("Could not assign competing herbalist.")
        _normalize_worker(actor)
        workers.append(actor)
        if workers.size() == 2:
            break
    if workers.size() != 2:
        return _fail("Competing-worker test needs two herbalists.")

    # Start both workers before either can finish the shared field phase.
    var first_a := workforce.perform_work(state, workers[0], WorkforceSystem.PROF_HERBALISM)
    var first_b := workforce.perform_work(state, workers[1], WorkforceSystem.PROF_HERBALISM)
    if not bool(first_a.get("ok", false)) or not bool(first_b.get("ok", false)):
        return _fail("Competing herbalists could not enter the shared field work phase.")
    if workers[0].work_cycle_state.is_empty() or workers[1].work_cycle_state.is_empty():
        return _fail("Competing herbalists did not both establish initial work cycles.")

    var completed_by := -1
    for _step in range(24):
        for worker_index in range(2):
            var actor := workers[worker_index]
            if actor.work_cycle_state.is_empty():
                continue
            var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
            if bool(result.get("completed", false)):
                completed_by = worker_index
                break
        if completed_by >= 0:
            break
    if completed_by < 0:
        return _fail("Neither competing herbalist completed planting.")
    if StringName(field.production_state.get("phase", "")) != BuildingSystem.SPIRIT_PHASE_GROWING:
        return _fail("Competing-worker completion did not start crop growth.")

    for actor in workers:
        if not actor.work_cycle_state.is_empty():
            return _fail("A competing herbalist remained trapped in a stale work cycle after planting completed.")
    return _validate(state)

func _verify_spirit_field_milestone_component() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 3)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    field.level = 9
    warehouse.add(state, StringName(BuildingSystem.MATERIAL_WOOD), 1000)
    warehouse.add(state, StringName(BuildingSystem.MATERIAL_ORE), 1000)
    state.sect.spirit_stones = 1000
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_LINH_TUYEN_HEART)) != 0:
        return _fail("Spirit Field milestone probe unexpectedly started with Linh Tuyền Chi Tâm.")

    var blocked := buildings.can_start_upgrade(state, field.id)
    if bool(blocked.get("ok", false)) or str(blocked.get("material_id", "")) != BuildingSystem.MATERIAL_LINH_TUYEN_HEART:
        return _fail("Spirit Field Lv9 -> Lv10 did not require Linh Tuyền Chi Tâm.")

    warehouse.add(state, StringName(BuildingSystem.MATERIAL_LINH_TUYEN_HEART), 1)
    var started := buildings.start_upgrade(state, field.id)
    if not bool(started.get("ok", false)):
        return _fail("Spirit Field Lv10 milestone could not start with Linh Tuyền Chi Tâm.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_LINH_TUYEN_HEART)) != 0:
        return _fail("Spirit Field milestone did not consume Linh Tuyền Chi Tâm.")

    var required := int(ceil(field.upgrade_required_work))
    for _i in range(required):
        buildings.process_tick(state)
    if field.level != 10 or not field.unlocked_milestones.has(10):
        return _fail("Spirit Field Lv10 milestone did not complete.")
    if buildings.worker_slots(field) != 4:
        return _fail("Spirit Field worker slots did not scale with generic building rule.")
    return _validate(state)

func _verify_growth_save_load_and_determinism() -> bool:
    var state_a := P37Factory.create_state(TEST_SEED + 4)
    var field := buildings.primary_building(state_a, BuildingSystem.TYPE_SPIRIT_FIELD)
    var actor := _assign_herbalist(state_a)
    if actor == null:
        return false
    _normalize_worker(actor)

    for _i in range(24):
        var result := workforce.perform_work(state_a, actor, WorkforceSystem.PROF_HERBALISM)
        if bool(result.get("completed", false)):
            break
    buildings.process_tick(state_a)
    buildings.process_tick(state_a)
    if StringName(field.production_state.get("phase", "")) != BuildingSystem.SPIRIT_PHASE_GROWING:
        return _fail("Persistence probe has no active crop growth.")

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P3.7A2 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("P3.7A2 load failed.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P3.7A2 exact save/load diverged during crop growth.")

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(loaded)
    for continuation_tick in range(40):
        scheduler_a.step()
        scheduler_b.step()
        if state_a.to_dict() != loaded.to_dict():
            var difference := _first_difference(state_a.to_dict(), loaded.to_dict(), "state")
            var field_a := buildings.primary_building(state_a, BuildingSystem.TYPE_SPIRIT_FIELD)
            var field_b := buildings.primary_building(loaded, BuildingSystem.TYPE_SPIRIT_FIELD)
            return _fail("P3.7A2 deterministic continuation diverged at continuation tick %d: %s | fieldA=%s fieldB=%s" % [
                continuation_tick + 1,
                difference,
                field_a.production_state,
                field_b.production_state
            ])
    return _validate(loaded)

func _assign_herbalist(state: SimulationState) -> DiscipleState:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id != &"mining_crew":
            if not workforce.assign_group(state, actor.id, &"herbalism_crew"):
                _fail("Could not assign herbalist.")
                return null
            workforce.set_work_preference(state, actor.id, WorkforceSystem.PROF_HERBALISM, 4)
            return actor
    _fail("No disciple available for herbalism.")
    return null

func _normalize_worker(disciple: DiscipleState) -> void:
    disciple.comprehension = 0.60
    disciple.constitution = 0.60
    disciple.profession_xp[str(WorkforceSystem.PROF_HERBALISM)] = 0.0
    disciple.profession_traits.clear()
    disciple.work_cycle_state.clear()
    disciple.stamina = 100.0
    disciple.hp = disciple.max_hp
    disciple.current_action = &"EVALUATE"
    disciple.direct_command.clear()

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
        return "%s type %s != %s" % [path, typeof(left), typeof(right)]
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
