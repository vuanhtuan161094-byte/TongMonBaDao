extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman13/tay_tran_giai_phu.gd")
var failures:=0
func check(value:bool,label:String)->void:
    if not value:
        failures+=1
        push_error("VFX_PAF03_FAIL "+label)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.active_03.human","exact PAF03 ID")
    check(LAB.EFFECT=="cleanse" and LAB.ELEMENT=="wind" and LAB.SHAPE=="single_target","single wind cleanse")
    check(LAB.TARGET_LIMIT==1 and LAB.HIT_COUNT==1 and LAB.DECLARED_RANGE==8.5,"one ally and range")
    check(LAB.DECLARED_CAST_TIME==.5 and LAB.DECLARED_COOLDOWN==12.2,"cast/cooldown")
    check(LAB.DECLARED_DURATION==0.0 and LAB.DECLARED_PROJECTILE_SPEED==0.0 and LAB.DECLARED_DAMAGE_RATIO==0.0,"instant cleanse no damage/projectile")
    check(LAB.CHARGE.get_size()==Vector2(1280,960),"12 charge frames")
    check(LAB.WIND.get_size()==Vector2(2048,1024),"16 transfer frames")
    check(LAB.CURSE.get_size()==Vector2(512,256),"8 fictional curse poses")
    check(LAB.CLEANSE.get_size()==Vector2(1280,1280),"14 cleansing poses")
    check(LAB.RESIDUE.get_size()==Vector2(1024,512),"8 residue poses")
    check(LAB.ALLY.has_animation("walk") and LAB.ALLY.get_frame_count("walk")>=8,"actual WALK ally")
    check(LAB.charge_gain(.3)>.65 and LAB.charge_gain(.63)==0.0,"short charge")
    check(LAB.transfer_gain(.67)>.65 and LAB.transfer_gain(1.1)==0.0,"short optical transfer")
    check(LAB.cleanse_gain(.98)>.70 and LAB.cleanse_gain(1.36)==0.0,"short instant cleansing")
    check(LAB.cleanse_applied_in_demo(.85) and not LAB.cleanse_applied_in_demo(.81),"receipt only simulated")
    check(LAB.curse_gain(.6)>.9 and LAB.curse_gain(1.1)==0.0,"fictional curse vanishes")
    check(LAB.phase(.3)=="charge" and LAB.phase(.67)=="wind_purifying_transfer" and LAB.phase(.98)=="instant_cleanse_on_moving_ally","phase timeline")
    check(LAB.target_foot(0,.3).distance_to(LAB.target_foot(0,.98))>20.0,"moving contact nonzero")
    for t in [.3,.67,.85,.98,1.4]:
        check(LAB.target_contact(0,t).distance_to(LAB.target_foot(0,t)+Vector2(0,-88))<.001,"target anchor follows WALK ally "+str(t))
    check(LAB.target_foot(1,.9)==Vector2.INF,"cannot silently cleanse two targets")
    var actor:=LAB.new()
    root.add_child(actor)
    await process_frame
    check(actor._light!=null,"light source available")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman13/tay_tran_giai_phu.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_mark","apply_cleanse","remove_status","spawn_projectile","damage_tick","status_registry"]:
        check(not source.contains(bad),"no gameplay writes "+bad)
    print("VFX_PAF03_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" one_moving_ally=true instant_cleanse_only=true no_projectile=true")
    actor.queue_free()
    quit(0 if failures==0 else 1)
