extends SceneTree
## Genuine cross-process SaveService school identity persistence.
## -- create, then a separate Godot process -- verify.
## Isolated QA path, no live player save and no V6.3 skill permission changes.
const SAVE_PATH := "user://qa_aschar_pve_school_20261119.json"
const EXPECTED_PATH := "user://qa_aschar_pve_school_expected_20261119.json"
const NOW := 1802400000

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var phase := str(args[0]) if not args.is_empty() else ""
    match phase:
        "create": _create()
        "verify": _verify()
        _: _fail("expected create or verify")

func _create() -> void:
    for path in [SAVE_PATH,SAVE_PATH+".bak",SAVE_PATH+".tmp",EXPECTED_PATH]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    var runtime := LiveGameRuntimeV2.new()
    var result := runtime.start(SAVE_PATH,NOW)
    if not bool(result.get("ok",false)):
        _fail("failed to start canonical New Game: "+str(result))
        return
    var state: SimulationState = runtime.state()
    if state == null or state.disciples.is_empty():
        _fail("New Game has no playable disciples")
        return
    var chosen: DiscipleState
    for raw_id in state.disciples:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.v63_combat_branch_id == &"" and disciple.region_id == &"sect":
            chosen = disciple
            break
    if chosen == null:
        _fail("no eligible novice disciple")
        return
    var branches := SectASCharCandidateBridgeV1.branches_for("fist")
    if branches.size() != 3:
        _fail("canonical fist school missing three branches")
        return
    var branch := str(branches[0].get("id",""))
    var assigned := SectASCharCandidateBridgeV1.assign_branch(state,chosen,branch)
    if not bool(assigned.get("ok",false)):
        _fail("canonical branch assignment failed: "+str(assigned))
        return
    var sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(chosen))
    var actor_id := SectASCharCandidateBridgeV1.actor_id("fist",sex)
    if actor_id < 0 or PveASCharFrameRendererV1._manifest(actor_id).is_empty():
        _fail("chosen disciple has no source-backed PvE actor")
        return
    if not chosen.v63_learned_skill_nodes.is_empty():
        _fail("branch assignment granted locked V6.3 skills")
        return
    var saved := runtime.save(NOW+60)
    if not bool(saved.get("ok",false)) or not FileAccess.file_exists(SAVE_PATH):
        _fail("canonical SaveService refused branch save: "+str(saved))
        return
    var file := FileAccess.open(EXPECTED_PATH,FileAccess.WRITE)
    if file == null:
        _fail("cannot write isolated QA witness")
        return
    file.store_string(JSON.stringify({"id":str(chosen.id),"branch":branch,"sex":sex,"actor_id":actor_id}))
    file.close()
    print("ASCHAR_SAVE_PHASE1_PASS actor=%d branch=%s" % [actor_id,branch])
    quit(0)

func _verify() -> void:
    if not FileAccess.file_exists(EXPECTED_PATH):
        _fail("missing phase-1 identity witness")
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(EXPECTED_PATH))
    if not (data is Dictionary):
        _fail("invalid QA witness")
        return
    var expected: Dictionary = data
    var runtime := LiveGameRuntimeV2.new()
    var result := runtime.start(SAVE_PATH,NOW+60)
    if not bool(result.get("ok",false)) or not bool(result.get("loaded",false)):
        _fail("cold reload failed: "+str(result))
        return
    var state: SimulationState = runtime.state()
    var id := StringName(str(expected.get("id","")))
    if state == null or not state.disciples.has(id):
        _fail("cold Save lost disciple identity")
        return
    var disciple: DiscipleState = state.disciples[id]
    var branch := str(disciple.v63_combat_branch_id)
    var school := SectASCharCandidateBridgeV1.school_for_disciple(disciple)
    var sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple))
    var actor_id := SectASCharCandidateBridgeV1.actor_id(school,sex)
    if branch != str(expected.get("branch","")) or school != "fist" or sex != str(expected.get("sex","")) or actor_id != int(expected.get("actor_id",-1)):
        _fail("cold Save changed branch/school/sex/PvE art ID")
        return
    if not disciple.v63_learned_skill_nodes.is_empty():
        _fail("cold Save illegally unlocked V6.3 skills")
        return
    if PveASCharFrameRendererV1._manifest(actor_id).is_empty():
        _fail("PvE actor source missing after cold Save")
        return
    print("ASCHAR_COLD_SAVE_RELOAD_PASS actor=%d branch=%s" % [actor_id,branch])
    quit(0)

func _fail(reason: String) -> void:
    push_error("ASCHAR_COLD_SAVE_RELOAD_FAIL "+reason)
    quit(1)
