extends SceneTree
const LAB=preload("res://labs/combat_lab/poison11/r1_original/van_doc_xuyen_tam_r1.gd")
const Badge=preload("res://labs/combat_lab/shared_poison_status/poison_status_badge.gd")
var failures:=0
func _initialize()->void:call_deferred("_run")
func check(ok:bool,reason:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_POI11_R1_FAIL "+reason)
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.ultimate.human","ultimate Human identity")
    check(LAB.EFFECT=="poison" and LAB.ELEMENT=="nether" and LAB.SHAPE=="circle","poison nether circle")
    check(LAB.TARGET_LIMIT==3 and LAB.DECLARED_RADIUS==3.0,"canonical circle radius 3, cap 3")
    check(LAB.DECLARED_RANGE==8.0 and LAB.DECLARED_CAST==1.15,"cast and range")
    check(LAB.DECLARED_COOLDOWN==36.0 and LAB.DECLARED_PROJECTILE_SPEED==8.0,"cooldown and projectile")
    check(LAB.DECLARED_DURATION==8.0 and LAB.DECLARED_POISON_STACKS==2 and LAB.DECLARED_DAMAGE_RATIO==1.8,"duration stacks and damage")
    check(LAB.CROWN_PATH.ends_with("poison11_crown_10_r9.png"),"R8 freeform alpha matte crown")
    check(LAB.phase_at(.55)=="charge" and LAB.phase_at(1.50)=="one_cosmetic_spear_approach","charge/flight")
    check(LAB.phase_at(2.06)=="poison_piercer_crown" and LAB.phase_at(2.47)=="localized_piercing_contacts","area burst/contact")
    check(LAB.spear_alpha(1.86)>.75 and LAB.crown_alpha(1.86)>0.0,"R7 painted vortex begins while spear remains visible")
    for t in [1.90,1.94,1.98,2.02]:
        check(LAB.spear_alpha(t)+LAB.crown_alpha(t)>.40,"R7 no empty spear-to-burst handoff at "+str(t))
    check(LAB.phase_at(4.0)=="shared_poison_status_only" and LAB.phase_at(10.60)=="idle","not 8s VFX aura")
    check(LAB.flight_position(LAB.CAST_END).distance_to(LAB.PALM)<.01,"launch palm")
    check(LAB.flight_position(LAB.AREA_ARRIVE).distance_to(LAB.AREA_CENTER)<.01,"area centroid")
    for q in [.1,.25,.5,.75,.9]:
        var t:float=lerpf(LAB.CAST_END,LAB.AREA_ARRIVE,q)
        check(LAB.flight_position(t).distance_to(LAB.PALM.lerp(LAB.AREA_CENTER,q))<.02,"straight projection "+str(q))
    check(LAB.MONSTER_FRAMES.has_animation("walk") and LAB.MONSTER_FRAMES.get_frame_count("walk")>=8,"real monster walk animation")
    for i in range(3):
        check(LAB.monster_foot(i,.55).distance_to(LAB.monster_foot(i,2.45))>10.0,"actual moving target "+str(i))
        check(LAB.monster_chest(i,2.45).distance_to(LAB.monster_foot(i,2.45)+Vector2(-5,-79))<.01,"contact follows target "+str(i))
        check(LAB.contact_anchor(i,2.45).distance_to(LAB.monster_chest(i,2.45)+Vector2(0,12))<.01,"R6 torso glint below face "+str(i))
        check(LAB.contact_anchor(i,.55).distance_to(LAB.contact_anchor(i,2.45))>10.0,"R6 contact tracks moving actor "+str(i))
        var hit:float=LAB.mock_contact_time(i)
        check(not Badge.should_show(2,LAB.demo_status_remaining(i,hit-.01)),"no pre-emptive poison badge")
        check(Badge.should_show(2,LAB.demo_status_remaining(i,hit+3.0)),"one shared poison icon")
        check(not Badge.should_show(2,LAB.demo_status_remaining(i,hit+8.01)),"badge cleared after eight seconds")
    check(not Badge.should_show(0,3.0) and not Badge.should_show(2,0.0),"no phantom poisoned state")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison11/r1_original/van_doc_xuyen_tam_r1.gd")
    for bad in ["SaveService.","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        check(not source.contains(bad),"view only "+bad)
    var specs=[
        [LAB.CHARGE_PATH,Vector2(768,576),Vector2i(192,192),10],
        [LAB.FLIGHT_PATH,Vector2(896,480),Vector2i(224,160),10],
        [LAB.CROWN_PATH,Vector2(1280,576),Vector2i(320,192),10],
        [LAB.CONTACT_PATH,Vector2(768,320),Vector2i(192,160),8]
    ]
    var total_bytes:=0
    for row in specs:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"atlas exists "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"atlas imported "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"atlas geometry "+path)
        total_bytes+=tex.get_width()*tex.get_height()*4
        var im:=tex.get_image()
        check(im.detect_alpha()!=Image.ALPHA_NONE,"alpha channel "+path)
        var cell:Vector2i=row[2]
        for i in range(row[3]):
            var x:int=(i%4)*cell.x
            var y:int=(i/4)*cell.y
            check(im.get_pixel(x,y).a==0.0 and im.get_pixel(x+cell.x-1,y+cell.y-1).a==0.0,"alpha gutters "+str(i))
    check(total_bytes<=8*1024*1024,"texture <=8MiB")
    if failures==0:
        var inst:=LAB.new()
        root.add_child(inst)
        await process_frame
        check(inst.charge_frames.size()==10 and inst.flight_frames.size()==10 and inst.crown_frames.size()==10 and inst.contact_frames.size()==8,"38 unique atlas poses")
        inst.queue_free()
    print("VFX_POI11_R1_RAW_RGBA_BYTES=",total_bytes)
    print("VFX_POI11_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)