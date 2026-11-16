extends SceneTree
const LAB=preload("res://labs/combat_lab/poison10/r1_painted/doc_khi_phe_tam_r1.gd")
var fails:=0
func _initialize() -> void: call_deferred("_run")
func check(ok: bool,reason: String) -> void:
    if not ok:
        fails+=1
        push_error("POI10_R1_FAIL "+reason)
func _run() -> void:
    check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.active_04.human","canonical Human ID")
    check(LAB.EFFECT=="poison" and LAB.ELEMENT=="nether" and LAB.SHAPE=="circle","effect/element/shape")
    check(LAB.TARGET_LIMIT==3 and LAB.DECLARED_RADIUS==2.6,"circle radius 2.6 cap 3")
    check(LAB.DECLARED_RANGE==7.0 and LAB.DECLARED_CAST==0.65,"cast/range")
    check(LAB.DECLARED_COOLDOWN==12.0 and LAB.DECLARED_PROJECTILE_SPEED==8.0,"cooldown/speed")
    check(LAB.DECLARED_DURATION==6.0 and LAB.DECLARED_POISON_STACKS==1 and LAB.DECLARED_DAMAGE_RATIO==0.9,"catalogue poison parameters")
    check(LAB.phase_at(.24)=="venom_charge" and LAB.phase_at(.86)=="expanding_toxic_wave_flight","charge/flight phases")
    check(LAB.phase_at(1.60)=="three_local_contacts" and LAB.phase_at(4.0)=="one_6s_mark_each","contact/mark phases")
    check(LAB.phase_at(7.80)=="mark_fade" and LAB.phase_at(8.30)=="idle","fade/idle")
    check(LAB.pulse_at(LAB.CAST_END).distance_to(LAB.PALM)<.01 and LAB.pulse_at(LAB.AREA_ARRIVE).distance_to(LAB.AREA_CENTER)<.01,"one radial energy wave anchored")
    for q in [.1,.25,.5,.75,.9]:
        var t:float=lerpf(LAB.CAST_END,LAB.AREA_ARRIVE,q)
        check(LAB.pulse_at(t).distance_to(LAB.PALM.lerp(LAB.AREA_CENTER,q))<.02,"no fake arc "+str(q))
    for i in range(3):
        var h:float=LAB.hit_time(i)
        check(LAB.target_at(i,.0).distance_to(LAB.target_at(i,2.0))>2.0,"mock target moves "+str(i))
        check(LAB.mark_alpha_at(i,h-.01)==0 and LAB.mark_alpha_at(i,h+3)>.9 and LAB.mark_alpha_at(i,h+6.35)==0,"6-second mark "+str(i))
        check(LAB.chest_at(i,h).distance_to(LAB.target_at(i,h)+Vector2(0,-40))<.01,"local mark follows target "+str(i))
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison10/r1_painted/doc_khi_phe_tam_r1.gd")
    for forbidden in ["SaveService.","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        check(not src.contains(forbidden),"view-only "+forbidden)
    var cases=[[LAB.CHARGE_PATH,Vector2(896,576),Vector2i(224,192),12],
        [LAB.CORONA_PATH,Vector2(896,672),Vector2i(224,224),12],
        [LAB.CONTACT_PATH,Vector2(768,480),Vector2i(192,160),10],
        [LAB.MARK_PATH,Vector2(640,480),Vector2i(160,160),12]]
    var raw_bytes:=0
    for row in cases:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"atlas exists "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"native texture "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"atlas dimensions "+path)
        raw_bytes+=int(tex.get_width()*tex.get_height()*4)
        var im:Image=tex.get_image()
        check(im.detect_alpha()!=Image.ALPHA_NONE,"real alpha "+path)
        var cell:Vector2i=row[2]
        for i in range(row[3]):
            var x:int=i%4*cell.x
            var y:int=i/4*cell.y
            check(im.get_pixel(x,y).a==0 and im.get_pixel(x+cell.x-1,y+cell.y-1).a==0,"alpha edge "+path+" frame "+str(i))
    check(raw_bytes<=8*1024*1024,"raw RGBA8 budget <=8MiB")
    if fails==0:
        var inst:=LAB.new()
        root.add_child(inst)
        await process_frame
        check(inst.charge_frames.size()==12 and inst.corona_frames.size()==12 and inst.contact_frames.size()==10 and inst.mark_frames.size()==12,"46 frames")
        inst.queue_free()
    print("VFX_POI10_R1_RAW_RGBA_BYTES=",raw_bytes)
    print("VFX_POI10_R1_RESULT=",("PASS" if fails==0 else "FAIL")," failures=",fails)
    quit(0 if fails==0 else 1)