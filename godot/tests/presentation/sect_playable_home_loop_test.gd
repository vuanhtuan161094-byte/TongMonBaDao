extends SceneTree

# SECT-PLAYABLE V1. Real landscape/player commands only: overview ->
# Guidance recruitment -> workforce picker -> warehouse -> physical autosave.
# Requires Godot 4.7.2; this text has NOT been executed in runtime.
const SAVE_PATH := "user://sect_playable_home_loop_test.json"
var ui: Control
var state: SimulationState
var buildings := BuildingSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("landscape scene unavailable")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not bool(ui.get("runtime_ready")):
        _fail("real live runtime unavailable")
        return
    ui.call("_bottom_action","home")
    await process_frame
    var hub := ui.find_child("SectOperationsHub",true,false) as Panel
    if hub == null or not hub.visible or hub.position.x+hub.size.x > 1280:
        _fail("sect operations hub invisible or outside landscape bounds")
        return
    var overview := ui.find_child("SectHubContent",true,false) as VBoxContainer
    if overview == null or overview.get_child_count() < 7:
        _fail("sect overview missing live navigation and status")
        return
    if not await _press("SectHubRoute_guidance"):
        return
    if StringName(ui.get("selected_building")) != SectMapPresentation.DEST_GUIDANCE or hub.visible:
        _fail("Guidance navigation did not close hub and focus real building")
        return

    var initial_count := state.disciples.size()
    var token_before := state.sect.disciple_recruitment_tokens
    if token_before <= 0 or not await _press("GuidanceRecruitOrder"):
        return
    if state.sect.disciple_recruitment_tokens != token_before-1:
        _fail("recruit order did not debit exactly one authentic token")
        return
    var recruitable_id: StringName = &""
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    for id in ids:
        var candidate: CandidateState = state.recruitment_candidates[id]
        if DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            recruitable_id = StringName(id)
            break
    if recruitable_id == &"":
        _fail("Dẫn Tiên yielded no authentic V2 candidate")
        return
    if not await _press("AcceptCandidate_%s" % str(recruitable_id)):
        return
    if state.disciples.size() != initial_count+1 or not state.disciples.has(recruitable_id):
        _fail("candidate not accepted exactly once into canonical roster")
        return
    var route := ui.find_child("GuidanceAssignNewRecruit",true,false) as Button
    if route == null or route.disabled or not await _press("GuidanceAssignNewRecruit"):
        return
    if StringName(ui.get("selected_building")) != SectMapPresentation.DEST_MINE:
        _fail("accepted recruit did not navigate to Mine workplace")
        return
    var picker := ui.find_child("WorkforcePicker",true,false) as Panel
    if picker == null or not picker.visible or picker.position.x+picker.size.x > 1280:
        _fail("new recruit did not open real picker in bounds")
        return
    var choice := ui.find_child("WorkforcePick_%s" % str(recruitable_id),true,false) as Button
    if choice == null or choice.disabled:
        _fail("authentic recruit unavailable for legal one-worker Mine transfer")
        return
    if not await _press("WorkforcePick_%s" % str(recruitable_id)):
        return
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var new_actor: DiscipleState = state.disciples[recruitable_id]
    if mine == null or new_actor.work_group_id != &"mining_crew" or new_actor.worksite_building_id != mine.id or buildings.assigned_worker_ids(state,mine).size() != 1:
        _fail("new recruit did not own exactly one Mine slot")
        return
    ui.call("_bottom_action","home")
    await process_frame
    if not hub.visible:
        _fail("returning to Tông Môn did not show overview")
        return
    if not await _press("SectHubRoute_warehouse"):
        return
    if StringName(ui.get("selected_building")) != SectMapPresentation.DEST_WAREHOUSE:
        _fail("warehouse navigation did not open canonical warehouse")
        return
    var body := ui.find_child("BuildingOperationBody",true,false) as Label
    if body == null or body.text.is_empty():
        _fail("warehouse stock/operation display missing")
        return
    ui.call("_autosave_runtime")
    if not FileAccess.file_exists(SAVE_PATH):
        _fail("real LiveGameRuntimeV2 autosave absent")
        return
    var reopened := SaveService.new().load_from_path(SAVE_PATH)
    if reopened == null or not reopened.disciples.has(recruitable_id):
        _fail("saved new recruit missing from authentic loaded state")
        return
    var saved_mine := buildings.primary_building(reopened,BuildingSystem.TYPE_MINE)
    var loaded_actor: DiscipleState = reopened.disciples[recruitable_id]
    if saved_mine == null or loaded_actor.worksite_building_id != saved_mine.id:
        _fail("save/load lost new worker's exact Mine worksite")
        return
    if not reopened.validate_invariants().is_empty():
        _fail("real recruited-and-assigned state violates invariants")
        return
    print("SECT-PLAYABLE V1 GUIDANCE→WORKFORCE→WAREHOUSE→SAVE: PASS")
    if ui != null:
        ui.queue_free()
    quit(0)

func _press(button_name: String) -> bool:
    var button := ui.find_child(button_name,true,false) as Button
    if button == null or button.disabled:
        _fail("missing or disabled real control: "+button_name)
        return false
    button.emit_signal("pressed")
    await process_frame
    return true

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))

func _fail(message: String) -> void:
    push_error("SECT-PLAYABLE V1 FAILED: "+message)
    if ui != null:
        ui.queue_free()
    quit(1)
