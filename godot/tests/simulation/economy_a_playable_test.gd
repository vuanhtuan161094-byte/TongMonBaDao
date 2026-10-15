extends SceneTree

# Economy-A: actual V2 recruit -> canonical timer -> one stock settlement +
# wage, NPC demand with warehouse reserve, service debit, save/offline replay.
const SAVE_PATH := "user://economy_a_playable_test.json"
var warehouse := WarehouseSystem.new()
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var economy := EconomySystem.new()

func _init() -> void:
    call_deferred("_run")

func _fail(why: String) -> bool:
    push_error("ECONOMY-A FOCUSED FAIL: "+why)
    quit(1)
    return false

func _check(condition: bool, reason: String) -> bool:
    return true if condition else _fail(reason)

func _run() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    var state := P37Factory.create_state(471103)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.spirit_stones = 500
    state.sect.disciple_capacity = state.disciples.size()+1
    var original_mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var original_forest := buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    if not _check(original_mine != null and original_forest != null,"missing P3.7 real producers"): return

    # Original production stays on legacy carry-cycle until explicit Economy-A
    # enable. No prior save switches behavior simply by loading new code.
    var initial_actor_id: StringName = buildings.active_worker_ids(state,original_mine)[0]
    var initial_actor: DiscipleState = state.disciples[initial_actor_id]
    var old_cycle := workforce.perform_work(state,initial_actor,WorkforceSystem.PROF_MINING)
    if not _check(bool(old_cycle.get("ok",false)) and not initial_actor.work_cycle_state.is_empty()
        and original_mine.production_state.get("economy_a_jobs",[]).is_empty(),
        "Opt-in disabled legacy Mine carry changed"): return
    # A legacy cycle must survive activation and complete its carried output.
    var previous_cycle := initial_actor.work_cycle_state.duplicate(true)
    if not _check(bool(economy.enable_v1(state).get("ok",false)),"cannot enable canonical Economy-A"): return
    var resumed := workforce.perform_work(state,initial_actor,WorkforceSystem.PROF_MINING)
    if not _check(bool(resumed.get("ok",false)) and not bool(resumed.get("started",false))
        and not initial_actor.work_cycle_state.is_empty()
        and str(previous_cycle.get("profession","")) == str(initial_actor.work_cycle_state.get("profession","")),
        "Legacy carry was replaced by new timer"): return
    # Finish or settle the legitimate carry before reassigning the slot.
    if not _check(workforce.issue_command(state,initial_actor_id,WorkforceSystem.COMMAND_HOLD,"",1000),
        "Cannot settle authentic legacy carry"): return
    var founders: Array = state.disciples.keys()
    founders.sort()
    for raw_id in founders:
        var id := StringName(raw_id)
        if id != initial_actor_id:
            if not _check(workforce.issue_command(state,id,WorkforceSystem.COMMAND_HOLD,"",1000),
                "Could not HOLD unrelated opening actor"): return

    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,9711
    )
    if not _check(candidate != null and not candidate.v2_birth_profile.is_empty(),"No genuine V2 recruit"): return
    state.recruitment_candidates[candidate.id] = candidate
    var recruited := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not _check(bool(recruited.get("ok",false)),"Real V2 candidate not accepted"): return
    var actor: DiscipleState = state.disciples[candidate.id]
    if not _check(DiscipleRealmProgressV2.owns_v2_progression(actor),"Recruit is not authentic V2"): return

    # Free one real Mine slot; do not manufacture a third workplace.
    if not _check(workforce.assign_group(state,initial_actor_id,&""),
        "Cannot free old Mine slot"): return
    if not _check(workforce.assign_group(state,actor.id,&"mining_crew")
        and workforce.assign_worksite(state,actor.id,original_mine.id),
        "Real V2 worker has no Mine slot"): return
    if not _check(buildings.active_worker_ids(state,original_mine).has(actor.id),
        "V2 Mine slot is not active"): return
    if not _check(bool(economy.configure_v1(state,"wage_per_batch",4).get("ok",false))
        and bool(economy.configure_v1(state,"resource_duration_ticks",10).get("ok",false)),
        "Pilot adjustable policy was rejected"): return

    var before_ore := warehouse.quantity(state,&"thanh_thiet")
    var before_stones := state.sect.spirit_stones
    var xp_before := float(actor.profession_xp.get("mining",0.0))
    var started := workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING)
    if not _check(bool(started.get("ok",false)) and bool(started.get("started",false))
        and warehouse.quantity(state,&"thanh_thiet") == before_ore
        and actor.profession_xp.get("mining",0.0) == xp_before
        and actor.spirit_stones == 0,
        "Starting timed Mine falsely credited output, XP, or salary"): return
    var pending := buildings.active_resource_timer_for_worker(state,actor.id)
    if not _check(not pending.is_empty() and int(pending.get("finish_tick",-1)) > state.tick
        and not workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_CULTIVATE,"",5),
        "Timed worker has no exclusive reservation"): return

    var saver := SaveService.new()
    if not _check(saver.save_to_path(state,SAVE_PATH) == OK,"Cannot save active Economy-A timer"): return
    var loaded := saver.load_from_path(SAVE_PATH)
    if not _check(loaded != null and loaded.sect.economy_a_enabled
        and not buildings.active_resource_timer_for_worker(loaded,actor.id).is_empty()
        and (loaded.disciples[actor.id] as DiscipleState).spirit_stones == 0,
        "Timer or personal balance lost on save/load"): return
    var live_actor: DiscipleState = loaded.disciples[actor.id]
    var live_mine := buildings.primary_building(loaded,BuildingSystem.TYPE_MINE)
    var scheduler := SimulationScheduler.new(loaded)
    var finish_tick := int(pending["finish_tick"])
    while loaded.tick < finish_tick:
        scheduler.step()
    var job_id := str(pending.get("job_id",""))
    var receipt_id := "wage:%s" % job_id
    if not _check(warehouse.quantity(loaded,&"thanh_thiet") == before_ore+2
        and float(live_actor.profession_xp.get("mining",0.0)) > xp_before
        and live_actor.spirit_stones == 4
        and loaded.sect.spirit_stones == before_stones-4
        and loaded.sect.economy_a_receipts.has(receipt_id),
        "Complete Mine did not settle exact stock, EXP and zero-sum wage"): return
    var stock_at_finish := warehouse.quantity(loaded,&"thanh_thiet")
    var wage_at_finish := live_actor.spirit_stones
    if not _check(bool(economy.settle_work_wage(loaded,live_actor,job_id).get("already_settled",false))
        and warehouse.quantity(loaded,&"thanh_thiet") == stock_at_finish
        and live_actor.spirit_stones == wage_at_finish,
        "Repeated job settlement minted wages"): return

    # Real stock is protected by the canonical Warehouse reserve; NPC cannot
    # buy starter stock or overdraw daily demand.
    if not _check(warehouse.set_rule(loaded,&"thanh_thiet",before_ore,false),"Reserve rejected"): return
    var sale := economy.sell_to_npc_v1(loaded,&"thanh_thiet",2,"test-ore-sale")
    if not _check(bool(sale.get("ok",false)) and not bool(sale.get("already_settled",false))
        and warehouse.quantity(loaded,&"thanh_thiet") == before_ore
        and loaded.sect.spirit_stones == before_stones-4+16,
        "NPC market did not purchase real spare ore"): return
    var replay_sale := economy.sell_to_npc_v1(loaded,&"thanh_thiet",2,"test-ore-sale")
    if not _check(bool(replay_sale.get("already_settled",false))
        and not bool(economy.sell_to_npc_v1(loaded,&"thanh_thiet",2,"different-overdraw").get("ok",false)),
        "Market allowed replay or sold reserved ore"): return

    live_actor.hp = live_actor.max_hp-14.0
    var service := economy.buy_personal_hp_service(loaded,actor.id,"test-service")
    if not _check(bool(service.get("ok",false)) and live_actor.spirit_stones == 1
        and is_equal_approx(live_actor.hp,live_actor.max_hp-4.0)
        and loaded.sect.spirit_stones == before_stones-4+16+3,
        "Personal healing failed real HP and matched Stone transfer"): return
    var second_service := economy.buy_personal_hp_service(loaded,actor.id,"test-service")
    if not _check(bool(second_service.get("already_settled",false)) and live_actor.spirit_stones == 1,
        "Personal service replay debited twice"): return

    # Scheduler may have legitimately assigned an ordinary outside action
    # at the Mine settlement boundary. Recall the actor through Workforce,
    # never set region/current_action directly in the fixture.
    if not _check(workforce.issue_command(loaded,actor.id,WorkforceSystem.COMMAND_HOLD,"",500),
        "Cannot issue lawful recall/HOLD after the finished Mine"): return
    for recovery_tick in range(16):
        if live_actor.region_id == &"sect" and (live_actor.current_action == &"EVALUATE" or live_actor.current_action == &"HOLD" or live_actor.current_action == &"IDLE"):
            break
        scheduler.step()
    if not _check(live_actor.region_id == &"sect","Worker did not return to Sect under HOLD"): return
    # Explicit cancellation of unfinished *new* timer must produce no goods.
    if not _check(workforce.assign_group(loaded,actor.id,original_forest.worker_group_id)
        and workforce.assign_worksite(loaded,actor.id,original_forest.id),
        "Cannot assign real Forestry slot after completed Mine"): return
    # Existing Sect workers can legitimately occupy both Forestry slots.
    # Release a real slot instead of manufacturing an extra producer.
    var live_forest := buildings.primary_building(loaded,BuildingSystem.TYPE_LINH_FOREST)
    for reserved_id in buildings.active_worker_ids(loaded,live_forest):
        if reserved_id != actor.id:
            if not _check(workforce.assign_group(loaded,reserved_id,&""),
                "Cannot release legitimate Forestry slot"): return
    if not _check(buildings.active_worker_ids(loaded,live_forest).has(actor.id),
        "V2 actor did not receive legitimate Forestry slot"): return
    # All simulation mutations after SaveService reload must use the restored
    # DiscipleState, not the pre-save object that has the same identity.
    var forestry := workforce.perform_work(loaded,live_actor,WorkforceSystem.PROF_FORESTRY)
    if not _check(bool(forestry.get("started",false)),
        "Forestry did not use new timer: %s" % str(forestry)): return
    var woods := warehouse.quantity(loaded,&"linh_moc")
    if not _check(workforce.issue_command(loaded,actor.id,WorkforceSystem.COMMAND_HOLD,"",300)
        and buildings.active_resource_timer_for_worker(loaded,actor.id).is_empty(),
        "Explicit HOLD did not cancel only unearned timer work"): return
    for i in range(35):
        scheduler.step()
    if not _check(warehouse.quantity(loaded,&"linh_moc") == woods,
        "Cancelled Forestry timer minted wood"): return
    if not _check(economy.validate_v1(loaded).is_empty(),"V2 economy invariants invalid"): return

    # Durable receipts through save/reload, second load has no phantom claims.
    if not _check(saver.save_to_path(loaded,SAVE_PATH) == OK,"Cannot save completed Economy-A"): return
    var roundtrip := saver.load_from_path(SAVE_PATH)
    if not _check(roundtrip != null and _receipts_equivalent(roundtrip.sect.economy_a_receipts,loaded.sect.economy_a_receipts)
        and roundtrip.sect.spirit_stones == loaded.sect.spirit_stones
        and (roundtrip.disciples[actor.id] as DiscipleState).spirit_stones == live_actor.spirit_stones
        and warehouse.quantity(roundtrip,&"linh_moc") == woods,
        "Economy-A reload changed receipts, stock, or Stone balances: receipts_equal=%s, sect=%d/%d, personal=%d/%d, wood=%d/%d, saved_receipts=%s, reloaded_receipts=%s" % [
            str(roundtrip != null and _receipts_equivalent(roundtrip.sect.economy_a_receipts,loaded.sect.economy_a_receipts)),
            -1 if roundtrip == null else roundtrip.sect.spirit_stones,loaded.sect.spirit_stones,
            -1 if roundtrip == null else (roundtrip.disciples[actor.id] as DiscipleState).spirit_stones,live_actor.spirit_stones,
            -1 if roundtrip == null else warehouse.quantity(roundtrip,&"linh_moc"),woods,
            str(loaded.sect.economy_a_receipts),
            "{}" if roundtrip == null else str(roundtrip.sect.economy_a_receipts)
        ]): return
    if not _check(saver.save_to_path(roundtrip,SAVE_PATH) == OK and
        _receipts_equivalent(saver.load_from_path(SAVE_PATH).sect.economy_a_receipts,loaded.sect.economy_a_receipts),
        "Repeated save/load replayed economic receipts"): return
    print("ECONOMY-A PLAYABLE V2 TIMERS + WAGES + MARKET + PERSONAL + SAVE: PASS")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    quit(0)


# JSON numbers can return as float while real in-memory ledger values are
# integer. Compare field semantics without dropping required receipt fields.
func _receipts_equivalent(expected: Dictionary, actual: Dictionary) -> bool:
    if expected.size() != actual.size():
        return false
    for key in expected.keys():
        if not actual.has(key):
            return false
        var e = expected[key]
        var a = actual[key]
        if not (e is Dictionary) or not (a is Dictionary) or e.size() != a.size():
            return false
        for field in e.keys():
            if not a.has(field):
                return false
            var left = e[field]
            var right = a[field]
            var numeric_left := typeof(left) == TYPE_INT or typeof(left) == TYPE_FLOAT
            var numeric_right := typeof(right) == TYPE_INT or typeof(right) == TYPE_FLOAT
            if numeric_left and numeric_right:
                if not is_equal_approx(float(left),float(right)):
                    return false
            elif left != right:
                return false
    return true
