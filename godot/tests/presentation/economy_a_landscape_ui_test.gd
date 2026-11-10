extends SceneTree

# A genuinely instantiated 1280x720 landscape main scene with Economy-A
# live command buttons; no invented presentation-only Stone balances.
const SAVE_PATH := "user://economy_a_landscape_ui_test.json"
var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for suffix in ["",".bak",".tmp"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("missing landscape scene")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not state.sect.economy_a_enabled:
        _fail("New Game must start with real market-enabled Stone income")
        return
    ui.call("_open_building",SectMapPresentation.DEST_MAIN_HALL)
    await process_frame
    if ui.find_child("EconomyA_RealIncome",true,false) == null:
        _fail("Main Hall lacks receipt-backed Stone income explanation")
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
    # QA-only unpaid historical receipt: the Hall must show and settle real
    # wage debt without injecting currency or overwriting the player Save.
    var economy := EconomySystem.new()
    var disciples: Array = state.disciples.keys()
    disciples.sort()
    if disciples.is_empty():
        _fail("No real disciple to receive wages")
        return
    var worker: DiscipleState = state.disciples[disciples[0]]
    var worker_before := worker.spirit_stones
    var treasury_before := state.sect.spirit_stones
    if treasury_before <= 0 or treasury_before >= 99999:
        _fail("QA treasury not suitable for a bounded partial wage")
        return
    if not bool(economy.configure_v1(state,"wage_per_batch",treasury_before+1).get("ok",false)):
        _fail("Cannot configure wage debt test")
        return
    var owed := economy.settle_work_wage(state,worker,"ui_qa_unpaid_salary_1")
    if not bool(owed.get("ok",false)) or int(economy.unpaid_work_wages(state).get("total",-1)) != treasury_before+1:
        _fail("Wage debt missing before player command")
        return
    ui.call("_open_building",SectMapPresentation.DEST_MAIN_HALL)
    await process_frame
    if not await _press("EconomyA_PayWageArrears"):
        return
    if state.sect.spirit_stones != 0 or worker.spirit_stones != worker_before+treasury_before or int(economy.unpaid_work_wages(state).get("total",-1)) != 1:
        _fail("Hall debt payment did not transfer actual available Stones")
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
