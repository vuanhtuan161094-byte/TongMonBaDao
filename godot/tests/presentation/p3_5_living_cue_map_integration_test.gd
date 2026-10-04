extends SceneTree

var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.5 integration could not load live map scene.")
        return

    ui = packed_scene.instantiate() as Control
    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null or state.disciples.is_empty():
        _fail("P3.5 integration requires live SimulationState.")
        return

    var layer := ui.get("living_cue_layer") as LivingCueLayer
    var map_layer := ui.get("map_layer") as Control
    if layer == null or map_layer == null:
        _fail("P3.5 live cue layer is missing.")
        return
    if layer.get_parent() != map_layer:
        _fail("LivingCueLayer is not attached to the transformed map layer.")
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    var first_id := StringName(ids[0])
    var first: DiscipleState = state.disciples[first_id]

    _force_many_real_cues(first)
    var tracker := ui.get("living_cue_tracker") as LivingCueTracker
    tracker.seed_from_state(state)
    ui.call("_refresh_living_cues")
    await process_frame

    var visible: Array = ui.get("visible_living_cues")
    if visible.is_empty():
        _fail("P3.5 live map rendered no cues under forced real conditions.")
        return
    if visible.size() > 3 or layer.visible_count() > 3:
        _fail("P3.5 live map exceeded the max-3 attention budget.")
        return

    var before_route := state.to_dict().duplicate(true)
    var disciple_cue := {
        "target_kind": str(LivingCueResolver.TARGET_DISCIPLE),
        "target_id": str(first_id)
    }
    ui.call("_on_living_cue_pressed", disciple_cue)
    await process_frame
    if StringName(ui.get("selected_id")) != first_id:
        _fail("Disciple cue did not route to real P3.3 selected disciple.")
        return
    var summary := ui.get("disciple_summary_panel") as Panel
    if summary == null or not summary.visible:
        _fail("Disciple cue did not open real P3.3 summary.")
        return
    if before_route != state.to_dict().duplicate(true):
        _fail("Tapping a disciple cue mutated gameplay state.")
        return

    var building_cue := {
        "target_kind": str(LivingCueResolver.TARGET_BUILDING),
        "target_id": str(SectMapPresentation.DEST_RESIDENCE)
    }
    ui.call("_on_living_cue_pressed", building_cue)
    await process_frame
    if StringName(ui.get("selected_building")) != SectMapPresentation.DEST_RESIDENCE:
        _fail("Building cue did not route to real P3.4 building context.")
        return
    var building_panel := ui.get("building_operation_panel") as Panel
    if building_panel == null or not building_panel.visible:
        _fail("Building cue did not open real P3.4 operation panel.")
        return

    ui.call("_close_building_operation_panel", true)
    tracker.seed_from_state(state)
    ui.call("_refresh_living_cues")
    await process_frame
    visible = ui.get("visible_living_cues")
    if not visible.is_empty():
        var cue: Dictionary = visible[0]
        if StringName(cue.get("target_kind", "")) == LivingCueResolver.TARGET_DISCIPLE:
            var key := str(cue.get("stable_key", ""))
            var buttons: Dictionary = layer.buttons
            if buttons.has(key):
                var button := buttons[key] as Button
                var before_pos := button.position
                var actor_nodes: Dictionary = ui.get("actor_nodes")
                var actor := actor_nodes[str(cue.get("target_id", ""))] as Control
                actor.position += Vector2(25.0, 10.0)
                ui.call("_refresh_living_cue_positions")
                await process_frame
                if button.position == before_pos:
                    _fail("Disciple cue did not follow actor movement.")
                    return

    print("P3.5 LIVING CUE MAP INTEGRATION TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _force_many_real_cues(first: DiscipleState) -> void:
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        disciple.region_id = &"sect"
        disciple.hp = disciple.max_hp
        disciple.stamina = 100.0
        disciple.work_group_id = &""
        disciple.cultivation_progress = 0.0
        disciple.next_breakthrough_tick = state.tick + 1000

    first.hp = first.max_hp * 0.50
    state.sect.medicine_stock = 0
    if state.disciples.size() > 1:
        state.sect.lodging_capacity = state.disciples.size() - 1

func _fail(message: String) -> void:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
