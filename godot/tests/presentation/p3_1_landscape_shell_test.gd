extends SceneTree

const TEST_SEED := 310131

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_landscape_project_contract():
        return
    if not _verify_destination_mapping():
        return
    if not _verify_transient_actions_keep_destination():
        return
    if not _verify_mapper_is_presentation_only():
        return
    if not _verify_real_direct_command_reaches_map_destination():
        return

    print("P3.1 LANDSCAPE SECT SHELL TEST PASS")
    quit(0)

func _verify_landscape_project_contract() -> bool:
    if int(ProjectSettings.get_setting("display/window/size/viewport_width", 0)) != 1280:
        return _fail("P3.1 viewport width must be 1280.")
    if int(ProjectSettings.get_setting("display/window/size/viewport_height", 0)) != 720:
        return _fail("P3.1 viewport height must be 720.")
    if str(ProjectSettings.get_setting("display/window/stretch/mode", "")) != "canvas_items":
        return _fail("P3.1 stretch mode must be canvas_items.")
    if str(ProjectSettings.get_setting("display/window/stretch/aspect", "")) != "expand":
        return _fail("P3.1 stretch aspect must be expand.")
    if int(ProjectSettings.get_setting("display/window/handheld/orientation", -1)) != 0:
        return _fail("P3.1 handheld orientation must be landscape (0).")
    if str(ProjectSettings.get_setting("application/run/main_scene", "")) != "res://scenes/p3/p3_1_landscape_sect.tscn":
        return _fail("P3.1 must be the project main scene.")
    if not ResourceLoader.exists("res://scenes/p3/p3_1_landscape_sect.tscn"):
        return _fail("P3.1 main scene is missing.")
    return true

func _verify_destination_mapping() -> bool:
    var cases := {
        "CULTIVATE": SectMapPresentation.DEST_CULTIVATION,
        "BREAKTHROUGH": SectMapPresentation.DEST_CULTIVATION,
        "WORK_MINING": SectMapPresentation.DEST_MINE,
        "WORK_FORGING": SectMapPresentation.DEST_FORGE,
        "REST": SectMapPresentation.DEST_RESIDENCE,
        "HEAL": SectMapPresentation.DEST_MEDICINE,
        "SELL": SectMapPresentation.DEST_WAREHOUSE,
        "BUY": SectMapPresentation.DEST_WAREHOUSE,
        "HUNT": SectMapPresentation.DEST_GATE,
        "TRAVEL": SectMapPresentation.DEST_GATE,
        "COMBAT": SectMapPresentation.DEST_GATE,
        "LOOT": SectMapPresentation.DEST_GATE,
        "RETURN_SECT": SectMapPresentation.DEST_GATE,
        "HOLD": SectMapPresentation.DEST_COURTYARD
    }
    var keys: Array = cases.keys()
    keys.sort()
    for action_text in keys:
        var actual := SectMapPresentation.destination_for_action(StringName(action_text), SectMapPresentation.DEST_COURTYARD)
        if actual != cases[action_text]:
            return _fail("P3.1 action %s mapped to %s instead of %s." % [action_text, actual, cases[action_text]])
        if SectMapPresentation.position_for_destination(actual) == Vector2.ZERO:
            return _fail("P3.1 destination %s has no usable map position." % actual)
    return true

func _verify_transient_actions_keep_destination() -> bool:
    var previous := SectMapPresentation.DEST_FORGE
    if SectMapPresentation.destination_for_action(&"EVALUATE", previous) != previous:
        return _fail("P3.1 EVALUATE must preserve the prior visible destination.")
    if SectMapPresentation.destination_for_action(&"IDLE", previous) != previous:
        return _fail("P3.1 IDLE must preserve the prior visible destination.")
    return true

func _verify_mapper_is_presentation_only() -> bool:
    var state := P212Factory.create_state(TEST_SEED)
    var before := state.to_dict()
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        SectMapPresentation.destination_for_action(disciple.current_action, SectMapPresentation.DEST_COURTYARD)
        SectMapPresentation.action_label(disciple.current_action)
    if before != state.to_dict():
        return _fail("P3.1 presentation mapper mutated simulation state.")
    return true

func _verify_real_direct_command_reaches_map_destination() -> bool:
    var state := P212Factory.create_state(TEST_SEED + 1)
    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        return _fail("P3.1 command test has no disciple.")
    var disciple_id := StringName(ids[0])
    var disciple: DiscipleState = state.disciples[disciple_id]
    disciple.region_id = &"sect"
    disciple.hp = disciple.max_hp
    disciple.stamina = 100.0
    disciple.current_action = &"EVALUATE"

    var workforce := WorkforceSystem.new()
    if not workforce.issue_command(state, disciple_id, WorkforceSystem.COMMAND_CULTIVATE, "", 40):
        return _fail("P3.1 could not issue real Sect Master cultivate command.")

    SimulationScheduler.new(state).step()
    if disciple.current_action != &"CULTIVATE":
        return _fail("P3.1 real cultivate command did not become CULTIVATE action; got %s." % disciple.current_action)
    if SectMapPresentation.destination_for_action(disciple.current_action, SectMapPresentation.DEST_COURTYARD) != SectMapPresentation.DEST_CULTIVATION:
        return _fail("P3.1 real cultivate command does not resolve to Tu Luyện Đài.")
    return true

func _fail(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
