extends SceneTree
## TRI-01 visual-only art contract. Never touches saves, live economy or recruitment.
const ART = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const SOURCE_A = preload("res://src/presentation/p3/sect_map25_source_art.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("TRI_B1_ART_V2_FAIL: " + message)
    quit(1)

func _run() -> void:
    var gate = SOURCE_A.new()
    var verified_hall: Texture2D = gate.texture_for("pv01_assets/main_hall/510052.png")
    for kind in ["hall", "residence", "guidance"]:
        var art = ART.new()
        art.facility_kind = kind
        art.custom_minimum_size = Vector2(340, 165)
        root.add_child(art)
        art.size = Vector2(340, 165)
        await process_frame
        var rendered: Variant = art.get("_art")
        if not (rendered is Texture2D) or rendered.get_width() < 100 or rendered.get_height() < 100:
            _fail("%s must have a genuine imported texture, not the legacy QA glyph" % kind)
            return
        var original: bool = bool(art.get("_original_source"))
        if kind == "hall" and original != (verified_hall != null):
            _fail("Hall must follow Source A exact-SHA verification; no unchecked source image")
            return
        if kind != "hall" and original:
            _fail("Unverified Source A provenance on %s" % kind)
            return
        art.queue_free()
        await process_frame
    print("TRI_B1_ART_V2_PASS source_a_hall=%s svg_residence=1 svg_guidance=1" % str(verified_hall != null))
    quit(0)
