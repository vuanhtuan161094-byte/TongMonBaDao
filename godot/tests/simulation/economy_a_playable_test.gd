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

    # Merchant stock, purchase limit, Warehouse credit and exact receipt must
    # survive replay. A rejected buy may not mutate either side.
    var merchant_ore := int(loaded.sect.economy_a_market_stock.get("thanh_thiet",0))
    var buy_stones := loaded.sect.spirit_stones
    var buy_ore := warehouse.quantity(loaded,&"thanh_thiet")
    var bought := economy.buy_from_npc_v1(loaded,&"thanh_thiet",1,"test-ore-buy")
    if not _check(bool(bought.get("ok",false)) and warehouse.quantity(loaded,&"thanh_thiet") == buy_ore+1
        and int(loaded.sect.economy_a_market_stock.get("thanh_thiet",0)) == merchant_ore-1
        and loaded.sect.spirit_stones == buy_stones-16,
        "Merchant purchase did not transfer actual item and Stones"): return
    if not _check(bool(economy.buy_from_npc_v1(loaded,&"thanh_thiet",1,"test-ore-buy").get("already_settled",false))
        and not bool(economy.buy_from_npc_v1(loaded,&"thanh_thiet",2,"test-ore-buy").get("ok",false))
        and warehouse.quantity(loaded,&"thanh_thiet") == buy_ore+1
        and loaded.sect.spirit_stones == buy_stones-16,
        "Merchant replay or conflicting request changed balances"): return
    var rejected_stones := loaded.sect.spirit_stones
    var rejected_stock := warehouse.quantity(loaded,&"thanh_thiet")
    if not _check(not bool(economy.buy_from_npc_v1(loaded,&"thanh_thiet",100,"over-limit-buy").get("ok",false))
        and loaded.sect.spirit_stones == rejected_stones
        and warehouse.quantity(loaded,&"thanh_thiet") == rejected_stock,
        "Over-limit merchant buy partially committed"): return

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
    # Seed personal funds only to isolate the policy ceiling from funding; the
    # genuine payroll/transfer above remains the integration proof.
    if not _check(live_actor.region_id == &"sect","Auto service actor did not return"): return
    live_actor.spirit_stones = 10
    live_actor.hp = maxf(1.0,minf(live_actor.max_hp*0.1,live_actor.max_hp-30.0))
    if not _check(bool(economy.configure_v1(loaded,"personal_heal_cost",1).get("ok",false))
        and bool(economy.configure_v1(loaded,"auto_hp_daily_stone_limit",1).get("ok",false))
        and bool(economy.configure_v1(loaded,"auto_hp_service",true).get("ok",false)),
        "Could not configure bounded auto spending"): return
    var auto_sect_before := loaded.sect.spirit_stones
    var auto_hp_before := live_actor.hp
    economy.auto_personal_service_tick(loaded,live_actor)
    economy.auto_personal_service_tick(loaded,live_actor)
    if not _check(live_actor.spirit_stones == 9
        and loaded.sect.spirit_stones == auto_sect_before+1
        and is_equal_approx(live_actor.hp,auto_hp_before+10.0)
        and int(loaded.sect.economy_a_auto_spend_by_disciple.get(str(actor.id),0)) == 1,
        "Auto personal service ignored daily per-disciple Stone limit"): return
    if not _check(bool(economy.configure_v1(loaded,"auto_hp_service",false).get("ok",false)),
        "Could not disable auto spending"): return
    if not _check(economy.validate_v1(loaded).is_empty(),"V2 economy invariants invalid"): return

    # Durable receipts through save/reload, second load has no phantom claims.
    if not _check(saver.save_to_path(loaded,SAVE_PATH) == OK,"Cannot save completed Economy-A"): return
    var roundtrip := saver.load_from_path(SAVE_PATH)
    if not _check(roundtrip != null and _receipts_equivalent(roundtrip.sect.economy_a_receipts,loaded.sect.economy_a_receipts)
        and roundtrip.sect.spirit_stones == loaded.sect.spirit_stones
        and (roundtrip.disciples[actor.id] as DiscipleState).spirit_stones == live_actor.spirit_stones
        and warehouse.quantity(roundtrip,&"linh_moc") == woods
        and roundtrip.sect.economy_a_market_stock == loaded.sect.economy_a_market_stock
        and roundtrip.sect.economy_a_market_units_bought == loaded.sect.economy_a_market_units_bought
        and roundtrip.sect.economy_a_auto_spend_by_disciple == loaded.sect.economy_a_auto_spend_by_disciple,
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
    # A separate legitimate timed Forestry batch must complete through the
    # actual wall-clock runtime owner while the game is closed. One reload at
    # the same wall time cannot replay either wages or stock.
    var before_offline_wood := warehouse.quantity(loaded,&"linh_moc")
    var before_offline_stones := live_actor.spirit_stones
    var offline_start := workforce.perform_work(loaded,live_actor,WorkforceSystem.PROF_FORESTRY)
    if not _check(bool(offline_start.get("ok",false)) and bool(offline_start.get("started",false)),
        "Could not start real Forestry batch for offline runtime"): return
    var pending_offline := buildings.active_resource_timer_for_worker(loaded,actor.id)
    if not _check(not pending_offline.is_empty(),"Offline Forestry lacks persisted job identity"): return
    var remaining_ticks := int(pending_offline.get("finish_tick",-1))-loaded.tick
    if not _check(remaining_ticks > 0,"Offline Forestry has invalid finish time"): return
    var wall_time := 1721000000
    var owner := SimulationRuntimeOwnerV2.new()
    if not _check(bool(owner.attach(loaded,wall_time).get("ok",false))
        and bool(owner.save_to_path(SAVE_PATH,wall_time).get("ok",false)),
        "Could not save active Forestry through canonical owner"): return
    var offline := SimulationRuntimeOwnerV2.new()
    var next_wall := wall_time+remaining_ticks*60
    var recovered := offline.load_from_path(SAVE_PATH,next_wall)
    if not _check(bool(recovered.get("ok",false))
        and int(recovered.get("catch_up_steps",-1)) == remaining_ticks,
        "Wall-clock offline did not replay the exact saved timer"): return
    var recovered_actor: DiscipleState = offline.state.disciples[actor.id]
    var settled_wood := warehouse.quantity(offline.state,&"linh_moc")
    var settled_stones := recovered_actor.spirit_stones
    if not _check(settled_wood == before_offline_wood+2
        and settled_stones == before_offline_stones+4
        and buildings.active_resource_timer_for_worker(offline.state,actor.id).is_empty(),
        "Real offline Forestry did not settle exactly one real batch and wage"): return
    if not _check(bool(offline.save_to_path(SAVE_PATH,next_wall).get("ok",false)),
        "Could not persist offline completed settlement"): return
    var replay_owner := SimulationRuntimeOwnerV2.new()
    var repeat_clock := replay_owner.load_from_path(SAVE_PATH,next_wall)
    if not _check(bool(repeat_clock.get("ok",false))
        and int(repeat_clock.get("catch_up_steps",-1)) == 0
        and warehouse.quantity(replay_owner.state,&"linh_moc") == settled_wood
        and (replay_owner.state.disciples[actor.id] as DiscipleState).spirit_stones == settled_stones
        and _receipts_equivalent(offline.state.sect.economy_a_receipts,replay_owner.state.sect.economy_a_receipts),
        "Repeated wall-clock offline reload changed a settled reward"): return
    if not _test_field_and_alchemy_wages(): return
    print("ECONOMY-A PLAYABLE V2 TIMERS + WAGES + MARKET + PERSONAL + SAVE + OFFLINE: PASS")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    quit(0)



# These are real V2 jobs with saved identity. Full Warehouse output blocks
# completion and payroll; freeing capacity permits exactly one settlement.
func _test_field_and_alchemy_wages() -> bool:
    var state := P37Factory.create_state(471104)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.disciple_capacity = state.disciples.size() + 1
    var original_ids: Array = state.disciples.keys()
    for raw_id in original_ids:
        if not _check(workforce.issue_command(state, StringName(raw_id), WorkforceSystem.COMMAND_HOLD, "", 1000),
            "Cannot isolate Field/Alchemy fixture"): return false
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state, DiscipleGeneratorV2.SOURCE_ORDINARY, 9712)
    if not _check(candidate != null and not candidate.v2_birth_profile.is_empty(),
        "No authentic V2 Field/Alchemy recruit"): return false
    state.recruitment_candidates[candidate.id] = candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state, candidate.id).get("ok", false))
        and bool(economy.enable_v1(state).get("ok", false)),
        "Could not recruit or enable Field/Alchemy economy"): return false
    var worker: DiscipleState = state.disciples[candidate.id]
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var hall := buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if not _check(field != null and hall != null, "Field/Alchemy facility missing"): return false
    if not _check(workforce.assign_group(state, worker.id, &"herbalism_crew")
        and workforce.assign_worksite(state, worker.id, field.id),
        "Could not assign genuine Field slot"): return false
    var field_start := buildings.perform_spirit_field_step(state, worker, 1.0)
    if not _check(bool(field_start.get("ok", false)), "Field job did not start: %s" % str(field_start)): return false
    var plots := buildings.spirit_field_plots(state, field)
    var plot: Dictionary = {}
    for raw_plot in plots:
        if str(raw_plot.get("assigned_worker_id", "")) == str(worker.id):
            plot = raw_plot
            break
    var field_job_id := str(plot.get("economy_a_wage_job_id", ""))
    var field_output := SpiritCropRegistry.new().output_resource_id(StringName(plot.get("crop_id", "")))
    var field_finish := int(plot.get("finish_tick", -1))
    var field_stones := state.sect.spirit_stones
    var personal_before := worker.spirit_stones
    if not _check(field_job_id != "" and field_finish > state.tick
        and not state.sect.economy_a_receipts.has("wage:" + field_job_id),
        "Field start created wage or lacks durable identity"): return false
    if not _check(warehouse.add(state, field_output, WarehouseSystem.MAX_SAFE_STACK - warehouse.quantity(state, field_output)),
        "Could not fill Field output for delivery failure"): return false
    state.tick = field_finish
    buildings._process_spirit_field_plots(state, field)
    if not _check(not buildings.disciple_has_active_spirit_plot(state, worker.id, field).is_empty()
        and worker.spirit_stones == personal_before
        and state.sect.spirit_stones == field_stones
        and not state.sect.economy_a_receipts.has("wage:" + field_job_id),
        "Blocked Field output retired job or paid phantom wage"): return false
    if not _check(warehouse.consume(state, field_output, WarehouseSystem.MAX_SAFE_STACK - 10, true),
        "Could not restore Field output capacity"): return false
    if not _check(SaveService.new().save_to_path(state, SAVE_PATH) == OK,
        "Could not save blocked Field job"): return false
    state = SaveService.new().load_from_path(SAVE_PATH)
    if not _check(state != null, "Could not reload blocked Field job"): return false
    worker = state.disciples[candidate.id]
    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var field_stock := warehouse.quantity(state, field_output)
    buildings._process_spirit_field_plots(state, field)
    if not _check(warehouse.quantity(state, field_output) > field_stock
        and worker.spirit_stones == personal_before + 2
        and state.sect.spirit_stones == field_stones - 2
        and state.sect.economy_a_receipts.has("wage:" + field_job_id)
        and buildings.disciple_has_active_spirit_plot(state, worker.id, field).is_empty(),
        "Field reload did not deliver output and exactly one Sect-funded wage"): return false
    buildings._process_spirit_field_plots(state, field)
    if not _check(worker.spirit_stones == personal_before + 2, "Field replay paid twice"): return false

    if not _check(workforce.assign_group(state, worker.id, &"alchemy_crew")
        and workforce.assign_worksite(state, worker.id, hall.id),
        "Could not assign genuine Alchemy slot"): return false
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    var recipe := AlchemyRecipeRegistry.new()
    var input_id := StringName("thanh_linh_thao")
    var needed := maxi(0, 3 - warehouse.available_quantity(state, input_id))
    if needed > 0 and not _check(warehouse.add(state, input_id, needed),
        "Could not seed real Alchemy inputs"): return false
    var alchemy_start := buildings.perform_alchemy_step(state, worker, 0, 1.0, 1.0)
    if not _check(bool(alchemy_start.get("ok", false)), "Alchemy job did not start: %s" % str(alchemy_start)): return false
    var job: Dictionary = alchemy_start.get("job", {})
    var alchemy_id := str(job.get("job_id", ""))
    var alchemy_finish := int(job.get("finish_tick", -1))
    var output_id := recipe.output_resource_id(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN)
    personal_before = worker.spirit_stones
    var sect_before := state.sect.spirit_stones
    if not _check(bool(job.get("economy_a_wage_eligible", false))
        and not state.sect.economy_a_receipts.has("wage:" + alchemy_id),
        "Alchemy start created wage or lacks durable identity"): return false
    if not _check(warehouse.add(state, output_id, WarehouseSystem.MAX_SAFE_STACK - warehouse.quantity(state, output_id)),
        "Could not fill Alchemy output for delivery failure"): return false
    state.tick = alchemy_finish
    buildings._process_alchemy_jobs(state, hall)
    if not _check(not buildings.active_alchemy_job_for_worker(state, worker.id).is_empty()
        and worker.spirit_stones == personal_before
        and state.sect.spirit_stones == sect_before
        and not state.sect.economy_a_receipts.has("wage:" + alchemy_id),
        "Blocked Alchemy output retired job or paid phantom wage"): return false
    if not _check(warehouse.consume(state, output_id, WarehouseSystem.MAX_SAFE_STACK - 10, true),
        "Could not restore Alchemy output capacity"): return false
    if not _check(SaveService.new().save_to_path(state, SAVE_PATH) == OK,
        "Could not save blocked Alchemy job"): return false
    state = SaveService.new().load_from_path(SAVE_PATH)
    if not _check(state != null, "Could not reload blocked Alchemy job"): return false
    worker = state.disciples[candidate.id]
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    var output_before := warehouse.quantity(state, output_id)
    buildings._process_alchemy_jobs(state, hall)
    if not _check(warehouse.quantity(state, output_id) == output_before + 1
        and worker.spirit_stones == personal_before + 2
        and state.sect.spirit_stones == sect_before - 2
        and state.sect.economy_a_receipts.has("wage:" + alchemy_id)
        and buildings.active_alchemy_job_for_worker(state, worker.id).is_empty(),
        "Alchemy reload did not deliver output and exactly one Sect-funded wage"): return false
    buildings._process_alchemy_jobs(state, hall)
    return _check(worker.spirit_stones == personal_before + 2, "Alchemy replay paid twice")


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
