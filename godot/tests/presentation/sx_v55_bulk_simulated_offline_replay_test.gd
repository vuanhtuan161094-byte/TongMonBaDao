extends SceneTree

# Real LiveGameRuntimeV2 -> SimulationRuntimeClockV2 -> Scheduler ->
# BuildingSystem -> Warehouse -> SaveService. Injected Unix times model
# 60 / 90 / 180 OFFLINE simulation minutes; this is not physical device QA.
# No free material, personal Stones, work XP, or new persistence authority.
const SAVE_PATH := "user://qa_sx_v55_bulk_offline_6090180.json"
const BASE_UNIX := 2000004000

var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for target in [
        {"crop":"linh_coc","minutes":60},
        {"crop":"thanh_linh_thao","minutes":90},
        {"crop":"tu_van_thao","minutes":180}
    ]:
        if not _run_crop(StringName(target["crop"]),int(target["minutes"])):
            return
    _cleanup()
    print("SX V55 LIVE CLOCK OFFLINE 60/90/180, FROZEN BULK PLOT, COLD SAVE/RELOAD AND REPLAY: PASS")
    quit(0)

func _run_crop(crop_id: StringName, offline_minutes: int) -> bool:
    _cleanup()
    var first := LiveGameRuntimeV2.new()
    var started := first.start(SAVE_PATH,BASE_UNIX,560000+offline_minutes)
    if not bool(started.get("ok",false)) or not bool(started.get("created",false)):
        return _fail("new live game bootstrap failed "+str(started))
    var state: SimulationState = first.state()
    var enabled := buildings.sx_v55_enable_bulk(state)
    if not bool(enabled.get("ok",false)) or not buildings.sx_v55_bulk_enabled(state):
        return _fail("player bulk opt-in failed: "+str(enabled))
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        return _fail("canonical Field instance missing")
    if crop_id == &"tu_van_thao":
        # QA-only paid-gate bypass to isolate a Lv10 plant's offline carry.
        # This does NOT unlock the crop for real players or grant resources.
        field.level = 10

    var chosen: DiscipleState
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var worker: DiscipleState = state.disciples[raw_id]
        if worker.region_id == &"sect" and worker.work_group_id == &"":
            chosen = worker
            break
    if chosen == null or not workforce.assign_group(state,chosen.id,&"herbalism_crew"):
        return _fail("no real available herb worker")
    var plot_choice := buildings.set_spirit_plot_crop(state,field.id,&"plot_001",crop_id)
    if not bool(plot_choice.get("ok",false)):
        return _fail("legitimate plot source selection failed: "+str(plot_choice))
    var planted := workforce.perform_work(state,chosen,WorkforceSystem.PROF_HERBALISM)
    if not bool(planted.get("started",false)):
        return _fail("authentic bulk crop not started "+str(planted))
    var frozen_plot: Dictionary = {}
    for raw_plot in buildings.spirit_field_plots(state,field):
        if str(raw_plot.get("status","")) == str(BuildingSystem.PLOT_GROWING) \
                and str(raw_plot.get("assigned_worker_id","")) == str(chosen.id):
            frozen_plot = raw_plot.duplicate(true)
            break
    var bulk_plan: Dictionary = BuildingSystem.SX_V55_BULK_PLANS.get(str(crop_id),{})
    if frozen_plot.is_empty() or str(frozen_plot.get("production_plan_id","")) != str(bulk_plan.get("plan_id","")) \
            or int(frozen_plot.get("routine_yield",0)) < int(bulk_plan.get("yield",0)):
        return _fail("frozen bulk source identity/yield missing: "+str(frozen_plot))
    var original_finish_tick := int(frozen_plot.get("finish_tick",-1))
    var planted_tick := state.tick
    var before_stock := warehouse.quantity(state,crop_id)
    var before_xp := float(chosen.profession_xp.get("herbalism",0.0))
    if not bool(first.save(BASE_UNIX).get("ok",false)):
        return _fail("canonical SaveService failed before offline")
    # Use the SAME replay path the owner game invokes on startup.
    var now := BASE_UNIX+offline_minutes*60
    var resumed := LiveGameRuntimeV2.new()
    var loaded := resumed.start(SAVE_PATH,now,560000+offline_minutes)
    if not bool(loaded.get("ok",false)) or not bool(loaded.get("loaded",false)) \
            or int(loaded.get("catch_up_steps",-1)) != offline_minutes:
        return _fail("offline clock did not replay exact minutes: "+str(loaded))
    state = resumed.state()
    if not buildings.sx_v55_bulk_enabled(state):
        return _fail("bulk opt-in lost during offline Save")
    # Time modifiers can make the authentic duration longer than the nominal
    # 60/90/180 window. Advance only any remaining saved finish-tick distance.
    var required_minutes := maxi(offline_minutes,original_finish_tick-planted_tick)
    if required_minutes > offline_minutes:
        if not bool(resumed.save(now).get("ok",false)):
            return _fail("partially completed plot failed Save")
        now = BASE_UNIX+required_minutes*60
        var continued := LiveGameRuntimeV2.new()
        var advanced := continued.start(SAVE_PATH,now,560000+offline_minutes)
        if not bool(advanced.get("ok",false)) or int(advanced.get("catch_up_steps",-1)) != required_minutes-offline_minutes:
            return _fail("remaining offline minutes did not progress: "+str(advanced))
        resumed = continued
        state = resumed.state()
    var after_stock := warehouse.quantity(state,crop_id)
    var loaded_worker: DiscipleState = state.disciples[chosen.id]
    var after_xp := float(loaded_worker.profession_xp.get("herbalism",0.0))
    var wage_job_id := str(frozen_plot.get("economy_a_wage_job_id",""))
    if after_stock < before_stock+int(frozen_plot.get("routine_yield",0)) \
            or after_xp <= before_xp:
        return _fail("earned harvest/XP did not arrive after offline replay: "+str(crop_id))
    if not wage_job_id.is_empty() and not state.sect.economy_a_receipts.has("wage:"+wage_job_id):
        return _fail("real V2 wage receipt lost for completed offline plot")
    var before_retry_stones := state.sect.spirit_stones
    var before_retry_tick := state.tick
    var before_retry_receipts := state.sect.economy_a_receipts.duplicate(true)
    if not bool(resumed.save(now).get("ok",false)):
        return _fail("post-catchup canonical SaveService failed")
    var reopened := LiveGameRuntimeV2.new()
    var retry := reopened.start(SAVE_PATH,now,560000+offline_minutes)
    if not bool(retry.get("ok",false)) or int(retry.get("catch_up_steps",-1)) != 0:
        return _fail("same-time reload re-ran previous minutes: "+str(retry))
    var again: SimulationState = reopened.state()
    if again.tick != before_retry_tick or warehouse.quantity(again,crop_id) != after_stock \
            or not is_equal_approx(float((again.disciples[chosen.id] as DiscipleState).profession_xp.get("herbalism",0.0)),after_xp) \
            or again.sect.spirit_stones != before_retry_stones \
            or again.sect.economy_a_receipts != before_retry_receipts:
        return _fail("second cold load duplicated goods/XP/wages/debit")
    if not again.validate_invariants().is_empty():
        return _fail("offline bulk Save broke canonical invariants "+str(again.validate_invariants()))
    print("SX_V55_OFFLINE_CASE_PASS crop=",str(crop_id),
        " nominal_offline_min=",offline_minutes," actual_catchup_min=",required_minutes,
        " frozen_yield=",frozen_plot.get("routine_yield",0),
        " warehouse_delta=",after_stock-before_stock,
        " xp_delta=",after_xp-before_xp," retry_steps=",retry.get("catch_up_steps",-1))
    return true

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path := SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(reason: String) -> bool:
    push_error("SX V55 LIVE OFFLINE CHECK FAIL: "+reason)
    _cleanup()
    quit(1)
    return false
