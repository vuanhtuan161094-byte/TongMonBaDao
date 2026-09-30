extends Control

const TEST_SEED := 1222222

var state: SimulationState
var scheduler: SimulationScheduler
var roots := SpiritualRootSystem.new()
var cultivation := CultivationSystem.new()
var recruitment := RecruitmentSystem.new()
var disciple_ids: Array[StringName] = []
var disciple_index := 0
var tick_accumulator := 0.0
var status_text := ""

var summary_label: Label
var disciple_label: Label
var root_label: Label
var candidate_label: Label
var status_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P22Factory.create_state(TEST_SEED)
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
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P2.2 LINH CĂN"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var disciple_row := HBoxContainer.new()
    column.add_child(disciple_row)
    disciple_label = Label.new()
    disciple_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    disciple_row.add_child(disciple_label)
    var next_button := Button.new()
    next_button.text = "Đổi đệ tử"
    next_button.pressed.connect(_next_disciple)
    disciple_row.add_child(next_button)

    root_label = Label.new()
    root_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root_label.add_theme_font_size_override("font_size", 15)
    column.add_child(root_label)

    var divider := HSeparator.new()
    column.add_child(divider)

    candidate_label = Label.new()
    candidate_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    candidate_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(candidate_label)

    var recruitment_row := HBoxContainer.new()
    recruitment_row.add_theme_constant_override("separation", 8)
    column.add_child(recruitment_row)
    var accept_button := Button.new()
    accept_button.text = "Nhận ứng viên đầu"
    accept_button.pressed.connect(_accept_first_candidate)
    recruitment_row.add_child(accept_button)
    var reject_button := Button.new()
    reject_button.text = "Từ chối ứng viên đầu"
    reject_button.pressed.connect(_reject_first_candidate)
    recruitment_row.add_child(reject_button)

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

func _accept_first_candidate() -> void:
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        status_text = "Không còn ứng viên."
        _refresh_ui()
        return
    var candidate_id := StringName(ids[0])
    var result := recruitment.accept_candidate(state, candidate_id)
    status_text = "Nhận: %s" % str(result.get("reason", "unknown"))
    recruitment.ensure_candidate_pool(state, RecruitmentSystem.DEFAULT_POOL_SIZE)
    _refresh_disciple_ids()
    _refresh_ui()

func _reject_first_candidate() -> void:
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        status_text = "Không còn ứng viên."
        _refresh_ui()
        return
    var candidate_id := StringName(ids[0])
    var result := recruitment.reject_candidate(state, candidate_id)
    status_text = "Từ chối: %s" % str(result.get("reason", "unknown"))
    recruitment.ensure_candidate_pool(state, RecruitmentSystem.DEFAULT_POOL_SIZE)
    _refresh_ui()

func _refresh_ui() -> void:
    if disciple_ids.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var multiplier := roots.cultivation_multiplier(disciple.spiritual_root_quality)
    var modifier := roots.breakthrough_modifier(disciple.spiritual_root_quality)
    var base_chance := cultivation.breakthrough_success_chance(disciple)
    var rooted_chance := cultivation.breakthrough_success_chance(disciple, state)

    summary_label.text = "Tick %d | Đệ tử %d/%d | Sự kiện linh căn %d" % [state.tick, state.disciples.size(), state.sect.disciple_capacity, state.sect.spiritual_root_event_count]
    disciple_label.text = "Đang xem: %s" % disciple.display_name
    root_label.text = (
        "Linh căn: %s\n"
        + "Tu luyện: %.2fx → %.1f tu vi/lần thay vì %.1f\n"
        + "Ảnh hưởng đột phá: %s | Ví dụ trạng thái hiện tại: %.1f%% → %.1f%%\n"
        + "Cảnh giới hiện tại: %s | Sức chiến đấu gốc: %.1f"
    ) % [
        roots.quality_name(disciple.spiritual_root_quality),
        multiplier, CultivationSystem.CULTIVATE_GAIN * multiplier, CultivationSystem.CULTIVATE_GAIN,
        _signed_percent(modifier), base_chance * 100.0, rooted_chance * 100.0,
        cultivation.stage_name(disciple), disciple.combat_power
    ]

    var lines: Array[String] = []
    lines.append("Ứng viên — ông tự cân sức mạnh hiện tại với tiềm năng dài hạn:")
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        var root_name := roots.quality_name(candidate.spiritual_root_quality)
        var root_multiplier := roots.cultivation_multiplier(candidate.spiritual_root_quality)
        var root_modifier := roots.breakthrough_modifier(candidate.spiritual_root_quality)
        lines.append("• %s | Sức hiện tại %.1f | %s | Tu %.2fx | Đột phá %s" % [candidate.display_name, candidate.combat_power, root_name, root_multiplier, _signed_percent(root_modifier)])
    candidate_label.text = "\n".join(lines)
    status_label.text = status_text

func _signed_percent(value: float) -> String:
    var percent := int(round(value * 100.0))
    return ("+%d%%" % percent) if percent >= 0 else ("%d%%" % percent)
