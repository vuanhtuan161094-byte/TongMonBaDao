extends SceneTree

# ECO-03: no policy unlock or fake crop. Production cost booked exactly once
# from genuine Hall income -> paid Field plot -> actual Warehouse harvest.
# 1/7/30-day and 6/30 schedules are conditional SOURCE-BASED cash models,
# not a claim to spawn 30 paid workers or to run 30 days of real time.
const SAVE_PATH := "user://qa_eco03_seed_wage_cashflow.json"
var buildings := BuildingSystem.new()
var crops := SpiritCropRegistry.new()
var economy := EconomySystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var vein := Eco01OriginVein.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, what: String) -> bool:
    if not ok:
        push_error("ECO03 CASH FLOW FAIL: "+what)
        _clean()
        quit(1)
        return false
    return true

func _run() -> void:
    _clean()
    var state := P37Factory.create_state(3031101)
    if not _check(state.disciples.size() == 6 and state.sect.spirit_stones == 500
        and bool(economy.enable_v1(state).get("ok",false))
        and not economy.sx_v55_r12_enabled(state),
        "Source must be six original disciples, 500 LT and public LT2/T2/W2 HOLD"): return
    if not _check(crops.all_crop_ids().size() == 3
        and crops.cost(&"linh_coc") == 3
        and crops.cost(&"thanh_linh_thao") == 4
        and crops.cost(&"tu_van_thao") == 14
        and not crops.eligible_crop_ids(1).has(&"tu_van_thao"),
        "Only real authored field crops 3/4/14 LT allowed"): return
    if not _check(not bool(economy.field_seed_preflight_v1(state,&"made_up_crop").get("ok",false)),
        "Ghost crop earned seed quote"): return
    if not _check(_model_conditional_6_30_1_7_30(state),
        "Source-based cash sensitivity drifted"): return
    # Stress 0 Sect LT without creating an artificial source or NPC sale.
    state.sect.spirit_stones = 0
    var insufficient := economy.field_seed_preflight_v1(state,&"linh_coc")
    if not _check(not bool(insufficient.get("ok",false))
        and str(insufficient.get("reason","")) == "insufficient_spirit_stones"
        and state.sect.economy_a_receipts.is_empty(),
        "0 LT must not plant or mint a seed receipt"): return
    if not _check(buildings.ensure_main_hall(state) != null,
        "Fixture must create the canonical Hall, just as ECO-01 does"): return
    var eligible := vein.eligible_workers(state)
    if not _check(not eligible.is_empty(),"No real free Hall worker at 0 LT"): return
    var hall_job := vein.start(state,eligible[0])
    if not _check(bool(hall_job.get("ok",false))
        and state.sect.spirit_stones == 0,
        "0 LT must start only canonical earning work, not instant money: "+str(hall_job)): return
    var scheduler := SimulationScheduler.new(state)
    scheduler.run_ticks(60)
    var hall_receipt: Dictionary = state.sect.economy_a_receipts.get(
        Eco01OriginVein.RECEIPT_PREFIX+str(hall_job.get("job_id","")),{})
    if not _check(int(hall_receipt.get("gross",-1)) == 1000
        and int(hall_receipt.get("wage_paid",-1)) == 2
        and state.sect.spirit_stones >= 3
        and state.sect.economy_a_market_units_sold == 0,
        "Real 60-tick origin-vein cash recovery not source-backed"): return

    # Use genuine RecruitmentSystem and V2 profile, not a fake hire.
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.disciple_capacity = state.disciples.size()+1 # QA capacity only
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,303811)
    if not _check(candidate != null and not candidate.v2_birth_profile.is_empty(),
        "Genuine V2 candidate missing"): return
    state.recruitment_candidates[candidate.id] = candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)),
        "V2 recruit acceptance failed"): return
    var actor: DiscipleState = state.disciples[candidate.id]
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(field != null and DiscipleRealmProgressV2.owns_v2_progression(actor)
        and workforce.assign_group(state,actor.id,&"herbalism_crew")
        and workforce.assign_worksite(state,actor.id,field.id),
        "Genuine new V2 worker lacks a valid Field slot"): return
    var before_cash := state.sect.spirit_stones
    var before_receipt_count := state.sect.economy_a_receipts.size()
    var begin := workforce.perform_work(state,actor,WorkforceSystem.PROF_HERBALISM)
    if not _check(bool(begin.get("ok",false)) and bool(begin.get("started",false)),
        "Real Field worker did not start an affordable plot: "+str(begin)): return
    var planted := buildings.spirit_field_plots(state,field)
    var plot: Dictionary = {}
    for raw_plot in planted:
        if raw_plot is Dictionary and str(raw_plot.get("assigned_worker_id","")) == str(actor.id):
            plot = raw_plot
            break
    var crop_id := StringName(plot.get("crop_id",""))
    var seed_cost := crops.cost(crop_id)
    var seed_id := "field-seed:%s:%d" % [str(field.id),int(field.production_state.get("plant_sequence",-1))]
    var seed_receipt: Dictionary = state.sect.economy_a_receipts.get(seed_id,{})
    var wage_id := str(plot.get("economy_a_wage_job_id",""))
    if not _check(not plot.is_empty() and crops.has(crop_id)
        and int(plot.get("paid_spirit_stones",-1)) == seed_cost
        and seed_cost >= 3 and seed_cost <= 4
        and state.sect.spirit_stones == before_cash-seed_cost
        and int(seed_receipt.get("cost",-1)) == seed_cost
        and str(seed_receipt.get("crop_id","")) == str(crop_id)
        and str(seed_receipt.get("worker_id","")) == str(actor.id)
        and state.sect.economy_a_receipts.size() == before_receipt_count+1
        and not wage_id.is_empty()
        and not state.sect.economy_a_receipts.has("wage:"+wage_id),
        "Field cash/receipt not atomic at authentic plant start"): return
    var before_second := state.sect.spirit_stones
    if not _check(not bool(workforce.perform_work(state,actor,WorkforceSystem.PROF_HERBALISM).get("ok",false))
        and state.sect.spirit_stones == before_second
        and int(state.sect.economy_a_receipts.get(seed_id,{}).get("cost",-1)) == seed_cost,
        "One Active Job broken or duplicate seed paid"): return
    var flow := economy.daily_market_cashflow(state)
    if not _check(int(flow.get("origin_income",0)) == 1000
        and int(flow.get("seed_costs",0)) >= seed_cost,
        "Read-only daily receipt report omits real source or seed costs"): return
    if not _check(SaveService.new().save_to_path(state,SAVE_PATH) == OK,
        "Cold in-flight field Save failed"): return
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if not _check(loaded != null and loaded.sect.spirit_stones == before_second
        and loaded.sect.economy_a_receipts.has(seed_id),
        "Cold Reload lost seed cost evidence or altered money"): return
    if not _check(not bool(workforce.perform_work(
        loaded,loaded.disciples[actor.id],WorkforceSystem.PROF_HERBALISM).get("ok",false))
        and loaded.sect.spirit_stones == before_second,
        "Cold in-flight replay planted again"): return
    var output_id := crops.output_resource_id(crop_id)
    var output_before := warehouse.quantity(loaded,output_id)
    scheduler = SimulationScheduler.new(loaded)
    for n in range(240):
        if loaded.sect.economy_a_receipts.has("wage:"+wage_id):
            break
        scheduler.step()
    var wage: Dictionary = loaded.sect.economy_a_receipts.get("wage:"+wage_id,{})
    if not _check(int(wage.get("due",-1)) == 2
        and int(wage.get("paid",-1)) >= 0 and int(wage.get("paid",-1)) <= 2
        and warehouse.quantity(loaded,output_id) > output_before
        and loaded.sect.economy_a_receipts.has(seed_id)
        and loaded.sect.spirit_stones >= 0,
        "Harvest must deliver source stock, booked wage (paid or arrears), permanent seed receipt"): return
    var actor_after: DiscipleState = loaded.disciples[actor.id]
    var personal_before_replay := actor_after.spirit_stones
    var sect_before_replay := loaded.sect.spirit_stones
    if not _check(bool(economy.settle_work_wage(loaded,actor_after,wage_id).get("already_settled",false))
        and actor_after.spirit_stones == personal_before_replay
        and loaded.sect.spirit_stones == sect_before_replay,
        "Replaying completed wage minted or duplicated cash"): return
    if not _check(loaded.validate_invariants().is_empty(),
        "Canonical state invariant failed after seed/wage/harvest"): return
    _clean()
    print("ECO03 REAL SEED COST+WAGE: 0 LT, ORIGIN JOB, FIELD, WAREHOUSE, RECEIPT, SAVE/LOAD, 1/7/30 MODEL PASS")
    quit(0)

func _model_conditional_6_30_1_7_30(state: SimulationState) -> bool:
    var p: Dictionary = BuildingSystem.SX_V55_BULK_PLANS
    var grain_cycles := int(p["linh_coc"]["cycle_ticks"])
    var herb_cycles := int(p["thanh_linh_thao"]["cycle_ticks"])
    var mine_cycles := int(p["thanh_thiet"]["cycle_ticks"])
    var forest_cycles := int(p["linh_moc"]["cycle_ticks"])
    var jobs_6 := 2*int(360/mine_cycles) + 2*int(360/forest_cycles) \
        +int(360/grain_cycles)+int(360/herb_cycles)
    var seeds_6 := int(360/grain_cycles)*crops.cost(&"linh_coc") \
        +int(360/herb_cycles)*crops.cost(&"thanh_linh_thao")
    var wage_per := int(state.sect.economy_a_policy.get("wage_per_batch",0))
    if not _check(jobs_6 == 34 and seeds_6 == 34 and wage_per == 2,
        "Authored 60/90 source cadence and existing wage differ"): return false
    for roster in [6,30]:
        var factor := int(roster/6)
        var jobs := jobs_6*factor
        var seeds := seeds_6*factor
        var wages := jobs*wage_per
        var net_upper := Eco01OriginVein.GROSS_STONES - wage_per - seeds - wages
        if not _check(net_upper == (896 if roster == 6 else 488),
            "Modeled 6/30 cashflow does not conserve wage and seeds"): return false
        for days in [1,7,30]:
            var cash_model := 500 + net_upper*int(days)
            if not _check(cash_model >= 500 and cash_model <= EconomySystem.V2_MAX_STONES,
                "Model went negative or overflowed without an actual source"): return false
            print("ECO03_MODELED_ONLY roster=",roster," paid_slots_proven=false",
                " days=",days," NPC_sales=0"," T2_tax=0",
                " seed_LT=",seeds*int(days)," producer_wages_LT=",wages*int(days),
                " origin_gross_LT=",Eco01OriginVein.GROSS_STONES*int(days),
                " origin_wage_LT=",wage_per*int(days),
                " modeled_upper_sect_LT=",cash_model)
    return true

func _clean() -> void:
    for suffix in ["",".bak",".tmp"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
