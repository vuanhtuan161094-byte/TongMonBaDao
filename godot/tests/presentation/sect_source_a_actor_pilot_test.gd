# TEST ONLY - short actor badge readability is presentation, not a work-action clip.
extends SceneTree

const SAVE_PATH := "user://sect_source_a_actor_pilot_test.json"
var scene: Control

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var capture_path := OS.get_environment("SOURCE_A_MALE_CAPTURE")
    if not capture_path.is_empty():
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(Vector2i(1280,720))
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
    var male_id: StringName = &""
    var female_count := 0
    for key in actors.keys():
        var actor := actors[key] as ModularDiscipleActor
        var disciple := state.disciples.get(StringName(key)) as DiscipleState
        if actor == null or disciple == null:
            _fail("map actor lost canonical disciple identity")
            return
        # Real Source A art remains stand/walk; the visible status caption
        # must contrast against the map and must not extend beyond the actor.
        if (
            actor.status_label == null
            or actor.status_label.get_theme_font_size("font_size") < 11
            or not (actor.status_label.get_theme_stylebox("normal") is StyleBoxFlat)
            or not actor.status_label.clip_text
        ):
            _fail("actor map work status lacks readable bounded background")
            return
        if actor.baked_visual_active():
            var expected := DiscipleSourceAVisualPool.scene_path_for_disciple(disciple)
            var visual_sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple))
            if expected.is_empty() or (visual_sex == "female") != (actor.rig_id == DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1):
                _fail("Source A actor does not match canonical visual sex")
                return
            if visual_sex == "male":
                male_id = disciple.id
            else:
                female_count += 1
            if actor.fallback_visual.visible or actor.baked_sprite.position != DiscipleActorVisualCatalog.ACTOR_FOOT_POINT:
                _fail("baked pilot did not replace fallback at foot anchor")
                return
            var stand := actor.baked_sprite.sprite_frames.get_frame_texture(&"stand",0)
            if stand == null or absf(actor.baked_sprite.scale.x * stand.get_height()-67.0) > 0.1 or actor.z_index >= 20:
                _fail("baked actor size/layer obscures map UI")
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
    if not capture_path.is_empty():
        if male_id == &"" or female_count == 0:
            _fail("capture requires real male and female map actors")
            return
        scene.call("_open_disciple_deep_screen",male_id,"Thuộc tính")
        for _i in range(20):
            await process_frame
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        if image == null or image.get_size() != Vector2i(1280,720) or image.save_png(capture_path) != OK:
            _fail("native 1280x720 male profile capture failed")
            return
        print("SOURCE A MALE CAPTURE PASS ",capture_path)
    print("SOURCE A ACTOR PILOT REAL SCENE PASS baked_actors=",pilot_count)
    scene.queue_free()
    quit(0)

func _fail(reason: String) -> void:
    push_error("SOURCE A ACTOR PILOT FAIL: "+reason)
    if scene != null:
        scene.queue_free()
    quit(1)
