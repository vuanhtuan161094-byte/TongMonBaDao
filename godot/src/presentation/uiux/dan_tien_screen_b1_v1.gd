extends Control
## Presentation-only candidate screen. All decisions and eligibility are delegated to caller callbacks.

signal candidate_page_requested(direction: int)
signal candidate_search_requested(query: String)
signal accept_candidate_requested(candidate_id: String)
signal reject_candidate_requested(candidate_id: String)
signal guide_management_requested
signal recruitment_order_requested
signal closed

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const RADAR_SCRIPT = preload("res://src/presentation/uiux/sect_d7_radar_v1.gd")
var _vm: Dictionary = {}
var _reject_armed := false
var _accept_armed := false
var _search_text := ""
var _candidate_index := 0

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
	stack.add_child(UI.label("DẪN TIÊN ĐÀI", 25, UI.PAPER, true))
	stack.add_child(UI.label("Ứng viên • Tam Căn / Tứ Tính • tiếp dẫn", 12, UI.MUTED, false))
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
	var card := UI.panel("CandidateProfile", UI.GOLD, UI.SURFACE)
	card.custom_minimum_size.x = 448
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.name = "CandidateProfileScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(scroll)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	content.add_child(UI.section_heading("Ứng viên", "guide", UI.GOLD))
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
	var profile := HBoxContainer.new()
	profile.add_theme_constant_override("separation", 12)
	profile.add_child(_candidate_portrait(candidate))
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_child(UI.label(str(candidate.get("name", "Không có ứng viên phù hợp")), 21, UI.PAPER, true))
	detail.add_child(UI.label(str(candidate.get("realm", "—")), 14, UI.JADE, true))
	detail.add_child(UI.label(str(candidate.get("origin", "—")), 12, UI.MUTED, false))
	detail.add_child(UI.label(str(candidate.get("personality", "—")), 12, UI.TEXT, false))
	detail.add_child(UI.label(str(candidate.get("status", "Chờ đánh giá")), 12, UI.GOLD, false))
	profile.add_child(detail)
	content.add_child(profile)
	content.add_child(UI.section_heading("Quyết định", "check", UI.JADE))
	var decisions := HBoxContainer.new()
	decisions.add_theme_constant_override("separation", 8)
	var accept := UI.button("XÁC NHẬN NHẬN ĐỆ TỬ" if _accept_armed else "NHẬN ĐỆ TỬ", true, UI.JADE)
	accept.name = "AcceptCandidate"
	accept.disabled = not bool(candidate.get("can_accept", _vm.get("can_accept", false))) or _candidate_id().is_empty()
	accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	accept.pressed.connect(_on_accept_pressed)
	decisions.add_child(accept)
	var reject := UI.button("XÁC NHẬN TỪ CHỐI" if _reject_armed else "TỪ CHỐI", false, UI.RED)
	reject.name = "RejectCandidate"
	reject.disabled = not bool(candidate.get("can_reject", _vm.get("can_reject", false))) or _candidate_id().is_empty()
	reject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reject.pressed.connect(_on_reject_pressed)
	decisions.add_child(reject)
	content.add_child(decisions)
	var management := VBoxContainer.new()
	management.add_theme_constant_override("separation", 6)
	var manage_guides := UI.button("QUẢN LÝ TIẾP DẪN CHÍNH / PHỤ", false, UI.GOLD)
	manage_guides.name = "ManageGuides"
	manage_guides.pressed.connect(func(): guide_management_requested.emit())
	management.add_child(manage_guides)
	var order := UI.button("CHIÊU MỘ LỆNH · CÒN %d" % int(_vm.get("recruitment_tokens", 0)), true, UI.JADE)
	order.name = "UseRecruitmentOrder"
	order.disabled = not bool(_vm.get("can_use_order", false))
	order.pressed.connect(func(): recruitment_order_requested.emit())
	management.add_child(order)
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

func _candidate_portrait(candidate: Dictionary) -> Control:
	var texture_value: Variant = candidate.get("portrait")
	if bool(candidate.get("source_art_approved", false)) and texture_value is Texture2D:
		return UI.portrait_slot(str(candidate.get("name", "")), texture_value, Vector2(118, 150))
	var guidance_art := UI.illustration("candidate")
	guidance_art.custom_minimum_size = Vector2(168, 150)
	guidance_art.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	guidance_art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return guidance_art

func _build_radar_panel() -> Control:
	var candidate := _candidate()
	var card := UI.panel("CandidateStats", UI.JADE, UI.SURFACE)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	card.add_child(content)
	content.add_child(UI.section_heading("D7 • Căn cơ", "rank", UI.JADE))
	var radar: Control
	var radar_factory: Variant = _vm.get("radar_factory")
	if radar_factory is Callable and radar_factory.is_valid():
		var created: Variant = radar_factory.call()
		if created is Control:
			radar = created
	if radar == null:
		radar = RADAR_SCRIPT.new()
	radar.name = "FoundationRadar"
	radar.custom_minimum_size = Vector2(250, 255)
	radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(radar)
	if radar.has_method("set_values"):
		radar.call("set_values", candidate.get("tam_values", []), candidate.get("tu_values", []))
	content.add_child(UI.section_heading("Thông tin", "leaf", UI.GOLD))
	var metrics := GridContainer.new()
	metrics.columns = 2
	metrics.add_theme_constant_override("h_separation", 8)
	metrics.add_theme_constant_override("v_separation", 7)
	var metric_rows: Array = _vm.get("metrics", candidate.get("metrics", []))
	for metric in metric_rows.slice(0, 4):
		metrics.add_child(UI.metric_card(str(metric.get("label", "")), str(metric.get("value", "")), str(metric.get("icon", "leaf")), UI.GOLD))
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
