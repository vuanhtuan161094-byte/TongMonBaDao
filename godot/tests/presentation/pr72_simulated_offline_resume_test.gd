extends SceneTree

# Deterministic unix-time injection: 60/90/180 SIMULATED offline minutes,
# never claim physical elapsed-device QA. Actual LiveGameRuntimeV2 + Save.
const SAVE_PATH := "user://qa_pr72_offline_60_90_180.json"
const BASE_UNIX := 2000000000
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var crops := SpiritCropRegistry.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for minutes in [60,90,180]:
        if not _run_case(minutes):
            return
    _cleanup()
    print("PR72 SIMULATED OFFLINE 60 90 180 MINUTES + REAL PLOT/WAREHOUSE/XP/COLD SAVE: PASS")
    quit(0)

func _run_case(minutes: int) -> bool:
    _cleanup()
    var first := LiveGameRuntimeV2.new()
    var result := first.start(SAVE_PATH,BASE_UNIX,30000+minutes)
    if not bool(result.get("ok",false)) or not bool(result.get("created",false)):
        return _fail("New Game start failed: "+str(result))
    var state: SimulationState = first.state()
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        return _fail("Starter Field unavailable.")
    var target: DiscipleState
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var candidate: DiscipleState = state.disciples[raw_id]
        if candidate.region_id == &"sect" and candidate.work_group_id == &"":
            target = candidate
            break
    if target == null or not workforce.assign_group(state,target.id,&"herbalism_crew"):
        return _fail("Canonical Field worker allocation failed.")
    var planted := false
    var plot := {}
    for _step in range(12):
        var commit := workforce.perform_work(state,target,WorkforceSystem.PROF_HERBALISM)
        if bool(commit.get("started",false)):
            planted = true
        for raw_plot in buildings.spirit_field_plots(state,field):
            if StringName(raw_plot.get("status","")) == BuildingSystem.PLOT_GROWING and str(raw_plot.get("assigned_worker_id","")) == str(target.id):
                plot = raw_plot
                break
        if not plot.is_empty():
            break
        if not bool(commit.get("ok",false)):
            return _fail("Real Field sowing rejected: "+str(commit))
    if not planted or plot.is_empty():
        return _fail("Real field plot/timer did not start at t=0.")
    var crop_id := StringName(plot.get("crop_id",""))
    var material_id := crops.output_resource_id(crop_id)
    var goods_before := warehouse.quantity(state,material_id)
    var xp_before := float(target.profession_xp.get("herbalism",0.0))
    var paid := first.save(BASE_UNIX)
    if not bool(paid.get("ok",false)):
        return _fail("SaveService before offline failed: "+str(paid))
    var resumed := LiveGameRuntimeV2.new()
    var later := BASE_UNIX+minutes*60
    var loaded := resumed.start(SAVE_PATH,later,30000+minutes)
    if not bool(loaded.get("ok",false)) or not bool(loaded.get("loaded",false)):
        return _fail("Live clock cold resume failed: "+str(loaded))
    var caught_up := int(loaded.get("catch_up_steps",-1))
    if caught_up != minutes:
        return _fail("Actual replay minutes mismatch: expected "+str(minutes)+" got "+str(caught_up))
    var after: SimulationState = resumed.state()
    var harvested_qty := warehouse.quantity(after,material_id)
    var harvested_xp := float((after.disciples[target.id] as DiscipleState).profession_xp.get("herbalism",0.0))
    var saved_field := buildings.primary_building(after,BuildingSystem.TYPE_SPIRIT_FIELD)
    if harvested_qty <= goods_before or harvested_xp <= xp_before or (
        saved_field == null or int(saved_field.metrics.get("production_batches",0)) <= 0
    ):
        return _fail("Offline "+str(minutes)+" minute replay did not harvest real plot/XP from Warehouse.")
    var saving := resumed.save(later)
    if not bool(saving.get("ok",false)):
        return _fail("Post-catch-up SaveService failed.")
    var reopened := LiveGameRuntimeV2.new()
    var same_time := reopened.start(SAVE_PATH,later,30000+minutes)
    if not bool(same_time.get("ok",false)) or int(same_time.get("catch_up_steps",-1)) != 0:
        return _fail("Second offline replay repeated minutes: "+str(same_time))
    var unchanged: SimulationState = reopened.state()
    if warehouse.quantity(unchanged,material_id) != harvested_qty or (
        not is_equal_approx(float((unchanged.disciples[target.id] as DiscipleState).profession_xp.get("herbalism",0.0)),harvested_xp)
        or unchanged.tick != after.tick
    ):
        return _fail("Same-time cold reload doubled goods/EXP or simulation ticks.")
    print("PR72 SIMULATED_OFFLINE_CASE_PASS minutes=",minutes,
        " catchup=",caught_up," crop=",crop_id,
        " stock_before=",goods_before," stock_after=",harvested_qty,
        " xp_before=",xp_before," xp_after=",harvested_xp)
    return true

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(message: String) -> bool:
    push_error("PR72 OFFLINE REPLAY: "+message)
    _cleanup()
    quit(1)
    return false
