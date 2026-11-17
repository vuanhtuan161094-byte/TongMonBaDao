extends SceneTree
const LAB=preload("res://labs/combat_lab/poison13_heal_heart/r2/giai_doc_ho_tam_energy.gd")
var errors:=0
func _initialize()->void:call_deferred("_check_all")
func ck(ok:bool,reason:String)->void:
    if not ok:
        errors+=1
        push_error("POI13_R2_FAIL "+reason)
func _check_all()->void:
    ck(LAB.SKILL_ID=="tmb.skill.poison.duoc_doc.active_02.human","canonical skill")
    ck(LAB.EFFECT=="heal" and LAB.ELEMENT=="wood" and LAB.SHAPE=="single_target","true one-ally wood heal")
    ck(LAB.TARGET_LIMIT==1 and LAB.DECLARED_DURATION==0.0,"not fake 8s status")
    ck(LAB.DECLARED_PROJECTILE_SPEED==0.0,"no projectile")
    ck(LAB.DECLARED_CAST==.55 and LAB.DECLARED_COOLDOWN==18.0 and LAB.DECLARED_RANGE==6.5,"cast cooldown range")
    ck(LAB.DECLARED_DAMAGE_RATIO==.05,"do not infer HP quantity")
    ck(LAB.phase_at(.28)=="charge" and LAB.phase_at(.82)=="heart_energy" and LAB.phase_at(1.20)=="rising_soft_energy" and LAB.phase_at(1.75)=="idle","three visual phases")
    ck(LAB.energy_fade(.75)>.60 and LAB.energy_fade(1.70)==0.0,"temporary cosmetic energy only")
    ck(LAB.ally_foot(.28).distance_to(LAB.ally_foot(1.20))>10.0,"ally moves")
    ck(LAB.ally_chest(.55).distance_to(LAB.ally_chest(1.20))>5.0,"energy tracks moving chest")
    ck(LAB.monster_foot(.28).distance_to(LAB.monster_foot(1.20))>10.0,"monster also WALKS, but is not target")
    ck(LAB.MONSTER_FRAMES.has_animation("walk"),"real WALK actor")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison13_heal_heart/r2/giai_doc_ho_tam_energy.gd")
    for prohibited in ["SaveService.","CombatV2.","apply_damage","apply_status","apply_heal","heal_target","set_health","summon_actor","spawn_projectile"]:
        ck(not source.contains(prohibited),"visual LAB only "+prohibited)
    var rows=[
        [LAB.ASSET_ROOT+"poi13_r2_charge_08.png",Vector2(768,384)],
        [LAB.ASSET_ROOT+"poi13_r2_aura_12.png",Vector2(1024,768)],
        [LAB.ASSET_ROOT+"poi13_r2_release_10.png",Vector2(1024,768)]
    ]
    var raw:=0
    for row in rows:
        var path:String=row[0]
        ck(ResourceLoader.exists(path),"atlas "+path)
        if not ResourceLoader.exists(path):continue
        var atlas:=load(path) as Texture2D
        ck(atlas!=null,"import "+path)
        if atlas==null:continue
        ck(atlas.get_size()==row[1],"atlas dimensions "+path)
        ck(atlas.get_image().detect_alpha()!=Image.ALPHA_NONE,"transparent "+path)
        raw+=atlas.get_width()*atlas.get_height()*4
    ck(raw<9*1024*1024,"under raw 9MiB RGBA8")
    if errors==0:
        var scene:=LAB.new()
        root.add_child(scene)
        await process_frame
        ck(scene.charge_frames.size()==8 and scene.aura_frames.size()==12 and scene.release_frames.size()==10,"30 original RGBA pose textures imported")
        scene.queue_free()
    print("POI13_R2_RGBA_RAW_BYTES=",raw)
    print("POI13_ENERGY_R2_RESULT=",("PASS" if errors==0 else "FAIL")," failures=",errors)
    quit(0 if errors==0 else 1)
