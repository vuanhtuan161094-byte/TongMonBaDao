extends Control
## Presentation-only Residence screen. No occupancy, capacity, cost or build state is derived here.

signal site_selection_requested(site_id: String)
signal residence_build_requested(site_id: String)
signal residence_upgrade_requested(residence_id: String)
signal room_management_requested
signal room_assignment_requested(disciple_id: String, house_id: String)
signal closed

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const FACILITY_ART = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
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
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	var body_scroll := ScrollContainer.new()
	body_scroll.name = "ResidenceBodyScroll"
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_scroll.add_child(body)
	shell.get_child(0).add_child(body_scroll)
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
	var feedback := str(_vm.get("feedback", ""))
	if not feedback.is_empty():
		column.add_child(UI.label(feedback, 12, UI.JADE, false))
	return margin

func _build_rooms_panel() -> Control:
	var card := UI.panel("ResidenceRooms", UI.GOLD, UI.SURFACE)
	card.custom_minimum_size.x = 430
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	card.add_child(content)
	content.add_child(UI.section_heading("Khu cư trú", "bed", UI.GOLD))
	var residence_art: Control = FACILITY_ART.new()
	residence_art.name = "ResidenceSourceAArtwork"
	residence_art.set("facility_kind", "residence")
	residence_art.custom_minimum_size = Vector2(360, 164)
	residence_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(residence_art)
	var metrics := HBoxContainer.new()
	var level_metric := UI.metric_card("CẤP XÁ", str(_vm.get("building_level", 1)), "hall", UI.JADE)
	level_metric.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metrics.add_child(level_metric)
	var beds_metric := UI.metric_card("CƯ TRÚ", str(_vm.get("room_count_label", "—")), "bed", UI.GOLD)
	beds_metric.custom_minimum_size.x = 216
	beds_metric.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metrics.add_child(beds_metric)
	content.add_child(metrics)
	content.add_child(UI.section_heading("Giường & đệ tử", "person", UI.JADE))
	var bed_legend := HBoxContainer.new()
	bed_legend.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bed_legend.add_theme_constant_override("separation", 7)
	var occupied_legend := HBoxContainer.new()
	occupied_legend.add_theme_constant_override("separation", 4)
	occupied_legend.add_child(UI.icon("person", 18, UI.JADE))
	var occupied_label := UI.label("Đang ở", 10, UI.MUTED, false)
	occupied_label.custom_minimum_size.x = 58
	occupied_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	occupied_legend.add_child(occupied_label)
	bed_legend.add_child(occupied_legend)
	var empty_bed_legend := HBoxContainer.new()
	empty_bed_legend.add_theme_constant_override("separation", 4)
	empty_bed_legend.add_child(UI.icon("bed", 18, UI.GOLD))
	var empty_bed_label := UI.label("Giường trống", 10, UI.MUTED, false)
	empty_bed_label.custom_minimum_size.x = 88
	empty_bed_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	empty_bed_legend.add_child(empty_bed_label)
	bed_legend.add_child(empty_bed_legend)
	content.add_child(bed_legend)
	var bed_scroll := ScrollContainer.new()
	bed_scroll.name = "ResidenceBedScroll"
	bed_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bed_scroll.custom_minimum_size.y = 190
	bed_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var beds := GridContainer.new()
	beds.name = "ResidenceBedSlots"
	beds.columns = 4
	beds.add_theme_constant_override("h_separation", 5)
	beds.add_theme_constant_override("v_separation", 5)
	for bed in _vm.get("bed_slots", []):
		beds.add_child(_bed_slot(bed))
	bed_scroll.add_child(beds)
	content.add_child(bed_scroll)
	return card

func _bed_slot(bed: Dictionary) -> Control:
	var card := UI.panel("Bed_%s" % str(bed.get("id", "")), UI.BORDER, UI.SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(88, 82)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 1)
	card.add_child(content)
	var resident := bool(bed.get("occupied", false))
	var icon = UI.ICON_SCRIPT.new()
	icon.kind = "person" if resident else "bed"
	icon.tint = UI.JADE if resident else UI.MUTED
	icon.custom_minimum_size = Vector2(22, 22)
	content.add_child(icon)
	var resident_label := UI.label(str(bed.get("disciple_short_name", "Trống")), 11, UI.TEXT if resident else UI.MUTED, false)
	resident_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resident_label.custom_minimum_size.y = 28
	resident_label.tooltip_text = str(bed.get("disciple_short_name", "Trống"))
	content.add_child(resident_label)
	return card

func _build_sites_panel() -> Control:
	var card := UI.panel("ResidenceSites", UI.JADE, UI.SURFACE)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	var management_scroll := ScrollContainer.new()
	management_scroll.name = "ResidenceManagementScroll"
	management_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	management_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	management_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	management_scroll.add_child(content)
	card.add_child(management_scroll)
	content.add_child(UI.section_heading("Mở rộng khu cư trú", "guide", UI.JADE))
	var selected_id := str(_vm.get("selected_residence_id", ""))
	var selected_site := _find_site(selected_id)
	var house_row := HBoxContainer.new()
	house_row.custom_minimum_size.y = 44
	var house_label := UI.label("Quản lý xá",13,UI.TEXT,true)
	house_label.custom_minimum_size.x = 96
	house_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	house_label.tooltip_text = "Chọn Đệ Tử Xá cần xem, nâng cấp hoặc phân phòng."
	house_row.add_child(house_label)
	var house_picker := OptionButton.new()
	house_picker.name = "ResidenceManageSelector"
	house_picker.custom_minimum_size = Vector2(270,44)
	house_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	house_picker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var house_options: Array = _vm.get("house_options",[])
	var selected_index := 0
	for index in range(house_options.size()):
		var option: Dictionary = house_options[index]
		house_picker.add_item(str(option.get("name","Đệ Tử Xá")))
		house_picker.set_item_metadata(index,str(option.get("id","")))
		if str(option.get("id","")) == selected_id:
			selected_index = index
	if house_options.is_empty():
		house_picker.add_item("Chưa có Đệ Tử Xá")
		house_picker.disabled = true
	else:
		house_picker.select(selected_index)
		house_picker.item_selected.connect(func(index:int): site_selection_requested.emit(str(house_picker.get_item_metadata(index))))
	house_row.add_child(house_picker)
	content.add_child(house_row)
	var selected_name := str(selected_site.get("name","Đệ Tử Xá"))
	content.add_child(UI.label("%s · %s · %s" % [selected_name,str(selected_site.get("status","—")),str(selected_site.get("resident_summary","0/0 giường"))],14,UI.PAPER,true))

	var upgrade_block := UI.panel("ResidenceUpgradeBlock",UI.GOLD,UI.SURFACE_LIGHT)
	var upgrade_content := VBoxContainer.new()
	upgrade_content.add_theme_constant_override("separation",6)
	upgrade_block.add_child(upgrade_content)
	upgrade_content.add_child(UI.section_heading("Nâng xá · +2 giường mỗi cấp", "upgrade", UI.GOLD))
	var upgrade_costs: Array[String] = []
	for cost in _vm.get("upgrade_costs",[]):
		upgrade_costs.append("%s %s" % [str(cost.get("name","")),str(cost.get("amount",""))])
	upgrade_content.add_child(UI.label("Chi phí nâng cấp tiếp theo: %s" % (" · ".join(upgrade_costs) if not upgrade_costs.is_empty() else "—"),12,UI.MUTED,false))
	var upgrade := UI.button("NÂNG CẤP ĐỆ TỬ XÁ",true,UI.JADE)
	upgrade.name = "UpgradeResidence"
	upgrade.disabled = not bool(_vm.get("can_upgrade_selected",false))
	upgrade.tooltip_text = "Nâng xá dùng tài nguyên thật trong Kho; không cấp miễn phí." if not upgrade.disabled else "Không thể nâng: kiểm tra cấp Đại Điện, công trình đang làm và tài nguyên trong Kho."
	upgrade.pressed.connect(func(): residence_upgrade_requested.emit(selected_id))
	upgrade_content.add_child(upgrade)
	content.add_child(upgrade_block)

	var building_block := UI.panel("ResidenceBuildBlock",UI.JADE,UI.SURFACE_LIGHT)
	var build_content := VBoxContainer.new()
	build_content.add_theme_constant_override("separation",6)
	building_block.add_child(build_content)
	build_content.add_child(UI.section_heading("Xây thêm nhà", "build", UI.JADE))
	var hall_level := int(_vm.get("hall_level",0))
	var hall_required := int(_vm.get("next_house_hall_level",11))
	var next_house := int(_vm.get("next_house_number",2))
	var gate_text := "Đại Điện Lv%d · cần Lv%d để mở Đệ Tử Xá %02d." % [hall_level,hall_required,next_house]
	if bool(_vm.get("can_build_next",false)):
		gate_text = "Đã mở lô hợp lệ. Chọn vị trí trên bản đồ rồi xác nhận; vật liệu và thời gian sẽ theo giá hiện hành."
	build_content.add_child(UI.label(gate_text,12,UI.TEXT,false))
	var build_costs: Array[String] = []
	for cost in _vm.get("next_house_costs",[]):
		build_costs.append("%s %s" % [str(cost.get("name","")),str(cost.get("amount",""))])
	build_content.add_child(UI.label("Chi phí nhà kế: %s · %d nhịp" % [" · ".join(build_costs),int(_vm.get("construction_ticks",0))],11,UI.MUTED,false))
	var build := UI.button("BỐ TRÍ TRÊN BẢN ĐỒ",false,UI.JADE)
	build.name = "BuildResidenceOnMap"
	build.disabled = not bool(_vm.get("can_build_next",false))
	build.tooltip_text = "Cần nâng Đại Điện và có lô hợp lệ trước khi khởi công." if build.disabled else "Chọn lô trực tiếp trên bản đồ; xem bóng công trình rồi xác nhận."
	build.pressed.connect(func(): residence_build_requested.emit(""))
	build_content.add_child(build)
	content.add_child(building_block)

	var assignment_block := UI.panel("ResidenceAssignmentBlock",UI.GOLD,UI.SURFACE_LIGHT)
	var assignment_content := VBoxContainer.new()
	assignment_content.add_theme_constant_override("separation",6)
	assignment_block.add_child(assignment_content)
	assignment_content.add_child(UI.section_heading("Phân phòng", "assignment", UI.GOLD))
	var assignment_row := HBoxContainer.new()
	assignment_row.add_theme_constant_override("separation",8)
	var disciple_picker := _option_picker("ResidenceRoomDisciple",_vm.get("room_disciple_options",[]),str(_vm.get("room_assignment_disciple_id","")))
	var room_picker := _option_picker("ResidenceRoomHouse",_vm.get("room_house_options",[]),str(_vm.get("room_assignment_house_id","")))
	disciple_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	room_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	assignment_row.add_child(disciple_picker)
	assignment_row.add_child(room_picker)
	assignment_content.add_child(assignment_row)
	assignment_content.add_child(UI.label(str(_vm.get("room_assignment_status","Chọn đệ tử và căn xá.")),11,UI.MUTED,false))
	var assign := UI.button("XÁC NHẬN PHÂN PHÒNG",false,UI.JADE)
	assign.name = "AssignResidenceRoom"
	assign.disabled = disciple_picker.disabled or room_picker.disabled or not bool(_vm.get("can_assign_room",false))
	assign.pressed.connect(func(): room_assignment_requested.emit(str(disciple_picker.get_item_metadata(disciple_picker.selected)),str(room_picker.get_item_metadata(room_picker.selected))))
	assignment_content.add_child(assign)
	content.add_child(assignment_block)

	var manage := UI.button("QUY HOẠCH / DỜI NHÀ TRÊN BẢN ĐỒ",false,UI.GOLD)
	manage.name = "ManageResidenceRooms"
	manage.pressed.connect(func(): room_management_requested.emit())
	content.add_child(manage)
	return card

func _option_picker(node_name: String, options: Array, selected_id: String) -> OptionButton:
	var picker := OptionButton.new()
	picker.name = node_name
	for index in range(options.size()):
		var option: Dictionary = options[index]
		picker.add_item(str(option.get("name","")))
		picker.set_item_metadata(index,str(option.get("id","")))
		if str(option.get("id","")) == selected_id:
			picker.select(index)
	if options.is_empty():
		picker.add_item("Chưa có lựa chọn")
		picker.disabled = true
	return picker

func _site_card(site: Dictionary) -> Control:
	var site_id := str(site.get("id", ""))
	var card := UI.panel("Site_%s" % site_id, UI.BORDER, UI.SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(245, 118)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	if site_id == str(_vm.get("selected_residence_id", "")):
		select.text = "ĐANG CHỌN"
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
