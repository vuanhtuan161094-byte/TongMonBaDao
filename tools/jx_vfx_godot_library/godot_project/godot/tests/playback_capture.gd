extends SceneTree

const IDS: Array[String] = [
	"duong_mon_fx:m38_fly.webp",
	"thuy_yen_fx:m146_fly.webp",
	"vltk_native:01744d1a.webp",
]
const SIZES := [48, 64, 75, 96]
const COLUMNS := [160.0, 480.0, 800.0, 1120.0]
const ROWS := [160.0, 370.0, 580.0]

var failures: Array[String] = []
var catalog := JXVfxCatalog.new()
var player: JXVfxPlayer
var stage: Node2D
var captures: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var watchdog := Timer.new()
	watchdog.wait_time = 20.0
	watchdog.one_shot = true
	watchdog.timeout.connect(func():
		printerr("playback capture watchdog expired")
		quit(2)
	)
	root.add_child(watchdog)
	watchdog.start()
	var args := OS.get_cmdline_user_args()
	var output_dir := ""
	var index := 0
	while index + 1 < args.size():
		if args[index] == "--output-dir":
			output_dir = args[index + 1]
			index += 2
		else:
			printerr("Unknown capture argument: %s" % args[index])
			quit(2)
			return
	if output_dir.is_empty():
		printerr("--output-dir is required")
		quit(2)
	if DirAccess.make_dir_recursive_absolute(output_dir) != OK and not DirAccess.dir_exists_absolute(output_dir):
		printerr("Could not create capture output directory")
		quit(2)
	if catalog.load_index("res://catalog/library_index.json") != OK:
		printerr("Could not load selected-pack catalog")
		quit(2)
	var window := root as Window
	window.size = Vector2i(1280, 720)
	var canvas := Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(canvas)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("111821")
	canvas.add_child(background)
	var heading := Label.new()
	heading.text = "Godot 4.7.2 · imported VFX · preview-size sweep"
	heading.position = Vector2(24, 14)
	heading.add_theme_font_size_override("font_size", 20)
	canvas.add_child(heading)
	var subheading := Label.new()
	subheading.text = "Loop playback · frames and anchors from selected-pack catalog"
	subheading.position = Vector2(24, 42)
	subheading.add_theme_color_override("font_color", Color("a9bbc7"))
	canvas.add_child(subheading)
	var size_header := Label.new()
	for size in SIZES:
		size_header.text += "%d px       " % size
	size_header.position = Vector2(120, 72)
	size_header.add_theme_font_size_override("font_size", 14)
	canvas.add_child(size_header)
	stage = Node2D.new()
	canvas.add_child(stage)
	player = JXVfxPlayer.new()
	canvas.add_child(player)
	player.set_catalog(catalog)
	for row_index in range(IDS.size()):
		var record := catalog.get_record(IDS[row_index])
		var animation: Dictionary = record.get("animation", {})
		var label := Label.new()
		label.text = "%s · %s" % [String(record.get("source_id", "")), String(record.get("filename", IDS[row_index]))]
		label.position = Vector2(24, ROWS[row_index] - 60)
		label.add_theme_color_override("font_color", Color("c9d5dc"))
		canvas.add_child(label)
		var frame_size: Array = animation.get("frame_size", [])
		var frame_width := float(frame_size[0]) if frame_size.size() == 2 else 96.0
		var frame_height := float(frame_size[1]) if frame_size.size() == 2 else 96.0
		if String(animation.get("layout", "")) == "rects":
			var rects: Array = animation.get("rects", [])
			frame_width = float(rects[0][2])
			frame_height = float(rects[0][3])
		for column_index in range(SIZES.size()):
			var pixel_size := float(SIZES[column_index])
			var scale := pixel_size / maxf(frame_width, frame_height)
			var handle := player.play(IDS[row_index], stage, Vector2(COLUMNS[column_index], ROWS[row_index]), {"loop": true, "direction": 0, "scale": scale})
			if handle == 0:
				failures.append("play_failed:%s:%d" % [IDS[row_index], SIZES[column_index]])
			var cell_label := Label.new()
			cell_label.text = "%d px" % SIZES[column_index]
			cell_label.position = Vector2(COLUMNS[column_index] - 25, ROWS[row_index] + 66)
			cell_label.add_theme_font_size_override("font_size", 12)
			cell_label.add_theme_color_override("font_color", Color("93a7b3"))
			canvas.add_child(cell_label)
	var viewport := window.get_viewport()
	await RenderingServer.frame_post_draw
	await process_frame
	if not _save_capture(output_dir.path_join("godot_playback_t00.png"), viewport):
		failures.append("capture_t00_failed")
	captures.append({"file": "godot_playback_t00.png", "active_frames": _active_frames()})
	await create_timer(0.27).timeout
	await RenderingServer.frame_post_draw
	if not _save_capture(output_dir.path_join("godot_playback_t270.png"), viewport):
		failures.append("capture_t270_failed")
	captures.append({"file": "godot_playback_t270.png", "active_frames": _active_frames()})
	var motion_by_effect: Dictionary = {}
	var motion_detected := true
	if captures.size() == 2:
		for effect_id in IDS:
			var changed: bool = captures[0]["active_frames"].get(effect_id, []) != captures[1]["active_frames"].get(effect_id, [])
			motion_by_effect[effect_id] = changed
			motion_detected = motion_detected and changed
	var result := {
		"status": "PASS" if failures.is_empty() and motion_detected else "FAIL",
		"engine_version": Engine.get_version_info().get("string", "unknown"),
		"capture_mode": "Godot GUI renderer, actual Sprite2D/JXVfxPlayer playback",
		"viewport_px": [window.size.x, window.size.y],
		"effect_ids": IDS,
		"display_sizes_px": SIZES,
		"captures": captures,
		"frame_change_by_effect": motion_by_effect,
		"frame_change_between_captures": motion_detected,
		"failures": failures,
	}
	var report := FileAccess.open(output_dir.path_join("playback_capture.json"), FileAccess.WRITE)
	if report != null:
		report.store_string(JSON.stringify(result, "\t"))
		report.close()
	watchdog.stop()
	print("PLAYBACK_CAPTURE_JSON=" + JSON.stringify(result))
	quit(0 if result["status"] == "PASS" else 1)

func _active_frames() -> Dictionary:
	var states: Dictionary = {}
	for handle in player.active.keys():
		var state: Dictionary = player.active[handle]
		var effect_id := String(state.get("effect_id", ""))
		if not states.has(effect_id):
			states[effect_id] = []
		states[effect_id].append(int(state.get("frame", -1)))
	return states

func _save_capture(path: String, viewport: Viewport) -> bool:
	var texture := viewport.get_texture()
	if texture == null:
		return false
	var image := texture.get_image()
	if image.is_empty() or image.get_width() != 1280 or image.get_height() != 720:
		return false
	return image.save_png(path) == OK
