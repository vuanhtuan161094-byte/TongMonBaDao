class_name ResourceBuildingExpansionPolicyV2
extends RefCounted

# Economy V2 opening expansion CAP CONTRACT, read-only by design.
# This is not SectLayoutState / Hall / land / construction transaction.
# Player-authorized building creation must remain BLOCKED until the separate
# persistent-layout, Hall-level and paid-construction authorities are present.
const RAW_TYPES := [
    BuildingSystem.TYPE_MINE,
    BuildingSystem.TYPE_LINH_FOREST,
    BuildingSystem.TYPE_SPIRIT_FIELD
]
const TIERS := [
    {"hall_level": 1, "mine": 1, "linh_forest": 1, "spirit_field": 1, "minimum_average": 1},
    {"hall_level": 10, "mine": 2, "linh_forest": 2, "spirit_field": 3, "minimum_average": 5},
    {"hall_level": 20, "mine": 5, "linh_forest": 5, "spirit_field": 7, "minimum_average": 10},
    {"hall_level": 40, "mine": 10, "linh_forest": 10, "spirit_field": 14, "minimum_average": 20},
    {"hall_level": 60, "mine": 18, "linh_forest": 18, "spirit_field": 24, "minimum_average": 35},
    {"hall_level": 80, "mine": 30, "linh_forest": 30, "spirit_field": 40, "minimum_average": 50}
]

static func tier_for_level(hall_level: int) -> Dictionary:
    if hall_level < 1 or hall_level > 100:
        return {}
    var chosen: Dictionary = {}
    for raw_tier in TIERS:
        var tier: Dictionary = raw_tier
        if hall_level < int(tier["hall_level"]):
            break
        chosen = tier
    return chosen.duplicate(true)

static func capacity_for(hall_level: int, building_type: StringName) -> int:
    if not RAW_TYPES.has(building_type):
        return 0
    return int(tier_for_level(hall_level).get(str(building_type), 0))

static func existing_instances(state: SimulationState, building_type: StringName) -> Array[BuildingState]:
    var result: Array[BuildingState] = []
    if state == null or not RAW_TYPES.has(building_type):
        return result
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var value = state.buildings[raw_id]
        if value is BuildingState and value.building_type == building_type:
            result.append(value)
    return result

static func next_instance_index(state: SimulationState, building_type: StringName) -> int:
    if state == null or not RAW_TYPES.has(building_type):
        return 0
    var maximum := 0
    for existing in existing_instances(state, building_type):
        maximum = maxi(maximum, existing.instance_index)
    return maximum + 1

static func preview(
    state: SimulationState, building_type: StringName, hypothetical_hall_level: int
) -> Dictionary:
    # Deliberately NOT a valid construction preflight. The Hall level here is
    # hypothetical; no Hall state exists to prove it, nor persistent placement.
    if state == null or not state.p3_7_buildings_enabled:
        return {"ok": false, "reason": "building_state_unavailable"}
    if not RAW_TYPES.has(building_type):
        return {"ok": false, "reason": "unsupported_resource_building"}
    var tier := tier_for_level(hypothetical_hall_level)
    if tier.is_empty():
        return {"ok": false, "reason": "invalid_hypothetical_hall_level"}

    var existing := existing_instances(state,building_type)
    var total_levels := 0.0
    for current in existing:
        total_levels += float(current.level)
    var average := total_levels / float(existing.size()) if not existing.is_empty() else 0.0
    var cap := int(tier[str(building_type)])
    var required_average := int(tier["minimum_average"])
    return {
        "ok": false,
        "reason": "hall_land_and_construction_authority_pending",
        "preview_only": true,
        "building_type": str(building_type),
        "hypothetical_hall_level": hypothetical_hall_level,
        "current_count": existing.size(),
        "limit": cap,
        "available_slots": maxi(cap-existing.size(),0),
        "mean_existing_level": average,
        "required_mean_level": required_average,
        "capacity_condition_met": existing.size() < cap,
        "progression_condition_met": existing.size() > 0 and average >= float(required_average),
        "next_instance_index": next_instance_index(state,building_type)
    }
