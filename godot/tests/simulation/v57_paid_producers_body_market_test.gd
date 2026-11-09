extends SceneTree

# Test-only initial resources are deliberately provisioned by QA. Gameplay
# annexes and market must still debit the canonical Warehouse and Stones.
const SAVE_PATH := "user://v57_paid_producers_body_market.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(570011)
    var buildings := BuildingSystem.new()
    var warehouse := WarehouseSystem.new()
    var economy := EconomySystem.new()
    if not bool(SectHallSystemV1.ensure_live(state).get("ok",false)):
        _fail("main hall not initialized")
        return
    if not bool(economy.enable_v1(state).get("ok",false)):
        _fail("Economy-A not enabled")
        return
    state.sect.spirit_stones = 200000
    if not warehouse.add(state,&"linh_moc",500) or not warehouse.add(state,&"thanh_thiet",500):
        _fail("QA stock provisioning failed")
        return
    var before_stones := state.sect.spirit_stones
    var before_wood := warehouse.quantity(state,&"linh_moc")
    var before_ore := warehouse.quantity(state,&"thanh_thiet")
    var built := buildings.build_paid_production_annex(state,BuildingSystem.TYPE_MINE,"qa-mine-2")
    if not bool(built.get("ok",false)) or bool(built.get("already_settled",true)):
        _fail("paid mine was not built")
        return
    var cost: Dictionary = built["cost"]
    if state.sect.spirit_stones != before_stones-int(cost["spirit_stones"])             or warehouse.quantity(state,&"linh_moc") != before_wood-int(cost["linh_moc"])             or warehouse.quantity(state,&"thanh_thiet") != before_ore-int(cost["thanh_thiet"]):
        _fail("paid annex cost not debited exactly")
        return
    var replay := buildings.build_paid_production_annex(state,BuildingSystem.TYPE_MINE,"qa-mine-2")
    if not bool(replay.get("already_settled",false)) or state.sect.spirit_stones != before_stones-int(cost["spirit_stones"]):
        _fail("duplicate producer charge")
        return
    if bool(buildings.build_paid_production_annex(state,BuildingSystem.TYPE_LINH_FOREST,"qa-mine-2").get("ok",false)):
        _fail("conflicting build request reused")
        return
    for kind in [BuildingSystem.TYPE_LINH_FOREST,BuildingSystem.TYPE_SPIRIT_FIELD,BuildingSystem.TYPE_ALCHEMY_HALL]:
        var additional := buildings.build_paid_production_annex(state,kind,"qa-"+str(kind))
        if not bool(additional.get("ok",false)):
            _fail("paid producer unavailable: "+str(kind))
            return
    if not buildings.validate_invariants(state).is_empty():
        _fail("producer invariant failure")
        return
    economy.sync_market_day(state)
    var material := &"huyet_thu_tinh_huyet"
    var price := economy.market_purchase_price(state,material)
    if price <= 0 or economy.market_sell_price(material) != 0             or not EconomySystem.body_gate_source_available(state,7):
        _fail("advanced Body materials have no paid market source")
        return
    var stones := state.sect.spirit_stones
    var stock := warehouse.quantity(state,material)
    var bought := economy.buy_from_npc_v1(state,material,2,"qa-body-material")
    if not bool(bought.get("ok",false)) or bool(bought.get("already_settled",true))             or state.sect.spirit_stones != stones-price*2             or warehouse.quantity(state,material) != stock+2:
        _fail("NPC Body material purchase is not atomic")
        return
    var duplicate_buy := economy.buy_from_npc_v1(state,material,2,"qa-body-material")
    if not bool(duplicate_buy.get("already_settled",false)) or state.sect.spirit_stones != stones-price*2:
        _fail("NPC market replay duplicated payment")
        return
    if not economy.validate_v1(state).is_empty():
        _fail("market invariants failed")
        return
    var save := SaveService.new()
    if save.save_to_path(state,SAVE_PATH) != OK:
        _fail("save failed")
        return
    var loaded := save.load_from_path(SAVE_PATH)
    if loaded == null or loaded.buildings.size() != state.buildings.size()             or loaded.sect.spirit_stones != state.sect.spirit_stones             or warehouse.quantity(loaded,material) != warehouse.quantity(state,material):
        _fail("paid buildings/market cold reload mismatch")
        return
    if not bool(buildings.build_paid_production_annex(loaded,BuildingSystem.TYPE_MINE,"qa-mine-2").get("already_settled",false)):
        _fail("building replay lost after reload")
        return
    if not bool(economy.buy_from_npc_v1(loaded,material,2,"qa-body-material").get("already_settled",false)):
        _fail("market replay lost after reload")
        return
    _cleanup()
    print("V57 PAID PRODUCERS + BODY MARKET + COLD RELOAD PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error("V57 PAID PRODUCERS / BODY MARKET FAIL: "+message)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
