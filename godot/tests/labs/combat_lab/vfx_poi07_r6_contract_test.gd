extends SceneTree
const LAB=preload("res://labs/combat_lab/poison07/r6_original/xuyen_cot_doc_cham_r6.gd")
var failures:=0
func _initialize() -> void: call_deferred("_run")
func _check(ok: bool,msg: String) -> void:
    if not ok:
        failures+=1
        push_error("POI07_R6_FAIL "+msg)
func _run() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.active_01.human","canonical skill ID")
    _check(LAB.ELEMENT=="nether" and LAB.EFFECT=="damage" and LAB.SHAPE=="single_target","canonical effect shape")
    _check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_POISON_STACKS==0,"single-target damage no DoT")
    _check(LAB.DECLARED_CAST==0.45 and LAB.DECLARED_RANGE==7.5,"cast and range")
    _check(LAB.DECLARED_PROJECTILE_SPEED==8.0 and LAB.DECLARED_COOLDOWN==9.0,"projectile and cooldown")
    _check(LAB.phase_at(0.15)=="charge" and LAB.phase_at(0.8)=="straight_flight","early phases")
    _check(LAB.phase_at(1.5)=="puncture" and LAB.phase_at(2.1)=="dissolve" and LAB.phase_at(2.5)=="idle","late phases")
    _check(LAB.flight_tip_at(LAB.CAST_END).distance_to(LAB.PALM)<0.005,"launch at palm")
    _check(LAB.flight_tip_at(LAB.CONTACT_AT).distance_to(LAB.CHEST)<0.005,"hit at chest")
    for k in [0.1,0.25,0.5,0.75,0.9]:
        _check(LAB.flight_tip_at(lerpf(LAB.CAST_END,LAB.CONTACT_AT,k)).distance_to(LAB.PALM.lerp(LAB.CHEST,k))<0.01,"strict no arc "+str(k))
    _check(LAB.charge_frame_float(0)==0 and LAB.charge_frame_float(LAB.CAST_END)==9,"charge frames")
    _check(LAB.hero_frame_float(LAB.CAST_END)==0 and LAB.hero_frame_float(LAB.CONTACT_AT)==11,"hero frames")
    _check(LAB.impact_frame_float(LAB.CONTACT_AT)==0 and LAB.impact_frame_float(LAB.FADE_END)==11,"impact frames")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison07/r6_original/xuyen_cot_doc_cham_r6.gd")
    for forbidden in ["SaveService.","MapBattleV2.","CombatV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not source.contains(forbidden),"view-only "+forbidden)
    var packs=[
        [LAB.HERO,Vector2(1024,480),Vector2i(256,160),12],
        [LAB.CHARGE,Vector2(768,576),Vector2i(192,192),10],
        [LAB.PUNCTURE,Vector2(1024,768),Vector2i(256,256),12]
    ]
    var raw_bytes:=0
    for item in packs:
        var path: String=item[0]
        _check(ResourceLoader.exists(path),"atlas present "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        _check(tex!=null,"imported texture "+path)
        if tex==null:continue
        _check(tex.get_size()==item[1],"atlas dimensions "+path)
        raw_bytes += int(tex.get_width()*tex.get_height()*4)
        var img: Image=tex.get_image()
        _check(img.detect_alpha()!=Image.ALPHA_NONE,"alpha channel "+path)
        var cell: Vector2i=item[2]
        for i in range(item[3]):
            var x: int=(i%4)*cell.x
            var y: int=(i/4)*cell.y
            _check(img.get_pixel(x,y).a==0.0 and img.get_pixel(x+cell.x-1,y+cell.y-1).a==0.0,"per-cell alpha "+str(i))
    _check(raw_bytes<8*1024*1024,"raw RGBA budget <8MiB")
    if failures==0:
        var example:=LAB.new()
        root.add_child(example)
        await process_frame
        _check(example.hero_frames.size()==12 and example.charge_frames.size()==10 and example.puncture_frames.size()==12,"34 native frames")
        example.queue_free()
    print("VFX_POI07_R6_RAW_RGBA_BYTES=",raw_bytes)
    print("VFX_POI07_R6_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
