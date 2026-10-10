extends SceneTree

const TEST_SAVE_PATH := "user://p3_2_disciple_ui_legacy_compat_test.json"

var ui: Control
var state: SimulationState
var disciple: DiscipleState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path", TEST_SAVE_PATH)

    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.2 disciple UI scene could not be loaded.")
        return

    ui = packed_scene.instantiate() as Control
    if ui == null:
        _fail("P3.2 disciple UI scene could not be instantiated.")
        return
    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null:
        _fail("P3.2 disciple UI did not expose the real simulation state.")
        return

    disciple = _first_legacy_disciple()
    if disciple == null:
        _fail("P3.2 disciple UI has no legacy disciple for compatibility testing.")
        return

    if not _verify_real_attribute_text():
        return
    if not _verify_hidden_bloodline_does_not_leak():
        return
    if not _verify_physique_tab_uses_real_profile():
        return
    if not _verify_real_physique_action_path():
        return
    if not _verify_real_bloodline_action_path():
        return
    if not _verify_real_other_tabs():
        return
    if not _verify_tab_builds_popup():
        return

    print("P3.2 DISCIPLE UI LEGACY COMPATIBILITY TEST PASS")
    ui.queue_free()
    await process_frame
    ui = null
    _cleanup()
    quit(0)

func _first_legacy_disciple() -> DiscipleState:
    # Prefer an already recruited generated legacy disciple because P2 identity
    # systems require profile_seed > 0. P0 founders intentionally have seed 0.
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var existing: DiscipleState = state.disciples[raw_id]
        if existing.profile_seed > 0 and not DiscipleRealmProgressV2.owns_v2_progression(existing):
            return existing

    # P37Factory creates its initial candidates before LiveGameRuntimeV2 turns
    # on future V2 birth. Accept one of those preserved legacy candidates so
    # this compatibility test exercises the same P2 generated-person contract
    # the old presentation demo used, without reintroducing demo roster logic.
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if candidate == null or candidate.profile_seed <= 0:
            continue
        if not candidate.v2_birth_profile.is_empty():
            continue
        state.sect.disciple_capacity = maxi(
            state.sect.disciple_capacity, state.disciples.size() + 1
        )
        var accepted := RecruitmentSystem.new().accept_candidate(state, candidate.id)
        if not bool(accepted.get("ok", false)):
            continue
        var recruited: DiscipleState = state.disciples.get(candidate.id)
        if recruited != null and not DiscipleRealmProgressV2.owns_v2_progression(recruited):
            return recruited

    # Live bootstrap is allowed to have no preserved candidate. Build a
    # compatibility-only generated person in a separate P37 state where V2
    # birth remains default-off, then attach that disciple to this test state.
    # This exercises the real open-point generator without changing live runtime
    # recruitment behavior or recreating presentation demo recruits.
    var legacy_source := P37Factory.create_state(31012026 + 77)
    var generated := DiscipleGeneratorOpenPoints.new().generate_candidate(
        legacy_source, DiscipleGeneratorV2.SOURCE_ORDINARY, 707
    )
    if generated == null or generated.profile_seed <= 0 or not generated.v2_birth_profile.is_empty():
        return null
    var fixture := generated.to_disciple()
    fixture.region_id = &"sect"
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity, state.disciples.size() + 1
    )
    state.disciples[fixture.id] = fixture
    return fixture

func _verify_real_attribute_text() -> bool:
    var text := str(ui.call("_disciple_tab_text", "Thuộc tính", disciple))
    var cultivation := CultivationSystem.new()
    if not text.contains(cultivation.stage_name(disciple)):
        return _fail("P3.2 Thuộc tính tab does not read the disciple's real cultivation stage.")
    if not text.contains("Chiến lực hiệu dụng") or not text.contains("Tư Chất"):
        return _fail("P3.2 Thuộc tính tab is missing real derived/foundation information.")
    return true

func _verify_hidden_bloodline_does_not_leak() -> bool:
    state.sect.bloodline_profiles[str(disciple.id)] = {
        "initialized":true,
        "bloodline_id":"true_dragon",
        "purity":0.42,
        "revealed":false,
        "awakened":false,
        "refinement_count":0
    }
    var text := str(ui.call("_disciple_tab_text", "Huyết Mạch", disciple))
    if not text.contains("Chưa xác định"):
        return _fail("P3.2 hidden bloodline is not presented as unknown.")
    if text.contains("Chân Long") or text.contains("42.0"):
        return _fail("P3.2 hidden bloodline leaked latent identity or purity.")
    return true

func _verify_physique_tab_uses_real_profile() -> bool:
    state.sect.physique_profiles[str(disciple.id)] = {
        "initialized":true,
        "physique_id":"sword_bone",
        "physique_grade":"mystic_body",
        "initial_physique_id":"sword_bone",
        "temper_level":2,
        "transformed":false,
        "latent_transformation":""
    }
    var expected := PhysiqueSystem.new().display_physique(state, disciple.id)
    var text := str(ui.call("_disciple_tab_text", "Thể Chất", disciple))
    if not text.contains(expected):
        return _fail("P3.2 Thể Chất tab does not read the stored physique type/grade.")
    if not text.contains("Tôi thể: 2/5") or not text.contains("Kiếm đạo XP"):
        return _fail("P3.2 Thể Chất tab is missing real temper/path effects.")
    return true

func _verify_real_physique_action_path() -> bool:
    state.sect.physique_profiles[str(disciple.id)] = {
        "initialized":true,
        "physique_id":"ordinary_body",
        "physique_grade":"mortal_body",
        "initial_physique_id":"ordinary_body",
        "temper_level":0,
        "transformed":false,
        "latent_transformation":"sword_bone"
    }
    if not _ensure_yao_dan(5):
        return _fail("P3.2 legacy fixture could not provision canonical Yêu Đan.")
    var before_material := _yao_dan_quantity()
    ui.set("selected_id", disciple.id)
    ui.call("_disciple_tab_action", "physique_temper")
    var profile: Dictionary = state.sect.physique_profiles[str(disciple.id)]
    if int(profile.get("temper_level", 0)) != 1:
        return _fail("P3.2 Tôi thể button path did not mutate the real PhysiqueSystem profile.")
    if _yao_dan_quantity() != before_material - 1:
        return _fail("P3.2 Tôi thể button path did not consume the real Yêu Đan cost.")
    return true

func _verify_real_bloodline_action_path() -> bool:
    state.sect.bloodline_profiles[str(disciple.id)] = {
        "initialized":true,
        "bloodline_id":"true_dragon",
        "purity":0.25,
        "revealed":true,
        "awakened":false,
        "refinement_count":0
    }
    if not _ensure_yao_dan(5):
        return _fail("P3.2 legacy fixture could not provision canonical Yêu Đan.")
    var before_material := _yao_dan_quantity()
    ui.set("selected_id", disciple.id)
    ui.call("_disciple_tab_action", "bloodline_awaken")
    var profile: Dictionary = state.sect.bloodline_profiles[str(disciple.id)]
    if not bool(profile.get("awakened", false)):
        return _fail("P3.2 Thức tỉnh button path did not invoke the real BloodlineSystem.")
    if _yao_dan_quantity() != before_material - 1:
        return _fail("P3.2 Thức tỉnh button path did not consume the real Yêu Đan cost.")
    var text := str(ui.call("_disciple_tab_text", "Huyết Mạch", disciple))
    if not text.contains("Chân Long Huyết") or not text.contains("Đã thức tỉnh"):
        return _fail("P3.2 Huyết Mạch tab did not refresh from the real awakened state.")
    return true

func _yao_dan_quantity() -> int:
    if state.sect.p3_7_resources_enabled:
        return WarehouseSystem.new().quantity(state, &"yeu_dan")
    return int(state.sect.technique_materials.get("yeu_dan", 0))

func _ensure_yao_dan(minimum: int) -> bool:
    if state.sect.p3_7_resources_enabled:
        var warehouse := WarehouseSystem.new()
        var current := warehouse.quantity(state, &"yeu_dan")
        if current < minimum:
            if not warehouse.add(state, &"yeu_dan", minimum - current):
                return false
        return warehouse.quantity(state, &"yeu_dan") >= minimum
    state.sect.technique_materials["yeu_dan"] = maxi(
        int(state.sect.technique_materials.get("yeu_dan", 0)), minimum
    )
    return true

func _verify_real_other_tabs() -> bool:
    var technique_text := str(ui.call("_disciple_tab_text", "Công pháp", disciple))
    var equipment_text := str(ui.call("_disciple_tab_text", "Trang bị", disciple))
    var relation_text := str(ui.call("_disciple_tab_text", "Quan hệ", disciple))
    if not technique_text.contains("Công pháp đã học"):
        return _fail("P3.2 Công pháp tab is not connected to learned technique state.")
    if not equipment_text.contains("Trang bị hiện tại"):
        return _fail("P3.2 Trang bị tab is not connected to equipment state.")
    if not relation_text.contains("Đồng hành ưu tiên"):
        return _fail("P3.2 Quan hệ tab is not connected to relationship state.")
    return true

func _verify_tab_builds_popup() -> bool:
    ui.set("selected_id", disciple.id)
    ui.call("_open_disciple_tab", "Thuộc tính")
    var popup_layer: Control = ui.get("popup_layer") as Control
    if popup_layer == null or popup_layer.get_child_count() < 2:
        return _fail("P3.2 disciple tab did not build its dim + parchment popup hierarchy.")
    return true

func _cleanup() -> void:
    if FileAccess.file_exists(TEST_SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error(message)
    if ui != null:
        ui.queue_free()
    _cleanup()
    quit(1)
    return false
