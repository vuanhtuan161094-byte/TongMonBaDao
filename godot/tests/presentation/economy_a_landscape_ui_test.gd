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
    var quote_label := ui.find_child("ECO02Stock_linh_moc",true,false) as Label
    if quote_label == null or not quote_label.text.contains("Dự trữ"):
        _fail("ECO-02 failed to show true stock and reserve on market screen")
        return
    if not await _press("EconomyA_PreviewSell_linh_moc"):
        return
    if state.sect.spirit_stones != before or warehouse.quantity(state,&"linh_moc") != qty:
        _fail("ECO-02 quote button mutated cash or stock before confirmation")
        return
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
    # Real 1280x720 scene exposes a player-activated SX-V55 gate, not a
    # hidden automatic migration of existing production/Save profiles.
    if BuildingSystem.new().sx_v55_bulk_enabled(state):
        _fail("new game unexpectedly activated bulk without the player")
        return
    if not await _press("SXV55_EnableBulk"):
        return
    var bulk := BuildingSystem.new()
    if not bulk.sx_v55_bulk_enabled(state):
        _fail("Hall player button did not activate real Economy-A bulk authority")
        return
    var bulk_button := ui.find_child("SXV55_EnableBulk",true,false) as Button
    if bulk_button == null or not bulk_button.disabled:
        _fail("Hall did not lock repeated activation after legitimate opt-in")
        return
    if not str(ui.call("_mine_operation_text")).contains("×10000"):
        _fail("Mine text still advertises legacy 2-unit batch in bulk mode")
        return
    if not str(ui.call("_linh_forest_operation_text")).contains("×8000"):
        _fail("Forest text still advertises legacy 2-unit batch in bulk mode")
        return
    var field_text := str(ui.call("_spirit_field_operation_text"))
    if not field_text.contains("chu kỳ nền 60 nhịp · sản lượng nền 2500") \
        or not field_text.contains("chu kỳ nền 90 nhịp · sản lượng nền 2000"):
        _fail("Field crop description contradicts real bulk timer and yield")
        return
    var forge_text := str(ui.call("_recipe_material_status",&"thanh_thiet_kiem"))
    if not forge_text.contains("cần 3000") or not forge_text.contains("cần 1000"):
        _fail("Forge panel did not display exact scaled material debits")
        return
    var hall := bulk.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    var selected := StringName(hall.production_state.get("recipe_id","hoi_xuan_dan"))
    var scaled_recipe := bulk.sx_v55_common_requirements(state,
        AlchemyRecipeRegistry.new().inputs(selected))
    var recipe_text := str(ui.call("_alchemy_operation_text"))
    for raw_id in scaled_recipe.keys():
        var name := ResourceRegistry.new().display_name(StringName(raw_id))
        var token := "%s ×%d" % [name,int(scaled_recipe[raw_id])]
        if not recipe_text.contains(token):
            _fail("Alchemy panel misreported real scaled input "+token)
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
