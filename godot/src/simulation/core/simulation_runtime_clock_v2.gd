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
    if HuntingPveRunV2.has_active_multicamp(state):
        return _advance_multicamp(state,scheduler,elapsed,max_steps)

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
    var multicamp_id := HuntingPveRunV2.active_multicamp_id(state)
    if not multicamp_id.is_empty():
        var snapshot = state.sect.v2_pve_active_runs.get(multicamp_id,{})
        if snapshot is Dictionary:
            phase = float(snapshot.get("minute_phase",0.0))
    return int(floor(
        (maxf(state.runtime_unconsumed_wall_seconds,0.0)+phase) /
        WALL_SECONDS_PER_SIMULATION_MINUTE
    ))

static func _advance_multicamp(state: SimulationState, scheduler: SimulationScheduler,
        elapsed: int, max_steps: int) -> Dictionary:
    var encounter := HuntingPveRunV2.active_multicamp_id(state)
    var restored := HuntingPveRunV2.resume_active(state,encounter)
    if not bool(restored.get("ok",false)):
        return restored
    var session: HuntingPveRunV2 = restored["session"]
    var budget := 2400
    if max_steps > 0:
        budget = mini(budget,max_steps*240)
    var frames := 0
    var minutes := 0
    var result: Dictionary = {"ok":true,"stepped":false}
    var profile := OS.get_environment("TMB_PVE_PERF_LOG") == "1"
    var batch_started_usec := Time.get_ticks_usec() if profile else 0
    while state.runtime_unconsumed_wall_seconds >= MapBattleV2.STEP_SECONDS and frames < budget:
        result = session.advance(false)
        if bool(result.get("stepped",false)):
            state.runtime_unconsumed_wall_seconds -= MapBattleV2.STEP_SECONDS
            frames += 1
            if state.sect.v2_pve_active_runs.has(encounter):
                session.minute_phase += MapBattleV2.STEP_SECONDS
                if session.minute_phase >= WALL_SECONDS_PER_SIMULATION_MINUTE:
                    session.minute_phase -= WALL_SECONDS_PER_SIMULATION_MINUTE
                    scheduler.step()
                    minutes += 1
                # advance() already checkpoints this exact battle frame.
                # Only minute_phase changes here; persist that scalar without
                # serializing the full battle/world snapshot a second time.
                var checkpoint: Variant = state.sect.v2_pve_active_runs.get(encounter,null)
                if not (checkpoint is Dictionary) or str(checkpoint.get("encounter_id","")) != encounter:
                    result = {"ok":false,"reason":"multicamp_checkpoint_missing"}
                    break
                checkpoint["minute_phase"] = session.minute_phase
            else:
                # Carry sub-minute progress back to the one shared runtime
                # remainder when the active camp settles or is defeated.
                state.runtime_unconsumed_wall_seconds += session.minute_phase+MapBattleV2.STEP_SECONDS
                session.minute_phase = 0.0
        if not bool(result.get("ok",false)) or bool(result.get("barrier",false)):
            break
        if not state.sect.v2_pve_active_runs.has(encounter):
            break
    result.merge({"elapsed_wall_seconds":elapsed,"steps_run":minutes,
        "frames_run":frames,"pending_minutes":pending_minutes(state),
        "remainder_seconds":state.runtime_unconsumed_wall_seconds,
        "simulation_tick":state.tick},true)
    if profile and session.battle != null:
        print("TMB_PVE_RUNTIME_BATCH_METRIC "+JSON.stringify({
            "frames":frames,
            "batch_ms":float(Time.get_ticks_usec()-batch_started_usec)/1000.0,
            "battle_step_count":session.battle.performance_step_count,
            "battle_step_total_ms":float(session.battle.performance_step_usec_total)/1000.0,
            "battle_step_max_ms":float(session.battle.performance_step_usec_max)/1000.0,
            "world_path_count":session.battle.performance_world_path_count,
            "world_path_total_ms":float(session.battle.performance_world_path_usec_total)/1000.0,
            "world_path_max_ms":float(session.battle.performance_world_path_usec_max)/1000.0,
            "snapshot_count":session.performance_checkpoint_count,
            "snapshot_total_ms":float(session.performance_checkpoint_usec_total)/1000.0,
            "snapshot_max_ms":float(session.performance_checkpoint_usec_max)/1000.0,
            "snapshot_minute_phase":session.minute_phase,
            "same_active_encounter":state.sect.v2_pve_active_runs.has(encounter)
        }))
    return result

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
