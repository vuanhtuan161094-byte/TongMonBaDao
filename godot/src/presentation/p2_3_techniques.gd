extends Control

const TEST_SEED := 1323232

var state: SimulationState
var scheduler: SimulationScheduler
var techniques := TechniqueSystem.new()
var roots := SpiritualRootSystem.new()
var disciple_ids: Array[StringName] = []
var disciple_index := 0
var tick_accumulator := 0.0
var selected_technique_id: StringName = &"duong_khi_quyet"
var status_text := ""

var summary_label: Label
var disciple_label: Label
var technique_label: Label
var warehouse_label: Label
var status_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P23Factory.create_state(TEST_SEED)
    scheduler = SimulationScheduler.new(state)
    _refresh_disciple_ids()
    _build_ui()
    _refresh_ui()

func _process(delta: float) -> void:
    tick_accumulator += delta
    if tick_accumulator >= 0.18:
        tick_accumulator = 0.0
        scheduler.step()
        _refresh_ui()

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.055, 0.07, 0.065, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P2.3 CÔNG PHÁP"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var action_row := HBoxContainer.new()
    action_row.add_theme_constant_override("separation", 6)
    column.add_child(action_row)
    for data in [
        ["Gacha 100 linh thạch", "gacha"],
        ["Chọn CP kế", "next_technique"],
        ["Lưu Tàng Kinh Các", "archive"],
        ["Bán quyển", "sell"],
        ["Ghép mảnh", "craft"]
    ]:
        var button := Button.new()
        button.text = str(data[0])
        button.pressed.connect(_action.bind(str(data[1])))
        action_row.add_child(button)

    warehouse_label = Label.new()
    warehouse_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(warehouse_label)

    var separator := HSeparator.new()
    column.add_child(separator)

    var disciple_row := HBoxContainer.new()
    column.add_child(disciple_row)
    disciple_label = Label.new()
    disciple_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    disciple_row.add_child(disciple_label)
    var next_disciple := Button.new()
    next_disciple.text = "Đổi đệ tử"
    next_disciple.pressed.connect(_next_disciple)
    disciple_row.add_child(next_disciple)
    var learn_button := Button.new()
    learn_button.text = "Học CP đang chọn"
    learn_button.pressed.connect(_action.bind("learn"))
    disciple_row.add_child(learn_button)
    var active_button := Button.new()
    active_button.text = "Dùng CP đang chọn"
    active_button.pressed.connect(_action.bind("activate"))
    disciple_row.add_child(active_button)
    var upgrade_button := Button.new()
    upgrade_button.text = "Nâng cấp CP"
    upgrade_button.pressed.connect(_action.bind("upgrade"))
    disciple_row.add_child(upgrade_button)

    technique_label = Label.new()
    technique_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    technique_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(technique_label)

    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(status_label)

func _refresh_disciple_ids() -> void:
    disciple_ids.clear()
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        disciple_ids.append(StringName(raw_id))
    if not disciple_ids.is_empty():
        disciple_index = mini(disciple_index, disciple_ids.size() - 1)

func _next_disciple() -> void:
    if disciple_ids.is_empty():
        return
    disciple_index = (disciple_index + 1) % disciple_ids.size()
    _refresh_ui()

func _action(action: String) -> void:
    if disciple_ids.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    match action:
        "gacha":
            status_text = str(techniques.gacha(state))
        "next_technique":
            var ids: Array = TechniqueSystem.TECHNIQUES.keys()
            ids.sort()
            var index := ids.find(str(selected_technique_id))
            selected_technique_id = StringName(ids[(index + 1) % ids.size()])
            status_text = "Đã chọn %s" % techniques.technique_name(selected_technique_id)
        "archive":
            status_text = str(techniques.archive_manual(state, selected_technique_id))
        "sell":
            status_text = str(techniques.sell_manual(state, selected_technique_id))
        "craft":
            status_text = str(techniques.craft_manual(state, selected_technique_id))
        "learn":
            status_text = str(techniques.learn_technique(state, disciple, selected_technique_id))
        "activate":
            status_text = "Đổi công pháp đang dùng: %s" % ("OK" if techniques.set_active_technique(state, disciple, selected_technique_id) else "Không hợp lệ")
        "upgrade":
            status_text = str(techniques.upgrade_technique(state, disciple, selected_technique_id))
    _refresh_ui()

func _refresh_ui() -> void:
    if disciple_ids.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var info := techniques.definition(selected_technique_id)
    var fragments := int(state.sect.technique_fragments.get(str(selected_technique_id), 0))
    var required := techniques.fragment_required(selected_technique_id)
    var elements: Array[String] = []
    for raw in disciple.spiritual_root_elements:
        elements.append(roots.element_name(StringName(raw)))

    summary_label.text = "Tick %d | Linh thạch tông môn: %d | Lần gacha: %d | Sự kiện CP: %d" % [state.tick, state.sect.spirit_stones, state.sect.technique_gacha_index, state.sect.technique_event_count]
    warehouse_label.text = (
        "Đang chọn: %s — %s | Hệ %s | %s | Vai trò %s\n"
        + "Quyển hoàn chỉnh: %d | Mảnh: %d/%d | Đã lưu Tàng Kinh Các: %s\n"
        + "Kho nguyên liệu: Linh Tủy %d | Huyền Thiết %d | Yêu Đan %d"
    ) % [
        techniques.technique_name(selected_technique_id), techniques.rarity_name(selected_technique_id),
        techniques.path_name(selected_technique_id), techniques.element_name(selected_technique_id), techniques.role_name(selected_technique_id),
        techniques.manual_count(state, selected_technique_id), fragments, required,
        "Có" if techniques.is_archived(state, selected_technique_id) else "Chưa",
        int(state.sect.technique_materials.get("linh_tuy", 0)), int(state.sect.technique_materials.get("huyen_thiet", 0)), int(state.sect.technique_materials.get("yeu_dan", 0))
    ]

    disciple_label.text = "Đệ tử: %s" % disciple.display_name
    var learned_lines: Array[String] = []
    var learned_ids: Array = disciple.learned_techniques.keys()
    learned_ids.sort()
    for technique_id in learned_ids:
        var mastery: Dictionary = disciple.learned_techniques[technique_id]
        learned_lines.append("• %s Lv%d | %.1f/%.1f%s" % [
            techniques.technique_name(StringName(technique_id)), int(mastery.get("level", 1)), float(mastery.get("xp", 0.0)),
            techniques.mastery_required(int(mastery.get("level", 1))), " [ĐANG DÙNG]" if str(disciple.active_technique_id) == str(technique_id) else ""
        ])
    if learned_lines.is_empty():
        learned_lines.append("• Chưa học công pháp")

    technique_label.text = (
        "Linh căn: %s — %s\nCống hiến: %d | Linh thạch cá nhân: %d\n"
        + "Chi phí học CP đang chọn: %d cống hiến + %d linh thạch\n"
        + "Đã học (%d/%d):\n%s\n\n"
        + "Farm: thắng trận có thể mang về linh thạch cá nhân, mảnh và nguyên liệu; khi về tông môn chúng tự nhập đúng kho."
    ) % [
        roots.quality_name(disciple.spiritual_root_quality), "/".join(elements), disciple.contribution_points, disciple.spirit_stones,
        int(info.get("learn_contribution", 0)), int(info.get("learn_stones", 0)),
        disciple.learned_techniques.size(), TechniqueSystem.MAX_LEARNED_TECHNIQUES, "\n".join(learned_lines)
    ]
    status_label.text = status_text
