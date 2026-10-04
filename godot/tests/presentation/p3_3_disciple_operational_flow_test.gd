extends SceneTree

var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.3 disciple operational flow could not load the live P3.2 map scene.")
        return

    ui = packed_scene.instantiate() as Control
    if ui == null:
        _fail("P3.3 disciple operational flow could not instantiate the live map scene.")
        return
    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null:
        _fail("P3.3 flow did not expose the real SimulationState.")
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        _fail("P3.3 flow has no disciple to test.")
        return

    var first_id := StringName(ids[0])
    var second_id := first_id
    if ids.size() > 1:
        second_id = StringName(ids[1])

    if not _verify_map_tap_opens_operational_summary(first_id):
        return
    if not _verify_hidden_bloodline_does_not_leak(first_id):
        return
    if not _verify_quick_order_uses_real_workforce(first_id):
        return
    var deep_flow_ok: bool = await _verify_summary_to_deep_and_back(first_id, second_id)
    if not deep_flow_ok:
        return
    var bottom_nav_ok: bool = await _verify_bottom_nav_deep_returns_clean_map(second_id)
    if not bottom_nav_ok:
        return

    print("P3.3 DISCIPLE OPERATIONAL FLOW TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _verify_map_tap_opens_operational_summary(disciple_id: StringName) -> bool:
    ui.call("_open_disciple", disciple_id)

    var summary := ui.get("disciple_summary_panel") as Panel
    if summary == null or not summary.visible:
        return _fail("Tap disciple did not open the fixed right-side operational summary.")

    var popup_layer := ui.get("popup_layer") as Control
    if popup_layer == null or popup_layer.get_child_count() != 0:
        return _fail("V3.2 summary incorrectly opened as a dimmed deep popup instead of preserving map context.")

    var selected := StringName(ui.get("selected_id"))
    if selected != disciple_id:
        return _fail("Operational summary did not preserve the selected disciple.")

    var disciple: DiscipleState = state.disciples[disciple_id]
    var summary_text := str(ui.call("_disciple_summary_text", disciple))
    var cultivation := CultivationSystem.new()
    if not summary_text.contains(cultivation.stage_name(disciple)):
        # Stage is intentionally rendered in the summary header/meta, not duplicated
        # in the body. Check the actual meta label as the authority.
        var meta := ui.get("disciple_summary_meta") as Label
        if meta == null or not meta.text.contains(cultivation.stage_name(disciple)):
            return _fail("Operational summary does not read the real cultivation stage.")
    if not summary_text.contains("HP ") or not summary_text.contains("Thể lực"):
        return _fail("Operational summary is missing real HP/stamina.")
    if not summary_text.contains("Tu vi:") or not summary_text.contains("Đang làm:") or not summary_text.contains("Vị trí:"):
        return _fail("Operational summary is missing cultivation/action/location continuity.")
    if not summary_text.contains("Chiến lực:") or not summary_text.contains("Công pháp:"):
        return _fail("Operational summary is missing key combat/technique cues.")

    var camera_controls := ui.get("camera_controls_panel") as Panel
    if camera_controls != null and camera_controls.visible:
        return _fail("Right-side summary did not clear the overlapping camera control rail.")
    return true

func _verify_hidden_bloodline_does_not_leak(disciple_id: StringName) -> bool:
    state.sect.bloodline_profiles[str(disciple_id)] = {
        "initialized": true,
        "bloodline_id": "true_dragon",
        "purity": 0.42,
        "revealed": false,
        "awakened": false,
        "refinement_count": 0
    }
    ui.call("_refresh_disciple_summary_content")
    var disciple: DiscipleState = state.disciples[disciple_id]
    var text := str(ui.call("_disciple_summary_text", disciple))
    if not text.contains("Huyết Mạch: Chưa xác định"):
        return _fail("Operational summary did not hide an unrevealed bloodline.")
    if text.contains("Chân Long") or text.contains("42%"):
        return _fail("Operational summary leaked latent bloodline identity or purity.")
    return true

func _verify_quick_order_uses_real_workforce(disciple_id: StringName) -> bool:
    var disciple: DiscipleState = state.disciples[disciple_id]
    var before_action := disciple.current_action
    var before_region := disciple.region_id

    ui.call("_issue_summary_order", WorkforceSystem.COMMAND_CULTIVATE, "", "Tu luyện")

    if StringName(disciple.direct_command.get("kind", "")) != WorkforceSystem.COMMAND_CULTIVATE:
        return _fail("V3.2 quick order did not call the real WorkforceSystem command path.")
    if disciple.current_action != before_action or disciple.region_id != before_region:
        return _fail("Quick-order UI directly mutated action/region instead of leaving authority to simulation.")
    var body := ui.get("disciple_summary_body") as Label
    if body == null or not body.text.contains("Lệnh Tông Chủ: Tu luyện"):
        return _fail("Operational summary did not refresh from the real stored direct command.")
    return true

func _verify_summary_to_deep_and_back(first_id: StringName, second_id: StringName) -> bool:
    ui.call("_open_disciple", first_id)
    ui.call("_open_selected_disciple_detail")
    await process_frame

    var summary := ui.get("disciple_summary_panel") as Panel
    if summary == null or summary.visible:
        return _fail("Opening V3.3 did not hide the right-side summary.")

    var deep := _find_named_child(ui.get("popup_layer") as Node, "DiscipleDeepScreen")
    if deep == null:
        return _fail("Xem chi tiết did not open the V3.3 deep disciple screen.")

    var tab_names := ["Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    var disciple: DiscipleState = state.disciples[first_id]
    for tab_name in tab_names:
        var text := str(ui.call("_disciple_tab_text", tab_name, disciple))
        if text.is_empty():
            return _fail("V3.3 real tab returned empty content: %s" % tab_name)

    ui.call("_open_disciple_deep_screen", second_id, "Quan hệ")
    await process_frame
    if StringName(ui.get("selected_id")) != second_id:
        return _fail("V3.3 roster switch did not update selected disciple.")

    ui.call("_return_to_disciple_summary")
    await process_frame

    if not summary.visible:
        return _fail("Back from V3.3 opened from V3.2 did not restore the right-side summary.")
    if StringName(ui.get("selected_id")) != second_id:
        return _fail("Back from V3.3 did not preserve the disciple selected inside the roster.")
    if StringName(ui.get("focused_id")) != second_id:
        return _fail("Back from V3.3 did not restore the selection marker to the current disciple.")
    return true

func _verify_bottom_nav_deep_returns_clean_map(disciple_id: StringName) -> bool:
    ui.set("selected_id", disciple_id)
    ui.call("_bottom_action", "disciples")
    await process_frame

    var deep := _find_named_child(ui.get("popup_layer") as Node, "DiscipleDeepScreen")
    if deep == null:
        return _fail("Bottom Đệ Tử entry did not open V3.3.")

    ui.call("_return_to_disciple_summary")
    await process_frame

    var summary := ui.get("disciple_summary_panel") as Panel
    if summary != null and summary.visible:
        return _fail("Direct bottom-nav V3.3 entry incorrectly restored a V3.2 summary that was never the entry context.")
    if StringName(ui.get("selected_id")) != &"":
        return _fail("Direct bottom-nav V3.3 Back did not return to a clean map selection state.")
    return true

func _find_named_child(parent: Node, target_name: String) -> Node:
    if parent == null:
        return null
    for child in parent.get_children():
        if child.name == target_name:
            return child
    return null

func _fail(message: String) -> bool:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
    return false
