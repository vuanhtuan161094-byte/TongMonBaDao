extends SceneTree

# GUI-WORKFORCE-V1: exercise the actual 1280x720 scene and canonical
# WorkforceSystem/BuildingSystem; never fabricate production or currency.
const SAVE_PATH := "user://gui_workforce_v1_scene_test.json"
var ui: Control
var state: SimulationState
var workforce := WorkforceSystem.new()
var buildings := BuildingSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for suffix in ["",".bak",".tmp"]:
        var filename := SAVE_PATH + suffix
        if FileAccess.file_exists(filename):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(filename))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("Missing real landscape scene")
        return
    ui = packed.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        _fail("No real live SimulationState")
        return

    var content_panel := ui.get("building_operation_content") as VBoxContainer
    if content_panel == null or content_panel.get_child(0).name != "BuildingManagementControls":
        _fail("Interactive controls are not before the long building detail")
        return
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if mine == null or field == null:
        _fail("Missing real Mine / Spirit Field")
        return
    ui.call("_open_building",SectMapPresentation.DEST_MINE)
    await process_frame
    var holders := buildings.active_worker_ids(state,mine)
    if holders.size() < 2:
        _fail("Expected two canonical Mine workers in opening state")
        return
    var full_launcher := ui.find_child("WorkforcePickerOpen_%s" % str(mine.building_type),true,false) as Button
    if full_launcher == null or full_launcher.disabled:
        _fail("Picker cannot be opened to review a full building's roster")
        return
    full_launcher.emit_signal("pressed")
    await process_frame
    if not (ui.get("workforce_picker_overlay") as Control).visible:
        _fail("Full Mine picker did not open")
        return
    ui.call("_close_workforce_picker")
    var candidate_id: StringName = holders[1]
    var legacy_release := ui.find_child("Group_mining_crew_%s" % str(candidate_id),true,false) as Button
    if legacy_release == null:
        _fail("O3-compatible real group release was removed")
        return
    legacy_release.emit_signal("pressed")
    await process_frame
    if (state.disciples[candidate_id] as DiscipleState).work_group_id != &"":
        _fail("Legacy real withdrawal did not release Mine slot")
        return
    var launch := ui.find_child("WorkforcePickerOpen_%s" % str(mine.building_type),true,false) as Button
    if launch == null or launch.disabled:
        _fail("Mine picker not visible/enabled after a true slot vacancy")
        return
    launch.emit_signal("pressed")
    await process_frame
    var overlay := ui.find_child("WorkforcePickerOverlay",true,false) as Control
    if overlay == null or not overlay.visible:
        _fail("Picker did not open")
        return
    var search := ui.find_child("WorkforcePickerSearch",true,false) as LineEdit
    if search == null:
        _fail("Search field missing")
        return
    var actor: DiscipleState = state.disciples[candidate_id]
    search.text = actor.display_name
    search.emit_signal("text_changed",search.text)
    await process_frame
    var pick := ui.find_child("WorkforcePick_%s" % str(candidate_id),true,false) as Button
    if pick == null or pick.disabled:
        _fail("Named idle candidate not available from picker")
        return
    pick.emit_signal("pressed")
    await process_frame
    if actor.work_group_id != &"mining_crew" or actor.worksite_building_id != mine.id:
        _fail("Selection did not use canonical work-group and worksite authority")
        return
    if not buildings.active_worker_ids(state,mine).has(candidate_id) or overlay.visible:
        _fail("Selection did not occupy the real Mine slot and close picker")
        return

    ui.call("_open_building",SectMapPresentation.DEST_SPIRIT_FIELD)
    await process_frame
    var field_picker := ui.find_child("WorkforcePickerOpen_%s" % str(field.building_type),true,false) as Button
    if field_picker == null:
        _fail("Spirit Field did not reuse shared disciple picker")
        return
    if not field_picker.disabled:
        field_picker.emit_signal("pressed")
        await process_frame
        search.text = actor.display_name
        search.emit_signal("text_changed",search.text)
        await process_frame
        pick = ui.find_child("WorkforcePick_%s" % str(candidate_id),true,false) as Button
        if pick == null or not pick.disabled:
            _fail("Busy Mine worker could be silently transferred to Spirit Field")
            return
        if actor.work_group_id != &"mining_crew" or actor.worksite_building_id != mine.id:
            _fail("Rejected transfer changed existing worksite")
            return
        ui.call("_close_workforce_picker")
    var errors := state.validate_invariants()
    if not errors.is_empty():
        _fail("GUI commands violated canonical invariants: %s" % str(errors))
        return
    print("GUI-WORKFORCE-V1 REAL PICKER + SAFE ASSIGNMENT + O3/O4 COMPAT: PASS")
    _dispose()
    quit(0)

func _dispose() -> void:
    if ui != null and is_instance_valid(ui):
        root.remove_child(ui)
        ui.queue_free()
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    for suffix in ["",".bak",".tmp"]:
        var filename := SAVE_PATH + suffix
        if FileAccess.file_exists(filename):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(filename))

func _fail(why: String) -> void:
    push_error("GUI-WORKFORCE-V1 FOCUSED FAIL: "+why)
    _dispose()
    quit(1)
