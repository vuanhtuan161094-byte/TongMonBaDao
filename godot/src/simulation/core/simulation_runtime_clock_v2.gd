class_name SimulationRuntimeClockV2
extends RefCounted

# DV2-03 persistent real-time bridge.
# Canonical mapping: 60 real seconds = 1 simulation minute = 1 scheduler step.
# This class is deterministic because callers inject wall time explicitly.
# Presentation may poll at any cadence; offline catch-up calls the same method.

const VERSION := 1
const WALL_SECONDS_PER_SIMULATION_MINUTE := 60.0

static func initialize(state: SimulationState, now_unix: int) -> Dictionary:
    if state == null or now_unix < 0:
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
    if now_unix < 0:
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
    return int(floor(
        maxf(state.runtime_unconsumed_wall_seconds,0.0) /
        WALL_SECONDS_PER_SIMULATION_MINUTE
    ))
