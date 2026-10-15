extends SceneTree

# GP-01: same real Dẫn Tiên V2 recruit -> work group + explicit worksite ->
# scheduler Mine travel/extraction/haul -> Warehouse -> offline resume exactly
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
    if not _check(initial_miners.size() == 1, "Opening mine must have exactly one operator."):
        return

    # Keep the six founders in the simulation, but prevent unrelated
    # mining/hunt rewards from contaminating this new disciple's batch.
    for raw_id in founders:
        if not _check(workforce.issue_command(
            state, StringName(raw_id), WorkforceSystem.COMMAND_HOLD, "", 2000
        ), "Could not hold founding disciple."):
            return

    ui.call("_open_building", SectMapPresentation.DEST_GUIDANCE)
    await process_frame
    var token_before := state.sect.disciple_recruitment_tokens
    if not await _press("GuidanceRecruitOrder"):
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
    if not await _press("AcceptCandidate_%s" % str(recruit_id)):
        return
    if not _check(state.disciples.has(recruit_id), "Dẫn Tiên accept did not create a disciple."):
        return
    var actor: DiscipleState = state.disciples[recruit_id]
    if not _check(DiscipleRealmProgressV2.owns_v2_progression(actor)
        and actor.v2_birth_profile == birth_before,
        "V2 birth identity rerolled on acceptance."):
        return

    # Fresh Mine is full with one founder: the recruited worker must not
    # receive a hidden waiting/oversubscribed assignment.
    if workforce.assign_group(state, recruit_id, &"mining_crew"):
        _fail("Mine allowed a second group-only worker before vacancy.")
        return
    if bool(workforce.assign_mine_worker(state, recruit_id, mine.id).get("ok", false)):
        _fail("Mine accepted a second active worker before vacancy.")
        return

    # Release the founder, then exercise the real player-facing group/site UI.
    if not _check(workforce.assign_group(state, initial_miners[0], &""),
        "Could not release initial one-worker Mine slot."):
        return
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    if not await _press("Group_mining_crew_%s" % str(recruit_id)):
        return
    if not _check(actor.work_group_id == &"mining_crew",
        "New V2 recruit was not allocated to the vacant mining crew."):
        return
    if not await _press("MineWorksite_%s" % str(recruit_id)):
        return
    if not _check(actor.worksite_building_id == mine.id
        and buildings.active_worker_ids(state, mine) == [recruit_id]
        and buildings.assigned_worker_ids(state, mine).size() == 1,
        "Recruit did not receive exactly one real Mine worksite."):
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
    var reached_haul := false
    var tick_count := 0
    for _i in range(100):
        scheduler.step()
        tick_count += 1
        var phase := str(actor.work_cycle_state.get("phase", ""))
        if phase == "haul_back" and int(actor.work_cycle_state.get("carried_units", 0)) > 0:
            reached_haul = true
            break
    ui.call("_refresh_all")
    if not _check(reached_haul and warehouse.quantity(state, &"thanh_thiet") == ore_before
        and str(ui.call("_mine_operation_text")).contains("Vận chuyển về kho"),
        "V2 Mine cycle did not reach real carried ore without early deposit."):
        return
    if not _check(float(actor.profession_xp.get("mining", 0.0)) == xp_before,
        "Mining EXP was granted before completing the batch."):
        return
    if not _check(_near(
        float(actor.v2_realm_progress["cultivation"]["xp"]),
        tuvi_before + rate * float(tick_count)
    ), "V2 Tu Vi natural tick was duplicated or lost during Mine work."):
        return

    var saved_cycle: Dictionary = actor.work_cycle_state.duplicate(true)
    var saved_birth: Dictionary = actor.v2_birth_profile.duplicate(true)
    var runtime: LiveGameRuntimeV2 = ui.get("runtime_session") as LiveGameRuntimeV2
    var wall := state.runtime_last_wall_unix
    if not _check(bool(runtime.save(wall).get("ok", false)),
        "Cannot save the canonical carried Mine cycle."):
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
    if not _check(needed > 0, "No paid Mine deposit occurred after carried phase."):
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
    var definition: Dictionary = BuildingSystem.DEFINITIONS[str(BuildingSystem.TYPE_MINE)]
    var batch := buildings.mining_batch_units_for_worker(state, mine, actor)
    if not _check(warehouse.quantity(final_state, &"thanh_thiet") == ore_before + batch
        and int(final_mine.metrics.get("production_batches", 0)) == batches_before + 1
        and final_actor.work_cycle_state.is_empty()
        and final_actor.v2_birth_profile == saved_birth
        and final_actor.worksite_building_id == mine.id
        and final_actor.profession_xp.get("mining", 0.0) > xp_before
        and final_state.to_dict() == expected.to_dict(),
        "Offline recovery diverged from one real Mine completion/EXP/state."):
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

func _dispose_scene() -> void:
    if ui != null and is_instance_valid(ui):
        root.remove_child(ui)
        ui.queue_free()
    ui = null
    state = null

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
