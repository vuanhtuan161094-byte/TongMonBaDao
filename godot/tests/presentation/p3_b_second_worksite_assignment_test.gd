extends SceneTree

# Gate B: actual player selection of paid Mine/Forest annexes and persisted
# workforce slot routing. Uses only New Game funds and the canonical producers.
const SAVE_PATH := "user://p3_b_second_worksite_assignment_test.json"

var ui: Control
var state: SimulationState
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("Live P3.2 scene missing.")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not bool(ui.get("runtime_ready")):
        _fail("Fresh canonical runtime missing.")
        return
    _stop_timers(ui)
    if not state.sect.economy_a_enabled:
        _fail("New Game production Economy-A not enabled.")
        return

    var first_mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var first_forest := buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    if first_mine == null or first_forest == null:
        _fail("Original producer buildings missing.")
        return
    var mine_workers := buildings.active_worker_ids(state, first_mine)
    if mine_workers.is_empty():
        _fail("Starter Mine has no real workforce.")
        return
    var miner_id: StringName = mine_workers[0]
    # The six New Game founders remain P2 legacy actors. Their real production
    # uses TRAVEL/EXTRACT/HAUL, never the V2 Economy-A timer contract.
    if DiscipleRealmProgressV2.owns_v2_progression(state.disciples[miner_id]):
        _fail("Starter-worker contract changed; verify provenance before timer test.")
        return
    # Hold all founders through canonical commands so AI cannot create
    # unrelated ore/XP during the new V2 recruit's exact-once timer test.
    for raw_id in state.disciples.keys():
        if not workforce.issue_command(state, StringName(raw_id), WorkforceSystem.COMMAND_HOLD, "", 2000):
            _fail("Could not isolate founding worker through real HOLD command.")
            return
    var funds_before := state.sect.spirit_stones
    var wood_before := warehouse.quantity(state, &"linh_moc")
    var ore_before := warehouse.quantity(state, &"thanh_thiet")

    var mine_preview := buildings.preview_production_annex(state, BuildingSystem.TYPE_MINE)
    if not bool(mine_preview.get("ok",false)):
        _fail("Cannot afford genuine second Mine: " + str(mine_preview))
        return
    var mine_cost: Dictionary = mine_preview["cost"]
    var mine_built := buildings.build_paid_production_annex(state, BuildingSystem.TYPE_MINE, "qa:b:mine:2")
    if not bool(mine_built.get("ok",false)):
        _fail("Real Mine annex purchase rejected: " + str(mine_built))
        return
    var mine_id := StringName(mine_built.get("building_id",""))
    var mine_two: BuildingState = state.buildings.get(str(mine_id)) as BuildingState
    if mine_two == null or mine_two.id == first_mine.id or (
        state.sect.spirit_stones != funds_before - int(mine_cost.get("spirit_stones",0))
        or warehouse.quantity(state,&"linh_moc") != wood_before - int(mine_cost.get("linh_moc",0))
        or warehouse.quantity(state,&"thanh_thiet") != ore_before - int(mine_cost.get("thanh_thiet",0))
    ):
        _fail("Paid Mine annex did not debit exact authoritative cost.")
        return

    ui.call("_open_building", SectMapPresentation.DEST_MINE, mine_id)
    await process_frame
    if StringName(ui.get("selected_production_instance_id")) != mine_id:
        _fail("Player Mine panel did not select the paid instance.")
        return
    var mine_picker := ui.find_child("MineWorksite_%s" % str(miner_id),true,false) as Button
    var mine_upgrade := ui.find_child("Upgrade_mine",true,false) as Button
    if mine_picker == null or mine_picker.disabled or mine_upgrade == null:
        _fail("Mine annex has no live worker/upgrade controls.")
        return
    mine_picker.pressed.emit()
    await process_frame
    await process_frame
    if (state.disciples[miner_id] as DiscipleState).worksite_building_id != mine_id or (
        not buildings.active_worker_ids(state,mine_two).has(miner_id)
        or buildings.active_worker_ids(state,first_mine).has(miner_id)
    ):
        _fail("Mine site selection did not move the actual worker slot.")
        return
    # A true timed job requires an authentic recruited V2 disciple, not a P2
    # founder. Use the live Dẫn Tiên player flow and expend a real recruitment
    # token; no test money, resource or XP is provisioned.
    var recruit_id: StringName = await _recruit_authentic_v2()
    if recruit_id == &"":
        return
    miner_id = recruit_id
    ui.call("_open_building", SectMapPresentation.DEST_MINE, mine_id)
    await process_frame
    var recruit_group := ui.find_child("Group_mining_crew_%s" % str(miner_id),true,false) as Button
    if recruit_group == null or recruit_group.disabled:
        _fail("Second Mine cannot assign genuine V2 recruit to mining crew.")
        return
    recruit_group.pressed.emit()
    await process_frame
    await process_frame
    var recruit_site := ui.find_child("MineWorksite_%s" % str(miner_id),true,false) as Button
    if recruit_site == null or recruit_site.disabled:
        _fail("Second Mine cannot select worksite for genuine V2 recruit.")
        return
    recruit_site.pressed.emit()
    await process_frame
    await process_frame
    var actor: DiscipleState = state.disciples[miner_id]
    if not DiscipleRealmProgressV2.owns_v2_progression(actor) or (
        actor.worksite_building_id != mine_id
        or not buildings.active_worker_ids(state,mine_two).has(miner_id)
    ):
        _fail("V2 identity/worksite not authentic at second Mine.")
        return
    var mining := ui.find_child("Work_mining_%s" % str(miner_id),true,false) as Button
    if mining == null or mining.disabled:
        _fail("Mine annex selected V2 worker cannot receive real Mine command.")
        return
    var xp_before := float(actor.profession_xp.get("mining",0.0))
    var stock_before := warehouse.quantity(state,&"thanh_thiet")
    mining.pressed.emit()
    await process_frame
    var scheduler := (ui.get("runtime_session") as LiveGameRuntimeV2).scheduler()
    var job: Dictionary = {}
    for _n in range(12):
        scheduler.step()
        job = buildings.active_resource_timer_for_worker(state,miner_id)
        if not job.is_empty():
            break
    if job.is_empty() or not buildings.resource_timer_jobs(mine_two).has(job) or (
        str(job.get("worker_id","")) != str(miner_id)
        or str(job.get("resource_id","")) != "thanh_thiet"
        or int(job.get("output_quantity",0)) <= 0
        or int(job.get("finish_tick",0)) <= state.tick
        or warehouse.quantity(state,&"thanh_thiet") != stock_before
        or not is_equal_approx(float(actor.profession_xp.get("mining",0.0)),xp_before)
    ):
        _fail("Real V2 second-Mine timer incorrectly started/credited: job=%s tick=%d stock=%d xp=%.2f" % [
            str(job),state.tick,warehouse.quantity(state,&"thanh_thiet"),float(actor.profession_xp.get("mining",0.0))
        ])
        return

    var forest_preview := buildings.preview_production_annex(state, BuildingSystem.TYPE_LINH_FOREST)
    if not bool(forest_preview.get("ok",false)):
        _fail("Cannot afford genuine second Forest: " + str(forest_preview))
        return
    var forest_built := buildings.build_paid_production_annex(state,BuildingSystem.TYPE_LINH_FOREST,"qa:b:forest:2")
    if not bool(forest_built.get("ok",false)):
        _fail("Real Forest annex purchase rejected: " + str(forest_built))
        return
    var forest_id := StringName(forest_built.get("building_id",""))
    var forest_two: BuildingState = state.buildings.get(str(forest_id)) as BuildingState
    if forest_two == null or forest_two.id == first_forest.id:
        _fail("Forest annex did not create a distinct real BuildingState.")
        return
    var forester_id: StringName = &""
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var next_id := StringName(raw_id)
        if next_id == miner_id:
            continue
        var member: DiscipleState = state.disciples[next_id]
        if member.work_group_id != &"mining_crew" and member.active_pve_encounter_id.is_empty():
            forester_id = next_id
            break
    if forester_id == &"":
        _fail("No real non-mining disciple for the Forest annex.")
        return
    ui.call("_open_building",SectMapPresentation.DEST_LINH_FOREST,forest_id)
    await process_frame
    var group_button := ui.find_child("Group_forestry_crew_%s" % str(forester_id),true,false) as Button
    if group_button == null or group_button.disabled:
        _fail("Forest annex has no real workforce group control.")
        return
    group_button.pressed.emit()
    await process_frame
    await process_frame
    var forest_picker := ui.find_child("ForestWorksite_%s" % str(forester_id),true,false) as Button
    if forest_picker == null or forest_picker.disabled:
        _fail("Forest annex has no enabled per-instance worksite control.")
        return
    forest_picker.pressed.emit()
    await process_frame
    await process_frame
    var assigned: DiscipleState = state.disciples[forester_id]
    if assigned.worksite_building_id != forest_id or (
        not buildings.active_worker_ids(state,forest_two).has(forester_id)
        or buildings.active_worker_ids(state,first_forest).has(forester_id)
    ):
        _fail("Forest worksite button did not transfer actual worker ownership.")
        return
    var forestry := ui.find_child("Work_forestry_%s" % str(forester_id),true,false) as Button
    if forestry == null or forestry.disabled:
        _fail("Player cannot order production at selected Forest annex.")
        return

    if SaveService.new().save_to_path(state,SAVE_PATH) != OK:
        _fail("Canonical second-worksite SaveService failed.")
        return
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if loaded == null or not loaded.disciples.has(miner_id) or not loaded.disciples.has(forester_id):
        _fail("Second-worksite cold Save/Load rejected.")
        return
    var loaded_mine: BuildingState = loaded.buildings.get(str(mine_id)) as BuildingState
    var loaded_forest: BuildingState = loaded.buildings.get(str(forest_id)) as BuildingState
    if loaded_mine == null or loaded_forest == null or (
        (loaded.disciples[miner_id] as DiscipleState).worksite_building_id != mine_id
        or (loaded.disciples[forester_id] as DiscipleState).worksite_building_id != forest_id
        or not buildings.active_worker_ids(loaded,loaded_mine).has(miner_id)
        or not buildings.active_worker_ids(loaded,loaded_forest).has(forester_id)
    ):
        _fail("Cold Save/Load lost canonical worker ownership of paid annexes.")
        return

    # Simulate completion against the loaded state, not the original scene's
    # transient ledger. No duplicate/premature credit is allowed on a resumed
    # timer, and profession XP must increase only when the same goods settle.
    var resumed_job := buildings.active_resource_timer_for_worker(loaded, miner_id)
    if resumed_job.is_empty() or str(resumed_job.get("job_id","")) != str(job.get("job_id","")):
        _fail("Save/Load lost the exact V2 second-Mine job ID.")
        return
    var saved_xp := float((loaded.disciples[miner_id] as DiscipleState).profession_xp.get("mining",0.0))
    var saved_ore := warehouse.quantity(loaded, &"thanh_thiet")
    var output := int(job.get("output_quantity",0))
    var loaded_scheduler := SimulationScheduler.new(loaded)
    var pending_ticks := maxi(0,int(job.get("finish_tick",0))-loaded.tick)
    if pending_ticks <= 0 or pending_ticks > 100:
        _fail("Persisted second-Mine finish tick is inconsistent.")
        return
    loaded_scheduler.run_ticks(pending_ticks)
    if warehouse.quantity(loaded,&"thanh_thiet") != saved_ore+output or (
        float((loaded.disciples[miner_id] as DiscipleState).profession_xp.get("mining",0.0)) <= saved_xp
        or not buildings.active_resource_timer_for_worker(loaded,miner_id).is_empty()
    ):
        _fail("Resumed Mine timer did not pay exact ore and profession XP once.")
        return
    loaded_scheduler.step()
    if warehouse.quantity(loaded,&"thanh_thiet") != saved_ore+output:
        _fail("Resumed Mine job duplicated ore after completion.")
        return
    ui.queue_free()
    await process_frame
    _cleanup()
    print("GATE B PAID MULTI-SITE MINE/FOREST WORKER + V2 TIMER/XP/WAREHOUSE/SAVE: PASS")
    quit(0)

func _recruit_authentic_v2() -> StringName:
    var hit := ui.find_child("BuildingHit_guidance",true,false) as Button
    if hit == null:
        _fail("Real Dẫn Tiên map entrance missing.")
        return &""
    hit.pressed.emit()
    await process_frame
    var launch := ui.find_child("OpenDanTienScreenV2",true,false) as Button
    if launch == null or launch.disabled:
        _fail("Dẫn Tiên V2 screen cannot open.")
        return &""
    launch.pressed.emit()
    await process_frame
    var token_before := state.sect.disciple_recruitment_tokens
    var order := ui.find_child("UseRecruitmentOrder",true,false) as Button
    if order == null or order.disabled:
        _fail("No real recruitment order is available.")
        return &""
    order.pressed.emit()
    await process_frame
    if state.sect.disciple_recruitment_tokens != token_before-1:
        _fail("Recruitment did not consume one real order.")
        return &""
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    var candidate_id: StringName = &""
    for raw_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            candidate_id = StringName(raw_id)
            break
    if candidate_id == &"":
        _fail("Guidance produced no authentic V2 candidate.")
        return &""
    var candidate: CandidateState = state.recruitment_candidates[candidate_id]
    var birth := candidate.v2_birth_profile.duplicate(true)
    var b1 := ui.get_node_or_null("DanTienScreenV2/TriFacilityB1LiveAdapterV1") as Control
    if b1 == null:
        _fail("Real B1 recruitment screen missing.")
        return &""
    var search := b1.find_child("CandidateSearch",true,false) as LineEdit
    if search == null:
        _fail("Real B1 recruitment search missing.")
        return &""
    search.text = candidate.display_name
    search.text_submitted.emit(search.text)
    await process_frame
    var pick := b1.find_child("CandidatePick_%s" % str(candidate_id),true,false) as Button
    if pick == null:
        _fail("Real B1 recruitment candidate button missing.")
        return &""
    if not pick.disabled:
        pick.pressed.emit()
        await process_frame
    else:
        var host := ui.get_node_or_null("DanTienScreenV2")
        if host == null or StringName(host.get("selected_candidate_id")) != candidate_id:
            _fail("B1 disabled candidate row was not selected.")
            return &""
    var accept := b1.find_child("AcceptCandidate",true,false) as Button
    if accept == null or accept.disabled:
        _fail("Real B1 admission control unavailable.")
        return &""
    accept.pressed.emit()
    await process_frame
    accept = b1.find_child("AcceptCandidate",true,false) as Button
    if accept == null or not accept.text.contains("XÁC NHẬN"):
        _fail("Real B1 second-confirmation control missing.")
        return &""
    accept.pressed.emit()
    await process_frame
    var recruited: DiscipleState = state.disciples.get(candidate_id)
    if recruited == null or not DiscipleRealmProgressV2.owns_v2_progression(recruited) or recruited.v2_birth_profile != birth:
        _fail("Admission did not preserve authentic V2 birth identity.")
        return &""
    return candidate_id

func _stop_timers(node: Node) -> void:
    if node is Timer:
        (node as Timer).stop()
    for child in node.get_children():
        _stop_timers(child)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)

func _fail(message: String) -> void:
    push_error("GATE B MULTI-SITE: " + message)
    if ui != null and is_instance_valid(ui):
        ui.queue_free()
    _cleanup()
    quit(1)
