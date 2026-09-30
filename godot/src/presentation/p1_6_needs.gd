extends Control

const TEST_SEED := 1020202

var state: SimulationState
var scheduler: SimulationScheduler
var needs := NeedsSystem.new()
var recruitment := RecruitmentSystem.new()
var organization := OrganizationSystem.new()
var tick_accumulator := 0.0

var summary_label: Label
var effect_label: Label
var detail_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P16Factory.create_state(TEST_SEED)
    scheduler = SimulationScheduler.new(state)
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
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P1.6 ĐỜI SỐNG & NHU CẦU"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary_label.add_theme_font_size_override("font_size", 16)
    column.add_child(summary_label)

    var priority_row := HBoxContainer.new()
    priority_row.add_theme_constant_override("separation", 8)
    column.add_child(priority_row)

    var medicine_button := Button.new()
    medicine_button.text = "Ưu tiên thuốc"
    medicine_button.pressed.connect(func():
        needs.set_priority(state, NeedsSystem.PRIORITY_MEDICINE)
        _refresh_ui()
    )
    priority_row.add_child(medicine_button)

    var balanced_button := Button.new()
    balanced_button.text = "Cân bằng"
    balanced_button.pressed.connect(func():
        needs.set_priority(state, NeedsSystem.PRIORITY_BALANCED)
        _refresh_ui()
    )
    priority_row.add_child(balanced_button)

    var supply_button := Button.new()
    supply_button.text = "Ưu tiên vật tư"
    supply_button.pressed.connect(func():
        needs.set_priority(state, NeedsSystem.PRIORITY_SUPPLIES)
        _refresh_ui()
    )
    priority_row.add_child(supply_button)

    var action_row := HBoxContainer.new()
    action_row.add_theme_constant_override("separation", 8)
    column.add_child(action_row)

    var expand_button := Button.new()
    expand_button.text = "Mở +1 chỗ nghỉ (8 vật tư)"
    expand_button.pressed.connect(func():
        needs.expand_lodging(state, 1)
        _refresh_ui()
    )
    action_row.add_child(expand_button)

    var recruit_button := Button.new()
    recruit_button.text = "Nhận thêm 1 đệ tử"
    recruit_button.pressed.connect(_recruit_one)
    action_row.add_child(recruit_button)

    effect_label = Label.new()
    effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    effect_label.add_theme_font_size_override("font_size", 15)
    column.add_child(effect_label)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(detail_label)

func _recruit_one() -> void:
    if state.disciples.size() >= state.sect.disciple_capacity:
        return
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        recruitment.ensure_candidate_pool(state, 1)
        ids = state.recruitment_candidates.keys()
        ids.sort()
    if ids.is_empty():
        return

    var candidate_id := StringName(ids[0])
    var result := recruitment.accept_candidate(state, candidate_id)
    if not bool(result.get("ok", false)):
        return

    var best_team: TeamState = null
    for team_value in state.teams.values():
        var team: TeamState = team_value
        if best_team == null or team.member_ids.size() < best_team.member_ids.size():
            best_team = team
    if best_team != null:
        organization.assign_member(state, candidate_id, best_team.id)
    recruitment.ensure_candidate_pool(state, RecruitmentSystem.DEFAULT_POOL_SIZE)
    _refresh_ui()

func _count_logistics() -> int:
    var count := 0
    for raw_role in state.role_assignments.values():
        if StringName(raw_role) == OrganizationSystem.ROLE_LOGISTICS:
            count += 1
    return count

func _refresh_ui() -> void:
    var rest_multiplier := needs.rest_recovery_multiplier(state)
    var medicine := state.sect.medicine_stock
    var supplies := state.sect.supply_stock
    var population := state.disciples.size()
    var lodging := state.sect.lodging_capacity

    summary_label.text = (
        "Tick %d | Đệ tử %d/%d | Chỗ nghỉ %d | Thuốc %d/%d | Vật tư %d/%d\n"
        + "Ưu tiên hậu cần: %s | Người hậu cần: %d"
    ) % [
        state.tick,
        population,
        state.sect.disciple_capacity,
        lodging,
        medicine,
        NeedsSystem.MEDICINE_CAP,
        supplies,
        NeedsSystem.SUPPLY_CAP,
        str(state.sect.needs_priority),
        _count_logistics()
    ]

    var lodging_status := "đủ chỗ" if rest_multiplier >= 0.999 else "quá tải — hồi phục chỉ còn %.0f%%" % (rest_multiplier * 100.0)
    var medicine_status := "có thể chữa trị" if medicine > 0 else "HẾT THUỐC — người bị thương phải nghỉ thường"
    var supply_status := "đủ chuẩn bị xuất hành" if supplies >= population else "thiếu vật tư — giảm xu hướng đi vùng nguy hiểm"

    effect_label.text = (
        "Tác động thật:\n"
        + "• Thuốc: %s.\n"
        + "• Vật tư: %s.\n"
        + "• Chỗ nghỉ: %s."
    ) % [medicine_status, supply_status, lodging_status]

    var stats := state.sect.needs_stats
    detail_label.text = (
        "Thống kê P1.6\n"
        + "Thuốc đã dùng: %d | Vật tư đã dùng: %d\n"
        + "Thuốc hậu cần tạo: %d | Vật tư hậu cần tạo: %d\n"
        + "Chỗ nghỉ đã mở: %d | Lượt nghỉ chịu quá tải: %d\n\n"
        + "Mở chỗ nghỉ dùng chính vật tư đang cần cho xuất hành. Đây là lựa chọn quản lý, không phải nâng cấp miễn phí."
    ) % [
        int(stats.get("medicine_used", 0)),
        int(stats.get("supplies_used", 0)),
        int(stats.get("medicine_produced", 0)),
        int(stats.get("supplies_produced", 0)),
        int(stats.get("lodging_expansions", 0)),
        int(stats.get("overcrowded_rests", 0))
    ]
