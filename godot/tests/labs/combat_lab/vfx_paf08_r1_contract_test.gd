extends SceneTree
const FX=preload("res://labs/combat_lab/talisman18/luu_van_liem_tuc_r1.gd")
var failed:int=0
func ck(ok:bool,name:String)->void:
	if not ok:
		failed+=1
		push_error("PAF08_R1_CONTRACT_FAIL "+name)
func _initialize()->void:
	call_deferred("_run")
func _run()->void:
	ck(FX.SKILL_ID=="tmb.skill.talisman.phong_an_phu.passive_03.human","canonical skill")
	ck(FX.EFFECT=="passive" and FX.ELEMENT=="wind" and FX.AI_PROFILE=="passive_always_on","passive only")
	ck(FX.CAST_TIME==0.0 and FX.COOLDOWN==0.0 and FX.DURATION==0.0,"no fabricated cast duration")
	ck(FX.DAMAGE_RATIO==0.0 and FX.PROJECTILE_SPEED==0.0 and FX.NO_HIT_OR_CAST,"no fake projectile/hit")
	ck(FX.OUTGOING_FACTOR==.015,"catalogue candidate outgoing modifier")
	ck(FX.FRAMES==36 and FX.COLS==9 and FX.CELL==320,"3 atlas X 36 keyposes")
	for tex in [FX.INK_REAR,FX.INK_FRONT,FX.INK_SCRIPT]:
		ck(tex.get_size()==Vector2(2880,1280),"original alpha atlas dimensions")
	ck(FX.frame_index(0.0)==FX.frame_index(3.0),"continuous 3 second loop")
	ck(FX.monster_foot(0.4).distance_to(FX.monster_foot(1.9))>10.0,"unrelated moving enemy")
	for t in [0.0,.18,.72,1.31,2.37,3.4,4.05]:
		ck(FX.frame_index(t)>=0 and FX.frame_index(t)<36,"pose index in bound")
		ck(FX.frame_blend(t)>=0.0 and FX.frame_blend(t)<1.0,"blend in range")
	var lab:Control=FX.new()
	root.add_child(lab)
	await process_frame
	ck(lab.motes is CPUParticles2D and lab.motes.emitting,"actual Godot particles")
	lab.set_passive_equipped(false)
	ck(not lab.motes.emitting and not lab.passive_equipped,"off state renders no VFX")
	lab.set_passive_equipped(true)
	ck(lab.motes.emitting,"restart")
	lab.queue_free()
	print("PAF08_R1_FOCUSED_RESULT="+("PASS" if failed==0 else "FAIL")+" failures="+str(failed)+" no_fake_cast=true RGBA_layers=3")
	quit(0 if failed==0 else 1)
