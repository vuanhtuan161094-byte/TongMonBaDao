extends SceneTree

# PR27 isolated presentation gate. Run with official Godot 4.7.2 and a
# fresh user data directory. This test must not grant items, XP or rewards.
const TEST_SAVE_PATH := "user://tmb_pr27_ui_readability_test.json"
var ui: Control

func _init() -> void:
    call_deferred("_run")

func _cleanup() -> void:
    if ui != null and is_instance_valid(ui):
        ui.queue_free()
    if FileAccess.file_exists(TEST_SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> void:
    push_error("PR27 UI: " + message)
    _cleanup()
    quit(1)

func _run() -> void:
    ProjectSettings.set_setting("runtime/live_save_path",TEST_SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("P3.2 scene is missing.")
        return
    ui = packed.instantiate() as Control
    root.add_child(ui)
    await process_frame
    if not bool(ui.get("runtime_ready")):
        _fail("P3.2 live runtime did not initialize.")
        return

    var main_state := ui.get("state") as SimulationState
    if main_state == null:
        _fail("No authoritative SimulationState available.")
        return

    var building_panel := ui.get("building_operation_panel") as Panel
    if building_panel == null:
        _fail("No real building operation panel.")
        return
    var close_button := building_panel.get_node_or_null("CloseBuildingOperation") as Button
    if close_button == null or close_button.size.x < 44.0 or close_button.size.y < 44.0:
        _fail("Building close tap target is too small.")
        return

    ui.call("_open_building",SectMapPresentation.DEST_MINE)
    await process_frame
    if not building_panel.visible:
        _fail("Real Mine operation panel did not open.")
        return
    var body := ui.get("building_operation_body") as Label
    if body == null or not body.text.contains("SẢN XUẤT"):
        _fail("Mine read-model was not displayed.")
        return
    if body.text.contains("NHÂN SỰ"):
        _fail("Mine duplicated the roster above its actual action controls.")
        return
    if body.custom_minimum_size.y > 200.0:
        _fail("Production summary still reserves a full-height empty block.")
        return

    var roster := ui.get("building_management_container") as VBoxContainer
    var found_role := false
    if roster != null:
        for row in roster.get_children():
            if not str(row.name).begins_with("Person_"):
                continue
            var member_label := row.get_child(0) as Label
            if member_label != null and (
                member_label.text.contains("ĐANG LÀM")
                or member_label.text.contains("TRONG ĐỘI")
                or member_label.text.contains("CHƯA PHÂN ĐỘI")
            ):
                found_role = true
                break
    if not found_role:
        _fail("Actual assignment roster does not distinguish worker roles.")
        return

    ui.call("_close_building_operation_panel",true)
    await process_frame
    if building_panel.visible:
        _fail("Building panel did not close.")
        return

    var all_ids: Array = main_state.disciples.keys()
    if all_ids.is_empty():
        _fail("Seed state contains no real disciple for profile verification.")
        return
    var disciple_id := StringName(all_ids[0])
    ui.call("_open_disciple_deep_screen",disciple_id,"Thuộc tính")
    await process_frame
    var popups := ui.get("popup_layer") as Control
    var profile := popups.get_node_or_null("DiscipleDeepScreen") as Panel
    if profile == null:
        _fail("Authentic V2 disciple profile failed to open.")
        return
    var profile_text := _find_named(profile,"DiscipleTabContentText") as Label
    if profile_text == null or profile_text.get_theme_font_size("font_size") < 14:
        _fail("Profile value column has unreadable font or missing facts.")
        return
    var radar := _find_named(profile,"DiscipleFoundationRadar") as DiscipleSixDimensionRadar
    if radar == null:
        _fail("Foundation radar is absent from real attribute tab.")
        return
    var snapshot := DisciplePresentationSnapshotV2.build(main_state,main_state.disciples[disciple_id])
    if bool(snapshot.get("ok",false)):
        var version := int(snapshot.get("foundations",{}).get("model_version",1))
        if version >= FoundationSystem.MODEL_D7 and radar.dimension_values.size() != 7:
            _fail("D7 profile lost one of its seven true axes.")
            return

    var hunt_facts := ui.get("b3_hunt_facts") as Label
    if hunt_facts == null or hunt_facts.get_theme_font_size("font_size") < 14:
        _fail("Combat V2/CARE HUD facts panel is not readable.")
        return

    _cleanup()
    print("TMB PR27 UI READABILITY: PASS")
    quit(0)

func _find_named(node: Node, wanted: String) -> Node:
    if node.name == wanted:
        return node
    for child in node.get_children():
        var found := _find_named(child,wanted)
        if found != null:
            return found
    return null
