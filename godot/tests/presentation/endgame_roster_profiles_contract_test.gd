extends SceneTree

# Read-only QA for the *generated* isolated 130/200/500 official SaveService
# profiles. Generate using the real endgame_fixture_generator.gd first.
# This does not fake/prove natural early-to-endgame progression or FPS.
const COUNTS := {"mine":30,"linh_forest":30,"spirit_field":40}

func _init() -> void:
    call_deferred("_run")

func _fail(reason: String, context: Dictionary = {}) -> void:
    printerr("TMB_ENDGAME_ROSTER_PROFILE FAIL "+JSON.stringify({
        "reason":reason,"context":context}))
    quit(1)

func _run() -> void:
    var roster := 130
    for arg in OS.get_cmdline_user_args():
        if str(arg).begins_with("--tmb-roster="):
            var value := str(arg).trim_prefix("--tmb-roster=")
            if not value.is_valid_int() or not [130,200,500].has(int(value)):
                _fail("invalid_roster_profile",{"arg":arg})
                return
            roster = int(value)
    var file := "res://qa/endgame_qa_save.json"
    if roster != 130:
        file = "res://qa/endgame_qa_save_%d.json" % roster
    if not FileAccess.file_exists(file):
        _fail("generate_isolated_qa_save_first",{"file":file,"roster":roster})
        return
    var state := SaveService.new().load_from_path(file)
    if state == null:
        _fail("official_SaveService_cannot_load_qa_profile",{"file":file})
        return
    if state.disciples.size() != roster:
        _fail("profile_roster_count_mismatch",{"wanted":roster,
            "observed":state.disciples.size()})
        return
    var invalid := state.validate_invariants()
    if not invalid.is_empty():
        _fail("saved_canonical_invariants_failed",{"errors":invalid})
        return
    var counts: Dictionary = {}
    for building in state.buildings.values():
        var kind := str(building.building_type)
        counts[kind] = int(counts.get(kind,0))+1
    for kind in COUNTS.keys():
        if int(counts.get(kind,0)) != int(COUNTS[kind]):
            _fail("producer_capacity_missing",{"kind":kind,
                "observed":counts.get(kind,0)})
            return
    var assigned: Dictionary = {}
    var distinct_sites: Dictionary = {}
    for d in state.disciples.values():
        if d.worksite_building_id == &"":
            continue
        var site_id := str(d.worksite_building_id)
        var worker := str(d.id)
        if not state.buildings.has(site_id) or assigned.has(worker):
            _fail("worksite_or_duplicate_worker",{"disciple":worker,
                "site":site_id})
            return
        assigned[worker] = site_id
        distinct_sites[site_id] = true
    if assigned.size() != 100 or distinct_sites.size() != 100:
        _fail("active_100_worker_contract_changed",{
            "workers":assigned.size(),"sites":distinct_sites.size()})
        return
    var file_reader := FileAccess.open(file,FileAccess.READ)
    var byte_count := file_reader.get_length() if file_reader != null else -1
    if file_reader != null:
        file_reader.close()
    print("TMB_ENDGAME_ROSTER_PROFILE PASS "+JSON.stringify({
        "roster":roster,"production_sites":100,"workers":100,
        "site_count":counts,"save_size_bytes":byte_count,
        "caveat":"static saved-state integrity only; official screenshot/FPS still required"}))
    quit(0)
