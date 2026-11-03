extends SceneTree

# P0 live P3.2 UI integration: real New Game, two authentic recruited V2
# disciples, selectable free-hunt admission, late join/withdraw, AUTO/HOLD,
# hide/reopen world and SaveService. Never accesses the player's live save.
const QA_PREFIX := "user://qa_pve_p0_live_ui_"
var qa_path := ""
var ui: Control
var checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    checks += 1
    if ok:
        return true
    push_error("PVE_P0_UI_PLAYER_ENTRY_FAIL "+reason)
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    if ui != null:
        for key in ["runtime_poll_timer","autosave_timer"]:
            var clock := ui.get(key) as Timer
            if clock != null:
                clock.stop()
        ui.set("runtime_ready",false)
        ui.queue_free()
        ui = null
    if qa_path.begins_with(QA_PREFIX):
        for suffix in ["",".tmp",".bak"]:
            var f := qa_path+suffix
            if FileAccess.file_exists(f):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(f))

func _run() -> void:
    root.size = Vector2i(1280,720)
    qa_path = QA_PREFIX+str(OS.get_process_id())+".json"
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",qa_path)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _check(packed != null,"main live scene missing"):
        return
    ui = packed.instantiate() as Control
    if not _check(ui != null,"main live scene failed to instantiate"):
        return
    root.add_child(ui)
    await process_frame
    var state: SimulationState = ui.get("state")
    var runtime: LiveGameRuntimeV2 = ui.get("runtime_session")
    if not _check(bool(ui.get("runtime_ready")) and state != null
            and runtime != null and runtime.owner.state == state,
            "P3.2 UI not bound to canonical New Game runtime"):
        return
    if not _check(state.disciples.size() == 6,
            "New Game baseline is not 6 authentic founder disciples"):
        return
    var candidates: Array = state.recruitment_candidates.keys()
    candidates.sort()
    if not _check(candidates.size() >= 2,"two genuine V2 recruitment candidates unavailable"):
        return
    var first_id := StringName(str(candidates[0]))
    var recruited := RecruitmentSystem.new().accept_candidate(state,first_id)
    if not _check(bool(recruited.get("ok",false))
            and DiscipleRealmProgressV2.progression_ready(state.disciples[first_id]),
            "first canonical V2 recruitment failed"):
        return
    ui.call("_open_pve_party_picker")
    var shade := ui.get_node_or_null("PvePartyPickerShade") as Control
    var start := ui.get_node_or_null(
        "PvePartyPickerShade/PvePartyPicker/PvePartyPickerStart") as Button
    var boss := ui.get_node_or_null(
        "PvePartyPickerShade/PvePartyPicker/PvePartyPickerBossStart") as Button
    if not _check(shade != null and shade.visible and start != null
            and boss != null and ui.get("pve_party_selected_ids").is_empty(),
            "P0 picker must not force six players or auto-select all hunters"):
        return
    var one: Array[StringName] = [first_id]
    ui.set("pve_party_selected_ids",one)
    ui.call("_populate_pve_party_picker")
    if not _check(not start.disabled and boss.disabled
            and ui.get("pve_party_selected_ids").size() == 1,
            "one authentic V2 disciple cannot start solo while Boss stays six-only"):
        return
    await ui.call("_start_multicamp_hunt_for_picked_party")
    var encounter := HuntingPveRunV2.active_multicamp_id(state)
    var session := runtime.owner.get_active_multicamp_session(encounter)
    if not _check(not encounter.is_empty() and session != null
            and PveDistributedWorldV1.enabled(session.camp_population)
            and session.battle._count_alive("disciple") == 1
            and session.battle.active,
            "player-facing P0 button failed to deploy one real recruit"):
        return
    var view := ui.get("b3_pve_world_view") as PveSectWorldViewV1
    if not _check(view != null and view.hunt_policy_ordered.has_connections()
            and view.move_ordered.has_connections(),
            "P3.2 map is missing P0 authoritative AUTO/HOLD/movement callbacks"):
        return
    var selected: Array[String] = [str(first_id)]
    view.selected_actor_ids = selected
    await ui.call("_on_p0_hunt_policy_ordered",selected,"hold")
    if not _check(str(session.battle.actors[str(first_id)].get("hunt_policy","")) == "hold",
            "selected human HOLD command did not reach Combat V2 authority"):
        return
    await ui.call("_close_p0_hunt_map")
    if not _check(not ui.get("b3_hunt_panel").get_parent().visible
            and session.battle.active
            and session.battle.actors.has(str(first_id))
            and HuntingPveRunV2.active_multicamp_id(state) == encounter,
            "closing the map must not withdraw or end the hunt"):
        return
    ui.call("_open_pve_party_picker")
    if not _check(ui.get("b3_hunt_panel").get_parent().visible,
            "player quick-entry did not reopen the saved active world"):
        return
    var candidates_again: Array = state.recruitment_candidates.keys()
    candidates_again.sort()
    if not _check(not candidates_again.is_empty(),
            "second authentic V2 candidate is missing"):
        return
    var second_id := StringName(str(candidates_again[0]))
    var recruited_second := RecruitmentSystem.new().accept_candidate(state,second_id)
    if not _check(bool(recruited_second.get("ok",false))
            and DiscipleRealmProgressV2.progression_ready(state.disciples[second_id]),
            "second authentic recruit failed at legitimate Residence capacity"):
        return
    ui.call("_open_p0_join_picker")
    var next: Array[StringName] = [second_id]
    ui.set("pve_party_selected_ids",next)
    ui.call("_populate_pve_party_picker")
    if not _check(bool(ui.get("pve_party_picker_join_mode"))
            and not start.disabled and boss.disabled,
            "live-world add-one picker blocked or Boss incorrectly enabled"):
        return
    await ui.call("_start_multicamp_hunt_for_picked_party")
    if not _check(session.battle._count_alive("disciple") == 2
            and session.battle.actors.has(str(second_id))
            and state.disciples[second_id].active_pve_encounter_id == encounter,
            "second recruit did not join active P0 world"):
        return
    view.selected_actor_ids = [str(second_id)]
    await ui.call("_withdraw_selected_p0_hunter")
    if not _check(session.battle.active
            and session.battle._count_alive("disciple") == 1
            and session.battle.actors.has(str(first_id))
            and not session.battle.actors.has(str(second_id))
            and state.disciples[second_id].active_pve_encounter_id.is_empty(),
            "return-one button ended the world or left a ghost participant"):
        return
    if not _check(FileAccess.file_exists(qa_path),
            "SaveService did not produce isolated persisted New Game"):
        return
    print("PVE_P0_UI_PLAYER_ENTRY_PASS checks=%d" % checks)
    _cleanup()
    quit(0)
