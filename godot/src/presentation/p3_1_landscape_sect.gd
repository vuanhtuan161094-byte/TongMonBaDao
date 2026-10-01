extends Control

const DEMO_SEED := 31012026
const BASE_SIZE := Vector2(1280.0, 720.0)

const INK := Color(0.12, 0.11, 0.09, 1.0)
const PAPER := Color(0.91, 0.86, 0.72, 0.98)
const PAPER_LIGHT := Color(0.97, 0.94, 0.84, 0.98)
const JADE := Color(0.28, 0.48, 0.37, 1.0)
const JADE_DARK := Color(0.10, 0.22, 0.17, 0.97)
const CINNABAR := Color(0.72, 0.27, 0.15, 1.0)
const GOLD := Color(0.78, 0.61, 0.25, 1.0)

var state: SimulationState
var scheduler: SimulationScheduler
var workforce := WorkforceSystem.new()
var bloodlines := BloodlineSystem.new()
var physiques := PhysiqueSystem.new()
var cultivation := CultivationSystem.new()
var generator := DiscipleGeneratorV2.new()

var map_layer: Control
var popup_layer: Control
var resource_label: Label
var time_label: Label
var task_label: Label
var selected_id: StringName = &""

var actor_nodes: Dictionary = {}
var actor_destinations: Dictionary = {}
var actor_status_labels: Dictionary = {}

var saw_work := false
var saw_cultivation := false
var opened_disciple_profile := false

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    custom_minimum_size = BASE_SIZE
    state = P212Factory.create_state(DEMO_SEED)
    _prepare_demo_roster()
    scheduler = SimulationScheduler.new(state)
    _build_shell()
    _spawn_all_disciples()
    _refresh_all()

    var timer := Timer.new()
    timer.wait_time = 0.55
    timer.one_shot = false
    timer.autostart = true
    timer.timeout.connect(_advance_simulation)
    add_child(timer)

func _prepare_demo_roster() -> void:
    # P0 founders are retained exactly. Two V2 candidates are accepted only in this
    # presentation/demo state so the roster can also demonstrate the modern schema.
    state.sect.disciple_capacity += 2
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for index in range(mini(2, candidate_ids.size())):
        var candidate_id := StringName(candidate_ids[index])
        var result := RecruitmentSystem.new().accept_candidate(state, candidate_id)
        if not bool(result.get("ok", false)):
            continue
        if index == 0:
            workforce.assign_group(state, candidate_id, &"mining_crew")
        else:
            workforce.assign_group(state, candidate_id, &"forge_hall")

func _build_shell() -> void:
    var background := ColorRect.new()
    background.color = Color(0.67, 0.75, 0.59, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    map_layer = Control.new()
    map_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(map_layer)

    _build_map_decoration()
    _build_buildings()
    _build_top_bar()
    _build_task_rail()
    _build_bottom_bar()

    popup_layer = Control.new()
    popup_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    # The empty overlay must never steal map taps. Children (dim/panels/buttons)
    # still receive their own events when a popup exists.
    popup_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(popup_layer)

func _build_map_decoration() -> void:
    var inner := Panel.new()
    inner.position = Vector2(250, 78)
    inner.size = Vector2(1012, 558)
    inner.add_theme_stylebox_override("panel", _style(Color(0.76, 0.80, 0.63, 1.0), Color(0.24, 0.31, 0.20, 1.0), 2, 26))
    map_layer.add_child(inner)

    var river := ColorRect.new()
    river.color = Color(0.40, 0.68, 0.70, 0.70)
    river.position = Vector2(270, 398)
    river.size = Vector2(950, 52)
    river.rotation = -0.035
    map_layer.add_child(river)

    var path_h := ColorRect.new()
    path_h.color = Color(0.76, 0.68, 0.51, 0.78)
    path_h.position = Vector2(395, 316)
    path_h.size = Vector2(730, 24)
    map_layer.add_child(path_h)

    var path_v := ColorRect.new()
    path_v.color = Color(0.76, 0.68, 0.51, 0.78)
    path_v.position = Vector2(680, 190)
    path_v.size = Vector2(22, 350)
    map_layer.add_child(path_v)

func _build_buildings() -> void:
    var buildings := [
        {"id":"main_hall", "name":"Tông Môn\nĐại Điện", "pos":Vector2(565, 118), "size":Vector2(150, 92), "color":Color(0.44, 0.31, 0.18, 1.0)},
        {"id":"residence", "name":"Đệ Tử Xá", "pos":Vector2(860, 150), "size":Vector2(132, 76), "color":Color(0.48, 0.39, 0.25, 1.0)},
        {"id":"cultivation", "name":"Tu Luyện Đài", "pos":Vector2(725, 300), "size":Vector2(140, 80), "color":Color(0.32, 0.45, 0.41, 1.0)},
        {"id":"warehouse", "name":"Kho", "pos":Vector2(962, 340), "size":Vector2(112, 74), "color":Color(0.47, 0.35, 0.20, 1.0)},
        {"id":"forge", "name":"Luyện Khí\nĐường", "pos":Vector2(480, 447), "size":Vector2(130, 86), "color":Color(0.50, 0.28, 0.17, 1.0)},
        {"id":"medicine", "name":"Dược Phòng", "pos":Vector2(760, 480), "size":Vector2(126, 76), "color":Color(0.35, 0.49, 0.29, 1.0)},
        {"id":"mine", "name":"Khai Khoáng", "pos":Vector2(300, 318), "size":Vector2(116, 82), "color":Color(0.39, 0.36, 0.31, 1.0)},
        {"id":"gate", "name":"Tông Môn\nĐại Môn", "pos":Vector2(1080, 470), "size":Vector2(140, 88), "color":Color(0.36, 0.29, 0.20, 1.0)}
    ]

    for data in buildings:
        var button := Button.new()
        button.text = str(data["name"])
        var building_position: Vector2 = data["pos"]
        var building_size: Vector2 = data["size"]
        var fill: Color = data["color"]
        button.position = building_position
        button.size = building_size
        button.add_theme_font_size_override("font_size", 15)
        button.add_theme_color_override("font_color", PAPER_LIGHT)
        button.add_theme_color_override("font_hover_color", Color.WHITE)
        button.add_theme_stylebox_override("normal", _style(fill, INK, 2, 12))
        button.add_theme_stylebox_override("hover", _style(fill.lightened(0.10), GOLD, 3, 12))
        button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.10), GOLD, 3, 12))
        var destination := StringName(data["id"])
        button.pressed.connect(Callable(self, "_open_building").bind(destination))
        map_layer.add_child(button)

    var build_button := Button.new()
    build_button.text = "+\nXây dựng"
    build_button.position = Vector2(1184, 565)
    build_button.size = Vector2(78, 68)
    build_button.add_theme_font_size_override("font_size", 13)
    build_button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 24))
    build_button.add_theme_stylebox_override("hover", _style(CINNABAR.lightened(0.08), GOLD, 3, 24))
    build_button.pressed.connect(Callable(self, "_open_notice").bind("Xây dựng", "P3.1 khóa khung tương tác. Danh sách xây/nâng công trình sẽ nối ở P3.3."))
    map_layer.add_child(build_button)

func _build_top_bar() -> void:
    var top := Panel.new()
    top.position = Vector2.ZERO
    top.size = Vector2(1280, 72)
    top.add_theme_stylebox_override("panel", _style(JADE_DARK, Color(0.06, 0.10, 0.08, 1.0), 3, 0))
    add_child(top)

    var name_label := _label(top, "TÔNG MÔN BÁ ĐẠO", Vector2(22, 12), Vector2(280, 30), 22)
    name_label.add_theme_color_override("font_color", Color(0.94, 0.82, 0.47, 1.0))

    time_label = _label(top, "", Vector2(22, 42), Vector2(260, 22), 13)
    time_label.add_theme_color_override("font_color", Color(0.78, 0.83, 0.72, 1.0))

    var crest := _label(top, "TÔNG SƯ", Vector2(564, 13), Vector2(150, 42), 20)
    crest.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    crest.add_theme_color_override("font_color", PAPER_LIGHT)

    resource_label = _label(top, "", Vector2(735, 18), Vector2(525, 34), 15)
    resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    resource_label.add_theme_color_override("font_color", PAPER_LIGHT)

func _build_task_rail() -> void:
    var rail := Panel.new()
    rail.position = Vector2(16, 92)
    rail.size = Vector2(236, 235)
    rail.add_theme_stylebox_override("panel", _style(PAPER, INK, 2, 14))
    add_child(rail)

    var title := _label(rail, "Chương 1 · Khai tông lập phái", Vector2(14, 12), Vector2(208, 30), 16)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    task_label = _label(rail, "", Vector2(14, 48), Vector2(208, 170), 14)
    task_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    task_label.add_theme_color_override("font_color", INK)

func _build_bottom_bar() -> void:
    var bottom := Panel.new()
    bottom.position = Vector2(0, 642)
    bottom.size = Vector2(1280, 78)
    bottom.add_theme_stylebox_override("panel", _style(Color(0.88, 0.82, 0.66, 0.98), INK, 2, 0))
    add_child(bottom)

    var entries := [
        {"text":"Đệ Tử", "x":365, "action":"disciples"},
        {"text":"Kho", "x":485, "action":"warehouse"},
        {"text":"Công Trình", "x":605, "action":"buildings"},
        {"text":"Thế Giới", "x":735, "action":"world"},
        {"text":"Nhiệm Vụ", "x":855, "action":"tasks"}
    ]
    for entry in entries:
        var button := Button.new()
        button.text = str(entry["text"])
        button.position = Vector2(float(entry["x"]), 14)
        button.size = Vector2(108, 50)
        button.add_theme_font_size_override("font_size", 15)
        button.add_theme_color_override("font_color", INK)
        button.add_theme_stylebox_override("normal", _style(PAPER_LIGHT, Color(0.35, 0.27, 0.18, 1.0), 2, 10))
        button.add_theme_stylebox_override("hover", _style(Color(0.97, 0.87, 0.62, 1.0), GOLD, 3, 10))
        button.pressed.connect(Callable(self, "_bottom_action").bind(str(entry["action"])))
        bottom.add_child(button)

func _bottom_action(action: String) -> void:
    match action:
        "disciples":
            var ids: Array = state.disciples.keys()
            ids.sort()
            if not ids.is_empty():
                _open_disciple(StringName(ids[0]))
        "warehouse":
            _open_building(SectMapPresentation.DEST_WAREHOUSE)
        "buildings":
            _open_notice("Công trình", "Chạm trực tiếp từng công trình trên bản đồ để xem trạng thái thật. P3.3 sẽ thêm xây/nâng/phân người hàng loạt.")
        "world":
            _open_building(SectMapPresentation.DEST_GATE)
        "tasks":
            _open_notice("Nhiệm vụ", _task_text())

func _spawn_all_disciples() -> void:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var disciple: DiscipleState = state.disciples[disciple_id]
        var destination := _initial_destination(disciple)
        actor_destinations[str(disciple_id)] = str(destination)

        var actor := VBoxContainer.new()
        actor.position = SectMapPresentation.position_for_destination(destination) + _actor_offset(index) - Vector2(30, 30)
        actor.size = Vector2(86, 78)
        actor.mouse_filter = Control.MOUSE_FILTER_PASS

        var portrait := Button.new()
        portrait.text = disciple.display_name.substr(0, 1)
        portrait.custom_minimum_size = Vector2(52, 52)
        portrait.tooltip_text = disciple.display_name
        portrait.add_theme_font_size_override("font_size", 20)
        portrait.add_theme_color_override("font_color", PAPER_LIGHT)
        portrait.add_theme_stylebox_override("normal", _style(JADE, INK, 2, 26))
        portrait.add_theme_stylebox_override("hover", _style(JADE.lightened(0.10), GOLD, 3, 26))
        portrait.pressed.connect(Callable(self, "_open_disciple").bind(disciple_id))
        actor.add_child(portrait)

        var status := Label.new()
        status.text = SectMapPresentation.action_label(disciple.current_action)
        status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        status.add_theme_font_size_override("font_size", 10)
        status.add_theme_color_override("font_color", INK)
        actor.add_child(status)

        map_layer.add_child(actor)
        actor_nodes[str(disciple_id)] = actor
        actor_status_labels[str(disciple_id)] = status

func _initial_destination(disciple: DiscipleState) -> StringName:
    if disciple.work_group_id == &"mining_crew":
        return SectMapPresentation.DEST_MINE
    if disciple.work_group_id == &"forge_hall":
        return SectMapPresentation.DEST_FORGE
    return SectMapPresentation.DEST_COURTYARD

func _advance_simulation() -> void:
    scheduler.step()
    _refresh_all()

func _refresh_all() -> void:
    _observe_tasks()
    _refresh_top_bar()
    _refresh_tasks()
    _sync_actor_positions()

func _observe_tasks() -> void:
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.current_action in [&"WORK_MINING", &"WORK_FORGING"]:
            saw_work = true
        if disciple.current_action in [&"CULTIVATE", &"BREAKTHROUGH"]:
            saw_cultivation = true

func _refresh_top_bar() -> void:
    time_label.text = "Năm đầu · Nhịp vận hành %d" % state.tick
    var iron := int(state.sect.forge_materials.get("thanh_thiet", 0))
    var yao := int(state.sect.technique_materials.get("yeu_dan", 0))
    var marrow := int(state.sect.technique_materials.get("linh_tuy", 0))
    resource_label.text = "Tiền %s   ◆ Linh thạch %s   ▣ Thanh Thiết %s   ◉ Yêu Đan %s   ✦ Linh Tủy %s" % [
        _compact_number(state.sect.treasury),
        _compact_number(state.sect.spirit_stones),
        _compact_number(iron),
        _compact_number(yao),
        _compact_number(marrow)
    ]

func _refresh_tasks() -> void:
    task_label.text = _task_text()

func _task_text() -> String:
    var has_iron := int(state.sect.forge_materials.get("thanh_thiet", 0)) > 0
    return "%s Quan sát đệ tử làm việc\n\n%s Có Thanh Thiết trong kho\n\n%s Quan sát đệ tử tu luyện\n\n%s Mở hồ sơ một đệ tử" % [
        _check(saw_work),
        _check(has_iron),
        _check(saw_cultivation),
        _check(opened_disciple_profile)
    ]

func _sync_actor_positions() -> void:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        if not actor_nodes.has(str(disciple_id)):
            continue
        var disciple: DiscipleState = state.disciples[disciple_id]
        var previous := StringName(actor_destinations.get(str(disciple_id), str(SectMapPresentation.DEST_COURTYARD)))
        var destination := SectMapPresentation.destination_for_action(disciple.current_action, previous)
        actor_destinations[str(disciple_id)] = str(destination)
        var target := SectMapPresentation.position_for_destination(destination) + _actor_offset(index) - Vector2(30, 30)
        var actor: Control = actor_nodes[str(disciple_id)]
        if actor.position.distance_to(target) > 1.0:
            var tween := create_tween()
            tween.set_trans(Tween.TRANS_QUAD)
            tween.set_ease(Tween.EASE_IN_OUT)
            tween.tween_property(actor, "position", target, 0.32)
        var status: Label = actor_status_labels[str(disciple_id)]
        status.text = SectMapPresentation.action_label(disciple.current_action)

func _open_building(destination: StringName) -> void:
    _clear_popup()
    _add_dim()
    var panel := Panel.new()
    panel.position = Vector2(390, 150)
    panel.size = Vector2(520, 390)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)

    var title := _label(panel, _building_name(destination), Vector2(24, 18), Vector2(390, 34), 23)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    var detail := _label(panel, _building_detail(destination), Vector2(26, 68), Vector2(468, 245), 15)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_color_override("font_color", INK)

    var close := Button.new()
    close.text = "Đóng"
    close.position = Vector2(378, 326)
    close.size = Vector2(112, 42)
    close.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 9))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)

func _building_name(destination: StringName) -> String:
    match destination:
        SectMapPresentation.DEST_MAIN_HALL: return "Tông Môn Đại Điện"
        SectMapPresentation.DEST_RESIDENCE: return "Đệ Tử Xá"
        SectMapPresentation.DEST_CULTIVATION: return "Tu Luyện Đài"
        SectMapPresentation.DEST_WAREHOUSE: return "Kho Tông Môn"
        SectMapPresentation.DEST_FORGE: return "Luyện Khí Đường"
        SectMapPresentation.DEST_MEDICINE: return "Dược Phòng"
        SectMapPresentation.DEST_MINE: return "Khu Khai Khoáng"
        SectMapPresentation.DEST_GATE: return "Tông Môn Đại Môn"
        _: return "Sân Tông Môn"

func _building_detail(destination: StringName) -> String:
    match destination:
        SectMapPresentation.DEST_MAIN_HALL:
            return "Đệ tử: %d/%d\nChính sách lao động: %s\nNgân khố: %d\n\nĐây là trung tâm quản trị tông môn. P3.1 chỉ đọc state thật; chức năng thăng cấp đại điện sẽ mở ở vòng công trình." % [state.disciples.size(), state.sect.disciple_capacity, str(state.sect.work_policy), state.sect.treasury]
        SectMapPresentation.DEST_WAREHOUSE:
            return "Thanh Thiết: %d\nLinh Mộc: %d\nYêu Đan: %d\nLinh Tủy: %d\nLinh Thạch: %d\n\nSố liệu lấy trực tiếp từ kho/economy hiện tại." % [
                int(state.sect.forge_materials.get("thanh_thiet", 0)),
                int(state.sect.forge_materials.get("linh_moc", 0)),
                int(state.sect.technique_materials.get("yeu_dan", 0)),
                int(state.sect.technique_materials.get("linh_tuy", 0)),
                state.sect.spirit_stones
            ]
        SectMapPresentation.DEST_FORGE:
            return "Đệ tử đang luyện khí: %d\nĐiểm hỗ trợ rèn: %d\nThanh Thiết trong kho: %d\n\nĐệ tử WORK_FORGING trên simulation sẽ di chuyển tới đây." % [_count_action(&"WORK_FORGING"), state.sect.forge_support_points, int(state.sect.forge_materials.get("thanh_thiet", 0))]
        SectMapPresentation.DEST_MINE:
            return "Đệ tử đang khai khoáng: %d\nThanh Thiết trong kho: %d\n\nHoàn thành chu kỳ khai khoáng thật sẽ cộng Thanh Thiết vào economy P2.7/P2.6." % [_count_action(&"WORK_MINING"), int(state.sect.forge_materials.get("thanh_thiet", 0))]
        SectMapPresentation.DEST_CULTIVATION:
            return "Đang tu luyện/phá cảnh: %d\n\nTu vi, Linh căn, Huyết Mạch, Thể Chất và các multiplier hiện tại vẫn do simulation P2 quyết định." % [_count_actions([&"CULTIVATE", &"BREAKTHROUGH"])]
        SectMapPresentation.DEST_RESIDENCE:
            return "Đệ tử đang nghỉ: %d\nSức chứa chỗ ở: %d\n\nREST thật sẽ hồi thể lực/HP theo NeedsSystem." % [_count_action(&"REST"), state.sect.lodging_capacity]
        SectMapPresentation.DEST_MEDICINE:
            return "Đệ tử đang trị thương: %d\nDược liệu/thuốc dự trữ: %d\n\nHEAL thật tiếp tục dùng economy/NeedsSystem hiện tại." % [_count_action(&"HEAL"), state.sect.medicine_stock]
        SectMapPresentation.DEST_GATE:
            return "Đệ tử ngoài tông: %d\nĐang trong luồng săn/di chuyển/chiến đấu: %d\n\nKhi xuất môn, avatar đi về Đại Môn; combat vẫn do P2.5 xử lý." % [_count_outside(), _count_actions([&"HUNT", &"TRAVEL", &"COMBAT", &"LOOT", &"RETURN_SECT"])]
        _:
            return "Sân trung tâm — nơi avatar giữ vị trí khi chờ lệnh."

func _open_disciple(disciple_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    selected_id = disciple_id
    opened_disciple_profile = true
    _refresh_tasks()
    _clear_popup()
    _add_dim()

    var panel := Panel.new()
    panel.position = Vector2(110, 82)
    panel.size = Vector2(1060, 548)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)

    var header := _label(panel, "Đệ Tử", Vector2(20, 12), Vector2(140, 36), 24)
    header.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    var close := Button.new()
    close.text = "×"
    close.position = Vector2(1008, 12)
    close.size = Vector2(36, 34)
    close.add_theme_font_size_override("font_size", 22)
    close.add_theme_stylebox_override("normal", _style(Color(0.76, 0.70, 0.58, 1.0), INK, 1, 16))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)

    var roster_panel := Panel.new()
    roster_panel.position = Vector2(18, 54)
    roster_panel.size = Vector2(185, 430)
    roster_panel.add_theme_stylebox_override("panel", _style(Color(0.86, 0.80, 0.66, 1.0), Color(0.40, 0.31, 0.20, 1.0), 2, 10))
    panel.add_child(roster_panel)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(8, 8)
    scroll.size = Vector2(169, 414)
    roster_panel.add_child(scroll)
    var roster := VBoxContainer.new()
    roster.custom_minimum_size = Vector2(150, 0)
    roster.add_theme_constant_override("separation", 6)
    scroll.add_child(roster)

    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var id := StringName(raw_id)
        var disciple: DiscipleState = state.disciples[id]
        var entry := Button.new()
        entry.text = disciple.display_name
        entry.custom_minimum_size = Vector2(148, 44)
        entry.add_theme_font_size_override("font_size", 13)
        var selected := id == selected_id
        entry.add_theme_stylebox_override("normal", _style(Color(0.97, 0.90, 0.70, 1.0) if selected else Color(0.91, 0.86, 0.72, 1.0), GOLD if selected else Color(0.45, 0.37, 0.25, 1.0), 2, 8))
        entry.pressed.connect(Callable(self, "_open_disciple").bind(id))
        roster.add_child(entry)

    var disciple: DiscipleState = state.disciples[selected_id]
    var portrait_panel := Panel.new()
    portrait_panel.position = Vector2(226, 66)
    portrait_panel.size = Vector2(300, 350)
    portrait_panel.add_theme_stylebox_override("panel", _style(Color(0.76, 0.84, 0.72, 1.0), Color(0.31, 0.40, 0.28, 1.0), 2, 120))
    panel.add_child(portrait_panel)
    var initial := _label(portrait_panel, disciple.display_name.substr(0, 1), Vector2(70, 74), Vector2(160, 170), 90)
    initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    initial.add_theme_color_override("font_color", JADE_DARK)
    var name := _label(panel, disciple.display_name, Vector2(228, 426), Vector2(296, 34), 23)
    name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name.add_theme_color_override("font_color", INK)
    var stage := _label(panel, cultivation.stage_name(disciple), Vector2(228, 462), Vector2(296, 24), 14)
    stage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stage.add_theme_color_override("font_color", CINNABAR)

    var detail := _label(panel, _disciple_detail(disciple), Vector2(550, 62), Vector2(482, 330), 14)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_color_override("font_color", INK)

    _add_quick_order_button(panel, "Tu luyện", Vector2(552, 405), WorkforceSystem.COMMAND_CULTIVATE)
    _add_quick_order_button(panel, "Khai khoáng", Vector2(652, 405), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_MINING))
    _add_quick_order_button(panel, "Luyện khí", Vector2(770, 405), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_FORGING))
    _add_quick_order_button(panel, "Nghỉ", Vector2(872, 405), WorkforceSystem.COMMAND_REST)
    _add_quick_order_button(panel, "Về tông", Vector2(952, 405), WorkforceSystem.COMMAND_RETURN_SECT)

    var tab_names := ["Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    for index in range(tab_names.size()):
        var tab := Button.new()
        tab.text = tab_names[index]
        tab.position = Vector2(225 + index * 128, 500)
        tab.size = Vector2(118, 36)
        tab.add_theme_font_size_override("font_size", 12)
        tab.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), Color(0.45, 0.37, 0.25, 1.0), 1, 6))
        tab.pressed.connect(Callable(self, "_tab_notice").bind(tab_names[index]))
        panel.add_child(tab)

func _disciple_detail(disciple: DiscipleState) -> String:
    var quality := "—"
    if disciple.disciple_quality != &"":
        quality = generator.quality_name(disciple.disciple_quality)

    var roots := "—"
    if not disciple.spiritual_root_elements.is_empty():
        var parts: Array[String] = []
        for element in disciple.spiritual_root_elements:
            parts.append(_element_name(str(element)))
        roots = "-".join(parts) + " · %.0f%%" % (disciple.spiritual_root_purity * 100.0)

    var bloodline_text := "—"
    var bloodline_profile := bloodlines.profile_for(state, disciple.id)
    if not bloodline_profile.is_empty():
        if bool(bloodline_profile.get("revealed", false)):
            var bid := StringName(bloodline_profile.get("bloodline_id", "none"))
            bloodline_text = "%s · %.0f%%" % [bloodlines.bloodline_name(bid), float(bloodline_profile.get("purity", 0.0)) * 100.0]
            if bool(bloodline_profile.get("awakened", false)):
                bloodline_text += " · Đã thức tỉnh"
        else:
            bloodline_text = "Chưa xác định"

    var physique_text := "—"
    var physique_profile := physiques.profile_for(state, disciple.id)
    if not physique_profile.is_empty():
        physique_text = physiques.display_physique(state, disciple.id)
        physique_text += " · Tôi thể %d/%d" % [physiques.temper_level(state, disciple.id), PhysiqueSystem.MAX_TEMPER_LEVEL]

    var command_text := "Không"
    if not disciple.direct_command.is_empty():
        command_text = "%s %s" % [str(disciple.direct_command.get("kind", "")), str(disciple.direct_command.get("target", ""))]

    return "Phẩm chất: %s\nCảnh giới: %s\nHP: %.0f/%.0f    Thể lực: %.0f/100\n\nLinh căn: %s\nHuyết mạch: %s\nThể chất: %s\n\nTư Chất: %s    Căn Cốt: %s\nCơ Duyên: %s    Thông Tuệ: %s\nMị Lực: %s    Tiềm Lực: %s\n\nĐang làm: %s\nNhóm việc: %s\nLệnh Tông Chủ: %s" % [
        quality,
        cultivation.stage_name(disciple),
        disciple.hp,
        disciple.max_hp,
        disciple.stamina,
        roots,
        bloodline_text,
        physique_text,
        _score(disciple.aptitude),
        _score(disciple.constitution),
        _score(disciple.fortune),
        _score(disciple.comprehension),
        _score(disciple.charisma),
        _score(disciple.potential),
        SectMapPresentation.action_label(disciple.current_action),
        str(disciple.work_group_id) if disciple.work_group_id != &"" else "—",
        command_text
    ]

func _add_quick_order_button(parent: Control, text: String, pos: Vector2, kind: StringName, target: String = "") -> void:
    var button := Button.new()
    button.text = text
    button.position = pos
    button.size = Vector2(94 if text != "Khai khoáng" else 112, 40)
    button.add_theme_font_size_override("font_size", 12)
    button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
    button.add_theme_stylebox_override("hover", _style(CINNABAR.lightened(0.08), GOLD, 3, 8))
    button.pressed.connect(Callable(self, "_issue_order").bind(kind, target))
    parent.add_child(button)

func _issue_order(kind: StringName, target: String) -> void:
    if selected_id == &"":
        return
    workforce.issue_command(state, selected_id, kind, target, 40)
    _open_disciple(selected_id)

func _tab_notice(tab_name: String) -> void:
    _open_notice(tab_name, "P3.1 đã khóa vị trí tab và hierarchy giống UX tham chiếu. Nội dung sâu của tab này sẽ dùng các hệ simulation hiện có trong các pass kế tiếp.")

func _open_notice(title_text: String, body: String) -> void:
    _clear_popup()
    _add_dim()
    var panel := Panel.new()
    panel.position = Vector2(420, 205)
    panel.size = Vector2(440, 280)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)
    var title := _label(panel, title_text, Vector2(22, 18), Vector2(300, 34), 22)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))
    var text := _label(panel, body, Vector2(24, 68), Vector2(392, 145), 14)
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var close := Button.new()
    close.text = "Đóng"
    close.position = Vector2(302, 222)
    close.size = Vector2(112, 38)
    close.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)

func _add_dim() -> void:
    var dim := ColorRect.new()
    dim.color = Color(0.04, 0.05, 0.04, 0.50)
    dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    popup_layer.add_child(dim)

func _clear_popup() -> void:
    if popup_layer == null:
        return
    for child in popup_layer.get_children():
        child.queue_free()

func _count_action(action: StringName) -> int:
    var count := 0
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.current_action == action:
            count += 1
    return count

func _count_actions(actions: Array) -> int:
    var count := 0
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if actions.has(disciple.current_action):
            count += 1
    return count

func _count_outside() -> int:
    var count := 0
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.region_id != &"sect":
            count += 1
    return count

func _actor_offset(index: int) -> Vector2:
    var col := index % 3
    var row := int(floor(float(index) / 3.0)) % 2
    return Vector2(float(col - 1) * 28.0, float(row) * 34.0)

func _element_name(element: String) -> String:
    match element:
        "metal": return "Kim"
        "wood": return "Mộc"
        "water": return "Thủy"
        "fire": return "Hỏa"
        "earth": return "Thổ"
        _: return element

func _score(value: float) -> String:
    if value <= 0.0:
        return "—"
    return "%d" % int(round(value * 100.0))

func _check(ok: bool) -> String:
    return "✓" if ok else "□"

func _compact_number(value: int) -> String:
    if abs(value) >= 1000000:
        return "%.1fTr" % (float(value) / 1000000.0)
    if abs(value) >= 1000:
        return "%.1fK" % (float(value) / 1000.0)
    return str(value)

func _label(parent: Control, text: String, pos: Vector2, label_size: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = pos
    label.size = label_size
    label.add_theme_font_size_override("font_size", font_size)
    parent.add_child(label)
    return label

func _style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = 8.0
    style.content_margin_right = 8.0
    style.content_margin_top = 6.0
    style.content_margin_bottom = 6.0
    return style
