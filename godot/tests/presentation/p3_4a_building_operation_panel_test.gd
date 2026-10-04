extends SceneTree

var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.4A could not load the live P3.2 map scene.")
        return

    ui = packed_scene.instantiate() as Control
    if ui == null:
        _fail("P3.4A could not instantiate the live map scene.")
        return

    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null:
        _fail("P3.4A did not expose the real SimulationState.")
        return

    var before := state.to_dict().duplicate(true)

    var destinations: Array[StringName] = [
        SectMapPresentation.DEST_MAIN_HALL,
        SectMapPresentation.DEST_RESIDENCE,
        SectMapPresentation.DEST_CULTIVATION,
        SectMapPresentation.DEST_WAREHOUSE,
        SectMapPresentation.DEST_FORGE,
        SectMapPresentation.DEST_MEDICINE,
        SectMapPresentation.DEST_MINE,
        SectMapPresentation.DEST_GATE
    ]

    for destination in destinations:
        ui.call("_open_building", destination)
        await process_frame
        if not _verify_open_panel(destination):
            return

    var after := state.to_dict().duplicate(true)
    if before != after:
        _fail("P3.4A read-only building panel mutated SimulationState.")
        return

    ui.call("_close_building_operation_panel", true)
    await process_frame

    var panel := ui.get("building_operation_panel") as Panel
    if panel != null and panel.visible:
        _fail("P3.4A building panel did not close.")
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    if not ids.is_empty():
        ui.call("_open_building", SectMapPresentation.DEST_MINE)
        await process_frame
        ui.call("_open_disciple", StringName(ids[0]))
        await process_frame
        if panel != null and panel.visible:
            _fail("Switching building -> disciple did not hide the building panel.")
            return

    print("P3.4A BUILDING OPERATION PANEL TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _verify_open_panel(destination: StringName) -> bool:
    var panel := ui.get("building_operation_panel") as Panel
    if panel == null or not panel.visible:
        return _fail("P3.4A tap building did not open fixed operation panel: %s" % str(destination))

    var popup_layer := ui.get("popup_layer") as Control
    if popup_layer == null or popup_layer.get_child_count() != 0:
        return _fail("P3.4A building panel incorrectly used dim/modal popup layer.")

    var selected := StringName(ui.get("selected_building"))
    if selected != destination:
        return _fail("P3.4A selected building mismatch: %s" % str(destination))

    var title := ui.get("building_operation_title") as Label
    var body := ui.get("building_operation_body") as Label
    if title == null or title.text.is_empty():
        return _fail("P3.4A building title is empty: %s" % str(destination))
    if body == null or body.text.is_empty():
        return _fail("P3.4A building body is empty: %s" % str(destination))

    var camera_controls := ui.get("camera_controls_panel") as Panel
    if camera_controls != null and camera_controls.visible:
        return _fail("P3.4A building panel overlaps the right camera control rail.")

    var focused_kind := StringName(ui.get("focused_kind"))
    var focused_id := StringName(ui.get("focused_id"))
    if focused_kind != &"building" or focused_id != destination:
        return _fail("P3.4A building selection marker/focus context is incorrect.")

    match destination:
        SectMapPresentation.DEST_MAIN_HALL:
            if not body.text.contains("Ngân khố") or not body.text.contains(str(state.sect.treasury)):
                return _fail("Main Hall does not read real treasury state.")
        SectMapPresentation.DEST_MINE:
            var iron := int(state.sect.forge_materials.get("thanh_thiet", 0))
            if not body.text.contains("Thanh Thiết") or not body.text.contains(str(iron)):
                return _fail("Mine does not read real Thanh Thiet state.")
        SectMapPresentation.DEST_FORGE:
            if not body.text.contains("Điểm hỗ trợ rèn") or not body.text.contains(str(state.sect.forge_support_points)):
                return _fail("Forge does not read real support-point state.")
        SectMapPresentation.DEST_CULTIVATION:
            if not body.text.contains("đột phá"):
                return _fail("Cultivation platform does not expose real cultivation readiness context.")
        SectMapPresentation.DEST_RESIDENCE:
            if not body.text.contains(str(state.sect.lodging_capacity)):
                return _fail("Residence does not read real lodging capacity.")
        SectMapPresentation.DEST_MEDICINE:
            if not body.text.contains(str(state.sect.medicine_stock)):
                return _fail("Medicine Hall does not read real medicine stock.")
        SectMapPresentation.DEST_WAREHOUSE:
            if not body.text.contains("TRANG BỊ") or not body.text.contains("Vật tư"):
                return _fail("Warehouse does not group real stored state.")
        SectMapPresentation.DEST_GATE:
            if not body.text.contains("Đệ tử ngoài tông"):
                return _fail("Gate does not expose real outside-disciple context.")

    return true

func _fail(message: String) -> bool:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
    return false
