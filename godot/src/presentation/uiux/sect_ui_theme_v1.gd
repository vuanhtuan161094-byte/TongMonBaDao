extends RefCounted
## Shared, presentation-only styles and compact controls for the three facility screens.
## All values shown by these helpers are supplied by the host screen/view model.

const INK := Color(0.055, 0.105, 0.115, 1.0)
const DEEP := Color(0.075, 0.145, 0.15, 1.0)
const SURFACE := Color(0.11, 0.20, 0.20, 1.0)
const SURFACE_LIGHT := Color(0.15, 0.25, 0.24, 1.0)
const PAPER := Color(0.91, 0.86, 0.72, 1.0)
const TEXT := Color(0.94, 0.91, 0.81, 1.0)
const MUTED := Color(0.66, 0.73, 0.67, 1.0)
const JADE := Color(0.35, 0.73, 0.61, 1.0)
const GOLD := Color(0.85, 0.66, 0.34, 1.0)
const RED := Color(0.75, 0.34, 0.28, 1.0)
const BLUE := Color(0.42, 0.69, 0.75, 1.0)
const BORDER := Color(0.46, 0.55, 0.45, 0.45)

const ICON_SCRIPT = preload("res://src/presentation/uiux/sect_ui_icon_v1.gd")
const ILLUSTRATION_SCRIPT = preload("res://src/presentation/uiux/sect_facility_illustration_v1.gd")

static func panel(node_name: String, accent: Color, tone: Color) -> PanelContainer:
	var result := PanelContainer.new()
	result.name = node_name
	var style := StyleBoxFlat.new()
	style.bg_color = tone
	style.border_color = accent
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
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
		result.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.055, 0.8))
		result.add_theme_constant_override("outline_size", 1)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result

static func button(text_value: String, primary: bool, accent: Color) -> Button:
	var result := Button.new()
	result.text = text_value
	result.custom_minimum_size = Vector2(52, 46)
	result.focus_mode = Control.FOCUS_ALL
	result.add_theme_font_size_override("font_size", 15)
	result.add_theme_color_override("font_color", TEXT)
	result.add_theme_color_override("font_hover_color", PAPER)
	result.add_theme_color_override("font_disabled_color", Color(0.51, 0.56, 0.52, 1.0))
	result.add_theme_stylebox_override("normal", _button_style(primary, accent, 0.78))
	result.add_theme_stylebox_override("hover", _button_style(primary, accent, 0.98))
	result.add_theme_stylebox_override("pressed", _button_style(primary, accent, 0.60))
	result.add_theme_stylebox_override("disabled", _button_style(false, BORDER, 0.35))
	return result

static func section_heading(title: String, icon_kind: String, accent: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var icon = ICON_SCRIPT.new()
	icon.kind = icon_kind
	icon.tint = accent
	icon.custom_minimum_size = Vector2(24, 24)
	row.add_child(icon)
	var title_label := label(title, 17, PAPER, true)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_label)
	return row

static func metric_card(title: String, value: String, icon_kind: String, accent: Color) -> PanelContainer:
	var card := panel("MetricCard", accent, SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(142, 66)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	var icon = ICON_SCRIPT.new()
	icon.kind = icon_kind
	icon.tint = accent
	icon.custom_minimum_size = Vector2(28, 28)
	row.add_child(icon)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 1)
	var title_label := label(title, 10, MUTED, false)
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	stack.add_child(title_label)
	var value_label := label(value, 16, TEXT, true)
	value_label.name = "MetricValue"
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	stack.add_child(value_label)
	row.add_child(stack)
	card.add_child(row)
	return card

static func portrait_slot(display_name: String, texture_value: Variant, size: Vector2) -> PanelContainer:
	var card := panel("PortraitSlot", GOLD, Color(0.12, 0.18, 0.18, 1.0))
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
		var initial := "?"
		if not display_name.is_empty():
			initial = display_name.substr(0, 1)
		var placeholder := label(initial, 25, PAPER, true)
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card.add_child(placeholder)
	return card

static func resource_item(resource_name: String, amount: String, icon_kind: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var icon = ICON_SCRIPT.new()
	icon.kind = icon_kind
	icon.tint = GOLD
	icon.custom_minimum_size = Vector2(20, 20)
	row.add_child(icon)
	var name_label := label(resource_name, 12, MUTED, false)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(name_label)
	var amount_label := label(amount, 13, TEXT, true)
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
	style.bg_color = accent if primary else Color(0.12, 0.20, 0.20, 0.95)
	style.bg_color.a = opacity
	style.border_color = accent
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style
