class_name SectMapCamera
extends RefCounted

const WORLD_SIZE := Vector2(1280.0, 720.0)
const VIEW_RECT := Rect2(Vector2(252.0, 72.0), Vector2(1028.0, 570.0))

const MIN_ZOOM := 0.75
const DEFAULT_ZOOM := 1.0
const MAX_ZOOM := 1.80
const FOCUS_ZOOM := 1.35

static func clamp_zoom(value: float) -> float:
    return clampf(value, MIN_ZOOM, MAX_ZOOM)

static func is_map_screen_point(screen_point: Vector2) -> bool:
    return VIEW_RECT.has_point(screen_point)

static func world_to_screen(world_point: Vector2, map_position: Vector2, zoom: float) -> Vector2:
    return map_position + world_point * clamp_zoom(zoom)

static func screen_to_world(screen_point: Vector2, map_position: Vector2, zoom: float) -> Vector2:
    return (screen_point - map_position) / maxf(clamp_zoom(zoom), 0.000001)

static func zoom_around_screen_point(current_position: Vector2, old_zoom: float, requested_zoom: float, screen_anchor: Vector2) -> Dictionary:
    var from_zoom := clamp_zoom(old_zoom)
    var to_zoom := clamp_zoom(requested_zoom)
    var world_anchor := screen_to_world(screen_anchor, current_position, from_zoom)
    var candidate_position := screen_anchor - world_anchor * to_zoom
    return {
        "zoom": to_zoom,
        "position": clamp_position(candidate_position, to_zoom)
    }

static func pan_position(current_position: Vector2, delta: Vector2, zoom: float) -> Vector2:
    return clamp_position(current_position + delta, zoom)

static func focus_transform(world_point: Vector2, requested_zoom: float = FOCUS_ZOOM) -> Dictionary:
    var zoom := clamp_zoom(requested_zoom)
    var center := VIEW_RECT.position + VIEW_RECT.size * 0.5
    var candidate_position := center - world_point * zoom
    return {
        "zoom": zoom,
        "position": clamp_position(candidate_position, zoom)
    }

static func reset_transform() -> Dictionary:
    return {
        "zoom": DEFAULT_ZOOM,
        "position": clamp_position(Vector2.ZERO, DEFAULT_ZOOM)
    }

static func clamp_position(candidate: Vector2, zoom: float) -> Vector2:
    var applied_zoom := clamp_zoom(zoom)
    var scaled_size := WORLD_SIZE * applied_zoom
    return Vector2(
        _clamp_axis(candidate.x, scaled_size.x, VIEW_RECT.position.x, VIEW_RECT.size.x),
        _clamp_axis(candidate.y, scaled_size.y, VIEW_RECT.position.y, VIEW_RECT.size.y)
    )

static func _clamp_axis(candidate: float, scaled_world_size: float, view_start: float, view_size: float) -> float:
    if scaled_world_size <= view_size:
        return view_start + (view_size - scaled_world_size) * 0.5
    var minimum := view_start + view_size - scaled_world_size
    var maximum := view_start
    return clampf(candidate, minimum, maximum)
