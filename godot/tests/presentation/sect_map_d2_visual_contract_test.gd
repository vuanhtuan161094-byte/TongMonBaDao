extends SceneTree

# MAP-D2 direct integration: original optional worksite artwork must NOT
# mutate the existing Source A SHA gate or any canonical producer state.
const SCENE_PATH := "res://scenes/p3/p3_2_landscape_sect.tscn"
const SAVE_PATH := "user://sect_map_d2_visual_contract_test.json"
const SITE_TYPES := ["mine","linh_forest","spirit_field"]


func _init() -> void:
    call_deferred("_run")


func _run() -> void:
    for suffix in ["",".tmp",".bak"]:
        var file: String = SAVE_PATH+suffix
        if FileAccess.file_exists(file):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load(SCENE_PATH) as PackedScene
    if packed == null:
        _fail("P3.2 scene is unavailable")
        return
    var scene := packed.instantiate() as Control
    root.add_child(scene)
    await process_frame
    var state := scene.get("state") as SimulationState
    var iso := scene.find_child("SectIsoWorld192",true,false) as SectIsometricWorldV1
    if state == null or iso == null or not bool(scene.get("runtime_ready")):
        _fail("canonical P3.2 state or isometric view missing")
        return
    var canonical_before := state.to_dict().duplicate(true)
    if iso.GRID != Vector2i(192,192) or iso.CHUNK != 16 or iso.STARTER != Rect2i(72,72,48,48):
        _fail("map geometry changed while upgrading presentation")
        return
    if not iso.lab_routes_ready or iso.preview_routes.size() != 9:
        _fail("Option B nine-route topology was lost")
        return

    # status() counts the actual texture_for() calls, not the full 32-entry
    # on-disk manifest. In PR32 the view loads 30 of the 32 verified PNGs.
    # The existing dedicated MAP25 gate separately verifies all 32 hashes.
    var status: Dictionary = iso.art_source_status
    if not bool(status.get("manifest_valid",false)):
        _fail("original Source A manifest invalid")
        return
    if int(status.get("accepted_count",0)) < 30 or int(status.get("missing_count",-1)) != 0 or int(status.get("rejected_count",-1)) != 0:
        _fail("view-visible verified Source A records changed: "+str(status))
        return
    for house in ["main_hall","warehouse","forge"]:
        if not iso.render_art.has(str(iso.HOUSE_TEXTURES[house])):
            _fail("verified PV01 building missing: "+house)
            return

    if iso.MAP_D2_CANDIDATE_SITES.size() != 3:
        _fail("candidate site count incorrect")
        return
    for site in SITE_TYPES:
        var path := str(iso.MAP_D2_CANDIDATE_SITES[site])
        var required_prefix := "res://art/map_d2_candidate/"
        if not path.begins_with(required_prefix):
            _fail("runtime site art provenance mismatch: "+path)
            return
        var texture := load(path) as Texture2D
        if texture == null or texture.get_width() < 128 or texture.get_height() < 90:
            _fail("MAP-D2 candidate SVG did not import as readable texture: "+path)
            return
        if not iso.candidate_site_art.has(site):
            _fail("MAP-D2 view adapter did not register candidate art: "+site)
            return

    var sample := [
        Vector2i(78,108),
        Vector2i(97,92),
        Vector2i(87,94),
        Vector2i(95,78)
    ]
    var tones: Dictionary = {}
    for cell in sample:
        var tone := SectMapD2Landscape.ground_color(cell,iso.STARTER,iso.preview_roads)
        tones[tone.to_html()] = true
    if tones.size() < 3:
        _fail("palette still repeats one uniform checkerboard across districts")
        return
    if SectMapD2Landscape.SCENIC_ACCENTS.size() < 5:
        _fail("no meaningful map-scene visual accents")
        return
    # Every visible Source A route/terrain tile must be rendered from the
    # exact existing texture once, even after static per-chunk caching.
    var road_expected := 0
    var terrain_expected := 0
    for yy in range(iso.STARTER.position.y,iso.STARTER.end.y):
        for xx in range(iso.STARTER.position.x,iso.STARTER.end.x):
            var cell := Vector2i(xx,yy)
            if iso._is_road(cell):
                var road_key := "env01_assets/roads/%s" % str(iso.ROAD_TEXTURES[iso._road_key(cell)])
                if iso.render_art.has(road_key):
                    road_expected += 1
            var terrain_key := iso._terrain_texture_key(cell)
            if not terrain_key.is_empty() and iso.render_art.has(terrain_key):
                terrain_expected += 1
    var road_cached := 0
    var terrain_cached := 0
    for rows in iso.road_overlays_by_chunk.values():
        road_cached += (rows as Array).size()
    for rows in iso.terrain_overlays_by_chunk.values():
        terrain_cached += (rows as Array).size()
    if road_expected == 0 or terrain_expected == 0 or road_cached != road_expected or terrain_cached != terrain_expected:
        _fail("map overlay cache differs from verified geometry: roads %d/%d terrain %d/%d" %
            [road_cached,road_expected,terrain_cached,terrain_expected])
        return

    var live_sites: Dictionary = {}
    for raw_id in state.buildings.keys():
        var b: BuildingState = state.buildings[raw_id]
        if str(b.building_type) in SITE_TYPES:
            live_sites[str(b.id)] = str(b.building_type)
    var view_sites: Dictionary = {}
    for row in iso.display_instances:
        if bool(row["managed"]):
            var instance_id := str(row["building_id"])
            if not live_sites.has(instance_id) or live_sites[instance_id] != str(row["destination"]) or view_sites.has(instance_id):
                _fail("site SVG changed canonical instance mapping: "+instance_id)
                return
            view_sites[instance_id] = true
    if view_sites.size() != live_sites.size():
        _fail("real managed site count differs from presentation")
        return

    # Presentation refresh and scenery must never settle resources or create
    # a second simulation clock. The existing Mine/Forest/Field click route
    # is verified by PR32's original unchanged focused integration tests.
    iso.refresh_from_state(state)
    iso.queue_redraw()
    await process_frame
    if state.to_dict() != canonical_before:
        _fail("rendering/candidate texture load mutated canonical SimulationState")
        return
    print("MAP-D2 VISUAL CONTRACT PASS verified_source_a_view=%d candidates=3 routes=9 managed=%d palettes=%d roads_cached=%d terrain_cached=%d" % [int(status.get("accepted_count",0)),view_sites.size(),tones.size(),road_cached,terrain_cached])
    quit(0)


func _fail(reason: String) -> void:
    push_error("MAP-D2 VISUAL CONTRACT FAIL: "+reason)
    quit(1)
