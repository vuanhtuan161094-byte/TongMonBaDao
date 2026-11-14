extends RefCounted
## VIS-01/02: one read-only palette for actual disciple quality IDs.
## No candidate generation, rarity rolls, saves, stats or combat dependencies.
const TEXT_SHADER = preload("res://src/presentation/uiux/shaders/vis01_prismatic_text.gdshader")
const EDGE_SHADER = preload("res://src/presentation/uiux/shaders/vis02_crystal_edge.gdshader")
const QUALITY_COLORS := {
    "common": Color(0.92, 0.89, 0.82),
    "outstanding": Color(0.48, 0.82, 0.90),
    "prodigy": Color(0.76, 0.61, 0.99),
    "peerless": Color(1.00, 0.82, 0.48),
    "heaven_defying": Color(0.96, 0.92, 0.81)
}
const QUALITY_NAMES := {
    "common": "Phàm Thường",
    "outstanding": "Xuất Chúng",
    "prodigy": "Thiên Kiêu",
    "peerless": "Tuyệt Luân",
    "heaven_defying": "Nghịch Thiên"
}
static var reduced_motion: bool = false
static var effects_enabled: bool = true

static func id_from_name(value: String) -> String:
    for id in QUALITY_NAMES:
        if str(QUALITY_NAMES[id]) == value or str(id) == value:
            return str(id)
    return ""

static func color_for(quality_id: String) -> Color:
    return QUALITY_COLORS.get(quality_id, Color(0.84, 0.85, 0.80))

static func apply_name(label: Label, quality_id: String) -> void:
    if label == null:
        return
    label.add_theme_color_override("font_color", color_for(quality_id))
    label.add_theme_color_override("font_outline_color", Color(0.025, 0.04, 0.055, 0.84))
    label.add_theme_constant_override("outline_size", 1)
    label.material = null
    if quality_id == "heaven_defying" and effects_enabled and not reduced_motion:
        var material := ShaderMaterial.new()
        material.shader = TEXT_SHADER
        label.material = material

static func apply_button(button: Button, quality_id: String) -> void:
    if button == null:
        return
    var color := color_for(quality_id)
    button.add_theme_color_override("font_color", color)
    button.add_theme_color_override("font_hover_color", color.lightened(0.12))
    button.add_theme_color_override("font_outline_color", Color(0.025,0.04,0.055,0.86))
    button.add_theme_constant_override("outline_size", 1)

static func frame_style(quality_id: String, background: Color, selected: bool = false) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = background
    style.border_color = color_for(quality_id)
    style.set_border_width_all(3 if selected else 2)
    style.set_corner_radius_all(10)
    style.shadow_color = Color(0.025, 0.045, 0.055, 0.42)
    style.shadow_size = 3
    style.content_margin_left = 8
    style.content_margin_right = 8
    style.content_margin_top = 7
    style.content_margin_bottom = 7
    return style

static func apply_edge(owner: Control, quality_id: String, permit_motion: bool = true) -> void:
    if owner == null:
        return
    var overlay := owner.get_node_or_null("VIS02QualityEdge") as ColorRect
    if overlay == null:
        overlay = ColorRect.new()
        overlay.name = "VIS02QualityEdge"
        overlay.color = Color.WHITE
        overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
        owner.add_child(overlay)
        overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    if overlay.material == null:
        var material := ShaderMaterial.new()
        material.shader = EDGE_SHADER
        overlay.material = material
    var shader_material := overlay.material as ShaderMaterial
    shader_material.set_shader_parameter("quality_color", color_for(quality_id))
    shader_material.set_shader_parameter("divine", 1.0 if quality_id == "heaven_defying" else 0.0)
    shader_material.set_shader_parameter("motion", 1.0 if permit_motion and effects_enabled and not reduced_motion else 0.0)
    overlay.visible = effects_enabled or quality_id != "heaven_defying"

static func wrap_portrait(slot: Control, dimensions: Vector2, quality_id: String) -> Control:
    # Artwork remains in the original TextureRect; shader lives on a sibling edge.
    var host := Control.new()
    host.name = "VIS02PortraitHost"
    host.custom_minimum_size = dimensions
    host.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    host.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    host.add_child(slot)
    slot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    apply_edge(host, quality_id)
    return host
