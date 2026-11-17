extends SceneTree
const R5=preload("res://labs/combat_lab/talisman15/r5/thai_huyen_phong_gioi_r5.gd")
var errs: int=0
func check(value: bool,msg: String) -> void:
	if not value:
		errs+=1
		push_error("PAF05_R5_FAIL "+msg)
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	check(R5.SKILL_ID=="tmb.skill.talisman.phong_an_phu.ultimate.human","exact canonical skill")
	check(R5.CAP==3 and R5.RADIUS==2.1,"circle cap3")
	check(R5.CAST==.9 and R5.COOLDOWN==23.0 and R5.STATUS==7,"three clocks")
	for k in range(3):
		check(R5.in_circle(k,R5.RECEIPT),"legal receipt k="+str(k))
		check(R5.target(k,.30).distance_to(R5.target(k,1.49))>8.0,"moving target k="+str(k))
		check(R5.latched_mark(k,1.40) and R5.latched_mark(k,8.28),"mark persists through 7s k="+str(k))
		check(not R5.latched_mark(k,8.34),"mark expires k="+str(k))
		check(R5.mark_pos(k,1.40).distance_to(R5.target_anchor(k,1.40)+Vector2(32,10))<.01,"shoulder contact follows target "+str(k))
	check(not R5.latched_mark(3,1.4),"fourth target forbidden")
	check(R5.mark_frame(1.33)==0 and R5.mark_frame(1.55)>=2,"handwritten stamp reveals distinct phases")
	check(R5.MARK_TEX.get_size()==Vector2(1280,960),"mark 12 real RGBA poses")
	check(R5.CONTACT_TEX.get_size()==Vector2(1280,960),"contact 11 real RGBA poses")
	var actor: Control=R5.new()
	root.add_child(actor)
	await process_frame
	check(actor.shader_mat!=null and actor.ambient is CPUParticles2D,"live VFX shader and particles")
	check(actor.bursts.size()==3,"contact particle targets")
	check(actor.glow!=null,"localized hot light")
	actor.queue_free()
	print("VFX_PAF05_R5_FOCUSED_RESULT="+("PASS" if errs==0 else "FAIL")+" failures="+str(errs)+" status7s_separate=true sprite=handpainted_rune targets=3")
	quit(0 if errs==0 else 1)
