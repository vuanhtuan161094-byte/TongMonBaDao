extends SceneTree
const LAB = preload("res://labs/combat_lab/fist14/r5/liep_huyet_truy_da_r5.gd")
var errors := 0

func must(condition: bool, tag: String) -> void:
	if not condition:
		errors += 1
		push_error("FIST14_R5_FAIL " + tag)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	must(LAB.SKILL_ID == "tmb.skill.fist.huyet_quyen.active_04.human", "canonical id")
	must(LAB.EFFECT == "mark" and LAB.ELEMENT == "nether", "effect and element")
	must(LAB.SHAPE == "single_target" and LAB.TARGET_LIMIT == 1, "single target")
	must(is_equal_approx(LAB.CAST_TIME, 0.45) and is_equal_approx(LAB.COOLDOWN, 8.0), "cast and cooldown")
	must(is_equal_approx(LAB.DECLARED_DURATION, 6.0), "declared mark duration")
	must(is_zero_approx(LAB.PROJECTILE_SPEED) and not LAB.HIT_COUNT_DECLARED, "no declared projectile or invented hit count")
	must(LAB.phase_at(0.20) == "charge", "charge phase")
	must(LAB.phase_at(0.62) == "target_local_punch", "peak phase")
	must(LAB.phase_at(0.94) == "one_visual_contact", "contact phase")
	must(LAB.phase_at(2.0) == "one_mark_sustain", "mark sustain")
	must(LAB.phase_at(7.0) == "mark_fade", "mark fade")
	var start := LAB.target_feet_at(0.20)
	var contact := LAB.target_feet_at(0.94)
	must(start.distance_to(contact) >= 55.0, "monster moves during visual sequence")
	must(LAB.target_anchor_at(0, 0.94).distance_to(LAB.target_chest_at(0.94)) < 0.01, "peak/contact anchor follows selected moving target")
	must(LAB.contact_anchor_at(0.94).distance_to(LAB.contact_anchor_at(0.20)) >= 55.0, "contact anchor follows target motion")
	must(LAB.target_anchor_at(1, 0.94) == Vector2(-9999.0, -9999.0), "no second target receives mark")
	must(is_zero_approx(LAB.mark_opacity(0.89)) and LAB.mark_opacity(3.9) > 0.99 and is_zero_approx(LAB.mark_opacity(7.21)), "six second mark and fade")
	var packet_script := FileAccess.get_file_as_string("res://labs/combat_lab/fist14/r5/liep_huyet_truy_da_r5.gd")
	for forbidden in ["SaveService.", "CombatV2.", "apply_damage", "apply_heal", "apply_status", "projectile_speed ="]:
		must(not packet_script.contains(forbidden), "view-only contract: " + forbidden)
	print("FIST14_R5_FOCUSED_RESULT=" + ("PASS" if errors == 0 else "FAIL") + " failures=" + str(errors))
	quit(0 if errors == 0 else 1)
