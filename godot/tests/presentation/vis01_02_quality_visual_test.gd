extends SceneTree
## VIS-01/02 focused real-engine presentation test; no mutation of any game state.
const VIS = preload("res://src/presentation/uiux/sect_quality_visual_v1.gd")
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    assert(VIS.QUALITY_COLORS.size() == 5)
    for quality_id in ["common", "outstanding", "prodigy", "peerless", "heaven_defying"]:
        assert(VIS.id_from_name(VIS.QUALITY_NAMES[quality_id]) == quality_id)
        var label := Label.new()
        root.add_child(label)
        VIS.apply_name(label, quality_id)
        assert(label.get_theme_color("font_color") == VIS.color_for(quality_id))
        if quality_id == "heaven_defying":
            assert(label.material is ShaderMaterial)
        else:
            assert(label.material == null)
        var slot := ColorRect.new()
        var wrapped := VIS.wrap_portrait(slot, Vector2(82, 96), quality_id)
        root.add_child(wrapped)
        assert(wrapped.get_node_or_null("VIS02QualityEdge") != null)
        assert(slot.material == null, "Portrait/source image must never be shaded")
        var edge := wrapped.get_node("VIS02QualityEdge") as ColorRect
        assert(edge.material is ShaderMaterial)
        VIS.reduced_motion = true
        VIS.apply_edge(wrapped, quality_id)
        assert((edge.material as ShaderMaterial).get_shader_parameter("motion") == 0.0)
        VIS.reduced_motion = false
        wrapped.queue_free()
        label.queue_free()
    var heaven := Label.new()
    root.add_child(heaven)
    VIS.reduced_motion = true
    VIS.apply_name(heaven, "heaven_defying")
    assert(heaven.material == null and heaven.get_theme_color("font_color") == VIS.color_for("heaven_defying"))
    VIS.reduced_motion = false
    assert(VIS.mode_label() == "ĐẦY ĐỦ")
    VIS.cycle_mode()
    assert(VIS.reduced_motion and VIS.effects_enabled and VIS.mode_label() == "GIẢM")
    VIS.cycle_mode()
    assert(not VIS.effects_enabled and VIS.mode_label() == "TẮT")
    VIS.cycle_mode()
    assert(VIS.effects_enabled and not VIS.reduced_motion and VIS.mode_label() == "ĐẦY ĐỦ")
    var host := Control.new()
    host.size = Vector2(180, 210)
    root.add_child(host)
    VIS.apply_backlight(host, Rect2(Vector2.ZERO, host.size), "heaven_defying")
    assert(host.find_child("VIS02SoftBacklight", true, false) != null)
    VIS.apply_edge(host, "heaven_defying")
    assert(host.find_child("VIS02AstralMotes", true, false) != null)
    VIS.reduced_motion = true
    VIS.apply_edge(host, "heaven_defying")
    assert(not (host.find_child("VIS02AstralMotes", true, false) as Control).visible)
    VIS.reduced_motion = false
    host.queue_free()
    heaven.queue_free()
    print("VIS01_VIS02_PRESENTATION_CONTRACT PASS quality_ids=5 motion_toggle=PASS gameplay_unchanged=BY_DESIGN")
    quit(0)
