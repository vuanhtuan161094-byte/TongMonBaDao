extends SceneTree

# GP-02A: real Dẫn Tiên V2 recruit, V2-only cultivation panel and command
# bridge, genuine paid Mine timer busy rejection, natural Tu Vi once per
# scheduler minute, and canonical save/reload. P2 legacy remains separate.
const SAVE_PATH := "user://gp_02a_v2_cultivation_panel_test.json"

var ui: Control
var state: SimulationState
var workforce := WorkforceSystem.new()
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    # P2 isolation: this founding disciple has no authentic V2 birth. Its
    # established stage and progress must remain sourced from P2.
    var founders: Array = state.disciples.keys()
    founders.sort()
    if not _check(founders.size() == 6, "Fresh scene has no opening roster."):
        return
    var legacy: DiscipleState = state.disciples[founders[0]]
    if not _check(not DiscipleRealmProgressV2.owns_v2_progression(legacy),
        "Legacy P2 founder unexpectedly has authentic V2 progression."):
        return
    var old_action := legacy.current_action
    legacy.current_action = &"CULTIVATE"
    var legacy_label := CultivationSystem.new().stage_name(legacy)
    var legacy_text := str(ui.call("_cultivation_operation_text"))
    if not _check(legacy_text.contains(legacy_label)
        and legacy_text.contains("thể lực %.0f" % legacy.stamina)
        and not legacy_text.contains("Tu Vi V2: dữ liệu chưa sẵn sàng"),
        "P2 founding disciple cultivation UI changed authority."):
        return
    legacy.current_action = old_action
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if not _check(mine != null, "Canonical Mine missing."):
        return
    var initial_miners := buildings.active_worker_ids(state, mine)
    if not _check(initial_miners.size() == 2, "Opening Mine has no two active miners."):
        return
    for raw_id in founders:
        if not _check(workforce.issue_command(
            state, StringName(raw_id), WorkforceSystem.COMMAND_HOLD, "", 1000
        ), "Cannot hold founder for isolated V2 test."):
            return

    # Recruit through the genuine Guidance UI, with token debit and Accept.
    if not await _open_guidance_surface():
        return
    var tokens := state.sect.disciple_recruitment_tokens
    if not await _press("UseRecruitmentOrder"):
        return
    if not _check(state.sect.disciple_recruitment_tokens == tokens - 1,
        "Real Dẫn Tiên order did not debit one token."):
        return
    var candidates: Array = state.recruitment_candidates.keys()
    candidates.sort()
    var chosen := &""
    for raw_id in candidates:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            chosen = StringName(raw_id)
            break
    if not _check(chosen != &"", "Dẫn Tiên produced no genuine V2 candidate."):
        return
    if not await _select_and_accept_candidate_via_b1(chosen):
        return
    if not _check(state.disciples.has(chosen), "V2 candidate was not accepted."):
        return
    var actor: DiscipleState = state.disciples[chosen]
    if not _check(DiscipleRealmProgressV2.progression_ready(actor),
        "Real recruited disciple lacks valid V2 authority."):
        return
    var v2_birth: Dictionary = actor.v2_birth_profile.duplicate(true)

    # Poison the P2 compatibility fields. Neither the visible V2 panel nor
    # its eligibility may take the legacy stage, XP, or breakthrough status.
    actor.cultivation_stage_index = 8
    actor.cultivation_progress = 876543.0
    var tuvi_before := float(actor.v2_realm_progress["cultivation"]["xp"])
    var passive_tick_before := int(actor.v2_realm_progress["last_passive_tuvi_tick"])
    var specialized := DiscipleTuViFlowV2.preview_rate(state, actor, true)
    if not _check(bool(specialized.get("ok", false)),
        "Cannot preview the authored V2 specialized Tu Vi source."):
        return

    # Player-facing Tu Luyện Đài must route through the V2 request API.
    ui.call("_open_building", SectMapPresentation.DEST_CULTIVATION)
    await process_frame
    if not await _press("Order_CULTIVATE_%s" % str(chosen)):
        return
    if not _check(actor.current_action == &"CULTIVATE"
        and actor.direct_command.is_empty()
        and str(actor.v2_realm_progress["training_policy"]) == "cultivation_focus"
        and _close(float(actor.v2_realm_progress["cultivation"]["xp"]), tuvi_before)
        and int(actor.v2_realm_progress["last_passive_tuvi_tick"]) == passive_tick_before
        and str(ui.get("building_management_feedback")).contains("Chuyên Tu"),
        "Cultivation Platform bypassed V2 preflight or granted instant XP."):
        return

    var snap: Dictionary = DisciplePresentationSnapshotV2.build(state, actor)
    var cultivation: Dictionary = snap["progression"]["cultivation"]
    var panel := str(ui.call("_cultivation_operation_text"))
    var expected := "%s tầng %d · %.0f/%.0f" % [
        str(cultivation["name"]), int(cultivation["floor"]),
        float(cultivation["xp"]), float(cultivation["required_xp"])
    ]
    if not _check(panel.contains(expected)
        and panel.contains("Thể lực viễn chinh")
        and not panel.contains("876543")
        and not panel.contains("Luyện Khí")
        and not panel.contains("CÓ THỂ ĐỘT PHÁ"),
        "Cultivation Platform leaked P2 fields/eligibility for V2."):
        return

    var scheduler: SimulationScheduler = (ui.get("runtime_session") as LiveGameRuntimeV2).scheduler()
    scheduler.step()
    var xp_one := float(actor.v2_realm_progress["cultivation"]["xp"])
    if not _check(_close(
        xp_one, tuvi_before + float(specialized["effective_tuvi_per_minute"])
    ) and int(actor.v2_realm_progress["last_passive_tuvi_tick"]) == state.tick,
        "Scheduler did not award V2 specialized Tu Vi precisely once."):
        return
    var duplicate := DiscipleTuViFlowV2.resolve_minute(state, actor, true)
    if not _check(not bool(duplicate.get("ok", true))
        and str(duplicate.get("reason", "")) == "passive_tuvi_tick_already_awarded"
        and _close(float(actor.v2_realm_progress["cultivation"]["xp"]), xp_one),
        "Second V2 Tu Vi grant in one tick was accepted."):
        return

    # Start the real Economy-A Mine timer and stop before its payout.
    # current_action alone cannot signal whether a saved job occupies a worker.
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    if not await _press("Group_mining_crew_%s" % str(chosen)):
        return
    if not await _press("MineWorksite_%s" % str(chosen)):
        return
    for raw_id in initial_miners:
        if not _check(workforce.assign_group(state, raw_id, &""),
            "Cannot make a Mine slot for the new V2 disciple."):
            return
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    if not _check(buildings.active_worker_ids(state, mine).has(chosen),
        "New V2 recruit has no active Mine slot."):
        return
    var ore_before := warehouse.quantity(state, &"thanh_thiet")
    if not await _press("Work_mining_%s" % str(chosen)):
        return
    var pending_job: Dictionary = {}
    for _i in range(100):
        scheduler.step()
        pending_job = buildings.active_resource_timer_for_worker(state, chosen)
        if not pending_job.is_empty():
            break
    if not _check(not pending_job.is_empty()
        and int(pending_job.get("finish_tick",state.tick)) > state.tick
        and actor.work_cycle_state.is_empty()
        and warehouse.quantity(state, &"thanh_thiet") == ore_before,
        "Real Mine timer not reserved without early Warehouse delivery."):
        return

    var busy_action := actor.current_action
    var before_timer: Dictionary = pending_job.duplicate(true)
    var before_command := actor.direct_command.duplicate(true)
    var before_group := actor.work_group_id
    var before_worksite := actor.worksite_building_id
    var before_policy := str(actor.v2_realm_progress["training_policy"])
    var before_xp := float(actor.v2_realm_progress["cultivation"]["xp"])
    var before_ore := warehouse.quantity(state, &"thanh_thiet")

    ui.call("_open_building", SectMapPresentation.DEST_CULTIVATION)
    await process_frame
    if not await _press("Order_CULTIVATE_%s" % str(chosen)):
        return
    if not _check(str(ui.get("building_management_feedback")).contains("đang bận")
        and actor.current_action == busy_action
        and buildings.active_resource_timer_for_worker(state,chosen) == before_timer
        and actor.direct_command == before_command
        and actor.work_group_id == before_group
        and actor.worksite_building_id == before_worksite
        and str(actor.v2_realm_progress["training_policy"]) == before_policy
        and _close(float(actor.v2_realm_progress["cultivation"]["xp"]), before_xp)
        and warehouse.quantity(state, &"thanh_thiet") == before_ore,
        "Busy V2 Cultivation Platform order canceled Mine haul or mutated state."):
        return

    # The already-existing summary V2 order must respect the SAME guard.
    ui.call("_open_disciple", chosen)
    await process_frame
    ui.call("_issue_summary_order", WorkforceSystem.COMMAND_CULTIVATE, "", "Tu luyện")
    if not _check(str(ui.get("summary_feedback")).contains("đang bận")
        and buildings.active_resource_timer_for_worker(state,chosen) == before_timer
        and actor.direct_command == before_command,
        "V2 summary cultivation bypassed the shared busy guard."):
        return

    # The automated test advances simulation manually; re-anchor wall time
    # and await the canonical async SaveService barrier before scene teardown.
    state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
    var saved_result: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not _check(bool(saved_result.get("ok",false)) and FileAccess.file_exists(SAVE_PATH),
        "Canonical SaveService barrier failed after denied busy command."):
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return
    var restored: DiscipleState = state.disciples[chosen]
    var restored_timer := buildings.active_resource_timer_for_worker(state,chosen)
    # JSON restores number tokens as floats; verify canonical job identity,
    # provenance, time and amount rather than Dictionary value representation.
    var timer_equal := not restored_timer.is_empty() and (
        str(restored_timer.get("job_id","")) == str(before_timer.get("job_id",""))
        and str(restored_timer.get("worker_id","")) == str(before_timer.get("worker_id",""))
        and str(restored_timer.get("profession_id","")) == str(before_timer.get("profession_id",""))
        and str(restored_timer.get("resource_id","")) == str(before_timer.get("resource_id",""))
        and int(restored_timer.get("started_tick",-1)) == int(before_timer.get("started_tick",-2))
        and int(restored_timer.get("finish_tick",-1)) == int(before_timer.get("finish_tick",-2))
        and int(restored_timer.get("output_quantity",-1)) == int(before_timer.get("output_quantity",-2))
        and is_equal_approx(float(restored_timer.get("profession_xp_gain",-1.0)),
            float(before_timer.get("profession_xp_gain",-2.0)))
    )
    var restored_ore := warehouse.quantity(state, &"thanh_thiet")
    var restorable := restored.v2_birth_profile == v2_birth
        and restored.work_cycle_state.is_empty()
        and timer_equal
        and restored.direct_command == before_command
        and restored.worksite_building_id == before_worksite
        and str(restored.v2_realm_progress["training_policy"]) == before_policy
        and _close(float(restored.v2_realm_progress["cultivation"]["xp"]), before_xp)
        and restored_ore == before_ore
    if not restorable:
        print("GP02A_RESTORE_FACTS birth=",restored.v2_birth_profile == v2_birth,
            " cycle_empty=",restored.work_cycle_state.is_empty(),
            " timer_equal=",timer_equal,
            " timer_before=",var_to_str(before_timer),
            " timer_after=",var_to_str(restored_timer),
            " command_equal=",restored.direct_command == before_command,
            " worksite_equal=",restored.worksite_building_id == before_worksite,
            " policy_equal=",str(restored.v2_realm_progress["training_policy"]) == before_policy,
            " xp_before=",before_xp," xp_after=",restored.v2_realm_progress["cultivation"]["xp"],
            " ore_before=",before_ore," ore_after=",restored_ore)
    if not _check(restorable, "Save/reload changed V2 authority or pending Mine timer."):
        return

    scheduler = (ui.get("runtime_session") as LiveGameRuntimeV2).scheduler()
    var delivered := false
    for _i in range(100):
        scheduler.step()
        if warehouse.quantity(state, &"thanh_thiet") > ore_before:
            delivered = true
            break
    if not _check(delivered and restored.work_cycle_state.is_empty()
        and buildings.active_resource_timer_for_worker(state,chosen).is_empty()
        and float(restored.profession_xp.get("mining", 0.0)) > 0.0,
        "Rejected Cultivation order broke continuation of the real Mine delivery."):
        return
    var errors := state.validate_invariants()
    errors.append_array(buildings.validate_invariants(state))
    errors.append_array(warehouse.validate_invariants(state))
    errors.append_array(workforce.validate_invariants(state))
    if not _check(errors.is_empty(), "GP-02A invariants failed: %s" % " | ".join(errors)):
        return

    print("GP-02A V2 CULTIVATION PANEL + SAFE BUSY COMMAND + SAVE/RELOAD + P2 ISOLATION PASS")
    _dispose_scene()
    _cleanup()
    quit(0)

func _close(a: float, b: float) -> bool:
    return absf(a-b) < 0.1

func _open_scene() -> bool:
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        return _fail("Cannot load real landscape scene.")
    ui = packed.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    return _check(state != null and bool(ui.get("runtime_ready")),
        "No canonical live simulation state.")

func _press(name: String) -> bool:
    var button := ui.find_child(name, true, false) as Button
    if button == null or button.disabled:
        return _fail("Missing or disabled real player control: " + name)
    button.emit_signal("pressed")
    await process_frame
    return true

func _open_guidance_surface() -> bool:
    var hit := ui.find_child("BuildingHit_guidance",true,false) as Button
    if hit == null:
        return _fail("Missing real map hit target for Dẫn Tiên Đài.")
    hit.pressed.emit()
    await process_frame
    return await _press("OpenDanTienScreenV2")

func _select_and_accept_candidate_via_b1(candidate_id: StringName) -> bool:
    var candidate: CandidateState = state.recruitment_candidates.get(candidate_id)
    var b1_surface := ui.get_node_or_null("DanTienScreenV2/TriFacilityB1LiveAdapterV1") as Control
    if b1_surface == null or not b1_surface.is_visible_in_tree():
        return _fail("Active B1 guidance surface is unavailable.")
    var search := b1_surface.find_child("CandidateSearch",true,false) as LineEdit
    if candidate == null or search == null:
        return _fail("B1 search/candidate control was missing.")
    search.text = candidate.display_name
    search.text_submitted.emit(search.text)
    await process_frame
    var pick := b1_surface.find_child("CandidatePick_%s" % str(candidate_id),true,false) as Button
    if pick == null:
        return _fail("B1 candidate picker did not expose the selected authentic candidate.")
    if not pick.disabled:
        pick.pressed.emit()
        await process_frame
    else:
        var host := ui.get_node_or_null("DanTienScreenV2")
        if host == null or StringName(host.get("selected_candidate_id")) != candidate_id:
            return _fail("Disabled B1 candidate row was not the currently selected candidate.")
    var accept := b1_surface.find_child("AcceptCandidate",true,false) as Button
    if accept == null or accept.disabled:
        return _fail("B1 Accept control was missing or disabled for an eligible candidate.")
    accept.pressed.emit()
    await process_frame
    accept = b1_surface.find_child("AcceptCandidate",true,false) as Button
    if accept == null or not accept.text.contains("XÁC NHẬN"):
        return _fail("B1 Accept did not present its visible second confirmation.")
    accept.pressed.emit()
    await process_frame
    return true

func _dispose_scene() -> void:
    if ui != null and is_instance_valid(ui):
        root.remove_child(ui)
        ui.queue_free()
    ui = null
    state = null

func _check(value: bool, message: String) -> bool:
    if not value:
        return _fail(message)
    return true

func _fail(message: String) -> bool:
    push_error("GP-02A: " + message)
    _dispose_scene()
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    for path in [SAVE_PATH, SAVE_PATH + ".bak", SAVE_PATH + ".tmp"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
