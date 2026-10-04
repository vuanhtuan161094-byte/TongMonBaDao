extends SceneTree

var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.4B could not load live map scene.")
        return

    ui = packed_scene.instantiate() as Control
    if ui == null:
        _fail("P3.4B could not instantiate live map scene.")
        return

    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null or not state.sect.workforce_enabled:
        _fail("P3.4B requires real workforce-enabled SimulationState.")
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        _fail("P3.4B test state has no disciples.")
        return

    var disciple_id := StringName(ids[0])
    var disciple: DiscipleState = state.disciples[disciple_id]

    var mine_ok: bool = await _verify_mine_flow(disciple)
    if not mine_ok:
        return
    var forge_ok: bool = await _verify_forge_flow(disciple)
    if not forge_ok:
        return
    var cultivate_ok: bool = await _verify_direct_order_flow(disciple, SectMapPresentation.DEST_CULTIVATION, WorkforceSystem.COMMAND_CULTIVATE, "", "Cultivation")
    if not cultivate_ok:
        return
    var rest_ok: bool = await _verify_direct_order_flow(disciple, SectMapPresentation.DEST_RESIDENCE, WorkforceSystem.COMMAND_REST, "", "Residence")
    if not rest_ok:
        return
    var return_ok: bool = await _verify_direct_order_flow(disciple, SectMapPresentation.DEST_GATE, WorkforceSystem.COMMAND_RETURN_SECT, "", "Gate")
    if not return_ok:
        return
    var heal_ok: bool = await _verify_no_fake_heal()
    if not heal_ok:
        return

    print("P3.4B BUILDING PEOPLE MANAGEMENT TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _verify_mine_flow(disciple: DiscipleState) -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_MINE)
    await process_frame
    if not _management_controls_present():
        return _fail("Mine did not expose P3.4B people-management controls.")

    var before_action := disciple.current_action
    var before_region := disciple.region_id

    ui.call("_assign_building_group", disciple.id, &"mining_crew", "test")
    await process_frame
    if disciple.work_group_id != &"mining_crew":
        return _fail("Mine assignment did not use real work-group authority.")
    if disciple.current_action != before_action or disciple.region_id != before_region:
        return _fail("Mine group assignment directly mutated action/region.")

    ui.call("_issue_building_order", disciple.id, WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_MINING), "test")
    await process_frame
    if StringName(disciple.direct_command.get("kind", "")) != WorkforceSystem.COMMAND_WORK:
        return _fail("Mine immediate order did not create real direct command.")
    if StringName(disciple.direct_command.get("target", "")) != WorkforceSystem.PROF_MINING:
        return _fail("Mine immediate order target is not real mining profession.")
    if disciple.current_action != before_action or disciple.region_id != before_region:
        return _fail("Mine immediate order directly mutated action/region.")
    return true

func _verify_forge_flow(disciple: DiscipleState) -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_FORGE)
    await process_frame
    if not _management_controls_present():
        return _fail("Forge did not expose P3.4B people-management controls.")

    var before_action := disciple.current_action
    var before_region := disciple.region_id

    ui.call("_assign_building_group", disciple.id, &"forge_hall", "test")
    await process_frame
    if disciple.work_group_id != &"forge_hall":
        return _fail("Forge assignment did not use real work-group authority.")
    if disciple.current_action != before_action or disciple.region_id != before_region:
        return _fail("Forge group assignment directly mutated action/region.")

    ui.call("_issue_building_order", disciple.id, WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_FORGING), "test")
    await process_frame
    if StringName(disciple.direct_command.get("kind", "")) != WorkforceSystem.COMMAND_WORK:
        return _fail("Forge immediate order did not create real direct command.")
    if StringName(disciple.direct_command.get("target", "")) != WorkforceSystem.PROF_FORGING:
        return _fail("Forge immediate order target is not real forging profession.")
    if disciple.current_action != before_action or disciple.region_id != before_region:
        return _fail("Forge immediate order directly mutated action/region.")
    return true

func _verify_direct_order_flow(disciple: DiscipleState, destination: StringName, kind: StringName, target: String, label: String) -> bool:
    ui.call("_open_building", destination)
    await process_frame
    if not _management_controls_present():
        return _fail("%s did not expose P3.4B direct-order controls." % label)

    var before_action := disciple.current_action
    var before_region := disciple.region_id
    ui.call("_issue_building_order", disciple.id, kind, target, "test")
    await process_frame

    if StringName(disciple.direct_command.get("kind", "")) != kind:
        return _fail("%s did not write the real direct command." % label)
    if disciple.current_action != before_action or disciple.region_id != before_region:
        return _fail("%s order directly mutated action/region." % label)
    return true

func _verify_no_fake_heal() -> bool:
    ui.call("_open_building", SectMapPresentation.DEST_MEDICINE)
    await process_frame
    var controls := ui.get("building_management_container") as VBoxContainer
    if controls == null:
        return _fail("Medicine Hall management container is missing.")
    if controls.get_child_count() != 0:
        return _fail("Medicine Hall exposed people actions even though COMMAND_HEAL does not exist.")
    return true

func _management_controls_present() -> bool:
    var controls := ui.get("building_management_container") as VBoxContainer
    return controls != null and controls.get_child_count() > 1

func _fail(message: String) -> bool:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
    return false
