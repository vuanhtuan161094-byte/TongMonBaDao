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
const NEW_GAME_FOCUS_CELL := Vector2(92,96)
# Option B is a presentation-only layout seed in the existing 48x48 starter.
# The model's route origin is the reserved gate point; no actor spawn or
# SimulationState field is changed by this map-only coordinate.
const TYPE_ANCHORS := SectResidenceSiteV1.LEGACY_MAP_ANCHORS
# A deliberate New Game composition: the Hall is the hub, Residence sits to
# the west, Guidance to the south, and Warehouse/Forge form the east work wing.
# This is a versioned visual layout; old saves retain their original anchors.
const TYPE_ANCHORS_NEW_GAME := SectResidenceSiteV1.NEW_GAME_MAP_ANCHORS
const PRODUCER_TYPES := {
    "main_hall":"main_hall",
    "mine":"mine",
    "linh_forest":"linh_forest",
    "spirit_field":"spirit_field",
    "alchemy_hall":"alchemy_hall",
    "residence":"residence"
}
# Deterministic QA display slots for canonical endgame instances. These are
# presentation-only because P3.2 has no persisted per-building placement yet.
# Each row is spaced for touch picking and remains within the 192x192 world.
const PRODUCER_DISTRICTS := {
    "mine":{"origin":Vector2i(16,18),"columns":6,"column_step":6,"row_step":6},
    "linh_forest":{"origin":Vector2i(16,126),"columns":6,"column_step":6,"row_step":6},
    "spirit_field":{"origin":Vector2i(130,72),"columns":8,"column_step":5,"row_step":7},
    "alchemy_hall":{"origin":Vector2i(120,12),"columns":6,"column_step":6,"row_step":6},
    # Deterministic temporary village annex sites; not editable placement.
    "residence":{"origin":Vector2i(86,108),"columns":6,"column_step":6,"row_step":6}
}
const HOUSE_TEXTURES := {
    "main_hall":"pv01_assets/main_hall/510052.png",
    "residence":"pv01_assets/residence/510076.png",
    "guidance":"pv01_assets/guidance/510111.png",
    "warehouse":"pv01_assets/warehouse/510102.png",
    "forge":"pv01_assets/forge/520081.png"
}
# Target rectangles retain each source sprite's measured aspect ratio.
const HOUSE_SIZES := {
    "main_hall":Vector2(300,201),
    "residence":Vector2(174,135.03),
    "guidance":Vector2(182,202.54),
    "warehouse":Vector2(162,138),
    "forge":Vector2(205,164)
}
# Original map-specific worksite vignettes, explicitly NOT Source A,
# NOT approved replacements for the historical missing building art.
# Runtime references are kept separate from the MAP25 SHA-gated inventory.
const MAP_D2_CANDIDATE_SITES := {
    "mine":"res://art/tmb_original_v1/mine_isometric.svg",
    "linh_forest":"res://art/map_d2_candidate/linh_forest_worksite_v1.svg",
    "spirit_field":"res://art/map_d2_candidate/spirit_field_worksite_v1.svg"
}
const REIMAGINED_REVIEW_ONLY_SITES := {
    "alchemy_hall":"res://art/reimagined_source_a_v1/alchemy_hall_3q_v1.svg"
}
const V3_ART = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")
const TMB_ORIGINAL_ART = preload("res://src/presentation/p3/tmb_original_world_art_v1.gd")
const MAP_D2_SITE_SIZE := {
    "mine":Vector2(166,121),
    "linh_forest":Vector2(166,121),
    "spirit_field":Vector2(166,121)
}
# PV01 renders sprite artwork at the CENTER of each actual static
# footprint (not at the map-model origin cell). This is presentation only.
const HOUSE_FOOTPRINT_CENTERS := {
    "main_hall":Vector2(3.0,2.0),
    "warehouse":Vector2(1.0,0.5),
    "forge":Vector2(1.0,1.0)
}
# DD-09.2: Destination = OUTSIDE the door, not inside the building sprite.
# Entrance offsets are one ground tile beyond the known footprint.
# No roads/entrance graph are needed to accept construction: characters move
# directly to this exterior interaction cell in the sect-only presentation.
# PvE's independent navigation and terrain collision remain unchanged.
const EXTERIOR_DOOR_OFFSETS := {
    "main_hall":Vector2i(3,-1),
    "warehouse":Vector2i(1,-1),
    "forge":Vector2i(1,-1),
    "residence":Vector2i(1,-1),
    "mine":Vector2i(1,3),
    "linh_forest":Vector2i(0,2),
    "spirit_field":Vector2i(0,2),
    "alchemy_hall":Vector2i(1,3),
    "cultivation":Vector2i(0,2),
    "ren_than_duong":Vector2i(0,2),
    "medicine":Vector2i(0,2),
    "guidance":Vector2i(0,2)
}
const ROAD_TEXTURES := {
    "cross":"stone_cross.png",
    "junction":"stone_junction.png",
    "axis_a":"stone_axis_a.png",
    "axis_b":"stone_axis_b.png",
    "branch":"stone_branch.png",
    "scatter":"stone_scatter.png"
}
# Curated, SHA-gated ENV01 props kept off buildings, roads, marker hitboxes,
# and the paved hub. 570183 remains intentionally unused: its semantics are
# not needed to communicate the three districts.
const DECOR_LAYOUT := [
    {"id":"570036","cell":Vector2i(74,92),"scale":0.42},
    {"id":"570037","cell":Vector2i(74,99),"scale":0.44},
    {"id":"570038","cell":Vector2i(76,106),"scale":0.40},
    {"id":"570171","cell":Vector2i(79,108),"scale":0.40},
    {"id":"570172","cell":Vector2i(77,112),"scale":0.40},
    {"id":"570173","cell":Vector2i(73,105),"scale":0.39},
    {"id":"570181","cell":Vector2i(75,103),"scale":0.47},
    {"id":"570182","cell":Vector2i(81,111),"scale":0.46},
    {"id":"570041","cell":Vector2i(75,89),"scale":0.50},
    {"id":"570042","cell":Vector2i(90,78),"scale":0.43},
    {"id":"570043","cell":Vector2i(94,80),"scale":0.47},
    {"id":"570073","cell":Vector2i(111,88),"scale":0.32},
    {"id":"570144","cell":Vector2i(104,100),"scale":0.38},
    {"id":"570399","cell":Vector2i(109,96),"scale":0.43},
    {"id":"570185","cell":Vector2i(99,108),"scale":0.39},
    {"id":"570186","cell":Vector2i(106,110),"scale":0.34},
    {"id":"570187","cell":Vector2i(112,102),"scale":0.38},
    {"id":"570397","cell":Vector2i(103,113),"scale":0.30}
]

# SPAWN_CELL is only the seed used by this presentation preview model.  It is
# aligned to the reserved gate point to produce the requested visual spine.
const SPAWN_CELL := Vector2i(96,102)
const PVE_SPAWN_CELL := Vector2i(95,72)
const ROADS_JUNCTION := Vector2i(89,96)
const COURTYARD_RECT := Rect2i(85,93,8,6)
const COURTYARD_RUNE_CELLS := [Vector2i(89,95),Vector2i(89,97)]
const PRODUCTION_APRON_RECT := Rect2i(94,92,5,6)
const PVE_JX_VFX_ADAPTER_SCRIPT := preload("res://src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd")
const PRODUCER_ROUTE_APPROACH := {
    "mine":Vector2i(0,1),
    "linh_forest":Vector2i(1,0),
    "spirit_field":Vector2i(-1,0)
}

var camera: Camera2D
var surface: Node2D
var display_instances: Array[Dictionary] = []
var selected_visual_site_id := ""
var tiles: Dictionary = {}
var active_chunks: Array[Vector2i] = []
# Chunk-local immutable ArrayMesh, cached in memory; purely visual, no save data.
var ground_chunk_meshes: Dictionary = {}
# View overlays are static once road topology and verified art are loaded.
# Build them once rather than rescanning all 16x16 cells on every draw.
var terrain_overlays_by_chunk: Dictionary = {}
var road_overlays_by_chunk: Dictionary = {}
var draw_revision := 0
var fallback_art_count := 0
var lab_geometry: SectIsoMapModelV1
var map_layout_version := 0
var placement_preview: Dictionary = {}
var preview_roads: Dictionary = {}
var static_preview_roads: Dictionary = {}
var residence_layout_signature := ""
var residence_road_signature := ""
var preview_routes: Dictionary = {}
var lab_routes_ready := false
var source_art: SectMap25SourceArt
var render_art: Dictionary = {}
# Experimental visual-only artwork is separate from source_art.status().
var candidate_site_art: Dictionary = {}
# Presentation-only; never persisted or used as production authority.
var variant_v3_textures: Dictionary = {}
var variant_v3_running_ids: Dictionary = {}
var decoration_items_by_chunk: Dictionary = {}
# Visual-only suppression of decorative plants under real House footprints.
var house_reserved_tiles: Dictionary = {}
var pve_static_draw_queue: Array[Dictionary] = []
var pve_detailed_site_ids: Dictionary = {}
var pve_static_queue_dirty := true
var pve_static_queue_camera_position := Vector2.ZERO
var pve_static_queue_zoom := 0.0
var pve_static_queue_chunks: Array[Vector2i] = []
var pve_static_queue_selected_site := ""
var pve_static_queue_has_view := false
var art_loaded_count := 0
var art_source_status: Dictionary = {}
var pve_landscape := false
var pve_path_cells: Dictionary = {}
var pve_obstacle_cells: Dictionary = {}
var pve_navigation: Dictionary = {}
var pve_topology: Dictionary = {}
var pve_battle: MapBattleV2
var pve_view_rows: Dictionary = {}
var pve_render_positions: Dictionary = {}
var pve_target_positions: Dictionary = {}
var pve_actor_actions: Dictionary = {}
var pve_clock := 0.0
var _pve_last_visual_encounter_id := ""
var pve_source_atlas := CombatV5SourceAAtlas.new()
var pve_jx_sword_vfx = PVE_JX_VFX_ADAPTER_SCRIPT.new()
var pve_selected_actor_ids: Array[String] = []
var pve_mini_texture: Texture2D
var pve_camera_initialized := false
var pve_performance_logging_enabled := false
var pve_vfx_advance_count := 0
var pve_vfx_advance_usec_total := 0
var pve_vfx_advance_usec_max := 0
const PVE_TREE_ASSETS := ["570036","570037","570038"]
const PVE_BAMBOO_ASSETS := ["570041","570042","570043"]
const PVE_ROCK_ASSETS := ["570073"]
const PVE_RARE_AUTUMN_ASSETS := ["570171","570172","570173"]
const PVE_RARE_BLOSSOM_ASSETS := ["570181","570182","570185","570186","570187"]
const PVE_FOREST_ASSETS := PVE_TREE_ASSETS + PVE_BAMBOO_ASSETS + PVE_ROCK_ASSETS + PVE_RARE_AUTUMN_ASSETS + PVE_RARE_BLOSSOM_ASSETS
const PVE_BRIDGE_ROWS := [32,92,150]


func configure_map_layout_version(version: int) -> void:
    # This must be called before add_child(), because _ready() seeds its road
    # presentation from the same layout version as the canonical save marker.
    map_layout_version = version if version == 2 else 0

func anchors_for_layout(version: int = -1) -> Dictionary:
    var resolved := map_layout_version if version < 0 else version
    return TYPE_ANCHORS_NEW_GAME if resolved == 2 else TYPE_ANCHORS

func anchor_for(destination: StringName, version: int = -1) -> Vector2i:
    return Vector2i(anchors_for_layout(version).get(str(destination),Vector2i(90,92)))

func set_placement_preview(preview: Dictionary) -> void:
    placement_preview = preview.duplicate(true)
    queue_redraw()

func clear_placement_preview() -> void:
    placement_preview.clear()
    queue_redraw()

func _ready() -> void:
    pve_performance_logging_enabled = OS.get_environment("TMB_PVE_PERF_LOG") == "1"
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
    if pve_landscape:
        _seed_pve_landscape()
    else:
        _seed_env02a_geometry()
    static_preview_roads = preview_roads.duplicate(true)
    _load_verified_source_art()
    _update_chunks()
    set_process(pve_landscape)

func configure_pve_landscape() -> void:
    # Select the landscape-only profile before the production renderer enters
    # the tree. Combat V2 remains the only simulation authority.
    pve_landscape = true

func _seed_pve_landscape() -> void:
    lab_geometry = SectIsoMapModelV1.new(GRID,PVE_SPAWN_CELL)
    pve_obstacle_cells = _pve_obstacles()
    pve_navigation = pve_navigation_grid()
    var navigation := _pve_astar()
    var start := PVE_SPAWN_CELL
    for row in range(4):
        for column in range(5):
            var center := Vector2i(roundi((float(column)+0.5)*float(GRID.x)/5.0),roundi((float(row)+0.5)*float(GRID.y)/4.0))
            var target := PveOpenWorldTopologyV1._nearest_walkable(pve_navigation,center)
            if target.x < 0:
                continue
            for cell in navigation.get_id_path(start,target):
                pve_path_cells[cell] = true
            start = target
    preview_roads = pve_path_cells.duplicate(true)
    pve_mini_texture = _pve_minimap_texture(pve_navigation,pve_path_cells)
    lab_routes_ready = true

static func pve_stream_center_x(y: float) -> float:
    return 97.0+sin(y*0.052)*17.0+sin(y*0.117)*5.0

static func pve_bridge_at(cell: Vector2i) -> bool:
    for bridge_y in PVE_BRIDGE_ROWS:
        var center_x := roundi(pve_stream_center_x(float(bridge_y)))
        if absi(cell.y-bridge_y) <= 1 and absi(cell.x-center_x) <= 3:
            return true
    return false

static func pve_forest_layout() -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var clearings: Array[Vector2i] = [PVE_SPAWN_CELL]
    for row in range(4):
        for column in range(5):
            clearings.append(Vector2i(roundi((float(column)+0.5)*float(GRID.x)/5.0),roundi((float(row)+0.5)*float(GRID.y)/4.0)))
    var asset_index := 0
    for y in range(4,188,5):
        for x in range(4,188,5):
            var cell := Vector2i(x,y)
            if absf(float(x)-pve_stream_center_x(float(y))) < 8.0:
                continue
            var clear := false
            for clearing in clearings:
                if Vector2(cell-clearing).length_squared() < 49.0:
                    clear = true
                    break
            if clear:
                continue
            var hash_value := posmod(x*1103515245+y*12345+20261026,2147483647)
            if hash_value%100 >= 42:
                continue
            var roll := hash_value%100
            var palette: Array = PVE_TREE_ASSETS
            if roll >= 48 and roll < 82:
                palette = PVE_BAMBOO_ASSETS
            elif roll >= 82 and roll < 94:
                palette = PVE_ROCK_ASSETS
            elif roll >= 94 and roll < 98:
                palette = PVE_RARE_AUTUMN_ASSETS
            elif roll >= 98:
                palette = PVE_RARE_BLOSSOM_ASSETS
            var selected_asset := str(palette[posmod(asset_index+hash_value,palette.size())])
            rows.append({"id":selected_asset,"cell":cell,"scale":0.53 if hash_value%3 == 0 else (0.45 if hash_value%3 == 1 else 0.38)})
            asset_index += 1
    return rows

static func pve_navigation_grid() -> Dictionary:
    var blocked := PackedByteArray()
    blocked.resize(GRID.x*GRID.y)
    for cell in _pve_obstacles():
        if cell.x >= 0 and cell.y >= 0 and cell.x < GRID.x and cell.y < GRID.y:
            blocked[cell.y*GRID.x+cell.x] = 1
    var identity := "sect-isometric-env02a-pve-v1|%s|%s|%s" % [str(GRID),str(PVE_SPAWN_CELL),str(PVE_BRIDGE_ROWS)]
    for row in pve_forest_layout():
        identity += "|%s:%s" % [str(row["id"]),str(row["cell"])]
    return {"width":GRID.x,"height":GRID.y,"blocked":blocked,"source_blob_sha":identity.sha1_text(),"source_map":"sect_isometric_source_a_pve_v1"}

static func _pve_obstacles() -> Dictionary:
    var result: Dictionary = {}
    for y in range(GRID.y):
        var center_x := pve_stream_center_x(float(y))
        for x in range(maxi(0,floori(center_x)-2),mini(GRID.x,ceili(center_x)+3)):
            var cell := Vector2i(x,y)
            if not pve_bridge_at(cell):
                result[cell] = true
    for row in pve_forest_layout():
        var cell: Vector2i = row["cell"]
        for oy in range(-1,2):
            for ox in range(-1,2):
                var blocked_cell := cell+Vector2i(ox,oy)
                if blocked_cell.x >= 0 and blocked_cell.y >= 0 and blocked_cell.x < GRID.x and blocked_cell.y < GRID.y and not pve_bridge_at(blocked_cell):
                    result[blocked_cell] = true
    return result

func _pve_astar() -> AStarGrid2D:
    var nav := AStarGrid2D.new()
    nav.region = Rect2i(Vector2i.ZERO,GRID)
    nav.cell_size = Vector2.ONE
    nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    nav.update()
    for cell in pve_obstacle_cells:
        nav.set_point_solid(cell,true)
    return nav

static func _pve_minimap_texture(navigation: Dictionary,path_cells: Dictionary = {}) -> Texture2D:
    var image := Image.create(GRID.x,GRID.y,false,Image.FORMAT_RGBA8)
    var blocked: PackedByteArray = navigation["blocked"]
    for y in range(GRID.y):
        for x in range(GRID.x):
            var cell := Vector2i(x,y)
            var color := Color("54794f") if int(blocked[y*GRID.x+x]) == 0 else Color("334b39")
            if absf(float(x)-pve_stream_center_x(float(y))) <= 2.5:
                color = Color("538786")
            if pve_bridge_at(cell):
                color = Color("a18e64")
            elif path_cells.has(cell):
                color = Color("9b8b5e")
            image.set_pixel(x,y,color)
    return ImageTexture.create_from_image(image)

# Reuse the ENV02A lab's exact AStarGrid2D/doorway geometry. This model
# owns ONLY procedural visual roads in the SubViewport, never player layout
# or paid construction. It is rebuilt from static content, never saved.
func _seed_env02a_geometry() -> void:
    lab_geometry = SectIsoMapModelV1.new(GRID,SPAWN_CELL)
    var anchors := anchors_for_layout()
    for kind in ["main_hall","warehouse","forge"]:
        var origin: Vector2i = anchors[kind]
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
        {"id":"gate_to_courtyard","from":SPAWN_CELL,"to":ROADS_JUNCTION},
        {"id":"courtyard_to_main_hall","from":ROADS_JUNCTION,"to":hdoor},
        {"id":"courtyard_to_warehouse","from":ROADS_JUNCTION,"to":sdoor},
        {"id":"courtyard_to_forge","from":ROADS_JUNCTION,"to":fdoor},
        {"id":"courtyard_to_mine","from":ROADS_JUNCTION,"to":anchors["mine"]+PRODUCER_ROUTE_APPROACH["mine"]},
        {"id":"courtyard_to_linh_forest","from":ROADS_JUNCTION,"to":anchors["linh_forest"]+PRODUCER_ROUTE_APPROACH["linh_forest"]},
        {"id":"courtyard_to_spirit_field","from":ROADS_JUNCTION,"to":anchors["spirit_field"]+PRODUCER_ROUTE_APPROACH["spirit_field"]},
        {"id":"courtyard_to_residence","from":ROADS_JUNCTION,"to":anchors["residence"]},
        {"id":"courtyard_to_cultivation","from":ROADS_JUNCTION,"to":anchors["cultivation"]}
    ]
    # The previous seed rebuilt a full 192x192 AStarGrid2D for each of
    # nine road routes, then three more times to recheck the doorways.
    # Keep ONE presentation-only navigation grid and update weights as each
    # road becomes available. This is equivalent to rebuilding from roads,
    # but avoids 11 redundant rebuilds and duplicate geometry traversal.
    var route_navigation: AStarGrid2D = lab_geometry._navigation()
    for segment in segments:
        if not _record_preview_route(str(segment["id"]),segment["from"],segment["to"],route_navigation):
            lab_routes_ready = false
            push_warning("ISO_ENV02A_PREVIEW_ROUTE_FAILED %s %s -> %s" % [str(segment["id"]),str(segment["from"]),str(segment["to"])])
    for kind in ["main_hall","warehouse","forge"]:
        var placed: Dictionary = lab_geometry.get_building(kind)
        var door: Vector2i = lab_geometry.doorway(kind,placed["origin"],0)
        if route_navigation.is_point_solid(SPAWN_CELL) or route_navigation.is_point_solid(door) or route_navigation.get_id_path(SPAWN_CELL,door).is_empty():
            lab_routes_ready = false
    queue_redraw()

func _record_preview_route(route_id: String, from_cell: Vector2i, to_cell: Vector2i, shared_navigation: AStarGrid2D = null) -> bool:
    if not STARTER.has_point(from_cell) or not STARTER.has_point(to_cell):
        return false
    # Optional argument retains the old independent route probe contract.
    var navigation: AStarGrid2D = shared_navigation if shared_navigation != null else lab_geometry._navigation()
    var route: Array[Vector2i] = navigation.get_id_path(from_cell,to_cell)
    if route.is_empty():
        return false
    for cell in route:
        if not STARTER.has_point(cell) or lab_geometry.occupied(cell):
            return false
    preview_routes[route_id] = route.duplicate()
    for cell in route:
        preview_roads[cell] = true
        if cell not in lab_geometry.roads and lab_geometry.toggle_road(cell):
            # Apply same scale as SectIsoMapModelV1._navigation(), so shared
            # route searches make identical path choices to full rebuilds.
            navigation.set_point_weight_scale(cell,0.7)
    return true

# Exact-SHA gated, individually optional Source A images. Fail-closed:
# no texture is drawn just because a file happens to have the correct name.
func _load_verified_source_art() -> void:
    source_art = SectMap25SourceArt.new()
    render_art.clear()
    candidate_site_art.clear()
    variant_v3_textures.clear()
    decoration_items_by_chunk.clear()
    # V3 is additive; if any PNG is absent the canonical worksite fallback stays visible.
    for path_v3 in V3_ART.all_paths():
        if not ResourceLoader.exists(path_v3, "Texture2D"):
            continue
        var tex_v3 := ResourceLoader.load(path_v3) as Texture2D
        if tex_v3 != null and tex_v3.get_width() > 0 and tex_v3.get_height() > 0:
            variant_v3_textures[path_v3] = tex_v3
    # Godot-imported candidate SVGs may be unavailable; fall back to the
    # original honest marker. Never add them to verified MAP25 art status.
    for kind in MAP_D2_CANDIDATE_SITES:
        var candidate_path := str(MAP_D2_CANDIDATE_SITES[kind])
        # Avoid a noisy invalid resource lookup when a candidate SVG was not
        # included/imported in a partial checkout or export. Source A assets
        # remain separately SHA-gated and their original paths are unchanged.
        if not ResourceLoader.exists(candidate_path,"Texture2D"):
            continue
        var candidate := ResourceLoader.load(candidate_path) as Texture2D
        if candidate != null:
            candidate_site_art[kind] = candidate
    for house in HOUSE_TEXTURES:
        var key := str(HOUSE_TEXTURES[house])
        var asset := source_art.texture_for(key)
        # Preserve independent SHA verification, but render original TMB hall.
        # The raw Source A atlas remains only as historical provenance/rollback.
        if house == "main_hall":
            render_art[key] = TMB_ORIGINAL_ART.hall()
        elif asset != null:
            render_art[key] = asset
    for key in ["stone_courtyard","stone_variant","stone_border","stone_runes"]:
        var rel := "env01_assets/terrain/%s.png" % key
        var original_terrain := source_art.texture_for(rel)
        # VIS-07 replaces every map tile regardless of historical SHA status.
        if original_terrain != null:
            render_art[rel] = TMB_ORIGINAL_ART.stone_for(key)
    for key in ROAD_TEXTURES:
        var rel := "env01_assets/roads/%s" % str(ROAD_TEXTURES[key])
        var original_paving := source_art.texture_for(rel)
        if original_paving != null:
            render_art[rel] = TMB_ORIGINAL_ART.stone_for(str(ROAD_TEXTURES[key]))
    var occupied: Dictionary = {}
    for landmark in ["main_hall","warehouse","forge"]:
        if lab_geometry != null:
            var placed: Dictionary = lab_geometry.get_building(landmark)
            if not placed.is_empty():
                for tile in lab_geometry.cells_for(landmark,placed["origin"],0):
                    occupied[tile] = true
    var placement_rows: Array = pve_forest_layout() if pve_landscape else DECOR_LAYOUT
    for item in placement_rows:
        var tile: Vector2i = item["cell"]
        if pve_landscape:
            if preview_roads.has(tile):
                continue
        else:
            if not STARTER.has_point(tile) or occupied.has(tile) or preview_roads.has(tile):
                continue
            var marker_clear := true
            for raw_anchor in anchors_for_layout().values():
                if (tile-Vector2i(raw_anchor)).length_squared() <= 2:
                    marker_clear = false
                    break
            if not marker_clear or COURTYARD_RECT.has_point(tile):
                continue
        var rel := "env01_assets/vegetation/%s.png" % str(item["id"])
        var historical_vegetation := source_art.texture_for(rel)
        # Cache original material once per source ID; never draw Source A foliage.
        var vegetation: Texture2D = TMB_ORIGINAL_ART.foliage_for(str(item["id"]))
        if historical_vegetation != null and vegetation != null:
            render_art[rel] = vegetation
            var chunk := Vector2i(tile.x/CHUNK,tile.y/CHUNK)
            if not decoration_items_by_chunk.has(chunk):
                decoration_items_by_chunk[chunk] = []
            (decoration_items_by_chunk[chunk] as Array).append({
                "world":project(Vector2(tile)+(Vector2(0.5,0.5) if pve_landscape else Vector2.ZERO)),
                "texture":vegetation,
                "scale":float(item["scale"]),
                "cell":tile
            })
    _cache_static_overlays()
    pve_static_queue_dirty = true
    art_source_status = source_art.status()
    art_loaded_count = int(art_source_status.get("accepted_count",0))
    # The user is not shown an invented Source A completion status.
    fallback_art_count = HOUSE_TEXTURES.size()-_verified_house_art_count()
    queue_redraw()

func _verified_house_art_count() -> int:
    var loaded := 0
    for value in HOUSE_TEXTURES.values():
        if render_art.has(str(value)):
            loaded += 1
    return loaded

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
    if neighbors == 2:
        if e and w:
            return "axis_a"
        if n and s:
            return "axis_b"
        # MAP25 has no verified corner tile; its scatter stone is the neutral
        # transition for an L-turn, so we do not pretend a crossroad exists.
        return "scatter"
    if neighbors == 1:
        return "branch"
    return "scatter"

func _terrain_texture_key(cell: Vector2i) -> String:
    if pve_landscape:
        return "env01_assets/terrain/stone_variant.png" if pve_bridge_at(cell) else ""
    if not STARTER.has_point(cell):
        return ""
    if COURTYARD_RECT.has_point(cell):
        if cell in COURTYARD_RUNE_CELLS:
            return "env01_assets/terrain/stone_runes.png"
        if cell.x == COURTYARD_RECT.position.x or cell.y == COURTYARD_RECT.position.y or cell.x == COURTYARD_RECT.end.x-1 or cell.y == COURTYARD_RECT.end.y-1:
            return "env01_assets/terrain/stone_border.png"
        return "env01_assets/terrain/stone_courtyard.png"
    if PRODUCTION_APRON_RECT.has_point(cell):
        return "env01_assets/terrain/stone_variant.png"
    return ""

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

static func exterior_door_cell(destination: StringName, instance_index: int = 1,
        saved_origin: Vector2i = SectResidenceSiteV1.UNSELECTED,
        layout_version: int = 0) -> Vector2i:
    var origin := saved_origin if saved_origin != SectResidenceSiteV1.UNSELECTED else producer_cell(destination,instance_index,layout_version)
    # The courtyard/gate are open ground, not enterable building interiors.
    return origin + EXTERIOR_DOOR_OFFSETS.get(str(destination), Vector2i.ZERO)

static func virtual_legacy_point(destination: StringName, building_id: StringName = &"",
        saved_origin: Vector2i = SectResidenceSiteV1.UNSELECTED,
        layout_version: int = 0) -> Vector2:
    var sequence := 1
    if building_id != &"":
        sequence = maxi(int(str(building_id).get_slice("_",str(building_id).get_slice_count("_")-1)),1)
    # Actual House coordinates are canonical BuildingState fields, not a
    # second world placement ledger. Display art/picking use same site.
    var entrance := exterior_door_cell(destination,sequence,saved_origin,layout_version)
    return LEGACY_ANCHOR+project(Vector2(entrance))-project(CENTER_CELL)

static func producer_cell(destination: StringName, instance_index: int,
        layout_version: int = 0) -> Vector2i:
    var key := str(destination)
    var anchors: Dictionary = TYPE_ANCHORS_NEW_GAME if layout_version == 2 else TYPE_ANCHORS
    var anchor: Vector2i = anchors.get(key,Vector2i(90,92))
    if instance_index <= 1 or not PRODUCER_DISTRICTS.has(key):
        return anchor
    var district: Dictionary = PRODUCER_DISTRICTS[key]
    var slot := instance_index - 2
    var columns := int(district["columns"])
    var column := slot % columns
    var row := int(slot / columns)
    var origin: Vector2i = district["origin"]
    return origin+Vector2i(column*int(district["column_step"]),row*int(district["row_step"]))

func refresh_from_state(state: SimulationState) -> void:
    if state == null:
        return
    map_layout_version = state.sect.world_layout_version
    variant_v3_running_ids.clear()
    # Read-only view of committed jobs; no writes, no mocked resource production.
    for raw_site_v3 in state.buildings.values():
        if not (raw_site_v3 is BuildingState):
            continue
        var site_v3: BuildingState = raw_site_v3
        if not V3_ART.supported(site_v3.building_type):
            continue
        if V3_ART.is_canonical_working(site_v3,state.tick):
            variant_v3_running_ids[str(site_v3.id)] = true
    house_reserved_tiles.clear()
    # Draw a paid construction site/House cleanly: decorative trees cannot
    # stand on the roof, footprint, or its exterior door interaction cell.
    for record in state.buildings.values():
        if not (record is BuildingState) or record.building_type != BuildingSystem.TYPE_RESIDENCE:
            continue
        var origin := SectResidenceSiteV1.origin_of(record)
        var footprint := Rect2i(origin,SectResidenceSiteV1.HOUSE_FOOTPRINT)
        for yy in range(footprint.position.y,footprint.end.y):
            for xx in range(footprint.position.x,footprint.end.x):
                house_reserved_tiles[Vector2i(xx,yy)] = true
        house_reserved_tiles[SectResidenceSiteV1.doorway(origin)] = true
    _refresh_residence_road_paths(state)
    var rows: Array[Dictionary] = []
    # One indexed pass over canonical buildings. Prior implementation scanned
    # the full state.buildings collection once for EACH producer destination.
    # 30 Mine + 30 Forest + 40 Field should not multiply lookup work.
    var producer_buckets: Dictionary = {}
    for raw_dest in PRODUCER_TYPES.keys():
        producer_buckets[str(PRODUCER_TYPES[raw_dest])] = []
    for raw_id in state.buildings.keys():
        var building: BuildingState = state.buildings[raw_id]
        var key := str(building.building_type)
        if producer_buckets.has(key):
            (producer_buckets[key] as Array).append(building)
    for key in producer_buckets.keys():
        (producer_buckets[key] as Array).sort_custom(
            func(a: BuildingState,b: BuildingState) -> bool:
                return str(a.id)<str(b.id))
    var anchors := anchors_for_layout(map_layout_version)
    for raw_dest in TYPE_ANCHORS.keys():
        var dest := StringName(raw_dest)
        if PRODUCER_TYPES.has(str(dest)):
            # Only actual canonical instances; exact old ordering preserved.
            var matching: Array = producer_buckets.get(str(PRODUCER_TYPES[str(dest)]),[])
            # Old P0/P3.7 fixture saves still draw their existing generic
            # Residence landmark; new live saves draw actual house IDs.
            if matching.is_empty() and dest in [SectMapPresentation.DEST_RESIDENCE, SectMapPresentation.DEST_MAIN_HALL]:
                rows.append(_row(dest,&"","Đệ Tử Xá" if dest == SectMapPresentation.DEST_RESIDENCE else "Đại Điện",1,false,SectResidenceSiteV1.UNSELECTED,map_layout_version))
            for building in matching:
                var live_label := str(building.display_name)
                if building.building_type == BuildingSystem.TYPE_RESIDENCE \
                        and building.status == BuildingSystem.STATUS_CONSTRUCTING:
                    live_label += " · đang xây"
                var owned_site: Vector2i = SectResidenceSiteV1.UNSELECTED
                if building.building_type == BuildingSystem.TYPE_RESIDENCE:
                    owned_site = SectResidenceSiteV1.origin_of(building)
                rows.append(_row(dest,building.id,live_label,building.instance_index,true,owned_site,map_layout_version))
        else:
            # A visual landmark/destination is NOT a BuildingState.
            rows.append(_row(dest,&"",str(dest).replace("_"," ").capitalize(),1,false,SectResidenceSiteV1.UNSELECTED,map_layout_version))
    rows.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var pa: Vector2 = a["world"]
        var pb: Vector2 = b["world"]
        return pa.y < pb.y)
    display_instances = rows
    fallback_art_count = maxi(0,rows.size()-_verified_house_art_count())
    pve_static_queue_dirty = true
    queue_redraw()

func _refresh_residence_road_paths(state: SimulationState) -> void:
    if pve_landscape or static_preview_roads.is_empty():
        return
    var houses := SectResidenceSystemV1.all_houses(state)
    var layout_parts: PackedStringArray = []
    for house in houses:
        layout_parts.append("%s:%d,%d" % [str(house.id),
            SectResidenceSiteV1.origin_of(house).x,SectResidenceSiteV1.origin_of(house).y])
    var layout_key := "|".join(layout_parts)
    if layout_key == residence_layout_signature:
        return
    residence_layout_signature = layout_key
    var roads := static_preview_roads.duplicate(true)
    var signature_rows: Array[String] = []
    for house in houses:
        var origin := SectResidenceSiteV1.origin_of(house)
        var path := SectResidenceSiteV1.path_to_door(state,origin,str(house.id))
        if path.is_empty():
            continue
        var path_parts: PackedStringArray = []
        for cell in path:
            roads[cell] = true
            path_parts.append("%d,%d" % [cell.x,cell.y])
        signature_rows.append("%s:%s:%s" % [str(house.id),str(origin),";".join(path_parts)])
    signature_rows.sort()
    var next_signature := "|".join(signature_rows)
    if next_signature == residence_road_signature:
        return
    residence_road_signature = next_signature
    if roads == preview_roads:
        return
    preview_roads = roads
    # Player construction/relocation is infrequent. Rebuild cached ground and
    # Source A road/vegetation overlays only when a doorway route really moves.
    ground_chunk_meshes.clear()
    _load_verified_source_art()

func _row(dest: StringName, instance_id: StringName, text_label: String, index: int,
        managed: bool, saved_origin: Vector2i = SectResidenceSiteV1.UNSELECTED,
        layout_version: int = 0) -> Dictionary:
    var cell: Vector2i = producer_cell(dest,index,layout_version) if managed else anchor_for(dest,layout_version)
    if saved_origin != SectResidenceSiteV1.UNSELECTED:
        cell = saved_origin
    return {
        "destination":dest,
        "building_id":instance_id,
        "world":project(visual_anchor(dest,cell)),
        "cell":cell,
        "managed":managed,
        "label":text_label,
        # Stable, display-only isometric camera view. No persisted rotation exists.
        "view_direction":"B" if managed and index % 2 == 0 else "A"
    }

func set_selected_visual_site(id: StringName) -> void:
    var next_id := str(id)
    if selected_visual_site_id == next_id:
        return
    selected_visual_site_id = next_id
    pve_static_queue_dirty = true
    queue_redraw()


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

func set_pve_camera(center_cell: Vector2, requested_zoom: float = 0.55) -> void:
    if camera == null:
        return
    camera.position = project(center_cell)
    camera.zoom = Vector2.ONE*clampf(requested_zoom,0.25,1.35)
    _update_chunks()

func pve_screen_to_cell(screen_point: Vector2, viewport_size: Vector2) -> Vector2:
    if camera == null:
        return Vector2.ZERO
    return inverse(camera.position+(screen_point-viewport_size*0.5)/camera.zoom.x)

func set_pve_snapshot(snapshot: MapBattleV2, view_rows: Dictionary,
        selected_actor_ids: Array[String], camp_positions: Array = []) -> void:
    pve_battle = snapshot
    pve_view_rows = view_rows.duplicate(true)
    pve_selected_actor_ids = selected_actor_ids.duplicate()
    if snapshot == null:
        _pve_last_visual_encounter_id = ""
        pve_target_positions.clear()
        pve_render_positions.clear()
        pve_actor_actions.clear()
        pve_jx_sword_vfx.observe_snapshot(null)
        queue_redraw()
        return
    if _pve_last_visual_encounter_id != snapshot.encounter_id:
        # Actor IDs can be reused across PvE runs. Do not interpolate or
        # continue a one-shot animation from the previous encounter.
        _pve_last_visual_encounter_id = snapshot.encounter_id
        pve_target_positions.clear()
        pve_render_positions.clear()
        pve_actor_actions.clear()
    var new_visual_events := pve_jx_sword_vfx.observe_snapshot(snapshot)
    var present: Dictionary = {}
    for raw_id in snapshot.actors:
        var id := str(raw_id)
        var actor: Dictionary = snapshot.actors[raw_id]
        present[id] = true
        var position: Vector2 = actor.get("position",Vector2.ZERO)
        pve_target_positions[id] = position
        if not pve_render_positions.has(id):
            pve_render_positions[id] = position
        if not pve_actor_actions.has(id):
            pve_actor_actions[id] = {"action":"idle","started":pve_clock,"until":-1.0}
        if float(actor.get("hp",0.0)) <= 0.0:
            # HUD snapshots arrive about four times a second. Resetting
            # `started` on every one pins a dead Source A rig to its first
            # frames forever; only enter the death action once.
            if str(pve_actor_actions[id].get("action","")) != "die":
                pve_actor_actions[id] = {"action":"die","started":pve_clock,"until":INF}
        elif str(pve_actor_actions[id].get("action","")) == "die":
            pve_actor_actions[id] = {"action":"idle","started":pve_clock,"until":-1.0}
    for id in pve_render_positions.keys().duplicate():
        if not present.has(str(id)):
            pve_render_positions.erase(id)
            pve_target_positions.erase(id)
            pve_actor_actions.erase(id)
    _apply_pve_actor_events(new_visual_events,snapshot)
    if not pve_camera_initialized and camera != null:
        for raw_id in snapshot.actors:
            var actor: Dictionary = snapshot.actors[raw_id]
            if str(actor.get("side","")) == "disciple":
                set_pve_camera(Vector2(actor.get("position",Vector2.ZERO)),0.55)
                pve_camera_initialized = true
                break
    queue_redraw()

func pve_minimap_texture() -> Texture2D:
    return pve_mini_texture

func consume_vfx_advance_metrics() -> Dictionary:
    var event_metrics: Dictionary = pve_jx_sword_vfx.consume_event_observation_metrics()
    var result := {
        "count":pve_vfx_advance_count,
        "total_usec":pve_vfx_advance_usec_total,
        "max_usec":pve_vfx_advance_usec_max,
        "event_rows_examined":int(event_metrics.get("rows_examined",0))
    }
    pve_vfx_advance_count = 0
    pve_vfx_advance_usec_total = 0
    pve_vfx_advance_usec_max = 0
    return result

func _process(delta: float) -> void:
    if not pve_landscape or pve_battle == null:
        return
    pve_clock += maxf(0.0,delta)
    var vfx_advance_started_usec := Time.get_ticks_usec() if pve_performance_logging_enabled else 0
    pve_jx_sword_vfx.advance(delta)
    if pve_performance_logging_enabled:
        var vfx_advance_elapsed_usec := Time.get_ticks_usec()-vfx_advance_started_usec
        pve_vfx_advance_count += 1
        pve_vfx_advance_usec_total += vfx_advance_elapsed_usec
        pve_vfx_advance_usec_max = maxi(pve_vfx_advance_usec_max,vfx_advance_elapsed_usec)
    for raw_id in pve_render_positions.keys():
        var id := str(raw_id)
        if pve_target_positions.has(id):
            var actor: Dictionary = pve_battle.actors.get(id,{})
            pve_render_positions[id] = (pve_render_positions[id] as Vector2).move_toward(
                pve_target_positions[id],maxf(0.1,float(actor.get("move_speed",3.0)))*delta)
    for raw_id in pve_actor_actions.keys():
        var id := str(raw_id)
        var actor: Dictionary = pve_battle.actors.get(id,{})
        var cue: Dictionary = pve_actor_actions[id]
        if float(actor.get("hp",0.0)) <= 0.0:
            cue["action"] = "die"
            cue["until"] = INF
        elif pve_clock > float(cue.get("until",-1.0)) and str(cue.get("action","")) in ["attack","cast","hit","run"]:
            var moving := (pve_render_positions.get(id,Vector2.ZERO) as Vector2).distance_to(
                pve_target_positions.get(id,Vector2.ZERO)) > 0.035
            cue["action"] = "run" if moving else "idle"
            cue["started"] = pve_clock
            cue["until"] = pve_clock+0.2 if moving else -1.0
        pve_actor_actions[id] = cue
    queue_redraw()


# VFX08 presentation-only animation tempo, derived from the same stats
# authority as MapBattleV2. Never changes the actual attack/cast clocks.
func _pve_visual_action_seconds(actor: Dictionary, skill_id: String = "") -> float:
    var stats: Dictionary = V63HumanSkillCombatSystem.effective_attack_stats(
        actor, actor.get("stats", {}))
    if not skill_id.is_empty():
        var definition: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
        var cast_seconds := float(definition.get("cast_time", 0.35))
        return clampf(cast_seconds / maxf(0.1, 1.0 + float(stats.get("cast_speed", 0.0))),
            0.10, 0.65)
    return clampf(0.29 / maxf(0.45, 1.0 + float(stats.get("attack_speed", 0.0))),
        0.10, 0.42)

func _apply_pve_actor_events(events: Array[Dictionary],snapshot: MapBattleV2) -> void:
    for event in events:
        var kind := str(event.get("type",""))
        var source_id := str(event.get("actor_id",event.get("attacker",event.get("caster",""))))
        var target_id := str(event.get("target",event.get("target_id","")))
        if kind == "move" and snapshot.actors.has(source_id):
            pve_actor_actions[source_id] = {"action":"run","started":pve_clock,"until":pve_clock+0.3}
        elif kind == "skill_cast" and snapshot.actors.has(source_id):
            var skill_id := str(event.get("skill_id", ""))
            var cast_window := _pve_visual_action_seconds(snapshot.actors[source_id], skill_id)
            pve_actor_actions[source_id] = {"action":"cast","started":pve_clock,"until":pve_clock+cast_window}
        elif kind == "hit":
            if str(event.get("kind","")) in ["basic","basic_followup"] and snapshot.actors.has(source_id):
                var attack_window := _pve_visual_action_seconds(snapshot.actors[source_id])
                pve_actor_actions[source_id] = {"action":"attack","started":pve_clock,"until":pve_clock+attack_window}
            # Basic damage and poison DoT leave the target's walk/cast/attack
            # alive. The already-authoritative VFX/HP-number can show contact.
        elif kind == "status_applied" and snapshot.actors.has(target_id) and \
                str(event.get("status","")) in ["stun","freeze","knockback","knock_up","stagger"]:
            pve_actor_actions[target_id] = {"action":"hit","started":pve_clock,"until":pve_clock+0.30}
        elif kind == "downed" and snapshot.actors.has(str(event.get("actor_id",""))):
            var downed_id := str(event.get("actor_id",""))
            pve_actor_actions[downed_id] = {"action":"die","started":pve_clock,"until":INF}

func _view_size() -> Vector2:
    if pve_landscape and is_inside_tree():
        var viewport := get_viewport()
        if viewport != null:
            return viewport.get_visible_rect().size
    return VIEW_SIZE


func _update_chunks() -> void:
    if camera == null:
        return
    var half_view := _view_size()*0.5/camera.zoom.x
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
    var chunks_changed := chunks != active_chunks
    var camera_changed := not pve_static_queue_has_view or not pve_static_queue_camera_position.is_equal_approx(camera.position) or not is_equal_approx(pve_static_queue_zoom,camera.zoom.x)
    if not chunks_changed and not camera_changed and not pve_static_queue_dirty:
        return
    if chunks_changed:
        active_chunks = chunks
    pve_static_queue_dirty = true
    draw_revision += 1
    queue_redraw()

func screen_to_world(screen: Vector2) -> Vector2:
    if camera == null:
        return Vector2.ZERO
    var local_view := screen if pve_landscape else screen-MAP_SCREEN_OFFSET
    return camera.position+(local_view-_view_size()*0.5)/camera.zoom.x

func pick_at_screen(screen: Vector2) -> Dictionary:
    var world := screen_to_world(screen)
    # Closest-frontmost manually authored 2.5D silhouette, not the saved
    # placement geometry. Selection dispatches canonical building instance id.
    var result: Dictionary = {}
    var best_distance := INF
    for item in display_instances:
        var place: Vector2 = item["world"]
        var offset := world-place
        # Match the smaller marker silhouette at wide zoom. The canonical
        # building ID/pick row always exists even when only an icon is drawn.
        var radius := SectEndgameVisualBudgetV1.pick_radius(
            camera.zoom.x,bool(item["managed"]))
        var roof_bias := 36.0 if not bool(item["managed"]) or camera.zoom.x >= SectEndgameVisualBudgetV1.COMPACT_SITE_ZOOM else 5.0
        var normalized := Vector2(offset.x/radius.x,(offset.y+roof_bias)/radius.y)
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
# Terrain and road art are immutable within the current view instance.
# Build source-SHA-gated textures, colors and projected rectangles once on
# startup, never during user camera pan/zoom/production progress repaint.
func _cache_static_overlays() -> void:
    terrain_overlays_by_chunk.clear()
    road_overlays_by_chunk.clear()
    var overlay_rect := Rect2i(Vector2i.ZERO,GRID) if pve_landscape else STARTER
    for iy in range(overlay_rect.position.y,overlay_rect.end.y):
        for ix in range(overlay_rect.position.x,overlay_rect.end.x):
            var cell := Vector2i(ix,iy)
            var chunk := Vector2i(ix/CHUNK,iy/CHUNK)
            var center := project(Vector2(cell))
            var terrain_key := _terrain_texture_key(cell)
            if not terrain_key.is_empty() and render_art.has(terrain_key):
                var tint := Color(0.96,0.98,0.94,0.48)
                if terrain_key.ends_with("stone_border.png"):
                    tint = Color(0.92,0.96,0.93,0.52)
                elif terrain_key.ends_with("stone_runes.png"):
                    tint = Color(0.94,0.97,1.0,0.58)
                elif terrain_key.ends_with("stone_variant.png"):
                    tint = Color(0.92,0.95,0.91,0.36)
                if not terrain_overlays_by_chunk.has(chunk):
                    terrain_overlays_by_chunk[chunk] = []
                (terrain_overlays_by_chunk[chunk] as Array).append({
                    "texture":render_art[terrain_key],
                    "rect":Rect2(center-Vector2(HALF_W,HALF_H),Vector2(HALF_W*2.0,HALF_H*2.0)),
                    "tint":tint
                })
            if not _is_road(cell):
                continue
            var road_key := "env01_assets/roads/%s" % str(ROAD_TEXTURES[_road_key(cell)])
            if not render_art.has(road_key):
                continue
            if not road_overlays_by_chunk.has(chunk):
                road_overlays_by_chunk[chunk] = []
            (road_overlays_by_chunk[chunk] as Array).append({
                "texture":render_art[road_key],
                "rect":Rect2(center-Vector2(HALF_W*1.1,HALF_H*1.15),
                    Vector2(HALF_W*2.2,HALF_H*2.3)),
                "shoulder":PackedVector2Array([
                    center+Vector2(0,-HALF_H*1.42),
                    center+Vector2(HALF_W*1.33,0),
                    center+Vector2(0,HALF_H*1.42),
                    center+Vector2(-HALF_W*1.33,0)
                ]),
                "shoulder_color":SectMapD2Landscape.road_shoulder_color(cell)
            })


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
            # Slow coherent terrain variation and district palettes replace
            # the old repeated checkerboard; this remains VIEW ONLY.
            var tone := _pve_ground_color(cell) if pve_landscape else SectMapD2Landscape.ground_color(cell,STARTER,preview_roads)
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

func _pve_ground_color(cell: Vector2i) -> Color:
    var slow := sin(float(cell.x)*0.18+float(cell.y)*0.11)*0.5
    slow += cos(float(cell.y)*0.16-float(cell.x)*0.09)*0.30
    var tint := clampf(slow*0.05,-0.05,0.05)
    var ground := Color(0.285+tint,0.405+tint,0.330+tint*0.7)
    if pve_path_cells.has(cell):
        ground = ground.blend(Color("877a54",0.55))
    if absf(float(cell.x)-pve_stream_center_x(float(cell.y))) < 5.5:
        ground = ground.blend(Color("365d57",0.50))
    return ground

func _draw() -> void:
    # Ground layer first: cached meshes remain valid for all camera positions.
    # Visibility still uses the original active_chunks and the existing camera.
    for chunk_id in active_chunks:
        draw_mesh(_ground_mesh_for_chunk(chunk_id),null)
    # Scenic water/reeds/rock-garden accents are original unapproved
    # view-only candidates and cannot act as a gameplay resource node.
    if pve_landscape:
        _draw_pve_stream()
    else:
        SectMapD2Landscape.draw_scenic_accents(self,active_chunks,camera.position,VIEW_SIZE*0.5/camera.zoom.x+Vector2(170,175))
    # Verified MAP25 terrain/road overlay source and connectivity were
    # classified once at import. Pan/zoom only iterates cached visible rows.
    for chunk_id in active_chunks:
        var terrain_rows: Array = terrain_overlays_by_chunk.get(chunk_id,[])
        for row in terrain_rows:
            draw_texture_rect(row["texture"],row["rect"],false,row["tint"])
    for chunk_id in active_chunks:
        var road_rows: Array = road_overlays_by_chunk.get(chunk_id,[])
        for row in road_rows:
            draw_colored_polygon(row["shoulder"],row["shoulder_color"])
            draw_texture_rect(row["texture"],row["rect"],false,
                Color(0.96,0.95,0.88,0.96))
    if pve_landscape:
        _ensure_pve_static_draw_queue()
        _draw_pve_actor_depth_merge()
        return
    # Sort all decorations with building art by actual projected ground depth.
    # One draw surface and one depth queue prevent large roofs from showing
    # behind trees which should occlude them.
    var queue: Array[Dictionary] = []
    for item in display_instances:
        if _visible_world(item["world"]):
            queue.append({"y":(item["world"] as Vector2).y,"kind":"building","data":item})
    for chunk_id in active_chunks:
        for item in decoration_items_by_chunk.get(chunk_id,[]):
            if not pve_landscape and house_reserved_tiles.has(item["cell"]):
                continue
            if _visible_world(item["world"]):
                queue.append({"y":(item["world"] as Vector2).y,"kind":"vegetation","data":item})
    if pve_landscape and pve_battle != null:
        for raw_id in pve_battle.actors:
            var id := str(raw_id)
            var actor: Dictionary = pve_battle.actors[raw_id]
            var cell: Vector2 = pve_render_positions.get(id,actor.get("position",Vector2.ZERO))
            var foot := project(cell)
            if _visible_world(foot):
                queue.append({"y":foot.y,"kind":"pve_actor","data":{"id":id,"actor":actor,"cell":cell}})
    # Preserve all canonical picking rows while limiting oversized temporary
    # SVG roofs to the focused worksite plus the nearest four view candidates.
    var site_candidates: Array[Dictionary] = []
    for entry in queue:
        if str(entry["kind"]) != "building":
            continue
        var item: Dictionary = entry["data"]
        if bool(item["managed"]) and MAP_D2_CANDIDATE_SITES.has(str(item["destination"])):
            site_candidates.append({
                "id":str(item["building_id"]),
                "center_distance":(item["world"] as Vector2).distance_squared_to(camera.position)
            })
    var detailed := SectEndgameVisualBudgetV1.choose_detailed_producers(
        site_candidates,camera.zoom.x,selected_visual_site_id)
    queue.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        return float(a["y"]) < float(b["y"])
    )
    for entry in queue:
        var item: Dictionary = entry["data"]
        if str(entry["kind"]) == "pve_actor":
            _draw_pve_actor(item)
            continue
        var place: Vector2 = item["world"]
        if str(entry["kind"]) == "vegetation":
            var tex: Texture2D = item["texture"]
            var scaled := tex.get_size()*float(item["scale"])
            draw_texture_rect(tex,Rect2(place-Vector2(scaled.x*0.5,
                scaled.y-4.0),scaled),false)
        else:
            _draw_building(place,str(item["destination"]),bool(item["managed"]),
                detailed.has(str(item["building_id"])),
                str(item["building_id"]),str(item.get("view_direction","A")))
    _draw_placement_preview()

func _ensure_pve_static_draw_queue() -> void:
    var camera_changed := not pve_static_queue_has_view or not pve_static_queue_camera_position.is_equal_approx(camera.position) or not is_equal_approx(pve_static_queue_zoom,camera.zoom.x)
    var chunks_changed := pve_static_queue_chunks != active_chunks
    var selection_changed := pve_static_queue_selected_site != selected_visual_site_id
    if not pve_static_queue_dirty and not camera_changed and not chunks_changed and not selection_changed:
        return
    var queue: Array[Dictionary] = []
    for item in display_instances:
        if _visible_world(item["world"]):
            queue.append({"y":(item["world"] as Vector2).y,"kind":"building","data":item})
    for chunk_id in active_chunks:
        for item in decoration_items_by_chunk.get(chunk_id,[]):
            if not pve_landscape and house_reserved_tiles.has(item["cell"]):
                continue
            if _visible_world(item["world"]):
                queue.append({"y":(item["world"] as Vector2).y,"kind":"vegetation","data":item})
    queue.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        return float(a["y"]) < float(b["y"])
    )
    var site_candidates: Array[Dictionary] = []
    for entry in queue:
        if str(entry["kind"]) != "building":
            continue
        var item: Dictionary = entry["data"]
        if bool(item["managed"]) and MAP_D2_CANDIDATE_SITES.has(str(item["destination"])):
            site_candidates.append({
                "id":str(item["building_id"]),
                "center_distance":(item["world"] as Vector2).distance_squared_to(camera.position)
            })
    pve_static_draw_queue = queue
    pve_detailed_site_ids = SectEndgameVisualBudgetV1.choose_detailed_producers(
        site_candidates,camera.zoom.x,selected_visual_site_id)
    pve_static_queue_camera_position = camera.position
    pve_static_queue_zoom = camera.zoom.x
    pve_static_queue_chunks = active_chunks.duplicate()
    pve_static_queue_selected_site = selected_visual_site_id
    pve_static_queue_has_view = true
    pve_static_queue_dirty = false


func _draw_pve_actor_depth_merge() -> void:
    var actors: Array[Dictionary] = []
    if pve_battle != null:
        for raw_id in pve_battle.actors:
            var id := str(raw_id)
            var actor: Dictionary = pve_battle.actors[raw_id]
            var cell: Vector2 = pve_render_positions.get(id,actor.get("position",Vector2.ZERO))
            var foot := project(cell)
            if _visible_world(foot):
                actors.append({"y":foot.y,"data":{"id":id,"actor":actor,"cell":cell}})
    actors.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        return float(a["y"]) < float(b["y"])
    )
    var static_index := 0
    var actor_index := 0
    while static_index < pve_static_draw_queue.size() or actor_index < actors.size():
        var draw_actor := actor_index < actors.size() and (
            static_index >= pve_static_draw_queue.size()
            or float(actors[actor_index]["y"]) < float(pve_static_draw_queue[static_index]["y"]))
        if draw_actor:
            _draw_pve_actor(actors[actor_index]["data"])
            actor_index += 1
        else:
            _draw_pve_static_item(pve_static_draw_queue[static_index])
            static_index += 1


func _draw_pve_static_item(entry: Dictionary) -> void:
    var item: Dictionary = entry["data"]
    if str(entry["kind"]) == "vegetation":
        var tex: Texture2D = item["texture"]
        var scaled := tex.get_size()*float(item["scale"])
        var place: Vector2 = item["world"]
        draw_texture_rect(tex,Rect2(place-Vector2(scaled.x*0.5,scaled.y-4.0),scaled),false)
    else:
        var place: Vector2 = item["world"]
        _draw_building(place,str(item["destination"]),bool(item["managed"]),
            pve_detailed_site_ids.has(str(item["building_id"])),
            str(item["building_id"]),str(item.get("view_direction","A")))


func _draw_pve_stream() -> void:
    var points := PackedVector2Array()
    for y in range(4,GRID.y,3):
        points.append(project(Vector2(pve_stream_center_x(float(y)),float(y))))
    if points.size() < 2:
        return
    draw_polyline(points,Color(0.39,0.49,0.39,0.97),64.0,true)
    draw_polyline(points,Color(0.22,0.53,0.57,0.98),36.0,true)
    draw_polyline(points,Color(0.70,0.86,0.80,0.60),2.4,true)

func selected_actor_ring_radius_screen(actor_id: String) -> float:
    if camera == null or pve_battle == null or not pve_selected_actor_ids.has(actor_id):
        return 0.0
    var actor: Dictionary = pve_battle.actors.get(actor_id,{})
    if actor.is_empty() or str(actor.get("side","")) != "disciple" or float(actor.get("hp",0.0)) <= 0.0:
        return 0.0
    var own_cell: Vector2 = pve_render_positions.get(actor_id,actor.get("position",Vector2.ZERO))
    var own_point := project(own_cell)
    var nearest_screen_distance := INF
    for other_value in pve_selected_actor_ids:
        var other_id := str(other_value)
        if other_id == actor_id:
            continue
        var other: Dictionary = pve_battle.actors.get(other_id,{})
        if other.is_empty() or str(other.get("side","")) != "disciple" or float(other.get("hp",0.0)) <= 0.0:
            continue
        var other_cell: Vector2 = pve_render_positions.get(other_id,other.get("position",Vector2.ZERO))
        nearest_screen_distance = minf(nearest_screen_distance,own_point.distance_to(project(other_cell))*camera.zoom.x)
    if is_inf(nearest_screen_distance):
        return 11.0
    # Reserve 4 px between ring edges plus 1.5 px stroke. Since the radius is
    # in screen pixels, crowding never makes selection circles touch at zoom.
    return clampf((nearest_screen_distance-5.5)*0.5,0.0,11.0)

func pve_actor_draw_scale() -> float:
    if camera == null:
        return 0.0
    # Zoom the world around the actors, but cap the Source A sprite's screen
    # footprint at the normal-zoom size. Otherwise zoom 1.35 enlarges the art
    # over neighboring combatants even though their authoritative foot points
    # and selection rings remain separated.
    return minf(camera.zoom.x*0.82,0.82)

func _draw_pve_actor(data: Dictionary) -> void:
    var id := str(data.get("id",""))
    var actor: Dictionary = data.get("actor",{})
    var cell: Vector2 = data.get("cell",Vector2.ZERO)
    var foot := project(cell)
    var side := str(actor.get("side",""))
    var alive := float(actor.get("hp",0.0)) > 0.0
    var visual: Dictionary = pve_actor_actions.get(id,{"action":"idle","started":pve_clock})
    var action := "die" if not alive else str(visual.get("action","idle"))
    if alive and pve_clock > float(visual.get("until",-1.0)):
        action = "run" if (pve_render_positions.get(id,cell) as Vector2).distance_to(cell) > 0.035 else "idle"
    if action == "cast" and pve_jx_sword_vfx.comparison_style == "jx1":
        action = "idle"
    var facing := Vector2.RIGHT
    if pve_target_positions.has(id) and pve_render_positions.has(id):
        facing = (pve_target_positions[id] as Vector2)-(pve_render_positions[id] as Vector2)
    if facing.length_squared() < 0.001:
        facing = Vector2.RIGHT if side == "disciple" else Vector2.LEFT
    var row: Dictionary = pve_view_rows.get(id,{})
    var actor_key := str(row.get("source_a_visual_key",""))
    var drawn := not actor_key.is_empty() and pve_source_atlas.has_actor(actor_key)
    if drawn:
        drawn = pve_source_atlas.draw_actor(self,actor_key,action,foot,facing,
            maxf(0.0,pve_clock-float(visual.get("started",pve_clock))),pve_actor_draw_scale())
    if not drawn:
        var shade := Color("73d6ad") if side == "disciple" else Color("dc9370")
        draw_colored_polygon(PackedVector2Array([foot+Vector2(0,-10),foot+Vector2(8,0),foot+Vector2(0,7),foot+Vector2(-8,0)]),shade)
    if side == "disciple" and pve_selected_actor_ids.has(id):
        var ring_radius_screen := selected_actor_ring_radius_screen(id)
        if ring_radius_screen > 0.0:
            draw_arc(foot,ring_radius_screen/camera.zoom.x,0.0,TAU,20,
                Color("ffe08a"),1.5/camera.zoom.x,true)
    # World-space HP/name anchors belong above the chibi head, not beneath
    # the feet (which obscured movement and made the fight look unfinished).
    # Camera2D already scales the Node2D drawing: do not multiply zoom twice.
    var bar_width := 44.0
    var hp_ratio := clampf(float(actor.get("hp",0.0))/maxf(1.0,float(actor.get("max_hp",1.0))),0.0,1.0)
    var bar_at := foot+Vector2(-bar_width*0.5,-82.0)
    draw_rect(Rect2(bar_at,Vector2(bar_width,5.0)),Color(0.04,0.07,0.05,0.9))
    if hp_ratio > 0.0:
        draw_rect(Rect2(bar_at,Vector2(bar_width*hp_ratio,5.0)),Color("85d884") if side == "disciple" else Color("e88372"))
    if side == "disciple" and pve_selected_actor_ids.size() == 1 and pve_selected_actor_ids.has(id):
        var font := ThemeDB.fallback_font
        if font != null:
            var name := str(row.get("display_name",id))
            draw_string_outline(font,foot+Vector2(-40.0,-93.0),name,HORIZONTAL_ALIGNMENT_LEFT,-1,10,2,Color(0.02,0.04,0.03,0.94))
            draw_string(font,foot+Vector2(-40.0,-93.0),name,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("f4f1dd"))


func _visible_world(point: Vector2) -> bool:
    if camera == null:
        return false
    var half := _view_size()*0.5/camera.zoom.x+Vector2(170,175)
    var delta := (point-camera.position).abs()
    return delta.x <= half.x and delta.y <= half.y

func _is_road(cell: Vector2i) -> bool:
    # Rebuildable read-only ENV-02A map-model route projection.
    var in_world := cell.x >= 0 and cell.y >= 0 and cell.x < GRID.x and cell.y < GRID.y
    if pve_landscape:
        return in_world and pve_bridge_at(cell) and preview_roads.has(cell)
    return STARTER.has_point(cell) and preview_roads.has(cell)

func _draw_placement_preview() -> void:
    if placement_preview.is_empty():
        return
    var origin: Vector2i = placement_preview.get("site",SectResidenceSiteV1.UNSELECTED)
    if origin == SectResidenceSiteV1.UNSELECTED:
        return
    var valid := bool(placement_preview.get("ok",false))
    var fill := Color(0.24,0.86,0.57,0.30) if valid else Color(0.96,0.24,0.22,0.30)
    var stroke := Color(0.39,1.0,0.69,0.92) if valid else Color(1.0,0.39,0.29,0.95)
    for y in range(SectResidenceSiteV1.HOUSE_FOOTPRINT.y):
        for x in range(SectResidenceSiteV1.HOUSE_FOOTPRINT.x):
            var center := project(Vector2(origin+Vector2i(x,y)))
            var tile := PackedVector2Array([
                center+Vector2(0,-HALF_H),center+Vector2(HALF_W,0),
                center+Vector2(0,HALF_H),center+Vector2(-HALF_W,0)
            ])
            draw_colored_polygon(tile,fill)
            draw_polyline(PackedVector2Array([tile[0],tile[1],tile[2],tile[3],tile[0]]),stroke,2.0,true)
    var door: Vector2i = SectResidenceSiteV1.doorway(origin)
    var door_center := project(Vector2(door))
    draw_circle(door_center,8.0,Color(0.25,0.80,1.0,0.95))
    draw_circle(door_center,3.0,Color(0.94,0.98,0.91,1.0))
    var art_key := str(HOUSE_TEXTURES["residence"])
    if render_art.has(art_key):
        var texture: Texture2D = render_art[art_key]
        var target: Vector2 = HOUSE_SIZES["residence"]
        var anchor := project(Vector2(origin))
        var tint := Color(0.75,1.0,0.82,0.50) if valid else Color(1.0,0.65,0.60,0.46)
        draw_texture_rect(texture,Rect2(anchor+Vector2(0,-target.y*0.28)-target*0.5,target),false,tint)

func _draw_compact_producer(p: Vector2,kind: String,overview: bool) -> void:
    # Clean compact symbols replace oversized repeated unapproved SVG roofs
    # at wide zoom. NOT a replacement Source A building master.
    # Camera projection and canonical selection/identity remain unchanged.
    var tint := Color(0.51,0.48,0.42)
    var detail := Color(0.85,0.78,0.60)
    match kind:
        "mine":
            tint = Color(0.37,0.44,0.46)
            detail = Color(0.82,0.80,0.65)
        "linh_forest":
            tint = Color(0.30,0.49,0.38)
            detail = Color(0.72,0.83,0.59)
        "spirit_field":
            tint = Color(0.46,0.55,0.36)
            detail = Color(0.91,0.84,0.53)
    var rx := 15.0 if overview else 20.0
    var ry := 8.0 if overview else 11.0
    var ring := PackedVector2Array([
        p+Vector2(0,-ry),p+Vector2(rx,0),
        p+Vector2(0,ry),p+Vector2(-rx,0)
    ])
    draw_colored_polygon(ring,tint)
    draw_polyline(PackedVector2Array([ring[0],ring[1],ring[2],ring[3],ring[0]]),detail,1.5,true)
    if kind == "mine":
        draw_line(p+Vector2(-7,2),p+Vector2(-1,-5),detail,2.0,true)
        draw_line(p+Vector2(-1,-5),p+Vector2(8,3),detail,2.0,true)
    elif kind == "linh_forest":
        draw_colored_polygon(PackedVector2Array([
            p+Vector2(-7,3),p+Vector2(-2,-6),p+Vector2(3,3)
        ]),detail)
        draw_line(p+Vector2(5,4),p+Vector2(5,-3),detail,2.0,true)
    else:
        for dx in [-7.0,0.0,7.0]:
            draw_line(p+Vector2(dx,3),p+Vector2(dx+2,-4),detail,1.5,true)


func _draw_building(p: Vector2,kind: String, managed: bool, allow_detail: bool = true,
        building_id: String = "", view_direction: String = "A") -> void:
    # Always keep all 100 actual producers in display_instances, but do NOT
    # paint 100 huge candidate buildings in a far overview. This is view LOD,
    # not reducing valid BuildingState instances or workers.
    if managed and (MAP_D2_CANDIDATE_SITES.has(kind) or V3_ART.supported(StringName(kind))):
        var level := SectEndgameVisualBudgetV1.site_level(camera.zoom.x)
        # Show authentic new architecture for each primary site and selected
        # instance even at normal zoom; distant extra sites keep cheap LOD.
        var v3_showcase := V3_ART.supported(StringName(kind)) and (
            (building_id.ends_with("_001") and camera.zoom.x >= 0.96)
            or (not building_id.is_empty() and building_id == selected_visual_site_id))
        if (level < 2 or not allow_detail) and not v3_showcase:
            _draw_compact_producer(p,kind,level == 0)
            return
    # Approved new architecture never overwrites the SHA-checked Source A originals.
    # Each sprite is a separate image: two real views, two real working states.
    if managed and V3_ART.supported(StringName(kind)):
        var is_working_v3 := bool(variant_v3_running_ids.get(building_id,false))
        var selected_v3 := V3_ART.sprite_path(StringName(kind),StringName(view_direction),is_working_v3)
        var image_v3 := variant_v3_textures.get(selected_v3) as Texture2D
        if image_v3 == null and is_working_v3:
            selected_v3 = V3_ART.sprite_path(StringName(kind),StringName(view_direction),false)
            image_v3 = variant_v3_textures.get(selected_v3) as Texture2D
        if image_v3 != null:
            var target_v3 := V3_ART.display_size(StringName(kind))
            draw_texture_rect(image_v3,
                Rect2(p + Vector2(0,-target_v3.y*0.28)-target_v3*0.5,target_v3),false)
            return
    if HOUSE_TEXTURES.has(kind):
        var key := str(HOUSE_TEXTURES[kind])
        if render_art.has(key):
            var image: Texture2D = render_art[key]
            var target: Vector2 = HOUSE_SIZES[kind]
            var offset := Vector2(0.0,-target.y*0.28)
            draw_texture_rect(image,Rect2(p+offset-target*0.5,target),false)
            return
    # New authored WORKSITE VIGNETTES, not approved building art; picking
    # and workload ownership remain the same canonical BuildingState row.
    # If the optional svg import fails, the existing explicit fallback shows.
    if managed and candidate_site_art.has(kind):
        var vignette: Texture2D = candidate_site_art[kind]
        var size: Vector2 = MAP_D2_SITE_SIZE[kind]
        draw_texture_rect(vignette,
            Rect2(p-Vector2(size.x*0.5,size.y*0.79),size),false)
        var candidate_font := ThemeDB.fallback_font
        if candidate_font != null:
            var label_text := "MỎ" if kind == "mine" else ("LINH LÂM" if kind == "linh_forest" else "LINH ĐIỀN")
            var width := candidate_font.get_string_size(label_text,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x
            var anchor := p+Vector2(-width*0.5,23)
            draw_string_outline(candidate_font,anchor,label_text,HORIZONTAL_ALIGNMENT_LEFT,-1,12,2,Color(0.16,0.25,0.20))
            draw_string(candidate_font,anchor,label_text,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(0.94,0.90,0.76))
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
