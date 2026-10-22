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

func attach(simulation_state: SimulationState, now_unix: int) -> Dictionary:
    if simulation_state == null:
        return {"ok":false,"reason":"invalid_runtime_state"}
    state = simulation_state
    scheduler = SimulationScheduler.new(state)
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

func update_to(now_unix: int, max_steps: int = -1) -> Dictionary:
    if state == null or scheduler == null:
        return {"ok":false,"reason":"runtime_owner_not_attached"}
    if b3_write_blocked:
        var retried := B3HuntWorld.commit(self)
        if not retried["ok"]:
            return retried
    var advanced := SimulationRuntimeClockV2.advance_to(
        state,scheduler,now_unix,max_steps
    )
    if not state.sect.b3_hunt.is_empty():
        var committed := B3HuntWorld.commit(self)
        if not committed["ok"]:
            return committed
    return advanced

func save_to_path(
    path: String, now_unix: int, max_steps: int = -1
) -> Dictionary:
    if state == null or scheduler == null:
        return {"ok":false,"reason":"runtime_owner_not_attached"}
    durable_path = path
    var advanced := update_to(now_unix,max_steps)
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
