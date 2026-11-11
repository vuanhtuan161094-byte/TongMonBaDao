extends SceneTree

# ECO-05 actual paid-capacity proof. No direct cash/ore/wood provision.
# Stage r1 pilot enabled ONLY inside disposable QA state, never public UI.
# One genuinely recruited V2 worker completes enough canonical timed jobs
# to afford r2 facilities. Job duration shortens with real profession XP;
# source-authoritative frozen minutes (not assumed 60) determine gross.
# Sim tick jumps to each real finish tick, NOT a 30-day scheduler replay.
const SAVE_PATH := "user://eco05_real_funded_30_slots_test.json"
const MAX_MINE_JOBS := 600
const FOREST_JOBS := 50
const CASH_TARGET := 8000000
var actual_external_gross := 0
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var economy := EconomySystem.new()
var workforce := WorkforceSystem.new()
var audit := Eco05CapacityAuditV1.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("ECO05 PAID 30-SLOT FAIL: "+why)
        quit(1)
        return false
    return true

func _earn(state: SimulationState,worker: DiscipleState,kind: StringName,
        group: StringName,profession: StringName,resource: StringName,units: int) -> bool:
    var site := buildings.primary_building(state,kind)
    if not _check(site != null
        and workforce.assign_group(state,worker.id,group)
        and workforce.assign_worksite(state,worker.id,site.id),
        "Worker cannot enter a real producer "+str(kind)): return false
    var start := workforce.perform_work(state,worker,profession)
    if not _check(bool(start.get("started",false)),
        "Failed to start real bulk job "+str(kind)+": "+str(start)): return false
    var timer := buildings.active_resource_timer_for_worker(state,worker.id)
    var snapshot: Dictionary = timer.get("sx_v55_r12_work",{})
    var actual_minutes := int(snapshot.get("minutes",0))
    var actual_gross := int(snapshot.get("gross",0))
    if not _check(int(snapshot.get("realm",0)) == 1
        and actual_minutes > 0 and actual_minutes <= 60
        and actual_gross == actual_minutes*1000
        and int(timer.get("finish_tick",0))-state.tick == actual_minutes,
        "Wrong real r1 frozen source snapshot: "+str(timer)): return false
    var receipt_id := str(timer.get("job_id",""))
    var money_before := state.sect.spirit_stones+worker.spirit_stones
    var qty_before := warehouse.quantity(state,resource)
    state.tick = int(timer["finish_tick"])
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,resource) == qty_before+units
        and state.sect.spirit_stones+worker.spirit_stones == money_before+actual_gross
        and state.sect.economy_a_receipts.has("sxv55-work:"+receipt_id)
        and state.sect.economy_a_receipts.has("wage:"+receipt_id),
        "Resource and external gross not source-backed"): return false
    actual_external_gross += actual_gross
    return true

func _run() -> void:
    _clean()
    var state := P37Factory.create_state(505030)
    if not _check(bool(SectHallSystemV1.ensure_live(state).get("ok",false))
        and bool(economy.enable_v1(state).get("ok",false))
        and bool(buildings.sx_v55_enable_bulk(state).get("ok",false))
        and not economy.sx_v55_r12_enabled(state),
        "Canonical QA start/source HOLD invalid"): return
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    var founders: Array = state.disciples.keys()
    founders.sort()
    for raw in founders:
        if not _check(workforce.assign_group(state,StringName(raw),&""),
            "Founding worker slot not cleared"): return
    state.sect.disciple_capacity = state.disciples.size()+1
    var recruit := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,455)
    if not _check(recruit != null,"No real V2 recruitment candidate"): return
    state.recruitment_candidates[recruit.id] = recruit
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,recruit.id).get("ok",false)),
        "Source V2 recruitment failed"): return
    var actor: DiscipleState = state.disciples[recruit.id]
    if not _check(DiscipleRealmProgressV2.progression_ready(actor),
        "Actor V2 grade not ready"): return
    state.sect.economy_a_policy[EconomySystem.SX_V55_R12_POLICY] = true
    var start_tick := state.tick
    var original := state.sect.spirit_stones+actor.spirit_stones
    for i in range(FOREST_JOBS):
        if not _earn(state,actor,BuildingSystem.TYPE_LINH_FOREST,
            &"forestry_crew",WorkforceSystem.PROF_FORESTRY,
            &"linh_moc",8000): return
    var mine_count := 0
    while state.sect.spirit_stones < CASH_TARGET and mine_count < MAX_MINE_JOBS:
        if not _earn(state,actor,BuildingSystem.TYPE_MINE,
            &"mining_crew",WorkforceSystem.PROF_MINING,
            &"thanh_thiet",10000): return
        mine_count += 1
    if not _check(mine_count > 0 and mine_count < MAX_MINE_JOBS
        and state.sect.spirit_stones >= CASH_TARGET
        and state.tick-start_tick > 0 and state.tick-start_tick < 30*1440
        and state.sect.spirit_stones+actor.spirit_stones == original+actual_external_gross
        and warehouse.quantity(state,&"thanh_thiet") >= mine_count*10000
        and warehouse.quantity(state,&"linh_moc") >= FOREST_JOBS*8000,
        "Source-funded 30-day r1 finance under real XP speed/cash requirements failed"): return

    var hall := SectHallSystemV1.hall(state)
    var old_money := state.sect.spirit_stones
    var old_ore := warehouse.quantity(state,&"thanh_thiet")
    var old_wood := warehouse.quantity(state,&"linh_moc")
    var upgrade_expense := {"spirit_stones":0,"thanh_thiet":0,"linh_moc":0}
    for lvl in range(2,9):
        var preflight := buildings.can_start_upgrade(state,hall.id)
        if not _check(bool(preflight.get("ok",false)),
            "Earned sources insufficient for Hall Lv"+str(lvl)+": "+str(preflight)): return
        var price: Dictionary = preflight["cost"]
        var action := buildings.start_upgrade(state,hall.id,"eco05-paid-hall-"+str(lvl))
        if not _check(bool(action.get("ok",false))
            and hall.is_upgrading() and hall.upgrade_target_level == lvl,
            "Hall upgrade did not consume actual funds/materials: "+str(action)): return
        for key in upgrade_expense.keys():
            upgrade_expense[key] = int(upgrade_expense[key])+int(price.get(key,0))
        var tick_count := ceili(hall.upgrade_required_work)
        for k in range(tick_count):
            state.tick += 1
            buildings.process_tick(state)
        if not _check(hall.level == lvl and not hall.is_upgrading(),
            "Paid Hall upgrade did not finish via canonical ticks at Lv"+str(lvl)): return
    if not _check(hall.level == 8
        and state.sect.spirit_stones == old_money-int(upgrade_expense["spirit_stones"])
        and warehouse.quantity(state,&"thanh_thiet") == old_ore-int(upgrade_expense["thanh_thiet"])
        and warehouse.quantity(state,&"linh_moc") == old_wood-int(upgrade_expense["linh_moc"]),
        "Real Hall Lv8 payment/upgrade cost conservation failed"): return

    var built_counts := {str(BuildingSystem.TYPE_MINE):4,
        str(BuildingSystem.TYPE_LINH_FOREST):4,
        str(BuildingSystem.TYPE_SPIRIT_FIELD):2}
    var annex_expense := {"spirit_stones":0,"thanh_thiet":0,"linh_moc":0}
    for kind in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST,
            BuildingSystem.TYPE_SPIRIT_FIELD]:
        for i in range(int(built_counts[str(kind)])):
            var offer := buildings.preview_production_annex(state,kind)
            if not _check(bool(offer.get("ok",false)),
                "Hall Lv8 did not authorize a paid worksite "+str(kind)+": "+str(offer)): return
            var cost: Dictionary = offer["cost"]
            var id := "eco05-30slots-%s-%d" % [str(kind),i]
            var before_stones := state.sect.spirit_stones
            var before_ore := warehouse.quantity(state,&"thanh_thiet")
            var before_wood := warehouse.quantity(state,&"linh_moc")
            var paid := buildings.build_paid_production_annex(state,kind,id)
            if not _check(bool(paid.get("ok",false)) and not bool(paid.get("already_settled",true))
                and state.sect.spirit_stones == before_stones-int(cost["spirit_stones"])
                and warehouse.quantity(state,&"thanh_thiet") == before_ore-int(cost["thanh_thiet"])
                and warehouse.quantity(state,&"linh_moc") == before_wood-int(cost["linh_moc"]),
                "Annex was not purchased from genuine earned money/materials"): return
            for key in annex_expense.keys():
                annex_expense[key] = int(annex_expense[key])+int(cost.get(key,0))
            if not _check(bool(buildings.build_paid_production_annex(state,
                kind,id).get("already_settled",false)),
                "Paid annex request replay minted an extra site"): return
    var final := audit.inspect(state)
    if not _check(bool(final.get("paid_capacity_30",false))
        and int(final["mine"]["slots"]) == 10
        and int(final["linh_forest"]["slots"]) == 10
        and int(final["spirit_field"]["slots"]) == 12
        and int(final.get("producer_slots",0)) == 32
        and state.disciples.size() == 7
        and int(final.get("staffed_now",-1)) <= 7,
        "30 PAID capacity still lacks actual worksite finance or roster distinction"): return

    var final_sect := state.sect.spirit_stones
    var final_ore := warehouse.quantity(state,&"thanh_thiet")
    var final_wood := warehouse.quantity(state,&"linh_moc")
    if not _check(SaveService.new().save_to_path(state,SAVE_PATH) == OK,
        "Actual paid-30 cold Save failed"): return
    var cold := SaveService.new().load_from_path(SAVE_PATH)
    if not _check(cold != null,"Actual paid-30 cold Reload failed"): return
    var cold_audit := audit.inspect(cold)
    if not _check(bool(cold_audit.get("paid_capacity_30",false))
        and int(cold_audit.get("producer_slots",-1)) == 32
        and cold.sect.spirit_stones == final_sect
        and warehouse.quantity(cold,&"thanh_thiet") == final_ore
        and warehouse.quantity(cold,&"linh_moc") == final_wood
        and cold.validate_invariants().is_empty(),
        "Cold Save lost paid worksite capacity/money/warehouse receipts"): return
    print("ECO05 PAID30 PASS actual timed r1 jobs 7 Hall paid upgrades 10 paid annexes 32 slots 7 owned, cold Save, 480 max remains roster rank ONLY; tick=",cold.tick,
        " mine_jobs=",mine_count," forest_jobs=",FOREST_JOBS,
        " Hall_upgrade_LT=",upgrade_expense["spirit_stones"],
        " annex_LT=",annex_expense["spirit_stones"])
    _clean()
    quit(0)

func _clean() -> void:
    for suffix in ["",".bak",".tmp"]:
        var file_path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(file_path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))
