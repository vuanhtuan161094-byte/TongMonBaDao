extends Control
## Presentation-only candidate screen. All decisions and eligibility are delegated to caller callbacks.

signal candidate_page_requested(direction: int)
signal accept_candidate_requested(candidate_id: String)
signal reject_candidate_requested(candidate_id: String)
signal lead_in_requested(candidate_id: String)
signal recruit_candidate_requested(candidate_id: String)
signal closed

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const RADAR_SCRIPT = preload("res://src/presentation/uiux/sect_d7_radar_v1.gd")
var _vm: Dictionary = {}
var _reject_armed := false

func bind_view_model(view_model: Dictionary) -> void:
	_vm = view_model.duplicate(true)
	_reject_armed = false
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
	return margin

func _candidate() -> Dictionary:
	return _vm.get("candidate", {})

func _build_candidate_panel() -> Control:
	var candidate := _candidate()
	var card := UI.panel("CandidateProfile", UI.GOLD, UI.SURFACE)
	card.custom_minimum_size.x = 448
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	card.add_child(content)
	content.add_child(UI.section_heading("Ứng viên", "guide", UI.GOLD))
	var profile := HBoxContainer.new()
	profile.add_theme_constant_override("separation", 12)
	profile.add_child(_candidate_portrait(candidate))
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_child(UI.label(str(candidate.get("name", "Ẩn danh")), 21, UI.PAPER, true))
	detail.add_child(UI.label(str(candidate.get("realm", "—")), 14, UI.JADE, true))
	detail.add_child(UI.label(str(candidate.get("origin", "—")), 12, UI.MUTED, false))
	detail.add_child(UI.label(str(candidate.get("personality", "—")), 12, UI.TEXT, false))
	detail.add_child(UI.label(str(candidate.get("status", "Chờ đánh giá")), 12, UI.GOLD, false))
	profile.add_child(detail)
	content.add_child(profile)
	content.add_child(UI.section_heading("Quyết định", "check", UI.JADE))
	var decisions := HBoxContainer.new()
	decisions.add_theme_constant_override("separation", 8)
	var accept := UI.button("NHẬN", true, UI.JADE)
	accept.name = "AcceptCandidate"
	accept.disabled = not bool(_vm.get("can_accept", false))
	accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	accept.pressed.connect(func(): accept_candidate_requested.emit(_candidate_id()))
	decisions.add_child(accept)
	var reject := UI.button("TỪ CHỐI", false, UI.RED)
	reject.name = "RejectCandidate"
	reject.disabled = not bool(_vm.get("can_reject", false))
	reject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reject.pressed.connect(_on_reject_pressed)
	decisions.add_child(reject)
	content.add_child(decisions)
	var management := HBoxContainer.new()
	management.add_theme_constant_override("separation", 8)
	var lead := UI.button("TIẾP DẪN", false, UI.GOLD)
	lead.name = "LeadInCandidate"
	lead.disabled = not bool(_vm.get("can_lead_in", false))
	lead.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lead.pressed.connect(func(): lead_in_requested.emit(_candidate_id()))
	management.add_child(lead)
	var recruit := UI.button("CHIÊU MỘ", true, UI.JADE)
	recruit.name = "RecruitCandidate"
	recruit.disabled = not bool(_vm.get("can_recruit", false))
	recruit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recruit.pressed.connect(func(): recruit_candidate_requested.emit(_candidate_id()))
	management.add_child(recruit)
	content.add_child(management)
	var pager := HBoxContainer.new()
	var previous := UI.button("‹ ỨNG VIÊN TRƯỚC", false, UI.JADE)
	previous.name = "PreviousCandidate"
	previous.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	previous.pressed.connect(func(): candidate_page_requested.emit(-1))
	pager.add_child(previous)
	var next := UI.button("ỨNG VIÊN TIẾP ›", false, UI.JADE)
	next.name = "NextCandidate"
	next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next.pressed.connect(func(): candidate_page_requested.emit(1))
	pager.add_child(next)
	content.add_child(pager)
	return card

func _candidate_portrait(candidate: Dictionary) -> Control:
	var texture_value: Variant = candidate.get("portrait")
	if bool(candidate.get("source_art_approved", false)) and texture_value is Texture2D:
		return UI.portrait_slot(str(candidate.get("name", "")), texture_value, Vector2(118, 150))
	var guidance_art := UI.illustration("guidance")
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
	for metric in _vm.get("metrics", []).slice(0, 4):
		metrics.add_child(UI.metric_card(str(metric.get("label", "")), str(metric.get("value", "")), str(metric.get("icon", "leaf")), UI.GOLD))
	content.add_child(metrics)
	return card

func _candidate_id() -> String:
	return str(_candidate().get("id", ""))

func _on_reject_pressed() -> void:
	if not _reject_armed:
		_reject_armed = true
		_rebuild()
		return
	_reject_armed = false
	reject_candidate_requested.emit(_candidate_id())
