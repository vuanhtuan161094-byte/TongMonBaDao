extends SceneTree
const LAB=preload("res://labs/combat_lab/poison08/r3_painted/phe_mach_doc_thich_r3.gd")
var failures:=0
func _initialize() -> void: call_deferred("_run")
func _check(ok: bool,msg: String) -> void:
    if not ok:
        failures+=1
        push_error("POI08_R3_FAIL "+msg)
func _run() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.active_02.human","canonical Human ID")
    _check(LAB.ELEMENT=="nether" and LAB.EFFECT=="poison" and LAB.SHAPE=="single_target","canonical spell type")
    _check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_RADIUS==0 and LAB.DECLARED_POISON_STACKS==1,"single target one stack")
    _check(LAB.DECLARED_CAST==0.45 and LAB.DECLARED_RANGE==7.5,"range and cast")
    _check(LAB.DECLARED_PROJECTILE_SPEED==8.0 and LAB.DECLARED_COOLDOWN==9,"flight and cooldown")
    _check(LAB.DECLARED_DURATION==8 and LAB.MARK_END-LAB.CONTACT_AT==8,"eight-second visual duration")
    _check(LAB.phase_at(0.14)=="seed_charge" and LAB.phase_at(.78)=="straight_barb","charge and flight phases")
    _check(LAB.phase_at(1.51)=="one_contact" and LAB.phase_at(5.1)=="one_mark_visual","local mark")
    _check(LAB.phase_at(9.54)=="mark_fade" and LAB.phase_at(9.80)=="idle","fade phases")
    _check(LAB.mark_opacity_at(LAB.CONTACT_AT-0.01)==0.0 and LAB.mark_opacity_at(5.0)>.9 and LAB.mark_opacity_at(LAB.FADE_END)==0.0,"no false mark outside timeline")
    _check(LAB.flight_tip_at(LAB.CAST_END).distance_to(LAB.PALM)<0.02 and LAB.flight_tip_at(LAB.CONTACT_AT).distance_to(LAB.CHEST)<0.02,"straight endpoints")
    for q in [0.1,0.25,0.5,0.75,0.9]:
        var at:float=lerpf(LAB.CAST_END,LAB.CONTACT_AT,q)
        _check(LAB.flight_tip_at(at).distance_to(LAB.PALM.lerp(LAB.CHEST,q))<0.02,"no arc fraction "+str(q))
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison08/r3_painted/phe_mach_doc_thich_r3.gd")
    for forbidden in ["SaveService.","MapBattleV2.","CombatV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not source.contains(forbidden),"view only "+forbidden)
    var spec=[
        [LAB.BARB_PATH,Vector2(1536,384),Vector2i(384,128),12],
        [LAB.SEED_PATH,Vector2(768,576),Vector2i(192,192),10],
        [LAB.BITE_PATH,Vector2(768,384),Vector2i(192,192),8],
        [LAB.MARK_PATH,Vector2(768,576),Vector2i(192,192),12]
    ]
    var total_bytes:=0
    for row in spec:
        var p:String=row[0]
        _check(ResourceLoader.exists(p),"RGBA path "+p)
        if not ResourceLoader.exists(p):continue
        var tex:=load(p) as Texture2D
        _check(tex!=null,"Godot Texture2D import "+p)
        if tex==null:continue
        _check(tex.get_size()==row[1],"atlas dimensions "+p)
        total_bytes+=int(tex.get_width()*tex.get_height()*4)
        var im:Image=tex.get_image()
        _check(im.detect_alpha()!=Image.ALPHA_NONE,"real alpha "+p)
        var cell:Vector2i=row[2]
        for i in range(row[3]):
            var x:int=(i%4)*cell.x
            var y:int=(i/4)*cell.y
            _check(im.get_pixel(x,y).a==0.0 and im.get_pixel(x+cell.x-1,y+cell.y-1).a==0.0,"no alpha bleed "+p+" pose "+str(i))
    _check(total_bytes<=8*1024*1024,"RGBA8 not above 8MiB per skill")
    if failures==0:
        var instance:=LAB.new()
        root.add_child(instance)
        await process_frame
        _check(instance.barb_frames.size()==12 and instance.seed_frames.size()==10 and instance.bite_frames.size()==8 and instance.mark_frames.size()==12,"all 42 sprite frames imported")
        instance.queue_free()
    print("VFX_POI08_R3_RAW_RGBA_BYTES=",total_bytes)
    print("VFX_POI08_R3_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
