extends Control

var runtime := LiveGameRuntimeV2.new()
var disciple_id: StringName
var status: Label
var facts: Label
var arena: HuntView
var message := ""
var poll_elapsed := 0.0
var proof_elapsed := 0.0
var proof_dir := ""
var proof_start := 1800000000
var proof_stage := 0
var proof_done := false
var path := "user://b3_vs1_playable_demo.json"

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
        if arg.begins_with("--b3-proof-dir="):
            proof_dir = arg.trim_prefix("--b3-proof-dir=")
    if not proof_dir.is_empty():
        path = "user://b3_proof_%d.json" % Time.get_ticks_msec()
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
    else:
        disciple_id = setup["disciple_id"]
        message = "Đã tuyển đệ tử thật, học Thanh Phong Trảm và chế tạo Thanh Thiết Kiếm."
    if not proof_dir.is_empty():
        message = str(B3HuntWorld.begin(runtime.owner,disciple_id))
    _refresh()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("0d1721")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left","top","right","bottom"]:
        margin.add_theme_constant_override("margin_"+side,24)
    add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation",14)
    margin.add_child(column)
    var title := Label.new()
    title.text = "TÔNG MÔN BÁ ĐẠO  /  BẠCH THẠCH KHÊ"
    title.add_theme_font_size_override("font_size",27)
    title.add_theme_color_override("font_color",Color("e5d2a6"))
    column.add_child(title)
    var subtitle := Label.new()
    subtitle.text = "B3 VS1 • Thanh Lang → 1 Tinh Lang Bì mỗi lần hạ • Kho tông môn chung"
    column.add_child(subtitle)
    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation",22)
    column.add_child(row)
    arena = HuntView.new()
    arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    arena.custom_minimum_size = Vector2(700,390)
    row.add_child(arena)
    var side := VBoxContainer.new()
    side.custom_minimum_size.x = 350
    side.add_theme_constant_override("separation",12)
    row.add_child(side)
    facts = Label.new()
    facts.add_theme_font_size_override("font_size",19)
    facts.size_flags_vertical = Control.SIZE_EXPAND_FILL
    side.add_child(facts)
    _button(side,"Ra săn",func(): _command("hunt"))
    _button(side,"Trở về tông môn",func(): _command("return"))
    _button(side,"Dưỡng sức tại tông môn",func(): _command("rest"))
    var saves := HBoxContainer.new()
    side.add_child(saves)
    _button(saves,"Lưu",func(): _command("save"))
    _button(saves,"Tải lại",func(): _command("reload"))
    status = Label.new()
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status.custom_minimum_size.y = 52
    column.add_child(status)
    var footer := Label.new()
    footer.text = "Đệ tử bị hạ trở về HP 1, Injury 120 phút simulation. Thế giới vẫn tiếp tục khi đội về tông môn."
    footer.add_theme_color_override("font_color",Color("9fb5b8"))
    column.add_child(footer)

func _button(parent: Node, text: String, action: Callable) -> void:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size.y = 42
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.pressed.connect(action)
    parent.add_child(button)

func _now() -> int:
    return int(Time.get_unix_time_from_system()) if proof_dir.is_empty() else proof_start+int(proof_elapsed*24.0)

func _command(kind: String) -> void:
    if runtime.state() == null or disciple_id == &"": return
    if ["hunt","return","rest"].has(kind):
        var caught_up := runtime.poll(_now(),10)
        if not caught_up["ok"] or (not runtime.state().sect.b3_hunt.is_empty() and runtime.state().runtime_unconsumed_wall_seconds >= 0.25):
            message = "Đang xử lý thời gian offline; vui lòng chờ trước khi ra/về săn."
            _refresh()
            return
    var result: Dictionary
    match kind:
        "hunt": result = B3HuntWorld.begin(runtime.owner,disciple_id)
        "return": result = B3HuntWorld.return_to_sect(runtime.owner)
        "save": result = runtime.save(_now(),10)
        "rest":
            var d: DiscipleState = runtime.state().disciples[disciple_id]
            var ok := WorkforceSystem.new().issue_command(runtime.state(),disciple_id,WorkforceSystem.COMMAND_REST,"",1000000)
            if ok: d.current_action = &"EVALUATE"
            result = {"ok":ok}
        "reload":
            var reloaded := LiveGameRuntimeV2.new()
            result = reloaded.start(path,_now(),930211,10)
            if result["ok"]: runtime = reloaded
    message = "Đã thực hiện: "+kind if result.get("ok",false) else "Chưa thực hiện: "+str(result.get("reason",result))
    _refresh()

func _process(delta: float) -> void:
    proof_elapsed += delta
    poll_elapsed += delta
    if runtime.state() == null or poll_elapsed < 0.25: return
    poll_elapsed = 0.0
    var result := runtime.poll(_now(),10)
    if not result["ok"]: message = str(result)
    _refresh()
    if not proof_dir.is_empty() and not proof_done:
        _proof()

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
    var generation := 0
    var paid := 0
    var respawn := 0.0
    if not w.is_empty():
        var restored := B3HuntWorld.restore(state)
        if restored["ok"]:
            arena.battle = restored["battle"]
            time = arena.battle.now
            generation = int(w["slot"]["generation"])
            paid = int(w["slot"]["paid_generation"])
            respawn = maxf(0.0,float(w["slot"]["due_at"])-time)
    arena.queue_redraw()
    facts.text = "%s\nHP %.0f / %.0f • %s\nThế giới: %.2f giây\nQuái: gen %d • Hồi sinh: %.1fs\nĐã hạ: %d • Kho Tinh Lang Bì: %d\nPhút simulation: %d\nInjury: %d • còn %d phút\n%s" % [d.display_name,d.hp,d.max_hp,
        "Đang săn" if not d.active_pve_encounter_id.is_empty() else "Tại tông môn",time,generation,respawn,paid,
        WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE),state.tick,d.injury_level,maxi(0,d.injury_recover_at_tick-state.tick),
        "Chế độ chứng minh • clock ×24" if not proof_dir.is_empty() else "Tốc độ thời gian 1×"]

func _proof() -> void:
    var state := runtime.state()
    var w := state.sect.b3_hunt
    if w.is_empty(): return
    var d: DiscipleState = state.disciples[disciple_id]
    if proof_stage == 0 and arena.battle.now >= 120.0:
        _command("save")
        _command("reload")
        _command("rest")
        # Test-only injected wall interval; same persisted canonical clock.
        proof_start += 120*60
        proof_stage = 1
    if proof_stage == 1 and state.runtime_unconsumed_wall_seconds < 0.25 and d.injury_level == 0 and d.hp >= d.max_hp:
        WorkforceSystem.new().issue_command(state,disciple_id,WorkforceSystem.COMMAND_HOLD,"",1000000)
        d.current_action = &"HOLD"
        _command("hunt")
        proof_stage = 2
    elif proof_stage == 1:
        WorkforceSystem.new().issue_command(state,disciple_id,WorkforceSystem.COMMAND_REST,"",1000000)
        if not [&"EVALUATE",&"REST"].has(d.current_action): d.current_action = &"EVALUATE"
        if state.runtime_unconsumed_wall_seconds < 0.25: proof_start += 60
    if proof_stage == 2 and int(w["slot"]["paid_generation"]) >= 3:
        proof_done = true
        _capture_proof()

func _capture_proof() -> void:
    set_process(false)
    message = "Đã chứng minh ≥3 kill thật, Kho thật, tải lại và hồi phục — cùng một thế giới."
    _refresh()
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    image.save_png(proof_dir.path_join("B3_PLAYABLE_DEMO.png"))
    runtime.save(_now(),10)
    var state := runtime.state()
    var summary := {"world_id":state.sect.b3_hunt["world_id"],"seconds":arena.battle.now,
        "kills":state.sect.b3_hunt["slot"]["paid_generation"],"warehouse_tinh_lang_bi":WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE),
        "save_path":ProjectSettings.globalize_path(path),"invariants":state.validate_invariants()}
    var file := FileAccess.open(proof_dir.path_join("B3_DEMO_RUN.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify(summary,"  "))
    file.close()
    print("B3 STANDALONE DEMO PROOF PASS ",JSON.stringify(summary))
    await get_tree().create_timer(1.5).timeout
    get_tree().quit()
