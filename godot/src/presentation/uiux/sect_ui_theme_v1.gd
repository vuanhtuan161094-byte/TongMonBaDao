extends RefCounted
## Shared, presentation-only styles and compact controls for the three facility screens.
## All values shown by these helpers are supplied by the host screen/view model.

const INK := Color(0.98,0.97,0.93)
const DEEP := Color(0.91,0.89,0.83)
const SURFACE := Color(0.98,0.97,0.93)
const SURFACE_LIGHT := Color(0.94,0.93,0.88)
const PAPER := Color(0.22,0.24,0.20)
const TEXT := Color(0.19,0.22,0.20)
const MUTED := Color(0.38,0.40,0.34)
const JADE := Color(0.24,0.43,0.34)
const GOLD := Color(0.52,0.37,0.17)
const RED := Color(0.65,0.21,0.16)
const BLUE := Color(0.24,0.43,0.54)
const BORDER := Color(0.72,0.67,0.56,0.70)

const ICON_SCRIPT = preload("res://src/presentation/uiux/sect_ui_icon_v1.gd")
const ILLUSTRATION_SCRIPT = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")

static func panel(node_name: String, accent: Color, tone: Color) -> PanelContainer:
	var result := PanelContainer.new()
	result.name = node_name
	var style := StyleBoxFlat.new()
	style.bg_color = tone
	style.border_color = accent
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0.27,0.23,0.16,0.12)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0, 3)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	result.add_theme_stylebox_override("panel", style)
	return result

static func label(text_value: String, font_size: int, color: Color, bold: bool) -> Label:
	var result := Label.new()
	result.text = text_value
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	if bold:
		var font := FontVariation.new()
		font.base_font = ThemeDB.fallback_font
		font.variation_embolden = 0.32
		result.add_theme_font_override("font",font)
	result.add_theme_constant_override("outline_size",0)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result

static func button(text_value: String, primary: bool, accent: Color) -> Button:
	var result := Button.new()
	result.text = text_value
	result.custom_minimum_size = Vector2(52, 48)
	result.focus_mode = Control.FOCUS_ALL
	result.add_theme_font_size_override("font_size", 15)
	result.add_theme_color_override("font_color", INK if primary else TEXT)
	result.add_theme_color_override("font_hover_color", INK if primary else PAPER)
	result.add_theme_color_override("font_pressed_color", INK if primary else PAPER)
	result.add_theme_color_override("font_disabled_color", Color(0.48,0.46,0.41))
	result.add_theme_constant_override("outline_size",0)
	result.add_theme_stylebox_override("normal", _button_style(primary, accent, 0.78))
	result.add_theme_stylebox_override("hover", _button_style(primary, accent, 0.98))
	result.add_theme_stylebox_override("pressed", _button_style(primary, accent, 0.60))
	result.add_theme_stylebox_override("disabled", _button_style(false, BORDER, 0.35))
	return result

static func section_heading(title: String, icon_kind: String, accent: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(icon(icon_kind, 26, accent))
	var title_label := label(title, 17, PAPER, true)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_label)
	return row

static func icon(icon_kind: String, size: int = 24, accent: Color = GOLD) -> Control:
	var result = ICON_SCRIPT.new()
	result.kind = icon_kind
	result.tint = accent
	result.custom_minimum_size = Vector2(size, size)
	return result

static func metric_card(title: String, value: String, icon_kind: String, accent: Color) -> PanelContainer:
	var card := panel("MetricCard", accent, SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(142, 66)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	row.add_child(icon(icon_kind, 30, accent))
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 1)
	var title_label := label(title, 12, MUTED, false)
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_label.tooltip_text = title
	stack.add_child(title_label)
	var value_label := label(value, 19, TEXT, true)
	value_label.tooltip_text = value
	value_label.name = "MetricValue"
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	stack.add_child(value_label)
	row.add_child(stack)
	card.add_child(row)
	return card

static func portrait_slot(display_name: String, texture_value: Variant, size: Vector2) -> PanelContainer:
	var card := panel("PortraitSlot", GOLD, SURFACE_LIGHT)
	card.custom_minimum_size = size
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if texture_value is Texture2D:
		var texture_rect := TextureRect.new()
		texture_rect.texture = texture_value
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card.add_child(texture_rect)
	else:
		# Do not render the repeated first letter of "Chưa bổ nhiệm" as a fake portrait.
		# A neutral silhouette is used only when the host supplies no real texture.
		var silhouette_size := int(clampf(minf(size.x, size.y) * 0.42, 32.0, 72.0))
		var placeholder := icon("person", silhouette_size, MUTED if display_name.is_empty() or display_name == "Chưa bổ nhiệm" else GOLD)
		placeholder.name = "UnassignedPortraitGlyph"
		placeholder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		placeholder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		card.add_child(placeholder)
	return card

static func resource_item(resource_name: String, amount: String, icon_kind: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(icon(icon_kind, 22, GOLD))
	var name_label := label(resource_name, 14, MUTED, false)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(name_label)
	var amount_label := label(amount, 15, TEXT, true)
	amount_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	amount_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(amount_label)
	return row

static func illustration(kind: String) -> Control:
	var result = ILLUSTRATION_SCRIPT.new()
	result.facility_kind = kind
	result.custom_minimum_size = Vector2(300, 185)
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return result

static func _button_style(primary: bool, accent: Color, opacity: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = accent.lerp(Color(0.12,0.20,0.15),0.15) if primary else Color(0.99,0.98,0.95)
	if not primary:
		style.bg_color = style.bg_color.lerp(SURFACE_LIGHT,1.0-opacity)
	style.border_color = accent if primary else BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(9)
	style.shadow_color = Color(0.025, 0.035, 0.032, 0.42)
	style.shadow_size = 0
	style.shadow_offset = Vector2(0, 2)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style
