class_name SectIsometricWorldV1
extends Node2D

# Actual main-scene 2.5D world surface: ENV-02A world geometry, not economy.
# No persistence, construction, Hall levels, unlocked-region grants or new clock.
# Artwork is opt-in ONLY after independently verified game-repo import.
const GRID := Vector2i(192,192)
const CHUNK := 16
const STARTER := Rect2i(72,72,48,48)
const HALF_W := 25.0
const HALF_H := 13.0
const VIEW_SIZE := Vector2(1028,570)
const MAP_SCREEN_OFFSET := Vector2(252,72)
const LEGACY_ANCHOR := Vector2(768,354)
const CENTER_CELL := Vector2(90,92)
const TYPE_ANCHORS := {
    "main_hall": Vector2i(84,86),
    "warehouse": Vector2i(96,87),
    "forge": Vector2i(92,92),
    "residence": Vector2i(96,83),
    "cultivation": Vector2i(89,87),
    "ren_than_duong": Vector2i(80,88),
    "medicine": Vector2i(95,98),
    "alchemy_hall": Vector2i(100,94),
    "mine": Vector2i(80,94),
    "linh_forest": Vector2i(84,99),
    "spirit_field": Vector2i(87,103),
    "guidance": Vector2i(104,88),
    "gate": Vector2i(104,104)
}
const PRODUCER_TYPES := {
    "mine":"mine",
    "linh_forest":"linh_forest",
    "spirit_field":"spirit_field"
}
const APPROVED_IMAGE_PATHS := {} # No verified Source A binaries in GitHub-only package.
const SPAWN_CELL := Vector2i(82,84)
const ROADS_JUNCTION := Vector2i(91,91)

var camera: Camera2D
var surface: Node2D
var display_instances: Array[Dictionary] = []
var tiles: Dictionary = {}
var active_chunks: Array[Vector2i] = []
var draw_revision := 0
var fallback_art_count := 0
var lab_geometry: SectIsoMapModelV1
var preview_roads: Dictionary = {}
var lab_routes_ready := false

func _ready() -> void:
    camera = Camera2D.new()
    camera.name = "SectIsoCamera2D"
    camera.enabled = true
    camera.position = project(CENTER_CELL)
    camera.zoom = Vector2.ONE
    add_child(camera)
    surface = Node2D.new()
    surface.name = "SectIsoChunkWorld"
    surface.z_index = -8
    add_child(surface)
    set_process(false)
    # An actual Node2D world with Camera2D lives only inside its own SubViewport.
    # The parent Control HUD is intentionally outside this camera transform.
    _seed_env02a_geometry()
    _update_chunks()

# Reuse the ENV02A lab's exact AStarGrid2D/doorway geometry. This model
# owns ONLY procedural visual roads in the SubViewport, never player layout
# or paid construction. It is rebuilt from static content, never saved.
func _seed_env02a_geometry() -> void:
    lab_geometry = SectIsoMapModelV1.new(GRID,SPAWN_CELL)
    for kind in ["main_hall","warehouse","forge"]:
        var origin: Vector2i = TYPE_ANCHORS[kind]
        var placement := lab_geometry.place(kind,kind,origin)
        if not bool(placement.get("ok",false)):
            lab_routes_ready = false
            push_warning("ISO_ENV02A_PREVIEW_SEED "+kind+" "+str(placement.get("reason","")))
            return
    lab_routes_ready = true
    var hall := lab_geometry.get_building("main_hall")
    var store := lab_geometry.get_building("warehouse")
    var forge := lab_geometry.get_building("forge")
    var hdoor: Vector2i = lab_geometry.doorway("main_hall",hall["origin"],0)
    var sdoor: Vector2i = lab_geometry.doorway("warehouse",store["origin"],0)
    var fdoor: Vector2i = lab_geometry.doorway("forge",forge["origin"],0)
    var segments := [
        [SPAWN_CELL,hdoor],[hdoor,ROADS_JUNCTION],
        [ROADS_JUNCTION,sdoor],[ROADS_JUNCTION,fdoor]
    ]
    for pair in segments:
        var navigation: AStarGrid2D = lab_geometry._navigation()
        var route: Array[Vector2i] = navigation.get_id_path(pair[0],pair[1])
        if route.is_empty():
            lab_routes_ready = false
            continue
        for cell in route:
            if not lab_geometry.occupied(cell):
                preview_roads[cell] = true
                if cell not in lab_geometry.roads:
                    lab_geometry.toggle_road(cell)
    for kind in ["main_hall","warehouse","forge"]:
        if lab_geometry.path_to(kind,SPAWN_CELL).is_empty():
            lab_routes_ready = false
    queue_redraw()

static func project(cell: Vector2) -> Vector2:
    return Vector2((cell.x-cell.y)*HALF_W,(cell.x+cell.y)*HALF_H)

static func inverse(world: Vector2) -> Vector2:
    var u := world.x/HALF_W
    var v := world.y/HALF_H
    return Vector2((u+v)*0.5,(v-u)*0.5)

static func virtual_legacy_point(destination: StringName, building_id: StringName = &"") -> Vector2:
    var cell := TYPE_ANCHORS.get(str(destination),Vector2i(90,92))
    if building_id != &"":
        # Extra instances in a fixed-layout V1 save have NO true placement.
        # Only display a stable read-only cluster, never persist coordinates.
        var sequence := maxi(int(str(building_id).get_slice("_",str(building_id).get_slice_count("_")-1)),1)
        if sequence > 1:
            cell += Vector2i((sequence-1)%4*2,(sequence-1)/4*2)
    return LEGACY_ANCHOR+project(Vector2(cell))-project(CENTER_CELL)

func refresh_from_state(state: SimulationState) -> void:
    if state == null:
        return
    var rows: Array[Dictionary] = []
    for raw_dest in TYPE_ANCHORS.keys():
        var dest := StringName(raw_dest)
        if PRODUCER_TYPES.has(str(dest)):
            # True canonical instances only. No fake second Mine from art token.
            var matching: Array = []
            for raw_id in state.buildings.keys():
                var building: BuildingState = state.buildings[raw_id]
                if str(building.building_type) == str(PRODUCER_TYPES[str(dest)]):
                    matching.append(building)
            matching.sort_custom(func(a: BuildingState,b: BuildingState) -> bool:
                return str(a.id)<str(b.id))
            for building in matching:
                rows.append(_row(dest,building.id,str(building.display_name),building.instance_index,true))
        else:
            # A visual landmark/destination is NOT a BuildingState.
            rows.append(_row(dest,&"",str(dest).replace("_"," ").capitalize(),1,false))
    rows.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var pa: Vector2 = a["world"]
        var pb: Vector2 = b["world"]
        return pa.y < pb.y)
    display_instances = rows
    fallback_art_count = rows.size()
    queue_redraw()

func _row(dest: StringName, instance_id: StringName, text_label: String, index: int, managed: bool) -> Dictionary:
    var cell: Vector2i = TYPE_ANCHORS.get(str(dest),Vector2i(90,92))
    if managed and index > 1:
        cell += Vector2i((index-1)%4*2,(index-1)/4*2)
    return {
        "destination":dest,
        "building_id":instance_id,
        "world":project(Vector2(cell)),
        "cell":cell,
        "managed":managed,
        "label":text_label
    }

func set_legacy_transform(zoom: float, legacy_position: Vector2) -> void:
    if camera == null:
        return
    var z := clampf(zoom,0.75,1.80)
    camera.zoom = Vector2.ONE*z
    # Legacy canvas transform: screen = legacy_position + old_world_pixel*z.
    # Center the Camera2D so the Node2D and existing overlay/tap projection
    # have identical screen coordinates at all accepted pan/zoom values.
    var legacy_center := MAP_SCREEN_OFFSET+VIEW_SIZE*0.5
    camera.position = project(CENTER_CELL)-(
        legacy_position+LEGACY_ANCHOR*z-legacy_center
    )/z
    _update_chunks()

func _update_chunks() -> void:
    if camera == null:
        return
    var half_view := VIEW_SIZE*0.5/camera.zoom.x
    var low := Vector2i(99999,99999)
    var high := Vector2i(-99999,-99999)
    for d in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
        var c := inverse(camera.position+Vector2(half_view.x*d.x,half_view.y*d.y))
        low = low.min(Vector2i(floori(c.x),floori(c.y)))
        high = high.max(Vector2i(ceili(c.x),ceili(c.y)))
    low = (low-Vector2i(3,3)).max(Vector2i.ZERO)
    high = (high+Vector2i(3,3)).min(GRID-Vector2i.ONE)
    var chunks: Array[Vector2i] = []
    for cx in range(clampi(floori(float(low.x)/CHUNK),0,11),clampi(floori(float(high.x)/CHUNK),0,11)+1):
        for cy in range(clampi(floori(float(low.y)/CHUNK),0,11),clampi(floori(float(high.y)/CHUNK),0,11)+1):
            chunks.append(Vector2i(cx,cy))
    if chunks == active_chunks:
        return
    active_chunks = chunks
    draw_revision += 1
    queue_redraw()

func screen_to_world(screen: Vector2) -> Vector2:
    if camera == null:
        return Vector2.ZERO
    var local_view := screen-MAP_SCREEN_OFFSET
    return camera.position+(local_view-VIEW_SIZE*0.5)/camera.zoom.x

func pick_at_screen(screen: Vector2) -> Dictionary:
    var world := screen_to_world(screen)
    # Closest-frontmost manually authored 2.5D silhouette, not the saved
    # placement geometry. Selection dispatches canonical building instance id.
    var result: Dictionary = {}
    var best_distance := INF
    for item in display_instances:
        var place: Vector2 = item["world"]
        var offset := world-place
        # Allow hitting the roof above its ground-plane anchor.
        var normalized := Vector2(offset.x/78.0,(offset.y+36.0)/78.0)
        var distance := normalized.length()
        if distance <= 1.0 and distance < best_distance:
            best_distance = distance
            result = item.duplicate(true)
    return result

func _draw() -> void:
    # Batched per-visible-chunk drawing; only map geometry, no saved ownership.
    # Fallback is deliberately stylized until verified Source A pack is imported.
    for chunk_id in active_chunks:
        var origin: Vector2i = chunk_id*CHUNK
        for iy in range(origin.y,mini(origin.y+CHUNK,GRID.y)):
            for ix in range(origin.x,mini(origin.x+CHUNK,GRID.x)):
                var cell := Vector2i(ix,iy)
                var center := project(Vector2(cell))
                var within := STARTER.has_point(cell)
                var tone := Color(0.39,0.56,0.36) if within else Color(0.26,0.35,0.29)
                if posmod(ix*17+iy*23,11)<4:
                    tone = tone.lightened(0.055 if within else 0.012)
                var diamond := PackedVector2Array([
                    center+Vector2(0,-HALF_H),center+Vector2(HALF_W,0),
                    center+Vector2(0,HALF_H),center+Vector2(-HALF_W,0)
                ])
                draw_colored_polygon(diamond,tone)
                if within and _is_road(cell):
                    draw_colored_polygon(diamond,Color(0.63,0.58,0.43,0.9))
                elif within and posmod(ix*13+iy*29,31)==0:
                    _draw_bush(center)
    for item in display_instances:
        var place: Vector2 = item["world"]
        if not _visible_world(place):
            continue
        var dest := str(item["destination"])
        var managed := bool(item["managed"])
        _draw_building(place,dest,managed)

func _visible_world(point: Vector2) -> bool:
    if camera == null:
        return false
    var half := VIEW_SIZE*0.5/camera.zoom.x+Vector2(170,175)
    var delta := (point-camera.position).abs()
    return delta.x <= half.x and delta.y <= half.y

func _is_road(cell: Vector2i) -> bool:
    # Rebuildable read-only ENV-02A map-model route projection.
    return STARTER.has_point(cell) and preview_roads.has(cell)

func _draw_bush(p: Vector2) -> void:
    draw_circle(p+Vector2(0,-8),6,Color(0.14,0.38,0.24,0.83))
    draw_circle(p+Vector2(-3,-11),5,Color(0.23,0.46,0.27,0.88))

func _draw_building(p: Vector2,kind: String, managed: bool) -> void:
    var base := Color(0.68,0.54,0.35)
    var roof := Color(0.23,0.45,0.36)
    if kind == "mine":
        base = Color(0.48,0.48,0.46)
        roof = Color(0.23,0.24,0.26)
    elif kind == "linh_forest":
        base = Color(0.25,0.38,0.25)
        roof = Color(0.17,0.46,0.27)
    elif kind == "spirit_field":
        base = Color(0.59,0.47,0.29)
        roof = Color(0.34,0.59,0.30)
    elif kind == "main_hall":
        roof = Color(0.26,0.45,0.50)
    draw_ellipse_shadow(p)
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(-58,-32),p+Vector2(0,-5),p+Vector2(58,-32),p+Vector2(0,-59)
    ]),base.darkened(0.20))
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(-58,-32),p+Vector2(0,-5),p+Vector2(0,-51),p+Vector2(-58,-78)
    ]),base)
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(0,-5),p+Vector2(58,-32),p+Vector2(58,-78),p+Vector2(0,-51)
    ]),base.darkened(0.10))
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(-68,-80),p+Vector2(0,-118),p+Vector2(68,-80),p+Vector2(0,-43)
    ]),roof if managed else roof.lightened(0.11))
    draw_line(p+Vector2(-68,-80),p+Vector2(0,-43),Color(0.87,0.76,0.50),3.0)
    draw_line(p+Vector2(68,-80),p+Vector2(0,-43),Color(0.87,0.76,0.50),3.0)
    if managed:
        draw_circle(p+Vector2(0,6),5,Color(0.93,0.74,0.30))

func draw_ellipse_shadow(p: Vector2) -> void:
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(-70,1),p+Vector2(-32,-10),p+Vector2(35,-10),
        p+Vector2(75,1),p+Vector2(30,13),p+Vector2(-35,13)
    ]),Color(0.12,0.20,0.16,0.32))
