extends SceneTree
const VIEWER = preload("res://labs/combat_lab/reference01/jx_vl_v9_reference_viewer.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_run")
func _check(ok: bool, label: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_REF01_FAIL " + label)
func _run() -> void:
    var viewer := VIEWER.new()
    root.add_child(viewer)
    await process_frame
    _check(viewer.issues().is_empty(), "all 6 authentic resources loaded")
    for k in ["jx_wudu_63_impact","jx_wudang_158_precast","jx_wudang_158_cast","jx_wudang_158_impact","sword_cast","sword_hit"]:
        var rec: Dictionary = viewer.metadata(k)
        _check(not rec.is_empty(), "source metadata " + k)
        if not rec.is_empty():
            _check((rec["atlas"] as Texture2D) != null, "source sprite " + k)
            _check((rec["rects"] as Array).size() >= int(rec["frames"]) * 6, "source frame rects " + k)
    _check(VIEWER.frame_index(0.055, 56.0, 13) == 0, "Wudu first frame")
    _check(VIEWER.frame_index(0.057, 56.0, 13) == 1, "Wudu second frame")
    _check(VIEWER.frame_index(0.728, 56.0, 13) == -1, "Wudu clip bounded")
    _check(VIEWER.frame_index(-1.0, 56.0, 13) == -1, "no pre-release frame")
    _check(VIEWER.TRACKS.size() == 4, "four lanes")
    print("VFX_REF01_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    viewer.queue_free()
    quit(0 if failures == 0 else 1)
