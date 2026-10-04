extends SceneTree

var ui: Control
var state: SimulationState

const BANNED_PLAYER_COPY := [
    "p3.",
    "p2.",
    "p1.",
    "command_",
    "needssystem",
    "workforcesystem",
    "authority",
    "baseline",
    "runtime",
    "simulation thật",
    "demo",
    "contract"
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.6A could not load the real main scene.")
        return

    ui = packed_scene.instantiate() as Control
    if ui == null:
        _fail("P3.6A could not instantiate the real main scene.")
        return

    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null:
        _fail("P3.6A main scene does not expose SimulationState.")
        return

    _stop_all_timers(ui)

    if not _verify_demo_task_rail_removed():
        return
    if not _verify_bottom_bar_has_only_real_entries():
        return
    if not _verify_building_tokens_are_player_readable():
        return
    if not _verify_idle_player_copy_is_clean():
        return

    var building_copy_ok: bool = await _verify_building_panels_are_clean()
    if not building_copy_ok:
        return

    var disciple_copy_ok: bool = await _verify_disciple_surfaces_are_clean()
    if not disciple_copy_ok:
        return

    var consequence_ok: bool = await _verify_real_order_has_visible_map_consequence()
    if not consequence_ok:
        return

    print("P3.6A PLAYABLE SLICE TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _verify_demo_task_rail_removed() -> bool:
    if ui.get("task_label") != null:
        return _fail("Old P3.1 demo task rail is still active in normal play.")

    var leaked := _find_text_fragment(ui, "Chương 1")
    if leaked != "":
        return _fail("Demo chapter/checklist text is still visible: %s" % leaked)
    return true

func _verify_bottom_bar_has_only_real_entries() -> bool:
    var bottom := ui.find_child("PlayerBottomBar", true, false) as Panel
    if bottom == null:
        return _fail("Player bottom bar is missing.")

    var labels: Array[String] = []
    for child in bottom.get_children():
        if child is Button:
            labels.append((child as Button).text)

    var expected: Array[String] = ["Tông Môn", "Đệ Tử", "Kho", "Thế Giới"]
    if labels != expected:
        return _fail("Bottom bar still exposes fake/unfinished entries: %s" % str(labels))
    return true

func _verify_building_tokens_are_player_readable() -> bool:
    var map_layer := ui.get("map_layer") as Control
    if map_layer == null:
        return _fail("Map layer is missing.")

    var destinations: Array[StringName] = [
        SectMapPresentation.DEST_MAIN_HALL,
        SectMapPresentation.DEST_RESIDENCE,
        SectMapPresentation.DEST_CULTIVATION,
        SectMapPresentation.DEST_WAREHOUSE,
        SectMapPresentation.DEST_FORGE,
        SectMapPresentation.DEST_MEDICINE,
        SectMapPresentation.DEST_MINE,
        SectMapPresentation.DEST_GATE
    ]

    for destination in destinations:
        var token := map_layer.get_node_or_null("BuildingToken_%s" % str(destination)) as Control
        if token == null:
            return _fail("Missing player-readable building token: %s" % str(destination))
        if token.get_child_count() < 3:
            return _fail("Building token is still effectively a plain debug box: %s" % str(destination))
        var hit := token.get_node_or_null("BuildingHit_%s" % str(destination)) as Button
        if hit == null:
            return _fail("Building token lost its real map interaction: %s" % str(destination))
        if hit.tooltip_text.strip_edges().is_empty():
            return _fail("Building token is not named for the player: %s" % str(destination))
    return true

func _verify_idle_player_copy_is_clean() -> bool:
    var leaked := _find_banned_player_copy(ui)
    if leaked != "":
        return _fail("Developer/debug copy leaked on the idle main map: %s" % leaked)
    return true

func _verify_building_panels_are_clean() -> bool:
    var destinations: Array[StringName] = [
        SectMapPresentation.DEST_MAIN_HALL,
        SectMapPresentation.DEST_RESIDENCE,
        SectMapPresentation.DEST_CULTIVATION,
        SectMapPresentation.DEST_WAREHOUSE,
        SectMapPresentation.DEST_FORGE,
        SectMapPresentation.DEST_MEDICINE,
        SectMapPresentation.DEST_MINE,
        SectMapPresentation.DEST_GATE
    ]

    for destination in destinations:
        ui.call("_open_building", destination)
        await process_frame
        var panel := ui.get("building_operation_panel") as Panel
        if panel == null or not panel.visible:
            return _fail("Building operation panel failed to open: %s" % str(destination))
        var leaked := _find_banned_player_copy(panel)
        if leaked != "":
            return _fail("Developer/debug copy leaked in building panel %s: %s" % [str(destination), leaked])

    ui.call("_close_building_operation_panel", true)
    await process_frame
    return true

func _verify_disciple_surfaces_are_clean() -> bool:
    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        return _fail("No disciple exists for P3.6A player-surface check.")

    var disciple_id := StringName(ids[0])
    ui.call("_open_disciple", disciple_id)
    await process_frame

    var summary := ui.get("disciple_summary_panel") as Panel
    if summary == null or not summary.visible:
        return _fail("Disciple summary did not open.")
    var leaked := _find_banned_player_copy(summary)
    if leaked != "":
        return _fail("Developer/debug copy leaked in disciple summary: %s" % leaked)

    var tabs: Array[String] = ["Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    for tab_name in tabs:
        ui.call("_open_disciple_deep_screen", disciple_id, tab_name)
        await process_frame
        var popup_layer := ui.get("popup_layer") as Control
        var deep := popup_layer.get_node_or_null("DiscipleDeepScreen") as Panel
        if deep == null:
            return _fail("Deep disciple screen failed to open for %s." % tab_name)
        leaked = _find_banned_player_copy(deep)
        if leaked != "":
            return _fail("Developer/debug copy leaked in disciple tab %s: %s" % [tab_name, leaked])

    ui.call("_return_to_disciple_summary")
    await process_frame
    ui.call("_close_disciple_summary", true)
    await process_frame
    return true

func _verify_real_order_has_visible_map_consequence() -> bool:
    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        return _fail("No disciple exists for consequence check.")

    var disciple_id := StringName(ids[0])
    var disciple: DiscipleState = state.disciples[disciple_id]
    disciple.region_id = &"sect"
    disciple.target_region_id = &""
    disciple.hp = disciple.max_hp
    disciple.stamina = 100.0
    disciple.current_action = &"EVALUATE"
    disciple.direct_command.clear()

    ui.call("_open_disciple", disciple_id)
    await process_frame

    ui.call("_issue_summary_order", WorkforceSystem.COMMAND_CULTIVATE, "", "Tu luyện")
    if StringName(disciple.direct_command.get("kind", "")) != WorkforceSystem.COMMAND_CULTIVATE:
        return _fail("Player quick order no longer reaches the real command authority.")

    var before_tick := state.tick
    ui.call("_advance_simulation")
    await process_frame

    if state.tick != before_tick + 1:
        return _fail("Main scene did not advance the real simulation.")
    if disciple.current_action != &"CULTIVATE":
        return _fail("Real cultivate order did not become visible cultivation action.")

    var destinations: Dictionary = ui.get("actor_destinations")
    if StringName(destinations.get(str(disciple_id), "")) != SectMapPresentation.DEST_CULTIVATION:
        return _fail("Actor destination did not visibly follow the real cultivate action.")

    return true

func _find_banned_player_copy(node: Node) -> String:
    if node is Label:
        var text := (node as Label).text
        var bad := _banned_fragment(text)
        if bad != "":
            return "%s -> %s" % [bad, text]
    elif node is Button:
        var button := node as Button
        var bad := _banned_fragment(button.text)
        if bad != "":
            return "%s -> %s" % [bad, button.text]
        bad = _banned_fragment(button.tooltip_text)
        if bad != "":
            return "%s -> tooltip %s" % [bad, button.tooltip_text]

    for child in node.get_children():
        var nested := _find_banned_player_copy(child)
        if nested != "":
            return nested
    return ""

func _find_text_fragment(node: Node, fragment: String) -> String:
    if node is Label and (node as Label).text.contains(fragment):
        return (node as Label).text
    if node is Button and (node as Button).text.contains(fragment):
        return (node as Button).text
    for child in node.get_children():
        var found := _find_text_fragment(child, fragment)
        if found != "":
            return found
    return ""

func _banned_fragment(text: String) -> String:
    var normalized := text.to_lower()
    for token in BANNED_PLAYER_COPY:
        if normalized.contains(token):
            return token
    return ""

func _stop_all_timers(node: Node) -> void:
    if node is Timer:
        (node as Timer).stop()
    for child in node.get_children():
        _stop_all_timers(child)

func _fail(message: String) -> bool:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
    return false
