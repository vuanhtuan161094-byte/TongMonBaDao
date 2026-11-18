extends SceneTree
const LAB = preload("res://labs/combat_lab/fist14/r3/liep_huyet_truy_da_r3.gd")
var errors := 0
func must(b: bool, tag: String) -> void:
    if not b:
        errors += 1
        push_error("FIST14_R3_FAIL " + tag)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    must(LAB.SKILL_ID == "tmb.skill.fist.huyet_quyen.active_04.human", "id")
    must(LAB.EFFECT == "mark" and LAB.ELEMENT == "nether", "effect")
    must(LAB.SHAPE == "single_target" and LAB.TARGET_LIMIT == 1, "one target")
    must(is_equal_approx(LAB.CAST_TIME, 0.45) and is_equal_approx(LAB.COOLDOWN, 8.0), "cast/cd")
    must(is_equal_approx(LAB.DECLARED_DURATION, 6.0), "six second mark")
    must(is_zero_approx(LAB.PROJECTILE_SPEED) and not LAB.HIT_COUNT_DECLARED, "no projectile or assumed hit")
    must(is_equal_approx(LAB.MARK_END - LAB.CONTACT_TIME, 6.0), "mark span")
    must(LAB.phase_at(0.22) == "gather" and LAB.phase_at(0.65) == "punch_flight", "preflight phases")
    must(LAB.phase_at(0.90) == "one_contact", "contact phase")
    must(LAB.phase_at(3.6) == "one_mark_sustain" and LAB.phase_at(6.98) == "mark_fade", "sustain/fade")
    must(LAB.mark_at(1, 0.9) == Vector2(-9999, -9999), "no second target")
    must(LAB.mark_at(0, 0.9).distance_to(LAB.mark_at(0, 3.9)) > 10.0, "mark tracks moving foe")
    must(LAB.fist_at(0.7).distance_to(LAB.fist_at(0.49)) > 45.0, "fist cinematic movement")
    must(LAB.mark_opacity(0.6) == 0.0 and LAB.mark_opacity(3.9) > 0.95 and LAB.mark_opacity(7.2) == 0.0, "mark opacity")
    var txt := FileAccess.get_file_as_string("res://labs/combat_lab/fist14/r3/liep_huyet_truy_da_r3.gd")
    for forbidden in ["SaveService.", "CombatV2.", "apply_damage", "apply_heal", "apply_status"]:
        must(not txt.contains(forbidden), "view only: " + forbidden)
    print("FIST14_R3_FOCUSED_RESULT=" + ("PASS" if errors == 0 else "FAIL") + " failures=" + str(errors))
    quit(0 if errors == 0 else 1)
