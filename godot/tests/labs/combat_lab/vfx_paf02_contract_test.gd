extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman12/thai_huyen_khep_an.gd")
var failures:=0
func check(ok:bool,label:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_PAF02_FAIL "+label)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.active_02.human","exact catalogue ID")
    check(LAB.ELEMENT=="wind" and LAB.EFFECT=="mark" and LAB.SHAPE=="line","wind / mark / line")
    check(LAB.TARGET_LIMIT==3 and LAB.HIT_COUNT==1 and LAB.DECLARED_RANGE==9.0,"max3 / hit count1")
    check(LAB.DECLARED_CAST_TIME==.5 and LAB.DECLARED_COOLDOWN==10.8,"cast/cooldown")
    check(LAB.DECLARED_DURATION==5.5 and LAB.DECLARED_PROJECTILE_SPEED==0.0 and LAB.DECLARED_RADIUS==0.0,"debuff5.5 no projectile")
    check(LAB.DECLARED_DAMAGE_RATIO==.6,"read-only damage_ratio")
    check(LAB.MOVIE_LOOP<LAB.DECLARED_DURATION and LAB.VFX_FADE_END<LAB.MOVIE_LOOP,"short clip / long status separate")
    check(LAB.CHARGE.get_size()==Vector2(1280,1280),"14 charge poses")
    check(LAB.LINE.get_size()==Vector2(2048,1280),"18 wind line poses")
    check(LAB.CONTACT.get_size()==Vector2(1024,768),"12 contact poses")
    check(LAB.BADGE.get_size()==Vector2(512,256),"8 status icon poses")
    check(LAB.MONSTER.has_animation("walk") and LAB.MONSTER.get_frame_count("walk")>=8,"true WALK monster")
    check(LAB.charge_gain(.29)>.7 and LAB.charge_gain(.8)==0,"charge short")
    check(LAB.line_gain(.67)>.6 and LAB.line_gain(1.13)==0,"line finite")
    check(LAB.contact_gain(.96)>.6 and LAB.contact_gain(1.3)==0,"contact short")
    check(LAB.gesture_active(.4) and not LAB.gesture_active(1.65),"no 5.5s waiting animation")
    check(LAB.status_active(0,.78) and LAB.status_active(2,6.27) and not LAB.status_active(1,6.28),"status exactly 5.5s, separately")
    check(not LAB.status_active(3,1.0) and LAB.target_foot(3,1.0)==Vector2.INF,"cannot tag fourth")
    check(LAB.visual_phase(.25)=="charge" and LAB.visual_phase(.67)=="seal_line" and LAB.visual_phase(.96)=="mark_contact","phase progression")
    check(LAB.visual_phase(1.78)=="gesture_finished_status_independent","gesture does not equal debuff")
    for i in range(3):
        check(LAB.target_foot(i,.28).distance_to(LAB.target_foot(i,.97))>5,"moving target "+str(i))
        for t in [.28,.97,1.42,3.0,6.25]:
            check(LAB.target_contact(i,t).distance_to(LAB.target_foot(i,t)+Vector2(0,-88))<.001,"contact attached "+str(i))
            check(LAB.badge_anchor(i,t).distance_to(LAB.target_foot(i,t)+Vector2(0,-155))<.001,"status cue attached "+str(i))
    var instance:=LAB.new()
    root.add_child(instance)
    await process_frame
    check(instance._light!=null,"soft native light")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman12/thai_huyen_khep_an.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_mark","spawn_projectile","damage_tick","status_registry"]:
        check(not source.contains(bad),"no gameplay writes "+bad)
    print("VFX_PAF02_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" moving_3_selected=true short_cast=true separate_status_5_5=true no_projectile=true")
    instance.queue_free()
    quit(0 if failures==0 else 1)
