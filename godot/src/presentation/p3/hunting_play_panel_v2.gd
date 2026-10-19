class_name HuntingPlayPanelV2
extends Control

signal request_guidance

# C4-BE01: actual region -> real disciple roster -> persisted HuntingPveRunV2.
# This is a view/controller. No substitute combat, loot, scheduler or save state.
const STAGE := Vector2(1280.0,720.0)
const BATTLE_STEP := MapBattleV2.STEP_SECONDS
const MAX_STEPS_PER_FRAME := 4
const VISIBLE_ROSTER_LIMIT := 90

var live: LiveGameRuntimeV2
var state: SimulationState
var session: HuntingPveRunV2
var selected_region := "thanh_truc_lam"
var selected_level := 1
var chosen: Dictionary = {}
var building_rules := BuildingSystem.new()
var roster_filter: LineEdit
var guidance_button: Button
var roster_diagnostics: Label
var accumulator := 0.0
var running := false

var region_choice: OptionButton
var level_choice: OptionButton
var roster_list: VBoxContainer
var roster_scroll: ScrollContainer
var status: Label
var launch_button: Button
var resume_button: Button
var claim_button: Button
var battle_layer: MapBattleWorldLayerV2
var _log_counter := 0

func open_session(runtime: LiveGameRuntimeV2) -> void:
    live = runtime
    state = live.state() if live != null else null
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    set_process(false)
    _build()
    if state != null:
        _rebuild_roster()
        _restore_first_session()
    else:
        _status("Không có dữ liệu game hợp lệ.")

func _build() -> void:
    if status != null:
        return
    mouse_filter = Control.MOUSE_FILTER_STOP
    var shade := ColorRect.new()
    shade.color = Color(0.91,0.86,0.72,0.99)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)

    var header := Label.new()
    header.position = Vector2(22,12)
    header.size = Vector2(1000,39)
    header.text = "THẾ GIỚI / SĂN QUÁI — COMBAT V2"
    header.add_theme_font_size_override("font_size",22)
    header.add_theme_color_override("font_color",Color(0.16,0.24,0.20,1.0))
    add_child(header)

    var close := Button.new()
    close.text = "Đóng / Lưu"
    close.position = Vector2(1110,10)
    close.size = Vector2(150,43)
    close.pressed.connect(_close)
    add_child(close)

    var left := PanelContainer.new()
    left.position = Vector2(16,63)
    left.size = Vector2(357,561)
    add_child(left)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation",5)
    left.add_child(column)
    left.add_theme_stylebox_override("panel",_hunting_panel_style(
        Color(0.975,0.94,0.84,1.0),Color(0.39,0.31,0.20,1.0)))

    var region_text := Label.new()
    region_text.text = "Khu vực"
    column.add_child(region_text)
    region_choice = OptionButton.new()
    var regions: Array = HuntingMapV2.REGION_CONTENT.keys()
    regions.sort()
    for id in regions:
        region_choice.add_item(str(HuntingMapV2.REGION_CONTENT[id]["name"]))
        region_choice.set_item_metadata(region_choice.item_count-1,str(id))
    region_choice.item_selected.connect(_region_changed)
    column.add_child(region_choice)
    for i in range(region_choice.item_count):
        if str(region_choice.get_item_metadata(i)) == selected_region:
            region_choice.select(i)
            break

    var level_text := Label.new()
    level_text.text = "Độ khó"
    column.add_child(level_text)
    level_choice = OptionButton.new()
    for level in range(1,6):
        level_choice.add_item("%d. %s" % [level,str(HuntingMapV2.LEVELS[level]["name"])])
    level_choice.select(0)
    level_choice.item_selected.connect(_level_changed)
    column.add_child(level_choice)

    var roster_text := Label.new()
    roster_text.text = "Chọn tối đa 30 đệ tử V2 rảnh; mỗi đội tối đa 6"
    roster_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(roster_text)
    roster_filter = LineEdit.new()
    roster_filter.placeholder_text = "Tìm đệ tử (tối đa 90 kết quả)"
    roster_filter.text_changed.connect(func(_text: String): _rebuild_roster())
    column.add_child(roster_filter)
    roster_diagnostics = Label.new()
    roster_diagnostics.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    roster_diagnostics.add_theme_font_size_override("font_size",12)
    column.add_child(roster_diagnostics)
    guidance_button = Button.new()
    guidance_button.text = "Tuyển đệ tử V2 ở Dẫn Tiên Đài"
    guidance_button.custom_minimum_size.y = 32
    guidance_button.pressed.connect(func(): request_guidance.emit())
    column.add_child(guidance_button)
    roster_scroll = ScrollContainer.new()
    roster_scroll.custom_minimum_size = Vector2(330,148)
    roster_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(roster_scroll)
    roster_list = VBoxContainer.new()
    roster_scroll.add_child(roster_list)

    launch_button = Button.new()
    launch_button.text = "Xuất môn"
    launch_button.custom_minimum_size.y = 44
    launch_button.pressed.connect(_launch)
    column.add_child(launch_button)

    resume_button = Button.new()
    resume_button.text = "Tiếp tục trận đã lưu"
    resume_button.custom_minimum_size.y = 40
    resume_button.pressed.connect(_restore_first_session)
    column.add_child(resume_button)

    claim_button = Button.new()
    claim_button.text = "Nhận chiến lợi phẩm"
    claim_button.custom_minimum_size.y = 42
    claim_button.disabled = true
    claim_button.pressed.connect(_claim)
    column.add_child(claim_button)

    var battlefield := PanelContainer.new()
    battlefield.position = Vector2(386,63)
    battlefield.size = Vector2(878,561)
    add_child(battlefield)
    var viewing := Control.new()
    viewing.clip_contents = true
    battlefield.add_child(viewing)
    battlefield.add_theme_stylebox_override("panel",_hunting_panel_style(
        Color(0.10,0.17,0.14,1.0),Color(0.35,0.29,0.18,1.0)))

    battle_layer = MapBattleWorldLayerV2.new()
    battle_layer.position = Vector2.ZERO
    battle_layer.stage_rect = Rect2(Vector2(6,6),Vector2(864,547))
    battle_layer.draw_pilot_ground = true
    battle_layer.enable_source_vl_art = true
    battle_layer.enable_spectator_framing = true
    battle_layer.spectator_zoom_ceiling = 1.0
    viewing.add_child(battle_layer)

    status = Label.new()
    status.position = Vector2(18,636)
    status.size = Vector2(1230,71)
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status.add_theme_font_size_override("font_size",15)
    status.add_theme_color_override("font_color",Color(0.16,0.23,0.18,1.0))
    add_child(status)
    # Match G1/MAP25 parchment and ink; Source-VL combat renderer stays unchanged.
    for control in [close,launch_button,resume_button,claim_button,guidance_button]:
        control.add_theme_stylebox_override("normal",_hunting_panel_style(
            Color(0.20,0.38,0.30,1.0),Color(0.60,0.48,0.28,1.0)))
        control.add_theme_stylebox_override("hover",_hunting_panel_style(
            Color(0.28,0.49,0.38,1.0),Color(0.81,0.65,0.37,1.0)))
        control.add_theme_color_override("font_color",Color(0.97,0.94,0.84,1.0))
    for label in [region_text,level_text,roster_text,roster_diagnostics]:
        label.add_theme_color_override("font_color",Color(0.18,0.24,0.17,1.0))
    _status("Cần đệ tử thật có Tu Vi/Luyện Thể V2 và rảnh. Nhấn 'Tuyển đệ tử V2' để tới Dẫn Tiên Đài.")

func _hunting_panel_style(fill: Color, outline: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = outline
    style.set_border_width_all(2)
    style.set_corner_radius_all(10)
    style.content_margin_left = 8.0
    style.content_margin_right = 8.0
    style.content_margin_top = 8.0
    style.content_margin_bottom = 8.0
    return style

func _status(message: String) -> void:
    if status != null:
        status.text = message

func _region_changed(index: int) -> void:
    selected_region = str(region_choice.get_item_metadata(index))
    chosen.clear()
    _rebuild_roster()

func _level_changed(index: int) -> void:
    selected_level = index+1

func _eligibility_reason(disciple: DiscipleState) -> String:
    # Each reason is source-backed and does not mutate legacy disciples.
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return "Chưa có hồ sơ Tu Vi + Luyện Thể V2"
    if disciple.hp <= 0.0:
        return "Đã gục, chưa được hồi phục"
    if disciple.injury_level != 0:
        return "Đang bị thương"
    if not disciple.active_pve_encounter_id.is_empty():
        return "Đang tham chiến ở khu khác"
    if disciple.region_id != &"sect":
        return "Đang ở ngoài tông môn"
    if disciple.current_action not in [&"EVALUATE",&"IDLE",&"HOLD"]:
        return "Đang làm việc: " + SectMapPresentation.action_label(disciple.current_action)
    if not disciple.work_cycle_state.is_empty():
        return "Đang có chu kỳ lao động"
    if building_rules.disciple_has_active_spirit_plot(state,disciple.id):
        return "Đang phụ trách Linh Điền"
    if building_rules.disciple_has_active_timed_recipe(state,disciple.id):
        return "Đang phụ trách sản xuất"
    if DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        return "Đang rèn thân"
    return ""

func _eligible(disciple: DiscipleState) -> bool:
    return _eligibility_reason(disciple).is_empty()

func _rebuild_roster() -> void:
    if roster_list == null or state == null:
        return
    for child in roster_list.get_children():
        child.queue_free()
    var ids: Array = state.disciples.keys()
    ids.sort()
    var shown := 0
    var eligible_total := 0
    var v2_missing := 0
    var busy_total := 0
    var injury_total := 0
    var fragment := roster_filter.text.strip_edges().to_lower() if roster_filter != null else ""
    for id in ids:
        var disciple: DiscipleState = state.disciples[id]
        if not fragment.is_empty() and not disciple.display_name.to_lower().contains(fragment):
            continue
        if shown >= VISIBLE_ROSTER_LIMIT:
            break
        shown += 1
        var reason := _eligibility_reason(disciple)
        var can_enter := reason.is_empty()
        if can_enter:
            eligible_total += 1
        elif reason.begins_with("Chưa có hồ sơ"):
            v2_missing += 1
        elif reason == "Đang bị thương" or reason.begins_with("Đã gục"):
            injury_total += 1
        else:
            busy_total += 1
        var check := CheckBox.new()
        check.text = disciple.display_name + (" — SẴN SÀNG" if can_enter else " — " + reason)
        check.tooltip_text = reason if not can_enter else "Có thể xếp đội săn quái"
        check.disabled = not can_enter or session != null
        check.set_pressed_no_signal(chosen.has(str(id)) and can_enter)
        check.toggled.connect(_select_disciple.bind(str(id)))
        roster_list.add_child(check)
    if roster_diagnostics != null:
        roster_diagnostics.text = "Trong tối đa 90 kết quả: sẵn sàng %d | chưa V2 %d | bận %d | bị thương %d" % [
            eligible_total,v2_missing,busy_total,injury_total
        ]
    launch_button.disabled = session != null or chosen.is_empty() or not state.sect.p3_7_resources_enabled
    resume_button.disabled = session != null or state.sect.v2_pve_active_runs.is_empty()
    region_choice.disabled = session != null
    level_choice.disabled = session != null
    guidance_button.disabled = session != null
    claim_button.disabled = session == null or session.battle == null or session.battle.active or session.battle.outcome != "win"

func _select_disciple(enabled: bool, id: String) -> void:
    if enabled:
        if chosen.size() >= MapBattleV2.MAX_DISCIPLES:
            _status("Đội đã đủ 30 người; bỏ chọn trước khi thêm.")
            _rebuild_roster()
            return
        chosen[id] = true
    else:
        chosen.erase(id)
    _status("Đã chọn %d/30 đệ tử." % chosen.size())

func _role_for(index: int) -> String:
    return ["frontline","ranged","mage","healer","frontline","ranged"][index%6]

func _launch() -> void:
    if state == null or live == null or session != null or chosen.is_empty():
        _status("Không thể xuất môn: thiếu đội hoặc còn trận chưa xử lý.")
        return
    if not state.sect.p3_7_resources_enabled or not state.regions.has(StringName(selected_region)):
        _status("Khu vực / kho tài nguyên chưa được mở theo tiến độ game.")
        return
    var selected := HuntingMapV2.choose_level(state,selected_region,selected_level)
    if not bool(selected.get("ok",false)):
        _status("Độ khó không hợp lệ: "+str(selected.get("reason","")))
        return
    var ids: Array = chosen.keys()
    ids.sort()
    var roster: Array = []
    for i in range(ids.size()):
        var id := str(ids[i])
        var member: DiscipleState = state.disciples.get(StringName(id),null)
        if member == null or not _eligible(member):
            _status("Một đệ tử đã thay đổi trạng thái; chọn lại đội.")
            _rebuild_roster()
            return
        var row := {
            "disciple_id":id,"party_id":"team_%02d" % int(i/6),
            "role":_role_for(i),
            "position":Vector2(4.0+float(i%6)*0.85,3.0+float(i/6)*2.4)
        }
        # Real V2 rank is read by HuntingPveRunV2 from the disciple's
        # canonical persistent progression. No fake stats in the live flow.
        roster.append(row)
    var id := "hunt_%d_%d_%d" % [
        int(Time.get_unix_time_from_system()),state.tick,Time.get_ticks_usec()
    ]
    var seed_value := maxi(1,int(state.tick)+int(Time.get_unix_time_from_system())%1000000)
    var proposed := HuntingPveRunV2.new()
    var started := proposed.begin(state,selected_region,id,seed_value,roster)
    if not bool(started.get("ok",false)):
        _status("Không thể xuất môn: "+str(started.get("reason","unknown")))
        _rebuild_roster()
        return
    session = proposed
    # Persist the reservation and checkpoint before a single combat tick.
    var saved := live.save()
    if not bool(saved.get("ok",false)):
        running = false
        _status("LỖI LƯU — trận đã tạo trong RAM; không tiếp tục để tránh mất dữ liệu.")
        return
    _start_view()

func _restore_first_session() -> void:
    if state == null or live == null or session != null:
        return
    var ids: Array = state.sect.v2_pve_active_runs.keys()
    ids.sort()
    if ids.is_empty():
        return
    var restored := HuntingPveRunV2.resume_active(state,str(ids[0]))
    if not bool(restored.get("ok",false)):
        _status("Checkpoint không hợp lệ: "+str(restored.get("reason","unknown")))
        return
    session = restored["session"]
    selected_region = session.region_id
    selected_level = int(session.spawn_data.get("level",1))
    for i in range(region_choice.item_count):
        if str(region_choice.get_item_metadata(i)) == selected_region:
            region_choice.select(i)
            break
    level_choice.select(clampi(selected_level,1,5)-1)
    if session.battle.active:
        _start_view()
    else:
        running = false
        set_process(false)
        battle_layer.attach_session(session.battle)
        _update_view_status()
        _rebuild_roster()

func _start_view() -> void:
    if session == null or session.battle == null:
        return
    battle_layer.attach_session(session.battle)
    # Original spawn and canonical registered disciple IDs supply genuine
    # names/levels; MapBattleV2 snapshots do not contain these UI fields.
    var metadata := {}
    for monster in session.spawn_data.get("monsters",[]):
        metadata[str(monster["id"])] = {
            "realm_index":int(monster.get("realm_index",0)),
            "floor_index":int(monster.get("floor_index",0))
        }
    for actor in session.battle.actors.values():
        if str(actor.get("side","")) != "disciple":
            continue
        var key := StringName(str(actor["id"]))
        if not state.disciples.has(key):
            continue
        var disciple: DiscipleState = state.disciples[key]
        var entry := {"display_name":disciple.display_name}
        if DiscipleRealmProgressV2.valid_profile(disciple.v2_realm_progress):
            var progress: Dictionary = disciple.v2_realm_progress
            var tu: Dictionary = progress.get("cultivation",{})
            var body: Dictionary = progress.get("body",{})
            entry["realm_index"] = int(tu.get("realm",0))
            entry["floor_index"] = int(tu.get("floor",0))
            entry["body_realm_index"] = int(body.get("realm",0))
            entry["body_floor_index"] = int(body.get("floor",0))
        metadata[str(actor["id"])] = entry
    battle_layer.set_actor_view_metadata(metadata)
    accumulator = 0.0
    running = session.battle.active
    set_process(running)
    _rebuild_roster()
    _update_view_status()

func _process(delta: float) -> void:
    if not running or session == null or session.battle == null:
        return
    accumulator += minf(delta,0.25)
    var count := 0
    while accumulator >= BATTLE_STEP and count < MAX_STEPS_PER_FRAME and session.battle.active:
        accumulator -= BATTLE_STEP
        count += 1
        var advanced := session.advance(true)
        if not bool(advanced.get("ok",false)):
            running = false
            set_process(false)
            _status("TRẬN ĐẤU TẠM DỪNG: "+str(advanced.get("reason","unknown")))
            return
        battle_layer.refresh_from_authority()
    if not session.battle.active:
        running = false
        set_process(false)
        # Terminal receipt and held character reservations must be durable.
        var saved := live.save()
        if not bool(saved.get("ok",false)):
            _status("LỖI LƯU kết toán; không tự nhận thưởng.")
            claim_button.disabled = true
            return
        _rebuild_roster()
    _log_counter += count
    if count > 0 and _log_counter%4 == 0:
        _update_view_status()

func _update_view_status() -> void:
    if session == null or session.battle == null:
        return
    var result := session.battle.summary()
    _status("Khu: %s | %s | %.1f giây | Đệ tử còn: %d | Quái còn: %d | Đòn: %d | %s" % [
        selected_region,str(result["outcome"]),float(result["time"]),
        int(result["alive_disciples"]),int(result["alive_monsters"]),
        int(result["actions"]),
        "Nhận thưởng khi THẮNG" if not session.battle.active else "Đang giao chiến"
    ])

func _claim() -> void:
    if session == null or session.battle == null or session.battle.active:
        return
    if session.battle.outcome != "win":
        _status("Trận không thắng: không có chiến lợi phẩm để nhận.")
        return
    var claimed := session.claim()
    if not bool(claimed.get("ok",false)):
        _status("Chưa nhận được thưởng: "+str(claimed.get("reason","unknown")))
        return
    var saved := live.save()
    if not bool(saved.get("ok",false)):
        _status("ĐÃ KẾT TOÁN TRONG RAM, nhưng lưu thất bại; không xuất môn lần nữa.")
        return
    var reward_text := str(claimed.get("rewards",claimed))
    session = null
    chosen.clear()
    _rebuild_roster()
    _status("Đã kết toán chiến lợi phẩm đúng một lần: "+reward_text)

func _close() -> void:
    running = false
    set_process(false)
    if live != null:
        var result := live.save()
        if not bool(result.get("ok",false)):
            _status("Không đóng: không lưu được checkpoint.")
            return
    queue_free()
