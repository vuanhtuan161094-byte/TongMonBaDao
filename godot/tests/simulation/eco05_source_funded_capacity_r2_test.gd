extends SceneTree

# ECO-05: real source-funded r1->r2 capital + actual paid producer
# capacity. The 30-slot target remains a strict proof gate, not a
# QA-provisioned fictional 30-worker economy.
const SAVE_PATH := "user://eco05_source_funded_capacity_r2_test.json"
var economy := EconomySystem.new()
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var audit := Eco05CapacityAuditV1.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("ECO05 SOURCE FUNDED CAPACITY FAIL: "+why)
        quit(1)
        return false
    return true

func _run() -> void:
    _clean()
    var state := P37Factory.create_state(551105)
    if not _check(bool(SectHallSystemV1.ensure_live(state).get("ok",false))
        and bool(economy.enable_v1(state).get("ok",false))
        and bool(buildings.sx_v55_enable_bulk(state).get("ok",false))
        and not economy.sx_v55_r12_enabled(state)
        and not bool(economy.configure_v1(state,
            EconomySystem.SX_V55_R12_POLICY,true).get("ok",false)),
        "Public R12 activation or canonical producer not held"): return
    var held := audit.upgrade_wave_quote(state)
    if not _check(not bool(held.get("ok",false))
        and str(held.get("reason","")) == "r12_pilot_held",
        "ECO05 disclosed 649k QA price to default player"): return

    var before := audit.inspect(state)
    if not _check(int(before.get("rank_roster_ceiling",0)) == 480
        and int(before.get("producer_slots",-1)) == 8
        and not bool(before.get("paid_capacity_30",true))
        and int(before.get("unupgraded_hall_floor_for_30",0)) == 8,
        "480 roster vs 8 paid producer slots vs 30 target conflated"): return

    # QA-only: enable an already-existing frozen real-job policy. Never
    # write this flag through player API, UI or Save migrations.
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    var original: Array = state.disciples.keys()
    original.sort()
    for raw_id in original:
        if not _check(workforce.assign_group(state,StringName(raw_id),&""),
            "Cannot release founding P2 workers"): return
    state.sect.disciple_capacity = state.disciples.size()+1
    var recruit := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,505)
    if not _check(recruit != null,"Source V2 recruitment failed"): return
    state.recruitment_candidates[recruit.id] = recruit
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,recruit.id).get("ok",false)),
        "Genuine V2 worker cannot join Sect"): return
    var worker: DiscipleState = state.disciples[recruit.id]
    if not _check(DiscipleRealmProgressV2.progression_ready(worker),
        "Source worker lacks authentic stage r1"): return
    state.sect.economy_a_policy[EconomySystem.SX_V55_R12_POLICY] = true
    var quote := audit.upgrade_wave_quote(state)
    var total: Dictionary = quote.get("cost",{})
    if not _check(bool(quote.get("ok",false))
        and int(total.get("spirit_stones",-1)) == 649000
        and int(total.get("linh_moc",-1)) == 46000
        and int(total.get("thanh_thiet",-1)) == 42000
        and not bool(quote.get("affordable_now",true)),
        "Exact 649k/46k wood/42k ore source quote not enforced"): return
    var original_wealth := state.sect.spirit_stones+worker.spirit_stones
    var original_ore := warehouse.quantity(state,&"thanh_thiet")
    var original_wood := warehouse.quantity(state,&"linh_moc")
    if not _check(int(quote.get("available",{}).get("spirit_stones",-1)) == state.sect.spirit_stones
        and not bool(buildings.can_start_upgrade(state,
            BuildingSystem.TYPE_MAIN_HALL).get("ok",false)),
        "Missing funded capital must block Hall upgrade"): return

    # Genuinely complete one Mine and one Forest r1 job; only these may
    # finance annexes. Do not insert raw stones/ore/wood into state.
    for row in [
        {"group":&"mining_crew","profession":WorkforceSystem.PROF_MINING,
            "site":BuildingSystem.TYPE_MINE,"material":&"thanh_thiet","yield":10000},
        {"group":&"forestry_crew","profession":WorkforceSystem.PROF_FORESTRY,
            "site":BuildingSystem.TYPE_LINH_FOREST,"material":&"linh_moc","yield":8000}
    ]:
        var site := buildings.primary_building(state,row["site"])
        if not _check(workforce.assign_group(state,worker.id,row["group"])
            and workforce.assign_worksite(state,worker.id,site.id),
            "Cannot assign authentic producer worker"): return
        var start := workforce.perform_work(state,worker,row["profession"])
        if not _check(bool(start.get("started",false)),
            "Cannot start real r1 work: "+str(start)): return
        var job := buildings.active_resource_timer_for_worker(state,worker.id)
        if not _check(not job.is_empty()
            and int(job.get("finish_tick",0)) > state.tick
            and int(job.get("sx_v55_r12_work",{}).get("gross",-1)) > 0,
            "Real work produced no valid frozen source receipt"): return
        var old_quantity := warehouse.quantity(state,row["material"])
        var old_money := state.sect.spirit_stones+worker.spirit_stones
        state.tick = int(job["finish_tick"])
        buildings.process_tick(state)
        if not _check(warehouse.quantity(state,row["material"]) >= old_quantity+int(row["yield"])
            and state.sect.spirit_stones+worker.spirit_stones ==
                old_money+int(job["sx_v55_r12_work"]["gross"]),
            "Real producer did not settle exact source-backed goods and money"): return
    if not _check(state.sect.spirit_stones+worker.spirit_stones > original_wealth
        and warehouse.quantity(state,&"thanh_thiet") > original_ore
        and warehouse.quantity(state,&"linh_moc") > original_wood,
        "Capital came from nowhere or sources did not produce"): return

    for kind in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST,
            BuildingSystem.TYPE_SPIRIT_FIELD]:
        var offer := buildings.preview_production_annex(state,kind)
        if not _check(bool(offer.get("ok",false)),
            "Real financed annex preview unavailable: "+str(offer)): return
        var cost: Dictionary = offer["cost"]
        var stones := state.sect.spirit_stones
        var ore := warehouse.quantity(state,&"thanh_thiet")
        var wood := warehouse.quantity(state,&"linh_moc")
        var request := "eco05-paid-"+str(kind)
        var result := buildings.build_paid_production_annex(state,kind,request)
        if not _check(bool(result.get("ok",false))
            and not bool(result.get("already_settled",true))
            and state.sect.spirit_stones == stones-int(cost["spirit_stones"])
            and warehouse.quantity(state,&"thanh_thiet") == ore-int(cost["thanh_thiet"])
            and warehouse.quantity(state,&"linh_moc") == wood-int(cost["linh_moc"]),
            "Annex not charged from real earned sources: "+str(kind)): return
        var after_stone := state.sect.spirit_stones
        if not _check(bool(buildings.build_paid_production_annex(state,kind,request).get("already_settled",false))
            and state.sect.spirit_stones == after_stone,
            "Duplicate annex purchase changed treasury"): return

    var actual := audit.inspect(state)
    if not _check(int(actual.get("producer_slots",-1)) == 16
        and int(actual["mine"]["paid_annexes"]) == 1
        and int(actual["linh_forest"]["paid_annexes"]) == 1
        and int(actual["spirit_field"]["paid_annexes"]) == 1
        and not bool(actual.get("paid_capacity_30",true))
        and not bool(buildings.preview_production_annex(state,
            BuildingSystem.TYPE_MINE).get("ok",false)),
        "No financial proof for 30 active sites; Hall Lv1 must cap third annex"): return

    if not _check(SaveService.new().save_to_path(state,SAVE_PATH) == OK,
        "Canonical cold save failed"): return
    var cold := SaveService.new().load_from_path(SAVE_PATH)
    if not _check(cold != null,"Canonical cold reload failed"): return
    var cold_audit := audit.inspect(cold)
    var cold_replay := buildings.build_paid_production_annex(cold,
        BuildingSystem.TYPE_MINE,"eco05-paid-mine")
    var cold_errors := cold.validate_invariants()
    print("ECO05_COLD_DIAGNOSTIC slots=",cold_audit.get("producer_slots",-1),
        " audit=",cold_audit,
        " replay=",cold_replay," invariants=",cold_errors)
    if not _check(int(cold_audit.get("producer_slots",-1)) == 16
        and not bool(cold_audit.get("paid_capacity_30",true))
        and bool(cold_replay.get("already_settled",false))
        and cold_errors.is_empty(),
        "Cold Save invented slots, lost receipt or broke invariants"): return

    # 1/7/30 source-backed sensitivity uses the true 60m Mine/Forest
    # bulk plan and r1 frozen site tax. It does NOT simulate simultaneous
    # staff attendance, no NPC, real recruitment, or 30-day scheduler ticks.
    var mine_plan := BuildingSystem.SX_V55_BULK_PLANS["thanh_thiet"]
    var forest_plan := BuildingSystem.SX_V55_BULK_PLANS["linh_moc"]
    var per_day_mine_jobs := 2*int(360/int(mine_plan["cycle_ticks"]))
    var per_day_forest_jobs := 2*int(360/int(forest_plan["cycle_ticks"]))
    var day_ore := per_day_mine_jobs*int(mine_plan["yield"])
    var day_wood := per_day_forest_jobs*int(forest_plan["yield"])
    var day_tax := per_day_mine_jobs*1000*int(mine_plan["cycle_ticks"])*70/100 \
        +per_day_forest_jobs*1000*int(forest_plan["cycle_ticks"])*30/100
    if not _check(day_ore == 120000 and day_wood == 96000 and day_tax == 720000,
        "R1 source rate/actual bulk/minute tax scenario drift"): return
    for days in [1,7,30]:
        var cash_ceiling := 500+int(days)*day_tax
        if not _check(cash_ceiling >= 0 and int(days)*day_ore >= 42000
            and int(days)*day_wood >= 46000,
            "R1 conditional 1/7/30 capacity budget has missing source"): return
        print("ECO05_QA_ONLY days=",days," mine_jobs/day=",per_day_mine_jobs,
            " forest_jobs/day=",per_day_forest_jobs,
            " ore_generated=",int(days)*day_ore," wood_generated=",int(days)*day_wood,
            " sect_tax_ceiling_LT=",cash_ceiling,
            " upgrade_wave_LT=",int(total["spirit_stones"]),
            " 30_paid_slots_proven=false"," 480_paid_workers_proven=false")
    _clean()
    print("ECO05 AUTHENTIC TWO-JOB FUNDED THREE ANNEXES, 16 REAL SLOTS, 649K UPGRADE QUOTE, 480 RANK CAP, COLD SAVE, 30-SLOT GAP HONEST: PASS")
    quit(0)

func _clean() -> void:
    for suffix in ["",".bak",".tmp"]:
        var path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
