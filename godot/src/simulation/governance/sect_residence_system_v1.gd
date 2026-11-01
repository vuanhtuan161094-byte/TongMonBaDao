class_name SectResidenceSystemV1
extends RefCounted

# DD-02: Houses are real independent BuildingStates; never an invented
# presentation-only capacity or a second writable recruitment limit.
const SCHEMA_VERSION := 1
const TYPE := &"residence"
const START_BEDS := 8
const BEDS_PER_LEVEL := 2

static func beds_for_level(level: int) -> int:
    return START_BEDS + BEDS_PER_LEVEL * (clampi(level, 1, 100) - 1)

static func all_houses(state: SimulationState) -> Array[BuildingState]:
    var list: Array[BuildingState] = []
    if state == null:
        return list
    var ids: Array = state.buildings.keys()
    ids.sort()
    for key in ids:
        var building = state.buildings[key]
        if building is BuildingState and building.building_type == TYPE:
            list.append(building)
    return list

static func total_beds(state: SimulationState) -> int:
    var total := 0
    for building in all_houses(state):
        total += beds_for_level(building.level)
    if SectHallSystemV1.installed(state):
        total += maxi(0, int(state.sect.hall_governance.get("legacy_bed_credit", 0)))
    return total

static func maximum_instances(state: SimulationState) -> int:
    var hall := SectHallSystemV1.hall(state)
    if hall == null:
        return 1
    # One main residence from the start; new fixed-site annexes every 10 Hall levels.
    return mini(10, 1 + int((hall.level - 1) / 10))

static func current_limit(state: SimulationState) -> int:
    if not SectHallSystemV1.installed(state):
        return state.sect.disciple_capacity
    var admin := SectHallSystemV1.rank_population_limit(state)
    return mini(admin, total_beds(state))

static func refresh_capacity(state: SimulationState) -> void:
    if not SectHallSystemV1.installed(state) or all_houses(state).is_empty():
        return
    var legal := current_limit(state)
    # Preserve an existing roster when migrating older / larger saves; do not
    # remove a disciple or enable fresh recruitment above the new legal cap.
    state.sect.disciple_capacity = maxi(state.disciples.size(), legal)
    state.sect.lodging_capacity = maxi(1, total_beds(state))

static func ensure_live(state: SimulationState) -> Dictionary:
    if state == null or not state.p3_7_buildings_enabled or not SectHallSystemV1.installed(state):
        return {"ok": false, "reason": "residence_requires_live_hall"}
    var governance: Dictionary = state.sect.hall_governance
    if not governance.has("residence_schema"):
        # Preserve prior purchased legacy bed extensions, but do not
        # translate old recruitment caps into free houses/positive capacity.
        governance["legacy_bed_credit"] = maxi(0, state.sect.lodging_capacity - START_BEDS)
        governance["residence_schema"] = SCHEMA_VERSION
        governance["residence_build_receipts"] = {}
        governance["residence_assignments"] = {}
    if int(governance.get("residence_schema", 0)) != SCHEMA_VERSION:
        return {"ok": false, "reason": "unsupported_residence_schema"}
    var houses := all_houses(state)
    if houses.is_empty():
        var starter := BuildingSystem.new().create_building(TYPE, 1)
        if starter == null or state.buildings.has(str(starter.id)):
            return {"ok": false, "reason": "residence_building_identity_collision"}
        state.buildings[str(starter.id)] = starter
        state.building_event_count += 1
    refresh_capacity(state)
    auto_assign_beds(state)
    return {"ok": true}

static func build_cost(state: SimulationState) -> Dictionary:
    var ordinal := all_houses(state).size() + 1
    return {
        BuildingSystem.MATERIAL_WOOD: 250 * ordinal,
        BuildingSystem.MATERIAL_ORE: 160 * ordinal,
        "spirit_stones": 5000 * ordinal
    }

static func can_construct(state: SimulationState) -> Dictionary:
    if not SectHallSystemV1.installed(state) or int(state.sect.hall_governance.get("residence_schema", 0)) != SCHEMA_VERSION:
        return {"ok": false, "reason": "residence_not_enabled"}
    var current := all_houses(state)
    if current.size() >= maximum_instances(state):
        return {"ok": false, "reason": "main_hall_instance_limit", "have": current.size(), "maximum": maximum_instances(state)}
    var next_id := "residence_%03d" % [current.size() + 1]
    if state.buildings.has(next_id):
        return {"ok": false, "reason": "residence_id_collision"}
    var cost := build_cost(state)
    var system := BuildingSystem.new()
    for key in cost.keys():
        if str(key) == "spirit_stones":
            if state.sect.spirit_stones < int(cost[key]):
                return {"ok": false, "reason": "missing_spirit_stones", "need": cost[key], "have": state.sect.spirit_stones}
        elif system._resource_available(state, StringName(key)) < int(cost[key]):
            return {"ok": false, "reason": "missing_material", "material_id": str(key), "need": cost[key], "have": system._resource_available(state, StringName(key))}
    return {"ok": true, "cost": cost, "next_id": next_id}

static func construct(state: SimulationState, request_id: String) -> Dictionary:
    if request_id.is_empty() or request_id.length() > 100:
        return {"ok": false, "reason": "invalid_request_id"}
    if not SectHallSystemV1.installed(state):
        return {"ok": false, "reason": "residence_not_enabled"}
    var receipts: Dictionary = state.sect.hall_governance.get("residence_build_receipts", {})
    if receipts.has(request_id):
        return {"ok": true, "already_settled": true, "building_id": str(receipts[request_id])}
    var check := can_construct(state)
    if not bool(check.get("ok", false)):
        return check
    var cost: Dictionary = check["cost"]
    var materials := cost.duplicate(true)
    materials.erase("spirit_stones")
    var building_system := BuildingSystem.new()
    var ordinal := all_houses(state).size() + 1
    var house := building_system.create_building(TYPE, ordinal)
    if house == null or state.buildings.has(str(house.id)):
        return {"ok": false, "reason": "pre_debit_identity_error"}
    if not building_system._consume_resources(state, materials):
        return {"ok": false, "reason": "materials_changed"}
    state.sect.spirit_stones -= int(cost["spirit_stones"])
    state.buildings[str(house.id)] = house
    state.building_event_count += 1
    receipts = receipts.duplicate(true)
    receipts[request_id] = str(house.id)
    state.sect.hall_governance["residence_build_receipts"] = receipts
    refresh_capacity(state)
    auto_assign_beds(state)
    return {"ok": true, "building_id": str(house.id), "cost": cost}

static func upgrade_room_projection(state: SimulationState, building_id: StringName) -> Dictionary:
    var building = state.buildings.get(str(building_id))
    if not (building is BuildingState) or building.building_type != TYPE:
        return {"ok": false, "reason": "residence_missing"}
    var current := beds_for_level(building.level)
    return {
        "ok": true,
        "beds": current,
        "next_beds": beds_for_level(building.level + 1) if building.level < building.max_level else current,
        "level": building.level,
        "max_level": building.max_level,
        "upgrade": BuildingSystem.new().can_start_upgrade(state, building.id),
        "cost": BuildingSystem.new().upgrade_cost(building)
    }

static func auto_assign_beds(state: SimulationState) -> void:
    if not SectHallSystemV1.installed(state):
        return
    var existing: Dictionary = state.sect.hall_governance.get("residence_assignments", {}).duplicate(true)
    var houses := all_houses(state)
    var capacities: Dictionary = {}
    var used: Dictionary = {}
    for house in houses:
        capacities[str(house.id)] = beds_for_level(house.level)
        used[str(house.id)] = 0
    # Retain valid reservations, then assign remaining in deterministic order.
    var stable: Dictionary = {}
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var did := str(raw_id)
        var home := str(existing.get(did, ""))
        if not capacities.has(home):
            continue
        if int(used[home]) < int(capacities[home]):
            stable[did] = home
            used[home] = int(used[home]) + 1
    for raw_id in ids:
        var did := str(raw_id)
        if stable.has(did):
            continue
        for house in houses:
            var key := str(house.id)
            if int(used[key]) < int(capacities[key]):
                stable[did] = key
                used[key] = int(used[key]) + 1
                break
    state.sect.hall_governance["residence_assignments"] = stable

static func house_of(state: SimulationState, disciple_id: StringName) -> String:
    if not SectHallSystemV1.installed(state):
        return ""
    var assignments: Dictionary = state.sect.hall_governance.get("residence_assignments", {})
    return str(assignments.get(str(disciple_id), ""))

static func assign_room(state: SimulationState, disciple_id: StringName, house_id: StringName) -> Dictionary:
    if not SectHallSystemV1.installed(state) or not state.disciples.has(disciple_id):
        return {"ok": false, "reason": "disciple_missing"}
    var house = state.buildings.get(str(house_id))
    if not (house is BuildingState) or house.building_type != TYPE:
        return {"ok": false, "reason": "house_missing"}
    var current: Dictionary = state.sect.hall_governance.get("residence_assignments", {})
    if str(current.get(str(disciple_id), "")) == str(house_id):
        return {"ok": true, "unchanged": true}
    var count := 0
    for other in current.values():
        if str(other) == str(house_id):
            count += 1
    if count >= beds_for_level(house.level):
        return {"ok": false, "reason": "house_full"}
    var changed := current.duplicate(true)
    changed[str(disciple_id)] = str(house_id)
    state.sect.hall_governance["residence_assignments"] = changed
    return {"ok": true}

static func comfort_factor(state: SimulationState, disciple_id: StringName) -> float:
    if not SectHallSystemV1.installed(state):
        return 1.0
    var id := house_of(state, disciple_id)
    var house = state.buildings.get(id)
    if not (house is BuildingState) or house.building_type != TYPE:
        return 1.0
    var lvl: int = house.level
    if lvl >= 100:
        return 1.20
    if lvl >= 75:
        return 1.15
    if lvl >= 50:
        return 1.10
    if lvl >= 20:
        return 1.05
    return 1.0

static func validate(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not SectHallSystemV1.installed(state):
        return errors
    if int(state.sect.hall_governance.get("residence_schema", 0)) != SCHEMA_VERSION:
        errors.append("Residence V1 missing/invalid schema.")
        return errors
    var houses := all_houses(state)
    if houses.is_empty():
        errors.append("Residence V1 has no starter house.")
    if houses.size() > 10:
        errors.append("Residence V1 exceeds absolute instance maximum.")
    var seen: Dictionary = {}
    for house in houses:
        if seen.has(str(house.id)):
            errors.append("Residence duplicated a stable instance ID.")
        seen[str(house.id)] = true
        if house.level < 1 or house.level > 100:
            errors.append("Residence invalid house level.")
    if state.sect.lodging_capacity != maxi(1, total_beds(state)):
        errors.append("Residence bed capacity diverges from canonical houses.")
    if state.sect.disciple_capacity != maxi(state.disciples.size(), current_limit(state)):
        errors.append("Residence recruitment cap diverges from rank/bed authority.")
    var occupied: Dictionary = {}
    var rooms: Dictionary = state.sect.hall_governance.get("residence_assignments", {})
    for raw_id in rooms.keys():
        if not state.disciples.has(StringName(raw_id)):
            errors.append("Residence room assignment points at missing disciple.")
        var hid := str(rooms[raw_id])
        if not state.buildings.has(hid):
            errors.append("Residence room assignment references missing house.")
            continue
        occupied[hid] = int(occupied.get(hid, 0)) + 1
    for house in houses:
        if int(occupied.get(str(house.id), 0)) > beds_for_level(house.level):
            errors.append("Residence overbooked house beds.")
    return errors
