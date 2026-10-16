class_name BuildingSystem
extends RefCounted

const TYPE_MINE := &"mine"
const TYPE_LINH_FOREST := &"linh_forest"
const TYPE_ALCHEMY_HALL := &"alchemy_hall"
const TYPE_SPIRIT_FIELD := &"spirit_field"
const TYPE_GUIDANCE_PLATFORM := &"dan_tien_dai"
const TYPE_BODY_TRAINING := &"ren_than_duong"

const PROF_MINING := &"mining"
const PROF_FORESTRY := &"forestry"
const PROF_ALCHEMY := &"alchemy"
const PROF_HERBALISM := &"herbalism"

const STATUS_ACTIVE := &"active"
const STATUS_UPGRADING := &"upgrading"
const VALID_STATUSES := [STATUS_ACTIVE, STATUS_UPGRADING]

const MILESTONE_LEVELS := [10, 20, 30, 50, 75, 100]

# Named resources remain explicit. P3.7B uses WarehouseSystem as the sole
# stackable-resource authority; legacy buckets are fallback-only for old direct states.
const MATERIAL_WOOD := "linh_moc"
const MATERIAL_ORE := "thanh_thiet"
const MATERIAL_TAM_MACH_BAN := "tam_mach_ban"
const MATERIAL_HERB := "thanh_linh_thao"
const MATERIAL_LINH_TUYEN_HEART := "linh_tuyen_chi_tam"
const MATERIAL_LINH_TUYEN_FRAGMENT := "linh_tuyen_chi_tam_manh"
const LINH_TUYEN_FRAGMENT_PER_HEART := 100
const LINH_TUYEN_FRAGMENT_BASE_CHANCE := 0.05

# Legacy A2 phase names remain only for old-save migration.
const SPIRIT_PHASE_GROWING := &"growing"
const SPIRIT_PHASE_HARVEST_READY := &"harvest_ready"

const FIELD_POLICY_AUTO_DEMAND := &"auto_demand"
const FIELD_POLICY_PRIORITY := &"priority"
const FIELD_POLICY_FIXED := &"fixed"
const VALID_FIELD_POLICIES := [FIELD_POLICY_AUTO_DEMAND, FIELD_POLICY_PRIORITY, FIELD_POLICY_FIXED]

const PLOT_EMPTY := &"empty"
const PLOT_GROWING := &"growing"

# Milestone specialty components. Spirit Field reuses one clear component
# across all major thresholds, with quantity increasing by milestone level.
const MILESTONE_COMPONENTS := {
    "mine": {
        10: MATERIAL_TAM_MACH_BAN
    },
    "spirit_field": {
        10: MATERIAL_LINH_TUYEN_HEART,
        20: MATERIAL_LINH_TUYEN_HEART,
        30: MATERIAL_LINH_TUYEN_HEART,
        50: MATERIAL_LINH_TUYEN_HEART,
        75: MATERIAL_LINH_TUYEN_HEART,
        100: MATERIAL_LINH_TUYEN_HEART
    }
}

const DEFINITIONS := {
    "mine": {
        "name": "Mỏ Linh Khoáng",
        "max_level": 100,
        "worker_group_id": "mining_crew",
        "profession_id": "mining",
        "job_model": "carry_cycle",
        "resource_id": MATERIAL_ORE,
        "cycle_phases": ["travel_out", "mining", "haul_back"],
        "cycle_work_phase": "mining",
        "base_worker_slots": 1,
        "worker_slot_every": 0,
        "base_wood_cost": 4,
        "base_ore_cost": 6,
        "base_stone_cost": 20,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "work_distance": 8.0,
        "haul_distance": 6.0,
        "base_work_duration": 4.0,
        "base_batch_units": 2
    },
    "linh_forest": {
        "name": "Linh Lâm",
        "max_level": 100,
        "worker_group_id": "forestry_crew",
        "profession_id": "forestry",
        "job_model": "carry_cycle",
        "resource_id": MATERIAL_WOOD,
        "cycle_phases": ["travel_out", "harvesting", "haul_back"],
        "cycle_work_phase": "harvesting",
        "base_worker_slots": 1,
        "worker_slot_every": 0,
        "work_distance": 8.0,
        "haul_distance": 6.0,
        "base_work_duration": 4.0,
        "base_batch_units": 2,
        "upgrade_enabled": false,
        "requires_milestone_component": false
    },
    "alchemy_hall": {
        "name": "Luyện Đan Điện",
        "max_level": 100,
        "worker_group_id": "alchemy_crew",
        "profession_id": "alchemy",
        "job_model": "timed_recipe",
        "base_worker_slots": 2,
        "worker_slot_every": 10,
        "upgrade_enabled": false,
        "requires_milestone_component": false
    },
    "spirit_field": {
        "name": "Linh Điền",
        "max_level": 100,
        "worker_group_id": "herbalism_crew",
        "profession_id": "herbalism",
        "job_model": "plot_timer",
        "base_worker_slots": 1,
        "worker_slot_every": 0,
        "base_wood_cost": 6,
        "base_ore_cost": 3,
        "base_stone_cost": 18,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "work_distance": 7.0,
        "haul_distance": 5.0,
        "base_tend_duration": 3.0,
        "base_harvest_duration": 3.0,
        "base_growth_duration": 12.0,
        "base_batch_units": 3,
        "resource_id": MATERIAL_HERB
    },
    "ren_than_duong": {
        "name": "Rèn Thân Đường",
        "max_level": 100,
        "worker_group_id": "body_training_crew",
        "base_worker_slots": 2,
        "worker_slot_every": 0,
        "requires_milestone_component": false
    },
    "dan_tien_dai": {
        "name": "Dẫn Tiên Đài",
        "max_level": 100,
        "worker_group_id": "",
        "base_worker_slots": 0,
        "worker_slot_every": 0,
        "base_wood_cost": 5,
        "base_ore_cost": 4,
        "base_stone_cost": 24,
        "base_upgrade_work": 8.0,
        "upgrade_work_per_level": 2.0,
        "requires_milestone_component": false
    }
}

var equipment := EquipmentSystem.new()
var warehouse := WarehouseSystem.new()
var crop_registry := SpiritCropRegistry.new()
var alchemy_registry := AlchemyRecipeRegistry.new()
var profession_modifiers := ProfessionModifierSystem.new()

func initialize(state: SimulationState) -> void:
    if not state.sect.workforce_enabled:
        return
    state.p3_7_buildings_enabled = true

    if not state.sect.work_groups.has("herbalism_crew"):
        state.sect.work_groups["herbalism_crew"] = {
            "name": "Đội Linh Thực",
            "priorities": {"herbalism": 3}
        }
        state.sect.workforce_event_count += 1

    if not state.sect.work_groups.has("forestry_crew"):
        state.sect.work_groups["forestry_crew"] = {
            "name": "Đội Lâm Nghiệp",
            "priorities": {"forestry": 3}
        }
        state.sect.workforce_event_count += 1

    if not state.sect.work_groups.has("alchemy_crew"):
        state.sect.work_groups["alchemy_crew"] = {
            "name": "Đội Luyện Đan",
            "priorities": {"alchemy": 3}
        }
        state.sect.workforce_event_count += 1

    if primary_building(state, TYPE_MINE) == null:
        var mine := create_building(TYPE_MINE, 1)
        state.buildings[str(mine.id)] = mine
        state.building_event_count += 1
        # Fresh P2 founders may have two legacy mining_crew members. This is
        # initial-state creation ONLY, not a silent migration of old user saves.
        var seed_ids: Array = state.disciples.keys()
        seed_ids.sort()
        var found_miner := false
        for raw_seed_id in seed_ids:
            var founder: DiscipleState = state.disciples[raw_seed_id]
            if founder.work_group_id != &"mining_crew":
                continue
            if not found_miner:
                found_miner = true
                continue
            founder.work_group_id = &""
            founder.worksite_building_id = &""
            state.sect.workforce_event_count += 1

    if primary_building(state, TYPE_LINH_FOREST) == null:
        var forest := create_building(TYPE_LINH_FOREST, 1)
        state.buildings[str(forest.id)] = forest
        state.building_event_count += 1

    if primary_building(state, TYPE_ALCHEMY_HALL) == null:
        var alchemy_hall := create_building(TYPE_ALCHEMY_HALL, 1)
        alchemy_hall.production_state = _default_alchemy_state()
        state.buildings[str(alchemy_hall.id)] = alchemy_hall
        state.building_event_count += 1

    if primary_building(state, TYPE_SPIRIT_FIELD) == null:
        var field := create_building(TYPE_SPIRIT_FIELD, 1)
        state.buildings[str(field.id)] = field
        state.building_event_count += 1

    if primary_building(state, TYPE_GUIDANCE_PLATFORM) == null:
        var guidance := create_building(TYPE_GUIDANCE_PLATFORM, 1)
        guidance.production_state = {
            "main_guide_id": "",
            "assistant_guide_ids": [],
            "snapshot_day_index": -1,
            "snapshot_main_charisma": 0.0,
            "enhanced_heaven_count": 0,
            "daily_arrival_target": 0,
            "daily_arrivals_generated": 0
        }
        state.buildings[str(guidance.id)] = guidance
        state.building_event_count += 1

    for field in _buildings_of_type(state, TYPE_SPIRIT_FIELD):
        _ensure_spirit_field_state(state, field)
    for hall in _buildings_of_type(state, TYPE_ALCHEMY_HALL):
        _ensure_alchemy_state(hall)

# Add the selected V2 training facility only in the V2 live runtime, not in
# older P3.7 factories/test fixtures. Repeat-safe on old loaded live saves.
func ensure_body_training_facility(state: SimulationState) -> BuildingState:
    if not state.p3_7_buildings_enabled:
        return null
    # A previously saved building must survive a workforce-disabled
    # compatibility state without creating any new resources or assignments.
    var facility := primary_building(state, TYPE_BODY_TRAINING)
    if facility != null:
        return facility
    if not state.sect.workforce_enabled:
        return null
    if not state.sect.work_groups.has("body_training_crew"):
        state.sect.work_groups["body_training_crew"] = {
            "name": "Đội Rèn Thân",
            "priorities": {}
        }
        state.sect.workforce_event_count += 1
    facility = create_building(TYPE_BODY_TRAINING, 1)
    state.buildings[str(facility.id)] = facility
    state.building_event_count += 1
    return facility

func create_building(building_type: StringName, instance_index: int = 1) -> BuildingState:
    var definition: Dictionary = DEFINITIONS.get(str(building_type), {})
    if definition.is_empty():
        return null
    var id := "%s_%03d" % [str(building_type), maxi(instance_index, 1)]
    return BuildingState.new({
        "id": id,
        "building_type": str(building_type),
        "name": str(definition.get("name", building_type)),
        "instance_index": maxi(instance_index, 1),
        "level": 1,
        "max_level": int(definition.get("max_level", 100)),
        "status": str(STATUS_ACTIVE),
        "worker_group_id": str(definition.get("worker_group_id", ""))
    })

func primary_building(state: SimulationState, building_type: StringName) -> BuildingState:
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if building is BuildingState and building.building_type == building_type:
            return building
    return null

func worker_slots(building: BuildingState) -> int:
    var definition := definition_for(building)
    if definition.is_empty():
        return 0
    # Economy V2 owner lock: raw-resource buildings have one responsible
    # operator per instance at every building level. Capacity growth belongs to
    # more instances / internal plots, never hidden extra workers.
    if [TYPE_MINE, TYPE_LINH_FOREST, TYPE_SPIRIT_FIELD].has(building.building_type):
        return 1
    var base_slots := maxi(int(definition.get("base_worker_slots", 0)), 0)
    var every := maxi(int(definition.get("worker_slot_every", 0)), 0)
    if every <= 0:
        return base_slots
    return base_slots + int(floor(float(building.level) / float(every)))

func spirit_plot_slots(building: BuildingState) -> int:
    if building == null or building.building_type != TYPE_SPIRIT_FIELD:
        return 0
    # One Linh Điền keeps four internal production plots. Building level scales
    # efficiency/content, not worker count or plot count.
    return 4

func guidance_elder_slots(building: BuildingState) -> int:
    if building == null or building.building_type != TYPE_GUIDANCE_PLATFORM:
        return 0
    return clampi(1 + int(floor(float(building.level) / 20.0)), 1, 6)

func guidance_base_daily_arrivals(building: BuildingState) -> int:
    if building == null or building.building_type != TYPE_GUIDANCE_PLATFORM:
        return 0
    # Dẫn Tiên should visibly scale with infrastructure without gating Mị Lực.
    # Current balance: 5/day at Lv1, +3 every 10 levels, 35/day at Lv100.
    return 5 + 3 * int(floor(float(building.level) / 10.0))

func spirit_field_speed_factor(field: BuildingState) -> float:
    return 1.0 + 0.005 * float(maxi(field.level - 1, 0))

func spirit_field_cycle_time_factor(field: BuildingState) -> float:
    var factor := 1.0
    if field.level >= 10:
        factor *= 0.90
    if field.level >= 75:
        factor *= 0.85
    return factor

func spirit_field_yield_factor(field: BuildingState) -> float:
    var factor := 1.0 + 0.005 * float(maxi(field.level - 1, 0))
    if field.level >= 20:
        factor *= 1.10
    if field.level >= 75:
        factor *= 1.10
    if field.level >= 100:
        factor *= 1.20
    return factor

func spirit_field_xp_factor(field: BuildingState) -> float:
    var factor := 1.0
    if field.level >= 30:
        factor *= 1.10
    if field.level >= 100:
        factor *= 1.20
    return factor

func assigned_worker_ids(state: SimulationState, building: BuildingState) -> Array[StringName]:
    var result: Array[StringName] = []
    if building == null or building.worker_group_id == &"":
        return result
    var primary := primary_building(state, building.building_type)
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id != building.worker_group_id:
            continue
        if disciple.worksite_building_id == building.id:
            result.append(disciple.id)
        elif disciple.worksite_building_id == &"" and primary != null and primary.id == building.id:
            result.append(disciple.id)
    return result

func active_worker_ids(state: SimulationState, building: BuildingState) -> Array[StringName]:
    var assigned := assigned_worker_ids(state, building)
    var slots := worker_slots(building)
    if assigned.size() <= slots:
        return assigned
    var result: Array[StringName] = []
    for index in range(slots):
        result.append(assigned[index])
    return result

func can_disciple_work(state: SimulationState, building: BuildingState, disciple: DiscipleState) -> bool:
    if disciple != null and not disciple.active_pve_encounter_id.is_empty():
        return false
    if not state.p3_7_buildings_enabled or building == null:
        return false
    if disciple.region_id != &"sect":
        return false
    return active_worker_ids(state, building).has(disciple.id)

func building_for_profession(state: SimulationState, profession_id: StringName, disciple: DiscipleState = null) -> BuildingState:
    var building_type := building_type_for_profession(profession_id)
    if building_type == &"":
        return null
    return _building_for_disciple(state, building_type, disciple)

func building_type_for_profession(profession_id: StringName) -> StringName:
    var types: Array = DEFINITIONS.keys()
    types.sort()
    for raw_type in types:
        var definition: Dictionary = DEFINITIONS[raw_type]
        if StringName(definition.get("profession_id", "")) == profession_id:
            return StringName(raw_type)
    return &""

func worker_group_for_profession(profession_id: StringName) -> StringName:
    var building_type := building_type_for_profession(profession_id)
    if building_type == &"":
        return &""
    var definition: Dictionary = DEFINITIONS.get(str(building_type), {})
    return StringName(definition.get("worker_group_id", ""))

func is_building_profession(profession_id: StringName) -> bool:
    return building_type_for_profession(profession_id) != &""

func work_available(state: SimulationState, profession_id: StringName, disciple: DiscipleState = null) -> bool:
    match profession_id:
        PROF_MINING, PROF_FORESTRY:
            var producer := building_for_profession(state, profession_id, disciple)
            return producer != null and (disciple == null or (can_disciple_work(state, producer, disciple) and not disciple_has_active_timed_recipe(state,disciple.id)))
        PROF_ALCHEMY:
            if disciple == null:
                for hall in _buildings_of_type(state, TYPE_ALCHEMY_HALL):
                    if _alchemy_has_startable_worker(state, hall):
                        return true
                return false
            return bool(alchemy_can_start(state, disciple).get("ok", false))
        PROF_HERBALISM:
            if disciple != null:
                var field := _building_for_disciple(state, TYPE_SPIRIT_FIELD, disciple)
                return field != null and can_disciple_work(state, field, disciple) and not disciple_has_active_spirit_plot(state, disciple.id, field) and _field_has_startable_plot(state, field)
            for field in _buildings_of_type(state, TYPE_SPIRIT_FIELD):
                if _field_has_startable_plot(state, field):
                    return true
            return false
        _:
            return true

func disciple_has_active_spirit_plot(state: SimulationState, disciple_id: StringName, field: BuildingState = null) -> bool:
    var fields: Array = [field] if field != null else _buildings_of_type(state, TYPE_SPIRIT_FIELD)
    for current_field in fields:
        if current_field == null:
            continue
        var data := _ensure_spirit_field_state(state, current_field)
        for raw_plot in data.get("plots", []):
            if raw_plot is Dictionary and StringName(raw_plot.get("status", "")) == PLOT_GROWING and str(raw_plot.get("assigned_worker_id", "")) == str(disciple_id):
                return true
    return false

func set_spirit_field_policy(state: SimulationState, field_id: StringName, mode: StringName, fixed_crop_id: StringName = &"", priority_weights: Dictionary = {}) -> bool:
    if not state.buildings.has(str(field_id)):
        return false
    var field: BuildingState = state.buildings[str(field_id)]
    if field.building_type != TYPE_SPIRIT_FIELD or not VALID_FIELD_POLICIES.has(mode):
        return false
    if mode != FIELD_POLICY_AUTO_DEMAND and field.level < 10:
        return false
    if mode == FIELD_POLICY_FIXED:
        if not crop_registry.has(fixed_crop_id) or int(crop_registry.definition(fixed_crop_id).get("required_field_level", 1)) > field.level:
            return false
    var data := _ensure_spirit_field_state(state, field)
    var normalized_weights: Dictionary = {}
    if mode == FIELD_POLICY_PRIORITY:
        var keys: Array = priority_weights.keys()
        keys.sort()
        for raw_id in keys:
            var crop_id := StringName(raw_id)
            var weight := maxi(int(priority_weights[raw_id]), 0)
            if weight > 0 and crop_registry.has(crop_id) and int(crop_registry.definition(crop_id).get("required_field_level", 1)) <= field.level:
                normalized_weights[str(crop_id)] = weight
        if normalized_weights.is_empty():
            return false
    data["policy_mode"] = str(mode)
    data["fixed_crop_id"] = str(fixed_crop_id) if mode == FIELD_POLICY_FIXED else ""
    data["priority_weights"] = normalized_weights
    field.production_state = data
    state.building_event_count += 1
    return true

func cancel_spirit_plot(state: SimulationState, field_id: StringName, plot_id: StringName) -> bool:
    if not state.buildings.has(str(field_id)):
        return false
    var field: BuildingState = state.buildings[str(field_id)]
    if field.building_type != TYPE_SPIRIT_FIELD:
        return false
    var data := _ensure_spirit_field_state(state, field)
    var plots: Array = data.get("plots", [])
    for index in range(plots.size()):
        if str(plots[index].get("plot_id", "")) != str(plot_id):
            continue
        if StringName(plots[index].get("status", "")) != PLOT_GROWING:
            return false
        plots[index] = _empty_plot(str(plot_id))
        data["plots"] = plots
        field.production_state = data
        state.building_event_count += 1
        return true
    return false

func upgrade_cost(building: BuildingState) -> Dictionary:
    if building == null or building.level >= building.max_level:
        return {}
    var definition := definition_for(building)
    var level := float(building.level)
    var factor := 1.0 + 0.15 * level + 0.01 * level * level
    var target_level := building.level + 1
    var milestone_mult := 2.0 if MILESTONE_LEVELS.has(target_level) else 1.0
    var cost := {
        MATERIAL_WOOD: maxi(1, int(ceil(float(definition.get("base_wood_cost", 1)) * factor * milestone_mult))),
        MATERIAL_ORE: maxi(1, int(ceil(float(definition.get("base_ore_cost", 1)) * factor * milestone_mult))),
        "spirit_stones": maxi(1, int(ceil(float(definition.get("base_stone_cost", 1)) * factor * milestone_mult)))
    }
    if MILESTONE_LEVELS.has(target_level):
        var component := _milestone_component(building.building_type, target_level)
        if component != "":
            cost[component] = _milestone_component_quantity(building.building_type, target_level)
    return cost

func upgrade_required_work(building: BuildingState) -> float:
    var definition := definition_for(building)
    var target_level := building.level + 1
    var work := float(definition.get("base_upgrade_work", 8.0)) + float(definition.get("upgrade_work_per_level", 2.0)) * float(target_level)
    if MILESTONE_LEVELS.has(target_level):
        work *= 1.75
    return maxf(work, 1.0)

func can_start_upgrade(state: SimulationState, building_id: StringName) -> Dictionary:
    if not state.p3_7_buildings_enabled or not state.buildings.has(str(building_id)):
        return {"ok": false, "reason": "missing_building"}
    var building: BuildingState = state.buildings[str(building_id)]
    if building.is_upgrading():
        return {"ok": false, "reason": "already_upgrading"}
    if building.level >= building.max_level:
        return {"ok": false, "reason": "max_level"}

    # Do not manufacture upgrade economics for facilities whose coefficients
    # and milestone content are not yet authored.
    if not bool(definition_for(building).get("upgrade_enabled", true)):
        return {"ok": false, "reason": "upgrade_content_pending"}
    if building.building_type == TYPE_BODY_TRAINING:
        return {"ok": false, "reason": "body_training_upgrade_content_pending"}
    var target_level := building.level + 1
    var requires_milestone_component := bool(definition_for(building).get("requires_milestone_component", true))
    if MILESTONE_LEVELS.has(target_level) and requires_milestone_component and _milestone_component(building.building_type, target_level) == "":
        return {"ok": false, "reason": "milestone_component_not_defined", "target_level": target_level}

    var cost := upgrade_cost(building)
    var material_ids: Array = cost.keys()
    material_ids.erase("spirit_stones")
    material_ids.sort()
    for material_id in material_ids:
        var need := int(cost.get(material_id, 0))
        var have := _resource_available(state, StringName(material_id))
        if have < need:
            return {"ok": false, "reason": "missing_material", "material_id": str(material_id), "need": need, "have": have}
    var stone_need := int(cost.get("spirit_stones", 0))
    if state.sect.spirit_stones < stone_need:
        return {"ok": false, "reason": "missing_spirit_stones", "need": stone_need, "have": state.sect.spirit_stones}
    return {"ok": true, "cost": cost}

func start_upgrade(state: SimulationState, building_id: StringName) -> Dictionary:
    var check := can_start_upgrade(state, building_id)
    if not bool(check.get("ok", false)):
        return check
    var building: BuildingState = state.buildings[str(building_id)]
    var cost: Dictionary = check.get("cost", {})
    var material_requirements := cost.duplicate(true)
    material_requirements.erase("spirit_stones")
    if not _consume_resources(state, material_requirements):
        return {"ok": false, "reason": "materials_changed"}
    state.sect.spirit_stones -= int(cost.get("spirit_stones", 0))

    building.status = STATUS_UPGRADING
    building.upgrade_target_level = building.level + 1
    building.upgrade_started_tick = state.tick
    building.upgrade_required_work = upgrade_required_work(building)
    building.upgrade_progress = 0.0
    state.building_event_count += 1
    return {
        "ok": true,
        "building_id": str(building.id),
        "target_level": building.upgrade_target_level,
        "required_work": building.upgrade_required_work,
        "cost": cost.duplicate(true)
    }

func process_tick(state: SimulationState) -> void:
    if not state.p3_7_buildings_enabled:
        return
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if not (building is BuildingState):
            continue
        if building.is_upgrading():
            building.upgrade_progress += 1.0
            if building.upgrade_progress + 0.000001 >= building.upgrade_required_work:
                _complete_upgrade(state, building)
        if building.building_type == TYPE_SPIRIT_FIELD:
            _process_spirit_field_plots(state, building)
        elif building.building_type == TYPE_ALCHEMY_HALL:
            _process_alchemy_jobs(state, building)
        if state.sect.economy_a_enabled and (building.building_type == TYPE_MINE or building.building_type == TYPE_LINH_FOREST):
            _process_resource_timers(state,building)

func _default_alchemy_state() -> Dictionary:
    return {"recipe_enabled": true, "recipe_id": str(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN), "job_sequence": 0, "jobs": []}

func _ensure_alchemy_state(hall: BuildingState) -> Dictionary:
    if hall == null or hall.building_type != TYPE_ALCHEMY_HALL:
        return {}
    var raw := hall.production_state
    var data: Dictionary = raw.duplicate(true) if raw is Dictionary else {}
    data["recipe_enabled"] = bool(data.get("recipe_enabled", true))
    var recipe_id := StringName(data.get("recipe_id", str(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN)))
    if not alchemy_registry.has(recipe_id):
        recipe_id = AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN
    data["recipe_id"] = str(recipe_id)
    data["job_sequence"] = maxi(int(data.get("job_sequence", 0)), 0)
    var jobs: Array = []
    var seen_workers: Dictionary = {}
    var raw_jobs = data.get("jobs", [])
    if raw_jobs is Array:
        for raw_job in raw_jobs:
            if not (raw_job is Dictionary):
                continue
            var worker_id := str(raw_job.get("worker_id", ""))
            var job_id := str(raw_job.get("job_id", ""))
            var current_recipe := StringName(raw_job.get("recipe_id", ""))
            if worker_id == "" or job_id == "" or seen_workers.has(worker_id) or not alchemy_registry.has(current_recipe):
                continue
            var started_tick := int(raw_job.get("started_tick", 0))
            var finish_tick := int(raw_job.get("finish_tick", started_tick + 1))
            if finish_tick <= started_tick:
                continue
            var inputs_raw = raw_job.get("inputs", {})
            var inputs: Dictionary = inputs_raw.duplicate(true) if inputs_raw is Dictionary else {}
            jobs.append({
                "job_id": job_id,
                "recipe_id": str(current_recipe),
                "worker_id": worker_id,
                "started_tick": started_tick,
                "finish_tick": finish_tick,
                "inputs": inputs,
                "output_resource_id": str(raw_job.get("output_resource_id", alchemy_registry.output_resource_id(current_recipe))),
                "output_quantity": maxi(int(raw_job.get("output_quantity", alchemy_registry.output_quantity(current_recipe))), 1),
                "profession_xp_gain": maxf(float(raw_job.get("profession_xp_gain", 0.0)), 0.0),
                "economy_a_wage_eligible": bool(raw_job.get("economy_a_wage_eligible", false))
            })
            seen_workers[worker_id] = true
    data["jobs"] = jobs
    hall.production_state = data
    return data

func alchemy_jobs(state: SimulationState, hall: BuildingState = null) -> Array:
    var target := hall if hall != null else primary_building(state, TYPE_ALCHEMY_HALL)
    if target == null:
        return []
    return Array(_ensure_alchemy_state(target).get("jobs", [])).duplicate(true)

func active_alchemy_job_for_worker(state: SimulationState, disciple_id: StringName) -> Dictionary:
    for hall in _buildings_of_type(state, TYPE_ALCHEMY_HALL):
        for raw_job in alchemy_jobs(state, hall):
            if raw_job is Dictionary and str(raw_job.get("worker_id", "")) == str(disciple_id):
                return (raw_job as Dictionary).duplicate(true)
    return {}

func disciple_has_active_timed_recipe(state: SimulationState, disciple_id: StringName) -> bool:
    return not active_alchemy_job_for_worker(state, disciple_id).is_empty() or not active_resource_timer_for_worker(state, disciple_id).is_empty()

func set_alchemy_recipe_enabled(state: SimulationState, hall_id: StringName, enabled: bool) -> bool:
    if not state.buildings.has(str(hall_id)):
        return false
    var hall: BuildingState = state.buildings[str(hall_id)]
    if hall.building_type != TYPE_ALCHEMY_HALL:
        return false
    var data := _ensure_alchemy_state(hall)
    data["recipe_enabled"] = enabled
    hall.production_state = data
    state.building_event_count += 1
    return true

func alchemy_can_start(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if disciple == null or disciple.region_id != &"sect":
        return {"ok": false, "reason": "invalid_worker"}
    var hall := _building_for_disciple(state, TYPE_ALCHEMY_HALL, disciple)
    if hall == null or not can_disciple_work(state, hall, disciple):
        return {"ok": false, "reason": "no_active_alchemy_slot"}
    var data := _ensure_alchemy_state(hall)
    if not bool(data.get("recipe_enabled", true)):
        return {"ok": false, "reason": "recipe_policy_disabled"}
    if disciple_has_active_timed_recipe(state, disciple.id):
        return {"ok": false, "reason": "worker_busy_alchemy"}
    var recipe_id := StringName(data.get("recipe_id", str(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN)))
    var requirements := alchemy_registry.inputs(recipe_id)
    if not warehouse.can_consume_requirements(state, requirements):
        return {"ok": false, "reason": "insufficient_or_reserved_inputs"}
    return {"ok": true, "hall_id": str(hall.id), "recipe_id": str(recipe_id), "requirements": requirements}

func perform_alchemy_step(state: SimulationState, disciple: DiscipleState, profession_level: int, work_speed: float, profession_xp_gain: float) -> Dictionary:
    var check := alchemy_can_start(state, disciple)
    if not bool(check.get("ok", false)):
        return {"ok": false, "completed": false, "reason": str(check.get("reason", "cannot_start"))}
    var hall: BuildingState = state.buildings[str(check.get("hall_id", ""))]
    var data := _ensure_alchemy_state(hall)
    var recipe_id := StringName(check.get("recipe_id", ""))
    if profession_level < alchemy_registry.required_profession_level(recipe_id):
        return {"ok": false, "completed": false, "reason": "profession_level_too_low"}
    var requirements: Dictionary = check.get("requirements", {}).duplicate(true)
    if not warehouse.consume_requirements(state, requirements):
        return {"ok": false, "completed": false, "reason": "input_commit_failed"}
    var sequence := int(data.get("job_sequence", 0)) + 1
    var duration := maxi(1, int(ceil(float(alchemy_registry.base_cycle_ticks(recipe_id)) / maxf(work_speed, 0.25))))
    var job := {
        "job_id": "%s_job_%06d" % [str(hall.id), sequence],
        "recipe_id": str(recipe_id),
        "worker_id": str(disciple.id),
        "started_tick": state.tick,
        "finish_tick": state.tick + duration,
        "inputs": requirements.duplicate(true),
        "output_resource_id": str(alchemy_registry.output_resource_id(recipe_id)),
        "output_quantity": alchemy_registry.output_quantity(recipe_id),
        "profession_xp_gain": maxf(profession_xp_gain, 0.0),
        "economy_a_wage_eligible": state.sect.economy_a_enabled and DiscipleRealmProgressV2.owns_v2_progression(disciple)
    }
    var jobs: Array = data.get("jobs", [])
    jobs.append(job)
    data["jobs"] = jobs
    data["job_sequence"] = sequence
    hall.production_state = data
    state.building_event_count += 1
    return {"ok": true, "completed": false, "started": true, "job": job.duplicate(true), "building_id": str(hall.id), "finish_tick": int(job["finish_tick"])}

func _alchemy_has_startable_worker(state: SimulationState, hall: BuildingState) -> bool:
    for worker_id in active_worker_ids(state, hall):
        if state.disciples.has(worker_id) and bool(alchemy_can_start(state, state.disciples[worker_id]).get("ok", false)):
            return true
    return false

func _process_alchemy_jobs(state: SimulationState, hall: BuildingState) -> void:
    var data := _ensure_alchemy_state(hall)
    var jobs: Array = data.get("jobs", [])
    if jobs.is_empty():
        return
    var remaining: Array = []
    var changed := false
    for raw_job in jobs:
        var job: Dictionary = raw_job
        if state.tick < int(job.get("finish_tick", state.tick + 1)):
            remaining.append(job)
            continue
        var output_id := StringName(job.get("output_resource_id", ""))
        var output_quantity := maxi(int(job.get("output_quantity", 0)), 0)
        if output_id == &"" or output_quantity <= 0 or not _deposit_resource(state, hall, str(output_id), output_quantity):
            remaining.append(job)
            continue
        var worker_id := StringName(job.get("worker_id", ""))
        if state.disciples.has(worker_id):
            var worker: DiscipleState = state.disciples[worker_id]
            var xp_gain := maxf(float(job.get("profession_xp_gain", 0.0)), 0.0)
            if xp_gain > 0.0:
                worker.profession_xp[str(PROF_ALCHEMY)] = float(worker.profession_xp.get(str(PROF_ALCHEMY), 0.0)) + xp_gain
            worker.metrics["work_completions"] = int(worker.metrics.get("work_completions", 0)) + 1
            worker.metrics["alchemy_completions"] = int(worker.metrics.get("alchemy_completions", 0)) + 1
            state.sect.workforce_event_count += 1
            if state.sect.economy_a_enabled and bool(job.get("economy_a_wage_eligible", false)):
                EconomySystem.new().settle_work_wage(state, worker, str(job.get("job_id", "")))
        changed = true
    if changed:
        data["jobs"] = remaining
        hall.production_state = data
        state.building_event_count += 1

func perform_mining_step(state: SimulationState, disciple: DiscipleState, work_speed: float, profession_xp_gain: float = 0.0) -> Dictionary:
    return perform_resource_job_step(state, disciple, work_speed, PROF_MINING, profession_xp_gain)

func perform_forestry_step(state: SimulationState, disciple: DiscipleState, work_speed: float, profession_xp_gain: float = 0.0) -> Dictionary:
    return perform_resource_job_step(state, disciple, work_speed, PROF_FORESTRY, profession_xp_gain)

# Generic carry-cycle producer used by Mine and Linh Lâm. Spirit Field remains
# plot/timer authority and intentionally does not use this envelope.
func perform_resource_job_step(state: SimulationState, disciple: DiscipleState, work_speed: float, profession_id: StringName, profession_xp_gain: float = 0.0) -> Dictionary:
    var producer := building_for_profession(state, profession_id, disciple)
    if producer == null or not can_disciple_work(state, producer, disciple):
        var slot_reason := "no_active_building_slot"
        if profession_id == PROF_MINING:
            slot_reason = "no_active_mine_slot"
        elif profession_id == PROF_FORESTRY:
            slot_reason = "no_active_linh_forest_slot"
        return {"ok": false, "completed": false, "reason": slot_reason}

    # Old TRAVEL/EXTRACT/HAUL cycles drain to canonical Warehouse without
    # resetting carried_units. Only *new* V2 jobs use the opt-in timer.
    if state.sect.economy_a_enabled and DiscipleRealmProgressV2.owns_v2_progression(disciple) and disciple.work_cycle_state.is_empty():
        return _start_resource_timer(state,producer,disciple,work_speed,profession_id,profession_xp_gain)
    var definition := definition_for(producer)
    if str(definition.get("job_model", "")) != "carry_cycle":
        return {"ok": false, "completed": false, "reason": "unsupported_job_model"}

    var phases = definition.get("cycle_phases", [])
    if not (phases is Array) or phases.size() < 3:
        return {"ok": false, "completed": false, "reason": "invalid_job_definition"}
    var start_phase := StringName(phases[0])
    var work_phase := StringName(definition.get("cycle_work_phase", ""))
    var resource_id := StringName(definition.get("resource_id", ""))
    if work_phase == &"" or resource_id == &"":
        return {"ok": false, "completed": false, "reason": "invalid_job_definition"}

    var cycle := disciple.work_cycle_state.duplicate(true)
    var cycle_profession := StringName(cycle.get("profession_id", cycle.get("profession", "")))
    if cycle_profession != profession_id or str(cycle.get("building_id", "")) != str(producer.id):
        cycle = {
            "profession": str(profession_id),
            "profession_id": str(profession_id),
            "building_id": str(producer.id),
            "resource_id": str(resource_id),
            "phase": str(start_phase),
            "progress": 0.0,
            "carried_units": 0
        }
    else:
        # Normalize old Mine saves forward without renaming their phases.
        cycle["profession"] = str(profession_id)
        cycle["profession_id"] = str(profession_id)
        cycle["resource_id"] = str(resource_id)

    var phase := StringName(cycle.get("phase", str(start_phase)))
    var progress := maxf(float(cycle.get("progress", 0.0)), 0.0)
    var result := {
        "ok": true,
        "completed": false,
        "phase": str(phase),
        "profession_id": str(profession_id),
        "building_id": str(producer.id),
        "resource_id": str(resource_id),
        "stamina_cost": 1.0
    }

    if phase == &"travel_out":
        progress += _movement_speed(state, disciple)
        if progress + 0.000001 >= float(definition.get("work_distance", 8.0)):
            phase = work_phase
            progress = 0.0
    elif phase == work_phase:
        progress += maxf(work_speed, 0.25)
        result["stamina_cost"] = 3.0
        if progress + 0.000001 >= _resource_job_duration(producer):
            phase = &"haul_back"
            progress = 0.0
            cycle["carried_units"] = _resource_job_batch_units(producer)
    elif phase == &"haul_back":
        progress += _movement_speed(state, disciple) * _haul_speed_multiplier(disciple)
        if progress + 0.000001 >= float(definition.get("haul_distance", 6.0)):
            var produced := maxi(int(cycle.get("carried_units", 0)), 1)
            _deposit_resource(state, producer, str(resource_id), produced)
            phase = &"complete"
            progress = 0.0
            cycle["carried_units"] = 0
            result["completed"] = true
            result["produced"] = produced
            result["deposited_to"] = "sect_main_warehouse"
    else:
        phase = start_phase
        progress = 0.0
        cycle["carried_units"] = 0

    result["next_phase"] = str(phase)
    result["progress"] = progress
    if bool(result.get("completed", false)):
        disciple.work_cycle_state.clear()
    else:
        cycle["phase"] = str(phase)
        cycle["progress"] = progress
        disciple.work_cycle_state = cycle
    return result

func perform_spirit_field_step(state: SimulationState, disciple: DiscipleState, work_speed: float) -> Dictionary:
    var field := _building_for_disciple(state, TYPE_SPIRIT_FIELD, disciple)
    if field == null or not can_disciple_work(state, field, disciple):
        return {"ok": false, "completed": false, "reason": "no_active_spirit_field_slot"}

    var data := _ensure_spirit_field_state(state, field)
    var plots: Array = data.get("plots", [])
    var empty_indices: Array[int] = []
    for index in range(plots.size()):
        if plots[index] is Dictionary and StringName(plots[index].get("status", "")) == PLOT_EMPTY:
            empty_indices.append(index)
    if empty_indices.is_empty():
        return {"ok": false, "completed": false, "reason": "no_empty_plot"}

    # A field operator starts one FIELD DUTY that may seed several internal
    # plots. Those plot timers are sub-state of this single occupation, not
    # separate disciple jobs. This preserves one-active-job while allowing one
    # person to manage the four-plot building.
    var first_crop := _select_crop(state, field, data)
    if first_crop == &"":
        return {"ok": false, "completed": false, "reason": "no_affordable_crop"}

    var plant_sequence := int(data.get("plant_sequence", 0)) + 1
    var duty_job_id := "%s:duty:%06d" % [str(field.id), plant_sequence]
    var wage_job_id := duty_job_id if state.sect.economy_a_enabled and DiscipleRealmProgressV2.owns_v2_progression(disciple) else ""
    var remainders = data.get("plot_work_remainders_bp", {})
    var plot_remainders: Dictionary = remainders.duplicate(true) if remainders is Dictionary else {}
    var started_plots: Array = []
    var total_cost := 0
    var xp_basis := 0.0

    for plot_index in empty_indices:
        var crop_id := _select_crop(state, field, data)
        if crop_id == &"":
            break
        var plant_cost := crop_registry.cost(crop_id)
        if state.sect.spirit_stones < plant_cost:
            break

        var affinity := _crop_affinity_factor(disciple, crop_id)
        var total_speed := maxf(work_speed, 0.25) * spirit_field_speed_factor(field) * affinity
        var base_duration := float(crop_registry.base_cycle_ticks(crop_id)) * spirit_field_cycle_time_factor(field)
        var plot_id := str(plots[plot_index].get("plot_id", "plot_%03d" % [plot_index + 1]))
        var timing := _timed_duration_plan(base_duration, total_speed, int(plot_remainders.get(plot_id, 0)))
        var routine_yield := maxi(1, int(round(float(crop_registry.base_yield(crop_id)) * spirit_field_yield_factor(field))))
        var rare_factor := profession_modifiers.rare_event_factor(state, disciple)

        state.sect.spirit_stones -= plant_cost
        total_cost += plant_cost
        xp_basis = maxf(xp_basis, crop_registry.base_work_xp(crop_id))
        plots[plot_index] = {
            "plot_id": plot_id,
            "crop_id": str(crop_id),
            "status": str(PLOT_GROWING),
            "started_tick": state.tick,
            "finish_tick": state.tick + int(timing["duration_ticks"]),
            "assigned_worker_id": str(disciple.id),
            "paid_spirit_stones": plant_cost,
            "routine_yield": routine_yield,
            "rare_factor": rare_factor,
            "economy_a_wage_job_id": wage_job_id,
            "completion_work_remainder_bp": int(timing["completion_remainder_bp"])
        }
        started_plots.append(plot_id)

    if started_plots.is_empty():
        return {"ok": false, "completed": false, "reason": "insufficient_spirit_stones"}

    data["plots"] = plots
    data["plant_sequence"] = plant_sequence
    data["plot_work_remainders_bp"] = plot_remainders
    field.production_state = data
    state.building_event_count += 1

    return {
        "ok": true,
        "completed": true,
        "work_kind": "start_field_duty",
        "building_id": str(field.id),
        "duty_job_id": duty_job_id,
        "plot_ids": started_plots,
        "plots_started": started_plots.size(),
        "paid_spirit_stones": total_cost,
        "base_work_xp": xp_basis if xp_basis > 0.0 else BASE_WORK_XP,
        "field_xp_factor": spirit_field_xp_factor(field),
        "stamina_cost": 0.0
    }

# ECONOMY-A duration/quantity pilot; real authority = saved building jobs +
# the existing SimulationScheduler.process_tick. Animations never settle goods.
func resource_timer_jobs(building: BuildingState) -> Array:
    if building == null:
        return []
    var value = building.production_state.get("economy_a_jobs",[])
    return value.duplicate(true) if value is Array else []

func active_resource_timer_for_worker(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not state.sect.economy_a_enabled:
        return {}
    for raw_building in state.buildings.values():
        if not (raw_building is BuildingState):
            continue
        var building: BuildingState = raw_building
        if building.building_type != TYPE_MINE and building.building_type != TYPE_LINH_FOREST:
            continue
        for raw_job in resource_timer_jobs(building):
            if raw_job is Dictionary and str(raw_job.get("worker_id","")) == str(disciple_id):
                return (raw_job as Dictionary).duplicate(true)
    return {}

func _start_resource_timer(state: SimulationState, producer: BuildingState, actor: DiscipleState, speed: float, profession_id: StringName, xp_gain: float) -> Dictionary:
    if not state.sect.p3_7_resources_enabled or not can_disciple_work(state,producer,actor):
        return {"ok":false,"reason":"missing_canonical_job_slot"}
    if disciple_has_active_timed_recipe(state,actor.id) or disciple_has_active_spirit_plot(state,actor.id) or actor.work_group_id == &"body_training_crew":
        return {"ok":false,"reason":"another_active_job"}
    if producer.building_type == TYPE_MINE and resource_timer_jobs(producer).size() >= 1:
        return {"ok":false,"reason":"mine_job_already_running"}
    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"worker_not_available"}
    var definition := definition_for(producer)
    if StringName(definition.get("profession_id","")) != profession_id:
        return {"ok":false,"reason":"wrong_job_profession"}
    var policy := state.sect.economy_a_policy
    var base_duration := clampi(int(policy.get("resource_duration_ticks",10)),1,1440)
    var data := producer.production_state.duplicate(true)
    var timing := _timed_duration_plan(float(base_duration), maxf(speed,0.25), int(data.get("economy_a_work_remainder_bp",0)))
    var duration := int(timing["duration_ticks"])
    var jobs := resource_timer_jobs(producer)
    var sequence := maxi(int(data.get("economy_a_sequence",0)),0)+1
    var job := {
        "job_id":"%s:v1:%d" % [str(producer.id),sequence],
        "worker_id":str(actor.id),"profession_id":str(profession_id),
        "resource_id":str(definition.get("resource_id","")),
        "output_quantity":_resource_job_batch_units(producer),
        "profession_xp_gain":maxf(xp_gain,0.0),
        "started_tick":state.tick,"finish_tick":state.tick+duration,
        "completion_work_remainder_bp":int(timing["completion_remainder_bp"])
    }
    jobs.append(job)
    data["economy_a_sequence"] = sequence
    data["economy_a_jobs"] = jobs
    producer.production_state = data
    state.building_event_count += 1
    return {"ok":true,"started":true,"completed":false,"job_id":str(job["job_id"]),"finish_tick":int(job["finish_tick"]),"phase":"timed","profession_id":str(profession_id),"building_id":str(producer.id),"stamina_cost":0.0}

func cancel_resource_timer(state: SimulationState, disciple_id: StringName) -> bool:
    if not state.sect.economy_a_enabled:
        return false
    for raw_building in state.buildings.values():
        if not (raw_building is BuildingState):
            continue
        var building: BuildingState = raw_building
        if building.building_type != TYPE_MINE and building.building_type != TYPE_LINH_FOREST:
            continue
        var jobs := resource_timer_jobs(building)
        for index in range(jobs.size()):
            if jobs[index] is Dictionary and str(jobs[index].get("worker_id","")) == str(disciple_id):
                jobs.remove_at(index)
                var data := building.production_state.duplicate(true)
                data["economy_a_jobs"] = jobs
                building.production_state = data
                state.building_event_count += 1
                return true
    return false

func _process_resource_timers(state: SimulationState, building: BuildingState) -> void:
    var jobs := resource_timer_jobs(building)
    if jobs.is_empty():
        return
    var remaining: Array = []
    var changed := false
    for raw_job in jobs:
        if not (raw_job is Dictionary):
            remaining.append(raw_job)
            continue
        var job: Dictionary = raw_job
        var worker_id := StringName(job.get("worker_id",""))
        if not state.disciples.has(worker_id):
            remaining.append(job)
            continue
        var worker: DiscipleState = state.disciples[worker_id]
        if worker.active_pve_encounter_id != "":
            remaining.append(job)
            continue
        if state.tick < int(job.get("finish_tick",state.tick+1)):
            if StringName(job.get("profession_id","")) == PROF_MINING:
                _award_timed_mining_body_minute(state,worker,building)
            remaining.append(job)
            continue
        var resource_id := StringName(job.get("resource_id",""))
        var units := int(job.get("output_quantity",0))
        var job_id := str(job.get("job_id",""))
        if job_id.is_empty() or units <= 0 or not warehouse.add(state,resource_id,units):
            remaining.append(job)
            continue
        building.metrics["production_batches"] = int(building.metrics.get("production_batches",0))+1
        building.metrics["units_produced"] = int(building.metrics.get("units_produced",0))+units
        var profession := str(job.get("profession_id",""))
        worker.profession_xp[profession] = float(worker.profession_xp.get(profession,0.0))+maxf(float(job.get("profession_xp_gain",0.0)),0.0)
        worker.metrics["work_completions"] = int(worker.metrics.get("work_completions",0))+1
        worker.metrics["%s_completions" % profession] = int(worker.metrics.get("%s_completions" % profession,0))+1
        state.sect.workforce_event_count += 1
        EconomySystem.new().settle_work_wage(state,worker,job_id)
        # Only a successfully delivered batch commits the timing overshoot.
        # Cancelled/blocked jobs never bank phantom progress.
        var committed_data := building.production_state.duplicate(true)
        committed_data["economy_a_work_remainder_bp"] = maxi(int(job.get("completion_work_remainder_bp",0)),0)
        building.production_state = committed_data
        changed = true
    if changed:
        var data := building.production_state.duplicate(true)
        data["economy_a_jobs"] = remaining
        building.production_state = data
        state.building_event_count += 1

func _award_timed_mining_body_minute(state: SimulationState, worker: DiscipleState, mine: BuildingState) -> void:
    if not state.sect.v2_training_enabled or not DiscipleRealmProgressV2.owns_v2_progression(worker):
        return
    var body_rule = state.sect.v2_training_rules.get("body",null)
    if not (body_rule is Dictionary):
        return
    DiscipleBodyXpSourceV2.commit_minute(state,worker,{
        "source_id":"p3_7_mine_active_extraction:%s" % str(mine.id),
        "source_kind":DiscipleBodyXpSourceV2.SOURCE_PRODUCTION,
        "base_body_xp_per_minute":DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE,
        "floor_costs":body_rule.get("floor_costs",{}),
        "modifiers":[],"active_work_verified":true
    },"dv2:mine:active:%s:%d" % [str(worker.id),state.tick])

func cancel_work_cycle(state: SimulationState, disciple: DiscipleState, settle_carried: bool = true) -> int:
    if disciple.work_cycle_state.is_empty():
        return 0
    var cycle := disciple.work_cycle_state
    var profession := StringName(cycle.get("profession_id", cycle.get("profession", "")))
    var deposited := 0
    if settle_carried:
        var carried := maxi(int(cycle.get("carried_units", 0)), 0)
        var building_id := StringName(cycle.get("building_id", ""))
        var producer = state.buildings.get(str(building_id))
        if carried > 0 and producer is BuildingState:
            var definition := definition_for(producer)
            var expected_profession := StringName(definition.get("profession_id", ""))
            var resource_id := StringName(cycle.get("resource_id", definition.get("resource_id", "")))
            if (
                str(definition.get("job_model", "")) == "carry_cycle"
                and profession == expected_profession
                and resource_id != &""
            ):
                _deposit_resource(state, producer, str(resource_id), carried)
                deposited = carried
    disciple.work_cycle_state.clear()
    return deposited

func clear_work_cycle(disciple: DiscipleState, profession_id: StringName = &"") -> void:
    if profession_id == &"" or StringName(disciple.work_cycle_state.get("profession", "")) == profession_id:
        disciple.work_cycle_state.clear()

func definition_for(building: BuildingState) -> Dictionary:
    if building == null:
        return {}
    return DEFINITIONS.get(str(building.building_type), {})

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.p3_7_buildings_enabled:
        if not state.buildings.is_empty() or state.building_event_count != 0:
            errors.append("P3.7 building data exists while the authority is disabled.")
        return errors
    if not state.sect.workforce_enabled:
        errors.append("P3.7 buildings require workforce authority.")
    if state.building_event_count < 0:
        errors.append("Building event count is negative.")

    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if not (building is BuildingState):
            errors.append("Building %s has invalid state type." % str(raw_id))
            continue
        if str(building.id) != str(raw_id):
            errors.append("Building key/id mismatch for %s." % str(raw_id))
        if definition_for(building).is_empty():
            errors.append("Building %s has unknown type %s." % [building.id, building.building_type])
        if building.level < 1 or building.level > building.max_level:
            errors.append("Building %s has invalid level." % building.id)
        if not VALID_STATUSES.has(building.status):
            errors.append("Building %s has invalid status." % building.id)
        if building.is_upgrading():
            if building.upgrade_target_level != building.level + 1:
                errors.append("Building %s has invalid upgrade target." % building.id)
            if building.upgrade_required_work <= 0.0 or building.upgrade_progress < 0.0:
                errors.append("Building %s has invalid upgrade progress." % building.id)
        elif building.upgrade_target_level != 0 or building.upgrade_required_work > 0.0 or building.upgrade_progress > 0.0:
            errors.append("Building %s has stale upgrade state." % building.id)
        for milestone in building.unlocked_milestones:
            if not MILESTONE_LEVELS.has(milestone) or milestone > building.level:
                errors.append("Building %s has invalid milestone %d." % [building.id, milestone])

        if [TYPE_MINE, TYPE_LINH_FOREST, TYPE_SPIRIT_FIELD].has(building.building_type) and assigned_worker_ids(state, building).size() > 1:
            errors.append("%s %s has more than one assigned operator." % [str(building.building_type), str(building.id)])
        if state.sect.economy_a_enabled and (building.building_type == TYPE_MINE or building.building_type == TYPE_LINH_FOREST):
            var resource_ids: Dictionary = {}
            var resource_workers: Dictionary = {}
            for raw_timer in resource_timer_jobs(building):
                if not (raw_timer is Dictionary):
                    errors.append("Economy-A invalid resource timer.")
                    continue
                var timer: Dictionary = raw_timer
                var timer_id := str(timer.get("job_id",""))
                var timer_worker := str(timer.get("worker_id",""))
                if timer_id.is_empty() or resource_ids.has(timer_id) or timer_worker.is_empty() or resource_workers.has(timer_worker) or not state.disciples.has(StringName(timer_worker)):
                    errors.append("Economy-A invalid/duplicate resource timer owner.")
                resource_ids[timer_id] = true
                resource_workers[timer_worker] = true
                if int(timer.get("finish_tick",0)) <= int(timer.get("started_tick",-1)):
                    errors.append("Economy-A invalid resource timer deadline.")
        if building.building_type == TYPE_ALCHEMY_HALL:
            var alchemy_data := _ensure_alchemy_state(building)
            var seen_job_ids: Dictionary = {}
            var seen_workers: Dictionary = {}
            for raw_job in alchemy_data.get("jobs", []):
                if not (raw_job is Dictionary):
                    errors.append("Alchemy Hall %s contains invalid job data." % building.id)
                    continue
                var job_id := str(raw_job.get("job_id", ""))
                var worker_id := str(raw_job.get("worker_id", ""))
                if job_id == "" or seen_job_ids.has(job_id):
                    errors.append("Alchemy Hall %s has invalid/duplicate job id." % building.id)
                seen_job_ids[job_id] = true
                if worker_id == "" or seen_workers.has(worker_id) or not state.disciples.has(StringName(worker_id)):
                    errors.append("Alchemy Hall %s has invalid/duplicate worker reservation." % building.id)
                seen_workers[worker_id] = true
                if int(raw_job.get("finish_tick", 0)) <= int(raw_job.get("started_tick", -1)):
                    errors.append("Alchemy Hall %s has invalid job timer." % building.id)

        if building.building_type == TYPE_SPIRIT_FIELD:
            var data = building.production_state
            if not (data is Dictionary) or not data.has("plots"):
                errors.append("Spirit Field %s has no canonical plot state." % building.id)
            else:
                var policy := StringName(data.get("policy_mode", ""))
                if not VALID_FIELD_POLICIES.has(policy):
                    errors.append("Spirit Field %s has invalid crop policy." % building.id)
                var plots = data.get("plots", [])
                if not (plots is Array) or plots.size() != spirit_plot_slots(building):
                    errors.append("Spirit Field %s has invalid plot count." % building.id)
                else:
                    var seen_plot_ids: Dictionary = {}
                    var plot_workers: Dictionary = {}
                    for raw_plot in plots:
                        if not (raw_plot is Dictionary):
                            errors.append("Spirit Field %s contains invalid plot data." % building.id)
                            continue
                        var plot_id := str(raw_plot.get("plot_id", ""))
                        var plot_status := StringName(raw_plot.get("status", ""))
                        if plot_id == "" or seen_plot_ids.has(plot_id):
                            errors.append("Spirit Field %s has invalid/duplicate plot id." % building.id)
                        seen_plot_ids[plot_id] = true
                        if plot_status != PLOT_EMPTY and plot_status != PLOT_GROWING:
                            errors.append("Spirit Field %s plot %s has invalid status." % [building.id, plot_id])
                        if plot_status == PLOT_GROWING:
                            var crop_id := StringName(raw_plot.get("crop_id", ""))
                            if not crop_registry.has(crop_id):
                                errors.append("Spirit Field %s plot %s has unknown crop." % [building.id, plot_id])
                            if int(raw_plot.get("finish_tick", 0)) <= int(raw_plot.get("started_tick", -1)):
                                errors.append("Spirit Field %s plot %s has invalid timer." % [building.id, plot_id])
                            if int(raw_plot.get("paid_spirit_stones", -1)) < 0:
                                errors.append("Spirit Field %s plot %s has invalid paid cost." % [building.id, plot_id])
                            var plot_worker := str(raw_plot.get("assigned_worker_id",""))
                            if plot_worker.is_empty() or not state.disciples.has(StringName(plot_worker)):
                                errors.append("Spirit Field %s plot %s has invalid operator." % [building.id, plot_id])
                            else:
                                plot_workers[plot_worker] = true
                    if plot_workers.size() > 1:
                        errors.append("Spirit Field %s has plots owned by multiple operators." % building.id)

    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.work_cycle_state.is_empty():
            continue
        var profession := StringName(disciple.work_cycle_state.get("profession_id", disciple.work_cycle_state.get("profession", "")))
        var building_id := str(disciple.work_cycle_state.get("building_id", ""))
        var phase := StringName(disciple.work_cycle_state.get("phase", ""))
        if not state.buildings.has(building_id):
            errors.append("%s references missing work-cycle building." % disciple.display_name)
        else:
            var cycle_building = state.buildings[building_id]
            if cycle_building is BuildingState:
                var cycle_definition := definition_for(cycle_building)
                var expected_profession := StringName(cycle_definition.get("profession_id", ""))
                var job_model := str(cycle_definition.get("job_model", ""))
                if job_model == "carry_cycle":
                    if profession != expected_profession:
                        errors.append("%s work-cycle profession/building mismatch." % disciple.display_name)
                    var valid_phases = cycle_definition.get("cycle_phases", [])
                    if not (valid_phases is Array) or not valid_phases.has(str(phase)):
                        errors.append("%s has invalid resource-job phase." % disciple.display_name)
                    var expected_resource := StringName(cycle_definition.get("resource_id", ""))
                    var cycle_resource := StringName(disciple.work_cycle_state.get("resource_id", str(expected_resource)))
                    if expected_resource == &"" or cycle_resource != expected_resource:
                        errors.append("%s has invalid resource-job output identity." % disciple.display_name)
                elif profession == PROF_HERBALISM:
                    # Legacy pre-plot Field cycle compatibility only.
                    if not [&"travel_out", &"tending", &"harvesting", &"haul_back"].has(phase):
                        errors.append("%s has invalid herbalism work-cycle phase." % disciple.display_name)
                else:
                    errors.append("%s has unsupported P3.7 work-cycle profession." % disciple.display_name)
        if float(disciple.work_cycle_state.get("progress", 0.0)) < 0.0 or int(disciple.work_cycle_state.get("carried_units", 0)) < 0:
            errors.append("%s has invalid work-cycle progress." % disciple.display_name)
    return errors

func _complete_upgrade(state: SimulationState, building: BuildingState) -> void:
    building.level = clampi(building.upgrade_target_level, 1, building.max_level)
    if MILESTONE_LEVELS.has(building.level) and not building.unlocked_milestones.has(building.level):
        building.unlocked_milestones.append(building.level)
        building.unlocked_milestones.sort()
    building.status = STATUS_ACTIVE
    building.upgrade_target_level = 0
    building.upgrade_started_tick = -1
    building.upgrade_required_work = 0.0
    building.upgrade_progress = 0.0
    building.metrics["upgrade_completions"] = int(building.metrics.get("upgrade_completions", 0)) + 1
    state.building_event_count += 1

func _process_spirit_field_plots(state: SimulationState, field: BuildingState) -> void:
    var data := _ensure_spirit_field_state(state, field)
    var plots: Array = data.get("plots", [])
    var changed := false
    for index in range(plots.size()):
        var plot: Dictionary = plots[index]
        if StringName(plot.get("status", "")) != PLOT_GROWING:
            continue
        if state.tick < int(plot.get("finish_tick", state.tick + 1)):
            continue
        if not _resolve_spirit_plot(state, field, plot):
            continue
        var plot_id := str(plot.get("plot_id", "plot_%03d" % [index + 1]))
        var stored_remainders = data.get("plot_work_remainders_bp", {})
        var plot_remainders: Dictionary = stored_remainders.duplicate(true) if stored_remainders is Dictionary else {}
        plot_remainders[plot_id] = maxi(int(plot.get("completion_work_remainder_bp",0)),0)
        data["plot_work_remainders_bp"] = plot_remainders
        plots[index] = _empty_plot(plot_id)
        changed = true
    if changed:
        data["plots"] = plots
        field.production_state = data
        state.building_event_count += 1

func lucky_harvest_multiplier(rare_factor: float, roll: float) -> int:
    var factor := maxf(rare_factor, 0.0)
    var value := clampf(roll, 0.0, 0.999999999)
    var p4 := 0.002 * factor
    var p3 := 0.008 * factor
    var p2 := 0.030 * factor
    if value < p4:
        return 4
    if value < p4 + p3:
        return 3
    if value < p4 + p3 + p2:
        return 2
    return 1

func spirit_field_plots(state: SimulationState, field: BuildingState) -> Array:
    if field == null or field.building_type != TYPE_SPIRIT_FIELD:
        return []
    return Array(_ensure_spirit_field_state(state, field).get("plots", [])).duplicate(true)

func _resolve_spirit_plot(state: SimulationState, field: BuildingState, plot: Dictionary) -> bool:
    var crop_id := StringName(plot.get("crop_id", ""))
    if not crop_registry.has(crop_id):
        return false
    var roll := _stable_plot_roll(state.seed, str(field.id), str(plot.get("plot_id", "")), int(plot.get("started_tick", 0)))
    var lucky := lucky_harvest_multiplier(float(plot.get("rare_factor", 1.0)), roll)
    var quantity := maxi(int(plot.get("routine_yield", crop_registry.base_yield(crop_id))), 1) * lucky
    if not _deposit_resource(state, field, str(crop_registry.output_resource_id(crop_id)), quantity):
        return false
    var wage_job_id := str(plot.get("economy_a_wage_job_id", ""))
    var worker_id := StringName(plot.get("assigned_worker_id", ""))
    if state.sect.economy_a_enabled and wage_job_id != "" and state.disciples.has(worker_id):
        EconomySystem.new().settle_work_wage(state, state.disciples[worker_id], wage_job_id)

    var fragment_roll := _stable_plot_roll(state.seed, "%s|linh_tuyen_fragment" % str(field.id), str(plot.get("plot_id", "")), int(plot.get("started_tick", 0)))
    if linh_tuyen_fragment_drop(float(plot.get("rare_factor", 1.0)), fragment_roll) > 0:
        _add_linh_tuyen_fragment(state)
        convert_linh_tuyen_fragments(state)
    return true

func linh_tuyen_fragment_drop(rare_factor: float, roll: float) -> int:
    var chance := clampf(LINH_TUYEN_FRAGMENT_BASE_CHANCE * maxf(rare_factor, 0.0), 0.0, 1.0)
    return 1 if clampf(roll, 0.0, 0.999999999) < chance else 0

func convert_linh_tuyen_fragments(state: SimulationState) -> int:
    if not state.sect.p3_7_resources_enabled:
        return 0
    var fragment_count := warehouse.quantity(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT))
    var hearts := int(floor(float(fragment_count) / float(LINH_TUYEN_FRAGMENT_PER_HEART)))
    if hearts <= 0:
        return 0
    if not warehouse.consume(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT), hearts * LINH_TUYEN_FRAGMENT_PER_HEART, true):
        return 0
    if not warehouse.add(state, StringName(MATERIAL_LINH_TUYEN_HEART), hearts):
        warehouse.add(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT), hearts * LINH_TUYEN_FRAGMENT_PER_HEART)
        return 0
    return hearts

func _add_linh_tuyen_fragment(state: SimulationState) -> void:
    if state.sect.p3_7_resources_enabled:
        warehouse.add(state, StringName(MATERIAL_LINH_TUYEN_FRAGMENT), 1)
    else:
        state.sect.forge_materials[MATERIAL_LINH_TUYEN_FRAGMENT] = int(state.sect.forge_materials.get(MATERIAL_LINH_TUYEN_FRAGMENT, 0)) + 1

func _ensure_spirit_field_state(state: SimulationState, field: BuildingState) -> Dictionary:
    if field == null or field.building_type != TYPE_SPIRIT_FIELD:
        return {}
    var desired_slots := spirit_plot_slots(field)
    var current = field.production_state
    if current is Dictionary and current.has("plots"):
        var data: Dictionary = current.duplicate(true)
        if not VALID_FIELD_POLICIES.has(StringName(data.get("policy_mode", ""))):
            data["policy_mode"] = str(FIELD_POLICY_AUTO_DEMAND)
        data["fixed_crop_id"] = str(data.get("fixed_crop_id", ""))
        var weights = data.get("priority_weights", {})
        data["priority_weights"] = weights.duplicate(true) if weights is Dictionary else {}
        data["plant_sequence"] = maxi(int(data.get("plant_sequence", 0)), 0)
        var raw_remainders = data.get("plot_work_remainders_bp", {})
        data["plot_work_remainders_bp"] = raw_remainders.duplicate(true) if raw_remainders is Dictionary else {}
        var plots: Array = []
        var raw_plots = data.get("plots", [])
        if raw_plots is Array:
            for index in range(raw_plots.size()):
                plots.append(_normalize_plot(raw_plots[index], index))
        while plots.size() < desired_slots:
            plots.append(_empty_plot("plot_%03d" % [plots.size() + 1]))
        if plots.size() > desired_slots:
            plots.resize(desired_slots)
        data["plots"] = plots
        field.production_state = data
        return data

    var legacy: Dictionary = current.duplicate(true) if current is Dictionary else {}
    var migrated := {
        "policy_mode": str(FIELD_POLICY_AUTO_DEMAND),
        "fixed_crop_id": "",
        "priority_weights": {},
        "plant_sequence": 0,
        "plot_work_remainders_bp": {},
        "plots": []
    }
    var plots: Array = []
    for index in range(desired_slots):
        plots.append(_empty_plot("plot_%03d" % [index + 1]))
    var legacy_phase := StringName(legacy.get("phase", ""))
    if legacy_phase == SPIRIT_PHASE_GROWING or legacy_phase == SPIRIT_PHASE_HARVEST_READY:
        var crop_id := StringName(legacy.get("resource_id", str(SpiritCropRegistry.CROP_THANH_LINH_THAO)))
        if not crop_registry.has(crop_id):
            crop_id = SpiritCropRegistry.CROP_THANH_LINH_THAO
        var progress := maxf(float(legacy.get("growth_progress", 0.0)), 0.0)
        var required := maxf(float(legacy.get("growth_required", crop_registry.base_cycle_ticks(crop_id))), 1.0)
        var remaining := 1 if legacy_phase == SPIRIT_PHASE_HARVEST_READY else maxi(1, int(ceil(required - progress)))
        plots[0] = {
            "plot_id": "plot_001",
            "crop_id": str(crop_id),
            "status": str(PLOT_GROWING),
            "started_tick": state.tick - int(floor(progress)),
            "finish_tick": state.tick + remaining,
            "assigned_worker_id": str(legacy.get("planted_by", "")),
            "paid_spirit_stones": 0,
            "routine_yield": crop_registry.base_yield(crop_id),
            "rare_factor": 1.0
        }
    migrated["plots"] = plots
    field.production_state = migrated
    state.building_event_count += 1
    return migrated

func _normalize_plot(value: Variant, index: int) -> Dictionary:
    if not (value is Dictionary):
        return _empty_plot("plot_%03d" % [index + 1])
    var plot_id := str(value.get("plot_id", "plot_%03d" % [index + 1]))
    var status := StringName(value.get("status", "empty"))
    if status != PLOT_GROWING:
        return _empty_plot(plot_id)
    var crop_id := StringName(value.get("crop_id", ""))
    if not crop_registry.has(crop_id):
        return _empty_plot(plot_id)
    return {
        "plot_id": plot_id,
        "crop_id": str(crop_id),
        "status": str(PLOT_GROWING),
        "started_tick": int(value.get("started_tick", 0)),
        "finish_tick": int(value.get("finish_tick", 1)),
        "assigned_worker_id": str(value.get("assigned_worker_id", "")),
        "paid_spirit_stones": maxi(int(value.get("paid_spirit_stones", 0)), 0),
        "routine_yield": maxi(int(value.get("routine_yield", crop_registry.base_yield(crop_id))), 1),
        "rare_factor": maxf(float(value.get("rare_factor", 1.0)), 0.0),
        "economy_a_wage_job_id": str(value.get("economy_a_wage_job_id", "")),
        "completion_work_remainder_bp": maxi(int(value.get("completion_work_remainder_bp",0)),0)
    }

func _empty_plot(plot_id: String) -> Dictionary:
    return {
        "plot_id": plot_id,
        "crop_id": "",
        "status": str(PLOT_EMPTY),
        "started_tick": -1,
        "finish_tick": -1,
        "assigned_worker_id": "",
        "paid_spirit_stones": 0,
        "routine_yield": 0,
        "rare_factor": 1.0,
        "completion_work_remainder_bp": 0
    }

func _first_empty_plot_index(plots: Array) -> int:
    for index in range(plots.size()):
        if plots[index] is Dictionary and StringName(plots[index].get("status", "")) == PLOT_EMPTY:
            return index
    return -1

func _field_has_startable_plot(state: SimulationState, field: BuildingState) -> bool:
    var data := _ensure_spirit_field_state(state, field)
    if _first_empty_plot_index(data.get("plots", [])) < 0:
        return false
    return _select_crop(state, field, data) != &""

func _select_crop(state: SimulationState, field: BuildingState, data: Dictionary) -> StringName:
    var eligible: Array[StringName] = []
    for crop_id in crop_registry.eligible_crop_ids(field.level):
        if state.sect.spirit_stones >= crop_registry.cost(crop_id):
            eligible.append(crop_id)
    if eligible.is_empty():
        return &""

    var mode := StringName(data.get("policy_mode", str(FIELD_POLICY_AUTO_DEMAND)))
    if mode == FIELD_POLICY_FIXED:
        var fixed_id := StringName(data.get("fixed_crop_id", ""))
        return fixed_id if eligible.has(fixed_id) else &""

    if mode == FIELD_POLICY_PRIORITY:
        var weights = data.get("priority_weights", {})
        if weights is Dictionary:
            var total := 0
            var weighted_ids: Array[StringName] = []
            for crop_id in eligible:
                var weight := maxi(int(weights.get(str(crop_id), 0)), 0)
                if weight > 0:
                    total += weight
                    weighted_ids.append(crop_id)
            if total > 0:
                weighted_ids.sort_custom(func(a: StringName, b: StringName) -> bool: return str(a) < str(b))
                var cursor := int(data.get("plant_sequence", 0)) % total
                var running := 0
                for crop_id in weighted_ids:
                    running += maxi(int(weights.get(str(crop_id), 0)), 0)
                    if cursor < running:
                        return crop_id

    var best := eligible[0]
    var best_score := -1.0e30
    for crop_id in eligible:
        var target := float(crop_registry.stock_target(crop_id))
        var quantity := float(warehouse.quantity(state, crop_registry.output_resource_id(crop_id))) if state.sect.p3_7_resources_enabled else 0.0
        var score := (target - quantity) / maxf(target, 1.0)
        if score > best_score or (is_equal_approx(score, best_score) and str(crop_id) < str(best)):
            best_score = score
            best = crop_id
    return best

func _crop_affinity_factor(disciple: DiscipleState, crop_id: StringName) -> float:
    var affinity := crop_registry.affinity_elements(crop_id)
    if affinity.is_empty():
        return 1.0
    for raw_element in disciple.spiritual_root_elements:
        if affinity.has(str(raw_element)):
            return 1.05
    return 1.0

func _stable_plot_roll(seed_value: int, building_id: String, plot_id: String, started_tick: int) -> float:
    var text := "%d|%s|%s|%d" % [seed_value, building_id, plot_id, started_tick]
    var value := 17
    for index in range(text.length()):
        value = int((value * 131 + text.unicode_at(index)) % 2147483629)
    return float(value % 1000000) / 1000000.0

func _buildings_of_type(state: SimulationState, building_type: StringName) -> Array[BuildingState]:
    var result: Array[BuildingState] = []
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building = state.buildings[raw_id]
        if building is BuildingState and building.building_type == building_type:
            result.append(building)
    return result

func _building_for_disciple(state: SimulationState, building_type: StringName, disciple: DiscipleState) -> BuildingState:
    if disciple != null and disciple.worksite_building_id != &"":
        var assigned = state.buildings.get(str(disciple.worksite_building_id))
        if assigned is BuildingState and assigned.building_type == building_type:
            return assigned
        return null
    return primary_building(state, building_type)

func _deposit_resource(state: SimulationState, building: BuildingState, resource_id: String, quantity: int) -> bool:
    if quantity <= 0:
        return false
    if state.sect.p3_7_resources_enabled:
        # A full Warehouse is expected backpressure for timed jobs, not a lost delivery.
        if quantity > WarehouseSystem.MAX_SAFE_STACK - warehouse.quantity(state, StringName(resource_id)):
            return false
        if not warehouse.add(state, StringName(resource_id), quantity):
            push_error("BuildingSystem: failed to deposit canonical resource %s x%d." % [resource_id, quantity])
            return false
    else:
        state.sect.forge_materials[resource_id] = int(state.sect.forge_materials.get(resource_id, 0)) + quantity
    building.metrics["production_batches"] = int(building.metrics.get("production_batches", 0)) + 1
    building.metrics["units_produced"] = int(building.metrics.get("units_produced", 0)) + quantity
    state.building_event_count += 1
    return true

func _resource_available(state: SimulationState, resource_id: StringName) -> int:
    if state.sect.p3_7_resources_enabled:
        return warehouse.available_quantity(state, resource_id)
    return maxi(int(state.sect.forge_materials.get(str(resource_id), 0)), 0)

func _consume_resources(state: SimulationState, requirements: Dictionary) -> bool:
    if state.sect.p3_7_resources_enabled:
        return warehouse.consume_requirements(state, requirements)
    var ids: Array = requirements.keys()
    ids.sort()
    for raw_id in ids:
        if int(state.sect.forge_materials.get(str(raw_id), 0)) < int(requirements[raw_id]):
            return false
    for raw_id in ids:
        var key := str(raw_id)
        var next := int(state.sect.forge_materials.get(key, 0)) - int(requirements[raw_id])
        if next <= 0:
            state.sect.forge_materials.erase(key)
        else:
            state.sect.forge_materials[key] = next
    return true

func _movement_speed(state: SimulationState, disciple: DiscipleState) -> float:
    # World/work movement is a canonical physical speed. Combat path style
    # controls positioning tactics, not how fast a disciple walks to a job.
    var movement_profile := {"move_speed": 2.7}
    movement_profile = equipment.apply_style_modifiers(state, disciple, movement_profile)
    return maxf(float(movement_profile.get("move_speed", 2.7)), 0.5)

func _haul_speed_multiplier(_disciple: DiscipleState) -> float:
    return 1.0

const WORK_PROGRESS_BP := 10000

# Convert fractional work speed into integer tick deadlines without losing
# small modifiers to ceil(). The completion remainder is persisted only after
# a real output settlement, so cancellation cannot create free progress.
func _timed_duration_plan(base_ticks: float, speed: float, prior_remainder_bp: int = 0) -> Dictionary:
    var required_bp := maxi(int(round(maxf(base_ticks, 1.0) * float(WORK_PROGRESS_BP))), WORK_PROGRESS_BP)
    var speed_bp := maxi(int(round(maxf(speed, 0.25) * float(WORK_PROGRESS_BP))), 1)
    var prior := clampi(prior_remainder_bp, 0, required_bp - 1)
    var remaining_bp := maxi(required_bp - prior, 1)
    var duration_ticks := maxi(int(ceil(float(remaining_bp) / float(speed_bp))), 1)
    var completion := prior + duration_ticks * speed_bp - required_bp
    if completion >= required_bp:
        completion %= required_bp
    return {
        "duration_ticks": duration_ticks,
        "completion_remainder_bp": maxi(completion, 0),
        "required_work_bp": required_bp,
        "speed_bp": speed_bp
    }

func _resource_job_duration(building: BuildingState) -> float:
    var base := float(definition_for(building).get("base_work_duration", 4.0))
    var facility_multiplier := maxf(0.50, 1.0 - float(maxi(building.level - 1, 0)) * 0.005)
    return maxf(base * facility_multiplier, 1.0)

func _resource_job_batch_units(building: BuildingState) -> int:
    var base := maxi(int(definition_for(building).get("base_batch_units", 2)), 1)
    return base + int(floor(float(building.level) / 10.0))

# Mining output remains the authored Mine/level batch quantity until a
# specific, approved production-result modifier is defined. In particular,
# Căn Cốt is a Body-training foundation and never grants arbitrary extra ore.
# Mining profession level already controls work time through WorkforceSystem;
# Thông Tuệ controls profession XP via the existing modifier channel.
# Keep old helper names for regression/debug compatibility.
func _mining_duration(mine: BuildingState) -> float:
    return _resource_job_duration(mine)

func _mining_batch_units(mine: BuildingState) -> int:
    return _resource_job_batch_units(mine)

func _milestone_component(building_type: StringName, target_level: int) -> String:
    var table = MILESTONE_COMPONENTS.get(str(building_type), {})
    if not (table is Dictionary):
        return ""
    return str(table.get(target_level, ""))

func _milestone_component_quantity(building_type: StringName, target_level: int) -> int:
    if building_type == TYPE_SPIRIT_FIELD and MILESTONE_LEVELS.has(target_level):
        return maxi(int(ceil(float(target_level) / 10.0)), 1)
    return 1
