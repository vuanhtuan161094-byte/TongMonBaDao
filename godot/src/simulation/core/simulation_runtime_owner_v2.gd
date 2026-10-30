class_name SimulationRuntimeOwnerV2
extends RefCounted

# Persistent backend owner for one SimulationState + one SimulationScheduler.
# Presentation must not own a second progression clock.
#
# Old saves with runtime_last_wall_unix == 0 are initialized at first load and
# intentionally receive no unknowable pre-upgrade offline credit.

var state: SimulationState
var scheduler: SimulationScheduler
var saves := SaveService.new()
var durable_path: String = ""
var b3_write_blocked: bool = false
var runtime_write_blocked: bool = false

func attach(simulation_state: SimulationState, now_unix: int) -> Dictionary:
    if simulation_state == null:
        return {"ok":false,"reason":"invalid_runtime_state"}
    state = simulation_state
    scheduler = SimulationScheduler.new(state)
    # Apply the owner's saved opt-in BEFORE any offline catch-up/active combat
    # is advanced, not after the first P3.2 UI frame.
    scheduler.v63_preview_overrides = V63FeatureGates.persisted_preview_overrides(state)
    var initialized := SimulationRuntimeClockV2.initialize(state,now_unix)
    if not bool(initialized.get("ok",false)):
        state = null
        scheduler = null
        return initialized
    return {
        "ok":true,
        "initialized":bool(initialized.get("initialized",false)),
        "state":state
    }

func load_from_path(
    path: String, now_unix: int, max_steps: int = -1
) -> Dictionary:
    var loaded := saves.load_from_path(path)
    if loaded == null:
        return {"ok":false,"reason":"runtime_save_not_found_or_invalid"}
    state = loaded
    durable_path = path
    scheduler = SimulationScheduler.new(state)
    # Apply the owner's saved opt-in BEFORE any offline catch-up/active combat
    # is advanced, not after the first P3.2 UI frame.
    scheduler.v63_preview_overrides = V63FeatureGates.persisted_preview_overrides(state)

    if state.runtime_last_wall_unix <= 0:
        var initialized := SimulationRuntimeClockV2.initialize(state,now_unix)
        if not bool(initialized.get("ok",false)):
            state = null
            scheduler = null
            return initialized
        return {
            "ok":true,
            "loaded":true,
            "legacy_clock_initialized":true,
            "catch_up_steps":0,
            "state":state
        }

    var caught_up := update_to(now_unix,max_steps)
    if not bool(caught_up.get("ok",false)):
        return caught_up
    return {
        "ok":true,
        "loaded":true,
        "legacy_clock_initialized":false,
        "catch_up_steps":int(caught_up.get("steps_run",0)),
        "pending_minutes":int(caught_up.get("pending_minutes",0)),
        "state":state
    }

func update_to(now_unix: int, max_steps: int = -1,
        async_pve_commit: bool = false, skip_pve_commit: bool = false) -> Dictionary:
    if state == null or scheduler == null:
        return {"ok":false,"reason":"runtime_owner_not_attached"}
    if b3_write_blocked:
        var retried := B3MedicalAutoplayV1.commit_owner(self)
        if not retried["ok"]:
            return retried
    if runtime_write_blocked:
        var retried_runtime: Dictionary
        if not state.sect.b3_hunt.is_empty():
            retried_runtime = B3HuntWorld.commit(self)
        elif HuntingPveRunV2.has_active_multicamp(state):
            retried_runtime = HuntingPveRunV2.commit_owner(self)
        elif not durable_path.is_empty():
            var retry_error := saves.save_to_path(state,durable_path)
            runtime_write_blocked = retry_error != OK
            retried_runtime = {"ok":retry_error == OK,"error":retry_error}
        else:
            retried_runtime = {"ok":false,"reason":"runtime_save_path_missing"}
        if not bool(retried_runtime.get("ok",false)):
            return retried_runtime
        runtime_write_blocked = false
    var had_multicamp := HuntingPveRunV2.has_active_multicamp(state)
    var advanced := SimulationRuntimeClockV2.advance_to(
        state,scheduler,now_unix,max_steps
    )
    if not state.sect.b3_hunt.is_empty():
        var restored := B3HuntWorld.restore(state)
        if not restored["ok"]: return restored
        B3MedicalAutoplayV1.review(state,restored["battle"])
        B3HuntWorld.checkpoint(state,restored["battle"])
        var committed := B3HuntWorld.commit(self)
        if not committed["ok"]:
            return committed
    elif (had_multicamp or HuntingPveRunV2.has_active_multicamp(state)) and not skip_pve_commit:
        var committed_pve := HuntingPveRunV2.commit_owner(self,async_pve_commit)
        if not bool(committed_pve.get("ok",false)):
            return committed_pve
        if bool(committed_pve.get("pending",false)):
            advanced["runtime_save_pending"] = true
    return advanced

func save_to_path(
    path: String, now_unix: int, max_steps: int = -1
) -> Dictionary:
    if state == null or scheduler == null:
        return {"ok":false,"reason":"runtime_owner_not_attached"}
    durable_path = path
    # This final SaveService write is the durability barrier for the state
    # advanced above. Avoid a second identical PVE barrier inside update_to.
    var advanced := update_to(now_unix,max_steps,false,true)
    if not bool(advanced.get("ok",false)):
        return advanced
    # If a bounded caller leaves pending whole minutes, the backlog remains in
    # runtime_unconsumed_wall_seconds and survives the save. No offline time is lost.
    var error := saves.save_to_path(state,path)
    return {
        "ok":error == OK,
        "error":error,
        "steps_run":int(advanced.get("steps_run",0)),
        "pending_minutes":SimulationRuntimeClockV2.pending_minutes(state)
    }

func save_to_path_async(
        path: String, now_unix: int, max_steps: int = -1) -> Dictionary:
    if state == null or scheduler == null:
        return {"ok":false,"reason":"runtime_owner_not_attached"}
    durable_path = path
    var advanced := update_to(now_unix,max_steps,false,true)
    if not bool(advanced.get("ok",false)):
        return advanced
    var error := saves.start_save_to_path_async(state,path)
    if error != OK:
        runtime_write_blocked = true
        return {"ok":false,"error":error,"reason":"runtime_async_save_start_failed"}
    runtime_write_blocked = false
    return {
        "ok":true,"pending":true,"steps_run":int(advanced.get("steps_run",0)),
        "pending_minutes":SimulationRuntimeClockV2.pending_minutes(state)
    }

func wait_for_pending_save(tree: SceneTree) -> Dictionary:
    var result: Dictionary = await saves.wait_for_async_save(tree)
    runtime_write_blocked = not bool(result.get("ok",false))
    return result
