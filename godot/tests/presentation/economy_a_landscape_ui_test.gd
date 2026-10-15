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
