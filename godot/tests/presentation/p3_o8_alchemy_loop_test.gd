extends SceneTree

const SAVE_PATH := "user://p3_o8_alchemy_loop_test.json"

var ui: Control
var state: SimulationState
var scheduler: SimulationScheduler
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    var hall := buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if hall == null or field == null:
        _fail("O8 fresh runtime is missing Alchemy Hall or Spirit Field.")
        return
    if hall.level != 1 or buildings.worker_slots(hall) != 2:
        _fail("O8 Alchemy Hall Lv1 must own exactly two worker slots.")
        return
    if ui.find_child("BuildingToken_alchemy_hall", true, false) == null:
        _fail("O8 main scene has no real Alchemy Hall token.")
        return
    if not AlchemyRecipeRegistry.new().validate_definitions().is_empty():
        _fail("O8 Alchemy recipe registry is invalid.")
        return

    var field_worker_id := _first_unassigned()
    if field_worker_id == &"":
        _fail("O8 has no unassigned Spirit Field worker.")
        return
    if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if not await _press("FieldGroup_%s" % str(field_worker_id)):
        return

    var alchemist_id := _first_unassigned()
    if alchemist_id == &"":
        _fail("O8 has no unassigned Alchemy worker.")
        return
    if not await _open_building(SectMapPresentation.DEST_ALCHEMY_HALL):
        return
    hall = buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    var original_hall_production := hall.production_state.duplicate(true)
    var original_policy := state.sect.sx01_pill_policy.duplicate(true)
    var original_building_event_count := state.building_event_count
    var v2_preview_recipe := MedicineCatalogueV2.recipe_id(MedicineCatalogueV2.FAMILY_HEAL,1)
    var preview_state := hall.production_state.duplicate(true)
    preview_state["recipe_id"] = str(v2_preview_recipe)
    hall.production_state = preview_state
    var v2_recipe_summary := str(ui.call("_alchemy_operation_text"))
    hall.production_state = original_hall_production
    state.sect.sx01_pill_policy = original_policy
    state.building_event_count = original_building_event_count
    if not v2_recipe_summary.contains("Thanh Linh Thảo ×3") or not v2_recipe_summary.contains("Hồi Nguyên Đan") or v2_recipe_summary.contains("Linh Cốc ×"):
        _fail("O8 Alchemy summary did not show the selected V2 recipe's canonical ingredient and product.")
        return
    if not await _press("Group_alchemy_crew_%s" % str(alchemist_id)):
        return

    # Isolate the first batch from legitimate standing automation. Keep the
    # recipe disabled while the Field creates its first real herb batch.
    if not await _press("AlchemyRecipeToggle"):
        return
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if bool(hall.production_state.get("recipe_enabled", true)):
        _fail("O8 test isolation failed to disable standing recipe.")
        return
    if not workforce.issue_command(state, alchemist_id, WorkforceSystem.COMMAND_HOLD, "", 1200):
        _fail("O8 could not hold isolated alchemist before first herb batch.")
        return

    for raw_id in state.disciples.keys():
        var id := StringName(raw_id)
        if id == field_worker_id or id == alchemist_id:
            continue
        workforce.issue_command(state, id, WorkforceSystem.COMMAND_HOLD, "", 1200)

    # Auto-demand tie starts with Linh Cốc; after that real stock exists and
    # Thanh Linh Thảo becomes the highest-demand Lv1 crop.
    if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if not await _press("FieldPlant_%s" % str(field_worker_id)):
        return
    var grain_before := warehouse.quantity(state, &"linh_coc")
    var herb_before := warehouse.quantity(state, &"thanh_linh_thao")
    for _i in range(80):
        scheduler.step()
        if warehouse.quantity(state, &"linh_coc") > grain_before:
            break
    if warehouse.quantity(state, &"linh_coc") <= grain_before:
        _fail("O8 first real Spirit Field crop never harvested.")
        return

    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if not buildings.disciple_has_active_spirit_plot(state, field_worker_id, field):
        if not await _open_building(SectMapPresentation.DEST_SPIRIT_FIELD):
            return
        if not await _press("FieldPlant_%s" % str(field_worker_id)):
            return
    for _i in range(100):
        scheduler.step()
        if warehouse.quantity(state, &"thanh_linh_thao") >= herb_before + 3:
            break
    if warehouse.quantity(state, &"thanh_linh_thao") != herb_before + 3:
        _fail("O8 real Spirit Field did not produce exactly one Lv1 Thanh Linh Thao batch.")
        return

    # Canonical lock denial: no job and no debit.
    if not warehouse.set_rule(state, &"thanh_linh_thao", 0, true):
        _fail("O8 could not lock canonical herb stock.")
        return
    var locked_qty := warehouse.quantity(state, &"thanh_linh_thao")
    if not await _open_building(SectMapPresentation.DEST_ALCHEMY_HALL):
        return
    # Re-enable the standing recipe while canonical stock is locked. No
    # scheduler tick occurs here, so lock denial remains the only start gate.
    if not await _press("AlchemyRecipeToggle"):
        return
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if not bool(hall.production_state.get("recipe_enabled", false)):
        _fail("O8 could not re-enable standing recipe under lock.")
        return
    var locked_button := ui.find_child("Work_alchemy_%s" % str(alchemist_id), true, false) as Button
    if locked_button == null or not locked_button.disabled:
        _fail("O8 UI did not fail-closed while herb stock was locked.")
        return
    if workforce.issue_command(state, alchemist_id, WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_ALCHEMY), 60):
        _fail("O8 backend accepted Alchemy work while herb stock was locked.")
        return
    if warehouse.quantity(state, &"thanh_linh_thao") != locked_qty:
        _fail("O8 lock denial mutated herb stock.")
        return
    warehouse.set_rule(state, &"thanh_linh_thao", 0, false)

    # Start the one opening recipe through the real player-facing button.
    if not await _open_building(SectMapPresentation.DEST_ALCHEMY_HALL):
        return
    var work := ui.find_child("Work_alchemy_%s" % str(alchemist_id), true, false) as Button
    if work == null or work.disabled:
        _fail("O8 Alchemy UI has no enabled real work action.")
        return
    var xp_before := workforce.profession_xp(state.disciples[alchemist_id], WorkforceSystem.PROF_ALCHEMY)
    var pill_before := warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID)
    var herbs_before_start := warehouse.quantity(state, &"thanh_linh_thao")
    work.emit_signal("pressed")
    await process_frame
    for _i in range(4):
        scheduler.step()
        hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
        if not buildings.alchemy_jobs(state, hall).is_empty():
            break

    var jobs := buildings.alchemy_jobs(state, hall)
    if jobs.size() != 1:
        _fail("O8 did not create exactly one timed Alchemy job.")
        return
    var job: Dictionary = jobs[0]
    if warehouse.quantity(state, &"thanh_linh_thao") != herbs_before_start - 3:
        _fail("O8 Alchemy start did not commit exactly three herbs once.")
        return
    if warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != pill_before:
        _fail("O8 pill appeared before timed job completion.")
        return
    if workforce.assign_group(state, alchemist_id, &"") or workforce.issue_command(state, alchemist_id, WorkforceSystem.COMMAND_HOLD, "", 20):
        _fail("O8 active timed recipe did not reserve its worker.")
        return
    ui.call("_open_disciple_quick_assignment",alchemist_id)
    await process_frame
    var active_withdraw_button := ui.find_child("QuickAssignmentWithdraw",true,false) as Button
    if active_withdraw_button == null or not active_withdraw_button.disabled or not active_withdraw_button.tooltip_text.contains("Luyện Đan"):
        _fail("O8 Quick Assignment allowed withdrawal while the canonical timed Alchemy job was active.")
        return

    var saved_id := str(job.get("job_id", ""))
    var saved_finish := int(job.get("finish_tick", -1))
    var saved_herbs := warehouse.quantity(state, &"thanh_linh_thao")
    # O8 must not tear down the scene while its real UI autosave coroutine
    # and SaveService worker are still committing. The old fire-and-forget
    # call made the reloaded recipe nondeterministic and orphaned a Thread.
    if not await _autosave_and_join_at_scene_boundary():
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return

    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    jobs = buildings.alchemy_jobs(state, hall)
    if jobs.size() != 1 or str(jobs[0].get("job_id", "")) != saved_id or int(jobs[0].get("finish_tick", -2)) != saved_finish:
        _fail("O8 reload lost/restarted the exact timed recipe.")
        return
    if warehouse.quantity(state, &"thanh_linh_thao") != saved_herbs:
        _fail("O8 reload charged recipe inputs twice.")
        return

    while state.tick < saved_finish:
        scheduler.step()
    if warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != pill_before + 1:
        _fail("O8 timed completion did not deposit exactly one canonical pill.")
        return
    if not buildings.alchemy_jobs(state, hall).is_empty():
        _fail("O8 completed job was not removed atomically.")
        return
    if workforce.profession_xp(state.disciples[alchemist_id], WorkforceSystem.PROF_ALCHEMY) <= xp_before:
        _fail("O8 completed Alchemy job granted no profession XP.")
        return

    # O8 must not tear down the scene while its real UI autosave coroutine
    # and SaveService worker are still committing. The old fire-and-forget
    # call made the reloaded recipe nondeterministic and orphaned a Thread.
    if not await _autosave_and_join_at_scene_boundary():
        return
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return
    hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != pill_before + 1 or not buildings.alchemy_jobs(state, hall).is_empty():
        _fail("O8 post-completion reload replayed output.")
        return

    # Dược Phòng consumes the canonical pill without legacy medicine/money.
    var target: DiscipleState = state.disciples[field_worker_id]
    target.hp = maxf(1.0, target.max_hp - 60.0)
    var hp_before := target.hp
    var medicine_before := state.sect.medicine_stock
    var wallet_before := target.wallet
    var treasury_before := state.sect.treasury
    if not await _open_building(SectMapPresentation.DEST_MEDICINE):
        return
    var use := ui.find_child("UsePill_%s" % str(target.id), true, false) as Button
    if use == null or use.disabled:
        _fail("O8 Dược Phòng exposes no real pill-use action.")
        return
    use.emit_signal("pressed")
    await process_frame
    if not is_equal_approx(target.hp, minf(target.max_hp, hp_before + NeedsSystem.HEALING_PILL_HP)):
        _fail("O8 Hoi Xuan Dan did not heal exactly +55 HP capped.")
        return
    if warehouse.quantity(state, NeedsSystem.HEALING_PILL_ID) != pill_before:
        _fail("O8 Dược Phòng did not consume exactly one canonical pill.")
        return
    if state.sect.medicine_stock != medicine_before or target.wallet != wallet_before or state.sect.treasury != treasury_before:
        _fail("O8 pill consumer mutated legacy medicine or money authority.")
        return

    # No second Alchemy click. Field worker remains assigned; once another real
    # herb batch exists, the standing recipe must start automatically.
    var second_job_started := false
    for _i in range(320):
        scheduler.step()
        hall = buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
        if not buildings.alchemy_jobs(state, hall).is_empty():
            second_job_started = true
            break
    if not second_job_started:
        _fail("O8 standing recipe did not autonomously start after new real herbs became available.")
        return

    ui.call("_refresh_all")
    if not str(ui.call("_alchemy_operation_text")).contains("Hồi Xuân Đan"):
        _fail("O8 Alchemy panel is not projecting canonical output.")
        return
    if not str(ui.call("_warehouse_operation_text")).contains("Hồi Xuân Đan"):
        _fail("O8 Warehouse panel omits canonical pill.")
        return

    var errors := state.validate_invariants()
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    if not errors.is_empty():
        _fail("O8 final state violates invariants: %s" % " | ".join(errors))
        return

    # The Dược Phòng button starts the real async UI autosave. Join it before
    # this harness suppresses P3.1._exit_tree's synchronous save barrier.
    if not await _autosave_and_join_at_scene_boundary():
        return

    print("P3 O8 ALCHEMY FIELD-PILL-CONSUMER TEST PASS")
    _dispose_scene()
    await process_frame
    _cleanup_save()
    quit(0)

# Exercise the actual UI autosave path AND verify durability before
# releasing its scene-owned runtime. This is a test barrier, not a gameplay
# change or a relaxation of the timed-job/warehouse assertions.
func _autosave_and_join_at_scene_boundary() -> bool:
    if ui == null:
        return _fail("O8 cannot checkpoint a missing scene.")
    var live := ui.get("runtime_session") as LiveGameRuntimeV2
    if live == null or live.owner == null:
        return _fail("O8 cannot checkpoint a missing live save owner.")

    # Let any autosave started by a UI button reach quiescence. The guard in
    # _autosave_runtime intentionally returns when another coroutine is active.
    var pending_frames := 0
    while bool(ui.get("runtime_poll_pending")) and pending_frames < 600:
        await process_frame
        pending_frames += 1
    if bool(ui.get("runtime_poll_pending")):
        return _fail("O8 UI autosave coroutine did not finish at scene boundary.")
    if live.owner.saves.has_async_save_pending():
        var prior: Dictionary = await live.wait_for_pending_save(self)
        if not bool(prior.get("ok", false)):
            return _fail("O8 prior SaveService worker did not join: %s" % str(prior))

    # With the old autosave joined, request and await one snapshot of the
    # current state so manual scheduler steps are durable at this boundary.
    await ui.call("_autosave_runtime")
    if live.owner.saves.has_async_save_pending():
        var completed: Dictionary = await live.wait_for_pending_save(self)
        if not bool(completed.get("ok", false)):
            return _fail("O8 autosave worker did not commit: %s" % str(completed))
    if live.owner.saves.has_async_save_pending():
        return _fail("O8 scene has an unjoined SaveService worker.")

    var persisted := SaveService.new().load_from_path(SAVE_PATH)
    if persisted == null:
        return _fail("O8 save was not durably readable at scene boundary.")
    if persisted.tick != state.tick:
        return _fail("O8 autosave was stale at scene boundary.")
    var old_hall := buildings.primary_building(persisted, BuildingSystem.TYPE_ALCHEMY_HALL)
    var live_hall := buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if old_hall == null or live_hall == null:
        return _fail("O8 autosave lost Alchemy Hall at scene boundary.")
    var saved_jobs := buildings.alchemy_jobs(persisted, old_hall)
    var live_jobs := buildings.alchemy_jobs(state, live_hall)
    if saved_jobs.size() != live_jobs.size():
        return _fail("O8 autosave changed timed-job count at scene boundary.")
    # Check only authoritative persisted identity/finish fields: JSON can
    # restore equivalent values with different Variant representation.
    for i in range(live_jobs.size()):
        var recorded: Dictionary = saved_jobs[i]
        var active: Dictionary = live_jobs[i]
        if str(recorded.get("job_id", "")) != str(active.get("job_id", "")) \
                or int(recorded.get("finish_tick", -1)) != int(active.get("finish_tick", -2)) \
                or str(recorded.get("worker_id", "")) != str(active.get("worker_id", "")):
            return _fail("O8 autosave changed timed-job identity at scene boundary.")
    if warehouse.quantity(persisted, &"thanh_linh_thao") != warehouse.quantity(state, &"thanh_linh_thao"):
        return _fail("O8 autosave changed herb stock at scene boundary.")
    return true

func _first_unassigned() -> StringName:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id == &"sect" and disciple.work_group_id == &"":
            return disciple.id
    return &""

func _press(node_name: String) -> bool:
    var button := ui.find_child(node_name, true, false) as Button
    if button == null:
        return _fail("O8 missing player-facing button %s." % node_name)
    if button.disabled:
        return _fail("O8 required button is disabled: %s." % node_name)
    button.emit_signal("pressed")
    await process_frame
    return true

func _open_building(destination: StringName) -> bool:
    var hit := ui.find_child("BuildingHit_%s" % str(destination), true, false) as Button
    if hit == null:
        return _fail("O8 missing map hit target %s." % str(destination))
    hit.emit_signal("pressed")
    await process_frame
    if StringName(ui.get("selected_building")) != destination:
        return _fail("O8 map did not open %s." % str(destination))
    return true

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O8 could not load P3.2 main scene.")
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if state == null or runtime == null:
        return _fail("O8 main scene returned no live runtime.")
    scheduler = runtime.scheduler()
    _stop_timers(ui)
    return scheduler != null

func _dispose_scene() -> void:
    if ui == null:
        return
    ui.set("runtime_ready", false)
    ui.queue_free()
    ui = null
    state = null
    scheduler = null

func _stop_timers(node: Node) -> void:
    if node is Timer:
        (node as Timer).stop()
    for child in node.get_children():
        _stop_timers(child)

func _cleanup_save() -> void:
    for suffix in ["", ".tmp", ".bak"]:
        var path: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> bool:
    push_error(message)
    _dispose_scene()
    _cleanup_save()
    quit(1)
    return false
