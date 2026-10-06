class_name BuildingSystem
extends RefCounted

const TYPE_MINE := &"mine"
const TYPE_SPIRIT_FIELD := &"spirit_field"

const PROF_MINING := &"mining"
const PROF_HERBALISM := &"herbalism"

const STATUS_ACTIVE := &"active"
const STATUS_UPGRADING := &"upgrading"
const VALID_STATUSES := [STATUS_ACTIVE, STATUS_UPGRADING]

const MILESTONE_LEVELS := [10, 20, 30, 50, 75, 100]

# P3.7A currently bridges the already-authoritative P2.6 material dictionary
# instead of creating a second warehouse. Unified warehouse migration comes later.
const MATERIAL_WOOD := "linh_moc"
const MATERIAL_ORE := "thanh_thiet"
const MATERIAL_TAM_MACH_BAN := "tam_mach_ban"
const MATERIAL_HERB := "thanh_linh_thao"
const MATERIAL_LINH_TUYEN_HEART := "linh_tuyen_chi_tam"

const SPIRIT_PHASE_GROWING := &"growing"
const SPIRIT_PHASE_HARVEST_READY := &"harvest_ready"

# Only milestone content that actually exists is allowed to start.
# Later milestones stay blocked until their real component/content is defined.
const MILESTONE_COMPONENTS := {
    "mine": {
        10: MATERIAL_TAM_MACH_BAN
    },
    "spirit_field": {
        10: MATERIAL_LINH_TUYEN_HEART
    }
}

const DEFINITIONS := {
    "mine": {
        "name": "Mỏ Linh Khoáng",
        "max_level": 100,
        "worker_group_id": "mining_crew",
        "base_worker_slots": 2,
        "worker_slot_every": 5,
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
    "spirit_field": {
        "name": "Linh Điền",
        "max_level": 100,
        "worker_group_id": "herbalism_crew",
        "base_worker_slots": 2,
        "worker_slot_every": 5,
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
    }
}

var equipment := EquipmentSystem.new()

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

    if primary_building(state, TYPE_MINE) == null:
        var mine := create_building(TYPE_MINE, 1)
        state.buildings[str(mine.id)] = mine
        state.building_event_count += 1

    if primary_building(state, TYPE_SPIRIT_FIELD) == null:
        var field := create_building(TYPE_SPIRIT_FIELD, 1)
        state.buildings[str(field.id)] = field
        state.building_event_count += 1

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
    var base_slots := maxi(int(definition.get("base_worker_slots", 0)), 0)
    var every := maxi(int(definition.get("worker_slot_every", 0)), 0)
    if every <= 0:
        return base_slots
    return base_slots + int(floor(float(building.level) / float(every)))

func assigned_worker_ids(state: SimulationState, building: BuildingState) -> Array[StringName]:
    var result: Array[StringName] = []
    if building.worker_group_id == &"":
        return result
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id == building.worker_group_id:
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
    if not state.p3_7_buildings_enabled or building == null:
        return false
    if disciple.region_id != &"sect":
        return false
    return active_worker_ids(state, building).has(disciple.id)

func work_available(state: SimulationState, profession_id: StringName) -> bool:
    match profession_id:
        PROF_MINING:
            return primary_building(state, TYPE_MINE) != null
        PROF_HERBALISM:
            var field := primary_building(state, TYPE_SPIRIT_FIELD)
            if field == null:
                return false
            var phase := StringName(field.production_state.get("phase", ""))
            return phase == &"" or phase == SPIRIT_PHASE_HARVEST_READY
        _:
            return true

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
            cost[component] = 1
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

    var target_level := building.level + 1
    if MILESTONE_LEVELS.has(target_level) and _milestone_component(building.building_type, target_level) == "":
        return {"ok": false, "reason": "milestone_component_not_defined", "target_level": target_level}

    var cost := upgrade_cost(building)
    var material_ids: Array = cost.keys()
    material_ids.erase("spirit_stones")
    material_ids.sort()
    for material_id in material_ids:
        var need := int(cost.get(material_id, 0))
        var have := int(state.sect.forge_materials.get(str(material_id), 0))
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
    var material_ids: Array = cost.keys()
    material_ids.erase("spirit_stones")
    material_ids.sort()
    for raw_material_id in material_ids:
        var material_id := str(raw_material_id)
        state.sect.forge_materials[material_id] = int(state.sect.forge_materials.get(material_id, 0)) - int(cost.get(material_id, 0))
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
            _process_spirit_field_growth(state, building)

func perform_mining_step(state: SimulationState, disciple: DiscipleState, work_speed: float) -> Dictionary:
    var mine := primary_building(state, TYPE_MINE)
    if mine == null or not can_disciple_work(state, mine, disciple):
        return {"ok": false, "completed": false, "reason": "no_active_mine_slot"}

    var cycle := disciple.work_cycle_state.duplicate(true)
    if str(cycle.get("profession", "")) != str(PROF_MINING) or str(cycle.get("building_id", "")) != str(mine.id):
        cycle = {
            "profession": str(PROF_MINING),
            "building_id": str(mine.id),
            "phase": "travel_out",
            "progress": 0.0,
            "carried_units": 0
        }

    var phase := StringName(cycle.get("phase", "travel_out"))
    var progress := maxf(float(cycle.get("progress", 0.0)), 0.0)
    var result := {
        "ok": true,
        "completed": false,
        "phase": str(phase),
        "building_id": str(mine.id),
        "stamina_cost": 1.0
    }

    match phase:
        &"travel_out":
            progress += _movement_speed(state, disciple)
            if progress + 0.000001 >= float(definition_for(mine).get("work_distance", 8.0)):
                phase = &"mining"
                progress = 0.0
        &"mining":
            progress += maxf(work_speed, 0.25)
            result["stamina_cost"] = 3.0
            if progress + 0.000001 >= _mining_duration(mine):
                phase = &"haul_back"
                progress = 0.0
                cycle["carried_units"] = _mining_batch_units(mine)
        &"haul_back":
            progress += _movement_speed(state, disciple) * _haul_speed_multiplier(disciple)
            if progress + 0.000001 >= float(definition_for(mine).get("haul_distance", 6.0)):
                var produced := maxi(int(cycle.get("carried_units", 0)), 1)
                _deposit_resource(state, mine, MATERIAL_ORE, produced)
                phase = &"complete"
                progress = 0.0
                cycle["carried_units"] = 0
                result["completed"] = true
                result["produced"] = produced
                result["resource_id"] = MATERIAL_ORE
                result["deposited_to"] = "sect_main_warehouse"
        _:
            phase = &"travel_out"
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
    var field := primary_building(state, TYPE_SPIRIT_FIELD)
    if field == null or not can_disciple_work(state, field, disciple):
        return {"ok": false, "completed": false, "reason": "no_active_spirit_field_slot"}

    var production_phase := StringName(field.production_state.get("phase", ""))
    if production_phase == SPIRIT_PHASE_GROWING:
        return {"ok": false, "completed": false, "reason": "crop_growing"}
    if production_phase != &"" and production_phase != SPIRIT_PHASE_HARVEST_READY:
        return {"ok": false, "completed": false, "reason": "invalid_field_state"}

    var task := &"plant" if production_phase == &"" else &"harvest"
    var cycle := disciple.work_cycle_state.duplicate(true)
    if str(cycle.get("profession", "")) != str(PROF_HERBALISM) or str(cycle.get("building_id", "")) != str(field.id) or StringName(cycle.get("task", "")) != task:
        cycle = {
            "profession": str(PROF_HERBALISM),
            "building_id": str(field.id),
            "task": str(task),
            "phase": "travel_out",
            "progress": 0.0,
            "carried_units": 0
        }

    var phase := StringName(cycle.get("phase", "travel_out"))
    var progress := maxf(float(cycle.get("progress", 0.0)), 0.0)
    var result := {
        "ok": true,
        "completed": false,
        "task": str(task),
        "phase": str(phase),
        "building_id": str(field.id),
        "stamina_cost": 1.0
    }

    match phase:
        &"travel_out":
            progress += _movement_speed(state, disciple)
            if progress + 0.000001 >= float(definition_for(field).get("work_distance", 7.0)):
                phase = &"tending" if task == &"plant" else &"harvesting"
                progress = 0.0
        &"tending":
            progress += maxf(work_speed, 0.25)
            result["stamina_cost"] = 2.0
            if progress + 0.000001 >= _field_tend_duration(field):
                field.production_state = {
                    "phase": str(SPIRIT_PHASE_GROWING),
                    "resource_id": str(definition_for(field).get("resource_id", MATERIAL_HERB)),
                    "growth_progress": 0.0,
                    "growth_required": _field_growth_duration(field),
                    "planted_by": str(disciple.id)
                }
                _release_competing_field_cycles(state, field.id, disciple.id)
                state.building_event_count += 1
                result["completed"] = true
                result["work_kind"] = "planting"
                result["next_phase"] = "growth"
        &"harvesting":
            progress += maxf(work_speed, 0.25)
            result["stamina_cost"] = 2.5
            if progress + 0.000001 >= _field_harvest_duration(field):
                phase = &"haul_back"
                progress = 0.0
                cycle["carried_units"] = _field_batch_units(field)
        &"haul_back":
            progress += _movement_speed(state, disciple) * _haul_speed_multiplier(disciple)
            if progress + 0.000001 >= float(definition_for(field).get("haul_distance", 5.0)):
                var produced := maxi(int(cycle.get("carried_units", 0)), 1)
                var resource_id := str(field.production_state.get("resource_id", definition_for(field).get("resource_id", MATERIAL_HERB)))
                _deposit_resource(state, field, resource_id, produced)
                field.production_state.clear()
                _release_competing_field_cycles(state, field.id, disciple.id)
                state.building_event_count += 1
                phase = &"complete"
                progress = 0.0
                cycle["carried_units"] = 0
                result["completed"] = true
                result["work_kind"] = "harvest"
                result["produced"] = produced
                result["resource_id"] = resource_id
                result["deposited_to"] = "sect_main_warehouse"
        _:
            phase = &"travel_out"
            progress = 0.0
            cycle["carried_units"] = 0

    if bool(result.get("completed", false)):
        disciple.work_cycle_state.clear()
        return result

    cycle["phase"] = str(phase)
    cycle["progress"] = progress
    disciple.work_cycle_state = cycle
    result["next_phase"] = str(phase)
    result["progress"] = progress
    return result

func cancel_work_cycle(state: SimulationState, disciple: DiscipleState, settle_carried: bool = true) -> int:
    if disciple.work_cycle_state.is_empty():
        return 0
    var profession := StringName(disciple.work_cycle_state.get("profession", ""))
    var deposited := 0
    if settle_carried:
        deposited = maxi(int(disciple.work_cycle_state.get("carried_units", 0)), 0)
        if deposited > 0 and profession == PROF_MINING:
            var mine := primary_building(state, TYPE_MINE)
            if mine != null:
                _deposit_resource(state, mine, MATERIAL_ORE, deposited)
        elif deposited > 0 and profession == PROF_HERBALISM:
            var field := primary_building(state, TYPE_SPIRIT_FIELD)
            if field != null:
                var resource_id := str(field.production_state.get("resource_id", definition_for(field).get("resource_id", MATERIAL_HERB)))
                _deposit_resource(state, field, resource_id, deposited)
                field.production_state.clear()
                state.building_event_count += 1
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

        if building.building_type == TYPE_SPIRIT_FIELD and not building.production_state.is_empty():
            var production_phase := StringName(building.production_state.get("phase", ""))
            if production_phase != SPIRIT_PHASE_GROWING and production_phase != SPIRIT_PHASE_HARVEST_READY:
                errors.append("Spirit Field %s has invalid production phase." % building.id)
            var growth_progress := float(building.production_state.get("growth_progress", 0.0))
            var growth_required := float(building.production_state.get("growth_required", 0.0))
            if growth_required <= 0.0 or growth_progress < 0.0 or growth_progress > growth_required + 0.001:
                errors.append("Spirit Field %s has invalid crop-growth progress." % building.id)

    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.work_cycle_state.is_empty():
            continue
        var profession := StringName(disciple.work_cycle_state.get("profession", ""))
        var building_id := str(disciple.work_cycle_state.get("building_id", ""))
        var phase := StringName(disciple.work_cycle_state.get("phase", ""))
        if profession != PROF_MINING and profession != PROF_HERBALISM:
            errors.append("%s has unsupported P3.7 work-cycle profession." % disciple.display_name)
        if not state.buildings.has(building_id):
            errors.append("%s references missing work-cycle building." % disciple.display_name)
        if profession == PROF_MINING and not [&"travel_out", &"mining", &"haul_back"].has(phase):
            errors.append("%s has invalid mining work-cycle phase." % disciple.display_name)
        if profession == PROF_HERBALISM and not [&"travel_out", &"tending", &"harvesting", &"haul_back"].has(phase):
            errors.append("%s has invalid herbalism work-cycle phase." % disciple.display_name)
        if float(disciple.work_cycle_state.get("progress", 0.0)) < 0.0 or int(disciple.work_cycle_state.get("carried_units", 0)) < 0:
            errors.append("%s has invalid work-cycle progress." % disciple.display_name)
    return errors

func _release_competing_field_cycles(state: SimulationState, building_id: StringName, except_disciple_id: StringName = &"") -> void:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var worker: DiscipleState = state.disciples[raw_id]
        if worker.id == except_disciple_id or worker.work_cycle_state.is_empty():
            continue
        if StringName(worker.work_cycle_state.get("profession", "")) != PROF_HERBALISM:
            continue
        if str(worker.work_cycle_state.get("building_id", "")) != str(building_id):
            continue
        worker.work_cycle_state.clear()

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

func _process_spirit_field_growth(state: SimulationState, field: BuildingState) -> void:
    if StringName(field.production_state.get("phase", "")) != SPIRIT_PHASE_GROWING:
        return
    var required := maxf(float(field.production_state.get("growth_required", 0.0)), 1.0)
    var progress := minf(float(field.production_state.get("growth_progress", 0.0)) + 1.0, required)
    field.production_state["growth_progress"] = progress
    if progress + 0.000001 >= required:
        field.production_state["phase"] = str(SPIRIT_PHASE_HARVEST_READY)
        state.building_event_count += 1

func _deposit_resource(state: SimulationState, building: BuildingState, resource_id: String, quantity: int) -> void:
    if quantity <= 0:
        return
    state.sect.forge_materials[resource_id] = int(state.sect.forge_materials.get(resource_id, 0)) + quantity
    building.metrics["production_batches"] = int(building.metrics.get("production_batches", 0)) + 1
    building.metrics["units_produced"] = int(building.metrics.get("units_produced", 0)) + quantity
    state.building_event_count += 1

func _movement_speed(state: SimulationState, disciple: DiscipleState) -> float:
    # World/work movement is a canonical physical speed. Combat path style
    # controls positioning tactics, not how fast a disciple walks to a job.
    var movement_profile := {"move_speed": 2.7}
    movement_profile = equipment.apply_style_modifiers(state, disciple, movement_profile)
    return maxf(float(movement_profile.get("move_speed", 2.7)), 0.5)

func _haul_speed_multiplier(disciple: DiscipleState) -> float:
    return lerpf(0.82, 1.08, clampf(disciple.constitution, 0.0, 1.0))

func _mining_duration(mine: BuildingState) -> float:
    var base := float(definition_for(mine).get("base_work_duration", 4.0))
    var facility_multiplier := maxf(0.50, 1.0 - float(maxi(mine.level - 1, 0)) * 0.005)
    return maxf(base * facility_multiplier, 1.0)

func _mining_batch_units(mine: BuildingState) -> int:
    var base := maxi(int(definition_for(mine).get("base_batch_units", 2)), 1)
    return base + int(floor(float(mine.level) / 10.0))

func _field_tend_duration(field: BuildingState) -> float:
    var base := float(definition_for(field).get("base_tend_duration", 3.0))
    return maxf(base * maxf(0.55, 1.0 - float(maxi(field.level - 1, 0)) * 0.004), 1.0)

func _field_harvest_duration(field: BuildingState) -> float:
    var base := float(definition_for(field).get("base_harvest_duration", 3.0))
    return maxf(base * maxf(0.55, 1.0 - float(maxi(field.level - 1, 0)) * 0.004), 1.0)

func _field_growth_duration(field: BuildingState) -> float:
    var base := float(definition_for(field).get("base_growth_duration", 12.0))
    return maxf(base * maxf(0.45, 1.0 - float(maxi(field.level - 1, 0)) * 0.005), 3.0)

func _field_batch_units(field: BuildingState) -> int:
    var base := maxi(int(definition_for(field).get("base_batch_units", 3)), 1)
    return base + int(floor(float(field.level) / 10.0))

func _milestone_component(building_type: StringName, target_level: int) -> String:
    var table = MILESTONE_COMPONENTS.get(str(building_type), {})
    if not (table is Dictionary):
        return ""
    return str(table.get(target_level, ""))
