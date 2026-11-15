extends SceneTree
const LAB=preload("res://labs/combat_lab/poison09/r1_painted/bach_doc_tan_cham_r1.gd")
var fails:=0
func _initialize() -> void: call_deferred("_run")
func check(ok: bool,reason: String) -> void:
    if not ok:
        fails+=1
        push_error("POI09_R1_FAIL "+reason)
func _run() -> void:
    check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.active_03.human","ID")
    check(LAB.ELEMENT=="nether" and LAB.EFFECT=="poison" and LAB.SHAPE=="circle","catalogue effect shape")
    check(LAB.TARGET_LIMIT==3 and LAB.DECLARED_RADIUS==2.8,"radius 2.8 cap 3")
    check(LAB.DECLARED_CAST==0.6 and LAB.DECLARED_RANGE==7,"cast range")
    check(LAB.DECLARED_COOLDOWN==11.0 and LAB.DECLARED_PROJECTILE_SPEED==8.0,"cooldown speed")
    check(LAB.DECLARED_DURATION==6.0 and LAB.DECLARED_POISON_STACKS==1,"one 6 sec poison stack")
    check(LAB.phase_at(.24)=="lotus_charge" and LAB.phase_at(1.03)=="three_needles_in_flight","charge flight")
    check(LAB.phase_at(1.58)=="three_local_contacts" and LAB.phase_at(5.5)=="one_poison_mark_each","contact sustain")
    check(LAB.phase_at(7.78)=="mark_dissolve" and LAB.phase_at(8.5)=="idle","fade")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison09/r1_painted/bach_doc_tan_cham_r1.gd")
    for forbidden in ["SaveService.","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        check(not src.contains(forbidden),"lab must be view-only "+forbidden)
    for i in range(LAB.TARGET_LIMIT):
        var start:float=LAB.start_time(i)
        var hit:float=LAB.hit_time(i)
        check(LAB.needle_tip_at(i,start).distance_to(LAB.PALM)<0.01,"launch from palm "+str(i))
        check(LAB.needle_tip_at(i,hit).distance_to(LAB.chest_at(i,hit))<0.01,"predict moving chest "+str(i))
        check(LAB.target_at(i,0.0).distance_to(LAB.target_at(i,2.0))>2.0,"moving mock enemy "+str(i))
        for q in [.1,.25,.5,.75,.9]:
            var t:float=lerpf(start,hit,q)
            check(LAB.needle_tip_at(i,t).distance_to(LAB.PALM.lerp(LAB.chest_at(i,hit),q))<.02,"strict no arc "+str(i)+" "+str(q))
        check(LAB.mark_alpha_at(i,hit-.01)==0 and LAB.mark_alpha_at(i,hit+3.0)>.9 and LAB.mark_alpha_at(i,hit+6.33)==0,"independent 6s mark "+str(i))
    var cases=[[LAB.CHARGE_PATH,Vector2(896,480),Vector2i(224,160),12],
        [LAB.NEEDLE_PATH,Vector2(1024,288),Vector2i(256,96),12],
        [LAB.CONTACT_PATH,Vector2(768,480),Vector2i(192,160),10],
        [LAB.MARK_PATH,Vector2(768,480),Vector2i(192,160),12]]
    var bytes_total:=0
    for row in cases:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"atlas exists "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"native texture "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"texture dims "+path)
        bytes_total+=int(tex.get_width()*tex.get_height()*4)
        var im:Image=tex.get_image()
        check(im.detect_alpha()!=Image.ALPHA_NONE,"true alpha "+path)
        var cell:Vector2i=row[2]
        for i in range(row[3]):
            var x:int=(i%4)*cell.x
            var y:int=(i/4)*cell.y
            check(im.get_pixel(x,y).a==0 and im.get_pixel(x+cell.x-1,y+cell.y-1).a==0,"alpha gutters "+str(i))
    check(bytes_total<=8*1024*1024,"raw alpha budget <=8MiB")
    if fails==0:
        var inst:=LAB.new()
        root.add_child(inst)
        await process_frame
        check(inst.charge_frames.size()==12 and inst.needle_frames.size()==12 and inst.contact_frames.size()==10 and inst.mark_frames.size()==12,"46 frames loaded")
        inst.queue_free()
    print("VFX_POI09_R1_RAW_RGBA_BYTES=",bytes_total)
    print("VFX_POI09_R1_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails))
    quit(0 if fails==0 else 1)