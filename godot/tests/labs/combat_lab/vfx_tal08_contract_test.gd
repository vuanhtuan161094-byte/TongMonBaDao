extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman08/hoa_tam_ngung_phu.gd")
var failures:=0
func check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL08_FAIL "+msg)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.hoa_phu.active_03.human","canonical HF03 skill ID")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire" and LAB.SHAPE=="single_target","fire single target")
    check(LAB.TARGET_LIMIT==1 and LAB.HIT_COUNT==1,"one locked target, one hit")
    check(LAB.DECLARED_CAST_TIME==0.5 and LAB.DECLARED_COOLDOWN==12.2,"catalogue cast and cooldown")
    check(LAB.DECLARED_RANGE==8.5 and LAB.DECLARED_PROJECTILE_SPEED==9.0,"real declared speed/range")
    check(LAB.DECLARED_DURATION==0.0,"no invented burn/status")
    check(LAB.CHARGE.get_size()==Vector2(1280,960),"12 original charge poses")
    check(LAB.MISSILE.get_size()==Vector2(1280,768),"16 painterly fire-heart flight poses")
    check(LAB.IMPACT.get_size()==Vector2(1280,768),"10 single-target impact poses")
    check(LAB.MONSTER.has_animation("walk") and LAB.MONSTER.get_frame_count("walk")>=8,"real moving monster WALK sprite")
    check(LAB.phase(.3)=="charge" and LAB.phase(.51)=="release","phase charge/release")
    check(LAB.phase(.89)=="travel" and LAB.phase(1.49)=="contact" and LAB.phase(2.0)=="embers","true lab phase order")
    check(LAB.flight_gain(.35)==0.0 and LAB.flight_gain(.81)>.8 and LAB.flight_gain(1.31)==0.0,"visible bounded flight")
    check(LAB.charge_gain(.3)>.85 and LAB.charge_gain(.7)==0.0,"charge bounded")
    check(LAB.contact_gain(.9)==0.0 and LAB.contact_gain(1.40)>.8 and LAB.contact_gain(1.87)==0.0,"single bounded impact")
    check(LAB.target_foot(.25).distance_to(LAB.target_foot(1.15))>12.0,"monster truly walks while charged")
    check(LAB.target_contact(1.37).distance_to(LAB.target_foot(1.37)+Vector2(-6,-79))<.001,"hit follows live monster feet")
    check(LAB.missile_at(LAB.DEMO_CONTACT).distance_to(LAB.target_contact(LAB.DEMO_CONTACT))<.001,"missile endpoint follows same locked monster")
    check(LAB.missile_at(.62).distance_to(LAB.missile_at(1.1))>110.0,"projectile travels significant distance")
    var instance:=LAB.new()
    root.add_child(instance)
    await process_frame
    check(instance._light!=null,"soft light texture exists")
    var code:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman08/hoa_tam_ngung_phu.gd")
    for disallowed in ["SaveService.","CombatV2.","apply_damage","apply_status","target_nearest","add_burn","V63FeatureGates."]:
        check(not code.contains(disallowed),"view-only no "+disallowed)
    print("VFX_TAL08_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" single_moving_target=true no_live_receipts=true")
    instance.queue_free()
    quit(0 if failures==0 else 1)
