extends SceneTree

# Opt-in r1/r2 bulk production: real worker -> timed work -> canonical
# Warehouse -> paid Alchemy -> real pill consumer, cold Save and no duplicate.
# Time advances deterministically in this QA fixture; NOT actual wall-clock QA.
const SAVE_PATH := "user://sx_v55_bulk_real_chain_save_test.json"

var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()
var economy := EconomySystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(value: bool, reason: String) -> bool:
    if not value:
        push_error("SX V55 BULK REAL CHAIN FAIL: " + reason)
        quit(1)
        return false
    return true

func _save_reload(state: SimulationState) -> SimulationState:
    var service := SaveService.new()
    if service.save_to_path(state,SAVE_PATH) != OK:
        return null
    return service.load_from_path(SAVE_PATH)

func _run() -> void:
    _cleanup()
    var baseline := P37Factory.create_state(55111203)
    var mine0 := buildings.primary_building(baseline,BuildingSystem.TYPE_MINE)
    var field0 := buildings.primary_building(baseline,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(mine0 != null and field0 != null
        and not buildings.sx_v55_bulk_enabled(baseline)
        and buildings.mine_ore_batch_units(mine0,&"thanh_thiet") == 2,
        "legacy game must keep two-unit Mine until actual player opt-in"):
        return
    if not _check(bool(economy.enable_v1(baseline).get("ok",false)),
        "cannot enable canonical timed economy"):
        return
    var original_miner_ids := buildings.active_worker_ids(baseline,mine0)
    if not _check(not original_miner_ids.is_empty(),"legacy miner missing"):
        return
    var old_miner: DiscipleState = baseline.disciples[original_miner_ids[0]]
    var old_cycle := workforce.perform_work(baseline,old_miner,WorkforceSystem.PROF_MINING)
    if not _check(bool(old_cycle.get("ok",false))
        and not old_miner.work_cycle_state.is_empty(),"legacy carry did not start"):
        return
    var frozen_cycle := old_miner.work_cycle_state.duplicate(true)
    var old_plot := {}
    var original_field_ids := buildings.active_worker_ids(baseline,field0)
    if not original_field_ids.is_empty():
        var old_farmer: DiscipleState = baseline.disciples[original_field_ids[0]]
        var plant := workforce.perform_work(baseline,old_farmer,WorkforceSystem.PROF_HERBALISM)
        if bool(plant.get("started",false)):
            for candidate in buildings.spirit_field_plots(baseline,field0):
                if str(candidate.get("status","")) == "growing":
                    old_plot = candidate.duplicate(true)
                    break
    var bulk_on := buildings.sx_v55_enable_bulk(baseline)
    if not _check(bool(bulk_on.get("ok",false))
        and old_miner.work_cycle_state == frozen_cycle
        and (old_plot.is_empty() or buildings.spirit_field_plots(baseline,field0).has(old_plot)),
        "opt-in modified old in-flight carry/plots"):
        return
    if not _check(bool(buildings.sx_v55_enable_bulk(baseline).get("already_enabled",false)),
        "repeated opt-in mutated a second time"):
        return
    var baseline_loaded := _save_reload(baseline)
    if not _check(baseline_loaded != null
        and buildings.sx_v55_bulk_enabled(baseline_loaded)
        and (baseline_loaded.disciples[old_miner.id] as DiscipleState).work_cycle_state == frozen_cycle,
        "old carry or bulk policy did not survive cold Save"):
        return
    mine0 = buildings.primary_building(baseline_loaded,BuildingSystem.TYPE_MINE)
    if not _check(buildings.mine_ore_batch_units(mine0,&"thanh_thiet") == 2,
        "old carry batch helper was rewritten globally"):
        return

    var state := P37Factory.create_state(55111204)
    if not _check(bool(economy.enable_v1(state).get("ok",false)),
        "authentic timed economy unavailable"):
        return
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    var original_ids: Array = state.disciples.keys()
    original_ids.sort()
    for original_id in original_ids:
        var id := StringName(original_id)
        if not _check(workforce.assign_group(state,id,&""),"cannot release legacy worker"):
            return
    state.sect.disciple_capacity = state.disciples.size()+1
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(state,DiscipleGeneratorV2.SOURCE_ORDINARY,411)
    if not _check(candidate != null,"no real generated V2 disciple"):
        return
    state.recruitment_candidates[candidate.id] = candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)),
        "cannot recruit true V2 worker"):
        return
    var actor: DiscipleState = state.disciples[candidate.id]
    if not _check(DiscipleRealmProgressV2.owns_v2_progression(actor),
        "worker lacks authentic V2 identity"):
        return
    if not _check(bool(buildings.sx_v55_enable_bulk(state).get("ok",false))
        and buildings.sx_v55_bulk_enabled(state),"player opt-in not persisted"):
        return

    # Existing recipes/Forge inputs remain unchanged before toggle; NEW
    # orders now scale common herb, ore and wood only, never rare body drops.
    if not _check(buildings.sx_v55_crop_stock_target(state,&"thanh_linh_thao") == 40000
        and buildings.sx_v55_crop_stock_target(state,&"linh_coc") == 60
        and buildings.sx_v55_crop_stock_target(state,&"tu_van_thao") == 20,
        "auto-demand incorrectly multiplied Grain/TuVan without matching real consumer"):
        return
    var scaled := buildings.sx_v55_common_requirements(state,{
        "thanh_thiet":3,"linh_moc":1,"thanh_linh_thao":2,
        "tinh_lang_bi":1,"tu_van_thao":2})
    if not _check(int(scaled.get("thanh_thiet",0)) == 3000
        and int(scaled.get("linh_moc",0)) == 1000
        and int(scaled.get("thanh_linh_thao",0)) == 2000
        and int(scaled.get("tinh_lang_bi",0)) == 1
        and int(scaled.get("tu_van_thao",0)) == 2,
        "common-only producer-to-consumer scaling changed rare materials"):
        return
    var equip := EquipmentSystem.new()
    var forge := equip.crafting_requirements(state,&"thanh_thiet_kiem")
    if not _check(int(forge.get("thanh_thiet",0)) == 3000
        and int(forge.get("linh_moc",0)) == 1000,
        "Forge still offers unscaled new bulk items"):
        return
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if not _check(mine != null and forest != null and field != null and hall != null,
        "canonical producer or consumer authority missing"):
        return
    var preview := buildings.sx_v55_upgrade_cost(state,mine)
    var old_upgrade := buildings.upgrade_cost(mine)
    if not _check(int(preview.get("linh_moc",-1)) == int(old_upgrade.get("linh_moc",-2))*1000
        and int(preview.get("thanh_thiet",-1)) == int(old_upgrade.get("thanh_thiet",-2))*1000
        and int(preview.get("spirit_stones",-1)) == int(old_upgrade.get("spirit_stones",-2)),
        "paid upgrade costs not safely bulk-scaled"):
        return

    if not _check(workforce.assign_group(state,actor.id,&"mining_crew")
        and workforce.assign_worksite(state,actor.id,mine.id),"cannot claim real Mine slot"):
        return
    var ore_before := warehouse.quantity(state,&"thanh_thiet")
    var xp_before := float(actor.profession_xp.get("mining",0.0))
    var started := workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING)
    if not _check(bool(started.get("started",false)),"authentic Mine work did not start"):
        return
    var timer := buildings.active_resource_timer_for_worker(state,actor.id)
    if not _check(str(timer.get("production_plan_id","")) == "mine_thanh_thiet_t1"
        and int(timer.get("output_quantity",-1)) == 10000
        and int(timer.get("finish_tick",-1)) > state.tick,
        "Mine did not freeze exact 10,000-unit bulk plan"):
        return
    var first_job_id := str(timer.get("job_id",""))
    if not _check(not bool(workforce.assign_group(state,actor.id,&"forestry_crew")),
        "active Mine timer can be wrongly stolen by Forest"):
        return
    state = _save_reload(state)
    if not _check(state != null,"cold Save failed for Mine batch"):
        return
    actor = state.disciples[candidate.id]
    mine = buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    forest = buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    field = buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    hall = buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if not _check(buildings.sx_v55_bulk_enabled(state)
        and int(buildings.active_resource_timer_for_worker(state,actor.id).get("output_quantity",-1)) == 10000,
        "cold Save rewrote Mine output or opt-in policy"):
        return
    state.tick = int(timer["finish_tick"])
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"thanh_thiet") == ore_before+10000
        and float(actor.profession_xp.get("mining",0.0)) > xp_before
        and state.sect.economy_a_receipts.has("wage:"+first_job_id),
        "Mine Warehouse/EXP/wage not settled after real timer"):
        return
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"thanh_thiet") == ore_before+10000,
        "duplicate Mine settlement after same tick"):
        return

    if not _check(workforce.assign_group(state,actor.id,&"forestry_crew")
        and workforce.assign_worksite(state,actor.id,forest.id),
        "worker cannot transfer to canonical Forest"):
        return
    var wood_before := warehouse.quantity(state,&"linh_moc")
    var forest_start := workforce.perform_work(state,actor,WorkforceSystem.PROF_FORESTRY)
    if not _check(bool(forest_start.get("started",false)),"Forest job did not start"):
        return
    timer = buildings.active_resource_timer_for_worker(state,actor.id)
    if not _check(str(timer.get("production_plan_id","")) == "forest_linh_moc_t1"
        and int(timer.get("output_quantity",-1)) == 8000,
        "Forest did not snapshot 8,000-unit bulk plan"):
        return
    state.tick = int(timer["finish_tick"])
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"linh_moc") == wood_before+8000,
        "authentic Forestry Warehouse settlement wrong"):
        return

    # Real paid Lv1->2 upgrade: Mine/Forest must create the exact bulk
    # common-material stock before the 1,000x consumer can spend it.
    mine = buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var price: Dictionary = buildings.sx_v55_upgrade_cost(state,mine)
    var can_upgrade := buildings.can_start_upgrade(state,mine.id)
    if not _check(bool(can_upgrade.get("ok",false))
        and can_upgrade.get("cost",{}) == price,
        "real Mine/Forest delivery did not fund a legitimate upgraded worksite"):
        return
    var wood_before_upgrade := warehouse.quantity(state,&"linh_moc")
    var ore_before_upgrade := warehouse.quantity(state,&"thanh_thiet")
    var money_before_upgrade := state.sect.spirit_stones
    var paid_upgrade := buildings.start_upgrade(state,mine.id)
    if not _check(bool(paid_upgrade.get("ok",false))
        and warehouse.quantity(state,&"linh_moc") == wood_before_upgrade-int(price.get("linh_moc",0))
        and warehouse.quantity(state,&"thanh_thiet") == ore_before_upgrade-int(price.get("thanh_thiet",0))
        and state.sect.spirit_stones == money_before_upgrade-int(price.get("spirit_stones",0))
        and mine.is_upgrading(),
        "bulk upgrade failed exact real-Stock and Stone debit"):
        return
    if not _check(not bool(buildings.start_upgrade(state,mine.id).get("ok",false))
        and warehouse.quantity(state,&"linh_moc") == wood_before_upgrade-int(price.get("linh_moc",0)),
        "upgrade replay incorrectly charged or started a second paid upgrade"):
        return
    state = _save_reload(state)
    if not _check(state != null,"real paid bulk upgrade cold Save failed"):
        return
    mine = buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    forest = buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    field = buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    hall = buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    actor = state.disciples[candidate.id]
    if not _check(mine.is_upgrading()
        and state.sect.spirit_stones == money_before_upgrade-int(price.get("spirit_stones",0))
        and warehouse.quantity(state,&"linh_moc") == wood_before_upgrade-int(price.get("linh_moc",0)),
        "paid upgrade was not frozen exactly once on cold reload"):
        return

    if not _check(workforce.assign_group(state,actor.id,&"herbalism_crew")
        and workforce.assign_worksite(state,actor.id,field.id),"cannot claim Field plot"):
        return
    for crop in [&"linh_coc",&"thanh_linh_thao",&"tu_van_thao"]:
        if crop == &"tu_van_thao":
            # QA-only gate probe. Player MUST pay real Lv10 milestone costs.
            field.level = 10
        # Field-wide FIXED policy requires Lv10 by design. At Lv1 the player
        # can still select a real crop on an empty plot; use that legal path.
        var plot_choice := buildings.set_spirit_plot_crop(state,field.id,&"plot_001",crop)
        if not _check(bool(plot_choice.get("ok",false)),
            "cannot select crop on owned empty plot: "+str(crop)+" "+str(plot_choice)):
            return
        var result := workforce.perform_work(state,actor,WorkforceSystem.PROF_HERBALISM)
        if not _check(bool(result.get("started",false)),"Field crop not started: "+str(crop)+" result="+str(result)):
            return
        var saved_plot := {}
        for p in buildings.spirit_field_plots(state,field):
            if str(p.get("status","")) == "growing":
                saved_plot = p
                break
        var plan: Dictionary = BuildingSystem.SX_V55_BULK_PLANS[str(crop)]
        if not _check(not saved_plot.is_empty()
            and str(saved_plot.get("production_plan_id","")) == str(plan.get("plan_id",""))
            and int(saved_plot.get("routine_yield",-1)) >= int(plan.get("yield",0)),
            "Field new planted plot did not freeze bulk output: "+str(crop)+" "+str(saved_plot)):
            return
        var before := warehouse.quantity(state,crop)
        state = _save_reload(state)
        if not _check(state != null,"Field cold Save failed: "+str(crop)):
            return
        field = buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
        actor = state.disciples[candidate.id]
        state.tick = int(saved_plot.get("finish_tick",state.tick))
        buildings.process_tick(state)
        var credited := warehouse.quantity(state,crop)-before
        if not _check(credited >= int(plan.get("yield",0))
            and credited % int(saved_plot.get("routine_yield",1)) == 0,
            "Field harvest did not deliver the exact saved output: "+str(crop)):
            return
        buildings.process_tick(state)
        if not _check(warehouse.quantity(state,crop) == before+credited,
            "Field cold-replay duplicated crop: "+str(crop)):
            return

    hall = buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if not _check(workforce.assign_group(state,actor.id,&"alchemy_crew")
        and workforce.assign_worksite(state,actor.id,hall.id),"cannot claim Alchemy hall"):
        return
    if not _check(buildings.set_alchemy_recipe(state,hall.id,AlchemyRecipeRegistry.RECIPE_TU_KHI_DAN),
        "cannot select canonical Tụ Khí recipe"):
        return
    var herb_available := warehouse.quantity(state,&"thanh_linh_thao")
    var grain_available := warehouse.quantity(state,&"linh_coc")
    if not _check(herb_available >= 2000 and grain_available >= 1,
        "real Field batches insufficient for scaled pill consumer"):
        return
    var can_start := buildings.alchemy_can_start(state,actor)
    if not _check(bool(can_start.get("ok",false))
        and int(can_start.get("requirements",{}).get("thanh_linh_thao",0)) == 2000
        and int(can_start.get("requirements",{}).get("linh_coc",0)) == 1,
        "Alchemy new batch bypassed common-material scaling"):
        return
    var pill_before := warehouse.quantity(state,&"tu_khi_dan")
    var alchemy_start := workforce.perform_work(state,actor,WorkforceSystem.PROF_ALCHEMY)
    if not _check(bool(alchemy_start.get("started",false)),
        "authentic Alchemy work rejected: "+str(alchemy_start)):
        return
    if not _check(warehouse.quantity(state,&"thanh_linh_thao") == herb_available-2000
        and warehouse.quantity(state,&"linh_coc") == grain_available-1,
        "recipe did not debit real Warehouse inputs exactly once"):
        return
    # A malformed 1,999-herb pending job is NOT accepted merely because
    # bulk was enabled. The existing B3 CARE validator still rejects it.
    var original_hall_state := hall.production_state.duplicate(true)
    var mutated := original_hall_state.duplicate(true)
    var forged_jobs: Array = mutated.get("jobs",[])
    if not _check(forged_jobs.size() == 1,"no authentic job to validate"):
        return
    var forged: Dictionary = forged_jobs[0]
    var altered_inputs: Dictionary = forged.get("inputs",{}).duplicate(true)
    altered_inputs["thanh_linh_thao"] = 1999
    forged["inputs"] = altered_inputs
    forged_jobs[0] = forged
    mutated["jobs"] = forged_jobs
    hall.production_state = mutated
    var malformed_reason := B3MedicalAutoplayV1.validate(state)
    hall.production_state = original_hall_state
    if not _check(malformed_reason == "invalid_tu_khi_recipe_snapshot",
        "CARE validator incorrectly accepted a non-authorized bulk input"):
        return
    if not _check(B3MedicalAutoplayV1.validate(state).is_empty(),
        "CARE validator rejects genuine frozen 2,000-herb input"):
        return
    state = _save_reload(state)
    if not _check(state != null,"Alchemy cold Save failed"):
        return
    hall = buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    var jobs := buildings.alchemy_jobs(state,hall)
    if not _check(jobs.size() == 1,"pending recipe lost on cold reload"):
        return
    state.tick = int(jobs[0].get("finish_tick",state.tick))
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"tu_khi_dan") == pill_before+1
        and buildings.alchemy_jobs(state,hall).is_empty(),
        "earned inputs failed to produce exact one Tụ Khí Đan"):
        return
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"tu_khi_dan") == pill_before+1,
        "recipe output duplicated on replay"):
        return
    state = _save_reload(state)
    if not _check(state != null and buildings.sx_v55_bulk_enabled(state)
        and warehouse.quantity(state,&"tu_khi_dan") == pill_before+1,
        "canonical Save lost bulk policy or one earned pill"):
        return
    # True medicine consumer: unassign after paid Alchemy job, use the
    # earned canonical Tụ Khí Đan, then exercise Save and replay guards.
    actor = state.disciples[candidate.id]
    if not _check(workforce.assign_group(state,actor.id,&""),
        "completed alchemist cannot leave job to consume earned medicine"):
        return
    # The focused test advanced process_tick directly, without the scheduler's
    # action transition. Simulate the real post-job IDLE window, not free items.
    actor.current_action = &"IDLE"
    if not _check(bool(B3PillSatietyV1.enable(state,actor).get("ok",false)),
        "legitimate V2 disciple cannot enable shared medicine satiety"):
        return
    var tuvi_before := actor.v2_realm_progress.duplicate(true)
    var pill_used := B3PillSatietyV1.consume(state,actor,&"tu_khi_dan",1)
    if not _check(bool(pill_used.get("ok",false))
        and not bool(pill_used.get("replay",true))
        and warehouse.quantity(state,&"tu_khi_dan") == pill_before
        and int(pill_used.get("receipt",{}).get("tuvi",0)) == 10000
        and B3PillSatietyV1.spent_today(state,actor) == 25
        and actor.v2_realm_progress != tuvi_before,
        "earned Tụ Khí was not consumed into legitimate Tu Vi once"):
        return
    var replayed_pill := B3PillSatietyV1.consume(state,actor,&"tu_khi_dan",1)
    if not _check(bool(replayed_pill.get("replay",false))
        and warehouse.quantity(state,&"tu_khi_dan") == pill_before
        and B3PillSatietyV1.spent_today(state,actor) == 25,
        "consumer retry duplicated medicine or saturation"):
        return
    state = _save_reload(state)
    if not _check(state != null,"consumer cold Save failed"):
        return
    actor = state.disciples[candidate.id]
    if not _check(B3PillSatietyV1.spent_today(state,actor) == 25
        and warehouse.quantity(state,&"tu_khi_dan") == pill_before
        and bool(B3PillSatietyV1.consume(state,actor,&"tu_khi_dan",1).get("replay",false)),
        "consumer cold reload lost exactly-once receipt"):
        return
    if not _check(state.validate_invariants().is_empty(),
        "real V55 producer/consumer Save failed invariants: "+str(state.validate_invariants())):
        return
    _cleanup()
    print("SX-V55 BULK 5 REAL SOURCES -> WAREHOUSE -> ALCHEMY -> TUVI CONSUMER; LEGACY FREEZE & COLD SAVE: PASS")
    quit(0)

func _cleanup() -> void:
    for suffix in ["",".bak",".tmp"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
