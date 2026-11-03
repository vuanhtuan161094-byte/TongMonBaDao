extends SceneTree

# O6 M1 release rehearsal:
# one fresh P3.2 session -> real recruitment -> live actor -> concurrent Mine +
# Spirit Field -> canonical Warehouse -> real Forge craft -> authored Mine upgrade
# -> save/restart with active production -> autonomous continuation.
const SAVE_PATH := "user://p3_o6_m1_release_rehearsal_test.json"
const RECIPE_ID := &"thanh_thiet_kiem"

var ui: Control
var state: SimulationState
var scheduler: SimulationScheduler
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()
var equipment := EquipmentSystem.new()
var crops := SpiritCropRegistry.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _cleanup_save():
        _fail("O6 could not clear its isolated main/tmp/backup save files.")
        return
    ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
    if not await _open_scene():
        return

    # Fresh opening truth.
    if state.disciples.size() != 6 or state.sect.disciple_capacity != 8:
        _fail("O6 fresh opening must start with the verified 6/8 roster.")
        return
    if state.sect.spirit_stones != 500:
        _fail("O6 fresh opening must use the existing 500 Sect Spirit Stones.")
        return
    var starter_iron := warehouse.quantity(state, &"thanh_thiet")
    var starter_wood := warehouse.quantity(state, &"linh_moc")
    var starter_items := state.sect.equipment_items.size()
    if starter_iron < 40 or starter_wood < 40:
        _fail("O6 fresh canonical starter Warehouse baseline is missing.")
        return

    # --- Recruitment through the real map hit target and B1 Dẫn Tiên surface.
    if not await _open_building_hit(SectMapPresentation.DEST_GUIDANCE):
        return
    if not await _press("OpenDanTienScreenV2"):
        return
    await process_frame
    var tokens_before := state.sect.disciple_recruitment_tokens
    if not await _press("UseRecruitmentOrder"):
        return
    if state.sect.disciple_recruitment_tokens != tokens_before - 1:
        _fail("O6 Guidance order did not debit exactly one recruitment token.")
        return

    var recruitable := _recruitable_candidate_ids()
    if recruitable.is_empty():
        _fail("O6 real Guidance order produced no authentic V2 candidate.")
        return
    var recruit_id := StringName(recruitable[0])
    if not await _select_and_accept_candidate_via_b1(recruit_id):
        return
    if state.disciples.size() != 7 or not state.disciples.has(recruit_id):
        _fail("O6 Accept did not add exactly one canonical recruit.")
        return
    # Actors are viewport-selected. Use the player's actual reveal action to
    # focus the new disciple before asserting that its Source A actor exists.
    if not await _press("RecruitedDiscipleWorld"):
        return
    await process_frame
    await process_frame
    ui.call("_refresh_all")
    await process_frame
    var actors: Dictionary = ui.get("actor_nodes")
    if not actors.has(str(recruit_id)):
        _fail("O6 map-focus action did not materialize the selected recruit in the viewport.")
        return
    if ui.find_children("ModularDisciple_%s" % str(recruit_id), "", true, false).size() != 1:
        _fail("O6 accepted recruit produced duplicate/missing modular actors.")
        return
    if StringName(ui.get("selected_id")) != recruit_id:
        _fail("O6 TỚI NHÂN VẬT did not select the recruited actor.")
        return

    # Assign the recruited disciple to the real Spirit Field via UI.
    if not await _open_building_hit(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if not await _press("FieldGroup_%s" % str(recruit_id)):
        return
    var field_worker: DiscipleState = state.disciples[recruit_id]
    if field_worker.work_group_id != &"herbalism_crew":
        _fail("O6 recruit is not assignable to Đội Linh Thực.")
        return
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null or not buildings.active_worker_ids(state, field).has(recruit_id):
        _fail("O6 recruited field worker owns no authoritative Field slot.")
        return

    # Select the real Mine worker, then hold all disciples while any opening
    # encounter loot, inventory deposit, timer or legacy carry is settled.
    # These are valid rewards and must remain in Warehouse, but they are not
    # output from the two explicit Mine receipts verified below.
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if mine == null:
        _fail("O6 live state has no authoritative Mine.")
        return
    var miners := buildings.active_worker_ids(state, mine)
    if miners.is_empty():
        _fail("O6 fresh Mine has no active worker.")
        return
    var miner_id := StringName(miners[0])
    for raw_id in state.disciples.keys():
        var id := StringName(raw_id)
        if not workforce.issue_command(state, id, WorkforceSystem.COMMAND_HOLD, "", 1200):
            _fail("O6 could not hold disciple %s while settling opening rewards." % str(id))
            return
    var opening_activity_settled := false
    for _i in range(240):
        if _opening_economy_is_settled():
            opening_activity_settled = true
            break
        scheduler.step()
        ui.call("_refresh_all")
    if not opening_activity_settled and not _opening_economy_is_settled():
        _fail("O6 opening encounters, inventory, or carried work did not settle before the Mine receipt baseline.")
        return

    # QA provenance boundary: reserve all canonical ore after valid opening
    # rewards/carries have settled. Only the explicit Mine batches below are
    # spendable in this conservation proof; the reward itself remains intact.
    var production_floor_iron := warehouse.quantity(state, &"thanh_thiet")
    if production_floor_iron < starter_iron:
        _fail("O6 opening settlement lost canonical starter Thanh Thiết.")
        return
    if not warehouse.set_rule(state, &"thanh_thiet", production_floor_iron, false):
        _fail("O6 could not reserve the isolated Warehouse baseline for conservation proof.")
        return

    # Start one real Field plot while Mine production also proceeds.
    if not await _open_building_hit(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if not await _press("FieldPlant_%s" % str(recruit_id)):
        return
    var field_batches_before := int(field.metrics.get("production_batches", 0))
    var first_plot := {}
    for _i in range(12):
        scheduler.step()
        ui.call("_refresh_all")
        first_plot = _plot_for_worker(field, recruit_id)
        if not first_plot.is_empty():
            break
    if first_plot.is_empty():
        _fail("O6 Field command never created a canonical paid plot.")
        return
    var first_crop_id := StringName(first_plot.get("crop_id", ""))
    var first_output_id := crops.output_resource_id(first_crop_id)
    var first_output_before := warehouse.quantity(state, first_output_id)

    # Two actual Mine batches create four spendable ore. Keep the miner on HOLD
    # between explicit batches so provenance remains exact.
    for ordinal in range(1, 3):
        if not await _mine_one_explicit_batch(miner_id, mine, ordinal):
            return

    # Ensure the first paid Field plot has really harvested, then withdraw that
    # worker before another autonomous crop starts so the upgrade debit can be
    # checked without concurrent Stone spending.
    var first_field_harvested := int(field.metrics.get("production_batches", 0)) > field_batches_before
    for _i in range(40):
        if first_field_harvested:
            break
        scheduler.step()
        ui.call("_refresh_all")
        first_field_harvested = int(field.metrics.get("production_batches", 0)) > field_batches_before
    if not first_field_harvested:
        _fail("O6 first real Spirit Field plot never harvested.")
        return
    if warehouse.quantity(state, first_output_id) <= first_output_before:
        _fail("O6 first Field harvest did not enter canonical Warehouse.")
        return
    # The herbalism group may already have autonomously started the next
    # legitimate plot while the Mine batches were advancing. If so, let that
    # currently owned plot finish and withdraw on its exact release tick.
    if buildings.disciple_has_active_spirit_plot(state, recruit_id, field):
        var active_batches := int(field.metrics.get("production_batches", 0))
        for _i in range(40):
            scheduler.step()
            ui.call("_refresh_all")
            if int(field.metrics.get("production_batches", 0)) > active_batches:
                break
        if buildings.disciple_has_active_spirit_plot(state, recruit_id, field):
            _fail("O6 could not reach a legitimate Field release point before isolation.")
            return

    if not await _open_building_hit(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if not await _press("FieldGroup_%s" % str(recruit_id)):
        return
    if field_worker.work_group_id != &"":
        _fail("O6 could not withdraw field worker after harvest.")
        return
    if not workforce.issue_command(state, recruit_id, WorkforceSystem.COMMAND_HOLD, "", 500):
        _fail("O6 could not hold released field worker.")
        return

    # Real produced ore -> real player Forge craft.
    if warehouse.available_quantity(state, &"thanh_thiet") != 4:
        _fail("O6 two isolated Mine batches must leave exactly four produced ore spendable.")
        return
    if not await _open_building_hit(SectMapPresentation.DEST_FORGE):
        return
    var craft := ui.find_child("Craft_%s" % str(RECIPE_ID), true, false) as Button
    if craft == null or craft.disabled:
        _fail("O6 produced ore did not enable the real Forge recipe.")
        return
    var iron_before_craft := warehouse.quantity(state, &"thanh_thiet")
    var wood_before_craft := warehouse.quantity(state, &"linh_moc")
    craft.emit_signal("pressed")
    await process_frame
    if warehouse.quantity(state, &"thanh_thiet") != iron_before_craft - 3:
        _fail("O6 Forge did not consume exactly 3 produced Thanh Thiết.")
        return
    if warehouse.quantity(state, &"linh_moc") != wood_before_craft - 1:
        _fail("O6 Forge did not consume exactly 1 Linh Mộc.")
        return
    if state.sect.equipment_items.size() != starter_items + 1:
        _fail("O6 Forge did not create exactly one equipment item.")
        return

    var crafted_id := &""
    for raw_item_id in state.sect.equipment_items.keys():
        var item: Dictionary = state.sect.equipment_items[raw_item_id]
        if str(item.get("recipe_id", "")) == str(RECIPE_ID) and StringName(item.get("location", "")) == EquipmentSystem.LOCATION_STORAGE:
            crafted_id = StringName(raw_item_id)
    if crafted_id == &"":
        _fail("O6 crafted Thanh Thiết Kiếm is not in Sect storage.")
        return

    # Three more real Mine batches produce the seven spendable ore required by
    # the already-authored Mine Lv1->2 upgrade.
    for ordinal in range(3, 6):
        if not await _mine_one_explicit_batch(miner_id, mine, ordinal):
            return
    if warehouse.available_quantity(state, &"thanh_thiet") != 7:
        _fail("O6 five Mine batches minus craft must leave exactly seven produced ore.")
        return

    if not await _open_building_hit(SectMapPresentation.DEST_MINE):
        return
    var upgrade := ui.find_child("Upgrade_mine", true, false) as Button
    if upgrade == null or upgrade.disabled:
        _fail("O6 authored Mine Lv1->2 upgrade is not available after legitimate production.")
        return
    var upgrade_cost := buildings.upgrade_cost(mine)
    var ore_need := int(upgrade_cost.get(BuildingSystem.MATERIAL_ORE, 0))
    var wood_need := int(upgrade_cost.get(BuildingSystem.MATERIAL_WOOD, 0))
    var stone_need := int(upgrade_cost.get("spirit_stones", 0))
    var iron_before_upgrade := warehouse.quantity(state, &"thanh_thiet")
    var wood_before_upgrade := warehouse.quantity(state, &"linh_moc")
    var stones_before_upgrade := state.sect.spirit_stones
    upgrade.emit_signal("pressed")
    await process_frame
    if not mine.is_upgrading():
        _fail("O6 Mine upgrade UI did not start authoritative timed upgrade.")
        return
    if warehouse.quantity(state, &"thanh_thiet") != iron_before_upgrade - ore_need:
        _fail("O6 Mine upgrade iron debit is not exact.")
        return
    if warehouse.quantity(state, &"linh_moc") != wood_before_upgrade - wood_need:
        _fail("O6 Mine upgrade wood debit is not exact.")
        return
    if state.sect.spirit_stones != stones_before_upgrade - stone_need:
        _fail("O6 Mine upgrade Stone debit is not exact.")
        return
    if warehouse.quantity(state, &"thanh_thiet") != production_floor_iron:
        _fail("O6 produce/spend conservation did not return iron to the isolated opening reserve.")
        return

    # Keep both economic actors at sect while upgrade completes.
    if not workforce.issue_command(state, miner_id, WorkforceSystem.COMMAND_HOLD, "", 80):
        _fail("O6 could not hold miner during Mine upgrade.")
        return
    var upgrade_completed := false
    for _i in range(40):
        scheduler.step()
        if mine.level == 2 and not mine.is_upgrading():
            upgrade_completed = true
            break
    if not upgrade_completed:
        _fail("O6 authored Mine upgrade did not complete by scheduler.")
        return

    # --- Prepare an active save/restart boundary.
    # Release HOLD and re-arm both real producers from player-facing controls.
    if not await _open_building_hit(SectMapPresentation.DEST_SPIRIT_FIELD):
        return
    if field_worker.work_group_id != &"herbalism_crew":
        if not await _press("FieldGroup_%s" % str(recruit_id)):
            return
    if not await _press("FieldPlant_%s" % str(recruit_id)):
        return
    var active_plot := {}
    for _i in range(12):
        scheduler.step()
        ui.call("_refresh_all")
        active_plot = _plot_for_worker(field, recruit_id)
        if not active_plot.is_empty():
            break
    if active_plot.is_empty():
        _fail("O6 could not create active Field work before restart.")
        return

    # Replace the miner's HOLD with a real queued Mine command, but save before
    # scheduler advances it. Restart must continue this exact command.
    if not await _open_building_hit(SectMapPresentation.DEST_MINE):
        return
    var mine_button := ui.find_child("Work_mining_%s" % str(miner_id), true, false) as Button
    if mine_button == null or mine_button.disabled:
        _fail("O6 upgraded Mine has no valid real work command.")
        return
    mine_button.emit_signal("pressed")
    await process_frame
    var miner: DiscipleState = state.disciples[miner_id]
    if workforce.command_kind(miner) != WorkforceSystem.COMMAND_WORK:
        _fail("O6 queued Mine command was not canonical before restart.")
        return

    # This rehearsal advances the scheduler directly. Re-anchor the wall clock
    # after that accelerated setup so SaveService cannot count the test's own
    # execution time a second time as offline simulation.
    state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
    # Await the canonical async-save barrier before scene teardown; Object.call does not await coroutines.
    var autosave_result: Dictionary = await ui.call("_save_runtime_async_barrier")
    if not bool(autosave_result.get("ok",false)):
        _fail("O6 canonical async SaveService barrier failed before restart.")
        return
    if not FileAccess.file_exists(SAVE_PATH):
        _fail("O6 active runtime save was not written.")
        return
    # Compare against the state actually committed by the save barrier, not an
    # earlier tick that may legitimately advance during persistence.
    var saved_tick := state.tick
    var saved_roster := state.disciples.size()
    var saved_iron := warehouse.quantity(state, &"thanh_thiet")
    var saved_wood := warehouse.quantity(state, &"linh_moc")
    var saved_stones := state.sect.spirit_stones
    var saved_items := state.sect.equipment_items.size()
    active_plot = _plot_for_worker(field,recruit_id)
    if active_plot.is_empty():
        _fail("O6 active Field plot settled before the restart snapshot.")
        return
    var saved_finish_tick := int(active_plot.get("finish_tick", -1))
    var saved_crop_id := StringName(active_plot.get("crop_id", ""))
    var saved_field_output := crops.output_resource_id(saved_crop_id)
    var saved_field_output_qty := warehouse.quantity(state, saved_field_output)
    var mine_batches_at_save := int(mine.metrics.get("production_batches", 0))
    var field_batches_at_save := int(field.metrics.get("production_batches", 0))
    _dispose_scene()
    await process_frame
    if not await _open_scene():
        return

    # Exact restart restoration: roster/actor/assignment/plot/queued work/
    # stock/item/building all survive without duplicate or replay.
    if state.tick != saved_tick:
        _fail("O6 restart changed simulation tick before continuation.")
        return
    if state.disciples.size() != saved_roster or not state.disciples.has(recruit_id):
        _fail("O6 restart lost/duplicated recruited disciple.")
        return
    # Virtual actors materialize only when selected and inside the viewport. Re-focus the restored disciple via the map action before asserting a single actor.
    ui.call("_open_disciple",recruit_id)
    await process_frame
    ui.call("_refresh_all")
    await process_frame
    actors = ui.get("actor_nodes")
    if not actors.has(str(recruit_id)) or ui.find_children("ModularDisciple_%s" % str(recruit_id), "", true, false).size() != 1:
        _fail("O6 focus action did not materialize exactly one restored recruit actor in the viewport.")
        return

    mine = buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    miner = state.disciples[miner_id]
    field_worker = state.disciples[recruit_id]
    if mine == null or mine.level != 2 or mine.is_upgrading():
        _fail("O6 restart lost completed Mine Lv2.")
        return
    if field_worker.work_group_id != &"herbalism_crew":
        _fail("O6 restart lost recruited Field assignment.")
        return
    active_plot = _plot_for_worker(field, recruit_id)
    if active_plot.is_empty() or int(active_plot.get("finish_tick", -2)) != saved_finish_tick or StringName(active_plot.get("crop_id", "")) != saved_crop_id:
        _fail("O6 restart lost/restarted active Spirit Field plot.")
        return
    if workforce.command_kind(miner) != WorkforceSystem.COMMAND_WORK or workforce.command_target(miner) != WorkforceSystem.PROF_MINING:
        _fail("O6 restart lost queued canonical Mine command.")
        return
    if (
        warehouse.quantity(state, &"thanh_thiet") != saved_iron
        or warehouse.quantity(state, &"linh_moc") != saved_wood
        or state.sect.spirit_stones != saved_stones
        or state.sect.equipment_items.size() != saved_items
        or not state.sect.equipment_items.has(str(crafted_id))
    ):
        _fail("O6 restart changed stock/currency/item before continuation.")
        return

    # No UI action after this point. The restored Field plot and queued Mine
    # command must finish, then group scheduling must autonomously start further
    # production for both workers.
    var resumed_mine := false
    var resumed_field := false
    for _i in range(100):
        scheduler.step()
        if int(mine.metrics.get("production_batches", 0)) > mine_batches_at_save:
            resumed_mine = true
        if int(field.metrics.get("production_batches", 0)) > field_batches_at_save:
            resumed_field = true
        if resumed_mine and resumed_field:
            break
    if not resumed_mine:
        _fail("O6 restart did not continue queued Mine production.")
        return
    if not resumed_field or warehouse.quantity(state, saved_field_output) <= saved_field_output_qty:
        _fail("O6 restart did not continue active Spirit Field production.")
        return

    var mine_batches_after_resume := int(mine.metrics.get("production_batches", 0))
    var field_batches_after_resume := int(field.metrics.get("production_batches", 0))
    var autonomous_mine := false
    var autonomous_field := false
    for _i in range(240):
        scheduler.step()
        if int(mine.metrics.get("production_batches", 0)) > mine_batches_after_resume:
            autonomous_mine = true
        if int(field.metrics.get("production_batches", 0)) > field_batches_after_resume:
            autonomous_field = true
        if autonomous_mine and autonomous_field:
            break
    if not autonomous_mine:
        _fail("O6 mining group did not autonomously continue after resumed direct work completed.")
        return
    if not autonomous_field:
        _fail("O6 herbalism group did not autonomously continue after resumed plot harvested.")
        return

    # Final player-facing projections must agree with canonical Warehouse.
    ui.call("_refresh_all")
    var iron_final := warehouse.quantity(state, &"thanh_thiet")
    var iron_usable := warehouse.available_quantity(state, &"thanh_thiet")
    if not str(ui.call("_mine_operation_text")).contains("Thanh Thiết tồn (dùng): %d (dùng %d)" % [iron_final, iron_usable]):
        _fail("O6 final Mine panel disagrees with canonical Warehouse.")
        return
    if not str(ui.call("_warehouse_operation_text")).contains("Thanh Thiết: %d (dùng %d)" % [iron_final, iron_usable]):
        _fail("O6 final Warehouse panel disagrees with canonical stock.")
        return

    var errors := state.validate_invariants()
    errors.append_array(BuildingSystem.new().validate_invariants(state))
    errors.append_array(WarehouseSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    if not errors.is_empty():
        _fail("O6 final M1 state violates invariants: %s" % " | ".join(errors))
        return

    _dispose_scene()
    await process_frame
    if not _cleanup_save():
        push_error("O6 could not remove its isolated save artifacts after PASS.")
        quit(2)
        return
    print("P3 O6 M1 END-TO-END RELEASE REHEARSAL PASS")
    quit(0)

func _mine_one_explicit_batch(miner_id: StringName, mine: BuildingState, ordinal: int) -> bool:
    if not await _open_building_hit(SectMapPresentation.DEST_MINE):
        return false
    var button := ui.find_child("Work_mining_%s" % str(miner_id), true, false) as Button
    if button == null or button.disabled:
        return _fail("O6 Mine batch %d has no enabled player work button." % ordinal)
    var before_batches := int(mine.metrics.get("production_batches", 0))
    var before_iron := warehouse.quantity(state, &"thanh_thiet")
    button.emit_signal("pressed")
    await process_frame

    for _i in range(60):
        scheduler.step()
        ui.call("_refresh_all")
        if int(mine.metrics.get("production_batches", 0)) > before_batches:
            break
    if int(mine.metrics.get("production_batches", 0)) != before_batches + 1:
        return _fail("O6 Mine batch %d did not complete exactly once." % ordinal)
    if warehouse.quantity(state, &"thanh_thiet") <= before_iron:
        return _fail("O6 Mine batch %d produced no canonical ore." % ordinal)
    if not workforce.issue_command(state, miner_id, WorkforceSystem.COMMAND_HOLD, "", 1000):
        return _fail("O6 could not hold miner after explicit batch %d." % ordinal)
    return true

func _opening_economy_is_settled() -> bool:
    for raw_id in state.disciples.keys():
        var disciple: DiscipleState = state.disciples[raw_id]
        if (
            not disciple.active_pve_encounter_id.is_empty()
            or disciple.region_id != &"sect"
            or not disciple.pending_loot.is_empty()
            or not disciple.inventory.is_empty()
            or not disciple.work_cycle_state.is_empty()
            or not buildings.active_resource_timer_for_worker(state, disciple.id).is_empty()
        ):
            return false
    return true

func _recruitable_candidate_ids() -> Array:
    var result: Array = []
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    for raw_id in ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if not state.sect.disciple_v2_birth_enabled or DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            result.append(StringName(raw_id))
    return result

func _plot_for_worker(field: BuildingState, disciple_id: StringName) -> Dictionary:
    for raw_plot in buildings.spirit_field_plots(state, field):
        if (
            raw_plot is Dictionary
            and StringName(raw_plot.get("status", "")) == BuildingSystem.PLOT_GROWING
            and str(raw_plot.get("assigned_worker_id", "")) == str(disciple_id)
        ):
            return (raw_plot as Dictionary).duplicate(true)
    return {}

func _open_building_hit(destination: StringName) -> bool:
    var hit := ui.find_child("BuildingHit_%s" % str(destination), true, false) as Button
    if hit == null:
        return _fail("O6 missing map hit target for %s." % str(destination))
    hit.emit_signal("pressed")
    await process_frame
    if StringName(ui.get("selected_building")) != destination:
        return _fail("O6 map click did not open %s." % str(destination))
    return true

func _press(node_name: String) -> bool:
    var button := ui.find_child(node_name, true, false) as Button
    if button == null:
        return _fail("O6 missing player-facing button: %s" % node_name)
    if button.disabled:
        return _fail("O6 required button is disabled: %s" % node_name)
    button.emit_signal("pressed")
    await process_frame
    return true

func _select_and_accept_candidate_via_b1(candidate_id: StringName) -> bool:
    var candidate: CandidateState = state.recruitment_candidates.get(candidate_id)
    var search := ui.find_child("CandidateSearch",true,false) as LineEdit
    if candidate == null or search == null:
        return _fail("O6 B1 search/candidate control was missing.")
    search.text = candidate.display_name
    search.text_submitted.emit(search.text)
    await process_frame
    var pick := ui.find_child("CandidatePick_%s" % str(candidate_id),true,false) as Button
    if pick == null:
        return _fail("O6 B1 candidate picker did not expose the authentic candidate.")
    if not pick.disabled:
        pick.pressed.emit()
        await process_frame
    else:
        var host := ui.get_node_or_null("DanTienScreenV2")
        if host == null or StringName(host.get("selected_candidate_id")) != candidate_id:
            return _fail("O6 disabled B1 candidate row was not the selected candidate.")
    var accept := ui.find_child("AcceptCandidate",true,false) as Button
    if accept == null or accept.disabled:
        return _fail("O6 B1 has no enabled canonical Accept action for the selected candidate.")
    accept.pressed.emit()
    await process_frame
    accept = ui.find_child("AcceptCandidate",true,false) as Button
    if accept == null or not accept.text.contains("XÁC NHẬN"):
        return _fail("O6 B1 candidate acceptance did not expose its second confirmation.")
    accept.pressed.emit()
    await process_frame
    return true

func _open_scene() -> bool:
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        return _fail("O6 could not load landscape main scene.")
    ui = scene.instantiate() as Control
    if ui == null:
        return _fail("O6 could not instantiate landscape main scene.")
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null:
        return _fail("O6 scene returned no live SimulationState.")
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if runtime == null:
        return _fail("O6 scene returned no LiveGameRuntimeV2.")
    scheduler = runtime.scheduler()
    if scheduler == null:
        return _fail("O6 runtime returned no scheduler.")
    _stop_timers(ui)
    return true

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

func _cleanup_save() -> bool:
    var ok := true
    for suffix in ["", ".tmp", ".bak"]:
        var path: String = SAVE_PATH + str(suffix)
        if not FileAccess.file_exists(path):
            continue
        var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
        if error != OK:
            push_error("O6 could not remove isolated QA save artifact (%s): %s" % [suffix,error])
            ok = false
    ProjectSettings.set_setting("runtime/live_save_path", LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    return ok

func _fail(message: String) -> bool:
    push_error(message)
    _dispose_scene()
    _cleanup_save()
    quit(1)
    return false
