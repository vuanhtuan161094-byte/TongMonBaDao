extends SceneTree
const LAB=preload("res://labs/combat_lab/fist14/liep_huyet_truy_da.gd")
var failures:=0
func check(ok:bool,n:String)->void:
    if not ok:
        failures+=1
        push_error("FIST14_FAIL "+n)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.fist.huyet_quyen.active_04.human","id")
    check(LAB.EFFECT=="mark" and LAB.ELEMENT=="nether","effect")
    check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"single target")
    check(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8.0),"cast cd")
    check(is_equal_approx(LAB.DECLARED_DURATION,6.0),"six second mark")
    check(is_zero_approx(LAB.DECLARED_RADIUS) and is_zero_approx(LAB.PROJECTILE_SPEED),"no aoe/projectile")
    check(is_equal_approx(LAB.MARK_END-LAB.MARK_START,6.0),"one six second status")
    check(LAB.phase_at(.22)=="blood_hunt_claw_gather","charge")
    check(LAB.phase_at(.64)=="one_hunter_talon_lunge","travel")
    check(LAB.phase_at(.90)=="one_cosmetic_mark_contact","local contact")
    check(LAB.phase_at(3.6)=="six_second_hunting_scar","status")
    check(LAB.phase_at(6.97)=="scar_dissipation","fade")
    check(LAB.target_position(1,.9)==Vector2(-9999,-9999),"no second target")
    check(LAB.mark_at(0,.95).distance_to(LAB.mark_at(0,3.95))>10,"mark follows walking foe")
    check(LAB.talon_at(.74).distance_to(LAB.talon_at(.48))>45,"moving talon")
    check(LAB.mark_at(0,2.5).y>LAB.foe_at(2.5).y-81,"scar below face")
    check(LAB.mark_opacity(.60)==0 and LAB.mark_opacity(3.9)>.95 and LAB.mark_opacity(7.2)==0,"status opacity")
    check(LAB.CHARGE.get_size()==Vector2(1280,640),"charge atlas")
    check(LAB.TALON.get_size()==Vector2(1280,960),"talon atlas")
    check(LAB.CONTACT.get_size()==Vector2(1280,640),"contact atlas")
    check(LAB.MARK.get_size()==Vector2(1280,640),"scar atlas")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist14/liep_huyet_truy_da.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_heal","apply_status"]:
        check(not src.contains(bad),"view-only "+bad)
    print("VFX_FIST14_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
