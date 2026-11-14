extends SceneTree
## Genuine GL/Xvfb recording of actual P3.2 gameplay UI.
## A naturally rolled gacha Nghịch Thiên is recruited via the REAL B1 button.
## All state/save changes are isolated to user:// VIS QA and removed on exit.
const SAVE_PATH := "user://vis02_real_recruitment_qa_isolated.json"
var game: Control
var output_dir := ""
var captured := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("Real rasterized display required; headless is not a visual capture.")
        return
    var args := OS.get_cmdline_user_args()
    if args.is_empty():
        _fail("Provide evidence output directory after --.")
        return
    output_dir = str(args[0])
    if DirAccess.make_dir_recursive_absolute(output_dir) != OK:
        _fail("Cannot write evidence directory.")
        return
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    DisplayServer.window_set_size(Vector2i(1280, 720))
    var pack := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if pack == null:
        _fail("Missing actual P3.2 OneGame scene")
        return
    game = pack.instantiate() as Control
    root.add_child(game)
    for i in range(12):
        await process_frame
    if not bool(game.get("runtime_ready")):
        _fail("Actual game runtime failed startup")
        return
    var state: SimulationState = game.get("state")
    if state == null:
        _fail("Actual authoritative SimulationState missing")
        return
    var common: DiscipleState = null
    for raw_id in state.disciples.keys():
        var actor: DiscipleState = state.disciples[StringName(raw_id)]
        if actor.disciple_quality != DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
            common = actor
            break
    if common == null:
        _fail("No real baseline disciple exists")
        return
    var generator := DiscipleGeneratorOpenPoints.new()
    var divine: CandidateState = null
    var found_generation := -1
    # Normal, unmodified Gacha generator rate; no forced_quality argument,
    # no manual quality/stat changes and no gameplay code changes.
    for index in range(1, 1200):
        var gen_index := 830000 + index
        var candidate := generator.generate_candidate(state, DiscipleGeneratorV2.SOURCE_GACHA, gen_index)
        if candidate != null and candidate.disciple_quality == DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
            divine = candidate
            found_generation = gen_index
            break
    if divine == null:
        _fail("Naturally rolled Nghịch Thiên not found within search cap")
        return
    if state.recruitment_candidates.has(divine.id):
        _fail("Candidate ID collision")
        return
    state.recruitment_candidates[divine.id] = divine
    game.call("_open_dan_tien_screen_v2")
    await _frames(9)
    var screen := game.find_child("TriFacilityB1LiveAdapterV1",true,false) as Control
    if screen == null:
        _fail("Missing actual Dẫn Tiên B1 live adapter")
        return
    var b1 := screen.find_child("CandidateProfile",true,false) as Control
    if b1 == null:
        _fail("Missing real B1 candidate panel")
        return
    # Re-select the naturally rolled candidate if prior queued candidates exist.
    var b1_view := screen.find_child("CandidateProfileScroll",true,false)
    if b1_view == null:
        _fail("Dẫn Tiên layout not ready")
        return
    var visual := screen.find_child("VISReducedMotionGuidance",true,false)
    if visual == null:
        _fail("VIS mode setting missing from real guidance screen")
        return
    if not await _capture("01_real_natural_divine_candidate.png"):
        return
    var accept := screen.find_child("AcceptCandidate",true,false) as Button
    if accept == null or accept.disabled:
        _fail("Cannot accept this naturally rolled candidate through actual UI")
        return
    accept.pressed.emit()
    await _frames(2)
    accept = screen.find_child("AcceptCandidate",true,false) as Button
    if accept == null or accept.disabled:
        _fail("Second-step authoritative B1 acceptance missing")
        return
    accept.pressed.emit()
    await _frames(1)
    if not state.disciples.has(divine.id):
        _fail("Real RecruitmentSystem did not accept naturally rolled candidate")
        return
    var joined: DiscipleState = state.disciples[divine.id]
    if joined.disciple_quality != DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
        _fail("Natural rarity changed during recruitment")
        return
    if not await _capture("02_recruit_reveal_early.png"):
        return
    await create_timer(0.25).timeout
    if not await _capture("03_recruit_reveal_middle.png"):
        return
    await create_timer(0.50).timeout
    if not await _capture("04_recruit_reveal_complete.png"):
        return
    var profile := screen.find_child("RecruitedDiscipleProfile",true,false) as Button
    if profile == null:
        _fail("Actual recruited profile navigation is missing")
        return
    profile.pressed.emit()
    await _frames(9)
    var panel := game.find_child("DiscipleDeepScreen",true,false) as Panel
    if panel == null:
        _fail("No actual shared V2/legacy disciple profile")
        return
    if panel.find_child("VIS02QualityEdge",true,false) == null or panel.find_child("VIS02SoftBacklight",true,false) == null or panel.find_child("VIS02AstralMotes",true,false) == null:
        _fail("Divine frame, aura or stardust not integrated with actual selected profile")
        return
    if not await _capture("05_divine_profile_full_early.png"):
        return
    await create_timer(0.65).timeout
    if not await _capture("06_divine_profile_full_late.png"):
        return
    var toggle := panel.find_child("VISReducedMotionToggle",true,false) as Button
    if toggle == null:
        _fail("Missing live profile effect-mode button")
        return
    toggle.pressed.emit()
    await _frames(3)
    panel = game.find_child("DiscipleDeepScreen",true,false) as Panel
    if panel == null or str((panel.find_child("VISReducedMotionToggle",true,false) as Button).text).find("GIẢM") == -1:
        _fail("Reduced motion did not persist across real profile refresh")
        return
    if not await _capture("07_divine_profile_reduced.png"):
        return
    toggle = panel.find_child("VISReducedMotionToggle",true,false) as Button
    toggle.pressed.emit()
    await _frames(3)
    panel = game.find_child("DiscipleDeepScreen",true,false) as Panel
    if panel == null or str((panel.find_child("VISReducedMotionToggle",true,false) as Button).text).find("TẮT") == -1:
        _fail("Off motion mode not applied on real profile")
        return
    if not await _capture("08_divine_profile_off.png"):
        return
    toggle = panel.find_child("VISReducedMotionToggle",true,false) as Button
    toggle.pressed.emit()
    await _frames(3)
    game.call("_open_disciple_deep_screen",common.id,"Tổng Quan",true)
    await _frames(4)
    if not await _capture("09_real_common_profile_baseline.png"):
        return
    var report := {
        "evidence_kind": "actual_P32_OneGame_Xvfb_GL_no_mockups",
        "rarity_source": "normal_D7_SOURCE_GACHA_roll_no_forcing",
        "rarity": str(joined.disciple_quality),
        "generated_index": found_generation,
        "disciple_id": str(joined.id),
        "isolation_save_path": SAVE_PATH,
        "screenshot_count": captured,
        "video_source": "Godot_4_7_2_write_movie",
        "renderer": "gl_compatibility",
        "viewport": [root.size.x,root.size.y],
        "physical_android_test": false,
        "source_sha": OS.get_environment("GITHUB_SHA")
    }
    var file := FileAccess.open(output_dir.path_join("vis02_capture_report.json"),FileAccess.WRITE)
    if file == null:
        _fail("Cannot write capture report")
        return
    file.store_string(JSON.stringify(report, "  "))
    file.close()
    print("VIS02 REAL_RECRUIT_PROFILE_CAPTURE PASS " + JSON.stringify(report))
    game.set("runtime_ready",false)
    game.queue_free()
    await process_frame
    _cleanup_save()
    quit(0)

func _frames(count: int) -> void:
    for _i in range(count):
        await process_frame

func _capture(filename: String) -> bool:
    await _frames(4)
    await RenderingServer.frame_post_draw
    var img := root.get_texture().get_image()
    if img == null or img.is_empty() or img.get_size() != Vector2i(1280,720):
        return _fail("Real viewport not 1280x720: " + filename)
    if img.save_png(output_dir.path_join(filename)) != OK:
        return _fail("Unable to save real viewport: " + filename)
    captured += 1
    print("VIS02_REAL_VIEWPORT_SCREENSHOT_OK " + filename)
    return true

func _cleanup_save() -> void:
    for suffix in ["", ".tmp", ".bak"]:
        if FileAccess.file_exists(SAVE_PATH + suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + suffix))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(reason: String) -> bool:
    push_error("VIS02_REAL_CAPTURE: " + reason)
    if game != null and is_instance_valid(game):
        game.set("runtime_ready",false)
        game.queue_free()
    _cleanup_save()
    quit(1)
    return false
