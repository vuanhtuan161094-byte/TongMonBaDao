class_name CombatV5SourceAAtlas
extends CombatV4SpriteAtlas

## View-only adapter for native Spine 3.8 clips baked by the existing
## SpineToGodot472 pipeline. No gameplay state is read or changed here.
const MANIFEST_PATH := "res://assets/combat_v5_source_a/visual_manifest.json"
const ACTORS_ROOT := "res://assets/actors/"

var _actors: Dictionary = {}
var _packs: Dictionary = {}
var _clip_cache: Dictionary = {}
var _resolved_clip_cache: Dictionary = {}

func _init() -> void:
	super()
	if not FileAccess.file_exists(MANIFEST_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not (parsed is Dictionary):
		return
	var rows: Dictionary = parsed.get("actors", {})
	for actor_key in rows:
		if not (rows[actor_key] is Dictionary):
			continue
		var row: Dictionary = rows[actor_key]
		var base_id := str(row.get("base_asset", ""))
		var combat_id := str(row.get("combat_asset", ""))
		var base_pack := _load_pack(base_id)
		var combat_pack := _load_pack(combat_id)
		if base_pack.is_empty() and combat_pack.is_empty():
			continue
		_actors[str(actor_key)] = {
			"base": base_pack,
			"combat": combat_pack,
			"base_scale": float(row.get("base_scale", 0.5)),
			"combat_scale": float(row.get("combat_scale", 0.5)),
			"source_face_x": -1 if int(row.get("source_face_x", -1)) < 0 else 1
		}

func has_actor(actor_key: String) -> bool:
	return _actors.has(actor_key)

func frame_region(actor_key: String, action: String, facing: Vector2, elapsed: float) -> Dictionary:
	var resolved := _resolve(actor_key, action)
	if resolved.is_empty():
		return {}
	var pack: Dictionary = resolved["pack"]
	var frames: SpriteFrames = pack["frames"]
	var clip_name := str(resolved["clip"])
	var cache_key := "%d:%s" % [frames.get_instance_id(),clip_name]
	var clip_data: Dictionary = _clip_cache.get(cache_key,{})
	if clip_data.is_empty():
		var count := frames.get_frame_count(clip_name)
		if count < 1:
			return {}
		var speed := maxf(0.001,frames.get_animation_speed(clip_name))
		var durations: Array[float] = []
		var textures: Array[Texture2D] = []
		var duration_total := 0.0
		for index in range(count):
			durations.append(maxf(0.001,frames.get_frame_duration(clip_name,index)/speed))
			textures.append(frames.get_frame_texture(clip_name,index))
			duration_total += durations.back()
		clip_data = {
			"durations":durations,
			"textures":textures,
			"duration_total":duration_total,
			"loop":frames.get_animation_loop(clip_name)
		}
		_clip_cache[cache_key] = clip_data
	var durations: Array = clip_data["durations"]
	var duration_total := float(clip_data["duration_total"])
	if durations.is_empty() or duration_total <= 0.0:
		return {}
	var sample_time := maxf(0.0, elapsed)
	if bool(clip_data["loop"]):
		sample_time = fposmod(sample_time, duration_total)
	else:
		sample_time = minf(sample_time, maxf(0.0, duration_total - 0.0001))
	var frame_index := durations.size() - 1
	for index in range(durations.size()):
		if sample_time < float(durations[index]) or index == durations.size() - 1:
			frame_index = index
			break
		sample_time -= durations[index]
	var textures: Array = clip_data["textures"]
	var texture := textures[frame_index] as Texture2D
	if texture == null:
		return {}
	return {
		"texture": texture,
		"source": Rect2(Vector2.ZERO, texture.get_size()),
		"anchor": pack["anchor"],
		"frame": frame_index,
		"direction": 0,
		"scale": float(resolved["scale"]),
		"source_face_x": int(_actors[actor_key]["source_face_x"])
	}

func action_duration(actor_key: String, action: String) -> float:
	var resolved := _resolve(actor_key, action)
	if resolved.is_empty():
		return 0.0
	var frames: SpriteFrames = resolved["pack"]["frames"]
	var clip_name := str(resolved["clip"])
	var speed := maxf(0.001, frames.get_animation_speed(clip_name))
	var total := 0.0
	for index in range(frames.get_frame_count(clip_name)):
		total += maxf(0.001, frames.get_frame_duration(clip_name, index) / speed)
	return total

func draw_actor(canvas: CanvasItem, actor_key: String, action: String, foot: Vector2,
		facing: Vector2, elapsed: float, art_scale: float = 1.0) -> bool:
	var info := frame_region(actor_key, action, facing, elapsed)
	if info.is_empty():
		return false
	var texture: Texture2D = info["texture"]
	var source: Rect2 = info["source"]
	var anchor: Vector2 = info["anchor"]
	var ratio := art_scale * float(info["scale"])
	var face_left := facing.x < -0.001
	var native_left := int(info["source_face_x"]) < 0
	if face_left == native_left:
		canvas.draw_texture_rect_region(texture,
			Rect2(foot - anchor * ratio, source.size * ratio), source)
	else:
		canvas.draw_set_transform(foot, 0.0, Vector2(-ratio, ratio))
		canvas.draw_texture_rect_region(texture,
			Rect2(Vector2(-anchor.x, -anchor.y), source.size), source)
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true

func _resolve(actor_key: String, action: String) -> Dictionary:
	var cache_key := actor_key+"|"+action
	if _resolved_clip_cache.has(cache_key):
		return _resolved_clip_cache[cache_key]
	if not _actors.has(actor_key):
		return {}
	var row: Dictionary = _actors[actor_key]
	var candidates: Array[String] = []
	match action:
		"attack", "cast": candidates = ["attack1", "attack"]
		"hit": candidates = ["hit"]
		"die", "dead": candidates = ["dead", "die"]
		"run", "walk": candidates = ["walk", "run"]
		_: candidates = ["stand", "idle1", "idle", "idle2"]
	var order := ["combat", "base"] if action in ["attack", "cast", "hit", "die", "dead"] else ["base", "combat"]
	for pack_key in order:
		var pack: Dictionary = row.get(pack_key, {})
		if pack.is_empty():
			continue
		var frames: SpriteFrames = pack["frames"]
		for clip_name in candidates:
			if frames.has_animation(clip_name) and frames.get_frame_count(clip_name) > 0:
				var resolved := {
					"pack": pack,
					"clip": clip_name,
					"scale": float(row["combat_scale"] if pack_key == "combat" else row["base_scale"])
				}
				_resolved_clip_cache[cache_key] = resolved
				return resolved
	_resolved_clip_cache[cache_key] = {}
	return {}

func _load_pack(asset_id: String) -> Dictionary:
	if asset_id.is_empty() or asset_id.contains("/") or asset_id.contains("\\") or asset_id.contains(".."):
		return {}
	if _packs.has(asset_id):
		return _packs[asset_id]
	var root := ACTORS_ROOT + asset_id + "/"
	var manifest_path := root + "asset.json"
	var animation_path := root + "animations.tres"
	if not FileAccess.file_exists(manifest_path) or not FileAccess.file_exists(animation_path):
		_packs[asset_id] = {}
		return {}
	var metadata = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var frames := load(animation_path) as SpriteFrames
	if not (metadata is Dictionary) or frames == null:
		_packs[asset_id] = {}
		return {}
	var offset: Array = metadata.get("offset", [])
	if offset.size() != 2:
		_packs[asset_id] = {}
		return {}
	var pack := {
		"frames": frames,
		"anchor": Vector2(-float(offset[0]), -float(offset[1])),
		"metadata": metadata
	}
	_packs[asset_id] = pack
	return pack
