extends SceneTree
## Focused LAB-only inheritance contract; no gameplay or simulated extra hit.
const F = preload("res://labs/combat_lab/talisman15/r5f/thai_huyen_phong_gioi_r5f.gd")
const E = preload("res://labs/combat_lab/talisman15/r5/thai_huyen_phong_gioi_r5.gd")
var failures := 0
func verify(ok: bool, reason: String) -> void:
	if not ok:
		failures += 1
		push_error("PAF05_R5F_FAIL " + reason)
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	verify(F.REVISION == "PAF05_R5F_CHARGE_ONLY_G3_5_CANDIDATE", "revision")
	verify(F.SKILL_ID == E.SKILL_ID and F.CAP == 3 and F.RADIUS == 2.1, "same canonical circle mark cap3")
	verify(F.CAST == .9 and F.COOLDOWN == 23.0 and F.STATUS == 7.0, "unchanged clocks")
	verify(F.RECEIPT == E.RECEIPT and F.FORM_START == E.FORM_START and F.FORM_END == E.FORM_END, "unchanged legal simulated contact")
	verify(F.CHARGE_TEX.get_size() == Vector2(1280, 960), "12 distinct R5F isolated RGBA wind silk poses")
	verify(F.CHARGE_TEX.resource_path.ends_with("/r5f/assets/paf05_r5f_charge.webp"), "R5F source separated from frozen R5E")
	verify(F.charge_frame_at(.08) < F.charge_frame_at(.54) and F.charge_frame_at(.54) < F.charge_frame_at(.85), "distinct authored pose progression")
	verify(F.charge_alpha_at(.42) > 0.0 and F.charge_alpha_at(1.1) == 0.0, "only charge window")
	for k in range(3):
		verify(F.in_circle(k, F.RECEIPT), "same legal locked target " + str(k))
		verify(F.target(k,.25).distance_to(F.target(k,1.49)) > 8.0, "moving original target " + str(k))
		verify(F.latched_mark(k,8.28) and not F.latched_mark(k,8.34), "status expiry unchanged " + str(k))
	verify(not F.latched_mark(3,1.5), "no fourth target")
	var fx: Control = F.new()
	root.add_child(fx)
	await process_frame
	verify(fx.shader_mat != null and fx.bursts.size() == 3 and fx.glow != null, "parent field and contact layers retained")
	fx.queue_free()
	print("VFX_PAF05_R5F_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures) + " source=original_12_pose_painted_rgba only_charge_override=true")
	quit(0 if failures == 0 else 1)
