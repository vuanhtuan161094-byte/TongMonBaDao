extends Node2D
## Shared LAB sprite layer: accepts original first-party atlas, never creates art.
## External authority/preview supplies anchors and visual local time.
## No rig, no gameplay writes, no hit/damage/status creation.
var atlas: Texture2D
var regions: Array = []
var semantic := "projectile" # projectile | cast | impact | guard | mark
var local_duration := 1.0
var local_time := 0.0
var source_anchor := Vector2.ZERO
var target_anchor := Vector2.ZERO
var scale_factor := 1.0
var opacity := 1.0
var rendered_frame := -1
var layer_name := "back"

func configure(source_atlas: Texture2D, atlas_regions: Array, visual_kind: String,
        seconds: float, size_factor: float = 1.0, alpha: float = 1.0,
        depth: String = "back") -> bool:
    if source_atlas == null or atlas_regions.is_empty() or seconds <= 0.0:
        return false
    if not visual_kind in ["projectile","cast","impact","guard","mark"]:
        return false
    for rect in atlas_regions:
        if not (rect is Rect2) or rect.size.x <= 0.0 or rect.size.y <= 0.0:
            return false
    atlas = source_atlas
    regions = atlas_regions.duplicate()
    semantic = visual_kind
    local_duration = seconds
    local_time = 0.0
    scale_factor = maxf(0.01,size_factor)
    opacity = clampf(alpha,0.0,1.0)
    layer_name = depth
    z_index = -2 if depth == "back" else (2 if depth == "front" else 0)
    rendered_frame = 0
    queue_redraw()
    return true

func set_anchors(from_point: Vector2, to_point: Vector2) -> void:
    source_anchor = from_point
    target_anchor = to_point
    queue_redraw()

func seek(seconds: float) -> void:
    local_time = maxf(0.0,seconds)
    rendered_frame = -1
    if atlas != null and local_time < local_duration:
        rendered_frame = clampi(int(floor(local_time/local_duration*float(regions.size()))),0,regions.size()-1)
    queue_redraw()

func visual_anchor() -> Vector2:
    if semantic == "projectile":
        return source_anchor.lerp(target_anchor,clampf(local_time/local_duration,0.0,1.0))
    if semantic in ["impact","mark"]:
        return target_anchor
    return source_anchor

func _draw() -> void:
    if atlas == null or rendered_frame < 0:
        return
    var source_region: Rect2 = regions[rendered_frame]
    var footprint: Vector2 = source_region.size*scale_factor
    var t := clampf(local_time/local_duration,0.0,1.0)
    var fade := 1.0-smoothstep(0.85,1.0,t)
    var pos := visual_anchor()
    draw_texture_rect_region(atlas,Rect2(pos-footprint*0.5,footprint),
        source_region,Color(1.0,1.0,1.0,opacity*fade))
