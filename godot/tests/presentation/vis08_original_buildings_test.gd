extends SceneTree
const CUSTOM = preload("res://src/presentation/p3/tmb_original_building_art_v5.gd")
const V3 = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    var expected := {
        "main_hall": Vector2i(300,201),
        "residence": Vector2i(174,135),
        "warehouse": Vector2i(162,138),
        "forge": Vector2i(205,164),
        "guidance": Vector2i(182,203)
    }
    for kind in expected:
        var tex: Texture2D = CUSTOM.texture_for(StringName(kind))
        assert(tex != null and tex.get_size() == Vector2(expected[kind]), "Missing or wrong-size original sprite: "+kind)
        var image := tex.get_image()
        assert(image != null and image.get_pixel(0,0).a < 0.05,"Alpha failure: "+kind)
    assert(V3.all_paths().size() == 12, "Previously completed 12 producer sprites must stay intact")
    print("VIS08_ART_IMPORT_PASS five original building sprites; V3 12 intact")
    quit(0)
