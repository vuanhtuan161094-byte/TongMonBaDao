extends SceneTree
const LAB=preload("res://labs/combat_lab/fist12/doan_mach_lien_quyen.gd")
var failures:=0
func check(ok:bool,note:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_FIST12_FAIL "+note)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.fist.huyet_quyen.active_02.human","canonical skill")
    check(LAB.ART_REVISION=="R1_ENERGY_FIRST_CRIMSON_MERIDIAN","R1 revision")
    check(LAB.EFFECT=="mark" and LAB.ELEMENT=="nether","mark/nether")
    check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"only one target")
    check(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8.0),"cast cooldown")
    check(is_equal_approx(LAB.DECLARED_DURATION,6.0) and is_equal_approx(LAB.DECLARED_RANGE,2.8),"mark duration/range")
    check(is_equal_approx(LAB.DECLARED_POWER,1.15) and is_zero_approx(LAB.DECLARED_PROJECTILE_SPEED),"mark power and no projectile")
    check(is_zero_approx(LAB.DECLARED_RADIUS),"single no AoE")
    check(LAB.phase_at(.22)=="huyet_qi_charge" and LAB.phase_at(.74)=="meridian_light_stream","charge stream")
    check(LAB.phase_at(.99)=="lab_only_mark_application" and LAB.phase_at(2.2)=="six_second_vein_mark","contact mark")
    check(LAB.phase_at(7.06)=="vein_mark_fade" and LAB.phase_at(7.40)=="idle","mark fade")
    check(is_equal_approx(LAB.MARK_END-LAB.MARK_START,6.0),"six seconds exact")
    check(LAB.charge_alpha(.23)>.12 and LAB.charge_alpha(.56)==0.0,"gather only")
    check(LAB.wave_alpha(.74)>.12 and LAB.wave_alpha(.99)==0.0,"one visual stream")
    check(LAB.contact_alpha(.99)>.12 and LAB.contact_alpha(1.45)==0.0,"brief local application")
    check(LAB.mark_alpha(.86)==0.0 and LAB.mark_alpha(2.15)>.95 and LAB.mark_alpha(6.73)>.95,"persistent mark")
    check(LAB.mark_alpha(7.24)==0.0,"no persistent ghost")
    check(LAB.target_position(0,.99).distance_to(LAB.target_position(0,.22))>12.0,"moving target")
    check(LAB.target_position(0,6.12).distance_to(LAB.target_position(0,2.20))>12.0,"mark follows later walk")
    check(LAB.wave_at(.59).distance_to(LAB.wave_at(.85))>50.0,"animated light stream motion")
    check(LAB.target_position(1,.99)==Vector2(-10000.0,-10000.0),"no invented other target")
    check(LAB.CHARGE.get_size()==Vector2(1024,512),"eight charge PNG")
    check(LAB.WAVE.get_size()==Vector2(1280,960),"twelve energy PNG")
    check(LAB.CONTACT.get_size()==Vector2(1280,640),"eight contact PNG")
    check(LAB.MARK.get_size()==Vector2(768,384),"eight 6s mark PNG")
    check(LAB.ATLAS_RAW_RGBA_BYTES==11468800,"raw GPU budget documented")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist12/doan_mach_lien_quyen.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","summon_actor","play_gif"]:
        check(not src.contains(forbidden),"view-only "+forbidden)
    var demo:=LAB.new()
    root.add_child(demo)
    await process_frame
    check(demo.elapsed>=0.0,"LAB boot")
    demo.queue_free()
    print("VFX_FIST12_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)