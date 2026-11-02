extends SceneTree
## Second independent Godot process verifies actual SaveService durability from B1 callbacks.

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if ok:
        return true
    push_error("TRI_B1_RELOAD_FAIL: " + reason)
    quit(1)
    return false

func _run() -> void:
    var save_path: String = OS.get_environment("TMB_TRI_B1_SAVE_PATH")
    var expected_path: String = OS.get_environment("TMB_TRI_B1_EXPECTED_PATH")
    if not _check(not save_path.is_empty() and not expected_path.is_empty(),
            "missing isolated cross-process QA file paths"):
        return
    var expected_file := FileAccess.open(expected_path, FileAccess.READ)
    if not _check(expected_file != null, "first process did not leave expected manifest"):
        return
    var parsed := JSON.new()
    var parse_result := parsed.parse(expected_file.get_as_text())
    expected_file.close()
    if not _check(parse_result == OK and parsed.data is Dictionary,
            "first-process manifest is not valid JSON"):
        return
    var expected: Dictionary = parsed.data
    var loaded: SimulationState = SaveService.new().load_from_path(save_path)
    if not _check(loaded != null, "second process cannot load canonical B1 SaveService file"):
        return
    if not _check(SectHallSystemV1.validate(loaded).is_empty(),
            "reloaded Hall/Residence/receipt authority violates invariants"):
        return
    var disciple_ids: Array[String] = []
    var candidate_ids: Array[String] = []
    for raw_id in loaded.disciples.keys():
        disciple_ids.append(str(raw_id))
    for raw_id in loaded.recruitment_candidates.keys():
        candidate_ids.append(str(raw_id))
    disciple_ids.sort()
    candidate_ids.sort()
    if not _check(disciple_ids == expected.get("disciple_ids", [])
            and candidate_ids == expected.get("candidate_ids", []),
            "cross-process roster or candidate identities changed"):
        return
    var accepted_id := StringName(str(expected.get("accepted_id", "")))
    if not _check(loaded.disciples.has(accepted_id)
            and not loaded.recruitment_candidates.has(accepted_id),
            "accepted B1 disciple not durably transferred out of queue"):
        return
    var hall: BuildingState = SectHallSystemV1.hall(loaded)
    if not _check(hall != null and hall.level == int(expected.get("hall_level", -1))
            and SectHallSystemV1.rank_index(loaded) == int(expected.get("rank_step", -1)),
            "Hall level/rank lost on cross-process reload"):
        return
    if not _check(SectResidenceSystemV1.all_houses(loaded).size() == int(expected.get("houses",-1))
            and loaded.sect.disciple_capacity == int(expected.get("capacity",-1))
            and loaded.sect.disciple_recruitment_tokens == int(expected.get("tokens",-1)),
            "residence capacity or paid recruitment tokens changed across process"):
        return
    print("TRI_B1_CROSS_PROCESS_RELOAD_PASS roster=%d queue=%d houses=%d accepted=%s" % [
        disciple_ids.size(),candidate_ids.size(),SectResidenceSystemV1.all_houses(loaded).size(),str(accepted_id)
    ])
    quit(0)
