extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var values: Dictionary = {}
	var index := 0
	while index < args.size():
		var key := String(args[index])
		if not key.begins_with("--") or index + 1 >= args.size():
			_fail("arguments must be --key value pairs")
			return
		values[key.substr(2)] = String(args[index + 1])
		index += 2
	for required in ["mode", "source", "output_dir", "stem", "frame_width", "frame_height", "frames", "directions", "max_page", "mapping"]:
		if not values.has(required):
			_fail("missing --%s" % required)
			return
	var mode := String(values["mode"])
	var frame_width := int(values["frame_width"])
	var frame_height := int(values["frame_height"])
	var frames := int(values["frames"])
	var directions := int(values["directions"])
	var max_page := int(values["max_page"])
	var anchor_x := int(values.get("anchor_x", "0"))
	var anchor_y := int(values.get("anchor_y", "0"))
	if frame_width <= 0 or frame_height <= 0 or frames <= 0 or directions <= 0 or max_page <= 0:
		_fail("frame geometry and max_page must be positive")
		return
	var source := Image.new()
	var error := source.load(String(values["source"]))
	if error != OK:
		_fail("Image.load failed: %s" % error)
		return
	source.convert(Image.FORMAT_RGBA8)
	var expected := Vector2i(frame_width * frames, frame_height * directions)
	var output_dir := String(values["output_dir"])
	if DirAccess.make_dir_recursive_absolute(output_dir) != OK and not DirAccess.dir_exists_absolute(output_dir):
		_fail("could not create output directory")
		return
	var mapping: Dictionary = {
		"mode": mode,
		"source_dimensions": [source.get_width(), source.get_height()],
		"expected_dimensions": [expected.x, expected.y],
		"frame_size": [frame_width, frame_height],
		"frames": frames,
		"directions": directions,
		"anchor_px": [anchor_x, anchor_y],
	}
	if mode == "pad":
		if source.get_width() > expected.x or source.get_height() > expected.y:
			_fail("transparent edge padding cannot remove source pixels")
			return
		if expected.x - source.get_width() >= frame_width or expected.y - source.get_height() >= frame_height:
			_fail("dimension gap is too large for transparent edge padding")
			return
		var padded := Image.create(expected.x, expected.y, false, Image.FORMAT_RGBA8)
		padded.fill(Color(0, 0, 0, 0))
		padded.blit_rect(source, Rect2i(0, 0, source.get_width(), source.get_height()), Vector2i.ZERO)
		var output_path := String(values["output_dir"]).path_join(String(values["stem"]) + "_padded.png")
		if padded.save_png(output_path) != OK:
			_fail("could not save padded PNG")
			return
		var pad_region := Rect2i(source.get_width(), source.get_height(), expected.x - source.get_width(), expected.y - source.get_height())
		mapping["output_path"] = output_path
		mapping["added_right_px"] = expected.x - source.get_width()
		mapping["added_bottom_px"] = expected.y - source.get_height()
		mapping["added_region_alpha_bbox"] = _alpha_bbox(padded, pad_region)
	elif mode == "pages":
		if Vector2i(source.get_width(), source.get_height()) != expected:
			_fail("page repack requires exact grid dimensions")
			return
		if frame_height > max_page or frame_width > max_page:
			_fail("a single frame exceeds the page maximum")
		var frames_per_page := maxi(1, max_page / frame_width)
		var pages: Array = []
		var regions: Array = []
		var frame_total := frames * directions
		for page_start in range(0, frame_total, frames_per_page):
			var count := mini(frames_per_page, frame_total - page_start)
			var page := Image.create(count * frame_width, frame_height, false, Image.FORMAT_RGBA8)
			page.fill(Color(0, 0, 0, 0))
			for local_index in range(count):
				var global_index := page_start + local_index
				var frame_index := global_index % frames
				var direction_index := global_index / frames
				var source_rect := Rect2i(frame_index * frame_width, direction_index * frame_height, frame_width, frame_height)
				page.blit_rect(source, source_rect, Vector2i(local_index * frame_width, 0))
			var page_path := String(values["output_dir"]).path_join("%s_p%02d.png" % [String(values["stem"]), pages.size()])
			if page.save_png(page_path) != OK:
				_fail("could not save page %d" % pages.size())
				return
			pages.append({"path": page_path, "size": [page.get_width(), page.get_height()], "first_global_frame": page_start, "frame_count": count})
			for local_index in range(count):
				var global_index := page_start + local_index
				regions.append({
					"texture_path": page_path,
					"rect": [local_index * frame_width, 0, frame_width, frame_height],
					"anchor_px": [anchor_x, anchor_y],
					"frame_index": global_index % frames,
					"direction_index": global_index / frames,
				})
		mapping["pages"] = pages
		mapping["frame_regions"] = regions
	else:
		_fail("unsupported mode: %s" % mode)
		return
	var mapping_file := FileAccess.open(String(values["mapping"]), FileAccess.WRITE)
	if mapping_file == null:
		_fail("could not write mapping JSON")
		return
	mapping_file.store_string(JSON.stringify(mapping, "\t"))
	mapping_file.close()
	print(JSON.stringify({"ok": true, "mode": mode, "mapping": String(values["mapping"])}))
	quit(0)

func _alpha_bbox(image: Image, region: Rect2i) -> Array:
	var points: Array[Vector2i] = []
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			if image.get_pixel(x, y).a > 0.0:
				points.append(Vector2i(x, y))
	if points.is_empty():
		return []
	var min_x := points[0].x
	var min_y := points[0].y
	var max_x := points[0].x
	var max_y := points[0].y
	for point in points:
		min_x = mini(min_x, point.x)
		min_y = mini(min_y, point.y)
		max_x = maxi(max_x, point.x)
		max_y = maxi(max_y, point.y)
	return [min_x, min_y, max_x - min_x + 1, max_y - min_y + 1]

func _fail(message: String) -> void:
	printerr(message)
	quit(1)
