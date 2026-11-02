extends SceneTree
## TRI-02 visual contract: original buildings are exact-SHA Source A sprites; candidate art stays anonymous.
const ART = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const SOURCE_A = preload("res://src/presentation/p3/sect_map25_source_art.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("TRI_B1_ART_V2_FAIL: " + message)
    quit(1)

func _run() -> void:
    var gate = SOURCE_A.new()
    var required_sources := {
        "hall": {"relative":"pv01_assets/main_hall/510052.png","model":"510052","size":Vector2i(1104,740)},
        "residence": {"relative":"pv01_assets/residence/510076.png","model":"510076","size":Vector2i(536,416)},
        "guidance": {"relative":"pv01_assets/guidance/510111.png","model":"510111","size":Vector2i(532,592)}
    }
    for kind in required_sources:
        var spec: Dictionary = required_sources[kind]
        var source_texture: Texture2D = gate.texture_for(str(spec["relative"]))
        if source_texture == null:
            _fail("required Source A model %s failed SHA-gated import" % spec["model"])
            return
        if source_texture.get_size() != spec["size"]:
            _fail("Source A model %s imported at unexpected dimensions %s" % [spec["model"],source_texture.get_size()])
            return
        var source_path := "res://art/source_a_env02a/" + str(spec["relative"])
        var source_image := Image.load_from_file(ProjectSettings.globalize_path(source_path))
        if source_image == null or source_image.is_empty() or not source_image.has_alpha():
            _fail("Source A model %s lost its imported alpha channel" % spec["model"])
            return
        source_image.convert(Image.FORMAT_RGBA8)
        var rgba: PackedByteArray = source_image.get_data()
        var image_width: int = source_image.get_width()
        var has_clear := false
        var has_opaque := false
        var has_semitransparent := false
        for y in range(0,source_image.get_height(),8):
            for x in range(0,image_width,8):
                var alpha_byte: int = rgba[(y*image_width+x)*4+3]
                var alpha: float = float(alpha_byte)/255.0
                has_clear = has_clear or alpha_byte <= 0
                has_opaque = has_opaque or alpha_byte >= 255
                has_semitransparent = has_semitransparent or (alpha_byte > 0 and alpha_byte < 255)
                if has_clear and has_opaque and has_semitransparent:
                    break
            if has_clear and has_opaque and has_semitransparent:
                break
        if not has_clear or not has_opaque or not has_semitransparent:
            _fail("Source A model %s lost transparency or antialiasing" % spec["model"])
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
