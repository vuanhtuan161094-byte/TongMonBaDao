extends Control
## Presentation-only Hall screen. bind_view_model() accepts authoritative data and emits UI intent signals.

signal office_selection_requested(role_id: String)
signal office_dismissal_requested(role_id: String)
signal promotion_requested
signal hall_upgrade_requested
signal closed

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const ROLE_IDS := ["master", "guide", "teacher", "steward", "guardian", "alchemist", "discipline"]
const ROLE_LABELS := {
	"master": "Chưởng Môn", "guide": "Tiếp Dẫn Trưởng Lão", "teacher": "Truyền Công Trưởng Lão",
	"steward": "Nội Vụ Chấp Sự", "guardian": "Hộ Pháp Trưởng Lão",
	"alchemist": "Đan Đạo Trưởng Lão", "discipline": "Giới Luật Trưởng Lão"
}

var _vm: Dictionary = {}

func bind_view_model(view_model: Dictionary) -> void:
	_vm = view_model.duplicate(true)
	_rebuild()

func _ready() -> void:
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var background := ColorRect.new()
	background.color = UI.DEEP
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var shell := _make_shell("ĐẠI ĐIỆN", "Thất chức • phẩm cấp và thăng bậc môn phái")
	add_child(shell)
	var body := HBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	var body_scroll := ScrollContainer.new()
	body_scroll.name = "HallBodyScroll"
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_scroll.add_child(body)
	shell.get_child(0).add_child(body_scroll)
	body.add_child(_build_progress_panel())
	body.add_child(_build_offices_panel())

func _make_shell(title: String, subtitle: String) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 18)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var header := HBoxContainer.new()
	var title_stack := VBoxContainer.new()
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_stack.add_child(UI.label(title, 25, UI.PAPER, true))
	title_stack.add_child(UI.label(subtitle, 12, UI.MUTED, false))
	header.add_child(title_stack)
	var close_button := UI.button("ĐÓNG", false, UI.GOLD)
	close_button.pressed.connect(func(): closed.emit())
	header.add_child(close_button)
	column.add_child(header)
	var line := ColorRect.new()
	line.color = Color(UI.GOLD, 0.65)
	line.custom_minimum_size.y = 1.0
	column.add_child(line)
	var feedback := str(_vm.get("feedback", ""))
	if not feedback.is_empty():
		column.add_child(UI.label(feedback, 12, UI.JADE, false))
	return margin

func _build_progress_panel() -> Control:
	var card := UI.panel("HallProgress", UI.GOLD, UI.SURFACE)
	card.custom_minimum_size.x = 372
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	card.add_child(content)
	var hall_art := UI.illustration("hall")
	hall_art.custom_minimum_size = Vector2(342, 174)
	hall_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(hall_art)
	var metrics := HBoxContainer.new()
	metrics.add_child(UI.metric_card("CẤP CÔNG TRÌNH", str(_vm.get("building_level", 1)), "hall", UI.JADE))
	metrics.add_child(UI.metric_card("BẬC MÔN PHÁI", "%02d / 27" % int(_vm.get("rank_step", 1)), "rank", UI.GOLD))
	content.add_child(metrics)
	var progress := ProgressBar.new()
	progress.name = "RankProgress"
	progress.custom_minimum_size.y = 14
	progress.max_value = 1.0
	progress.value = clampf(float(_vm.get("rank_progress", 0.0)), 0.0, 1.0)
	progress.show_percentage = false
	content.add_child(progress)
	var rank_grid := GridContainer.new()
	rank_grid.name = "RankSteps"
	rank_grid.columns = 27
	rank_grid.add_theme_constant_override("h_separation", 2)
	rank_grid.add_theme_constant_override("v_separation", 5)
	var current_step := clampi(int(_vm.get("rank_step", 1)), 1, 27)
	for index in range(27):
		var tick := ColorRect.new()
		tick.custom_minimum_size = Vector2(8, 6)
		tick.color = UI.GOLD if index < current_step else Color(0.30, 0.39, 0.35, 1.0)
		rank_grid.add_child(tick)
	content.add_child(rank_grid)
	content.add_child(UI.section_heading("Điều kiện thăng bậc", "rank", UI.JADE))
	var rank_requirement := UI.label(str(_vm.get("rank_requirement", "Điều kiện do môn phái cung cấp")), 13, UI.TEXT, false)
	rank_requirement.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rank_requirement.custom_minimum_size.y = 48.0
	rank_requirement.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(rank_requirement)
	var promotion := UI.button("THĂNG BẬC", true, UI.GOLD)
	promotion.name = "PromoteRank"
	promotion.disabled = not bool(_vm.get("can_promote", false))
	promotion.pressed.connect(func(): promotion_requested.emit())
	content.add_child(promotion)
	return card

func _build_offices_panel() -> Control:
	var card := UI.panel("HallOffices", UI.JADE, UI.SURFACE)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	card.add_child(content)
	content.add_child(UI.section_heading("Bảy chức vụ", "person", UI.JADE))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	var office_map: Dictionary = {}
	for office in _vm.get("offices", []):
		office_map[str(office.get("id", ""))] = office
	for role_id in ROLE_IDS:
		var office: Dictionary = office_map.get(role_id, {})
		grid.add_child(_office_card(role_id, office))
	content.add_child(grid)
	var hint := UI.label("Chọn chức vụ để mở danh sách phân công.", 12, UI.MUTED, false)
	content.add_child(hint)
	var upgrade_row := HBoxContainer.new()
	upgrade_row.add_theme_constant_override("separation", 10)
	var costs_column := VBoxContainer.new()
	costs_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	costs_column.add_child(UI.section_heading("Nâng cấp Đại Điện", "resource", UI.GOLD))
	var costs := HBoxContainer.new()
	costs.add_theme_constant_override("separation", 9)
	for cost in _vm.get("upgrade_costs", []).slice(0, 3):
		var item := UI.resource_item(str(cost.get("name", "")), str(cost.get("amount", "")), str(cost.get("icon", "resource")))
		item.custom_minimum_size.x = 148
		costs.add_child(item)
	costs_column.add_child(costs)
	upgrade_row.add_child(costs_column)
	var upgrade := UI.button("NÂNG CẤP", true, UI.JADE)
	upgrade.name = "UpgradeHall"
	upgrade.disabled = not bool(_vm.get("can_upgrade", false))
	upgrade.pressed.connect(func(): hall_upgrade_requested.emit())
	upgrade_row.add_child(upgrade)
	content.add_child(upgrade_row)
	return card

func _office_card(role_id: String, office: Dictionary) -> Control:
	var card := UI.panel("Office_%s" % role_id, UI.BORDER, UI.SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(245, 78)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	card.add_child(row)
	row.add_child(UI.portrait_slot(str(office.get("disciple_name", "")), office.get("portrait"), Vector2(48, 48)))
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_child(UI.label(str(office.get("role_label", ROLE_LABELS[role_id])), 13, UI.PAPER, true))
	var disciple_name := str(office.get("disciple_name", "Chưa bổ nhiệm"))
	details.add_child(UI.label(disciple_name, 12, UI.TEXT, false))
	details.add_child(UI.label(str(office.get("office_rank", "—")), 10, UI.MUTED, false))
	row.add_child(details)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 4)
	var choose := UI.button("BỔ NHIỆM", false, UI.JADE)
	choose.name = "ChooseOffice"
	choose.custom_minimum_size = Vector2(88, 32)
	choose.pressed.connect(_request_office_selection.bind(role_id))
	actions.add_child(choose)
	var dismiss := UI.button("MIỄN NHIỆM", false, UI.RED)
	dismiss.name = "DismissOffice"
	dismiss.custom_minimum_size = Vector2(88, 32)
	dismiss.disabled = not bool(office.get("can_dismiss", false))
	dismiss.pressed.connect(func(): office_dismissal_requested.emit(role_id))
	actions.add_child(dismiss)
	row.add_child(actions)
	return card

func _request_office_selection(role_id: String) -> void:
	office_selection_requested.emit(role_id)
