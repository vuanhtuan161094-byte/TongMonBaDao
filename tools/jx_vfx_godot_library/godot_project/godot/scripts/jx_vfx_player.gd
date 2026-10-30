extends Node
class_name JXVfxPlayer

signal effect_finished(effect_id: String, handle: int)
signal effect_failed(effect_id: String, reason: String)

var catalog: JXVfxCatalog
var texture_cache: Dictionary = {}
var active: Dictionary = {}
var _next_handle := 1

func set_catalog(value: JXVfxCatalog) -> void:
	catalog = value

func preload_effects(effect_ids: Array[String]) -> int:
	var failures := 0
	for effect_id in effect_ids:
		if _get_texture(effect_id) == null:
			failures += 1
	return failures

func get_texture(effect_id: String) -> Texture2D:
	return _get_texture(effect_id)

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
	var texture := _get_texture(effect_id)
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
	var keep_sha: Dictionary = {}
	if catalog != null:
		for effect_id in keep_effect_ids:
			var row := catalog.get_record(effect_id)
			if not row.is_empty():
				keep_sha[String(row.get("sha256", ""))] = true
	for sha in texture_cache.keys():
		if not keep_sha.has(sha):
			texture_cache.erase(sha)

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
	var sha := String(row.get("sha256", ""))
	if texture_cache.has(sha):
		return texture_cache[sha]
	var image := Image.new()
	if image.load(catalog.get_texture_path(effect_id)) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	texture_cache[sha] = texture
	return texture

func _apply_frame(state: Dictionary) -> bool:
	var animation: Dictionary = state["animation"]
	var frame := int(state["frame"])
	var direction := int(state["direction"])
	var rect := Rect2i()
	if String(animation.get("layout", "")) == "grid":
		var frame_size: Array = animation.get("frame_size", [])
		if frame_size.size() != 2:
			return false
		var width := int(frame_size[0])
		var height := int(frame_size[1])
		rect = Rect2i(frame * width, direction * height, width, height)
		var anchor: Array = animation.get("anchor_px", [0, 0])
		state["sprite"].offset = -Vector2(float(anchor[0]), float(anchor[1]))
	else:
		var rects: Array = animation.get("rects", [])
		var index := direction * int(animation["frames"]) + frame
		if index < 0 or index >= rects.size():
			return false
		var values: Array = rects[index]
		if values.size() != 6:
			return false
		rect = Rect2i(int(values[0]), int(values[1]), int(values[2]), int(values[3]))
		state["sprite"].offset = -Vector2(float(values[4]), float(values[5]))
	if rect.size.x <= 0 or rect.size.y <= 0:
		return false
	state["sprite"].region_rect = Rect2(Vector2(rect.position), Vector2(rect.size))
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

