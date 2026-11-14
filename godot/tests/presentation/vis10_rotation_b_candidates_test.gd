extends SceneTree
## Targeted PNG alpha/dimensions and preview OFF-by-default contract.
const B = preload("res://src/presentation/p3/tmb_rotation_b_candidate_v1.gd")
const V3 = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for kind in B.TARGET_SIZES:
        var tex := B.texture_for(StringName(kind))
        assert(tex != null, "Missing B candidate: "+kind)
        assert(tex.get_size() == Vector2(B.TARGET_SIZES[kind]))
        var img := tex.get_image()
        assert(img != null and img.get_pixel(0,0).a < 0.05,
            "B PNG needs alpha, not a presentation-board background: "+kind)
    assert(V3.all_paths().size() == 12, "V3 A/B idle/active pack must stay intact")
    var world := SectIsometricWorldV1.new()
    assert(not world.vis10_b_preview_enabled,
        "No B draft may replace approved art automatically")
    assert(not world.set_visual_rotation_preview(&"nonexistent",&"B"),
        "Preview must reject absent building ids")
    assert(not world.set_visual_rotation_preview(&"nonexistent",&"C"),
        "Rotation is two-view only")
    world.free()
    print("VIS10_B_CANDIDATES_6_OF_6_IMPORT_ALPHA_PASS; B_OWNER_VISUAL_PENDING; GAME_A_UNCHANGED")
    quit(0)
