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

# A bundled, Vietnamese-capable font family is staged for native evidence
# and the Web export. Local checkout without the staged assets remains usable.
static var _fonts: Dictionary = {}
static func font_face(role: String = "body") -> Font:
	if _fonts.has(role):
		return _fonts[role]
	var file := "NotoSerif-Bold.ttf" if role == "title" else ("NotoSans-Bold.ttf" if role == "strong" else "NotoSans-Regular.ttf")
	var path := "res://art/uiux/fonts/" + file
	var face: Font
	if ResourceLoader.exists(path,"FontFile"):
		face = ResourceLoader.load(path,"FontFile") as Font
	if face == null:
		var fallback := SystemFont.new()
		fallback.font_names = PackedStringArray(["Noto Serif","Georgia","Noto Sans"] if role == "title" else ["Noto Sans","Arial","DejaVu Sans"])
		fallback.font_weight = 700 if role in ["strong","title"] else 400
		face = fallback
	_fonts[role] = face
	return face

# A dedicated rendered frame, with no baked text or gameplay values.
# Use only on focal surfaces; repeated items deliberately keep clean flat backgrounds.
const PREMIUM_FRAME = preload("res://art/uiux/premium/panel_jade_gold.webp")

const PREMIUM_JADE_BUTTON = preload("res://art/uiux/premium/button_jade.webp")
const PREMIUM_GOLD_BUTTON = preload("res://art/uiux/premium/button_gold.webp")
const PREMIUM_IVORY_BUTTON = preload("res://art/uiux/premium/button_ivory.webp")
static var _scenes: Dictionary = {}

static func facility_texture(key: String) -> Texture2D:
	var resolved := str({"main_hall":"hall","ren_than_duong":"training","alchemy_hall":"alchemy","linh_forest":"forest","spirit_field":"field","gate":"hall"}.get(key,key))
	if _scenes.has(resolved):
		return _scenes[resolved] as Texture2D
	var path := "res://art/uiux/premium/%s_scene.webp" % resolved
	if not ResourceLoader.exists(path,"Texture2D"):
		return null
	var tex := ResourceLoader.load(path,"Texture2D") as Texture2D
	if tex != null:
		_scenes[resolved] = tex
	return tex

static func scene_picture(key: String, min_size: Vector2) -> TextureRect:
	var picture := TextureRect.new()
	picture.name = "PremiumScenePicture"
	picture.set_meta("premium_facility_kind",key)
	picture.texture = facility_texture(key)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.custom_minimum_size = min_size
	picture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return picture

static func primary_button_skin(tint: Color = Color.WHITE, material: String = "jade") -> StyleBoxTexture:
	var skin := StyleBoxTexture.new()
	skin.texture = PREMIUM_GOLD_BUTTON if material == "gold" else (PREMIUM_IVORY_BUTTON if material == "ivory" else PREMIUM_JADE_BUTTON)
	skin.modulate_color = tint
	skin.set_texture_margin(SIDE_LEFT,19.0)
	skin.set_texture_margin(SIDE_RIGHT,19.0)
	skin.set_texture_margin(SIDE_TOP,10.0)
	skin.set_texture_margin(SIDE_BOTTOM,10.0)
	skin.set_content_margin(SIDE_LEFT,22.0)
	skin.set_content_margin(SIDE_RIGHT,22.0)
	skin.set_content_margin(SIDE_TOP,8.0)
	skin.set_content_margin(SIDE_BOTTOM,8.0)
	return skin

# Facility illustrations are optional presentation-only assets. Never block
# the existing game when an artwork has not yet been staged/imported.
static func add_facility_backdrop(parent: Control, key: String) -> void:
	var texture := facility_texture(key)
	if texture == null:
		return
	var art := TextureRect.new()
	art.name = "PremiumFacilityBackdrop"
	art.texture = texture
	# Preserve contrast behind the live forms while focal scene art stays vivid.
	art.modulate = Color(1,1,1,0.26)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(art)

static func apply_premium_frame(target: PanelContainer) -> void:
	var frame := StyleBoxTexture.new()
	frame.texture = PREMIUM_FRAME
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		frame.set_texture_margin(side,18.0)
		frame.set_content_margin(side,16.0)
	frame.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	frame.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	target.add_theme_stylebox_override("panel",frame)

static func panel(node_name: String, accent: Color, tone: Color) -> PanelContainer:
	var result := PanelContainer.new()
	result.name = node_name
	var style := StyleBoxFlat.new()
	style.bg_color = tone
	style.border_color = accent
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0.27,0.23,0.16,0.12)
	style.shadow_size = 0
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
	result.add_theme_font_override("font",font_face("title" if font_size >= 24 and bold else ("strong" if bold else "body")))
	result.add_theme_constant_override("outline_size",0)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result

static func button(text_value: String, primary: bool, accent: Color) -> Button:
	var result := Button.new()
	result.text = text_value
	result.custom_minimum_size = Vector2(52, 48)
	result.focus_mode = Control.FOCUS_ALL
	result.add_theme_font_size_override("font_size", 16)
	result.add_theme_font_override("font",font_face("strong" if primary else "body"))
	result.add_theme_color_override("font_color", INK if primary else TEXT)
	result.add_theme_color_override("font_hover_color", INK if primary else PAPER)
	result.add_theme_color_override("font_pressed_color", INK if primary else PAPER)
	result.add_theme_color_override("font_disabled_color", Color(0.48,0.46,0.41))
	result.add_theme_constant_override("outline_size",0)
	result.add_theme_stylebox_override("normal", _button_style(primary, accent, 0.78))
	result.add_theme_stylebox_override("hover", _button_style(primary, accent, 0.98))
	result.add_theme_stylebox_override("pressed", _button_style(primary, accent, 0.60))
	result.add_theme_stylebox_override("disabled", _button_style(false, BORDER, 0.35))
	if primary:
		result.add_theme_stylebox_override("normal",primary_button_skin())
		result.add_theme_stylebox_override("hover",primary_button_skin(Color(1.12,1.12,1.12)))
		result.add_theme_stylebox_override("pressed",primary_button_skin(Color(0.77,0.84,0.80)))
	else:
		result.add_theme_stylebox_override("normal",primary_button_skin(Color.WHITE,"ivory"))
		result.add_theme_stylebox_override("hover",primary_button_skin(Color(1.0,0.96,0.83),"ivory"))
	return result

static func section_heading(title: String, icon_kind: String, accent: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(icon(icon_kind, 26, accent))
	var title_label := label(title, 19, PAPER, true)
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
		var placeholder := label("—",20,MUTED,false)
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
