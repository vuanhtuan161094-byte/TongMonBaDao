extends Control
## Standalone integration preview. Every visible value is explicitly marked as sample data.
## Screen callbacks only update this preview's note; no simulation command is connected.

const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const HALL = preload("res://src/presentation/uiux/dai_dien_screen_b1_v1.gd")
const RESIDENCE = preload("res://src/presentation/uiux/de_tu_xa_screen_b1_v1.gd")
const GUIDANCE = preload("res://src/presentation/uiux/dan_tien_screen_b1_v1.gd")

var _screen_host: Control
var _notice: Label
var _active_screen: Control

func _ready() -> void:
	_build()

func _build() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var base := ColorRect.new()
	base.color = UI.DEEP
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(base)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)
	var bar := HBoxContainer.new()
	bar.custom_minimum_size.y = 52
	bar.add_theme_constant_override("separation", 8)
	bar.add_theme_constant_override("margin_left", 18)
	var brand := UI.label("TÔNG MÔN", 16, UI.PAPER, true)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(brand)
	_notice = UI.label("PREVIEW • DỮ LIỆU MẪU", 12, UI.GOLD, true)
	_notice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(_notice)
	for entry in [
		{"label": "ĐẠI ĐIỆN", "screen": "hall"},
		{"label": "ĐỆ TỬ XÁ", "screen": "residence"},
		{"label": "DẪN TIÊN ĐÀI", "screen": "guidance"}
	]:
		var tab := UI.button(entry.label, false, UI.GOLD)
		tab.pressed.connect(_show_screen.bind(str(entry.screen)))
		bar.add_child(tab)
	root.add_child(bar)
	_screen_host = Control.new()
	_screen_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_screen_host.clip_contents = true
	root.add_child(_screen_host)
	_show_screen("hall")

func _show_screen(kind: String) -> void:
	if _screen_host == null:
		return
	if _active_screen != null:
		_screen_host.remove_child(_active_screen)
		_active_screen.queue_free()
	match kind:
		"residence":
			_active_screen = RESIDENCE.new()
			_active_screen.bind_view_model(_sample_residence())
			_active_screen.site_selection_requested.connect(func(_id): _note("Chọn lô — callback preview"))
			_active_screen.residence_build_requested.connect(func(_id): _note("Yêu cầu xây — callback preview"))
			_active_screen.residence_upgrade_requested.connect(func(_id): _note("Yêu cầu nâng cấp — callback preview"))
		"guidance":
			_active_screen = GUIDANCE.new()
			_active_screen.bind_view_model(_sample_guidance())
			_active_screen.candidate_page_requested.connect(func(_direction): _note("Đổi ứng viên — callback preview"))
			_active_screen.accept_candidate_requested.connect(func(_id): _note("Nhận ứng viên — callback preview"))
			_active_screen.reject_candidate_requested.connect(func(_id): _note("Từ chối ứng viên — callback preview"))
			_active_screen.lead_in_requested.connect(func(_id): _note("Tiếp dẫn — callback preview"))
			_active_screen.recruit_candidate_requested.connect(func(_id): _note("Chiêu mộ — callback preview"))
		_:
			_active_screen = HALL.new()
			_active_screen.bind_view_model(_sample_hall())
			_active_screen.office_selection_requested.connect(func(_id): _note("Chọn chức vụ — callback preview"))
			_active_screen.promotion_requested.connect(func(): _note("Thăng bậc — callback preview"))
			_active_screen.hall_upgrade_requested.connect(func(): _note("Nâng cấp — callback preview"))
	_screen_host.add_child(_active_screen)
	_active_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _note(message: String) -> void:
	_notice.text = "PREVIEW • " + message

func _sample_hall() -> Dictionary:
	var offices: Array = []
	var ids := ["master", "guide", "teacher", "steward", "guardian", "alchemist", "discipline"]
	var names := ["Chưởng Môn", "Hộ Sơn", "Truyền Công", "Chấp Sự", "Tuần Sơn", "Đan Sư", "Giới Luật"]
	for index in range(ids.size()):
		offices.append({"id": ids[index], "disciple_name": "Đệ tử %02d" % (index + 1), "office_rank": "Chấp sự • Kim Đan"})
	return {
		"building_level": 4, "rank_step": 12, "rank_progress": 0.68,
		"rank_requirement": "Đạt 12/27 • điều kiện lấy từ dữ liệu môn phái",
		"can_promote": true, "can_upgrade": true,
		"upgrade_costs": [{"name": "Linh Thạch", "amount": "1.200", "icon": "gold"}, {"name": "Mộc Linh", "amount": "36", "icon": "leaf"}],
		"offices": offices
	}

func _sample_residence() -> Dictionary:
	var beds: Array = []
	for index in range(10):
		beds.append({"id": "bed_%02d" % index, "occupied": index < 6, "disciple_short_name": "Đệ %02d" % (index + 1) if index < 6 else "Trống"})
	var sites := [
		{"id": "north", "name": "Tĩnh Tâm Viện", "status": "Đang sử dụng • cấp 3", "resident_summary": "6 đệ tử cư trú", "built": true, "can_upgrade": true},
		{"id": "east", "name": "Thanh Trúc Xá", "status": "Đất trống • có thể xây", "resident_summary": "Chưa có cư trú", "built": false, "can_build": true},
		{"id": "west", "name": "Bích Vân Các", "status": "Đang xây • còn 02 ngày", "resident_summary": "Tiến độ từ hệ thống xây dựng", "built": false},
		{"id": "south", "name": "Linh Tuyền Cư", "status": "Chưa mở", "resident_summary": "Điều kiện do hệ thống cung cấp", "built": false}
	]
	return {"building_level": 3, "room_count_label": "10 phòng", "bed_slots": beds, "sites": sites, "selected_residence_id": "north"}

func _sample_guidance() -> Dictionary:
	return {
		"candidate": {
			"id": "preview_candidate", "name": "Lạc Vân Dao", "realm": "Trúc Cơ • tầng 6",
			"origin": "Tán tu • Vân Châu", "personality": "Tâm cảnh bình hòa",
			"status": "Chưa tiếp dẫn", "tam_values": [74, 62, 88], "tu_values": [70, 83, 61, 54],
			"source_art_approved": false
		},
		"can_accept": true, "can_reject": true, "can_lead_in": true, "can_recruit": false,
		"metrics": [
			{"label": "TIỀM LỰC", "value": "74", "icon": "leaf"},
			{"label": "TUỔI", "value": "21", "icon": "rank"},
			{"label": "DUYÊN PHẬN", "value": "Khá", "icon": "guide"}
		]
	}
