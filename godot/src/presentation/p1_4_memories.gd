extends Control

const TEST_SEED := 818181

var state: SimulationState
var scheduler: SimulationScheduler
var relationships := RelationshipSystem.new()
var memories := MemorySystem.new()
var source_id: StringName = &"bach_nguyet"
var target_id: StringName = &"tran_mac"
var tick_accumulator := 0.0

var summary_label: Label
var status_label: Label
var memory_label: Label
var behavior_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P14Factory.create_state(TEST_SEED)
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
    column.add_theme_constant_override("separation", 9)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P1.4 KÝ ỨC"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 15)
    column.add_child(status_label)

    var action_row := HBoxContainer.new()
    action_row.add_theme_constant_override("separation", 8)
    column.add_child(action_row)

    var assign_button := Button.new()
    assign_button.text = "Ghép Bạch Nguyệt + Trần Mặc"
    assign_button.pressed.connect(_assign_companion)
    action_row.add_child(assign_button)

    var clear_button := Button.new()
    clear_button.text = "Bỏ ghép"
    clear_button.pressed.connect(_clear_companion)
    action_row.add_child(clear_button)

    memory_label = Label.new()
    memory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    memory_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(memory_label)

    behavior_label = Label.new()
    behavior_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(behavior_label)

func _assign_companion() -> void:
    relationships.assign_companion(state, source_id, target_id)
    _refresh_ui()

func _clear_companion() -> void:
    relationships.clear_companion(state, source_id)
    _refresh_ui()

func _refresh_ui() -> void:
    var source: DiscipleState = state.disciples.get(source_id)
    var target: DiscipleState = state.disciples.get(target_id)
    if source == null or target == null:
        return

    var assigned := str(state.companion_assignments.get(str(source_id), ""))
    var assignment_text := "không"
    if assigned == str(target_id):
        assignment_text = "có"

    summary_label.text = "Lượt %d | Đệ tử %d/%d | Ký ức đang giữ %d | Sự kiện tạo/củng cố ký ức %d" % [
        state.tick,
        state.disciples.size(),
        state.sect.disciple_capacity,
        memories.memory_count(state),
        state.memory_event_count
    ]
    status_label.text = "Đang xem: %s | Ghép với %s: %s | Giới hạn ký ức/người: %d" % [
        source.display_name,
        target.display_name,
        assignment_text,
        MemorySystem.MAX_MEMORIES_PER_DISCIPLE
    ]

    var owner_memories: Array = state.memories.get(str(source_id), [])
    var lines: Array[String] = []
    var start_index := maxi(owner_memories.size() - 8, 0)
    for index in range(start_index, owner_memories.size()):
        var memory: MemoryState = owner_memories[index]
        var target_name := "-"
        if memory.target_id != &"" and state.disciples.has(memory.target_id):
            target_name = state.disciples[memory.target_id].display_name
        var region_name := "-"
        if memory.region_id != &"" and state.regions.has(memory.region_id):
            region_name = state.regions[memory.region_id].display_name
        lines.append("%s | người: %s | nơi: %s | mạnh %.1f | lặp %d%s" % [
            str(memory.event_id),
            target_name,
            region_name,
            memory.effective_strength(state.tick),
            memory.occurrences,
            " | do lệnh người chơi" if memory.player_linked else ""
        ])

    memory_label.text = "Ký ức gần đây của %s:\n%s" % [
        source.display_name,
        "\n".join(lines) if not lines.is_empty() else "Chưa hình thành ký ức đáng kể."
    ]

    var memory_scores: Dictionary = source.last_decision.get("memory_region_scores", {})
    behavior_label.text = (
        "Tác động lên hành vi:\n"
        + "Thanh Trúc %.1f | Bạch Thạch %.1f | Hắc Phong %.1f\n"
        + "Ký ức tốt kéo nhân vật quay lại; ký ức xấu làm né tránh. "
        + "Trải nghiệm tốt với người khác tiếp tục ảnh hưởng ngay cả sau khi bỏ ghép đồng hành."
    ) % [
        float(memory_scores.get("thanh_truc_lam", 0.0)),
        float(memory_scores.get("bach_thach_khe", 0.0)),
        float(memory_scores.get("hac_phong_coc", 0.0))
    ]
