extends SceneTree

const TEST_SAVE_PATH := "user://hs09_disciple_profile_test.json"
const EXPECTED_TABS := ["Tổng Quan","Thuộc Tính","Công Pháp","Trang Bị","Huyết Mạch","Thể Chất","Quan Hệ"]

var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _cleanup() -> void:
    if FileAccess.file_exists(TEST_SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> void:
    push_error("HS09 DISCIPLE PROFILE FAIL: "+message)
    if ui != null:
        ui.queue_free()
    _cleanup()
    quit(1)

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",TEST_SAVE_PATH)

    var radar := HS09DualFoundationRadar.new()
    var synthetic := {"ok":true,"foundations":{"model_version":3,"current":{
        "aptitude":12.0,"constitution":24.0,"mind_nature":9999.0,
        "potential":100.0,"comprehension":200.0,"fortune":300.0,"charisma":400.0
    }}}
    if not radar.apply_snapshot(synthetic):
        _fail("valid D7 snapshot with six canonical stats rejected")
        return
    if radar.dimension_values.size() != 6 or radar.dimension_values != [12.0,24.0,300.0,200.0,400.0,100.0]:
        _fail("visible HS-09 chart must expose only the six canonical stats and omit mind compatibility")
        return
    if radar.chart_ceiling != 400.0 or radar.dimension_values.has(9999.0):
        _fail("non-gameplay mind compatibility changed the visible chart scale")
        return
    var saved_values := radar.dimension_values.duplicate()
    if radar.apply_snapshot({"ok":true,"foundations":{"model_version":3,"current":{"aptitude":1.0}}}):
        _fail("incomplete six-stat foundation snapshot accepted")
        return
    if radar.dimension_values != saved_values:
        _fail("rejected snapshot modified the previously valid canonical chart")
        return
    radar.free()

    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("could not load the live P3.2 scene")
        return
    ui = packed.instantiate() as Control
    if ui == null:
        _fail("could not instantiate the live P3.2 scene")
        return
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or state.disciples.is_empty():
        _fail("New Game authority did not expose disciples")
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    var disciple_id := StringName(ids[0])
    var disciple: DiscipleState = state.disciples[disciple_id]
    var before := disciple.to_dict()
    var snapshot := DisciplePresentationSnapshotV2.build(state,disciple)
    if not bool(snapshot.get("ok",false)):
        _fail("canonical presentation snapshot rejected the selected disciple")
        return
    var v63: Dictionary = snapshot.get("v63",{})
    var gates: Dictionary = v63.get("feature_gates",{})
    for gate in ["sect_codex","technique_learning","human_skill_combat","divine_skill_combat"]:
        if bool(gates.get(gate,true)):
            _fail("legacy New Game unexpectedly enabled V6.3 gate "+gate)
            return
    if disciple.to_dict() != before:
        _fail("adding the V6.3 read projection mutated the disciple")
        return

    var semantic_tabs := ["Tổng Quan","Thuộc tính","Công pháp","Trang bị","Huyết Mạch","Thể Chất","Quan hệ"]
    for tab_name in semantic_tabs:
        var text := str(ui.call("_disciple_tab_text",tab_name,disciple))
        if text.is_empty():
            _fail("profile tab returned empty data: "+tab_name)
            return
    if not str(ui.call("_disciple_tab_text","Tổng Quan",disciple)).contains("Hồ sơ chỉ đọc"):
        _fail("overview omitted its read-only authority marker")
        return

    ui.call("_open_disciple_deep_screen",disciple_id,"Tổng Quan")
    await process_frame
    var popups := ui.get("popup_layer") as Control
    var deep := popups.get_node_or_null("DiscipleDeepScreen") as Panel if popups != null else null
    if deep == null:
        _fail("Tổng Quan did not open the P3.2 disciple profile")
        return
    for index in range(EXPECTED_TABS.size()):
        var button := deep.get_node_or_null("DeepDiscipleTab_%d" % index) as Button
        if button == null or button.text != EXPECTED_TABS[index]:
            _fail("seven-tab navigation is missing or mislabeled at index %d" % index)
            return
    if deep.find_child("HS09OverviewRadar",true,false) == null:
        _fail("overview is missing the compact dual radar")
        return
    var search := deep.find_child("DeepRosterSearch",true,false) as LineEdit
    if search == null:
        _fail("disciple roster search is missing")
        return
    search.text = disciple.display_name
    # Setting LineEdit.text programmatically does not model user typing; emit
    # the public signal so this exercises the same filter callback as the UI.
    search.text_changed.emit(search.text)
    await process_frame
    var roster := deep.find_child("DeepDiscipleRoster",true,false) as VBoxContainer
    if roster == null:
        _fail("search filter lost the roster")
        return
    var matching_visible := false
    for entry in roster.get_children():
        if entry is Button:
            var entry_button := entry as Button
            var matches := str(entry_button.text).to_lower().contains(disciple.display_name.to_lower())
            if matches and entry_button.visible:
                matching_visible = true
            elif not matches and entry_button.visible:
                _fail("roster search left a nonmatching disciple visible")
                return
    if not matching_visible:
        _fail("roster search hid the matching disciple")
        return

    ui.call("_toggle_deep_disciple_roster","Tổng Quan")
    await process_frame
    deep = popups.get_node_or_null("DiscipleDeepScreen") as Panel
    var roster_panel := deep.find_child("DeepDiscipleRosterPanel",true,false) as Panel if deep != null else null
    if roster_panel == null or roster_panel.size.x > 52.0:
        _fail("disciple roster did not collapse to its compact rail")
        return
    ui.call("_toggle_deep_disciple_roster","Tổng Quan")
    await process_frame

    ui.call("_open_disciple_deep_screen",disciple_id,"Thuộc tính")
    await process_frame
    deep = popups.get_node_or_null("DiscipleDeepScreen") as Panel
    if deep == null or deep.find_child("HS09AttributeRadar",true,false) == null:
        _fail("Thuộc Tính tab is missing the large dual radar")
        return
    if deep.find_child("DiscipleFoundationRadar",true,false) == null:
        _fail("backward-compatible existing P3.2 radar probe is missing")
        return
    if disciple.to_dict() != before:
        _fail("opening the read-only HS-09 profile changed game state")
        return

    ui.queue_free()
    await process_frame
    ui = null
    _cleanup()
    print("HS09 DISCIPLE PROFILE / DUAL RADAR / FEATURE-GATE READ MODEL PASS")
    quit(0)
