extends SceneTree

var actor: ModularDiscipleActor

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var library := FemaleNormalV1MotionLibrary.build()
    if library == null:
        _fail("Female motion library was not created.")
        return

    var expected := [
        &"idle_down", &"walk_down",
        &"idle_right", &"walk_right",
        &"idle_up", &"walk_up"
    ]
    if FemaleNormalV1MotionLibrary.required_animation_names() != expected:
        _fail("Shared motion animation-name contract changed.")
        return

    for name in expected:
        if not library.has_animation(name):
            _fail("Missing shared motion animation: %s" % str(name))
            return
        var animation := library.get_animation(name)
        if animation == null:
            _fail("Could not resolve shared motion animation: %s" % str(name))
            return
        if animation.loop_mode != Animation.LOOP_LINEAR:
            _fail("%s must loop." % str(name))
            return
        if animation.length <= 0.0:
            _fail("%s has invalid length." % str(name))
            return
        var minimum_tracks := 5 if str(name).begins_with("idle_") else 7
        if animation.get_track_count() < minimum_tracks:
            _fail("%s does not animate enough shared-rig channels." % str(name))
            return

    if library.has_animation(&"idle_left") or library.has_animation(&"walk_left"):
        _fail("V1 left must reuse mirrored RIGHT motion instead of authored duplicate clips.")
        return

    actor = ModularDiscipleActor.new()
    root.add_child(actor)
    actor.set_animation_library(library)

    var down_result := FemaleStageAAssetLoader.apply_public_direction(actor, &"down")
    if int(down_result.get("applied", 0)) != 14:
        _fail("DOWN appearance failed to attach for motion proof.")
        return
    actor.current_clip = &"idle"
    actor.set_facing_from_delta(Vector2(0.0, 1.0))
    if actor.current_playback_animation_name() != &"idle_down":
        _fail("DOWN idle did not resolve to idle_down.")
        return
    if actor.animation_player.current_animation != &"idle_down":
        _fail("AnimationPlayer did not start idle_down.")
        return

    var right_result := FemaleStageAAssetLoader.apply_public_direction(actor, &"right")
    if int(right_result.get("applied", 0)) != 14:
        _fail("RIGHT appearance failed to attach for motion proof.")
        return
    actor.play_walk_for_delta(Vector2(1.0, 0.0))
    if actor.current_playback_animation_name() != &"walk_right":
        _fail("RIGHT walk did not resolve to walk_right.")
        return
    if actor.animation_player.current_animation != &"walk_right":
        _fail("AnimationPlayer did not start walk_right.")
        return

    var up_result := FemaleStageAAssetLoader.apply_public_direction(actor, &"up")
    if int(up_result.get("applied", 0)) != 14:
        _fail("UP appearance failed to attach for motion proof.")
        return
    actor.play_walk_for_delta(Vector2(0.0, -1.0))
    if actor.current_playback_animation_name() != &"walk_up":
        _fail("UP walk did not resolve to walk_up.")
        return

    var left_result := FemaleStageAAssetLoader.apply_public_direction(actor, &"left")
    if int(left_result.get("applied", 0)) != 14:
        _fail("LEFT mirror appearance failed to reuse RIGHT assets.")
        return
    actor.play_walk_for_delta(Vector2(-1.0, 0.0))
    if actor.facing != &"left" or not actor.uses_mirrored_left():
        _fail("LEFT public direction did not activate mirrored RIGHT rig.")
        return
    if actor.current_animation_name() != &"walk_left":
        _fail("Public LEFT animation name must remain walk_left.")
        return
    if actor.current_playback_animation_name() != &"walk_right":
        _fail("Mirrored LEFT playback must reuse walk_right.")
        return
    if actor.animation_player.current_animation != &"walk_right":
        _fail("AnimationPlayer did not reuse walk_right for LEFT.")
        return
    if actor.rig_root.scale.x >= 0.0:
        _fail("LEFT rig was not visually mirrored.")
        return

    print("P3.2 FEMALE SHARED IDLE WALK MOTION CONTRACT TEST PASS")
    actor.queue_free()
    await process_frame
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    if actor != null:
        actor.queue_free()
    quit(1)
