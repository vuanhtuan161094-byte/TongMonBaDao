extends SceneTree
const LAB=preload("res://labs/combat_lab/poison_basic_tiers_v3/poison_basic_tiers.gd")
var failures:=0
func _initialize()->void:call_deferred("_test")
func check(ok:bool,info:String)->void:
    if not ok:
        failures+=1
        push_error("POISON_BASIC_TIERS_V3_FAIL "+info)
func _test()->void:
    check(LAB.SCHOOL=="poison" and LAB.EFFECT=="damage" and LAB.ELEMENT=="metal" and LAB.SHAPE=="single_target","canonical type")
    check(LAB.TARGET_LIMIT==1,"single visual hit")
    check(LAB.TIER_NAMES.size()==3 and LAB.SKILL_IDS.size()==3,"three catalogue identities")
    check(LAB.SKILL_IDS[0]=="tmb.skill.poison.basic.human" and LAB.SKILL_IDS[1]=="tmb.skill.poison.basic.immortal.base" and LAB.SKILL_IDS[2]=="tmb.skill.poison.basic.divine.base","exact tier ids")
    check(LAB.DAMAGE_RATIOS==[1.0,1.18,1.34],"separate damage coefficients, no gameplay intervention")
    check(LAB.COOLDOWNS==[1.6,1.54,1.47],"catalogue cooldowns")
    check(LAB.RANGES==[6.0,6.24,6.42],"catalogue range")
    check(LAB.PROJECTILE_SPEEDS.size()==3 and is_equal_approx(LAB.PROJECTILE_SPEEDS[0],12.0) and is_equal_approx(LAB.PROJECTILE_SPEEDS[1],13.44) and is_equal_approx(LAB.PROJECTILE_SPEEDS[2],13.44),"catalogue speeds")
    check(LAB.CASTS==[0.0,0.0,0.0] and LAB.DURATIONS==[0.0,0.0,0.0],"no cast/status invention")
    check(LAB.tier_of(.10)==0 and LAB.tier_of(1.36)==1 and LAB.tier_of(2.62)==2,"three sequential native clips")
    for i in range(3):
        var t:float=float(i)*LAB.PER_TIER
        check(LAB.phase_at(t+.08)=="charge" and LAB.phase_at(t+.42)=="flight" and LAB.phase_at(t+.80)=="contact","phase windows "+str(i))
        check(LAB.monster_foot(t+.08).distance_to(LAB.monster_foot(t+.80))>10,"moving monster "+str(i))
        var o:=Vector2(400,330)
        var dirs:Array[Vector2]=[Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
        for d in dirs:
            var target:Vector2=o+d*200.0
            check(Vector2.RIGHT.rotated(LAB.aim_angle(o,target)).dot(d)>.9999,"aim cardinal "+str(d))
            check(LAB.flight_pos(LAB.DEMO_CONTACT,o,target).distance_to(target)<.01,"reach target")
    check(LAB.aim_angle(Vector2.ZERO,Vector2.ZERO)==0.0,"zero vector")
    var text_code:=FileAccess.get_file_as_string("res://labs/combat_lab/poison_basic_tiers_v3/poison_basic_tiers.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_status","heal_target","summon_actor"]:
        check(not text_code.contains(bad),"no gameplay or GIF "+bad)
    var total_bytes:=0
    for tier in LAB.TIER_NAMES:
        for part in [["charge",6,Vector2(768,384)],["flight",8,Vector2(1152,320)],["contact",8,Vector2(1024,512)]]:
            var path:=LAB.atlas_path(tier,part[0],part[1])
            check(ResourceLoader.exists(path),"atlas "+path)
            if not ResourceLoader.exists(path):continue
            var tex:=load(path) as Texture2D
            check(tex!=null and tex.get_size()==part[2],"geometry "+path)
            if tex==null:continue
            check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true alpha "+path)
            total_bytes+=tex.get_width()*tex.get_height()*4
    check(total_bytes<18*1024*1024,"atlas budget")
    if failures==0:
        var actor:=LAB.new()
        root.add_child(actor)
        await process_frame
        check(actor.atlas.size()==3,"9 independent tier atlas groups imported")
        actor.queue_free()
    print("VFX_POISON_BASIC_TIERS_V3_RAW_RGBA_BYTES=",total_bytes)
    print("VFX_POISON_BASIC_TIERS_V3_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
