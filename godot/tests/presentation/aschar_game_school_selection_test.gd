extends SceneTree
const GAME := preload("res://scenes/p3/p3_2_landscape_sect.tscn")
const SAVE := "user://aschar_game_schools_qa.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(SAVE+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE+suffix))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE)
    if SectASCharCandidateBridgeV1.SCHOOL_IDS.size() != 12:
        _fail("not exactly 12 schools")
        return
    # Avoid decoding 24 x 96 full-resolution RGBA frame sets in one CI process.
    # Confirm all 24 IDs have a loadable source path and a socket contract,
    # and fully instantiate representative male/female + repaired sources.
    var count := 0
    for school in SectASCharCandidateBridgeV1.SCHOOL_IDS:
        var branches := SectASCharCandidateBridgeV1.branches_for(school)
        if branches.size() != 3:
            _fail("missing canonical 3 branches: "+school)
            return
        for sex in ["male","female"]:
            var id := SectASCharCandidateBridgeV1.actor_id(school,sex)
            var path := str(SectASCharCandidateBridgeV1.SOURCE_PATHS.get(id,""))
            if path.is_empty() or not ResourceLoader.exists(path,"SpriteFrames"):
                _fail("ASCHAR SpriteFrames missing: "+school+" "+sex)
                return
            var sockets := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/actor_sockets/AS%d_weapon_sockets_v9_3_candidate.json" % id
            if not FileAccess.file_exists(sockets):
                _fail("ASCHAR per-frame sockets missing: "+school+" "+sex)
                return
            count += 1
    for school in ["sword","fist","talisman"]:
        var sex := "female" if school == "talisman" else "male"
        if SectASCharCandidateBridgeV1.preview_texture(school,sex) == null:
            _fail("school choice portrait did not load authored idle source")
            return
        var scene := SectASCharCandidateBridgeV1.scene_for(school,sex)
        if scene == null:
            _fail("ASCHAR runtime scene missing: "+school+" "+sex)
            return
        var sprite := scene.instantiate() as AnimatedSprite2D
        if sprite == null or sprite.sprite_frames == null \
                or not sprite.sprite_frames.has_animation(&"stand") \
                or not sprite.sprite_frames.has_animation(&"walk") \
                or not sprite.sprite_frames.has_animation(&"idle_front"):
            _fail("ASCHAR runtime action contract invalid: "+school+" "+sex)
            return
        sprite.free()
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
    if not SectASCharCandidateBridgeV1.school_for_disciple(disciple).is_empty():
        _fail("new novice was assigned a school without player selection")
        return
    var novice_actor_id := SectASCharCandidateBridgeV1.actor_id_for_disciple(disciple)
    var novice_portrait := SectASCharCandidateBridgeV1.preview_texture_for_disciple(disciple)
    if novice_actor_id < 48 or novice_actor_id > 71 or novice_portrait == null:
        _fail("novice missing deterministic source-backed starter visual")
        return
    if novice_actor_id != SectASCharCandidateBridgeV1.actor_id_for_disciple(
            DiscipleState.from_dict(disciple.to_dict())):
        _fail("novice visual rerolled through Save serialization")
        return
    # The Hall must display the same authoritative visual as map/PvE.
    var hall := DaiDienScreenV1.new()
    var hall_preview := hall._aschar_portrait(disciple)
    var hall_image := hall_preview.find_child("HallASCharPortrait",true,false) as TextureRect
    if hall_image == null or hall_image.texture != novice_portrait:
        _fail("Hall portrait differs from the novice AS-CHAR Save identity")
        return
    hall_preview.free()
    hall.free()
    # B1 must display valid candidate frames without claiming art approval.
    var b1_script := preload("res://src/presentation/uiux/dan_tien_screen_b1_v1.gd")
    var b1 := b1_script.new() as Control
    var b1_block := b1.call("_candidate_portrait",{
        "name":disciple.display_name, "quality":"common",
        "portrait":novice_portrait, "portrait_verified":true,
        "source_art_approved":false
    }) as Control
    if b1_block == null or b1_block.find_child("ASCharCandidatePreview",true,false) == null:
        _fail("B1 recruitment hid a valid AS-CHAR candidate portrait")
        return
    b1_block.free()
    b1.free()
    # Dẫn Tiên uses the same bridge for the candidate before acceptance.
    if not state.recruitment_candidates.is_empty():
        var first_candidate: CandidateState = state.recruitment_candidates.values()[0]
        var dan := DanTienScreenV2.new()
        var candidate_preview := dan._aschar_preview(first_candidate)
        var candidate_image := candidate_preview.find_child("CandidateASCharPortrait",true,false) as TextureRect
        if SectASCharCandidateBridgeV1.preview_texture_for_disciple(first_candidate.to_disciple()) != null \
                and (candidate_image == null or candidate_image.texture == null):
            _fail("recruitment preview does not display the candidate AS-CHAR")
            return
        candidate_preview.free()
        dan.free()
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
    for school in SectASCharCandidateBridgeV1.SCHOOL_IDS:
        var seal := overlay.find_child("SchoolChoice_"+school,true,false) as Button
        if seal == null or seal.icon == null or seal.icon.get_size() != Vector2(64,64):
            _fail("missing school seal "+school)
            return
    var school_choice := overlay.find_child("SchoolChoice_fist",true,false) as Button
    if school_choice == null:
        _fail("missing Fist browse action")
        return
    school_choice.pressed.emit()
    await process_frame
    var browse_branches := SectASCharCandidateBridgeV1.branches_for("fist")
    var browse_id := str(browse_branches[1]["id"])
    var browse := overlay.find_child("SchoolBranch_"+browse_id,true,false) as Button
    if browse == null:
        _fail("missing second branch preview")
        return
    browse.pressed.emit()
    await process_frame
    if not str(disciple.v63_combat_branch_id).is_empty() or str(overlay.get("_preview_branch")) != browse_id:
        _fail("preview assigned disciple or lost selected branch")
        return
    var tier := overlay.find_child("SchoolTier_immortal",true,false) as Button
    if tier == null:
        _fail("missing immortal browse tab")
        return
    tier.pressed.emit()
    await process_frame
    var list := overlay.find_child("SchoolSkillList",true,false)
    if str(overlay.get("_skill_tier")) != "immortal" or list == null or list.get_child_count() <= 10:
        _fail("higher-tier browse still truncated or unavailable")
        return
    for row in list.get_children():
        for control in row.get_children():
            if control is Button and not control.disabled:
                _fail("unassigned preview allowed skill action")
                return
    if overlay.find_child("SchoolConfirmBranch",true,false) == null:
        _fail("missing explicit branch confirmation")
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
    if not V63HumanSkillCombatSystem.branch_definitions().has(branch_id):
        _fail("chosen school did not match canonical V63 combat branch ID")
        return
    if SectASCharCandidateBridgeV1.school_for_branch(branch_id) != candidate_school:
        _fail("school visual crosswalk cannot resolve combat branch")
        return
    if SectASCharCandidateBridgeV1.visual_school_for_disciple(disciple) != candidate_school:
        _fail("confirmed branch did not switch from novice art to school art")
        return
    var combat_errors := V63HumanSkillCombatSystem.validate_state(state)
    if not combat_errors.is_empty():
        _fail("V63 combat state rejects school assignment: "+str(combat_errors))
        return
    if str(DiscipleState.from_dict(disciple.to_dict()).v63_combat_branch_id) != branch_id:
        _fail("canonical Save roundtrip lost school branch")
        return
    if SectASCharCandidateBridgeV1.scene_for_disciple(disciple) == null:
        _fail("assigned school actor not available")
        return
    overlay.call("refresh")
    await process_frame
    var other_school := overlay.find_child("SchoolChoice_sword",true,false) as Button
    if other_school == null or other_school.disabled:
        _fail("assigned disciple cannot browse another school")
        return
    other_school.pressed.emit()
    await process_frame
    var confirm := overlay.find_child("SchoolConfirmBranch",true,false) as Button
    if str(overlay.get("_school")) != "sword" or confirm == null or not confirm.disabled:
        _fail("cross-school browsing changed or unlocked affiliation")
        return
    if str(disciple.v63_combat_branch_id) != branch_id:
        _fail("cross-school browse mutated branch")
        return
    var other_list := overlay.find_child("SchoolSkillList",true,false)
    for row in other_list.get_children():
        for control in row.get_children():
            if control is Button and not control.disabled:
                _fail("cross-school browse enabled skill actions")
                return
    # Optional capture from the actual game scene, never a reconstructed mockup.
    var capture := OS.get_environment("TMB_SCHOOL_SCREEN_CAPTURE")
    if not capture.is_empty() and DisplayServer.get_name() != "headless":
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        if image == null or image.save_png(capture) != OK:
            _fail("school screen capture failed")
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
    # P2 skills are the already-active combat system. Learning them through
    # the profile must use the actual CombatSkillSystem authority.
    var basic_skill := &"thanh_phong_tram"
    var can_basic := CombatSkillSystem.new().can_learn_skill(state,disciple,basic_skill)
    var prev_known := disciple.learned_combat_skills.duplicate(true)
    game.call("_aschar_skill_action",disciple_id,str(basic_skill),"learn_basic")
    var basic_learned := bool(disciple.learned_combat_skills.get(str(basic_skill),false))
    if can_basic and not basic_learned:
        _fail("P2 combat skill did not learn through real profile action")
        return
    if not can_basic and disciple.learned_combat_skills != prev_known:
        _fail("P2 stage/feature gate bypassed")
        return
    print("ASCHAR GAME PASS %d candidate sex+school actors, 36 branches, real profile, one-time choice, Save, locked skills" % count)
    quit(0)

func _fail(message: String) -> void:
    push_error("ASCHAR GAME FAIL: "+message)
    quit(1)
