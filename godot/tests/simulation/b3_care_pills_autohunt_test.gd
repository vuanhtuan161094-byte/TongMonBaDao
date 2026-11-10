extends SceneTree

const START := 1800000000
var checks := 0
var failed := false
var warehouse := WarehouseSystem.new()

class RejectSave:
    extends SaveService
    func save_to_path(_s: SimulationState, _p: String) -> Error: return ERR_CANT_CREATE

func _init() -> void: call_deferred("run")

func check(ok: bool, label: String) -> bool:
    checks += 1
    if not ok:
        failed = true
        push_error("B3 CARE FAIL: "+label)
    return ok

func fresh(name: String, medicine: bool) -> Dictionary:
    var path := "user://care_loop_%s_%d.json" % [name,Time.get_ticks_usec()]
    var runtime := LiveGameRuntimeV2.new()
    if not check(runtime.start(path,START,930211)["ok"],"real live runtime "+name): return {}
    var setup := B3DemoSetup.prepare(runtime)
    if not check(setup["ok"],"real recruitment/equipment "+name): return {}
    var id: StringName = setup["disciple_id"]
    WorkforceSystem.new().issue_command(runtime.state(),id,WorkforceSystem.COMMAND_HOLD,"",1000000)
    if medicine:
        if not check(B3MedicalAutoplayV1.buy_demo_inputs(runtime.owner)["ok"],"actual market input trade"): return {}
        var job := B3MedicalAutoplayV1.craft(runtime.owner,&"hoi_xuan_dan",1,id)
        if not check(job["ok"],"HXD real job: "+str(job)): return {}
        if not drain(runtime.owner,START+int(job["finish_tick"])*60): return {}
        if not check(warehouse.quantity(runtime.state(),&"hoi_xuan_dan") == 1,"HXD actually produced"): return {}
    if not check(B3HuntWorld.begin(runtime.owner,id)["ok"],"same PH0 battle admitted"): return {}
    if not check(B3MedicalAutoplayV1.configure(runtime.owner,id,true)["ok"],"AUTO enabled and saved"): return {}
    return {"runtime":runtime,"id":id,"path":path}

func drain(owner: SimulationRuntimeOwnerV2, now: int) -> bool:
    for i in range(2000):
        var result := owner.update_to(now,10)
        if not result["ok"]: return check(false,"clock: "+str(result))
        if owner.state.runtime_unconsumed_wall_seconds < 0.25: return true
    return check(false,"bounded backlog did not drain")

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

func canonical(state: SimulationState) -> Dictionary:
    var data := state.to_dict()
    var battle: MapBattleV2 = B3HuntWorld.restore(state)["battle"]
    battle.events.clear()
    data["sect"]["b3_hunt"]["battle"] = MapBattleSnapshotV2.save(battle)
    return data

func differences(a: Variant, b: Variant, path: String = "") -> void:
    if same(a,b): return
    if a is Dictionary and b is Dictionary:
        for key in a:
            if not b.has(key): print("DIFF missing ",path,"/",key)
            else: differences(a[key],b[key],path+"/"+str(key))
        for key in b:
            if not a.has(key): print("DIFF added ",path,"/",key,"=",b[key])
    elif a is Array and b is Array and a.size() == b.size():
        for i in range(a.size()): differences(a[i],b[i],path+"/"+str(i))
    else: print("DIFF ",path," ",str(a).left(90)," -> ",str(b).left(90))

func run() -> void:
    if not loop_with_reload() or not no_pills_and_guards():
        quit(1)
        return
    print("B3 CARE REAL DEFEAT + FULL HP REVIVE + NO-WASTE PILL + INJURY120 + AUTO + OFFLINE + SAVE PASS (%d checks)" % checks)
    quit(1 if failed else 0)

func loop_with_reload() -> bool:
    var fx := fresh("medicine",true)
    if fx.is_empty(): return false
    var runtime: LiveGameRuntimeV2 = fx["runtime"]
    var owner := runtime.owner
    var state := owner.state
    var id: StringName = fx["id"]
    var d: DiscipleState = state.disciples[id]
    var world_id := str(state.sect.b3_hunt["world_id"])
    var initial_tick := state.tick
    var baseline := warehouse.quantity(state,B3PilotContent.RESOURCE)
    # Every damage/defeat/kill below comes from real Combat V2, no stat injection.
    for second in range(1,601):
        if not drain(owner,START+initial_tick*60+second): return false
        if d.injury_level == 1: break
    if not check(d.injury_level == 1 and is_equal_approx(d.hp,d.max_hp) and d.region_id == &"sect" and d.active_pve_encounter_id.is_empty(),"natural defeat returns FULL HP and Injury1 at sect"): return false
    var down_tick := state.tick
    var until := d.injury_recover_at_tick
    var kills_before := int(state.sect.b3_hunt["slot"]["paid_generation"])
    check(until == down_tick+120 and kills_before >= 1,"locked 120 minute Injury and actual kills")
    if not drain(owner,START+(down_tick+1)*60): return false
    check(is_equal_approx(d.hp,d.max_hp) and d.injury_level == 1 and d.injury_recover_at_tick == until and int(state.sect.b3_hunt["care"]["heals"]) == 0,"FULL HP revival must NOT auto-use a healing pill to cure Injury")
    check(warehouse.quantity(state,&"hoi_xuan_dan") == 1 and B3PillSatietyV1.spent_today(state,d) == 0,"no Warehouse pill debit or satiety cost when HP already full")
    if not drain(owner,START+(down_tick+15)*60): return false
    check(int(state.sect.b3_hunt["care"]["rest_requests"]) == 0 and is_equal_approx(d.hp,d.max_hp),"FULL HP Injury waits without unnecessary REST and medicine")
    var saved := canonical(state)
    var online := LiveGameRuntimeV2.new()
    var offline := LiveGameRuntimeV2.new()
    var online_path := str(fx["path"])+".online"
    var offline_path := str(fx["path"])+".offline"
    check(SaveService.new().save_to_path(state,online_path) == OK and SaveService.new().save_to_path(state,offline_path) == OK,"fork complete canonical save for offline comparison")
    if not check(online.start(online_path,state.runtime_last_wall_unix)["ok"] and offline.start(offline_path,state.runtime_last_wall_unix)["ok"],"load mid-Injury without extra pill or HP"): return false
    if not same(saved,canonical(online.state())): differences(saved,canonical(online.state()))
    check(same(saved,canonical(online.state())) and same(saved,canonical(offline.state())),"reload preserves RNG/HP/timers/receipt/policy exactly")
    runtime = online
    owner = online.owner
    state = owner.state
    d = state.disciples[id]
    while state.tick < until-1:
        if not drain(owner,state.runtime_last_wall_unix+60): return false
    check(d.injury_level == 1 and str(state.sect.b3_hunt["member"]).is_empty() and int(state.sect.b3_hunt["care"]["auto_deploys"]) == 0,"tick119 no early re-entry")
    if not drain(owner,START+until*60): return false
    print("AUTO AT120 tick=",state.tick," hp=",d.hp," injury=",d.injury_level," action=",d.current_action," cmd=",d.direct_command," policy=",state.sect.b3_hunt["care"])
    if not check(d.injury_level == 0 and str(state.sect.b3_hunt["member"]) == str(id) and int(state.sect.b3_hunt["care"]["auto_deploys"]) == 1,"tick120 automatic real re-admission"): return false
    check(d.hp >= d.max_hp*0.75 and str(state.sect.b3_hunt["world_id"]) == world_id,"recovered health threshold and same world ID")
    if not drain(offline.owner,START+until*60): return false
    check(same(canonical(state),canonical(offline.state())),"one offline catch-up equals viewed minute-by-minute recovery, no second clock")
    for second in range(1,121):
        if not drain(owner,START+until*60+second): return false
        if int(state.sect.b3_hunt["slot"]["paid_generation"]) >= kills_before+2: break
    var kills_after := int(state.sect.b3_hunt["slot"]["paid_generation"])
    check(kills_after >= kills_before+2 and warehouse.quantity(state,B3PilotContent.RESOURCE)-baseline == kills_after,"after recovery two more real kills, exact canonical loot")
    check(B3MedicalAutoplayV1.configure(owner,id,false)["ok"],"AUTO OFF persists")
    if not check(B3HuntWorld.return_to_sect(owner)["ok"],"manual safe return"): return false
    check(not state.sect.b3_hunt["care"]["auto_hunt"] and state.sect.b3_hunt["care"]["paused_manual"],"manual return pauses hunting intent")
    if not drain(owner,state.runtime_last_wall_unix+60): return false
    check(str(state.sect.b3_hunt["member"]).is_empty(),"OFF/manual pause does not redeploy")
    check(state.validate_invariants().is_empty(),"canonical invariants: "+str(state.validate_invariants()))
    print("B3 CARE LOOP EVIDENCE world=",world_id," down_tick=",down_tick," recover_tick=",until," auto_deploys=",state.sect.b3_hunt["care"]["auto_deploys"]," kills=",kills_after," real_warehouse=",warehouse.quantity(state,B3PilotContent.RESOURCE)," save=",ProjectSettings.globalize_path(online_path))
    return not failed

func no_pills_and_guards() -> bool:
    var fx := fresh("rest_only",false)
    if fx.is_empty(): return false
    var runtime: LiveGameRuntimeV2 = fx["runtime"]
    var owner := runtime.owner
    var state := owner.state
    var d: DiscipleState = state.disciples[fx["id"]]
    if not drain(owner,START+180): return false
    if not check(d.injury_level == 1 and warehouse.quantity(state,&"hoi_xuan_dan") == 0,"natural defeat without fabricated pills"): return false
    var until := d.injury_recover_at_tick
    if not drain(owner,START+(until-1)*60): return false
    check(d.injury_level == 1 and is_equal_approx(d.hp,d.max_hp) and state.sect.b3_hunt["care"]["heals"] == 0 and state.sect.b3_hunt["care"]["rest_requests"] == 0,"no pills means injury waits at full HP, no artificial REST")
    if not drain(owner,START+until*60): return false
    check(d.injury_level == 0 and str(state.sect.b3_hunt["member"]) == str(d.id),"empty-pills full automatic loop returns to same world")
    check(B3HuntWorld.return_to_sect(owner)["ok"],"manual return for occupation guard")
    owner.saves = RejectSave.new()
    check(not B3MedicalAutoplayV1.configure(owner,d.id,true)["ok"] and owner.b3_write_blocked,"AUTO command durability failure freezes runtime")
    check(not B3MedicalAutoplayV1.configure(owner,d.id,false)["ok"],"no new commands while write blocked")
    owner.saves = SaveService.new()
    if not drain(owner,state.runtime_last_wall_unix): return false
    check(not owner.b3_write_blocked,"retry commits before any new advancement")
    # Explicit guard fixtures, separate from the genuine loop above.
    if not d.active_pve_encounter_id.is_empty(): B3HuntWorld.return_to_sect(owner)
    check(B3MedicalAutoplayV1.configure(owner,d.id,true)["ok"],"enable policy for guard fixtures")
    d.work_cycle_state = {"phase":"TRAVEL"}
    if not drain(owner,state.runtime_last_wall_unix+60): return false
    check(str(state.sect.b3_hunt["member"]).is_empty() and state.sect.b3_hunt["care"]["status"] == "BUSY","AUTO cannot steal production occupation")
    d.work_cycle_state.clear()
    B3MedicalAutoplayV1.configure(owner,d.id,false)
    var bad := state.to_dict()
    bad["sect"]["b3_hunt"]["care"]["next_review_tick"] = -1
    check(SimulationState.from_dict(bad) == null,"malformed AUTO tick fails closed (expected diagnostic)")
    print("B3 REST-ONLY EVIDENCE recover_tick=",until," same_world=",state.sect.b3_hunt["world_id"]," rest_requests=",state.sect.b3_hunt["care"]["rest_requests"])
    return not failed
