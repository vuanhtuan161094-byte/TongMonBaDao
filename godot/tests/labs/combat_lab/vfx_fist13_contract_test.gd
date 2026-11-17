extends SceneTree
const LAB=preload("res://labs/combat_lab/fist13/huyet_khi_hoi_luu.gd")
var failures:=0
func verify(ok:bool,note:String)->void:
    if not ok:
        failures+=1
        push_error("FIST13_TEST_FAIL: "+note)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    verify(LAB.SKILL_ID=="tmb.skill.fist.huyet_quyen.active_03.human","canonical")
    verify(LAB.EFFECT=="mark" and LAB.ELEMENT=="nether","effect")
    verify(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"target cap")
    verify(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8),"timing")
    verify(is_equal_approx(LAB.DECLARED_DURATION,6) and is_equal_approx(LAB.DECLARED_RANGE,2.8),"range and duration")
    verify(is_zero_approx(LAB.PROJECTILE_SPEED) and is_zero_approx(LAB.DECLARED_RADIUS),"no projectile or AOE")
    verify(is_equal_approx(LAB.MARK_END-LAB.MARK_START,6),"one six second mark")
    verify(LAB.phase_at(.22)=="gather" and LAB.phase_at(.64)=="inward_contact","phase")
    verify(LAB.phase_at(.9)=="one_mark_six_seconds" and LAB.phase_at(6.99)=="fade","mark/fade")
    verify(LAB.mark_at(0,.90).distance_to(LAB.mark_at(0,.22))>12,"moving contact")
    verify(LAB.mark_at(0,4.35).distance_to(LAB.mark_at(0,2.25))>12,"moving marked target")
    verify(LAB.mark_at(1,.9)==Vector2(-9999.0,-9999.0),"single mark target")
    verify(LAB.mark_opacity(.6)==0 and LAB.mark_opacity(1.2)>.99 and LAB.mark_opacity(7.2)==0,"opacity")
    verify(LAB.CHARGE.get_size()==Vector2(1280,640),"charge")
    verify(LAB.CONTACT.get_size()==Vector2(1280,960),"contact")
    verify(LAB.MARK.get_size()==Vector2(1280,640),"mark")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist13/huyet_khi_hoi_luu.gd")
    for token in ["SaveService.","CombatV2.","apply_damage","apply_heal","apply_status"]:
        verify(not src.contains(token),"view-only "+token)
    var lab=LAB.new()
    root.add_child(lab)
    await process_frame
    lab.queue_free()
    print("VFX_FIST13_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
