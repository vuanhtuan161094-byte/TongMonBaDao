extends Control

const TEST_SEED := 2129292

var state: SimulationState
var recruitment := RecruitmentSystem.new()
var trait_system := TraitSystem.new()
var generator := DiscipleGeneratorV2.new()
var selected_id: StringName = &""
var summary_label: Label
var detail_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P29Factory.create_state(TEST_SEED)
    _select_first_candidate()
    _build_ui()
    _refresh()

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.045, 0.06, 0.055, 1.0)
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
    title.text = "TÔNG MÔN BÁ ĐẠO — P2.9 ĐẶC CHẤT ĐỆ TỬ"
    title.add_theme_font_size_override("font_size", 20)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    column.add_child(row)

    var ordinary_button := Button.new()
    ordinary_button.text = "Tuyển thường"
    ordinary_button.pressed.connect(_ordinary)
    row.add_child(ordinary_button)

    var gacha_button := Button.new()
    gacha_button.text = "Chiêu Hiền"
    gacha_button.pressed.connect(_gacha)
    row.add_child(gacha_button)

    var fate_button := Button.new()
    fate_button.text = "Nhân Duyên"
    fate_button.pressed.connect(_fate)
    row.add_child(fate_button)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(detail_label)

func _ordinary() -> void:
    var candidate := recruitment.generate_candidate(state, DiscipleGeneratorV2.SOURCE_ORDINARY)
    if candidate != null:
        selected_id = candidate.id
    _refresh()

func _gacha() -> void:
    var result := recruitment.gacha_candidate(state)
    if bool(result.get("ok", false)):
        selected_id = StringName(result.get("candidate_id", ""))
    _refresh()

func _fate() -> void:
    var result := recruitment.fate_candidate(state)
    if bool(result.get("ok", false)):
        selected_id = StringName(result.get("candidate_id", ""))
    _refresh()

func _select_first_candidate() -> void:
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if not ids.is_empty():
        selected_id = StringName(ids[0])

func _refresh() -> void:
    var candidate: CandidateState = state.recruitment_candidates.get(selected_id)
    if candidate == null:
        summary_label.text = "Không có ứng viên."
        detail_label.text = ""
        return

    var visible_ids := trait_system.visible_trait_ids(state, candidate.id)
    var latent_ids := trait_system.latent_trait_ids(state, candidate.id)
    var visible_names: Array[String] = []
    for raw_id in visible_ids:
        visible_names.append(trait_system.trait_name(StringName(raw_id)))

    summary_label.text = "%s | %s | nguồn %s | đặc chất thấy ngay %d | bí ẩn %d" % [
        candidate.display_name,
        generator.quality_name(candidate.disciple_quality),
        str(candidate.recruitment_source),
        visible_ids.size(),
        latent_ids.size()
    ]

    detail_label.text = "Tư Chất %d | Căn Cốt %d | Cơ Duyên %d\nThông Tuệ %d | Mị Lực %d | Tiềm Lực %d\nĐặc chất: %s\nĐặc chất ẩn: %s\n\nP2.9: phần ẩn đã được khóa từ lúc sinh nhân vật. Khi đủ lịch sử chiến đấu / làm nghề / tu luyện, game chỉ lộ ra thứ đã có — không roll lại." % [
        int(round(candidate.aptitude * 100.0)),
        int(round(candidate.constitution * 100.0)),
        int(round(candidate.fortune * 100.0)),
        int(round(candidate.comprehension * 100.0)),
        int(round(candidate.charisma * 100.0)),
        int(round(candidate.potential * 100.0)),
        ", ".join(visible_names) if not visible_names.is_empty() else "Không",
        "%d điều chưa biết" % latent_ids.size() if not latent_ids.is_empty() else "Không"
    ]
