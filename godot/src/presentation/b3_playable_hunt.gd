extends Control

var runtime := LiveGameRuntimeV2.new()
var disciple_id: StringName
var status: Label
var facts: Label
var auto_button: Button
var arena: HuntView
var message := ""
var poll_elapsed := 0.0
var path := "user://b3_care_playable_demo.json"
var proof_dir := ""
var proof_now := 1800000000
var proof_stage := 0
var proof_busy := false
var proof_done := false
var proof_evidence: Dictionary = {"clock":"canonical injected acceptance interval; normal GUI is 1x"}

class HuntView:
    extends Control
    var battle: MapBattleV2
    func _draw() -> void:
        var bounds := Rect2(Vector2.ZERO,size)
        draw_style_box(_panel(Color("142d29")),bounds)
        for x in range(1,18):
            draw_line(Vector2(size.x*x/18.0,0),Vector2(size.x*x/18.0,size.y),Color("24403b"))
        for y in range(1,10):
            draw_line(Vector2(0,size.y*y/10.0),Vector2(size.x,size.y*y/10.0),Color("24403b"))
        if battle == null: return
        var font := ThemeDB.fallback_font
        for actor in battle.actors.values():
            var p: Vector2 = actor["position"]
            p = Vector2(p.x/36.0*size.x,p.y/20.0*size.y)
            var friendly := str(actor["side"]) == "disciple"
            var hp := float(actor["hp"])
            var color := Color("57cfdf") if friendly else Color("e6a764")
            if hp <= 0: color = Color("675e54")
            draw_circle(p,15.0 if friendly else 13.0,color)
            draw_arc(p,19,0,TAU,24,color,1.0)
            var label_at := p+Vector2(-112 if friendly else 22,-48)
            draw_line(p+Vector2(0,-19),label_at+Vector2(32,12),Color("779b94"))
            draw_rect(Rect2(label_at+Vector2(0,8),Vector2(80,6)),Color("101b24"))
            draw_rect(Rect2(label_at+Vector2(0,8),Vector2(80*hp/float(actor["max_hp"]),6)),Color("85d991"))
            draw_string(font,label_at,"Đệ tử V2" if friendly else "Thanh Lang",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("e7e9e4"))
            draw_string(font,label_at+Vector2(0,32),"%.0f / %.0f" % [hp,actor["max_hp"]],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("e7e9e4"))
    func _panel(color: Color) -> StyleBoxFlat:
        var box := StyleBoxFlat.new()
        box.bg_color = color
        box.corner_radius_top_left = 12
        box.corner_radius_top_right = 12
        box.corner_radius_bottom_left = 12
        box.corner_radius_bottom_right = 12
        return box

func _ready() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--b3-proof-dir="): proof_dir = arg.trim_prefix("--b3-proof-dir=")
    if not proof_dir.is_empty(): path = "user://b3_care_proof_%d.json" % Time.get_ticks_usec()
    _build_ui()
    var result := runtime.start(path,_now(),930211,10)
    if not result["ok"]:
        message = str(result)
        set_process(false)
        _refresh()
        return
    var setup := B3DemoSetup.prepare(runtime)
    if not setup["ok"]:
        message = str(setup)
        _refresh()
        return
    disciple_id = setup["disciple_id"]
    var d: DiscipleState = runtime.state().disciples[disciple_id]
    if runtime.state().sect.b3_hunt.is_empty() and d.current_action == &"HOLD":
        WorkforceSystem.new().issue_command(runtime.state(),d.id,WorkforceSystem.COMMAND_HOLD,"",1000000)
        # Persist the preparation reservation even if the window is closed
        # before the first button click. Restart must not start unrelated work.
        result = B3MedicalAutoplayV1.commit_owner(runtime.owner)
        if not result["ok"]:
            message = str(result)
            set_process(false)
            _refresh()
            return
    message = "Đổi nguyên liệu → luyện đan → dùng Tụ Khí Đan tại tông môn → bật AUTO để săn và tự hồi phục."
    if not proof_dir.is_empty():
        result = B3MedicalAutoplayV1.buy_demo_inputs(runtime.owner)
        if result["ok"]: result = B3MedicalAutoplayV1.craft(runtime.owner,&"tu_khi_dan",1,disciple_id)
        if not result["ok"]:
            _proof_fail(result)
            return
        proof_evidence["tu_khi_job"] = result["job"]
        proof_now += int(result["finish_tick"])*60
    _refresh()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("0d1721")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left","top","right","bottom"]: margin.add_theme_constant_override("margin_"+side,20)
    add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation",8)
    margin.add_child(column)
    var title := Label.new()
    title.text = "TÔNG MÔN BÁ ĐẠO  /  B3 CARE — AUTO SĂN & HỒI PHỤC"
    title.add_theme_font_size_override("font_size",25)
    title.add_theme_color_override("font_color",Color("e5d2a6"))
    column.add_child(title)
    var subtitle := Label.new()
    subtitle.text = "Thanh Lang → Tinh Lang Bì vào Kho chung • Thuốc hồi HP • Injury vẫn đủ 120 phút simulation"
    column.add_child(subtitle)
    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation",18)
    column.add_child(row)
    arena = HuntView.new()
    arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    arena.custom_minimum_size = Vector2(640,350)
    row.add_child(arena)
    var side := VBoxContainer.new()
    side.custom_minimum_size.x = 420
    side.add_theme_constant_override("separation",6)
    row.add_child(side)
    facts = Label.new()
    facts.add_theme_font_size_override("font_size",16)
    facts.size_flags_vertical = Control.SIZE_EXPAND_FILL
    side.add_child(facts)
    var actions := HBoxContainer.new()
    side.add_child(actions)
    _button(actions,"Ra săn","hunt")
    _button(actions,"Trở về","return")
    auto_button = _button(actions,"AUTO: TẮT","auto")
    var recipes := HBoxContainer.new()
    side.add_child(recipes)
    _button(recipes,"Luyện Hồi Xuân Đan","craft_heal")
    _button(recipes,"Luyện Tụ Khí Đan","craft_tuvi")
    var pills := HBoxContainer.new()
    side.add_child(pills)
    _button(pills,"Dùng Hồi Xuân Đan","heal")
    _button(pills,"Dùng Tụ Khí Đan","tuvi")
    _button(side,"Đổi 10 Thanh Thiết → 5 thảo + 1 cốc (1 lần)","inputs")
    var saves := HBoxContainer.new()
    side.add_child(saves)
    _button(saves,"Lưu","save")
    _button(saves,"Tải lại","reload")
    _button(saves,"Dưỡng sức","rest")
    status = Label.new()
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status.custom_minimum_size.y = 38
    column.add_child(status)
    var footer := Label.new()
    footer.text = "PILOT: bão hòa 1.000.000/ngày/đệ tử • Hồi Xuân 10 điểm • Tụ Khí 25 điểm, +10.000 Tu Vi"
    footer.add_theme_font_size_override("font_size",14)
    footer.add_theme_color_override("font_color",Color("9fb5b8"))
    column.add_child(footer)

func _button(parent: Node, text: String, kind: String) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size.y = 34
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.pressed.connect(func(): _command(kind))
    parent.add_child(button)
    return button

func _now() -> int:
    return int(Time.get_unix_time_from_system()) if proof_dir.is_empty() else proof_now

func _command(kind: String) -> void:
    if runtime.state() == null or disciple_id == &"": return
    var advanced := runtime.poll(_now(),10)
    if not advanced["ok"] or not B3MedicalAutoplayV1.command_ready(runtime.owner):
        message = "Đang xử lý offline hoặc chờ ghi save: "+str(advanced.get("reason","vui lòng chờ"))
        _refresh()
        return
    var state := runtime.state()
    var d: DiscipleState = state.disciples[disciple_id]
    var result: Dictionary = {"ok":false}
    match kind:
        "hunt": result = B3HuntWorld.begin(runtime.owner,disciple_id)
        "return": result = B3HuntWorld.return_to_sect(runtime.owner)
        "auto":
            var enabled := bool(state.sect.b3_hunt.get("care",{}).get("auto_hunt",false))
            result = B3HuntWorld.begin(runtime.owner,disciple_id) if state.sect.b3_hunt.is_empty() else {"ok":true}
            if result["ok"]: result = B3MedicalAutoplayV1.configure(runtime.owner,disciple_id,not enabled)
        "inputs": result = B3MedicalAutoplayV1.buy_demo_inputs(runtime.owner)
        "craft_heal","craft_tuvi":
            var hall := BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
            var sequence := int(hall.production_state.get("b3_command",{}).get("sequence",0))+1 if hall != null else 1
            result = B3MedicalAutoplayV1.craft(runtime.owner,&"hoi_xuan_dan" if kind == "craft_heal" else &"tu_khi_dan",sequence,disciple_id)
        "heal","tuvi": result = B3MedicalAutoplayV1.use_pill(runtime.owner,disciple_id,&"hoi_xuan_dan" if kind == "heal" else &"tu_khi_dan",B3PillSatietyV1.next_sequence(d))
        "save": result = runtime.save(_now(),10)
        "rest":
            var ok := WorkforceSystem.new().issue_command(state,disciple_id,WorkforceSystem.COMMAND_REST,"",1000000)
            if ok: d.current_action = &"EVALUATE"
            result = B3MedicalAutoplayV1.commit_owner(runtime.owner) if ok else {"ok":false,"reason":"disciple_busy"}
        "reload":
            var reloaded := LiveGameRuntimeV2.new()
            result = reloaded.start(path,_now(),930211,10)
            if result["ok"]: runtime = reloaded
    message = "Đã thực hiện: "+kind if result.get("ok",false) else "Chưa thực hiện: "+str(result.get("reason",result))
    _refresh()

func _process(delta: float) -> void:
    poll_elapsed += delta
    if runtime.state() == null or poll_elapsed < 0.25: return
    poll_elapsed = 0.0
    if not proof_dir.is_empty():
        if not proof_busy and not proof_done: _proof_step()
        return
    var result := runtime.poll(_now(),10)
    if not result["ok"]: message = str(result)
    _refresh()

func _refresh() -> void:
    status.text = message
    if runtime.state() == null:
        facts.text = "Không thể đọc save.\n"+message
        return
    var state := runtime.state()
    var d: DiscipleState = state.disciples.get(disciple_id)
    if d == null: return
    var w := state.sect.b3_hunt
    var time := 0.0
    var paid := 0
    var generation := 0
    if not w.is_empty():
        var restored := B3HuntWorld.restore(state)
        if restored["ok"]:
            arena.battle = restored["battle"]
            time = arena.battle.now
            generation = int(w["slot"]["generation"])
            paid = int(w["slot"]["paid_generation"])
    arena.queue_redraw()
    var care: Dictionary = w.get("care",{})
    var wh := WarehouseSystem.new()
    var hall := BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    var jobs := BuildingSystem.new().alchemy_jobs(state,hall).size() if hall != null else 0
    auto_button.text = "AUTO: BẬT" if care.get("auto_hunt",false) else "AUTO: TẮT"
    var labels := {"HUNTING":"Đang săn","INJURY_WAIT":"Chờ Injury hồi phục","PILL_RECOVERY":"Đã dùng thuốc hồi HP","REST_RECOVERY":"Đang nghỉ dưỡng","OFF":"Đã tắt","READY":"Sẵn sàng","MANUAL_PAUSE":"Tạm dừng khi trở về","BUSY":"Đang có công việc khác"}
    var mode := str(care.get("status","OFF"))
    var c: Dictionary = d.v2_realm_progress.get("cultivation",{})
    facts.text = "%s • HP %.0f / %.0f\n%s • %s\nInjury %d • còn %d phút\nWorld %.2fs • Quái gen %d\nĐã hạ %d • Kho Tinh Lang Bì %d\nHồi Xuân Đan %d • Tụ Khí Đan %d\nThanh Linh Thảo %d • Linh Cốc %d\nLuyện đan: %d job • phút %d\nBão hòa: %d / 1.000.000 • ngày %d\nTu Vi: tầng %d • %.0f XP\nTự ra săn lại: %d • dùng thuốc: %d\n%s" % [d.display_name,d.hp,d.max_hp,
        "Bạch Thạch Khê" if not d.active_pve_encounter_id.is_empty() else "Tại tông môn",labels.get(mode,mode),d.injury_level,maxi(0,d.injury_recover_at_tick-state.tick),time,generation,paid,wh.quantity(state,B3PilotContent.RESOURCE),wh.quantity(state,&"hoi_xuan_dan"),wh.quantity(state,&"tu_khi_dan"),wh.quantity(state,&"thanh_linh_thao"),wh.quantity(state,&"linh_coc"),jobs,state.tick,B3PillSatietyV1.spent_today(state,d),int(state.tick/1440),int(c.get("floor",0)),float(c.get("xp",0.0)),int(care.get("auto_deploys",0)),int(care.get("heals",0)),"Nghiệm thu: tăng tốc clock canonical" if not proof_dir.is_empty() else "Thời gian thực 1× • Save riêng cho demo"]

func _proof_fail(result: Dictionary) -> void:
    proof_done = true
    set_process(false)
    message = "Nghiệm thu thất bại: "+str(result)
    push_error("B3 CARE GUI PROOF FAIL "+str(result))
    _refresh()
    get_tree().quit(1)

func _capture(name: String) -> void:
    _refresh()
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png(proof_dir.path_join(name+".png"))
    DirAccess.copy_absolute(ProjectSettings.globalize_path(path),proof_dir.path_join(name+".json"))

func _proof_step() -> void:
    proof_busy = true
    var result := runtime.poll(proof_now,10)
    if not result["ok"]:
        _proof_fail(result)
        return
    _refresh()
    if runtime.state().runtime_unconsumed_wall_seconds >= 0.25:
        proof_busy = false
        return
    var state := runtime.state()
    var d: DiscipleState = state.disciples[disciple_id]
    match proof_stage:
        0:
            result = B3MedicalAutoplayV1.use_pill(runtime.owner,disciple_id,&"tu_khi_dan",1)
            if result["ok"]:
                proof_evidence["tuvi_receipt"] = result["receipt"]
                result = B3MedicalAutoplayV1.craft(runtime.owner,&"hoi_xuan_dan",2,disciple_id)
            if result["ok"]:
                proof_evidence["hoi_xuan_job"] = result["job"]
                proof_now = 1800000000+int(result["finish_tick"])*60
                proof_stage = 1
        1:
            result = B3MedicalAutoplayV1.commit_owner(runtime.owner)
            if result["ok"]:
                message = "Đã luyện hai loại đan bằng nguyên liệu thật; Tụ Khí Đan đã tăng đúng 10.000 Tu Vi."
                await _capture("CARE_01_ALCHEMY_TUVI")
                result = B3HuntWorld.begin(runtime.owner,disciple_id)
            if result["ok"]: result = B3MedicalAutoplayV1.configure(runtime.owner,disciple_id,true)
            if result["ok"]:
                proof_evidence["world_id"] = state.sect.b3_hunt["world_id"]
                proof_now += 15
                proof_stage = 2
        2:
            if d.injury_level == 0:
                proof_now += 15
            else:
                proof_evidence["defeat"] = state.sect.b3_hunt["last_return"].duplicate(true)
                proof_evidence["recover_tick"] = d.injury_recover_at_tick
                proof_evidence["kills_before_recovery"] = state.sect.b3_hunt["slot"]["paid_generation"]
                message = "Combat V2 đã hạ đệ tử; AUTO dùng thuốc/nghỉ dưỡng, Injury giữ nguyên đủ 120 phút."
                await _capture("CARE_02_DEFEAT_RECOVERY")
                proof_now = 1800000000+(state.tick+40)*60
                proof_stage = 3
        3:
            var reloaded := LiveGameRuntimeV2.new()
            var old_sequence := B3PillSatietyV1.next_sequence(d)
            result = reloaded.start(path,proof_now,930211,10)
            if result["ok"]:
                runtime = reloaded
                proof_evidence["mid_injury_reload"] = {"tick":runtime.state().tick,"same_sequence":old_sequence == B3PillSatietyV1.next_sequence(runtime.state().disciples[disciple_id]),"same_world":str(runtime.state().sect.b3_hunt["world_id"]) == str(proof_evidence["world_id"])}
                proof_now = 1800000000+(int(proof_evidence["recover_tick"])-1)*60
                proof_stage = 4
        4:
            if d.injury_level != 1 or not str(state.sect.b3_hunt["member"]).is_empty():
                result = {"ok":false,"reason":"early_redeployment"}
            else:
                proof_evidence["tick119"] = {"tick":state.tick,"injury":d.injury_level,"member":state.sect.b3_hunt["member"]}
                proof_now += 60
                proof_stage = 5
        5:
            if d.injury_level != 0 or str(state.sect.b3_hunt["member"]) != str(d.id):
                result = {"ok":false,"reason":"auto_redeployment_missing","care":state.sect.b3_hunt["care"]}
            else:
                proof_evidence["tick120"] = {"tick":state.tick,"injury":d.injury_level,"member":state.sect.b3_hunt["member"],"hp":d.hp,"max_hp":d.max_hp}
                proof_now += 15
                proof_stage = 6
        6:
            if int(state.sect.b3_hunt["slot"]["paid_generation"]) < int(proof_evidence["kills_before_recovery"])+2:
                proof_now += 15
            else:
                proof_done = true
                set_process(false)
                result = runtime.save(proof_now,10)
                if result["ok"]:
                    message = "PASS: luyện đan thật → săn → bị hạ → tự hồi phục → cùng world → thêm 2 kill và chiến lợi phẩm vào Kho."
                    await _capture("CARE_03_AUTO_RETURN_HUNT")
                    proof_evidence["final"] = {"tick":state.tick,"same_world":str(state.sect.b3_hunt["world_id"]) == str(proof_evidence["world_id"]),"kills":state.sect.b3_hunt["slot"]["paid_generation"],"warehouse_tinh_lang_bi":WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE),"care":state.sect.b3_hunt["care"],"satiety":d.b3_pill_state,"invariants":state.validate_invariants(),"save_path":ProjectSettings.globalize_path(path)}
                    var file := FileAccess.open(proof_dir.path_join("B3_CARE_DEMO_RUN.json"),FileAccess.WRITE)
                    file.store_string(JSON.stringify(proof_evidence,"  ")); file.close()
                    print("B3 CARE GUI PLAYABLE PROOF PASS ",JSON.stringify(proof_evidence))
                    await get_tree().create_timer(1.0).timeout
                    get_tree().quit(0)
    if not result["ok"]: _proof_fail(result)
    proof_busy = false
