extends SceneTree
## VIS11 12 exact-sheet A/B source cutouts; strict alpha and native QA.
const ART = preload("res://src/presentation/p3/tmb_building_art_ab_v7.gd")
const V3 = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    assert(ART.all_paths().size() == 12)
    for kind in ART.TARGET_SIZE:
        var a := ART.texture_for(StringName(kind),&"A")
        var b := ART.texture_for(StringName(kind),&"B")
        assert(a != null and b != null,"Missing native A/B PNG: "+kind)
        assert(Vector2i(a.get_width(),a.get_height()) == ART.TARGET_SIZE[kind])
        assert(Vector2i(b.get_width(),b.get_height()) == ART.TARGET_SIZE[kind])
        var img_a := a.get_image()
        var img_b := b.get_image()
        assert(img_a != null and img_b != null)
        assert(img_a.get_pixel(0,0).a < 0.05 and img_b.get_pixel(0,0).a < 0.05)
        assert(img_a.get_data() != img_b.get_data(),"A and B cannot be duplicates")
    assert(ART.texture_for(&"unknown",&"B") == null)
    assert(ART.texture_for(&"main_hall",&"C") == null)
    assert(V3.all_paths().size() == 12,"Existing three producer families untouched")
    print("VIS11_12_AB_NATIVE_PNG_ALPHA_IMPORT_PASS; V3_12_PRESERVED")
    quit(0)
