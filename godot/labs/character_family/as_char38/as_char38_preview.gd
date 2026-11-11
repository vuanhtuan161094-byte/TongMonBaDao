extends Control

const ResolverScript = preload("res://labs/character_family/as_char38/as_char38_family_resolver.gd")
const FEMALE_FRAMES: SpriteFrames = preload("res://labs/character_family/as_char38/assets/novice_female.spriteframes.tres")
const MALE_FRAMES: SpriteFrames = preload("res://labs/character_family/as_char38/assets/novice_male.spriteframes.tres")

const CLIPS := ["idle", "walk", "cast", "attack", "hit", "death"]
const DIRECTIONS := ["front", "right", "back", "left"]
const ATLAS_CELL_SIZE := 128
const ATLAS_PIVOT := Vector2(64, 104)
const BODY_HEIGHT_PX := 70.0
const CLIP_LABELS := {
	"idle": "Idle",
	"walk": "Walk",
	"cast": "Cast",
	"attack": "Attack",
	"hit": "Hit",
	"death": "Death"
}
const DIRECTION_LABELS := {
	"front": "Front / Down",
	"right": "Right",
	"back": "Back / Up",
	"left": "Left"
}

var _resolver = ResolverScript.new()
var _registry: Dictionary = {}
var _selected_sex := "female"
var _selected_direction := "front"
var _selected_clip := "idle"
var _selected_branch_group: Dictionary = {}
var _detail_zoom := 1.0
var _sprite: AnimatedSprite2D
var _branch_picker: OptionButton
var _sex_picker: OptionButton
var _direction_picker: OptionButton
var _clip_picker: OptionButton
var _status: Label
var _identity_label: Label
var _asset_label: Label
var _foot_label: Label
var _stage: Control
var _baseline: ColorRect
var _pivot_marker: ColorRect


func _ready() -> void:
	_registry = _resolver.load_registry()
	_build_ui()
	_populate_branch_picker()
	_refresh_preview()
	print("AS_CHAR38_PREVIEW_READY groups=%d" % _registry.get("group_count", 0))


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#111319")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)

	var title := Label.new()
	title.text = "AS-CHAR-38  |  SPRITE FAMILY REVIEW"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("#e8ce89"))
	page.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Issue #77 · 1280×720 · isolated presentation preview · no gameplay authority"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color("#b7b5c0"))
	page.add_child(subtitle)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	page.add_child(content)

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(335, 0)
	content.add_child(sidebar)
	var controls := VBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	sidebar.add_child(controls)

	_add_section_label(controls, "MÔN PHÁI / NHÁNH")
	_branch_picker = OptionButton.new()
	_branch_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_branch_picker.item_selected.connect(_on_branch_selected)
	controls.add_child(_branch_picker)

	_add_section_label(controls, "GIỚI TÍNH")
	_sex_picker = OptionButton.new()
	_sex_picker.add_item("Nữ", 0)
	_sex_picker.set_item_metadata(0, "female")
	_sex_picker.add_item("Nam", 1)
	_sex_picker.set_item_metadata(1, "male")
	_sex_picker.selected = 0
	_sex_picker.item_selected.connect(_on_sex_selected)
	controls.add_child(_sex_picker)

	_add_section_label(controls, "HƯỚNG")
	_direction_picker = OptionButton.new()
	for direction in DIRECTIONS:
		_direction_picker.add_item(DIRECTION_LABELS[direction])
	_direction_picker.item_selected.connect(_on_direction_selected)
	controls.add_child(_direction_picker)

	_add_section_label(controls, "TRẠNG THÁI")
	_clip_picker = OptionButton.new()
	for clip in CLIPS:
		_clip_picker.add_item(CLIP_LABELS[clip])
	_clip_picker.item_selected.connect(_on_clip_selected)
	controls.add_child(_clip_picker)

	_add_section_label(controls, "SOI HÌNH · THÂN CHUẨN 70 PX")
	var zoom_row := HBoxContainer.new()
	zoom_row.add_theme_constant_override("separation", 6)
	controls.add_child(zoom_row)
	zoom_row.add_child(_make_button("1×", _set_detail_zoom.bind(1.0)))
	zoom_row.add_child(_make_button("6×", _set_detail_zoom.bind(6.0)))

	_identity_label = Label.new()
	_identity_label.custom_minimum_size = Vector2(0, 156)
	_identity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_identity_label.add_theme_color_override("font_color", Color("#c7c5d0"))
	controls.add_child(_identity_label)

	_status = Label.new()
	_status.custom_minimum_size = Vector2(0, 64)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_color_override("font_color", Color("#efbf75"))
	controls.add_child(_status)

	var stage_panel := PanelContainer.new()
	stage_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(stage_panel)
	_stage = ColorRect.new()
	_stage.color = Color("#1b1e26")
	_stage.custom_minimum_size = Vector2(760, 500)
	_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stage.resized.connect(_layout_sprite)
	stage_panel.add_child(_stage)
	_add_checkerboard()

	var baseline := ColorRect.new()
	baseline.name = "FootBaseline"
	baseline.color = Color("#dfc27e")
	baseline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(baseline)
	_baseline = baseline

	_sprite = AnimatedSprite2D.new()
	_sprite.centered = true
	_sprite.offset = Vector2(0, -40)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.name = "StaticPoseCandidate"
	_stage.add_child(_sprite)

	var pivot_marker := ColorRect.new()
	pivot_marker.name = "FootPivotMarker"
	pivot_marker.color = Color("#efc968")
	pivot_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(pivot_marker)
	_pivot_marker = pivot_marker

	_asset_label = Label.new()
	_asset_label.position = Vector2(12, 8)
	_asset_label.add_theme_font_size_override("font_size", 13)
	_asset_label.add_theme_color_override("font_color", Color("#f0ddb2"))
	_asset_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_asset_label)

	_foot_label = Label.new()
	_foot_label.add_theme_font_size_override("font_size", 12)
	_foot_label.add_theme_color_override("font_color", Color("#ead49c"))
	_foot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_foot_label)
	_layout_sprite()


func _add_section_label(parent: VBoxContainer, text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("#d7c281"))
	parent.add_child(label)


func _make_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	return button


func _populate_branch_picker() -> void:
	_branch_picker.add_item("Tân thủ / chưa chọn nhánh", 0)
	_branch_picker.set_item_metadata(0, "")
	var groups: Array = _registry.get("groups", [])
	for group: Dictionary in groups:
		if group.get("group_kind") != "branch":
			continue
		var label := "%s · %s" % [group.get("school_id", ""), group.get("branch_name", "")]
		_branch_picker.add_item(label)
		_branch_picker.set_item_metadata(_branch_picker.item_count - 1, group.get("group_id", ""))


func _on_branch_selected(index: int) -> void:
	var group_id := str(_branch_picker.get_item_metadata(index))
	_selected_branch_group = _resolver.group_by_id(group_id, _registry) if not group_id.is_empty() else {}
	_refresh_preview()


func _on_sex_selected(index: int) -> void:
	_selected_sex = str(_sex_picker.get_item_metadata(index))
	_refresh_preview()


func _on_direction_selected(index: int) -> void:
	_selected_direction = DIRECTIONS[index]
	_refresh_preview()


func _on_clip_selected(index: int) -> void:
	_selected_clip = CLIPS[index]
	_refresh_preview()


func _set_detail_zoom(value: float) -> void:
	_detail_zoom = value
	_layout_sprite()


func _add_checkerboard() -> void:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color("#d6d4cf"))
	image.fill_rect(Rect2i(0, 0, 16, 16), Color("#aaa8a4"))
	image.fill_rect(Rect2i(16, 16, 16, 16), Color("#aaa8a4"))
	var checker := TextureRect.new()
	checker.name = "TransparencyCheckerboard"
	checker.texture = ImageTexture.create_from_image(image)
	checker.stretch_mode = TextureRect.STRETCH_TILE
	checker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	checker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	checker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stage.add_child(checker)
	_stage.move_child(checker, 0)


func _layout_sprite() -> void:
	if not is_instance_valid(_sprite) or not is_instance_valid(_stage):
		return
	var total_scale := _detail_zoom
	var visible_height := BODY_HEIGHT_PX * total_scale
	var baseline_y := min(max(_stage.size.y * 0.76, visible_height + 14.0), _stage.size.y - 10.0)
	var center_x := _stage.size.x * 0.5
	_sprite.position = Vector2(center_x, baseline_y)
	_sprite.scale = Vector2(total_scale, total_scale)
	if is_instance_valid(_baseline):
		_baseline.position = Vector2(center_x - min(_stage.size.x * 0.32, 280.0), baseline_y)
		_baseline.size = Vector2(min(_stage.size.x * 0.64, 560.0), 2.0)
	if is_instance_valid(_pivot_marker):
		_pivot_marker.position = Vector2(center_x - 3.0, baseline_y - 3.0)
		_pivot_marker.size = Vector2(6.0, 6.0)
	if is_instance_valid(_foot_label):
		_foot_label.position = Vector2(14.0, baseline_y + 8.0)


func _refresh_preview() -> void:
	var frames: SpriteFrames = FEMALE_FRAMES if _selected_sex == "female" else MALE_FRAMES
	_sprite.sprite_frames = frames
	var direction := _selected_direction
	var idle_name := "idle_" + direction
	if not frames.has_animation(idle_name):
		_status.text = "Không có frame idle cho hướng này."
		_sprite.stop()
		return
	_sprite.animation = idle_name
	_sprite.frame = 0
	_sprite.stop()

	var disciple_id := "preview.novice." + _selected_sex
	var identity := {
		"disciple_id": disciple_id,
		"sex_id": _selected_sex,
		"school_id": str(_selected_branch_group.get("school_id", "")),
		"branch_id": str(_selected_branch_group.get("branch_design_slug", "")),
		"v63_combat_branch_id": str(_selected_branch_group.get("v63_path_candidate_id", "")),
		"profile_seed": 20261112,
		"cosmetic_seed": 0
	}
	var resolution: Dictionary = _resolver.resolve_identity(identity, _registry)
	var group_name := "Tân thủ %s" % ("nữ" if _selected_sex == "female" else "nam")
	var branch_status := "Chưa chọn nhánh; dùng mẫu nền tân thủ."
	if not _selected_branch_group.is_empty():
		group_name = str(_selected_branch_group.get("branch_name", group_name))
		branch_status = "Nhánh đã định nghĩa; art=%s." % _selected_branch_group.get("art_status", "ART_PENDING")
	var clip_status := "STATIC_POSE_CANDIDATE" if _selected_clip == "idle" else "ART_PENDING"
	if _selected_clip == "idle":
		_status.text = "%s · %s · static 1 pose/hướng; chưa được nghiệm thu mỹ thuật." % [group_name, _status_colorless(branch_status)]
	else:
		_status.text = "%s · %s · không có frame cho clip này; đang giữ pose idle, không giả chuyển động." % [CLIP_LABELS[_selected_clip], clip_status]
	var atlas_family := "novice_female" if _selected_sex == "female" else "novice_male"
	var atlas_index := DIRECTIONS.find(_selected_direction)
	var region_x := atlas_index * ATLAS_CELL_SIZE
	_asset_label.text = "ATLAS  %s_idle_4dir.png  ·  region (%d, 0, 128, 128)  ·  mirror=false" % [atlas_family, region_x]
	_foot_label.text = "FOOT PIVOT  (%.0f, %.0f)  ·  %.0f px body" % [ATLAS_PIVOT.x, ATLAS_PIVOT.y, BODY_HEIGHT_PX]
	var visual_contract: Dictionary = _selected_branch_group.get("visual_contract", {})
	var design_id := str(_selected_branch_group.get("design_group_id", "as_char38.novice." + _selected_sex))
	var path_candidate := str(_selected_branch_group.get("v63_path_candidate_id", ""))
	_identity_label.text = "Nhóm: %s\nID thiết kế: %s\nV63 path: %s\nDáng: %s\nGesture: %s\nGiới tính: %s · %s\nHướng: %s · %s\nSeed xem trước: %s" % [
		group_name,
		design_id,
		path_candidate if not path_candidate.is_empty() else "design-only",
		str(visual_contract.get("common_silhouette", "mẫu nền trung tính")),
		str(visual_contract.get("branch_motion_signature", "pose tĩnh")),
		_selected_sex,
		_selected_clip,
		DIRECTION_LABELS[_selected_direction],
		clip_status,
		str(resolution.get("appearance_seed", 0))
	]


func _status_colorless(value: String) -> String:
	return value.replace(" · ", " / ")


func _exit_tree() -> void:
	if is_instance_valid(_sprite):
		_sprite.stop()
