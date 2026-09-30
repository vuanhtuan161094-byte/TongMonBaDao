extends Control

const TEST_SEED := 717171

var state: SimulationState
var scheduler: SimulationScheduler
var relationships := RelationshipSystem.new()
var source_id: StringName = &"tran_mac"
var target_ids: Array[StringName] = []
var target_index: int = 0
var tick_accumulator := 0.0

var summary_label: Label
var target_label: Label
var relation_label: Label
var behavior_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P13Factory.create_state(TEST_SEED)
    scheduler = SimulationScheduler.new(state)
    _refresh_targets()
    _build_ui()
    _refresh_ui()

func _process(delta: float) -> void:
    tick_accumulator += delta
    if tick_accumulator >= 0.18:
        tick_accumulator = 0.0
        scheduler.step()
        _refresh_ui()

func _refresh_targets() -> void:
    target_ids.clear()
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple_id := StringName(raw_id)
        if disciple_id != source_id:
            target_ids.append(disciple_id)
    target_index = clampi(target_index, 0, maxi(target_ids.size() - 1, 0))

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
    title.text = "TÔNG MÔN TYCOON — P1.3 QUAN HỆ"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var source := Label.new()
    source.text = "Đang xem: Trần Mặc"
    source.add_theme_font_size_override("font_size", 17)
    column.add_child(source)

    var target_row := HBoxContainer.new()
    target_row.add_theme_constant_override("separation", 8)
    column.add_child(target_row)

    target_label = Label.new()
    target_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    target_row.add_child(target_label)

    var next_button := Button.new()
    next_button.text = "Đổi người"
    next_button.pressed.connect(_next_target)
    target_row.add_child(next_button)

    relation_label = Label.new()
    relation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    relation_label.add_theme_font_size_override("font_size", 15)
    column.add_child(relation_label)

    var action_row := HBoxContainer.new()
    action_row.add_theme_constant_override("separation", 8)
    column.add_child(action_row)

    var assign_button := Button.new()
    assign_button.text = "Ghép đồng hành"
    assign_button.pressed.connect(_assign_companion)
    action_row.add_child(assign_button)

    var clear_button := Button.new()
    clear_button.text = "Bỏ ghép"
    clear_button.pressed.connect(_clear_companion)
    action_row.add_child(clear_button)

    behavior_label = Label.new()
    behavior_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    behavior_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(behavior_label)

func _next_target() -> void:
    if target_ids.is_empty():
        return
    target_index = (target_index + 1) % target_ids.size()
    _refresh_ui()

func _assign_companion() -> void:
    if target_ids.is_empty():
        return
    relationships.assign_companion(state, source_id, target_ids[target_index])
    _refresh_ui()

func _clear_companion() -> void:
    relationships.clear_companion(state, source_id)
    _refresh_ui()

func _refresh_ui() -> void:
    _refresh_targets()
    if target_ids.is_empty():
        return

    var source: DiscipleState = state.disciples.get(source_id)
    var target_id := target_ids[target_index]
    var target: DiscipleState = state.disciples.get(target_id)
    var relation := relationships.get_relation(state, source_id, target_id, false)

    var affinity := RelationshipState.NEUTRAL
    var trust := RelationshipState.NEUTRAL
    var respect := RelationshipState.NEUTRAL
    var last_event := "chưa có"
    if relation != null:
        affinity = relation.affinity
        trust = relation.trust
        respect = relation.respect
        if relation.last_event != &"":
            last_event = str(relation.last_event)

    var assigned := str(state.companion_assignments.get(str(source_id), ""))
    var companion_name := "chưa ghép"
    if assigned != "" and state.disciples.has(StringName(assigned)):
        companion_name = state.disciples[StringName(assigned)].display_name

    summary_label.text = "Tick %d | Đệ tử %d/%d | Quan hệ đang lưu %d | Sự kiện quan hệ %d" % [
        state.tick,
        state.disciples.size(),
        state.sect.disciple_capacity,
        relationships.relationship_count(state),
        state.relationship_event_count
    ]
    target_label.text = "Người đang xem quan hệ: %s" % target.display_name
    relation_label.text = "Thiện cảm %.1f | Tin tưởng %.1f | Kính trọng %.1f\nSự kiện gần nhất: %s\nĐồng hành được giao: %s" % [
        affinity,
        trust,
        respect,
        last_event,
        companion_name
    ]

    var social_scores: Dictionary = source.last_decision.get("social_region_scores", {})
    behavior_label.text = (
        "Tác động thật lên hành vi:\n"
        + "- Quan hệ tốt kéo lựa chọn về nơi người quen/đồng hành đang hoạt động.\n"
        + "- Quan hệ xấu làm giảm điểm khu vực đó.\n"
        + "- Lệnh Ghép đồng hành của người chơi tăng mạnh tác động này.\n\n"
        + "Trần Mặc hiện tại: %s | mục tiêu khu vực: %s\n"
        + "Điểm xã hội: Thanh Trúc %.1f | Bạch Thạch %.1f | Hắc Phong %.1f"
    ) % [
        str(source.current_action),
        str(source.target_region_id),
        float(social_scores.get("thanh_truc_lam", 0.0)),
        float(social_scores.get("bach_thach_khe", 0.0)),
        float(social_scores.get("hac_phong_coc", 0.0))
    ]
