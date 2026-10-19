class_name HuntingExpeditionScreenV2
extends Control

# World-gate launcher. Actual loot, HP, injury, RNG and encounter replay
# are owned solely by HuntingPveRunV2 + existing LiveGameRuntimeV2 save.
# Combat advances only on explicit actions, never a competing GUI timer.
var game_state: SimulationState
var live_runtime: LiveGameRuntimeV2
var run: HuntingPveRunV2
var selected: Dictionary = {}
var region_choice: OptionButton
var level_choice: OptionButton
var roster_list: VBoxContainer
var feedback: Label
var summary: Label
var view: MapBattleWorldLayerV2
var selection_panel: PanelContainer
var advance_button: Button
var finish_button: Button
var reward_button: Button
var choose_all_button: Button

func configure(state: SimulationState, runtime: LiveGameRuntimeV2) -> void:
    game_state = state
    live_runtime = runtime

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var shade := ColorRect.new()
    shade.color = Color(0.024,0.042,0.037,0.97)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    view = MapBattleWorldLayerV2.new()
    view.enable_source_vl_art = true
    view.draw_pilot_ground = true
    view.enable_spectator_framing = true
    view.spectator_zoom_ceiling = 1.0
    view.visible = false
    add_child(view)

    var close := Button.new()
    close.text = "TRỞ VỀ TÔNG MÔN"
    close.position = Vector2(1030,8)
    close.size = Vector2(232,42)
    close.pressed.connect(_close)
    add_child(close)

    selection_panel = PanelContainer.new()
    selection_panel.position = Vector2(24,56)
    selection_panel.size = Vector2(570,568)
    add_child(selection_panel)
    var controls := VBoxContainer.new()
    controls.add_theme_constant_override("separation",7)
    selection_panel.add_child(controls)
    var title := Label.new()
    title.text = "THẾ GIỚI  /  XUẤT CHIẾN"
    title.add_theme_font_size_override("font_size",22)
    controls.add_child(title)
    region_choice = OptionButton.new()
    var regions: Array = HuntingMapV2.REGION_CONTENT.keys()
    regions.sort()
    for region in regions:
        var code := str(region)
        region_choice.add_item(str(HuntingMapV2.REGION_CONTENT[region]["name"]))
        region_choice.set_item_metadata(region_choice.item_count-1,code)
    controls.add_child(region_choice)
    level_choice = OptionButton.new()
    for level in range(1,6):
        level_choice.add_item("%d — %s" % [level,str(HuntingMapV2.LEVELS[level]["name"])],level)
    level_choice.select(0)
    controls.add_child(level_choice)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(540,334)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    controls.add_child(scroll)
    roster_list = VBoxContainer.new()
    roster_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(roster_list)
    choose_all_button = Button.new()
    choose_all_button.text = "Chọn tối đa 30 đệ tử hợp lệ"
    choose_all_button.pressed.connect(_select_all)
    controls.add_child(choose_all_button)
    var start := Button.new()
    start.text = "XUẤT CHIẾN (đội thật, không cộng chỉ số)"
    start.pressed.connect(_start_hunt)
    controls.add_child(start)

    summary = Label.new()
    summary.position = Vector2(20,633)
    summary.size = Vector2(1240,25)
    summary.add_theme_font_size_override("font_size",16)
    add_child(summary)
    feedback = Label.new()
    feedback.position = Vector2(20,664)
    feedback.size = Vector2(1200,50)
    feedback.add_theme_font_size_override("font_size",13)
    feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(feedback)

    advance_button = _add_action("TIẾP 10 TICK",635,46,_advance_ten)
    finish_button = _add_action("GIẢI QUYẾT TRẬN",794,46,_finish)
    reward_button = _add_action("NHẬN THƯỞNG",963,46,_claim)
    _render_roster()
    _refresh_controls()
    _resume_existing()

func _add_action(text_value: String, x: float, y: float, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text_value
    button.position = Vector2(x,y)
    button.size = Vector2(156,46)
    button.pressed.connect(callback)
    add_child(button)
    return button

func _render_roster() -> void:
    for child in roster_list.get_children():
        child.queue_free()
    selected.clear()
    for row in HuntingExpeditionEntryV2.eligible_roster(game_state):
        var key := str(row["id"])
        var checkbox := CheckBox.new()
        checkbox.text = "%s · %s T%d · %s T%d" % [
            str(row["name"]),
            DiscipleRealmProgressV2.realm_name("cultivation",int(row["realm"])),
            int(row["floor"]),
            DiscipleRealmProgressV2.realm_name("body",int(row["body_realm"])),
            int(row["body_floor"])
        ]
        checkbox.toggled.connect(_toggle_member.bind(key))
        roster_list.add_child(checkbox)
        checkbox.set_meta("disciple_id",key)
    if roster_list.get_child_count() == 0:
        feedback.text = "Không có đệ tử V2 đang rảnh. Cần đệ tử Tu Vi/Luyện Thể thật, không cấp cảnh giới giả."

func _toggle_member(pressed: bool, key: String) -> void:
    if pressed:
        selected[key] = true
    else:
        selected.erase(key)
    summary.text = "Đã chọn %d/30 đệ tử" % selected.size()

func _select_all() -> void:
    var limit := 0
    for child in roster_list.get_children():
        if child is CheckBox:
            child.button_pressed = limit < MapBattleV2.MAX_DISCIPLES
            limit += 1

func _region() -> String:
    if region_choice.selected < 0:
        return ""
    return str(region_choice.get_item_metadata(region_choice.selected))

func _start_hunt() -> void:
    if game_state == null or live_runtime == null:
        feedback.text = "Chưa có runtime/save thật."
        return
    var ids: Array = selected.keys()
    ids.sort()
    var party_data := HuntingExpeditionEntryV2.build_party(game_state,ids)
    if not bool(party_data.get("ok",false)):
        feedback.text = "Không thể xuất chiến: "+str(party_data.get("reason","unknown"))
        return
    var level := level_choice.get_selected_id()
    var chosen := HuntingMapV2.choose_level(game_state,_region(),level)
    if not bool(chosen.get("ok",false)):
        feedback.text = "Không thể chọn khu vực: "+str(chosen.get("reason","unknown"))
        return
    var session := HuntingPveRunV2.new()
    var encounter_id := HuntingExpeditionEntryV2.next_encounter_id(game_state)
    var started := session.begin(game_state,_region(),encounter_id,
        int(game_state.seed)+int(game_state.tick)+int(game_state.sect.v2_pve_reward_claims.size()),
        party_data["party"])
    if not bool(started.get("ok",false)):
        feedback.text = "Từ chối xuất chiến: "+str(started.get("reason","unknown"))
        return
    run = session
    _open_battle()
    _save_now("đặt đội xuất chiến")

func _resume_existing() -> void:
    if game_state == null:
        return
    var ids: Array = game_state.sect.v2_pve_active_runs.keys()
    ids.sort()
    for raw in ids:
        var resumed := HuntingPveRunV2.resume_active(game_state,str(raw))
        if bool(resumed.get("ok",false)):
            run = resumed["session"]
            _open_battle()
            feedback.text = "Đã tải lại trận thật %s từ snapshot." % str(raw)
            return
    # Unavailable/invalid snapshots remain untouched for the owner to repair.
    if not ids.is_empty():
        feedback.text = "Có trận lưu không hợp lệ; không tự xóa hay tạo thưởng."

func _open_battle() -> void:
    selection_panel.visible = false
    view.visible = true
    view.attach_session(run.battle)
    view.set_actor_view_metadata(
        HuntingExpeditionEntryV2.display_metadata(game_state,run))
    _refresh_controls()

func _refresh_controls() -> void:
    var battle_ready := run != null and run.battle != null
    advance_button.visible = battle_ready
    finish_button.visible = battle_ready
    reward_button.visible = battle_ready
    if not battle_ready:
        return
    advance_button.disabled = not run.battle.active
    finish_button.disabled = not run.battle.active
    reward_button.disabled = run.battle.active or run.battle.outcome != "win" or \
        game_state.sect.v2_pve_reward_claims.has(run.battle.encounter_id)
    var report := run.battle.summary()
    summary.text = "%s · %s · %.2fs · Đệ tử còn %d · Quái còn %d" % [
        str(run.region_id),str(report["outcome"]),float(report["time"]),
        int(report["alive_disciples"]),int(report["alive_monsters"])
    ]
    view.refresh_from_authority()

func _advance_ten() -> void:
    if run == null or not run.battle.active:
        return
    for _i in range(10):
        if not run.battle.active:
            break
        var outcome := run.advance(false)
        if not bool(outcome.get("ok",false)):
            feedback.text = "Lỗi tick: "+str(outcome.get("reason","unknown"))
            break
    _refresh_controls()
    _save_now("tiến hành trận")

func _finish() -> void:
    if run == null:
        return
    var result := run.finish(400)
    if not bool(result.get("ok",false)):
        feedback.text = "Trận chưa hoàn tất: "+str(result.get("reason","unknown"))
    else:
        feedback.text = "Trận đã kết toán theo HP/Injury thật. Thưởng chỉ cấp một lần khi thắng."
    _refresh_controls()
    _save_now("kết toán trận")

func _claim() -> void:
    if run == null or run.battle.active or run.battle.outcome != "win":
        return
    var earned := run.claim()
    if not bool(earned.get("ok",false)):
        feedback.text = "Không nhận được thưởng: "+str(earned.get("reason","unknown"))
    else:
        feedback.text = "Đã xử lý phần thưởng thật qua kho, receipt không thể nhận trùng: "+str(earned)
    _refresh_controls()
    _save_now("nhận thưởng")

func _save_now(stage: String) -> void:
    var saved := live_runtime.save()
    if not bool(saved.get("ok",false)):
        feedback.text = "CẢNH BÁO: %s chưa lưu được; không thoát game. %s" % [
            stage,str(saved.get("reason",saved.get("error","save_failed")))]

func _close() -> void:
    if live_runtime != null:
        var saved := live_runtime.save()
        if not bool(saved.get("ok",false)):
            feedback.text = "Không thể rời màn: lưu thất bại."
            return
    queue_free()
