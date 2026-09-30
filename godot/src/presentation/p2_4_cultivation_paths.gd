extends Control

const TEST_SEED := 1324242

var state: SimulationState
var scheduler: SimulationScheduler
var paths := CultivationPathSystem.new()
var techniques := TechniqueSystem.new()
var disciple_ids: Array[StringName] = []
var disciple_index := 0
var tick_accumulator := 0.0

var summary_label: Label
var disciple_label: Label
var path_label: Label
var technique_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P24Factory.create_state(TEST_SEED)
    _seed_demo_techniques()
    scheduler = SimulationScheduler.new(state)
    _refresh_ids()
    _build_ui()
    _refresh_ui()

func _process(delta: float) -> void:
    tick_accumulator += delta
    if tick_accumulator >= 0.18:
        tick_accumulator = 0.0
        scheduler.step()
        _refresh_ui()

func _seed_demo_techniques() -> void:
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    if actor == null:
        return
    actor.learned_techniques = {
        "thanh_phong_kiem_quyet": {"level": 2, "xp": 0.0},
        "huyen_giap_cong": {"level": 2, "xp": 0.0},
        "duong_khi_quyet": {"level": 2, "xp": 0.0}
    }
    actor.active_technique_id = &"duong_khi_quyet"
    actor.cultivation_directive = CultivationSystem.DIRECTIVE_CULTIVATE

func _refresh_ids() -> void:
    disciple_ids.clear()
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        disciple_ids.append(StringName(raw_id))

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
    title.text = "TÔNG MÔN TYCOON — P2.4 ĐẠO LỘ"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
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

    path_label = Label.new()
    path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    path_label.add_theme_font_size_override("font_size", 16)
    column.add_child(path_label)

    var technique_row := HBoxContainer.new()
    technique_row.add_theme_constant_override("separation", 8)
    column.add_child(technique_row)
    for data in [
        ["Dùng Kiếm", &"thanh_phong_kiem_quyet"],
        ["Dùng Thể", &"huyen_giap_cong"],
        ["Dùng Pháp", &"duong_khi_quyet"]
    ]:
        var button := Button.new()
        button.text = str(data[0])
        button.pressed.connect(_set_active.bind(StringName(data[1])))
        technique_row.add_child(button)

    technique_label = Label.new()
    technique_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    technique_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(technique_label)

func _next_disciple() -> void:
    if disciple_ids.is_empty():
        return
    disciple_index = (disciple_index + 1) % disciple_ids.size()
    _refresh_ui()

func _set_active(technique_id: StringName) -> void:
    if disciple_ids.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    if not disciple.learned_techniques.has(str(technique_id)):
        disciple.learned_techniques[str(technique_id)] = {"level": 1, "xp": 0.0}
    techniques.set_active_technique(state, disciple, technique_id)
    disciple.cultivation_directive = CultivationSystem.DIRECTIVE_CULTIVATE
    _refresh_ui()

func _refresh_ui() -> void:
    if disciple_ids.is_empty():
        return
    var disciple: DiscipleState = state.disciples[disciple_ids[disciple_index]]
    var sword_xp := paths.path_xp(disciple, CultivationPathSystem.PATH_SWORD)
    var body_xp := paths.path_xp(disciple, CultivationPathSystem.PATH_BODY)
    var spell_xp := paths.path_xp(disciple, CultivationPathSystem.PATH_SPELL)
    summary_label.text = "Tick %d | Sự kiện đạo lộ %d" % [state.tick, state.sect.cultivation_path_event_count]
    disciple_label.text = "Đang xem: %s" % disciple.display_name
    path_label.text = "Đạo lộ hiện tại: %s\nKiếm %.0f | Thể %.0f | Pháp %.0f" % [paths.identity_label(disciple), sword_xp, body_xp, spell_xp]

    var active_name := "Chưa có"
    var active_path := "-"
    if disciple.active_technique_id != &"":
        active_name = techniques.technique_name(disciple.active_technique_id)
        active_path = techniques.path_name(disciple.active_technique_id)
    technique_label.text = (
        "Công pháp đang dùng: %s | Hệ %s\n\n"
        + "P2.4 không cho chọn class trực tiếp. Tu và chiến đấu bằng công pháp nào thì hệ đó tích kinh nghiệm.\n"
        + "Kiếm sâu → tăng sức chiến đấu. Thể sâu → giảm sát thương nhận. Pháp sâu → tăng hiệu suất tu luyện.\n"
        + "Độ sâu đúng hệ còn khuếch đại hiệu quả công pháp cùng hệ; đổi hệ không xóa lịch sử cũ."
    ) % [active_name, active_path]
