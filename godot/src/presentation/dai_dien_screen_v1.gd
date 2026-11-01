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
const OFFICES := SectHallSystemV1.OFFICES
const TABS := ["TỔNG QUAN", "CHỨC VỤ", "NÂNG CẤP", "THĂNG BẬC", "CHÍNH SÁCH", "ĐỆ TỬ XÁ"]

var game_state: SimulationState
var active_tab := 0
var selected_office := SectHallSystemV1.OFFICE_MASTER
var feedback := ""
var _content: VBoxContainer
var _tabs: HBoxContainer
var _candidate_ids: Array[StringName] = []
var _selected_index := 0
var _candidate_selection_office := ""
var _source_a_portraits: Dictionary = {}
# One compact selector pair, not one node per disciple (safe at 480 roster).
var _room_disciple_ids: Array[StringName] = []
var _room_house_ids: Array[StringName] = []
var _room_selected_disciple := 0
var _room_selected_house := 0

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

func _source_a_portrait(disciple: DiscipleState) -> Control:
    var frame := PanelContainer.new()
    frame.custom_minimum_size = Vector2(90, 92)
    frame.add_theme_stylebox_override("panel", _style(SURFACE, GOLD))
    var texture: Texture2D = null
    if disciple != null:
        var path := DiscipleSourceAVisualPool.scene_path_for_disciple(disciple)
        if not path.is_empty():
            if _source_a_portraits.has(path):
                texture = _source_a_portraits[path] as Texture2D
            else:
                var packed := DiscipleSourceAVisualPool.scene_for_disciple(disciple)
                if packed != null:
                    var actor := packed.instantiate() as AnimatedSprite2D
                    if actor != null:
                        var frames := actor.sprite_frames
                        if frames != null and frames.has_animation(&"stand") and frames.get_frame_count(&"stand") > 0:
                            texture = frames.get_frame_texture(&"stand", 0)
                        actor.free()
                _source_a_portraits[path] = texture
    if texture != null:
        var portrait := TextureRect.new()
        portrait.name = "HallSourceAPortrait"
        portrait.texture = texture
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        frame.add_child(portrait)
    else:
        var placeholder := _label("PNG\nchưa có", 12, MUTED)
        placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        frame.add_child(placeholder)
    return frame

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
    if not SectHallSystemV1.installed(game_state) or SectHallSystemV1.hall(game_state) == null:
        _content.add_child(_label("Đại Điện chưa được khởi tạo trong lượt chơi này.", 16))
        return
    if active_tab == 0:
        _overview()
    elif active_tab == 1:
        _offices()
    elif active_tab == 2:
        _upgrades()
    elif active_tab == 3:
        _sect_rank()
    elif active_tab == 4:
        _policies()
    else:
        _residences()
    if not feedback.is_empty():
        _content.add_child(_label(feedback, 13, JADE))

func _overview() -> void:
    var hall := SectHallSystemV1.hall(game_state)
    var rank := SectHallSystemV1.rank_index(game_state)
    var realm_name := "Nhân Giới" if rank <= 9 else ("Tiên Giới" if rank <= 18 else "Thần Giới")
    _content.add_child(_label("TÔNG MÔN  ·  " + realm_name.to_upper(), 18, GOLD))
    _content.add_child(_label("Đại Điện Lv%d/100  ·  Bậc Tông Môn: %s" % [
        hall.level, SectHallSystemV1.rank_label(rank)
    ], 16))
    _content.add_child(_label("Đệ tử %d/%d  ·  Giường %d  ·  Trần quản trị %d  ·  Linh Thạch %d" % [
        game_state.disciples.size(), SectResidenceSystemV1.current_limit(game_state),
        SectResidenceSystemV1.total_beds(game_state), SectHallSystemV1.rank_population_limit(game_state),
        game_state.sect.spirit_stones
    ], 15))
    _content.add_child(_label("Hiện có %d Đệ Tử Xá · quyền xây tối đa %d · Uy Danh %d" % [
        SectResidenceSystemV1.all_houses(game_state).size(),
        SectResidenceSystemV1.maximum_instances(game_state),
        int(game_state.sect.hall_governance.get("prestige", 0))
    ], 14, MUTED))
    var binding := "Cần nâng Đệ Tử Xá" if SectResidenceSystemV1.total_beds(game_state) < SectHallSystemV1.rank_population_limit(game_state) else "Cần thăng bậc Tông Môn"
    if game_state.disciples.size() >= SectResidenceSystemV1.current_limit(game_state):
        _content.add_child(_label("Đã đầy: %s" % binding, 14, GOLD))
        if SectResidenceSystemV1.total_beds(game_state) < SectHallSystemV1.rank_population_limit(game_state):
            _content.add_child(_button("ĐẾN ĐỆ TỬ XÁ", Callable(self, "_tab").bind(5), true))
        else:
            _content.add_child(_button("XEM ĐIỀU KIỆN THĂNG BẬC", Callable(self, "_tab").bind(3), true))
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
    var offices_row := GridContainer.new()
    offices_row.columns = 3
    offices_row.add_theme_constant_override("h_separation", 8)
    offices_row.add_theme_constant_override("v_separation", 8)
    _content.add_child(offices_row)
    for office_id in OFFICES:
        var role := _button(SectHallSystemV1.label(office_id), Callable(self, "_select_office").bind(office_id), selected_office == office_id)
        role.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        role.custom_minimum_size.x = 305
        var hall_building := SectHallSystemV1.hall(game_state)
        role.disabled = hall_building == null or hall_building.level < int(SectHallSystemV1.OFFICE_UNLOCK.get(office_id, 101))
        if role.disabled:
            role.tooltip_text = "Mở tại Đại Điện Lv%d" % int(SectHallSystemV1.OFFICE_UNLOCK.get(office_id, 101))
        offices_row.add_child(role)
    var id := SectHallSystemV1.holder_id(game_state, selected_office)
    var name_text := "Ghế trống"
    if not id.is_empty() and game_state.disciples.has(StringName(id)):
        var current: DiscipleState = game_state.disciples[StringName(id)]
        name_text = current.display_name
    var identity := HBoxContainer.new()
    identity.add_theme_constant_override("separation", 12)
    _content.add_child(identity)
    if not id.is_empty() and game_state.disciples.has(StringName(id)):
        identity.add_child(_source_a_portrait(game_state.disciples[StringName(id)]))
    identity.add_child(_label("Đương nhiệm: " + name_text, 17, GOLD))
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
        _content.add_child(_label("Chưởng Môn: buff Tu Vi tự nhiên + Tư Chất hiệu dụng; HP/Tiềm Lực trong chiến đấu. Không sửa thuộc tính gốc." , 13, MUTED))
    elif selected_office == SectHallSystemV1.OFFICE_TEACHER:
        _content.add_child(_label("Truyền Công: +%.1f%% Tu Vi tự nhiên toàn tông; đan cộng điểm cố định không bị nhân." % [
            100.0 * SectHallSystemV1.office_bonus(game_state, selected_office) if not id.is_empty() else 3.0
        ], 13, MUTED))
    if selected_office not in [SectHallSystemV1.OFFICE_MASTER, SectHallSystemV1.OFFICE_GUIDE, SectHallSystemV1.OFFICE_TEACHER]:
        _content.add_child(_label("Buff chức vụ %.1f%% (cấp tinh thông, chỉ tác động khi có nghiệp vụ thật)." % (100.0 * SectHallSystemV1.role_effect(game_state, selected_office)), 13, MUTED))
    var dropdown := OptionButton.new()
    dropdown.name = "HallCandidateSelector"
    dropdown.custom_minimum_size = Vector2(440, 46)
    dropdown.add_theme_font_size_override("font_size", 14)
    _candidate_ids.clear()
    var ids: Array = game_state.disciples.keys()
    ids.sort_custom(func(left, right):
        var a: DiscipleState = game_state.disciples[left]
        var b: DiscipleState = game_state.disciples[right]
        var va := SectHallSystemV1.affinity_score(a, selected_office)
        var vb := SectHallSystemV1.affinity_score(b, selected_office)
        if is_equal_approx(va, vb):
            return str(left) < str(right)
        return va > vb)
    for raw_id in ids:
        var disciple: DiscipleState = game_state.disciples[raw_id]
        _candidate_ids.append(disciple.id)
        var fit := SectHallSystemV1.affinity_factor(disciple, selected_office)
        var eligibility := SectHallSystemV1.can_appoint(game_state, selected_office, disciple.id)
        var state_label := "" if bool(eligibility.get("ok", false)) else " · không hợp lệ"
        dropdown.add_item("%s · Phù hợp %.0f%% · D7 %.0f%s" % [
            disciple.display_name, fit * 100.0,
            SectHallSystemV1.affinity_score(disciple, selected_office), state_label
        ])
    if _candidate_selection_office != selected_office:
        _candidate_selection_office = selected_office
        _selected_index = 0
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
    if not _candidate_ids.is_empty():
        var applicant: DiscipleState = game_state.disciples[_candidate_ids[_selected_index]]
        var q := SectHallSystemV1.affinity_factor(applicant, selected_office)
        var record := SectHallSystemV1.mastery(game_state, selected_office, str(applicant.id))
        _content.add_child(_label("Xem trước: %s · Tinh Thông Lv%d · Hiệu suất phù hợp %.1f%%" % [
            applicant.display_name, int(record["level"]), q * 100.0
        ], 13, JADE))
        var eligible := SectHallSystemV1.can_appoint(game_state, selected_office, applicant.id)
        if not bool(eligible.get("ok", false)):
            _content.add_child(_label("Không thể bổ nhiệm: " + str(eligible.get("reason", "unknown")), 12, MUTED))
        elif selected_office == SectHallSystemV1.OFFICE_MASTER:
            _content.add_child(_label("Tư Chất/Tiềm Lực hiệu dụng +%.1f · Tu Vi tự nhiên +%.1f%% · HP chiến đấu +%.1f%%" % [
                lerpf(25.0, 70.0, float(int(record["level"]) - 1) / 9.0) * q,
                lerpf(8.0, 14.0, float(int(record["level"]) - 1) / 9.0) * q,
                lerpf(3.0, 7.0, float(int(record["level"]) - 1) / 9.0) * q
            ], 12, JADE))
    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 9)
    _content.add_child(actions)
    var appoint := _button("BỔ NHIỆM / THAY THẾ", Callable(self, "_appoint"), true)
    var hall_building := SectHallSystemV1.hall(game_state)
    appoint.disabled = _candidate_ids.is_empty() or hall_building == null or hall_building.level < int(SectHallSystemV1.OFFICE_UNLOCK.get(selected_office, 101))
    if not appoint.disabled:
        appoint.disabled = not bool(SectHallSystemV1.can_appoint(game_state, selected_office, _candidate_ids[_selected_index]).get("ok", false))
    appoint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    actions.add_child(appoint)
    var dismiss := _button("MIỄN NHIỆM", Callable(self, "_dismiss"))
    dismiss.disabled = id.is_empty()
    actions.add_child(dismiss)
    _content.add_child(_label("Một đệ tử không thể giữ hai chức chính. Không tự hủy công việc; Tiếp Dẫn từ chối người đang bận hoặc bị thương.", 12, MUTED))

func _candidate_changed(index: int) -> void:
    _selected_index = index
    _refresh()

func _select_office(value: String) -> void:
    selected_office = value
    _selected_index = 0
    _candidate_selection_office = ""
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
    _content.add_child(_label("Kho hiện có: Linh Mộc %d · Thanh Thiết %d · Linh Thạch %d" % [
        buildings._resource_available(game_state, BuildingSystem.MATERIAL_WOOD),
        buildings._resource_available(game_state, BuildingSystem.MATERIAL_ORE),
        game_state.sect.spirit_stones
    ], 13, JADE))
    _content.add_child(_label("Nguồn Mộc: Linh Lâm · Nguồn Thiết: Mỏ · Tiến độ %.0f tick · Giá đang thử nghiệm." % buildings.upgrade_required_work(hall), 13, MUTED))
    _content.add_child(_label("Mốc chức vụ: Lv3 Nội Vụ · Lv5 Hộ Pháp · Lv7 Đan Đạo · Lv10 Giới Luật. Consumer đã nối code, chưa qua Godot QA.", 12, MUTED))
    var check := buildings.can_start_upgrade(game_state, hall.id)
    var upgrade_request := "hall-upgrade:%s:%d" % [str(hall.id), hall.level + 1]
    var upgrade := _button("BẮT ĐẦU NÂNG CẤP", Callable(self, "_start_upgrade").bind(upgrade_request), true)
    upgrade.name = "UpgradeMainHall"
    upgrade.disabled = not bool(check.get("ok", false))
    if upgrade.disabled:
        upgrade.tooltip_text = str(check.get("reason", "upgrade_unavailable"))
    _content.add_child(upgrade)
    if upgrade.disabled:
        _content.add_child(_label("Chưa đủ điều kiện: %s" % str(check.get("reason", "unknown")), 12, MUTED))

func _start_upgrade(request_id: String) -> void:
    var hall := SectHallSystemV1.hall(game_state)
    var result := BuildingSystem.new().start_upgrade(game_state, hall.id, request_id)
    feedback = "Đã khởi công, tài nguyên bị trừ một lượt." if bool(result.get("ok", false)) else "Không thể nâng cấp: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        state_changed.emit()
    _refresh()

func _sect_rank() -> void:
    var current := SectHallSystemV1.rank_index(game_state)
    var check := SectHallSystemV1.promotion_requirements(game_state)
    _content.add_child(_label("TÔNG MÔN: %s  ·  ĐẠI ĐIỆN ĐỘC LẬP" % SectHallSystemV1.rank_label(current), 17, GOLD))
    if current >= 27:
        _content.add_child(_label("Tông Môn đạt Thần 9/9.", 15, JADE))
        return
    _content.add_child(_label("Mốc tiếp theo: %s" % str(check.get("next_name", "")), 16))
    var requirements := [
        ["Đại Điện", str(check.get("hall_level", 0)), str(check.get("hall_need", 0))],
        ["Đệ tử", str(check.get("roster", 0)), str(check.get("roster_need", 0))],
        ["Đệ tử đủ cảnh giới ≥%d" % int(check.get("min_realm", 1)), str(check.get("realm", 0)), str(check.get("realm_need", 0))],
        ["Mẻ sản xuất thật", str(check.get("production", 0)), str(check.get("production_need", 0))],
        ["Uy Danh", str(check.get("prestige", 0)), str(check.get("prestige_need", 0))]
    ]
    for item in requirements:
        _content.add_child(_label("%s: %s / %s" % [item[0], item[1], item[2]], 14))
    var cost: Dictionary = check.get("cost", {})
    _content.add_child(_label("Linh Mộc %d · Thanh Thiết %d · Linh Thạch %d" % [
        int(cost.get(BuildingSystem.MATERIAL_WOOD, 0)),
        int(cost.get(BuildingSystem.MATERIAL_ORE, 0)),
        int(cost.get("spirit_stones", 0))
    ], 14, GOLD))
    var button := _button("THĂNG BẬC TÔNG MÔN", Callable(self, "_promote_sect"), true)
    button.name = "PromoteSectRank"
    button.disabled = not bool(check.get("ok", false))
    _content.add_child(button)
    var blockers: Array = check.get("blockers", [])
    if not blockers.is_empty():
        _content.add_child(_label("Điều kiện chưa đạt: %s" % ", ".join(PackedStringArray(blockers)), 12, MUTED))
    _content.add_child(_label("Uy Danh và sản lượng chỉ tính từ hành động đã hoàn thành; không bắt buộc diệt Boss. Giá/mốc V2 còn cần cân bằng thời gian chơi dài hạn.", 12, MUTED))

func _promote_sect() -> void:
    var seq := SectHallSystemV1.rank_index(game_state) + 1
    var receipt := "hall-promote:%d" % seq
    var result := SectHallSystemV1.promote(game_state, receipt)
    feedback = "Đã thăng lên %s." % str(result.get("name", "")) if bool(result.get("ok", false)) else "Không đủ điều kiện thăng bậc."
    if bool(result.get("ok", false)):
        state_changed.emit()
    _refresh()

func _policies() -> void:
    _content.add_child(_label("CHÍNH SÁCH TÔNG MÔN", 17, GOLD))
    _content.add_child(_label("Điều hành thực: chính sách lao động · hậu cần · trang bị. Các nút gọi authority hiện có.", 13, MUTED))
    var modes := [
        ["CÂN BẰNG LAO ĐỘNG", WorkforceSystem.POLICY_BALANCED],
        ["ƯU TIÊN SẢN XUẤT", WorkforceSystem.POLICY_PRODUCTION],
        ["ƯU TIÊN TU LUYỆN", WorkforceSystem.POLICY_CULTIVATION]
    ]
    _content.add_child(_label("Phân công: " + str(game_state.sect.work_policy), 14))
    for item in modes:
        _content.add_child(_button(str(item[0]), Callable(self, "_set_work_policy").bind(item[1])))
    _content.add_child(_label("Hậu cần: " + str(game_state.sect.needs_priority), 14))
    for value in [NeedsSystem.PRIORITY_BALANCED, NeedsSystem.PRIORITY_MEDICINE, NeedsSystem.PRIORITY_SUPPLIES]:
        _content.add_child(_button("HẬU CẦN · " + str(value), Callable(self, "_set_needs_policy").bind(value)))
    _content.add_child(_label("Trang bị: " + str(game_state.sect.equipment_policy), 14))
    for value in [EquipmentSystem.POLICY_BALANCED, EquipmentSystem.POLICY_COMBAT, EquipmentSystem.POLICY_FRUGAL]:
        _content.add_child(_button("TRANG BỊ · " + str(value), Callable(self, "_set_equipment_policy").bind(value)))

func _set_work_policy(value: StringName) -> void:
    var ok := WorkforceSystem.new().set_work_policy(game_state, value)
    feedback = "Đã cập nhật chính sách lao động." if ok else "Chính sách bị từ chối."
    if ok:
        state_changed.emit()
    _refresh()

func _set_needs_policy(value: StringName) -> void:
    var ok := NeedsSystem.new().set_priority(game_state, value)
    feedback = "Đã cập nhật ưu tiên hậu cần." if ok else "Không đổi được ưu tiên."
    if ok:
        state_changed.emit()
    _refresh()

func _set_equipment_policy(value: StringName) -> void:
    var ok := EquipmentSystem.new().set_policy(game_state, value)
    feedback = "Đã cập nhật chính sách trang bị." if ok else "Không đổi được ưu tiên."
    if ok:
        state_changed.emit()
    _refresh()

func _residences() -> void:
    _content.add_child(_label("ĐỆ TỬ XÁ · NHÀ Ở THỰC", 17, GOLD))
    _content.add_child(_label("Đang có %d/%d nhà · Tổng %d giường · %d đệ tử" % [
        SectResidenceSystemV1.all_houses(game_state).size(),
        SectResidenceSystemV1.maximum_instances(game_state),
        SectResidenceSystemV1.total_beds(game_state), game_state.disciples.size()
    ], 15))
    _content.add_child(_label("Mỗi Đệ Tử Xá có ID, Lv1–100 và danh sách cư dân riêng. Cấp 20/50/75/100 mở bonus hồi phục khi nghỉ.", 13, MUTED))
    var assignments: Dictionary = game_state.sect.hall_governance.get("residence_assignments", {})
    # Large rosters use exactly two selectors plus one transaction button.
    # No 480-card room allocation panel and no automatic reassignment of jobs.
    _room_disciple_ids.clear()
    _room_house_ids.clear()
    var disciple_ids: Array = game_state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        _room_disciple_ids.append(StringName(str(raw_id)))
    for house in SectResidenceSystemV1.all_houses(game_state):
        if house.status != BuildingSystem.STATUS_CONSTRUCTING:
            _room_house_ids.append(house.id)
    if not _room_disciple_ids.is_empty() and not _room_house_ids.is_empty():
        _content.add_child(_label("PHÂN PHÒNG · THỦ CÔNG", 15, GOLD))
        var disciple_picker := OptionButton.new()
        disciple_picker.name = "ResidenceDiscipleSelector"
        disciple_picker.custom_minimum_size = Vector2(440, 46)
        for did in _room_disciple_ids:
            var member: DiscipleState = game_state.disciples[did]
            var current_house := SectResidenceSystemV1.house_of(game_state, did)
            disciple_picker.add_item("%s · %s" % [member.display_name, current_house if not current_house.is_empty() else "chưa có giường"])
        _room_selected_disciple = clampi(_room_selected_disciple, 0, _room_disciple_ids.size() - 1)
        disciple_picker.select(_room_selected_disciple)
        disciple_picker.item_selected.connect(Callable(self, "_select_room_disciple"))
        _content.add_child(disciple_picker)
        var house_picker := OptionButton.new()
        house_picker.name = "ResidenceHouseSelector"
        house_picker.custom_minimum_size = Vector2(440, 46)
        for hid in _room_house_ids:
            house_picker.add_item(str(hid))
        _room_selected_house = clampi(_room_selected_house, 0, _room_house_ids.size() - 1)
        house_picker.select(_room_selected_house)
        house_picker.item_selected.connect(Callable(self, "_select_room_house"))
        _content.add_child(house_picker)
        _content.add_child(_button("XÁC NHẬN PHÂN PHÒNG", Callable(self, "_assign_room")))
    for house in SectResidenceSystemV1.all_houses(game_state):
        var occupied := 0
        for hid in assignments.values():
            if str(hid) == str(house.id):
                occupied += 1
        _content.add_child(HSeparator.new())
        var actual_beds := 0 if house.status == BuildingSystem.STATUS_CONSTRUCTING else SectResidenceSystemV1.beds_for_level(house.level)
        _content.add_child(_label("%s · Lv%d/100 · Giường %d/%d" % [
            str(house.id), house.level, occupied, actual_beds
        ], 15, GOLD))
        var cost := BuildingSystem.new().upgrade_cost(house)
        if house.status == BuildingSystem.STATUS_CONSTRUCTING:
            _content.add_child(_label("ĐANG XÂY · còn %d phút mô phỏng · chưa nhận cư dân" % [
                SectResidenceSystemV1.construction_remaining_ticks(game_state, house)
            ], 14, JADE))
        elif house.is_upgrading():
            _content.add_child(_label("Đang nâng Lv%d · %.0f/%.0f tick" % [
                house.upgrade_target_level, house.upgrade_progress, house.upgrade_required_work
            ], 14, JADE))
        elif house.level < house.max_level:
            _content.add_child(_label("Lv tiếp theo +2 giường · Mộc %d · Thiết %d · Linh Thạch %d" % [
                int(cost.get(BuildingSystem.MATERIAL_WOOD, 0)),
                int(cost.get(BuildingSystem.MATERIAL_ORE, 0)),
                int(cost.get("spirit_stones", 0))
            ], 13))
            var room_request := "residence-upgrade:%s:%d" % [str(house.id), house.level + 1]
            var upgrade := _button("NÂNG " + str(house.id), Callable(self, "_upgrade_house").bind(house.id, room_request), true)
            upgrade.name = "UpgradeResidence_%s" % str(house.id)
            var can := BuildingSystem.new().can_start_upgrade(game_state, house.id)
            upgrade.disabled = not bool(can.get("ok", false))
            upgrade.tooltip_text = str(can.get("reason", "")) if upgrade.disabled else ""
            _content.add_child(upgrade)
    var plan := SectResidenceSystemV1.can_construct(game_state)
    var material: Dictionary = plan.get("cost", SectResidenceSystemV1.build_cost(game_state))
    _content.add_child(HSeparator.new())
    _content.add_child(_label("XÂY THÊM NHÀ · Mộc %d · Thiết %d · Linh Thạch %d · %d phút xây" % [
        int(material.get(BuildingSystem.MATERIAL_WOOD, 0)),
        int(material.get(BuildingSystem.MATERIAL_ORE, 0)),
        int(material.get("spirit_stones", 0)),
        SectResidenceSystemV1.construction_duration_ticks(SectResidenceSystemV1.all_houses(game_state).size() + 1)
    ], 14))
    var build := _button("XÂY THÊM ĐỆ TỬ XÁ", Callable(self, "_construct_house"), true)
    build.name = "ConstructResidence"
    build.disabled = not bool(plan.get("ok", false))
    build.tooltip_text = str(plan.get("reason", "")) if build.disabled else ""
    _content.add_child(build)
    _content.add_child(_label("Các nhà bổ sung hiện dùng danh sách cụm công trình gắn với điểm Đệ Tử Xá trên bản đồ. Kéo-thả và mở đất tùy ý chưa được kích hoạt.", 12, MUTED))

func _select_room_disciple(index: int) -> void:
    _room_selected_disciple = clampi(index, 0, maxi(0, _room_disciple_ids.size() - 1))
    if not _room_disciple_ids.is_empty():
        var current := SectResidenceSystemV1.house_of(game_state, _room_disciple_ids[_room_selected_disciple])
        var house_index := _room_house_ids.find(StringName(current))
        if house_index >= 0:
            _room_selected_house = house_index
    _refresh()

func _select_room_house(index: int) -> void:
    _room_selected_house = clampi(index, 0, maxi(0, _room_house_ids.size() - 1))

func _assign_room() -> void:
    if _room_disciple_ids.is_empty() or _room_house_ids.is_empty():
        return
    var did := _room_disciple_ids[_room_selected_disciple]
    var hid := _room_house_ids[_room_selected_house]
    var result := SectResidenceSystemV1.assign_room(game_state, did, hid)
    feedback = "Đã lưu phân phòng." if bool(result.get("ok", false)) else "Không phân phòng được: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        state_changed.emit()
    _refresh()

func _upgrade_house(house_id: StringName, request_id: String) -> void:
    var result := BuildingSystem.new().start_upgrade(game_state, house_id, request_id)
    feedback = "Đã bắt đầu nâng nhà, trừ nguyên liệu một lần." if bool(result.get("ok", false)) else "Chưa nâng được: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        state_changed.emit()
    _refresh()

func _construct_house() -> void:
    var seq := SectResidenceSystemV1.all_houses(game_state).size() + 1
    var result := SectResidenceSystemV1.construct(game_state, "residence:%d" % seq)
    if bool(result.get("ok", false)):
        feedback = "Đã khởi công %s · %d phút; giường sẽ mở khi hoàn thành." % [
            str(result.get("building_id", "")), int(result.get("construction_duration_ticks", 0))
        ]
        state_changed.emit()
    else:
        feedback = "Chưa xây được: %s" % str(result.get("reason", "unknown"))
    _refresh()
