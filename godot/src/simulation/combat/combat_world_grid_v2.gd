class_name CombatWorldGridV2
extends RefCounted

# Optional finite V2 navigation grid. Source collision is input data only;
# damage, range, speed, targeting and settlement stay in MapBattleV2.
static func valid(grid: Dictionary) -> bool:
    if grid.is_empty():
        return true
    var width := int(grid.get("width",0))
    var height := int(grid.get("height",0))
    if width < 1 or height < 1 or width > 256 or height > 256:
        return false
    var cells = grid.get("blocked",null)
    if not (cells is Array) or cells.size() != width*height:
        return false
    for value in cells:
        if not (value is int or value is float) or float(value) not in [0.0,1.0]:
            return false
    return not str(grid.get("source_blob_sha","")).is_empty()

static func walkable(grid: Dictionary, cell: Vector2i) -> bool:
    if grid.is_empty():
        return true
    var width := int(grid["width"])
    if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= int(grid["height"]):
        return false
    return int(grid["blocked"][cell.y*width+cell.x]) == 0

static func cell_at(point: Vector2) -> Vector2i:
    return Vector2i(floori(point.x),floori(point.y))

static func nearest_open(grid: Dictionary, point: Vector2) -> Vector2:
    if grid.is_empty() or walkable(grid,cell_at(point)):
        return point
    var best := Vector2(-1.0,-1.0)
    var distance := INF
    for y in range(int(grid["height"])):
        for x in range(int(grid["width"])):
            var cell := Vector2i(x,y)
            if not walkable(grid,cell):
                continue
            var at := Vector2(cell)+Vector2(0.5,0.5)
            var candidate := point.distance_squared_to(at)
            if candidate < distance:
                best = at
                distance = candidate
    return best

static func segment_open(grid: Dictionary, from: Vector2, to: Vector2) -> bool:
    var samples := maxi(1,ceili(from.distance_to(to)/0.08))
    for i in range(samples+1):
        if not walkable(grid,cell_at(from.lerp(to,float(i)/float(samples)))):
            return false
    return true

static func move_toward(grid: Dictionary, from: Vector2, target: Vector2,
        maximum: float) -> Vector2:
    if grid.is_empty():
        return from.move_toward(target,maximum)
    if maximum <= 0.0:
        return from
    if segment_open(grid,from,target):
        return from.move_toward(target,maximum)
    var start := cell_at(from)
    var goal := cell_at(target)
    if not walkable(grid,start) or not walkable(grid,goal):
        return from
    # V2 uses a square metric. A deterministic four-neighbour route avoids
    # cutting corners; this does not copy JXQY's native pathfinding algorithm.
    var queue: Array[Vector2i] = [start]
    var previous: Dictionary = {start:start}
    var cursor := 0
    while cursor < queue.size() and not previous.has(goal):
        var cell := queue[cursor]
        cursor += 1
        for offset in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]:
            var next: Vector2i = cell+offset
            if walkable(grid,next) and not previous.has(next):
                previous[next] = cell
                queue.append(next)
    if not previous.has(goal):
        return from
    var next := goal
    while previous[next] != start and next != start:
        next = previous[next]
    var waypoint := Vector2(next)+Vector2(0.5,0.5)
    if not segment_open(grid,from,waypoint):
        waypoint = Vector2(start)+Vector2(0.5,0.5)
    var candidate := from.move_toward(waypoint,maximum)
    return candidate if segment_open(grid,from,candidate) else from
