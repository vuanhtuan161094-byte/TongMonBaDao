extends Control

const TEST_SEED := 2031199

var state: SimulationState
var recruitment := RecruitmentSystem.new()
var bloodlines := BloodlineSystem.new()
var selected_id: StringName = &""
var summary_label: Label
var detail_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P211Factory.create_state(TEST_SEED)
    _ensure_special_candidate()
    _build_ui()
    _refresh()

func _ensure_special_candidate() -> void:
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        var candidate_id := StringName(raw_id)
        if bloodlines.bloodline_id(state, candidate_id) != BloodlineSystem.BLOODLINE_NONE:
            selected_id = candidate_id
            return

    for _index in range(12):
        var fate_result := recruitment.fate_candidate(state)
        if not bool(fate_result.get("ok", false)):
            continue
        var generated_id := StringName(fate_result.get("candidate_id", ""))
        if bloodlines.bloodline_id(state, generated_id) != BloodlineSystem.BLOODLINE_NONE:
            selected_id = generated_id
            return

    candidate_ids = state.recruitment_candidates.keys()
    candidate_ids.sort()
    if not candidate_ids.is_empty():
        selected_id = StringName(candidate_ids[0])

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
    title.text = "TÔNG MÔN BÁ ĐẠO — P2.11 HUYẾT MẠCH"
    title.add_theme_font_size_override("font_size", 20)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    column.add_child(row)

    var accept_button := Button.new()
    accept_button.text = "Nhận vào tông"
    accept_button.pressed.connect(_accept)
    row.add_child(accept_button)

    var reveal_button := Button.new()
    reveal_button.text = "Mô phỏng lộ huyết mạch"
    reveal_button.pressed.connect(_reveal)
    row.add_child(reveal_button)

    var awaken_button := Button.new()
    awaken_button.text = "Thức tỉnh"
    awaken_button.pressed.connect(_awaken)
    row.add_child(awaken_button)

    var refine_button := Button.new()
    refine_button.text = "Luyện huyết"
    refine_button.pressed.connect(_refine)
    row.add_child(refine_button)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(detail_label)

func _accept() -> void:
    if state.recruitment_candidates.has(selected_id):
        state.sect.disciple_capacity += 1
        recruitment.accept_candidate(state, selected_id)
    _refresh()

func _reveal() -> void:
    if state.recruitment_candidates.has(selected_id):
        state.sect.disciple_capacity += 1
        recruitment.accept_candidate(state, selected_id)
    var disciple: DiscipleState = state.disciples.get(selected_id)
    if disciple != null:
        match bloodlines.bloodline_id(state, disciple.id):
            BloodlineSystem.BLOODLINE_TRUE_DRAGON:
                disciple.metrics["combats"] = 3
            BloodlineSystem.BLOODLINE_PHOENIX:
                disciple.metrics["defeats"] = 1
                disciple.metrics["rests"] = 1
            BloodlineSystem.BLOODLINE_WHITE_TIGER:
                disciple.metrics["wins"] = 3
            BloodlineSystem.BLOODLINE_BLACK_TORTOISE:
                disciple.metrics["retreats"] = 2
            BloodlineSystem.BLOODLINE_TAOTIE_REMNANT:
                disciple.metrics["rests"] = 3
            _:
                pass
        bloodlines.process_reveal(state, disciple)
    _refresh()

func _awaken() -> void:
    if state.disciples.has(selected_id):
        bloodlines.awaken_bloodline(state, selected_id)
    _refresh()

func _refine() -> void:
    if state.disciples.has(selected_id):
        bloodlines.refine_bloodline(state, selected_id)
    _refresh()

func _refresh() -> void:
    var display_name := "Không có nhân vật"
    if state.recruitment_candidates.has(selected_id):
        display_name = state.recruitment_candidates[selected_id].display_name
    elif state.disciples.has(selected_id):
        display_name = state.disciples[selected_id].display_name

    var profile := bloodlines.profile_for(state, selected_id)
    if profile.is_empty():
        summary_label.text = display_name
        detail_label.text = "Không có hồ sơ huyết mạch."
        return

    var lineage_id := StringName(profile.get("bloodline_id", "none"))
    var revealed := bool(profile.get("revealed", false))
    var awakened := bool(profile.get("awakened", false))
    var lineage_text := bloodlines.bloodline_name(lineage_id) if revealed else "???"
    summary_label.text = "%s | Huyết mạch: %s | Yêu Đan: %d" % [
        display_name,
        lineage_text,
        int(state.sect.technique_materials.get(BloodlineSystem.MATERIAL_ID, 0))
    ]

    var flavor := ""
    if lineage_id == BloodlineSystem.BLOODLINE_TAOTIE_REMNANT and awakened:
        flavor = "\n\nThao Thiết tàn huyết: hồi phục mạnh, nhưng khi xuất môn sẽ ăn thêm 1 phần vật tư nếu kho còn."

    detail_label.text = "Độ thuần: %d%%\nĐã phát hiện: %s\nĐã thức tỉnh: %s\nSố lần luyện huyết: %d%s" % [
        int(round(float(profile.get("purity", 0.0)) * 100.0)),
        "Có" if revealed else "Chưa",
        "Có" if awakened else "Chưa",
        int(profile.get("refinement_count", 0)),
        flavor
    ]
