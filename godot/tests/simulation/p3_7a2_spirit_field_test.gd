extends SceneTree

const TEST_SEED := 370072
const SAVE_PATH := "user://p3_7a2_spirit_field_test.json"

var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()
var crops := SpiritCropRegistry.new()
var modifiers := ProfessionModifierSystem.new()
var traits := TraitSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_authority_and_crop_registry():
        return
    if not _verify_simple_foundation_and_data_driven_modifiers():
        return
    if not _verify_simple_timer_cost_and_warehouse_harvest():
        return
    if not _verify_insufficient_funds_and_no_refund_cancel():
        return
    if not _verify_multiple_plots_and_workers():
        return
    if not _verify_multiple_fields_use_specific_worksites():
        return
    if not _verify_crop_policies():
        return
    if not _verify_lucky_harvest_math():
        return
    if not _verify_profession_learning_and_long_term_level():
        return
    if not _verify_field_level_and_milestone_numbers():
        return
    if not _verify_milestone_heart_costs_and_fragments():
        return
    if not _verify_passive_work_cultivation_only_on_work():
        return
    if not _verify_legacy_field_state_migrates():
        return
    if not _verify_save_load_and_deterministic_continuation():
        return
    if not _verify_open_point_six_foundation_persistence():
        return
    print("P3.7A2R SPIRIT FIELD COMPLETION TEST PASS")
    _cleanup()
    quit(0)

func _verify_authority_and_crop_registry() -> bool:
    var state := P37Factory.create_state(TEST_SEED)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null or field.level != 1 or field.max_level != 100:
        return _fail("Spirit Field authority is missing or has invalid level bounds.")
    if field.worker_group_id != &"herbalism_crew" or buildings.worker_slots(field) != 4:
        return _fail("Spirit Field Lv1 must expose four worker slots for four plots.")
    if buildings.spirit_plot_slots(field) != 4:
        return _fail("Spirit Field Lv1 must expose four plots.")
    var plots := buildings.spirit_field_plots(state, field)
    if plots.size() != 4:
        return _fail("Spirit Field did not initialize four independent plot states.")
    for plot in plots:
        if StringName(plot.get("status", "")) != BuildingSystem.PLOT_EMPTY:
            return _fail("Fresh Spirit Field contains a non-empty plot.")
    var crop_errors := crops.validate_definitions()
    if not crop_errors.is_empty():
        return _fail("Crop registry invalid: %s" % " | ".join(crop_errors))
    return _validate(state)

func _verify_simple_foundation_and_data_driven_modifiers() -> bool:
    var character_modifiers := CharacterModifierSystem.new()
    if not is_equal_approx(character_modifiers.foundation_factor(0.50), 1.0):
        return _fail("Foundation midpoint must be neutral x1.00.")
    if not is_equal_approx(character_modifiers.foundation_factor(1.00), 1.25):
        return _fail("Foundation maximum must be x1.25.")
    if not is_equal_approx(character_modifiers.foundation_factor(0.20), 0.85):
        return _fail("Foundation 20/100 must be x0.85.")

    var state := P37Factory.create_state(TEST_SEED + 1)
    var actor := _first_non_miner(state)
    if actor == null:
        return false
    _set_trait_profile(state, actor, [str(TraitSystem.TRAIT_DILIGENT_WORKER)], {
        str(TraitSystem.TRAIT_DILIGENT_WORKER): 3
    })
    var factor := traits.modifier_factor(state, actor, CharacterModifierSystem.CHANNEL_WORK_SPEED)
    if not is_equal_approx(factor, 1.15):
        return _fail("Cần Mẫn grade 3 is not data-driven +15% work speed.")

    _set_trait_profile(state, actor, [str(TraitSystem.TRAIT_CARELESS_WORKER)], {
        str(TraitSystem.TRAIT_CARELESS_WORKER): 4
    })
    factor = traits.modifier_factor(state, actor, CharacterModifierSystem.CHANNEL_WORK_SPEED)
    if not is_equal_approx(factor, 0.80):
        return _fail("Cẩu Thả grade 4 is not data-driven -20% work speed.")
    return true

func _verify_simple_timer_cost_and_warehouse_harvest() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 2)
    state.sect.spirit_stones = 1000
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var actor := _assign_herbalist(state, field)
    if actor == null:
        return false
    _normalize_worker(state, actor)

    var stones_before := state.sect.spirit_stones
    var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    if not bool(result.get("ok", false)) or not bool(result.get("completed", false)):
        return _fail("Starting one crop did not complete as one simple work action.")
    var crop_id := StringName(result.get("crop_id", ""))
    if state.sect.spirit_stones != stones_before - crops.cost(crop_id):
        return _fail("Starting a crop did not consume exact Sect Spirit Stones.")
    if not actor.work_cycle_state.is_empty():
        return _fail("Herbalist entered an obsolete detailed movement/harvest work cycle.")
    if not buildings.disciple_has_active_spirit_plot(state, actor.id, field):
        return _fail("Started plot did not reserve exactly one disciple.")
    var blocked_again := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    if bool(blocked_again.get("ok", false)) or str(blocked_again.get("reason", "")) != "busy_spirit_plot":
        return _fail("One disciple was allowed to occupy more than one Spirit Field plot.")

    var plot := _growing_plot(state, field)
    if plot.is_empty() or int(plot.get("finish_tick", 0)) <= state.tick:
        return _fail("Crop did not become one authoritative countdown timer.")
    var before := warehouse.quantity(state, crops.output_resource_id(crop_id))
    _advance_buildings_to_tick(state, int(plot.get("finish_tick", state.tick + 1)))
    if warehouse.quantity(state, crops.output_resource_id(crop_id)) <= before:
        return _fail("Completed crop did not deposit directly into canonical warehouse.")
    if not _growing_plot(state, field).is_empty():
        return _fail("Finished plot did not return to empty state.")
    if buildings.disciple_has_active_spirit_plot(state, actor.id, field):
        return _fail("Disciple was not released when the assigned plot finished.")
    return _validate(state)

func _verify_insufficient_funds_and_no_refund_cancel() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 3)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var actor := _assign_herbalist(state, field)
    if actor == null:
        return false
    _normalize_worker(state, actor)

    state.sect.spirit_stones = 0
    var blocked := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    if bool(blocked.get("ok", false)):
        return _fail("Spirit Field started a crop without enough Spirit Stones.")

    state.sect.spirit_stones = 100
    var started := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    if not bool(started.get("ok", false)):
        return _fail("Cancelable crop could not start.")
    var after_payment := state.sect.spirit_stones
    if not buildings.cancel_spirit_plot(state, field.id, StringName(started.get("plot_id", ""))):
        return _fail("Active plot could not be canceled.")
    if state.sect.spirit_stones != after_payment:
        return _fail("Canceled crop refunded Spirit Stones despite V1 no-refund rule.")
    return _validate(state)

func _verify_multiple_plots_and_workers() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 4)
    state.sect.spirit_stones = 1000
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var workers := _assign_herbalists(state, field, 2)
    if workers.size() != 2:
        return _fail("Multiple-plot test needs two active herbalists.")

    for actor in workers:
        _normalize_worker(state, actor)
        if not bool(workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM).get("ok", false)):
            return _fail("A valid field worker could not start an independent plot.")

    var growing := 0
    for plot in buildings.spirit_field_plots(state, field):
        if StringName(plot.get("status", "")) == BuildingSystem.PLOT_GROWING:
            growing += 1
    if growing != 2:
        return _fail("Two workers did not start two independent crop timers.")
    for actor in workers:
        if not buildings.disciple_has_active_spirit_plot(state, actor.id, field):
            return _fail("Growing plot did not keep its assigned disciple.")
    return _validate(state)

func _verify_multiple_fields_use_specific_worksites() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 5)
    state.sect.spirit_stones = 1000
    var field_a := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var field_b := buildings.create_building(BuildingSystem.TYPE_SPIRIT_FIELD, 2)
    state.buildings[str(field_b.id)] = field_b
    state.building_event_count += 1
    buildings.spirit_field_plots(state, field_b)

    var workers := _assign_herbalists(state, field_a, 2)
    if workers.size() != 2:
        return _fail("Multiple-field test needs two disciples.")
    if not workforce.assign_worksite(state, workers[1].id, field_b.id):
        return _fail("Could not assign second concrete Spirit Field worksite.")

    for actor in workers:
        _normalize_worker(state, actor)
        if not bool(workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM).get("ok", false)):
            return _fail("Concrete field worker could not start crop.")
    if _growing_plot(state, field_a).is_empty() or _growing_plot(state, field_b).is_empty():
        return _fail("Concrete worksite assignment routed both workers into one field.")
    return _validate(state)

func _verify_crop_policies() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 6)
    state.sect.spirit_stones = 1000
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    field.level = 10
    buildings.spirit_field_plots(state, field)
    var actor := _assign_herbalist(state, field)
    if actor == null:
        return false
    _normalize_worker(state, actor)

    if not buildings.set_spirit_field_policy(state, field.id, BuildingSystem.FIELD_POLICY_FIXED, SpiritCropRegistry.CROP_LINH_COC):
        return _fail("Lv10 FIXED crop policy could not be set.")
    var fixed := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    if StringName(fixed.get("crop_id", "")) != SpiritCropRegistry.CROP_LINH_COC:
        return _fail("FIXED policy planted the wrong crop.")
    buildings.cancel_spirit_plot(state, field.id, StringName(fixed.get("plot_id", "")))

    if not buildings.set_spirit_field_policy(state, field.id, BuildingSystem.FIELD_POLICY_PRIORITY, &"", {
        str(SpiritCropRegistry.CROP_THANH_LINH_THAO): 100,
        str(SpiritCropRegistry.CROP_LINH_COC): 0
    }):
        return _fail("Lv10 PRIORITY crop policy could not be set.")
    var priority := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    if StringName(priority.get("crop_id", "")) != SpiritCropRegistry.CROP_THANH_LINH_THAO:
        return _fail("PRIORITY policy ignored configured weights.")
    return _validate(state)

func _verify_lucky_harvest_math() -> bool:
    if buildings.lucky_harvest_multiplier(1.0, 0.001) != 4:
        return _fail("x4 lucky-harvest band is wrong.")
    if buildings.lucky_harvest_multiplier(1.0, 0.005) != 3:
        return _fail("x3 lucky-harvest band is wrong.")
    if buildings.lucky_harvest_multiplier(1.0, 0.020) != 2:
        return _fail("x2 lucky-harvest band is wrong.")
    if buildings.lucky_harvest_multiplier(1.0, 0.500) != 1:
        return _fail("Normal lucky-harvest remainder is wrong.")

    var actor := DiscipleState.new({"id":"fortune_probe", "fortune":1.0})
    if not is_equal_approx(modifiers.fortune_factor(actor), 1.25):
        return _fail("Cơ Duyên maximum must use the shared x1.25 foundation factor.")
    return true

func _verify_profession_learning_and_long_term_level() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 7)
    state.sect.spirit_stones = 1000
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var actor := _assign_herbalist(state, field)
    if actor == null:
        return false
    _normalize_worker(state, actor)

    actor.comprehension = 0.0
    FoundationSystem.new().recompute_disciple_quality(actor)
    actor.profession_traits = [str(WorkforceSystem.TRAIT_HERBALIST)]
    actor.profession_trait_grades = {str(WorkforceSystem.TRAIT_HERBALIST): 5}
    var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    var expected := crops.base_work_xp(StringName(result.get("crop_id", ""))) * 1.25
    if not is_equal_approx(float(result.get("xp_gain", 0.0)), expected):
        return _fail("Linh Thực talent grade 5 did not add exactly +25% profession XP at neutral Thông Tuệ.")

    actor.profession_xp[str(WorkforceSystem.PROF_HERBALISM)] = WorkforceSystem.P3_7_XP_LEVEL_SCALE * 100.0
    if workforce.p3_7_profession_level(actor, WorkforceSystem.PROF_HERBALISM) != 10:
        return _fail("P3.7 long-term profession level curve is invalid at Lv10 probe.")
    if not is_equal_approx(modifiers.profession_speed_factor(10), 1.10):
        return _fail("Profession level must grant +1% work speed per level.")
    return true

func _verify_field_level_and_milestone_numbers() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 8)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)

    field.level = 20
    buildings.spirit_field_plots(state, field)
    if buildings.worker_slots(field) != 8 or buildings.spirit_plot_slots(field) != 8:
        return _fail("Field must keep one worker slot per plot at Lv20.")
    if not is_equal_approx(buildings.spirit_field_speed_factor(field), 1.095):
        return _fail("Field +0.5% speed/level formula is wrong.")
    if not is_equal_approx(buildings.spirit_field_yield_factor(field), 1.095 * 1.10):
        return _fail("Field Lv20 yield formula is wrong.")

    field.level = 10
    buildings.spirit_field_plots(state, field)
    if not is_equal_approx(buildings.spirit_field_cycle_time_factor(field), 0.90):
        return _fail("Field Lv10 irrigation must reduce cycle time by 10%.")

    field.level = 100
    buildings.spirit_field_plots(state, field)
    if not is_equal_approx(buildings.spirit_field_xp_factor(field), 1.10 * 1.20):
        return _fail("Field Lv30/Lv100 profession-XP milestones are wrong.")
    return true

func _verify_milestone_heart_costs_and_fragments() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 80)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var probes := {
        9: 1,
        19: 2,
        29: 3,
        49: 5,
        74: 8,
        99: 10
    }
    for current_level in probes.keys():
        field.level = int(current_level)
        var cost := buildings.upgrade_cost(field)
        if int(cost.get(BuildingSystem.MATERIAL_LINH_TUYEN_HEART, 0)) != int(probes[current_level]):
            return _fail("Spirit Field milestone Linh Tuyền Chi Tâm quantity is wrong at target Lv%d." % [int(current_level) + 1])

    if buildings.linh_tuyen_fragment_drop(1.0, 0.049) != 1 or buildings.linh_tuyen_fragment_drop(1.0, 0.051) != 0:
        return _fail("Linh Tuyền fragment base drop chance must be 5%.")
    if not warehouse.add(state, StringName(BuildingSystem.MATERIAL_LINH_TUYEN_FRAGMENT), 199):
        return _fail("Could not stage Linh Tuyền fragments.")
    var hearts_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_LINH_TUYEN_HEART))
    if buildings.convert_linh_tuyen_fragments(state) != 1:
        return _fail("100 Linh Tuyền fragments did not convert into one Chi Tâm.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_LINH_TUYEN_FRAGMENT)) != 99:
        return _fail("Linh Tuyền fragment conversion remainder is wrong.")
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_LINH_TUYEN_HEART)) != hearts_before + 1:
        return _fail("Linh Tuyền Chi Tâm conversion output is wrong.")
    field.level = 1
    buildings.spirit_field_plots(state, field)
    return _validate(state)

func _verify_passive_work_cultivation_only_on_work() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 9)
    state.sect.spirit_stones = 1000
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var actor := _assign_herbalist(state, field)
    if actor == null:
        return false
    _normalize_worker(state, actor)

    actor.cultivation_stage_index = 0
    actor.cultivation_progress = 0.0
    var before := actor.cultivation_progress
    var result := workforce.perform_work(state, actor, WorkforceSystem.PROF_HERBALISM)
    if not bool(result.get("ok", false)) or actor.cultivation_progress <= before:
        return _fail("Actual Linh Điền work did not grant passive work Tu Vi.")

    var after_work := actor.cultivation_progress
    for _i in range(3):
        state.tick += 1
        buildings.process_tick(state)
    if not is_equal_approx(actor.cultivation_progress, after_work):
        return _fail("Passive crop countdown incorrectly granted Tu Vi while disciple was not working.")
    return _validate(state)

func _verify_legacy_field_state_migrates() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 10)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    field.production_state = {
        "phase": str(BuildingSystem.SPIRIT_PHASE_GROWING),
        "resource_id": str(SpiritCropRegistry.CROP_THANH_LINH_THAO),
        "growth_progress": 2.0,
        "growth_required": 12.0,
        "planted_by": "legacy_worker"
    }

    var plots := buildings.spirit_field_plots(state, field)
    if plots.size() != buildings.spirit_plot_slots(field):
        return _fail("Legacy A2 field state did not migrate to canonical plots.")
    var migrated := _growing_plot(state, field)
    if migrated.is_empty() or StringName(migrated.get("crop_id", "")) != SpiritCropRegistry.CROP_THANH_LINH_THAO:
        return _fail("Legacy growing crop identity was lost during A2R migration.")
    return _validate(state)

func _verify_save_load_and_deterministic_continuation() -> bool:
    var state_a := P37Factory.create_state(TEST_SEED + 11)
    state_a.sect.spirit_stones = 1000
    var field := buildings.primary_building(state_a, BuildingSystem.TYPE_SPIRIT_FIELD)
    var workers := _assign_herbalists(state_a, field, 2)
    if workers.size() != 2:
        return _fail("Persistence test needs two herbalists.")

    for actor in workers:
        _normalize_worker(state_a, actor)
        if not bool(workforce.perform_work(state_a, actor, WorkforceSystem.PROF_HERBALISM).get("ok", false)):
            return _fail("Persistence test could not start independent plots.")
    state_a.tick += 2
    buildings.process_tick(state_a)

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("A2R save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or state_a.to_dict() != loaded.to_dict():
        return _fail("A2R exact save/load diverged mid-crop.")

    var build_a := BuildingSystem.new()
    var build_b := BuildingSystem.new()
    for _i in range(40):
        state_a.tick += 1
        loaded.tick += 1
        build_a.process_tick(state_a)
        build_b.process_tick(loaded)
        if state_a.to_dict() != loaded.to_dict():
            return _fail("A2R deterministic continuation diverged after save/load.")
    _cleanup()
    return _validate(loaded)

func _verify_open_point_six_foundation_persistence() -> bool:
    var state := P37Factory.create_state(TEST_SEED + 50)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var actor: DiscipleState = state.disciples[ids[0]]
    actor.profile_seed = 0
    actor.recruitment_source = &""
    actor.race_id = &""
    actor.sex_id = &""
    actor.origin_id = &""
    actor.aptitude = 41.0
    actor.constitution = 62.0
    actor.fortune = 53.0
    actor.comprehension = 74.0
    actor.charisma = 36.0
    actor.potential = 88.0
    FoundationSystem.new().recompute_disciple_quality(actor)

    var service := SaveService.new()
    if service.save_to_path(state, SAVE_PATH) != OK:
        return _fail("Six-foundation persistence save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        return _fail("Six-foundation persistence load failed.")
    var restored: DiscipleState = loaded.disciples[actor.id]
    if not is_equal_approx(restored.aptitude, actor.aptitude) or not is_equal_approx(restored.constitution, actor.constitution) or not is_equal_approx(restored.fortune, actor.fortune) or not is_equal_approx(restored.comprehension, actor.comprehension) or not is_equal_approx(restored.charisma, actor.charisma) or not is_equal_approx(restored.potential, actor.potential):
        return _fail("Open-point disciple lost one or more six-foundation values.")
    _cleanup()
    return _validate(loaded)

func _assign_herbalist(state: SimulationState, field: BuildingState) -> DiscipleState:
    var workers := _assign_herbalists(state, field, 1)
    return workers[0] if not workers.is_empty() else null

func _assign_herbalists(state: SimulationState, field: BuildingState, count: int) -> Array[DiscipleState]:
    var result: Array[DiscipleState] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id == &"mining_crew":
            continue
        if not workforce.assign_group(state, actor.id, &"herbalism_crew"):
            continue
        if not workforce.assign_worksite(state, actor.id, field.id):
            continue
        workforce.set_work_preference(state, actor.id, WorkforceSystem.PROF_HERBALISM, 4)
        result.append(actor)
        if result.size() >= count:
            break
    return result

func _first_non_miner(state: SimulationState) -> DiscipleState:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id != &"mining_crew":
            return actor
    return null

func _normalize_worker(state: SimulationState, disciple: DiscipleState) -> void:
    disciple.aptitude = 0.0
    disciple.comprehension = 0.0
    disciple.constitution = 0.0
    disciple.fortune = 50.0
    FoundationSystem.new().recompute_disciple_quality(disciple)
    disciple.profession_xp[str(WorkforceSystem.PROF_HERBALISM)] = 0.0
    # Keep a canonical, unrelated profession talent so P3.7 load migration is
    # intentionally a no-op while Herbalism remains neutral.
    disciple.profession_traits = [str(WorkforceSystem.TRAIT_FORGE)]
    disciple.profession_trait_grades = {str(WorkforceSystem.TRAIT_FORGE): 1}
    disciple.work_cycle_state.clear()
    disciple.stamina = 100.0
    disciple.hp = disciple.max_hp
    disciple.current_action = &"EVALUATE"
    disciple.direct_command.clear()
    _set_trait_profile(state, disciple, [], {})

func _set_trait_profile(state: SimulationState, disciple: DiscipleState, visible: Array, grades: Dictionary) -> void:
    state.sect.disciple_trait_profiles[str(disciple.id)] = {
        "initialized": true,
        "visible": visible.duplicate(),
        "latent": [],
        "revealed": [],
        "grades": grades.duplicate(true)
    }

func _growing_plot(state: SimulationState, field: BuildingState) -> Dictionary:
    for plot in buildings.spirit_field_plots(state, field):
        if StringName(plot.get("status", "")) == BuildingSystem.PLOT_GROWING:
            return plot
    return {}

func _advance_buildings_to_tick(state: SimulationState, target_tick: int) -> void:
    while state.tick < target_tick:
        state.tick += 1
        buildings.process_tick(state)

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

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
