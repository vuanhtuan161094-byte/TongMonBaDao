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
const R2_GROUND: Texture2D = preload("res://art/onegame_world_r2/terrain_grain.svg")
const MAP01_MEADOW: Texture2D = preload("res://art/onegame_world_r2/map01_meadow.svg")
const MAP01_PAVING: Texture2D = preload("res://art/onegame_world_r2/map01_paving.svg")
const SECT_FLAGSTONE: Texture2D = preload("res://art/onegame_world_r2/map01_sect_flagstone.svg")
# Original visual candidates for existing navigable landmarks; no new buildings.
# Reuse actual raster illustrations from the coherent original VIS08 family.
# These are provisional visual roles, not newly authored or approved masters.
# The practice court uses actual stone terrain artwork, not a fake house.
const MAP01_LANDMARKS := {
    "cultivation":preload("res://art/tmb_original_buildings_v5/hall_original_1x.png"),
    "ren_than_duong":preload("res://art/source_a_env02a/env01_assets/terrain/stone_runes.png"),
    "medicine":preload("res://art/tmb_original_buildings_v5/residence_original_1x.png"),
    "gate":preload("res://art/tmb_original_buildings_v5/guidance_original_1x.png")
}
const MAP01_LANDMARK_SIZES := {
    "cultivation":Vector2(228,153),"ren_than_duong":Vector2(166,86),
    "medicine":Vector2(192,149),"gate":Vector2(166,185)
}
const R2_PRODUCER_APRON: Texture2D = preload("res://art/onegame_world_r2/producer_apron.svg")
const R2_BRIDGE: Texture2D = preload("res://art/onegame_world_r2/stone_bridge.svg")
const R2_COURT: Texture2D = preload("res://art/onegame_world_r2/jade_court.svg")
# Original scenic art only: these are not resource nodes, buildings or nav cells.
const R3_SCENERY := {
    "pine":preload("res://art/onegame_world_r2/pine_rock_grove.svg"),
    "garden":preload("res://art/onegame_world_r2/terraced_garden.svg"),
    "stockyard":preload("res://art/onegame_world_r2/producer_stockyard.svg")
}
const R3_SCENERY_CELLS := [
    {"cell":Vector2i(101,78),"art":"pine","scale":0.86},
    {"cell":Vector2i(109,82),"art":"pine","scale":0.88},
    {"cell":Vector2i(115,87),"art":"pine","scale":0.95},
    {"cell":Vector2i(114,96),"art":"stockyard","scale":0.75},
    {"cell":Vector2i(106,103),"art":"stockyard","scale":0.70},
    {"cell":Vector2i(100,105),"art":"garden","scale":0.82},
    {"cell":Vector2i(96,83),"art":"garden","scale":0.84},
    {"cell":Vector2i(79,79),"art":"pine","scale":0.92},
    {"cell":Vector2i(74,81),"art":"pine","scale":0.95},
    {"cell":Vector2i(76,110),"art":"garden","scale":0.85},
    {"cell":Vector2i(81,114),"art":"pine","scale":0.88},
    {"cell":Vector2i(116,105),"art":"pine","scale":0.92},
    {"cell":Vector2i(74,85),"art":"pine","scale":0.92},
    {"cell":Vector2i(77,75),"art":"pine","scale":0.9},
    {"cell":Vector2i(83,74),"art":"pine","scale":0.91},
    {"cell":Vector2i(97,75),"art":"pine","scale":0.92},
    {"cell":Vector2i(112,79),"art":"pine","scale":0.9},
    {"cell":Vector2i(117,82),"art":"pine","scale":0.94},
    {"cell":Vector2i(118,92),"art":"pine","scale":0.88},
    {"cell":Vector2i(118,100),"art":"pine","scale":0.9},
    {"cell":Vector2i(73,114),"art":"pine","scale":0.91},
    {"cell":Vector2i(79,118),"art":"pine","scale":0.9},
    {"cell":Vector2i(85,118),"art":"pine","scale":0.9}
]
const R2_PRODUCERS := {
    "mine":preload("res://art/onegame_world_r2/mine_compact.svg"),
    "linh_forest":preload("res://art/onegame_world_r2/forest_compact.svg"),
    "spirit_field":preload("res://art/onegame_world_r2/field_compact.svg")
}
const R2_FORMATION = preload("res://src/presentation/p3/pve_formation_atlas_v1.gd")
const R2_FACTORY = preload("res://src/presentation/p3/pve_factory_sprite_v1.gd")
const VIEW_SIZE := Vector2(1280,570)
const MAP_SCREEN_OFFSET := Vector2(0,72)
const LEGACY_ANCHOR := Vector2(768,354)
const CENTER_CELL := Vector2(90,92)
const NEW_GAME_FOCUS_CELL := Vector2(94,94)
const APPROVED_FOCUS_CELL := Vector2(96.2,94.8)
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
    "mine":"res://art/map_d2_candidate/mine_worksite_v1.svg",
    "linh_forest":"res://art/map_d2_candidate/linh_forest_worksite_v1.svg",
    "spirit_field":"res://art/map_d2_candidate/spirit_field_worksite_v1.svg"
}
const REIMAGINED_REVIEW_ONLY_SITES := {
    "alchemy_hall":"res://art/reimagined_source_a_v1/alchemy_hall_3q_v1.svg"
}
const V3_ART = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")
const VIS07_APPROVED = preload("res://src/presentation/p3/tmb_approved_building_art_v4.gd")
const VIS08_ORIGINAL_BUILDINGS = preload("res://src/presentation/p3/tmb_original_building_art_v5.gd")
const VIS09_HANDPAINT = preload("res://src/presentation/p3/tmb_handpaint_building_art_v6.gd")
const VIS10_B_DRAFT = preload("res://src/presentation/p3/tmb_rotation_b_candidate_v1.gd")
const VIS11_AB = preload("res://src/presentation/p3/tmb_building_art_ab_v7.gd")
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
const MAP01_PRODUCTION_PLAZA := preload("res://art/onegame_world_r2/map01_production_plaza.svg")
const PVE_JX_VFX_ADAPTER_SCRIPT := preload("res://src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd")
const A3_SWORD_VFX = preload("res://src/presentation/p3/pve_a3_sword_vfx.gd")
const V8_BLADE_VFX = preload("res://src/presentation/p3/pve_v8_blade_vfx.gd")
const V9_P2_SPELL_VFX = preload("res://src/presentation/p3/pve_v9_p2_spell_vfx.gd")

# Signs are presentation wayfinding, not constructed buildings, loot nodes or
# fake facilities. Coordinates follow the fixed V2 masterplan in SectResidenceSiteV1.
const MASTERPLAN_DISTRICT_SIGNS := [
    {"label":"ĐẠI ĐIỆN","detail":"Điều hành tông môn","cell":Vector2i(86,94),"tone":Color("dfb96f")},
    {"label":"NỘI VIỆN","detail":"Đệ tử · Y quán","cell":Vector2i(79,103),"tone":Color("9bc8a1")},
    {"label":"KHU TU LUYỆN","detail":"Tu vi · Rèn thân","cell":Vector2i(101,83),"tone":Color("86d6d8")},
    {"label":"KHU CHẾ TẠO","detail":"Kho · Luyện khí · Luyện đan","cell":Vector2i(90,108),"tone":Color("e2ad78")},
    {"label":"KHU TÀI NGUYÊN","detail":"Linh điền · Linh lâm · Mỏ","cell":Vector2i(108,94),"tone":Color("b6cf9b")},
    {"label":"SĂN YÊU · XUẤT CHINH","detail":"Cổng ra thế giới","cell":Vector2i(99,105),"tone":Color("e49c88")}
]
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
# PERF-WEB-01: keep static sect draw commands while camera moves within the
# pre-existing 170x175 world-visibility buffer. Camera2D still pans every
# frame, and picking uses the exact camera transform; only expensive reauthoring
# of ground/roads/depth-sorted decorations/buildings is rate-limited.
# PvE is deliberately excluded: its VFX and battle state redraw independently.
const SECT_REDRAW_WORLD_DISTANCE := 56.0
const SECT_REDRAW_ZOOM_DELTA := 0.025
var sect_draw_view_initialized := false
var sect_draw_view_position := Vector2.ZERO
var sect_draw_view_zoom := 1.0
# Chunk-local immutable ArrayMesh, cached in memory; purely visual, no save data.
var ground_chunk_meshes: Dictionary = {}
var sect_paving_meshes: Dictionary = {}
# View overlays are static once road topology and verified art are loaded.
# Build them once rather than rescanning all 16x16 cells on every draw.
var terrain_overlays_by_chunk: Dictionary = {}
var road_overlays_by_chunk: Dictionary = {}
var draw_revision := 0
var fallback_art_count := 0
var lab_geometry: SectIsoMapModelV1
var map_layout_version := 0
var placement_preview: Dictionary = {}
var masterplan_plots_visible := false
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
# VIS-10: transient rotation preview only. No persisted building direction
# exists in BuildingState; default remains approved A for all 5 houses + mine.
var vis10_b_preview_enabled := false
var vis10_preview_directions: Dictionary = {}
# VIS-07 original Mine asset state, used by bounded 1x LOD (no per-frame loads).
var vis07_mine_owner_art_loaded := false
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
# Transient rendering direction: maintain facing after movement or a cast/hit.
var pve_actor_facings: Dictionary = {}
# Presentation only: consume the same fresh receipt stream as the existing VFX.
var pve_damage_feedback: Array[Dictionary] = []
const PVE_FEEDBACK_LIMIT := 48
const PVE_FEEDBACK_LIFETIME := 0.85
const PVE_BASIC_CONTACT := preload("res://art/pve_v7/basic_contact_6cel.svg")
const PVE_BASIC_CONTACT_SECONDS := 0.24
const PVE_SCHOOL_CONTACT := {
    "spear":preload("res://art/pve_v8/spear_contact_6cel.svg"),
    "bow":preload("res://art/pve_v8/bow_contact_6cel.svg"),
    "palm":preload("res://art/pve_v8/palm_contact_6cel.svg"),
    "dual_blade":preload("res://art/pve_v8/dual_blade_contact_6cel.svg")
}
var pve_clock := 0.0
var _pve_last_visual_encounter_id := ""
var pve_source_atlas := CombatV5SourceAAtlas.new()
var pve_jx_sword_vfx = PVE_JX_VFX_ADAPTER_SCRIPT.new()
var pve_a3_sword_vfx = A3_SWORD_VFX.new()
var pve_r2_formation = R2_FORMATION.new()
var pve_r2_factory = R2_FACTORY.new()
var pve_v8_blade_vfx = V8_BLADE_VFX.new()
var pve_v9_p2_spell_vfx = V9_P2_SPELL_VFX.new()
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
    map_layout_version = version if version in [2,3,4] else 0

func anchors_for_layout(version: int = -1) -> Dictionary:
    var resolved := map_layout_version if version < 0 else version
    return SectResidenceSiteV1.map_anchors(resolved)

func anchor_for(destination: StringName, version: int = -1) -> Vector2i:
    return Vector2i(anchors_for_layout(version).get(str(destination),Vector2i(90,92)))

func set_placement_preview(preview: Dictionary) -> void:
    placement_preview = preview.duplicate(true)
    queue_redraw()

func set_masterplan_plots_visible(enabled: bool) -> void:
    masterplan_plots_visible = enabled
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
    var spawn := SectResidenceSiteV1.gate_for_layout(map_layout_version)
    var junction := SectResidenceSiteV1.junction_for_layout(map_layout_version)
    lab_geometry = SectIsoMapModelV1.new(GRID,spawn)
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
        {"id":"gate_to_courtyard","from":spawn,"to":junction},
        {"id":"courtyard_to_main_hall","from":junction,"to":hdoor},
        {"id":"courtyard_to_warehouse","from":junction,"to":sdoor},
        {"id":"courtyard_to_forge","from":junction,"to":fdoor},
        {"id":"courtyard_to_mine","from":junction,"to":anchors["mine"]+PRODUCER_ROUTE_APPROACH["mine"]},
        {"id":"courtyard_to_linh_forest","from":junction,"to":anchors["linh_forest"]+PRODUCER_ROUTE_APPROACH["linh_forest"]},
        {"id":"courtyard_to_spirit_field","from":junction,"to":anchors["spirit_field"]+PRODUCER_ROUTE_APPROACH["spirit_field"]},
        {"id":"courtyard_to_residence","from":junction,"to":anchors["residence"]},
        {"id":"courtyard_to_cultivation","from":junction,"to":anchors["cultivation"]}
    ]
    # The previous seed rebuilt a full 192x192 AStarGrid2D for each of
    # nine road routes, then three more times to recheck the doorways.
    # Keep ONE presentation-only navigation grid and update weights as each
    # road becomes available. This is equivalent to rebuilding from roads,
    # but avoids 11 redundant rebuilds and duplicate geometry traversal.
    var route_navigation: AStarGrid2D = lab_geometry._navigation()
    if map_layout_version >= 2:
        for kind in ["ren_than_duong","medicine","guidance","alchemy_hall"]:
            segments.append({"id":"courtyard_to_"+kind,"from":junction,"to":anchors[kind]+Vector2i(0,2)})
    for segment in segments:
        if not _record_preview_route(str(segment["id"]),segment["from"],segment["to"],route_navigation):
            lab_routes_ready = false
            push_warning("ISO_ENV02A_PREVIEW_ROUTE_FAILED %s %s -> %s" % [str(segment["id"]),str(segment["from"]),str(segment["to"])])
    for kind in ["main_hall","warehouse","forge"]:
        var placed: Dictionary = lab_geometry.get_building(kind)
        var door: Vector2i = lab_geometry.doorway(kind,placed["origin"],0)
        if route_navigation.is_point_solid(spawn) or route_navigation.is_point_solid(door) or route_navigation.get_id_path(spawn,door).is_empty():
            lab_routes_ready = false
    queue_redraw()

func _record_preview_route(route_id: String, from_cell: Vector2i, to_cell: Vector2i, shared_navigation: AStarGrid2D = null) -> bool:
    var bounds := SectResidenceSiteV1.construction_bounds(map_layout_version)
    if not bounds.has_point(from_cell) or not bounds.has_point(to_cell):
        return false
    # Optional argument retains the old independent route probe contract.
    var navigation: AStarGrid2D = shared_navigation if shared_navigation != null else lab_geometry._navigation()
    var route: Array[Vector2i] = navigation.get_id_path(from_cell,to_cell)
    if route.is_empty():
        return false
    for cell in route:
        if not bounds.has_point(cell) or lab_geometry.occupied(cell):
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
    vis07_mine_owner_art_loaded = false
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
    # VIS-11: six independent native A/B pairs, exactly extracted from
    # the owner's selected art sheet. Legacy assets are rollback only.
    var new_mine := VIS11_AB.texture_for(&"mine",&"A")
    if new_mine != null:
        candidate_site_art["mine"] = new_mine
        vis07_mine_owner_art_loaded = true
    else:
        var handpaint_mine := VIS09_HANDPAINT.texture_for(&"mine")
        if handpaint_mine != null:
            candidate_site_art["mine"] = handpaint_mine
            vis07_mine_owner_art_loaded = true
    for house in HOUSE_TEXTURES:
        var key := str(HOUSE_TEXTURES[house])
        var asset: Texture2D = VIS11_AB.texture_for(StringName(house),&"A")
        if asset == null:
            asset = VIS08_ORIGINAL_BUILDINGS.texture_for(StringName(house))
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
    var placement_rows: Array = pve_forest_layout() if pve_landscape else []
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
                if (tile-Vector2i(raw_anchor)).length_squared() <= 9:
                    marker_clear = false
                    break
            if not marker_clear or COURTYARD_RECT.has_point(tile):
                continue
        var art_id := str(item["id"])
        # Existing brightly colored crystal and floating spire sprites
        # belong to combat scenery, not the everyday sect production yard.
        if not pve_landscape and art_id in ["570073","570144","570399","570397"]:
            art_id = str(PVE_TREE_ASSETS[posmod(tile.x+tile.y,PVE_TREE_ASSETS.size())])
        var rel := "env01_assets/vegetation/%s.png" % art_id
        var vegetation := source_art.texture_for(rel)
        if pve_landscape:
            # The topology's density roll was also used as a species roll,
            # making every accepted prop a normal tree. Keep the exact saved
            # obstacle grid and choose a separate display-only species.
            var species_roll := posmod(tile.x*7919+tile.y*104729+tile.x*tile.y*31,100)
            var species: Array = PVE_TREE_ASSETS
            if species_roll >= 47 and species_roll < 74:
                species = PVE_BAMBOO_ASSETS
            elif species_roll >= 74 and species_roll < 86:
                species = PVE_ROCK_ASSETS
            elif species_roll >= 86 and species_roll < 94:
                species = PVE_RARE_AUTUMN_ASSETS
            elif species_roll >= 94:
                species = PVE_RARE_BLOSSOM_ASSETS
            var alternative := "env01_assets/vegetation/%s.png" % str(species[posmod(tile.x*31+tile.y*17,species.size())])
            var alternative_texture := source_art.texture_for(alternative)
            if alternative_texture != null:
                vegetation = alternative_texture
                rel = alternative
        if vegetation != null:
            render_art[rel] = vegetation
            var chunk := Vector2i(tile.x/CHUNK,tile.y/CHUNK)
            if not decoration_items_by_chunk.has(chunk):
                decoration_items_by_chunk[chunk] = []
            (decoration_items_by_chunk[chunk] as Array).append({
                "world":project(Vector2(tile)+(Vector2(0.5,0.5) if pve_landscape else Vector2.ZERO)),
                "texture":vegetation,
                "scale":float(item["scale"]) if pve_landscape else minf(0.35,float(item["scale"])*0.82),
                "cell":tile
            })
    if not pve_landscape:
        # MAP01: dense exterior woodland, never interior construction tiles.
        # Deterministic spacing keeps the silhouette coherent on every load.
        var forest_bounds := STARTER.grow(32)
        for y in range(forest_bounds.position.y,forest_bounds.end.y,2):
            for x in range(forest_bounds.position.x,forest_bounds.end.x,2):
                var tile := Vector2i(x,y)
                if not Rect2i(Vector2i.ZERO,GRID).has_point(tile):
                    continue
                var distance := sect_estate_distance(project(Vector2(tile)),map_layout_version)
                if distance < 48.0 or distance > 420.0:
                    continue
                var tree_point := project(Vector2(tile))
                var gate_point := project(Vector2(SectResidenceSiteV1.gate_for_layout(map_layout_version)))
                if map_layout_version >= SectResidenceSiteV1.ISOMETRIC_LAYOUT:
                    if tile.x >= 123 and absi(tile.y-86) <= 4:
                        continue
                elif map_layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT and tree_point.y > SECT_ESTATE_MID_Y+SECT_ESTATE_HALF_HEIGHT-25.0 and absf(tree_point.x-gate_point.x) < 145.0:
                    continue
                if posmod(x*17+y*31+x*y,7) == 0:
                    continue
                var tree_id := str(PVE_TREE_ASSETS[posmod(x*7+y*11,PVE_TREE_ASSETS.size())])
                var rel := "env01_assets/vegetation/%s.png" % tree_id
                var tree := source_art.texture_for(rel)
                if tree == null:
                    continue
                render_art[rel] = tree
                var chunk := Vector2i(tile.x/CHUNK,tile.y/CHUNK)
                if not decoration_items_by_chunk.has(chunk):
                    decoration_items_by_chunk[chunk] = []
                var jitter := Vector2(float(posmod(x*13+y*7,5)-2)*0.33,float(posmod(x*11+y*3,5)-2)*0.33)
                (decoration_items_by_chunk[chunk] as Array).append({
                    "world":project(Vector2(tile)+jitter),"texture":tree,
                    "scale":0.32+float(posmod(x*3+y*5,9))*0.035,"cell":tile
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
    var anchors: Dictionary = SectResidenceSiteV1.map_anchors(layout_version)
    var anchor: Vector2i = anchors.get(key,Vector2i(90,92))
    if instance_index <= 1 or not PRODUCER_DISTRICTS.has(key):
        return anchor
    if layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT and key in ["mine","linh_forest","spirit_field","alchemy_hall"]:
        # All live expanded producers use the same reserved production wing.
        # Slot rows remain separate from fixed landmarks; IDs never change.
        var slot_index := instance_index-2
        if layout_version >= SectResidenceSiteV1.ISOMETRIC_LAYOUT:
            match key:
                "spirit_field":
                    return Vector2i(96+2*(slot_index%13),76+2*int(slot_index/13))
                "linh_forest":
                    return Vector2i(94+2*(slot_index%15),69+2*int(slot_index/15))
                "mine":
                    return Vector2i(94+2*(slot_index%15),59+2*int(slot_index/15))
                "alchemy_hall":
                    return Vector2i(82+2*(slot_index%5),60+2*int(slot_index/5))
        var uv := Vector2.ZERO
        if key == "alchemy_hall":
            uv = Vector2(0.575+float(slot_index%10)*0.041,0.08+float(slot_index/10)*0.053)
        else:
            var band: int = ["spirit_field","linh_forest","mine"].find(key)
            uv = Vector2(0.55+float(band)*0.15+0.023+float(slot_index%4)*0.034,0.56+float(slot_index/4)*0.043)
        var point := SectResidenceSiteV1.estate_point(uv)
        var raw := inverse(point)
        return Vector2i(roundi(raw.x),roundi(raw.y))
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
    sect_paving_meshes.clear()
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

## VIS-10 editor/preview API. Never modifies BuildingState or SaveService.
## Candidates B intentionally require explicit preview; they are not owner
## visually approved and are not assumed to be camera-exact to A.
func set_visual_rotation_preview(building_id: StringName, direction: StringName) -> bool:
    var id := str(building_id)
    var view := str(direction).to_upper()
    if id.is_empty() or view not in ["A","B"]:
        return false
    var found := false
    for item in display_instances:
        if str(item.get("building_id","")) == id:
            found = true
            break
    if not found:
        return false
    vis10_preview_directions[id] = view
    vis10_b_preview_enabled = true
    pve_static_queue_dirty = true
    queue_redraw()
    return true

func clear_visual_rotation_preview() -> void:
    vis10_preview_directions.clear()
    vis10_b_preview_enabled = false
    pve_static_queue_dirty = true
    queue_redraw()

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
    var z := SectMapCamera.clamp_zoom(zoom)
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
        pve_actor_facings.clear()
        pve_jx_sword_vfx.observe_snapshot(null)
        pve_a3_sword_vfx.reset()
        pve_v8_blade_vfx.reset()
        pve_v9_p2_spell_vfx.reset()
        pve_r2_formation.reset()
        pve_r2_factory.reset()
        pve_damage_feedback.clear()
        queue_redraw()
        return
    if _pve_last_visual_encounter_id != snapshot.encounter_id:
        # Actor IDs can be reused across PvE runs. Do not interpolate or
        # continue a one-shot animation from the previous encounter.
        _pve_last_visual_encounter_id = snapshot.encounter_id
        pve_damage_feedback.clear()
        pve_target_positions.clear()
        pve_render_positions.clear()
        pve_actor_actions.clear()
        pve_actor_facings.clear()
    var new_visual_events := pve_jx_sword_vfx.observe_snapshot(snapshot)
    # A real enabled school actor is sufficient for its receipt-bound art.
    # Never enable combat/learning gates from presentation; explicit test
    # preview settings remain supported for isolated review.
    var sword_visual := bool(ProjectSettings.get_setting(A3_SWORD_VFX.PREVIEW_SETTING,false))
    var blade_visual := bool(ProjectSettings.get_setting(V8_BLADE_VFX.PREVIEW_SETTING,false))
    for raw_actor in snapshot.actors.values():
        if not (raw_actor is Dictionary) or not bool(raw_actor.get("v63_combat_enabled",false)):
            continue
        sword_visual = sword_visual or bool(raw_actor.get("v63_sword_combat_enabled",false))
        blade_visual = blade_visual or bool(raw_actor.get("v63_blade_combat_enabled",false))
    pve_a3_sword_vfx.observe(new_visual_events,snapshot,sword_visual)
    pve_v8_blade_vfx.observe(new_visual_events,snapshot,blade_visual)
    pve_v9_p2_spell_vfx.observe(new_visual_events,snapshot)
    pve_r2_formation.observe(new_visual_events,snapshot)
    pve_r2_factory.observe(new_visual_events,snapshot)
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
            pve_actor_facings.erase(id)
    _apply_pve_actor_events(new_visual_events,snapshot)
    _ingest_pve_damage_feedback(new_visual_events,snapshot)
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
    for index in range(pve_damage_feedback.size()-1,-1,-1):
        if pve_clock-float(pve_damage_feedback[index]["started"]) >= PVE_FEEDBACK_LIFETIME:
            pve_damage_feedback.remove_at(index)
    var vfx_advance_started_usec := Time.get_ticks_usec() if pve_performance_logging_enabled else 0
    pve_jx_sword_vfx.advance(delta)
    pve_a3_sword_vfx.advance(delta)
    pve_v8_blade_vfx.advance(delta)
    pve_v9_p2_spell_vfx.advance(delta)
    pve_r2_formation.advance(delta)
    pve_r2_factory.advance(delta)
    if pve_performance_logging_enabled:
        var vfx_advance_elapsed_usec := Time.get_ticks_usec()-vfx_advance_started_usec
        pve_vfx_advance_count += 1
        pve_vfx_advance_usec_total += vfx_advance_elapsed_usec
        pve_vfx_advance_usec_max = maxi(pve_vfx_advance_usec_max,vfx_advance_elapsed_usec)
    for raw_id in pve_render_positions.keys():
        var id := str(raw_id)
        if pve_target_positions.has(id):
            var actor: Dictionary = pve_battle.actors.get(id,{})
            var current: Vector2 = pve_render_positions[id]
            var destination: Vector2 = pve_target_positions[id]
            var visual_action := str((pve_actor_actions.get(id,{}) as Dictionary).get("action","idle"))
            if visual_action in ["idle","run"] and destination.distance_squared_to(current) > 0.001:
                pve_actor_facings[id] = destination-current
            pve_render_positions[id] = current.move_toward(
                destination,maxf(0.1,float(actor.get("move_speed",3.0)))*delta)
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
            var next_action := "run" if moving else "idle"
            if str(cue.get("action","")) != next_action:
                cue["started"] = pve_clock
            cue["action"] = next_action
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
        if snapshot.actors.has(source_id) and snapshot.actors.has(target_id) and kind in ["skill_cast","hit","skill_hit","basic_hit"]:
            var to_target: Vector2 = Vector2(snapshot.actors[target_id].get("position",Vector2.ZERO))-Vector2(snapshot.actors[source_id].get("position",Vector2.ZERO))
            if to_target.length_squared() > 0.001:
                pve_actor_facings[source_id] = to_target
        if kind == "move" and snapshot.actors.has(source_id):
            var current_cue: Dictionary = pve_actor_actions.get(source_id,{})
            if str(current_cue.get("action","idle")) in ["idle","run"] or pve_clock >= float(current_cue.get("until",-1.0)):
                if str(current_cue.get("action","")) != "run":
                    pve_actor_actions[source_id] = {"action":"run","started":pve_clock,"until":pve_clock+0.3}
                else:
                    current_cue["until"] = pve_clock+0.3
                    pve_actor_actions[source_id] = current_cue
        elif kind == "skill_cast" and snapshot.actors.has(source_id):
            var skill_id := str(event.get("skill_id", ""))
            var cast_window := _pve_visual_action_seconds(snapshot.actors[source_id], skill_id)
            pve_actor_actions[source_id] = {"action":"cast","started":pve_clock,"until":pve_clock+cast_window}
        elif kind == "hit":
            if str(event.get("kind","")) in ["basic","basic_followup"] and snapshot.actors.has(source_id):
                var attack_window := _pve_visual_action_seconds(snapshot.actors[source_id])
                pve_actor_actions[source_id] = {"action":"attack","started":pve_clock,"until":pve_clock+attack_window}
            # Basic hit/DoT do not interrupt the victim clip. A separate
            # receipt-driven contact sprite supplies the visible impact.
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
    if not pve_landscape:
        # _draw() culls static sect decorations with a 170px/175px buffer.
        # Reusing CanvasItem commands over short camera travel is safe within
        # that cushion; chunk transitions and significant zoom redraw at once.
        var sect_view_changed := not sect_draw_view_initialized
        if sect_draw_view_initialized:
            sect_view_changed = camera.position.distance_squared_to(
                sect_draw_view_position) >= SECT_REDRAW_WORLD_DISTANCE * SECT_REDRAW_WORLD_DISTANCE
            sect_view_changed = sect_view_changed or absf(
                camera.zoom.x-sect_draw_view_zoom) >= SECT_REDRAW_ZOOM_DELTA
        if not chunks_changed and not sect_view_changed:
            return
        if chunks_changed:
            active_chunks = chunks
        sect_draw_view_initialized = true
        sect_draw_view_position = camera.position
        sect_draw_view_zoom = camera.zoom.x
        draw_revision += 1
        queue_redraw()
        return
    # Battle world retains exact per-frame camera-dependent culling/VFX.
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
        if not pve_landscape and map_layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT:
            var art_scale := _map01_art_scale(str(item["destination"]),str(item["building_id"]))
            if art_scale > 1.0:
                radius = Vector2(maxf(radius.x,42.0*art_scale),maxf(radius.y,49.0*art_scale))
                roof_bias = 36.0
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
    var overlay_rect := Rect2i(Vector2i.ZERO,GRID) if pve_landscape else SectResidenceSiteV1.construction_bounds(map_layout_version)
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
                "center":center,
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
    var uvs := PackedVector2Array()
    var indices := PackedInt32Array()
    var origin := chunk_id*CHUNK
    var texture_center := project(Vector2(origin)+Vector2(CHUNK-1,CHUNK-1)*0.5)
    for iy in range(origin.y,mini(origin.y+CHUNK,GRID.y)):
        for ix in range(origin.x,mini(origin.x+CHUNK,GRID.x)):
            var cell := Vector2i(ix,iy)
            var center := project(Vector2(cell))
            # Slow coherent terrain variation and district palettes replace
            # the old repeated checkerboard; this remains VIEW ONLY.
            var tone := _pve_ground_color(cell) if pve_landscape else SectMapD2Landscape.ground_color(cell,STARTER,preview_roads,map_layout_version)
            var base := vertices.size()
            vertices.append_array(PackedVector2Array([
                center+Vector2(0,-HALF_H),center+Vector2(HALF_W,0),
                center+Vector2(0,HALF_H),center+Vector2(-HALF_W,0)
            ]))
            for corner in [Vector2(0,-HALF_H),Vector2(HALF_W,0),Vector2(0,HALF_H),Vector2(-HALF_W,0)]:
                var point: Vector2 = center+corner-texture_center
                uvs.append(Vector2(point.x/(CHUNK*HALF_W*2.0)+0.5,point.y/(CHUNK*HALF_H*2.0)+0.5))
            # Interpolate adjacent non-road material at corners to soften the
            # visible tile grid without changing routes or collision.
            if pve_landscape:
                for _vertex in range(4):
                    colors.append(tone)
            else:
                # A shared diamond corner has four identical cell samples
                # regardless of which tile owns it. Remove diagonal seams.
                for direction in [Vector2i(-1,-1),Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1)]:
                    var d: Vector2i = direction
                    var sum := tone
                    for offset in [Vector2i(d.x,0),Vector2i(0,d.y),d]:
                        var near_cell: Vector2i = cell+offset
                        sum += SectMapD2Landscape.ground_color(near_cell,STARTER,preview_roads,map_layout_version)
                    colors.append(sum*0.25)
            indices.append_array(PackedInt32Array([
                base,base+1,base+2,base,base+2,base+3
            ]))
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_COLOR] = colors
    arrays[Mesh.ARRAY_TEX_UV] = uvs
    arrays[Mesh.ARRAY_INDEX] = indices
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(
        Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_2D_VERTICES
    )
    ground_chunk_meshes[chunk_id] = mesh
    return mesh

# Presentation boundary only. The saved 48x48 buildable grid remains intact.
# Horizontal top/bottom, gently sloping sides, full coverage of all saved lots.
const SECT_ESTATE_MID_Y := SectResidenceSiteV1.ESTATE_CENTER.y
const SECT_ESTATE_MID_X := SectResidenceSiteV1.ESTATE_CENTER.x
const SECT_ESTATE_HALF_WIDTH := SectResidenceSiteV1.ESTATE_HALF_WIDTH
const SECT_ESTATE_HALF_HEIGHT := SectResidenceSiteV1.ESTATE_HALF_HEIGHT
const SECT_ESTATE_SHEAR := SectResidenceSiteV1.ESTATE_SHEAR

static func sect_paving_cell(cell: Vector2i) -> bool:
    return STARTER.has_point(cell)

static func sect_estate_distance(point: Vector2,version: int = SectResidenceSiteV1.APPROVED_LAYOUT) -> float:
    if version >= SectResidenceSiteV1.ISOMETRIC_LAYOUT:
        var uv := SectResidenceSiteV1.estate_uv(point,version)
        return maxf(absf(uv.x-0.5)-0.5,absf(uv.y-0.5)-0.5)*1350.0
    var dy := point.y-SECT_ESTATE_MID_Y
    var dx := point.x-SECT_ESTATE_MID_X-dy*SECT_ESTATE_SHEAR
    return maxf(absf(dx)-SECT_ESTATE_HALF_WIDTH,absf(dy)-SECT_ESTATE_HALF_HEIGHT)

# Clip each isometric stone to the straight perimeter, rather than rounding
# the outline to whole diamonds. UVs are calculated from its original tile.
static func _clip_estate_plane(poly: PackedVector2Array,normal: Vector2,limit: float) -> PackedVector2Array:
    var result := PackedVector2Array()
    if poly.is_empty():
        return result
    var previous := poly[poly.size()-1]
    var prev_dist := normal.dot(previous)-limit
    for current in poly:
        var dist := normal.dot(current)-limit
        if (dist <= 0.0) != (prev_dist <= 0.0):
            result.append(previous.lerp(current,prev_dist/(prev_dist-dist)))
        if dist <= 0.0:
            result.append(current)
        previous = current
        prev_dist = dist
    return result

static func _clip_estate_tile(poly: PackedVector2Array,version: int = SectResidenceSiteV1.APPROVED_LAYOUT) -> PackedVector2Array:
    if version >= SectResidenceSiteV1.ISOMETRIC_LAYOUT:
        # x/y cell half-planes, exactly aligned to 25:13 terrain projection.
        var nx := Vector2(1.0/50.0,1.0/26.0)
        var ny := Vector2(-1.0/50.0,1.0/26.0)
        poly = _clip_estate_plane(poly,nx,126.0)
        poly = _clip_estate_plane(poly,-nx,-70.0)
        poly = _clip_estate_plane(poly,ny,112.0)
        return _clip_estate_plane(poly,-ny,-56.0)
    poly = _clip_estate_plane(poly,Vector2(0,1),SECT_ESTATE_MID_Y+SECT_ESTATE_HALF_HEIGHT)
    poly = _clip_estate_plane(poly,Vector2(0,-1),-SECT_ESTATE_MID_Y+SECT_ESTATE_HALF_HEIGHT)
    poly = _clip_estate_plane(poly,Vector2(1,-SECT_ESTATE_SHEAR),SECT_ESTATE_HALF_WIDTH+SECT_ESTATE_MID_X-SECT_ESTATE_SHEAR*SECT_ESTATE_MID_Y)
    return _clip_estate_plane(poly,Vector2(-1,SECT_ESTATE_SHEAR),SECT_ESTATE_HALF_WIDTH-SECT_ESTATE_MID_X+SECT_ESTATE_SHEAR*SECT_ESTATE_MID_Y)

func _sect_paving_mesh(chunk_id: Vector2i) -> ArrayMesh:
    if sect_paving_meshes.has(chunk_id):
        return sect_paving_meshes[chunk_id] as ArrayMesh
    var vertices := PackedVector2Array()
    var colors := PackedColorArray()
    var uvs := PackedVector2Array()
    var indices := PackedInt32Array()
    var origin := chunk_id*CHUNK
    for y in range(origin.y,mini(origin.y+CHUNK,GRID.y)):
        for x in range(origin.x,mini(origin.x+CHUNK,GRID.x)):
            var cell := Vector2i(x,y)
            var center := project(Vector2(cell))
            if sect_estate_distance(center,map_layout_version) > 40.0:
                continue
            var points := PackedVector2Array([
                center+Vector2(0,-HALF_H),center+Vector2(HALF_W,0),
                center+Vector2(0,HALF_H),center+Vector2(-HALF_W,0)
            ])
            if sect_estate_distance(center,map_layout_version) > -40.0:
                points = _clip_estate_tile(points,map_layout_version)
            if points.size() < 3:
                continue
            var base := vertices.size()
            var tint := 0.96+float(posmod(x*17+y*23+x*y,7))*0.005
            var tone := Color(tint,tint,tint,1.0)
            if map_layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT:
                match SectResidenceSiteV1.estate_zone(center,map_layout_version):
                    "residence": tone *= Color(0.97,0.99,0.97)
                    "production": tone *= Color(1.0,0.98,0.94)
                    "hall": tone *= Color(1.0,1.0,0.97)
                    "cultivation": tone *= Color(0.96,0.99,1.0)
                    "court": tone *= Color(0.99,0.99,0.98)
            for point in points:
                vertices.append(point)
                uvs.append(Vector2(0.5+(point.x-center.x)/(2.0*HALF_W),0.5+(point.y-center.y)/(2.0*HALF_H)))
                colors.append(tone)
            for index in range(1,points.size()-1):
                indices.append_array(PackedInt32Array([base,base+index,base+index+1]))
    var mesh := ArrayMesh.new()
    if not vertices.is_empty():
        var arrays := []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = vertices
        arrays[Mesh.ARRAY_COLOR] = colors
        arrays[Mesh.ARRAY_TEX_UV] = uvs
        arrays[Mesh.ARRAY_INDEX] = indices
        mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_2D_VERTICES)
    sect_paving_meshes[chunk_id] = mesh
    return mesh

# Architectural low wall, not a new collision boundary. Stone base and
# continuous dark jade roof, with repeated masonry joints and posts.
func _draw_wall_span(a: Vector2,b: Vector2) -> void:
    var span := b-a
    var length := span.length()
    if length < 1.0:
        return
    var n := Vector2(0,-22)
    draw_colored_polygon(PackedVector2Array([a,b,b+n,a+n]),Color("878579"))
    draw_line(a,b,Color("6c6b60"),3.0,true)
    draw_line(a+n,b+n,Color("d0c6ac"),3.0,true)
    draw_line(a+n+Vector2(0,-4),b+n+Vector2(0,-4),Color("3c5752"),9.0,true)
    draw_line(a+n+Vector2(0,-8),b+n+Vector2(0,-8),Color("63796d"),2.0,true)
    var count := maxi(1,ceili(length/100.0))
    for index in range(count+1):
        var foot := a.lerp(b,float(index)/float(count))
        draw_rect(Rect2(foot+Vector2(-5,-27),Vector2(10,28)),Color("9a9583"))
        draw_rect(Rect2(foot+Vector2(-7,-30),Vector2(14,5)),Color("485e54"))

func _draw_sect_estate_border() -> void:
    if map_layout_version >= SectResidenceSiteV1.ISOMETRIC_LAYOUT:
        var tl := _map01_estate_point(Vector2(0,0))
        var tr := _map01_estate_point(Vector2(1,0))
        var br := _map01_estate_point(Vector2(1,1))
        var bl := _map01_estate_point(Vector2(0,1))
        _draw_wall_span(tl,tr)
        _draw_wall_span(tr,br)
        _draw_wall_span(tl,bl)
        # Opening along actual x-axis forward approach (constant grid Y).
        _draw_wall_span(bl,_map01_estate_point(Vector2(0.39,1)))
        _draw_wall_span(_map01_estate_point(Vector2(0.54,1)),br)
        return
    var top := SECT_ESTATE_MID_Y-SECT_ESTATE_HALF_HEIGHT
    var bottom := SECT_ESTATE_MID_Y+SECT_ESTATE_HALF_HEIGHT
    var offset := SECT_ESTATE_HALF_HEIGHT*SECT_ESTATE_SHEAR
    var w := SECT_ESTATE_HALF_WIDTH
    var tl := Vector2(SECT_ESTATE_MID_X-w-offset,top)
    var tr := Vector2(SECT_ESTATE_MID_X+w-offset,top)
    var br := Vector2(SECT_ESTATE_MID_X+w+offset,bottom)
    var bl := Vector2(SECT_ESTATE_MID_X-w+offset,bottom)
    _draw_wall_span(tl,tr)
    _draw_wall_span(tl,bl)
    _draw_wall_span(tr,br)
    # The southern wall has a clear ceremonial opening aligned with the gate.
    var gate_x := project(Vector2(SectResidenceSiteV1.gate_for_layout(map_layout_version))).x
    _draw_wall_span(bl,Vector2(gate_x-110,bottom))
    _draw_wall_span(Vector2(gate_x+110,bottom),br)

# Architectural inlays mark the two future expansion wings without
# drawing empty construction slots in everyday play.
# Courtyard composition: architecture, paved commons and reserved wings.
# Static cached ground texture stays separate from real instance depth queue.
# All decoration is flat and traversable, so no build capacity is consumed.
func _map01_estate_point(uv: Vector2) -> Vector2:
    return SectResidenceSiteV1.estate_point(uv,map_layout_version)

func _map01_ground_quad(uv_a: Vector2,uv_b: Vector2,tint: Color) -> void:
    var points := PackedVector2Array([
        _map01_estate_point(uv_a),
        _map01_estate_point(Vector2(uv_b.x,uv_a.y)),
        _map01_estate_point(uv_b),
        _map01_estate_point(Vector2(uv_a.x,uv_b.y))])
    draw_colored_polygon(points,tint)

func _map01_court_frame(a: Vector2,b: Vector2,tone: Color) -> void:
    _map01_ground_quad(a,b,tone)
    var outline := PackedVector2Array([
        _map01_estate_point(a),
        _map01_estate_point(Vector2(b.x,a.y)),
        _map01_estate_point(b),
        _map01_estate_point(Vector2(a.x,b.y)),
        _map01_estate_point(a)])
    draw_polyline(outline,Color(0.47,0.48,0.42,0.48),5.0,true)
    var inset := Vector2(0.006,0.012)
    var inside_a := a+inset
    var inside_b := b-inset
    var inner := PackedVector2Array([
        _map01_estate_point(inside_a),
        _map01_estate_point(Vector2(inside_b.x,inside_a.y)),
        _map01_estate_point(inside_b),
        _map01_estate_point(Vector2(inside_a.x,inside_b.y)),
        _map01_estate_point(inside_a)])
    draw_polyline(inner,Color(0.92,0.87,0.72,0.72),3.0,true)

func _draw_approved_district_inlays() -> void:
    # Broad finished courtyards and a common transverse promenade rather than
    # one uniform slab. The rectangles designate whole district courts,
    # not empty building slots or fabricated production.
    _map01_court_frame(Vector2(0.024,0.05),Vector2(0.283,0.43),Color(0.75,0.79,0.71,0.22))
    _map01_court_frame(Vector2(0.024,0.51),Vector2(0.283,0.94),Color(0.69,0.76,0.69,0.23))
    _map01_court_frame(Vector2(0.316,0.045),Vector2(0.535,0.35),Color(0.91,0.81,0.64,0.29))
    _map01_court_frame(Vector2(0.316,0.40),Vector2(0.535,0.69),Color(0.69,0.78,0.75,0.28))
    _map01_court_frame(Vector2(0.568,0.05),Vector2(0.976,0.43),Color(0.86,0.78,0.62,0.26))
    _map01_court_frame(Vector2(0.568,0.51),Vector2(0.976,0.94),Color(0.80,0.74,0.59,0.24))
    _map01_ground_quad(Vector2(0.024,0.443),Vector2(0.976,0.494),Color(0.91,0.85,0.73,0.54))
    # Use SHA-checked original road/terrain art already in the game. Keep
    # all underlying surfaces paved and retain actual route endpoints.
    for chunk_id in active_chunks:
        for row in road_overlays_by_chunk.get(chunk_id,[]):
            var center: Vector2 = row["center"]
            if sect_estate_distance(center,map_layout_version) > -20.0:
                continue
            draw_texture_rect(row["texture"],row["rect"],false,Color(0.95,0.94,0.87,0.60))
    # Stone detailing at court corners using existing game texture.
    var marker: Texture2D = render_art.get("env01_assets/terrain/stone_runes.png") as Texture2D
    if marker != null:
        for uv in [Vector2(0.04,0.07),Vector2(0.266,0.07),Vector2(0.04,0.92),Vector2(0.266,0.92),
                Vector2(0.588,0.07),Vector2(0.957,0.07),Vector2(0.588,0.92),Vector2(0.957,0.92)]:
            var point := _map01_estate_point(Vector2(uv))
            draw_texture_rect(marker,Rect2(point-Vector2(30,16),Vector2(60,32)),false,Color(0.95,0.94,0.87,0.75))

func _draw_map01_platform(p: Vector2,extent: Vector2,tone: Color) -> void:
    # Inlaid stone directly below an actual landmark, not a separate shadow.
    var r := extent*0.5
    var corners := PackedVector2Array([p+Vector2(-r.x,-r.y),p+Vector2(r.x,-r.y),
        p+Vector2(r.x+12,r.y),p+Vector2(-r.x+12,r.y)])
    draw_colored_polygon(corners,tone)
    corners.append(corners[0])
    draw_polyline(corners,Color("b7a98c"),2.0,true)

func _draw_sect_civic_axis() -> void:
    if map_layout_version < 2:
        return
    var hall := project(visual_anchor(&"main_hall",anchor_for(&"main_hall")))
    var gate := project(Vector2(SectResidenceSiteV1.gate_for_layout(map_layout_version)))
    if map_layout_version >= SectResidenceSiteV1.ISOMETRIC_LAYOUT:
        # The path follows the same 26-27 degree axis as the stairs/roofs.
        # All four corners are projected grid coordinates, never screen rectangles.
        var a := project(Vector2(83,83))
        var b := project(Vector2(134,83))
        var c := project(Vector2(134,89))
        var d := project(Vector2(83,89))
        var axis := PackedVector2Array([a,b,c,d])
        draw_colored_polygon(axis,Color(0.82,0.79,0.68,0.52))
        axis.append(a)
        draw_polyline(axis,Color("aa9b7c"),3.0,true)
        var court := project(Vector2(SectResidenceSiteV1.junction_for_layout(map_layout_version)))
        var extent := Vector2(250,130)
        draw_texture_rect(R2_COURT,Rect2(court-extent*0.5,extent),false)
        return
    var center_x := (hall.x+gate.x)*0.5
    var top := hall.y+42.0
    var bottom := gate.y-32.0
    if bottom <= top:
        return
    # Distinct ceremonial stone path, warm border and an engraved jade court.
    draw_rect(Rect2(center_x-73,top,146,bottom-top),Color(0.78,0.75,0.66,0.42))
    for side in [-1.0,1.0]:
        var x: float = center_x+float(side)*73.0
        draw_line(Vector2(x,top),Vector2(x,bottom),Color("a99b7e"),3.0,true)
        draw_line(Vector2(x+float(side)*5.0,top),Vector2(x+float(side)*5.0,bottom),Color("d5c5a3"),2.0,true)
    var court := project(Vector2(ROADS_JUNCTION))
    var court_size := Vector2(230,120)
    draw_texture_rect(R2_COURT,Rect2(court-court_size*0.5,court_size),false,Color(1.0,1.0,1.0,0.83))
    if map_layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT:
        _draw_map01_platform(hall+Vector2(0,5),Vector2(305,92),Color(0.73,0.70,0.62,0.45))
        _draw_map01_platform(gate+Vector2(0,4),Vector2(215,70),Color(0.73,0.70,0.62,0.45))
        # Connect the real gate to the opening through the exterior woodland.
        var edge := SECT_ESTATE_MID_Y+SECT_ESTATE_HALF_HEIGHT
        var walk_top := gate.y+6.0
        draw_rect(Rect2(gate.x-76,walk_top,152,edge+150.0-walk_top),Color("b7ae97"))
        for side in [-1.0,1.0]:
            var edge_x: float = gate.x+float(side)*76.0
            draw_line(Vector2(edge_x,walk_top),Vector2(edge_x,edge+150.0),Color("8f8c7c"),3.0,true)

func _pve_ground_color(cell: Vector2i) -> Color:
    var slow := sin(float(cell.x)*0.18+float(cell.y)*0.11)*0.5
    slow += cos(float(cell.y)*0.16-float(cell.x)*0.09)*0.30
    var tint := clampf(slow*0.05,-0.05,0.05)
    var ground := Color(0.335+tint,0.46+tint,0.345+tint*0.7)
    var biome := sin(float(cell.x)*0.044+float(cell.y)*0.033)+cos(float(cell.y)*0.049-float(cell.x)*0.021)
    if biome > 0.55:
        ground = ground.lerp(Color(0.47,0.50,0.32),clampf((biome-0.55)*0.40,0.0,0.5))
    elif biome < -0.35:
        ground = ground.lerp(Color(0.25,0.42,0.36),clampf((-biome-0.35)*0.40,0.0,0.5))
    if pve_path_cells.has(cell):
        ground = ground.blend(Color("ad986d",0.65))
    if absf(float(cell.x)-pve_stream_center_x(float(cell.y))) < 5.5:
        ground = ground.blend(Color("52746a",0.50))
    return ground

# Small diegetic district labels, on the real isometric surface. They never
# intercept a tap, block the verified artwork, or affect the AStar road graph.
func _draw_masterplan_lots() -> void:
    if not masterplan_plots_visible or map_layout_version < 2 or pve_landscape:
        return
    var font := ThemeDB.fallback_font
    var lots := SectResidenceSiteV1.annex_sites(map_layout_version)
    for index in range(lots.size()):
        var origin: Vector2i = lots[index]
        if origin == Vector2i(placement_preview.get("site",SectResidenceSiteV1.UNSELECTED)):
            continue
        var occupied := false
        for y in range(SectResidenceSiteV1.HOUSE_FOOTPRINT.y):
            for x in range(SectResidenceSiteV1.HOUSE_FOOTPRINT.x):
                occupied = occupied or house_reserved_tiles.has(origin+Vector2i(x,y))
        if occupied:
            continue
        var center := project(Vector2(origin)+Vector2(1,1))
        if not _visible_world(center):
            continue
        var points := PackedVector2Array([center+Vector2(0,-HALF_H*3),center+Vector2(HALF_W*3,0),center+Vector2(0,HALF_H*3),center+Vector2(-HALF_W*3,0)])
        draw_colored_polygon(points,Color(0.85,0.72,0.39,0.12))
        var closed := points.duplicate()
        closed.append(points[0])
        draw_polyline(closed,Color(0.96,0.81,0.52,0.78),2.0,true)
        if font != null:
            draw_string(font,center+Vector2(-30,4),"LÔ %02d" % (index+1),HORIZONTAL_ALIGNMENT_CENTER,60,12,Color(1.0,0.91,0.68))

func _draw_masterplan_district_signs() -> void:
    if map_layout_version < 2 or pve_landscape or masterplan_plots_visible:
        return
    var font := ThemeDB.fallback_font
    if font == null:
        return
    # Small, legible wayfinding plaques in open ground. Their screen size
    # stays stable as the camera zooms; they never consume pointer events.
    # At overview show restrained section titles only; close-up uses
    # architecture and the existing district navigation. No floating cards.
    if map_layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT:
        if camera.zoom.x > 0.62:
            return
        var titles := [
            ["ĐỆ TỬ XÁ",Vector2(0.13,0.24)],
            ["ĐẠI ĐIỆN",Vector2(0.425,0.075)],
            ["SẢN XUẤT",Vector2(0.775,0.075)],
            ["TU LUYỆN",Vector2(0.425,0.47)],
            ["SƠN MÔN",Vector2(0.425,0.94)]]
        for row in titles:
            var at := _map01_estate_point(Vector2(row[1]))
            var title := str(row[0])
            var width := font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x
            draw_set_transform(at,0.0,Vector2.ONE/maxf(camera.zoom.x,0.25))
            draw_string_outline(font,Vector2(-width*0.5,0),title,HORIZONTAL_ALIGNMENT_LEFT,-1,14,2,Color(0.84,0.81,0.73,0.92))
            draw_string(font,Vector2(-width*0.5,0),title,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("414b42"))
            draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
        return

func _draw() -> void:
    # Ground layer first: cached meshes remain valid for all camera positions.
    # Visibility still uses the original active_chunks and the existing camera.
    for chunk_id in active_chunks:
        draw_mesh(_ground_mesh_for_chunk(chunk_id),R2_GROUND if pve_landscape else MAP01_MEADOW)
    if not pve_landscape:
        # Unified paved estate. Roads are still used by the simulation and
        # construction checks, but are no longer painted as separate strips.
        for chunk_id in active_chunks:
            var paving := _sect_paving_mesh(chunk_id)
            if paving.get_surface_count() > 0:
                draw_mesh(paving,SECT_FLAGSTONE)
        _draw_sect_estate_border()
        if map_layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT:
            _draw_approved_district_inlays()
        _draw_sect_civic_axis()
    else:
        _draw_pve_stream()
        for chunk_id in active_chunks:
            for row in terrain_overlays_by_chunk.get(chunk_id,[]):
                draw_texture_rect(row["texture"],row["rect"],false,row["tint"])
        for chunk_id in active_chunks:
            for row in road_overlays_by_chunk.get(chunk_id,[]):
                draw_colored_polygon(row["shoulder"],row["shoulder_color"])
                draw_texture_rect(row["texture"],row["rect"],false,Color(0.96,0.95,0.88,0.96))
    if pve_landscape:
        # Render a real crossing at each existing navigation bridge, below
        # characters; the illustration never creates a walkable cell.
        for bridge_y in PVE_BRIDGE_ROWS:
            var bridge_center := project(Vector2(roundf(pve_stream_center_x(float(bridge_y))),float(bridge_y)))
            if _visible_world(bridge_center):
                var bridge_extent := Vector2(326,183)
                draw_texture_rect(R2_BRIDGE,Rect2(bridge_center-Vector2(163,95),bridge_extent),false)
        _ensure_pve_static_draw_queue()
        _draw_pve_actor_depth_merge()
        pve_a3_sword_vfx.draw_on(self,pve_render_positions,Callable(self,"_a3_project"),1.0)
        pve_v8_blade_vfx.draw_on(self,pve_render_positions,Callable(self,"_a3_project"),1.0)
        pve_v9_p2_spell_vfx.draw_on(self,pve_render_positions,Callable(self,"_a3_project"))
        pve_r2_formation.draw_on(self,pve_render_positions,Callable(self,"_a3_project"))
        pve_r2_factory.draw_on(self,pve_render_positions,Callable(self,"_a3_project"))
        _draw_pve_damage_feedback()
        return
    _draw_masterplan_lots()
    # District navigation already names each area. Avoid duplicate labels
    # obscuring the roof silhouettes; the building captions are sufficient.
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
            # Remove disconnected miniature polygon shadows; retain sprite bases.
            draw_texture_rect(tex,Rect2(place-Vector2(scaled.x*0.5,
                scaled.y-4.0),scaled),false)
        else:
            _draw_building(place,str(item["destination"]),bool(item["managed"]),
                detailed.has(str(item["building_id"])),
                str(item["building_id"]),str(item.get("view_direction","A")))
    _draw_masterplan_district_signs()
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
    draw_polyline(points,Color(0.25,0.37,0.31,0.92),72.0,true)
    draw_polyline(points,Color(0.63,0.63,0.44,0.96),61.0,true)
    draw_polyline(points,Color(0.16,0.41,0.44,0.99),46.0,true)
    draw_polyline(points,Color(0.31,0.63,0.62,0.85),29.0,true)
    # Broken current highlights follow the real river instead of a single
    # artificial bright centerline. Navigation and bridges are unchanged.
    for i in range(1,points.size()-1,3):
        var direction := (points[i+1]-points[i-1]).normalized()
        var normal := direction.orthogonal()
        var p := points[i]+normal*float((i%5-2)*4)
        draw_line(p-direction*8,p+direction*9,Color(0.78,0.90,0.82,0.48),1.7,true)
        draw_line(p-direction*4+normal*6,p+direction*6+normal*6,Color(0.58,0.82,0.76,0.32),1.1,true)

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

func _a3_project(cell: Vector2) -> Vector2:
    return project(cell)

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
        action = "run" if (pve_target_positions.get(id,cell) as Vector2).distance_to(cell) > 0.035 else "idle"
    # AS-CHAR has a real cast clip; the legacy JX comparison must not hide it.
    if action == "cast" and pve_jx_sword_vfx.comparison_style == "jx1" and not (pve_view_rows.get(id,{}) as Dictionary).has("aschar_school"):
        action = "idle"
    var facing: Vector2 = pve_actor_facings.get(id,
        Vector2.RIGHT if side == "disciple" else Vector2.LEFT)
    if action in ["idle","run"] and pve_target_positions.has(id) and pve_render_positions.has(id):
        var movement: Vector2 = (pve_target_positions[id] as Vector2)-(pve_render_positions[id] as Vector2)
        if movement.length_squared() > 0.001:
            facing = movement
    if facing.length_squared() < 0.001:
        facing = Vector2.RIGHT if side == "disciple" else Vector2.LEFT
    var row: Dictionary = pve_view_rows.get(id,{})
    var age := maxf(0.0,pve_clock-float(visual.get("started",pve_clock)))
    # Real PvE now prioritizes the saved 12-school/24-sex AS-CHAR identity.
    # This is a visual adapter only; all battle events still come from MapBattleV2.
    var drawn := false
    if side == "disciple" and row.has("aschar_school"):
        drawn = PveASCharFrameRendererV1.draw_actor(self,
            str(row.get("aschar_school","")),str(row.get("aschar_sex","male")),
            action,foot,project(facing),age,0.22,maxf(0.0,float(visual.get("until",pve_clock))-float(visual.get("started",pve_clock))))
    # Source A remains available for monsters/Bosses, never for disciples.
    if not drawn and side != "disciple":
        var actor_key := str(row.get("source_a_visual_key",""))
        drawn = not actor_key.is_empty() and pve_source_atlas.has_actor(actor_key)
        if drawn:
            drawn = pve_source_atlas.draw_actor(self,actor_key,action,foot,facing,
                age,pve_actor_draw_scale())
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
    var tier := str(actor.get("tier","normal"))
    var bar_width := 56.0 if tier == "boss" else 44.0
    var hp_ratio := clampf(float(actor.get("hp",0.0))/maxf(1.0,float(actor.get("max_hp",1.0))),0.0,1.0)
    var bar_at := foot+Vector2(-bar_width*0.5,-82.0)
    # Readable 30-hunter view: hide full-health ordinary monster bars and dead bars.
    if alive and (side == "disciple" or tier in ["boss","elite"] or hp_ratio < 0.999):
        draw_rect(Rect2(bar_at,Vector2(bar_width,5.0)),Color(0.04,0.07,0.05,0.9))
        draw_rect(Rect2(bar_at,Vector2(bar_width*hp_ratio,5.0)),Color("85d884") if side == "disciple" else Color("e88372"))
        if tier == "boss":
            draw_rect(Rect2(bar_at-Vector2(1,1),Vector2(bar_width+2,7)),Color("e7bb72"),false,1.0)
    # Persistent guard/poison cues are driven only by the live actor status.
    # Keep distant ordinary mobs uncluttered; approved spell sprites still
    # own the cast/release/contact phases.
    if alive and (camera.zoom.x >= 0.55 or pve_selected_actor_ids.has(id) or tier == "boss"):
        var statuses: Dictionary = actor.get("status_effects",{})
        var poisoned := false
        for stack in statuses.get("v63_poison",[]):
            if stack is Dictionary and float(stack.get("expires_at",0.0)) > pve_battle.now:
                poisoned = true
                break
        if poisoned:
            draw_arc(foot+Vector2(0,3),15.0,0.0,TAU,24,Color(0.66,0.87,0.30,0.75),1.6,true)
        if float(actor.get("learned_guard_until",-1.0)) > pve_battle.now:
            draw_arc(foot+Vector2(0,3),20.0,0.0,TAU,24,Color(0.43,0.83,0.98,0.78),1.6,true)
    if side == "disciple" and pve_selected_actor_ids.size() == 1 and pve_selected_actor_ids.has(id):
        var font := ThemeDB.fallback_font
        if font != null:
            var name := str(row.get("display_name",id))
            draw_string_outline(font,foot+Vector2(-40.0,-93.0),name,HORIZONTAL_ALIGNMENT_LEFT,-1,10,2,Color(0.02,0.04,0.03,0.94))
            draw_string(font,foot+Vector2(-40.0,-93.0),name,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("f4f1dd"))


# One label per real authoritative hit/heal, never per derived skill_hit/pilot_impact.
func _ingest_pve_damage_feedback(events: Array[Dictionary], snapshot: MapBattleV2) -> void:
    for event in events:
        var kind := str(event.get("type",""))
        if kind not in ["hit","heal","pilot_hot_tick","pilot_poison_tick"]:
            continue
        var target := str(event.get("target",""))
        if not snapshot.actors.has(target):
            continue
        var healing := kind in ["heal","pilot_hot_tick"]
        var amount := float(event.get("amount",0.0)) if healing else float(event.get("damage",0.0))
        if amount <= 0.0 or is_nan(amount) or is_inf(amount):
            continue
        var critical := not healing and bool(event.get("critical",false))
        var poison := kind == "pilot_poison_tick" or str(event.get("kind","")) == "dot"
        var tint := Color("8df5a1") if healing else (Color("ffe093") if critical else (Color("c3e586") if poison else Color("fff1d2")))
        var label := ("+" if healing else ("BẠO " if critical else "−")) + ("%.0f" % amount if amount >= 1.0 else "%.1f" % amount)
        var origin: Vector2 = pve_render_positions.get(target,snapshot.actors[target].get("position",Vector2.ZERO))
        var lane := 0
        for item in pve_damage_feedback:
            if str(item.get("target","")) == target:
                lane += 1
        if pve_damage_feedback.size() >= PVE_FEEDBACK_LIMIT:
            pve_damage_feedback.pop_front()
        var source := str(event.get("attacker",""))
        var basic_contact := kind == "hit" and str(event.get("kind","")) in ["basic","basic_followup"] and snapshot.actors.has(source)
        var angle := 0.0
        var contact_school := ""
        if basic_contact:
            if str(snapshot.actors[source].get("side","")) == "disciple":
                contact_school = str((pve_view_rows.get(source,{}) as Dictionary).get("aschar_school",""))
            var from: Vector2 = pve_render_positions.get(source,snapshot.actors[source].get("position",Vector2.ZERO))
            var heading := project(origin)-project(from)
            if heading.length_squared() > 0.001:
                angle = heading.angle() if contact_school in PVE_SCHOOL_CONTACT else heading.angle()+PI*0.25
        pve_damage_feedback.append({"target":target,"origin":origin,"started":pve_clock,"label":label,"color":tint,"lane":lane%3,"basic_contact":basic_contact,"angle":angle,"contact_school":contact_school})

func _draw_pve_damage_feedback() -> void:
    var font := ThemeDB.fallback_font
    if font == null or camera == null:
        return
    for item in pve_damage_feedback:
        var foot := project(item["origin"])
        if not _visible_world(foot):
            continue
        var elapsed := pve_clock-float(item["started"])
        if bool(item.get("basic_contact",false)) and elapsed < PVE_BASIC_CONTACT_SECONDS:
            var frame := clampi(int(elapsed/PVE_BASIC_CONTACT_SECONDS*6.0),0,5)
            var region := Rect2(Vector2(frame%3,floori(float(frame)/3.0))*128.0,Vector2(128,128))
            var extent := Vector2(94,94)
            draw_set_transform(foot+Vector2(0,-40),float(item.get("angle",0.0)))
            var atlas: Texture2D = PVE_SCHOOL_CONTACT.get(str(item.get("contact_school","")),PVE_BASIC_CONTACT)
            draw_texture_rect_region(atlas,Rect2(-extent*0.5,extent),region)
            draw_set_transform(Vector2.ZERO)
        var age := clampf(elapsed/PVE_FEEDBACK_LIFETIME,0.0,1.0)
        var opacity := 1.0-smoothstep(0.55,1.0,age)
        var color: Color = item["color"]
        color.a = opacity
        var at := foot+Vector2((float(item["lane"])-1.0)*24.0,-100.0-age*36.0)
        var label := str(item["label"])
        draw_string_outline(font,at-Vector2(48,0),label,HORIZONTAL_ALIGNMENT_CENTER,96,17,3,Color(0.03,0.035,0.02,opacity))
        draw_string(font,at-Vector2(48,0),label,HORIZONTAL_ALIGNMENT_CENTER,96,17,color)

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
    return SectResidenceSiteV1.construction_bounds(map_layout_version).has_point(cell) and preview_roads.has(cell)

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
    # At working zoom use the authored site vignette rather than a flat icon.
    # Far-overview remains bounded by the original lightweight LOD.
    if R2_PRODUCERS.has(kind):
        var miniature: Texture2D = R2_PRODUCERS[kind]
        var extent := Vector2(72.0,54.0) if overview else Vector2(108.0,81.0)
        draw_texture_rect(miniature,Rect2(p-Vector2(extent.x*0.5,extent.y*0.78),extent),false)
        return
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


func _map01_art_scale(kind: String,building_id: String = "") -> float:
    if pve_landscape or map_layout_version < SectResidenceSiteV1.APPROVED_LAYOUT:
        return 1.0
    if kind == "main_hall":
        return 1.60
    if kind == "gate":
        return 1.37
    if kind in ["cultivation","ren_than_duong","medicine"]:
        return 1.22
    if kind == "residence":
        return 1.33 if building_id.ends_with("_001") else 1.08
    if kind in ["guidance","warehouse","forge"]:
        return 1.28
    return 1.18 if building_id.ends_with("_001") else 1.0

func _draw_building(p: Vector2,kind: String, managed: bool, allow_detail: bool = true,
        building_id: String = "", view_direction: String = "A") -> void:
    var chosen_view := view_direction
    if vis10_b_preview_enabled and vis10_preview_directions.has(building_id):
        chosen_view = str(vis10_preview_directions[building_id])
    # Always keep all 100 actual producers in display_instances, but do NOT
    # paint 100 huge candidate buildings in a far overview. This is view LOD,
    # not reducing valid BuildingState instances or workers.
    if managed and (MAP_D2_CANDIDATE_SITES.has(kind) or V3_ART.supported(StringName(kind))):
        if map_layout_version >= SectResidenceSiteV1.APPROVED_LAYOUT and not pve_landscape and not building_id.ends_with("_001") and building_id != selected_visual_site_id:
            _draw_compact_producer(p,kind,true)
            return
        var level := SectEndgameVisualBudgetV1.site_level(camera.zoom.x)
        # Show authentic new architecture for each primary site and selected
        # instance even at normal zoom; distant extra sites keep cheap LOD.
        var v3_showcase := V3_ART.supported(StringName(kind)) and (
            (building_id.ends_with("_001") and (not pve_landscape or camera.zoom.x >= 0.65))
            or (not building_id.is_empty() and building_id == selected_visual_site_id))
        # One genuine Owner-approved Mine landmark remains visible at default
        # map zoom; other 99 possible sites retain cheap LOD unless selected.
        var owner_mine_showcase := kind == "mine" and vis07_mine_owner_art_loaded and (
            (building_id.ends_with("_001") and (not pve_landscape or camera.zoom.x >= 0.65))
            or (not building_id.is_empty() and building_id == selected_visual_site_id))
        var primary_worksite := building_id.ends_with("_001") and (not pve_landscape or camera.zoom.x >= 0.65) and candidate_site_art.has(kind)
        if (level < 2 or not allow_detail) and not v3_showcase and not owner_mine_showcase and not primary_worksite:
            _draw_compact_producer(p,kind,level == 0)
            return
    # Approved new architecture never overwrites the SHA-checked Source A originals.
    # Each sprite is a separate image: two real views, two real working states.
    if managed and V3_ART.supported(StringName(kind)):
        var is_working_v3 := bool(variant_v3_running_ids.get(building_id,false))
        var selected_v3 := V3_ART.sprite_path(StringName(kind),StringName(chosen_view),is_working_v3)
        var image_v3 := variant_v3_textures.get(selected_v3) as Texture2D
        if image_v3 == null and is_working_v3:
            selected_v3 = V3_ART.sprite_path(StringName(kind),StringName(chosen_view),false)
            image_v3 = variant_v3_textures.get(selected_v3) as Texture2D
        if image_v3 != null:
            var target_v3 := V3_ART.display_size(StringName(kind))*_map01_art_scale(kind,building_id)
            draw_texture_rect(image_v3,
                Rect2(p + Vector2(0,-target_v3.y*0.28)-target_v3*0.5,target_v3),false)
            return
    if HOUSE_TEXTURES.has(kind):
        var key := str(HOUSE_TEXTURES[kind])
        if render_art.has(key):
            var image: Texture2D = render_art[key]
            # Real A/B art (not horizontal flip), selected only for this
            # visual instance. Gameplay/footprints remain unchanged.
            var new_house := VIS11_AB.texture_for(StringName(kind),StringName(chosen_view))
            if new_house != null:
                image = new_house
            var target: Vector2 = HOUSE_SIZES[kind]*_map01_art_scale(kind,building_id)
            var offset := Vector2(0.0,-target.y*0.28)
            draw_texture_rect(image,Rect2(p+offset-target*0.5,target),false)
            return
    # New authored WORKSITE VIGNETTES, not approved building art; picking
    # and workload ownership remain the same canonical BuildingState row.
    # If the optional svg import fails, the existing explicit fallback shows.
    if managed and candidate_site_art.has(kind):
        var vignette: Texture2D = candidate_site_art[kind]
        if kind == "mine":
            var new_mine_view := VIS11_AB.texture_for(&"mine",StringName(chosen_view))
            if new_mine_view != null:
                vignette = new_mine_view
        var size: Vector2 = MAP_D2_SITE_SIZE[kind]*_map01_art_scale(kind,building_id)
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
    if not pve_landscape and MAP01_LANDMARKS.has(kind):
        var art: Texture2D = MAP01_LANDMARKS[kind]
        var size: Vector2 = MAP01_LANDMARK_SIZES[kind]*_map01_art_scale(kind,building_id)
        if kind == "ren_than_duong":
            # Open training court: actual pavement texture in a small tiled
            # yard, readable as a functional outdoor landmark at overview.
            var tile_size := Vector2(86.0,45.0)
            for iy in range(-1,2):
                for ix in range(-1,2):
                    var center := p+Vector2(float(ix-iy)*43.0,float(ix+iy)*22.5)
                    draw_texture_rect(art,Rect2(center-tile_size*0.5,tile_size),false)
        else:
            draw_texture_rect(art,Rect2(p-Vector2(size.x*0.5,size.y*0.79),size),false)
        var captions := {"cultivation":"TU LUYỆN","ren_than_duong":"RÈN THÂN","medicine":"Y QUÁN","gate":"CỔNG TÔNG MÔN"}
        var caption := str(captions[kind])
        var font := ThemeDB.fallback_font
        if font != null and (kind == "ren_than_duong" or map_layout_version < SectResidenceSiteV1.APPROVED_LAYOUT or camera.zoom.x > 0.62):
            var width := font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x
            var baseline := p+Vector2(-width*0.5,24)
            draw_string_outline(font,baseline,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,13,3,Color(0.08,0.15,0.12,0.94))
            draw_string(font,baseline,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f6e8b8"))
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
