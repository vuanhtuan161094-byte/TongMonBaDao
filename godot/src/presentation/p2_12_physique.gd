extends Control

const TEST_SEED := 2031299

var state: SimulationState
var physiques := PhysiqueSystem.new()
var selected_id: StringName = &""
var summary_label: Label
var detail_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P212Factory.create_state(TEST_SEED)
    _select_disciple()
    _build_ui()
    _refresh()

func _select_disciple() -> void:
    state.sect.disciple_capacity += 2
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    if not candidate_ids.is_empty():
        var candidate_id := StringName(candidate_ids[0])
        var result := RecruitmentSystem.new().accept_candidate(state, candidate_id)
        if bool(result.get("ok", false)):
            selected_id = candidate_id
            return
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    if not disciple_ids.is_empty():
        selected_id = StringName(disciple_ids[0])

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.045, 0.055, 0.05, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 16)
    margin.add_theme_constant_override("margin_right", 16)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN BÁ ĐẠO — P2.12 THỂ CHẤT"
    title.add_theme_font_size_override("font_size", 20)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    column.add_child(row)

    var temper_button := Button.new()
    temper_button.text = "Tôi thể (1 Yêu Đan)"
    temper_button.pressed.connect(_temper)
    row.add_child(temper_button)

    var transform_button := Button.new()
    transform_button.text = "Cải thể (2 Linh Tủy)"
    transform_button.pressed.connect(_transform)
    row.add_child(transform_button)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(detail_label)

func _temper() -> void:
    if selected_id != &"":
        physiques.temper_body(state, selected_id)
    _refresh()

func _transform() -> void:
    if selected_id != &"":
        physiques.transform_body(state, selected_id)
    _refresh()

func _refresh() -> void:
    var disciple: DiscipleState = state.disciples.get(selected_id)
    if disciple == null:
        summary_label.text = "Không có đệ tử."
        detail_label.text = ""
        return

    var profile := physiques.profile_for(state, disciple.id)
    var id := StringName(profile.get("physique_id", "ordinary_body"))
    var stats := physiques.stat_profile(state, disciple)
    var defense_pct := (1.0 - float(stats.get("incoming_damage_multiplier", 1.0))) * 100.0
    var cultivation_pct := (float(stats.get("cultivation_multiplier", 1.0)) - 1.0) * 100.0
    var breakthrough_pct := float(stats.get("breakthrough_bonus", 0.0)) * 100.0
    var recovery_pct := (float(stats.get("recovery_multiplier", 1.0)) - 1.0) * 100.0
    var sword_pct := (float(stats.get("sword_xp_multiplier", 1.0)) - 1.0) * 100.0
    var body_pct := (float(stats.get("body_xp_multiplier", 1.0)) - 1.0) * 100.0
    var spell_pct := (float(stats.get("spell_xp_multiplier", 1.0)) - 1.0) * 100.0

    summary_label.text = "%s | Thể chất: %s | Tôi thể: %d/%d" % [
        disciple.display_name,
        physiques.physique_name(id),
        int(profile.get("temper_level", 0)),
        PhysiqueSystem.MAX_TEMPER_LEVEL
    ]

    var transform_text := ""
    if id == PhysiqueSystem.PHYSIQUE_ORDINARY:
        transform_text = "\nPhàm Thể có đường cải thể đã khóa từ seed. Cần Tôi thể >= 3; mục tiêu vẫn ẩn cho tới khi cải thể."
    elif bool(profile.get("transformed", false)):
        transform_text = "\nThể chất này được cải tạo từ Phàm Thể."

    detail_label.text = "Công: +%.2f\nThủ: %.1f%% giảm sát thương\nTu luyện: %.1f%%\nĐột phá: %.2f điểm phần trăm\nHồi phục: %.1f%%\nThiên hướng XP — Kiếm %.1f%% | Thể %.1f%% | Pháp %.1f%%\nYêu Đan: %d | Linh Tủy: %d%s" % [
        float(stats.get("attack_bonus", 0.0)),
        defense_pct,
        cultivation_pct,
        breakthrough_pct,
        recovery_pct,
        sword_pct,
        body_pct,
        spell_pct,
        int(state.sect.technique_materials.get(PhysiqueSystem.TEMPER_MATERIAL_ID, 0)),
        int(state.sect.technique_materials.get(PhysiqueSystem.TRANSFORM_MATERIAL_ID, 0)),
        transform_text
    ]
