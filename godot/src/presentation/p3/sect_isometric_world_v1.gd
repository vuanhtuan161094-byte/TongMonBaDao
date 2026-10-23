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
const VIEW_SIZE := Vector2(1280,570)
const MAP_SCREEN_OFFSET := Vector2(0,72)
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
const HOUSE_TEXTURES := {
    "main_hall":"pv01_assets/main_hall/510052.png",
    "warehouse":"pv01_assets/warehouse/510102.png",
    "forge":"pv01_assets/forge/520081.png"
}
const HOUSE_SIZES := {
    "main_hall":Vector2(300,201),
    "warehouse":Vector2(162,138),
    "forge":Vector2(205,164)
}
# PV01 renders sprite artwork at the CENTER of each actual static
# footprint (not at the map-model origin cell). This is presentation only.
const HOUSE_FOOTPRINT_CENTERS := {
    "main_hall":Vector2(3.0,2.0),
    "warehouse":Vector2(1.0,0.5),
    "forge":Vector2(1.0,1.0)
}
const ROAD_TEXTURES := {
    "cross":"stone_cross.png",
    "junction":"stone_junction.png",
    "axis_a":"stone_axis_a.png",
    "axis_b":"stone_axis_b.png",
    "branch":"stone_branch.png",
    "scatter":"stone_scatter.png"
}
# Curated lab ENV01 single-region vegetation, inside starter district.
const DECOR_LAYOUT := [
    {"id":"570036","offset":Vector2i(-1,7),"scale":0.42},
    {"id":"570037","offset":Vector2i(4,13),"scale":0.44},
    {"id":"570038","offset":Vector2i(19,9),"scale":0.40},
    {"id":"570171","offset":Vector2i(8,14),"scale":0.40},
    {"id":"570172","offset":Vector2i(21,4),"scale":0.40},
    {"id":"570173","offset":Vector2i(15,13),"scale":0.39},
    {"id":"570181","offset":Vector2i(-2,10),"scale":0.47},
    {"id":"570182","offset":Vector2i(20,10),"scale":0.46},
    {"id":"570041","offset":Vector2i(2,12),"scale":0.50},
    {"id":"570042","offset":Vector2i(18,-1),"scale":0.43},
    {"id":"570043","offset":Vector2i(13,13),"scale":0.47},
    {"id":"570073","offset":Vector2i(0,12),"scale":0.32},
    {"id":"570144","offset":Vector2i(9,6),"scale":0.38},
    {"id":"570399","offset":Vector2i(16,8),"scale":0.43},
    {"id":"570185","offset":Vector2i(-1,8),"scale":0.39},
    {"id":"570186","offset":Vector2i(11,13),"scale":0.34},
    {"id":"570187","offset":Vector2i(21,6),"scale":0.38},
    {"id":"570397","offset":Vector2i(18,7),"scale":0.30}
]

const SPAWN_CELL := Vector2i(82,84)
const ROADS_JUNCTION := Vector2i(91,91)

var camera: Camera2D
var surface: Node2D
var display_instances: Array[Dictionary] = []
var tiles: Dictionary = {}
var active_chunks: Array[Vector2i] = []
# Chunk-local immutable ArrayMesh, cached in memory; purely visual, no save data.
var ground_chunk_meshes: Dictionary = {}
var draw_revision := 0
var fallback_art_count := 0
var lab_geometry: SectIsoMapModelV1
var preview_roads: Dictionary = {}
var lab_routes_ready := false
var source_art: SectMap25SourceArt
var render_art: Dictionary = {}
var decoration_items: Array[Dictionary] = []
var art_loaded_count := 0
var art_source_status: Dictionary = {}


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
    _load_verified_source_art()
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

# Exact-SHA gated, individually optional Source A images. Fail-closed:
# no texture is drawn just because a file happens to have the correct name.
func _load_verified_source_art() -> void:
    source_art = SectMap25SourceArt.new()
    render_art.clear()
    decoration_items.clear()
    for house in HOUSE_TEXTURES:
        var key := str(HOUSE_TEXTURES[house])
        var asset := source_art.texture_for(key)
        if asset != null:
            render_art[key] = asset
    for key in ["stone_courtyard","stone_variant","stone_border","stone_runes"]:
        var rel := "env01_assets/terrain/%s.png" % key
        var terrain := source_art.texture_for(rel)
        if terrain != null:
            render_art[rel] = terrain
    for key in ROAD_TEXTURES:
        var rel := "env01_assets/roads/%s" % str(ROAD_TEXTURES[key])
        var paving := source_art.texture_for(rel)
        if paving != null:
            render_art[rel] = paving
    var occupied: Dictionary = {}
    for landmark in ["main_hall","warehouse","forge"]:
        if lab_geometry != null:
            var placed: Dictionary = lab_geometry.get_building(landmark)
            if not placed.is_empty():
                for tile in lab_geometry.cells_for(landmark,placed["origin"],0):
                    occupied[tile] = true
    for item in DECOR_LAYOUT:
        var tile: Vector2i = SPAWN_CELL+Vector2i(item["offset"])
        if not STARTER.has_point(tile) or occupied.has(tile) or preview_roads.has(tile):
            continue
        var rel := "env01_assets/vegetation/%s.png" % str(item["id"])
        var vegetation := source_art.texture_for(rel)
        if vegetation != null:
            render_art[rel] = vegetation
            decoration_items.append({
                "world":project(Vector2(tile)),
                "texture":vegetation,
                "scale":float(item["scale"]),
                "cell":tile
            })
    decoration_items.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        return (a["world"] as Vector2).y < (b["world"] as Vector2).y
    )
    art_source_status = source_art.status()
    art_loaded_count = int(art_source_status.get("accepted_count",0))
    # The user is not shown an invented Source A completion status.
    fallback_art_count = HOUSE_TEXTURES.size()-mini(HOUSE_TEXTURES.size(),render_art.size())
    queue_redraw()

func _road_key(cell: Vector2i) -> String:
    var neighbors := 0
    var n := preview_roads.has(cell+Vector2i(0,-1))
    var s := preview_roads.has(cell+Vector2i(0,1))
    var e := preview_roads.has(cell+Vector2i(1,0))
    var w := preview_roads.has(cell+Vector2i(-1,0))
    for on in [n,s,e,w]:
        if on:
            neighbors += 1
    if neighbors == 4:
        return "cross"
    if neighbors == 3:
        return "junction"
    if neighbors <= 1:
        return "branch" if posmod(cell.x+cell.y,3)!=0 else "scatter"
    if e and w:
        return "axis_a"
    if n and s:
        return "axis_b"
    return "cross"

static func project(cell: Vector2) -> Vector2:
    return Vector2((cell.x-cell.y)*HALF_W,(cell.x+cell.y)*HALF_H)

static func inverse(world: Vector2) -> Vector2:
    var u := world.x/HALF_W
    var v := world.y/HALF_H
    return Vector2((u+v)*0.5,(v-u)*0.5)

static func visual_anchor(destination: StringName, cell: Vector2i) -> Vector2:
    # The three verified PV01 houses must agree with footprint door geometry.
    # For all other destinations the existing V1 anchor remains authoritative.
    return Vector2(cell)+HOUSE_FOOTPRINT_CENTERS.get(str(destination),Vector2.ZERO)

static func virtual_legacy_point(destination: StringName, building_id: StringName = &"") -> Vector2:
    var cell: Vector2i = TYPE_ANCHORS.get(str(destination),Vector2i(90,92))
    if building_id != &"":
        # Extra instances in a fixed-layout V1 save have NO true placement.
        # Only display a stable read-only cluster, never persist coordinates.
        var sequence := maxi(int(str(building_id).get_slice("_",str(building_id).get_slice_count("_")-1)),1)
        if sequence > 1:
            cell += Vector2i((sequence-1)%4*2,(sequence-1)/4*2)
    return LEGACY_ANCHOR+project(visual_anchor(destination,cell))-project(CENTER_CELL)

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
    fallback_art_count = maxi(0,rows.size()-int(render_art.has(HOUSE_TEXTURES["main_hall"]))-int(render_art.has(HOUSE_TEXTURES["warehouse"]))-int(render_art.has(HOUSE_TEXTURES["forge"])))
    queue_redraw()

func _row(dest: StringName, instance_id: StringName, text_label: String, index: int, managed: bool) -> Dictionary:
    var cell: Vector2i = TYPE_ANCHORS.get(str(dest),Vector2i(90,92))
    if managed and index > 1:
        cell += Vector2i((index-1)%4*2,(index-1)/4*2)
    return {
        "destination":dest,
        "building_id":instance_id,
        "world":project(visual_anchor(dest,cell)),
        "cell":cell,
        "managed":managed,
        "label":text_label
    }

func set_legacy_transform(zoom: float, legacy_position: Vector2) -> bool:
    if camera == null:
        return false
    var z := clampf(zoom,0.75,1.80)
    # Match the legacy Control actor overlay and the isometric camera.
    var legacy_center := MAP_SCREEN_OFFSET+VIEW_SIZE*0.5
    var next_position := project(CENTER_CELL)-(
        legacy_position+LEGACY_ANCHOR*z-legacy_center
    )/z
    # Called every main-scene frame. A static camera does not need to
    # recalculate visible chunks or re-render thousands of ground tiles.
    if is_equal_approx(camera.zoom.x,z) and camera.position.is_equal_approx(next_position):
        return false
    camera.zoom = Vector2.ONE*z
    camera.position = next_position
    _update_chunks()
    return true

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

# Each static 16x16 chunk is one 2D colored triangle mesh instead of 256
# separate CanvasItem polygons. The viewport still redraws on camera motion,
# but its draw command count no longer grows by one per ground tile.
# Road paint is composited into its tile's vertex color; road sprites, paths,
# Source A buildings and vegetation stay in the existing overlay/depth pass.
func _ground_mesh_for_chunk(chunk_id: Vector2i) -> ArrayMesh:
    if ground_chunk_meshes.has(chunk_id):
        return ground_chunk_meshes[chunk_id] as ArrayMesh
    var vertices := PackedVector2Array()
    var colors := PackedColorArray()
    var indices := PackedInt32Array()
    var origin := chunk_id*CHUNK
    for iy in range(origin.y,mini(origin.y+CHUNK,GRID.y)):
        for ix in range(origin.x,mini(origin.x+CHUNK,GRID.x)):
            var cell := Vector2i(ix,iy)
            var center := project(Vector2(cell))
            var within := STARTER.has_point(cell)
            var tone := Color(0.39,0.56,0.36) if within else Color(0.26,0.35,0.29)
            if posmod(ix*17+iy*23,11)<4:
                tone = tone.lightened(0.055 if within else 0.012)
            if within and _is_road(cell):
                tone = tone.blend(Color(0.63,0.58,0.43,0.9))
            var base := vertices.size()
            vertices.append_array(PackedVector2Array([
                center+Vector2(0,-HALF_H),center+Vector2(HALF_W,0),
                center+Vector2(0,HALF_H),center+Vector2(-HALF_W,0)
            ]))
            for _vertex in range(4):
                colors.append(tone)
            indices.append_array(PackedInt32Array([
                base,base+1,base+2,base,base+2,base+3
            ]))
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_COLOR] = colors
    arrays[Mesh.ARRAY_INDEX] = indices
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(
        Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_2D_VERTICES
    )
    ground_chunk_meshes[chunk_id] = mesh
    return mesh

func _draw() -> void:
    # Ground layer first: cached meshes remain valid for all camera positions.
    # Visibility still uses the original active_chunks and the existing camera.
    for chunk_id in active_chunks:
        draw_mesh(_ground_mesh_for_chunk(chunk_id),null)
    # Sparse overlays only. Terrain tint and road fill are baked into the mesh.
    for chunk_id in active_chunks:
        var origin: Vector2i = chunk_id*CHUNK
        for iy in range(origin.y,mini(origin.y+CHUNK,GRID.y)):
            for ix in range(origin.x,mini(origin.x+CHUNK,GRID.x)):
                var cell := Vector2i(ix,iy)
                if not STARTER.has_point(cell):
                    continue
                var center := project(Vector2(cell))
                if _is_road(cell):
                    var road_key := "env01_assets/roads/%s" % str(ROAD_TEXTURES[_road_key(cell)])
                    if render_art.has(road_key):
                        draw_texture_rect(render_art[road_key],
                            Rect2(center-Vector2(HALF_W*1.1,HALF_H*1.15),
                                Vector2(HALF_W*2.2,HALF_H*2.3)),
                            false,Color(0.92,0.91,0.80,0.92))
                elif posmod(ix*13+iy*29,31)==0:
                    _draw_bush(center)
                if posmod(ix*11+iy*23,13)==0:
                    var tile_art := "env01_assets/terrain/stone_courtyard.png"
                    if render_art.has(tile_art):
                        draw_texture_rect(render_art[tile_art],
                            Rect2(center-Vector2(HALF_W,HALF_H),
                                Vector2(HALF_W*2.0,HALF_H*2.0)),
                            false,Color(0.78,0.90,0.76,0.13))
    # Sort all decorations with building art by actual projected ground depth.
    # One draw surface and one depth queue prevent large roofs from showing
    # behind trees which should occlude them.
    var queue: Array[Dictionary] = []
    for item in display_instances:
        if _visible_world(item["world"]):
            queue.append({"y":(item["world"] as Vector2).y,"kind":"building","data":item})
    for item in decoration_items:
        if _visible_world(item["world"]):
            queue.append({"y":(item["world"] as Vector2).y,"kind":"vegetation","data":item})
    queue.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        return float(a["y"]) < float(b["y"])
    )
    for entry in queue:
        var item: Dictionary = entry["data"]
        var place: Vector2 = item["world"]
        if str(entry["kind"]) == "vegetation":
            var tex: Texture2D = item["texture"]
            var scaled := tex.get_size()*float(item["scale"])
            draw_texture_rect(tex,Rect2(place-Vector2(scaled.x*0.5,
                scaled.y-4.0),scaled),false)
        else:
            _draw_building(place,str(item["destination"]),bool(item["managed"]))

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
    if HOUSE_TEXTURES.has(kind):
        var key := str(HOUSE_TEXTURES[kind])
        if render_art.has(key):
            var image: Texture2D = render_art[key]
            var target: Vector2 = HOUSE_SIZES[kind]
            var offset := Vector2(0.0,-target.y*0.28)
            draw_texture_rect(image,Rect2(p+offset-target*0.5,target),false)
            return
    # MAP25 visual-only fallback: a flat ground footprint, never a fake
    # 3D building. Actual producer rows retain BuildingState.id and tap hitbox.
    # Non-producer landmarks are navigation labels, not constructed buildings.
    var ground := Color(0.53,0.49,0.38)
    var mark := Color(0.78,0.71,0.54)
    var label := kind.replace("_"," ").to_upper()
    match kind:
        "mine":
            ground = Color(0.40,0.43,0.44)
            mark = Color(0.88,0.77,0.50)
            label = "MỎ"
        "linh_forest":
            ground = Color(0.25,0.43,0.32)
            mark = Color(0.75,0.88,0.56)
            label = "LINH LÂM"
        "spirit_field":
            ground = Color(0.43,0.53,0.30)
            mark = Color(0.92,0.84,0.52)
            label = "LINH ĐIỀN"
        "residence":
            label = "CƯ XÁ"
        "cultivation":
            label = "TU LUYỆN"
        "ren_than_duong":
            label = "RÈN THÂN"
        "medicine":
            label = "Y QUÁN"
        "alchemy_hall":
            label = "LUYỆN ĐAN"
        "guidance":
            label = "DẪN TIÊN"
        "gate":
            label = "CỔNG"
    var footprint := PackedVector2Array([
        p+Vector2(0,-18),p+Vector2(37,0),
        p+Vector2(0,18),p+Vector2(-37,0)
    ])
    draw_colored_polygon(footprint,ground)
    draw_polyline(PackedVector2Array([
        footprint[0],footprint[1],footprint[2],footprint[3],footprint[0]
    ]),mark,2.0,true)
    draw_circle(p,5.0,mark)
    if managed:
        draw_circle(p+Vector2(28,1),4.0,Color(0.99,0.78,0.28))
    var font: Font = ThemeDB.fallback_font
    if font != null:
        var font_size := 12
        var label_width := font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
        var at := p+Vector2(-label_width*0.5,35)
        draw_string_outline(font,at,label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,2,Color(0.10,0.15,0.11))
        draw_string(font,at,label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(1,0.98,0.88))

func draw_ellipse_shadow(p: Vector2) -> void:
    draw_colored_polygon(PackedVector2Array([
        p+Vector2(-70,1),p+Vector2(-32,-10),p+Vector2(35,-10),
        p+Vector2(75,1),p+Vector2(30,13),p+Vector2(-35,13)
    ]),Color(0.12,0.20,0.16,0.32))
