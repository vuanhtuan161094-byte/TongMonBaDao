extends Control

const TEST_SEED := 1121212

var state: SimulationState
var scheduler: SimulationScheduler
var cultivation := CultivationSystem.new()
var disciple_ids: Array[StringName] = []
var disciple_index := 0
var tick_accumulator := 0.0

var summary_label: Label
var disciple_label: Label
var cultivation_label: Label
var behavior_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P21Factory.create_state(TEST_SEED)
    scheduler = SimulationScheduler.new(state)
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        disciple_ids.append(StringName(raw_id))
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
    title.text = "TÔNG MÔN TYCOON — P2.1 TU LUYỆN"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var row := HBoxContainer.new()
    column.add_child(row)
    disciple_label = Label.new()
    disciple_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(disciple_label)
    var next_button := Button.new()
    next_button.text = "Đổi đệ tử"
    next_button.pressed.connect(_next_disciple)
    row.add_child(next_button)

    cultivation_label = Label.new()
    cultivation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    cultivation_label.add_theme_font_size_override("font_size", 15)
    column.add_child(cultivation_label)

    var directive_row := HBoxContainer.new()
    directive_row.add_theme_constant_override("separation", 8)
    column.add_child(directive_row)
    for data in [
        ["Cân bằng", CultivationSystem.DIRECTIVE_BALANCED],
        ["Ưu tiên tu luyện", CultivationSystem.DIRECTIVE_CULTIVATE],
        ["Ưu tiên thực chiến", CultivationSystem.DIRECTIVE_FIELD]
    ]:
        var button := Button.new()
        button.text = str(data[0])
        button.pressed.connect(_set_directive.bind(StringName(data[1])))
        directive_row.add_child(button)

    behavior_label = Label.new()
    behavior_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    behavior_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(behavior_label)

func _next_disciple() -> void:
    if disciple_ids.is_empty():
        return
    disciple_index = (disciple_index + 1) % disciple_ids.size()
    _refresh_ui()

func _set_directive(directive: StringName) -> void:
    if disciple_ids.is_empty():
        return
    cultivation.set_directive(state, disciple_ids[disciple_index], directive)
    _refresh_ui()

func _refresh_ui() -> void:
    if disciple_ids.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var required := cultivation.required_progress(disciple)
    var effective_power := cultivation.effective_combat_power(state, disciple)

    summary_label.text = "Tick %d | Đệ tử %d | Sự kiện đột phá/ưu tiên %d" % [state.tick, state.disciples.size(), state.sect.cultivation_event_count]
    disciple_label.text = "Đang xem: %s" % disciple.display_name
    cultivation_label.text = (
        "Cảnh giới: %s\nTu vi: %.0f / %.0f\nNăng lực gốc: %.1f | Thưởng cảnh giới: +%.1f | Sức chiến đấu thực: %.1f\nHP: %.1f / %.1f | Thưởng HP cảnh giới: +%.1f\nƯu tiên: %s | Đột phá gần nhất: %s"
    ) % [
        cultivation.stage_name(disciple), disciple.cultivation_progress, required,
        disciple.combat_power, disciple.cultivation_combat_bonus, effective_power,
        disciple.hp, disciple.max_hp, disciple.cultivation_hp_bonus,
        str(disciple.cultivation_directive), str(disciple.last_breakthrough_outcome)
    ]

    var scores: Dictionary = disciple.last_decision.get("scores", {})
    behavior_label.text = (
        "Tác động thật:\n"
        + "- TU LUYỆN tăng tu vi nhưng tốn thể lực.\n"
        + "- Thắng chiến đấu tăng một ít tu vi.\n"
        + "- Đột phá thành công tăng HP + sức chiến đấu; thất bại mất tu vi/HP/thể lực và phải chờ.\n"
        + "- Sức mạnh cảnh giới đi thẳng vào chọn vùng và chiến đấu.\n\n"
        + "Hành động hiện tại: %s | Tu luyện %.1f | Đi săn %.1f | Đột phá %.1f"
    ) % [
        str(disciple.current_action),
        float(scores.get("CULTIVATE", 0.0)),
        float(scores.get("HUNT", 0.0)),
        float(scores.get("BREAKTHROUGH", 0.0))
    ]
