extends RefCounted
## VIS-01/02: one read-only palette for actual disciple quality IDs.
## No candidate generation, rarity rolls, saves, stats or combat dependencies.
const TEXT_SHADER = preload("res://src/presentation/uiux/shaders/vis01_prismatic_text.gdshader")
const EDGE_SHADER = preload("res://src/presentation/uiux/shaders/vis02_crystal_edge.gdshader")
const AURA_SHADER = preload("res://src/presentation/uiux/shaders/vis02_soft_aura.gdshader")
const MOTES_SCRIPT = preload("res://src/presentation/uiux/sect_prismatic_motes_v1.gd")
const CRYSTAL_ART: Texture2D = preload("res://art/uiux/quality/vis02_heaven_crystal_frame.svg")
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

static func mode_label() -> String:
    if not effects_enabled:
        return "TẮT"
    return "GIẢM" if reduced_motion else "ĐẦY ĐỦ"

static func cycle_mode() -> void:
    if not effects_enabled:
        effects_enabled = true
        reduced_motion = false
    elif reduced_motion:
        effects_enabled = false
        reduced_motion = true
    else:
        reduced_motion = true

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

static func apply_frame_material(panel: Control, quality_id: String) -> void:
    if panel == null:
        return
    var original := panel.get_theme_stylebox("panel") as StyleBoxFlat
    if original == null:
        return
    var style := original.duplicate() as StyleBoxFlat
    var divine := quality_id == "heaven_defying"
    style.border_color = Color(0.65,0.87,0.90) if divine else color_for(quality_id)
    style.set_border_width_all(3 if divine else 2)
    if divine and effects_enabled:
        style.shadow_color = Color(0.45,0.75,0.76,0.33)
        style.shadow_size = 7
    panel.add_theme_stylebox_override("panel",style)

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
    # VIS-02 R2: original transparent-cut nine-slice crystal art; never tint
    # or replace source portraits, keep the midsection entirely transparent.
    var crystal := owner.get_node_or_null("VIS02CrystalArtwork") as NinePatchRect
    if quality_id == "heaven_defying" and crystal == null:
        crystal = NinePatchRect.new()
        crystal.name = "VIS02CrystalArtwork"
        crystal.texture = CRYSTAL_ART
        crystal.draw_center = false
        crystal.patch_margin_left = 32
        crystal.patch_margin_right = 32
        crystal.patch_margin_top = 32
        crystal.patch_margin_bottom = 32
        crystal.mouse_filter = Control.MOUSE_FILTER_IGNORE
        owner.add_child(crystal)
        crystal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    if crystal != null:
        crystal.visible = quality_id == "heaven_defying" and effects_enabled
        crystal.modulate.a = 0.76 if reduced_motion else 1.0
    var motes := owner.get_node_or_null("VIS02AstralMotes") as Control
    if quality_id == "heaven_defying" and effects_enabled:
        if motes == null:
            motes = MOTES_SCRIPT.new()
            motes.name = "VIS02AstralMotes"
            motes.mouse_filter = Control.MOUSE_FILTER_IGNORE
            owner.add_child(motes)
            motes.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        motes.set("motion_enabled", not reduced_motion)
        motes.visible = not reduced_motion
    elif motes != null:
        motes.visible = false

static func apply_backlight(owner: Control, area: Rect2, quality_id: String) -> void:
    if owner == null:
        return
    var halo := owner.get_node_or_null("VIS02SoftBacklight") as ColorRect
    if halo == null and quality_id == "heaven_defying":
        halo = ColorRect.new()
        halo.name = "VIS02SoftBacklight"
        halo.color = Color.WHITE
        halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var material := ShaderMaterial.new()
        material.shader = AURA_SHADER
        halo.material = material
        owner.add_child(halo)
        owner.move_child(halo, 0)
    if halo != null:
        halo.position = area.position
        halo.size = area.size
        halo.visible = quality_id == "heaven_defying" and effects_enabled
        (halo.material as ShaderMaterial).set_shader_parameter("motion", 0.0 if reduced_motion else 1.0)

static func wrap_portrait(slot: Control, dimensions: Vector2, quality_id: String) -> Control:
    # Artwork remains in the original TextureRect; shader lives on a sibling edge.
    var host := Control.new()
    host.name = "VIS02PortraitHost"
    host.custom_minimum_size = dimensions
    host.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    host.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    host.add_child(slot)
    slot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    if slot is PanelContainer:
        apply_frame_material(slot as PanelContainer, quality_id)
    apply_edge(host, quality_id)
    apply_backlight(slot, Rect2(Vector2.ZERO, dimensions), quality_id)
    return host
