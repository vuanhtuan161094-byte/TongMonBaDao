extends SceneTree
const LAB = preload("res://labs/combat_lab/poison01/xa_anh_quan_mach.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_POI01_FAIL " + label)

func _run() -> void:
    _check(LAB.SKILL_ID == "tmb.skill.poison.co_doc.active_02.human", "canonical exact skill ID")
    _check(LAB.FLIGHT_FRAMES == 9 and LAB.COIL_FRAMES == 12, "unique independent serpent poses")
    _check(LAB.phase_at(0.30) == "charge", "anticipation")
    _check(LAB.phase_at(1.10) == "flight", "one moving snake")
    _check(LAB.phase_at(2.10) == "coil", "single-target wrap")
    _check(LAB.phase_at(3.10) == "dissolve", "no sticky status")
    _check(LAB.phase_at(3.80) == "idle", "fully faded")
    _check(LAB.anchor() == LAB.VICTIM + Vector2(0.0, -57.0), "one fixed lab-only visual anchor")
    _check(LAB.flight_gain(0.50) == 0.0 and LAB.flight_gain(2.10) == 0.0, "bounded flight")
    _check(LAB.coil_gain(1.00) == 0.0 and LAB.coil_gain(3.80) == 0.0, "bounded wrap")
    _check(not LAB.visual_contact(0.50) and LAB.visual_contact(2.10), "visual contact only after arrival")
    var source := FileAccess.get_file_as_string("res://labs/combat_lab/poison01/xa_anh_quan_mach.gd")
    _check(not "SaveService.save" in source and not "CombatV2." in source and not "V63FeatureGates." in source,
        "no gameplay authority calls")
    print("VFX_POI01_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
