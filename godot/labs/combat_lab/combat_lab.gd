extends Control

const ArenaScript = preload("res://labs/combat_lab/combat_lab_arena.gd")
const EventBridgeScript = preload("res://labs/combat_lab/combat_lab_event_bridge.gd")
const SCHOOL_KEYS := ["bow", "fist", "poison"]
const SCHOOL_LABELS := ["Cung", "Quyền", "Độc"]
const GENERATION_KEYS := ["human", "immortal", "divine"]
const GENERATION_LABELS := ["Nhân", "Tiên", "Thần"]
const VISUAL_FRAME_INTERVAL := 1.0 / 24.0
const HUD_UPDATE_INTERVAL := 0.15
const BOSS_IDS := [
    "tmb.boss.thiet_giap_son_vien", "tmb.boss.xich_viem_lang_vuong", "tmb.boss.bach_doc_chu_hau",
    "tmb.boss.loi_nguc_tien_tuong", "tmb.boss.han_nguyet_ao_hau", "tmb.boss.u_minh_co_tien",
    "tmb.boss.cuu_tieu_kiep_long", "tmb.boss.bat_diet_huyet_ma_ton", "tmb.boss.thai_so_phap_tac_de",
    "tmb.boss.immortal.test", "tmb.boss.divine.test"
]

var battle: MapBattleV2
var bridge: CombatLabEventBridge
var arena: Control
var school_option: OptionButton
var generation_option: OptionButton
var branch_option: OptionButton
var lineage_option: OptionButton
var party_count: SpinBox
var enemy_option: OptionButton
var boss_option: OptionButton
var zoom_option: OptionButton
var active_slots: Array[OptionButton] = []
var ultimate_slot: OptionButton
var skill_preview_option: OptionButton
var state_label: Label
var roster_label: Label
var stats_label: Label
var events_label: Label
var mode_label: Label
var event_log: Array[String] = []
var auto_run := true
var accumulator := 0.0
var frame_accumulator := 0.0
var hud_accumulator := 0.0
var fixture_states: Array[SimulationState] = []
var fixture_actors: Array[Dictionary] = []

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    bridge = EventBridgeScript.new()
    _build_ui()
    _refresh_branches()
    _refresh_skills()
    _start_battle()
    _select_zoom(2.0)
    var requested_zoom := float(OS.get_environment("TMB_COMBAT_LAB_ZOOM"))
    if requested_zoom in [1.0, 2.0, 4.0, 6.0]:
        _select_zoom(requested_zoom)
    var screenshot := OS.get_environment("TMB_COMBAT_LAB_SCREENSHOT")
    if not screenshot.is_empty():
        get_tree().create_timer(4.0).timeout.connect(func(): _save_screenshot(screenshot))

func _process(delta: float) -> void:
    if battle != null and auto_run and battle.active:
        accumulator += minf(delta, 0.1)
        while accumulator >= MapBattleV2.STEP_SECONDS:
            accumulator -= MapBattleV2.STEP_SECONDS
            _step_battle()
            if not battle.active: break
    # The actor rig animates at 24 Hz independently of the slower HUD.
    # Keep both visual and HUD rendering read-only to the battle authority.
    frame_accumulator += delta
    if frame_accumulator >= VISUAL_FRAME_INTERVAL:
        frame_accumulator = fmod(frame_accumulator, VISUAL_FRAME_INTERVAL)
        if arena != null:
            arena.queue_redraw()
    hud_accumulator += delta
    if hud_accumulator >= HUD_UPDATE_INTERVAL:
        hud_accumulator = fmod(hud_accumulator, HUD_UPDATE_INTERVAL)
        _refresh_hud()

func _build_ui() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var backdrop := ColorRect.new()
    backdrop.color = Color("0b0b13")
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 18)
    margin.add_theme_constant_override("margin_top", 14)
    margin.add_theme_constant_override("margin_right", 18)
    margin.add_theme_constant_override("margin_bottom", 14)
    add_child(margin)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
    margin.add_child(root)
    var header := HBoxContainer.new()
    header.custom_minimum_size.y = 52
    root.add_child(header)
    var title := Label.new()
    title.text = "TÔNG MÔN BÁ ĐẠO   /   COMBAT LAB"
    title.add_theme_font_size_override("font_size", 23)
    title.add_theme_color_override("font_color", Color("eee4fa"))
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var badge := Label.new()
    badge.text = "LAB_ONLY  ·  KHÔNG GHI SAVE / THƯỞNG"
    badge.add_theme_font_size_override("font_size", 12)
    badge.add_theme_color_override("font_color", Color("c19cff"))
    header.add_child(badge)
    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 12)
    root.add_child(body)
    var left_panel := _make_panel(286)
    body.add_child(left_panel)
    var controls_scroll := ScrollContainer.new()
    controls_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    controls_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left_panel.add_child(controls_scroll)
    var controls := VBoxContainer.new()
    controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_theme_constant_override("separation", 6)
    controls_scroll.add_child(controls)
    _label(controls, "ĐỘI HÌNH THỬ NGHIỆM", 14, Color("c9b9dd"))
    school_option = _option(controls, "Trường phái", SCHOOL_LABELS)
    school_option.item_selected.connect(func(_i: int): _refresh_branches())
    generation_option = _option(controls, "Cảnh giới kỹ năng", GENERATION_LABELS)
    generation_option.item_selected.connect(func(_i: int): _refresh_skills())
    branch_option = OptionButton.new()
    branch_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(branch_option)
    branch_option.item_selected.connect(func(_i: int): _refresh_skills())
    lineage_option = _option(controls, "Truyền thừa", ["A", "B"])
    lineage_option.item_selected.connect(func(_i: int): _refresh_skills())
    var count_row := HBoxContainer.new()
    controls.add_child(count_row)
    var count_label := _label(count_row, "Số đệ tử", 13)
    count_label.custom_minimum_size.x = 96
    party_count = SpinBox.new()
    party_count.min_value = 1
    party_count.max_value = 6
    party_count.step = 1
    party_count.value = 3
    party_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    count_row.add_child(party_count)
    _label(controls, "4 KỸ NĂNG CHỦ ĐỘNG", 12, Color("b9a9cf"))
    for index in range(4):
        var slot := OptionButton.new()
        slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        slot.tooltip_text = "Kỹ năng chủ động %d/4" % (index + 1)
        controls.add_child(slot)
        slot.item_selected.connect(func(_i: int): _refresh_preview_choice())
        active_slots.append(slot)
    _label(controls, "TUYỆT KỸ", 12, Color("b9a9cf"))
    ultimate_slot = OptionButton.new()
    ultimate_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(ultimate_slot)
    ultimate_slot.item_selected.connect(func(_i: int): _refresh_preview_choice())
    _label(controls, "THỬ TỪNG CHIÊU · DỮ LIỆU THẬT", 12, Color("c4b3e1"))
    skill_preview_option = OptionButton.new()
    skill_preview_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(skill_preview_option)
    var cast_preview_button := _button(controls, "THỬ CHIÊU (HOLD)", Color("4a6073"))
    cast_preview_button.tooltip_text = "Tạm dừng AUTO, thử đúng kỹ năng đã học/trang bị. Không bỏ qua hồi chiêu."
    cast_preview_button.pressed.connect(_preview_selected_skill)
    _label(controls, "ĐỐI THỦ", 14, Color("c9b9dd"))
    enemy_option = _option(controls, "Đối thủ", ["Thường · Hắc Lang", "Tinh Anh · Nham Giáp", "Boss V6.3 thật"])
    enemy_option.item_selected.connect(func(_i: int): _refresh_boss_visibility())
    boss_option = OptionButton.new()
    boss_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls.add_child(boss_option)
    _fill_bosses()
    _label(controls, "GÓC NHÌN", 12, Color("b9a9cf"))
    zoom_option = _option(controls, "Zoom", ["1×", "2×", "4×", "6×"])
    zoom_option.item_selected.connect(func(index: int):
        var factors := [1.0, 2.0, 4.0, 6.0]
        if arena != null: arena.call("set_zoom", factors[index])
    )
    _label(controls, "AUTO chạy từng tick 0,25 giây. HOLD đóng băng mô phỏng; STEP tiến đúng một tick.", 11, Color("9e93ae"))
    _refresh_boss_visibility()

    var center_column := VBoxContainer.new()
    center_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
    center_column.add_theme_constant_override("separation", 8)
    body.add_child(center_column)
    arena = Control.new()
    arena.set_script(ArenaScript)
    arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    arena.size_flags_vertical = Control.SIZE_FILL
    arena.custom_minimum_size = Vector2(630, 380)
    center_column.add_child(arena)
    var buttons := HBoxContainer.new()
    buttons.add_theme_constant_override("separation", 8)
    center_column.add_child(buttons)
    var start_button := _button(buttons, "TÁI TẠO TRẬN", Color("674a91"))
    start_button.pressed.connect(_start_battle)
    var step_button := _button(buttons, "STEP · 0,25s", Color("3a384b"))
    step_button.pressed.connect(func(): _step_battle())
    var auto_button := _button(buttons, "AUTO", Color("4d7b5e"))
    auto_button.pressed.connect(func(): _set_auto(true))
    var hold_button := _button(buttons, "HOLD", Color("7d5263"))
    hold_button.pressed.connect(func(): _set_auto(false))
    state_label = Label.new()
    state_label.text = "ĐANG CHUẨN BỊ"
    state_label.add_theme_color_override("font_color", Color("d7cce5"))
    state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    buttons.add_child(state_label)

    var right_panel := _make_panel(294)
    body.add_child(right_panel)
    var right := VBoxContainer.new()
    right.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right.add_theme_constant_override("separation", 7)
    right_panel.add_child(right)
    mode_label = _label(right, "MÔ PHỎNG V6.3 · LAB_ONLY", 12, Color("bd9fff"))
    _label(right, "ĐỘI HÌNH / HP", 14, Color("d8cce9"))
    roster_label = _label(right, "", 12, Color("e5ddeb"))
    roster_label.custom_minimum_size.y = 155
    var sep := HSeparator.new(); right.add_child(sep)
    _label(right, "STAT BREAKDOWN · CONSUMER V2", 13, Color("d8cce9"))
    stats_label = _label(right, "", 11, Color("b9aec7"))
    stats_label.custom_minimum_size.y = 118
    var sep2 := HSeparator.new(); right.add_child(sep2)
    _label(right, "SỰ KIỆN CHIẾN ĐẤU", 13, Color("d8cce9"))
    events_label = _label(right, "", 11, Color("c8bed5"))
    events_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    events_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _apply_theme()

func _make_panel(width: float) -> PanelContainer:
    var panel := PanelContainer.new()
    panel.custom_minimum_size.x = width
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var style := StyleBoxFlat.new()
    style.bg_color = Color("14131e")
    style.border_color = Color("393149")
    style.set_border_width_all(1)
    style.set_corner_radius_all(8)
    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    panel.add_theme_stylebox_override("panel", style)
    return panel

func _label(parent: Node, value: String, font_size: int = 12, color: Color = Color("e5ddeb")) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    parent.add_child(label)
    return label

func _option(parent: Node, _caption: String, labels: Array) -> OptionButton:
    var option := OptionButton.new()
    option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for index in range(labels.size()): option.add_item(str(labels[index]), index)
    parent.add_child(option)
    return option

func _button(parent: Node, text_value: String, color: Color) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(96, 38)
    button.add_theme_color_override("font_color", Color("f3edf8"))
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.set_corner_radius_all(5)
    style.content_margin_left = 9
    style.content_margin_right = 9
    button.add_theme_stylebox_override("normal", style)
    parent.add_child(button)
    return button

func _apply_theme() -> void:
    var theme := Theme.new()
    theme.default_font_size = 13
    theme.set_color("font_color", "Label", Color("e5ddeb"))
    theme.set_color("font_color", "Button", Color("f3edf8"))
    theme.set_color("font_color", "OptionButton", Color("e5ddeb"))
    theme.set_color("font_color", "LineEdit", Color("e5ddeb"))
    theme.set_stylebox("normal", "OptionButton", _field_style())
    theme.set_stylebox("normal", "SpinBox", _field_style())
    theme.set_stylebox("normal", "Button", _field_style())
    theme.set_stylebox("focus", "OptionButton", _field_style(true))
    theme.set_stylebox("focus", "Button", _field_style(true))
    self.theme = theme

func _field_style(focused: bool = false) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color("211d2d") if not focused else Color("302645")
    style.border_color = Color("5c4b79")
    style.set_border_width_all(1)
    style.set_corner_radius_all(4)
    style.content_margin_left = 8
    style.content_margin_right = 8
    style.content_margin_top = 5
    style.content_margin_bottom = 5
    return style

func _school() -> String:
    return SCHOOL_KEYS[school_option.selected]

func _generation() -> String:
    return GENERATION_KEYS[generation_option.selected]

func _branch() -> String:
    if branch_option.item_count == 0: return ""
    return str(branch_option.get_item_metadata(branch_option.selected))

func _lineage() -> String:
    return "a" if lineage_option.selected == 0 else "b"

func _refresh_branches() -> void:
    if branch_option == null: return
    branch_option.clear()
    var rows := CombatLabRosterAdapter.school_branches(_school())
    for row in rows: branch_option.add_item(str(row.get("name", row.get("id", ""))))
    for index in range(rows.size()): branch_option.set_item_metadata(index, str(rows[index].get("id", "")))
    if rows.size() > 0: branch_option.select(0)
    _refresh_skills()

func _refresh_skills() -> void:
    if school_option == null or branch_option == null: return
    var school := _school()
    var generation := _generation()
    var branch := _branch()
    var lineage := _lineage()
    var active := CombatLabRosterAdapter.skill_options(school, generation, "active", branch, lineage)
    var ultimate := CombatLabRosterAdapter.skill_options(school, generation, "ultimate", branch, lineage)
    for index in range(active_slots.size()):
        _fill_skill_option(active_slots[index], active, mini(index, maxi(active.size() - 1, 0)))
        active_slots[index].disabled = active.is_empty()
    _fill_skill_option(ultimate_slot, ultimate, 0)
    ultimate_slot.disabled = ultimate.is_empty()
    _refresh_preview_choice()

func _refresh_preview_choice() -> void:
    if skill_preview_option == null:
        return
    var previous_id := ""
    if skill_preview_option.item_count > 0 and skill_preview_option.selected >= 0:
        previous_id = str(skill_preview_option.get_item_metadata(skill_preview_option.selected))
    skill_preview_option.clear()
    var seen := {}
    var equipped_options: Array = []
    for action_slot in active_slots:
        equipped_options.append(action_slot)
    equipped_options.append(ultimate_slot)
    for slot in equipped_options:
        if slot == null or slot.item_count == 0 or slot.selected < 0:
            continue
        var skill_id := str(slot.get_item_metadata(slot.selected))
        if skill_id.is_empty() or seen.has(skill_id):
            continue
        seen[skill_id] = true
        var definition: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
        skill_preview_option.add_item(str(definition.get("name", skill_id)))
        skill_preview_option.set_item_metadata(skill_preview_option.item_count - 1, skill_id)
    if skill_preview_option.item_count == 0:
        return
    var selected := 0
    for index in range(skill_preview_option.item_count):
        if str(skill_preview_option.get_item_metadata(index)) == previous_id:
            selected = index
            break
    skill_preview_option.select(selected)

func _fill_skill_option(option: OptionButton, rows: Array[Dictionary], selected_index: int) -> void:
    option.clear()
    for row in rows:
        option.add_item(str(row.get("name", row.get("id", ""))))
        option.set_item_metadata(option.item_count - 1, str(row.get("id", "")))
    if option.item_count > 0: option.select(clampi(selected_index, 0, option.item_count - 1))

func _fill_bosses() -> void:
    boss_option.clear()
    for id in BOSS_IDS:
        var definition := V63HumanSkillCombatSystem.boss_definition(id)
        if definition.is_empty(): continue
        boss_option.add_item(str(definition.get("name", id)))
        boss_option.set_item_metadata(boss_option.item_count - 1, id)
    if boss_option.item_count > 0: boss_option.select(0)

func _refresh_boss_visibility() -> void:
    if boss_option != null: boss_option.visible = enemy_option.selected == 2

func _selected_loadout() -> Array[String]:
    var result: Array[String] = []
    var basics := CombatLabRosterAdapter.skill_options(_school(), _generation(), "basic", _branch(), _lineage())
    var mobility := CombatLabRosterAdapter.skill_options(_school(), _generation(), "mobility", _branch(), _lineage())
    var passives := CombatLabRosterAdapter.skill_options(_school(), _generation(), "passive", _branch(), _lineage())
    if basics.is_empty() or mobility.is_empty() or passives.size() < 5 or ultimate_slot.item_count == 0: return result
    result.append(str(basics[0].id))
    result.append(str(mobility[0].id))
    for slot in active_slots:
        if slot.item_count == 0: return []
        result.append(str(slot.get_item_metadata(slot.selected)))
    result.append(str(ultimate_slot.get_item_metadata(ultimate_slot.selected)))
    for index in range(5): result.append(str(passives[index].id))
    return result

func _preview_selected_skill() -> void:
    # Lab-only controlled cast, real skill engine. No new damage authority and
    # no cooldown override. In normal PvE this button does not exist.
    if battle == null or not battle.active or skill_preview_option == null:
        return
    if skill_preview_option.item_count == 0 or skill_preview_option.selected < 0:
        return
    _set_auto(false)
    var skill_id := str(skill_preview_option.get_item_metadata(skill_preview_option.selected))
    var disciple_ids: Array = []
    var enemy_ids: Array = []
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        if float(actor.get("hp", 0.0)) <= 0.0:
            continue
        if str(actor.get("side", "")) == "disciple":
            disciple_ids.append(raw_id)
        elif str(actor.get("side", "")) == "monster":
            enemy_ids.append(raw_id)
    disciple_ids.sort()
    enemy_ids.sort()
    if disciple_ids.is_empty() or enemy_ids.is_empty():
        _set_error("Không có đệ tử/đối thủ còn sống để thử chiêu")
        return
    var caster: Dictionary = battle.actors[disciple_ids[0]]
    var target: Dictionary = battle.actors[enemy_ids[0]]
    var old_loadout: Array = caster.get("v63_skill_loadout", []).duplicate(true)
    if not old_loadout.has(skill_id):
        _set_error("Kỹ năng chưa được trang bị trong đội hình Lab")
        return
    if not caster.get("v63_pending_cast", {}).is_empty():
        _set_error("Đệ tử đang thi triển chiêu trước")
        return
    var ready: Dictionary = caster.get("v63_skill_ready", {})
    if battle.now < float(ready.get(skill_id, 0.0)):
        _set_error("Kỹ năng đang hồi chiêu: %.1fs" % (float(ready.get(skill_id, 0.0)) - battle.now))
        return
    # Isolate only the selected skill. If it cannot be cast, no other
    # equipped skill may silently substitute for the requested preview.
    caster["v63_skill_loadout"] = [skill_id]
    var cast_started := V63HumanSkillCombatSystem.try_cast(battle, caster, target)
    caster["v63_skill_loadout"] = old_loadout
    _consume_events()
    _refresh_hud()
    if not cast_started:
        _set_error("Chiêu không hợp lệ ở khoảng cách/đối tượng hoặc trạng thái hiện tại")
        return
    state_label.text = "THỬ CHIÊU · " + str(V63HumanSkillCombatSystem.skill_definition(skill_id).get("name", skill_id)) + " · STEP để phóng"

func _start_battle() -> void:
    if school_option == null: return
    var ids := _selected_loadout()
    var setup := CombatLabRosterAdapter.build_party(int(party_count.value), _school(), _generation(), _branch(), _lineage(), ids)
    if not bool(setup.get("ok", false)):
        _set_error("Loadout không hợp lệ: " + str(setup.get("errors", setup.get("detail", setup.get("reason", "")))))
        return
    var enemy_kind: String = str(["normal", "elite", "boss"][enemy_option.selected])
    var boss_id := str(boss_option.get_item_metadata(boss_option.selected)) if boss_option.item_count > 0 else ""
    var enemy := CombatLabRosterAdapter.build_enemy(enemy_kind, boss_id, "lab_enemy")
    if not bool(enemy.get("ok", false)):
        _set_error("Không tạo được đối thủ từ catalog thật: " + str(enemy.get("detail", enemy.get("reason", ""))))
        return
    var monster: Dictionary = enemy.actor
    if enemy_kind != "boss": monster["position"] = Vector2(26, 10)
    var monsters: Array = [monster]
    var candidate := MapBattleV2.new(515151)
    var ready := candidate.setup("combat_lab_preview", setup.party, monsters, false)
    if not bool(ready.get("ok", false)):
        _set_error("MapBattleV2 từ chối fixture: " + str(ready.get("reason", "")))
        return
    battle = candidate
    fixture_states = setup.states
    fixture_actors = setup.actors
    bridge.reset(battle)
    event_log.clear()
    auto_run = true
    accumulator = 0.0
    arena.call("set_battle", battle, _school())
    arena.call("set_status", "LAB_ONLY  ·  " + GENERATION_LABELS[generation_option.selected] + " · " + SCHOOL_LABELS[school_option.selected])
    _consume_events()
    _refresh_hud()

func _set_error(message: String) -> void:
    state_label.text = "LỖI FIXTURE"
    if events_label != null: events_label.text = message
    if arena != null: arena.call("set_status", "LAB_ONLY  ·  cấu hình chưa hợp lệ")

func _step_battle() -> void:
    if battle == null or not battle.active: return
    var result := battle.step(false)
    if not bool(result.get("ok", false)):
        _set_error("MapBattleV2.step thất bại: " + str(result.get("reason", "")))
    _consume_events()
    _refresh_hud()
    if not battle.active: auto_run = false

func _consume_events() -> void:
    if battle == null or arena == null: return
    var rows := bridge.poll(battle)
    arena.call("consume_events", rows)
    for event in rows:
        event_log.append("%05.1fs  %s" % [float(event.get("time", 0.0)), str(event.get("type", "event"))])
    if event_log.size() > 8: event_log = event_log.slice(event_log.size() - 8)

func _refresh_hud() -> void:
    if battle == null:
        return
    state_label.text = "%s  ·  %.1fs  ·  %s" % ["AUTO" if auto_run else "HOLD", battle.now, battle.outcome]
    mode_label.text = "V6.3  ·  %d ĐỆ TỬ  ·  %s" % [int(party_count.value), "ĐANG ĐÁNH" if battle.active else "KẾT THÚC"]
    var roster := PackedStringArray()
    for id in battle.actors.keys():
        var actor: Dictionary = battle.actors[id]
        var current := float(actor.get("hp", 0.0))
        var maximum := float(actor.get("max_hp", 1.0))
        var tag := "ĐT" if str(actor.get("side", "")) == "disciple" else ("BOSS" if str(actor.get("tier", "")) == "boss" else "QUÁI")
        roster.append("%s  %s  %d / %d HP" % [tag, str(id).replace("lab_disciple_", "#"), roundi(current), roundi(maximum)])
    roster_label.text = "\n".join(roster)
    if not fixture_actors.is_empty():
        var stats := CombatLabRosterAdapter.stat_breakdown(fixture_actors[0])
        var fixture_id := str(fixture_actors[0].get("id", ""))
        var live_actor: Dictionary = battle.actors.get(fixture_id, {})
        var cast_state := "—"
        var pending: Dictionary = live_actor.get("v63_pending_cast", {})
        if not pending.is_empty():
            var pending_id := str(pending.get("v63_skill_id", pending.get("skill_id", pending.get("id", ""))))
            var definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(pending_id, {})
            var skill_name := str(definition.get("name", pending_id))
            cast_state = "%s · %.1fs" % [skill_name, maxf(0.0, float(pending.get("ready", battle.now)) - battle.now)]
        var cooldown_count := 0
        var ready: Dictionary = live_actor.get("v63_skill_ready", {})
        for skill_id in ready:
            if float(ready[skill_id]) > battle.now: cooldown_count += 1
        stats_label.text = "HP %s  ·  ATK %s  ·  DEF %s\nBạo kích %.1f%%  ·  Hút sinh lực %.1f%%\nTốc niệm %.2f  ·  Hồi chiêu %.2f\nHiệu ứng %.2f\nĐang niệm: %s\nKỹ năng hồi chiêu: %d" % [
            _fmt(float(stats.max_hp)), _fmt(float(stats.attack)), _fmt(float(stats.defense)),
            float(stats.crit_chance) * 100.0, float(stats.lifesteal) * 100.0,
            float(stats.cast_speed), float(stats.cooldown_recovery), float(stats.effect_hit), cast_state, cooldown_count]
    events_label.text = "\n".join(event_log)

func _fmt(value: float) -> String:
    return str(roundi(value))

func _set_auto(value: bool) -> void:
    auto_run = value
    if value and battle != null and not battle.active: return
    _refresh_hud()

func _select_zoom(factor: float) -> void:
    var factors := [1.0, 2.0, 4.0, 6.0]
    var index := factors.find(factor)
    if index >= 0 and zoom_option != null:
        zoom_option.select(index)
        arena.call("set_zoom", factor)

func _save_screenshot(path: String) -> void:
    var image := get_viewport().get_texture().get_image()
    if image.is_empty(): return
    var absolute_path := ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
    var directory := absolute_path.get_base_dir()
    DirAccess.make_dir_recursive_absolute(directory)
    var error := image.save_png(absolute_path)
    if error == OK:
        print("COMBAT_LAB_SCREENSHOT=" + absolute_path)
        get_tree().quit()
    else: push_error("combat_lab screenshot save failed: %s" % error)
