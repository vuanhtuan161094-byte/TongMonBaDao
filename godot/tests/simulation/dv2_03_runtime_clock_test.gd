extends SceneTree

const SAVE_PATH := "user://dv2_03_runtime_clock_test.json"

func _init() -> void:
    call_deferred("_run")

func _assert(valid: bool, reason: String) -> bool:
    if not valid:
        push_error(reason)
        quit(1)
        return false
    return true

func _close(a: float, b: float) -> bool:
    return absf(a-b) < 0.00001

func _make_state(seed: int) -> Dictionary:
    var state := P37Factory.create_state(seed)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,state.disciples.size()+1
    )
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,913
    )
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return {}
    var disciple: DiscipleState = state.disciples[candidate.id]
    # Preserve the generated D7 birth stats; changing aptitude directly can
    # desynchronize the authored quality band and make SaveService reject it.
    var foundation_errors: Array[String] = FoundationSystem.new().validate_disciple(disciple)
    if not foundation_errors.is_empty():
        push_error("DV2-03 fixture contains an invalid D7 disciple: "+str(foundation_errors))
        return {}
    disciple.current_action = &"HOLD"
    disciple.v2_realm_progress["training_policy"] = "manual"
    state.sect.workforce_enabled = false
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    return {"state":state,"disciple_id":candidate.id}

func _tuvi(state: SimulationState, disciple_id: StringName) -> float:
    var disciple: DiscipleState = state.disciples[disciple_id]
    return float(disciple.v2_realm_progress["cultivation"]["xp"])

func _run() -> void:
    var fixture := _make_state(44421)
    if not _assert(not fixture.is_empty(),"Could not create runtime-clock fixture."):
        return
    var state: SimulationState = fixture["state"]
    var disciple_id := StringName(fixture["disciple_id"])
    var scheduler := SimulationScheduler.new(state)

    var init := SimulationRuntimeClockV2.initialize(state,1000)
    if not _assert(bool(init.get("ok",false)) and
        state.runtime_last_wall_unix==1000 and
        _close(state.runtime_unconsumed_wall_seconds,0.0),
        "Runtime clock failed initialization."):
        return

    var before := _tuvi(state,disciple_id)
    var partial := SimulationRuntimeClockV2.advance_to(
        state,scheduler,1059
    )
    if not _assert(bool(partial.get("ok",false)) and
        int(partial.get("steps_run",-1))==0 and
        state.tick==0 and
        _close(state.runtime_unconsumed_wall_seconds,59.0) and
        _close(_tuvi(state,disciple_id),before),
        "59 wall seconds incorrectly produced a simulation minute."):
        return

    # Compare the clock-driven minute to one canonical scheduler step using
    # the same valid generated disciple, not a hand-edited foundation value.
    var one_tick_control: SimulationState = SimulationState.from_dict(state.to_dict())
    if not _assert(one_tick_control != null,
        "Could not clone the valid D7 fixture for one-step comparison."):
        return
    var one_tick_scheduler := SimulationScheduler.new(one_tick_control)
    one_tick_scheduler.step()
    var first_minute := SimulationRuntimeClockV2.advance_to(
        state,scheduler,1060
    )
    if not _assert(bool(first_minute.get("ok",false)) and
        int(first_minute.get("steps_run",-1))==1 and
        state.tick==1 and
        _close(state.runtime_unconsumed_wall_seconds,0.0) and
        _close(_tuvi(state,disciple_id)-before,
            _tuvi(one_tick_control,disciple_id)-before),
        "60 real seconds did not produce exactly one canonical scheduler step."):
        return

    # Persist the exact wall timestamp/remainder with the simulation state.
    var saves := SaveService.new()
    var save_error: Error = saves.save_to_path(state,SAVE_PATH)
    var save_error_detail := "Runtime-clock save failed (error=%d %s; user_data=%s; path=%s)." % [
        save_error,error_string(save_error),OS.get_user_data_dir(),
        ProjectSettings.globalize_path(SAVE_PATH)
    ]
    if not _assert(save_error==OK,save_error_detail):
        return
    var offline: SimulationState = saves.load_from_path(SAVE_PATH)
    var online: SimulationState = saves.load_from_path(SAVE_PATH)
    var chunked: SimulationState = saves.load_from_path(SAVE_PATH)
    if not _assert(offline != null and online != null and chunked != null,
        "Runtime-clock save could not be loaded for comparison."):
        return
    if not _assert(offline.runtime_last_wall_unix==1060 and
        _close(offline.runtime_unconsumed_wall_seconds,0.0),
        "Wall-clock metadata did not survive SaveService."):
        return

    # Offline: one jump of five minutes.
    var offline_scheduler := SimulationScheduler.new(offline)
    var offline_result := SimulationRuntimeClockV2.advance_to(
        offline,offline_scheduler,1360
    )
    if not _assert(bool(offline_result.get("ok",false)) and
        int(offline_result.get("steps_run",-1))==5,
        "Offline catch-up did not run five simulation minutes."):
        return

    # Online: same elapsed wall time delivered one minute at a time.
    var online_scheduler := SimulationScheduler.new(online)
    for now in [1120,1180,1240,1300,1360]:
        var result := SimulationRuntimeClockV2.advance_to(
            online,online_scheduler,int(now)
        )
        if not _assert(bool(result.get("ok",false)) and
            int(result.get("steps_run",-1))==1,
            "Online minute cadence failed."):
            return

    var offline_disciple: DiscipleState = offline.disciples[disciple_id]
    var online_disciple: DiscipleState = online.disciples[disciple_id]
    if not _assert(
        offline.tick==online.tick and
        offline.rng_state==online.rng_state and
        offline_disciple.v2_realm_progress==online_disciple.v2_realm_progress and
        _close(_tuvi(offline,disciple_id),_tuvi(online,disciple_id)),
        "Offline catch-up diverged from equal online elapsed time."):
        return

    # Large catch-up may be processed in bounded chunks without discarding time.
    var chunk_scheduler := SimulationScheduler.new(chunked)
    var first_chunk := SimulationRuntimeClockV2.advance_to(
        chunked,chunk_scheduler,1360,2
    )
    if not _assert(bool(first_chunk.get("ok",false)) and
        int(first_chunk.get("steps_run",-1))==2 and
        int(first_chunk.get("pending_minutes",-1))==3 and
        _close(chunked.runtime_unconsumed_wall_seconds,180.0),
        "Bounded catch-up lost or miscounted pending minutes."):
        return
    var second_chunk := SimulationRuntimeClockV2.advance_to(
        chunked,chunk_scheduler,1360
    )
    var chunked_disciple: DiscipleState = chunked.disciples[disciple_id]
    if not _assert(bool(second_chunk.get("ok",false)) and
        int(second_chunk.get("steps_run",-1))==3 and
        int(second_chunk.get("pending_minutes",-1))==0 and
        chunked.tick==offline.tick and
        chunked_disciple.v2_realm_progress==
            offline_disciple.v2_realm_progress,
        "Chunked catch-up did not converge to the same state."):
        return

    var tick_before_rollback := chunked.tick
    var rollback := SimulationRuntimeClockV2.advance_to(
        chunked,chunk_scheduler,1300
    )
    if not _assert(not bool(rollback.get("ok",true)) and
        str(rollback.get("reason",""))=="wall_clock_moved_backwards" and
        chunked.tick==tick_before_rollback,
        "Backwards wall clock mutated simulation progress."):
        return

    # Runtime owner must catch up before save and again on load without a
    # presentation-owned second clock.
    var owner_fixture := _make_state(77221)
    if not _assert(not owner_fixture.is_empty(),
        "Could not create runtime-owner fixture."):
        return
    var owner_state: SimulationState = owner_fixture["state"]
    var owner_id := StringName(owner_fixture["disciple_id"])
    var owner := SimulationRuntimeOwnerV2.new()
    var attached := owner.attach(owner_state,2000)
    if not _assert(bool(attached.get("ok",false)),
        "Runtime owner failed to attach."):
        return
    var owner_save := owner.save_to_path(SAVE_PATH,2120)
    if not _assert(bool(owner_save.get("ok",false)) and
        int(owner_save.get("steps_run",-1))==2 and
        owner.state.runtime_last_wall_unix==2120,
        "Runtime owner did not advance exactly to save time."):
        return
    var owner_saved_tuvi := _tuvi(owner.state,owner_id)

    var expected_after_reload: SimulationState = SimulationState.from_dict(owner.state.to_dict())
    if not _assert(expected_after_reload != null,
        "Could not clone the saved runtime state for three-step catch-up comparison."):
        return
    var expected_reload_scheduler := SimulationScheduler.new(expected_after_reload)
    expected_reload_scheduler.run_ticks(3)
    var reloaded_owner := SimulationRuntimeOwnerV2.new()
    var reloaded := reloaded_owner.load_from_path(SAVE_PATH,2300)
    if not _assert(bool(reloaded.get("ok",false)) and
        int(reloaded.get("catch_up_steps",-1))==3 and
        reloaded_owner.state.tick==owner.state.tick+3 and
        reloaded_owner.state.rng_state==expected_after_reload.rng_state and
        _close(_tuvi(reloaded_owner.state,owner_id)-owner_saved_tuvi,
            _tuvi(expected_after_reload,owner_id)-owner_saved_tuvi),
        "Runtime owner load did not apply exactly three canonical offline scheduler steps."):
        return

    print("DV2-03 ONLINE/OFFLINE RUNTIME CLOCK EQUIVALENCE: PASS")
    quit(0)
