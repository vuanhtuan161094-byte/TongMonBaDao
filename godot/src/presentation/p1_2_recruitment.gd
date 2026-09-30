extends Control

var scheduler: SimulationScheduler
var recruitment := RecruitmentSystem.new()
var tick_accumulator := 0.0

var population_label: Label
var treasury_label: Label
var candidate_box: VBoxContainer
var message_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scheduler = SimulationScheduler.new(P12Factory.create_state(1337))
    _build_ui()
    _refresh_all()

func _process(delta: float) -> void:
    tick_accumulator += delta
    if tick_accumulator >= 0.18:
        tick_accumulator = 0.0
        scheduler.step()
        _refresh_summary()

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

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(scroll)

    var column := VBoxContainer.new()
    column.custom_minimum_size = Vector2(350, 0)
    column.add_theme_constant_override("separation", 10)
    scroll.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P1.2 TUYỂN ĐỆ TỬ"
    title.add_theme_font_size_override("font_size", 20)
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(title)

    var explanation := Label.new()
    explanation.text = "Ứng viên chỉ gia nhập khi người chơi bấm Nhận. Tính cách và sức mạnh của họ đã được hình thành trước khi gia nhập."
    explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    explanation.add_theme_font_size_override("font_size", 13)
    column.add_child(explanation)

    population_label = Label.new()
    population_label.add_theme_font_size_override("font_size", 15)
    column.add_child(population_label)

    treasury_label = Label.new()
    treasury_label.add_theme_font_size_override("font_size", 13)
    column.add_child(treasury_label)

    message_label = Label.new()
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message_label.add_theme_font_size_override("font_size", 13)
    column.add_child(message_label)

    column.add_child(HSeparator.new())

    var heading := Label.new()
    heading.text = "ỨNG VIÊN"
    heading.add_theme_font_size_override("font_size", 17)
    column.add_child(heading)

    candidate_box = VBoxContainer.new()
    candidate_box.add_theme_constant_override("separation", 10)
    column.add_child(candidate_box)

func _refresh_all() -> void:
    _refresh_summary()
    _refresh_candidates()

func _refresh_summary() -> void:
    var state := scheduler.state
    population_label.text = "Đệ tử: %d / %d   |   Ứng viên chờ: %d" % [
        state.disciples.size(),
        state.sect.disciple_capacity,
        state.recruitment_candidates.size()
    ]
    treasury_label.text = "Tông khố: %d   |   Tổng tiền hệ thống: %d   |   Nhịp: %d" % [
        state.sect.treasury,
        state.total_money(),
        state.tick
    ]

func _refresh_candidates() -> void:
    for child in candidate_box.get_children():
        candidate_box.remove_child(child)
        child.queue_free()

    var state := scheduler.state
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()

    if ids.is_empty():
        var empty := Label.new()
        empty.text = "Không còn ứng viên đang chờ."
        candidate_box.add_child(empty)
        return

    for candidate_id in ids:
        var candidate: CandidateState = state.recruitment_candidates[candidate_id]
        candidate_box.add_child(_candidate_card(candidate))

func _candidate_card(candidate: CandidateState) -> Control:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(0, 126)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 10)
    margin.add_theme_constant_override("margin_right", 10)
    margin.add_theme_constant_override("margin_top", 8)
    margin.add_theme_constant_override("margin_bottom", 8)
    panel.add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 5)
    margin.add_child(column)

    var name_label := Label.new()
    name_label.text = "%s   |   Sức mạnh %.1f" % [candidate.display_name, candidate.combat_power]
    name_label.add_theme_font_size_override("font_size", 15)
    column.add_child(name_label)

    var traits := Label.new()
    traits.text = "Tính cách: %s   |   Liều %.2f   Tiêu %.2f   Sinh tồn %.2f" % [
        str(candidate.personality_id),
        candidate.risk_bias,
        candidate.spend_bias,
        candidate.survival_bias
    ]
    traits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    traits.add_theme_font_size_override("font_size", 12)
    column.add_child(traits)

    var buttons := HBoxContainer.new()
    buttons.add_theme_constant_override("separation", 8)
    column.add_child(buttons)

    var accept := Button.new()
    accept.text = "Nhận"
    accept.disabled = not recruitment.can_accept_more(scheduler.state)
    accept.pressed.connect(_accept_candidate.bind(candidate.id))
    buttons.add_child(accept)

    var reject := Button.new()
    reject.text = "Từ chối"
    reject.pressed.connect(_reject_candidate.bind(candidate.id))
    buttons.add_child(reject)

    return panel

func _accept_candidate(candidate_id: StringName) -> void:
    var candidate: CandidateState = scheduler.state.recruitment_candidates.get(candidate_id)
    var candidate_name := candidate.display_name if candidate != null else str(candidate_id)
    var result := recruitment.accept_candidate(scheduler.state, candidate_id)
    if bool(result.get("ok", false)):
        message_label.text = "Đã nhận %s vào tông môn. Người này từ giờ tự hành động theo tính cách và mục tiêu của mình." % candidate_name
    elif str(result.get("reason", "")) == "capacity_full":
        message_label.text = "Không thể nhận thêm: tông môn đã đủ chỗ."
    else:
        message_label.text = "Không thể nhận ứng viên này."
    _refresh_all()

func _reject_candidate(candidate_id: StringName) -> void:
    var candidate: CandidateState = scheduler.state.recruitment_candidates.get(candidate_id)
    var candidate_name := candidate.display_name if candidate != null else str(candidate_id)
    var result := recruitment.reject_candidate(scheduler.state, candidate_id)
    if bool(result.get("ok", false)):
        message_label.text = "Đã từ chối %s." % candidate_name
    else:
        message_label.text = "Không thể từ chối ứng viên này."
    _refresh_all()
