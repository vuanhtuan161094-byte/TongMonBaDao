extends SceneTree
const LAB=preload("res://labs/combat_lab/poison13_heal_heart/r1/giai_doc_ho_tam.gd")
var failures:=0
func _initialize()->void:call_deferred("_run")
func check(ok:bool,s:String)->void:
    if not ok:
        failures+=1
        push_error("POI13_HEART_R1_FAIL "+s)
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.duoc_doc.active_02.human","canonical POI13 ID")
    check(LAB.EFFECT=="heal" and LAB.ELEMENT=="wood" and LAB.SHAPE=="single_target","heal wood one target")
    check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_DURATION==0.0,"one instant ally heal, no buff")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0,"no invented homing projectile")
    check(LAB.DECLARED_CAST==.55 and LAB.DECLARED_COOLDOWN==18.0 and LAB.DECLARED_RANGE==6.5,"canonical cast cooldown range")
    check(LAB.DECLARED_DAMAGE_RATIO==.05,"canonical value retained, NOT assumed HP amount")
    check(LAB.phase_at(.30)=="charge" and LAB.phase_at(.80)=="heart_light" and LAB.phase_at(1.20)=="release" and LAB.phase_at(1.75)=="idle","charge/heart/release")
    check(LAB.alpha_at(.80)>.70 and LAB.alpha_at(1.8)==0.0,"local light and expiry; not a lasting guard")
    check(LAB.ally_foot(.30).distance_to(LAB.ally_foot(1.20))>10.0,"ally really MOVES")
    check(LAB.monster_foot(.30).distance_to(LAB.monster_foot(1.20))>10.0,"monster really MOVES but not healed")
    check(LAB.ally_chest(.55).distance_to(LAB.ally_chest(1.20))>5.0,"target chest anchor follows motion")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"actual animated WALK monster")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison13_heal_heart/r1/giai_doc_ho_tam.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_status","apply_heal","heal_target","set_health","spawn_projectile","summon_actor"]:
        check(not src.contains(bad),"view-only, not live gameplay "+bad)
    var specs=[
        [LAB.ASSET_ROOT+"poi13_charge_08.png",Vector2(768,384)],
        [LAB.ASSET_ROOT+"poi13_heart_10.png",Vector2(1024,768)],
        [LAB.ASSET_ROOT+"poi13_release_08.png",Vector2(1024,512)]
    ]
    var rgba:=0
    for spec in specs:
        var path:String=spec[0]
        check(ResourceLoader.exists(path),"transparent atlas "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"Godot imported RGBA "+path)
        if tex==null:continue
        check(tex.get_size()==spec[1],"correct atlas geometry "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true alpha "+path)
        rgba+=tex.get_width()*tex.get_height()*4
    check(rgba<9*1024*1024,"under 9 MiB uncompressed three atlases")
    if failures==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.charge_frames.size()==8 and lab.heart_frames.size()==10 and lab.release_frames.size()==8,"26 authored source poses")
        lab.queue_free()
    print("POI13_HEART_R1_RAW_RGBA_BYTES=",rgba)
    print("POI13_HEART_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
