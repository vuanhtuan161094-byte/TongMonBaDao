extends SceneTree
const LAB = preload("res://labs/combat_lab/talisman15/r4/thai_huyen_phong_gioi_r4.gd")
var fails: int=0
func ck(ok: bool, note: String) -> void:
	if not ok:
		fails+=1
		push_error("PAF05_R4_FAILED "+note)
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	ck(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.ultimate.human","skill ID")
	ck(LAB.CAP==3 and LAB.RADIUS==2.1,"cap and radius")
	ck(LAB.CAST==.9 and LAB.COOLDOWN==23.0 and LAB.STATUS==7.0,"timing")
	for k in range(3):
		ck(LAB.in_circle(k,1.49),"three monsters in area "+str(k))
		ck(LAB.target(k,.3).distance_to(LAB.target(k,1.49))>8,"walking target "+str(k))
		ck(LAB.target_anchor(k,1.49).distance_to(LAB.target(k,1.49)+Vector2(0,-86))<.001,"anchoring "+str(k))
		ck(LAB.mark_alive(k,1.5) and LAB.mark_alive(k,7.95),"seven-second status "+str(k))
		ck(not LAB.mark_alive(k,8.34),"status expiry "+str(k))
	ck(not LAB.in_circle(3,1.4),"hard target cap")
	ck(LAB.field_envelope(1.16)>.3 and LAB.field_envelope(2.7)==0.0,"short field movie")
	ck(LAB.charge_envelope(.42)>.3 and LAB.charge_envelope(1.2)==0.0,"short caster focus")
	ck(LAB.contact_envelope(1.49)>.3 and LAB.contact_envelope(2.1)==0.0,"real local contact")
	var node: Control=LAB.new()
	root.add_child(node)
	await process_frame
	ck(node.shader_mat!=null and node.ambient is CPUParticles2D,"living shader and CPU particles")
	ck(node.bursts.size()==3,"per-target contact emitters")
	node.queue_free()
	print("VFX_PAF05_R4_FOCUSED_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails))
	quit(0 if fails==0 else 1)
