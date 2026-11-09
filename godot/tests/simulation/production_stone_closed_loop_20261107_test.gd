extends SceneTree

# Test-only P3.7 fixture. Earn Stone through a truly completed Mine cycle,
# not by granting an arbitrary wallet balance. Save/cold-reload all deltas.
const SAVE_PATH := "user://production_stone_closed_loop_20261107.json"
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()
var economy := EconomySystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(7110701)
    var empty_treasury_probe := P37Factory.create_state(7110703)
    empty_treasury_probe.sect.spirit_stones = 0
    TechniqueSystem.new().initialize(empty_treasury_probe)
    if empty_treasury_probe.sect.spirit_stones != 0:
        _fail("re-initializing an existing technique economy regranted 500 free Stones")
        return
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if mine == null or field == null:
        _fail("authoritative Mine/Field missing")
        return
    if state.sect.economy_a_enabled:
        _fail("P37 fixture legacy opt-in contract changed")
        return
    if not bool(economy.enable_v1(state).get("ok",false)):
        _fail("cannot activate market")
        return
    var initial_stones := state.sect.spirit_stones
    var initial_ore := warehouse.quantity(state,&"thanh_thiet")
    if not warehouse.set_rule(state,&"thanh_thiet",initial_ore,false):
        _fail("cannot protect starter ore")
        return
    var miners := buildings.active_worker_ids(state,mine)
    if miners.is_empty():
        _fail("no genuine Mine worker")
        return
    var miner: DiscipleState = state.disciples[miners[0]]
    var completed := false
    for i in range(80):
        var action := workforce.perform_work(state,miner,WorkforceSystem.PROF_MINING)
        if not bool(action.get("ok",false)):
            _fail("Mine work rejected: "+str(action))
            return
        if bool(action.get("completed",false)):
            completed = true
            break
    if not completed:
        _fail("genuine Mine work never completed")
        return
    var produced := warehouse.quantity(state,&"thanh_thiet")-initial_ore
    if produced <= 0 or produced > 5:
        _fail("unexpected genuine Mine yield")
        return
    var income := economy.sell_to_npc_v1(state,&"thanh_thiet",produced,"earned-ore-1")
    if not bool(income.get("ok",false)) or bool(income.get("already_settled",false)):
        _fail("legitimate ore sale rejected: "+str(income))
        return
    var earned := produced * economy.market_sell_price(&"thanh_thiet")
    if state.sect.spirit_stones != initial_stones+earned or warehouse.quantity(state,&"thanh_thiet") != initial_ore:
        _fail("NPC sale did not debit genuine ore and credit exact Stones")
        return
    var replay := economy.sell_to_npc_v1(state,&"thanh_thiet",produced,"earned-ore-1")
    if not bool(replay.get("already_settled",false)) or state.sect.spirit_stones != initial_stones+earned:
        _fail("replayed NPC sale duplicated Stones")
        return

    var board_cost := economy.market_purchase_price(state,&"tam_mach_ban")
    if board_cost <= 0 or economy.market_sell_price(&"tam_mach_ban") != 0:
        _fail("premium component market violates paid-only loop")
        return
    var buy := economy.buy_from_npc_v1(state,&"tam_mach_ban",1,"paid-board-1")
    if not bool(buy.get("ok",false)) or warehouse.quantity(state,&"tam_mach_ban") != 1:
        _fail("cannot buy a real Mine upgrade component")
        return
    var stones_after_buy := state.sect.spirit_stones
    var daily_report := economy.daily_market_cashflow(state)
    if int(daily_report.get("income",-1)) != earned or int(daily_report.get("purchases",-1)) != board_cost:
        _fail("Hall daily cashflow does not reconcile exact NPC sale/purchase receipts")
        return
    if stones_after_buy != initial_stones+earned-board_cost:
        _fail("Tầm Mạch Bàn purchase did not cost genuine Stones")
        return
    var again := economy.buy_from_npc_v1(state,&"tam_mach_ban",1,"paid-board-1")
    if not bool(again.get("already_settled",false)) or state.sect.spirit_stones != stones_after_buy:
        _fail("duplicate purchase minted a board")
        return
    if bool(economy.buy_from_npc_v1(state,&"tam_mach_ban",1,"paid-board-2").get("ok",false)):
        _fail("special merchant stocked more than one board in same day")
        return
    # The real Field milestone remains 100 fragments -> one Heart, including
    # fragments actually purchased with earned/seeded Sect funds. Only the
    # fixture seeds 96 pieces to isolate the final exact conversion boundary.
    var shards_id := &"linh_tuyen_chi_tam_manh"
    var hearts_id := &"linh_tuyen_chi_tam"
    if not warehouse.add(state,shards_id,96):
        _fail("cannot prepare 100-fragment QA boundary")
        return
    var hearts_before := warehouse.quantity(state,hearts_id)
    var money_before_shards := state.sect.spirit_stones
    var shard_cost := economy.market_purchase_price(state,shards_id)
    var purchased_shards := economy.buy_from_npc_v1(state,shards_id,4,"paid-shards-1")
    if not bool(purchased_shards.get("ok",false)) or warehouse.quantity(state,shards_id) != 0 or warehouse.quantity(state,hearts_id) != hearts_before+1 or state.sect.spirit_stones != money_before_shards-4*shard_cost:
        _fail("purchased 100th fragment failed exact payable Heart conversion")
        return
    if not bool(economy.buy_from_npc_v1(state,shards_id,4,"paid-shards-1").get("already_settled",false)) or warehouse.quantity(state,hearts_id) != hearts_before+1:
        _fail("replayed fragment purchase duplicated Linh Tuyen Chi Tam")
        return

    # A QA-only level probe, not an upgrade grant in normal gameplay.
    if not warehouse.set_rule(state,&"thanh_thiet",0,false):
        _fail("cannot release reserved stock")
        return
    mine.level = 9
    var gate := buildings.can_start_upgrade(state,mine.id)
    if not bool(gate.get("ok",false)):
        _fail("Mine Lv9 gate cannot consume an actually purchased board: "+str(gate))
        return
    var upgraded := buildings.start_upgrade(state,mine.id)
    if not bool(upgraded.get("ok",false)) or warehouse.quantity(state,&"tam_mach_ban") != 0:
        _fail("paid Mine upgrade did not spend the board")
        return
    var work_ticks := ceili(mine.upgrade_required_work)
    for i in range(work_ticks):
        state.tick += 1
        buildings.process_tick(state)
    if mine.level != 10 or mine.is_upgrading():
        _fail("Mine paid upgrade never reached Lv10")
        return

    # Explicit per-tile choice must persist and only charge when actual sowing.
    var choose := buildings.set_spirit_plot_crop(state,field.id,&"plot_001",&"linh_coc")
    if not bool(choose.get("ok",false)):
        _fail("cannot choose Linh Cốc for real plot_001")
        return
    var worker: DiscipleState = null
    var all_ids: Array = state.disciples.keys()
    all_ids.sort()
    for raw_id in all_ids:
        var candidate: DiscipleState = state.disciples[raw_id]
        if candidate.work_group_id == &"":
            worker = candidate
            break
    if worker == null or not workforce.assign_group(state,worker.id,&"herbalism_crew"):
        _fail("no unassigned real Field worker")
        return
    var before_plant := state.sect.spirit_stones
    var xp_before_plant := workforce.profession_xp(worker,WorkforceSystem.PROF_HERBALISM)
    var planting := workforce.perform_work(state,worker,WorkforceSystem.PROF_HERBALISM)
    if not bool(planting.get("ok",false)):
        _fail("per-plot sowing rejected: "+str(planting))
        return
    var plots := buildings.spirit_field_plots(state,field)
    if plots.is_empty() or str(plots[0].get("crop_id","")) != "linh_coc" or state.sect.spirit_stones != before_plant-SpiritCropRegistry.new().cost(&"linh_coc"):
        _fail("per-tile crop choice failed or plant price not debited exactly")
        return
    var pending_herbal_xp := float(plots[0].get("profession_xp_gain",-1.0))
    if pending_herbal_xp <= 0.0 or not is_equal_approx(workforce.profession_xp(worker,WorkforceSystem.PROF_HERBALISM),xp_before_plant):
        _fail("sowing wrongly paid profession EXP before actual harvest")
        return
    if bool(buildings.set_spirit_plot_crop(state,field.id,&"plot_001",&"thanh_linh_thao").get("ok",false)):
        _fail("player rewrote an active paid plot")
        return

    if SaveService.new().save_to_path(state,SAVE_PATH) != OK:
        _fail("cannot save paid market and active plot state")
        return
    var restored := SaveService.new().load_from_path(SAVE_PATH)
    if restored == null:
        _fail("cannot cold reload production economy")
        return
    var restored_field := buildings.primary_building(restored,BuildingSystem.TYPE_SPIRIT_FIELD)
    var restored_mine := buildings.primary_building(restored,BuildingSystem.TYPE_MINE)
    if restored_field == null or restored_mine == null or restored_mine.level != 10:
        _fail("paid upgrade was lost after cold reload")
        return
    if str(restored_field.production_state.get("plot_crop_preferences",{}).get("plot_001","")) != "linh_coc" or buildings.spirit_field_plots(restored,restored_field)[0].get("crop_id","") != "linh_coc":
        _fail("per-plot preference or paid crop lost on reload")
        return
    if not bool(economy.sell_to_npc_v1(restored,&"thanh_thiet",produced,"earned-ore-1").get("already_settled",false)):
        _fail("market receipt replayed on cold reload")
        return
    var stored_stones := restored.sect.spirit_stones
    if not bool(economy.buy_from_npc_v1(restored,&"tam_mach_ban",1,"paid-board-1").get("already_settled",false)) or restored.sect.spirit_stones != stored_stones:
        _fail("milestone purchase replayed on cold reload")
        return
    # The pending profession EXP must remain locked after serialization.
    var restored_worker: DiscipleState = restored.disciples[worker.id]
    var restored_plot: Dictionary = buildings.spirit_field_plots(restored,restored_field)[0]
    if not is_equal_approx(float(restored_plot.get("profession_xp_gain",-1.0)),pending_herbal_xp):
        _fail("Save lost the exact committed Field EXP amount")
        return
    var crop_id := StringName(restored_plot.get("crop_id",""))
    var crop_stock_before := warehouse.quantity(restored,SpiritCropRegistry.new().output_resource_id(crop_id))
    restored.tick = maxi(restored.tick+1,int(restored_plot.get("finish_tick",restored.tick+1)))
    buildings.process_tick(restored)
    if warehouse.quantity(restored,SpiritCropRegistry.new().output_resource_id(crop_id)) <= crop_stock_before:
        _fail("Field did not genuinely deliver a crop to Warehouse")
        return
    if not is_equal_approx(workforce.profession_xp(restored_worker,WorkforceSystem.PROF_HERBALISM)-xp_before_plant,pending_herbal_xp):
        _fail("Field did not credit exactly the previously committed EXP on harvest")
        return
    buildings.process_tick(restored)
    if not is_equal_approx(workforce.profession_xp(restored_worker,WorkforceSystem.PROF_HERBALISM)-xp_before_plant,pending_herbal_xp):
        _fail("Field credited duplicate EXP on repeat processing")
        return

    # Cold migration: already-growing legacy plots had their EXP credited at
    # planting. Remove the new pending key to model an existing saved crop.
    # Resolving its harvest MUST NOT credit EXP a second time.
    var legacy := P37Factory.create_state(7110704)
    var legacy_field := buildings.primary_building(legacy,BuildingSystem.TYPE_SPIRIT_FIELD)
    var old_worker: DiscipleState = null
    for raw_id in legacy.disciples.keys():
        var potential: DiscipleState = legacy.disciples[raw_id]
        if potential.work_group_id == &"":
            old_worker = potential
            break
    if old_worker == null or not workforce.assign_group(legacy,old_worker.id,&"herbalism_crew"):
        _fail("cannot set up legacy pending crop migration fixture")
        return
    var old_sow := workforce.perform_work(legacy,old_worker,WorkforceSystem.PROF_HERBALISM)
    if not bool(old_sow.get("started",false)):
        _fail("could not prepare old in-flight crop")
        return
    var old_data := legacy_field.production_state.duplicate(true)
    var old_plots: Array = old_data.get("plots",[])
    var old_plot: Dictionary = old_plots[0]
    var precredited := maxf(float(old_plot.get("profession_xp_gain",0.0)),0.0)
    old_plot.erase("profession_xp_gain")
    old_plots[0] = old_plot
    old_data["plots"] = old_plots
    legacy_field.production_state = old_data
    old_worker.profession_xp[str(WorkforceSystem.PROF_HERBALISM)] = workforce.profession_xp(old_worker,WorkforceSystem.PROF_HERBALISM)+precredited
    var old_before := workforce.profession_xp(old_worker,WorkforceSystem.PROF_HERBALISM)
    if SaveService.new().save_to_path(legacy,SAVE_PATH) != OK:
        _fail("could not save legacy pending crop without EXP marker")
        return
    var old_reload := SaveService.new().load_from_path(SAVE_PATH)
    if old_reload == null:
        _fail("could not load legacy pending crop")
        return
    var old_reload_field := buildings.primary_building(old_reload,BuildingSystem.TYPE_SPIRIT_FIELD)
    var old_reload_plot: Dictionary = buildings.spirit_field_plots(old_reload,old_reload_field)[0]
    if old_reload_plot.has("profession_xp_gain"):
        _fail("SaveService injected a new pending EXP marker into an already-paid legacy plot")
        return
    var old_finish := int(old_reload_plot.get("finish_tick",0))
    old_reload.tick = maxi(old_reload.tick+1,old_finish)
    buildings.process_tick(old_reload)
    var old_reload_worker: DiscipleState = old_reload.disciples[old_worker.id]
    if not is_equal_approx(workforce.profession_xp(old_reload_worker,WorkforceSystem.PROF_HERBALISM),old_before):
        _fail("legacy crop harvest paid profession EXP twice")
        return

    # Demand policy must stop when all real + in-flight supply targets are met.
    var capped := P37Factory.create_state(7110702)
    var capped_field := buildings.primary_building(capped,BuildingSystem.TYPE_SPIRIT_FIELD)
    for stock_crop_id in SpiritCropRegistry.new().eligible_crop_ids(capped_field.level):
        var amount := SpiritCropRegistry.new().stock_target(stock_crop_id)
        if not warehouse.add(capped,SpiritCropRegistry.new().output_resource_id(stock_crop_id),amount):
            _fail("cannot seed QA stock-target cap probe")
            return
    var capped_worker: DiscipleState = null
    for raw_id in capped.disciples.keys():
        var candidate: DiscipleState = capped.disciples[raw_id]
        if candidate.work_group_id == &"":
            capped_worker = candidate
            break
    if capped_worker == null or not workforce.assign_group(capped,capped_worker.id,&"herbalism_crew"):
        _fail("cannot assign capped field worker")
        return
    var no_crop := workforce.perform_work(capped,capped_worker,WorkforceSystem.PROF_HERBALISM)
    if bool(no_crop.get("ok",false)) or capped.sect.spirit_stones != P37Factory.create_state(7110702).sect.spirit_stones:
        _fail("AUTO_DEMAND continued to spend Stones at target stock")
        return
    _cleanup()
    print("P3 PRODUCTION STONE CLOSED-LOOP + PLOT CHOICE + SAVE: PASS")
    quit(0)

func _fail(why: String) -> void:
    push_error("P3 PRODUCTION STONE CLOSED-LOOP FAIL: "+why)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    for extension in ["",".tmp",".bak"]:
        var file := SAVE_PATH+extension
        if FileAccess.file_exists(file):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
