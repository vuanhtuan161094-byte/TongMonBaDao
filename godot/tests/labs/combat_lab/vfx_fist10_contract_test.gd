extends SceneTree
const LAB=preload("res://labs/combat_lab/fist10/bat_dong_kim_chung.gd")
var fails:=0
func check(ok: bool,note: String) -> void:
    if not ok:
        fails+=1
        push_error("VFX_FIST10_FAIL "+note)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    check(LAB.SKILL_ID=="tmb.skill.fist.kim_cang.ultimate.human","ID")
    check(LAB.ART_REVISION=="R4_NO_HIT_FINAL","revision")
    check(LAB.EFFECT=="guard" and LAB.ELEMENT=="earth","canonical effect/element")
    check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"no AoE/multitarget")
    check(is_equal_approx(LAB.CAST_TIME,1.15) and is_equal_approx(LAB.COOLDOWN,34.0),"authority times")
    check(is_equal_approx(LAB.DECLARED_DURATION,4.0) and is_equal_approx(LAB.DECLARED_RANGE,5.5),"duration/range")
    check(is_equal_approx(LAB.DECLARED_POWER,.35) and is_zero_approx(LAB.PROJECTILE_SPEED),"guard power and no projectile")
    check(LAB.phase_at(.45)=="charge" and LAB.phase_at(1.24)=="bell_release","cast")
    check(LAB.phase_at(3.14)=="sustained_guard" and LAB.phase_at(5.32)=="guard_fade","status")
    check(LAB.phase_at(5.90)=="idle","clear")
    check(LAB.cast_alpha(.82)>.65 and LAB.cast_alpha(1.65)==0.0,"large cast ends promptly")
    check(LAB.guard_alpha(.80)==0.0 and LAB.guard_alpha(1.50)>.99 and LAB.guard_alpha(4.90)>.99,"4s quiet buff")
    check(LAB.guard_alpha(5.75)==0.0,"status cleared")
    check(LAB.fade_alpha(2.16)==0.0 and LAB.fade_alpha(5.30)>0.0,"fade only after guard")
    check(LAB.fade_alpha(5.55)==0.0,"fade clears")
    check(LAB.target_position(0,2.16).distance_to(LAB.target_position(0,.44))>12.0,"protected moves")
    check(LAB.enemy_at(2.16).distance_to(LAB.enemy_at(.44))>12.0,"opponent moves")
    check(LAB.target_position(0,2.16).distance_to(LAB.target_position(0,.44))>12.0,"quiet guard follows mover")
    check(LAB.target_position(1,2.16)==Vector2(-10000.0,-10000.0),"no unconfirmed second recipient")
    check(LAB.CAST.get_size()==Vector2(1536,1152),"12 cast illustrated bell poses")
    check(LAB.STATUS.get_size()==Vector2(768,384),"8 status poses")
    check(LAB.FADE.get_size()==Vector2(1024,512),"8 fade poses")
    check(LAB.ATLAS_RAW_RGBA_BYTES==10354688,"9.875 MiB raw RGBA budget")
    check(LAB.WALK.get_width()>=320 and LAB.WALK.get_height()>=384,"approved frame WALK")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/fist10/bat_dong_kim_chung.gd")
    for prohibited in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","summon_actor","caster_shift"]:
        check(not source.contains(prohibited),"view-only "+prohibited)
    for forbidden_hit in ["block_alpha(", "DEMO_BLOCKS", "manual_blocks", "f10_guard_resonance.png", "contact_at(", "KEY_H"]:
        check(not source.contains(forbidden_hit),"NO_HIT owner veto "+forbidden_hit)
    var instance:=LAB.new()
    root.add_child(instance)
    await process_frame
    check(instance.elapsed>=0.0,"clock and initialization")
    instance.queue_free()
    print("VFX_FIST10_FOCUSED_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails))
    quit(0 if fails==0 else 1)
