extends Control
## Presentation-only Hall screen. bind_view_model() accepts authoritative data and emits UI intent signals.

signal office_selection_requested(role_id: String)
signal office_dismissal_requested(role_id: String)
signal promotion_requested
signal hall_upgrade_requested
signal closed

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const FACILITY_ART = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const ROLE_IDS := ["master", "guide", "teacher", "steward", "guardian", "alchemist", "discipline"]
const ROLE_LABELS := {
	"master": "Chưởng Môn", "guide": "Tiếp Dẫn Trưởng Lão", "teacher": "Truyền Công Trưởng Lão",
	"steward": "Nội Vụ Chấp Sự", "guardian": "Hộ Pháp Trưởng Lão",
	"alchemist": "Đan Đạo Trưởng Lão", "discipline": "Giới Luật Trưởng Lão"
}

signal hall_action_requested(action: String, value: String)
const TABS := ["Tổng quan","Chức vụ","Nâng cấp","Thăng bậc","Kinh tế","Chính sách"]
var _vm: Dictionary = {}
var _tab_index := 0
var _pages: Array[Control] = []
var _nav: Array[Button] = []

func bind_view_model(view_model: Dictionary) -> void:
	_vm = view_model.duplicate(true)
	_rebuild()

func _ready() -> void:
	_rebuild()

func get_tab_index() -> int:
	return _tab_index

func set_tab_index(index: int) -> void:
	_tab_index = clampi(index,0,TABS.size()-1)
	for i in range(_pages.size()):
		_pages[i].visible = i == _tab_index
	for i in range(_nav.size()):
		_nav[i].button_pressed = i == _tab_index
		_nav[i].add_theme_color_override("font_color",UI.INK if i == _tab_index else UI.TEXT)
		_nav[i].add_theme_color_override("font_pressed_color",UI.INK)
		_nav[i].add_theme_color_override("font_hover_color",UI.INK if i == _tab_index else UI.TEXT)
		_nav[i].add_theme_stylebox_override("normal",UI._button_style(i == _tab_index,UI.JADE,1.0))
		_nav[i].add_theme_stylebox_override("pressed",UI._button_style(true,UI.JADE,1.0))

func _surface(node_name: String) -> PanelContainer:
	var panel := UI.panel(node_name,UI.BORDER,UI.SURFACE)
	var style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.set_border_width_all(1)
	style.shadow_size = 0
	panel.add_theme_stylebox_override("panel",style)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return panel

func _stack(parent: Control, separation: int = 10) -> VBoxContainer:
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",separation)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(stack)
	return stack

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_pages.clear()
	_nav.clear()
	var bg := ColorRect.new()
	bg.color = UI.DEEP
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["margin_left","margin_right","margin_top","margin_bottom"]:
		margin.add_theme_constant_override(edge,18)
	add_child(margin)
	var root := _stack(margin,12)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation",16)
	root.add_child(header)
	var back := UI.button("‹ Bản đồ",false,UI.BORDER)
	back.name = "HallBackToMap"
	back.pressed.connect(func(): closed.emit())
	header.add_child(back)
	var title := UI.label("Đại Điện",32,UI.PAPER,true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	for entry in [["spirit_stones","Linh Thạch","gold"],["treasury","Ngân khố","resource"]]:
		if _vm.has(entry[0]):
			var token := UI.resource_item(str(entry[1]),str(_vm[entry[0]]),str(entry[2]))
			token.custom_minimum_size.x = 176
			header.add_child(token)
	root.add_child(HSeparator.new())
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",18)
	root.add_child(body)
	var sidebar := _surface("HallNavigation")
	var nav_style := sidebar.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	nav_style.bg_color = UI.DEEP
	nav_style.set_border_width_all(0)
	sidebar.add_theme_stylebox_override("panel",nav_style)
	sidebar.custom_minimum_size.x = 172
	sidebar.size_flags_horizontal = Control.SIZE_FILL
	body.add_child(sidebar)
	var rail := _stack(sidebar,7)
	var group := ButtonGroup.new()
	for i in range(TABS.size()):
		var button := UI.button(TABS[i],false,UI.BORDER)
		button.name = "HallTab_%d" % i
		button.toggle_mode = true
		button.button_group = group
		button.custom_minimum_size = Vector2(148,52)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size",17)
		button.add_theme_stylebox_override("pressed",UI._button_style(true,UI.GOLD,0.75))
		button.pressed.connect(set_tab_index.bind(i))
		rail.add_child(button)
		_nav.append(button)
	var pages := _stack(body,0)
	_pages = [_overview(),_build_offices_panel(),_upgrade_page(),_rank_page(),_economy_page(),_policy_page()]
	for page in _pages:
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		pages.add_child(page)
	set_tab_index(_tab_index)
	var feedback := str(_vm.get("feedback",""))
	if not feedback.is_empty():
		var message := UI.label(feedback,13,UI.JADE,false)
		message.name = "HallFeedback"
		root.add_child(message)

func _overview() -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",16)
	var hero := HBoxContainer.new()
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.add_theme_constant_override("separation",18)
	column.add_child(hero)
	var scene := _surface("HallArtworkStage")
	scene.size_flags_stretch_ratio = 1.0
	var stage_style := scene.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	stage_style.bg_color = UI.SURFACE_LIGHT
	stage_style.set_border_width_all(0)
	scene.add_theme_stylebox_override("panel",stage_style)
	hero.add_child(scene)
	var left := _stack(scene,8)
	var art: Control = FACILITY_ART.new()
	art.name = "HallSourceAArtwork"
	art.set("facility_kind","hall")
	art.custom_minimum_size = Vector2(350,280)
	art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	var stage_heading := UI.label("Tông môn · Đại Điện",25,UI.PAPER,true)
	stage_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(stage_heading)
	left.add_child(art)
	var level := UI.label("Đại Điện · Lv%d" % int(_vm.get("building_level",1)),20,UI.PAPER,true)
	level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(level)
	var info := _surface("HallSectSummary")
	UI.apply_premium_frame(info)
	info.custom_minimum_size.x = 290
	hero.add_child(info)
	var facts := _stack(info,14)
	facts.alignment = BoxContainer.ALIGNMENT_CENTER
	facts.add_child(UI.section_heading("Tông môn","rank",UI.GOLD))
	for office in _vm.get("offices",[]):
		if str(office.get("id","")) != "master":
			continue
		var master_row := HBoxContainer.new()
		master_row.add_theme_constant_override("separation",10)
		master_row.add_child(UI.portrait_slot(str(office.get("disciple_name","")),office.get("portrait"),Vector2(72,72)))
		var master_info := VBoxContainer.new()
		master_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		master_info.add_child(UI.label("Chưởng Môn",13,UI.MUTED,false))
		master_info.add_child(UI.label(str(office.get("disciple_name","Chưa bổ nhiệm")),19,UI.PAPER,true))
		master_info.add_child(UI.label(str(office.get("mastery_detail","")),12,UI.MUTED,false))
		master_row.add_child(master_info)
		facts.add_child(master_row)
		break
	var count := 0
	for office in _vm.get("offices",[]):
		if bool(office.get("can_dismiss",false)):
			count += 1
	var metrics := GridContainer.new()
	metrics.columns = 2
	metrics.add_theme_constant_override("h_separation",10)
	metrics.add_theme_constant_override("v_separation",10)
	facts.add_child(metrics)
	for entry in [
		["Bậc tông môn",str(_vm.get("rank_label",str(_vm.get("rank_step","—"))+" / 27")),"rank"],
		["Đệ tử",str(_vm.get("population_label","—")),"person"],
		["Chức vụ","%d / 7" % count,"office"],
		["Uy danh",str(_vm.get("prestige","—")),"rank"]
	]:
		var metric := UI.metric_card(str(entry[0]),str(entry[1]),str(entry[2]),UI.BORDER)
		metric.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		metrics.add_child(metric)
	var growth := _surface("HallGrowth")
	UI.apply_premium_frame(growth)
	growth.custom_minimum_size.y = 116
	growth.size_flags_vertical = Control.SIZE_FILL
	column.add_child(growth)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",20)
	growth.add_child(row)
	for entry in [["Nâng cấp Đại Điện","Lv%d → Lv%d" % [int(_vm.get("building_level",1)),mini(100,int(_vm.get("building_level",1))+1)],2],["Thăng bậc tông môn",str(_vm.get("rank_requirement","—")),3]]:
		var box := _stack(row,6)
		box.add_child(UI.label(str(entry[0]),16,UI.PAPER,true))
		var desc := UI.label(str(entry[1]),13,UI.MUTED,false)
		desc.custom_minimum_size.y = 30
		box.add_child(desc)
		var see := UI.button("Nâng cấp" if int(entry[2]) == 2 else "Thăng bậc",true,UI.JADE)
		see.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		see.custom_minimum_size = Vector2(148,40)
		see.pressed.connect(set_tab_index.bind(int(entry[2])))
		box.add_child(see)
	return column

func _upgrade_page() -> Control:
	var card := _surface("HallProgress")
	var content := _stack(card,15)
	var center := HBoxContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation",24)
	content.add_child(center)
	var art_panel := _surface("HallUpgradeArtwork")
	art_panel.size_flags_stretch_ratio = 0.8
	center.add_child(art_panel)
	var art: Control = FACILITY_ART.new()
	art.set("facility_kind","hall")
	art.custom_minimum_size = Vector2(285,180)
	art_panel.add_child(art)
	var form := _stack(center,12)
	form.size_flags_stretch_ratio = 1.4
	content = form
	content.add_child(UI.section_heading("Nâng cấp Đại Điện","upgrade",UI.GOLD))
	content.add_child(UI.label("Lv%d  →  Lv%d / 100" % [int(_vm.get("building_level",1)),mini(100,int(_vm.get("building_level",1))+1)],30,UI.PAPER,true))
	content.add_child(UI.label(str(_vm.get("upgrade_status","")),15,UI.MUTED,false))
	content.add_child(UI.label("Nguyên liệu · Có / Cần",16,UI.PAPER,true))
	for unlocked in _vm.get("upgrade_unlocks",[]):
		content.add_child(UI.label("Sẽ mở chức vụ: "+str(unlocked),14,UI.JADE,false))
	for cost in _vm.get("upgrade_costs",[]):
		content.add_child(UI.resource_item(str(cost.get("name","")),str(cost.get("available","—"))+" / "+str(cost.get("amount","")),str(cost.get("icon","resource"))))
	var button := UI.button("Nâng cấp",true,UI.JADE)
	button.name = "UpgradeHall"
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.custom_minimum_size = Vector2(220,48)
	button.disabled = not bool(_vm.get("can_upgrade",false))
	button.pressed.connect(func(): hall_upgrade_requested.emit())
	content.add_child(button)
	return card

func _rank_page() -> Control:
	var card := _surface("HallRank")
	UI.apply_premium_frame(card)
	var content := _stack(card,13)
	content.add_child(UI.section_heading("Thăng bậc tông môn","rank",UI.GOLD))
	content.add_child(UI.label(str(_vm.get("rank_label","Bậc"))+" · %d / 27" % int(_vm.get("rank_step",1)),24,UI.PAPER,true))
	var steps := GridContainer.new()
	steps.name = "RankSteps"
	steps.columns = 27
	steps.add_theme_constant_override("h_separation",5)
	for i in range(27):
		var tick := ColorRect.new()
		tick.custom_minimum_size = Vector2(18,9)
		tick.color = UI.GOLD if i < int(_vm.get("rank_step",1)) else UI.BORDER
		steps.add_child(tick)
	content.add_child(steps)
	content.add_child(UI.label(str(_vm.get("rank_requirement","—")),14,UI.MUTED,false))
	content.add_child(UI.label("Sức chứa theo bậc: %d → %d" % [int(_vm.get("rank_capacity",0)),int(_vm.get("next_rank_capacity",0))],14,UI.JADE,false))
	for requirement in _vm.get("rank_rows",[]):
		content.add_child(UI.resource_item(str(requirement.get("name","")),str(requirement.get("value","")),"rank"))
	for cost in _vm.get("promotion_costs",[]):
		content.add_child(UI.resource_item(str(cost.get("name","")),str(cost.get("amount","")),str(cost.get("icon","resource"))))
	var promotion := UI.button("Thăng bậc",true,UI.GOLD)
	promotion.name = "PromoteRank"
	promotion.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	promotion.custom_minimum_size = Vector2(220,48)
	promotion.disabled = not bool(_vm.get("can_promote",false))
	promotion.pressed.connect(func(): promotion_requested.emit())
	content.add_child(promotion)
	return card

func _economy_page() -> Control:
	var page := _surface("HallEconomy")
	var content := _stack(page,12)
	content.add_child(UI.section_heading("Kinh tế tông môn","resource",UI.GOLD))
	var ledger_panel := UI.panel("HallLedgerSurface",UI.BORDER,UI.SURFACE_LIGHT)
	content.add_child(ledger_panel)
	var ledger := UI.label(str(_vm.get("cashflow","Chưa có sổ thu chi.")),17,UI.TEXT,false)
	ledger.add_theme_constant_override("line_spacing",6)
	ledger.name = "HallReceiptLedger"
	ledger_panel.add_child(ledger)
	for action in _vm.get("economy_actions",[]):
		_add_action(content,action)
	var workers: Array = _vm.get("vein_workers",[])
	if not workers.is_empty():
		var choose := OptionButton.new()
		for worker in workers:
			choose.add_item(str(worker.get("name","")))
			choose.set_item_metadata(choose.item_count-1,str(worker.get("id","")))
		choose.custom_minimum_size = Vector2(300,48)
		choose.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		choose.add_theme_font_override("font",UI.font_face("body"))
		choose.add_theme_font_size_override("font_size",16)
		content.add_child(choose)
		var start := UI.button("Khai thác Linh Mạch",false,UI.JADE)
		start.name = "HallOriginVeinStart"
		start.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		start.custom_minimum_size = Vector2(240,48)
		start.pressed.connect(func(): hall_action_requested.emit("vein_start",str(choose.get_item_metadata(choose.selected))))
		content.add_child(start)
	return page

func _policy_page() -> Control:
	var page := _surface("HallPolicies")
	var content := _stack(page,12)
	content.add_child(UI.section_heading("Chính sách vận hành","office",UI.GOLD))
	for policy in _vm.get("policy_groups",[]):
		content.add_child(UI.label(str(policy.get("name","")),16,UI.PAPER,true))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation",8)
		content.add_child(row)
		for choice in policy.get("choices",[]):
			var button := UI.button(str(choice.get("name","")),str(choice.get("value","")) == str(policy.get("current","")),UI.JADE)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.custom_minimum_size.y = 40
			button.pressed.connect(_emit_action.bind(str(policy.get("action","")),str(choice.get("value",""))))
			row.add_child(button)
	for action in _vm.get("policy_actions",[]):
		_add_action(content,action)
	return page

func _add_action(parent: Control,action: Dictionary) -> void:
	var button := UI.button(str(action.get("label","")),false,UI.JADE)
	button.disabled = bool(action.get("disabled",false))
	button.custom_minimum_size = Vector2(300,48)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.pressed.connect(_emit_action.bind(str(action.get("action","")),str(action.get("value",""))))
	parent.add_child(button)

func _emit_action(action: String,value: String) -> void:
	hall_action_requested.emit(action,value)

func _build_offices_panel() -> Control:
	var card := UI.panel("HallOffices", UI.JADE, UI.SURFACE)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	card.add_child(content)
	content.add_child(UI.section_heading("Bảy chức vụ", "office", UI.JADE))
	content.add_child(UI.label("Một đệ tử chỉ giữ một chức vụ. Chọn người đang đủ điều kiện.",11,UI.MUTED,false))
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

	return card

func _office_card(role_id: String, office: Dictionary) -> Control:
	var card := UI.panel("Office_%s" % role_id, UI.BORDER, UI.SURFACE_LIGHT)
	card.custom_minimum_size = Vector2(245, 105)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	card.add_child(row)
	if office.get("portrait") is Texture2D:
		row.add_child(UI.portrait_slot(str(office.get("disciple_name","")),office.get("portrait"),Vector2(60,60)))
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_child(UI.label(str(office.get("role_label", ROLE_LABELS[role_id])), 14, UI.PAPER, true))
	var disciple_name := str(office.get("disciple_name", "Chưa bổ nhiệm"))
	details.add_child(UI.label(disciple_name, 13, UI.TEXT, false))
	var unlocked := bool(office.get("unlocked",true))
	var status := str(office.get("unlock_label",""))
	if not unlocked:
		var lock_note := UI.label(status,11,UI.RED,false)
		lock_note.tooltip_text = status
		details.add_child(lock_note)
	else:
		details.add_child(UI.label(str(office.get("mastery_detail",office.get("office_rank","—"))),11,UI.MUTED,false))
		var effect := UI.label(str(office.get("effect_label","")),11,UI.JADE,false)
		effect.tooltip_text = "Hiệu lực đang có từ SectHallSystem, không phải phần thưởng chưa mở."
		details.add_child(effect)
	row.add_child(details)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 4)
	var choose := UI.button("Bổ nhiệm", false, UI.JADE)
	choose.name = "ChooseOffice"
	choose.custom_minimum_size = Vector2(90, 34)
	choose.disabled = not unlocked
	choose.visible = unlocked
	choose.tooltip_text = status if not unlocked else "Chỉ chọn đệ tử đủ điều kiện."
	choose.pressed.connect(_request_office_selection.bind(role_id))
	actions.add_child(choose)
	var dismiss := UI.button("Miễn nhiệm", false, UI.RED)
	dismiss.name = "DismissOffice"
	dismiss.custom_minimum_size = Vector2(90, 34)
	dismiss.disabled = not bool(office.get("can_dismiss", false))
	dismiss.visible = not dismiss.disabled
	dismiss.pressed.connect(func(): office_dismissal_requested.emit(role_id))
	actions.add_child(dismiss)
	row.add_child(actions)
	return card

func _request_office_selection(role_id: String) -> void:
	office_selection_requested.emit(role_id)
