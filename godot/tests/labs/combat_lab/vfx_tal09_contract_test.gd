extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman09/chu_tuoc_hoi_hoan.gd")
var failures:=0
func check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL09_FAIL "+msg)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.hoa_phu.active_04.human","HF04 exact canonical ID")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire" and LAB.SHAPE=="circle","canonical FIRE circle")
    check(LAB.DECLARED_RADIUS==2.35 and LAB.DECLARED_RANGE==8.5,"legal circle/range")
    check(LAB.TARGET_LIMIT==3 and LAB.HIT_COUNT==1,"cap 3, one hit pulse")
    check(LAB.DECLARED_CAST_TIME==.5 and LAB.DECLARED_COOLDOWN==13.6,"catalogue cast/cooldown")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0 and LAB.DECLARED_DURATION==0.0,"no fake projectile/status")
    check(LAB.CHARGE.get_size()==Vector2(1280,960),"12 charge poses 320x320")
    check(LAB.PHOENIX.get_size()==Vector2(2048,1280),"16 painted phoenix wing poses")
    check(LAB.ORBIT.get_size()==Vector2(2560,1020),"12 original painterly orbit poses")
    check(LAB.CONTACT.get_size()==Vector2(1024,768),"10 localized contact poses")
    check(LAB.MONSTER.has_animation("walk") and LAB.MONSTER.get_frame_count("walk")>=8,"actual independent WALK monster frames")
    check(LAB.charge_gain(.30)>.65 and LAB.charge_gain(.8)==0.0,"charge visible and finite")
    check(LAB.bird_gain(.43)==0.0 and LAB.bird_gain(1.15)>.7,"phoenix after release")
    check(LAB.orbit_gain(1.25)>.75 and LAB.orbit_gain(2.5)==0.0,"bounded painted orbit")
    check(LAB.contact_gain(1.5)==0.0 and LAB.contact_gain(1.72)>.8 and LAB.contact_gain(2.1)==0.0,"ONE bounded AoE pulse")
    check(LAB.phase(.26)=="charge" and LAB.phase(1.1)=="phoenix_orbit" and LAB.phase(1.72)=="circle_contact","phase order")
    check(LAB.target_foot(0,.30).distance_to(LAB.target_foot(0,1.65))>12.0,"monster 0 moving")
    check(LAB.target_foot(1,.30).distance_to(LAB.target_foot(1,1.65))>12.0,"monster 1 moving")
    check(LAB.target_foot(2,.30).distance_to(LAB.target_foot(2,1.65))>12.0,"monster 2 moving")
    for k in range(LAB.TARGET_LIMIT):
        check(LAB.target_contact(k,1.69).distance_to(LAB.target_foot(k,1.69)+Vector2(-5,-76))<.001,"target-local hit follows moving actor "+str(k))
    check(LAB.bird_center(.65).distance_to(LAB.bird_center(1.27))>95.0,"non-static visual bird orbit")
    var inst:=LAB.new()
    root.add_child(inst)
    await process_frame
    check(inst._light!=null,"source-sprite luminosity support ready")
    var code:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman09/chu_tuoc_hoi_hoan.gd")
    for x in ["SaveService.","CombatV2.","apply_damage","apply_status","DamageService.","set_hitpoints","spawn_projectile"]:
        check(not code.contains(x),"no live game write "+x)
    print("VFX_TAL09_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" cap3_walk=true projectile_speed_zero=true one_visual_AoE=true")
    inst.queue_free()
    quit(0 if failures==0 else 1)
