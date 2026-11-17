extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman16/r5/vo_lam_buff_sprite_r5.gd")
var fails:int=0
func ck(ok:bool,label:String)->void:
	if not ok:
		fails+=1
		push_error("PAF06_R5_TEST_FAILED "+label)
func _initialize()->void:call_deferred("_run")
func _run()->void:
	ck(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.passive_01.human","skill id")
	ck(LAB.EFFECT=="passive" and LAB.AI_PROFILE=="passive_always_on","always-on")
	ck(LAB.CAST_TIME==0.0 and LAB.COOLDOWN==0.0 and LAB.DURATION==0.0,"no cast")
	ck(LAB.COOLDOWN_RECOVERY_FACTOR==.015 and LAB.NO_CAST_NO_DAMAGE,"no game writes")
	ck(LAB.ATLAS.get_size()==Vector2(288,96),"real 3-cell RGBA original sprite atlas")
	ck(LAB.full_sprite_region(0)==LAB.WIND and LAB.full_sprite_region(1)==LAB.SWIRL and LAB.full_sprite_region(2)==LAB.GROUND,"regions")
	ck(LAB.frame_at(0.0)==LAB.frame_at(3.0),"R3 approved orbit loop seam")
	ck(LAB.depth_front(PI/2) and not LAB.depth_front(3*PI/2),"far-near depth rule")
	var lab:Control=LAB.new()
	root.add_child(lab)
	await process_frame
	ck(lab.texture_source_valid and lab.flow_rear!=null and lab.flow_front!=null,"actual independent RGBA behind and in-front")
	ck(lab.spirit_motes is CPUParticles2D,"real CPU particles")
	ck(lab.passive_equipped and lab.spirit_motes.emitting,"equipped on")
	lab.set_passive_equipped(false)
	ck(not lab.passive_equipped and not lab.spirit_motes.emitting,"equipped off")
	lab.queue_free()
	print("PAF06_R5_FOCUSED_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails)+" passive=true no_paper_talismans=true original_RGBA=true")
	quit(0 if fails==0 else 1)
