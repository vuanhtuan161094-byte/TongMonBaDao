extends SceneTree

# GP-01: same real Dẫn Tiên V2 recruit -> work group + explicit worksite ->
# scheduler starts a persisted Mine timer -> Warehouse -> offline resume exactly
# once. No injected resources, EXP, time rewards or fake secondary authority.
const SAVE_PATH := "user://gp_01_v2_mine_vertical_slice_test.json"

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
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if not _check(mine != null and state.sect.disciple_v2_birth_enabled
        and state.sect.v2_training_enabled and state.disciples.size() == 6,
        "Missing canonical fresh live Mine/V2 runtime."):
        return

    var founders: Array = state.disciples.keys()
    founders.sort()
    var initial_miners := buildings.active_worker_ids(state, mine)
    if not _check(initial_miners.size() == 2, "Opening mine must have two real slots."):
        return

    # Keep the six founders in the simulation, but prevent unrelated
    # mining/hunt rewards from contaminating this new disciple's batch.
    for raw_id in founders:
        if not _check(workforce.issue_command(
            state, StringName(raw_id), WorkforceSystem.COMMAND_HOLD, "", 2000
        ), "Could not hold founding disciple."):
            return

    if not await _open_guidance_surface():
        return
    var token_before := state.sect.disciple_recruitment_tokens
    if not await _press("UseRecruitmentOrder"):
        return
    if not _check(state.sect.disciple_recruitment_tokens == token_before - 1,
        "Dẫn Tiên did not consume one real recruitment order."):
        return
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    var recruit_id := &""
    for raw_id in ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            recruit_id = StringName(raw_id)
            break
    if not _check(recruit_id != &"", "Dẫn Tiên yielded no genuine V2 candidate."):
        return
    var birth_before: Dictionary = (
        state.recruitment_candidates[recruit_id] as CandidateState
    ).v2_birth_profile.duplicate(true)
    if not await _select_and_accept_candidate_via_b1(recruit_id):
        return
    if not _check(state.disciples.has(recruit_id), "Dẫn Tiên accept did not create a disciple."):
        return
    var actor: DiscipleState = state.disciples[recruit_id]
    if not _check(DiscipleRealmProgressV2.owns_v2_progression(actor)
        and actor.v2_birth_profile == birth_before,
        "V2 birth identity rerolled on acceptance."):
        return

    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    if not await _press("Group_mining_crew_%s" % str(recruit_id)):
        return
    if not _check(actor.work_group_id == &"mining_crew",
        "New V2 recruit did not join the real mining crew."):
        return
    if not await _press("MineWorksite_%s" % str(recruit_id)):
        return
    if not _check(actor.worksite_building_id == mine.id,
        "Mine worksite was not assigned through player-facing UI."):
        return

    # Being in a group/worksite is not the same as consuming an active slot.
    # Explicit worksite selection must not create phantom third slot.
    var active := buildings.active_worker_ids(state, mine)
    if not _check(active.size() == buildings.worker_slots(mine)
        and _mine_group_count() == 3
        and str(ui.call("_mine_operation_text")).contains("Đang chờ slot Mỏ: 1"),
        "Oversubscribed Mine did not report one waiting member."):
        return
    var waiting_id := &""
    for raw_id in state.disciples.keys():
        var d: DiscipleState = state.disciples[raw_id]
        if d.work_group_id == &"mining_crew" and not active.has(d.id):
            waiting_id = d.id
            break
    if not _check(waiting_id != &"" and not workforce.issue_command(
        state, waiting_id, WorkforceSystem.COMMAND_WORK, "mining", 40
    ), "Waiting member received a fake work command."):
        return
    var waiting_button := ui.find_child(
        "Work_mining_%s" % str(waiting_id), true, false
    ) as Button
    if not _check(waiting_button != null and waiting_button.disabled,
        "Waiting Mine member's UI work control is enabled."):
        return

    # Releasing founding workers preserves the V2 recruit's group and
    # explicit worksite, and activates exactly one valid Mine slot.
    for raw_id in initial_miners:
        if not _check(workforce.assign_group(state, raw_id, &""),
            "Could not release an initial Mine slot."):
            return
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    if not _check(buildings.active_worker_ids(state, mine).has(recruit_id)
        and actor.worksite_building_id == mine.id,
        "V2 recruit did not gain the available Mine slot."):
        return
    var xp_before := float(actor.profession_xp.get("mining", 0.0))
    var tuvi_before := float(actor.v2_realm_progress["cultivation"]["xp"])
    var natural := DiscipleTuViFlowV2.preview_rate(state, actor, false)
    if not _check(bool(natural.get("ok", false)), "Natural V2 Tu Vi rate unavailable."):
        return
    var rate := float(natural["effective_tuvi_per_minute"])
    var ore_before := warehouse.quantity(state, &"thanh_thiet")
    var batches_before := int(mine.metrics.get("production_batches", 0))
    if not await _press("Work_mining_%s" % str(recruit_id)):
        return
    if not _check(workforce.command_kind(actor) == WorkforceSystem.COMMAND_WORK,
        "Player Mine order was not committed by WorkforceSystem."):
        return

    var scheduler: SimulationScheduler = (ui.get("runtime_session") as LiveGameRuntimeV2).scheduler()
    # Economy-A owns a saved building timer, not a disciple carry phase.
    # Stop at the first real active job, before any goods or profession EXP.
    var pending_job: Dictionary = {}
    var tick_count := 0
    for _i in range(100):
        scheduler.step()
        tick_count += 1
        pending_job = buildings.active_resource_timer_for_worker(state, recruit_id)
        if not pending_job.is_empty():
            break
    ui.call("_refresh_all")
    if not _check(not pending_job.is_empty()
        and str(pending_job.get("resource_id", "")) == "thanh_thiet"
        and int(pending_job.get("output_quantity", 0)) > 0
        and int(pending_job.get("finish_tick", state.tick)) > state.tick
        and actor.work_cycle_state.is_empty()
        and warehouse.quantity(state, &"thanh_thiet") == ore_before
        and str(ui.call("_mine_operation_text")).contains("Còn ")
        and str(ui.call("_mine_operation_text")).contains("phút mô phỏng"),
        "V2 Mine did not create a paid pending timer with zero early Warehouse credit."):
        return
    if not _check(float(actor.profession_xp.get("mining", 0.0)) == xp_before,
        "Mining EXP was granted before completing the batch."):
        return
    if not _check(_near(
        float(actor.v2_realm_progress["cultivation"]["xp"]),
        tuvi_before + rate * float(tick_count)
    ), "V2 Tu Vi natural tick was duplicated or lost during Mine work."):
        return

    var saved_job: Dictionary = pending_job.duplicate(true)
    var saved_birth: Dictionary = actor.v2_birth_profile.duplicate(true)
    var runtime: LiveGameRuntimeV2 = ui.get("runtime_session") as LiveGameRuntimeV2
    var wall := state.runtime_last_wall_unix
    if not _check(bool(runtime.save(wall).get("ok", false)),
        "Cannot save the canonical pending Mine timer."):
        return

    # Predict with the SAME scheduler and runtime clock on an independent
    # snapshot; offline reload must converge byte-for-byte to that authority.
    var expected := SimulationState.from_dict(state.to_dict())
    var expected_scheduler := SimulationScheduler.new(expected)
    var needed := -1
    for minutes in range(1, 101):
        var advanced := SimulationRuntimeClockV2.advance_to(
            expected, expected_scheduler, wall + minutes * 60
        )
        if not _check(bool(advanced.get("ok", false))
            and int(advanced.get("steps_run", -1)) == 1,
            "Prediction clock failed exactly-one-minute progression."):
            return
        if warehouse.quantity(expected, &"thanh_thiet") > ore_before:
            needed = minutes
            break
    if not _check(needed > 0, "No paid Mine deposit occurred after the pending timer."):
        return

    _dispose_scene()
    await process_frame
    var resumed := LiveGameRuntimeV2.new()
    var opened := resumed.start(SAVE_PATH, wall + needed * 60, 31012026)
    if not _check(bool(opened.get("ok", false))
        and int(opened.get("catch_up_steps", -1)) == needed,
        "Offline runtime did not replay the exact pending minutes."):
        return
    var final_state := resumed.state()
    var final_actor: DiscipleState = final_state.disciples[recruit_id]
    var final_mine := buildings.primary_building(final_state, BuildingSystem.TYPE_MINE)
    var batch := int(saved_job.get("output_quantity", 0))
    if not _check(warehouse.quantity(final_state, &"thanh_thiet") == ore_before + batch
        and int(final_mine.metrics.get("production_batches", 0)) == batches_before + 1
        and final_actor.work_cycle_state.is_empty()
        and buildings.active_resource_timer_for_worker(final_state,recruit_id).is_empty()
        and final_actor.v2_birth_profile == saved_birth
        and final_actor.worksite_building_id == mine.id
        and final_actor.profession_xp.get("mining", 0.0) > xp_before
        and _state_semantically_equal(final_state.to_dict(),expected.to_dict()),
        "Offline recovery diverged from one real Mine completion/EXP/state."):
        print("GP01_OFFLINE_FACTS ore_expected=%d ore_actual=%d batches_expected=%d batches_actual=%d cycle_empty=%s birth_equal=%s worksite_expected=%s worksite_actual=%s mining_xp_before=%.6f mining_xp_after=%.6f state_equal=%s" % [
            ore_before+batch,warehouse.quantity(final_state,&"thanh_thiet"),batches_before+1,
            int(final_mine.metrics.get("production_batches",0)),str(final_actor.work_cycle_state.is_empty()),
            str(final_actor.v2_birth_profile == saved_birth),str(mine.id),str(final_actor.worksite_building_id),
            xp_before,float(final_actor.profession_xp.get("mining",0.0)),
            str(final_state.to_dict() == expected.to_dict())
        ])
        var state_diffs: Array[String] = []
        _collect_state_diffs(expected.to_dict(),final_state.to_dict(),"state",state_diffs)
        for difference in state_diffs:
            print("GP01_STATE_DIFF %s" % difference)
        return
    var loaded_xp := float(final_actor.profession_xp["mining"])
    if not _check(_near(
        float(final_actor.v2_realm_progress["cultivation"]["xp"]),
        tuvi_before + rate * float(tick_count + needed)
    ), "Offline V2 natural Tu Vi diverged or was awarded twice."):
        return
    if not _check(bool(resumed.save(wall + needed * 60).get("ok", false)),
        "Cannot save first actual offline completion."):
        return
    var repeated := LiveGameRuntimeV2.new()
    var retried := repeated.start(SAVE_PATH, wall + needed * 60, 31012026)
    var again: SimulationState = repeated.state()
    if not _check(bool(retried.get("ok", false))
        and int(retried.get("catch_up_steps", -1)) == 0
        and warehouse.quantity(again, &"thanh_thiet") == ore_before + batch
        and int((buildings.primary_building(again, BuildingSystem.TYPE_MINE)).metrics.get("production_batches", 0)) == batches_before + 1
        and _near(float((again.disciples[recruit_id] as DiscipleState).profession_xp["mining"]), loaded_xp),
        "Same-time second reload replayed Mine output or profession EXP."):
        return
    var errors := again.validate_invariants()
    errors.append_array(buildings.validate_invariants(again))
    errors.append_array(warehouse.validate_invariants(again))
    errors.append_array(workforce.validate_invariants(again))
    if not _check(errors.is_empty(), "GP-01 invariants: %s" % " | ".join(errors)):
        return

    print("GP-01 V2 GUIDANCE -> WORKSITE -> MINE -> WAREHOUSE -> OFFLINE EXACTLY-ONCE: PASS")
    _cleanup()
    quit(0)

func _near(a: float, b: float) -> bool:
    return absf(a-b) < 0.1

func _mine_group_count() -> int:
    var count := 0
    for raw_id in state.disciples.keys():
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id == &"mining_crew":
            count += 1
    return count

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("Cannot load real P3.2 scene.")
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    return _check(state != null, "No canonical live SimulationState in scene.")

func _press(name: String) -> bool:
    var button := ui.find_child(name, true, false) as Button
    if button == null or button.disabled:
        return _fail("Missing or disabled real UI button: %s" % name)
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

func _collect_state_diffs(expected_value: Variant, actual_value: Variant,
        path: String, differences: Array[String]) -> void:
    if differences.size() >= 24:
        return
    if typeof(expected_value) != typeof(actual_value):
        differences.append("%s type expected=%s (%s) actual=%s (%s)" % [
            path,type_string(typeof(expected_value)),str(expected_value).substr(0,120),
            type_string(typeof(actual_value)),str(actual_value).substr(0,120)
        ])
        return
    if expected_value is Dictionary and actual_value is Dictionary:
        var keys: Array = expected_value.keys()
        for key in actual_value.keys():
            if not keys.has(key):
                keys.append(key)
        keys.sort()
        for key in keys:
            var child_path := "%s.%s" % [path,str(key)]
            if not expected_value.has(key) or not actual_value.has(key):
                differences.append("%s expected=%s actual=%s" % [child_path,str(expected_value.get(key,"<missing>")),str(actual_value.get(key,"<missing>"))])
            else:
                _collect_state_diffs(expected_value[key],actual_value[key],child_path,differences)
            if differences.size() >= 24:
                return
    elif expected_value is Array and actual_value is Array:
        if expected_value.size() != actual_value.size():
            differences.append("%s.length expected=%d actual=%d" % [path,expected_value.size(),actual_value.size()])
        var count := mini(expected_value.size(),actual_value.size())
        for index in range(count):
            _collect_state_diffs(expected_value[index],actual_value[index],"%s[%d]" % [path,index],differences)
            if differences.size() >= 24:
                return
    elif expected_value != actual_value:
        differences.append("%s expected=%s actual=%s" % [path,str(expected_value).substr(0,180),str(actual_value).substr(0,180)])

func _state_semantically_equal(left: Variant, right: Variant) -> bool:
    # JSON has no distinct integer token, so reload can produce 1.0 instead of 1.
    # Compare exact numeric value while ignoring only the integer/float type tag.
    var left_numeric := left is int or left is float
    var right_numeric := right is int or right is float
    if left_numeric or right_numeric:
        return left_numeric and right_numeric and left == right
    if left is Dictionary and right is Dictionary:
        if left.size() != right.size():
            return false
        for key in left.keys():
            if not right.has(key) or not _state_semantically_equal(left[key],right[key]):
                return false
        return true
    if left is Array and right is Array:
        if left.size() != right.size():
            return false
        for index in range(left.size()):
            if not _state_semantically_equal(left[index],right[index]):
                return false
        return true
    return left == right

func _check(valid: bool, message: String) -> bool:
    if not valid:
        return _fail(message)
    return true

func _fail(message: String) -> bool:
    push_error("GP-01: " + message)
    _dispose_scene()
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    for name in [SAVE_PATH, SAVE_PATH + ".bak", SAVE_PATH + ".tmp"]:
        if FileAccess.file_exists(name):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(name))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
