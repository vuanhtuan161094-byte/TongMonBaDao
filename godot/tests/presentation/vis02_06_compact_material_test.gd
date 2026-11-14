extends SceneTree
## One compact Godot QA gate for VIS02-R2 / VIS04, alongside existing VIS01.
const VIS = preload("res://src/presentation/uiux/sect_quality_visual_v1.gd")
const EQUIPMENT = preload("res://src/presentation/uiux/sect_equipment_material_v1.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    assert(EQUIPMENT.GRADE_COLORS.size() == 3)
    assert(not EQUIPMENT.GRADE_COLORS.has("heaven_defying"))
    assert(EQUIPMENT.color_for("pham") != EQUIPMENT.color_for("thuong"))
    var host := Control.new()
    host.size = Vector2(180, 196)
    root.add_child(host)
    VIS.effects_enabled = true
    VIS.reduced_motion = false
    VIS.apply_edge(host, "heaven_defying")
    var art := host.get_node_or_null("VIS02CrystalArtwork") as NinePatchRect
    assert(art != null and art.texture != null and not art.draw_center)
    assert(art.mouse_filter == Control.MOUSE_FILTER_IGNORE)
    VIS.reduced_motion = true
    VIS.apply_edge(host, "heaven_defying")
    assert(art.visible and art.modulate.a < 1.0)
    VIS.effects_enabled = false
    VIS.apply_edge(host, "heaven_defying")
    assert(not art.visible)
    VIS.effects_enabled = true
    VIS.reduced_motion = false
    host.queue_free()
    print("VIS02_06_COMPACT_MATERIAL PASS artwork=SVG quality_isolation=TRUE")
    quit(0)
