extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman16/r3/vo_lam_orbit_buff_r3.gd")
var failures: int=0
func ck(condition: bool,name: String) -> void:
	if not condition:
		failures+=1
		push_error("PAF06_R3_FAIL "+name)
func _initialize() -> void:
	call_deferred("_check")
func _check() -> void:
	ck(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.passive_01.human","canonical identity")
	ck(LAB.EFFECT=="passive" and LAB.AI_PROFILE=="passive_always_on","passive not proc/cast")
	ck(LAB.CAST_TIME==0.0 and LAB.COOLDOWN==0.0 and LAB.DURATION==0.0,"no gameplay spell timer")
	ck(LAB.PROJECTILE_SPEED==0.0 and LAB.NO_CAST_NO_DAMAGE,"no fake attack")
	ck(LAB.COOLDOWN_RECOVERY_FACTOR==.015,"catalogue modifier unchanged")
	ck(LAB.R3_POSES==48 and LAB.R3_COLUMNS==8,"painted orbit frame count")
	ck(LAB.R3_REAR.get_size()==Vector2(2560,1920),"rear source atlas size")
	ck(LAB.R3_FRONT.get_size()==Vector2(2560,1920),"front source atlas size")
	ck(LAB.R3_SPARK.get_size()==Vector2(2560,1920),"spark source atlas size")
	ck(LAB.frame_at(0.0)==LAB.frame_at(3.0),"true 3s seamless orbit")
	ck(LAB.moving_caustic(0.0,0)!=LAB.moving_caustic(.7,0),"orbit really rotates")
	ck(LAB.moving_caustic(.0,1)!=LAB.moving_caustic(.7,1),"second orbit rotates opposite direction")
	ck(LAB.depth_front(PI/2.0) and not LAB.depth_front(3.0*PI/2.0),"actor depth split")
	for v in [.03,.45,1.33,2.64,3.91]:
		ck(LAB.frame_at(v)>=0 and LAB.frame_at(v)<48,"pose index "+str(v))
		ck(LAB.blend_at(v)>=0 and LAB.blend_at(v)<1.0,"blend index "+str(v))
	ck(LAB.decoy_foot(.3).distance_to(LAB.decoy_foot(2.2))>8.0,"real WALK decoy")
	var fx: Control=LAB.new()
	root.add_child(fx)
	await process_frame
	ck(fx.spirit_motes is CPUParticles2D,"actual Godot motes")
	ck(fx.passive_equipped and fx.spirit_motes.emitting,"always-on visual")
	fx.set_passive_equipped(false)
	ck(not fx.passive_equipped and not fx.spirit_motes.emitting,"buff can be visually turned off")
	fx.set_passive_equipped(true)
	ck(fx.passive_equipped and fx.spirit_motes.emitting,"buff returns")
	fx.queue_free()
	print("PAF06_R3_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" actual_orbit=2 ring_depth=BACK_FRONT passive=true")
	quit(0 if failures==0 else 1)
