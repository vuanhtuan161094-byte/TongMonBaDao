class_name DanTienScreenV2
extends Control

# C2 live recruitment screen. Reads ONE SimulationState; all mutations go through
# RecruitmentSystem (no private roster/inventory/gacha state). Source A is optional:
# an actual verified scene is used if registered; no substitute is claimed as Source A.
signal closed
signal state_changed

const BG := Color("#101e27")
const SURFACE := Color("#20333a")
const SURFACE_LIGHT := Color("#2a4148")
const GOLD := Color("#e6c58b")
const WHITE := Color("#eef2e9")
const MUTED := Color("#a6b9b6")
const JADE := Color("#53c6ac")
const DANGER := Color("#e4a4a0")
const PAGE_SIZE := 6

var game_state: SimulationState
var recruitment: RecruitmentSystem
var selected_candidate_id: StringName = &""
var pending_reject_id: StringName = &""
var search_text := ""
var grade_filter := "all"
var page_index := 0
var feedback := ""
var _count_label: Label
var _token_button: Button
var _page_label: Label
var _candidate_list: VBoxContainer
var _detail_list: VBoxContainer
var _feedback_label: Label
var _root_panel: PanelContainer
var _guide_select: OptionButton
var _assistant_select: OptionButton
var _guide_hint: Label
var _main_options: Array[StringName] = []
var _assistant_options: Array[StringName] = []
var _source_a_frame_cache: Dictionary = {}

func attach_state(authoritative_state: SimulationState, authority: RecruitmentSystem) -> void:
    game_state = authoritative_state
    recruitment = authority

func _ready() -> void:
    name = "DanTienScreenV2"
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _build_layout()
    _refresh_all()

func _style(fill: Color, border: Color = Color.TRANSPARENT, thickness: int = 0, curve: int = 10) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(thickness)
    style.set_corner_radius_all(curve)
    return style

func _label(value: String, font_size: int = 13, color: Color = WHITE) -> Label:
    var out := Label.new()
    out.text = value
    out.add_theme_font_size_override("font_size", font_size)
    out.add_theme_color_override("font_color", color)
    out.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return out

func _button(value: String, action: Callable, accent: bool = false) -> Button:
    var button := Button.new()
    button.text = value
    button.custom_minimum_size = Vector2(0, 36)
    button.add_theme_font_size_override("font_size", 12)
    button.add_theme_color_override("font_color", BG if accent else WHITE)
    button.add_theme_color_override("font_disabled_color", MUTED)
    button.add_theme_stylebox_override("normal", _style(GOLD if accent else SURFACE_LIGHT, GOLD if accent else Color("#627d7c"), 1, 8))
    button.add_theme_stylebox_override("hover", _style(JADE if accent else Color("#36535a"), JADE, 1, 8))
    button.add_theme_stylebox_override("pressed", _style(Color("#568e80"), JADE, 1, 8))
    button.add_theme_stylebox_override("disabled", _style(Color("#304047"), Color("#4a585b"), 1, 8))
    button.pressed.connect(action)
    return button

func _clear(container: Node) -> void:
    for child in container.get_children():
        container.remove_child(child)
        child.queue_free()

func _build_layout() -> void:
    var shade := ColorRect.new()
    shade.name = "RecruitmentBackdrop"
    shade.color = Color(0.015, 0.030, 0.045, 0.86)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(shade)

    _root_panel = PanelContainer.new()
    _root_panel.name = "DanTienDialog"
    _root_panel.anchor_left = 0.5
    _root_panel.anchor_top = 0.5
    _root_panel.anchor_right = 0.5
    _root_panel.anchor_bottom = 0.5
    var view_size := get_viewport_rect().size
    var width := minf(view_size.x - 24.0, 1170.0)
    var height := minf(view_size.y - 24.0, 656.0)
    _root_panel.offset_left = -width * 0.5
    _root_panel.offset_right = width * 0.5
    _root_panel.offset_top = -height * 0.5
    _root_panel.offset_bottom = height * 0.5
    _root_panel.add_theme_stylebox_override("panel", _style(BG, GOLD, 2, 15))
    add_child(_root_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 20)
    margin.add_theme_constant_override("margin_right", 20)
    margin.add_theme_constant_override("margin_top", 14)
    margin.add_theme_constant_override("margin_bottom", 14)
    _root_panel.add_child(margin)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 9)
    margin.add_child(layout)

    var head := HBoxContainer.new()
    head.add_theme_constant_override("separation", 10)
    layout.add_child(head)
    var headline := VBoxContainer.new()
    headline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    headline.add_child(_label("DẪN TIÊN ĐÀI  ·  CHIÊU MỘ ĐỆ TỬ", 22, GOLD))
    headline.add_child(_label("Xem căn cơ, nhận môn đồ, quản lý ứng viên · D7", 12, MUTED))
    head.add_child(headline)
    head.add_child(_button("ĐÓNG  ×", Callable(self, "_close_screen")))

    var status := HBoxContainer.new()
    status.add_theme_constant_override("separation", 10)
    layout.add_child(status)
    _count_label = _label("", 13, WHITE)
    _count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status.add_child(_count_label)
    _token_button = _button("Chiêu Mộ Lệnh", Callable(self, "_spend_order"), true)
    _token_button.custom_minimum_size.x = 220
    status.add_child(_token_button)

    var guide_bar := HBoxContainer.new()
    guide_bar.name = "DanTienGuideBar"
    guide_bar.add_theme_constant_override("separation", 9)
    layout.add_child(guide_bar)
    guide_bar.add_child(_label("Tiếp Dẫn Chính", 12, GOLD))
    _guide_select = OptionButton.new()
    _guide_select.custom_minimum_size.x = 174
    _guide_select.item_selected.connect(Callable(self, "_on_guide_selected"))
    guide_bar.add_child(_guide_select)
    guide_bar.add_child(_label("Hỗ trợ", 12, GOLD))
    _assistant_select = OptionButton.new()
    _assistant_select.custom_minimum_size.x = 180
    _assistant_select.item_selected.connect(Callable(self, "_on_assistant_selected"))
    guide_bar.add_child(_assistant_select)
    _guide_hint = _label("", 11, MUTED)
    _guide_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    guide_bar.add_child(_guide_hint)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 12)
    layout.add_child(body)

    var left := PanelContainer.new()
    left.custom_minimum_size.x = maxf(430.0, width * 0.52)
    left.size_flags_vertical = Control.SIZE_EXPAND_FILL
    left.add_theme_stylebox_override("panel", _style(SURFACE, Color("#425d60"), 1, 10))
    body.add_child(left)
    var left_margin := MarginContainer.new()
    for key in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
        left_margin.add_theme_constant_override(key, 12)
    left.add_child(left_margin)
    var left_column := VBoxContainer.new()
    left_column.add_theme_constant_override("separation", 8)
    left_margin.add_child(left_column)
    left_column.add_child(_label("DANH SÁCH ỨNG VIÊN", 15, GOLD))

    var controls := HBoxContainer.new()
    controls.add_theme_constant_override("separation", 6)
    left_column.add_child(controls)
    var search := LineEdit.new()
    search.name = "CandidateSearch"
    search.placeholder_text = "Tìm tên ứng viên..."
    search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    search.text_changed.connect(Callable(self, "_on_search_changed"))
    controls.add_child(search)
    var filter := OptionButton.new()
    filter.name = "CandidateQualityFilter"
    filter.custom_minimum_size.x = 158
    for item in ["Tất cả phẩm", "Phàm Thường", "Xuất Chúng", "Thiên Kiêu", "Tuyệt Luân", "Nghịch Thiên"]:
        filter.add_item(item)
    filter.item_selected.connect(Callable(self, "_on_quality_filter_changed"))
    controls.add_child(filter)

    var scroller := ScrollContainer.new()
    scroller.name = "PagedCandidateListScroll"
    scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    left_column.add_child(scroller)
    _candidate_list = VBoxContainer.new()
    _candidate_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _candidate_list.add_theme_constant_override("separation", 7)
    scroller.add_child(_candidate_list)
    var pager := HBoxContainer.new()
    pager.add_theme_constant_override("separation", 10)
    left_column.add_child(pager)
    pager.add_child(_button("◀ Trước", Callable(self, "_previous_page")))
    _page_label = _label("", 12, MUTED)
    _page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pager.add_child(_page_label)
    pager.add_child(_button("Sau ▶", Callable(self, "_next_page")))

    var right := PanelContainer.new()
    right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right.add_theme_stylebox_override("panel", _style(Color("#192b34"), Color("#425d60"), 1, 10))
    body.add_child(right)
    var right_margin := MarginContainer.new()
    for key in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
        right_margin.add_theme_constant_override(key, 12)
    right.add_child(right_margin)
    var detail_scroll := ScrollContainer.new()
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    right_margin.add_child(detail_scroll)
    _detail_list = VBoxContainer.new()
    _detail_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _detail_list.add_theme_constant_override("separation", 8)
    detail_scroll.add_child(_detail_list)

    _feedback_label = _label("", 12, GOLD)
    _feedback_label.custom_minimum_size.y = 20
    layout.add_child(_feedback_label)

func _close_screen() -> void:
    closed.emit()
    queue_free()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
        _close_screen()
        get_viewport().set_input_as_handled()

func _on_search_changed(value: String) -> void:
    search_text = value.strip_edges().to_lower()
    page_index = 0
    _refresh_list()
    # Keep the profile/action panel in sync with the active search results.
    _refresh_detail()

func _on_quality_filter_changed(index: int) -> void:
    var ids := ["all", "common", "outstanding", "prodigy", "peerless", "heaven_defying"]
    grade_filter = ids[clampi(index, 0, ids.size() - 1)]
    page_index = 0
    _refresh_list()
    # A filtered-out candidate must not remain actionable in the detail panel.
    _refresh_detail()

func _filtered_ids() -> Array:
    var ids: Array = []
    if game_state == null:
        return ids
    for raw_id in game_state.recruitment_candidates.keys():
        var candidate: CandidateState = game_state.recruitment_candidates[raw_id]
        if candidate == null:
            continue
        if not search_text.is_empty() and not candidate.display_name.to_lower().contains(search_text):
            continue
        if grade_filter != "all" and str(candidate.disciple_quality) != grade_filter:
            continue
        ids.append(raw_id)
    ids.sort()
    return ids

func _refresh_all() -> void:
    if game_state == null or recruitment == null:
        return
    var queue_size := game_state.recruitment_candidates.size()
    var limit := RecruitmentSystem.C2_QUEUE_CAP
    _count_label.text = "Đệ tử %d/%d   ·   Ứng viên %d/%d   ·   Còn %d chỗ" % [
        game_state.disciples.size(), game_state.sect.disciple_capacity,
        queue_size, limit, maxi(0, game_state.sect.disciple_capacity-game_state.disciples.size())
    ]
    _token_button.text = "Chiêu Mộ Lệnh  ×%d" % game_state.sect.disciple_recruitment_tokens
    _token_button.disabled = game_state.sect.disciple_recruitment_tokens <= 0 or queue_size >= limit
    _token_button.tooltip_text = "Hàng chờ đã đầy: không tiêu Chiêu Mộ Lệnh" if queue_size >= limit else "Tốn đúng 1 lệnh để tạo thêm một ứng viên"
    _feedback_label.text = feedback
    _refresh_guide_selectors()
    _refresh_list()
    _refresh_detail()

func _refresh_list() -> void:
    if _candidate_list == null:
        return
    _clear(_candidate_list)
    var ids := _filtered_ids()
    var pages := maxi(1, int(ceil(float(ids.size()) / float(PAGE_SIZE))))
    page_index = clampi(page_index, 0, pages - 1)
    _page_label.text = "Trang %d/%d · %d hồ sơ" % [page_index+1, pages, ids.size()]
    if ids.is_empty():
        _candidate_list.add_child(_label("Chưa có ứng viên phù hợp. Chờ lượt tự đến hoặc dùng Chiêu Mộ Lệnh.", 13, MUTED))
        return
    var start := page_index * PAGE_SIZE
    var stop := mini(start + PAGE_SIZE, ids.size())
    for i in range(start, stop):
        var candidate_id := StringName(str(ids[i]))
        var candidate: CandidateState = game_state.recruitment_candidates[candidate_id]
        var selected := candidate_id == selected_candidate_id
        var row := PanelContainer.new()
        row.add_theme_stylebox_override("panel", _style(SURFACE_LIGHT if selected else Color("#253942"), GOLD if selected else Color("#4b696b"), 1, 8))
        _candidate_list.add_child(row)
        var choose := Button.new()
        choose.name = "DanTienCandidate_%s" % str(candidate_id)
        choose.flat = true
        choose.alignment = HORIZONTAL_ALIGNMENT_LEFT
        choose.custom_minimum_size.y = 62
        choose.text = "%s  ·  %s\nTư %.0f  Cốt %.0f  Tâm %.0f  |  Tuệ %.0f  Duyên %.0f" % [
            candidate.display_name, _quality_name(candidate),
            candidate.aptitude, candidate.constitution, candidate.mind_nature,
            candidate.comprehension, candidate.fortune
        ]
        choose.add_theme_font_size_override("font_size", 12)
        choose.add_theme_color_override("font_color", GOLD if selected else WHITE)
        choose.pressed.connect(Callable(self, "_select_candidate").bind(candidate_id))
        row.add_child(choose)

func _select_candidate(candidate_id: StringName) -> void:
    selected_candidate_id = candidate_id
    pending_reject_id = &""
    _refresh_list()
    _refresh_detail()

func _refresh_detail() -> void:
    if _detail_list == null:
        return
    _clear(_detail_list)
    var ids := _filtered_ids()
    if selected_candidate_id == &"" or not game_state.recruitment_candidates.has(selected_candidate_id) or not ids.has(selected_candidate_id):
        selected_candidate_id = StringName(str(ids[0])) if not ids.is_empty() else &""
    if selected_candidate_id == &"":
        _detail_list.add_child(_label("Chọn một ứng viên để xem căn cơ.", 14, MUTED))
        return
    var candidate: CandidateState = game_state.recruitment_candidates[selected_candidate_id]
    if candidate == null:
        return
    _detail_list.add_child(_label("HỒ SƠ ỨNG VIÊN", 15, GOLD))
    _detail_list.add_child(_label("%s  ·  %s" % [candidate.display_name, _quality_name(candidate)], 18, WHITE))
    _detail_list.add_child(_label("%s  ·  %d tuổi / thọ %d" % [
        "Nữ" if str(candidate.sex_id) == "female" else "Nam", candidate.age, candidate.max_lifespan
    ], 12, MUTED))

    var visual_row := HBoxContainer.new()
    visual_row.add_theme_constant_override("separation", 6)
    _detail_list.add_child(visual_row)
    var portrait := _source_a_preview(candidate)
    visual_row.add_child(portrait)
    var radar := DanTienD7Radar.new()
    radar.name = "DanTienD7Radar"
    radar.custom_minimum_size = Vector2(195, 174)
    radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    radar.set_candidate(candidate)
    visual_row.add_child(radar)

    _detail_list.add_child(_label("● Tam Căn: Tư %.0f / Cốt %.0f / Tâm %.0f" % [
        candidate.aptitude, candidate.constitution, candidate.mind_nature
    ], 12, JADE))
    _detail_list.add_child(_label("● Tứ Tính: Tiềm %.0f / Tuệ %.0f / Duyên %.0f / Mị %.0f" % [
        candidate.potential, candidate.comprehension, candidate.fortune, candidate.charisma
    ], 12, GOLD))
    _detail_list.add_child(_label("Linh Căn: %s" % _visible_roots(candidate), 12, WHITE))
    _detail_list.add_child(_label("Thiên hướng nghề: %s" % _visible_professions(candidate), 12, WHITE))
    var discovered := _visible_special_identity(candidate)
    if not discovered.is_empty():
        _detail_list.add_child(_label("Đã khám phá: %s" % discovered, 12, MUTED))
    _detail_list.add_child(_label("Công Pháp: chưa học khi tuyển · Cảnh giới V2 khởi đầu: Phàm Nhân/Phàm Thân tầng 1", 12, MUTED))

    if not _recruitable(candidate):
        _detail_list.add_child(_label("Không thể nhận: hồ sơ sinh V2 chưa hợp lệ. Không tạo lại ngẫu nhiên.", 12, DANGER))
    if game_state.disciples.size() >= game_state.sect.disciple_capacity:
        _detail_list.add_child(_label("Đệ Tử Xá đã đủ chỗ: cần mở rộng trước khi nhận.", 12, DANGER))
    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 6)
    _detail_list.add_child(actions)
    var accept := _button("NHẬN ĐỆ TỬ", Callable(self, "_accept_selected"), true)
    accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    accept.disabled = not _recruitable(candidate) or not recruitment.can_accept_more(game_state)
    actions.add_child(accept)
    var reject_text := "XÁC NHẬN TỪ CHỐI" if pending_reject_id == selected_candidate_id else "TỪ CHỐI"
    var reject := _button(reject_text, Callable(self, "_reject_selected"))
    reject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    actions.add_child(reject)
    _detail_list.add_child(_label("Ứng viên chưa nhận không chiếm chỗ. Từ chối không hoàn Chiêu Mộ Lệnh đã dùng.", 11, MUTED))

func _guide_eligible(disciple: DiscipleState) -> bool:
    return disciple != null and recruitment.guidance_guide_eligible(game_state, disciple.id)

func _refresh_guide_selectors() -> void:
    var snapshot := recruitment.guidance_state_snapshot(game_state)
    var main := str(snapshot.get("main_guide_id", ""))
    var assistants: Array = snapshot.get("assistant_guide_ids", [])
    var ids: Array = game_state.disciples.keys()
    ids.sort()

    _guide_select.clear()
    _main_options.clear()
    _main_options.append(&"")
    _guide_select.add_item("Không chỉ định")
    var active_index := 0
    for raw_id in ids:
        var disciple: DiscipleState = game_state.disciples[raw_id]
        if not _guide_eligible(disciple) and str(disciple.id) != main:
            continue
        _main_options.append(disciple.id)
        _guide_select.add_item(disciple.display_name)
        if str(disciple.id) == main:
            active_index = _main_options.size() - 1
    _guide_select.select(active_index)

    _assistant_select.clear()
    _assistant_options.clear()
    _assistant_options.append(&"")
    _assistant_select.add_item("Chọn/Bỏ hỗ trợ")
    for raw_id in ids:
        var disciple: DiscipleState = game_state.disciples[raw_id]
        if str(disciple.id) == main:
            continue
        if not _guide_eligible(disciple) and not assistants.has(str(disciple.id)):
            continue
        _assistant_options.append(disciple.id)
        var mark := "✓ " if assistants.has(str(disciple.id)) else "+ "
        _assistant_select.add_item(mark + disciple.display_name)
    _assistant_select.select(0)
    var rates := recruitment.guidance_current_quality_rates(game_state)
    var platform := BuildingSystem.new().primary_building(game_state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    var slots := maxi(BuildingSystem.new().guidance_elder_slots(platform) - 1, 0) if platform != null else 0
    _guide_hint.text = "Hiệu lực ngày mô phỏng kế tiếp\nNghịch Thiên hôm nay: %.1f%% · Hỗ trợ %d/%d" % [
        float(rates.get("heaven_defying",0.002))*100.0,
        assistants.size(), slots
    ]

func _on_guide_selected(index: int) -> void:
    if index < 0 or index >= _main_options.size():
        return
    var id := _main_options[index]
    if id != &"" and not _guide_eligible(game_state.disciples.get(id)):
        feedback = "Đệ tử đang làm việc, PvE hoặc bị thương; không tự chuyển việc."
        _refresh_all()
        return
    var result := recruitment.assign_guidance_main(game_state,id)
    feedback = "Đã đổi Tiếp Dẫn Chính. Tỷ lệ phẩm đổi vào ngày mô phỏng kế tiếp." if bool(result.get("ok",false)) else "Không đổi được: %s" % str(result.get("reason","unknown"))
    if bool(result.get("ok",false)):
        state_changed.emit()
    _refresh_all()

func _on_assistant_selected(index: int) -> void:
    if index <= 0 or index >= _assistant_options.size():
        return
    var id := _assistant_options[index]
    var snapshot := recruitment.guidance_state_snapshot(game_state)
    var current: Array = snapshot.get("assistant_guide_ids", []).duplicate()
    if current.has(str(id)):
        current.erase(str(id))
    else:
        if not _guide_eligible(game_state.disciples.get(id)):
            feedback = "Không được chuyển đệ tử đang làm việc."
            _refresh_all()
            return
        current.append(str(id))
    var result := recruitment.set_guidance_assistants(game_state,current)
    feedback = "Đã cập nhật đệ tử hỗ trợ. Có hiệu lực vào ngày mô phỏng kế tiếp." if bool(result.get("ok",false)) else "Không đổi được: %s" % str(result.get("reason","unknown"))
    if bool(result.get("ok",false)):
        state_changed.emit()
    _refresh_all()

func _quality_name(candidate: CandidateState) -> String:
    return str(DiscipleGeneratorV2.QUALITY_NAMES.get(str(candidate.disciple_quality), str(candidate.disciple_quality)))

func _recruitable(candidate: CandidateState) -> bool:
    return candidate != null and (
        not game_state.sect.disciple_v2_birth_enabled
        or DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile)
    )

func _source_a_preview(candidate: CandidateState) -> Control:
    var holder := PanelContainer.new()
    holder.custom_minimum_size = Vector2(142, 174)
    holder.add_theme_stylebox_override("panel", _style(Color("#30474b"), Color("#a28c67"), 1, 8))
    var render := TextureRect.new()
    render.name = "CandidateSourceAPortrait"
    render.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    render.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    render.custom_minimum_size = Vector2(140, 170)
    var preview_disciple := candidate.to_disciple()
    var scene_path := DiscipleSourceAVisualPool.scene_path_for_disciple(preview_disciple)
    if not scene_path.is_empty() and _source_a_frame_cache.has(scene_path):
        render.texture = _source_a_frame_cache[scene_path] as Texture2D
    elif not scene_path.is_empty():
        var source_scene := DiscipleSourceAVisualPool.scene_for_disciple(preview_disciple)
        if source_scene != null:
            var sprite := source_scene.instantiate() as AnimatedSprite2D
            if sprite != null:
                var frames := sprite.sprite_frames
                if frames != null and frames.has_animation(&"stand") and frames.get_frame_count(&"stand") > 0:
                    render.texture = frames.get_frame_texture(&"stand", 0)
                    _source_a_frame_cache[scene_path] = render.texture
                sprite.free()
    if render.texture != null:
        holder.add_child(render)
    else:
        var fallback := _label("CHƯA CÓ\nẢNH SOURCE A\nPHÙ HỢP", 11, MUTED)
        fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        fallback.custom_minimum_size = Vector2(140, 170)
        holder.add_child(fallback)
    return holder

func _visible_roots(candidate: CandidateState) -> String:
    var profile: Dictionary = candidate.v2_birth_profile
    var layers: Dictionary = profile.get("layers", {})
    var root: Dictionary = layers.get("spiritual_root", {})
    var values: Dictionary = root.get("current_values", {})
    if values.is_empty():
        return "chưa có dữ liệu xác minh"
    var keys: Array = values.keys()
    keys.sort()
    var labels: Array[String] = []
    var names := {"metal":"Kim", "wood":"Mộc", "water":"Thủy", "fire":"Hỏa", "earth":"Thổ"}
    for key in keys:
        labels.append("%s %d" % [str(names.get(str(key), str(key))), int(values[key])])
    return " · ".join(labels)

func _visible_professions(candidate: CandidateState) -> String:
    if candidate.profession_traits.is_empty():
        return "chưa có thiên phú xác minh"
    var grades: Array[String] = []
    var labels := {"forge_talent":"Luyện Khí", "miner_instinct":"Khai Khoáng", "herbalist_affinity":"Linh Dược"}
    for entry in candidate.profession_traits:
        var id := str(entry)
        if labels.has(id):
            grades.append("%s · bậc %d" % [str(labels[id]), int(candidate.profession_trait_grades.get(id, 1))])
    return " / ".join(grades) if not grades.is_empty() else "chưa có thiên phú nghề xác minh"

func _visible_special_identity(candidate: CandidateState) -> String:
    var profile: Dictionary = candidate.v2_birth_profile
    var layers: Dictionary = profile.get("layers", {})
    var disclosed: Array[String] = []
    for key in ["root_mutation", "bloodline", "physique", "destiny"]:
        var entry: Dictionary = layers.get(key, {})
        if not bool(entry.get("revealed", false)):
            continue
        var title: String = str({"root_mutation":"Dị Linh Căn", "bloodline":"Huyết Mạch", "physique":"Thể Chất", "destiny":"Mệnh Cách"}[key])
        var identity := str(entry.get("mutation_id", entry.get("bloodline_id", entry.get("physique_id", entry.get("destiny_id", "")))))
        if identity != "" and identity != "none":
            disclosed.append("%s: %s" % [str(title), identity])
    return " · ".join(disclosed)

func _spend_order() -> void:
    if game_state.recruitment_candidates.size() >= RecruitmentSystem.C2_QUEUE_CAP:
        feedback = "Hàng chờ đầy, Chiêu Mộ Lệnh chưa bị tiêu."
        _refresh_all()
        return
    var result := recruitment.guidance_recruit_with_order(game_state)
    feedback = "Đã tạo một ứng viên bằng Chiêu Mộ Lệnh." if bool(result.get("ok", false)) else "Không thể chiêu mộ: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        selected_candidate_id = StringName(str(result.get("candidate_id", "")))
        state_changed.emit()
    _refresh_all()

func _accept_selected() -> void:
    if selected_candidate_id == &"":
        return
    var candidate: CandidateState = game_state.recruitment_candidates.get(selected_candidate_id)
    if candidate == null:
        return
    var name_text := candidate.display_name
    var result := recruitment.accept_candidate(game_state, selected_candidate_id)
    feedback = "Đã nhận %s vào tông môn." % name_text if bool(result.get("ok",false)) else "Không thể nhận: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok",false)):
        selected_candidate_id = &""
        pending_reject_id = &""
        state_changed.emit()
    _refresh_all()

func _reject_selected() -> void:
    if selected_candidate_id == &"":
        return
    if pending_reject_id != selected_candidate_id:
        pending_reject_id = selected_candidate_id
        feedback = "Bấm XÁC NHẬN TỪ CHỐI lần nữa để loại hồ sơ này."
        _refresh_all()
        return
    var result := recruitment.reject_candidate(game_state, selected_candidate_id)
    feedback = "Đã từ chối ứng viên." if bool(result.get("ok", false)) else "Không thể từ chối: %s" % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        selected_candidate_id = &""
        state_changed.emit()
    pending_reject_id = &""
    _refresh_all()

func _previous_page() -> void:
    page_index = maxi(page_index - 1, 0)
    _refresh_list()

func _next_page() -> void:
    page_index += 1
    _refresh_list()
