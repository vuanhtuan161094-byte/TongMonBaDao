extends SceneTree

var actor: ModularDiscipleActor

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if DiscipleActorVisualCatalog.SOURCE_FRAME_SIZE != Vector2(128.0, 128.0):
        _fail("Stage A canvas drifted from 128x128.")
        return
    if DiscipleActorVisualCatalog.SOURCE_FOOT_POINT != Vector2(64.0, 104.0):
        _fail("Stage A foot anchor drifted from (64,104).")
        return
    if not FemaleStageAAssetLoader.components_for_direction(&"left").is_empty():
        _fail("Stage A V1 left must remain mirror-right, not a required authored asset set.")
        return

    actor = ModularDiscipleActor.new()
    root.add_child(actor)

    for direction in FemaleStageAAssetLoader.AUTHORED_DIRECTIONS:
        var components := FemaleStageAAssetLoader.components_for_direction(direction)
        if components.size() != 14:
            _fail("Stage A %s component count must remain 14, got %d." % [str(direction), components.size()])
            return

        var missing := FemaleStageAAssetLoader.missing_paths(direction)
        if not missing.is_empty():
            _fail("Stage A %s asset pack is not installed. Missing: %s" % [str(direction), ", ".join(missing)])
            return

        for path in FemaleStageAAssetLoader.required_paths(direction):
            var texture := load(path) as Texture2D
            if texture == null:
                _fail("Stage A %s texture failed to load: %s" % [str(direction), path])
                return
            if texture.get_width() != 128 or texture.get_height() != 128:
                _fail("Stage A %s texture must remain 128x128: %s" % [str(direction), path])
                return

        var result := FemaleStageAAssetLoader.apply_direction(actor, direction)
        if int(result.get("applied", 0)) != components.size():
            _fail("Stage A %s did not attach all components: %s" % [str(direction), str(result)])
            return
        if not actor.production_body_active():
            _fail("Stage A %s body did not replace placeholder mode." % str(direction))
            return
        if actor.visual_components.size() != components.size():
            _fail("Stage A %s component count changed after attachment." % str(direction))
            return
        if actor.facing != direction:
            _fail("Stage A actor facing mismatch. Expected %s, got %s." % [str(direction), str(actor.facing)])
            return

    print("P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS")
    actor.queue_free()
    await process_frame
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    if actor != null:
        actor.queue_free()
    quit(1)
