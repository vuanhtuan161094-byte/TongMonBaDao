extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman10/van_phu_phan_thien.gd")
var failures:=0
func check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL10_FAIL "+msg)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.hoa_phu.ultimate.human","exact HF05 canonical")
    check(LAB.ELEMENT=="fire" and LAB.EFFECT=="damage" and LAB.SHAPE=="circle","FIRE circle damage")
    check(LAB.TARGET_LIMIT==3 and LAB.HIT_COUNT==1,"single circle hit capped at three")
    check(LAB.DECLARED_RADIUS==2.8 and LAB.DECLARED_RANGE==9.5,"canonical radius and range")
    check(LAB.DECLARED_CAST_TIME==1.05 and LAB.DECLARED_COOLDOWN==23.0,"ultimate cast and cooldown")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0 and LAB.DECLARED_DURATION==0.0,"cosmetic papers not projectiles or DoT")
    check(LAB.DAMAGE_RATIO==1.58,"catalogue power unchanged")
    check(LAB.CHARGE.get_size()==Vector2(1280,1280),"16 pose alpha charge")
    check(LAB.STORM.get_size()==Vector2(2560,2304),"24 pose animated mega-seal sky constellation")
    check(LAB.RAIN.get_size()==Vector2(2560,2200),"20 pose source-painted paper rain")
    check(LAB.IMPACT.get_size()==Vector2(2560,960),"12 pose area fire burst")
    check(LAB.MONSTER.has_animation("walk") and LAB.MONSTER.get_frame_count("walk")>=8,"actual moving WALK sprite")
    check(LAB.phase(.58)=="charge_and_storm" and LAB.phase(1.44)=="cosmetic_flame_rain","correct cast and rain phase")
    check(LAB.phase(1.96)=="one_circle_contact" and LAB.phase(2.38)=="residue","bounded contact and afterburn")
    check(LAB.charge_gain(.52)>.8 and LAB.charge_gain(1.18)==0.0,"charge local")
    check(LAB.storm_gain(1.42)>.8 and LAB.storm_gain(2.0)==0.0,"storm local")
    check(LAB.rain_gain(1.59)>.8 and LAB.rain_gain(2.14)==0.0,"flame rain local")
    check(LAB.impact_gain(1.83)==0.0 and LAB.impact_gain(1.96)>.75 and LAB.impact_gain(2.28)==0.0,"only ONE visual circle blast")
    for k in range(3):
        check(LAB.target_foot(k,.50).distance_to(LAB.target_foot(k,1.96))>10.0,"walking displacement "+str(k))
        check(LAB.target_contact(k,1.96).distance_to(LAB.target_foot(k,1.96)+Vector2(-5,-75))<.001,"current-position impact "+str(k))
    var inst:=LAB.new()
    root.add_child(inst)
    await process_frame
    check(inst._light!=null,"soft light support")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman10/van_phu_phan_thien.gd")
    for prohibited in ["SaveService.","CombatV2.","apply_damage","apply_status","set_hitpoints","spawn_projectile","add_burn"]:
        check(not src.contains(prohibited),"no gameplay writes "+prohibited)
    print("VFX_TAL10_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" one_circle_hit_cap3=true moving_targets=3 no_gameplay_projectiles=true")
    inst.queue_free()
    quit(0 if failures==0 else 1)
