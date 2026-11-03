class_name SectResidenceSystemV1
extends RefCounted

# DD-02: Houses are real independent BuildingStates; never an invented
# presentation-only capacity or a second writable recruitment limit.
const SCHEMA_VERSION := 1
const TYPE := &"residence"
const START_BEDS := 8
const BEDS_PER_LEVEL := 2
# DD-09 provisional early-loop construction duration (simulation minutes).
# Use the canonical BuildingSystem tick, not wall time or UI frames.
const CONSTRUCTION_BASE_TICKS := 60
const CONSTRUCTION_TICKS_PER_ANNEX := 15

static func construction_duration_ticks(ordinal: int) -> int:
    return CONSTRUCTION_BASE_TICKS + maxi(0, ordinal - 2) * CONSTRUCTION_TICKS_PER_ANNEX

static func construction_remaining_ticks(state: SimulationState, house: BuildingState) -> int:
    if state == null or house == null or house.building_type != TYPE \
            or house.status != BuildingSystem.STATUS_CONSTRUCTING:
        return 0
    return maxi(0, int(house.production_state.get("construction_finish_tick", 0)) - state.tick)

static func complete_due_construction(state: SimulationState, house: BuildingState) -> bool:
    if state == null or house == null or house.building_type != TYPE \
            or house.status != BuildingSystem.STATUS_CONSTRUCTING:
        return false
    if house.instance_index < 2 or house.level != 1:
        return false
    var started = house.production_state.get("construction_started_tick", null)
    var due = house.production_state.get("construction_finish_tick", null)
    var duration = house.production_state.get("construction_duration_ticks", null)
    for value in [started, due, duration]:
        if not (value is int or value is float):
            return false
        if value is float and (is_nan(value) or is_inf(value)):
            return false
        if float(value) != float(int(value)):
            return false
    if int(started) < 0 or int(started) > state.tick \
            or int(duration) != construction_duration_ticks(house.instance_index) \
            or int(due) != int(started) + int(duration) \
            or state.tick < int(due):
        return false
    house.status = BuildingSystem.STATUS_ACTIVE
    house.production_state.erase("construction_started_tick")
    house.production_state.erase("construction_finish_tick")
    house.production_state.erase("construction_duration_ticks")
    # BuildingState's persisted metrics schema has no construction counter;
    # the authoritative status transition and event_count are sufficient.
    state.building_event_count += 1
    refresh_capacity(state)
    auto_assign_beds(state)
    return true

static func beds_for_level(level: int) -> int:
    return START_BEDS + BEDS_PER_LEVEL * (clampi(level, 1, 100) - 1)

static func all_houses(state: SimulationState) -> Array[BuildingState]:
    var list: Array[BuildingState] = []
    if state == null:
        return list
    # Filter first, then sort only actual houses (at most ten). This
    # avoids sorting every production building on each capacity query.
    for building in state.buildings.values():
        if building is BuildingState and building.building_type == TYPE:
            list.append(building)
    list.sort_custom(func(left: BuildingState, right: BuildingState) -> bool:
        return str(left.id) < str(right.id))
    return list

static func total_beds(state: SimulationState) -> int:
    var total := 0
    for building in all_houses(state):
        if building.status != BuildingSystem.STATUS_CONSTRUCTING:
            total += beds_for_level(building.level)
    if SectHallSystemV1.installed(state):
        total += maxi(0, int(state.sect.hall_governance.get("legacy_bed_credit", 0)))
    return total

static func maximum_instances(state: SimulationState) -> int:
    var hall := SectHallSystemV1.hall(state)
    if hall == null:
        return 1
    # G1 early-play gate: the first paid annex is available at the founding Hall.
    # Later annexes retain the existing 10-level cadence, so only the first
    # housing expansion moves forward for New Game accessibility.
    return mini(10, maxi(2, 1 + int((hall.level - 1) / 10)))

static func required_hall_level_for_instance(ordinal: int) -> int:
    if ordinal <= 2:
        return 1
    return 1 + (ordinal - 1) * 10
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
    var persisted_rooms := governance.has("residence_schema")
    if not persisted_rooms and (
            governance.has("residence_assignments") or governance.has("residence_build_receipts")
            or governance.has("legacy_bed_credit")):
        return {"ok": false, "reason": "partial_residence_schema"}
    if not governance.has("residence_schema"):
        # Preserve prior purchased legacy bed extensions, but do not
        # translate old recruitment caps into free houses/positive capacity.
        governance["legacy_bed_credit"] = maxi(0, state.sect.lodging_capacity - START_BEDS)
        governance["residence_schema"] = SCHEMA_VERSION
        governance["residence_build_receipts"] = {}
        governance["residence_assignments"] = {}
    var raw_schema = governance.get("residence_schema", null)
    if not (raw_schema is int or raw_schema is float) \
            or (raw_schema is float and (is_nan(raw_schema) or is_inf(raw_schema))) \
            or float(raw_schema) != float(SCHEMA_VERSION):
        return {"ok": false, "reason": "unsupported_residence_schema"}
    for field in ["residence_assignments", "residence_build_receipts"]:
        if not governance.has(field) or not (governance[field] is Dictionary):
            return {"ok": false, "reason": "malformed_residence_" + field}
    var legacy_credit = governance.get("legacy_bed_credit", null)
    if not (legacy_credit is int or legacy_credit is float) \
            or (legacy_credit is float and (is_nan(legacy_credit) or is_inf(legacy_credit))) \
            or float(legacy_credit) != float(int(legacy_credit)) or int(legacy_credit) < 0:
        return {"ok": false, "reason": "invalid_legacy_bed_credit"}
    var houses := all_houses(state)
    if not houses.is_empty() and not state.buildings.has("residence_001"):
        return {"ok": false, "reason": "residence_001_missing"}
    if not houses.is_empty() and str(houses[0].id) != "residence_001":
        return {"ok": false, "reason": "residence_001_identity_mismatch"}
    if houses.is_empty():
        # Only genuine migration from a legacy no-House save grants a starter.
        # Persisted V2 housing cannot be replaced by a fresh empty Lv1 House.
        if persisted_rooms:
            return {"ok": false, "reason": "persisted_residence_buildings_missing"}
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
    # Provisional G1 first-expansion cost stays tied to real starter stock.
    # House #2 costs 40 Wood, 30 Ore and 500 Spirit Stones; no free grant or
    # test-only resource path is used. Higher houses scale by the same ordinal.
    return {
        BuildingSystem.MATERIAL_WOOD: 20 * ordinal,
        BuildingSystem.MATERIAL_ORE: 15 * ordinal,
        "spirit_stones": 250 * ordinal
    }
static func can_construct(state: SimulationState,
        selected_site: Vector2i = SectResidenceSiteV1.UNSELECTED) -> Dictionary:
    if not SectHallSystemV1.installed(state) or int(state.sect.hall_governance.get("residence_schema", 0)) != SCHEMA_VERSION:
        return {"ok": false, "reason": "residence_not_enabled"}
    var current := all_houses(state)
    if current.size() >= maximum_instances(state):
        return {"ok": false, "reason": "main_hall_instance_limit", "have": current.size(), "maximum": maximum_instances(state)}
    var next_id := "residence_%03d" % [current.size() + 1]
    if state.buildings.has(next_id):
        return {"ok": false, "reason": "residence_id_collision"}
    var site := selected_site
    if site == SectResidenceSiteV1.UNSELECTED:
        var free := SectResidenceSiteV1.available_plots(state)
        if free.is_empty():
            return {"ok": false, "reason": "no_free_house_plot"}
        site = free[0]
    var plot_check := SectResidenceSiteV1.check(state, site)
    if not bool(plot_check.get("ok",false)):
        return plot_check
    var cost := build_cost(state)
    var system := BuildingSystem.new()
    for key in cost.keys():
        if str(key) == "spirit_stones":
            if state.sect.spirit_stones < int(cost[key]):
                return {"ok": false, "reason": "missing_spirit_stones", "need": cost[key], "have": state.sect.spirit_stones}
        elif system._resource_available(state, StringName(key)) < int(cost[key]):
            return {"ok": false, "reason": "missing_material", "material_id": str(key), "need": cost[key], "have": system._resource_available(state, StringName(key))}
    return {"ok": true, "cost": cost, "next_id": next_id,
        "site": site, "door": SectResidenceSiteV1.doorway(site)}

static func _house_was_relocated_from(state: SimulationState, house_id: String,
        site: Vector2i) -> bool:
    if state == null or state.sect == null:
        return false
    var receipts: Variant = state.sect.hall_governance.get("residence_move_receipts", {})
    if not (receipts is Dictionary):
        return false
    for value in receipts.values():
        if not (value is Dictionary) or str(value.get("house_id", "")) != house_id:
            continue
        var previous := Vector2i(
            int(value.get("previous_x", SectResidenceSiteV1.UNSELECTED.x)),
            int(value.get("previous_y", SectResidenceSiteV1.UNSELECTED.y)))
        if previous == site:
            return true
    return false

static func construct(state: SimulationState, request_id: String,
        selected_site: Vector2i = SectResidenceSiteV1.UNSELECTED) -> Dictionary:
    if request_id.is_empty() or request_id.length() > 100:
        return {"ok": false, "reason": "invalid_request_id"}
    if not SectHallSystemV1.installed(state):
        return {"ok": false, "reason": "residence_not_enabled"}
    var receipts: Dictionary = state.sect.hall_governance.get("residence_build_receipts", {})
    if receipts.has(request_id):
        var settled_id := str(receipts[request_id])
        var settled_house = state.buildings.get(settled_id)
        if not (settled_house is BuildingState) or settled_house.building_type != TYPE:
            return {"ok": false, "reason": "settled_house_receipt_without_building"}
        var settled_origin := SectResidenceSiteV1.origin_of(settled_house)
        if selected_site != SectResidenceSiteV1.UNSELECTED and settled_origin != selected_site \
                and not _house_was_relocated_from(state, settled_id, selected_site):
            return {"ok": false, "reason": "conflicting_house_plot_replay"}
        return {"ok": true, "already_settled": true, "building_id": settled_id,
            "site": settled_origin}
    var check := can_construct(state,selected_site)
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
    var duration := construction_duration_ticks(ordinal)
    var site: Vector2i = check["site"]
    house.production_state["site_version"] = 1
    house.production_state["site_x"] = site.x
    house.production_state["site_y"] = site.y
    house.status = BuildingSystem.STATUS_CONSTRUCTING
    house.production_state["construction_started_tick"] = state.tick
    house.production_state["construction_finish_tick"] = state.tick + duration
    house.production_state["construction_duration_ticks"] = duration
    state.buildings[str(house.id)] = house
    state.building_event_count += 1
    receipts = receipts.duplicate(true)
    receipts[request_id] = str(house.id)
    state.sect.hall_governance["residence_build_receipts"] = receipts
    refresh_capacity(state)
    auto_assign_beds(state)
    return {"ok": true, "building_id": str(house.id), "cost": cost,
        "site": site, "door": SectResidenceSiteV1.doorway(site),
        "construction_finish_tick": state.tick + duration,
        "construction_duration_ticks": duration}

static func can_move_house(state: SimulationState, house_id: StringName,
        selected_site: Vector2i) -> Dictionary:
    if state == null or not SectHallSystemV1.installed(state):
        return {"ok": false, "reason": "residence_not_enabled"}
    var house = state.buildings.get(str(house_id))
    if not (house is BuildingState) or house.building_type != TYPE:
        return {"ok": false, "reason": "house_missing"}
    if house.instance_index <= 1 or str(house.id) == "residence_001":
        return {"ok": false, "reason": "starter_house_fixed"}
    if house.status != BuildingSystem.STATUS_ACTIVE or house.is_upgrading():
        return {"ok": false, "reason": "house_not_idle"}
    var assignments: Dictionary = state.sect.hall_governance.get("residence_assignments", {})
    for disciple_id in assignments:
        if str(assignments[disciple_id]) == str(house.id):
            return {"ok": false, "reason": "house_occupied", "disciple_id": str(disciple_id)}
    var plot := SectResidenceSiteV1.check(state, selected_site, str(house.id))
    if not bool(plot.get("ok", false)):
        return plot
    return {"ok": true, "house_id": str(house.id), "site": selected_site,
        "door": SectResidenceSiteV1.doorway(selected_site)}

static func move_house(state: SimulationState, request_id: String,
        house_id: StringName, selected_site: Vector2i) -> Dictionary:
    if request_id.is_empty() or request_id.length() > 100:
        return {"ok": false, "reason": "invalid_request_id"}
    if state == null or not SectHallSystemV1.installed(state):
        return {"ok": false, "reason": "residence_not_enabled"}
    var receipts: Dictionary = state.sect.hall_governance.get("residence_move_receipts", {})
    if not (receipts is Dictionary):
        return {"ok": false, "reason": "malformed_move_receipts"}
    if receipts.has(request_id):
        var settled = receipts[request_id]
        if not (settled is Dictionary) \
                or str(settled.get("house_id", "")) != str(house_id) \
                or int(settled.get("site_x", SectResidenceSiteV1.UNSELECTED.x)) != selected_site.x \
                or int(settled.get("site_y", SectResidenceSiteV1.UNSELECTED.y)) != selected_site.y:
            return {"ok": false, "reason": "conflicting_house_move_replay"}
        return {"ok": true, "already_settled": true, "house_id": str(house_id),
            "site": selected_site}
    var allowed := can_move_house(state, house_id, selected_site)
    if not bool(allowed.get("ok", false)):
        return allowed
    var house: BuildingState = state.buildings[str(house_id)]
    var old_site := SectResidenceSiteV1.origin_of(house)
    if old_site == selected_site:
        return {"ok": true, "unchanged": true, "house_id": str(house.id), "site": old_site}
    house.production_state["site_version"] = 1
    house.production_state["site_x"] = selected_site.x
    house.production_state["site_y"] = selected_site.y
    receipts = receipts.duplicate(true)
    receipts[request_id] = {"house_id": str(house.id), "site_x": selected_site.x,
        "site_y": selected_site.y, "previous_x": old_site.x, "previous_y": old_site.y}
    state.sect.hall_governance["residence_move_receipts"] = receipts
    state.building_event_count += 1
    return {"ok": true, "house_id": str(house.id), "old_site": old_site,
        "site": selected_site, "door": SectResidenceSiteV1.doorway(selected_site)}
static func upgrade_room_projection(state: SimulationState, building_id: StringName) -> Dictionary:
    var building = state.buildings.get(str(building_id))
    if not (building is BuildingState) or building.building_type != TYPE:
        return {"ok": false, "reason": "residence_missing"}
    var current := 0 if building.status == BuildingSystem.STATUS_CONSTRUCTING else beds_for_level(building.level)
    return {
        "ok": true,
        "beds": current,
        "next_beds": beds_for_level(building.level + 1) if building.level < building.max_level else current,
        "level": building.level,
        "max_level": building.max_level,
        "upgrade": BuildingSystem.new().can_start_upgrade(state, building.id),
        "construction_remaining_ticks": construction_remaining_ticks(state, building),
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
        if house.status != BuildingSystem.STATUS_ACTIVE and house.status != BuildingSystem.STATUS_UPGRADING:
            continue
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
            if not capacities.has(key):
                continue
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
    if house.status != BuildingSystem.STATUS_ACTIVE and house.status != BuildingSystem.STATUS_UPGRADING:
        return {"ok": false, "reason": "house_not_ready"}
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
    if not (house is BuildingState) or house.building_type != TYPE \
            or house.status == BuildingSystem.STATUS_CONSTRUCTING:
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
    var governance: Dictionary = state.sect.hall_governance
    var schema = governance.get("residence_schema", null)
    if not (schema is int or schema is float) or float(schema) != float(SCHEMA_VERSION):
        errors.append("Residence V1 missing/invalid schema.")
        return errors
    var credit = governance.get("legacy_bed_credit", null)
    if not (credit is int or credit is float) or (credit is float and (is_nan(credit) or is_inf(credit))) \
            or float(credit) != float(int(credit)) or int(credit) < 0:
        errors.append("Residence invalid legacy bed credit.")
        return errors
    var houses := all_houses(state)
    if houses.is_empty():
        errors.append("Residence V1 has no starter house.")
    if houses.size() > 10:
        errors.append("Residence V1 exceeds absolute instance maximum.")
    var seen: Dictionary = {}
    for index in range(houses.size()):
        var house: BuildingState = houses[index]
        var expected_id := "residence_%03d" % (index + 1)
        if str(house.id) != expected_id or house.instance_index != index + 1 \
                or not state.buildings.has(expected_id) \
                or state.buildings[expected_id] != house:
            errors.append("Residence noncanonical, missing, or miskeyed house identity: " + str(house.id))
        if seen.has(str(house.id)):
            errors.append("Residence duplicated a stable instance ID.")
        seen[str(house.id)] = true
        if house.level < 1 or house.level > 100:
            errors.append("Residence invalid house level.")
        if not SectResidenceSiteV1.has_valid_site_fields(house):
            errors.append("Residence contains malformed saved plot coordinates.")
        elif index == 0:
            if SectResidenceSiteV1.origin_of(house) != SectResidenceSiteV1.LEGACY_STARTER:
                errors.append("Residence starter plot cannot be relocated.")
        elif not bool(SectResidenceSiteV1.check(
                state,SectResidenceSiteV1.origin_of(house),str(house.id)).get("ok",false)):
            errors.append("Residence paid House plot overlaps a footprint or blocks a door.")
        if house.status == BuildingSystem.STATUS_CONSTRUCTING:
            if index == 0 or house.level != 1 or house.is_upgrading():
                errors.append("Residence starter/level cannot be under construction.")
            var start = house.production_state.get("construction_started_tick", null)
            var finish = house.production_state.get("construction_finish_tick", null)
            var duration = house.production_state.get("construction_duration_ticks", null)
            if not (start is int or start is float) \
                    or not (finish is int or finish is float) \
                    or not (duration is int or duration is float):
                errors.append("Residence construction timestamps are malformed.")
            elif (start is float and (is_nan(start) or is_inf(start))) \
                    or (finish is float and (is_nan(finish) or is_inf(finish))) \
                    or (duration is float and (is_nan(duration) or is_inf(duration))):
                errors.append("Residence construction timestamps are non-finite.")
            elif float(start) != float(int(start)) or float(finish) != float(int(finish)) \
                    or float(duration) != float(int(duration)) \
                    or int(start) < 0 or int(start) > state.tick \
                    or int(duration) != construction_duration_ticks(house.instance_index) \
                    or int(finish) != int(start) + int(duration):
                errors.append("Residence construction timer violates canonical tick contract.")
        elif house.status == BuildingSystem.STATUS_ACTIVE or house.status == BuildingSystem.STATUS_UPGRADING:
            if house.production_state.has("construction_started_tick") \
                    or house.production_state.has("construction_finish_tick") \
                    or house.production_state.has("construction_duration_ticks"):
                errors.append("Residence ready house retains construction timer fields.")
        else:
            errors.append("Residence house has invalid status.")
    if state.sect.lodging_capacity != maxi(1, total_beds(state)):
        errors.append("Residence bed capacity diverges from canonical houses.")
    if state.sect.disciple_capacity != maxi(state.disciples.size(), current_limit(state)):
        errors.append("Residence recruitment cap diverges from rank/bed authority.")
    var occupied: Dictionary = {}
    var saved_rooms = state.sect.hall_governance.get("residence_assignments", null)
    var build_receipts = state.sect.hall_governance.get("residence_build_receipts", null)
    if not (saved_rooms is Dictionary) or not (build_receipts is Dictionary):
        errors.append("Residence saved room or construction receipts are malformed.")
        return errors
    # DD-07: a paid construction receipt must continue to refer to the
    # exact real House. A phantom receipt otherwise returns "already_settled"
    # after reload while the owned building no longer exists.
    var paid_houses: Dictionary = {}
    for raw_request in build_receipts.keys():
        var request_id := str(raw_request)
        var paid_id := str(build_receipts[raw_request])
        if request_id.is_empty() or paid_id == "residence_001" or paid_houses.has(paid_id):
            errors.append("Residence invalid/duplicate paid construction receipt.")
            continue
        var paid_building = state.buildings.get(paid_id)
        if not (paid_building is BuildingState) or paid_building.building_type != TYPE:
            errors.append("Residence construction receipt references missing paid house.")
            continue
        paid_houses[paid_id] = true
    for house in houses:
        if str(house.id) != "residence_001" and not paid_houses.has(str(house.id)):
            errors.append("Residence has a nonstarter house without a paid construction receipt.")
    var move_receipts = governance.get("residence_move_receipts", {})
    if not (move_receipts is Dictionary):
        errors.append("Residence move receipts are malformed.")
    else:
        for raw_request in move_receipts.keys():
            var request_id := str(raw_request)
            var receipt = move_receipts[raw_request]
            if request_id.is_empty() or not (receipt is Dictionary):
                errors.append("Residence move receipt entry is malformed.")
                continue
            var moved_id := str(receipt.get("house_id", ""))
            var moved_house = state.buildings.get(moved_id)
            if not (moved_house is BuildingState) or moved_house.building_type != TYPE \
                    or moved_house.instance_index <= 1:
                errors.append("Residence move receipt references missing/immovable house.")
            for key in ["site_x", "site_y", "previous_x", "previous_y"]:
                var value = receipt.get(key, null)
                if not (value is int or value is float) or (value is float and (is_nan(value) or is_inf(value))) \
                        or float(value) != float(int(value)):
                    errors.append("Residence move receipt coordinates are malformed.")
                    break
    var rooms: Dictionary = saved_rooms
    for raw_id in rooms.keys():
        if not state.disciples.has(StringName(raw_id)):
            errors.append("Residence room assignment points at missing disciple.")
        var hid := str(rooms[raw_id])
        if not state.buildings.has(hid):
            errors.append("Residence room assignment references missing house.")
            continue
        var assigned_house = state.buildings[hid]
        if not (assigned_house is BuildingState) or assigned_house.building_type != TYPE:
            errors.append("Residence room assignment references non-House building.")
            continue
        if assigned_house.status == BuildingSystem.STATUS_CONSTRUCTING:
            errors.append("Residence room assigned before construction completion.")
        occupied[hid] = int(occupied.get(hid, 0)) + 1
    for house in houses:
        if int(occupied.get(str(house.id), 0)) > beds_for_level(house.level):
            errors.append("Residence overbooked house beds.")
    return errors
