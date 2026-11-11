
extends Control

const MANIFEST_PATH := "res://labs/character_family/assets/nu_doc_tu_v4_candidate/manifest.json"
const DIRECTIONS := ["front", "left", "right", "back"]
const CLIP_IDS := ["idle", "walk", "cast", "attack", "hit", "death"]
const CELL_WIDTH := 320
const CELL_HEIGHT := 384
const ZOOM_OPTIONS := [
	{"label": "Game ~69 px", "scale": 0.18},
	{"label": "1x", "scale": 1.0},
	{"label": "2x", "scale": 2.0},
	{"label": "4x", "scale": 4.0},
	{"label": "6x", "scale": 6.0}
]

var _manifest: Dictionary = {}
var _files_by_id: Dictionary = {}
var _atlas: Texture2D
var _clip_id := "idle"
var _direction := "front"
var _frame_index := 0
var _frame_count := 1
var _fps := 0.0
var _speed := 1.0
var _zoom := 0.18
var _elapsed := 0.0
var _playing := false
var _stage: Control
var _sprite: TextureRect
var _status: Label
var _clip_status: Label
var _frame_status: Label
var _zoom_status: Label
var _speed_status: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_load_manifest()
	_select_clip("idle")
	print("POISON_V4_CANDIDATE_PREVIEW_READY")

func _process(delta: float) -> void:
	if not _playing or _fps <= 0.0 or _frame_count <= 1:
		return
	_elapsed += delta * _speed
	var frame_duration := 1.0 / _fps
	while _elapsed >= frame_duration:
		_elapsed -= frame_duration
		if _frame_index + 1 < _frame_count:
			_frame_index += 1
		elif bool(_manifest.get("clips", {}).get(_clip_id, {}).get("loop", false)):
			_frame_index = 0
		else:
			_playing = false
			break
		_show_frame()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#111514")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "NỮ ĐỘC TU V4 · REVIEW CANDIDATE"
	title.add_theme_font_size_override("font_size", 24)
	layout.add_child(title)

	_status = Label.new()
	_status.text = "CANDIDATE_NOT_FOR_PRODUCTION · no gameplay or VFX events"
	layout.add_child(_status)

	var clip_row := HBoxContainer.new()
	clip_row.add_theme_constant_override("separation", 5)
	layout.add_child(clip_row)
	for clip_id in CLIP_IDS:
		var button := Button.new()
		button.text = clip_id.capitalize()
		button.pressed.connect(_select_clip.bind(clip_id))
		clip_row.add_child(button)

	var direction_row := HBoxContainer.new()
	direction_row.add_theme_constant_override("separation", 5)
	layout.add_child(direction_row)
	for direction in DIRECTIONS:
		var button := Button.new()
		button.text = direction.capitalize()
		button.pressed.connect(_select_direction.bind(direction))
		direction_row.add_child(button)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 5)
	layout.add_child(controls)
	var play_button := Button.new()
	play_button.text = "Play / Pause"
	play_button.pressed.connect(_toggle_play)
	controls.add_child(play_button)
	var restart_button := Button.new()
	restart_button.text = "Restart"
	restart_button.pressed.connect(_restart)
	controls.add_child(restart_button)
	var slower := Button.new()
	slower.text = "Speed -"
	slower.pressed.connect(_change_speed.bind(-0.25))
	controls.add_child(slower)
	_speed_status = Label.new()
	_speed_status.text = "1.00x"
	controls.add_child(_speed_status)
	var faster := Button.new()
	faster.text = "Speed +"
	faster.pressed.connect(_change_speed.bind(0.25))
	controls.add_child(faster)
	for zoom_option in ZOOM_OPTIONS:
		var zoom_button := Button.new()
		zoom_button.text = str(zoom_option["label"])
		zoom_button.pressed.connect(_set_zoom.bind(float(zoom_option["scale"]), str(zoom_option["label"])))
		controls.add_child(zoom_button)

	_stage = Control.new()
	_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stage.custom_minimum_size = Vector2(0, 420)
	_stage.clip_contents = true
	_stage.resized.connect(_layout_sprite)
	layout.add_child(_stage)

	_sprite = TextureRect.new()
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_SCALE
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_stage.add_child(_sprite)

	_clip_status = Label.new()
	_clip_status.add_theme_font_size_override("font_size", 18)
	layout.add_child(_clip_status)
	_frame_status = Label.new()
	layout.add_child(_frame_status)
	_zoom_status = Label.new()
	layout.add_child(_zoom_status)

func _load_manifest() -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		_status.text = "Asset manifest missing: " + MANIFEST_PATH
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not parsed is Dictionary:
		_status.text = "Invalid asset manifest JSON."
		return
	_manifest = parsed
	for item in _manifest.get("files", []):
		if item is Dictionary:
			_files_by_id[str(item.get("id", ""))] = item

func _select_clip(clip_id: String) -> void:
	var clips: Dictionary = _manifest.get("clips", {})
	if not clips.has(clip_id):
		_status.text = "Clip not present: " + clip_id
		return
	_clip_id = clip_id
	_frame_index = 0
	_elapsed = 0.0
	_playing = false
	var clip: Dictionary = clips[clip_id]
	_frame_count = int(clip.get("frames_per_direction", 1))
	var fps_value: Variant = clip.get("fps")
	_fps = float(fps_value) if fps_value != null else 0.0
	var file_record: Dictionary = _files_by_id.get(str(clip.get("file_id", "")), {})
	var atlas_path := str(file_record.get("path", ""))
	if atlas_path.is_empty():
		_status.text = "Atlas metadata missing for " + clip_id
		return
	_atlas = load(atlas_path) as Texture2D
	if _atlas == null:
		_status.text = "Atlas not available: " + atlas_path
		return
	_status.text = "Candidate pixels only. No skill, VFX, damage, or status events are emitted."
	_clip_status.text = "%s · %s · %d frame/direction · %s fps" % [
		clip_id.capitalize(),
		str(clip.get("status", "UNVERIFIED")),
		_frame_count,
		("still" if _fps <= 0.0 else "%.1f" % _fps)
	]
	_show_frame()
	_layout_sprite()

func _select_direction(direction: String) -> void:
	if not DIRECTIONS.has(direction):
		return
	_direction = direction
	_frame_index = 0
	_elapsed = 0.0
	_show_frame()

func _show_frame() -> void:
	if _sprite == null or _atlas == null:
		return
	var row := DIRECTIONS.find(_direction)
	var frame := AtlasTexture.new()
	frame.atlas = _atlas
	frame.region = Rect2(float(_frame_index * CELL_WIDTH), float(row * CELL_HEIGHT), float(CELL_WIDTH), float(CELL_HEIGHT))
	_sprite.texture = frame
	_frame_status.text = "%s · frame %d / %d" % [_direction.capitalize(), _frame_index + 1, _frame_count]

func _layout_sprite() -> void:
	if _sprite == null or _stage == null:
		return
	var display_size := Vector2(CELL_WIDTH, CELL_HEIGHT) * _zoom
	_sprite.size = display_size
	_sprite.position = (_stage.size - display_size) * 0.5
	_zoom_status.text = "Scale %.2fx · cell 320x384 · foot pivot (160,351)" % _zoom

func _toggle_play() -> void:
	_playing = not _playing and _frame_count > 1 and _fps > 0.0

func _restart() -> void:
	_frame_index = 0
	_elapsed = 0.0
	_show_frame()

func _change_speed(amount: float) -> void:
	_speed = clampf(_speed + amount, 0.25, 3.0)
	_speed_status.text = "%.2fx" % _speed

func _set_zoom(value: float, label: String) -> void:
	_zoom = value
	_zoom_status.text = label
	_layout_sprite()
