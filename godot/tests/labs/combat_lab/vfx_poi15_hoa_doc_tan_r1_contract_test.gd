extends SceneTree
const LAB=preload("res://labs/combat_lab/poison15_hoa_doc_tan/r1/hoa_doc_tan.gd")
var failures:=0
func _initialize()->void:call_deferred("_check")
func check(ok:bool,why:String)->void:
    if not ok:
        failures+=1
        push_error("POI15_HOA_DOC_TAN_R1_FAIL "+why)
func _check()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.duoc_doc.active_04.human","canonical ID")
    check(LAB.EFFECT=="poison" and LAB.ELEMENT=="wood" and LAB.SHAPE=="circle","poison AOE, not cleanse/heal")
    check(LAB.TARGET_LIMIT==3 and LAB.DECLARED_RADIUS==2.3,"circle radius world2.3 target cap3")
    check(LAB.DECLARED_RANGE==7.0 and LAB.DECLARED_CAST==.6 and LAB.DECLARED_COOLDOWN==13.0,"range, cast, cooldown")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0,"instant area visual no missile")
    check(LAB.DECLARED_DAMAGE_RATIO==.86 and LAB.DECLARED_POWER==.015,"canonical coefficients")
    check(LAB.DECLARED_POISON_STACKS==1 and LAB.DECLARED_DURATION==6.0,"exact one stack six seconds")
    check(is_equal_approx(LAB.MARK_END-LAB.MARK_START,6.0),"duration exact, no fake longer poison")
    check(LAB.phase_at(.28)=="charge" and LAB.phase_at(.86)=="cloud_contact" and LAB.phase_at(1.20)=="poison_mark_duration" and LAB.phase_at(7.20)=="idle","cast cloud contact status expiration")
    check(not LAB.status_active(1.04) and LAB.status_active(1.05) and LAB.status_active(6.99) and not LAB.status_active(7.05),"state start and expiry")
    check(LAB.status_alpha(1.20)>.9 and LAB.status_alpha(4.15)>.9 and LAB.status_alpha(7.05)==0.0,"3 status probes and expiry")
    for t in [.35,1.25,3.60,6.85]:
        var chosen:Array[int]=LAB.selected_demo_targets(t)
        check(chosen.size()==3,"visual 3 targets "+str(t))
        check(chosen.has(0) and chosen.has(1) and chosen.has(2) and not chosen.has(3),"4th enemy remains OUTSIDE "+str(t))
        for idx in chosen:
            check(LAB.is_inside_visual_circle(LAB.monster_foot(idx,t)),"selected in circle")
        check(not LAB.is_inside_visual_circle(LAB.monster_foot(3,t)),"external enemy out of range")
    for i in range(4):
        check(LAB.monster_foot(i,.35).distance_to(LAB.monster_foot(i,6.85))>10,"moving enemy "+str(i))
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"real enemy animated")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison15_hoa_doc_tan/r1/hoa_doc_tan.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status","apply_poison","set_health","remove_status","spawn_projectile","summon_actor"]:
        check(not src.contains(forbidden),"no gameplay state mutation "+forbidden)
    var raw:=0
    for row in [
        [LAB.ASSET_ROOT+"poi15_charge_08.png",Vector2(768,384)],
        [LAB.ASSET_ROOT+"poi15_field_12.png",Vector2(1280,960)],
        [LAB.ASSET_ROOT+"poi15_mark_08.png",Vector2(512,256)]
    ]:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"RGBA atlas path "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"Godot imported "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"atlas size "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true alpha source "+path)
        raw+=tex.get_width()*tex.get_height()*4
    check(raw<8*1024*1024,"source atlas raw under8MiB")
    if failures==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.charge_frames.size()==8 and lab.field_frames.size()==12 and lab.mark_frames.size()==8,"28 independent sprite keyposes")
        lab.queue_free()
    print("POI15_HOA_DOC_TAN_RGBA_RAW_BYTES=",raw)
    print("POI15_HOA_DOC_TAN_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
