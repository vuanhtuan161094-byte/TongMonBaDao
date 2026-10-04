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
    chosen.sex_id = &"female"

    ui.call("_install_modular_live_actors")
    await process_frame

    var actor_nodes: Dictionary = ui.get("actor_nodes")
    var key := str(chosen_id)
    if not actor_nodes.has(key):
        _fail("Chosen disciple disappeared from live actor registry.")
        return

    var actor := actor_nodes[key]
    if not (actor is ModularDiscipleActor):
        _fail("Female disciple was not upgraded to ModularDiscipleActor on the live map.")
        return

    var modular := actor as ModularDiscipleActor
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
