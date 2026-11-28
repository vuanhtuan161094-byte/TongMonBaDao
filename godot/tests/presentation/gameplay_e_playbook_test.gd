extends SceneTree

# E: open the actual main game, click the actual guide controls, verify
# facility routes, and ensure read-only navigation does not create resources.
const SAVE_PATH := "user://qa_gameplay_e_playbook.json"
var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _cleanup() -> void:
    if ui != null and is_instance_valid(ui):
        ui.set("runtime_ready",false)
        root.remove_child(ui)
        ui.queue_free()
        ui = null
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    for suffix in ["",".bak",".tmp"]:
        var path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(reason: String) -> void:
    push_error("GAMEPLAY_E_PLAYBOOK_FAIL "+reason)
    _cleanup()
    quit(1)

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("main scene missing")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        _fail("canonical state missing")
        return
    var receipts := state.sect.economy_a_receipts.size()
    var stones := state.sect.spirit_stones
    var routes := {
        "recruit":SectMapPresentation.DEST_GUIDANCE,
        "residence":SectMapPresentation.DEST_RESIDENCE,
        "hall":SectMapPresentation.DEST_MAIN_HALL,
        "body":SectMapPresentation.DEST_BODY_TRAINING,
        "medicine":SectMapPresentation.DEST_MEDICINE,
        "production":SectMapPresentation.DEST_MINE,
        "forest":SectMapPresentation.DEST_LINH_FOREST,
        "field":SectMapPresentation.DEST_SPIRIT_FIELD,
        "warehouse":SectMapPresentation.DEST_WAREHOUSE,
        "craft":SectMapPresentation.DEST_ALCHEMY_HALL,
        "forge":SectMapPresentation.DEST_FORGE,
        "gate":SectMapPresentation.DEST_GATE
    }
    var all_actions: Array = routes.keys()
    all_actions.append_array(["school","cultivation","hunt","transmission"])
    ui.call("_art05_open_playbook")
    await process_frame
    for action in all_actions:
        if ui.find_child("OneGamePlaybook_"+str(action),true,false) as Button == null:
            _fail("missing action "+str(action))
            return
    var progress_button := ui.find_child("OneGameProgressButton",true,false) as Button
    if progress_button == null:
        _fail("missing progression entry")
        return
    progress_button.pressed.emit()
    await process_frame
    var goals: Array = ui.call("_gameplay_e2_goal_rows")
    if goals.size() != 8:
        _fail("expected eight derived milestones")
        return
    for i in range(goals.size()):
        if ui.find_child("OneGameGoal_"+str(i),true,false) == null:
            _fail("missing milestone action "+str(i))
            return
    var progress: Dictionary = ui.call("_gameplay_e2_progress_snapshot")
    if int(progress.get("disciples",-1)) != state.disciples.size():
        _fail("progress not tied to roster")
        return
    var back := ui.find_child("OneGameProgressBack",true,false) as Button
    if back == null:
        _fail("missing progress back route")
        return
    back.pressed.emit()
    await process_frame
    var snapshot: Dictionary = ui.call("_gameplay_playbook_snapshot")
    if int(snapshot.get("ready",-1)) < 0 or int(snapshot.get("ready",-1)) > state.disciples.size():
        _fail("invalid live readiness count")
        return
    for action in routes:
        ui.call("_art05_open_playbook")
        await process_frame
        var control := ui.find_child("OneGamePlaybook_"+str(action),true,false) as Button
        if control == null:
            _fail("unable to reopen guide "+str(action))
            return
        control.pressed.emit()
        await process_frame
        if StringName(ui.get("selected_building")) != routes[action]:
            _fail("incorrect facility route "+str(action))
            return
        print("GAMEPLAY_E_ROUTE_PASS "+str(action)+" -> "+str(routes[action]))
    if state.sect.economy_a_receipts.size() != receipts or state.sect.spirit_stones != stones:
        _fail("read-only navigation changed economy")
        return
    if not state.validate_invariants().is_empty():
        _fail(str(state.validate_invariants()))
        return
    _cleanup()
    print("GAMEPLAY_E_PLAYBOOK_PASS 16 actions present / 12 facility routes clicked / no economy writes")
    quit(0)
