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
    return {"tick":state.tick,"disciples":state.disciples.size(),"buildings":state.buildings.size(),
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
        print("GAMEPLAY_E_MILESTONE "+JSON.stringify({"hours":hour,"metrics":current,"source_sha":OS.get_environment("GITHUB_SHA")}))
        previous_tick = state.tick
        previous_hour = int(hour)
    _cleanup()
    print("GAMEPLAY_E_LONGITUDINAL_PASS cumulative simulated hours 1/5/10/50/100; default starter policy, no injected resources")
    quit(0)
