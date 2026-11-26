extends Node2D
const CATALOG := "res://labs/visual_bridge_v1/vfx_web_catalog_v1.json"
var _entries: Array[Dictionary] = []
var _lab: Node2D
var _paused := false
var _moving := true
var _fx := true
var _bright := false
var _zoomed := false
var _speed := 1.0
var _picker: OptionButton
var _identity: Label
var _provenance: Label
var _pause_button: Button
var _moving_button: Button
var _fx_button: Button
var _bg_button: Button
var _zoom_button: Button
var _version_button: Button
var _version_v2 := true
var _original_projectile_phase := false

func _read_catalog() -> void:
    if not FileAccess.file_exists(CATALOG):
        push_error("WEB_VFX_CATALOG_MISSING")
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
    if not (data is Dictionary) or str(data.get("schema", "")) != "tmb.vfx_web_review_catalog.v1":
        push_error("WEB_VFX_CATALOG_INVALID")
        return
    var entries: Array = data.get("entries", [])
    for row in entries:
        if not (row is Dictionary):
            continue
        var entry: Dictionary = row
        var scene_path := str(entry.get("scene", ""))
        if not scene_path.begins_with("res://labs/") or not scene_path.ends_with(".tscn"):
            continue
        if str(entry.get("id", "")).is_empty() or not ResourceLoader.exists(scene_path):
            continue
        _entries.append(entry)

func _ready() -> void:
    get_window().size = Vector2i(1280, 720)
    _read_catalog()
    if _entries.is_empty():
        push_error("WEB_VFX_NO_VERIFIED_SOURCE_SCENES")
        return
    var canvas := CanvasLayer.new()
    canvas.layer = 15
    add_child(canvas)
    var panel := PanelContainer.new()
    panel.name = "WebReviewControls"
    panel.position = Vector2(1022, 111)
    panel.size = Vector2(238, 498)
    canvas.add_child(panel)
    _version_button = Button.new()
    _version_button.name = "R1EVersionCompare"
    _version_button.position = Vector2(1022,614)
    _version_button.size = Vector2(238,35)
    _version_button.text = "R1E V2 24f  ↔  cũ 12f"
    _version_button.visible = false
    _version_button.pressed.connect(_toggle_version)
    canvas.add_child(_version_button)
    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 5)
    panel.add_child(vbox)
    var header := Label.new()
    header.text = "VFX REVIEW / GODOT WEB"
    header.add_theme_font_size_override("font_size", 15)
    vbox.add_child(header)
    _picker = OptionButton.new()
    _picker.custom_minimum_size = Vector2(216, 36)
    _picker.fit_to_longest_item = false
    _picker.clip_text = true
    for i in range(_entries.size()):
        var e: Dictionary = _entries[i]
        _picker.add_item(str(e.get("school_vi", "")) + " · " + str(e.get("name_vi", "")), i)
    _picker.item_selected.connect(_change_skill)
    vbox.add_child(_picker)
    _identity = Label.new()
    _identity.add_theme_font_size_override("font_size", 13)
    _identity.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _identity.clip_text = true
    _identity.custom_minimum_size = Vector2(205, 0)
    vbox.add_child(_identity)
    _button(vbox, "Thử lại chiêu", _replay)
    _pause_button = _button(vbox, "Tạm dừng", _toggle_pause)
    _moving_button = _button(vbox, "Quái di chuyển: BẬT", _toggle_moving)
    _fx_button = _button(vbox, "Hiện VFX: BẬT", _toggle_fx)
    _bg_button = _button(vbox, "Nền: TỐI", _toggle_bg)
    _zoom_button = _button(vbox, "Actor: 1×", _toggle_zoom)
    var speed_label := Label.new()
    speed_label.text = "Tốc độ 0.25× — 2×"
    vbox.add_child(speed_label)
    var slider := HSlider.new()
    slider.min_value = 0.25
    slider.max_value = 2.0
    slider.step = 0.25
    slider.value = 1.0
    slider.custom_minimum_size = Vector2(205, 23)
    slider.value_changed.connect(_on_speed)
    vbox.add_child(slider)
    var phases := HBoxContainer.new()
    phases.add_theme_constant_override("separation", 3)
    vbox.add_child(phases)
    for cfg in [["Tụ lực", "charge"], ["Thi triển", "release"], ["Tiếp xúc", "contact"]]:
        var btn := Button.new()
        btn.text = str(cfg[0])
        btn.custom_minimum_size = Vector2(69, 31)
        btn.pressed.connect(_seek_phase.bind(str(cfg[1])))
        phases.add_child(btn)
    _provenance = Label.new()
    _provenance.add_theme_font_size_override("font_size", 12)
    _provenance.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _provenance.clip_text = true
    _provenance.custom_minimum_size = Vector2(205, 0)
    _provenance.add_theme_color_override("font_color", Color("f2c978"))
    vbox.add_child(_provenance)
    _change_skill(0)
    # Direct link /vfx/?skill=r1e selects the same canonical Godot Web review,
    # never creates a second build, site, or independent game.
    if OS.has_feature("web") and _entries.size() > 1:
        var query_text: Variant = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('skill')", true)
        var key := str(query_text).strip_edges().to_lower()
        # Preview key selects a specific revision, not merely a skill ID.
        # Existing r1e/r2b links continue to open the original approved source lab.
        if not key.is_empty() and key != "null":
            for i in range(_entries.size()):
                var info: Dictionary = _entries[i]
                var preview_key := str(info.get("preview_key",""))
                var matches := preview_key == key
                if not matches and key.length() == 3 and key.begins_with("s"):
                    matches = preview_key == "sword_factory_batch1_" + key.substr(1)
                if matches:
                    _picker.select(i)
                    _change_skill(i)
                    if key == "r1e":
                        print("VFX_R1E_DEEPLINK=PASS")
                    else:
                        print("VFX_WEB_DEEPLINK=PASS key=",key," id=",str(info.get("id","")))
                    break

func _button(parent: BoxContainer, title: String, callback: Callable) -> Button:
    var control := Button.new()
    control.text = title
    control.custom_minimum_size = Vector2(215, 32)
    control.pressed.connect(callback)
    parent.add_child(control)
    return control

func _change_skill(index: int) -> void:
    if index < 0 or index >= _entries.size():
        return
    var info: Dictionary = _entries[index]
    var scene := load(str(info["scene"])) as PackedScene
    if scene == null:
        push_error("WEB_VFX_SCENE_NOT_FOUND " + str(info["scene"]))
        return
    var candidate := scene.instantiate() as Node2D
    if candidate == null:
        push_error("WEB_VFX_SCENE_NOT_NODE2D")
        return
    var needed := ["review_replay", "review_set_paused", "review_set_moving",
        "review_set_fx", "review_set_bright", "review_set_map_zoom", "review_set_speed"]
    for method in needed:
        if not candidate.has_method(str(method)):
            push_error("WEB_VFX_SCENE_MISSING_REVIEW_CONTRACT " + str(method))
            candidate.free()
            return
    # Data-driven school factory scenes may host multiple skills. Set the
    # selected catalog identity before _ready runs when the scene is attached.
    # Existing standalone review scenes keep their original behavior.
    if candidate.has_method("review_set_skill_id"):
        candidate.call("review_set_skill_id", str(info.get("id", "")))
    if _lab != null:
        remove_child(_lab)
        _lab.queue_free()
    _lab = candidate
    _original_projectile_phase = str(info.get("preview_key","")) in ["r1e","r2b"]
    _lab.name = "SelectedVfxLab"
    add_child(_lab)
    _version_v2 = true
    _version_button.visible = _lab.has_method("review_set_version")
    if _version_button.visible:
        _lab.call("review_set_version","v2")
    _version_button.text = "V2 24f (đang xem) | Chạm: R1E 12f"
    _identity.text = str(info.get("branch_vi", "")) + " · " + str(info.get("tier", "")).to_upper()
    var directions: Array = info.get("directions", [])
    var direction_text := ""
    for i in range(directions.size()):
        if i > 0:
            direction_text += ", "
        direction_text += str(directions[i])
    _provenance.text = "TỰ LẶP • " + str(info.get("review_stages", "3 phase cues")) + "\nHướng thật: " + direction_text + "\n" + \
        str(info.get("vfx_status", "")).replace("_", " ") + " | G3: " + str(info.get("g3_art", "")).replace("_", " ") + \
        "\nOWNER: " + str(info.get("owner_art", "")).replace("_", " ") + "\nKhông combat · PVE HOLD"
    _paused = false
    _moving = true
    _fx = true
    _bright = false
    _zoomed = false
    _speed = 1.0
    _pause_button.text = "Tạm dừng"
    _moving_button.text = "Quái di chuyển: BẬT"
    _fx_button.text = "Hiện VFX: BẬT"
    _bg_button.text = "Nền: TỐI"
    _zoom_button.text = "Actor: 1×"
    _apply()
    print("WEB_VFX_SCENE_LOADED id=", str(info.get("id", "")),
        " status=", str(info.get("vfx_status", "")))

func _apply() -> void:
    if _lab == null: return
    _lab.call("review_set_paused", _paused)
    _lab.call("review_set_moving", _moving)
    _lab.call("review_set_fx", _fx)
    _lab.call("review_set_bright", _bright)
    _lab.call("review_set_map_zoom", _zoomed)
    _lab.call("review_set_speed", _speed)

func _seek_phase(phase: String) -> void:
    if _lab == null:
        return
    _paused = true
    # Original sword labs call the middle phase projectile; Factory uses release.
    var actual_phase := "projectile" if phase == "release" and _original_projectile_phase else phase
    _lab.call("review_seek_phase", actual_phase)
    _pause_button.text = "Tiếp tục"

func _replay() -> void:
    if _lab == null: return
    _paused = false
    _lab.call("review_replay")
    _pause_button.text = "Tạm dừng"
    _apply()

func _toggle_version() -> void:
    if _lab == null or not _lab.has_method("review_set_version"):
        return
    _version_v2 = not _version_v2
    _lab.call("review_set_version","v2" if _version_v2 else "r1e")
    _version_button.text = "V2 24f (đang xem) | Chạm: R1E 12f" if _version_v2 else "R1E 12f (đang xem) | Chạm: V2 24f"
    _paused = false
    _pause_button.text = "Tạm dừng"
    _apply()

func _toggle_pause() -> void:
    _paused = not _paused
    _pause_button.text = "Tiếp tục" if _paused else "Tạm dừng"
    _apply()

func _toggle_moving() -> void:
    _moving = not _moving
    _moving_button.text = "Quái di chuyển: BẬT" if _moving else "Quái di chuyển: TẮT"
    _apply()

func _toggle_fx() -> void:
    _fx = not _fx
    _fx_button.text = "Hiện VFX: BẬT" if _fx else "Hiện VFX: TẮT"
    _apply()

func _toggle_bg() -> void:
    _bright = not _bright
    _bg_button.text = "Nền: SÁNG" if _bright else "Nền: TỐI"
    _apply()

func _toggle_zoom() -> void:
    _zoomed = not _zoomed
    _zoom_button.text = "Actor: 2×" if _zoomed else "Actor: 1×"
    _apply()

func _on_speed(value: float) -> void:
    _speed = value
    _apply()
