extends SceneTree
# Native New Game PvE capture. Real recruitment, actual party picker and
# authoritative runtime clock. No spawned dummy actors, forced damage or gates.
const PREFIX := "user://qa_onegame_pve_movie_"
var ui: Control
var path := ""
var out := ""

func _init() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("ONEGAME_PVE_CAPTURE_FAIL "+reason)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    if ui != null:
        for key in ["runtime_poll_timer","autosave_timer"]:
            var timer := ui.get(key) as Timer
            if timer != null:
                timer.stop()
        ui.set("runtime_ready",false)
        ui.queue_free()
    if path.begins_with(PREFIX):
        for suffix in ["",".tmp",".bak"]:
            if FileAccess.file_exists(path+suffix):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))

func _capture(name: String) -> bool:
    await process_frame
    await RenderingServer.frame_post_draw
    var image := root.get_texture().get_image()
    return image != null and image.get_size() == Vector2i(1280,720) and image.save_png(out.path_join(name)) == OK

func _run() -> void:
    if DisplayServer.get_name() == "headless" or OS.get_cmdline_user_args().is_empty():
        _fail("Real display and evidence directory required")
        return
    out = str(OS.get_cmdline_user_args()[0])
    DirAccess.make_dir_recursive_absolute(out)
    path = PREFIX+str(OS.get_process_id())+".json"
    ProjectSettings.set_setting("runtime/live_save_path",path)
    DisplayServer.window_set_size(Vector2i(1280,720))
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("Missing OneGame main scene")
        return
    ui = packed.instantiate() as Control
    root.add_child(ui)
    for _frame in range(8):
        await process_frame
    var state: SimulationState = ui.get("state")
    var runtime: LiveGameRuntimeV2 = ui.get("runtime_session")
    if state == null or runtime == null or not bool(ui.get("runtime_ready")):
        _fail("New Game runtime unavailable")
        return
    for key in ["runtime_poll_timer","autosave_timer"]:
        var timer := ui.get(key) as Timer
        if timer != null:
            timer.stop()
    var ids: Array[StringName] = []
    var branches := ["ngu_kiem","doc_cham"]
    for i in range(2):
        var candidates: Array = state.recruitment_candidates.keys()
        candidates.sort()
        if candidates.is_empty():
            _fail("No real recruitment candidate")
            return
        var id := StringName(str(candidates[0]))
        var result := RecruitmentSystem.new().accept_candidate(state,id)
        if not bool(result.get("ok",false)) or not DiscipleRealmProgressV2.progression_ready(state.disciples[id]):
            _fail("Canonical V2 recruitment rejected")
            return
        var disciple: DiscipleState = state.disciples[id]
        var school := SectASCharCandidateBridgeV1.assign_branch(state,disciple,branches[i])
        if not bool(school.get("ok",false)):
            _fail("Canonical school assignment rejected: "+str(school))
            return
        ids.append(id)
    ui.call("_open_pve_party_picker")
    ui.set("pve_party_selected_ids",ids)
    ui.call("_populate_pve_party_picker")
    var start := ui.get_node_or_null("PvePartyPickerShade/PvePartyPicker/PvePartyPickerStart") as Button
    if start == null or start.disabled or not await _capture("00_real_party_picker.png"):
        _fail("Actual two-hunter picker unavailable")
        return
    state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
    state.runtime_unconsumed_wall_seconds = 0.0
    await ui.call("_start_multicamp_hunt_for_picked_party")
    await process_frame
    ui.set_process(false)
    var encounter := HuntingPveRunV2.active_multicamp_id(state)
    var session: HuntingPveRunV2 = runtime.owner.get_active_multicamp_session(encounter)
    var view := ui.get("b3_pve_world_view") as PveSectWorldViewV1
    if session == null or view == null or not view.is_visible_in_tree():
        _fail("Real hunting map did not open")
        return
    var selected: Array[String] = [str(ids[0])]
    view.selected_actor_ids = selected
    view.camera_zoom = PveSectWorldViewV1.MAX_ZOOM
    view._clamp_camera()
    await ui.call("_on_p0_hunt_policy_ordered",selected,"auto")
    view.camera_zoom = PveSectWorldViewV1.MAX_ZOOM
    view._clamp_camera()
    if not await _capture("01_live_world_entry.png"):
        _fail("World entry frame missing")
        return
    var observed_hit := false
    var observed_cast := false
    var hit_receipts := {}
    var hunter_hits := {}
    var captured_hit := false
    var elapsed_ticks := 0
    for tick in range(45):
        var wall_target := int(state.runtime_last_wall_unix)+1
        var step := runtime.poll(wall_target)
        var drains := 0
        while true:
            if not bool(step.get("ok",false)):
                _fail("Runtime poll rejected: "+str(step))
                return
            if bool(step.get("barrier",false)):
                var save: Dictionary = await runtime.owner.saves.wait_for_async_save(self)
                if not bool(save.get("ok",false)) or bool(save.get("pending",false)):
                    _fail("Runtime save barrier failed")
                    return
            if not bool(step.get("backlog_pending",false)):
                break
            drains += 1
            if drains > 64:
                _fail("Runtime backlog did not drain")
                return
            step = runtime.poll(wall_target)
        session = runtime.owner.get_active_multicamp_session(encounter)
        if session == null or session.battle == null:
            break
        elapsed_ticks = tick+1
        var battle := session.battle
        var actor: Dictionary = battle.actors.get(str(ids[0]),{})
        if not actor.is_empty():
            view.camera_center = actor.get("position",view.camera_center)
            view._clamp_camera()
        ui.call("_refresh_multicamp_hunt_panel")
        view.camera_zoom = PveSectWorldViewV1.MAX_ZOOM
        view._clamp_camera()
        for event in battle.events:
            if str(event.get("type","")) == "skill_cast" and str(event.get("caster","")) in [str(ids[0]),str(ids[1])]:
                observed_cast = true
            if str(event.get("type","")) == "hit" and float(event.get("damage",0.0)) > 0.0:
                var receipt := str(event.get("event_id",""))
                if not receipt.is_empty():
                    hit_receipts[receipt] = true
                observed_hit = true
                if str(event.get("attacker","")) in [str(ids[0]),str(ids[1])] and not receipt.is_empty():
                    hunter_hits[receipt] = true
        for _frame in range(24):
            await process_frame
        if observed_hit and not captured_hit:
            captured_hit = await _capture("02_live_positive_hit.png")
        # Capture the actual evolving fight, not just the first burst of
        # receipts. Never invent hits or keep a defeated battle advancing.
        if battle._count_alive("disciple") <= 0:
            break
        if elapsed_ticks >= 15 and hunter_hits.size() >= 4:
            break
    var final_frame := await _capture("03_live_world_end.png")
    var report := {
        "source_sha":OS.get_environment("GITHUB_SHA"),"new_game":true,
        "real_recruits":ids,"observed_positive_hit":observed_hit,
        "observed_skill_cast":observed_cast,"unique_hit_receipts":hit_receipts.size(),
        "hunter_hit_receipts":hunter_hits.size(),
        "simulated_wall_ticks":elapsed_ticks,"forced_damage":false,"forced_feature_gates":false,
        "camera_zoom":view.camera_zoom,"camera_max_zoom":PveSectWorldViewV1.MAX_ZOOM,
        "capture_kind":"actual_OneGame_scene_virtual_display_max_native_zoom"
    }
    var file := FileAccess.open(out.path_join("pve_capture_report.json"),FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(report,"  "))
        file.close()
    print("ONEGAME_PVE_CAPTURE "+JSON.stringify(report))
    _cleanup()
    quit(0 if observed_hit and not hunter_hits.is_empty() and captured_hit and final_frame else 1)
