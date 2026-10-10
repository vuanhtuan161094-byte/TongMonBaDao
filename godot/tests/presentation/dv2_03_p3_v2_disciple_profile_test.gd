extends SceneTree

const TEST_SAVE_PATH := "user://dv2_03_p3_v2_disciple_profile_test.json"

var ui: Control
var state: SimulationState
var disciple: DiscipleState

func _init() -> void:
    call_deferred("_run")

func _cleanup() -> void:
    if FileAccess.file_exists(TEST_SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> void:
    push_error(message)
    if ui != null:
        ui.queue_free()
    _cleanup()
    quit(1)

func _recruit_v2() -> DiscipleState:
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,777
    )
    if candidate == null or candidate.v2_birth_profile.is_empty():
        return null
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    return state.disciples.get(candidate.id)

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",TEST_SAVE_PATH)

    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("Could not load P3.2 main scene.")
        return
    ui = packed.instantiate() as Control
    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null or not bool(ui.get("runtime_ready")):
        _fail("P3.2 did not expose the live runtime state.")
        return
    disciple = _recruit_v2()
    if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        _fail("P3.2 test could not recruit an authentic V2 disciple.")
        return

    # Deliberately poison legacy fields. Authentic V2 UI must ignore them.
    disciple.combat_power = 987654.0
    disciple.cultivation_progress = 876543.0
    disciple.cultivation_stage_index = 8

    var attributes := str(ui.call("_disciple_tab_text","Thuộc tính",disciple))
    if not attributes.contains("Tu Vi: Phàm Nhân tầng 1"):
        _fail("V2 attribute tab does not show canonical Tu Vi coordinate.")
        return
    if not attributes.contains("Luyện Thể: Phàm Thân tầng 1"):
        _fail("V2 attribute tab does not show canonical Body coordinate.")
        return
    if not attributes.contains("Thể lực viễn chinh"):
        _fail("V2 attribute tab still labels expedition stamina as ordinary work stamina.")
        return
    if attributes.contains("Chiến lực hiệu dụng") or attributes.contains("987654") or attributes.contains("876543"):
        _fail("V2 attribute tab leaked legacy P2 progression/combat authority.")
        return
    if not attributes.contains("Linh Căn:") or not attributes.contains("Đặc Chất:"):
        _fail("V2 attribute tab does not consume innate snapshot.")
        return

    var snapshot := DisciplePresentationSnapshotV2.build(state,disciple)
    var combat: Dictionary = snapshot["combat"]
    if not bool(combat.get("ready",false)):
        _fail("V2 UI snapshot has no canonical combat stats.")
        return
    var stats: Dictionary = combat["stats"]
    if not attributes.contains("Công %.1f" % float(stats["attack"])):
        _fail("V2 attribute tab attack is not sourced from CombatStatsV2.")
        return
    if not attributes.contains("Thủ %.1f" % float(stats["defense"])):
        _fail("V2 attribute tab defense is not sourced from CombatStatsV2.")
        return

    # Hidden identities must remain hidden in every V2 surface.
    var layers: Dictionary = disciple.v2_birth_profile["layers"]
    layers["bloodline"] = {
        "initialized":true,"bloodline_id":"chan_long_huyet",
        "birth_purity":77,"current_purity":84,"revealed":false,
        "awakened":false,"active":false
    }
    layers["physique"] = {
        "initialized":true,"physique_id":"kim_cuong_ba_the",
        "revealed":false,"active":false,"origin":"birth"
    }
    layers["destiny"] = {
        "initialized":true,"destiny_id":"pha_quan",
        "revealed":false,"origin":"birth","active":false
    }
    disciple.v2_birth_profile["layers"] = layers
    if not DiscipleBirthProfileV2.valid_complete_birth(disciple.v2_birth_profile):
        _fail("Hidden V2 UI fixture became invalid.")
        return

    var hidden_bloodline := str(ui.call("_disciple_tab_text","Huyết Mạch",disciple))
    var hidden_physique := str(ui.call("_disciple_tab_text","Thể Chất",disciple))
    if not hidden_bloodline.contains("Chưa xác định"):
        _fail("Hidden V2 Bloodline is not masked in UI.")
        return
    if hidden_bloodline.contains("Chân Long") or hidden_bloodline.contains("84") or hidden_bloodline.contains("77"):
        _fail("Hidden V2 Bloodline identity/purity leaked in UI.")
        return
    if not hidden_physique.contains("Chưa xác định") or hidden_physique.contains("Kim Cương"):
        _fail("Hidden V2 Physique leaked in UI.")
        return
    attributes = str(ui.call("_disciple_tab_text","Thuộc tính",disciple))
    if attributes.contains("Phá Quân") or attributes.contains("Chân Long") or attributes.contains("Kim Cương"):
        _fail("Hidden V2 innate identity leaked through attribute tab.")
        return

    # Reveal only the Bloodline and verify read-only display. P2 action buttons
    # must not be offered and direct invocation must not mutate the V2 birth row.
    disciple.v2_birth_profile["layers"]["bloodline"]["revealed"] = true
    var revealed_text := str(ui.call("_disciple_tab_text","Huyết Mạch",disciple))
    if not revealed_text.contains("Chân Long Huyết") or not revealed_text.contains("84%"):
        _fail("Revealed V2 Bloodline is not read from the birth profile snapshot.")
        return
    if not revealed_text.contains("Hiệu ứng đặc thù: Chưa khả dụng"):
        _fail("V2 Bloodline UI pretends its effect consumer is active.")
        return

    ui.set("selected_id",disciple.id)
    ui.call("_open_disciple_deep_screen",disciple.id,"Huyết Mạch")
    await process_frame
    var deep := (ui.get("popup_layer") as Control).get_node_or_null("DiscipleDeepScreen") as Panel
    if deep == null:
        _fail("V2 deep profile did not open.")
        return
    if _has_button_text(deep,"Thức tỉnh") or _has_button_text(deep,"Luyện huyết"):
        _fail("Authentic V2 Bloodline still exposes P2 mutation buttons.")
        return

    var birth_before := disciple.v2_birth_profile.duplicate(true)
    var legacy_map_before := state.sect.bloodline_profiles.duplicate(true)
    ui.call("_disciple_tab_action","bloodline_awaken")
    await process_frame
    if disciple.v2_birth_profile != birth_before:
        _fail("Blocked P2 Bloodline action mutated V2 birth identity.")
        return
    if state.sect.bloodline_profiles != legacy_map_before:
        _fail("Blocked P2 Bloodline action created/changed legacy parallel profile.")
        return

    # Summary/deep status must show both progression tracks.
    var summary_snapshot := DisciplePresentationSnapshotV2.build(state,disciple)
    var summary := str(ui.call("_v2_disciple_summary_text",summary_snapshot))
    var status := str(ui.call("_deep_status_text",disciple))
    if not summary.contains("Tu Vi: Phàm Nhân tầng 1") or not summary.contains("Luyện Thể: Phàm Thân tầng 1"):
        _fail("V2 summary does not show both canonical tracks.")
        return
    if not status.contains("Phàm Nhân tầng 1") or not status.contains("Phàm Thân tầng 1"):
        _fail("V2 deep status does not show both canonical tracks.")
        return

    # Authentic identity + malformed progression must display fail-closed text,
    # not legacy P2 cultivation values.
    var good_progress := disciple.v2_realm_progress.duplicate(true)
    disciple.v2_realm_progress["body"]["realm"] = 99
    var broken_attributes := str(ui.call("_disciple_tab_text","Thuộc tính",disciple))
    if not broken_attributes.contains("không dùng cảnh giới cũ để thay thế".to_lower()) and not broken_attributes.to_lower().contains("không dùng cảnh giới cũ để thay thế"):
        _fail("Malformed V2 progression UI did not fail closed.")
        return
    if broken_attributes.contains("987654") or broken_attributes.contains("876543"):
        _fail("Malformed V2 progression UI fell back to legacy values.")
        return
    disciple.v2_realm_progress = good_progress

    ui.queue_free()
    await process_frame
    ui = null
    _cleanup()
    print("DV2-03 P3 AUTHENTIC V2 DISCIPLE PROFILE: PASS")
    quit(0)

func _has_button_text(node: Node, text_value: String) -> bool:
    if node is Button and (node as Button).text == text_value:
        return true
    for child in node.get_children():
        if _has_button_text(child,text_value):
            return true
    return false
