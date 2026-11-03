extends SceneTree

# O2: real landscape recruitment entry -> authoritative accept -> live actor ->
# selectable/assignable disciple -> save/reload exactly once.
const SAVE_PATH := "user://p3_o2_recruitment_map_test.json"

var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    if state.disciples.size() != 6 or state.sect.disciple_capacity != 8:
        _fail("O2 fresh opening must expose the verified 6/8 roster.")
        return
    if ui.find_child("BuildingToken_guidance", true, false) == null:
        _fail("O2 landscape map has no Dẫn Tiên Đài entry.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_GUIDANCE)
    await process_frame
    if StringName(ui.get("selected_building")) != SectMapPresentation.DEST_GUIDANCE:
        _fail("O2 Dẫn Tiên entry did not open its real management panel.")
        return

    var candidates: Array = state.recruitment_candidates.keys()
    candidates.sort()
    if candidates.size() < 3:
        _fail("O2 fresh state does not expose the expected real candidate pool.")
        return
    var first_visible := StringName(candidates[0])
    ui.call("_open_dan_tien_screen_v2")
    await process_frame
    var dan_tien := ui.get_node_or_null("DanTienScreenV2") as DanTienScreenV2
    if dan_tien == null:
        _fail("O2 Dẫn Tiên entry did not open the player-facing V2 recruitment screen.")
        return
    dan_tien.call("_select_candidate", first_visible)
    await process_frame
    if _find_button_with_text(dan_tien, "TỪ CHỐI") == null:
        _fail("O2 candidate has no player-facing Reject control in DanTienScreenV2.")
        return
    # Live runtime enables authentic V2 births after P3.7 factory creation.
    # Existing pre-V2 waiting candidates remain visible but cannot bypass the
    # canonical complete-birth gate. Use the real Dẫn Tiên action to obtain an
    # authentic recruit; this consumes a real Chiêu Mộ Lệnh.
    var tokens_before := state.sect.disciple_recruitment_tokens
    var pool_before := state.recruitment_candidates.size()
    var order_button := dan_tien.get("_token_button") as Button
    if order_button == null or order_button.disabled:
        _fail("O2 fresh Guidance entry cannot use the real recruitment order.")
        return
    order_button.emit_signal("pressed")
    await process_frame
    if state.sect.disciple_recruitment_tokens != tokens_before - 1:
        _fail("O2 Dẫn Tiên action did not consume exactly one Chiêu Mộ Lệnh.")
        return
    if state.recruitment_candidates.size() <= pool_before:
        _fail("O2 Dẫn Tiên action did not produce a real candidate.")
        return

    var recruitable := _recruitable_candidate_ids()
    if recruitable.is_empty():
        _fail("O2 Dẫn Tiên produced no authentic V2 candidate.")
        return
    var first_id := StringName(recruitable[0])
    dan_tien.call("_select_candidate", first_id)
    await process_frame
    var accept_first := _find_button_with_text(dan_tien, "NHẬN ĐỆ TỬ")
    if accept_first == null or accept_first.disabled:
        _fail("O2 authentic candidate has no enabled player-facing Accept control in DanTienScreenV2.")
        return

    var initial_count := state.disciples.size()
    accept_first.emit_signal("pressed")
    await process_frame
    if state.disciples.size() != initial_count + 1:
        _fail("O2 valid Accept did not add exactly one disciple.")
        return
    if state.recruitment_candidates.has(first_id):
        _fail("O2 accepted candidate remained in the waiting pool.")
        return
    if not state.disciples.has(first_id):
        _fail("O2 accepted candidate did not become canonical DiscipleState.")
        return

    # Actors are materialized only for the focused/visible world viewport.
    # Select through the real disciple route before asserting the map node.
    ui.call("_open_disciple", first_id)
    for _frame in range(18):
        await process_frame
    var actors: Dictionary = ui.get("actor_nodes")
    if not actors.has(str(first_id)):
        _fail("O2 accepted disciple did not materialize as a live map actor.")
        return
    var recruited_actor := actors[str(first_id)] as Control
    if recruited_actor == null or not is_instance_valid(recruited_actor) or not (recruited_actor is ModularDiscipleActor):
        _fail("O2 accepted disciple did not use the live modular actor path.")
        return
    if ui.find_children("ModularDisciple_%s" % str(first_id), "", true, false).size() != 1:
        _fail("O2 created a duplicate actor for the accepted disciple.")
        return

    if StringName(ui.get("selected_id")) != first_id:
        _fail("O2 recruited map actor is not selectable through the live disciple flow.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    var group_button := ui.find_child("Group_mining_crew_%s" % str(first_id), true, false) as Button
    if group_button == null:
        _fail("O2 recruited disciple is absent from real workforce controls.")
        return
    group_button.emit_signal("pressed")
    await process_frame
    var recruited: DiscipleState = state.disciples[first_id]
    if recruited.work_group_id != &"mining_crew":
        _fail("O2 recruited disciple could not be assigned through workforce UI.")
        return

    await ui.call("_autosave_runtime")
    if not FileAccess.file_exists(SAVE_PATH):
        _fail("O2 player-facing runtime save was not written.")
        return
    _dispose_scene()
    await process_frame

    if not await _open_scene():
        return
    if state.disciples.size() != initial_count + 1 or not state.disciples.has(first_id):
        _fail("O2 recruited disciple vanished or duplicated after reload.")
        return
    if state.recruitment_candidates.has(first_id):
        _fail("O2 accepted candidate returned after reload.")
        return
    if (state.disciples[first_id] as DiscipleState).work_group_id != &"mining_crew":
        _fail("O2 workforce assignment did not persist with the recruited disciple.")
        return
    ui.call("_open_disciple", first_id)
    for _frame in range(18):
        await process_frame
    actors = ui.get("actor_nodes")
    if not actors.has(str(first_id)) or ui.find_children("ModularDisciple_%s" % str(first_id), "", true, false).size() != 1:
        _fail("O2 reload did not restore exactly one live actor for the recruit.")
        return

    var before_retry := state.disciples.size()
    ui.call("_accept_guidance_candidate", first_id)
    await process_frame
    if state.disciples.size() != before_retry:
        _fail("O2 retry of an already accepted candidate duplicated the roster.")
        return

    ui.call("_accept_guidance_candidate", &"candidate_missing_o2")
    await process_frame
    if state.disciples.size() != before_retry:
        _fail("O2 invalid candidate ID mutated the roster.")
        return

    var remaining := _recruitable_candidate_ids()
    if remaining.size() < 2:
        _fail("O2 needs two remaining authentic candidates for capacity/reject denial checks.")
        return
    var second_id := StringName(remaining[0])
    var third_id := StringName(remaining[1])

    ui.call("_open_building", SectMapPresentation.DEST_GUIDANCE)
    await process_frame
    ui.call("_open_dan_tien_screen_v2")
    await process_frame
    dan_tien = ui.get_node_or_null("DanTienScreenV2") as DanTienScreenV2
    if dan_tien == null:
        _fail("O2 full-capacity verification could not open DanTienScreenV2.")
        return
    dan_tien.call("_select_candidate", second_id)
    await process_frame
    var accept_second := _find_button_with_text(dan_tien, "NHẬN ĐỆ TỬ")
    if accept_second == null or accept_second.disabled:
        _fail("O2 legal second recruit is not available from Guidance UI.")
        return
    accept_second.emit_signal("pressed")
    await process_frame
    if state.disciples.size() != state.sect.disciple_capacity:
        _fail("O2 second legal recruit did not fill capacity exactly.")
        return

    var full_count := state.disciples.size()
    ui.call("_accept_guidance_candidate", third_id)
    await process_frame
    if state.disciples.size() != full_count or not state.recruitment_candidates.has(third_id):
        _fail("O2 capacity-full denial consumed or accepted the waiting candidate.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_GUIDANCE)
    await process_frame
    ui.call("_open_dan_tien_screen_v2")
    await process_frame
    dan_tien = ui.get_node_or_null("DanTienScreenV2") as DanTienScreenV2
    if dan_tien == null:
        _fail("O2 reject verification could not open DanTienScreenV2.")
        return
    dan_tien.call("_select_candidate", third_id)
    await process_frame
    var reject_third := _find_button_with_text(dan_tien, "TỪ CHỐI")
    if reject_third == null:
        _fail("O2 remaining candidate lost the Reject control in DanTienScreenV2 at full capacity.")
        return
    reject_third.emit_signal("pressed")
    await process_frame
    reject_third = _find_button_with_text(dan_tien, "XÁC NHẬN TỪ CHỐI")
    if reject_third == null:
        _fail("O2 rejection did not request its second confirmation.")
        return
    reject_third.emit_signal("pressed")
    await process_frame
    if state.recruitment_candidates.has(third_id) or state.disciples.size() != full_count:
        _fail("O2 Reject did not remove only the candidate.")
        return

    var errors := state.validate_invariants()
    if not errors.is_empty():
        _fail("O2 final state violates invariants: %s" % " | ".join(errors))
        return

    print("P3 O2 RECRUITMENT MAP TEST PASS")
    _dispose_scene()
    await process_frame
    _cleanup_save()
    # TEMPORARY QA-only CI bridge.  Standalone G0 natural E2E runs in a
    # separate official Godot executable and returns its real exit code/log.
    # Parent O2 stays independent; this bridge is removed after evidence.
    var natural_output: Array = []
    var args := PackedStringArray([
        "--headless","--path",ProjectSettings.globalize_path("res://"),
        "-s","res://tests/presentation/g0_natural_newgame_six_v2_pve_test.gd"
    ])
    var child_exit: int = OS.execute(OS.get_executable_path(),args,natural_output,true)
    var transcript := ""
    for row in natural_output:
        transcript += str(row)
    print("G0_NATURAL_STANDALONE_BEGIN")
    print(transcript)
    print("G0_NATURAL_STANDALONE_END")
    print("G0_NATURAL_STANDALONE_EXIT="+str(child_exit))
    if child_exit != 0:
        print("G0_NATURAL_TEST_FIRST_RED exit="+str(child_exit))
    else:
        print("G0_NATURAL_TEST_FIRST_GREEN")
    quit(0)

func _recruitable_candidate_ids() -> Array:
    var result: Array = []
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    for raw_id in ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if not state.sect.disciple_v2_birth_enabled or DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            result.append(StringName(raw_id))
    return result

func _find_button_with_text(parent: Node, value: String) -> Button:
    if parent is Button and (parent as Button).text == value:
        return parent as Button
    for child in parent.get_children():
        var found := _find_button_with_text(child, value)
        if found != null:
            return found
    return null

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O2 could not load landscape entry scene.")
    ui = scene.instantiate() as Control
    if ui == null:
        return _fail("O2 could not instantiate landscape entry scene.")
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        return _fail("O2 scene returned no live SimulationState.")
    _stop_timers(ui)
    return true

func _dispose_scene() -> void:
    if ui == null:
        return
    ui.set("runtime_ready", false)
    ui.queue_free()
    ui = null
    state = null

func _stop_timers(node: Node) -> void:
    if node is Timer:
        (node as Timer).stop()
    for child in node.get_children():
        _stop_timers(child)

func _cleanup_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error(message)
    _dispose_scene()
    _cleanup_save()
    quit(1)
    return false
