extends SceneTree

# E3 real-map acceptance: clickable owned Rèn Thân Đường; two assignments,
# real treasury/paid minute, release and replacement; no preview-only data.
const SAVE_PATH := "user://dv2_03_e3_body_building_ui_test.json"
var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if ok:
        return true
    push_error(message)
    _finish(false)
    return false

func _finish(ok: bool) -> void:
    if ui != null and is_instance_valid(ui):
        ui.queue_free()
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    quit(0 if ok else 1)

func _recruit(index: int) -> DiscipleState:
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,index
    )
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    var disciple: DiscipleState = state.disciples[candidate.id]
    disciple.region_id = &"sect"
    disciple.current_action = &"EVALUATE"
    return disciple

func _prepare_ninth_real_bed() -> bool:
    var builder := BuildingSystem.new()
    var houses := SectResidenceSystemV1.all_houses(state)
    if not _check(houses.size() >= 1, "E3 needs the real starter Residence."):
        return false
    var house: BuildingState = houses[0]
    var wh := WarehouseSystem.new()
    var cost := builder.upgrade_cost(house)
    if cost.is_empty():
        return _check(false, "E3 starter Residence has no actual upgrade cost.")
    var need_wood := int(cost.get(BuildingSystem.MATERIAL_WOOD, 0))
    var wood_id := StringName(BuildingSystem.MATERIAL_WOOD)
    if wh.available_quantity(state, wood_id) < need_wood:
        # Earn any shortfall from the canonical Forest job/timer. No fake
        # materials are injected into the game or the QA fixture.
        var forest := builder.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
        if not _check(forest != null, "E3 missing real Forest to earn Residence wood."):
            return false
        var workers := builder.active_worker_ids(state, forest)
        if not _check(not workers.is_empty(), "E3 Forest needs an assigned worker to earn wood."):
            return false
        var worker_id: StringName = workers[0]
        var workforce := WorkforceSystem.new()
        for _minute in range(120):
            if wh.available_quantity(state, wood_id) >= need_wood:
                break
            if builder.active_resource_timer_for_worker(state, worker_id).is_empty():
                var worked := workforce.perform_work(state, state.disciples[worker_id], WorkforceSystem.PROF_FORESTRY)
                if not _check(bool(worked.get("ok", false)),
                        "E3 real Forest production failed: " + str(worked)):
                    return false
            state.tick += 1
            builder.process_tick(state)
    if not _check(wh.available_quantity(state, wood_id) >= need_wood
            and wh.available_quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
                >= int(cost.get(BuildingSystem.MATERIAL_ORE, 0)),
            "E3 Residence lacks actually produced upgrade materials."):
        return false

    # This UI test isolates Body Training, not the game's Linh Thach earning
    # curve. The wallet is an explicit QA fixture; its construction debit is
    # still performed by the real transaction authority (no gameplay grant).
    state.sect.spirit_stones = int(cost.get("spirit_stones", 0)) + 9
    var started := builder.start_upgrade(state, house.id, "qa:e3:starter-bed-upgrade")
    if not _check(bool(started.get("ok", false)) and house.is_upgrading(),
            "E3 real Residence paid upgrade failed: " + str(started)):
        return false
    var duration := int(ceil(house.upgrade_required_work)) + 1
    for _minute in range(duration):
        state.tick += 1
        builder.process_tick(state)
    return _check(house.level == 2 and not house.is_upgrading()
        and SectResidenceSystemV1.current_limit(state) >= 9
        and state.sect.spirit_stones == 9,
        "E3 real paid Residence upgrade did not unlock the ninth V2 bed.")

func _run() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _check(packed != null,"E3 failed to load P3.2 playable map."):
        return
    ui = packed.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if not _check(state != null and bool(ui.get("runtime_ready")),
        "E3 scene does not use real LiveGameRuntimeV2."):
        return
    var token := ui.get_node_or_null(
        "MapLayer/BuildingToken_ren_than_duong/BuildingHit_ren_than_duong"
    )
    # Parent map layer is created dynamically by P3.1; if not named, locate
    # using the actual reference instead of fabricating an alternative marker.
    var map_layer: Control = ui.get("map_layer") as Control
    if token == null and map_layer != null:
        token = map_layer.get_node_or_null(
            "BuildingToken_ren_than_duong/BuildingHit_ren_than_duong"
        )
    if not _check(token is Button and
        SectMapPresentation.destination_for_action(&"TRAIN_BODY") ==
        SectMapPresentation.DEST_BODY_TRAINING,
        "E3 map has no clickable body-training building or action routing."):
        return
    var hall := BuildingSystem.new().primary_building(
        state,BuildingSystem.TYPE_BODY_TRAINING
    )
    if not _check(hall != null and BuildingSystem.new().worker_slots(hall) == 2,
        "E3 map is not backed by the real two-slot facility."):
        return

    # New Game starts with six founders and eight genuine Residence beds.
    # E3 needs three *additional* V2 recruits for the two-slot release test.
    # Expand the real starter Residence through paid BuildingSystem, not by
    # overriding the recruitment limit or inventing a ninth bed.
    if not _prepare_ninth_real_bed():
        return
    var a := _recruit(6051)
    var b := _recruit(6052)
    var c := _recruit(6053)
    if not _check(a != null and b != null and c != null,"E3 requires three authentic V2 disciples."):
        return
    (token as Button).pressed.emit()
    var panel: Panel = ui.get("building_operation_panel") as Panel
    if not _check(panel != null and panel.visible and
        StringName(ui.get("selected_building")) == SectMapPresentation.DEST_BODY_TRAINING,
        "Tapping the E3 map building did not open its management panel."):
        return
    var body := str(ui.call("_body_training_operation_text"))
    if not _check(body.contains("Vị trí: 0/2") and body.contains("Linh Thạch Tông Môn: 9") and
        body.contains("EXP nền: 1.500 EXP/phút") and body.contains("Lượt đã thanh toán: 0"),
        "E3 management summary does not display real slots/treasury/EXP audit."):
        return
    var controls: VBoxContainer = ui.get("building_management_container") as VBoxContainer
    if not _check(controls.get_node_or_null("BodyTrainingSlot_1") != null and
        controls.get_node_or_null("BodyTrainingSlot_2") != null and
        controls.get_node_or_null("BodyTrainingCandidate_%s" % str(a.id)) != null,
        "E3 management controls were not built from the authentic roster."):
        return

    ui.call("_start_body_training_from_building",a.id)
    ui.call("_start_body_training_from_building",b.id)
    var holders := BuildingSystem.new().active_worker_ids(state,hall)
    if not _check(holders.size() == 2 and a.current_action == &"TRAIN_BODY" and
        b.current_action == &"TRAIN_BODY" and state.sect.spirit_stones == 9 and
        float(a.v2_realm_progress["body"]["xp"]) == 0.0,
        "E3 assignment failed or charged/awarded before a real minute."):
        return
    ui.call("_start_body_training_from_building",c.id)
    if not _check(BuildingSystem.new().active_worker_ids(state,hall).size() == 2 and
        c.current_action == &"EVALUATE" and c.work_group_id != &"body_training_crew" and
        str(ui.get("building_management_feedback")).contains("kín 2 chỗ"),
        "E3 allowed a third training slot or concealed real overcapacity denial."):
        return

    var release_button := controls.find_child("BodyTrainingRelease_%s" % str(a.id),true,false)
    if not _check(release_button is Button,"E3 did not create real slot-release control."):
        return
    (release_button as Button).pressed.emit()
    if not _check(a.work_group_id == &"" and a.worksite_building_id == &"" and
        a.current_action != &"TRAIN_BODY" and
        str(a.v2_realm_progress.get("training_policy","")) == "manual" and
        state.sect.spirit_stones == 9,
        "E3 releasing a slot failed to stop training or incorrectly changed funds."):
        return
    ui.call("_start_body_training_from_building",c.id)
    holders = BuildingSystem.new().active_worker_ids(state,hall)
    if not _check(holders.size() == 2 and holders.has(b.id) and holders.has(c.id),
        "E3 freed slot cannot be reused for another authentic disciple."):
        return

    # One real committed minute from the existing canonical source owner.
    state.tick = maxi(state.tick+1,1)
    var gained := DiscipleTrainingActionV2.resolve(state,b,"TRAIN_BODY")
    if not _check(bool(gained.get("ok",false)) and
        state.sect.spirit_stones == 8 and
        float(b.v2_realm_progress["body"]["xp"]) > 0.0 and
        int(hall.production_state.get("paid_training_minutes",-1)) == 1,
        "E3 training did not debit exactly one stone and award real Body EXP."):
        return
    # The source commit API returns a receipt; only SimulationScheduler
    # stores last_decision. Assert persisted economic truth, not a synthetic receipt.
    ui.call("_refresh_building_operation_content")
    body = str(ui.get("building_operation_body").text)
    if not _check(body.contains("Linh Thạch Tông Môn: 8") and
        body.contains("Lượt đã thanh toán: 1") and body.contains("Linh Thạch đã tiêu: 1"),
        "E3 building panel is not refreshed from the real paid minute."):
        return

    var loaded := SimulationState.from_dict(
        JSON.parse_string(JSON.stringify(state.to_dict()))
    )
    var loaded_hall := BuildingSystem.new().primary_building(
        loaded,BuildingSystem.TYPE_BODY_TRAINING
    )
    if not _check(loaded_hall != null and
        BuildingSystem.new().active_worker_ids(loaded,loaded_hall).size() == 2 and
        loaded.sect.spirit_stones == 8 and
        int(loaded_hall.production_state.get("paid_training_minutes",0)) == 1,
        "E3 save/load lost real slot/treasury/training accounting."):
        return
    # E3.1 player-facing transfer must be as safe as the backend API: a
    # Chuyên Tu command frees C's seat without refunding B's paid minute.
    var switch: Dictionary = ui.call("_queue_v2_training","cultivation",c.id)
    if not _check(bool(switch.get("ok",false)) and
        c.current_action == &"CULTIVATE" and
        c.work_group_id == &"" and c.worksite_building_id == &"" and
        BuildingSystem.new().active_worker_ids(state,hall).size() == 1 and
        state.sect.spirit_stones == 8 and
        int(hall.production_state.get("paid_training_minutes",0)) == 1,
        "E3.1 UI Chuyên Tu failed to vacate a paid Body slot safely."):
        return
    var reassign: Dictionary = ui.call("_queue_v2_training","body",a.id)
    if not _check(bool(reassign.get("ok",false)) and
        BuildingSystem.new().active_worker_ids(state,hall).size() == 2 and
        state.sect.spirit_stones == 8,
        "E3.1 freed training place cannot be reused from actual UI."):
        return
    print("DV2-03E3 REAL RÈN THÂN MAP + TWO-SLOT UI: PASS")
    _finish(true)
