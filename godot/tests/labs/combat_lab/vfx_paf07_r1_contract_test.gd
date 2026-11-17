extends SceneTree
const FX=preload("res://labs/combat_lab/talisman17/duong_phu_quy_nguyen_r1.gd")
var fail:int=0
func ck(ok:bool,label:String)->void:
	if not ok:
		fail+=1
		push_error("PAF07_R1_FAILED "+label)
func _initialize()->void:call_deferred("_run")
func _run()->void:
	ck(FX.SKILL_ID=="tmb.skill.talisman.phong_an_phu.passive_02.human","canonical")
	ck(FX.EFFECT=="passive" and FX.AI_PROFILE=="passive_always_on","passive always-on")
	ck(FX.CAST_SPEED_FACTOR==.015,"candidate metadata not a game write")
	ck(FX.CAST_TIME==0 and FX.COOLDOWN==0 and FX.DURATION==0,"no cast clock")
	ck(FX.PROJECTILE_SPEED==0 and FX.NO_DAMAGE_OR_HIT,"no fabricated hit")
	ck(FX.PEARL.get_size()==Vector2(1536,1024),"24 true painted key poses")
	ck(FX.frame_index(0)==FX.frame_index(FX.LOOP),"seamless passive cycle")
	for t in [0.0,.13,.59,.98,1.57,2.38,4.5]:
		ck(FX.frame_index(t)>=0 and FX.frame_index(t)<FX.FRAMES,"key idx")
		ck(FX.frame_blend(t)>=0 and FX.frame_blend(t)<1,"frame blend")
	var lab:Control=FX.new()
	root.add_child(lab)
	await process_frame
	ck(lab.motes is CPUParticles2D,"real motes")
	ck(lab.passive_equipped and lab.motes.emitting,"equipped")
	lab.set_passive_equipped(false)
	ck(not lab.motes.emitting,"disabled")
	lab.queue_free()
	print("PAF07_R1_FOCUSED_RESULT="+("PASS" if fail==0 else "FAIL")+" failures="+str(fail)+" gameplay_unchanged=true")
	quit(0 if fail==0 else 1)
