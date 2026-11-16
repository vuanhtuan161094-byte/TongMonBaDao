extends SceneTree
const LAB=preload("res://labs/combat_lab/fist07/kim_cang_ho_the.gd")
var failures:=0
func ck(x: bool,why: String) -> void:
    if not x:
        failures+=1
        push_error("FIST07_R5_FAIL "+why)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    ck(LAB.SKILL_ID=="tmb.skill.fist.kim_cang.active_02.human","skill ID")
    ck(LAB.ART_REVISION=="R6_JX_CAST_ONCE_QUIET_STATUS","revision")
    ck(LAB.EFFECT=="guard" and LAB.ELEMENT=="earth","guard earth")
    ck(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"one protected")
    ck(is_equal_approx(LAB.CAST_TIME,0.45) and is_equal_approx(LAB.COOLDOWN,8),"authority cast/cooldown")
    ck(is_equal_approx(LAB.DECLARED_DURATION,4.0) and is_equal_approx(LAB.DECLARED_RANGE,5.5),"duration/range")
    ck(is_equal_approx(LAB.DECLARED_POWER,0.35) and is_zero_approx(LAB.PROJECTILE_SPEED),"power and no projectile")
    ck(LAB.phase_at(.23)=="cast_burst" and LAB.phase_at(.60)=="cast_retract_status_on","burst phase")
    ck(LAB.phase_at(1.4)=="quiet_sustained_guard" and LAB.phase_at(4.63)=="status_fade","long status")
    ck(LAB.phase_at(5.01)=="idle","finished")
    ck(LAB.cast_alpha(.40)>.9 and LAB.cast_alpha(1.0)==0.0,"large art only at activation")
    ck(LAB.guard_alpha(.33)==0.0 and LAB.guard_alpha(.92)>.99 and LAB.guard_alpha(4.20)>.99,"4s sustained")
    ck(LAB.guard_alpha(4.92)==0.0,"status clears")
    ck(LAB.block_alpha(.35,.30)==0.0 and LAB.block_alpha(4.70,4.55)==0.0,"no external guard proc")
    ck(LAB.block_alpha(1.33,1.29)>.1 and LAB.block_alpha(1.90,1.29)==0.0,"bounded guarded-hit")
    ck(LAB.demo_target_position(0,1.33).distance_to(LAB.demo_target_position(0,.30))>=12.0,"actual moving protected actor")
    ck(LAB.enemy_position_at(.30).distance_to(LAB.enemy_position_at(1.33))>=12.0,"moving opponent")
    ck(LAB.demo_target_contact(0,1.33).distance_to(LAB.demo_target_contact(0,.30))>=12.0,"block anchor follows subject")
    ck(LAB.demo_target_position(1,.90)==Vector2(-10000,-10000),"out-of-cap recipient")
    ck(LAB.CAST.get_size()==Vector2(1280,640),"8 original guardian cast poses")
    ck(LAB.STATUS.get_size()==Vector2(768,384),"8 quiet sustain poses")
    ck(LAB.BLOCK.get_size()==Vector2(1024,512),"8 block poses")
    ck(LAB.ATLAS_RAW_RGBA_BYTES==6553600,"6.25MiB atlas pixel budget")
    ck(LAB.WALK.get_width()>=320 and LAB.WALK.get_height()>=384,"actual WALK sprite atlas")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/fist07/kim_cang_ho_the.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","summon_actor","caster_shift","_actor(CASTER +"]:
        ck(not source.contains(forbidden),"view-only "+forbidden)
    var scene:=LAB.new()
    root.add_child(scene)
    await process_frame
    ck(scene.elapsed>=0.0,"lab clock")
    scene.queue_free()
    print("VFX_FIST07_R6_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
