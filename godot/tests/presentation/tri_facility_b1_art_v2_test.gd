extends SceneTree
## TRI-02 visual contract: original buildings are exact-SHA Source A sprites; candidate art stays anonymous.
const ART = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const SOURCE_A = preload("res://src/presentation/p3/sect_map25_source_art.gd")
const ISO_WORLD = preload("res://src/presentation/p3/sect_isometric_world_v1.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("TRI_B1_ART_V2_FAIL: " + message)
    quit(1)

func _run() -> void:
    var gate = SOURCE_A.new()
    var required_sources := {
        "hall": {"relative":"pv01_assets/main_hall/510052.png","model":"510052"},
        "residence": {"relative":"pv01_assets/residence/510076.png","model":"510076"},
        "guidance": {"relative":"pv01_assets/guidance/510111.png","model":"510111"}
    }
    for kind in required_sources:
        var spec: Dictionary = required_sources[kind]
        var source_texture: Texture2D = gate.texture_for(str(spec["relative"]))
        if source_texture == null:
            _fail("required Source A model %s failed SHA-gated import" % spec["model"])
            return
        var map_key := str(ISO_WORLD.HOUSE_TEXTURES.get(kind,""))
        if map_key != str(spec["relative"]):
            _fail("%s map renderer did not point to its verified Source A model" % kind)
            return
        var target_size: Vector2 = ISO_WORLD.HOUSE_SIZES[kind]
        var source_ratio := float(source_texture.get_width()) / float(source_texture.get_height())
        var target_ratio := target_size.x / target_size.y
        if absf(source_ratio-target_ratio) > 0.01:
            _fail("%s map render target would distort its source sprite" % kind)
            return

    for kind in ["hall","residence","guidance","candidate"]:
        var art = ART.new()
        art.facility_kind = kind
        art.custom_minimum_size = Vector2(340,165)
        root.add_child(art)
        art.size = Vector2(340,165)
        await process_frame
        var rendered: Variant = art.get("_art")
        if not (rendered is Texture2D) or rendered.get_width() < 100 or rendered.get_height() < 100:
            _fail("%s must show an imported texture, not a legacy QA glyph" % kind)
            return
        var original := bool(art.get("_original_source"))
        if kind == "candidate":
            if original or str(art.get("_source_model_id")) != "":
                _fail("candidate must stay an anonymous non-Source-A fallback until an approved portrait exists")
                return
        elif not original or str(art.get("_source_model_id")) != str(required_sources[kind]["model"]):
            _fail("%s did not resolve to its verified Source A building sprite" % kind)
            return
        art.queue_free()
        await process_frame
    print("TRI_B1_ART_V2_PASS source_a_models=510052,510076,510111 candidate=anonymous_fallback")
    quit(0)
