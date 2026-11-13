extends SceneTree
const LAB = preload("res://labs/combat_lab/calibration00/thunder_calibration.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_CAL00_FAIL " + label)

func _run() -> void:
    _check(LAB.STRIKE_COUNT == 6, "six original beats")
    _check(LAB.CONTACTS.size() == 3, "three locked mock contacts")
    _check(LAB.MAX_SIDE_BRANCHES <= 1, "no lightning web")
    _check(LAB.active_primary_count(1.10) == 0, "no premature discharge")
    _check(LAB.active_primary_count(1.22) == 1, "single hero strike")
    _check(LAB.active_primary_count(1.47) == 2, "overlap only between adjacent beats")
    _check(LAB.active_primary_count(3.15) == 0, "all primaries dissipated")
    var max_concurrent := 0
    for frame in range(280):
        max_concurrent = maxi(max_concurrent,
            LAB.active_primary_count(float(frame) / 60.0))
    _check(max_concurrent <= 2, "maximum two concurrent main strokes")
    for beat in range(6):
        _check(LAB.selected_contact(beat) == LAB.CONTACTS[beat % 3],
            "mock target mapping " + str(beat))
    var p := LAB.visual_pulse(0.17)
    _check(p > 0.8 and LAB.visual_pulse(0.36) == 0.0,
        "clean visible peak and bounded life")
    print("VFX_CAL00_THUNDER_FOCUSED_RESULT=" +
        ("PASS" if failures == 0 else "FAIL") +
        " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
