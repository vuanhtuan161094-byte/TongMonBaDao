extends SceneTree

const PREVIEW := {"sect_codex":true,"technique_learning":true}
const SAVE_PATH := "user://v63_d3_learning_roundtrip.json"

var checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("V63_D3_LEARNING_FAIL: " + detail)
        _cleanup()
        quit(1)
        return false
    checks += 1
    return true

func _run() -> void:
    _cleanup()
    if not _check(not V63FeatureGates.is_enabled("technique_learning"), "D3 learning gate must default OFF"):
        return
    var loaded := V63LearningSystem.load_catalogue()
    if not _check(bool(loaded.get("ok", false)), "learning catalogue errors: " + str(loaded.get("errors", []))):
        return
    var catalog: Dictionary = loaded.data
    if not _check(catalog.techniques.size() == 12 and catalog.mastery_thresholds_xp.size() == 5,
        "D3 pilot must expose 3 school foundations, 9 branches and five mastery milestones"):
        return
    var invalid := catalog.duplicate(true)
    invalid.enabled = true
    if not _check(not V63LearningSystem.validate_catalogue(invalid).is_empty(), "release-enabled learning catalog must fail closed"):
        return

    var state := _new_state("d3_student")
    var disciple: DiscipleState = state.disciples[&"d3_student"]
    var learning := V63LearningSystem.new()
    var foundation: Dictionary = catalog.techniques[0]
    var branch: Dictionary = catalog.techniques[1]
    var other_foundation: Dictionary = catalog.techniques[4]
    var third_foundation: Dictionary = catalog.techniques[8]

    state.sect.v63_archive_opt_in = true
    state.sect.v63_learning_opt_in = true
    if not _check(not V63LearningSystem.is_enabled(state), "per-save opt-in must not bypass the global OFF gate"):
        return
    var denied := learning.start_study(state, disciple, StringName(foundation.id), "d3:gate:off", {})
    if not _check(not bool(denied.get("ok", false)) and disciple.contribution_points == 500,
        "gate-OFF start changed personal balances"):
        return
    if not _check(V63LearningSystem.is_enabled(state, PREVIEW), "explicit preview gates did not enable D3 tests"):
        return
    var missing_manual := learning.start_study(state, disciple, StringName(foundation.id), "d3:manual:missing", PREVIEW)
    if not _check(str(missing_manual.get("reason", "")) == "required_manual_not_archived",
        "unarchived source manual did not block deterministic learning: " + str(missing_manual) + " job=" + str(disciple.v63_study_job) + " active=" + str(disciple.active_job_id)):
        return
    if not _archive_source(state, foundation, "foundation"):
        return

    var available_contribution := disciple.contribution_points
    var available_stones := disciple.spirit_stones
    disciple.active_job_id = &"production:reserved"
    var existing_job := learning.start_study(state, disciple, StringName(foundation.id), "d3:study:existing-job", PREVIEW)
    if not _check(str(existing_job.get("reason", "")) == "another_active_job"
        and disciple.contribution_points == available_contribution and disciple.spirit_stones == available_stones,
        "study replaced an existing active job or consumed its cost"):
        return
    disciple.active_job_id = &""
    disciple.work_cycle_state = {"profession":"mine","phase":"travel_out"}
    var working := learning.can_start_study(state, disciple, StringName(foundation.id), PREVIEW)
    if not _check(str(working.get("reason", "")) == "disciple_has_reserved_occupation",
        "study overlapped an active P3.7 work cycle"):
        return
    disciple.work_cycle_state.clear()

    var contribution_before := disciple.contribution_points
    var stones_before := disciple.spirit_stones
    var started := learning.start_study(state, disciple, StringName(foundation.id), "d3:study:foundation", PREVIEW)
    if not _check(bool(started.get("ok", false)) and str(disciple.active_job_id) == str(started.job.job_id),
        "study did not reserve the One Active Job slot"):
        return
    if not _check(disciple.contribution_points == contribution_before - int(foundation.cost.contribution)
        and disciple.spirit_stones == stones_before - int(foundation.cost.spirit_stones),
        "candidate costs were not reserved exactly once at study start"):
        return
    var repeated_start := learning.start_study(state, disciple, StringName(foundation.id), "d3:study:foundation", PREVIEW)
    if not _check(bool(repeated_start.get("duplicate", false)) and disciple.contribution_points == contribution_before - int(foundation.cost.contribution),
        "retry duplicated a study reservation"):
        return
    var collision := learning.start_study(state, disciple, StringName(branch.id), "d3:study:foundation", PREVIEW)
    if not _check(not bool(collision.get("ok", false)) and str(collision.get("reason", "")) == "request_id_collision",
        "a reused request ID changed its operation payload"):
        return
    var busy := learning.start_study(state, disciple, StringName(other_foundation.id), "d3:study:busy", PREVIEW)
    if not _check(str(busy.get("reason", "")) == "another_active_job",
        "a disciple started a second concurrent study"):
        return
    if not _check(state.validate_invariants().is_empty(), "active study failed the state invariant: " + str(state.validate_invariants())):
        return

    var service := SaveService.new()
    if not _check(service.save_to_path(state, SAVE_PATH) == OK, "active study did not save"):
        return
    var loaded_state := service.load_from_path(SAVE_PATH)
    if not _check(loaded_state != null, "active study did not load after schema migration"):
        return
    var loaded_disciple: DiscipleState = loaded_state.disciples[&"d3_student"]
    if not _check(loaded_disciple.v63_study_job == disciple.v63_study_job
        and loaded_disciple.active_job_id == disciple.active_job_id
        and loaded_state.sect.v63_learning_active_jobs == state.sect.v63_learning_active_jobs,
        "job, active-job index or reservations did not round-trip: job=%s/%s active=%s/%s index=%s/%s" % [
            str(disciple.v63_study_job),str(loaded_disciple.v63_study_job),str(disciple.active_job_id),
            str(loaded_disciple.active_job_id),str(state.sect.v63_learning_active_jobs),str(loaded_state.sect.v63_learning_active_jobs)]):
        return

    var scheduler := SimulationScheduler.new(loaded_state)
    scheduler.v63_preview_overrides = PREVIEW.duplicate(true)
    scheduler.run_ticks(5)
    var study_progress := V63LearningSystem.study_progress(loaded_state, loaded_disciple)
    if not _check(int(study_progress.job.progress_ticks) == 5 and int(study_progress.remaining_ticks) == int(foundation.study_ticks) - 5,
        "scheduler did not advance study progress and ETA"):
        return
    var processed_again := learning.process_tick(loaded_state, PREVIEW)
    if not _check(processed_again == 0 and int(loaded_disciple.v63_study_job.progress_ticks) == 5,
        "reprocessing the same simulation tick advanced study twice"):
        return
    scheduler.v63_preview_overrides.clear()
    scheduler.run_ticks(2)
    if not _check(int(loaded_disciple.v63_study_job.progress_ticks) == 5,
        "turning the learning gate OFF did not pause the saved job"):
        return
    scheduler.v63_preview_overrides = PREVIEW.duplicate(true)
    scheduler.run_ticks(int(foundation.study_ticks) - 5)
    if not _check(loaded_disciple.known_techniques.has(str(foundation.id)) and loaded_disciple.v63_study_job.is_empty()
        and loaded_disciple.active_job_id == &"",
        "study completion did not grant personal knowledge and release the job"):
        return
    var completion_receipt_id := "study:complete:" + str(started.job.job_id)
    if not _check(loaded_state.sect.v63_learning_operation_receipts.has(completion_receipt_id),
        "study completion receipt was not persisted"):
        return
    var earned := learning.record_mastery_event(loaded_state, loaded_disciple, StringName(foundation.id), "event:mastery:1", 100.0, PREVIEW)
    if not _check(bool(earned.get("ok", false)) and int(loaded_disciple.known_techniques[str(foundation.id)].mastery_stage) == 1,
        "meaningful mastery event did not reach its deterministic milestone"):
        return
    var earned_again := learning.record_mastery_event(loaded_state, loaded_disciple, StringName(foundation.id), "event:mastery:1", 100.0, PREVIEW)
    if not _check(bool(earned_again.get("duplicate", false)) and float(loaded_disciple.known_techniques[str(foundation.id)].mastery_xp) == 100.0,
        "mastery event retry duplicated personal mastery"):
        return
    var long_mastery_id := ""
    for _index in range(V63LearningSystem.MAX_OPERATION_ID_LENGTH - "mastery:".length() + 1):
        long_mastery_id += "x"
    var long_mastery := learning.record_mastery_event(loaded_state, loaded_disciple, StringName(foundation.id), long_mastery_id, 1.0, PREVIEW)
    if not _check(not bool(long_mastery.get("ok", false)) and str(long_mastery.get("reason", "")) == "invalid_mastery_event",
        "mastery receipt key exceeded the durable operation-ID limit"):
        return

    if not _archive_source(loaded_state, branch, "branch"):
        return
    loaded_disciple.current_action = &"HOLD"
    var branch_started := learning.start_study(loaded_state, loaded_disciple, StringName(branch.id), "d3:study:branch", PREVIEW)
    if not _check(bool(branch_started.get("ok", false)), "archived branch technique did not start after its prerequisite was learned"):
        return
    var branch_scheduler := SimulationScheduler.new(loaded_state)
    branch_scheduler.v63_preview_overrides = PREVIEW.duplicate(true)
    branch_scheduler.run_ticks(int(branch.study_ticks))
    if not _check(loaded_disciple.known_techniques.has(str(branch.id)), "branch study did not complete"):
        return

    for extra in [other_foundation, third_foundation]:
        if not _archive_source(loaded_state, extra, str(extra.id)):
            return
        loaded_disciple.current_action = &"HOLD"
        var extra_start := learning.start_study(loaded_state, loaded_disciple, StringName(extra.id), "d3:study:" + str(extra.id), PREVIEW)
        if not _check(bool(extra_start.get("ok", false)), "additional school foundation did not start: " + str(extra_start)):
            return
        var extra_scheduler := SimulationScheduler.new(loaded_state)
        extra_scheduler.v63_preview_overrides = PREVIEW.duplicate(true)
        extra_scheduler.run_ticks(int(extra.study_ticks))
        if not _check(loaded_disciple.known_techniques.has(str(extra.id)), "additional school foundation did not complete"):
            return
    if not _check(bool(learning.equip_slot(loaded_state, loaded_disciple, "main", StringName(foundation.id), PREVIEW).get("ok", false))
        and bool(learning.equip_slot(loaded_state, loaded_disciple, "aux_1", StringName(branch.id), PREVIEW).get("ok", false))
        and bool(learning.equip_slot(loaded_state, loaded_disciple, "aux_2", StringName(other_foundation.id), PREVIEW).get("ok", false)),
        "1 main + 2 auxiliary loadout could not be equipped"):
        return
    var duplicate_slot := learning.equip_slot(loaded_state, loaded_disciple, "aux_2", StringName(foundation.id), PREVIEW)
    if not _check(not bool(duplicate_slot.get("ok", false)) and str(loaded_disciple.active_technique_main) == str(foundation.id),
        "same technique was equipped in two slots"):
        return

    var cancel_state := _new_state("d3_cancel_student")
    cancel_state.sect.v63_archive_opt_in = true
    cancel_state.sect.v63_learning_opt_in = true
    var cancel_disciple: DiscipleState = cancel_state.disciples[&"d3_cancel_student"]
    if not _archive_source(cancel_state, other_foundation, "cancel"):
        return
    var cancel_contribution := cancel_disciple.contribution_points
    var cancel_stones := cancel_disciple.spirit_stones
    var cancel_start := learning.start_study(cancel_state, cancel_disciple, StringName(other_foundation.id), "d3:cancel:start", PREVIEW)
    if not _check(bool(cancel_start.get("ok", false)), "cancellation fixture study did not start"):
        return
    var cancel_scheduler := SimulationScheduler.new(cancel_state)
    cancel_scheduler.v63_preview_overrides = PREVIEW.duplicate(true)
    cancel_scheduler.run_ticks(4)
    var cancel_request := "d3:cancel:" + str(cancel_start.job.job_id)
    var canceled := learning.cancel_study(cancel_state, cancel_disciple, cancel_request, str(cancel_start.job.job_id), PREVIEW)
    if not _check(bool(canceled.get("ok", false)) and cancel_disciple.v63_study_job.is_empty()
        and cancel_disciple.contribution_points == cancel_contribution and cancel_disciple.spirit_stones == cancel_stones,
        "cancellation did not release exactly the reserved costs"):
        return
    var canceled_again := learning.cancel_study(cancel_state, cancel_disciple, cancel_request, str(cancel_start.job.job_id), PREVIEW)
    if not _check(bool(canceled_again.get("duplicate", false)) and cancel_disciple.contribution_points == cancel_contribution
        and cancel_disciple.spirit_stones == cancel_stones,
        "cancel retry refunded reserved costs more than once"):
        return
    if not _check(not cancel_disciple.known_techniques.has(str(other_foundation.id)) and cancel_state.validate_invariants().is_empty(),
        "canceled study granted knowledge or violated invariants"):
        return

    if not _test_legacy_migration():
        return
    if not _check(loaded_state.validate_invariants().is_empty(), "completed learning state failed invariants: " + str(loaded_state.validate_invariants())):
        return
    print("V63_D3_LEARNING_PASS checks=%d catalog=12 jobs=exactly_once migration=additive loadout=1+2 gate_default=off" % checks)
    _cleanup()
    quit(0)

func _new_state(disciple_id: String) -> SimulationState:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 8
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    var disciple := DiscipleState.new()
    disciple.id = StringName(disciple_id)
    disciple.display_name = disciple_id
    disciple.contribution_points = 500
    disciple.spirit_stones = 500
    disciple.current_action = &"HOLD"
    state.disciples[disciple.id] = disciple
    return state

func _archive_source(state: SimulationState, info: Dictionary, suffix: String) -> bool:
    var codex_id := str(info.get("source_codex_id", ""))
    var codex := V63SectArchiveSystem.codex_definition(codex_id)
    if not _check(not codex.is_empty(), "catalogue source codex is missing: " + codex_id):
        return false
    if bool(state.sect.v63_archived_codices.get(codex_id, false)):
        return true
    var warehouse := WarehouseSystem.new()
    var manual_id := StringName(codex.get("manual_item_id", ""))
    if not _check(warehouse.add(state, manual_id, 1), "could not seed canonical Warehouse manual " + suffix):
        return false
    var archived := V63SectArchiveSystem.archive_manual(state, codex_id, PREVIEW)
    return _check(bool(archived.get("ok", false)), "could not archive manual " + suffix + ": " + str(archived))

func _test_legacy_migration() -> bool:
    var legacy := SimulationState.new()
    legacy.sect.disciple_capacity = 6
    var old_disciple := DiscipleState.new()
    old_disciple.id = &"legacy_student"
    old_disciple.learned_techniques["old_legacy_manual_id"] = {"level":4,"xp":222.0}
    old_disciple.active_technique_id = &"old_legacy_manual_id"
    legacy.disciples[old_disciple.id] = old_disciple
    var payload := legacy.to_dict()
    payload["save_version"] = 3
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if not _check(file != null, "could not create a version-3 legacy save fixture"):
        return false
    file.store_string(JSON.stringify(payload))
    file.close()
    var migrated := SaveService.new().load_from_path(SAVE_PATH)
    if not _check(migrated != null and int(SaveService.new()._build_payload(legacy).get("save_version", 0)) == SaveService.CURRENT_VERSION,
        "version-3 save did not migrate to the additive D3 schema"):
        return false
    var restored: DiscipleState = migrated.disciples[&"legacy_student"]
    return _check(restored.learned_techniques == old_disciple.learned_techniques
        and restored.active_technique_id == old_disciple.active_technique_id
        and restored.known_techniques.is_empty() and restored.active_technique_main == &""
        and restored.active_technique_aux == ["", ""] and restored.active_job_id == &"",
        "legacy P2.3 knowledge/loadout changed without an explicit identity crosswalk")

func _cleanup() -> void:
    for path in [SAVE_PATH, SAVE_PATH + ".tmp", SAVE_PATH + ".bak"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

