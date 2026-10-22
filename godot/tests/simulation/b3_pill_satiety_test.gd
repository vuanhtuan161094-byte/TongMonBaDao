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
        push_error("B3 PILL FAIL: "+label)
    return ok

func run() -> void:
    if not execute():
        quit(1)
        return
    print("B3 PILL SATIETY + REAL ALCHEMY + FIXED TUVI + DAILY LIMIT + SAVE RETRY PASS (%d checks)" % checks)
    quit(1 if failed else 0)

func advance(owner: SimulationRuntimeOwnerV2, minute: int) -> bool:
    return check(owner.update_to(START+minute*60)["ok"],"canonical minute "+str(minute))

func execute() -> bool:
    var path := "user://care_pills_%d.json" % Time.get_ticks_usec()
    var runtime := LiveGameRuntimeV2.new()
    if not check(runtime.start(path,START,930211)["ok"],"real runtime"): return false
    var setup := B3DemoSetup.prepare(runtime)
    if not check(setup["ok"],"authentic recruitment and equipment"): return false
    var owner := runtime.owner
    var state := runtime.state()
    var id: StringName = setup["disciple_id"]
    var d: DiscipleState = state.disciples[id]
    WorkforceSystem.new().issue_command(state,id,WorkforceSystem.COMMAND_HOLD,"",1000000)
    var ore_before := warehouse.quantity(state,&"thanh_thiet")
    var stones_before := state.sect.spirit_stones
    if not check(B3MedicalAutoplayV1.buy_demo_inputs(owner)["ok"],"real NPC trade, no ingredient grant"): return false
    print("TRADE ore=",ore_before," -> ",warehouse.quantity(state,&"thanh_thiet")," stones=",state.sect.spirit_stones," herbs=",warehouse.quantity(state,&"thanh_linh_thao")," grain=",warehouse.quantity(state,&"linh_coc"))
    check(warehouse.quantity(state,&"thanh_thiet") == ore_before-10 and warehouse.quantity(state,&"thanh_linh_thao") == 5 and warehouse.quantity(state,&"linh_coc") == 1 and state.sect.spirit_stones == stones_before+12,"10 ore -> 80 stones -> 5 herbs + 1 grain")
    var money := state.sect.spirit_stones
    check(B3MedicalAutoplayV1.buy_demo_inputs(owner)["ok"] and state.sect.spirit_stones == money and warehouse.quantity(state,&"thanh_linh_thao") == 5,"starter exchange retry idempotent")
    var crafted := B3MedicalAutoplayV1.craft(owner,&"tu_khi_dan",1,id)
    if not check(crafted["ok"],"real TQD job: "+str(crafted)): return false
    var finish := int(crafted["finish_tick"])
    check(AlchemyRecipeRegistry.new().base_cycle_ticks(&"tu_khi_dan") == 6 and finish > state.tick,"base recipe 6 ticks, real workforce speed")
    check(warehouse.quantity(state,&"thanh_linh_thao") == 3 and warehouse.quantity(state,&"linh_coc") == 0 and warehouse.quantity(state,&"tu_khi_dan") == 0,"inputs consumed immediately, output pending")
    check(B3MedicalAutoplayV1.craft(owner,&"tu_khi_dan",1)["ok"] and warehouse.quantity(state,&"thanh_linh_thao") == 3,"craft same request no second debit")
    check(not B3MedicalAutoplayV1.craft(owner,&"hoi_xuan_dan",1)["ok"],"conflicting craft sequence rejected")
    if not advance(owner,finish-1): return false
    check(warehouse.quantity(state,&"tu_khi_dan") == 0,"no early output")
    var loaded := LiveGameRuntimeV2.new()
    if not check(loaded.start(path,START+(finish-1)*60)["ok"],"save/load pending recipe"): return false
    runtime = loaded
    owner = loaded.owner
    state = loaded.state()
    d = state.disciples[id]
    if not advance(owner,finish): return false
    check(warehouse.quantity(state,&"tu_khi_dan") == 1,"completed output in canonical Warehouse once")
    var before := d.v2_realm_progress.duplicate(true)
    var expected := DiscipleState.from_dict(d.to_dict())
    var xp := DiscipleRealmProgressV2.grant_xp(expected,"cultivation",10000.0,"fixed",state.sect.v2_training_rules["cultivation"]["floor_costs"])
    check(xp["ok"] and xp["gained"] == 10000.0,"fixed source has no aptitude multiplier")
    var used := B3MedicalAutoplayV1.use_pill(owner,id,&"tu_khi_dan",1)
    if not check(used["ok"],"use real TQD: "+str(used)): return false
    check(d.v2_realm_progress["cultivation"]["floor"] == expected.v2_realm_progress["cultivation"]["floor"] and d.v2_realm_progress["cultivation"]["xp"] == expected.v2_realm_progress["cultivation"]["xp"],"canonical Tu Vi exactly fixed 10000")
    check(warehouse.quantity(state,&"tu_khi_dan") == 0 and B3PillSatietyV1.spent_today(state,d) == 25,"real item debit and 25 shared satiety")
    check(B3MedicalAutoplayV1.use_pill(owner,id,&"tu_khi_dan",1)["replay"] and d.b3_pill_state["sequence"] == 1,"retry does not grant XP or use count")
    check(not B3MedicalAutoplayV1.use_pill(owner,id,&"hoi_xuan_dan",1)["ok"],"same sequence other pill rejected")
    crafted = B3MedicalAutoplayV1.craft(owner,&"hoi_xuan_dan",2,id)
    if not check(crafted["ok"],"real HXD recipe job: "+str(crafted)): return false
    finish = int(crafted["finish_tick"])
    if not advance(owner,finish): return false
    check(warehouse.quantity(state,&"hoi_xuan_dan") == 1 and warehouse.quantity(state,&"thanh_linh_thao") == 0,"second recipe uses last 3 real herbs")
    check(B3MedicalAutoplayV1.commit_owner(owner)["ok"],"persist completed recipe before crash fixture")
    # Boundary fixtures alter HP/counters only; the playable hunt test uses real damage.
    d.hp = 1.0
    d.injury_level = 1
    d.injury_recover_at_tick = state.tick+120
    var until := d.injury_recover_at_tick
    owner.saves = RejectSave.new()
    var disk_before := SaveService.new().load_from_path(path)
    var rejected := B3MedicalAutoplayV1.use_pill(owner,id,&"hoi_xuan_dan",2)
    check(not rejected["ok"] and owner.b3_write_blocked and d.hp == 56.0 and warehouse.quantity(state,&"hoi_xuan_dan") == 0,"failed durable barrier freezes exactly one staged effect")
    check(d.injury_level == 1 and d.injury_recover_at_tick == until,"pill never shortens Injury120")
    var crashed := SaveService.new().load_from_path(path)
    check(crashed.disciples[id].b3_pill_state["sequence"] == disk_before.disciples[id].b3_pill_state["sequence"] and warehouse.quantity(crashed,&"hoi_xuan_dan") == 1,"crash before durable publish restores precommand inventory")
    owner.saves = SaveService.new()
    if not advance(owner,state.tick): return false
    check(not owner.b3_write_blocked and B3MedicalAutoplayV1.use_pill(owner,id,&"hoi_xuan_dan",2)["replay"],"save retry publishes once, same request replay")
    check(B3PillSatietyV1.spent_today(state,d) == 35 and d.hp == 56.0,"HXD and TQD share pool 25+10, HP55 once")
    var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
    check(int(raw["save_version"]) == 3 and int(raw["b3_care_version"]) == 1,"CARE capability envelope rejects old readers")
    var restored := SaveService.new().load_from_path(path)
    check(restored != null and restored.disciples[id].b3_pill_state["spent"] == 35,"real disk ledger preserved")
    raw["save_version"] = 2
    var bad := path+".downgraded"
    var f := FileAccess.open(bad,FileAccess.WRITE)
    f.store_string(JSON.stringify(raw)); f.close()
    check(SaveService.new()._load_exact(bad) == null,"downgraded CARE payload fails closed (expected diagnostic)")
    var malformed := state.to_dict()
    for row in malformed["disciples"]:
        if str(row["id"]) == str(id): row["b3_pill_state"]["spent"] = -1
    check(SimulationState.from_dict(malformed) == null,"negative satiety fails closed (expected diagnostic)")
    # Explicit numerical boundary fixture, not 100000 manufactured consumed pills.
    d.b3_pill_state["spent"] = 999995
    d.b3_pill_state["receipt"]["spent_after"] = 999995
    warehouse.add(state,&"hoi_xuan_dan",1)
    var sequence := B3PillSatietyV1.next_sequence(d)
    check(not B3PillSatietyV1.consume(state,d,&"hoi_xuan_dan",sequence)["ok"] and warehouse.quantity(state,&"hoi_xuan_dan") == 1,"1000000 pilot cap blocks before debit")
    d.b3_pill_state["spent"] = 999990
    d.b3_pill_state["receipt"]["spent_after"] = 999990
    check(B3PillSatietyV1.consume(state,d,&"hoi_xuan_dan",sequence)["ok"] and B3PillSatietyV1.spent_today(state,d) == 1000000,"exact cap accepted")
    warehouse.add(state,&"tu_khi_dan",1)
    check(not B3PillSatietyV1.consume(state,d,&"tu_khi_dan",sequence+1)["ok"] and warehouse.quantity(state,&"tu_khi_dan") == 1,"shared cap blocks other pill")
    if not advance(owner,1439): return false
    check(B3PillSatietyV1.spent_today(state,d) == 1000000,"no reset before canonical day boundary")
    if not advance(owner,1440): return false
    check(B3PillSatietyV1.spent_today(state,d) == 0,"same clock resets budget at day1440")
    check(B3PillSatietyV1.consume(state,d,&"tu_khi_dan",sequence+1)["ok"] and B3PillSatietyV1.spent_today(state,d) == 25,"new day permits pill with monotonic sequence")
    var progress := d.v2_realm_progress.duplicate(true)
    d.v2_realm_progress["cultivation"]["floor"] = 10
    d.v2_realm_progress["cultivation"]["xp"] = float(state.sect.v2_training_rules["cultivation"]["floor_costs"]["%d:10" % int(progress["cultivation"]["realm"])])
    warehouse.add(state,&"tu_khi_dan",1)
    check(not B3PillSatietyV1.consume(state,d,&"tu_khi_dan",sequence+2)["ok"] and warehouse.quantity(state,&"tu_khi_dan") == 1,"major gate overflow rejected before debit")
    d.v2_realm_progress = progress
    print("B3 PILL EVIDENCE recipe_base=6 fixed_tuvi=10000 shared_costs=10+25 cap=1000000 day_tick=1440 save=",ProjectSettings.globalize_path(path))
    return not failed
