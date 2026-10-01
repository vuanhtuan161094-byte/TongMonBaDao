extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_active_scene_contract():
        return
    if not _verify_zoom_limits():
        return
    if not _verify_map_hit_region():
        return
    if not _verify_coordinate_round_trip():
        return
    if not _verify_zoom_keeps_anchor_stable():
        return
    if not _verify_pan_is_clamped():
        return
    if not _verify_min_zoom_centers_world_in_view():
        return
    if not _verify_focus_centers_target():
        return
    if not _verify_focus_handles_edge_target():
        return
    if not _verify_reset_contract():
        return

    print("P3.2 MAP CAMERA TEST PASS")
    quit(0)

func _verify_active_scene_contract() -> bool:
    if str(ProjectSettings.get_setting("application/run/main_scene", "")) != "res://scenes/p3/p3_2_landscape_sect.tscn":
        return _fail("P3.2 zoomable landscape scene must be the project main scene.")
    if not ResourceLoader.exists("res://scenes/p3/p3_2_landscape_sect.tscn"):
        return _fail("P3.2 zoomable landscape scene is missing.")
    return true

func _verify_zoom_limits() -> bool:
    if absf(SectMapCamera.clamp_zoom(0.1) - SectMapCamera.MIN_ZOOM) > 0.000001:
        return _fail("P3.2 camera did not clamp minimum zoom.")
    if absf(SectMapCamera.clamp_zoom(9.0) - SectMapCamera.MAX_ZOOM) > 0.000001:
        return _fail("P3.2 camera did not clamp maximum zoom.")
    if absf(SectMapCamera.clamp_zoom(1.25) - 1.25) > 0.000001:
        return _fail("P3.2 camera changed an in-range zoom.")
    return true

func _verify_map_hit_region() -> bool:
    var inside := SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5
    if not SectMapCamera.is_map_screen_point(inside):
        return _fail("P3.2 camera rejected a point inside the map viewport.")
    if SectMapCamera.is_map_screen_point(Vector2(30.0, 30.0)):
        return _fail("P3.2 camera accepted a point inside fixed HUD as map input.")
    return true

func _verify_coordinate_round_trip() -> bool:
    var world_point := Vector2(742.5, 318.25)
    var map_position := Vector2(-184.0, -72.0)
    var zoom := 1.42
    var screen_point := SectMapCamera.world_to_screen(world_point, map_position, zoom)
    var recovered := SectMapCamera.screen_to_world(screen_point, map_position, zoom)
    if world_point.distance_to(recovered) > 0.0001:
        return _fail("P3.2 screen/world camera conversion is not reversible.")
    return true

func _verify_zoom_keeps_anchor_stable() -> bool:
    var anchor := Vector2(700.0, 350.0)
    var result := SectMapCamera.zoom_around_screen_point(Vector2.ZERO, 1.0, 1.2, anchor)
    var zoom := float(result["zoom"])
    var position: Vector2 = result["position"]
    var world_anchor_before := SectMapCamera.screen_to_world(anchor, Vector2.ZERO, 1.0)
    var world_anchor_after := SectMapCamera.screen_to_world(anchor, position, zoom)
    if world_anchor_before.distance_to(world_anchor_after) > 0.001:
        return _fail("P3.2 pinch/wheel zoom does not preserve the screen anchor.")
    return true

func _verify_pan_is_clamped() -> bool:
    var far_positive := SectMapCamera.pan_position(Vector2.ZERO, Vector2(100000.0, 100000.0), 1.8)
    var far_negative := SectMapCamera.pan_position(Vector2.ZERO, Vector2(-100000.0, -100000.0), 1.8)
    var positive_clamped := SectMapCamera.clamp_position(far_positive, 1.8)
    var negative_clamped := SectMapCamera.clamp_position(far_negative, 1.8)
    if far_positive != positive_clamped or far_negative != negative_clamped:
        return _fail("P3.2 pan escaped camera clamp bounds.")
    if far_positive == far_negative:
        return _fail("P3.2 pan clamp collapsed both map edges to one point.")
    return true

func _verify_min_zoom_centers_world_in_view() -> bool:
    var zoom := SectMapCamera.MIN_ZOOM
    var position := SectMapCamera.clamp_position(Vector2.ZERO, zoom)
    var top_left := SectMapCamera.world_to_screen(Vector2.ZERO, position, zoom)
    var bottom_right := SectMapCamera.world_to_screen(SectMapCamera.WORLD_SIZE, position, zoom)
    var world_center := (top_left + bottom_right) * 0.5
    var expected_center := SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5
    if world_center.distance_to(expected_center) > 0.001:
        return _fail("P3.2 minimum zoom did not center the smaller map inside the visible map viewport.")
    return true

func _verify_focus_centers_target() -> bool:
    var world_target := Vector2(700.0, 360.0)
    var result := SectMapCamera.focus_transform(world_target, SectMapCamera.FOCUS_ZOOM)
    var zoom := float(result["zoom"])
    var position: Vector2 = result["position"]
    var screen_target := SectMapCamera.world_to_screen(world_target, position, zoom)
    var expected_center := SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5
    if screen_target.distance_to(expected_center) > 0.001:
        return _fail("P3.2 focus transform did not center an unclamped target.")
    return true

func _verify_focus_handles_edge_target() -> bool:
    var world_target := Vector2(1220.0, 570.0)
    var result := SectMapCamera.focus_transform(world_target, SectMapCamera.FOCUS_ZOOM)
    var zoom := float(result["zoom"])
    var position: Vector2 = result["position"]
    if position != SectMapCamera.clamp_position(position, zoom):
        return _fail("P3.2 edge focus escaped camera bounds.")
    var screen_target := SectMapCamera.world_to_screen(world_target, position, zoom)
    if not SectMapCamera.VIEW_RECT.has_point(screen_target):
        return _fail("P3.2 edge focus moved the selected target under fixed HUD or outside the visible map viewport.")
    return true

func _verify_reset_contract() -> bool:
    var result := SectMapCamera.reset_transform()
    if absf(float(result["zoom"]) - SectMapCamera.DEFAULT_ZOOM) > 0.000001:
        return _fail("P3.2 reset did not restore default zoom.")
    var reset_position: Vector2 = result["position"]
    if reset_position != SectMapCamera.clamp_position(Vector2.ZERO, SectMapCamera.DEFAULT_ZOOM):
        return _fail("P3.2 reset did not restore canonical map position.")
    return true

func _fail(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
