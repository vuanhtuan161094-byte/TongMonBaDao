extends Control

const TEST_SEED := 919191

var state: SimulationState
var scheduler: SimulationScheduler
var organization := OrganizationSystem.new()
var disciple_ids: Array[StringName] = []
var selected_index := 0
var tick_accumulator := 0.0

var summary_label: Label
var disciple_label: Label
var detail_label: Label
var behavior_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P15Factory.create_state(TEST_SEED)
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

func _refresh_ids() -> void:
    disciple_ids.clear()
    var raw_ids: Array = state.disciples.keys()
    raw_ids.sort()
    for raw_id in raw_ids:
        disciple_ids.append(StringName(raw_id))
    selected_index = clampi(selected_index, 0, maxi(disciple_ids.size() - 1, 0))

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
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P1.5 TỔ CHỨC"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var disciple_row := HBoxContainer.new()
    disciple_row.add_theme_constant_override("separation", 8)
    column.add_child(disciple_row)

    disciple_label = Label.new()
    disciple_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    disciple_row.add_child(disciple_label)

    var next_button := Button.new()
    next_button.text = "Đổi người"
    next_button.pressed.connect(_next_disciple)
    disciple_row.add_child(next_button)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(detail_label)

    var team_row := HBoxContainer.new()
    team_row.add_theme_constant_override("separation", 6)
    column.add_child(team_row)

    var move_button := Button.new()
    move_button.text = "Chuyển đội"
    move_button.pressed.connect(_move_team)
    team_row.add_child(move_button)

    var leader_button := Button.new()
    leader_button.text = "Bổ nhiệm đội trưởng"
    leader_button.pressed.connect(_make_leader)
    team_row.add_child(leader_button)

    var role_row := HBoxContainer.new()
    role_row.add_theme_constant_override("separation", 5)
    column.add_child(role_row)

    for role_id in [OrganizationSystem.ROLE_HUNTER, OrganizationSystem.ROLE_LOGISTICS, OrganizationSystem.ROLE_GUARD]:
        var button := Button.new()
        button.text = _role_name(role_id)
        button.pressed.connect(_assign_role.bind(role_id))
        role_row.add_child(button)

    var clear_button := Button.new()
    clear_button.text = "Bỏ vai trò"
    clear_button.pressed.connect(_clear_role)
    role_row.add_child(clear_button)

    behavior_label = Label.new()
    behavior_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    behavior_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(behavior_label)

func _next_disciple() -> void:
    if disciple_ids.is_empty():
        return
    selected_index = (selected_index + 1) % disciple_ids.size()
    _refresh_ui()

func _selected_id() -> StringName:
    if disciple_ids.is_empty():
        return &""
    return disciple_ids[selected_index]

func _move_team() -> void:
    var disciple_id := _selected_id()
    var current := organization.team_for_disciple(state, disciple_id)
    var team_ids: Array = state.teams.keys()
    team_ids.sort()
    if team_ids.size() < 2:
        return
    var target_id := StringName(team_ids[0])
    if current != null and str(current.id) == str(team_ids[0]):
        target_id = StringName(team_ids[1])
    organization.assign_member(state, disciple_id, target_id)
    _refresh_ui()

func _make_leader() -> void:
    var disciple_id := _selected_id()
    var team := organization.team_for_disciple(state, disciple_id)
    if team != null:
        organization.assign_leader(state, team.id, disciple_id)
    _refresh_ui()

func _assign_role(role_id: StringName) -> void:
    organization.assign_role(state, _selected_id(), role_id)
    _refresh_ui()

func _clear_role() -> void:
    organization.clear_role(state, _selected_id())
    _refresh_ui()

func _refresh_ui() -> void:
    _refresh_ids()
    if disciple_ids.is_empty():
        return

    var disciple_id := _selected_id()
    var disciple: DiscipleState = state.disciples.get(disciple_id)
    var team := organization.team_for_disciple(state, disciple_id)
    var role_id := organization.role_for_disciple(state, disciple_id)
    var team_name := "chưa có đội"
    var leader_name := "chưa có"
    if team != null:
        team_name = team.display_name
        if team.leader_id != &"" and state.disciples.has(team.leader_id):
            leader_name = state.disciples[team.leader_id].display_name

    summary_label.text = "Tick %d | Đệ tử %d | Đội %d | Lần thay đổi tổ chức %d" % [
        state.tick,
        state.disciples.size(),
        state.teams.size(),
        state.organization_change_count
    ]
    disciple_label.text = "Đang xem: %s" % disciple.display_name
    detail_label.text = "Đội: %s | Đội trưởng: %s | Vai trò: %s" % [
        team_name,
        leader_name,
        _role_name(role_id)
    ]

    var org_scores: Dictionary = disciple.last_decision.get("organization_region_scores", {})
    var scores: Dictionary = disciple.last_decision.get("scores", {})
    behavior_label.text = (
        "Tác động thật:\n"
        + "- Đội trưởng kéo thành viên về hướng của đội, mạnh/yếu theo Tin tưởng + Kính trọng.\n"
        + "- Ký ức tốt/xấu với đội trưởng vẫn cộng riêng.\n"
        + "- Săn tăng xu hướng đi săn; Hậu cần tăng mua/bán/phục hồi; Hộ vệ ưu tiên an toàn và hỗ trợ đồng đội.\n\n"
        + "Hành động: %s | Mục tiêu khu vực: %s\n"
        + "Điểm HUNT %.1f | BUY %.1f | REST %.1f\n"
        + "Điểm tổ chức: Thanh Trúc %.1f | Bạch Thạch %.1f | Hắc Phong %.1f"
    ) % [
        str(disciple.current_action),
        str(disciple.target_region_id),
        float(scores.get("HUNT", 0.0)),
        float(scores.get("BUY", 0.0)),
        float(scores.get("REST", 0.0)),
        float(org_scores.get("thanh_truc_lam", 0.0)),
        float(org_scores.get("bach_thach_khe", 0.0)),
        float(org_scores.get("hac_phong_coc", 0.0))
    ]

func _role_name(role_id: StringName) -> String:
    match role_id:
        OrganizationSystem.ROLE_HUNTER:
            return "Săn"
        OrganizationSystem.ROLE_LOGISTICS:
            return "Hậu cần"
        OrganizationSystem.ROLE_GUARD:
            return "Hộ vệ"
        _:
            return "Chưa phân công"
