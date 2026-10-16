extends Node2D
## CMB-V4-VP01 — ISOLATED visual fixture, not installed in the live P3.2 scene.
## This lab owns one ephemeral MapBattleV2 object ONLY. No scheduler, save or rewards.
const PilotWorld = preload("res://src/presentation/labs/combat_v4_world_view.gd")
const FIXTURE_SEED := 240416
const VIEW_SIZE := Vector2(1280.0, 720.0)
const ZOOM_MIN := 0.75
const ZOOM_MAX := 1.8

var battle: MapBattleV2
var world: Node2D
var camera: Camera2D
var status: Label
var source_note: Label
var pause_button: Button
var step_accum := 0.0
var event_cursor := 0
var paused := false
var dragging := false
var touches: Dictionary = {}
var prior_pinch_distance := 0.0

func _ready() -> void:
    world = PilotWorld.new()
    world.name = "ReadOnlyCombatView"
    add_child(world)
    camera = Camera2D.new()
    camera.name = "LabCamera"
    camera.position = VIEW_SIZE * 0.5
    camera.zoom = Vector2.ONE
    camera.enabled = true
    add_child(camera)
    _make_hud()
    restart_fixture()

func restart_fixture() -> void:
    # Authentic combat primitives, but a LAB party; never a live DiscipleState.
    var core := CombatStatsV2.derive(2, 1, 2, 1, 0.0)
    if not bool(core.get("ok", false)):
        push_error("CMBV4 core combat stats unavailable")
        return
    var stats: Dictionary = core["stats"]
    var party := [{
        "id": "pilot_female", "party_id": "pilot_team_1",
        "role": "frontline", "position": Vector2(7.5, 10.0),
        "stats": stats.duplicate(true), "hp": float(stats["max_hp"])
    }]
    var wolf := MonsterCatalogueV2.create_actor("thanh_lang", 1, 1, "pilot_wolf")
    var boss := MonsterCatalogueV2.create_actor("hac_lang_vuong", 1, 1, "pilot_boss")
    if not bool(wolf.get("ok", false)) or not bool(boss.get("ok", false)):
        push_error("CMBV4 monster species lookup failed")
        return
    wolf["id"] = "pilot_wolf"
    wolf["position"] = Vector2(25.0, 8.0)
    boss["id"] = "pilot_boss"
    boss["position"] = Vector2(26.5, 12.5)
    battle = MapBattleV2.new(FIXTURE_SEED)
    var setup := battle.setup("CMBV4_LAB_ONLY", party, [wolf, boss])
    if not bool(setup.get("ok", false)):
        push_error("CMBV4 fixture setup rejected: " + str(setup))
        return
    world.call("bind_battle", battle)
    event_cursor = battle.events.size()
    step_accum = 0.0
    paused = false
    if pause_button != null:
        pause_button.text = "Tạm dừng"
    _refresh_hud()

func _process(delta: float) -> void:
    world.call("advance_cosmetics", delta)
    if battle == null or not battle.active or paused:
        return
    # Only the isolated TEST HARNESS advances combat; the view never does.
    step_accum += minf(delta, 0.25)
    if step_accum < MapBattleV2.STEP_SECONDS:
        return
    step_accum -= MapBattleV2.STEP_SECONDS
    var result := battle.step(false)
    if not bool(result.get("ok", false)):
        paused = true
        push_error("CMBV4 fixture step failed: " + str(result))
        return
    var next_events := battle.events.slice(event_cursor)
    event_cursor = battle.events.size()
    world.call("consume_events", next_events)
    world.call("sync_visuals")
    _refresh_hud()

func _make_hud() -> void:
    var canvas := CanvasLayer.new()
    canvas.name = "LabHUD"
    add_child(canvas)
    var overlay := Control.new()
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(overlay)
    var panel := PanelContainer.new()
    panel.position = Vector2(14, 12)
    panel.size = Vector2(1252, 56)
    panel.mouse_filter = Control.MOUSE_FILTER_PASS
    var paper := StyleBoxFlat.new()
    paper.bg_color = Color("#f4ebcf")
    paper.border_color = Color("#a9936b")
    paper.set_border_width_all(2)
    paper.set_corner_radius_all(10)
    panel.add_theme_stylebox_override("panel", paper)
    overlay.add_child(panel)
    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation", 14)
    panel.add_child(top)
    var heading := Label.new()
    heading.text = "THANH TRÚC LÂM   ·   CMB-V4-VP01"
    heading.custom_minimum_size = Vector2(360, 44)
    heading.add_theme_font_size_override("font_size", 19)
    heading.add_theme_color_override("font_color", Color("#3d4b37"))
    top.add_child(heading)
    status = Label.new()
    status.custom_minimum_size = Vector2(410, 44)
    status.add_theme_font_size_override("font_size", 16)
    status.add_theme_color_override("font_color", Color("#5a6448"))
    top.add_child(status)
    pause_button = Button.new()
    pause_button.text = "Tạm dừng"
    pause_button.custom_minimum_size = Vector2(150, 44)
    pause_button.pressed.connect(_toggle_pause)
    top.add_child(pause_button)
    var capture := Button.new()
    capture.text = "Chụp ảnh"
    capture.custom_minimum_size = Vector2(110, 44)
    capture.pressed.connect(_save_godot_screenshot)
    top.add_child(capture)
    var restart := Button.new()
    restart.text = "Chơi lại"
    restart.custom_minimum_size = Vector2(142, 44)
    restart.pressed.connect(restart_fixture)
    top.add_child(restart)
    source_note = Label.new()
    source_note.position = Vector2(24, 657)
    source_note.size = Vector2(1220, 52)
    source_note.add_theme_font_size_override("font_size", 15)
    source_note.add_theme_color_override("font_color", Color("#203a32"))
    source_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(source_note)

func _refresh_hud() -> void:
    if battle == null or status == null:
        return
    status.text = "Auto · %.1fs  |  %s" % [battle.now, battle.outcome]
    if not battle.active:
        status.text += "  — kết quả fixture, KHÔNG có phần thưởng"
    var stage_ready: bool = bool(world.get("stage_art_loaded"))
    var source_loaded: Array = world.get("source_loaded")
    var art: Dictionary = world.get("original_textures")
    var human_art := "STAGE A" if stage_ready else ("ORIGINAL POSE" if art.has("human_idle") else "FALLBACK")
    var jx_ready: bool = bool(world.get("jx_wolf_loaded"))
    var wolves := "JX1 GOC · 5 CLIP (HANG %d, F8 DOI HUONG)" % int(world.get("jx_direction_row")) if jx_ready else ("ORIGINAL POSE" if art.has("wolf_idle") and art.has("boss_idle") else "PLACEHOLDER")
    source_note.text = "2 HƯỚNG + MIRROR · NGƯỜI: %s · SÓI/BOSS: %s · ĐỊA HÌNH: %s · ART POSE CHƯA ANIMATE" % [
        human_art, wolves,
        "%d SOURCE A" % source_loaded.size() if not source_loaded.is_empty() else "procedural"
    ]

func _save_godot_screenshot() -> void:
    # Requires a REAL graphical Godot renderer (not --headless).
    var folder := ProjectSettings.globalize_path("user://cmb_v4_screenshots")
    var mkerr := DirAccess.make_dir_recursive_absolute(folder)
    if mkerr != OK:
        push_error("CMB-V4 screenshot directory failed: " + str(mkerr))
        return
    var safe_time := Time.get_datetime_string_from_system().replace(":", "-")
    var filename := folder.path_join("CMB-V4-%s.png" % safe_time)
    # Wait until the next drawn frame; captures the actual game viewport.
    await RenderingServer.frame_post_draw
    var captured := get_viewport().get_texture().get_image()
    var err := captured.save_png(filename)
    if err == OK:
        print("CMB-V4 REAL GODOT SCREENSHOT: " + filename)
        source_note.text = "ẢNH GODOT ĐÃ LƯU: " + filename
    else:
        push_error("CMB-V4 screenshot failed: " + str(err))

func _toggle_pause() -> void:
    paused = not paused
    pause_button.text = "Tiếp tục" if paused else "Tạm dừng"

func _set_zoom(amount: float, anchor: Vector2) -> void:
    var previous_world := camera.position + (anchor - VIEW_SIZE * 0.5) / camera.zoom
    var value := clampf(camera.zoom.x * amount, ZOOM_MIN, ZOOM_MAX)
    camera.zoom = Vector2.ONE * value
    camera.position = previous_world - (anchor - VIEW_SIZE * 0.5) / camera.zoom
    _clamp_camera()

func _clamp_camera() -> void:
    var half := VIEW_SIZE * 0.5 / camera.zoom
    var left := PilotWorld.MAP_RECT.position.x + half.x
    var right := PilotWorld.MAP_RECT.end.x - half.x
    var top := PilotWorld.MAP_RECT.position.y + half.y
    var bottom := PilotWorld.MAP_RECT.end.y - half.y
    camera.position.x = (left + right) * 0.5 if left > right else clampf(camera.position.x, left, right)
    camera.position.y = (top + bottom) * 0.5 if top > bottom else clampf(camera.position.y, top, bottom)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        var keyboard := event as InputEventKey
        if keyboard.pressed and not keyboard.echo and keyboard.keycode == KEY_F8:
            # Preview 8 SOURCE atlas rows to identify a side profile; Combat V4
            # still uses ONE approved row + mirror after actual screenshot review.
            var row := (int(world.get("jx_direction_row")) + 1) % 8
            world.set("jx_direction_row", row)
            world.call("sync_visuals")
            _refresh_hud()
            return

    if event is InputEventMouseButton:
        var button := event as InputEventMouseButton
        if button.button_index == MOUSE_BUTTON_WHEEL_UP and button.pressed:
            _set_zoom(1.12, button.position)
        elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN and button.pressed:
            _set_zoom(1.0 / 1.12, button.position)
        elif button.button_index == MOUSE_BUTTON_LEFT or button.button_index == MOUSE_BUTTON_MIDDLE:
            dragging = button.pressed
    elif event is InputEventMouseMotion and dragging and touches.is_empty():
        camera.position -= (event as InputEventMouseMotion).relative / camera.zoom
        _clamp_camera()
    elif event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed:
            touches[touch.index] = touch.position
        else:
            touches.erase(touch.index)
        if touches.size() != 2:
            prior_pinch_distance = 0.0
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if not touches.has(drag.index):
            return
        touches[drag.index] = drag.position
        if touches.size() == 1:
            camera.position -= drag.relative / camera.zoom
            _clamp_camera()
        elif touches.size() == 2:
            var ids: Array = touches.keys()
            var a: Vector2 = touches[ids[0]]
            var b: Vector2 = touches[ids[1]]
            var distance := a.distance_to(b)
            if prior_pinch_distance > 1.0:
                _set_zoom(distance / prior_pinch_distance, (a + b) * 0.5)
            prior_pinch_distance = distance
