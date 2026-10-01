extends Control

const TEST_SEED := 2030302

var state: SimulationState
var actor: DiscipleState
var roots := RootRefinementSystem.new()
var spiritual_roots := SpiritualRootSystem.new()
var summary_label: Label
var detail_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P210Factory.create_state(TEST_SEED)
    state.sect.disciple_capacity += 2
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if not ids.is_empty():
        var candidate_id := StringName(ids[0])
        RecruitmentSystem.new().accept_candidate(state, candidate_id)
        actor = state.disciples.get(candidate_id)
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
    title.text = "TÔNG MÔN BÁ ĐẠO — P2.10 TINH LUYỆN LINH CĂN"
    title.add_theme_font_size_override("font_size", 20)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var refine_button := Button.new()
    refine_button.text = "Dùng 1 Linh Tủy tinh luyện"
    refine_button.pressed.connect(_refine)
    column.add_child(refine_button)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(detail_label)

func _refine() -> void:
    if actor != null:
        roots.refine_disciple(state, actor.id)
    _refresh()

func _refresh() -> void:
    if actor == null:
        summary_label.text = "Không có đệ tử V2 để tinh luyện."
        detail_label.text = ""
        return
    var mutation := roots.revealed_mutation(state, actor.id)
    var mutation_text := "Chưa thức tỉnh" if mutation == &"" else roots.mutation_name(mutation)
    summary_label.text = "%s | %s | độ tinh thuần %d%% | Linh Tủy: %d" % [
        actor.display_name,
        spiritual_roots.quality_name(actor.spiritual_root_quality),
        int(round(actor.spiritual_root_purity * 100.0)),
        int(state.sect.technique_materials.get(RootRefinementSystem.MATERIAL_ID, 0))
    ]
    var element_names: Array = []
    for raw_element in actor.spiritual_root_elements:
        element_names.append(spiritual_roots.element_name(StringName(raw_element)))
    detail_label.text = "Linh căn: %s\nSố lần tinh luyện: %d\nBiến dị: %s\n\nTinh luyện tăng độ tinh thuần nhưng không tự đổi số hệ. Qua ngưỡng tinh thuần, phẩm linh căn tăng và các hệ tu luyện/công pháp cũ nhận hiệu quả mới. Biến dị nếu có đã được khóa từ lúc sinh, tinh luyện chỉ làm nó thức tỉnh." % [
        ", ".join(element_names),
        roots.refinement_count(state, actor.id),
        mutation_text
    ]
