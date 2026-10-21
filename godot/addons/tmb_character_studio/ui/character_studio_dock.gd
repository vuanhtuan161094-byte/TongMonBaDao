@tool
extends VBoxContainer

const Catalog = preload("res://addons/tmb_character_studio/core/source_a_catalog.gd")
const PresetSchema = preload("res://addons/tmb_character_studio/core/preset_schema.gd")
const SandboxPreview = preload("res://addons/tmb_character_studio/core/sandbox_preview.gd")
const PreviewStage = preload("res://addons/tmb_character_studio/ui/preview_stage.gd")
const CombatSkillSystem = preload("res://src/simulation/combat/combat_skill_system.gd")
const EquipmentSystem = preload("res://src/simulation/equipment/equipment_system.gd")
const GearSystem = EquipmentSystem
const PRESET_DIR := "res://addons/tmb_character_studio/presets"

var _catalog: TmbSourceACatalog = Catalog.new()
var _preset: Dictionary = {}
var _selected_asset_id := ""
var _preview_actor: Node2D
var _preview_sprite: AnimatedSprite2D
var _direction := "right"

var _status: Label
var _rig_tree: Tree
var _rig_option: OptionButton
var _sex_option: OptionButton
var _role_option: OptionButton
var _preset_id: LineEdit
var _name: LineEdit
var _scale: SpinBox
var _pivot_x: SpinBox
var _pivot_y: SpinBox
var _clip_option: OptionButton
var _asset_info: RichTextLabel
var _preview_report: TextEdit
var _stage: Node2D
var _item_list: ItemList
var _skill_option: OptionButton
var _skill_stage: SpinBox
var _foundation_controls: Dictionary = {}
var _realm_controls: Dictionary = {}
var _equipment_options: Dictionary = {}
var _file_dialog: EditorFileDialog
var _file_dialog_mode := "open"
var _manifest_label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(410.0, 520.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_catalog.refresh()
	_preset = PresetSchema.default_preset(_catalog)
	_build_ui()
	_refresh_rig_tree()
	_populate_form_options()
	_apply_preset_to_form()
	_refresh_validation_and_preview()

func _build_ui() -> void:
	var heading := Label.new()
	heading.text = "DEV CHARACTER STUDIO"
	heading.add_theme_font_size_override("font_size", 18)
	add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "Sandbox nội bộ · không ghi DiscipleState/SimulationState hoặc save thật"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(subtitle)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_color_override("font_color", Color(0.85, 0.74, 0.42))
	add_child(_status)
	var toolbar := HBoxContainer.new()
	add_child(toolbar)
	_add_button(toolbar, "Làm mới", _on_refresh_pressed)
	_add_button(toolbar, "Mới", _on_new_pressed)
	_add_button(toolbar, "Mở", _on_open_pressed)
	_add_button(toolbar, "Lưu", _on_save_pressed)
	_add_button(toolbar, "Xuất", _on_export_pressed)

	_file_dialog = EditorFileDialog.new()
	_file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	_file_dialog.filters = PackedStringArray(["*.json ; Character Preset JSON"])
	_file_dialog.size = Vector2i(760, 520)
	_file_dialog.file_selected.connect(_on_file_dialog_selected)
	add_child(_file_dialog)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(tabs)
	tabs.add_child(_build_asset_tab())
	tabs.add_child(_build_preset_tab())

func _build_asset_tab() -> Control:
	var page := VBoxContainer.new()
	page.name = "Rig Source A"
	var manifest_row := HBoxContainer.new()
	page.add_child(manifest_row)
	_manifest_label = Label.new()
	_manifest_label.name = "ManifestStatus"
	_manifest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_manifest_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	manifest_row.add_child(_manifest_label)

	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(split)
	_rig_tree = Tree.new()
	_rig_tree.custom_minimum_size = Vector2(150.0, 220.0)
	_rig_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rig_tree.hide_root = true
	_rig_tree.item_selected.connect(_on_rig_tree_selected)
	split.add_child(_rig_tree)

	var inspector := VBoxContainer.new()
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(inspector)
	var controls := HBoxContainer.new()
	inspector.add_child(controls)
	_clip_option = OptionButton.new()
	_clip_option.add_item("stand")
	_clip_option.add_item("walk")
	_clip_option.item_selected.connect(_on_clip_changed)
	controls.add_child(_clip_option)
	_add_button(controls, "←", func(): _set_direction("left"))
	_add_button(controls, "→", func(): _set_direction("right"))
	_add_labeled_spin(inspector, "Tỷ lệ hiển thị", 0.05, 2.0, 0.01, 0.34, _on_preview_value_changed, "preview_scale")
	var scale_row := inspector.get_child(inspector.get_child_count() - 1) as HBoxContainer
	_scale = scale_row.get_node("preview_scale") as SpinBox
	_add_labeled_spin(inspector, "Pivot X", -768.0, 768.0, 1.0, 0.0, _on_preview_value_changed, "pivot_x")
	_pivot_x = (inspector.get_child(inspector.get_child_count() - 1) as HBoxContainer).get_node("pivot_x") as SpinBox
	_add_labeled_spin(inspector, "Pivot Y", -768.0, 768.0, 1.0, 0.0, _on_preview_value_changed, "pivot_y")
	_pivot_y = (inspector.get_child(inspector.get_child_count() - 1) as HBoxContainer).get_node("pivot_y") as SpinBox

	var stage_container := SubViewportContainer.new()
	stage_container.custom_minimum_size = Vector2(340.0, 280.0)
	stage_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_container.stretch = true
	inspector.add_child(stage_container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(340, 280)
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.world_2d = World2D.new()
	stage_container.add_child(viewport)
	_stage = PreviewStage.new()
	_stage.name = "PreviewStage"
	viewport.add_child(_stage)
	_stage.configure(232.0, Vector2(170.0, 232.0))

	_asset_info = RichTextLabel.new()
	_asset_info.fit_content = true
	_asset_info.scroll_active = true
	_asset_info.custom_minimum_size = Vector2(0.0, 95.0)
	inspector.add_child(_asset_info)
	return page

func _build_preset_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.name = "Character Preset"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(page)
	_preset_id = _add_line_edit(page, "Preset ID")
	_name = _add_line_edit(page, "Tên thử nghiệm")
	var identity_row := HBoxContainer.new()
	page.add_child(identity_row)
	_sex_option = _add_labeled_option(identity_row, "Giới tính", ["female", "male"])
	_role_option = _add_labeled_option(identity_row, "Vai trò", PresetSchema.ROLES)
	_rig_option = _add_labeled_option(page, "Rig Source A", [])

	var foundation_group := VBoxContainer.new()
	page.add_child(_section_header("Nền tảng · giá trị sandbox"))
	page.add_child(foundation_group)
	var foundation_grid := GridContainer.new()
	foundation_grid.columns = 3
	foundation_group.add_child(foundation_grid)
	var foundation_names := {
		"aptitude":"Tư Chất", "constitution":"Căn Cốt", "fortune":"Cơ Duyên",
		"comprehension":"Thông Tuệ", "charisma":"Mị Lực", "potential":"Tiềm Lực"
	}
	for key in PresetSchema.FOUNDATION_KEYS:
		var control := _add_compact_spin(foundation_grid, str(foundation_names[key]), 0.0, 1000000.0, 1.0, 0.0)
		_foundation_controls[key] = control
		control.value_changed.connect(_on_form_changed)

	page.add_child(_section_header("Cảnh giới V2 · preview coordinate"))
	var realm_grid := GridContainer.new()
	realm_grid.columns = 4
	page.add_child(realm_grid)
	for track in ["cultivation", "body"]:
		var track_label := Label.new()
		track_label.text = "Tu Vi" if track == "cultivation" else "Luyện Thể"
		track_label.custom_minimum_size.x = 70.0
		realm_grid.add_child(track_label)
		var realm := _add_compact_spin(realm_grid, "Cảnh", 1, 30, 1, 1)
		var floor_index := _add_compact_spin(realm_grid, "Tầng", 1, 10, 1, 1)
		_realm_controls[track] = {"realm": realm, "floor": floor_index}
		realm.value_changed.connect(_on_form_changed)
		floor_index.value_changed.connect(_on_form_changed)

	_skill_stage = _add_labeled_spin(page, "Skill stage (consumer hiện hành)", 0, 1000000, 1, 0, _on_form_changed, "skill_stage")
	var skill_header := HBoxContainer.new()
	page.add_child(_section_header("Skill sandbox · thứ tự slot DESIGN-ONLY"))
	page.add_child(skill_header)
	_skill_option = _add_labeled_option(skill_header, "Skill", [])
	_add_button(skill_header, "Thêm", _on_add_skill)
	_item_list = ItemList.new()
	_item_list.custom_minimum_size.y = 76.0
	page.add_child(_item_list)
	_add_button(page, "Bỏ skill đang chọn", _on_remove_skill)
	var slot_note := Label.new()
	slot_note.text = "Runtime CombatSkillSystem dùng learned skills; chưa có giới hạn/sơ đồ slot. Thứ tự dưới đây chỉ thuộc preset studio."
	slot_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(slot_note)

	page.add_child(_section_header("Equipment set · chỉ tham chiếu recipe canonical"))
	for slot in GearSystem.VALID_SLOTS:
		var slot_name := str(slot)
		var option := _add_labeled_option(page, slot_name.capitalize(), [])
		_equipment_options[slot_name] = option

	page.add_child(_section_header("Hồ sơ và stat breakdown · read-only consumers"))
	_preview_report = TextEdit.new()
	_preview_report.editable = false
	_preview_report.custom_minimum_size.y = 220.0
	_preview_report.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(_preview_report)
	return scroll

func _populate_form_options() -> void:
	_rig_option.clear()
	for rig in _catalog.rigs:
		_rig_option.add_item("%s · %s" % [str(rig.get("asset_id", "")), str(rig.get("sex", ""))])
		_rig_option.set_item_metadata(_rig_option.item_count - 1, str(rig.get("asset_id", "")))
	_skill_option.clear()
	var skill_ids: Array = CombatSkillSystem.SKILLS.keys()
	skill_ids.sort()
	for raw_id in skill_ids:
		var skill_id := str(raw_id)
		_skill_option.add_item("%s · %s" % [str(CombatSkillSystem.SKILLS[skill_id].get("name", skill_id)), skill_id])
		_skill_option.set_item_metadata(_skill_option.item_count - 1, skill_id)
	for slot in EquipmentSystem.VALID_SLOTS:
		var slot_name := str(slot)
		var option: OptionButton = _equipment_options[slot_name]
		option.clear()
		option.add_item("— Không chọn —")
		option.set_item_metadata(0, "")
		var recipe_ids: Array = EquipmentSystem.RECIPES.keys()
		recipe_ids.sort()
		for raw_id in recipe_ids:
			var recipe_id := str(raw_id)
			var recipe: Dictionary = EquipmentSystem.RECIPES[recipe_id]
			if str(recipe.get("slot", "")) != slot_name:
				continue
			option.add_item("%s · %s" % [str(recipe.get("name", recipe_id)), recipe_id])
			option.set_item_metadata(option.item_count - 1, recipe_id)

func _refresh_rig_tree() -> void:
	_rig_tree.clear()
	_manifest_label.text = "Pool: %s · Combat V5 manifest: %s" % [_catalog.pool_status, _catalog.combat_manifest_status]
	if not _catalog.pool_error.is_empty():
		_manifest_label.text += "\n" + _catalog.pool_error
	var root := _rig_tree.create_item()
	_rig_tree.hide_root = true
	if _catalog.rigs.is_empty():
		var unavailable := _rig_tree.create_item(root)
		unavailable.set_text(0, "Source A rig pool unavailable")
		unavailable.set_metadata(0, "")
		return
	for rig in _catalog.rigs:
		var item := _rig_tree.create_item(root)
		var status := _status_text(str(rig.get("asset_status", "unverified")))
		item.set_text(0, "%s · %s · %s" % [str(rig.get("asset_id", "")), str(rig.get("sex", "")), status])
		item.set_metadata(0, str(rig.get("asset_id", "")))
	if not _selected_asset_id.is_empty():
		_select_tree_asset(_selected_asset_id)

func _apply_preset_to_form() -> void:
	_preset_id.text = str(_preset.get("preset_id", ""))
	_name.text = str(_preset.get("name", ""))
	_select_option_by_text(_sex_option, str(_preset.get("sex", "")))
	_select_option_by_text(_role_option, str(_preset.get("role", "")))
	_select_option_by_metadata(_rig_option, str(_preset.get("rig_id", "")))
	_scale.value = float(_preset.get("display_scale", 0.34))
	var pivot: Array = _preset.get("pivot_offset", [0.0, 0.0])
	_pivot_x.value = float(pivot[0])
	_pivot_y.value = float(pivot[1])
	var attributes: Dictionary = _preset.get("attributes", {})
	for key in PresetSchema.FOUNDATION_KEYS:
		(_foundation_controls[key] as SpinBox).value = float(attributes.get(key, 0.0))
	var progression: Dictionary = _preset.get("progression", {})
	for track in ["cultivation", "body"]:
		var row: Dictionary = progression.get(track, {})
		(_realm_controls[track]["realm"] as SpinBox).value = int(row.get("realm", 1))
		(_realm_controls[track]["floor"] as SpinBox).value = int(row.get("floor", 1))
	_skill_stage.value = int(_preset.get("skill_stage_index", 0))
	_refresh_skill_list()
	for slot in EquipmentSystem.VALID_SLOTS:
		var slot_name := str(slot)
		_select_option_by_metadata(_equipment_options[slot_name], _recipe_for_slot(slot_name))
	var rig_id := str(_preset.get("rig_id", ""))
	if not rig_id.is_empty():
		_selected_asset_id = rig_id
	else:
		_selected_asset_id = ""
	_refresh_preview_actor()

func _read_form() -> Dictionary:
	var updated := _preset.duplicate(true)
	updated["preset_id"] = _preset_id.text.strip_edges()
	updated["name"] = _name.text.strip_edges()
	updated["sex"] = str(_sex_option.get_item_text(_sex_option.selected)) if _sex_option.selected >= 0 else ""
	updated["role"] = str(_role_option.get_item_text(_role_option.selected)) if _role_option.selected >= 0 else ""
	updated["rig_id"] = str(_rig_option.get_item_metadata(_rig_option.selected)) if _rig_option.selected >= 0 else ""
	var rig := _catalog.get_rig(str(updated["rig_id"]))
	updated["asset_path"] = str(rig.get("scene_path", ""))
	updated["display_scale"] = _scale.value
	updated["pivot_offset"] = [_pivot_x.value, _pivot_y.value]
	var attributes: Dictionary = {}
	for key in PresetSchema.FOUNDATION_KEYS:
		attributes[key] = (_foundation_controls[key] as SpinBox).value
	updated["attributes"] = attributes
	var progression: Dictionary = {}
	for track in ["cultivation", "body"]:
		progression[track] = {
			"realm": int((_realm_controls[track]["realm"] as SpinBox).value),
			"floor": int((_realm_controls[track]["floor"] as SpinBox).value)
		}
	updated["progression"] = progression
	updated["skill_stage_index"] = int(_skill_stage.value)
	var equipment: Array[Dictionary] = []
	for slot in EquipmentSystem.VALID_SLOTS:
		var option: OptionButton = _equipment_options[str(slot)]
		if option.selected < 0:
			continue
		var recipe_id := str(option.get_item_metadata(option.selected))
		if recipe_id.is_empty():
			continue
		equipment.append({"slot": str(slot), "recipe_id": recipe_id})
	updated["equipment_set"] = equipment
	return updated

func _refresh_validation_and_preview() -> void:
	_preset = _read_form()
	var errors := PresetSchema.validate(_preset, _catalog)
	if errors.is_empty():
		_status.text = "Preset hợp lệ · sandbox only"
		_status.add_theme_color_override("font_color", Color(0.52, 0.86, 0.57))
	else:
		_status.text = "Có %d lỗi validation" % errors.size()
		_status.add_theme_color_override("font_color", Color(0.98, 0.53, 0.44))
	_preview_report.text = _build_profile_report(errors)
	_update_asset_info()
	_apply_preview_settings()

func _build_profile_report(validation_errors: Array[String]) -> String:
	if not validation_errors.is_empty():
		return "VALIDATION\n" + "\n".join(validation_errors)
	var result := SandboxPreview.build(_preset, _catalog)
	if not bool(result.get("ok", false)):
		return "Preview lỗi\n" + "\n".join(result.get("errors", []))
	var snapshot: Dictionary = result.get("snapshot", {})
	var foundations: Dictionary = snapshot.get("foundations", {}).get("current", {})
	var combat: Dictionary = result.get("combat", {})
	var stats: Dictionary = combat.get("stats", {})
	var breakdown: Dictionary = combat.get("stat_breakdown", {})
	var text := "HỒ SƠ SANDBOX\n"
	text += "Consumer snapshot: %s\n" % str(snapshot.get("authority", "unknown"))
	text += "Giới tính / vai trò / rig: %s / %s / %s\n" % [str(_preset.get("sex", "")), str(_preset.get("role", "")), str(_preset.get("rig_id", ""))]
	text += "\nSÁU NỀN TẢNG (DisciplePresentationSnapshotV2)\n"
	for key in PresetSchema.FOUNDATION_KEYS:
		text += "• %s: %.1f\n" % [str(snapshot.get("foundations", {}).get("labels", {}).get(key, key)), float(foundations.get(key, 0.0))]
	text += "\nCẢNH GIỚI (sandbox coordinates)\n"
	text += "Tu Vi: %s · cảnh %d tầng %d\n" % [str(result.get("cultivation_name", "")), int(_preset.progression.cultivation.realm), int(_preset.progression.cultivation.floor)]
	text += "Luyện Thể: %s · cảnh %d tầng %d\n" % [str(result.get("body_name", "")), int(_preset.progression.body.realm), int(_preset.progression.body.floor)]
	text += "V2 progression readiness: %s\n" % ("ready" if bool(result.get("v2_progress_ready", false)) else "DESIGN-ONLY / birth profile chưa hoàn chỉnh")
	text += "Linh căn / thiên phú / thiên mệnh: %s\n" % str(result.get("root_and_talents_status", "DESIGN-ONLY"))
	text += "Accuracy / Evasion: DESIGN-ONLY · không có trong runtime.\n"
	text += "\nSTAT BREAKDOWN (DiscipleCombatLoadoutV2 → CombatStatsV2)\n"
	for stat in ["max_hp", "attack", "defense", "move_speed", "attack_speed", "crit_chance", "effect_hit", "effect_resistance"]:
		if stats.has(stat):
			text += "%s: %.3f\n" % [stat, float(stats[stat])]
			if breakdown.has(stat):
				var row: Dictionary = breakdown[stat]
				text += "  realm %.2f + body %.2f × potential %.3f\n" % [float(row.get("realm", 0.0)), float(row.get("body", 0.0)), float(row.get("potential_factor", 1.0))]
	text += "\nSkill loadout: %s\n" % ", ".join(combat.get("skill_loadout", []))
	text += "Deferred/non-damage skills: %s\n" % ", ".join(combat.get("deferred_skill_ids", []))
	text += "Equipment IDs are recipe references only; preview instances are ephemeral.\n"
	return text

func _update_asset_info() -> void:
	var rig := _catalog.get_rig(_selected_asset_id)
	if rig.is_empty():
		_asset_info.text = "Không có rig Source A để preview. Không dùng placeholder.\n"
		_asset_info.text += "Pool status: %s · %s\n" % [_catalog.pool_status, _catalog.pool_error]
		_asset_info.text += "Combat manifest: %s" % _catalog.combat_manifest_status
		return
	var validation := _catalog.validate_rig(_selected_asset_id)
	var metadata: Dictionary = rig.get("asset_manifest", {})
	var clips: Dictionary = rig.get("clip_metadata", {})
	var text := "Rig: %s · giới tính tương thích: %s\n" % [_selected_asset_id, str(rig.get("sex", ""))]
	text += "Asset: %s\n" % str(rig.get("scene_path", ""))
	text += "Manifest: %s · binary: %s\n" % [str(rig.get("manifest_status", "unverified")), "SHA-256 PASS" if bool(validation.get("ok", false)) else "cần kiểm tra"]
	text += "FPS: %s · canvas: %s · foot anchor: %s · scene offset: %s\n" % [str(metadata.get("fps", "?")), str(metadata.get("canvas", [])), str(metadata.get("foot_anchor", [])), str(metadata.get("offset", []))]
	text += "Combat V5 visual manifest: %s\n" % _catalog.combat_manifest_status
	for clip_name in Catalog.CLIPS:
		var clip: Dictionary = clips.get(clip_name, {})
		text += "%s: %s" % [clip_name, _status_text(_catalog.clip_status(_selected_asset_id, clip_name))]
		if not clip.is_empty():
			text += " · %.2fs · %s frames" % [float(clip.get("duration_seconds", 0.0)), str(clip.get("frames", "?"))]
		text += "\n"
	if not bool(validation.get("ok", false)):
		text += "Validation: " + "; ".join(validation.get("errors", []))
	_asset_info.text = text

func _refresh_preview_actor() -> void:
	if _preview_actor != null and is_instance_valid(_preview_actor):
		_preview_actor.queue_free()
	_preview_actor = null
	_preview_sprite = null
	if _selected_asset_id.is_empty():
		_update_asset_info()
		return
	_preview_actor = _catalog.instantiate_actor(_selected_asset_id)
	if _preview_actor == null:
		_update_asset_info()
		return
	_stage.add_child(_preview_actor)
	_preview_sprite = _preview_actor as AnimatedSprite2D
	if _preview_sprite == null:
		var sprites := _preview_actor.find_children("*", "AnimatedSprite2D", true, false)
		if not sprites.is_empty():
			_preview_sprite = sprites[0] as AnimatedSprite2D
	_apply_preview_settings()
	_update_asset_info()

func _apply_preview_settings() -> void:
	if _stage == null:
		return
	var pivot := Vector2(170.0 + _pivot_x.value, 232.0 + _pivot_y.value)
	_stage.configure(232.0, pivot)
	if _preview_actor == null or not is_instance_valid(_preview_actor) or _preview_sprite == null:
		return
	_preview_actor.position = pivot
	_preview_actor.scale = Vector2(_scale.value, _scale.value)
	_preview_sprite.flip_h = _direction == "left"
	var clip_name := str(_clip_option.get_item_text(_clip_option.selected)) if _clip_option.selected >= 0 else "stand"
	var clip_status := _catalog.clip_status(_selected_asset_id, clip_name)
	if clip_status != "present":
		_preview_sprite.stop()
		_preview_sprite.visible = false
		return
	_preview_sprite.visible = true
	if _preview_sprite.sprite_frames == null or not _preview_sprite.sprite_frames.has_animation(clip_name):
		_preview_sprite.stop()
		_preview_sprite.visible = false
		return
	_preview_sprite.play(clip_name)

func _refresh_skill_list() -> void:
	_item_list.clear()
	var slots: Array = _preset.get("skill_slots", [])
	slots.sort_custom(func(a, b): return int(a.get("slot", 0)) < int(b.get("slot", 0)))
	for row in slots:
		var skill_id := str(row.get("skill_id", ""))
		var definition: Dictionary = CombatSkillSystem.SKILLS.get(skill_id, {})
		_item_list.add_item("%02d · %s · %s" % [int(row.get("slot", 0)), str(definition.get("name", "?")), skill_id])

func _recipe_for_slot(slot: String) -> String:
	for item in _preset.get("equipment_set", []):
		if str(item.get("slot", "")) == slot:
			return str(item.get("recipe_id", ""))
	return ""

func _add_button(parent: Node, text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _add_line_edit(parent: Node, label_text: String) -> LineEdit:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 110.0
	row.add_child(label)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text_changed.connect(_on_form_changed)
	row.add_child(edit)
	return edit

func _add_labeled_option(parent: Node, label_text: String, values: Array) -> OptionButton:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 72.0
	row.add_child(label)
	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for value in values:
		option.add_item(str(value))
	option.item_selected.connect(_on_form_changed)
	row.add_child(option)
	return option

func _add_labeled_spin(parent: Node, label_text: String, minimum: float, maximum: float, step: float, value: float, callback: Callable, node_name: String) -> SpinBox:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var spin := SpinBox.new()
	spin.name = node_name
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.value = value
	spin.value_changed.connect(callback)
	row.add_child(spin)
	return spin

func _add_compact_spin(parent: Node, label_text: String, minimum: float, maximum: float, step: float, value: float) -> SpinBox:
	var column := VBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	column.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.value = value
	column.add_child(spin)
	parent.add_child(column)
	return spin

func _section_header(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 14)
	return label

func _select_option_by_text(option: OptionButton, value: String) -> void:
	for index in range(option.item_count):
		if option.get_item_text(index) == value:
			option.select(index)
			return
	if option.item_count > 0:
		option.select(0)

func _select_option_by_metadata(option: OptionButton, value: String) -> void:
	for index in range(option.item_count):
		if str(option.get_item_metadata(index)) == value:
			option.select(index)
			return

func _select_tree_asset(asset_id: String) -> void:
	var root := _rig_tree.get_root()
	if root == null:
		return
	var item := root.get_first_child()
	while item != null:
		if str(item.get_metadata(0)) == asset_id:
			item.select(0)
			return
		item = item.get_next()

func _status_text(status: String) -> String:
	match status:
		"present", "available": return "CÓ THẬT"
		"missing": return "THIẾU"
		_: return "CHƯA XÁC MINH"

func _on_refresh_pressed() -> void:
	_catalog.refresh()
	_populate_form_options()
	_refresh_rig_tree()
	_refresh_validation_and_preview()

func _on_new_pressed() -> void:
	_preset = PresetSchema.default_preset(_catalog)
	_apply_preset_to_form()
	_refresh_validation_and_preview()

func _on_open_pressed() -> void:
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.title = "Mở Character Preset JSON"
	_file_dialog.current_dir = ProjectSettings.globalize_path(PRESET_DIR)
	_file_dialog_mode = "open"
	_file_dialog.popup_centered()

func _on_save_pressed() -> void:
	_save_dialog(false)

func _on_export_pressed() -> void:
	_save_dialog(true)

func _save_dialog(is_export: bool) -> void:
	_preset = _read_form()
	var errors := PresetSchema.validate(_preset, _catalog)
	if not errors.is_empty():
		_refresh_validation_and_preview()
		return
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.title = "Xuất Character Preset JSON" if is_export else "Lưu Character Preset JSON"
	_file_dialog.current_dir = ProjectSettings.globalize_path(PRESET_DIR)
	_file_dialog.current_file = "%s.json" % str(_preset.get("preset_id", "character_preset"))
	_file_dialog_mode = "save"
	_file_dialog.popup_centered()

func _on_file_dialog_selected(path: String) -> void:
	if _file_dialog_mode == "open":
		_on_file_opened(path)
	else:
		_on_file_saved(path)

func _on_file_opened(path: String) -> void:
	var parsed := PresetSchema.parse_json(FileAccess.get_file_as_string(path))
	if not bool(parsed.get("ok", false)):
		_status.text = str(parsed.get("error", "JSON không hợp lệ."))
		return
	var raw_preset: Dictionary = parsed.get("data", {})
	var errors := PresetSchema.validate(raw_preset, _catalog)
	if not errors.is_empty():
		_status.text = "Preset bị từ chối: %d lỗi schema/authority." % errors.size()
		_preview_report.text = "VALIDATION\n" + "\n".join(errors)
		return
	_preset = PresetSchema.normalize(raw_preset)
	_apply_preset_to_form()
	_refresh_validation_and_preview()

func _on_file_saved(path: String) -> void:
	_preset = _read_form()
	var errors := PresetSchema.validate(_preset, _catalog)
	if not errors.is_empty():
		_refresh_validation_and_preview()
		return
	var absolute_path := ProjectSettings.globalize_path(path)
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		_status.text = "Không ghi được preset: %s" % error_string(FileAccess.get_open_error())
		return
	file.store_string(PresetSchema.serialize(_preset) + "\n")
	file.close()
	_status.text = "Đã lưu sandbox preset: %s" % path

func _on_rig_tree_selected() -> void:
	var selected := _rig_tree.get_selected()
	if selected == null:
		return
	var asset_id := str(selected.get_metadata(0))
	if asset_id.is_empty():
		return
	_selected_asset_id = asset_id
	_select_option_by_metadata(_rig_option, asset_id)
	_refresh_preview_actor()
	_refresh_validation_and_preview()

func _on_clip_changed(_index: int) -> void:
	_apply_preview_settings()
	_update_asset_info()

func _set_direction(direction: String) -> void:
	_direction = direction
	_apply_preview_settings()

func _on_preview_value_changed(_value: float = 0.0) -> void:
	_apply_preview_settings()
	_refresh_validation_and_preview()

func _on_form_changed(_value: Variant = null) -> void:
	_refresh_validation_and_preview()
	if _rig_option.selected >= 0:
		var asset_id := str(_rig_option.get_item_metadata(_rig_option.selected))
		if asset_id != _selected_asset_id:
			_selected_asset_id = asset_id
			_refresh_preview_actor()

func _on_add_skill() -> void:
	if _skill_option.selected < 0:
		return
	var skill_id := str(_skill_option.get_item_metadata(_skill_option.selected))
	var slots: Array = _preset.get("skill_slots", [])
	for row in slots:
		if str(row.get("skill_id", "")) == skill_id:
			return
	var next_slot := 1
	for row in slots:
		next_slot = maxi(next_slot, int(row.get("slot", 0)) + 1)
	slots.append({"slot": next_slot, "skill_id": skill_id})
	var owned: Array = _preset.get("owned_skill_ids", [])
	if not owned.has(skill_id):
		owned.append(skill_id)
	_preset["skill_slots"] = slots
	_preset["owned_skill_ids"] = owned
	_refresh_skill_list()
	_refresh_validation_and_preview()

func _on_remove_skill() -> void:
	var selected := _item_list.get_selected_items()
	if selected.is_empty():
		return
	var slots: Array = _preset.get("skill_slots", [])
	if selected[0] >= 0 and selected[0] < slots.size():
		var removed: Dictionary = slots[selected[0]]
		var skill_id := str(removed.get("skill_id", ""))
		slots.remove_at(selected[0])
		var owned: Array = _preset.get("owned_skill_ids", [])
		owned.erase(skill_id)
		_preset["skill_slots"] = slots
		_preset["owned_skill_ids"] = owned
		_refresh_skill_list()
		_refresh_validation_and_preview()
