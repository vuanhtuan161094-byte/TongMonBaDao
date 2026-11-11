extends SceneTree

# ECO06 real 1280x720 OneGame UI. The display may read canonical state,
# but never credits Stone, writes receipt, changes jobs or fabricates stock.
const SAVE_PATH := "user://eco06_real_economy_ui_test.json"
var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("OneGame landscape scene unavailable")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not state.sect.economy_a_enabled:
        _fail("New Game canonical Economy-A unavailable")
        return
    var stones := state.sect.spirit_stones
    var warehouse := WarehouseSystem.new()
    var ore := warehouse.quantity(state,&"thanh_thiet")
    var wood := warehouse.quantity(state,&"linh_moc")
    var receipts := state.sect.economy_a_receipts.size()
    ui.call("_open_building",SectMapPresentation.DEST_MAIN_HALL)
    await process_frame
    var hall := ui.find_child("EconomyA_RealIncome",true,false) as Label
    if hall == null or hall.text != str(ui.call("_eco06_cashflow_text")) \
            or not hall.text.contains("SỔ THU CHI") \
            or not hall.text.contains("Lương đã trả") \
            or not hall.text.contains("Quỹ hiện có: %d LT" % stones):
        _fail("Hall missing real partial income/cost/treasury summary")
        return
    for item in [
        [SectMapPresentation.DEST_MINE,BuildingSystem.TYPE_MINE],
        [SectMapPresentation.DEST_LINH_FOREST,BuildingSystem.TYPE_LINH_FOREST],
        [SectMapPresentation.DEST_SPIRIT_FIELD,BuildingSystem.TYPE_SPIRIT_FIELD]
    ]:
        ui.call("_open_building",item[0])
        await process_frame
        var building := BuildingSystem.new().primary_building(state,item[1])
        var view := ui.find_child("ECO06WorksiteSummary",true,false) as Label
        if building == null or view == null \
                or view.text != str(ui.call("_eco06_site_text",building)) \
                or not view.text.contains("NHÂN CÔNG") \
                or not view.text.contains("TIẾN ĐỘ") \
                or not view.text.contains("LT2/W2/T2 nâng cao: CHƯA MỞ") \
                or ui.find_child("CanonicalWorksiteProgress",true,false) == null:
            _fail("Worksite %s lacks real worker/ETA/canonical progress" % str(item[1]))
            return
        if item[1] == BuildingSystem.TYPE_SPIRIT_FIELD:
            var description := str(ui.call("_spirit_field_operation_text"))
            var crops := SpiritCropRegistry.new()
            for raw_id in crops.eligible_crop_ids(building.level):
                var crop_id := StringName(raw_id)
                var cost := crops.cost(crop_id)
                var prefix := "%s · phí %d LT" % [crops.display_name(crop_id),cost]
                var expected_mark := "ĐỦ PHÍ" if stones >= cost else "THIẾU LT"
                var found := false
                for line in description.split("\n",false):
                    if prefix in line and expected_mark in line and "chu kỳ nền" in line:
                        found = true
                        break
                if not found:
                    _fail("Field affordability is not derived from actual Stone balance for "+str(crop_id))
                    return
    ui.call("_open_building",SectMapPresentation.DEST_WAREHOUSE)
    await process_frame
    var market := ui.find_child("ECO06MarketSummary",true,false) as Label
    if market == null or market.text != str(ui.call("_eco06_market_text")) \
            or not market.text.contains("Bán đã thu") \
            or not market.text.contains("Hạn mức còn"):
        _fail("Market omitted real-sale and buyer capacity readout")
        return
    var warehouse_text := str(ui.call("_warehouse_operation_text"))
    if not warehouse_text.contains("dùng được") \
            or not warehouse_text.contains("Chênh lệch từ các biên nhận"):
        _fail("Warehouse failed to distinguish owned/usable goods and cashflow")
        return
    if state.sect.spirit_stones != stones \
            or warehouse.quantity(state,&"thanh_thiet") != ore \
            or warehouse.quantity(state,&"linh_moc") != wood \
            or state.sect.economy_a_receipts.size() != receipts \
            or not state.validate_invariants().is_empty():
        _fail("UI-only readout generated money, inventory or receipts")
        return
    _cleanup()
    print("ECO06 1280x720 LIVE HALL/WORKSITES/MARKET/WAREHOUSE READOUTS WITHOUT ECONOMY WRITES: PASS")
    quit(0)

func _cleanup() -> void:
    if ui != null and is_instance_valid(ui):
        root.remove_child(ui)
        ui.queue_free()
        ui = null
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    for suffix in ["",".bak",".tmp"]:
        var path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(reason: String) -> void:
    push_error("ECO06 ACTUAL UI FAIL: "+reason)
    _cleanup()
    quit(1)
