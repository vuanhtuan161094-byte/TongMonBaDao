extends SceneTree

var actor: ModularDiscipleActor

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var missing := FemaleStageAAssetLoader.missing_down_paths()
    if not missing.is_empty():
        _fail("Stage A down asset pack is not installed. Missing: %s" % ", ".join(missing))
        return

    for path in FemaleStageAAssetLoader.required_down_paths():
        var texture := load(path) as Texture2D
        if texture == null:
            _fail("Stage A texture failed to load: %s" % path)
            return
        if texture.get_width() != 128 or texture.get_height() != 128:
            _fail("Stage A texture must remain 128x128: %s" % path)
            return

    actor = ModularDiscipleActor.new()
    root.add_child(actor)
    var result := FemaleStageAAssetLoader.apply_down(actor)
    if int(result.get("applied", 0)) != FemaleStageAAssetLoader.DOWN_COMPONENTS.size():
        _fail("Stage A did not attach all down/front components: %s" % str(result))
        return
    if not actor.production_body_active():
        _fail("Stage A body did not replace placeholder mode.")
        return
    if actor.visual_components.size() != FemaleStageAAssetLoader.DOWN_COMPONENTS.size():
        _fail("Stage A component count changed after attachment.")
        return
    if actor.facing != DiscipleActorVisualCatalog.DIR_DOWN:
        _fail("Stage A pivot-lock proof must remain in down/front facing.")
        return
    if DiscipleActorVisualCatalog.SOURCE_FRAME_SIZE != Vector2(128.0, 128.0):
        _fail("Stage A canvas drifted from 128x128.")
        return
    if DiscipleActorVisualCatalog.SOURCE_FOOT_POINT != Vector2(64.0, 104.0):
        _fail("Stage A foot anchor drifted from (64,104).")
        return

    print("P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS")
    actor.queue_free()
    await process_frame
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    if actor != null:
        actor.queue_free()
    quit(1)
