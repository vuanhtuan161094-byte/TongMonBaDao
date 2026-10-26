extends SceneTree

const SAVE_PATH := "user://dv2_03_live_runtime_integration_test.json"
const BAD_SAVE_PATH := "user://dv2_03_live_runtime_invalid_test.json"

func _init() -> void:
    call_deferred("_run")

func _assert(valid: bool, reason: String) -> bool:
    if not valid:
        push_error(reason)
        _cleanup()
        quit(1)
        return false
    return true

func _close(a: float, b: float) -> bool:
    return absf(a-b) < 0.00001

func _remove(path: String) -> void:
    # SaveService writes a staged file and rotates the previous valid save to
    # .bak. Remove all test-owned artifacts so reruns cannot mistake a stale
    # backup for the missing-save fixture.
    for suffix in ["", ".tmp", ".bak"]:
        var artifact: String = path+suffix
        if FileAccess.file_exists(artifact):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(artifact))

func _cleanup() -> void:
    _remove(SAVE_PATH)
    _remove(BAD_SAVE_PATH)

func _recruit_v2(state: SimulationState, generation_index: int) -> DiscipleState:
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,state.disciples.size()+1
    )
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,generation_index
    )
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    return state.disciples[candidate.id]

func _run() -> void:
    _cleanup()

    # A missing save creates one canonical P3.7 live run and activates the
    # authentic V2 birth/training contract before any wall-clock progression.
    var runtime := LiveGameRuntimeV2.new()
    var started := runtime.start(SAVE_PATH,1000,55123)
    if not _assert(bool(started.get("ok",false)) and
        bool(started.get("created",false)) and
        FileAccess.file_exists(SAVE_PATH),
        "Live runtime did not create and persist a missing save."):
        return

    var state := runtime.state()
    if not _assert(
        state != null and
        state.p3_7_buildings_enabled and
        state.sect.disciple_v2_birth_enabled and
        state.sect.v2_training_enabled and
        not state.sect.v2_training_rules.is_empty() and
        _close(float(state.sect.v2_training_rules["cultivation"]["base_tuvi_per_minute"]),1000.0),
        "Live runtime did not activate canonical P3.7/DV2-03 authority."):
        return

    # Recruit after live activation so this is an authentic V2 identity.
    var disciple := _recruit_v2(state,991)
    if not _assert(disciple != null and
        DiscipleRealmProgressV2.owns_v2_progression(disciple),
        "Live runtime could not recruit an authentic V2 disciple."):
        return
    disciple.aptitude = 0.0
    disciple.current_action = &"HOLD"
    disciple.v2_realm_progress["training_policy"] = "manual"
    state.sect.workforce_enabled = false

    # Persist the newly recruited actor at the same wall time.
    var saved_recruit := runtime.save(1000)
    if not _assert(bool(saved_recruit.get("ok",false)),
        "Live runtime failed to save recruited V2 state."):
        return

    var disciple_id := disciple.id
    var xp_before := float(disciple.v2_realm_progress["cultivation"]["xp"])
    var partial := runtime.poll(1059)
    if not _assert(bool(partial.get("ok",false)) and
        int(partial.get("steps_run",-1))==0 and
        _close(float(disciple.v2_realm_progress["cultivation"]["xp"]),xp_before),
        "Live presentation poll granted a sub-minute simulation tick."):
        return

    var first_minute := runtime.poll(1060)
    if not _assert(bool(first_minute.get("ok",false)) and
        int(first_minute.get("steps_run",-1))==1 and
        _close(float(disciple.v2_realm_progress["cultivation"]["xp"])-xp_before,1000.0),
        "Live runtime minute did not grant canonical 1,000 base Tu Vi."):
        return

    var first_saved_tick := state.tick
    var first_saved_xp := float(disciple.v2_realm_progress["cultivation"]["xp"])
    if not _assert(bool(runtime.save(1060).get("ok",false)),
        "Live runtime failed to persist the first canonical minute."):
        return

    # Reopening at +120s must load the exact save, apply two scheduler minutes,
    # and must not recreate/append any presentation-only demo roster.
    var disciple_count := state.disciples.size()
    var capacity := state.sect.disciple_capacity
    var reopened := LiveGameRuntimeV2.new()
    var loaded := reopened.start(SAVE_PATH,1180,99999)
    if not _assert(bool(loaded.get("ok",false)) and
        bool(loaded.get("loaded",false)) and
        not bool(loaded.get("created",true)) and
        int(loaded.get("catch_up_steps",-1))==2,
        "Live runtime did not apply exactly two offline minutes on reopen."):
        return

    var loaded_state := reopened.state()
    if not _assert(
        loaded_state.disciples.size()==disciple_count and
        loaded_state.sect.disciple_capacity==capacity and
        loaded_state.tick==first_saved_tick+2 and
        loaded_state.disciples.has(disciple_id),
        "Reopen mutated roster/capacity or lost the V2 disciple."):
        return

    var loaded_disciple: DiscipleState = loaded_state.disciples[disciple_id]
    if not _assert(
        _close(float(loaded_disciple.v2_realm_progress["cultivation"]["xp"])-first_saved_xp,2000.0) and
        loaded_state.sect.disciple_v2_birth_enabled and
        loaded_state.sect.v2_training_enabled,
        "Offline reopen did not use the same canonical V2 progression contract."):
        return

    var same_time := reopened.poll(1180)
    if not _assert(bool(same_time.get("ok",false)) and
        int(same_time.get("steps_run",-1))==0 and
        _close(float(loaded_disciple.v2_realm_progress["cultivation"]["xp"]),first_saved_xp+2000.0),
        "Polling the same wall timestamp duplicated progression."):
        return

    # Corrupt data must fail closed and must never be overwritten by a new run.
    var bad := FileAccess.open(BAD_SAVE_PATH,FileAccess.WRITE)
    if not _assert(bad != null,"Could not create corrupt-save fixture."):
        return
    bad.store_string("{ definitely not a valid save")
    bad.close()
    var bad_before := FileAccess.get_file_as_string(BAD_SAVE_PATH)
    var invalid_runtime := LiveGameRuntimeV2.new()
    var invalid := invalid_runtime.start(BAD_SAVE_PATH,2000,123)
    var bad_after := FileAccess.get_file_as_string(BAD_SAVE_PATH)
    if not _assert(not bool(invalid.get("ok",true)) and
        str(invalid.get("reason",""))=="live_runtime_save_invalid" and
        bad_before==bad_after,
        "Corrupt live save was not rejected without overwrite."):
        return

    _cleanup()
    print("DV2-03 LIVE P3 RUNTIME SAVE/OFFLINE INTEGRATION: PASS")
    quit(0)
