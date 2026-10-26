class_name PveOpenWorldTopologyV1
extends RefCounted

# Builds continuous, walkable monster regions from a pinned JXQY2 collision
# grid. Regions are spawn behavior zones over one map, never separate battles.
const CAMP_COUNT := 20
const SLOTS_PER_CAMP := 10

static func build(navigation: Dictionary, spawn_hint: Vector2 = Vector2(7.0,40.0)) -> Dictionary:
    var width := int(navigation.get("width",0))
    var height := int(navigation.get("height",0))
    var blocked = navigation.get("blocked",null)
    if width < 8 or height < 8 or not (blocked is Array or blocked is PackedByteArray) or blocked.size() != width*height:
        return {"ok":false,"reason":"invalid_jx_navigation_grid"}
    var start := _nearest_walkable(navigation,Vector2i(floori(spawn_hint.x),floori(spawn_hint.y)))
    if start.x < 0:
        return {"ok":false,"reason":"no_walkable_jx_spawn"}
    var reachable := _reachable_cells(navigation,start)
    if reachable.size() < CAMP_COUNT*SLOTS_PER_CAMP+6:
        return {"ok":false,"reason":"jx_map_connected_walkable_area_too_small"}

    var raw_centres: Array[Vector2i] = []
    for row in range(4):
        for column in range(5):
            raw_centres.append(Vector2i(
                clampi(roundi((float(column)+0.5)*float(width)/5.0),0,width-1),
                clampi(roundi((float(row)+0.5)*float(height)/4.0),0,height-1)))
    var remaining := raw_centres.duplicate()
    var ordered_centres: Array[Vector2i] = []
    var cursor := Vector2(start)+Vector2(0.5,0.5)
    var used_centres: Dictionary = {}
    for _index in range(CAMP_COUNT):
        var chosen_raw := Vector2i(-1,-1)
        var chosen_cell := Vector2i(-1,-1)
        var best := INF
        for raw in remaining:
            var candidate := _nearest_reachable(reachable,raw,used_centres,width)
            if candidate.x < 0:
                continue
            var distance := cursor.distance_squared_to(Vector2(candidate)+Vector2(0.5,0.5))
            if distance < best:
                best = distance
                chosen_raw = raw
                chosen_cell = candidate
        if chosen_cell.x < 0:
            return {"ok":false,"reason":"jx_map_camp_regions_cannot_be_separated"}
        remaining.erase(chosen_raw)
        used_centres[chosen_cell.y*width+chosen_cell.x] = true
        ordered_centres.append(chosen_cell)
        cursor = Vector2(chosen_cell)+Vector2(0.5,0.5)

    var camp_positions: Array[Vector2] = []
    for cell in ordered_centres:
        camp_positions.append(Vector2(cell)+Vector2(0.5,0.5))
    var slot_positions: Dictionary = {}
    var used_slots: Dictionary = {}
    var party_spawn_points: Array[Vector2] = []
    for camp_index in range(CAMP_COUNT):
        var center := camp_positions[camp_index]
        var candidates: Array[Vector2i] = []
        for cell in reachable:
            var distance := Vector2(cell).distance_squared_to(center)
            if distance <= 49.0:
                candidates.append(cell)
        candidates.sort_custom(func(a: Vector2i,b: Vector2i) -> bool:
            var da := Vector2(a).distance_squared_to(center)
            var db := Vector2(b).distance_squared_to(center)
            if is_equal_approx(da,db):
                return a.y*width+a.x < b.y*width+b.x
            return da < db)
        var ordinal := 0
        for cell in candidates:
            var key: int = cell.y*width+cell.x
            if used_slots.has(key):
                continue
            used_slots[key] = true
            var position := Vector2(cell)+Vector2(0.5,0.5)
            slot_positions[PveMultiCampPopulationV1.slot_id(camp_index,ordinal)] = position
            ordinal += 1
            if ordinal == SLOTS_PER_CAMP:
                break
        if ordinal != SLOTS_PER_CAMP:
            return {"ok":false,"reason":"jx_map_region_has_too_few_nearby_spawn_cells","camp":PveMultiCampPopulationV1.camp_id(camp_index)}
    # Keep the selected team together at the camp instead of scattering them
    # across empty cells. JX sprites can overlap naturally; small offsets keep
    # their world positions distinct while all six share the same walkable tile
    # and can engage the nearest monsters immediately.
    var party_offsets := [
        Vector2(-0.36,-0.30),Vector2(0.0,-0.40),Vector2(0.36,-0.30),
        Vector2(-0.36,0.30),Vector2(0.0,0.40),Vector2(0.36,0.30)
    ]
    var anchor_cell := Vector2i(floori(camp_positions[0].x),floori(camp_positions[0].y))
    if not _walkable(navigation,anchor_cell):
        return {"ok":false,"reason":"jx_map_party_anchor_not_walkable"}
    for offset in party_offsets:
        party_spawn_points.append(camp_positions[0]+offset)
    return {"ok":true,"bounds":Rect2(Vector2.ZERO,Vector2(width,height)),
        "navigation":navigation.duplicate(true),"camp_positions":camp_positions,
        "slot_positions":slot_positions,"party_spawn_points":party_spawn_points,
        "source_map":str(navigation.get("source_map","")),
        "source_blob_sha":str(navigation.get("source_blob_sha","")),
        "camp_count":CAMP_COUNT,"slots_per_camp":SLOTS_PER_CAMP}

static func _walkable(navigation: Dictionary, cell: Vector2i) -> bool:
    var width := int(navigation["width"])
    var height := int(navigation["height"])
    if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= height:
        return false
    var blocked = navigation["blocked"]
    return int(blocked[cell.y*width+cell.x]) == 0

static func _nearest_walkable(navigation: Dictionary, origin: Vector2i) -> Vector2i:
    var width := int(navigation["width"])
    var height := int(navigation["height"])
    for radius in range(maxi(width,height)):
        for y in range(origin.y-radius,origin.y+radius+1):
            for x in range(origin.x-radius,origin.x+radius+1):
                if absi(x-origin.x) != radius and absi(y-origin.y) != radius:
                    continue
                var cell := Vector2i(x,y)
                if _walkable(navigation,cell):
                    return cell
    return Vector2i(-1,-1)

static func _reachable_cells(navigation: Dictionary, start: Vector2i) -> Array[Vector2i]:
    var width := int(navigation["width"])
    var queue: Array[Vector2i] = [start]
    var seen: Dictionary = {start.y*width+start.x:true}
    var result: Array[Vector2i] = []
    var head := 0
    var directions := [Vector2i(0,-1),Vector2i(-1,0),Vector2i(1,0),Vector2i(0,1)]
    while head < queue.size():
        var cell := queue[head]
        head += 1
        result.append(cell)
        for direction in directions:
            var next: Vector2i = cell+direction
            if not _walkable(navigation,next):
                continue
            var key := next.y*width+next.x
            if seen.has(key):
                continue
            seen[key] = true
            queue.append(next)
    return result

static func _nearest_reachable(cells: Array[Vector2i], target: Vector2i, excluded: Dictionary, width: int) -> Vector2i:
    var chosen := Vector2i(-1,-1)
    var best := INF
    for cell in cells:
        var key := cell.y*width+cell.x
        if excluded.has(key):
            continue
        var distance := Vector2(cell).distance_squared_to(Vector2(target))
        if distance < best:
            best = distance
            chosen = cell
    return chosen
