class_name V63CombatHudV1
extends PanelContainer

signal archive_requested
signal preview_gate_toggled(enabled: bool)

const VFX_SCRIPT = preload("res://src/presentation/p3/v63_original_combat_vfx_v1.gd")
const VIS_QUALITY = preload("res://src/presentation/uiux/sect_quality_visual_v1.gd")

var state: SimulationState
var battle: MapBattleV2
var gate_enabled := false
var selected_actor_id := ""
var _rows: VBoxContainer
var _party_rows: Array[Button] = []
var _party_row_actor_ids: Array[String] = []
var _boss_name: Label
var _boss_hp: ProgressBar
var _boss_state: Label
var _skills: Label
var _event: Label
var _gate_button: Button
var _vfx: Control

func _ready() -> void:
    add_theme_stylebox_override("panel", _panel_style(Color("eee6d2"), Color("74694f")))
    var column := VBoxContainer.new()
    column.name = "CombatHudColumn"
    column.add_theme_constant_override("separation", 5)
    add_child(column)
    var head := HBoxContainer.new()
    column.add_child(head)
    var title := Label.new()
    title.text = "V6.5 · COMBAT V2"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_color_override("font_color", Color("183d35"))
    title.add_theme_font_size_override("font_size", 16)
    head.add_child(title)
    _gate_button = Button.new()
    _gate_button.custom_minimum_size = Vector2(104, 30)
    _gate_button.pressed.connect(_toggle_gate)
    head.add_child(_gate_button)
    _boss_name = Label.new()
    _boss_name.add_theme_font_size_override("font_size", 14)
    _boss_name.add_theme_color_override("font_color", Color("791f1b"))
    column.add_child(_boss_name)
    _boss_hp = ProgressBar.new()
    _boss_hp.custom_minimum_size = Vector2(0, 12)
    _boss_hp.show_percentage = false
    column.add_child(_boss_hp)
    _boss_state = Label.new()
    _boss_state.custom_minimum_size = Vector2(0, 34)
    _boss_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _boss_state.add_theme_font_size_override("font_size", 11)
    _boss_state.add_theme_color_override("font_color", Color("4f3822"))
    column.add_child(_boss_state)
    var party_title := Label.new()
    party_title.text = "ĐỘI HÌNH · chọn đệ tử để xem kỹ năng"
    party_title.add_theme_font_size_override("font_size", 11)
    party_title.add_theme_color_override("font_color", Color("183d35"))
    column.add_child(party_title)
    _rows = VBoxContainer.new()
    _rows.add_theme_constant_override("separation", 1)
    column.add_child(_rows)
    _skills = Label.new()
    _skills.custom_minimum_size = Vector2(0, 62)
    _skills.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _skills.add_theme_font_size_override("font_size", 11)
    _skills.add_theme_color_override("font_color", Color("252b25"))
    column.add_child(_skills)
    _event = Label.new()
    _event.custom_minimum_size = Vector2(0, 44)
    _event.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _event.add_theme_font_size_override("font_size", 11)
    _event.add_theme_color_override("font_color", Color("791f1b"))
    column.add_child(_event)
    var archive := Button.new()
    archive.text = "Mở Tàng Kinh Các · kỹ năng"
    archive.custom_minimum_size = Vector2(0, 34)
    archive.pressed.connect(func() -> void: archive_requested.emit())
    column.add_child(archive)
    _vfx = VFX_SCRIPT.new()
    _vfx.name = "OriginalCombatVFX"
    _vfx.custom_minimum_size = Vector2(52, 52)
    _vfx.mouse_filter = Control.MOUSE_FILTER_IGNORE
    column.add_child(_vfx)
    _render()

func set_authority(authoritative_state: SimulationState, snapshot: MapBattleV2,
        preview_enabled: bool) -> void:
    state = authoritative_state
    battle = snapshot
    gate_enabled = preview_enabled
    _gate_button.text = "V6.5: ON" if gate_enabled else "V6.5: OFF"
    _render()
    if _vfx != null:
        _vfx.call("consume_battle_events", snapshot)

func _toggle_gate() -> void:
    gate_enabled = not gate_enabled
    _gate_button.text = "V6.5: ON" if gate_enabled else "V6.5: OFF"
    preview_gate_toggled.emit(gate_enabled)

func _select_actor(actor_id: String) -> void:
    selected_actor_id = actor_id
    _render()

func _render() -> void:
    if _rows == null:
        return
    _ensure_party_rows()
    if battle == null:
        _hide_party_rows()
        _boss_name.text = "Chờ trận Combat V2"
        _boss_hp.value = 0
        _boss_state.text = "Boss, phase và telegraph sẽ đọc từ trận đã lưu."
        _skills.text = "Chưa có snapshot chiến đấu."
        _event.text = ""
        return
    var boss_actor: Dictionary = {}
    var party_ids: Array[String] = []
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side", "")) == "monster" and not str(actor.get("v63_boss_id", "")).is_empty():
            boss_actor = actor
        elif str(actor.get("side", "")) == "disciple":
            party_ids.append(str(raw_id))
    party_ids.sort()
    if boss_actor.is_empty():
        _boss_name.text = "Đối thủ · %d còn sống" % battle._count_alive("monster")
        _boss_hp.value = 0
        _boss_state.text = "Thời gian trận %.1fs · %s" % [battle.now, battle.outcome]
    else:
        var boss_id := str(boss_actor.get("v63_boss_id", ""))
        var definition := V63HumanSkillCombatSystem.boss_definition(boss_id)
        var boss_display_name := str(definition.get("name_vi","")).strip_edges()
        if boss_display_name.is_empty():
            boss_display_name = str(definition.get("name",definition.get("display_name",boss_id))).strip_edges()
        _boss_name.text = "Boss · "+boss_display_name
        _boss_hp.max_value = maxf(1.0, float(boss_actor.get("max_hp", 1.0)))
        _boss_hp.value = maxf(0.0, float(boss_actor.get("hp", 0.0)))
        var phase := int(boss_actor.get("v63_boss_phase", 1))
        var counter := ""
        var window: Dictionary = boss_actor.get("v63_boss_counter_window", {})
        if not window.is_empty():
            counter = " · phản kích mở"
        _boss_state.text = "HP %.0f / %.0f · Phase %d%s · %.1fs" % [
            _boss_hp.value, _boss_hp.max_value, phase, counter, battle.now]
    var visible_row_count := mini(6, party_ids.size())
    if selected_actor_id.is_empty():
        selected_actor_id = party_ids[0] if not party_ids.is_empty() else ""
    for row_index in range(_party_rows.size()):
        var row := _party_rows[row_index]
        if row_index >= visible_row_count:
            _party_row_actor_ids[row_index] = ""
            row.hide()
            continue
        var actor_id := party_ids[row_index]
        var actor: Dictionary = battle.actors[actor_id]
        var actor_state: DiscipleState = null
        if state != null and state.disciples.has(StringName(actor_id)):
            actor_state = state.disciples[StringName(actor_id)]
        var display_name: String = actor_id
        if actor_state != null:
            display_name = actor_state.display_name
        var hp := float(actor.get("hp", 0.0))
        var max_hp := maxf(1.0, float(actor.get("max_hp", 1.0)))
        var injury_text := " · Injury %d" % actor_state.injury_level if actor_state != null and actor_state.injury_level > 0 else ""
        row.text = "%s   HP %.0f/%.0f%s" % [display_name, hp, max_hp, injury_text]
        # VIS-03: canonical source-only quality in the existing combat HUD.
        if actor_state != null:
            VIS_QUALITY.apply_button(row, str(actor_state.disciple_quality))
        else:
            row.remove_theme_color_override("font_color")
            row.remove_theme_color_override("font_hover_color")
        _party_row_actor_ids[row_index] = actor_id
        row.button_pressed = actor_id == selected_actor_id
        row.show()
    _render_skills()
    _event.text = _latest_event_text()

func _ensure_party_rows() -> void:
    while _party_rows.size() < 6:
        var row_index := _party_rows.size()
        var row := Button.new()
        row.custom_minimum_size = Vector2(0, 25)
        row.alignment = HORIZONTAL_ALIGNMENT_LEFT
        row.add_theme_font_size_override("font_size", 10)
        row.pressed.connect(_select_party_row.bind(row_index))
        _rows.add_child(row)
        _party_rows.append(row)
        _party_row_actor_ids.append("")

func _hide_party_rows() -> void:
    for row_index in range(_party_rows.size()):
        _party_row_actor_ids[row_index] = ""
        _party_rows[row_index].hide()

func _select_party_row(row_index: int) -> void:
    if row_index < 0 or row_index >= _party_row_actor_ids.size():
        return
    var actor_id := _party_row_actor_ids[row_index]
    if not actor_id.is_empty():
        _select_actor(actor_id)

func _render_skills() -> void:
    if battle == null or not battle.actors.has(selected_actor_id):
        _skills.text = "Chọn thành viên để xem kỹ năng / mastery."
        return
    var actor: Dictionary = battle.actors[selected_actor_id]
    var loadout: Array = actor.get("v63_skill_loadout", [])
    var lines: Array[String] = ["Kỹ năng Combat V2 · %s" % selected_actor_id]
    for raw_id in loadout.slice(0, 5):
        var skill_id := str(raw_id)
        var definition := V63HumanSkillCombatSystem.skill_definition(skill_id)
        var name := str(definition.get("name_vi", definition.get("display_name", skill_id)))
        var ready := float(actor.get("v63_skill_ready", {}).get(skill_id, 0.0))
        lines.append("• %s%s" % [name, " · hồi %.1fs" % maxf(0.0, ready - battle.now) if ready > battle.now else " · sẵn sàng"])
    if lines.size() == 1:
        lines.append("Chưa có kỹ năng cá nhân được học/trang bị.")
    _skills.text = "\n".join(lines)

func _latest_event_text() -> String:
    if battle == null:
        return ""
    for index in range(battle.events.size() - 1, maxi(-1, battle.events.size() - 60), -1):
        var event: Dictionary = battle.events[index]
        var kind := str(event.get("type", ""))
        if kind == "telegraph":
            return "BÁO CHIÊU · %s · còn %.1fs · né khỏi vùng đỏ" % [str(event.get("skill_id", event.get("skill", "Boss"))), maxf(0.0, float(event.get("release_at", battle.now)) - battle.now)]
        if kind == "v63_boss_phase":
            return "BOSS ĐỔI PHASE · phase %d · HP %.0f%%" % [int(event.get("phase", 1)), float(event.get("hp_ratio", 0.0)) * 100.0]
        if kind == "boss_counter_hit":
            return "PHẢN KÍCH TRÚNG · %s" % str(event.get("skill_id", "Combat V2"))
        if kind in ["v63_skill_hit", "skill_cast"]:
            return "KỸ NĂNG THẬT · %s" % str(event.get("skill_id", "Combat V2"))
        if kind == "status_applied":
            return "HIỆU ỨNG · %s → %s" % [str(event.get("status", "")), str(event.get("target", ""))]
    return "Combat V2 · actions %d · %s" % [battle.actions, battle.outcome]

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(1)
    style.set_corner_radius_all(6)
    style.content_margin_left = 9
    style.content_margin_right = 9
    style.content_margin_top = 7
    style.content_margin_bottom = 7
    return style
