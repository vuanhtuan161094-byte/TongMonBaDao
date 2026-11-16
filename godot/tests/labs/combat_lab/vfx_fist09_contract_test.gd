extends SceneTree
const LAB=preload("res://labs/combat_lab/fist09/tran_son_ho_dong.gd")
var fails:=0
func check(ok: bool,note: String) -> void:
    if not ok:
        fails+=1
        push_error("VFX_FIST09_FAIL "+note)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    check(LAB.SKILL_ID=="tmb.skill.fist.kim_cang.active_04.human","ID")
    check(LAB.ART_REVISION=="R6_CURVED_DEFLECTION_GUARD","revision")
    check(LAB.EFFECT=="guard" and LAB.ELEMENT=="earth","canonical effect/element")
    check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"no AoE/multitarget")
    check(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8.0),"authority times")
    check(is_equal_approx(LAB.DECLARED_DURATION,4.0) and is_equal_approx(LAB.DECLARED_RANGE,5.5),"duration/range")
    check(is_equal_approx(LAB.DECLARED_POWER,.35) and is_zero_approx(LAB.PROJECTILE_SPEED),"guard power and no projectile")
    check(LAB.phase_at(.23)=="charge" and LAB.phase_at(.61)=="cast_retract","cast")
    check(LAB.phase_at(2.14)=="sustained_guard" and LAB.phase_at(4.70)=="guard_fade","status")
    check(LAB.phase_at(5.10)=="idle","clear")
    check(LAB.cast_alpha(.40)>.65 and LAB.cast_alpha(1.5)==0.0,"large cast ends promptly")
    check(LAB.guard_alpha(.30)==0.0 and LAB.guard_alpha(1.0)>.99 and LAB.guard_alpha(4.3)>.99,"4s quiet buff")
    check(LAB.guard_alpha(4.95)==0.0,"status cleared")
    check(LAB.block_alpha(.34,.30)==0.0 and LAB.block_alpha(4.80,4.70)==0.0,"no invalid block")
    check(LAB.block_alpha(1.34,1.30)>.10 and LAB.block_alpha(2.01,1.30)==0.0,"short defensive burst")
    check(LAB.target_position(0,1.33).distance_to(LAB.target_position(0,.26))>12.0,"protected moves")
    check(LAB.enemy_at(1.33).distance_to(LAB.enemy_at(.30))>12.0,"opponent moves")
    check(LAB.contact_at(0,1.33).distance_to(LAB.contact_at(0,.26))>12.0,"impact follows mover")
    check(LAB.target_position(1,1.33)==Vector2(-10000.0,-10000.0),"no unconfirmed second recipient")
    check(LAB.CAST.get_size()==Vector2(1280,640),"8 cast original material poses")
    check(LAB.STATUS.get_size()==Vector2(768,384),"8 status poses")
    check(LAB.BLOCK.get_size()==Vector2(1024,512),"8 contact poses")
    check(LAB.ATLAS_RAW_RGBA_BYTES==6553600,"6.25 MiB raw RGBA budget")
    check(LAB.WALK.get_width()>=320 and LAB.WALK.get_height()>=384,"approved frame WALK")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/fist09/tran_son_ho_dong.gd")
    for prohibited in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","summon_actor","caster_shift"]:
        check(not source.contains(prohibited),"view-only "+prohibited)
    var instance:=LAB.new()
    root.add_child(instance)
    await process_frame
    check(instance.elapsed>=0.0,"clock and initialization")
    instance.queue_free()
    print("VFX_FIST09_FOCUSED_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails))
    quit(0 if fails==0 else 1)
