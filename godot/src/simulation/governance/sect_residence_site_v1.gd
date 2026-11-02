class_name SectResidenceSiteV1
extends RefCounted

# DD-09.3: exterior-door House plots with an actual four-way walk path to the
# sect gate. Placement remains deterministic and independent of visual roads.
# Simulation/save authority: only the actual BuildingState owns site_x/site_y.
# Existing House saves lacking placement fields retain their deterministic
# historical location; no automatic relocation or player-save rewrites.
const STARTER := Rect2i(72, 72, 48, 48)
const HOUSE_FOOTPRINT := Vector2i(3, 3)
const HOUSE_TYPE := &"residence"
const DOOR_OFFSET := Vector2i(1, -1)
const PATH_SPAWN := Vector2i(96, 102)
const LEGACY_STARTER := Vector2i(76, 97)
const UNSELECTED := Vector2i(-999, -999)

# Twelve small annex sites for at most nine paid houses. Spacing leaves
# outdoor interaction cells, avoids the central Hall and protects the gate.
const ANNEX_SITES := [
    Vector2i(86, 108), Vector2i(92, 108),
    Vector2i(98, 108), Vector2i(104, 108),
    Vector2i(110, 108), Vector2i(116, 108),
    Vector2i(86, 114), Vector2i(92, 114),
    Vector2i(98, 114), Vector2i(104, 114),
    Vector2i(110, 114), Vector2i(116, 114)
]

# Current authoritative static village footprints; placement is denied if a
# player-chosen House or its entrance would overlap these legacy landmarks.
const FIXED_FOOTPRINTS := [
    Rect2i(81, 89, 7, 5),  # Hall
    Rect2i(95, 91, 3, 2),  # Warehouse
    Rect2i(95, 95, 3, 3)   # Forge
]

static func historical_origin(index: int) -> Vector2i:
    if index <= 1:
        return LEGACY_STARTER
    var ordinal := index - 2
    var column := ordinal % 6
    var row := int(ordinal / 6)
    return Vector2i(86 + column * 6, 108 + row * 6)

static func origin_of(house: BuildingState) -> Vector2i:
    if house == null:
        return UNSELECTED
    var data: Dictionary = house.production_state
    if data.has("site_x") and data.has("site_y"):
        return Vector2i(int(data["site_x"]), int(data["site_y"]))
    return historical_origin(house.instance_index)

static func has_valid_site_fields(house: BuildingState) -> bool:
    if house == null:
        return false
    var data: Dictionary = house.production_state
    if data.has("site_version"):
        var version = data["site_version"]
        if not (version is int or version is float) \
                or (version is float and (is_nan(version) or is_inf(version))) \
                or float(version) != 1.0:
            return false
        # Explicit site schema never silently reverts to an old indexed lot.
        if not data.has("site_x") or not data.has("site_y"):
            return false
    if not data.has("site_x") and not data.has("site_y"):
        return true # Old V2 House: deterministic location migration.
    if not data.has("site_x") or not data.has("site_y"):
        return false
    for key in ["site_x", "site_y"]:
        var value = data[key]
        if not (value is int or value is float):
            return false
        if value is float and (is_nan(value) or is_inf(value)):
            return false
        if float(value) != float(int(value)):
            return false
    return true

static func doorway(origin: Vector2i) -> Vector2i:
    return origin + DOOR_OFFSET

static func _path_navigation(state: SimulationState,
        ignore_id: String = "") -> AStarGrid2D:
    if state == null:
        return null
    var navigation := AStarGrid2D.new()
    navigation.region = STARTER
    navigation.cell_size = Vector2.ONE
    navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    navigation.update()
    for footprint in FIXED_FOOTPRINTS:
        for y in range(footprint.position.y,footprint.end.y):
            for x in range(footprint.position.x,footprint.end.x):
                var cell := Vector2i(x,y)
                if STARTER.has_point(cell):
                    navigation.set_point_solid(cell,true)
    for row in state.buildings.values():
        if not (row is BuildingState) or row.building_type != HOUSE_TYPE \
                or str(row.id) == ignore_id:
            continue
        if not has_valid_site_fields(row):
            return null
        var footprint := Rect2i(origin_of(row),HOUSE_FOOTPRINT)
        for y in range(footprint.position.y,footprint.end.y):
            for x in range(footprint.position.x,footprint.end.x):
                var cell := Vector2i(x,y)
                if STARTER.has_point(cell):
                    navigation.set_point_solid(cell,true)
    return navigation

static func path_to_door(state: SimulationState, origin: Vector2i,
        ignore_id: String = "", navigation: AStarGrid2D = null) -> Array[Vector2i]:
    var empty_path: Array[Vector2i] = []
    if state == null or not STARTER.has_point(PATH_SPAWN):
        return empty_path
    var door := doorway(origin)
    if not STARTER.has_point(door):
        return empty_path
    if navigation == null:
        navigation = _path_navigation(state,ignore_id)
    if navigation == null:
        return empty_path
    if navigation.is_point_solid(PATH_SPAWN) or navigation.is_point_solid(door):
        return empty_path
    return navigation.get_id_path(PATH_SPAWN,door)

static func check(state: SimulationState, origin: Vector2i,
        ignore_id: String = "", navigation: AStarGrid2D = null) -> Dictionary:
    if state == null or not ANNEX_SITES.has(origin):
        return {"ok": false, "reason": "invalid_house_plot"}
    var footprint := Rect2i(origin, HOUSE_FOOTPRINT)
    var entrance := doorway(origin)
    if not STARTER.encloses(footprint) or not STARTER.has_point(entrance):
        return {"ok": false, "reason": "house_plot_outside_open_area"}
    # The entrance must remain open, collision-free, and reachable from the
    # sect gate on the canonical four-way walking grid.
    for fixed in FIXED_FOOTPRINTS:
        if footprint.intersects(fixed) or fixed.has_point(entrance):
            return {"ok": false, "reason": "house_plot_occupied"}
    for row in state.buildings.values():
        if not (row is BuildingState) or row.building_type != HOUSE_TYPE                 or str(row.id) == ignore_id:
            continue
        if not has_valid_site_fields(row):
            return {"ok": false, "reason": "corrupt_existing_house_plot"}
        var occupied := Rect2i(origin_of(row), HOUSE_FOOTPRINT)
        if occupied.intersects(footprint) or occupied.has_point(entrance)                 or footprint.has_point(doorway(origin_of(row)))                 or doorway(origin_of(row)) == entrance:
            return {"ok": false, "reason": "house_plot_occupied"}
    var path := path_to_door(state,origin,ignore_id,navigation)
    if path.is_empty():
        return {"ok": false, "reason": "house_plot_unreachable"}
    return {"ok": true, "origin": origin, "door": entrance,
        "path_length": path.size(), "path_cells": path}

static func available_plots(state: SimulationState) -> Array[Vector2i]:
    var result: Array[Vector2i] = []
    if state == null:
        return result
    var navigation := _path_navigation(state)
    if navigation == null:
        return result
    for site in ANNEX_SITES:
        if bool(check(state,site,"",navigation).get("ok",false)):
            result.append(site)
    return result
