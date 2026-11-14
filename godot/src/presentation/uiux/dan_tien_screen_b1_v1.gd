extends Control
## Presentation-only candidate screen. All decisions and eligibility are delegated to caller callbacks.

signal candidate_page_requested(direction: int)
signal candidate_search_requested(query: String)
signal accept_candidate_requested(candidate_id: String)
signal reject_candidate_requested(candidate_id: String)
signal guide_management_requested
signal guidance_main_requested(disciple_id: String)
signal guidance_assistants_requested(disciple_ids: Array)
signal residence_capacity_requested
signal recruited_profile_requested(disciple_id: String)
signal recruited_assignment_requested(disciple_id: String)
signal recruited_world_requested(disciple_id: String)
signal recruitment_order_requested
signal closed

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const RADAR_SCRIPT = preload("res://src/presentation/uiux/sect_d7_radar_v1.gd")
const FACILITY_ART = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const VIS_QUALITY = preload("res://src/presentation/uiux/sect_quality_visual_v1.gd")
var _vm: Dictionary = {}
var _reject_armed := false
var _accept_armed := false
var _search_text := ""
var _candidate_index := 0
var _vis_reveal_seen: Dictionary = {}

func bind_view_model(view_model: Dictionary) -> void:
	_vm = view_model.duplicate(true)
	_reject_armed = false
	_accept_armed = false
	var preferred_id := str(view_model.get("selected_candidate_id", ""))
	_candidate_index = 0
	if not preferred_id.is_empty():
		var pool: Array = view_model.get("candidates", [])
		for index in range(pool.size()):
			if str(pool[index].get("id", "")) == preferred_id:
				_candidate_index = index
				break
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
	body.add_child(_build_candidate_panel())
	body.add_child(_build_radar_panel())
	_vis_run_first_reveal()

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
	header.add_theme_constant_override("separation", 10)
	var building_art: Control = FACILITY_ART.new()
	building_art.name = "GuidanceFacilityArt"
	building_art.set("facility_kind", "guidance")
	building_art.custom_minimum_size = Vector2(142, 100)
	building_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(building_art)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(UI.label("DẪN TIÊN ĐÀI", 25, UI.PAPER, true))
	stack.add_child(UI.label("Ứng viên • Tam Căn / Tứ Tính • tiếp dẫn", 12, UI.MUTED, false))
	header.add_child(stack)
	var reduce := UI.button("VFX: %s" % VIS_QUALITY.mode_label(), false, UI.JADE)
	reduce.name = "VISReducedMotionGuidance"
	reduce.pressed.connect(func():
		VIS_QUALITY.cycle_mode()
		_rebuild()
	)
	header.add_child(reduce)
	var close_button := UI.button("ĐÓNG", false, UI.GOLD)
	close_button.pressed.connect(func(): closed.emit())
	header.add_child(close_button)
	column.add_child(header)
	var line := ColorRect.new()
	line.color = Color(UI.GOLD, 0.65)
	line.custom_minimum_size.y = 1.0
	column.add_child(line)
	var feedback := str(_vm.get("feedback", ""))
	# A successful recruit already has a prominent persistent reveal card below.
	# Avoid adding a second status row above the whole screen, which squeezed the
	# fixed decision controls below the 1280x720 safe area after recruitment.
	var recruited: Dictionary = _vm.get("recruited_disciple", {})
	if not feedback.is_empty() and recruited.is_empty():
		column.add_child(UI.label(feedback, 12, UI.JADE, false))
	return margin

func _candidate() -> Dictionary:
	var pool := _filtered_candidates()
	if pool.is_empty() and not _vm.has("candidates"):
		return _vm.get("candidate", {})
	if pool.is_empty():
		return {}
	_candidate_index = clampi(_candidate_index, 0, pool.size() - 1)
	return pool[_candidate_index]

func _filtered_candidates() -> Array:
	var result: Array = []
	var source: Array = _vm.get("candidates", [])
	if source.is_empty():
		var single: Dictionary = _vm.get("candidate", {})
		if not single.is_empty():
			source = [single]
	for row in source:
		if not (row is Dictionary):
			continue
		var name := str(row.get("name", "")).to_lower()
		if not _search_text.is_empty() and not name.contains(_search_text.to_lower()):
			continue
		result.append(row)
	return result

func _apply_candidate_search(value: String = "") -> void:
	if value.is_empty() and has_node("CandidateSearch"):
		value = (get_node("CandidateSearch") as LineEdit).text
	_search_text = value.strip_edges()
	_candidate_index = 0
	_reject_armed = false
	_accept_armed = false
	candidate_search_requested.emit(_search_text)
	_rebuild()

func _step_candidate(direction: int) -> void:
	var pool := _filtered_candidates()
	if pool.size() <= 1:
		return
	_candidate_index = posmod(_candidate_index + direction, pool.size())
	_reject_armed = false
	_accept_armed = false
	candidate_page_requested.emit(direction)
	_rebuild()

func _on_accept_pressed() -> void:
	var candidate := _candidate()
	if not bool(candidate.get("can_accept", _vm.get("can_accept", false))) or _candidate_id().is_empty():
		return
	if not _accept_armed:
		_accept_armed = true
		_reject_armed = false
		_rebuild()
		return
	_accept_armed = false
	accept_candidate_requested.emit(_candidate_id())

func _build_candidate_panel() -> Control:
	var candidate := _candidate()
	var quality_id := VIS_QUALITY.id_from_name(str(candidate.get("quality", "")))
	var card := UI.panel("CandidateProfile", VIS_QUALITY.color_for(quality_id), UI.SURFACE)
	card.custom_minimum_size.x = 500
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_content := VBoxContainer.new()
	panel_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_content.add_theme_constant_override("separation",6)
	card.add_child(panel_content)
	var scroll := ScrollContainer.new()
	scroll.name = "CandidateProfileScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_content.add_child(scroll)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	content.add_child(UI.section_heading("Ứng viên", "recruit_order", UI.GOLD))
	var capacity := UI.panel("RecruitmentCapacity",UI.RED if bool(_vm.get("capacity_full",false)) else UI.JADE,UI.SURFACE_LIGHT)
	capacity.custom_minimum_size.y = 52
	var capacity_row := HBoxContainer.new()
	capacity_row.add_theme_constant_override("separation",8)
	var capacity_text := UI.label(str(_vm.get("capacity_text","Chỗ ở chưa được xác định")),12,UI.PAPER,true)
	capacity_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	capacity_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	capacity_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	capacity_text.tooltip_text = str(_vm.get("capacity_text","")) + "\n" + str(_vm.get("accept_gate",""))
	capacity_row.add_child(capacity_text)
	var expand := UI.button("MỞ RỘNG XÁ",false,UI.GOLD)
	expand.name = "OpenResidenceCapacity"
	expand.custom_minimum_size = Vector2(128,42)
	expand.pressed.connect(func(): residence_capacity_requested.emit())
	capacity_row.add_child(expand)
	capacity.add_child(capacity_row)
	content.add_child(capacity)
	var reveal := _build_recruit_reveal()
	if reveal != null:
		content.add_child(reveal)
	var search_row := HBoxContainer.new()
	search_row.add_theme_constant_override("separation", 6)
	var search := LineEdit.new()
	search.name = "CandidateSearch"
	search.placeholder_text = "Tìm tên ứng viên"
	search.text = _search_text
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.text_submitted.connect(_apply_candidate_search)
	search_row.add_child(search)
	var search_button := UI.button("TÌM", false, UI.JADE)
	search_button.name = "ApplyCandidateSearch"
	search_button.pressed.connect(func(): _apply_candidate_search(search.text))
	search_row.add_child(search_button)
	content.add_child(search_row)
	var pool := _filtered_candidates()
	content.add_child(UI.label("%d ứng viên%s" % [
		pool.size(), " · đã lọc" if not _search_text.is_empty() else ""
	], 11, UI.MUTED, false))
	if not pool.is_empty():
		var candidate_scroll := ScrollContainer.new()
		candidate_scroll.name = "CandidateChoiceScroll"
		candidate_scroll.custom_minimum_size.y = 58
		candidate_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		candidate_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		var candidate_choices := HBoxContainer.new()
		candidate_choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		candidate_choices.add_theme_constant_override("separation",6)
		var first_choice := clampi(_candidate_index-1,0,maxi(0,pool.size()-3))
		for choice_index in range(first_choice,mini(pool.size(),first_choice+3)):
			var row: Dictionary = pool[choice_index]
			var row_id := str(row.get("id",""))
			var selected := row_id == _candidate_id()
			var choice := UI.button("%s\n%s" % [str(row.get("name","Ứng viên")),str(row.get("quality","Phẩm chưa rõ"))],selected,UI.GOLD if selected else UI.JADE)
			choice.name = "CandidatePick_%s" % row_id
			choice.custom_minimum_size = Vector2(138,60)
			choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			choice.disabled = selected
			choice.pressed.connect(_select_candidate_by_id.bind(row_id))
			VIS_QUALITY.apply_button(choice, VIS_QUALITY.id_from_name(str(row.get("quality", ""))))
			candidate_choices.add_child(choice)
		candidate_scroll.add_child(candidate_choices)
		content.add_child(candidate_scroll)
	var profile := HBoxContainer.new()
	profile.add_theme_constant_override("separation", 12)
	profile.add_child(_candidate_portrait(candidate))
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var candidate_name := UI.label(str(candidate.get("name", "Không có ứng viên phù hợp")), 22, UI.PAPER, true)
	candidate_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	VIS_QUALITY.apply_name(candidate_name, quality_id)
	detail.add_child(candidate_name)
	var identity_badges := HBoxContainer.new()
	identity_badges.add_theme_constant_override("separation", 6)
	identity_badges.add_child(_candidate_badge("PHẨM", str(candidate.get("quality", "—")), "rank", VIS_QUALITY.color_for(quality_id)))
	identity_badges.add_child(_candidate_badge("CẢNH GIỚI", str(candidate.get("realm", "—")), "root", UI.JADE))
	detail.add_child(identity_badges)
	detail.add_child(_candidate_info_row("search", str(candidate.get("origin", "—")), UI.MUTED))
	detail.add_child(_candidate_info_row("person", str(candidate.get("personality", "—")), UI.TEXT))
	detail.add_child(_candidate_info_row("check", str(candidate.get("status", "Chờ đánh giá")), UI.GOLD))
	profile.add_child(detail)
	content.add_child(profile)
	content.add_child(_candidate_info_row("root", str(candidate.get("root_values", "Linh Căn chưa có dữ liệu")), UI.JADE))
	content.add_child(_candidate_info_row("root", str(candidate.get("special_identity", "Các tầng ẩn chưa được khai mở")), UI.MUTED))
	content.add_child(_candidate_info_row("assignment", str(candidate.get("role_fit", "Chưa đủ dữ liệu tương hợp")), UI.JADE))
	var decisions := HBoxContainer.new()
	decisions.add_theme_constant_override("separation", 8)
	var accept := UI.button("XÁC NHẬN NHẬN ĐỆ TỬ" if _accept_armed else "NHẬN ĐỆ TỬ", true, UI.JADE)
	accept.name = "AcceptCandidate"
	accept.disabled = not bool(candidate.get("can_accept", _vm.get("can_accept", false))) or _candidate_id().is_empty()
	accept.tooltip_text = str(candidate.get("accept_reason",_vm.get("accept_gate","")))
	accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	accept.pressed.connect(_on_accept_pressed)
	decisions.add_child(accept)
	var reject := UI.button("XÁC NHẬN TỪ CHỐI" if _reject_armed else "TỪ CHỐI", false, UI.RED)
	reject.name = "RejectCandidate"
	reject.disabled = not bool(candidate.get("can_reject", _vm.get("can_reject", false))) or _candidate_id().is_empty()
	reject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reject.pressed.connect(_on_reject_pressed)
	decisions.add_child(reject)
	panel_content.add_child(UI.section_heading("Quyết định", "office", UI.JADE))
	var gate_reason := str(candidate.get("accept_reason", _vm.get("accept_gate", ""))).strip_edges()
	if not gate_reason.is_empty():
		var gate_label := UI.label(gate_reason, 11, UI.RED if accept.disabled else UI.JADE, false)
		gate_label.name = "CandidateEligibilityReason"
		gate_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		gate_label.custom_minimum_size.y = 26
		gate_label.tooltip_text = gate_reason
		panel_content.add_child(gate_label)
	panel_content.add_child(decisions)
	content.add_child(_build_guidance_management())
	var management := VBoxContainer.new()
	management.add_theme_constant_override("separation", 6)
	var order_row := HBoxContainer.new()
	order_row.add_theme_constant_override("separation", 9)
	order_row.add_child(UI.icon("recruit_order", 34, UI.GOLD))
	var order := UI.button("CHIÊU MỘ LỆNH · CÒN %d" % int(_vm.get("recruitment_tokens", 0)), true, UI.JADE)
	order.name = "UseRecruitmentOrder"
	order.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	order.disabled = not bool(_vm.get("can_use_order", false))
	order.tooltip_text = "Tốn 1 Chiêu Mộ Lệnh để tạo ứng viên; không tuyển trực tiếp." if not order.disabled else "Cần còn lệnh, hàng chờ dưới 30 và Dẫn Tiên Đài đang mở."
	order.pressed.connect(func(): recruitment_order_requested.emit())
	order_row.add_child(order)
	management.add_child(order_row)
	content.add_child(management)
	var pager := HBoxContainer.new()
	var previous := UI.button("‹ ỨNG VIÊN TRƯỚC", false, UI.JADE)
	previous.name = "PreviousCandidate"
	previous.disabled = pool.size() <= 1
	previous.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	previous.pressed.connect(_step_candidate.bind(-1))
	pager.add_child(previous)
	var next := UI.button("ỨNG VIÊN TIẾP ›", false, UI.JADE)
	next.name = "NextCandidate"
	next.disabled = pool.size() <= 1
	next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next.pressed.connect(_step_candidate.bind(1))
	pager.add_child(next)
	content.add_child(pager)
	return card

func _candidate_badge(title: String, value: String, icon_kind: String, accent: Color) -> Control:
	var badge := UI.panel("CandidateIdentityBadge", accent, UI.SURFACE_LIGHT)
	badge.custom_minimum_size = Vector2(132, 52)
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)
	row.add_child(UI.icon(icon_kind, 22, accent))
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.add_theme_constant_override("separation", 0)
	var title_label := UI.label(title, 9, UI.MUTED, false)
	title_label.custom_minimum_size.x = 74
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	labels.add_child(title_label)
	var value_label := UI.label(value, 12, UI.PAPER, true)
	# A two-line value is preferable to hiding the candidate's actual realm.
	value_label.custom_minimum_size.x = 74
	value_label.custom_minimum_size.y = 29
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value_label.max_lines_visible = 2
	value_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	value_label.tooltip_text = value
	labels.add_child(value_label)
	row.add_child(labels)
	badge.add_child(row)
	return badge

func _candidate_info_row(icon_kind: String, value: String, accent: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var icon := UI.icon(icon_kind, 18, accent)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	var detail := UI.label(value, 11, UI.TEXT, false)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size.y = 22
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	detail.tooltip_text = value
	row.add_child(detail)
	return row

func _candidate_portrait(candidate: Dictionary) -> Control:
	var texture_value: Variant = candidate.get("portrait")
	var verified := bool(candidate.get("source_art_approved", false)) and texture_value is Texture2D
	var portrait := UI.portrait_slot(str(candidate.get("name", "")), texture_value if verified else null, Vector2(156, 188))
	portrait.name = "VerifiedSourceACandidatePreview" if verified else "CandidateUnverifiedPortrait"
	var stack := VBoxContainer.new()
	stack.name = "CandidatePortraitBlock"
	stack.custom_minimum_size = Vector2(156, 210)
	stack.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stack.add_child(VIS_QUALITY.wrap_portrait(portrait, Vector2(156, 188), VIS_QUALITY.id_from_name(str(candidate.get("quality", "")))))
	var caption := UI.label("ẢNH SOURCE A" if verified else "CHƯA CÓ ẢNH ĐÃ DUYỆT", 9, UI.GOLD if verified else UI.MUTED, true)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.tooltip_text = "Chân dung lấy từ actor Source A đã qua cổng xác thực." if verified else "Không có chân dung Source A đã xác thực cho ứng viên này; dùng biểu tượng trung tính."
	stack.add_child(caption)
	return stack

func _select_candidate_by_id(candidate_id: String) -> void:
	var pool: Array = _filtered_candidates()
	for index in range(pool.size()):
		if str(pool[index].get("id","")) == candidate_id:
			_candidate_index = index
			_reject_armed = false
			_accept_armed = false
			candidate_page_requested.emit(0)
			_rebuild()
			return

func _build_recruit_reveal() -> Control:
	var disciple: Dictionary = _vm.get("recruited_disciple",{})
	if disciple.is_empty():
		return null
	var quality_id := VIS_QUALITY.id_from_name(str(disciple.get("quality", "")))
	var panel := UI.panel("RecruitmentReveal",VIS_QUALITY.color_for(quality_id),UI.SURFACE_LIGHT)
	VIS_QUALITY.apply_frame_material(panel as PanelContainer, quality_id)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",6)
	panel.add_child(content)
	content.add_child(UI.section_heading("Đệ tử đã gia nhập Tông Môn", "check", UI.GOLD))
	if quality_id == "heaven_defying":
		var seal := UI.label("✦  NGŨ SẮC TIÊN QUANG  ✦", 12, VIS_QUALITY.color_for(quality_id), true)
		seal.name = "VIS05DivineSeal"
		seal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(seal)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",10)
	var portrait: Variant = disciple.get("portrait")
	row.add_child(VIS_QUALITY.wrap_portrait(UI.portrait_slot(str(disciple.get("name","")),portrait,Vector2(82,96)), Vector2(82,96), quality_id))
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var recruited_name := UI.label(str(disciple.get("name","Đệ tử mới")),18,UI.PAPER,true)
	VIS_QUALITY.apply_name(recruited_name, quality_id)
	detail.add_child(recruited_name)
	detail.add_child(UI.label("%s · %s · %s tuổi" % [str(disciple.get("quality","—")),str(disciple.get("sex","—")),str(disciple.get("age","—"))],12,VIS_QUALITY.color_for(quality_id),false))
	detail.add_child(UI.label("%s · %s" % [str(disciple.get("root","Linh Căn chưa rõ")),str(disciple.get("profession","Chưa có thiên phú nghề"))],11,UI.TEXT,false))
	detail.add_child(UI.label(str(disciple.get("stats","")),10,UI.MUTED,false))
	row.add_child(detail)
	content.add_child(row)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation",6)
	var profile := UI.button("XEM HỒ SƠ",false,UI.GOLD)
	profile.name = "RecruitedDiscipleProfile"
	profile.pressed.connect(func(): recruited_profile_requested.emit(str(disciple.get("id",""))))
	actions.add_child(profile)
	var assign := UI.button("PHÂN CÔNG",true,UI.JADE)
	assign.name = "RecruitedDiscipleAssignment"
	assign.pressed.connect(func(): recruited_assignment_requested.emit(str(disciple.get("id",""))))
	actions.add_child(assign)
	var world := UI.button("TỚI NHÂN VẬT",false,UI.JADE)
	world.name = "RecruitedDiscipleWorld"
	world.pressed.connect(func(): recruited_world_requested.emit(str(disciple.get("id",""))))
	actions.add_child(world)
	content.add_child(actions)
	return panel

func _build_guidance_management() -> Control:
	var panel := UI.panel("GuidanceAssignmentBlock",UI.GOLD,UI.SURFACE_LIGHT)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",5)
	panel.add_child(content)
	content.add_child(UI.section_heading("Tiếp Dẫn chính / phụ", "assignment", UI.GOLD))
	var options: Array = _vm.get("guidance_options",[])
	var main_id := str(_vm.get("guidance_main_id",""))
	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation",6)
	var main_picker := OptionButton.new()
	main_picker.name = "GuidanceMainPicker"
	main_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_picker.add_item("Chưa bổ nhiệm")
	main_picker.set_item_metadata(0,"")
	var selected_index := 0
	for option in options:
		var id := str(option.get("id",""))
		var eligible := bool(option.get("eligible",false))
		main_picker.add_item(str(option.get("name","Đệ tử")))
		var index := main_picker.item_count-1
		main_picker.set_item_metadata(index,id)
		if not eligible and id != main_id:
			main_picker.set_item_disabled(index,true)
		if id == main_id:
			selected_index = index
	main_picker.select(selected_index)
	main_row.add_child(main_picker)
	var apply_main := UI.button("LƯU TIẾP DẪN CHÍNH",false,UI.JADE)
	apply_main.name = "AssignGuidanceMain"
	apply_main.disabled = not bool(_vm.get("can_assign_guidance",false))
	apply_main.pressed.connect(func(): guidance_main_requested.emit(str(main_picker.get_item_metadata(main_picker.selected))))
	main_row.add_child(apply_main)
	content.add_child(main_row)
	var max_assistants := int(_vm.get("guidance_max_assistants",0))
	var current_assistants: Array = _vm.get("guidance_assistant_ids",[])
	content.add_child(UI.label("Chỗ Tiếp Dẫn: %d · phụ tối đa %d · đang chọn %d" % [int(_vm.get("guidance_slots",0)),max_assistants,current_assistants.size()],11,UI.MUTED,false))
	var assistant_scroll := ScrollContainer.new()
	assistant_scroll.name = "GuidanceAssistantScroll"
	assistant_scroll.custom_minimum_size.y = 96
	assistant_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var assistant_list := VBoxContainer.new()
	assistant_list.name = "GuidanceAssistantOptions"
	for option in options:
		var id := str(option.get("id",""))
		if id.is_empty() or id == main_id:
			continue
		var eligible := bool(option.get("eligible",false))
		var selected := current_assistants.has(id)
		var check := CheckBox.new()
		check.name = "GuidanceAssistant_%s" % id
		check.text = str(option.get("name","Đệ tử")) + ("" if eligible else " · đang bận / bị thương")
		check.button_pressed = selected
		check.disabled = not eligible and not selected
		check.custom_minimum_size.y = 40
		check.add_theme_font_size_override("font_size",13)
		assistant_list.add_child(check)
	assistant_scroll.add_child(assistant_list)
	content.add_child(assistant_scroll)
	var apply_assistants := UI.button("CẬP NHẬT TIẾP DẪN PHỤ",false,UI.GOLD)
	apply_assistants.name = "AssignGuidanceAssistants"
	apply_assistants.disabled = not bool(_vm.get("can_assign_guidance",false))
	apply_assistants.pressed.connect(_submit_assistant_selection.bind(assistant_list))
	content.add_child(apply_assistants)
	return panel

func _submit_assistant_selection(list: VBoxContainer) -> void:
	var ids: Array[String] = []
	for child in list.get_children():
		if child is CheckBox and (child as CheckBox).button_pressed:
			ids.append(str(child.name).trim_prefix("GuidanceAssistant_"))
	guidance_assistants_requested.emit(ids)

func _build_radar_panel() -> Control:
	var candidate := _candidate()
	var card := UI.panel("CandidateStats", UI.JADE, UI.SURFACE)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	card.add_child(content)
	content.add_child(UI.section_heading("Tam Căn / Tứ Tính • Căn cơ", "root", UI.JADE))
	var radar: Control
	var radar_factory: Variant = _vm.get("radar_factory")
	if radar_factory is Callable and radar_factory.is_valid():
		var created: Variant = radar_factory.call()
		if created is Control:
			radar = created
	if radar == null:
		radar = RADAR_SCRIPT.new()
	radar.name = "FoundationRadar"
	# The chart remains readable at landscape 720p while leaving room for all
	# four real identity metrics below it without clipping the second row.
	radar.custom_minimum_size = Vector2(420, 260)
	radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(radar)
	if radar.has_method("set_values"):
		radar.call("set_values", candidate.get("tam_values", []), candidate.get("tu_values", []))
	var tam_note := str(candidate.get("tam_note", "")).strip_edges()
	if not tam_note.is_empty():
		var foundation_note := UI.label(tam_note, 10, UI.MUTED, false)
		foundation_note.name = "CandidateFoundationNote"
		foundation_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		foundation_note.custom_minimum_size.y = 24
		content.add_child(foundation_note)
	content.add_child(UI.section_heading("Thông tin", "search", UI.GOLD))
	var metrics := GridContainer.new()
	metrics.columns = 2
	metrics.add_theme_constant_override("h_separation", 8)
	metrics.add_theme_constant_override("v_separation", 7)
	var metric_rows: Array = _vm.get("metrics", candidate.get("metrics", []))
	for metric in metric_rows.slice(0, 4):
		var metric_card := UI.metric_card(str(metric.get("label", "")), str(metric.get("value", "")), str(metric.get("icon", "leaf")), UI.GOLD)
		metric_card.custom_minimum_size.x = 285
		metric_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		metrics.add_child(metric_card)
	content.add_child(metrics)
	return card

func _candidate_id() -> String:
	return str(_candidate().get("id", ""))

func _on_reject_pressed() -> void:
	var candidate := _candidate()
	if _candidate_id().is_empty() or not bool(candidate.get("can_reject", _vm.get("can_reject", false))):
		return
	if not _reject_armed:
		_reject_armed = true
		_accept_armed = false
		_rebuild()
		return
	_reject_armed = false
	reject_candidate_requested.emit(_candidate_id())

func _vis_run_first_reveal() -> void:
	var recruited: Dictionary = _vm.get("recruited_disciple", {})
	if recruited.is_empty():
		return
	var id := str(recruited.get("id", ""))
	if id.is_empty() or _vis_reveal_seen.has(id) or not bool(_vm.get("vis_reveal_once",false)):
		return
	_vis_reveal_seen[id] = true
	if VIS_QUALITY.id_from_name(str(recruited.get("quality", ""))) != "heaven_defying":
		return
	if not VIS_QUALITY.effects_enabled or VIS_QUALITY.reduced_motion:
		return
	var panel := find_child("RecruitmentReveal", true, false) as PanelContainer
	if panel == null:
		return
	# VIS-05: five quiet narrative beats on an actual accepted recruit,
	# keyed by real ID. Never repeats on redraw, never blocks player input.
	# 1 seal charging, 2 jade flash, 3 identity, 4 aurora, 5 settle.
	panel.modulate.a = 0.0
	var seal := panel.find_child("VIS05DivineSeal", true, false) as Label
	if seal != null:
		seal.modulate.a = 0.0
	var tween := panel.create_tween()
	tween.tween_property(panel, "modulate:a", 0.18, 0.12)
	tween.tween_property(panel, "modulate:a", 0.68, 0.21)
	tween.tween_property(panel, "modulate:a", 0.91, 0.23)
	tween.tween_property(panel, "modulate:a", 1.0, 0.29)
	tween.tween_interval(0.25)
	if seal != null:
		var seal_tween := seal.create_tween()
		seal_tween.tween_interval(0.32)
		seal_tween.tween_property(seal, "modulate:a", 1.0, 0.54)
