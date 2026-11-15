extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman07/lien_diem_phan_gioi.gd")
var failures:=0
func check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL07_FAIL "+msg)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.hoa_phu.active_02.human","canonical HF02 identity")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire" and LAB.SHAPE=="circle","fire circle damage")
    check(LAB.TARGET_LIMIT==3 and LAB.HIT_COUNT==1,"three targets at most, one hit")
    check(LAB.DECLARED_RADIUS==2.1 and LAB.DECLARED_RANGE==8.5,"canonical radius and range")
    check(LAB.DECLARED_CAST_TIME==.62 and LAB.DECLARED_COOLDOWN==10.8,"canonical cast and cooldown")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0,"NO invented flying projectile")
    check(LAB.LOTUS.get_size()==Vector2(2048,1152),"12 unique painted fire-lotus poses")
    check(LAB.SEALS.get_size()==Vector2(1024,768),"12 independent painted talisman poses")
    check(LAB.GROUND.get_size()==Vector2(2048,512),"8 painterly ground poses")
    check(LAB.CONTACT.get_size()==Vector2(1024,512),"8 localized fire contact poses")
    check(LAB.MONSTER_FRAMES.has_animation("walk") and LAB.MONSTER_FRAMES.get_frame_count("walk")>=8,"real monster animation")
    check(LAB.phase_at(.30)=="charge" and LAB.phase_at(.70)=="ground_awaken","charge then ground cue")
    check(LAB.phase_at(1.10)=="lotus_bloom" and LAB.phase_at(1.49)=="demo_hit","bloom/contact staged")
    check(LAB.phase_at(2.20)=="embers_fade" and LAB.phase_at(2.90)=="idle","no status duration")
    check(LAB.bloom_gain(.65)==0.0 and LAB.bloom_gain(1.27)>.50 and LAB.bloom_gain(2.63)==0.0,"bloom bounded")
    check(LAB.ground_gain(1.11)>.40 and LAB.ground_gain(2.64)==0.0,"ground bounded")
    for i in range(3):
        check(LAB.inside_demo_circle(i,LAB.DEMO_HIT_AT),"locked ID in demo circle "+str(i))
        check(LAB.demo_target_foot(i,.30).distance_to(LAB.demo_target_foot(i,1.49))>12.0,"moving stand-in "+str(i))
        check(LAB.demo_target_contact(i,1.49).distance_to(LAB.demo_target_foot(i,1.49)+Vector2(-5,-79))<.001,"contact anchor follows same ID "+str(i))
        check(LAB.hit_gain(i,.50)==0.0 and LAB.hit_gain(i,1.47)>.18 and LAB.hit_gain(i,1.80)==0.0,"single bounded contact "+str(i))
    check(not LAB.inside_demo_circle(3,LAB.DEMO_HIT_AT),"no fourth target")
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    check(sample._glow!=null,"luminous post-process assist created")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman07/lien_diem_phan_gioi.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status","add_burn","summon_actor","target_nearest","V63FeatureGates."]:
        check(not src.contains(forbidden),"view-only cannot use "+forbidden)
    print("VFX_TAL07_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" canonical_circle_cap3_no_projectile=true")
    sample.queue_free()
    quit(0 if failures==0 else 1)
