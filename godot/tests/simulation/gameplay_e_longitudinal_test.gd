extends SceneTree

# Real scheduler, one isolated save, cumulative 1/5/10/50/100 simulated hours.
# No gifts, balance changes, artificial resources or real-time playtest claim.
const SAVE_PATH := "user://qa_gameplay_e_longitudinal.json"
const BASE_UNIX := 2000000000

func _init() -> void:
    call_deferred("_run")

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(reason: String) -> void:
    push_error("GAMEPLAY_E_LONGITUDINAL_FAIL "+reason)
    _cleanup()
    quit(1)

func _snapshot(state: SimulationState) -> Dictionary:
    var warehouse := WarehouseSystem.new()
    var xp := 0.0
    var employed := 0
    for raw in state.disciples.values():
        var disciple: DiscipleState = raw
        if not disciple.worksite_building_id.is_empty():
            employed += 1
        for value in disciple.profession_xp.values():
            xp += float(value)
    var economy := EconomySystem.new()
    var cash := economy.daily_market_cashflow(state)
    var production_batches := 0
    var max_cultivation := 0
    var max_body := 0
    var v2_ready := 0
    var cultivation_xp := 0.0
    var body_xp := 0.0
    for raw in state.buildings.values():
        var building: BuildingState = raw
        production_batches += int(building.metrics.get("production_batches",0))
    for raw in state.disciples.values():
        var d: DiscipleState = raw
        var current := DiscipleRealmProgressV2.current(d)
        if bool(current.get("ok",false)):
            v2_ready += 1
            cultivation_xp += float(current["cultivation"]["xp"])
            body_xp += float(current["body"]["xp"])
            max_cultivation = maxi(max_cultivation,int(current["cultivation_global_floor"]))
            max_body = maxi(max_body,int(current["body_global_floor"]))
    return {"tick":state.tick,"disciples":state.disciples.size(),"buildings":state.buildings.size(),
        "production_batches":production_batches,"max_cultivation":max_cultivation,"max_body":max_body,"v2_ready":v2_ready,"cultivation_xp":cultivation_xp,"body_xp":body_xp,
        "wage_arrears":int(economy.unpaid_work_wages(state).get("total",0)),
        "daily_net_recorded":int(cash.get("net_recorded",0)),
        "daily_income":int(cash.get("income",0))+int(cash.get("origin_income",0)),
        "daily_wages":int(cash.get("wages",0)),
        "employed":employed,"stones":state.sect.spirit_stones,"treasury":state.sect.treasury,
        "iron":warehouse.quantity(state,&"thanh_thiet"),"wood":warehouse.quantity(state,&"linh_moc"),
        "economy_receipts":state.sect.economy_a_receipts.size(),"profession_xp":xp}

func _run() -> void:
    _cleanup()
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(SAVE_PATH,BASE_UNIX,28112026)
    if not bool(opened.get("ok",false)) or not bool(opened.get("created",false)):
        _fail("new game "+str(opened))
        return
    var initial := _snapshot(runtime.state())
    print("GAMEPLAY_E_BASELINE "+JSON.stringify(initial))
    if int(initial["v2_ready"]) != int(initial["disciples"]) or int(initial["max_cultivation"]) != 1 or int(initial["max_body"]) != 1:
        _fail("new-game founders are not authentic realm-one V2 disciples")
        return
    var previous_hour := 0
    var previous_tick := int(initial["tick"])
    for hour in [1,5,10,50,100]:
        var now := BASE_UNIX+int(hour)*3600
        var resumed := LiveGameRuntimeV2.new()
        var result := resumed.start(SAVE_PATH,now,28112026)
        if not bool(result.get("ok",false)) or not bool(result.get("loaded",false)):
            _fail("resume at "+str(hour)+" "+str(result))
            return
        var state := resumed.state()
        var current := _snapshot(state)
        # Simulate one conservative owner sale at each checkpoint, using only
        # stock above the starting reserve and the actual market quote.
        var economy := EconomySystem.new()
        var warehouse := WarehouseSystem.new()
        for resource in [&"thanh_thiet",&"linh_moc"]:
            var starting := int(initial["iron"] if resource == &"thanh_thiet" else initial["wood"])
            if warehouse.quantity(state,resource) <= starting:
                continue
            var quote := economy.sell_quote_v1(state,resource,1)
            if not bool(quote.get("ok",false)):
                continue
            var before_stones := state.sect.spirit_stones
            var before_stock := warehouse.quantity(state,resource)
            var request := "gameplay_e3_sale_%d_%s" % [int(hour),str(resource)]
            var paid := economy.sell_to_npc_v1(state,resource,1,request)
            if not bool(paid.get("ok",false)) or state.sect.spirit_stones != before_stones+int(quote["earned"]) or warehouse.quantity(state,resource) != before_stock-1:
                _fail("market sale mismatch "+request)
                return
            var repeated := economy.sell_to_npc_v1(state,resource,1,request)
            if not bool(repeated.get("already_settled",false)) or state.sect.spirit_stones != before_stones+int(quote["earned"]):
                _fail("duplicate market sale "+request)
                return
            print("GAMEPLAY_E3_MARKET "+JSON.stringify({"hour":hour,"resource":str(resource),"earned":quote["earned"]}))
        current = _snapshot(state)
        var expected_steps := (int(hour)-previous_hour)*60
        if int(result.get("catch_up_steps",-1)) != expected_steps or state.tick != previous_tick+expected_steps:
            _fail("clock mismatch at "+str(hour)+" "+str(result))
            return
        if not state.validate_invariants().is_empty() or int(current["stones"]) < 0 or int(current["iron"]) < 0 or int(current["wood"]) < 0:
            _fail("invalid economy or state at "+str(hour)+" "+str(state.validate_invariants()))
            return
        if not bool(resumed.save(now).get("ok",false)):
            _fail("save at "+str(hour))
            return
        var reopened := LiveGameRuntimeV2.new()
        var cold := reopened.start(SAVE_PATH,now,28112026)
        if not bool(cold.get("ok",false)) or int(cold.get("catch_up_steps",-1)) != 0:
            _fail("same-time reload replay at "+str(hour))
            return
        var after := _snapshot(reopened.state())
        for key in current:
            if not is_equal_approx(float(current[key]),float(after.get(key,-1))):
                _fail("same-time reload changed "+str(key)+" at "+str(hour))
                return
        if int(current["v2_ready"]) != int(current["disciples"]):
            _fail("V2 identity disappeared at "+str(hour))
            return
        if int(hour) == 100:
            if int(current["max_cultivation"]) <= int(initial["max_cultivation"]) and float(current["cultivation_xp"]) <= 0.0:
                _fail("no earned cultivation growth after 100 hours")
                return
            if int(current["max_body"]) <= int(initial["max_body"]) and float(current["body_xp"]) <= 0.0:
                _fail("no earned body growth after 100 hours")
                return
        print("GAMEPLAY_E_MILESTONE "+JSON.stringify({"hours":hour,"metrics":current,"source_sha":OS.get_environment("GITHUB_SHA")}))
        previous_tick = state.tick
        previous_hour = int(hour)
    _cleanup()
    print("GAMEPLAY_E_LONGITUDINAL_PASS cumulative simulated hours 1/5/10/50/100; default starter policy, no injected resources")
    quit(0)
