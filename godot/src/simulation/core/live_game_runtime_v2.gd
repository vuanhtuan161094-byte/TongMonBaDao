class_name LiveGameRuntimeV2
extends RefCounted

# DV2-03 live-game runtime bootstrap.
#
# Presentation owns no simulation clock. This object is the single bridge from
# the main scene to persistent SimulationState + SimulationRuntimeOwnerV2.
#
# New games use the current P3.7 simulation factory. Existing saves are loaded
# first, upgraded to the live DV2-03 runtime contract, then offline time is
# applied through the same SimulationScheduler used online.

const DEFAULT_SAVE_PATH := "user://tong_mon_ba_dao_live_v2.json"
const DEFAULT_SEED := 31012026

var owner := SimulationRuntimeOwnerV2.new()
var save_path := DEFAULT_SAVE_PATH

func start(
    path: String = DEFAULT_SAVE_PATH,
    now_unix: int = -1,
    seed: int = DEFAULT_SEED,
    max_catch_up_steps: int = -1
) -> Dictionary:
    var now := _resolve_now(now_unix)
    if now <= 0:
        return {"ok":false,"reason":"invalid_live_runtime_wall_time"}
    if path.is_empty():
        return {"ok":false,"reason":"invalid_live_runtime_save_path"}
    if max_catch_up_steps == 0 or max_catch_up_steps < -1:
        return {"ok":false,"reason":"invalid_live_runtime_step_limit"}

    save_path = path
    var save_exists := FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path + ".bak")
    var loaded := SaveService.new().load_from_path(save_path)

    if save_exists and loaded == null:
        return {"ok":false,"reason":"live_runtime_save_invalid","path":save_path}

    var created := loaded == null
    var live_state: SimulationState = (
        P37Factory.create_state(seed) if created else loaded
    )
    var configured := _configure_live_state(live_state)
    if not bool(configured.get("ok",false)):
        return configured

    var attached := owner.attach(live_state,now)
    if not bool(attached.get("ok",false)):
        return attached

    owner.durable_path = save_path
    var advanced := owner.update_to(now,max_catch_up_steps)
    if not bool(advanced.get("ok",false)):
        return advanced

    # Establish the save immediately for a new run. If catch-up was bounded on
    # an existing run, its backlog remains inside runtime_unconsumed_wall_seconds.
    if created:
        var saved := owner.save_to_path(save_path,now,max_catch_up_steps)
        if not bool(saved.get("ok",false)):
            return {
                "ok":false,
                "reason":"live_runtime_initial_save_failed",
                "error":saved.get("error",FAILED)
            }

    return {
        "ok":true,
        "created":created,
        "loaded":not created,
        "catch_up_steps":int(advanced.get("steps_run",0)),
        "pending_minutes":int(advanced.get("pending_minutes",0)),
        "state":owner.state,
        "path":save_path
    }

func poll(now_unix: int = -1, max_steps: int = -1) -> Dictionary:
    if owner.state == null:
        return {"ok":false,"reason":"live_runtime_not_started"}
    return owner.update_to(_resolve_now(now_unix),max_steps)

func save(now_unix: int = -1, max_steps: int = -1) -> Dictionary:
    if owner.state == null:
        return {"ok":false,"reason":"live_runtime_not_started"}
    return owner.save_to_path(save_path,_resolve_now(now_unix),max_steps)

func state() -> SimulationState:
    return owner.state

func scheduler() -> SimulationScheduler:
    return owner.scheduler

func _configure_live_state(live_state: SimulationState) -> Dictionary:
    if live_state == null:
        return {"ok":false,"reason":"invalid_live_runtime_state"}

    var canonical_rules := DiscipleTrainingContentV2.canonical_rules()
    if canonical_rules.is_empty():
        return {"ok":false,"reason":"canonical_v2_training_rules_unavailable"}

    # New recruitment should produce authentic V2 identities. Existing legacy
    # founders are not silently rewritten; progression ownership stays strict.
    live_state.sect.disciple_v2_birth_enabled = true

    # Activate the canonical Tu Vi source for authentic V2 disciples only.
    # Body remains fail-closed because its real consumer is not implemented yet.
    live_state.sect.v2_training_enabled = true
    live_state.sect.v2_training_rules = canonical_rules
    # Explicit V2-only building migration: preserve legacy P3.7 fixtures and
    # existing saves, add this owned facility exactly once to live V2 games.
    if BuildingSystem.new().ensure_body_training_facility(live_state) == null:
        return {"ok":false,"reason":"body_training_facility_migration_failed"}

    return {"ok":true}

func _resolve_now(now_unix: int) -> int:
    if now_unix > 0:
        return now_unix
    return int(Time.get_unix_time_from_system())
