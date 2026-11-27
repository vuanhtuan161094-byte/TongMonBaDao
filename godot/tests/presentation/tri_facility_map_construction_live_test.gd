extends SceneTree
## ART-05 V2 fixed-MASTERPLAN paid Residence route; Hall/resource additions are isolated in-memory QA fixtures.
const GAME = preload("res://scenes/p3/p3_2_landscape_sect.tscn")
const RUNTIME_PATH := "user://tri03_map_build_runtime_isolated.json"
const ROUNDTRIP_PATH := "user://tri03_map_build_roundtrip.json"
const EXPECTED_PATH := "user://tri03_map_build_expected.json"
var game: Control

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("TRI_MAP_BUILD_FAIL: " + message)
    quit(1)

func _find_button(node: Node, target: String) -> Button:
    if node is Button and node.name == target:
        return node as Button
    for child in node.get_children():
        var found := _find_button(child,target)
        if found != null:
            return found
    return null

func _clean(path: String) -> void:
    var absolute := ProjectSettings.globalize_path(path)
    for suffix in ["", ".bak", ".tmp"]:
        if FileAccess.file_exists(absolute+suffix):
            DirAccess.remove_absolute(absolute+suffix)

func _run() -> void:
    var argv := OS.get_cmdline_user_args()
    if argv.is_empty():
        _fail("Pass the isolated screenshot output directory after --.")
        return
    var out_dir: String = argv[0]
    DirAccess.make_dir_recursive_absolute(out_dir)
    _clean(RUNTIME_PATH)
    _clean(ROUNDTRIP_PATH)
    _clean(EXPECTED_PATH)
    ProjectSettings.set_setting("runtime/live_save_path",RUNTIME_PATH)
    DisplayServer.window_set_size(Vector2i(1280,720))

    game = GAME.instantiate() as Control
    if game == null:
        _fail("Could not instantiate the real P3.2 scene.")
        return
    root.add_child(game)
    for _frame in range(4):
        await process_frame
    if not bool(game.get("runtime_ready")):
        _fail("P3.2 runtime did not initialize from the isolated QA profile.")
        return
    var state := game.get("state") as SimulationState
    if state == null or not SectHallSystemV1.installed(state):
        _fail("Canonical Hall state missing in the new-game session.")
        return

    # QA fixture only: meet the existing Hall Lv11 gate and seed canonical
    # Warehouse stock so the actual production UI and transaction can be exercised.
    var hall := SectHallSystemV1.hall(state)
    hall.level = 11
    var warehouse := WarehouseSystem.new()
    if not warehouse.add(state,BuildingSystem.MATERIAL_WOOD,1500) or not warehouse.add(state,BuildingSystem.MATERIAL_ORE,1000):
        _fail("Could not seed isolated QA Warehouse materials.")
        return
    state.sect.spirit_stones = 25000
    game.call("_refresh_all")
    await process_frame
    print("TRI_MAP_BUILD_QA_FIXTURE hall_level=11 warehouse_seed=isolated_in_memory_only")

    # ART-05 world layout V2 is owner-approved fixed MASTERPLAN. The older
    # free terrain-click placement and relocation contract is not playable.
    # Use the real build catalog + paid confirmation, never fake a build.
    game.call("_enter_build_mode")
    await process_frame
    var catalog := _find_button(game,"BuildCatalogResidence")
    if catalog == null or catalog.disabled:
        _fail("ART-05 real build catalog unavailable with canonical QA stock.")
        return
    catalog.pressed.emit()
    await process_frame
    await process_frame
    if not bool(game.get("build_mode_active")) or str(game.get("build_mode_kind")) != "construct":
        _fail("ART-05 catalog did not enter the actual construction flow.")
        return
    var target := Vector2i(game.get("build_mode_site"))
    var confirm := _find_button(game,"ConfirmMapConstruction")
    if not SectResidenceSiteV1.annex_sites(state.sect.world_layout_version).has(target) \
            or not bool(SectResidenceSiteV1.check(state,target).get("ok",false)) \
            or not str(game.call("_residence_site_actor_conflict_reason",target)).is_empty() \
            or confirm == null or confirm.disabled:
        _fail("ART-05 did not select an unoccupied paid MASTERPLAN annex lot: %s" % str(target))
        return

    # Arbitrary map placement must not override the one assigned lot.
    var alternate := SectResidenceSiteV1.UNSELECTED
    for candidate in SectResidenceSiteV1.available_plots(state):
        if candidate != target:
            alternate = candidate
            break
    if alternate == SectResidenceSiteV1.UNSELECTED:
        _fail("No alternate lot available for ART-05 free-placement denial.")
        return
    game.call("_select_build_mode_site",alternate)
    if Vector2i(game.get("build_mode_site")) != target or confirm.disabled:
        _fail("ART-05 allowed manual terrain to replace the fixed planned lot.")
        return

    var iso := game.get("iso_world") as SectIsometricWorldV1
    if iso == null:
        _fail("P3.2 lacks the real isometric world.")
        return
    var camera := iso.get("camera") as Camera2D
    if camera == null:
        _fail("P3.2 map camera is unavailable.")
        return
    var world_point := SectIsometricWorldV1.project(Vector2(target))
    var screen_point := SectIsometricWorldV1.VIEW_SIZE*0.5 \
        + (world_point-camera.position)*camera.zoom.x \
        + SectIsometricWorldV1.MAP_SCREEN_OFFSET
    await RenderingServer.frame_post_draw
    var frame := root.get_texture().get_image()
    if frame == null or frame.get_size() != Vector2i(1280,720):
        _fail("No 1280x720 native Godot fixed-plan frame was rendered.")
        return
    if frame.save_png(out_dir.path_join("05_map_residence_valid_placement_qa_fixture.png")) != OK:
        _fail("Could not save the ART-05 fixed-plan screenshot.")
        return
    print("TRI_MAP_BUILD_FIXED_MASTERPLAN_PASS plot=%d,%d screen=%.1f,%.1f ignored=%s" % [
        target.x,target.y,screen_point.x,screen_point.y,str(alternate)])

    var request_id := "map-house:%d:%d:%d:new" % [state.tick,target.x,target.y]
    var pre_build_count := SectResidenceSystemV1.all_houses(state).size()
    var pre_wood := warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD)
    var pre_ore := warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE)
    var pre_stones := state.sect.spirit_stones
    var cost_before: Dictionary = SectResidenceSystemV1.build_cost(state)
    confirm.pressed.emit()
    await process_frame
    await process_frame
    var building_id := "residence_%03d" % (pre_build_count+1)
    var house := state.buildings.get(building_id) as BuildingState
    if house == null or house.status != BuildingSystem.STATUS_CONSTRUCTING or SectResidenceSiteV1.origin_of(house) != target:
        _fail("Canonical construction did not create a paid house at the selected site.")
        return
    var new_house_path := SectResidenceSiteV1.path_to_door(state,target,building_id)
    if new_house_path.is_empty():
        _fail("Placed residence did not retain a valid walking route from the sect gate.")
        return
    for path_cell in new_house_path:
        if not iso.preview_roads.has(path_cell):
            _fail("The map did not render the validated residence path cell %s." % str(path_cell))
            return
    var receipts: Dictionary = state.sect.hall_governance.get("residence_build_receipts",{})
    if receipts.get(request_id,"") != building_id or receipts.size() != 1:
        _fail("Canonical exactly-once build receipt missing or duplicated.")
        return
    var cost: Dictionary = cost_before
    if pre_wood-warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD) != int(cost[BuildingSystem.MATERIAL_WOOD]) \
            or pre_ore-warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE) != int(cost[BuildingSystem.MATERIAL_ORE]) \
            or pre_stones-state.sect.spirit_stones != int(cost["spirit_stones"]):
        _fail("Construction did not debit its canonical material and stone costs exactly once.")
        return
    await RenderingServer.frame_post_draw
    var started_frame := root.get_texture().get_image()
    if started_frame == null or started_frame.get_size() != Vector2i(1280,720) or started_frame.save_png(out_dir.path_join("06_map_residence_started_qa_fixture.png")) != OK:
        _fail("Could not save construction result frame.")
        return
    var saver := SaveService.new()
    var save_path := ProjectSettings.globalize_path(ROUNDTRIP_PATH)
    if saver.save_to_path(state,save_path) != OK:
        _fail("SaveService failed to persist the real map build result.")
        return
    var expected := {
        "request_id":request_id,"building_id":building_id,"site_x":target.x,"site_y":target.y,
        "wood":warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD),
        "ore":warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE),"stones":state.sect.spirit_stones,
        "house_count":SectResidenceSystemV1.all_houses(state).size(),"receipt_count":receipts.size()
    }
    var expected_path := ProjectSettings.globalize_path(EXPECTED_PATH)
    var expected_file := FileAccess.open(expected_path,FileAccess.WRITE)
    if expected_file == null:
        _fail("Could not write isolated expected manifest.")
        return
    expected_file.store_string(JSON.stringify(expected))
    expected_file.close()
    print("TRI_MAP_BUILD_TRANSACTION_PASS building=%s site=%d,%d cost=%s receipt=%d save=1" % [building_id,target.x,target.y,str(cost),receipts.size()])

    # ART-05 V2 keeps annex plots fixed. The old Source A relocation/drag
    # UI has been retired; verify it is not reachable rather than inventing
    # a relocation transaction to satisfy an obsolete test.
    var construction_finish := int(house.production_state.get("construction_finish_tick",-1))
    state.tick = construction_finish
    if not SectResidenceSystemV1.complete_due_construction(state,house):
        _fail("Canonical residence did not complete on its saved finish tick.")
        return
    game.call("_refresh_all")
    await process_frame
    game.call("_enter_build_mode")
    await process_frame
    var moves := game.find_child("RelocatableResidenceList",true,false) as Control
    if moves != null and moves.visible:
        _fail("ART-05 fixed districts exposed the retired relocation UI.")
        return
    game.call("_begin_residence_relocation",StringName(building_id))
    if str(game.get("build_mode_kind")) == "relocate" \
            or SectResidenceSiteV1.origin_of(house) != target:
        _fail("ART-05 accepted a forbidden relocation or moved the planned House.")
        return

    # Replay must not charge or place the same house a second time.
    var wood_after := warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD)
    var ore_after := warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE)
    var stones_after := state.sect.spirit_stones
    var house_count_after := SectResidenceSystemV1.all_houses(state).size()
    var replay := SectResidenceSystemV1.construct(state,request_id,target)
    if not bool(replay.get("ok",false)) or not bool(replay.get("already_settled",false)) \
            or str(replay.get("building_id","")) != building_id \
            or warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD) != wood_after \
            or warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE) != ore_after \
            or state.sect.spirit_stones != stones_after \
            or SectResidenceSystemV1.all_houses(state).size() != house_count_after:
        _fail("ART-05 receipt replay charged resources or duplicated the House.")
        return

    if saver.save_to_path(state,save_path) != OK:
        _fail("SaveService failed to persist completed MASTERPLAN residence.")
        return
    expected["site_x"] = target.x
    expected["site_y"] = target.y
    expected["house_status"] = "active"
    expected["fixed_masterplan"] = true
    expected["move_receipt_count"] = 0
    expected_file = FileAccess.open(expected_path,FileAccess.WRITE)
    if expected_file == null:
        _fail("Could not update isolated completed-house manifest.")
        return
    expected_file.store_string(JSON.stringify(expected))
    expected_file.close()
    print("TRI_MAP_FIXED_MASTERPLAN_TRANSACTION_PASS building=%s site=%d,%d receipt=1 exact_once=1 relocation_blocked=1 save=1" % [
        building_id,target.x,target.y])
    game.set("runtime_ready",false)
    game.queue_free()
    await process_frame
    print("TRI_MAP_BUILD_PROCESS1_SAVED path=%s expected=%s" % [save_path,expected_path])
    quit(0)
