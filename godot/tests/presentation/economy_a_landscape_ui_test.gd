extends SceneTree

# A genuinely instantiated 1280x720 landscape main scene with Economy-A
# live command buttons; no invented presentation-only Stone balances.
const SAVE_PATH := "user://economy_a_landscape_ui_test.json"
var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("missing landscape scene")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or state.sect.economy_a_enabled:
        _fail("invalid original fresh-state economy toggle")
        return
    ui.call("_open_building",SectMapPresentation.DEST_MAIN_HALL)
    await process_frame
    if not await _press("EconomyA_Enable"):
        return
    if not state.sect.economy_a_enabled:
        _fail("Economy-A UI button did not change saved simulation authority")
        return
    if not await _press("EconomyA_AutoSpendLimit"):
        return
    if int(state.sect.economy_a_policy.get("auto_hp_daily_stone_limit",-1)) != 12:
        _fail("Main Hall did not change canonical personal spending limit")
        return
    var before := state.sect.spirit_stones
    var warehouse := WarehouseSystem.new()
    var qty := warehouse.quantity(state,&"linh_moc")
    ui.call("_open_building",SectMapPresentation.DEST_WAREHOUSE)
    await process_frame
    if not await _press("EconomyA_Sell_linh_moc"):
        return
    if not (state.sect.spirit_stones > before and warehouse.quantity(state,&"linh_moc") < qty):
        _fail("Economy-A Phuong Thi UI did not settle actual stock and Stones")
        return
    var market_before := int(state.sect.economy_a_market_stock.get("linh_moc",0))
    var stones_before_buy := state.sect.spirit_stones
    var wood_before_buy := warehouse.quantity(state,&"linh_moc")
    if not await _press("EconomyA_Buy_linh_moc"):
        return
    if not (state.sect.spirit_stones < stones_before_buy
        and warehouse.quantity(state,&"linh_moc") > wood_before_buy
        and int(state.sect.economy_a_market_stock.get("linh_moc",0)) < market_before):
        _fail("Economy-A Phuong Thi UI buy did not settle real stock and Stones")
        return
    ui.call("_open_building",SectMapPresentation.DEST_MINE)
    await process_frame
    var body := ui.find_child("BuildingOperationBody",true,false) as Label
    var controls := ui.find_child("BuildingManagementControls",true,false) as VBoxContainer
    if body == null or controls == null or body.custom_minimum_size.y > 0:
        _fail("Mine controls still sit behind the old 420px spacer")
        return
    var checked_rows := 0
    for node in controls.get_children():
        if not (node is GridContainer) or not str(node.name).begins_with("Person_"):
            continue
        checked_rows += 1
        var row := node as GridContainer
        if row.columns != 2:
            _fail("Disciple controls no longer wrap into two columns")
            return
        var name := row.get_child(0) as Label
        if name == null or name.get_theme_color("font_color").get_luminance() > 0.45:
            _fail("Disciple name lost readable ink color")
            return
        for child in row.get_children():
            if child is Button and child.position.x + child.size.x > row.size.x + 1.0:
                _fail("Mine worker action extends past the management row")
                return
    if checked_rows == 0:
        _fail("Mine worker management rows are missing")
        return
    var search := ui.find_child("BuildingDiscipleSearch",true,false) as LineEdit
    if search == null:
        _fail("Mine worker search is missing")
        return
    var target_id := str(state.disciples.keys()[0])
    search.emit_signal("text_submitted",target_id)
    await process_frame
    controls = ui.find_child("BuildingManagementControls",true,false) as VBoxContainer
    var filtered_rows := 0
    for node in controls.get_children():
        if node is GridContainer and str(node.name).begins_with("Person_"):
            filtered_rows += 1
            if str(node.name) != "Person_%s" % target_id:
                _fail("Mine search returned an unrelated disciple")
                return
    if filtered_rows != 1:
        _fail("Mine search did not narrow worker rows to the requested ID")
        return
    var v2_profile_checked := false
    for raw_id in state.disciples.keys():
        var actor: DiscipleState = state.disciples[raw_id]
        if not DiscipleRealmProgressV2.owns_v2_progression(actor):
            continue
        var snapshot := DisciplePresentationSnapshotV2.build(state,actor)
        var professions: Dictionary = snapshot["work"]["professions"]
        var mining: Dictionary = professions[str(WorkforceSystem.PROF_MINING)]
        var profile_text := str(ui.call("_attributes_tab_text",actor))
        if not profile_text.contains("Khai Khoáng Lv%d · EXP %.1f" % [
            int(mining["level"]), float(mining["xp"])
        ]):
            _fail("Authentic V2 profile omitted canonical Mining level or EXP")
            return
        v2_profile_checked = true
        break
    if not v2_profile_checked:
        _fail("Fresh landscape state has no authentic V2 profile to verify")
        return
    var result := state.validate_invariants()
    if not result.is_empty():
        _fail("Economy-A real landscape state violated invariants: %s" % str(result))
        return
    print("ECONOMY-A LANDSCAPE MAIN HALL + PHUONG THI REAL COMMANDS: PASS")
    _dispose()
    quit(0)

func _press(name: String) -> bool:
    var button := ui.find_child(name,true,false) as Button
    if button == null or button.disabled:
        _fail("Missing enabled UI control "+name)
        return false
    button.emit_signal("pressed")
    await process_frame
    return true

func _dispose() -> void:
    if ui != null and is_instance_valid(ui):
        root.remove_child(ui)
        ui.queue_free()
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    for name in [SAVE_PATH,SAVE_PATH+".bak",SAVE_PATH+".tmp"]:
        if FileAccess.file_exists(name):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(name))

func _fail(message: String) -> void:
    push_error("ECONOMY-A UI FAIL: "+message)
    _dispose()
    quit(1)
