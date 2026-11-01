class_name DaiDienScreenV1
extends Control

# DD-01 native 1280x720 Godot panel. No HTML and no duplicate save authority.
signal closed
signal state_changed

const BG := Color("#101f2a")
const SURFACE := Color("#223741")
const GOLD := Color("#e7c88d")
const WHITE := Color("#edf3ec")
const MUTED := Color("#a9bfba")
const JADE := Color("#68cdb3")
const OFFICES := [
    SectHallSystemV1.OFFICE_MASTER,
    SectHallSystemV1.OFFICE_GUIDE,
    SectHallSystemV1.OFFICE_TEACHER
]
const TABS := ["TỔNG QUAN", "CHỨC VỤ", "NÂNG CẤP", "THĂNG BẬC"]

var game_state: SimulationState
var active_tab := 0
var selected_office := SectHallSystemV1.OFFICE_MASTER
var feedback := ""
var _content: VBoxContainer
var _tabs: HBoxContainer
var _candidate_ids: Array[StringName] = []
var _selected_index := 0

func attach_state(state: SimulationState) -> void:
    game_state = state

func _ready() -> void:
    name = "DaiDienScreenV1"
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _build()
    _refresh()

func _style(bg: Color, edge: Color = Color.TRANSPARENT) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = edge
    style.set_border_width_all(2 if edge != Color.TRANSPARENT else 0)
    style.set_corner_radius_all(10)
    return style

func _label(text_value: String, size_value: int = 14, tint: Color = WHITE) -> Label:
    var label_node := Label.new()
    label_node.text = text_value
    label_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label_node.add_theme_font_size_override("font_size", size_value)
    label_node.add_theme_color_override("font_color", tint)
    return label_node

func _button(value: String, action: Callable, primary: bool = false) -> Button:
    var control := Button.new()
    control.text = value
    control.custom_minimum_size = Vector2(0, 46)
    control.add_theme_font_size_override("font_size", 13)
    control.add_theme_color_override("font_color", BG if primary else WHITE)
    control.add_theme_stylebox_override("normal", _style(GOLD if primary else SURFACE, GOLD))
    control.add_theme_stylebox_override("hover", _style(JADE, GOLD))
    control.pressed.connect(action)
    return control

func _build() -> void:
    var shade := ColorRect.new()
    shade.name = "DaiDienBackdrop"
    shade.color = Color(0.02, 0.035, 0.045, 0.88)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(shade)

    var shell := PanelContainer.new()
    shell.name = "DaiDienDialog"
    shell.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    var screen := get_viewport_rect().size
    var width := minf(1100.0, maxf(screen.x - 24.0, 300.0))
    var height := minf(640.0, maxf(screen.y - 24.0, 240.0))
    shell.offset_left = -width * 0.5
    shell.offset_right = width * 0.5
    shell.offset_top = -height * 0.5
    shell.offset_bottom = height * 0.5
    shell.add_theme_stylebox_override("panel", _style(BG, GOLD))
    add_child(shell)

    var margin := MarginContainer.new()
    for key in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
        margin.add_theme_constant_override(key, 18)
    shell.add_child(margin)
    var vertical := VBoxContainer.new()
    vertical.add_theme_constant_override("separation", 12)
    margin.add_child(vertical)
    var heading := HBoxContainer.new()
    vertical.add_child(heading)
    var title_node := _label("ĐẠI ĐIỆN  ·  QUẢN TRỊ TÔNG MÔN", 22, GOLD)
    title_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    heading.add_child(title_node)
    heading.add_child(_button("ĐÓNG  ×", Callable(self, "_close")))

    _tabs = HBoxContainer.new()
    _tabs.add_theme_constant_override("separation", 8)
    vertical.add_child(_tabs)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    vertical.add_child(scroll)
    _content = VBoxContainer.new()
    _content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _content.add_theme_constant_override("separation", 12)
    scroll.add_child(_content)

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        _close()
        get_viewport().set_input_as_handled()

func _close() -> void:
    closed.emit()
    queue_free()

func _tab(index: int) -> void:
    active_tab = index
    feedback = ""
    _refresh()

func _clear(parent: Node) -> void:
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

func _refresh() -> void:
    if game_state == null or _content == null:
        return
    _clear(_tabs)
    for index in range(TABS.size()):
        var tab := _button(TABS[index], Callable(self, "_tab").bind(index), index == active_tab)
        tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _tabs.add_child(tab)
    _clear(_content)
    var status := SectHallSystemV1.ensure_live(game_state)
    if not bool(status.get("ok", false)):
        _content.add_child(_label("Không thể khởi tạo Đại Điện: %s" % str(status.get("reason", "")), 16))
        return
    if active_tab == 0:
        _overview()
    elif active_tab == 1:
        _offices()
    elif active_tab == 2:
        _upgrades()
    else:
        _sect_rank()
    if not feedback.is_empty():
        _content.add_child(_label(feedback, 13, JADE))

func _overview() -> void:
    var hall := SectHallSystemV1.hall(game_state)
    _content.add_child(_label("TÔNG MÔN  ·  NHÂN GIỚI", 18, GOLD))
    _content.add_child(_label("Đại Điện Lv%d/100  ·  Bậc Tông Môn: Nhân %d/9" % [
        hall.level, int(game_state.sect.hall_governance.get("sect_rank_index", 1))
    ], 16))
    _content.add_child(_label("Đệ tử: %d/%d  ·  Chỗ nghỉ: %d  ·  Linh Thạch: %d" % [
        game_state.disciples.size(), game_state.sect.disciple_capacity,
        game_state.sect.lodging_capacity, game_state.sect.spirit_stones
    ], 15))
    _content.add_child(_label("Lưu ý: hệ thống giường và trần tuyển vẫn cần hợp nhất với Đệ Tử Xá V2. Các số hiện tại được đọc trực tiếp từ save.", 12, MUTED))
    _content.add_child(_label("CHỨC VỤ ĐANG BỔ NHIỆM", 17, GOLD))
    for office_id in OFFICES:
        var id := SectHallSystemV1.holder_id(game_state, office_id)
        var display := "Chưa bổ nhiệm"
        if not id.is_empty() and game_state.disciples.has(StringName(id)):
            var disciple: DiscipleState = game_state.disciples[StringName(id)]
            display = disciple.display_name
        _content.add_child(_label("%s: %s" % [SectHallSystemV1.label(office_id), display], 14))
    _content.add_child(_button("QUẢN LÝ CHỨC VỤ", Callable(self, "_tab").bind(1), true))

func _offices() -> void:
    _content.add_child(_label("BỔ NHIỆM  ·  CHƯỞNG MÔN VÀ TRƯỞNG LÃO", 17, GOLD))
    var offices_row := HBoxContainer.new()
    offices_row.add_theme_constant_override("separation", 8)
    _content.add_child(offices_row)
    for office_id in OFFICES:
        var role := _button(SectHallSystemV1.label(office_id), Callable(self, "_select_office").bind(office_id), selected_office == office_id)
        role.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        offices_row.add_child(role)
    var id := SectHallSystemV1.holder_id(game_state, selected_office)
    var name_text := "Ghế trống"
    if not id.is_empty() and game_state.disciples.has(StringName(id)):
        var current: DiscipleState = game_state.disciples[StringName(id)]
        name_text = current.display_name
    _content.add_child(_label("Đương nhiệm: " + name_text, 17, GOLD))
    if not id.is_empty():
        var progress := SectHallSystemV1.mastery(game_state, selected_office, id)
        var level := int(progress.get("level", 1))
        _content.add_child(_label("Tinh Thông Lv%d/10 · EXP %d/%d" % [
            level, int(progress.get("xp", 0)),
            SectHallSystemV1.required_xp(level) if level < 10 else 0
        ], 13, WHITE))
    if selected_office == SectHallSystemV1.OFFICE_GUIDE:
        _content.add_child(_label("Tiếp Dẫn dùng chính vị trí Trưởng Lão ở Dẫn Tiên Đài; Mị Lực tăng chất lượng ứng viên theo bảng gốc. Không có hệ quay thứ hai.", 13, MUTED))
    elif selected_office == SectHallSystemV1.OFFICE_MASTER:
        _content.add_child(_label("Chưởng Môn: +%.1f%% Tu Vi tự nhiên của chính mình (hiệu ứng thật từ source). Phần D7 và HP mở rộng chưa bật." % [
            100.0 * SectHallSystemV1.office_bonus(game_state, selected_office) if not id.is_empty() else 8.0
        ], 13, MUTED))
    else:
        _content.add_child(_label("Truyền Công: +%.1f%% Tu Vi tu luyện tự nhiên toàn tông môn. Đan cố định không nhân bonus." % [
            100.0 * SectHallSystemV1.office_bonus(game_state, selected_office) if not id.is_empty() else 3.0
        ], 13, MUTED))
    var dropdown := OptionButton.new()
    dropdown.name = "HallCandidateSelector"
    dropdown.custom_minimum_size = Vector2(440, 46)
    dropdown.add_theme_font_size_override("font_size", 14)
    _candidate_ids.clear()
    var ids: Array = game_state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = game_state.disciples[raw_id]
        _candidate_ids.append(disciple.id)
        var suffix := " · Mị %.0f" % disciple.charisma if selected_office == SectHallSystemV1.OFFICE_GUIDE else " · Tuệ %.0f · Tâm %.0f" % [disciple.comprehension, disciple.mind_nature]
        dropdown.add_item(disciple.display_name + suffix)
    if not id.is_empty():
        var own_index := _candidate_ids.find(StringName(id))
        if own_index >= 0:
            _selected_index = own_index
    _selected_index = clampi(_selected_index, 0, maxi(0, _candidate_ids.size() - 1))
    if not _candidate_ids.is_empty():
        dropdown.select(_selected_index)
    dropdown.item_selected.connect(Callable(self, "_candidate_changed"))
    _content.add_child(_label("Chọn đệ tử để bổ nhiệm", 14, GOLD))
    _content.add_child(dropdown)
    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 9)
    _content.add_child(actions)
    var appoint := _button("BỔ NHIỆM / THAY THẾ", Callable(self, "_appoint"), true)
    appoint.disabled = _candidate_ids.is_empty()
    appoint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    actions.add_child(appoint)
    var dismiss := _button("MIỄN NHIỆM", Callable(self, "_dismiss"))
    dismiss.disabled = id.is_empty()
    actions.add_child(dismiss)
    _content.add_child(_label("Một đệ tử không thể giữ hai chức chính. Không tự hủy công việc; Tiếp Dẫn từ chối người đang bận hoặc bị thương.", 12, MUTED))

func _candidate_changed(index: int) -> void:
    _selected_index = index

func _select_office(value: String) -> void:
    selected_office = value
    _selected_index = 0
    _refresh()

func _appoint() -> void:
    if _selected_index < 0 or _selected_index >= _candidate_ids.size():
        return
    var result := SectHallSystemV1.appoint(game_state, selected_office, _candidate_ids[_selected_index])
    feedback = "Bổ nhiệm thành công, buff đã cập nhật." if bool(result.get("ok", false)) else "Chưa bổ nhiệm: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        state_changed.emit()
    _refresh()

func _dismiss() -> void:
    var result := SectHallSystemV1.dismiss(game_state, selected_office)
    feedback = "Đã miễn nhiệm, giữ lịch sử tinh thông." if bool(result.get("ok", false)) else "Chưa thể miễn nhiệm: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        state_changed.emit()
    _refresh()

func _upgrades() -> void:
    var hall := SectHallSystemV1.hall(game_state)
    var buildings := BuildingSystem.new()
    _content.add_child(_label("NÂNG CẤP ĐẠI ĐIỆN", 17, GOLD))
    _content.add_child(_label("Công trình Lv%d/100" % hall.level, 16))
    if hall.is_upgrading():
        _content.add_child(_label("Đang nâng Lv%d → Lv%d · tiến độ %.0f/%.0f" % [
            hall.level, hall.upgrade_target_level, hall.upgrade_progress,
            hall.upgrade_required_work
        ], 15, JADE))
        return
    if hall.level >= hall.max_level:
        _content.add_child(_label("Đại Điện đã đạt cấp tối đa.", 14, JADE))
        return
    var cost := buildings.upgrade_cost(hall)
    _content.add_child(_label("Lv%d → Lv%d" % [hall.level, hall.level + 1], 16))
    _content.add_child(_label("Linh Mộc %d · Thanh Thiết %d · Linh Thạch %d" % [
        int(cost.get(BuildingSystem.MATERIAL_WOOD, 0)),
        int(cost.get(BuildingSystem.MATERIAL_ORE, 0)),
        int(cost.get("spirit_stones", 0))
    ], 15))
    _content.add_child(_label("Tiến độ dự kiến %.0f tick mô phỏng · Chi phí DD-01 hiện là thử nghiệm, chưa phải cân bằng cuối." % buildings.upgrade_required_work(hall), 13, MUTED))
    _content.add_child(_label("Lv3 mở Nội Vụ · Lv5 Hộ Pháp · Lv7 Đan Đạo · Lv10 Giới Luật: đang chờ consumer và nghiệm thu; không cấp buff giả.", 12, MUTED))
    var check := buildings.can_start_upgrade(game_state, hall.id)
    var upgrade := _button("BẮT ĐẦU NÂNG CẤP", Callable(self, "_start_upgrade"), true)
    upgrade.name = "UpgradeMainHall"
    upgrade.disabled = not bool(check.get("ok", false))
    if upgrade.disabled:
        upgrade.tooltip_text = str(check.get("reason", "upgrade_unavailable"))
    _content.add_child(upgrade)
    if upgrade.disabled:
        _content.add_child(_label("Chưa đủ điều kiện: %s" % str(check.get("reason", "unknown")), 12, MUTED))

func _start_upgrade() -> void:
    var hall := SectHallSystemV1.hall(game_state)
    var result := BuildingSystem.new().start_upgrade(game_state, hall.id)
    feedback = "Đã khởi công, tài nguyên bị trừ một lượt." if bool(result.get("ok", false)) else "Không thể nâng cấp: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        state_changed.emit()
    _refresh()

func _sect_rank() -> void:
    _content.add_child(_label("THĂNG BẬC TÔNG MÔN · 27 BẬC", 17, GOLD))
    _content.add_child(_label("Hiện tại: Nhân 1/9", 16))
    _content.add_child(_label("Hệ yêu cầu Uy Danh, nhân lực, sản xuất, cảnh giới và thử thách chưa có đủ authority trong RC. Chưa cho phép thăng bậc bằng số liệu giả.", 14, MUTED))
    _content.add_child(_label("Nhân 9 ≥90 đệ tử · Tiên 9 ~200 · Thần 9 khoảng 400–500: mục tiêu thiết kế, chưa phải giới hạn chạy thật.", 13, MUTED))
