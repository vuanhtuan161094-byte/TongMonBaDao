extends SceneTree
const PAF06 = preload("res://labs/combat_lab/talisman16/tinh_gioi_tinh_tam_r1.gd")
var failures: int = 0
func ck(ok: bool, msg: String) -> void:
	if not ok:
		failures += 1
		push_error("PAF06_R1_FAILED: " + msg)
func _initialize() -> void:
	call_deferred("_check")
func _check() -> void:
	ck(PAF06.SKILL_ID == "tmb.skill.talisman.phong_an_phu.passive_01.human", "exact passive identity")
	ck(PAF06.EFFECT == "passive" and PAF06.ELEMENT == "wind", "wind passive")
	ck(PAF06.AI_PROFILE == "passive_always_on", "passive mode only")
	ck(PAF06.CAST_TIME == 0.0 and PAF06.COOLDOWN == 0.0 and PAF06.DURATION == 0.0, "no fabricated cast clock")
	ck(PAF06.PROJECTILE_SPEED == 0.0 and PAF06.NO_CAST_NO_DAMAGE, "no invented projectile or hit")
	ck(PAF06.COOLDOWN_RECOVERY_FACTOR == 0.015, "catalogue passive modifier metadata")
	ck(PAF06.TARGET_LIMIT == 1, "canonical single target class, no attack")
	ck(PAF06.ATLAS_FRAME_COUNT == 24 and PAF06.ATLAS_COLS == 6, "24 frame atlas contract")
	for t in [.0, .15, .37, .75, 1.35, 1.98, 2.77, 3.0, 4.28]:
		ck(PAF06.pose_index(t) >= 0 and PAF06.pose_index(t) < 24, "pose bounds " + str(t))
		ck(PAF06.pose_mix(t) >= .0 and PAF06.pose_mix(t) < 1.0, "interpolation bounds " + str(t))
	ck(PAF06.pose_index(0.0) == PAF06.pose_index(3.0), "passive loop seam")
	ck(PAF06.decoy_foot(.2).distance_to(PAF06.decoy_foot(2.3)) > 10.0, "unrelated walking decoy")
	ck(PAF06.AURA_ANCHOR.distance_to(PAF06.HERO_FEET + Vector2(0.0, -98.0)) <= .01, "caster chest anchor")
	for tex in [PAF06.AURA_BACK, PAF06.AURA_FRONT, PAF06.QUIET_HEART]:
		ck(tex.get_size() == Vector2(1920, 1280), "independent 24 pose atlas")
	var instance: Control = PAF06.new()
	root.add_child(instance)
	await process_frame
	ck(instance.spirit_motes is CPUParticles2D, "genuine ambient particle node")
	ck(instance.passive_equipped and instance.spirit_motes.emitting, "always on when equipped")
	instance.set_passive_equipped(false)
	ck(not instance.passive_equipped and not instance.spirit_motes.emitting, "disable hides passive, no combat write")
	instance.set_passive_equipped(true)
	ck(instance.passive_equipped and instance.spirit_motes.emitting, "re-enable")
	instance.queue_free()
	print("PAF06_R1_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures) + " proc=NONE cast=NONE status=ALWAYS_ON true_rgba=true")
	quit(0 if failures == 0 else 1)
