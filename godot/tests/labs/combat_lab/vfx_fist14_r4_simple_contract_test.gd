extends SceneTree
const LAB = preload("res://labs/combat_lab/fist14/r4_simple/fist14_simple.gd")
var errors := 0

func must(ok: bool, tag: String) -> void:
	if not ok:
		errors += 1
		push_error("FIST14_R4_SIMPLE_FAIL " + tag)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	must(LAB.SKILL_ID == "tmb.skill.fist.huyet_quyen.active_04.human", "canonical id")
	must(LAB.EFFECT == "mark" and LAB.ELEMENT == "nether", "canonical type")
	must(LAB.SHAPE == "single_target" and LAB.TARGET_LIMIT == 1, "one target")
	must(is_equal_approx(LAB.CAST_TIME, 0.45) and is_equal_approx(LAB.COOLDOWN, 8.0), "cast and cooldown")
	must(is_equal_approx(LAB.DURATION, 6.0) and is_equal_approx(LAB.RANGE, 2.8), "duration and range")
	must(is_zero_approx(LAB.PROJECTILE_SPEED) and not LAB.HIT_COUNT_DECLARED, "no invented projectile or hit count")
	must(LAB.phase_at(0.22) == "windup", "native windup")
	must(LAB.phase_at(0.65) == "fist_travel", "moving fist")
	must(LAB.phase_at(0.99) == "local_contact", "single local impact")
	must(LAB.contact_opacity(0.65) == 0.0 and LAB.contact_opacity(0.99) > 0.0, "impact timing")
	must(LAB.fist_at(0.88).distance_to(LAB.fist_at(0.49)) > 100.0, "directed short travel")
	must(LAB.foe_at(0.99).distance_to(LAB.foe_at(0.22)) > 12.0, "moving target evidence")
	var text := FileAccess.get_file_as_string("res://labs/combat_lab/fist14/r4_simple/fist14_simple.gd")
	for forbidden in ["CombatV2.", "SaveService.", "apply_damage", "apply_heal", "apply_status"]:
		must(not text.contains(forbidden), "view only: " + forbidden)
	print("FIST14_R4_SIMPLE_FOCUSED_RESULT=" + ("PASS" if errors == 0 else "FAIL") + " failures=" + str(errors))
	quit(0 if errors == 0 else 1)
