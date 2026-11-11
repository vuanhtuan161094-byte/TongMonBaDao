extends Control

const POISON_MANIFEST_PATH := "res://labs/combat_lab/assets/nu_doc_tu_grok_01/manifest.json"
const CLIPS := ["idle", "walk", "cast", "attack", "hit", "defeated"]
const CLIP_LABELS := {
    "idle": "Idle",
    "walk": "Walk",
    "cast": "Cast",
    "attack": "Attack",
    "hit": "Hit",
    "defeated": "Defeated"
}

var _poison_manifest: Dictionary = {}
var _poison_frames: Array[Texture2D] = []
var _poison_preview: TextureRect
var _poison_status: Label
var _frame_label: Label
var _candidate_previews: Array[TextureRect] = []
var _active_clip := "idle"
var _frame_index := 0
var _fps := 10.0
var _playback_rate := 1.0
var _playing := true
var _elapsed := 0.0


func _ready() -> void:
    _poison_manifest = _read_json(POISON_MANIFEST_PATH)
    _build_ui()
    _select_clip("idle")
    print("AS_CHAR_FAMILY_PREVIEW_READY clip=%s" % _active_clip)


func _process(delta: float) -> void:
    if not _playing or _poison_frames.is_empty():
        return
    _elapsed += delta * _playback_rate
    var interval := 1.0 / maxf(_fps, 1.0)
    if _elapsed < interval:
        return
    var steps := int(_elapsed / interval)
    _elapsed -= float(steps) * interval
    _frame_index = (_frame_index + steps) % _poison_frames.size()
    _show_current_frame()


func _read_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if parsed is Dictionary else {}


func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color("#101018")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 22)
    margin.add_theme_constant_override("margin_right", 22)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 16)
    add_child(margin)

    var page := VBoxContainer.new()
    page.add_theme_constant_override("separation", 10)
    margin.add_child(page)

    var title := Label.new()
    title.text = "AS-CHAR · DISCIPLE FAMILY REVIEW"
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color("#e3c77a"))
    page.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Issue #77 · 1280×720 · isolated preview · no gameplay authority"
    subtitle.add_theme_font_size_override("font_size", 14)
    subtitle.add_theme_color_override("font_color", Color("#aaa9bb"))
    page.add_child(subtitle)

    var cards := HBoxContainer.new()
    cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
    cards.add_theme_constant_override("separation", 12)
    page.add_child(cards)
    cards.add_child(_make_poison_card())
    cards.add_child(_make_candidate_card(
        "MALE SWORD CULTIVATOR",
        "CANDIDATE · static 4-view sheet · edge review required",
        "res://labs/character_family/assets/candidate_male_swordsman_4view.png"
    ))
    cards.add_child(_make_candidate_card(
        "FEMALE HEALER",
        "CANDIDATE · static 4-view sheet · no clips authored",
        "res://labs/character_family/assets/candidate_female_healer_4view.png"
    ))

    var controls := HBoxContainer.new()
    controls.add_theme_constant_override("separation", 8)
    page.add_child(controls)
    controls.add_child(_make_button("Pause / Play", _toggle_playback))
    controls.add_child(_make_button("Restart", _restart_clip))
    controls.add_child(_make_button("0.5×", _set_rate.bind(0.5)))
    controls.add_child(_make_button("1×", _set_rate.bind(1.0)))
    controls.add_child(_make_button("1.5×", _set_rate.bind(1.5)))
    controls.add_child(_make_button("2×", _set_rate.bind(2.0)))
    controls.add_child(_make_button("Zoom 0.75×", _set_zoom.bind(0.75)))
    controls.add_child(_make_button("Zoom 1×", _set_zoom.bind(1.0)))
    controls.add_child(_make_button("Zoom 1.35×", _set_zoom.bind(1.35)))

    var footer := Label.new()
    footer.text = "Poison atlas: stored frames only; source videos unavailable. New turnarounds are static candidates; no fake motion or production import."
    footer.add_theme_font_size_override("font_size", 12)
    footer.add_theme_color_override("font_color", Color("#c7c5d3"))
    page.add_child(footer)


func _make_poison_card() -> PanelContainer:
    var panel := _make_panel()
    var body := VBoxContainer.new()
    body.add_theme_constant_override("separation", 6)
    panel.add_child(body)

    body.add_child(_make_heading("NU DOC TU · EXISTING ATLAS"))
    body.add_child(_make_small_label("Locked master: BLOCKED_SOURCE_ART · atlas is visual-only, not a 4-view master."))

    var frame := Control.new()
    frame.custom_minimum_size = Vector2(350, 304)
    frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    frame.clip_contents = true
    body.add_child(frame)

    _poison_preview = TextureRect.new()
    _poison_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _poison_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _poison_preview.size = Vector2(220, 268)
    _poison_preview.position = (frame.custom_minimum_size - _poison_preview.size) * 0.5
    _poison_preview.pivot_offset = _poison_preview.size * 0.5
    frame.add_child(_poison_preview)

    _poison_status = _make_small_label("Loading atlas…")
    body.add_child(_poison_status)
    _frame_label = _make_small_label("frame —")
    body.add_child(_frame_label)

    var clip_grid := GridContainer.new()
    clip_grid.columns = 3
    clip_grid.add_theme_constant_override("h_separation", 6)
    clip_grid.add_theme_constant_override("v_separation", 4)
    body.add_child(clip_grid)
    for clip_id in CLIPS:
        var button := Button.new()
        button.text = str(CLIP_LABELS[clip_id])
        button.custom_minimum_size = Vector2(92, 30)
        button.pressed.connect(_select_clip.bind(clip_id))
        clip_grid.add_child(button)

    return panel


func _make_candidate_card(title_text: String, status_text: String, resource_path: String) -> PanelContainer:
    var panel := _make_panel()
    var body := VBoxContainer.new()
    body.add_theme_constant_override("separation", 6)
    panel.add_child(body)

    body.add_child(_make_heading(title_text))
    body.add_child(_make_small_label(status_text))

    var frame := Control.new()
    frame.custom_minimum_size = Vector2(350, 304)
    frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    frame.clip_contents = true
    body.add_child(frame)

    var texture_rect := TextureRect.new()
    texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    texture_rect.size = Vector2(285, 285)
    texture_rect.position = (frame.custom_minimum_size - texture_rect.size) * 0.5
    texture_rect.pivot_offset = texture_rect.size * 0.5
    var texture := load(resource_path) as Texture2D
    if texture != null:
        texture_rect.texture = texture
    else:
        body.add_child(_make_small_label("Asset missing: %s" % resource_path))
    frame.add_child(texture_rect)
    _candidate_previews.append(texture_rect)

    body.add_child(_make_small_label("Four static views: front / right / back / left"))
    body.add_child(_make_small_label("No rig, idle, walk, or combat clip is claimed."))
    return panel


func _make_panel() -> PanelContainer:
    var panel := PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.custom_minimum_size = Vector2(385, 465)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#1b1b27")
    style.border_color = Color("#514761")
    style.set_border_width_all(1)
    style.set_corner_radius_all(8)
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    panel.add_theme_stylebox_override("panel", style)
    return panel


func _make_heading(text_value: String) -> Label:
    var label := Label.new()
    label.text = text_value
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", Color("#e0c579"))
    label.clip_text = true
    return label


func _make_small_label(text_value: String) -> Label:
    var label := Label.new()
    label.text = text_value
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", Color("#c3c0cf"))
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return label


func _make_button(text_value: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(88, 30)
    button.add_theme_font_size_override("font_size", 12)
    button.pressed.connect(callback)
    return button


func _select_clip(clip_id: String) -> void:
    if not CLIPS.has(clip_id):
        return
    var animations: Dictionary = _poison_manifest.get("animations", {})
    var clip_info: Dictionary = animations.get(clip_id, {})
    if clip_info.is_empty():
        _poison_frames.clear()
        if _poison_status != null:
            _poison_status.text = "Clip manifest missing: %s" % clip_id
        return
    var resource_path := str(clip_info.get("sheet", ""))
    var atlas := load(resource_path) as Texture2D
    if atlas == null:
        _poison_frames.clear()
        _poison_status.text = "Atlas missing: %s" % resource_path
        return

    _poison_frames.clear()
    var width := int(clip_info.get("cell_width", 0))
    var height := int(clip_info.get("cell_height", 0))
    var columns := int(clip_info.get("columns", 0))
    var frame_count := int(clip_info.get("frames", 0))
    if width <= 0 or height <= 0 or columns <= 0 or frame_count <= 0:
        _poison_status.text = "Invalid frame metadata: %s" % clip_id
        return

    for frame_index in range(frame_count):
        var atlas_frame := AtlasTexture.new()
        atlas_frame.atlas = atlas
        var row := floori(float(frame_index) / float(columns))
        atlas_frame.region = Rect2(
            float((frame_index % columns) * width),
            float(row * height),
            float(width),
            float(height)
        )
        _poison_frames.append(atlas_frame)

    _active_clip = clip_id
    _fps = float(clip_info.get("playback_fps", 10))
    _frame_index = 0
    _elapsed = 0.0
    _playing = true
    _show_current_frame()
    _poison_status.text = "%s · %d stored frames · %.1f fps · three-quarter-right" % [
        str(CLIP_LABELS[clip_id]), frame_count, _fps
    ]
    print("AS_CHAR_CLIP_LOADED id=%s frames=%d fps=%.1f" % [clip_id, frame_count, _fps])


func _show_current_frame() -> void:
    if _poison_preview == null or _poison_frames.is_empty():
        return
    _poison_preview.texture = _poison_frames[_frame_index]
    if _frame_label != null:
        _frame_label.text = "frame %d / %d" % [_frame_index + 1, _poison_frames.size()]


func _toggle_playback() -> void:
    _playing = not _playing


func _restart_clip() -> void:
    _frame_index = 0
    _elapsed = 0.0
    _show_current_frame()


func _set_rate(rate: float) -> void:
    _playback_rate = rate


func _set_zoom(value: float) -> void:
    if _poison_preview != null:
        _poison_preview.scale = Vector2.ONE * value
    for preview in _candidate_previews:
        preview.scale = Vector2.ONE * value

