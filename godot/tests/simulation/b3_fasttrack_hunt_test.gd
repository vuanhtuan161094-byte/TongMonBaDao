extends SceneTree

var checks := 0
const START := 1800000000
const ROOT := "user://b3_fasttrack_test_"

class RejectSave:
    extends SaveService
    func save_to_path(_state: SimulationState, _path: String) -> Error:
        return ERR_CANT_CREATE

func _init() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> bool:
    checks += 1
    if not ok:
        push_error("B3 FASTTRACK FAIL: "+label)
    return ok

func fresh(name: String) -> Dictionary:
    var path := ROOT+name+".json"
    for suffix in ["",".bak",".tmp"]:
        if FileAccess.file_exists(path+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))
    var runtime := LiveGameRuntimeV2.new()
    if not check(runtime.start(path,START,930211)["ok"],name+" LiveGameRuntime start"):
        return {}
    var setup := B3DemoSetup.prepare(runtime)
    if not check(setup["ok"],name+" genuine recruitment + craft: "+str(setup)):
        return {}
    return {"runtime":runtime,"id":setup["disciple_id"],"path":path}

func drain(owner: SimulationRuntimeOwnerV2, now: int) -> bool:
    for i in range(1000):
        var result := owner.update_to(now,10)
        if not result["ok"]:
            return check(false,"clock drain: "+str(result))
        if owner.state.runtime_unconsumed_wall_seconds < 0.25:
            return true
    return check(false,"bounded catch-up did not drain")

func canonical(state: SimulationState) -> Dictionary:
    var data := state.to_dict()
    var restored := B3HuntWorld.restore(state)
    var battle: MapBattleV2 = restored["battle"]
    battle.events.clear()
    data["sect"]["b3_hunt"]["battle"] = MapBattleSnapshotV2.save(battle)
    return data

func differences(a: Variant, b: Variant, path: String = "") -> void:
    if a == b: return
    if a is Dictionary and b is Dictionary:
        for key in a:
            if not b.has(key): print("DIFF missing ",path,"/",key)
            else: differences(a[key],b[key],path+"/"+str(key))
        for key in b:
            if not a.has(key): print("DIFF added ",path,"/",key)
    elif a is Array and b is Array and a.size() == b.size():
        for i in range(a.size()): differences(a[i],b[i],path+"/"+str(i))
    else: print("DIFF ",path," ",str(a).left(120)," -> ",str(b).left(120))

# Existing JSON nested content may normalize integer Variant tags to float;
# compare every value exactly, including opaque PH0 RNG/HP/cast snapshot bytes.
func same(a: Variant, b: Variant) -> bool:
    if a is Dictionary and b is Dictionary:
        if a.size() != b.size(): return false
        for key in a:
            if not b.has(key) or not same(a[key],b[key]): return false
        return true
    if a is Array and b is Array:
        if a.size() != b.size(): return false
        for i in range(a.size()):
            if not same(a[i],b[i]): return false
        return true
    return a == b

func _run() -> void:
    if not main_loop() or not crash_retry() or not pending_and_invalid() or not command_catch_up_guard():
        quit(1)
        return
    print("B3 FASTTRACK REAL HUNT + CANONICAL WAREHOUSE + SAVE/LOAD + CRASH/RETRY + CLOCK PASS (%d checks)" % checks)
    quit(0)

func main_loop() -> bool:
    var fx := fresh("main")
    if fx.is_empty(): return false
    var runtime: LiveGameRuntimeV2 = fx["runtime"]
    var owner := runtime.owner
    var state := runtime.state()
    var d: DiscipleState = state.disciples[fx["id"]]
    if not check(DiscipleRealmProgressV2.progression_ready(d) and not d.equipped_items.is_empty() and bool(d.learned_combat_skills.get("thanh_phong_tram",false)),"authentic V2 + actual learned/equipped loadout"): return false
    d.injury_level = 1
    if not check(not B3HuntWorld.begin(owner,d.id)["ok"],"injured admission rejected"): return false
    d.injury_level = 0
    d.current_action = &"CULTIVATE"
    if not check(not B3HuntWorld.begin(owner,d.id)["ok"],"training admission rejected"): return false
    d.current_action = &"HOLD"
    d.work_cycle_state = {"phase":"TRAVEL"}
    if not check(not B3HuntWorld.begin(owner,d.id)["ok"],"reserved production rejected"): return false
    d.work_cycle_state.clear()
    d.active_pve_encounter_id = "old_pve"
    if not check(not B3HuntWorld.begin(owner,d.id)["ok"],"old PvE reservation rejected"): return false
    d.active_pve_encounter_id = ""
    var baseline := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)
    var xp_before := float(d.v2_realm_progress["cultivation"]["xp"])
    var minute_rate := float(DiscipleTuViFlowV2.preview_rate(state,d)["effective_tuvi_per_minute"])
    if not check(B3HuntWorld.begin(owner,d.id)["ok"],"real world admitted"): return false
    var world_id := str(state.sect.b3_hunt["world_id"])
    if not check(not WorkforceSystem.new().perform_work(state,d,WorkforceSystem.PROF_MINING)["ok"],"B3 reserves canonical work guard"): return false
    if not check(not WorkforceSystem.new().issue_command(state,d.id,WorkforceSystem.COMMAND_HOLD,"",20),"commands cannot steal B3 actor"): return false
    var preview_count := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)
    B3HuntWorld.restore(state)["battle"].summary()
    if not check(preview_count == baseline,"preview has no payout"): return false
    # Real fighting only: no injected damage or stat/HP mutation.
    for second in range(1,121):
        if not drain(owner,START+second): return false
        if second == 17:
            var before := canonical(owner.state)
            var reloaded := LiveGameRuntimeV2.new()
            if not check(reloaded.start(str(fx["path"]),START+second)["ok"],"mid-fight real disk reload"): return false
            runtime = reloaded
            owner = runtime.owner
            state = runtime.state()
            d = state.disciples[fx["id"]]
            if not same(canonical(state),before): differences(before,canonical(state))
            if not check(same(canonical(state),before),"mid-fight RNG/HP/cast/slot/receipt/clock exact"): return false
    var battle: MapBattleV2 = B3HuntWorld.restore(state)["battle"]
    var killed := int(state.sect.b3_hunt["slot"]["paid_generation"])
    var gained := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)-baseline
    print("B3 REAL RUN world=%s seconds=%.2f kills=%d warehouse_delta=%d generation=%d injury=%d" % [world_id,battle.now,killed,gained,state.sect.b3_hunt["slot"]["generation"],d.injury_level])
    if not check(battle.now == 120.0 and battle.active and battle.encounter_id == world_id,"same living world beyond 90 seconds"): return false
    if not check(killed >= 1 and gained == killed,"true kills credit exact registered material into same Warehouse"): return false
    if not check(battle.events.size() <= 96 and battle.pending_kill_events().is_empty(),"bounded disposable events; domain ACK only after save"): return false
    if not check(state.validate_invariants().is_empty(),"canonical invariants: "+str(state.validate_invariants())): return false
    if not check(absf(float(d.v2_realm_progress["cultivation"]["xp"])-xp_before-2.0*minute_rate) < 0.0000001,"only two canonical minute Tu Vi grants; no kill XP"): return false
    # Same seed/state, one offline interval vs viewed/compacted online polling.
    var off := fresh("offline")
    if off.is_empty(): return false
    var offline: LiveGameRuntimeV2 = off["runtime"]
    if not check(B3HuntWorld.begin(offline.owner,off["id"])["ok"],"offline world begin"): return false
    if not drain(offline.owner,START+120): return false
    if not same(canonical(state),canonical(offline.state())): differences(canonical(state),canonical(offline.state()))
    if not check(same(canonical(state),canonical(offline.state())),"online/offline same state, ordering, rewards, passive Tu Vi"): return false
    # Natural defeat revives FULL HP + Injury1, without world teardown.
    if d.injury_level == 0:
        if not drain(owner,START+600): return false
    state = owner.state
    d = state.disciples[fx["id"]]
    if not check(d.injury_level == 1 and is_equal_approx(d.hp,d.max_hp) and d.region_id == &"sect" and d.active_pve_encounter_id.is_empty(),"natural defeat -> Sect full HP Injury1"): return false
    var until := d.injury_recover_at_tick
    var lifespan := d.max_lifespan
    var returned: Dictionary = state.sect.b3_hunt["last_return"].duplicate(true)
    if not check(WorkforceSystem.new().issue_command(state,d.id,WorkforceSystem.COMMAND_REST,"",1000000),"real resting command permitted during Injury"): return false
    d.current_action = &"EVALUATE"
    while state.tick < until-1:
        WorkforceSystem.new().issue_command(state,d.id,WorkforceSystem.COMMAND_REST,"",1000000)
        if not drain(owner,state.runtime_last_wall_unix+60): return false
    if not check(d.injury_level == 1,"injury not cleared before exact 120 ticks"): return false
    if not drain(owner,state.runtime_last_wall_unix+60): return false
    if not check(d.injury_level == 0 and d.injury_recover_at_tick == 0 and d.max_lifespan == lifespan and state.sect.b3_hunt["last_return"] == returned,"120 tick recovery, no duplicate Injury or lifespan penalty"): return false
    for minute in range(300):
        if d.hp >= d.max_hp: break
        WorkforceSystem.new().issue_command(state,d.id,WorkforceSystem.COMMAND_REST,"",1000000)
        if not [&"EVALUATE",&"REST"].has(d.current_action): d.current_action = &"EVALUATE"
        if not drain(owner,state.runtime_last_wall_unix+60): return false
    if not check(d.hp == d.max_hp,"rest restores real HP before re-entry"): return false
    WorkforceSystem.new().issue_command(state,d.id,WorkforceSystem.COMMAND_HOLD,"",1000000)
    d.current_action = &"HOLD"
    if not check(B3HuntWorld.begin(owner,d.id)["ok"],"re-admission preserves existing world"): return false
    if not drain(owner,state.runtime_last_wall_unix+120): return false
    killed = int(state.sect.b3_hunt["slot"]["paid_generation"])
    gained = WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)-baseline
    battle = B3HuntWorld.restore(state)["battle"]
    print("B3 COMPLETE LOOP same_world=%s seconds=%.2f real_kills=%d canonical_warehouse_delta=%d" % [world_id,battle.now,killed,gained])
    if not check(killed >= 3 and gained == killed,"3+ consecutive generations, real rewards across recovery/re-entry without world reset"): return false
    return check(str(state.sect.b3_hunt["world_id"]) == world_id,"world identity survives defeat/recovery/re-entry")

func crash_retry() -> bool:
    var fx := fresh("crash")
    if fx.is_empty(): return false
    var owner: SimulationRuntimeOwnerV2 = fx["runtime"].owner
    if not check(B3HuntWorld.begin(owner,fx["id"])["ok"],"crash fixture begin"): return false
    var baseline := WarehouseSystem.new().quantity(owner.state,B3PilotContent.RESOURCE)
    # BEFORE HP0 durable save is the initial battle. Drop the first transaction
    # AFTER Warehouse.add but BEFORE SaveService publish.
    owner.saves = RejectSave.new()
    var rejected := owner.update_to(START+120)
    if not check(not rejected["ok"] and rejected.get("reason","") == "b3_save_barrier_failed","injected save failure surfaced"): return false
    if not check(WarehouseSystem.new().quantity(owner.state,B3PilotContent.RESOURCE) == baseline+1,"failure is after actual Warehouse.add"): return false
    var disk := SaveService.new().load_from_path(str(fx["path"]))
    if not check(WarehouseSystem.new().quantity(disk,B3PilotContent.RESOURCE) == baseline,"pre-publish crash cannot leak payout to disk"): return false
    var reopened := SimulationRuntimeOwnerV2.new()
    if not check(reopened.load_from_path(str(fx["path"]),START+120)["ok"],"reopen durable pre-kill state + retry elapsed"): return false
    if not drain(reopened,START+120): return false
    var paid := int(reopened.state.sect.b3_hunt["slot"]["paid_generation"])
    if not check(WarehouseSystem.new().quantity(reopened.state,B3PilotContent.RESOURCE) == baseline+paid,"replayed kills are each paid once"): return false
    # The disk snapshot is intentionally AFTER save but BEFORE in-memory ACK.
    var again := SimulationRuntimeOwnerV2.new()
    if not check(again.load_from_path(str(fx["path"]),START+120)["ok"],"reopen after save/before ACK"): return false
    if not drain(again,START+120): return false
    return check(same(canonical(reopened.state),canonical(again.state)),"reopen/retry/ACK produces no extra reward")

func pending_and_invalid() -> bool:
    var fx := fresh("pending")
    if fx.is_empty(): return false
    var owner: SimulationRuntimeOwnerV2 = fx["runtime"].owner
    if not B3HuntWorld.begin(owner,fx["id"])["ok"]: return false
    var warehouse := WarehouseSystem.new()
    warehouse.add(owner.state,B3PilotContent.RESOURCE,WarehouseSystem.MAX_SAFE_STACK-warehouse.quantity(owner.state,B3PilotContent.RESOURCE))
    var blocked := owner.update_to(START+120)
    if not check(not blocked["ok"] and blocked.get("reason","") == "b3_warehouse_backpressure","HP0 before Warehouse: overflow holds PENDING receipt"): return false
    var disk := SaveService.new().load_from_path(str(fx["path"]))
    if not check(disk != null and disk.sect.b3_hunt["receipt"]["state"] == "PENDING","HP0 + pending result durable without ACK"): return false
    var invalid := disk.to_dict()
    invalid["sect"]["b3_hunt"]["slot"]["paid_generation"] = 1
    if not check(SimulationState.from_dict(invalid) == null,"uncommitted/forged watermark fails closed"): return false
    var reopened := SimulationRuntimeOwnerV2.new()
    if not reopened.attach(disk,START+120)["ok"]: return false
    reopened.durable_path = str(fx["path"])
    warehouse.consume(disk,B3PilotContent.RESOURCE,WarehouseSystem.MAX_SAFE_STACK)
    var retry := reopened.update_to(START+120)
    if not check(retry["ok"] and warehouse.quantity(disk,B3PilotContent.RESOURCE) == 1,"pending retry applies frozen result once"): return false
    var replay: MapBattleV2 = B3HuntWorld.restore(disk)["battle"]
    var duplicate: MapBattleV2 = B3HuntWorld.restore(SaveService.new().load_from_path(str(fx["path"])))["battle"]
    replay._pending_kill_events = duplicate.pending_kill_events()
    replay.events.clear()
    var before := warehouse.quantity(disk,B3PilotContent.RESOURCE)
    if not check(B3HuntWorld.settle_kills(disk,replay,false)["ok"] and warehouse.quantity(disk,B3PilotContent.RESOURCE) == before,"same committed domain event replay + compacted UI cannot mint"): return false
    var data := disk.to_dict()
    data["sect"]["b3_hunt"]["version"] = 999
    if not check(SimulationState.from_dict(data) == null,"unknown B3 schema fails closed"): return false
    data = disk.to_dict()
    data["sect"]["b3_hunt"]["receipt"]["quantity"] = 2
    if not check(SimulationState.from_dict(data) == null,"tampered frozen receipt fails closed"): return false
    data = disk.to_dict()
    data["sect"].erase("b3_hunt")
    # Existing saves with no B3 field remain readable without enabling B3.
    data["disciples"] = data["disciples"].filter(func(row): return str(row.get("active_pve_encounter_id","")).is_empty())
    return check(SimulationState.from_dict(data) != null,"legacy no-B3 save remains readable")

func command_catch_up_guard() -> bool:
    var fx := fresh("command_guard")
    if fx.is_empty(): return false
    var owner: SimulationRuntimeOwnerV2 = fx["runtime"].owner
    if not check(B3HuntWorld.begin(owner,fx["id"])["ok"],"catch-up command fixture admitted"): return false
    if not check(owner.update_to(START+120,1)["ok"] and owner.state.runtime_unconsumed_wall_seconds >= 0.25,"bounded clock leaves persisted backlog"): return false
    var enter := B3HuntWorld.begin(owner,fx["id"])
    var leave := B3HuntWorld.return_to_sect(owner)
    if not check(not enter["ok"] and enter["reason"] == "b3_clock_backlog_pending","admission cannot harvest past offline time"): return false
    if not check(not leave["ok"] and leave["reason"] == "b3_clock_backlog_pending","return cannot evade past offline damage"): return false
    return drain(owner,START+120)
