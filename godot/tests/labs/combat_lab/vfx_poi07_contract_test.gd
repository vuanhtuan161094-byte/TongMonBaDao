extends SceneTree
const LAB = preload("res://labs/combat_lab/poison07/xuyen_cot_doc_cham.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_run")
func _check(ok: bool, msg: String) -> void:
    if not ok:
        failures+=1
        push_error("POI07_FAIL "+msg)
func _run() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.active_01.human","skill id")
    _check(LAB.ELEMENT=="nether" and LAB.EFFECT=="damage" and LAB.SHAPE=="single_target","canonical contract")
    _check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_POISON_STACKS==0,"no false poison/aoe")
    _check(LAB.DECLARED_CAST==0.45 and LAB.DECLARED_RANGE==7.5,"cast/range")
    _check(LAB.DECLARED_COOLDOWN==9.0 and LAB.DECLARED_PROJECTILE_SPEED==8.0,"speed/cooldown")
    _check(LAB.phase_at(0.18)=="charge" and LAB.phase_at(0.67)=="travel","phases")
    _check(LAB.phase_at(1.65)=="single_contact" and LAB.phase_at(2.11)=="fade" and LAB.phase_at(2.5)=="idle","contact/fade/idle")
    _check(LAB.flight_tip_at(LAB.CAST_END).distance_to(LAB.PALM)<0.01,"flight begins at palm")
    _check(LAB.flight_tip_at(LAB.CONTACT_AT).distance_to(LAB.CHEST)<0.01,"flight ends at chest")
    for fraction in [0.1,0.25,0.5,0.75,0.9]:
        var timepoint: float = lerpf(LAB.CAST_END,LAB.CONTACT_AT,fraction)
        var actual: Vector2 = LAB.flight_tip_at(timepoint)
        var ideal: Vector2 = LAB.PALM.lerp(LAB.CHEST,fraction)
        _check(actual.distance_to(ideal)<0.05,"strict straight constant-speed flight fraction "+str(fraction))
    var source := FileAccess.get_file_as_string("res://labs/combat_lab/poison07/xuyen_cot_doc_cham.gd")
    for forbidden in ["SaveService.","MapBattleV2.","CombatV2.","apply_damage","apply_status","V63FeatureGates."]:
        _check(not source.contains(forbidden),"view-only: "+forbidden)
    for path in [LAB.ATLAS_PATH,LAB.CONTACT_PATH]:
        _check(ResourceLoader.exists(path),"alpha atlas exists "+path)
    if ResourceLoader.exists(LAB.ATLAS_PATH) and ResourceLoader.exists(LAB.CONTACT_PATH):
        var a := load(LAB.ATLAS_PATH) as Texture2D
        var b := load(LAB.CONTACT_PATH) as Texture2D
        _check(a!=null and b!=null,"real Texture2D")
        if a!=null and b!=null:
            _check(a.get_size()==Vector2(1536,576) and b.get_size()==Vector2(1024,512),"atlas dimensions")
            for atlas in [a,b]:
                var img: Image=atlas.get_image()
                _check(img.detect_alpha()!=Image.ALPHA_NONE,"native alpha")
                var w: int=384 if atlas==a else 256
                var h: int=192 if atlas==a else 256
                var count: int=12 if atlas==a else 8
                for i in range(count):
                    var x: int=(i%4)*w
                    var y: int=int(floor(float(i)/4.0))*h
                    _check(img.get_pixel(x,y).a==0.0 and img.get_pixel(x+w-1,y+h-1).a==0.0,"alpha edge "+str(i))
    if failures==0:
        var sample:=LAB.new()
        root.add_child(sample)
        await process_frame
        _check(sample.needle_frames.size()==12 and sample.impact_frames.size()==8,"created atlas frames")
        sample.queue_free()
    print("VFX_POI07_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
