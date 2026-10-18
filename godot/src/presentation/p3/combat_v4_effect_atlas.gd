class_name CombatV4EffectAtlas
extends RefCounted

# Read-only frame adapter for two real owner-authorized Source VL WebP VFX.
# Source graphics illustrate existing V2 skill events only; never determine damage.
const INDEX_PATH := "res://assets/combat_v4/source_vl/vfx_manifest.json"
const ATLAS_ROOT := "res://assets/combat_v4/source_vl/"
var effects: Dictionary = {}
var cache: Dictionary = {}

func _init() -> void:
    if not FileAccess.file_exists(INDEX_PATH):
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(INDEX_PATH))
    if parsed is Dictionary:
        effects = parsed.get("effects",{})

func duration(kind: String) -> float:
    var cue: Dictionary = effects.get(kind,{})
    return float(cue.get("frames",0)) * float(cue.get("frame_ms",0)) * 0.001

func frame_region(kind: String, elapsed: float) -> Dictionary:
    var cue: Dictionary = effects.get(kind,{})
    if cue.is_empty() or elapsed < 0.0:
        return {}
    var file_name := str(cue.get("image",""))
    if file_name.is_empty() or file_name.contains("/") or file_name.contains("\\"):
        return {}
    var frames := int(cue.get("frames",0))
    var dirs := int(cue.get("dirs",0))
    var frame_ms := int(cue.get("frame_ms",0))
    var rects: Array = cue.get("rects",[])
    if frames < 1 or dirs != 1 or frame_ms < 1 or rects.size() != frames * dirs * 6:
        return {}
    var index := int(floor(elapsed * 1000.0 / float(frame_ms)))
    if index >= frames:
        return {}
    var offset := index * 6
    var x := int(rects[offset])
    var y := int(rects[offset+1])
    var w := int(rects[offset+2])
    var h := int(rects[offset+3])
    if w <= 1 or h <= 1:
        return {}
    var texture := _texture(file_name)
    if texture == null or x < 0 or y < 0 or x+w > texture.get_width() or y+h > texture.get_height():
        return {}
    return {"texture":texture,"region":Rect2(float(x),float(y),float(w),float(h)),
        "anchor":Vector2(float(rects[offset+4]),float(rects[offset+5]))}

func draw_effect(canvas: CanvasItem, kind: String, position: Vector2,
        elapsed: float, scale: float = 0.65) -> bool:
    var item := frame_region(kind,elapsed)
    if item.is_empty():
        return false
    var source: Rect2 = item["region"]
    var at: Vector2 = item["anchor"]
    canvas.draw_texture_rect_region(item["texture"],
        Rect2(position-at*scale,source.size*scale),source,Color(1.0,1.0,1.0,0.74))
    return true

func _texture(file_name: String) -> Texture2D:
    if cache.has(file_name):
        return cache[file_name]
    var texture := load(ATLAS_ROOT + file_name) as Texture2D
    cache[file_name] = texture
    return texture
