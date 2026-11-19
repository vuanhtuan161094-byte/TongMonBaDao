extends SceneTree
const GAME := preload("res://scenes/p3/p3_2_landscape_sect.tscn")
const SAVE := "user://aschar_game_schools_qa.json"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(SAVE+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE+suffix))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE)
    if SectASCharCandidateBridgeV1.SCHOOL_IDS.size() != 12:
        _fail("not exactly 12 schools")
        return
    var count := 0
    for school in SectASCharCandidateBridgeV1.SCHOOL_IDS:
        var branches := SectASCharCandidateBridgeV1.branches_for(school)
        if branches.size() != 3:
            _fail("missing canonical 3 branches: "+school)
            return
        for sex in ["male","female"]:
            var scene := SectASCharCandidateBridgeV1.scene_for(school,sex)
            if scene == null:
                _fail("ASCHAR candidate sprite missing: "+school+" "+sex)
                return
            var sprite := scene.instantiate() as AnimatedSprite2D
            if sprite == null or sprite.sprite_frames == null \
                    or not sprite.sprite_frames.has_animation(&"stand") \
                    or not sprite.sprite_frames.has_animation(&"walk") \
                    or not sprite.sprite_frames.has_animation(&"idle_front"):
                _fail("ASCHAR action contract invalid: "+school+" "+sex)
                return
            sprite.free()
            count += 1
    var game := GAME.instantiate() as Control
    root.add_child(game)
    for i in range(9):
        await process_frame
    var state := game.get("state") as SimulationState
    if state == null or not bool(game.get("runtime_ready")):
        _fail("real game did not start")
        return
    var disciple_id := StringName(state.disciples.keys()[0])
    var disciple: DiscipleState = state.disciples[disciple_id]
    game.call("_open_disciple_deep_screen",disciple_id)
    await process_frame
    var button := game.find_child("DeepSchoolSkillsButton",true,false) as Button
    if button == null:
        _fail("school selection missing in real profile")
        return
    button.pressed.emit()
    await process_frame
    var overlay := game.find_child("SectSchoolSkillsScreenV1",true,false)
    if overlay == null:
        _fail("school skill screen did not open")
        return
    var candidate_school := "fist"
    var branches := SectASCharCandidateBridgeV1.branches_for(candidate_school)
    var branch_id := str(branches[0]["id"])
    var check := SectASCharCandidateBridgeV1.assign_branch(state,disciple,branch_id)
    if not bool(check.get("ok",false)):
        _fail("failed to assign one real school branch: "+str(check))
        return
    if bool(SectASCharCandidateBridgeV1.assign_branch(state,disciple,str(branches[1]["id"])).get("ok",false)):
        _fail("branch can be switched without a respec authority")
        return
    if str(DiscipleState.from_dict(disciple.to_dict()).v63_combat_branch_id) != branch_id:
        _fail("canonical Save roundtrip lost school branch")
        return
    if SectASCharCandidateBridgeV1.scene_for_disciple(disciple) == null:
        _fail("assigned school actor not available")
        return
    var before := disciple.v63_learned_skill_nodes.duplicate(true)
    var skill_id := "tmb.skill.fist.basic.human"
    if not V63HumanSkillCombatSystem.is_enabled(state):
        if bool(V63HumanSkillCombatSystem.learn_skill(state,disciple,skill_id).get("ok",false)):
            _fail("candidate locked combat was bypassed")
            return
    if disciple.v63_learned_skill_nodes != before:
        _fail("view-only school selection silently granted skills")
        return
    print("ASCHAR GAME PASS %d candidate sex+school actors, 36 branches, real profile, one-time choice, Save, locked skills" % count)
    quit(0)

func _fail(message: String) -> void:
    push_error("ASCHAR GAME FAIL: "+message)
    quit(1)
