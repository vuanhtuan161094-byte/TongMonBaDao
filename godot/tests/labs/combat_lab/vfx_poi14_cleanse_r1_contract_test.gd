extends SceneTree
const LAB=preload("res://labs/combat_lab/poison14_cleanse/r1/nghich_doc_phan_che.gd")
var failures:=0
func _initialize()->void:call_deferred("_check_all")
func check(ok:bool,why:String)->void:
    if not ok:
        failures+=1
        push_error("POI14_CLEANSE_R1_FAIL "+why)
func _check_all()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.duoc_doc.active_03.human","exact catalogue ID")
    check(LAB.EFFECT=="cleanse" and LAB.ELEMENT=="wood" and LAB.SHAPE=="single_target","cleanse not heal or poison")
    check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_DURATION==0.0,"one instant cleanse, no lasting status")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0,"no invented projectile")
    check(LAB.DECLARED_CAST==.55 and LAB.DECLARED_COOLDOWN==18.0 and LAB.DECLARED_RANGE==6.5,"cast cooldown range")
    check(LAB.DECLARED_DAMAGE_RATIO==.05,"not damage or healing receipt")
    check(LAB.phase_at(.28)=="charge" and LAB.phase_at(.82)=="reverse_cleanse" and LAB.phase_at(1.20)=="purge_remnants" and LAB.phase_at(1.75)=="idle","original cleanse storyboard")
    check(LAB.impurity_fraction(.55)>.99 and LAB.impurity_fraction(1.70)==0.0,"violet contamination only REMOVED")
    check(LAB.energy_fade(.75)>.60 and LAB.energy_fade(1.70)==0.0,"light finite and soft")
    check(LAB.ally_foot(.28).distance_to(LAB.ally_foot(1.20))>10.0,"moving allied target")
    check(LAB.ally_chest(.55).distance_to(LAB.ally_chest(1.20))>5.0,"actual moving torso target")
    check(LAB.monster_foot(.28).distance_to(LAB.monster_foot(1.20))>10.0,"independent moving monster")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"true WALK frames")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison14_cleanse/r1/nghich_doc_phan_che.gd")
    for blocked in ["SaveService.","CombatV2.","apply_damage","apply_status","apply_heal","heal_target","remove_status","set_health","summon_actor","spawn_projectile"]:
        check(not source.contains(blocked),"visual only, no real cleanse "+blocked)
    var specs=[
        [LAB.ASSET_ROOT+"poi14_charge_08.png",Vector2(768,384)],
        [LAB.ASSET_ROOT+"poi14_sever_12.png",Vector2(1024,768)],
        [LAB.ASSET_ROOT+"poi14_purge_10.png",Vector2(1024,768)]
    ]
    var raw:=0
    for spec in specs:
        var path:String=spec[0]
        check(ResourceLoader.exists(path),"original sprite "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"Godot import "+path)
        if tex==null:continue
        check(tex.get_size()==spec[1],"RGBA atlas dimension "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true RGBA alpha "+path)
        raw+=tex.get_width()*tex.get_height()*4
    check(raw<9*1024*1024,"VFX under 9MiB raw alpha atlas budget")
    if failures==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.charge_frames.size()==8 and lab.sever_frames.size()==12 and lab.purge_frames.size()==10,"30 distinct alpha poses")
        lab.queue_free()
    print("POI14_CLEANSE_R1_RAW_RGBA=",raw)
    print("POI14_CLEANSE_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
