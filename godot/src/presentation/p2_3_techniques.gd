extends Control

const TEST_SEED := 1323232

var state: SimulationState
var scheduler: SimulationScheduler
var initial_state_override: SimulationState
var archive_preview_overrides: Dictionary = {}
var techniques := TechniqueSystem.new()
var roots := SpiritualRootSystem.new()
var archive_warehouse := WarehouseSystem.new()
var archive_codices: Array[Dictionary] = []
var learning_techniques: Array[Dictionary] = []
var disciple_ids: Array[StringName] = []
var disciple_index := 0
var archive_codex_index := 0
var learning_technique_index := 0
var tick_accumulator := 0.0
var selected_technique_id: StringName = &"duong_khi_quyet"
var learning_preview_overrides: Dictionary = {}
var status_text := ""

var summary_label: Label
var disciple_label: Label
var technique_label: Label
var warehouse_label: Label
var status_label: Label
var archive_label: Label
var archive_manual_button: Button
var archive_restore_button: Button
var archive_research_button: Button
var archive_codex_button: Button
var learning_label: Label
var learning_next_button: Button
var learning_start_button: Button
var learning_cancel_button: Button
var learning_main_button: Button
var learning_aux_1_button: Button
var learning_aux_2_button: Button
var learning_system := V63LearningSystem.new()

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = initial_state_override if initial_state_override != null else P23Factory.create_state(TEST_SEED)
    scheduler = SimulationScheduler.new(state)
    scheduler.v63_preview_overrides = learning_preview_overrides.duplicate(true)
    archive_codices = V63SectArchiveSystem.codices()
    learning_techniques = V63LearningSystem.techniques()
    for index in range(archive_codices.size()):
        if bool(archive_codices[index].get("archivable",false)):
            archive_codex_index = index
            break
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

    var archive_title := Label.new()
    archive_title.text = "TÀNG KINH CÁC V6.3 — D2"
    archive_title.add_theme_font_size_override("font_size",18)
    column.add_child(archive_title)
    archive_label = Label.new()
    archive_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(archive_label)
    var archive_actions := HBoxContainer.new()
    archive_actions.add_theme_constant_override("separation",6)
    column.add_child(archive_actions)
    archive_codex_button = Button.new()
    archive_codex_button.text = "Chọn Bí Kíp kế"
    archive_codex_button.pressed.connect(_next_archive_codex)
    archive_actions.add_child(archive_codex_button)
    archive_manual_button = Button.new()
    archive_manual_button.text = "Lưu bản hoàn chỉnh"
    archive_manual_button.pressed.connect(_archive_action.bind("archive"))
    archive_actions.add_child(archive_manual_button)
    archive_restore_button = Button.new()
    archive_restore_button.text = "Chỉnh lý từ tàn quyển"
    archive_restore_button.pressed.connect(_archive_action.bind("restore"))
    archive_actions.add_child(archive_restore_button)
    archive_research_button = Button.new()
    archive_research_button.text = "Hiến bản trùng nghiên cứu"
    archive_research_button.pressed.connect(_archive_action.bind("research"))
    archive_actions.add_child(archive_research_button)

    var learning_title := Label.new()
    learning_title.text = "TÔNG MÔN V6.3 — D3 NGHIÊN TU CÔNG PHÁP"
    learning_title.add_theme_font_size_override("font_size", 18)
    column.add_child(learning_title)
    learning_label = Label.new()
    learning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(learning_label)
    var learning_actions := HBoxContainer.new()
    learning_actions.add_theme_constant_override("separation", 6)
    column.add_child(learning_actions)
    learning_next_button = Button.new()
    learning_next_button.text = "Chọn Công Pháp kế"
    learning_next_button.pressed.connect(_next_learning_technique)
    learning_actions.add_child(learning_next_button)
    learning_start_button = Button.new()
    learning_start_button.text = "Bắt đầu nghiên tu"
    learning_start_button.pressed.connect(_start_learning)
    learning_actions.add_child(learning_start_button)
    learning_cancel_button = Button.new()
    learning_cancel_button.text = "Hủy nghiên tu"
    learning_cancel_button.pressed.connect(_cancel_learning)
    learning_actions.add_child(learning_cancel_button)
    var loadout_actions := HBoxContainer.new()
    loadout_actions.add_theme_constant_override("separation", 6)
    column.add_child(loadout_actions)
    learning_main_button = Button.new()
    learning_main_button.text = "Đặt Chủ Tu"
    learning_main_button.pressed.connect(_equip_learning.bind("main"))
    loadout_actions.add_child(learning_main_button)
    learning_aux_1_button = Button.new()
    learning_aux_1_button.text = "Đặt Phụ Tu 1"
    learning_aux_1_button.pressed.connect(_equip_learning.bind("aux_1"))
    loadout_actions.add_child(learning_aux_1_button)
    learning_aux_2_button = Button.new()
    learning_aux_2_button.text = "Đặt Phụ Tu 2"
    learning_aux_2_button.pressed.connect(_equip_learning.bind("aux_2"))
    loadout_actions.add_child(learning_aux_2_button)

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

func _next_archive_codex() -> void:
    if archive_codices.is_empty():
        return
    archive_codex_index = (archive_codex_index+1)%archive_codices.size()
    _refresh_ui()

func _archive_action(action: String) -> void:
    if archive_codices.is_empty():
        status_text = "Tàng Kinh Các: không tải được danh mục."
        _refresh_ui()
        return
    var codex: Dictionary = archive_codices[archive_codex_index]
    var codex_id := str(codex.get("id",""))
    var request_id := "p2_3:%s:%d" % [action,state.sect.v63_archive_operation_index+1]
    match action:
        "archive":
            status_text = str(V63SectArchiveSystem.archive_manual(state,codex_id,archive_preview_overrides))
        "restore":
            status_text = str(V63SectArchiveSystem.restore_manual_from_fragments(state,codex_id,request_id,archive_preview_overrides))
        "research":
            status_text = str(V63SectArchiveSystem.donate_duplicate_manual(state,codex_id,request_id,archive_preview_overrides))
    _refresh_ui()

func _next_learning_technique() -> void:
    if learning_techniques.is_empty():
        return
    learning_technique_index = (learning_technique_index + 1) % learning_techniques.size()
    _refresh_ui()

func _start_learning() -> void:
    if disciple_ids.is_empty() or learning_techniques.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var info: Dictionary = learning_techniques[learning_technique_index]
    var request_id := "p23_d3:start:%s:%d" % [str(disciple.id), state.sect.v63_learning_job_index + 1]
    status_text = str(learning_system.start_study(
        state, disciple, StringName(info.get("id", "")), request_id, learning_preview_overrides
    ))
    _refresh_ui()

func _cancel_learning() -> void:
    if disciple_ids.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var job_id := str(disciple.v63_study_job.get("job_id", ""))
    if job_id.is_empty():
        return
    status_text = str(learning_system.cancel_study(
        state, disciple, "p23_d3:cancel:" + job_id, job_id, learning_preview_overrides
    ))
    _refresh_ui()

func _equip_learning(slot: String) -> void:
    if disciple_ids.is_empty() or learning_techniques.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var info: Dictionary = learning_techniques[learning_technique_index]
    status_text = str(learning_system.equip_slot(
        state, disciple, slot, StringName(info.get("id", "")), learning_preview_overrides
    ))
    _refresh_ui()

func _refresh_archive_ui() -> void:
    if archive_codices.is_empty():
        archive_label.text = "Tàng Kinh Các: danh mục chưa hợp lệ."
        archive_manual_button.disabled = true
        archive_restore_button.disabled = true
        archive_research_button.disabled = true
        return
    var codex: Dictionary = archive_codices[archive_codex_index]
    var codex_id := str(codex.get("id",""))
    var enabled := V63SectArchiveSystem.is_enabled(state,archive_preview_overrides)
    var archived := bool(state.sect.v63_archived_codices.get(codex_id,false))
    var manual_id := StringName(codex.get("manual_item_id",""))
    var manual_count := archive_warehouse.quantity(state,manual_id) if not manual_id.is_empty() else 0
    var fragment_id := StringName(codex.get("fragment_resource_id",""))
    var fragment_count := archive_warehouse.quantity(state,fragment_id) if not fragment_id.is_empty() else 0
    var restore_candidate := int(codex.get("restore_fragments_candidate",0))
    var available := V63SectArchiveSystem.available_disciple_count(state,codex_id,archive_preview_overrides)
    archive_label.text = "%s | %s\nArchive: %s | Quyển trong Kho: %d | Tàn quyển: %d/%d (%s) | %d đệ tử có truyền thụ" % [
        str(codex.get("name",codex_id)),codex_id,"Bật" if enabled else "ĐANG TẮT",
        manual_count,fragment_count,restore_candidate,str(codex.get("balance_status","")),available]
    archive_manual_button.disabled = not enabled or not bool(codex.get("archivable",false)) or archived or manual_count <= 0
    archive_restore_button.disabled = not enabled or not bool(codex.get("archivable",false)) or fragment_count < restore_candidate or restore_candidate <= 0
    archive_research_button.disabled = not enabled or not archived or manual_count <= 0

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
    _refresh_archive_ui()
    _refresh_learning_ui()

func _refresh_learning_ui() -> void:
    if learning_label == null or disciple_ids.is_empty() or learning_techniques.is_empty():
        if learning_start_button != null:
            learning_start_button.disabled = true
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var info: Dictionary = learning_techniques[learning_technique_index]
    var technique_id := str(info.get("id", ""))
    var source_codex_id := str(info.get("source_codex_id", ""))
    var source_archived := bool(state.sect.v63_archived_codices.get(source_codex_id, false))
    var enabled := V63LearningSystem.is_enabled(state, learning_preview_overrides)
    var start_check := learning_system.can_start_study(
        state, disciple, StringName(technique_id), learning_preview_overrides
    )
    var progress := V63LearningSystem.study_progress(state, disciple)
    var mastery: Dictionary = disciple.known_techniques.get(technique_id, {})
    var job_text := "Không có nghiên tu đang chạy."
    if bool(progress.get("active", false)):
        var job: Dictionary = progress.job
        job_text = "Đang nghiên tu: %.0f%% | còn %d tick | mã %s" % [
            float(progress.progress) * 100.0, int(progress.remaining_ticks), str(job.get("job_id", ""))
        ]
    var aux_1 := str(disciple.active_technique_aux[0]) if disciple.active_technique_aux.size() > 0 else ""
    var aux_2 := str(disciple.active_technique_aux[1]) if disciple.active_technique_aux.size() > 1 else ""
    var prerequisites: Array[String] = []
    for prerequisite in info.get("prerequisite_technique_ids", []):
        prerequisites.append(str(prerequisite))
    var cost: Dictionary = info.get("cost", {})
    learning_label.text = "%s | %s\nNguồn Bí Kíp: %s — %s | Gate %s | economy %s (candidate)\n" % [
        str(info.get("name", technique_id)), technique_id, source_codex_id,
        "Đã truyền thừa" if source_archived else "Chưa lưu Tàng Kinh Các",
        "BẬT" if enabled else "ĐANG TẮT", str(info.get("balance_status", "candidate"))
    ] + "Điều kiện: %s | Chi phí %d cống hiến + %d linh thạch | %d tick (chưa cân bằng)\n" % [
        ", ".join(prerequisites) if not prerequisites.is_empty() else "không có Công Pháp trước",
        int(cost.get("contribution", 0)), int(cost.get("spirit_stones", 0)), int(info.get("study_ticks", 0))
    ] + "Chủ Tu: %s | Phụ Tu: %s / %s | mastery %d XP / mốc %d\n%s\n" % [
        str(disciple.active_technique_main) if disciple.active_technique_main != &"" else "trống",
        aux_1 if not aux_1.is_empty() else "trống", aux_2 if not aux_2.is_empty() else "trống",
        int(float(mastery.get("mastery_xp", 0.0))), int(mastery.get("mastery_stage", 0)), job_text
    ] + "Bí Kíp chỉ mở truyền thừa; Công Pháp lưu ở sổ cá nhân riêng, không tự mở kỹ năng chiến đấu."
    learning_start_button.disabled = not bool(start_check.get("ok", false))
    learning_cancel_button.disabled = not bool(progress.get("active", false)) or not enabled
    var known := disciple.known_techniques.has(technique_id)
    var out_of_combat := disciple.active_pve_encounter_id.is_empty()
    learning_main_button.disabled = not enabled or not known or not out_of_combat
    learning_aux_1_button.disabled = not enabled or not known or not out_of_combat
    learning_aux_2_button.disabled = not enabled or not known or not out_of_combat

