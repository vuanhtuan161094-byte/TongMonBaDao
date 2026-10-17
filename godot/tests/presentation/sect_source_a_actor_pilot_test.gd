extends SceneTree

const SAVE_PATH := "user://sect_source_a_actor_pilot_test.json"
var scene: Control

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("real landscape scene missing")
        return
    scene = packed.instantiate() as Control
    root.add_child(scene)
    for _i in range(3):
        await process_frame
    if not bool(scene.get("runtime_ready")):
        _fail("canonical runtime not ready")
        return
    var actors := scene.get("actor_nodes") as Dictionary
    var state := scene.get("state") as SimulationState
    var pilot_count := 0
    for key in actors.keys():
        var actor := actors[key] as ModularDiscipleActor
        var disciple := state.disciples.get(StringName(key)) as DiscipleState
        if actor == null or disciple == null:
            _fail("map actor lost canonical disciple identity")
            return
        if actor.baked_visual_active():
            if actor.rig_id != DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1:
                _fail("female pilot was applied to a non-female rig")
                return
            if actor.fallback_visual.visible or actor.baked_sprite.position != DiscipleActorVisualCatalog.ACTOR_FOOT_POINT:
                _fail("baked pilot did not replace fallback at foot anchor")
                return
            actor.play_walk_for_delta(Vector2(-1,0))
            if actor.baked_sprite.animation != &"walk" or not actor.baked_sprite.flip_h:
                _fail("public left walk did not play mirrored verified clip")
                return
            actor.play_walk_for_delta(Vector2(1,0))
            if actor.baked_sprite.animation != &"walk" or actor.baked_sprite.flip_h:
                _fail("public right walk did not restore orientation")
                return
            actor.sync_action(&"IDLE")
            if actor.baked_sprite.animation != &"stand" or not actor.baked_sprite.is_playing():
                _fail("idle did not stop walk and play stand")
                return
            pilot_count += 1
    if pilot_count == 0:
        _fail("verified pilot did not appear in the real scene")
        return
    print("SOURCE A ACTOR PILOT REAL SCENE PASS female_actors=",pilot_count)
    scene.queue_free()
    quit(0)

func _fail(reason: String) -> void:
    push_error("SOURCE A ACTOR PILOT FAIL: "+reason)
    if scene != null:
        scene.queue_free()
    quit(1)
