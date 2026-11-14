extends SceneTree
## VIS-09 2D: original sprite pixels and actual map-size gate.
const ART = preload("res://src/presentation/p3/tmb_handpaint_building_art_v6.gd")
const OLD = preload("res://src/presentation/p3/tmb_original_building_art_v5.gd")
const V3 = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for kind in [&"main_hall",&"mine"]:
        var tex := ART.texture_for(kind)
        assert(tex != null,"Missing VIS09 art: "+str(kind))
        var expected := Vector2i(300,201) if kind == &"main_hall" else Vector2i(166,121)
        assert(Vector2i(tex.get_width(),tex.get_height()) == expected,"Map-sized art mismatch: "+str(kind))
        var pixels := tex.get_image()
        assert(pixels != null and pixels.get_pixel(0,0).a < 0.04)
        assert(pixels.get_pixel(expected.x-1,expected.y-1).a < 0.04)
        assert(pixels.get_pixel(expected.x/2,expected.y/2).a > 0.30,"Missing rendered sprite body: "+str(kind))
    for kind in [&"residence",&"warehouse",&"forge",&"guidance"]:
        assert(OLD.texture_for(kind) != null,"Do not drop previously integrated buildings")
    assert(V3.all_paths().size() == 12)
    print("VIS09_HANDPAINT_NATIVE PASS hall=300x201 mine=166x121 alpha=PASS old_family=4 v3=12")
    quit(0)
