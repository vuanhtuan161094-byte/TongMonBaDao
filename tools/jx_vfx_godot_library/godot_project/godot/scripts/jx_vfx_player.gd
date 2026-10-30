extends Node
class_name JXVfxPlayer

const _RESOURCE_MANIFEST = preload("res://godot/scripts/jx_vfx_resource_manifest.gd")

signal effect_finished(effect_id: String, handle: int)
signal effect_failed(effect_id: String, reason: String)

var catalog: JXVfxCatalog
var texture_cache: Dictionary = {}
var active: Dictionary = {}
var _next_handle := 1
var texture_cache_hits := 0
var texture_cache_misses := 0
var resource_manifest_reference_count := _RESOURCE_MANIFEST.TEXTURES.size()

func set_catalog(value: JXVfxCatalog) -> void:
	catalog = value

func _exit_tree() -> void:
	for handle in active.keys():
		stop(int(handle))
	texture_cache.clear()

func preload_effects(effect_ids: Array[String]) -> int:
	var failures := 0
	for effect_id in effect_ids:
		if catalog == null:
			failures += 1
			continue
		var row := catalog.get_record(effect_id)
		if row.is_empty():
			failures += 1
			continue
		var animation: Dictionary = row.get("animation", {})
		var failed := false
		for texture_path in _runtime_texture_paths_for_record(row, animation):
			if _get_texture_path(texture_path) == null:
				failed = true
		if failed:
			failures += 1
	return failures

func get_texture(effect_id: String) -> Texture2D:
	if catalog == null:
		return null
	var row := catalog.get_record(effect_id)
	if row.is_empty():
		return null
	var animation: Dictionary = row.get("animation", {})
	return _get_texture_path(_texture_path_for_frame(row, animation, 0, 0))

func play(effect_id: String, parent: Node2D, position: Vector2, options: Dictionary = {}) -> int:
	if catalog == null or parent == null:
		effect_failed.emit(effect_id, "CATALOG_OR_PARENT_MISSING")
		return 0
	var record := catalog.get_record(effect_id)
	var animation: Dictionary = record.get("animation", {})
	if record.is_empty() or animation.is_empty():
		effect_failed.emit(effect_id, "NO_LINKED_FRAME_GEOMETRY")
		return 0
	if animation.get("timing_unit", "") != "ms" or int(animation.get("frame_ms", 0)) <= 0:
		effect_failed.emit(effect_id, "TIMING_UNIT_UNVERIFIED_OR_MISSING")
		return 0
	if animation.get("source_dimensions_match", true) == false:
		effect_failed.emit(effect_id, "SOURCE_SHEET_DIMENSION_MISMATCH")
		return 0
	var texture_path := _texture_path_for_frame(record, animation, 0, clampi(int(options.get("direction", 0)), 0, maxi(0, int(animation.get("directions", 1)) - 1)))
	var texture := _get_texture_path(texture_path)
	if texture == null:
		effect_failed.emit(effect_id, "TEXTURE_LOAD_FAILED")
		return 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.region_enabled = true
	sprite.position = position
	sprite.scale = Vector2.ONE * float(options.get("scale", 1.0))
	sprite.rotation = float(options.get("rotation", 0.0))
	sprite.modulate.a = clampf(float(options.get("alpha", 1.0)), 0.0, 1.0)
	var material := CanvasItemMaterial.new()
	material.blend_mode = _blend_mode(String(options.get("blend", "MIX")))
	sprite.material = material
	parent.add_child(sprite)
	var frames := int(animation.get("frames", 0))
	var directions := int(animation.get("directions", 1))
	if frames <= 0 or directions <= 0:
		sprite.queue_free()
		effect_failed.emit(effect_id, "INVALID_FRAME_COUNT")
		return 0
	var direction := clampi(int(options.get("direction", 0)), 0, directions - 1)
	var handle := _next_handle
	_next_handle += 1
	active[handle] = {
		"effect_id": effect_id,
		"sprite": sprite,
		"animation": animation,
		"frame": 0,
		"direction": direction,
		"elapsed": 0.0,
		"loop": bool(options.get("loop", false)),
		"frame_seconds": float(animation["frame_ms"]) / 1000.0,
	}
	if not _apply_frame(active[handle]):
		stop(handle)
		effect_failed.emit(effect_id, "FRAME_REGION_INVALID")
		return 0
	return handle

func stop(handle: int) -> void:
	if not active.has(handle):
		return
	var state: Dictionary = active[handle]
	var sprite: Sprite2D = state.get("sprite")
	if is_instance_valid(sprite):
		sprite.queue_free()
	active.erase(handle)

func release_unused(keep_effect_ids: Array[String]) -> void:
	var keep_paths: Dictionary = {}
	if catalog != null:
		for effect_id in keep_effect_ids:
			var row := catalog.get_record(effect_id)
			if not row.is_empty():
				for texture_path in _runtime_texture_paths_for_record(row, row.get("animation", {})):
					keep_paths[texture_path] = true
	for texture_path in texture_cache.keys():
		if not keep_paths.has(texture_path):
			texture_cache.erase(texture_path)

func _process(delta: float) -> void:
	for handle in active.keys():
		if not active.has(handle):
			continue
		var state: Dictionary = active[handle]
		state["elapsed"] = float(state["elapsed"]) + delta
		var finished := false
		while float(state["elapsed"]) >= float(state["frame_seconds"]):
			state["elapsed"] = float(state["elapsed"]) - float(state["frame_seconds"])
			var next_frame := int(state["frame"]) + 1
			if next_frame >= int(state["animation"]["frames"]):
				if bool(state["loop"]):
					next_frame = 0
				else:
					finished = true
					break
			state["frame"] = next_frame
			if not _apply_frame(state):
				finished = true
				break
		active[handle] = state
		if finished:
			var effect_id := String(state["effect_id"])
			stop(handle)
			effect_finished.emit(effect_id, handle)

func _get_texture(effect_id: String) -> Texture2D:
	if catalog == null:
		return null
	var row := catalog.get_record(effect_id)
	if row.is_empty():
		return null
	return _get_texture_path(String(row.get("texture_path", "")))

func _get_texture_path(relative_path: String) -> Texture2D:
	if relative_path.is_empty():
		return null
	if texture_cache.has(relative_path):
		texture_cache_hits += 1
		return texture_cache[relative_path]
	texture_cache_misses += 1
	var resource_path := relative_path if relative_path.begins_with("res://") else "res://" + relative_path.trim_prefix("/")
	if not ResourceLoader.exists(resource_path):
		return null
	var resource := ResourceLoader.load(resource_path)
	if not (resource is Texture2D):
		return null
	var texture: Texture2D = resource
	texture_cache[relative_path] = texture
	return texture

func _texture_path_for_frame(record: Dictionary, animation: Dictionary, frame: int, direction: int) -> String:
	var layout := String(animation.get("layout", ""))
	if layout == "paged_rects":
		var regions: Array = animation.get("frame_regions", [])
		var index := direction * int(animation.get("frames", 0)) + frame
		if index < 0 or index >= regions.size() or not (regions[index] is Dictionary):
			return ""
		return String(regions[index].get("texture_path", ""))
	var runtime_path := String(animation.get("runtime_texture_path", ""))
	return runtime_path if not runtime_path.is_empty() else String(record.get("texture_path", ""))

func _runtime_texture_paths_for_record(record: Dictionary, animation: Dictionary) -> Array[String]:
	var unique: Array[String] = []
	if String(animation.get("layout", "")) == "paged_rects":
		for region in animation.get("frame_regions", []):
			if region is Dictionary:
				var page_path := String(region.get("texture_path", ""))
				if not page_path.is_empty() and not unique.has(page_path):
					unique.append(page_path)
	else:
		var runtime_path := String(animation.get("runtime_texture_path", ""))
		var texture_path := runtime_path if not runtime_path.is_empty() else String(record.get("texture_path", ""))
		if not texture_path.is_empty():
			unique.append(texture_path)
	return unique

func _apply_frame(state: Dictionary) -> bool:
	var animation: Dictionary = state["animation"]
	var frame := int(state["frame"])
	var direction := int(state["direction"])
	var record := catalog.get_record(String(state["effect_id"]))
	if record.is_empty():
		return false
	var rect := Rect2i()
	var anchor := Vector2.ZERO
	var texture_path := _texture_path_for_frame(record, animation, frame, direction)
	if String(animation.get("layout", "")) == "grid":
		var frame_size: Array = animation.get("frame_size", [])
		if frame_size.size() != 2:
			return false
		var width := int(frame_size[0])
		var height := int(frame_size[1])
		rect = Rect2i(frame * width, direction * height, width, height)
		var anchor_values: Array = animation.get("anchor_px", [0, 0])
		anchor = Vector2(float(anchor_values[0]), float(anchor_values[1]))
	elif String(animation.get("layout", "")) == "rects":
		var rects: Array = animation.get("rects", [])
		var index := direction * int(animation["frames"]) + frame
		if index < 0 or index >= rects.size():
			return false
		var values: Array = rects[index]
		if values.size() != 6:
			return false
		rect = Rect2i(int(values[0]), int(values[1]), int(values[2]), int(values[3]))
		anchor = Vector2(float(values[4]), float(values[5]))
	elif String(animation.get("layout", "")) == "paged_rects":
		var regions: Array = animation.get("frame_regions", [])
		var region_index := direction * int(animation["frames"]) + frame
		if region_index < 0 or region_index >= regions.size() or not (regions[region_index] is Dictionary):
			return false
		var region: Dictionary = regions[region_index]
		var values: Array = region.get("rect", [])
		var anchor_values: Array = region.get("anchor_px", animation.get("anchor_px", [0, 0]))
		if values.size() != 4 or anchor_values.size() != 2:
			return false
		texture_path = String(region.get("texture_path", texture_path))
		rect = Rect2i(int(values[0]), int(values[1]), int(values[2]), int(values[3]))
		anchor = Vector2(float(anchor_values[0]), float(anchor_values[1]))
	else:
		return false
	if rect.size.x <= 0 or rect.size.y <= 0:
		return false
	var texture := _get_texture_path(texture_path)
	if texture == null:
		return false
	var sprite: Sprite2D = state["sprite"]
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2(rect.position), Vector2(rect.size))
	sprite.offset = -anchor
	return true

func _blend_mode(name: String) -> CanvasItemMaterial.BlendMode:
	match name.to_upper():
		"ADD", "LIGHTER":
			return CanvasItemMaterial.BLEND_MODE_ADD
		"SUB":
			return CanvasItemMaterial.BLEND_MODE_SUB
		"MUL":
			return CanvasItemMaterial.BLEND_MODE_MUL
		_:
			return CanvasItemMaterial.BLEND_MODE_MIX
