class_name HuntingExpeditionPanelV2
extends Control

# UI is an adapter only. HuntingPveRunV2 owns HP, injury, reservations,
# receipt settlement and Warehouse payout; LiveGameRuntimeV2 owns saving.
# The regular live scheduler is never replaced or duplicated.
const PAGE_SIZE := 36
const MAX_PARTY := MapBattleV2.MAX_DISCIPLES
const BATTLE_STEP := MapBattleV2.STEP_SECONDS
const ROLES := ["frontline","ranged","mage","healer","frontline","ranged"]

var game_state: SimulationState
var live_runtime: LiveGameRuntimeV2
var session: HuntingPveRunV2
var selected_ids: Dictionary = {}
var candidates: Array[String] = []
var page := 0
var elapsed := 0.0
var save_ready := true

var zone_choice: OptionButton
var difficulty: HuntingLevelSelectorV2
var roster_root: VBoxContainer
var roster_page_label: Label
var status_label: Label
var battle_view: MapBattleWorldLayerV2
var selection_group: Control
var start_button: Button
var claim_button: Button
var finish_button: Button
var return_button: Button
var retry_save_button: Button

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.055,0.09,0.085,0.98)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)

    battle_view = MapBattleWorldLayerV2.new()
    battle_view.enable_source_vl_art = true
    battle_view.enable_spectator_framing = true
    battle_view.spectator_zoom_ceiling = 1.0
    battle_view.visible = false
    add_child(battle_view)

    var title := _label(self,"SĂN QUÁI · CHIẾN ĐẤU THỰC V2",Vector2(30,14),Vector2(850,38),23)
    title.add_theme_color_override("font_color",Color(0.96,0.85,0.55))
    var exit := _button(self,"ĐÓNG",Vector2(1150,12),Vector2(100,46))
    exit.pressed.connect(_close)

    selection_group = Control.new()
    selection_group.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    selection_group.mouse_filter = Control.MOUSE_FILTER_PASS
    add_child(selection_group)

    zone_choice = OptionButton.new()
    zone_choice.position = Vector2(35,77)
    zone_choice.size = Vector2(465,45)
    selection_group.add_child(zone_choice)
    var regions: Array = HuntingMapV2.REGION_CONTENT.keys()
    regions.sort()
    for region in regions:
        var row: Dictionary = HuntingMapV2.REGION_CONTENT[region]
        zone_choice.add_item(str(row["name"]))
        zone_choice.set_item_metadata(zone_choice.item_count-1,str(region))
    zone_choice.item_selected.connect(_change_region)

    difficulty = HuntingLevelSelectorV2.new()
    difficulty.position = Vector2(35,128)
    difficulty.size = Vector2(465,455)
    selection_group.add_child(difficulty)

    var roster_label := _label(selection_group,"ĐỘI HÌNH · TỐI ĐA 5 ĐỘI × 6",Vector2(530,76),Vector2(405,38),18)
    roster_label.add_theme_color_override("font_color",Color(0.96,0.85,0.55))
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(525,132)
    scroll.size = Vector2(410,423)
    selection_group.add_child(scroll)
    roster_root = VBoxContainer.new()
    roster_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(roster_root)
    _button(selection_group,"◀",Vector2(530,565),Vector2(66,38)).pressed.connect(_page_previous)
    roster_page_label = _label(selection_group,"",Vector2(607,566),Vector2(230,34),14)
    _button(selection_group,"▶",Vector2(842,565),Vector2(66,38)).pressed.connect(_page_next)

    start_button = _button(self,"XUẤT CHINH",Vector2(966,150),Vector2(276,56))
    start_button.pressed.connect(_begin_hunt)
    finish_button = _button(self,"HOÀN TẤT TRẬN",Vector2(966,220),Vector2(276,52))
    finish_button.pressed.connect(_finish_hunt)
    claim_button = _button(self,"NHẬN THƯỞNG",Vector2(966,285),Vector2(276,52))
    claim_button.pressed.connect(_claim_reward)
    return_button = _button(self,"VỀ TÔNG (THUA/HÒA)",Vector2(966,350),Vector2(276,52))
    return_button.pressed.connect(_return_from_finished_hunt)
    retry_save_button = _button(self,"THỬ LƯU LẠI",Vector2(966,414),Vector2(276,52))
    retry_save_button.pressed.connect(_retry_checkpoint)
    status_label = _label(self,"",Vector2(28,615),Vector2(1210,85),16)
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_color_override("font_color",Color(0.94,0.91,0.81))
    _refresh_actions()

func bind_runtime(runtime: LiveGameRuntimeV2) -> void:
    live_runtime = runtime
    game_state = runtime.state() if runtime != null else null
    if game_state == null:
        _say("Chưa có dữ liệu runtime.")
        return
    _gather_candidates()
    if candidates.is_empty():
        _say("Chưa có đệ tử V2 hợp lệ: tuyển đệ tử mới trước khi săn quái.")
    if zone_choice.item_count > 0:
        zone_choice.select(0)
        _change_region(0)
    var ids: Array = game_state.sect.v2_pve_active_runs.keys()
    ids.sort()
    for id in ids:
        var result := HuntingPveRunV2.resume_active(game_state,str(id))
        if bool(result.get("ok",false)):
            session = result["session"]
            for slot in range(zone_choice.item_count):
                if str(zone_choice.get_item_metadata(slot)) == session.region_id:
                    zone_choice.select(slot)
                    _change_region(slot)
                    break
            battle_view.attach_session(session.battle)
            battle_view.set_actor_view_metadata(_source_view_metadata())
            _say("Đã tiếp tục trận có checkpoint: "+str(id))
            break
    _refresh_actions()

# Snapshot level/name metadata is view-only. The real battle strips spawn
# realm coordinates; the original, reproducibly seeded spawn retains them.
func _source_view_metadata() -> Dictionary:
    var rows: Dictionary = {}
    if session == null or game_state == null:
        return rows
    for enemy in session.spawn_data.get("monsters",[]):
        var row: Dictionary = enemy
        rows[str(row["id"])] = {
            "realm_index":int(row.get("realm_index",0)),
            "floor_index":int(row.get("floor_index",0))
        }
    for key in session.battle.actors.keys():
        var actor: Dictionary = session.battle.actors[key]
        if str(actor.get("side","")) != "disciple":
            continue
        if not game_state.disciples.has(StringName(str(key))):
            continue
        var living: DiscipleState = game_state.disciples[StringName(str(key))]
        if not DiscipleRealmProgressV2.progression_ready(living):
            continue
        var progress: Dictionary = living.v2_realm_progress
        var cultivation: Dictionary = progress["cultivation"]
        var body: Dictionary = progress["body"]
        rows[str(key)] = {
            "display_name":str(living.display_name),
            "realm_index":int(cultivation["realm"]),
            "floor_index":int(cultivation["floor"]),
            "body_realm_index":int(body["realm"]),
            "body_floor_index":int(body["floor"])
        }
    return rows

func _change_region(index: int) -> void:
    if game_state == null or index < 0 or index >= zone_choice.item_count:
        return
    var region := str(zone_choice.get_item_metadata(index))
    var answer := difficulty.show_region(game_state,region)
    if not bool(answer.get("ok",false)):
        _say("Không thể tải khu vực: "+str(answer.get("reason","")))
    _refresh_actions()

func _gather_candidates() -> void:
    candidates.clear()
    selected_ids.clear()
    page = 0
    if game_state == null:
        return
    var ids: Array = game_state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var living: DiscipleState = game_state.disciples[raw_id]
        # Never invent a 30x10 realm for legacy non-V2 founders.
        if DiscipleRealmProgressV2.progression_ready(living):
            candidates.append(str(raw_id))
    _render_roster()

func _render_roster() -> void:
    if roster_root == null:
        return
    for child in roster_root.get_children():
        roster_root.remove_child(child)
        child.queue_free()
    var start := page*PAGE_SIZE
    for i in range(start,mini(start+PAGE_SIZE,candidates.size())):
        var id: String = candidates[i]
        var living: DiscipleState = game_state.disciples[StringName(id)]
        var training: Dictionary = living.v2_realm_progress["cultivation"]
        var name := str(living.display_name)+" · "+DiscipleRealmProgressV2.realm_name(
            "cultivation",int(training["realm"]))+" "+str(training["floor"])
        var item := CheckBox.new()
        item.text = name
        item.button_pressed = selected_ids.has(id)
        item.tooltip_text = "Chỉ đệ tử V2 thật; job/Injury/HP được backend kiểm tra lại lúc xuất chinh"
        item.toggled.connect(_toggle_member.bind(id))
        roster_root.add_child(item)
    if roster_page_label != null:
        roster_page_label.text = "%d/%d · Chọn %d/%d" % [
            page+1,maxi(1,int(ceil(float(candidates.size())/float(PAGE_SIZE)))),
            selected_ids.size(),MAX_PARTY
        ]

func _toggle_member(checked: bool, id: String) -> void:
    if checked:
        if selected_ids.size() >= MAX_PARTY:
            _say("Một trận tối đa 30 đệ tử, 6 người mỗi đội.")
            _render_roster()
            return
        selected_ids[id] = true
    else:
        selected_ids.erase(id)
    _render_roster()
    _refresh_actions()

func _page_previous() -> void:
    page = maxi(0,page-1)
    _render_roster()

func _page_next() -> void:
    if (page+1)*PAGE_SIZE < candidates.size():
        page += 1
    _render_roster()

func _begin_hunt() -> void:
    if game_state == null or live_runtime == null or session != null or selected_ids.is_empty():
        _say("Chọn đệ tử V2 hợp lệ trước khi xuất chinh.")
        return
    var zone := str(zone_choice.get_item_metadata(zone_choice.selected))
    var level := HuntingMapV2.selected_level(game_state,zone)
    var chosen := HuntingMapV2.choose_level(game_state,zone,level)
    if not bool(chosen.get("ok",false)):
        _say("Không thể chọn khu vực: "+str(chosen.get("reason","")))
        return
    var ids: Array = selected_ids.keys()
    ids.sort()
    var party: Array = []
    for i in range(ids.size()):
        var id := str(ids[i])
        var entry := {"disciple_id":id,"party_id":"hunt_team_%d" % int(i/6),
            "role":ROLES[i%6],
            "position":Vector2(5.5+float(i%6)*0.68,5.5+float(int(i/6))*1.45)}
        # Canonical realm is read inside HuntingPveRunV2.begin; no forged
        # levels or skill/equipment are copied into this input.
        party.append(entry)
    var stamp := Time.get_ticks_usec()
    var encounter := "live_hunt_%d_%d" % [int(Time.get_unix_time_from_system()),stamp]
    var run := HuntingPveRunV2.new()
    var result := run.begin(game_state,zone,encounter,int(stamp%2000000000)+1,party)
    if not bool(result.get("ok",false)):
        _say("Không thể xuất chinh: "+str(result.get("reason","")))
        return
    session = run
    battle_view.attach_session(run.battle)
    battle_view.set_actor_view_metadata(_source_view_metadata())
    elapsed = 0.0
    if not _checkpoint():
        _say("LỖI LƯU: trận đã khởi tạo trong RAM; tạm dừng để bảo vệ dữ liệu.")
        _refresh_actions()
        return
    _say("Đã vào trận: "+encounter)
    _refresh_actions()

func _process(delta: float) -> void:
    if session == null or not save_ready or not session.battle.active:
        return
    elapsed = minf(elapsed+maxf(0.0,delta),1.0)
    var ticks := 0
    while elapsed >= BATTLE_STEP and ticks < 4 and session.battle.active:
        elapsed -= BATTLE_STEP
        var result := session.advance(true)
        if not bool(result.get("ok",false)):
            save_ready = false
            _say("Trận tạm dừng: "+str(result.get("reason","unknown")))
            _refresh_actions()
            return
        ticks += 1
    if ticks > 0:
        _refresh_battle()
    if not session.battle.active:
        if _checkpoint():
            _say("Kết thúc: "+session.battle.outcome+". Nhấn nhận thưởng nếu chiến thắng.")

func _finish_hunt() -> void:
    if session == null or not save_ready:
        return
    if session.battle.active:
        var result := session.finish()
        if not bool(result.get("ok",false)):
            _say("Chưa thể kết thúc: "+str(result.get("reason","")))
            return
    _refresh_battle()
    if _checkpoint():
        _say("Kết thúc: "+session.battle.outcome+" (đã lưu).")

func _claim_reward() -> void:
    if session == null or session.battle.active or not save_ready:
        return
    var result := session.claim()
    if not bool(result.get("ok",false)):
        _say("Không thể nhận thưởng: "+str(result.get("reason","")))
        return
    # Rewards are credited by HuntingMapV2.claim_reward exactly once,
    # never by this Control. Persist before allowing another encounter.
    if not _checkpoint():
        _say("LỖI LƯU SAU NHẬN THƯỞNG. Không khởi tạo trận khác.")
        _refresh_actions()
        return
    session = null
    battle_view.visible = false
    _gather_candidates()
    _say("Thưởng đã nhập kho: "+str(result.get("items",{})))
    _refresh_actions()

func _return_from_finished_hunt() -> void:
    if session == null or session.battle.active or session.battle.outcome == "win":
        return
    # Defeat/retreat has already been settled by the owned PVE authority.
    # There is no warehouse claim; merely clear the finished screen.
    if not _checkpoint():
        return
    session = null
    battle_view.visible = false
    _gather_candidates()
    _say("Đã trở về tông, không có phần thưởng khi thua hoặc rút lui.")
    _refresh_actions()

func _retry_checkpoint() -> void:
    if _checkpoint():
        _say("Đã lưu checkpoint thành công. Có thể tiếp tục.")
        _refresh_actions()
    else:
        _say("Vẫn không thể lưu. Trận tạm dừng, giữ nguyên dữ liệu trong RAM.")

func _checkpoint() -> bool:
    if live_runtime == null:
        return false
    var saved := live_runtime.save()
    save_ready = bool(saved.get("ok",false))
    if not save_ready:
        push_error("Hunting save refused: "+str(saved))
    return save_ready

func _refresh_battle() -> void:
    if session == null:
        return
    var info := session.battle.summary()
    _say("Trận %s | %.1fs | Đệ tử còn %d | Quái còn %d | %s" % [
        session.battle.encounter_id,float(info["time"]),
        int(info["alive_disciples"]),int(info["alive_monsters"]),session.battle.outcome
    ])
    _refresh_actions()

func _refresh_actions() -> void:
    if selection_group != null:
        selection_group.visible = session == null
    if battle_view != null:
        battle_view.visible = session != null
    if start_button != null:
        start_button.disabled = session != null or selected_ids.is_empty() or not save_ready
    if finish_button != null:
        finish_button.disabled = session == null or not save_ready or not session.battle.active
    if claim_button != null:
        claim_button.disabled = session == null or not save_ready or session.battle.active or session.battle.outcome != "win"
    if return_button != null:
        return_button.disabled = session == null or not save_ready or session.battle.active or session.battle.outcome == "win"
    if retry_save_button != null:
        retry_save_button.disabled = live_runtime == null or save_ready

func _say(message: String) -> void:
    if status_label != null:
        status_label.text = message

func _close() -> void:
    if session != null:
        _checkpoint()
    queue_free()

func _exit_tree() -> void:
    # Closing from another Sect UI entry also preserves the live checkpoint.
    if session != null and live_runtime != null:
        _checkpoint()

func _label(parent: Control, value: String, pos: Vector2, dimensions: Vector2, size: int) -> Label:
    var node := Label.new()
    node.text = value
    node.position = pos
    node.size = dimensions
    node.add_theme_font_size_override("font_size",size)
    parent.add_child(node)
    return node

func _button(parent: Control, value: String, pos: Vector2, dimensions: Vector2) -> Button:
    var node := Button.new()
    node.text = value
    node.position = pos
    node.size = dimensions
    node.add_theme_font_size_override("font_size",16)
    parent.add_child(node)
    return node
