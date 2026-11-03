extends SceneTree
## Real P3.2 route test for paid residence placement. The Hall/resource changes here are an in-memory QA fixture only.
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

    game.call("_open_building",SectMapPresentation.DEST_RESIDENCE)
    await process_frame
    await process_frame
    var open_management := _find_button(game,"OpenResidenceManagementV1")
    if open_management == null or open_management.disabled:
        _fail("P3.2 residence operation panel did not expose its real management route.")
        return
    open_management.pressed.emit()
    await process_frame
    await process_frame
    var adapter := game.get_node_or_null("DaiDienScreenV1/TriFacilityB1LiveAdapterV1")
    var build_button := _find_button(adapter,"BuildResidenceOnMap") if adapter != null else null
    if build_button == null or build_button.disabled:
        var model: Dictionary = adapter.call("_house_model") if adapter != null else {}
        _fail("B1 map construction control is absent/disabled despite QA prerequisites: %s" % str(model))
        return
    build_button.pressed.emit()
    await process_frame
    await process_frame
    if not bool(game.get("build_mode_active")):
        _fail("B1 construction intent did not enter real P3.2 map build mode.")
        return

    var iso := game.get("iso_world") as SectIsometricWorldV1
    if iso == null:
        _fail("P3.2 has no isometric world for map placement.")
        return
    var camera := iso.get("camera") as Camera2D
    if camera == null:
        _fail("P3.2 map camera is unavailable.")
        return
    var target := SectResidenceSiteV1.UNSELECTED
    var screen_point := Vector2.ZERO
    for candidate in SectResidenceSiteV1.available_plots(state):
        var gate: Dictionary = SectResidenceSystemV1.can_construct(state,candidate)
        if not bool(gate.get("ok",false)):
            continue
        if not str(game.call("_residence_site_actor_conflict_reason",candidate)).is_empty():
            continue
        var world_point := SectIsometricWorldV1.project(Vector2(candidate))
        var local_view := SectIsometricWorldV1.VIEW_SIZE*0.5 + (world_point-camera.position)*camera.zoom.x
        var candidate_screen := local_view+SectIsometricWorldV1.MAP_SCREEN_OFFSET
        if not SectMapCamera.is_map_screen_point(candidate_screen):
            continue
        if Rect2(Vector2(18,144),Vector2(392,510)).has_point(candidate_screen):
            continue
        if Vector2i(game.call("_cell_at_map_screen",candidate_screen)) != candidate:
            continue
        target = candidate
        screen_point = candidate_screen
        break
    if target == SectResidenceSiteV1.UNSELECTED:
        _fail("Could not find a visible legal lot for real map input.")
        return

    # Feed real mouse down/up events through P3.2._input; this runs the same
    # screen-to-cell path used by player clicks, without a desktop mouse driver.
    var down := InputEventMouseButton.new()
    down.button_index = MOUSE_BUTTON_LEFT
    down.position = screen_point
    down.pressed = true
    game.call("_input",down)
    var up := InputEventMouseButton.new()
    up.button_index = MOUSE_BUTTON_LEFT
    up.position = screen_point
    up.pressed = false
    game.call("_input",up)
    await process_frame
    if Vector2i(game.get("build_mode_site")) != target:
        _fail("Map click did not select the expected legal lot.")
        return
    var confirm := _find_button(game,"ConfirmMapConstruction")
    if confirm == null or confirm.disabled:
        _fail("Valid map placement did not enable the canonical construction confirmation.")
        return
    await RenderingServer.frame_post_draw
    var frame := root.get_texture().get_image()
    if frame == null or frame.get_size() != Vector2i(1280,720):
        _fail("No 1280x720 native Godot placement frame was rendered.")
        return
    if frame.save_png(out_dir.path_join("05_map_residence_valid_placement_qa_fixture.png")) != OK:
        _fail("Could not save the map placement frame.")
        return
    print("TRI_MAP_BUILD_PLACEMENT_PASS plot=%d,%d screen=%.1f,%.1f" % [target.x,target.y,screen_point.x,screen_point.y])

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

    var starter_move := SectResidenceSystemV1.can_move_house(state,&"residence_001",target)
    if starter_move.get("reason","") != "starter_house_fixed":
        _fail("The unique starter residence must stay fixed on the map.")
        return
    var construction_finish := int(house.production_state.get("construction_finish_tick",-1))
    state.tick = construction_finish
    if not SectResidenceSystemV1.complete_due_construction(state,house):
        _fail("Canonical residence construction did not complete at its saved finish tick.")
        return
    game.call("_refresh_all")
    game.call("_enter_build_mode")
    await process_frame
    await process_frame
    var move_button := _find_button(game,"MoveResidence_02")
    if move_button == null or move_button.disabled:
        _fail("Completed, empty annex must expose the real map relocation action.")
        return
    move_button.pressed.emit()
    await process_frame
    var move_target := SectResidenceSiteV1.UNSELECTED
    var move_screen := Vector2.ZERO
    camera = iso.get("camera") as Camera2D
    for candidate in SectResidenceSiteV1.available_plots(state):
        var gate: Dictionary = SectResidenceSystemV1.can_move_house(state,StringName(building_id),candidate)
        if not bool(gate.get("ok",false)):
            continue
        var world_point := SectIsometricWorldV1.project(Vector2(candidate))
        var local_view := SectIsometricWorldV1.VIEW_SIZE*0.5 + (world_point-camera.position)*camera.zoom.x
        var candidate_screen := local_view+SectIsometricWorldV1.MAP_SCREEN_OFFSET
        if not SectMapCamera.is_map_screen_point(candidate_screen):
            continue
        if Rect2(Vector2(18,144),Vector2(392,510)).has_point(candidate_screen):
            continue
        if Vector2i(game.call("_cell_at_map_screen",candidate_screen)) != candidate:
            continue
        move_target = candidate
        move_screen = candidate_screen
        break
    if move_target == SectResidenceSiteV1.UNSELECTED:
        _fail("Could not find a visible safe destination for a completed empty annex.")
        return
    var move_down := InputEventMouseButton.new()
    move_down.button_index = MOUSE_BUTTON_LEFT
    move_down.position = move_screen
    move_down.pressed = true
    game.call("_input",move_down)
    var move_up := InputEventMouseButton.new()
    move_up.button_index = MOUSE_BUTTON_LEFT
    move_up.position = move_screen
    move_up.pressed = false
    game.call("_input",move_up)
    await process_frame
    if Vector2i(game.get("build_mode_site")) != move_target:
        _fail("Map input did not select the valid relocation destination.")
        return
    var move_confirm := _find_button(game,"ConfirmMapConstruction")
    if move_confirm == null or move_confirm.disabled or move_confirm.text != "DỜI NHÀ":
        _fail("The map relocation confirmation is not valid for this legal site.")
        return
    var move_request_id := "map-house:%d:%d:%d:%s" % [state.tick,move_target.x,move_target.y,building_id]
    var wood_before_move := warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD)
    var ore_before_move := warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE)
    var stones_before_move := state.sect.spirit_stones
    var houses_before_move := SectResidenceSystemV1.all_houses(state).size()
    move_confirm.pressed.emit()
    await process_frame
    await process_frame
    if SectResidenceSiteV1.origin_of(house) != move_target or house.status != BuildingSystem.STATUS_ACTIVE:
        _fail("Canonical map relocation did not move the annex to the selected site.")
        return
    var move_receipts: Dictionary = state.sect.hall_governance.get("residence_move_receipts",{})
    if move_receipts.size() != 1 or not move_receipts.has(move_request_id):
        _fail("Relocation must persist exactly one canonical move receipt.")
        return
    var move_replay := SectResidenceSystemV1.move_house(state,move_request_id,house.id,move_target)
    if not bool(move_replay.get("ok",false)) or not bool(move_replay.get("already_settled",false)) \
            or warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD) != wood_before_move \
            or warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE) != ore_before_move \
            or state.sect.spirit_stones != stones_before_move \
            or SectResidenceSystemV1.all_houses(state).size() != houses_before_move:
        _fail("Replaying the same move receipt must not relocate or charge twice.")
        return
    var assignments: Dictionary = state.sect.hall_governance.get("residence_assignments",{}).duplicate(true)
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    if not disciple_ids.is_empty():
        state.sect.hall_governance["residence_assignments"][str(disciple_ids[0])] = building_id
        var blocked_move := SectResidenceSystemV1.can_move_house(state,house.id,target)
        state.sect.hall_governance["residence_assignments"] = assignments
        if bool(blocked_move.get("ok",false)) or blocked_move.get("reason","") != "house_occupied":
            _fail("An occupied residence must not be relocated.")
            return
    await RenderingServer.frame_post_draw
    var moved_frame := root.get_texture().get_image()
    if moved_frame == null or moved_frame.get_size() != Vector2i(1280,720) \
            or moved_frame.save_png(out_dir.path_join("07_map_residence_relocated_qa_fixture.png")) != OK:
        _fail("Could not save the 1280x720 relocated-house map frame.")
        return
    var build_replay := SectResidenceSystemV1.construct(state,request_id,target)
    if not bool(build_replay.get("ok",false)) or not bool(build_replay.get("already_settled",false)) \
            or str(build_replay.get("building_id","")) != building_id \
            or warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD) != pre_wood-int(cost[BuildingSystem.MATERIAL_WOOD]) \
            or warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE) != pre_ore-int(cost[BuildingSystem.MATERIAL_ORE]) \
            or state.sect.spirit_stones != pre_stones-int(cost["spirit_stones"]):
        _fail("Replaying the original build after relocation must remain exactly-once.")
        return
    if saver.save_to_path(state,save_path) != OK:
        _fail("SaveService failed to persist the relocated house and receipt.")
        return
    expected["original_site_x"] = target.x
    expected["original_site_y"] = target.y
    expected["site_x"] = move_target.x
    expected["site_y"] = move_target.y
    expected["move_request_id"] = move_request_id
    expected["move_receipt_count"] = move_receipts.size()
    expected["house_status"] = "active"
    expected_file = FileAccess.open(expected_path,FileAccess.WRITE)
    if expected_file == null:
        _fail("Could not update the isolated expected relocation manifest.")
        return
    expected_file.store_string(JSON.stringify(expected))
    expected_file.close()
    print("TRI_MAP_RELOCATION_TRANSACTION_PASS building=%s old=%d,%d new=%d,%d receipt=%d exact_once=1 occupied_guard=1 save=1" % [
        building_id,target.x,target.y,move_target.x,move_target.y,move_receipts.size()])
    game.set("runtime_ready",false)
    game.queue_free()
    await process_frame
    print("TRI_MAP_BUILD_PROCESS1_SAVED path=%s expected=%s" % [save_path,expected_path])
    quit(0)
