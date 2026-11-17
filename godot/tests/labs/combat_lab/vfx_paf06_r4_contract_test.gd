extends SceneTree
const FX=preload("res://labs/combat_lab/talisman16/r4/vo_lam_tinh_tam_buff_r4.gd")
var fail:int=0
func ck(ok:bool,name:String)->void:
	if not ok:
		fail+=1
		push_error("PAF06_R4_CONTRACT_FAIL "+name)
func _initialize()->void:
	call_deferred("_run")
func _run()->void:
	ck(FX.SKILL_ID=="tmb.skill.talisman.phong_an_phu.passive_01.human","skill canonical")
	ck(FX.EFFECT=="passive" and FX.AI_PROFILE=="passive_always_on","always-on")
	ck(FX.NO_CAST_NO_DAMAGE and FX.CAST_TIME==0.0 and FX.COOLDOWN==0.0 and FX.DURATION==0.0,"never fake cast or impact")
	ck(FX.PROJECTILE_SPEED==0.0 and FX.COOLDOWN_RECOVERY_FACTOR==.015,"visual leaves mechanics alone")
	ck(FX.canonical_motif().contains("TALISMANS") and FX.canonical_motif().contains("HEART_LOTUS"),"specific wind+heart silhouette")
	ck(FX.R4_POSES==48 and FX.R4_COLUMNS==8,"original frame timing")
	for tex in [FX.ID_REAR,FX.ID_FRONT,FX.ID_HEART]:
		ck(tex.get_size()==Vector2(2560,1920),"three independent original RGBA atlases")
	ck(FX.identity_frame(0.0)==FX.identity_frame(3.0),"loop seam")
	ck(FX.identity_frame(.30)!=FX.identity_frame(.60),"traveling feathers motion")
	ck(FX.depth_front(PI/2.0) and not FX.depth_front(3.0*PI/2.0),"front behind actor correct")
	ck(FX.CORE_POS==Vector2(632,505),"chest center not head badge")
	var node:Control=FX.new()
	root.add_child(node)
	await process_frame
	ck(node.spirit_motes is CPUParticles2D,"real Godot CPU motes")
	ck(node.passive_equipped and node.spirit_motes.emitting,"starts active")
	node.set_passive_equipped(false)
	ck(not node.spirit_motes.emitting,"can hide VFX if passive not equipped")
	node.set_passive_equipped(true)
	ck(node.spirit_motes.emitting,"re-enable")
	node.queue_free()
	print("PAF06_R4_FOCUSED_RESULT="+("PASS" if fail==0 else "FAIL")+" failures="+str(fail)+" semantic_layers=3 view_only=true")
	quit(0 if fail==0 else 1)
