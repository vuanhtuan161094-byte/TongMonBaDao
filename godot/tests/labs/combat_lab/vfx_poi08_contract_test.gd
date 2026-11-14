extends SceneTree
const LAB=preload("res://labs/combat_lab/poison08/phe_mach_doc_thich.gd")
var failures:=0
func _initialize() -> void:
    call_deferred("_run")
func _check(ok: bool,why: String) -> void:
    if not ok:
        failures+=1
        push_error("POI08_FAIL "+why)
func _run() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.active_02.human","canonical skill id")
    _check(LAB.ELEMENT=="nether" and LAB.EFFECT=="poison" and LAB.SHAPE=="single_target","canonical elemental effect")
    _check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_RADIUS==0.0 and LAB.DECLARED_POISON_STACKS==1,"strict one target one stack")
    _check(LAB.DECLARED_CAST==0.45 and LAB.DECLARED_RANGE==7.5,"cast/range")
    _check(LAB.DECLARED_COOLDOWN==9.0 and LAB.DECLARED_PROJECTILE_SPEED==8.0,"speed/cooldown")
    _check(LAB.DECLARED_DURATION==8.0 and LAB.MARK_END-LAB.CONTACT_AT==8.0,"eight seconds metadata and visual")
    _check(LAB.phase_at(0.21)=="charge" and LAB.phase_at(0.72)=="flight","early phases")
    _check(LAB.phase_at(5.3)=="single_target_poison_visual" and LAB.phase_at(9.55)=="fade" and LAB.phase_at(9.83)=="idle","late phases")
    _check(LAB.tip_at(LAB.CAST_END).distance_to(LAB.PALM)<0.02 and LAB.tip_at(LAB.CONTACT_AT).distance_to(LAB.CHEST)<0.02,"strict direct flight endpoints")
    for q in [0.10,0.25,0.50,0.75,0.90]:
        var at: float=lerpf(LAB.CAST_END,LAB.CONTACT_AT,q)
        _check(LAB.tip_at(at).distance_to(LAB.PALM.lerp(LAB.CHEST,q))<0.02,"straight flight "+str(q))
    _check(LAB.charge_pose_at(0)==0 and LAB.charge_pose_at(LAB.CAST_END)==7,"8 frame charge")
    _check(LAB.thorn_pose_at(LAB.CAST_END)==0 and LAB.thorn_pose_at(LAB.CONTACT_AT)==11,"12 frame flight")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison08/phe_mach_doc_thich.gd")
    for forbidden in ["SaveService.","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not source.contains(forbidden),"view-only "+forbidden)
    var entries=[[LAB.THORN_PATH,Vector2(1536,576),Vector2i(384,192),12],[LAB.CHARGE_PATH,Vector2(1024,512),Vector2i(256,256),8],[LAB.VEIN_PATH,Vector2(1280,960),Vector2i(320,320),12]]
    for item in entries:
        var p: String=item[0]
        _check(ResourceLoader.exists(p),"imported atlas "+p)
        if not ResourceLoader.exists(p):continue
        var tex:=load(p) as Texture2D
        _check(tex!=null,"load Texture2D "+p)
        if tex==null:continue
        _check(tex.get_size()==item[1],"atlas dimensions "+p)
        var im: Image=tex.get_image()
        _check(im.detect_alpha()!=Image.ALPHA_NONE,"alpha "+p)
        var cell: Vector2i=item[2]
        for i in range(item[3]):
            var x: int=(i%4)*cell.x
            var y: int=int(floor(float(i)/4.0))*cell.y
            _check(im.get_pixel(x,y).a==0.0 and im.get_pixel(x+cell.x-1,y+cell.y-1).a==0.0,"alpha border "+p+" "+str(i))
    if failures==0:
        var sample:=LAB.new()
        root.add_child(sample)
        await process_frame
        _check(sample.thorn_frames.size()==12 and sample.charge_frames.size()==8 and sample.vein_frames.size()==12,"native imported flipbook frames")
        sample.queue_free()
    print("VFX_POI08_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
