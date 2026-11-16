extends SceneTree
const LAB=preload("res://labs/combat_lab/poison_basic_human_v2/doc_cham_thuong_thuc.gd")
var failures:=0
func _initialize()->void:call_deferred("_test")
func check(ok:bool,reason:String)->void:
    if not ok:
        failures+=1
        push_error("POISON_BASIC_R2_FAIL "+reason)
func _test()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.basic.human","canonical skill")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="metal" and LAB.SHAPE=="single_target","damage metal single")
    check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_DURATION==0.0,"single target without status")
    check(LAB.DECLARED_CAST==0.0 and LAB.DECLARED_COOLDOWN==1.6 and LAB.DECLARED_RANGE==6.0,"cast cooldown range")
    check(LAB.DECLARED_DAMAGE_RATIO==1.0 and LAB.DECLARED_PROJECTILE_SPEED==12.0,"damage ratio and speed")
    check(LAB.CAST_END>0.0 and LAB.DECLARED_CAST==0.0,"visual formation distinct from Combat cast")
    check(LAB.phase_at(.08)=="charge" and LAB.phase_at(.42)=="flight" and LAB.phase_at(.78)=="contact" and LAB.phase_at(1.13)=="idle","three phases and fade")
    check(LAB.monster_foot(.08).distance_to(LAB.monster_foot(.78))>10.0,"monster WALK movement")
    check(LAB.visual_flight_at(LAB.CAST_END,LAB.PALM,LAB.monster_chest(LAB.CAST_END)).distance_to(LAB.PALM)<.01,"flight start")
    check(LAB.visual_flight_at(LAB.DEMO_CONTACT,LAB.PALM,LAB.monster_chest(LAB.DEMO_CONTACT)).distance_to(LAB.monster_chest(LAB.DEMO_CONTACT))<.01,"moving target contact")
    var o:=Vector2(400,330)
    for d in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
        var target:=o+d*190.0
        check(Vector2.RIGHT.rotated(LAB.projectile_angle(o,target)).dot(d)>.9999,"direction "+str(d))
        check(LAB.visual_flight_at(LAB.DEMO_CONTACT,o,target).distance_to(target)<.01,"direction target")
    check(LAB.projectile_angle(o,o)==0.0,"zero vector")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"monster real walk")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison_basic_human_v2/doc_cham_thuong_thuc.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_status","poison_status_badge","heal_target","summon_actor"]:
        check(not src.contains(bad),"view-only "+bad)
    var atlas_data=[[LAB.CHARGE_PATH,Vector2(768,384),6],[LAB.FLIGHT_PATH,Vector2(1152,320),8],[LAB.IMPACT_PATH,Vector2(1024,512),8]]
    var bytes:=0
    for row in atlas_data:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"source exists "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"source import "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"atlas size "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true RGBA "+path)
        bytes+=tex.get_width()*tex.get_height()*4
    check(bytes<=5*1024*1024,"budget 22 original poses")
    if failures==0:
        var scene:=LAB.new()
        root.add_child(scene)
        await process_frame
        check(scene.charge_frames.size()==6 and scene.flight_frames.size()==8 and scene.impact_frames.size()==8,"22 original alpha atlas poses live")
        scene.queue_free()
    print("VFX_POISON_BASIC_R2_RAW_RGBA_BYTES=",bytes)
    print("VFX_POISON_BASIC_R2_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
