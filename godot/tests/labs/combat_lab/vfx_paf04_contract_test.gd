extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman14/ho_menh_luu_van.gd")
var failures:=0
func check(v:bool,label:String)->void:
    if not v:
        failures+=1
        push_error("VFX_PAF04_FAIL "+label)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.active_04.human","exact catalogue ID")
    check(LAB.EFFECT=="guard" and LAB.ELEMENT=="wind" and LAB.SHAPE=="single_target","guard wind self")
    check(LAB.TARGET_LIMIT==1 and LAB.HIT_COUNT==1 and LAB.DECLARED_RANGE==8.5,"cap1 hit count1 range")
    check(LAB.DECLARED_CAST_TIME==.5 and LAB.DECLARED_COOLDOWN==13.6,"cast/cooldown")
    check(LAB.DECLARED_DURATION==4.0 and LAB.DECLARED_PROJECTILE_SPEED==0.0 and LAB.DECLARED_DAMAGE_RATIO==0.0,"duration4 no projectile damage")
    check(LAB.DECLARED_GUARD_POWER==.16 and LAB.GUARD_MODE=="mitigation","mitigation read only")
    check(LAB.CHARGE.get_size()==Vector2(1280,960),"12 crystal charge")
    check(LAB.GLASS_BACK.get_size()==Vector2(1408,1792),"16 RGBA glass back")
    check(LAB.GLASS_FRONT.get_size()==Vector2(1408,1792),"16 RGBA glass front")
    check(LAB.LOCK.get_size()==Vector2(1280,1280),"14 glass locking impact")
    check(LAB.SHIMMER.get_size()==Vector2(1024,512),"8 pearl caustics")
    check(LAB.BADGE.get_size()==Vector2(512,256),"8 separate compact guard status")
    check(LAB.CASTER.has_animation("walk") and LAB.CASTER.get_frame_count("walk")>=8,"real moving SELF caster")
    check(LAB.charge_gain(.28)>.6 and LAB.charge_gain(.65)==0.0,"short cast visuals")
    check(LAB.crystal_gain(.72)>.45 and LAB.crystal_gain(1.8)==0.0,"glass short animation")
    check(LAB.lock_gain(.99)>.80 and LAB.lock_gain(1.5)==0.0,"lock short vs status duration")
    check(LAB.self_guard_active_in_demo(.88) and LAB.self_guard_active_in_demo(3.4),"self status starts and is sustained")
    check(LAB.self_guard_active_in_demo(4.81) and not LAB.self_guard_active_in_demo(4.83),"4-second status expiry separate from clip")
    check(LAB.MOVIE_LOOP<LAB.DECLARED_DURATION and LAB.VFX_FADE_END<LAB.MOVIE_LOOP,"not recording four seconds of active motion")
    check(LAB.phase(.3)=="self_charge" and LAB.phase(.72)=="glass_forming" and LAB.phase(.99)=="self_guard_lock","phase clocks")
    check(LAB.self_foot(0,.3).distance_to(LAB.self_foot(0,.99))>20,"SELF actor moves")
    check(LAB.self_foot(1,.99)==Vector2.INF,"one target only")
    for t in [.30,.72,.82,.99,1.28]:
        check(LAB.self_contact(0,t).distance_to(LAB.self_foot(0,t)+Vector2(0,-90))<.001,"self glass anchor "+str(t))
    var instance:=LAB.new()
    root.add_child(instance)
    await process_frame
    check(instance._light!=null,"translucent light material available")
    var file:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman14/ho_menh_luu_van.gd")
    for blocked in ["SaveService.","CombatV2.","apply_damage","apply_guard","set_status","spawn_projectile","remove_status","damage_tick"]:
        check(not file.contains(blocked),"no real guard gameplay status write "+blocked)
    print("VFX_PAF04_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" moving_SELF=true guard4s_status_only=true no_gameplay_writes=true")
    instance.queue_free()
    quit(0 if failures==0 else 1)
