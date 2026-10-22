class_name SimulationRuntimeClockV2
extends RefCounted

# DV2-03 persistent real-time bridge.
# Canonical mapping: 60 real seconds = 1 simulation minute = 1 scheduler step.
# This class is deterministic because callers inject wall time explicitly.
# Presentation may poll at any cadence; offline catch-up calls the same method.

const VERSION := 1
const WALL_SECONDS_PER_SIMULATION_MINUTE := 60.0

static func initialize(state: SimulationState, now_unix: int) -> Dictionary:
    if state == null or now_unix <= 0:
        return {"ok":false,"reason":"invalid_runtime_clock_init"}
    if state.runtime_clock_version != VERSION:
        return {"ok":false,"reason":"unsupported_runtime_clock_version"}
    if state.runtime_last_wall_unix > 0:
        return {
            "ok":true,
            "initialized":false,
            "last_wall_unix":state.runtime_last_wall_unix,
            "unconsumed_wall_seconds":state.runtime_unconsumed_wall_seconds
        }
    state.runtime_last_wall_unix = now_unix
    state.runtime_unconsumed_wall_seconds = maxf(
        state.runtime_unconsumed_wall_seconds,0.0
    )
    return {
        "ok":true,
        "initialized":true,
        "last_wall_unix":state.runtime_last_wall_unix,
        "unconsumed_wall_seconds":state.runtime_unconsumed_wall_seconds
    }

static func advance_to(
    state: SimulationState, scheduler: SimulationScheduler,
    now_unix: int, max_steps: int = -1
) -> Dictionary:
    if state == null or scheduler == null or scheduler.state != state:
        return {"ok":false,"reason":"invalid_runtime_clock_owner"}
    if state.runtime_clock_version != VERSION:
        return {"ok":false,"reason":"unsupported_runtime_clock_version"}
    if now_unix <= 0:
        return {"ok":false,"reason":"invalid_wall_time"}
    if max_steps == 0 or max_steps < -1:
        return {"ok":false,"reason":"invalid_runtime_step_limit"}

    if state.runtime_last_wall_unix <= 0:
        var initialized := initialize(state,now_unix)
        if not bool(initialized.get("ok",false)):
            return initialized
        return {
            "ok":true,
            "initialized":true,
            "elapsed_wall_seconds":0,
            "steps_run":0,
            "pending_minutes":int(floor(
                state.runtime_unconsumed_wall_seconds /
                WALL_SECONDS_PER_SIMULATION_MINUTE
            )),
            "remainder_seconds":state.runtime_unconsumed_wall_seconds
        }

    # A backwards system clock must never create negative progression or let a
    # user repeatedly rewind-and-reclaim elapsed time.
    if now_unix < state.runtime_last_wall_unix:
        return {
            "ok":false,
            "reason":"wall_clock_moved_backwards",
            "last_wall_unix":state.runtime_last_wall_unix,
            "now_unix":now_unix
        }

    var elapsed := now_unix-state.runtime_last_wall_unix
    state.runtime_last_wall_unix = now_unix
    state.runtime_unconsumed_wall_seconds += float(elapsed)

    if not state.sect.b3_hunt.is_empty():
        return _advance_b3(state,scheduler,elapsed,max_steps)

    var available := int(floor(
        state.runtime_unconsumed_wall_seconds /
        WALL_SECONDS_PER_SIMULATION_MINUTE
    ))
    var steps := available if max_steps < 0 else mini(available,max_steps)

    if steps > 0:
        scheduler.run_ticks(steps)
        state.runtime_unconsumed_wall_seconds -= (
            float(steps)*WALL_SECONDS_PER_SIMULATION_MINUTE
        )
        if state.runtime_unconsumed_wall_seconds < 0.000001:
            state.runtime_unconsumed_wall_seconds = 0.0

    return {
        "ok":true,
        "initialized":false,
        "elapsed_wall_seconds":elapsed,
        "steps_run":steps,
        "pending_minutes":int(floor(
            state.runtime_unconsumed_wall_seconds /
            WALL_SECONDS_PER_SIMULATION_MINUTE
        )),
        "remainder_seconds":state.runtime_unconsumed_wall_seconds,
        "last_wall_unix":state.runtime_last_wall_unix,
        "simulation_tick":state.tick
    }

static func pending_minutes(state: SimulationState) -> int:
    if state == null:
        return 0
    var phase := float(state.sect.b3_hunt.get("minute_phase",0.0))
    return int(floor(
        (maxf(state.runtime_unconsumed_wall_seconds,0.0)+phase) /
        WALL_SECONDS_PER_SIMULATION_MINUTE
    ))

static func _advance_b3(state: SimulationState, scheduler: SimulationScheduler, elapsed: int, max_steps: int) -> Dictionary:
    var restored := B3HuntWorld.restore(state)
    if not restored["ok"]:
        return restored
    var battle: MapBattleV2 = restored["battle"]
    var budget := B3HuntWorld.MAX_BATCH_FRAMES
    if max_steps > 0:
        budget = mini(budget,max_steps*240)
    var frames := 0
    var minutes := 0
    var result := {"ok":true}
    while state.runtime_unconsumed_wall_seconds >= MapBattleV2.STEP_SECONDS and frames < budget:
        result = B3HuntWorld.advance_frame(state,battle)
        if bool(result.get("stepped",false)):
            state.runtime_unconsumed_wall_seconds -= MapBattleV2.STEP_SECONDS
            frames += 1
            state.sect.b3_hunt["minute_phase"] = float(state.sect.b3_hunt["minute_phase"])+MapBattleV2.STEP_SECONDS
            if float(state.sect.b3_hunt["minute_phase"]) >= 60.0:
                state.sect.b3_hunt["minute_phase"] = 0.0
                scheduler.step()
                minutes += 1
        if not result["ok"] or bool(result.get("barrier",false)):
            break
    B3HuntWorld.checkpoint(state,battle)
    result.merge({"elapsed_wall_seconds":elapsed,"steps_run":minutes,"frames_run":frames,
        "pending_minutes":pending_minutes(state),"remainder_seconds":state.runtime_unconsumed_wall_seconds,
        "simulation_tick":state.tick},true)
    return result
