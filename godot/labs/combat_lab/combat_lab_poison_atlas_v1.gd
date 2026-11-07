class_name CombatLabPoisonAtlasV1
extends RefCounted

# Uses the owner's existing six Grok-derived sprite sheets as visual-only art.
# PNGs remain full-resolution; one clip texture is loaded on first use.
const MANIFEST_PATH := "res://labs/combat_lab/assets/nu_doc_tu_grok_01/manifest.json"

static var _clip_cache: Dictionary = {}
static var _texture_cache: Dictionary = {}

static func clip_for_pose(pose: String) -> String:
    match pose:
        "idle": return "idle"
        "walk": return "walk"
        "cast": return "cast"
        "attack": return "attack"
        "hit": return "hit"
        "death": return "defeated"
    return "idle"

static func _clips() -> Dictionary:
    if not _clip_cache.is_empty():
        return _clip_cache
    if not FileAccess.file_exists(MANIFEST_PATH):
        return {}
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
    if not (parsed is Dictionary):
        return {}
    var animations: Variant = parsed.get("animations", {})
    if animations is Dictionary:
        _clip_cache = animations
    return _clip_cache

static func clip_duration_ms(pose: String) -> int:
    var clip := clip_for_pose(pose)
    var row: Dictionary = _clips().get(clip, {})
    if row.is_empty() or bool(row.get("loop", false)):
        return 0
    var count := maxi(1, int(row.get("frames", 1)))
    var fps := maxf(1.0, float(row.get("playback_fps", 1.0)))
    return maxi(1, roundi(float(count) * 1000.0 / fps))

static func frame_index(clip: String, visual_time: float, pose_elapsed: float,
        playback_duration: float = -1.0) -> int:
    var row: Dictionary = _clips().get(clip, {})
    var count := int(row.get("frames", 0))
    if count <= 0:
        return -1
    var fps := maxf(1.0, float(row.get("playback_fps", 1.0)))
    var is_loop := bool(row.get("loop", false))
    if not is_loop and playback_duration > 0.0:
        var progress := clampf(pose_elapsed / playback_duration, 0.0, 0.999999)
        return mini(floori(progress * float(count)), count - 1)
    var clock := visual_time if is_loop else pose_elapsed
    var raw := maxi(0, floori(maxf(0.0, clock) * fps))
    return posmod(raw, count) if is_loop else mini(raw, count - 1)

static func _texture_for_clip(clip: String, row: Dictionary) -> Texture2D:
    if _texture_cache.has(clip):
        return _texture_cache[clip] as Texture2D
    var sheet_path := str(row.get("sheet", ""))
    if sheet_path.is_empty():
        return null
    var loaded: Resource = ResourceLoader.load(sheet_path)
    if not (loaded is Texture2D):
        return null
    var texture := loaded as Texture2D
    _texture_cache[clip] = texture
    return texture

static func draw(canvas: CanvasItem, foot: Vector2, pose: String,
        visual_time: float, pose_elapsed: float, actor_scale: float,
        facing: float = 1.0, playback_duration: float = -1.0) -> bool:
    var clip := clip_for_pose(pose)
    var row: Dictionary = _clips().get(clip, {})
    if row.is_empty():
        return false
    var texture := _texture_for_clip(clip, row)
    if texture == null:
        return false

    var cell_width := int(row.get("cell_width", 0))
    var cell_height := int(row.get("cell_height", 0))
    var columns := int(row.get("columns", 0))
    var rows := int(row.get("rows", 0))
    var count := int(row.get("frames", 0))
    var frame := frame_index(clip, visual_time, pose_elapsed, playback_duration)
    if cell_width <= 0 or cell_height <= 0 or columns <= 0 or rows <= 0 or frame < 0:
        return false
    if frame >= count or frame >= columns * rows:
        return false
    if texture.get_width() < columns * cell_width or texture.get_height() < rows * cell_height:
        return false

    var source_x := (frame % columns) * cell_width
    var source_y := floori(float(frame) / float(columns)) * cell_height
    var source_rect := Rect2(source_x, source_y, cell_width, cell_height)
    var anchor: Array = row.get("foot_anchor", [112, 245])
    if anchor.size() < 2:
        return false
    var local_rect := Rect2(-float(anchor[0]), -float(anchor[1]), cell_width, cell_height)
    var scale_factor := maxf(0.01, float(row.get("gameplay_recommended_scale", 0.32)) * actor_scale)
    var facing_sign := -1.0 if facing < 0.0 else 1.0

    # The source manifest defines the foot anchor; mirror around it without
    # mutating the atlas or permanently rescaling any sheet.
    canvas.draw_set_transform(foot, 0.0, Vector2(facing_sign * scale_factor, scale_factor))
    canvas.draw_texture_rect_region(texture, local_rect, source_rect)
    canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    return true
