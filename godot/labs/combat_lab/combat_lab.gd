extends Control

const ArenaScript = preload("res://labs/combat_lab/combat_lab_arena.gd")
const EventBridgeScript = preload("res://labs/combat_lab/combat_lab_event_bridge.gd")
const PoisonArtBrief = preload("res://labs/combat_lab/combat_lab_poison_skill_art_brief.gd")
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
var encounter_option: OptionButton
var zoom_option: OptionButton
var active_slots: Array[OptionButton] = []
var ultimate_slot: OptionButton
var skill_preview_option: OptionButton
var advanced_loadout: VBoxContainer
var advanced_loadout_button: Button
var poison_catalog_heading: Label
var poison_catalog_option: OptionButton
var poison_skill_detail_label: Label
var cinematic_skill_title: Label
var cinematic_mechanics: Label
var poison_load_button: Button
var poison_boss_preset_button: Button
var poison_aoe_preset_button: Button
var poison_current_skill_label: Label
var poison_stack_label: Label
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
var selected_catalog_skill_id := ""
var last_combat_skill_id := ""
var passive_override_id := ""
var basic_override_id := ""
var mobility_override_id := ""

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    bridge = EventBridgeScript.new()
    _build_ui()
    # Combat Lab opens on the requested showcase. All three enemy tiers and
    # party sizes remain selectable from the same Lab controls.
    school_option.select(SCHOOL_KEYS.find("poison"))
    party_count.value = 6
    enemy_option.select(2)
    _refresh_boss_visibility()
    _refresh_branches()
    _refresh_skills()
    _apply_capture_preset()
    _start_battle()
    _select_zoom(2.0)
    var requested_zoom := float(OS.get_environment("TMB_COMBAT_LAB_ZOOM"))
    if requested_zoom in [1.0, 2.0, 4.0, 6.0]:
        _select_zoom(requested_zoom)
    if OS.get_environment("TMB_POISON_V4_CINEMATIC") == "1":
        _apply_v4_cinematic_layout()
    var screenshot := OS.get_environment("TMB_COMBAT_LAB_SCREENSHOT")
    if not screenshot.is_empty():
        var requested_delay := OS.get_environment("TMB_COMBAT_LAB_CAPTURE_DELAY")
        var screenshot_delay := clampf(requested_delay.to_float(), 0.25, 12.0) if not requested_delay.is_empty() else 4.0
        get_tree().create_timer(screenshot_delay).timeout.connect(func(): _save_screenshot(screenshot))

# Only Movie Maker / explicitly requested LAB showcase. Enlarges the true
# combat viewport instead of recording a 630px battle in a 1280px black UI.
# No simulation, skill or SaveService mutations; normal Lab retains controls.
func _apply_v4_cinematic_layout() -> void:
    if arena == null:
        return
    var center_column := arena.get_parent() as VBoxContainer
    if center_column == null:
        return
    var body := center_column.get_parent() as HBoxContainer
    if body == null:
        return
    for panel in body.get_children():
        if panel != center_column:
            panel.visible = false
    for panel in center_column.get_children():
        if panel != arena:
            panel.visible = false
    arena.custom_minimum_size = Vector2.ZERO
    arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
    arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    # Group shots need bigger readable actors on the 1280x720 canvas.
    # This camera-only fit is explicitly opt-in; normal Lab and Save are
    # untouched, including the game's actual 1x scale.
    var four_vs_eight := encounter_option != null and encounter_option.selected == 4
    arena.call("set_v4_swarm_cinematic", four_vs_eight)
    var root_column := body.get_parent() as VBoxContainer
    if root_column != null:
        for panel in root_column.get_children():
            if panel != body:
                panel.visible = false
        var margin := root_column.get_parent() as MarginContainer
        if margin != null:
            for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
                margin.add_theme_constant_override(side, 9)
    cinematic_skill_title = Label.new()
    cinematic_skill_title.position = Vector2(22, 19)
    cinematic_skill_title.add_theme_font_size_override("font_size", 24)
    cinematic_skill_title.add_theme_color_override("font_color", Color("f5e7bf"))
    cinematic_skill_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    arena.add_child(cinematic_skill_title)
    cinematic_mechanics = Label.new()
    cinematic_mechanics.position = Vector2(23, 54)
    cinematic_mechanics.add_theme_font_size_override("font_size", 14)
    cinematic_mechanics.add_theme_color_override("font_color", Color("c5f3db"))
    cinematic_mechanics.mouse_filter = Control.MOUSE_FILTER_IGNORE
    arena.add_child(cinematic_mechanics)
    _refresh_v4_cinematic_labels()
    var note := Label.new()
    note.text = "GODOT 4.7.2 · V6.3 LIVE EVENTS · VFX V4 LAB ONLY · KHÔNG LƯU SAVE" + (" · 1x FILM LENS = 1.65x" if four_vs_eight else "")
    note.position = Vector2(23, 79)
    note.add_theme_font_size_override("font_size", 11)
    note.add_theme_color_override("font_color", Color("9288b1"))
    note.mouse_filter = Control.MOUSE_FILTER_IGNORE
    arena.add_child(note)

func _refresh_v4_cinematic_labels() -> void:
    if cinematic_skill_title == null or cinematic_mechanics == null:
        return
    var definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(selected_catalog_skill_id, {})
    cinematic_skill_title.text = str(definition.get("name", "ĐỘC TU · TRẬN THỬ"))
    cinematic_mechanics.text = PoisonArtBrief.mechanic(definition) + " · " + PoisonArtBrief.geometry(definition)

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
            var display_seconds := battle.now if battle != null else 0.0
            if battle != null and battle.active:
                # HOLD retains the last partial presentation time; no rewind.
                display_seconds += accumulator
            arena.call("set_visual_time", display_seconds)
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
    root.add_theme_constant_override("separation", 8)
    margin.add_child(root)
    var header := HBoxContainer.new()
    header.custom_minimum_size.y = 46
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
    var left_panel := _make_panel(300)
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
    advanced_loadout_button = _button(controls, "LOADOUT CHI TIẾT  ▸", Color("30283b"))
    advanced_loadout_button.pressed.connect(_toggle_advanced_loadout)
    advanced_loadout = VBoxContainer.new()
    advanced_loadout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    advanced_loadout.add_theme_constant_override("separation", 5)
    advanced_loadout.visible = false
    controls.add_child(advanced_loadout)
    _label(advanced_loadout, "4 KỸ NĂNG CHỦ ĐỘNG", 12, Color("b9a9cf"))
    for index in range(4):
        var slot := OptionButton.new()
        slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        slot.tooltip_text = "Kỹ năng chủ động %d/4" % (index + 1)
        advanced_loadout.add_child(slot)
        slot.item_selected.connect(func(_i: int): _refresh_preview_choice())
        active_slots.append(slot)
    _label(advanced_loadout, "TUYỆT KỸ", 12, Color("b9a9cf"))
    ultimate_slot = OptionButton.new()
    ultimate_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    advanced_loadout.add_child(ultimate_slot)
    ultimate_slot.item_selected.connect(func(_i: int): _refresh_preview_choice())
    _label(advanced_loadout, "THỬ TỪNG CHIÊU · DỮ LIỆU THẬT", 12, Color("c4b3e1"))
    skill_preview_option = OptionButton.new()
    skill_preview_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    advanced_loadout.add_child(skill_preview_option)
    skill_preview_option.item_selected.connect(_on_preview_skill_selected)
    var cast_preview_button := _button(advanced_loadout, "THỬ CHIÊU (HOLD)", Color("4a6073"))
    cast_preview_button.tooltip_text = "Tạm dừng AUTO, thử đúng kỹ năng đã học/trang bị. Không bỏ qua hồi chiêu."
    cast_preview_button.pressed.connect(_preview_selected_skill)
    poison_catalog_heading = _label(controls, "DANH MỤC ĐỘC TU · CẢNH GIỚI / NHÁNH", 12, Color("c4b3e1"))
    poison_catalog_option = OptionButton.new()
    poison_catalog_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    poison_catalog_option.item_selected.connect(_on_poison_catalog_selected)
    controls.add_child(poison_catalog_option)
    poison_skill_detail_label = _label(controls, "Chọn skill để xem mô tả và trạng thái hỗ trợ.", 11, Color("b9e6b1"))
    poison_load_button = _button(controls, "NẠP SKILL & TẠO LẠI TRẬN", Color("476a4f"))
    poison_load_button.tooltip_text = "Chỉ nạp slot mà V6.3 cho phép; nội tại chưa có slot loadout Lab sẽ chỉ hiển thị."
    poison_load_button.pressed.connect(_load_selected_poison_skill)
    poison_aoe_preset_button = _button(controls, "ĐỘC CHÂM · QUẦN CÔNG 3/4", Color("557047"))
    poison_aoe_preset_button.pressed.connect(_apply_poison_aoe_preset)
    var vfx_mode_button := _button(controls, "VFX V4 · " + ("BẬT" if OS.get_environment("TMB_POISON_V4_PREVIEW") == "1" else "TẮT"), Color("594878"))
    vfx_mode_button.tooltip_text = "Bật/tắt V4 chỉ trong Combat Lab; hiệu ứng V3 và Save không bị thay đổi."
    vfx_mode_button.pressed.connect(func():
        if arena == null: return
        var next_mode := not bool(arena.get("v4_preview_enabled"))
        arena.call("set_v4_preview_enabled", next_mode)
        vfx_mode_button.text = "VFX V4 · " + ("BẬT" if next_mode else "TẮT")
    )
    var v8_mode_button := _button(controls,
        "VFX V8 · RẮN RÕ HÌNH · " + ("BẬT" if OS.get_environment("TMB_POISON_V8_PREVIEW") == "1" else "TẮT"),
        Color("365e62"))
    v8_mode_button.tooltip_text = "Chỉ thay hình rắn Cổ Độc của skill thật; không sửa sát thương, tầm, mục tiêu, cooldown hay Save."
    v8_mode_button.pressed.connect(func():
        if arena == null: return
        var next_v8 := not bool(arena.get("v8_preview_enabled"))
        arena.call("set_v8_preview_enabled", next_v8)
        v8_mode_button.text = "VFX V8 · RẮN RÕ HÌNH · " + ("BẬT" if next_v8 else "TẮT")
        vfx_mode_button.text = "VFX V4 · " + ("BẬT" if bool(arena.get("v4_preview_enabled")) else "TẮT")
    )
    var v9_mode_button := _button(controls,
        "VFX V9 · ÁNH SÁNG THẬT · " + ("BẬT" if OS.get_environment("TMB_POISON_V9_LIGHT") == "1" else "TẮT"),
        Color("2e6374"))
    v9_mode_button.tooltip_text = "Godot additive shader + dải linh khí động; không dùng ảnh rắn/kiếm, không thay logic hit/Save."
    v9_mode_button.pressed.connect(func():
        if arena == null: return
        var next_light := arena.get("v9_preview_enabled") != true
        arena.call("set_v9_preview_enabled", next_light)
        v9_mode_button.text = "VFX V9 · ÁNH SÁNG THẬT · " + ("BẬT" if next_light else "TẮT")
        v8_mode_button.text = "VFX V8 · RẮN RÕ HÌNH · " + ("BẬT" if bool(arena.get("v8_preview_enabled")) else "TẮT")
    )
    var swarm_button := _button(controls, "4 ĐỘC TU · VÂY 8 QUÁI · AOE THẬT", Color("395e58"))
    var swarm_skill: Dictionary = V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_03.human")
    swarm_button.tooltip_text = "4 đệ tử ở 4 góc; Bách Độc Tán Châm: bán kính %.1f ô, tối đa %d mục tiêu. Dùng kỹ năng V6.3 thật, không phát sát thương giả." % [float(swarm_skill.get("radius", 0.0)), int(swarm_skill.get("target_limit", 0))]
    swarm_button.pressed.connect(_apply_poison_swarm_preset)
    poison_boss_preset_button = _button(controls, "ĐỘC TU · 6 vs BOSS + QUÁI", Color("5d3e75"))
    poison_boss_preset_button.pressed.connect(_apply_poison_boss_preset)
    _label(controls, "ĐỐI THỦ", 14, Color("c9b9dd"))
    enemy_option = _option(controls, "Đối thủ", ["Thường · Hắc Lang", "Tinh Anh · Nham Giáp", "Boss V6.3 thật"])
    enemy_option.item_selected.connect(func(_i: int): _refresh_boss_visibility())
    _label(controls, "BỐ CỤC MỤC TIÊU · LAB_ONLY", 12, Color("c4b3e1"))
    encounter_option = _option(controls, "Bố cục", [
        "Đơn mục tiêu", "Độc Châm · 3 trong vùng + 1 ngoài",
        "AOE · 5 trong vùng + 1 ngoài", "Boss V6.3 + 3 quái phụ",
        "4 Độc Tu · 6 quái trong + 2 quái ngoài vùng"])
    encounter_option.select(0)
    encounter_option.item_selected.connect(_on_encounter_selected)
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
    arena.custom_minimum_size = Vector2(630, 420)
    center_column.add_child(arena)
    var buttons := HBoxContainer.new()
    buttons.add_theme_constant_override("separation", 8)
    center_column.add_child(buttons)
    var start_button := _button(buttons, "TÁI TẠO TRẬN", Color("674a91"))
    start_button.pressed.connect(_start_battle)
    var step_button := _button(buttons, "STEP · 0,25s", Color("3a384b"))
    step_button.pressed.connect(func():
        _set_auto(false)
        _step_battle())
    var auto_button := _button(buttons, "AUTO", Color("4d7b5e"))
    auto_button.pressed.connect(func(): _set_auto(true))
    var hold_button := _button(buttons, "HOLD", Color("7d5263"))
    hold_button.pressed.connect(func(): _set_auto(false))
    state_label = Label.new()
    state_label.text = "ĐANG CHUẨN BỊ"
    state_label.add_theme_color_override("font_color", Color("d7cce5"))
    state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    buttons.add_child(state_label)

    var hud_panel := _make_panel(0)
    hud_panel.custom_minimum_size.y = 100
    hud_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center_column.add_child(hud_panel)
    var hud := VBoxContainer.new()
    hud.add_theme_constant_override("separation", 2)
    hud_panel.add_child(hud)
    var hud_top := HBoxContainer.new()
    hud_top.add_theme_constant_override("separation", 10)
    hud.add_child(hud_top)
    mode_label = _label(hud_top, "V6.3 · LAB_ONLY", 11, Color("bd9fff"))
    roster_label = _label(hud, "", 11, Color("e5ddeb"))
    roster_label.custom_minimum_size.y = 20
    roster_label.clip_text = true
    roster_label.autowrap_mode = TextServer.AUTOWRAP_OFF
    roster_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    stats_label = _label(hud, "", 10, Color("b9aec7"))
    stats_label.clip_text = false
    poison_current_skill_label = _label(hud_top, "Skill: —", 11, Color("d3c2e4"))
    poison_current_skill_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    poison_current_skill_label.clip_text = true
    poison_current_skill_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    poison_stack_label = _label(hud_top, "Độc: 0", 11, Color("a5f28e"))
    poison_stack_label.custom_minimum_size.x = 140
    poison_stack_label.clip_text = true
    poison_stack_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    events_label = _label(hud, "", 9, Color("c8bed5"))
    events_label.clip_text = true
    events_label.autowrap_mode = TextServer.AUTOWRAP_OFF
    events_label.custom_minimum_size.y = 12
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

func _toggle_advanced_loadout() -> void:
    if advanced_loadout == null or advanced_loadout_button == null:
        return
    advanced_loadout.visible = not advanced_loadout.visible
    advanced_loadout_button.text = "LOADOUT CHI TIẾT  ▾" if advanced_loadout.visible else "LOADOUT CHI TIẾT  ▸"

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
    var previous_branch := _branch()
    branch_option.clear()
    var rows := CombatLabRosterAdapter.school_branches(_school())
    for row in rows: branch_option.add_item(str(row.get("name", row.get("id", ""))))
    for index in range(rows.size()): branch_option.set_item_metadata(index, str(rows[index].get("id", "")))
    if rows.size() > 0:
        if _school() != "poison":
            branch_option.select(0)
            _refresh_skills()
            return
        var selected_branch := previous_branch
        if selected_branch.is_empty() or not _branch_rows_have_id(rows, selected_branch):
            selected_branch = "doc_cham" if _school() == "poison" else str(rows[0].get("id", ""))
        var selected_index := 0
        for index in range(rows.size()):
            if str(rows[index].get("id", "")) == selected_branch:
                selected_index = index
                break
        branch_option.select(selected_index)
    _refresh_skills()

func _refresh_skills() -> void:
    if school_option == null or branch_option == null: return
    var school := _school()
    var generation := _generation()
    var branch := _branch()
    var lineage := _lineage()
    var active := CombatLabRosterAdapter.skill_options(school, generation, "active", branch, lineage)
    var ultimate := CombatLabRosterAdapter.skill_options(school, generation, "ultimate", branch, lineage)
    var basics := CombatLabRosterAdapter.skill_options(school, generation, "basic", branch, lineage)
    var mobility := CombatLabRosterAdapter.skill_options(school, generation, "mobility", branch, lineage)
    var passives := CombatLabRosterAdapter.skill_options(school, generation, "passive", branch, lineage)
    if not _rows_have_id(passives, passive_override_id): passive_override_id = ""
    if not _rows_have_id(basics, basic_override_id): basic_override_id = ""
    if not _rows_have_id(mobility, mobility_override_id): mobility_override_id = ""
    for index in range(active_slots.size()):
        _fill_skill_option(active_slots[index], active, mini(index, maxi(active.size() - 1, 0)))
        active_slots[index].disabled = active.is_empty()
    _fill_skill_option(ultimate_slot, ultimate, 0)
    ultimate_slot.disabled = ultimate.is_empty()
    _refresh_preview_choice()
    _refresh_poison_catalog()

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

func _refresh_poison_catalog() -> void:
    if poison_catalog_option == null:
        return
    var is_poison := _school() == "poison"
    poison_catalog_heading.visible = is_poison
    poison_catalog_option.visible = is_poison
    poison_skill_detail_label.visible = is_poison
    poison_load_button.visible = is_poison
    poison_boss_preset_button.visible = is_poison
    poison_aoe_preset_button.visible = is_poison
    if not is_poison:
        poison_catalog_option.clear()
        selected_catalog_skill_id = ""
        poison_skill_detail_label.text = ""
        return

    var previous_id := selected_catalog_skill_id
    if poison_catalog_option.item_count > 0 and poison_catalog_option.selected >= 0:
        previous_id = str(poison_catalog_option.get_item_metadata(poison_catalog_option.selected))
    poison_catalog_option.clear()
    var rows := _poison_catalog_rows()
    poison_catalog_heading.text = "DANH MỤC ĐỘC TU · %d SKILL · %s / %s" % [
        rows.size(), _generation_label(_generation()), _branch_label(_branch())]
    for row in rows:
        var slot := str(row.get("slot", "unknown"))
        var tier := str(row.get("generation", row.get("tier", "human")))
        var name := str(row.get("name", row.get("id", "")))
        var lineage := str(row.get("lineage", ""))
        var candidate_tag := " · CANDIDATE" if str(row.get("balance_status", "")) == "candidate" else ""
        var unavailable_tag := " · DESIGN-ONLY" if slot == "innate" and not bool(row.get("archivable", false)) else ""
        var lineage_tag := " · " + lineage.to_upper() if not lineage.is_empty() else ""
        var pending_tag := " · DESIGN_PENDING" if str(row.get("divine_rule_status", "")) == "DESIGN_PENDING" else ""
        poison_catalog_option.add_item("%s · %s · %s%s%s%s%s" % [
            _catalog_slot_label(slot), _generation_label(tier), name, lineage_tag, candidate_tag, unavailable_tag, pending_tag])
        poison_catalog_option.set_item_metadata(poison_catalog_option.item_count - 1, str(row.get("id", "")))
    if poison_catalog_option.item_count == 0:
        selected_catalog_skill_id = ""
        poison_skill_detail_label.text = "Catalog không có skill cho lựa chọn này."
        poison_load_button.disabled = true
        return
    var selected_index := 0
    for index in range(poison_catalog_option.item_count):
        if str(poison_catalog_option.get_item_metadata(index)) == previous_id:
            selected_index = index
            break
    poison_catalog_option.select(selected_index)
    selected_catalog_skill_id = str(poison_catalog_option.get_item_metadata(selected_index))
    _refresh_poison_skill_details()

func _poison_catalog_rows() -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var generation := _generation()
    var branch := _branch()
    var lineage := _lineage()
    for raw in CombatLabRosterAdapter.skill_definitions().values():
        if not (raw is Dictionary):
            continue
        var row: Dictionary = raw
        if str(row.get("school", "")) != "poison":
            continue
        if str(row.get("generation", row.get("tier", "human"))) != generation:
            continue
        var row_branch := str(row.get("branch", ""))
        if not row_branch.is_empty() and row_branch != branch:
            continue
        var row_lineage := str(row.get("lineage", ""))
        if generation in ["immortal", "divine"] and not row_lineage.is_empty() and row_lineage != lineage:
            continue
        rows.append(row.duplicate(true))
    rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        var a_slot := _catalog_slot_order(str(a.get("slot", "")))
        var b_slot := _catalog_slot_order(str(b.get("slot", "")))
        if a_slot != b_slot:
            return a_slot < b_slot
        var a_order := int(a.get("order", a.get("index", 0)))
        var b_order := int(b.get("order", b.get("index", 0)))
        if a_order != b_order:
            return a_order < b_order
        return str(a.get("id", "")) < str(b.get("id", ""))
    )
    return rows

func _catalog_slot_order(slot: String) -> int:
    var slots := ["basic", "mobility", "active", "ultimate", "passive", "innate"]
    var index := slots.find(slot)
    return index if index >= 0 else slots.size()

func _catalog_slot_label(slot: String) -> String:
    match slot:
        "basic": return "CƠ BẢN"
        "mobility": return "THÂN PHÁP"
        "active": return "CHỦ ĐỘNG"
        "ultimate": return "TUYỆT KỸ"
        "passive": return "BỊ ĐỘNG"
        "innate": return "NỘI TẠI"
    return slot.to_upper()

func _generation_label(generation: String) -> String:
    var index := GENERATION_KEYS.find(generation)
    return GENERATION_LABELS[index] if index >= 0 else generation

func _branch_label(branch: String) -> String:
    match branch:
        "doc_cham": return "Độc Châm"
        "co_doc": return "Cổ Độc"
        "duoc_doc": return "Dược Độc"
    return branch if not branch.is_empty() else "Chung"

func _rows_have_id(rows: Array[Dictionary], skill_id: String) -> bool:
    if skill_id.is_empty():
        return false
    for row in rows:
        if str(row.get("id", "")) == skill_id:
            return true
    return false

func _branch_rows_have_id(rows: Array[Dictionary], branch: String) -> bool:
    for row in rows:
        if str(row.get("id", "")) == branch:
            return true
    return false

func _on_poison_catalog_selected(index: int) -> void:
    if index < 0 or index >= poison_catalog_option.item_count:
        return
    selected_catalog_skill_id = str(poison_catalog_option.get_item_metadata(index))
    _refresh_poison_skill_details()

func _on_preview_skill_selected(index: int) -> void:
    if index < 0 or index >= skill_preview_option.item_count or _school() != "poison":
        return
    selected_catalog_skill_id = str(skill_preview_option.get_item_metadata(index))
    for catalog_index in range(poison_catalog_option.item_count):
        if str(poison_catalog_option.get_item_metadata(catalog_index)) == selected_catalog_skill_id:
            poison_catalog_option.select(catalog_index)
            break
    _refresh_poison_skill_details()

func _refresh_poison_skill_details() -> void:
    if poison_skill_detail_label == null or _school() != "poison":
        return
    var definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(selected_catalog_skill_id, {})
    if definition.is_empty():
        poison_skill_detail_label.text = "Chọn skill để xem mô tả và trạng thái hỗ trợ."
        poison_load_button.disabled = true
        return
    var slot := str(definition.get("slot", "unknown"))
    var tier := str(definition.get("generation", definition.get("tier", "human")))
    var branch := str(definition.get("branch", ""))
    var skill_name := str(definition.get("name", selected_catalog_skill_id))
    var effect := str(definition.get("effect", ""))
    var art: Dictionary = PoisonArtBrief.profile(selected_catalog_skill_id)
    var design_pending := str(definition.get("divine_rule_status", "")) == "DESIGN_PENDING"
    var runtime_tag := "V6.3 Lab · có thể nạp" if bool(definition.get("archivable", false)) or slot in ["basic", "mobility"] else "DESIGN-ONLY trong loadout Lab · chỉ duyệt"
    if design_pending:
        runtime_tag = "DESIGN_PENDING · chưa có cơ chế được duyệt · chỉ duyệt metadata"
    if str(definition.get("balance_status", "")) == "candidate":
        runtime_tag += " · CANDIDATE"
    var semantics := PoisonArtBrief.mechanic(definition)
    var footprint := PoisonArtBrief.geometry(definition)
    var casting := "Hồi chiêu %.1fs" % float(definition.get("cooldown", 0.0))
    if slot in ["active", "ultimate", "basic", "mobility"]:
        casting = "Niệm %.2fs · hồi %.1fs" % [
            float(definition.get("cast_time", 0.0)), float(definition.get("cooldown", 0.0))]
    var art_line := "Ý tưởng hình ảnh riêng: chưa có bản duyệt cho kỹ năng này."
    if not art.is_empty():
        art_line = str(art.get("vfx", ""))
    elif slot in ["innate", "passive"]:
        art_line = "Nội tại: không dựng hiệu ứng thi triển giả; chỉ dùng tín hiệu thật nếu có."
    var description := str(art.get("description", "")) if not art.is_empty() else ""
    poison_skill_detail_label.text = "%s\n%s · %s · %s\nTÁC DỤNG THẬT: %s\n%s · %s\n%s\nMỸ THUẬT: %s\n%s" % [
        skill_name, _generation_label(tier), _branch_label(branch),
        _catalog_slot_label(slot), semantics, footprint, casting,
        description if not description.is_empty() else "Mô tả tạo hình chưa được duyệt.",
        art_line, runtime_tag]
    poison_skill_detail_label.tooltip_text = "ID thật: " + selected_catalog_skill_id + " | effect=" + effect
    poison_load_button.disabled = design_pending or not (bool(definition.get("archivable", false)) or slot in ["basic", "mobility"])
    poison_load_button.text = "NẠP SKILL & TẠO LẠI TRẬN" if not poison_load_button.disabled else "NỘI TẠI · CHỈ DUYỆT"

func _load_selected_poison_skill() -> void:
    if selected_catalog_skill_id.is_empty() or _school() != "poison":
        return
    var definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(selected_catalog_skill_id, {})
    if definition.is_empty():
        return
    var slot := str(definition.get("slot", ""))
    var loaded := false
    match slot:
        "active":
            var target_index := 0
            for index in range(active_slots.size()):
                var current_id := str(active_slots[index].get_item_metadata(active_slots[index].selected))
                if current_id == selected_catalog_skill_id:
                    target_index = index
                    break
                var current: Dictionary = CombatLabRosterAdapter.skill_definitions().get(current_id, {})
                if str(current.get("family_id", "")) == str(definition.get("family_id", "")):
                    target_index = index
                    break
            loaded = _select_skill_option(active_slots[target_index], selected_catalog_skill_id)
        "ultimate":
            loaded = _select_skill_option(ultimate_slot, selected_catalog_skill_id)
        "passive":
            passive_override_id = selected_catalog_skill_id
            loaded = true
        "basic":
            basic_override_id = selected_catalog_skill_id
            loaded = true
        "mobility":
            mobility_override_id = selected_catalog_skill_id
            loaded = true
    if not loaded:
        _set_error("Slot này chưa có đường nạp trong Combat Lab")
        return
    _refresh_preview_choice()
    _start_battle()
    if slot in ["active", "ultimate"]:
        for index in range(skill_preview_option.item_count):
            if str(skill_preview_option.get_item_metadata(index)) == selected_catalog_skill_id:
                skill_preview_option.select(index)
                break
    _refresh_poison_combat_summary()
    _refresh_v4_cinematic_labels()

func _select_skill_option(option: OptionButton, skill_id: String) -> bool:
    for index in range(option.item_count):
        if str(option.get_item_metadata(index)) == skill_id:
            option.select(index)
            return true
    return false

func _apply_poison_boss_preset() -> void:
    school_option.select(SCHOOL_KEYS.find("poison"))
    generation_option.select(GENERATION_KEYS.find("human"))
    lineage_option.select(0)
    party_count.value = 6
    enemy_option.select(2)
    encounter_option.select(3)
    _select_boss("tmb.boss.bach_doc_chu_hau")
    _refresh_boss_visibility()
    _refresh_branches()
    _refresh_skills()
    _select_poison_skill("tmb.skill.poison.doc_cham.active_03.human")
    _load_selected_poison_skill()

func _apply_poison_aoe_preset() -> void:
    school_option.select(SCHOOL_KEYS.find("poison"))
    generation_option.select(GENERATION_KEYS.find("human"))
    lineage_option.select(0)
    party_count.value = 1
    enemy_option.select(0)
    encounter_option.select(1)
    _refresh_boss_visibility()
    _refresh_branches()
    _refresh_skills()
    _select_poison_skill("tmb.skill.poison.doc_cham.active_03.human")
    _load_selected_poison_skill()

func _apply_poison_swarm_preset() -> void:
    # Presentation-only encounter selector; source damage remains MapBattleV2.
    school_option.select(SCHOOL_KEYS.find("poison"))
    generation_option.select(GENERATION_KEYS.find("human"))
    lineage_option.select(0)
    party_count.value = 4
    enemy_option.select(0)
    encounter_option.select(4)
    _refresh_boss_visibility()
    _refresh_branches()
    _refresh_skills()
    _select_poison_skill("tmb.skill.poison.doc_cham.active_03.human")
    _load_selected_poison_skill()

func _select_poison_skill(skill_id: String) -> bool:
    for index in range(poison_catalog_option.item_count):
        if str(poison_catalog_option.get_item_metadata(index)) == skill_id:
            poison_catalog_option.select(index)
            selected_catalog_skill_id = skill_id
            _refresh_poison_skill_details()
            return true
    return false

func _select_boss(boss_id: String) -> bool:
    for index in range(boss_option.item_count):
        if str(boss_option.get_item_metadata(index)) == boss_id:
            boss_option.select(index)
            return true
    return false

func _on_encounter_selected(index: int) -> void:
    if index == 3:
        enemy_option.select(2)
        if boss_option.item_count > 0 and boss_option.selected < 0:
            boss_option.select(0)
    elif enemy_option.selected == 2:
        enemy_option.select(0)
    _refresh_boss_visibility()
    _start_battle()

func _fill_bosses() -> void:
    boss_option.clear()
    for id in BOSS_IDS:
        var definition := V63HumanSkillCombatSystem.boss_definition(id)
        if definition.is_empty(): continue
        boss_option.add_item(str(definition.get("name", id)))
        boss_option.set_item_metadata(boss_option.item_count - 1, id)
    if boss_option.item_count > 0: boss_option.select(0)

func _refresh_boss_visibility() -> void:
    if boss_option != null:
        boss_option.visible = enemy_option.selected == 2 or (encounter_option != null and encounter_option.selected == 3)

func _selected_loadout() -> Array[String]:
    var result: Array[String] = []
    var basics := CombatLabRosterAdapter.skill_options(_school(), _generation(), "basic", _branch(), _lineage())
    var mobility := CombatLabRosterAdapter.skill_options(_school(), _generation(), "mobility", _branch(), _lineage())
    var passives := CombatLabRosterAdapter.skill_options(_school(), _generation(), "passive", _branch(), _lineage())
    if basics.is_empty() or mobility.is_empty() or passives.size() < 5 or ultimate_slot.item_count == 0: return result
    result.append(basic_override_id if not basic_override_id.is_empty() else str(basics[0].get("id", "")))
    result.append(mobility_override_id if not mobility_override_id.is_empty() else str(mobility[0].get("id", "")))
    for slot in active_slots:
        if slot.item_count == 0: return []
        result.append(str(slot.get_item_metadata(slot.selected)))
    result.append(str(ultimate_slot.get_item_metadata(ultimate_slot.selected)))
    if passive_override_id.is_empty():
        for index in range(5): result.append(str(passives[index].get("id", "")))
    else:
        var selected_passives: Array[Dictionary] = []
        var seen_passive_families: Dictionary = {}
        for passive in passives:
            if str(passive.get("id", "")) == passive_override_id:
                selected_passives.append(passive)
                seen_passive_families[str(passive.get("family_id", ""))] = true
                break
        if selected_passives.is_empty(): return []
        for passive in passives:
            if selected_passives.size() >= 5:
                break
            var family := str(passive.get("family_id", ""))
            if seen_passive_families.has(family):
                continue
            seen_passive_families[family] = true
            selected_passives.append(passive)
        if selected_passives.size() < 5: return []
        for passive in selected_passives: result.append(str(passive.get("id", "")))
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
        _set_preview_warning("Không có đệ tử/đối thủ còn sống để thử chiêu")
        return
    var caster: Dictionary = battle.actors[disciple_ids[0]]
    var target: Dictionary = battle.actors[enemy_ids[0]]
    var old_loadout: Array = caster.get("v63_skill_loadout", []).duplicate(true)
    if not old_loadout.has(skill_id):
        _set_preview_warning("Kỹ năng chưa được trang bị trong đội hình Lab")
        return
    if not caster.get("v63_pending_cast", {}).is_empty():
        _set_preview_warning("Đệ tử đang thi triển chiêu trước")
        return
    var ready: Dictionary = caster.get("v63_skill_ready", {})
    if battle.now < float(ready.get(skill_id, 0.0)):
        _set_preview_warning("Kỹ năng đang hồi chiêu: %.1fs" % (float(ready.get(skill_id, 0.0)) - battle.now))
        return
    # Isolate only the selected skill. If it cannot be cast, no other
    # equipped skill may silently substitute for the requested preview.
    caster["v63_skill_loadout"] = [skill_id]
    var cast_started := V63HumanSkillCombatSystem.try_cast(battle, caster, target)
    caster["v63_skill_loadout"] = old_loadout
    _consume_events()
    _refresh_hud()
    if not cast_started:
        _set_preview_warning("Chiêu không hợp lệ ở khoảng cách/đối tượng hoặc trạng thái hiện tại")
        return
    state_label.text = "THỬ CHIÊU · " + str(V63HumanSkillCombatSystem.skill_definition(skill_id).get("name", skill_id)) + " · STEP để phóng"

func _apply_capture_preset() -> void:
    # QA-only environment selectors; normal F6 player interaction is unchanged.
    # Each screenshot process can use a different school and zoom while still
    # creating a real finite MapBattleV2 encounter from canonical catalogues.
    var school_key := OS.get_environment("TMB_COMBAT_LAB_SCHOOL").strip_edges().to_lower()
    var school_index := SCHOOL_KEYS.find(school_key)
    if school_index >= 0:
        school_option.select(school_index)
        _refresh_branches()
    var generation_key := OS.get_environment("TMB_COMBAT_LAB_GENERATION").strip_edges().to_lower()
    var generation_index := GENERATION_KEYS.find(generation_key)
    if generation_index >= 0:
        generation_option.select(generation_index)
        _refresh_skills()
    var branch_key := OS.get_environment("TMB_COMBAT_LAB_BRANCH").strip_edges().to_lower()
    if not branch_key.is_empty():
        for index in range(branch_option.item_count):
            if str(branch_option.get_item_metadata(index)) == branch_key:
                branch_option.select(index)
                _refresh_skills()
                break
    var lineage_key := OS.get_environment("TMB_COMBAT_LAB_LINEAGE").strip_edges().to_lower()
    if lineage_key in ["a", "b"]:
        lineage_option.select(0 if lineage_key == "a" else 1)
        _refresh_skills()
    var enemy_keys := ["normal", "elite", "boss"]
    var enemy_index := enemy_keys.find(OS.get_environment("TMB_COMBAT_LAB_ENEMY").strip_edges().to_lower())
    if enemy_index >= 0:
        enemy_option.select(enemy_index)
        _refresh_boss_visibility()
    var encounter_key := OS.get_environment("TMB_COMBAT_LAB_ENCOUNTER").strip_edges().to_lower()
    var encounter_keys := ["single", "aoe3", "aoe5", "boss_adds", "poison_swarm"]
    var encounter_index := encounter_keys.find(encounter_key)
    if encounter_index >= 0:
        encounter_option.select(encounter_index)
        if encounter_index == 3:
            enemy_option.select(2)
            _select_boss("tmb.boss.bach_doc_chu_hau")
        _refresh_boss_visibility()
    var requested_party := OS.get_environment("TMB_COMBAT_LAB_PARTY").strip_edges()
    if requested_party.is_valid_int():
        party_count.value = clampi(int(requested_party), 1, 6)

func _start_battle() -> void:
    if school_option == null: return
    var ids := _selected_loadout()
    var setup := CombatLabRosterAdapter.build_party(int(party_count.value), _school(), _generation(), _branch(), _lineage(), ids)
    if not bool(setup.get("ok", false)):
        _set_error("Loadout không hợp lệ: " + str(setup.get("errors", setup.get("detail", setup.get("reason", "")))))
        return
    # Four genuine party actors are placed at four corners. Their original
    # stats, loadouts and canonical combat authority are left untouched.
    if encounter_option != null and encounter_option.selected == 4 and setup.party.size() == 4:
        var corners: Array[Vector2] = [
            Vector2(12.4, 7.4), Vector2(12.4, 12.6),
            Vector2(23.6, 7.4), Vector2(23.6, 12.6)]
        for index in range(4):
            var hero: Dictionary = setup.party[index]
            hero["position"] = corners[index]
            hero["lab_showcase_corner"] = index
    var enemy_kind: String = str(["normal", "elite", "boss"][enemy_option.selected])
    var boss_id := str(boss_option.get_item_metadata(boss_option.selected)) if boss_option.item_count > 0 else ""
    var monsters := _build_lab_monsters(enemy_kind, boss_id)
    if monsters.is_empty():
        _set_error("Không tạo được đội quái từ catalog thật")
        return
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
    last_combat_skill_id = ""
    auto_run = true
    accumulator = 0.0
    arena.call("set_battle", battle, _school())
    arena.call("set_status", "LAB_ONLY  ·  " + GENERATION_LABELS[generation_option.selected] + " · " + SCHOOL_LABELS[school_option.selected])
    _consume_events()
    _refresh_hud()

func _build_lab_monsters(enemy_kind: String, boss_id: String) -> Array:
    var monsters: Array = []
    if encounter_option != null and encounter_option.selected == 4:
        # Real MonsterCatalogueV2 actors. 6 within a 3-tile ring around
        # (18,10), 2 clearly outside. Zero scripted HP/damage outcomes.
        var swarm_points: Array[Vector2] = [
            Vector2(18.0, 10.0), Vector2(16.8, 9.1),
            Vector2(19.0, 9.0), Vector2(17.4, 11.2),
            Vector2(19.2, 11.0), Vector2(18.2, 8.5),
            Vector2(13.0, 10.0), Vector2(23.0, 10.0)]
        for index in range(swarm_points.size()):
            var id := "lab_swarm_%02d" % (index + 1)
            var mob := CombatLabRosterAdapter.build_enemy("normal", "", id)
            if not bool(mob.get("ok", false)):
                return []
            var monster: Dictionary = mob.actor
            monster["position"] = swarm_points[index]
            # Only start positions are authored for the geometry oracle.
            # MapBattleV2 retains real monster pursuit / attack behaviour.
            monsters.append(monster)
        return monsters
    if encounter_option != null and encounter_option.selected == 3:
        var boss := CombatLabRosterAdapter.build_enemy("boss", boss_id, "lab_boss")
        if not bool(boss.get("ok", false)):
            return []
        var boss_actor: Dictionary = boss.actor
        boss_actor["id"] = "lab_boss"
        boss_actor["position"] = Vector2(28.0, 10.0)
        monsters.append(boss_actor)
        var add_positions: Array[Vector2] = [Vector2(26.0, 8.4), Vector2(25.7, 10.0), Vector2(26.0, 11.6)]
        for index in range(add_positions.size()):
            var add := CombatLabRosterAdapter.build_enemy("normal", "", "lab_boss_add_%02d" % (index + 1))
            if not bool(add.get("ok", false)):
                return []
            var add_actor: Dictionary = add.actor
            add_actor["position"] = add_positions[index]
            add_actor["move_speed"] = 0.0
            monsters.append(add_actor)
        return monsters

    if encounter_option != null and encounter_option.selected in [1, 2]:
        var inside_count := 3 if encounter_option.selected == 1 else 5
        var positions: Array[Vector2] = [Vector2(12.0, 10.0), Vector2(10.2, 8.5), Vector2(10.4, 11.6),
            Vector2(13.7, 8.1), Vector2(13.8, 11.7)]
        for index in range(inside_count):
            var enemy := CombatLabRosterAdapter.build_enemy(enemy_kind, "", "lab_aoe_%02d" % index)
            if not bool(enemy.get("ok", false)):
                return []
            var actor: Dictionary = enemy.actor
            actor["position"] = positions[index]
            actor["move_speed"] = 0.0
            monsters.append(actor)
        var outside := CombatLabRosterAdapter.build_enemy(enemy_kind, "", "lab_aoe_outside")
        if not bool(outside.get("ok", false)):
            return []
        var outside_actor: Dictionary = outside.actor
        outside_actor["position"] = Vector2(16.5, 10.0)
        outside_actor["move_speed"] = 0.0
        monsters.append(outside_actor)
        return monsters

    var single := CombatLabRosterAdapter.build_enemy(enemy_kind, boss_id, "lab_enemy")
    if not bool(single.get("ok", false)):
        return []
    var single_actor: Dictionary = single.actor
    if enemy_kind != "boss": single_actor["position"] = Vector2(26, 10)
    return [single_actor]

# A rejected preview command (cooldown, out of range, missing target) does
# not invalidate an already-running MapBattleV2 scene or its event/VFX QA.
func _set_preview_warning(message: String) -> void:
    state_label.text = "THỬ CHIÊU · CHƯA THỰC HIỆN"
    state_label.tooltip_text = message
    if events_label != null: events_label.text = message

func _set_error(message: String) -> void:
    state_label.text = "LỖI FIXTURE"
    state_label.tooltip_text = message
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
        var event_type := str(event.get("type", ""))
        var event_skill_id := str(event.get("skill_id", event.get("source_skill_id", "")))
        if event_type in ["skill_cast", "skill_release", "skill_hit"] and not event_skill_id.is_empty():
            var event_skill: Dictionary = CombatLabRosterAdapter.skill_definitions().get(event_skill_id, {})
            var event_source_id := str(event.get("caster", event.get("attacker", event.get("actor_id", ""))))
            var event_source: Dictionary = battle.actors.get(event_source_id, {})
            if str(event_skill.get("school", "")) == "poison" and str(event_source.get("side", "")) == "disciple":
                last_combat_skill_id = event_skill_id
        event_log.append("%05.1fs  %s" % [float(event.get("time", 0.0)), str(event.get("type", "event"))])
    if event_log.size() > 8: event_log = event_log.slice(event_log.size() - 8)

func _refresh_hud() -> void:
    if battle == null:
        return
    state_label.text = "%s  ·  %.1fs  ·  %s" % ["AUTO" if auto_run else "HOLD", battle.now, battle.outcome]
    mode_label.text = "V6.3 · %d ĐT" % int(party_count.value)
    # Aggregate real actor HP by side. 12 individual long rows pushed HUD
    # text into vertical narrow columns and obscured the combat arena.
    var alive_disciples := 0
    var total_disciples := 0
    var alive_monsters := 0
    var total_monsters := 0
    for actor_value in battle.actors.values():
        var actor: Dictionary = actor_value
        if str(actor.get("side", "")) == "disciple":
            total_disciples += 1
            if float(actor.get("hp", 0.0)) > 0.0: alive_disciples += 1
        elif str(actor.get("side", "")) == "monster":
            total_monsters += 1
            if float(actor.get("hp", 0.0)) > 0.0: alive_monsters += 1
    roster_label.text = "Đệ tử %d/%d còn chiến đấu    ·    Quái %d/%d còn sống" % [
        alive_disciples, total_disciples, alive_monsters, total_monsters]
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
        stats_label.text = "ĐT01: HP %d/%d · Công %d · Thủ %d · Chí mạng %.1f%% · Hút máu %.1f%%" % [
            roundi(float(live_actor.get("hp", 0.0))), roundi(float(stats.max_hp)),
            roundi(float(stats.attack)), roundi(float(stats.defense)),
            float(stats.crit_chance) * 100.0, float(stats.lifesteal) * 100.0]
    events_label.text = event_log.back() if not event_log.is_empty() else ""
    _refresh_poison_combat_summary()

func _refresh_poison_combat_summary() -> void:
    if poison_current_skill_label == null or poison_stack_label == null:
        return
    var poison_selected := _school() == "poison"
    poison_current_skill_label.visible = poison_selected
    poison_stack_label.visible = poison_selected
    if not poison_selected:
        return
    var skill_id := last_combat_skill_id if not last_combat_skill_id.is_empty() else selected_catalog_skill_id
    var definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(skill_id, {})
    if definition.is_empty():
        poison_current_skill_label.text = "Skill: chưa chọn"
    else:
        var prefix := "Đang đánh" if not last_combat_skill_id.is_empty() else "Đang xem"
        poison_current_skill_label.text = "%s: %s" % [prefix, str(definition.get("name", skill_id))]
    var poison_stacks := 0
    var poisoned_monsters := 0
    if battle != null:
        for actor_value in battle.actors.values():
            var actor: Dictionary = actor_value
            if str(actor.get("side", "")) != "monster":
                continue
            var statuses: Dictionary = actor.get("status_effects", {})
            var stacks: Array = statuses.get("v63_poison", [])
            poison_stacks += stacks.size()
            if not stacks.is_empty(): poisoned_monsters += 1
    poison_stack_label.text = "Độc %d · %d quái" % [poison_stacks, poisoned_monsters]

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
