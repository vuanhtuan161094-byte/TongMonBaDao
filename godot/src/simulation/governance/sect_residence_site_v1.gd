class_name SectResidenceSiteV1
extends RefCounted

# DD-09: player-selected House origins on the real 48x48 starter map.
# Only BuildingState.site_x/site_y is saved. The static map is authored once
# here and shared with the isometric renderer so collision, roads and visuals
# use the same world layout.
const STARTER := Rect2i(72, 72, 48, 48)
const HOUSE_FOOTPRINT := Vector2i(3, 3)
const HOUSE_CLEARANCE := 1 # keep Source A roofs and door approach from touching
const HOUSE_TYPE := &"residence"
const DOOR_OFFSET := Vector2i(1, -1)
const PATH_SPAWN := Vector2i(96, 102)
const ROAD_JUNCTION := Vector2i(89, 96)
const LEGACY_STARTER := Vector2i(76, 97)
const UNSELECTED := Vector2i(-999, -999)

# Map origins are shared with SectIsometricWorldV1. Fixed layout rows remain
# presentation geometry; they never become saved BuildingStates or resources.
const LEGACY_MAP_ANCHORS := {
    "main_hall":Vector2i(81,89), "warehouse":Vector2i(95,91),
    "forge":Vector2i(95,95), "residence":Vector2i(76,97),
    "cultivation":Vector2i(88,81), "ren_than_duong":Vector2i(77,93),
    "medicine":Vector2i(76,102), "alchemy_hall":Vector2i(98,86),
    "mine":Vector2i(92,83), "linh_forest":Vector2i(82,104),
    "spirit_field":Vector2i(103,93), "guidance":Vector2i(78,84),
    "gate":Vector2i(96,102)
}
const NEW_GAME_MAP_ANCHORS := {
    "main_hall":Vector2i(81,89), "warehouse":Vector2i(98,88),
    "forge":Vector2i(107,87), "residence":Vector2i(76,97),
    "cultivation":Vector2i(89,80), "ren_than_duong":Vector2i(77,82),
    "medicine":Vector2i(74,105), "alchemy_hall":Vector2i(106,84),
    "mine":Vector2i(74,82), "linh_forest":Vector2i(74,90),
    "spirit_field":Vector2i(108,96), "guidance":Vector2i(100,104),
    "gate":Vector2i(96,102)
}
const MAP_FOOTPRINT_SIZES := {
    "main_hall":Vector2i(7,5), "warehouse":Vector2i(3,2),
    "forge":Vector2i(3,3), "cultivation":Vector2i(2,2),
    "ren_than_duong":Vector2i(2,2), "medicine":Vector2i(2,2),
    "alchemy_hall":Vector2i(3,3), "mine":Vector2i(3,3),
    "linh_forest":Vector2i(2,2), "spirit_field":Vector2i(2,2),
    "guidance":Vector2i(2,2)
}
const ORIGIN_ANCHORED := ["main_hall","warehouse","forge"]
# Existing authored trees/rocks are reserved from new construction. The
# renderer already suppresses these sprites under a saved House footprint.
const MAP_DECOR_CELLS := [
    Vector2i(74,92),Vector2i(74,99),Vector2i(76,106),Vector2i(79,108),
    Vector2i(77,112),Vector2i(73,105),Vector2i(75,103),Vector2i(81,111),
    Vector2i(75,89),Vector2i(90,78),Vector2i(94,80),Vector2i(111,88),
    Vector2i(104,100),Vector2i(109,96),Vector2i(99,108),Vector2i(106,110),
    Vector2i(112,102),Vector2i(103,113)
]
# Retained solely for deterministic migration of legacy saves which had no
# persisted site coordinates. New player construction is not limited to these.
const ANNEX_SITES := [
    Vector2i(86,108),Vector2i(92,108),Vector2i(98,108),Vector2i(104,108),
    Vector2i(110,108),Vector2i(116,108),Vector2i(86,114),Vector2i(92,114),
    Vector2i(98,114),Vector2i(104,114),Vector2i(110,114),Vector2i(116,114)
]

static func map_anchors(world_layout_version: int) -> Dictionary:
    return NEW_GAME_MAP_ANCHORS if world_layout_version >= 2 else LEGACY_MAP_ANCHORS

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
        if not data.has("site_x") or not data.has("site_y"):
            return false
    if not data.has("site_x") and not data.has("site_y"):
        return true
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

static func _mark_rect(navigation: AStarGrid2D, rectangle: Rect2i) -> void:
    for y in range(rectangle.position.y,rectangle.end.y):
        for x in range(rectangle.position.x,rectangle.end.x):
            var cell := Vector2i(x,y)
            if STARTER.has_point(cell):
                navigation.set_point_solid(cell,true)

static func _map_footprints(state: SimulationState, roof_clearance: bool = true) -> Array[Rect2i]:
    var result: Array[Rect2i] = []
    if state == null:
        return result
    var anchors := map_anchors(state.sect.world_layout_version)
    for raw_kind in MAP_FOOTPRINT_SIZES.keys():
        var kind := str(raw_kind)
        var anchor: Vector2i = anchors[kind]
        var size: Vector2i = MAP_FOOTPRINT_SIZES[kind]
        var origin := anchor if ORIGIN_ANCHORED.has(kind) else anchor-Vector2i(int(size.x/2),int(size.y/2))
        var footprint := Rect2i(origin,size)
        result.append(footprint.grow(HOUSE_CLEARANCE) if roof_clearance else footprint)
    return result

static func _protected_road_cells(state: SimulationState) -> Dictionary:
    var roads: Dictionary = {}
    if state == null:
        return roads
    # Same starter-map path graph and segment order as the live renderer.
    var navigation := AStarGrid2D.new()
    navigation.region = STARTER
    navigation.cell_size = Vector2.ONE
    navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    navigation.update()
    var anchors := map_anchors(state.sect.world_layout_version)
    for kind in ["main_hall","warehouse","forge"]:
        var origin: Vector2i = anchors[kind]
        _mark_rect(navigation,Rect2i(origin,MAP_FOOTPRINT_SIZES[kind]))
    var hall_door: Vector2i = anchors["main_hall"]+Vector2i(3,-1)
    var warehouse_door: Vector2i = anchors["warehouse"]+Vector2i(1,-1)
    var forge_door: Vector2i = anchors["forge"]+Vector2i(1,-1)
    var segments := [
        {"from":PATH_SPAWN,"to":ROAD_JUNCTION},
        {"from":ROAD_JUNCTION,"to":hall_door},
        {"from":ROAD_JUNCTION,"to":warehouse_door},
        {"from":ROAD_JUNCTION,"to":forge_door},
        {"from":ROAD_JUNCTION,"to":anchors["mine"]+Vector2i(0,1)},
        {"from":ROAD_JUNCTION,"to":anchors["linh_forest"]+Vector2i(1,0)},
        {"from":ROAD_JUNCTION,"to":anchors["spirit_field"]+Vector2i(-1,0)},
        {"from":ROAD_JUNCTION,"to":anchors["residence"]},
        {"from":ROAD_JUNCTION,"to":anchors["cultivation"]}
    ]
    for segment in segments:
        var path: Array[Vector2i] = navigation.get_id_path(segment["from"],segment["to"])
        if path.is_empty():
            return {}
        for cell in path:
            roads[cell] = true
            if not navigation.is_point_solid(cell):
                navigation.set_point_weight_scale(cell,0.7)
    return roads

static func _path_navigation(state: SimulationState, ignore_id: String = "") -> AStarGrid2D:
    if state == null:
        return null
    var navigation := AStarGrid2D.new()
    navigation.region = STARTER
    navigation.cell_size = Vector2.ONE
    navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    navigation.update()
    for footprint in _map_footprints(state,true):
        _mark_rect(navigation,footprint)
    for cell in MAP_DECOR_CELLS:
        if STARTER.has_point(cell):
            navigation.set_point_solid(cell,true)
    for row in state.buildings.values():
        if not (row is BuildingState) or row.building_type != HOUSE_TYPE \
                or str(row.id) == ignore_id:
            continue
        if not has_valid_site_fields(row):
            return null
        _mark_rect(navigation,Rect2i(origin_of(row),HOUSE_FOOTPRINT).grow(HOUSE_CLEARANCE))
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
    if navigation == null or navigation.is_point_solid(PATH_SPAWN) or navigation.is_point_solid(door):
        return empty_path
    return navigation.get_id_path(PATH_SPAWN,door)

static func _candidate_occupied(state: SimulationState, origin: Vector2i,
        ignore_id: String, roads: Dictionary) -> String:
    var footprint := Rect2i(origin,HOUSE_FOOTPRINT)
    var entrance := doorway(origin)
    if not STARTER.encloses(footprint) or not STARTER.has_point(entrance):
        return "house_plot_outside_open_area"
    if roads.is_empty():
        return "house_map_routes_unavailable"
    var safe_footprint := footprint.grow(HOUSE_CLEARANCE)
    for fixed in _map_footprints(state,true):
        if safe_footprint.intersects(fixed):
            return "house_plot_occupied"
    # The live renderer hides authored vegetation under a canonical House
    # footprint and its door cell. It therefore is not a physical collision
    # blocker; protecting it here incorrectly removed legal plots from DD-09.
    for cell in roads.keys():
        if footprint.has_point(cell):
            return "house_plot_blocks_road"
    for row in state.buildings.values():
        if not (row is BuildingState) or row.building_type != HOUSE_TYPE \
                or str(row.id) == ignore_id:
            continue
        if not has_valid_site_fields(row):
            return "corrupt_existing_house_plot"
        var other_origin := origin_of(row)
        var other_footprint := Rect2i(other_origin,HOUSE_FOOTPRINT)
        var other_safe := other_footprint.grow(HOUSE_CLEARANCE)
        if safe_footprint.intersects(other_safe) \
                or other_footprint.has_point(entrance) \
                or footprint.has_point(doorway(other_origin)) \
                or doorway(other_origin) == entrance:
            return "house_plot_occupied"
    return ""

static func check(state: SimulationState, origin: Vector2i,
        ignore_id: String = "", navigation: AStarGrid2D = null) -> Dictionary:
    if state == null:
        return {"ok":false,"reason":"invalid_house_plot"}
    var roads := _protected_road_cells(state)
    var occupied_reason := _candidate_occupied(state,origin,ignore_id,roads)
    if occupied_reason != "":
        return {"ok":false,"reason":occupied_reason}
    var path := path_to_door(state,origin,ignore_id,navigation)
    if path.is_empty():
        return {"ok":false,"reason":"house_plot_unreachable"}
    return {"ok":true,"origin":origin,"door":doorway(origin),
        "path_length":path.size(),"path_cells":path}

static func _reachable_cells(navigation: AStarGrid2D) -> Dictionary:
    var reachable: Dictionary = {}
    if navigation == null or navigation.is_point_solid(PATH_SPAWN):
        return reachable
    var queue: Array[Vector2i] = [PATH_SPAWN]
    reachable[PATH_SPAWN] = true
    var index := 0
    var offsets: Array[Vector2i] = [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]
    while index < queue.size():
        var cell := queue[index]
        index += 1
        for offset in offsets:
            var next: Vector2i = cell+offset
            if not STARTER.has_point(next) or reachable.has(next) or navigation.is_point_solid(next):
                continue
            reachable[next] = true
            queue.append(next)
    return reachable

static func available_plots(state: SimulationState) -> Array[Vector2i]:
    var result: Array[Vector2i] = []
    if state == null:
        return result
    var roads := _protected_road_cells(state)
    if roads.is_empty():
        return result
    var navigation := _path_navigation(state)
    if navigation == null:
        return result
    var reachable := _reachable_cells(navigation)
    for y in range(STARTER.position.y,STARTER.end.y-HOUSE_FOOTPRINT.y+1):
        for x in range(STARTER.position.x,STARTER.end.x-HOUSE_FOOTPRINT.x+1):
            var origin := Vector2i(x,y)
            if _candidate_occupied(state,origin,"",roads) != "":
                continue
            if reachable.has(doorway(origin)):
                result.append(origin)
    return result
