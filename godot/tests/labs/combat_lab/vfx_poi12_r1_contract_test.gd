extends SceneTree
const LAB=preload("res://labs/combat_lab/poison12/tay_mach_linh_duoc.gd")
var failures:=0
func _initialize()->void:call_deferred("_run")
func check(ok:bool,description:String)->void:
    if not ok:
        failures+=1
        push_error("POI12_R1_FAIL "+description)
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.duoc_doc.active_01.human","canonical exact ID")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="wood" and LAB.SHAPE=="single_target","NO HEAL, single damage wood")
    check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_DURATION==0.0,"one target no poison duration")
    check(LAB.DECLARED_CAST==.45 and LAB.DECLARED_COOLDOWN==8.0 and LAB.DECLARED_RANGE==7.5,"canonical cast cooldown range")
    check(LAB.DECLARED_DAMAGE_RATIO==1.35 and LAB.DECLARED_PROJECTILE_SPEED==8.0,"canonical speed and ratio")
    check(LAB.phase_at(.20)=="medicinal_charge" and LAB.phase_at(.73)=="one_elixir_projectile" and LAB.phase_at(1.12)=="botanical_local_impact","phase truth")
    check(LAB.phase_at(1.8)=="idle","attack not prolonged as poison status")
    check(LAB.monster_foot(.20).distance_to(LAB.monster_foot(1.12))>10,"actual moving walking target displacement")
    check(LAB.demo_flight_at(LAB.CAST_END).distance_to(LAB.PALM)<.01,"palm origin")
    check(LAB.demo_flight_at(LAB.DEMO_CONTACT).distance_to(LAB.monster_chest(LAB.DEMO_CONTACT))<.01,"one moving target anchor")
    # Four cardinal vectors work from ONE reused right-facing atlas.
    var origin:=Vector2(400.0,330.0)
    var cases: Array[Vector2]=[Vector2(600,330),Vector2(200,330),Vector2(400,130),Vector2(400,530)]
    for target in cases:
        var d:Vector2=target-origin
        var angle:=LAB.projectile_angle(origin,target)
        var facing:=Vector2.RIGHT.rotated(angle)
        check(facing.dot(d.normalized())>.9999,"four-direction flight angle reaches target: "+str(target))
        check(LAB.directional_flight_position(origin,target,0.0).distance_to(origin)<.01,"four directions start at caster")
        check(LAB.directional_flight_position(origin,target,1.0).distance_to(target)<.01,"four directions end at target")
        check(LAB.directional_flight_position(origin,target,0.5).distance_to(origin.lerp(target,0.5))<.01,"four directions travel to target")
    check(LAB.projectile_angle(origin,origin)==0.0,"zero vector safe")
    check(LAB.MONSTER_FRAMES.has_animation("walk") and LAB.MONSTER_FRAMES.get_frame_count("walk")>=8,"actual monster walk frames")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison12/tay_mach_linh_duoc.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_status","poison_status_badge","heal_target","add_health","summon_actor"]:
        check(not src.contains(bad),"no fake gameplay/status/heal "+bad)
    var specs=[
        [LAB.CHARGE_PATH,Vector2(768,384),8],
        [LAB.FLIGHT_PATH,Vector2(1152,480),12],
        [LAB.IMPACT_PATH,Vector2(1024,768),10]
    ]
    var raw:=0
    for row in specs:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"atlas exists "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"imported atlas "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"atlas dimensions "+path)
        raw+=tex.get_width()*tex.get_height()*4
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"alpha "+path)
    check(raw<9*1024*1024,"sprite texture budget")
    if failures==0:
        var inst:=LAB.new()
        root.add_child(inst)
        await process_frame
        check(inst.charge_frames.size()==8 and inst.flight_frames.size()==12 and inst.impact_frames.size()==10,"30 poses ready in scene")
        inst.queue_free()
    print("VFX_POI12_R1_RAW_RGBA_BYTES=",raw)
    print("VFX_POI12_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
