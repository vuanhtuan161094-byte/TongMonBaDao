extends Control
## Presentation-only Residence screen. No occupancy, capacity, cost or build state is derived here.

signal site_selection_requested(site_id: String)
signal residence_build_requested(site_id: String)
signal residence_upgrade_requested(residence_id: String)
signal closed

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
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
	var shell := _make_shell()
	add_child(shell)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	shell.get_child(0).add_child(body)
	body.add_child(_build_rooms_panel())
	body.add_child(_build_sites_panel())

func _make_shell() -> MarginContainer:
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
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(UI.label("ĐỆ TỬ XÁ", 25, UI.PAPER, true))
	stack.add_child(UI.label("Phòng ở • cư trú • quy hoạch lô đất", 12, UI.MUTED, false))
	header.add_child(stack)
	var close_button := UI.button("ĐÓNG", false, UI.GOLD)
	close_button.pressed.connect(func(): closed.emit())
	header.add_child(close_button)
	column.add_child(header)
	var line := ColorRect.new()
	line.color = Color(UI.GOLD, 0.65)
	line.custom_minimum_size.y = 1.0
	column.add_child(line)
	return margin

func _build_rooms_panel() -> Control:
	var card := UI.panel("ResidenceRooms", UI.GOLD, UI.SURFACE)
	card.custom_minimum_size.x = 430
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	card.add_child(content)
	content.add_child(UI.section_heading("Khu cư trú", "bed", UI.GOLD))
	var residence_art := UI.illustration("residence")
	residence_art.custom_minimum_size = Vector2(360, 138)
	residence_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(residence_art)
	var metrics := HBoxContainer.new()
	metrics.add_child(UI.metric_card("CẤP XÁ", str(_vm.get("building_level", 1)), "hall", UI.JADE))
	metrics.add_child(UI.metric_card("PHÒNG", str(_vm.get("room_count_label", "—")), "bed", UI.GOLD))
	content.add_child(metrics)
	content.add_child(UI.section_heading("Giường & đệ tử", "person", UI.JADE))
	var beds := GridContainer.new()
	beds.columns = 5
	beds.add_theme_constant_override("h_separation", 5)
	beds.add_theme_constant_override("v_separation", 5)
	for bed in _vm.get("bed_slots", []):
		beds.add_child(_bed_slot(bed))
	var bed_scroll := ScrollContainer.new()
	bed_scroll.custom_minimum_size.y = 210
	bed_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(bed_scroll)
	bed_scroll.add_child(beds)
	return card

func _bed_slot(bed: Dictionary) -> Control:
	var card := UI.panel("Bed_%s" % str(bed.get("id", "")), UI.BORDER, UI.SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(64, 68)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 1)
	card.add_child(content)
	var resident := bool(bed.get("occupied", false))
	var icon = UI.ICON_SCRIPT.new()
	icon.kind = "person" if resident else "bed"
	icon.tint = UI.JADE if resident else UI.MUTED
	icon.custom_minimum_size = Vector2(22, 22)
	content.add_child(icon)
	content.add_child(UI.label(str(bed.get("disciple_short_name", "Trống")), 9, UI.TEXT if resident else UI.MUTED, false))
	return card

func _build_sites_panel() -> Control:
	var card := UI.panel("ResidenceSites", UI.JADE, UI.SURFACE)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	card.add_child(content)
	content.add_child(UI.section_heading("Lô xây dựng", "hall", UI.JADE))
	content.add_child(UI.label("Tình trạng và hành động nhận từ hệ thống công trình.", 12, UI.MUTED, false))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 9)
	grid.add_theme_constant_override("v_separation", 9)
	for site in _vm.get("sites", []):
		grid.add_child(_site_card(site))
	var plot_scroll := ScrollContainer.new()
	plot_scroll.custom_minimum_size.y = 338
	plot_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(plot_scroll)
	plot_scroll.add_child(grid)
	var selected_id := str(_vm.get("selected_residence_id", ""))
	var selected_site := _find_site(selected_id)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	var build := UI.button("XÂY DỰNG LÔ ĐÃ CHỌN", true, UI.GOLD)
	build.name = "BuildSelectedSite"
	build.disabled = selected_site.is_empty() or not bool(selected_site.get("can_build", false))
	build.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build.pressed.connect(func(): residence_build_requested.emit(selected_id))
	footer.add_child(build)
	var upgrade := UI.button("NÂNG CẤP", false, UI.JADE)
	upgrade.name = "UpgradeResidence"
	upgrade.disabled = selected_site.is_empty() or not bool(selected_site.get("can_upgrade", false))
	upgrade.pressed.connect(func(): residence_upgrade_requested.emit(selected_id))
	footer.add_child(upgrade)
	content.add_child(footer)
	return card

func _site_card(site: Dictionary) -> Control:
	var site_id := str(site.get("id", ""))
	var card := UI.panel("Site_%s" % site_id, UI.BORDER, UI.SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(245, 118)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	card.add_child(content)
	var heading := HBoxContainer.new()
	var marker = UI.ICON_SCRIPT.new()
	marker.kind = "hall" if bool(site.get("built", false)) else "lock"
	marker.tint = UI.GOLD if bool(site.get("built", false)) else UI.MUTED
	marker.custom_minimum_size = Vector2(22, 22)
	heading.add_child(marker)
	var title := UI.label(str(site.get("name", site_id)), 14, UI.PAPER, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	content.add_child(heading)
	content.add_child(UI.label(str(site.get("status", "—")), 12, UI.TEXT, false))
	content.add_child(UI.label(str(site.get("resident_summary", "")), 11, UI.MUTED, false))
	var select := UI.button("CHỌN LÔ", false, UI.JADE)
	select.name = "SelectSite"
	select.custom_minimum_size.y = 40
	select.pressed.connect(_request_site_selection.bind(site_id))
	content.add_child(select)
	return card

func _find_site(site_id: String) -> Dictionary:
	for site in _vm.get("sites", []):
		if str(site.get("id", "")) == site_id:
			return site
	return {}

func _request_site_selection(site_id: String) -> void:
	site_selection_requested.emit(site_id)
