extends SceneTree

var ui: Control

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not (
        FemaleStageAAssetLoader.assets_available(&"down")
        and FemaleStageAAssetLoader.assets_available(&"right")
        and FemaleStageAAssetLoader.assets_available(&"up")
    ):
        _fail("Female Stage A asset pack must be installed before live-map integration test.")
        return

    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.2 live-map scene could not be loaded.")
        return

    ui = packed_scene.instantiate() as Control
    if ui == null:
        _fail("P3.2 live-map scene could not be instantiated.")
        return
    root.add_child(ui)
    await process_frame

    var state := ui.get("state") as SimulationState
    if state == null:
        _fail("Live map did not expose real SimulationState.")
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.is_empty():
        _fail("Live map has no disciples.")
        return

    var chosen_id := StringName(ids[0])
    var chosen: DiscipleState = state.disciples[chosen_id]
    var before_action := chosen.current_action
    var before_region := chosen.region_id
    var key := str(chosen_id)
    var actor_virtual_positions: Dictionary = ui.get("actor_virtual_positions")
    var actor_nodes_before: Dictionary = ui.get("actor_nodes")
    if not actor_virtual_positions.has(key):
        _fail("Chosen canonical disciple has no live virtual map position.")
        return

    chosen.sex_id = &"female"

    var selected_before := StringName(ui.get("selected_id"))
    var map_layer := ui.get("map_layer") as Control
    var screen_before := Vector2.ZERO
    if map_layer != null:
        screen_before = map_layer.get_global_transform() * Vector2(actor_virtual_positions[key])
    print("P3.2 selected-only diagnostic before focus chosen=%s selected=%s virtual=%s actor_nodes=%d screen=%s view=%s" % [str(chosen_id), str(selected_before), str(actor_virtual_positions[key]), actor_nodes_before.size(), str(screen_before), str(SectMapCamera.VIEW_RECT)])

    # Use the same selection/focus path as the map UI. The production renderer
    # intentionally materializes only the selected disciple inside the viewport.
    ui.call("_open_disciple", chosen_id)
    if StringName(ui.get("selected_id")) != chosen_id:
        _fail("Live map selection path did not select the chosen canonical disciple.")
        return

    var focus_tween := ui.get("camera_tween") as Tween
    if focus_tween != null and focus_tween.is_valid() and focus_tween.is_running():
        await focus_tween.finished
    await process_frame
    ui.call("_refresh_world_actor_visibility")
    await process_frame

    if not state.disciples.has(chosen_id):
        _fail("Selected disciple disappeared from canonical simulation state.")
        return
    actor_virtual_positions = ui.get("actor_virtual_positions")
    var actor_nodes: Dictionary = ui.get("actor_nodes")
    var map_layer_after := ui.get("map_layer") as Control
    if not actor_virtual_positions.has(key):
        _fail("Selected disciple lost its virtual position after camera focus.")
        return
    if map_layer_after == null:
        _fail("P3.2 map camera layer was missing after the real selection/focus path.")
        return
    var selected_after := StringName(ui.get("selected_id"))
    var virtual_position := Vector2(actor_virtual_positions[key])
    var map_transform := map_layer_after.get_global_transform()
    var projected_top_left := map_transform * virtual_position
    var actor_size: Vector2 = DiscipleActorVisualCatalog.ACTOR_BOX_SIZE
    var projected_size := Vector2(
        absf(map_transform.x.x) * actor_size.x + absf(map_transform.y.x) * actor_size.y,
        absf(map_transform.x.y) * actor_size.x + absf(map_transform.y.y) * actor_size.y
    )
    var projected_actor_rect := Rect2(projected_top_left, projected_size)
    var focus_tween_valid := focus_tween != null and focus_tween.is_valid()
    var focus_tween_running := focus_tween_valid and focus_tween.is_running()
    print("P3.2 selected-only diagnostic after focus chosen=%s selected=%s virtual=%s actor_nodes=%d projected_rect=%s view=%s camera_position=%s zoom=%s tween_valid=%s tween_running=%s" % [str(chosen_id), str(selected_after), str(virtual_position), actor_nodes.size(), str(projected_actor_rect), str(SectMapCamera.VIEW_RECT), str(map_layer_after.position), str(ui.get("map_zoom")), str(focus_tween_valid), str(focus_tween_running)])

    if not actor_nodes.has(key):
        _fail("Selected disciple was not materialized through the live selection/focus path.")
        return
    if actor_nodes.size() != 1:
        _fail("Selected-only actor visibility allocated %d scene actors; expected exactly one selected in-view actor." % actor_nodes.size())
        return
    if actor_virtual_positions.size() != state.disciples.size():
        _fail("Non-materialized canonical disciples were not retained in the virtual actor registry.")
        return
    for raw_id in state.disciples.keys():
        if str(raw_id) != key and actor_nodes.has(str(raw_id)):
            _fail("An unselected disciple was materialized outside the selected-only viewport path.")
            return

    if not SectMapCamera.VIEW_RECT.encloses(projected_actor_rect):
        _fail("Selected actor was not fully inside the camera viewport after the real focus path: %s." % str(projected_actor_rect))
        return

    var modular := actor_nodes[key] as ModularDiscipleActor
    if modular == null:
        _fail("Female disciple was not upgraded to ModularDiscipleActor on the live map.")
        return

    if not modular.production_body_active():
        _fail("Live modular actor did not attach the real Stage A production body.")
        return
    if modular.animation_player == null:
        _fail("Live modular actor has no shared AnimationPlayer.")
        return
    if not modular.animation_player.has_animation(&"idle_down") or not modular.animation_player.has_animation(&"walk_right"):
        _fail("Live modular actor does not have the accepted shared idle/walk library.")
        return

    var original_position := modular.position
    modular.position -= Vector2(80.0, 0.0)
    ui.call("_sync_actor_positions")

    if modular.current_clip != &"walk":
        _fail("Live modular actor did not switch to WALK while moving to its real destination.")
        return
    if modular.facing != &"right":
        _fail("Live modular actor did not face movement direction.")
        return
    if modular.current_playback_animation_name() != &"walk_right":
        _fail("Live modular actor did not play shared walk_right motion.")
        return

    if chosen.current_action != before_action or chosen.region_id != before_region:
        _fail("Live presentation integration mutated simulation action/region authority.")
        return

    modular.position = original_position
    ui.call("_sync_actor_positions")
    if modular.status_label.text != SectMapPresentation.action_label(chosen.current_action):
        _fail("Live modular actor status is not reading the real simulation action.")
        return

    print("P3.2 LIVE MODULAR FEMALE MAP INTEGRATION TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
