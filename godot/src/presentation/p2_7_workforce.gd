extends Control

const TEST_SEED := 1827272

var state: SimulationState
var actor: DiscipleState
var workforce := WorkforceSystem.new()
var scheduler: SimulationScheduler
var summary_label: Label
var detail_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P27Factory.create_state(TEST_SEED)
    actor = state.disciples.get(&"bach_nguyet")
    actor.region_id = &"sect"
    actor.stamina = 100.0
    actor.work_group_id = &"mining_crew"
    scheduler = SimulationScheduler.new(state)
    _build_ui()
    _refresh()

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
    title.text = "TÔNG MÔN TYCOON — P2.7 ĐỜI SỐNG & PHÂN CÔNG ĐỆ TỬ"
    title.add_theme_font_size_override("font_size", 20)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    column.add_child(row)

    var mine_button := Button.new()
    mine_button.text = "Ưu tiên khai khoáng"
    mine_button.pressed.connect(_prefer_mining)
    row.add_child(mine_button)

    var forge_button := Button.new()
    forge_button.text = "Lệnh: hỗ trợ luyện khí"
    forge_button.pressed.connect(_command_forging)
    row.add_child(forge_button)

    var clear_button := Button.new()
    clear_button.text = "Hủy lệnh trực tiếp"
    clear_button.pressed.connect(_clear_command)
    row.add_child(clear_button)

    var tick_button := Button.new()
    tick_button.text = "Chạy 20 nhịp"
    tick_button.pressed.connect(_run_ticks)
    row.add_child(tick_button)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(detail_label)

func _prefer_mining() -> void:
    actor.work_group_id = &""
    workforce.set_work_preference(state, actor.id, WorkforceSystem.PROF_MINING, 4)
    workforce.set_work_preference(state, actor.id, WorkforceSystem.PROF_FORGING, 0)
    _refresh()

func _command_forging() -> void:
    workforce.issue_command(state, actor.id, WorkforceSystem.COMMAND_WORK, "forging", 40)
    _refresh()

func _clear_command() -> void:
    workforce.clear_command(state, actor)
    _refresh()

func _run_ticks() -> void:
    scheduler.run_ticks(20)
    _refresh()

func _refresh() -> void:
    var command := str(actor.direct_command.get("kind", "Tự động")) if not actor.direct_command.is_empty() else "Tự động"
    var phase := workforce.schedule_phase(state, actor)
    summary_label.text = "%s | %s | ngộ tính %.2f | nhóm %s | pha %s | lệnh %s" % [
        actor.display_name,
        str(actor.sect_rank),
        actor.comprehension,
        str(actor.work_group_id) if actor.work_group_id != &"" else "cá nhân",
        str(phase),
        command
    ]
    detail_label.text = "Khai khoáng: cấp %d / XP %.1f\nLuyện khí: cấp %d / XP %.1f\nThanh Thiết trong kho: %d\nĐiểm hỗ trợ rèn: %d\nThể lực: %.1f\n\nP2.7: Tông Chủ đặt ưu tiên và lệnh; đệ tử tự cân lịch làm việc → tu luyện → hồi phục, rồi quay lại tự động sau khi lệnh trực tiếp hoàn tất." % [
        workforce.profession_level(actor, WorkforceSystem.PROF_MINING),
        workforce.profession_xp(actor, WorkforceSystem.PROF_MINING),
        workforce.profession_level(actor, WorkforceSystem.PROF_FORGING),
        workforce.profession_xp(actor, WorkforceSystem.PROF_FORGING),
        int(state.sect.forge_materials.get("thanh_thiet", 0)),
        state.sect.forge_support_points,
        actor.stamina
    ]
