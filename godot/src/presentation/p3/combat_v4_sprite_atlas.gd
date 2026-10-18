class_name CombatV4SpriteAtlas
extends RefCounted

# View-only reader for selected, owner-provided Source VL sheets.
# Metadata is copied from the exact sprites.json source rects/anchor/dirs; no grid guessing.
const INDEX_PATH := "res://assets/combat_v4/source_vl/atlas_manifest.json"
const ATLAS_ROOT := "res://assets/combat_v4/source_vl/"
const DEFAULT_FPS := 12.0
var sheets: Dictionary = {}
var texture_cache: Dictionary = {}

func _init() -> void:
    if not FileAccess.file_exists(INDEX_PATH):
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(INDEX_PATH))
    if parsed is Dictionary:
        sheets = parsed.get("atlases", {})

func has_actor(actor_key: String) -> bool:
    return sheets.has(actor_key)

func frame_region(actor_key: String, action: String, facing: Vector2, elapsed: float) -> Dictionary:
    var source: Dictionary = sheets.get(actor_key, {})
    if source.is_empty():
        return {}
    var actions: Dictionary = source.get("actions", {})
    var clip: Dictionary = actions.get(action, actions.get("idle", {}))
    if clip.is_empty():
        return {}
    var file_name := str(clip.get("image", ""))
    if file_name.is_empty() or file_name.contains("/") or file_name.contains("\\"):
        return {}
    var texture := _texture(file_name)
    if texture == null:
        return {}
    var frames := int(clip.get("frames", 0))
    var dirs := int(source.get("directions", 0))
    var rects: Array = clip.get("rects", [])
    if frames < 1 or dirs < 1 or rects.size() != frames * dirs * 6:
        return {}
    var frame_index := int(floor(maxf(elapsed, 0.0) * DEFAULT_FPS))
    if action in ["attack", "hit", "die"]:
        frame_index = mini(frame_index, frames - 1)
    else:
        frame_index = posmod(frame_index, frames)
    var direction := facing.normalized() if facing.length_squared() > 0.0001 else Vector2.RIGHT
    var dir_index := posmod(int(round(direction.angle() * float(dirs) / TAU)) + int(source.get("dir_offset", 0)), dirs)
    var offset := (dir_index * frames + frame_index) * 6
    var x := int(rects[offset])
    var y := int(rects[offset + 1])
    var width := int(rects[offset + 2])
    var height := int(rects[offset + 3])
    if x < 0 or y < 0 or width <= 0 or height <= 0:
        return {}
    if x + width > texture.get_width() or y + height > texture.get_height():
        return {}
    return {
        "texture": texture,
        "source": Rect2(float(x), float(y), float(width), float(height)),
        "anchor": Vector2(float(rects[offset + 4]), float(rects[offset + 5])),
        "frame": frame_index, "direction": dir_index,
        "scale": float(source.get("scale", 1.0))
    }

func draw_actor(canvas: CanvasItem, actor_key: String, action: String, foot: Vector2,
        facing: Vector2, elapsed: float, art_scale: float = 1.0) -> bool:
    var info := frame_region(actor_key, action, facing, elapsed)
    if info.is_empty():
        return false
    var source: Rect2 = info["source"]
    var ratio: float = art_scale * float(info["scale"])
    var anchor: Vector2 = info["anchor"]
    var dest := Rect2(foot - anchor * ratio, source.size * ratio)
    canvas.draw_texture_rect_region(info["texture"], dest, source)
    return true

func _texture(file_name: String) -> Texture2D:
    if texture_cache.has(file_name):
        return texture_cache[file_name]
    var resource = load(ATLAS_ROOT + file_name)
    var texture := resource as Texture2D
    texture_cache[file_name] = texture
    return texture
