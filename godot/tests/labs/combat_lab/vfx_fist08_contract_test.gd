extends SceneTree
const LAB=preload("res://labs/combat_lab/fist08/phan_chan_quyen.gd")
var errors:=0
func ck(ok: bool,why: String)->void:
    if not ok:
        errors+=1
        push_error("VFX_FIST08_FAIL "+why)
func _initialize()->void:
    call_deferred("_check_all")
func _check_all()->void:
    ck(LAB.SKILL_ID=="tmb.skill.fist.kim_cang.active_03.human","canonical ID")
    ck(LAB.EFFECT=="guard" and LAB.ELEMENT=="earth","earth guard")
    ck(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"single recipient")
    ck(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8),"cast/cooldown")
    ck(is_equal_approx(LAB.DECLARED_DURATION,4.0) and is_equal_approx(LAB.DECLARED_RANGE,5.5),"duration/range")
    ck(LAB.PROJECTILE_SPEED==0.0,"no outgoing projectile")
    ck(LAB.phase_at(.25)=="charge" and LAB.phase_at(.67)=="cast_retract","cast once")
    ck(LAB.phase_at(1.90)=="guard_quiet" and LAB.phase_at(4.64)=="guard_fade","sustained distinct")
    ck(LAB.phase_at(5.03)=="idle","fade clears")
    ck(LAB.cast_alpha(.43)>.9 and LAB.cast_alpha(.9)==0.0,"large cast not held")
    ck(LAB.status_alpha(.3)==0.0 and LAB.status_alpha(1.1)>0.99 and LAB.status_alpha(4.25)>0.99,"4s status")
    ck(LAB.status_alpha(5.0)==0.0,"status clears")
    ck(LAB.contact_alpha(.8,.3)==0.0 and LAB.contact_alpha(4.7,4.55)==0.0,"no out-of-window block")
    ck(LAB.contact_alpha(1.34,1.29)>.1 and LAB.contact_alpha(1.9,1.29)==0.0,"brief reaction only")
    ck(LAB.demo_target_position(0,1.34).distance_to(LAB.demo_target_position(0,.30))>12.0,"protected person moves")
    ck(LAB.demo_target_contact(0,1.34).distance_to(LAB.demo_target_contact(0,.30))>12.0,"hit follows protector")
    ck(LAB.enemy_feet_at(.30).distance_to(LAB.enemy_feet_at(1.34))>12.0,"opponent moves")
    ck(LAB.demo_target_position(1,1.0)==Vector2(-10000.0,-10000.0),"target limit enforced")
    ck(LAB.CAST.get_size()==Vector2(1280,640),"8 hero frames")
    ck(LAB.STATUS.get_size()==Vector2(768,384),"8 quiet loop frames")
    ck(LAB.CONTACT.get_size()==Vector2(1024,768),"10 incoming impact frames")
    ck(LAB.ATLAS_RAW_RGBA_BYTES==7602176,"7.25MiB texture budget")
    ck(LAB.WALK.get_width()>=320 and LAB.WALK.get_height()>=384,"actual walk sprite")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist08/phan_chan_quyen.gd")
    for unsafe in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","summon_actor","damage_target"]:
        ck(not src.contains(unsafe),"view only "+unsafe)
    var scene:=LAB.new()
    root.add_child(scene)
    await process_frame
    ck(scene.elapsed>=0.0,"scene initialization")
    scene.queue_free()
    print("VFX_FIST08_FOCUSED_RESULT="+("PASS" if errors==0 else "FAIL")+" failures="+str(errors))
    quit(0 if errors==0 else 1)
