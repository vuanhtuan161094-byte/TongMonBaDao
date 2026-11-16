extends SceneTree
const LAB=preload("res://labs/combat_lab/fist11/huyet_liet_quyen.gd")
var fails:=0
func check(v:bool, note:String)->void:
    if not v:
        fails+=1
        push_error("VFX_FIST11_FAIL "+note)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.fist.huyet_quyen.active_01.human","skill ID")
    check(LAB.ART_REVISION=="R1_PAINTED_CRIMSON_FIST","art revision")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="nether","canonical effect and element")
    check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"no false AoE")
    check(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8.0),"authority cast/cd")
    check(is_equal_approx(LAB.DECLARED_RANGE,2.8) and is_equal_approx(LAB.DECLARED_PROJECTILE_SPEED,8.0),"authority range/speed")
    check(is_zero_approx(LAB.DECLARED_DURATION) and is_zero_approx(LAB.DECLARED_POWER) and is_zero_approx(LAB.DECLARED_RADIUS),"authority effect params")
    check(LAB.phase_at(.22)=="gather_blood_qi" and LAB.phase_at(.62)=="single_target_blood_fist_flight","charge/flight")
    check(LAB.phase_at(.86)=="lab_only_impact" and LAB.phase_at(1.42)=="red_ink_dissipate","contact/fade")
    check(LAB.phase_at(1.70)=="idle","idle")
    check(LAB.charge_alpha(.25)>.10 and LAB.charge_alpha(.62)==0.0,"charge only pre-cast")
    check(LAB.flight_alpha(.62)>.10 and LAB.flight_alpha(.86)==0.0,"flight only pre-contact")
    check(LAB.contact_alpha(.85)>.10 and LAB.contact_alpha(1.40)==0.0,"contact only short local")
    check(LAB.target_position(0,.86).distance_to(LAB.target_position(0,.22))>12.0,"moving target")
    check(LAB.punch_at(.58).distance_to(LAB.punch_at(.73))>40.0,"real travel, not static hit")
    check(LAB.target_position(1,.86)==Vector2(-10000,-10000),"only target 0")
    check(LAB.CHARGE.get_size()==Vector2(1024,512),"8 actual cast frames")
    check(LAB.FLIGHT.get_size()==Vector2(1024,768),"12 actual flight frames")
    check(LAB.CONTACT.get_size()==Vector2(1280,960),"10 actual contact frames")
    check(LAB.RAW_RGBA_BUDGET==10158080,"atlas budget")
    var code:=FileAccess.get_file_as_string("res://labs/combat_lab/fist11/huyet_liet_quyen.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","summon_actor"]:
        check(not code.contains(bad),"view-only: "+bad)
    var lab:=LAB.new()
    root.add_child(lab)
    await process_frame
    check(lab.elapsed>=0.0,"LAB initialized")
    lab.queue_free()
    print("VFX_FIST11_FOCUSED_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails))
    quit(0 if fails==0 else 1)