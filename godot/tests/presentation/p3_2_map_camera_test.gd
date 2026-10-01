extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_zoom_limits():
        return
    if not _verify_zoom_keeps_anchor_stable():
        return
    if not _verify_pan_is_clamped():
        return
    if not _verify_focus_centers_target():
        return
    if not _verify_reset_contract():
        return

    print("P3.2 MAP CAMERA TEST PASS")
    quit(0)

func _verify_zoom_limits() -> bool:
    if absf(SectMapCamera.clamp_zoom(0.1) - SectMapCamera.MIN_ZOOM) > 0.000001:
        return _fail("P3.2 camera did not clamp minimum zoom.")
    if absf(SectMapCamera.clamp_zoom(9.0) - SectMapCamera.MAX_ZOOM) > 0.000001:
        return _fail("P3.2 camera did not clamp maximum zoom.")
    if absf(SectMapCamera.clamp_zoom(1.25) - 1.25) > 0.000001:
        return _fail("P3.2 camera changed an in-range zoom.")
    return true

func _verify_zoom_keeps_anchor_stable() -> bool:
    var anchor := Vector2(700.0, 350.0)
    var result := SectMapCamera.zoom_around_screen_point(Vector2.ZERO, 1.0, 1.2, anchor)
    var zoom := float(result["zoom"])
    var position := Vector2(result["position"])
    var world_anchor_before := anchor
    var world_anchor_after := (anchor - position) / zoom
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

func _verify_focus_centers_target() -> bool:
    var world_target := Vector2(700.0, 360.0)
    var result := SectMapCamera.focus_transform(world_target, SectMapCamera.FOCUS_ZOOM)
    var zoom := float(result["zoom"])
    var position := Vector2(result["position"])
    var screen_target := position + world_target * zoom
    var expected_center := SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5
    if screen_target.distance_to(expected_center) > 0.001:
        return _fail("P3.2 focus transform did not center an unclamped target.")
    return true

func _verify_reset_contract() -> bool:
    var result := SectMapCamera.reset_transform()
    if absf(float(result["zoom"]) - SectMapCamera.DEFAULT_ZOOM) > 0.000001:
        return _fail("P3.2 reset did not restore default zoom.")
    if Vector2(result["position"]) != SectMapCamera.clamp_position(Vector2.ZERO, SectMapCamera.DEFAULT_ZOOM):
        return _fail("P3.2 reset did not restore canonical map position.")
    return true

func _fail(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
