extends SceneTree
const LAB=preload("res://labs/combat_lab/poison16_van_linh_giai_ach/r2/van_linh_giai_ach_semantic.gd")
var failures:=0
func _initialize()->void:call_deferred("_check")
func check(ok:bool,why:String)->void:
    if not ok:
        failures+=1
        push_error("POI16_SEMANTIC_R2_FAIL "+why)
func _check()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.duoc_doc.ultimate.human","exact catalogue ID")
    check(LAB.EFFECT=="heal" and LAB.ELEMENT=="wood" and LAB.SHAPE=="circle","AOE heal ultimate, not POI15 poison")
    check(LAB.TARGET_LIMIT==3 and LAB.DECLARED_RADIUS==2.5,"circle radius world2.5 cap3")
    check(LAB.DECLARED_RANGE==6.5 and LAB.DECLARED_CAST==1.2 and LAB.DECLARED_COOLDOWN==46.0,"range cast cooldown")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0 and LAB.DECLARED_DURATION==0.0,"no invented missile or lingering heal shield")
    check(LAB.DECLARED_DAMAGE_RATIO==.05 and LAB.DECLARED_POWER==.16,"catalogue metadata, no fabricated heals")
    check(LAB.phase_at(.62)=="charge" and LAB.phase_at(1.47)=="bloom" and LAB.phase_at(1.92)=="ally_blessing" and LAB.phase_at(2.37)=="fade" and LAB.phase_at(2.85)=="idle","honest 3-clock visual phases")
    check(LAB.active_cosmetic_heal(1.92) and not LAB.active_cosmetic_heal(.99) and not LAB.active_cosmetic_heal(2.36),"one-time short heal cue, no persistent status")
    check(LAB.field_alpha(1.49)>.6 and LAB.field_alpha(2.5)==0.0,"soft bloom and finite radius")
    for t in [.62,1.48,1.92,2.42]:
        var selected:Array[int]=LAB.selected_demo_allies(t)
        check(selected.size()==3,"three moving allies within one visual AOE at "+str(t))
        check(selected.has(0) and selected.has(1) and selected.has(2) and not selected.has(3),"4th ally excluded at "+str(t))
        check(not LAB.lab_within_visual_area(LAB.ally_foot(3,t)),"4th actor truly outside area")
    for i in range(4):
        check(LAB.ally_foot(i,.50).distance_to(LAB.ally_foot(i,2.55))>10.0,"real moving ally "+str(i))
    check(LAB.monster_foot(.50).distance_to(LAB.monster_foot(2.10))>10.0,"independent moving unhealed enemy")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"monster fixture real WALK")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison16_van_linh_giai_ach/r2/van_linh_giai_ach_semantic.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status","apply_heal","heal_target","set_health","spawn_projectile","summon_actor"]:
        check(not source.contains(forbidden),"view only no real HP receipt "+forbidden)
    for index in range(3):
        var torso_gap:=LAB.ally_foot(index,1.92).y-LAB.ally_chest(index,1.92).y
        check(torso_gap>=55.0 and torso_gap<=74.0,"herbal stamp must anchor around TORSO not face or head "+str(index))
    check(LAB.semantic_phase_at(.64)=="medicine_seed","recognizable medicine seed")
    check(LAB.semantic_phase_at(1.28)=="three_leaf_herb","READABLE tripetal herbal bloom")
    check(LAB.semantic_phase_at(1.51)=="three_healing_links","real three branch transfer to ally")
    check(LAB.semantic_phase_at(1.86)=="three_herbal_seals","medicinal target identity for heal")
    check(LAB.semantic_phase_at(2.38)=="energy_dissolves" and LAB.semantic_phase_at(2.86)=="clear","not a long-lived buff")
    for t in [1.49,1.72,1.93,2.05]:
        var pts:Array[Vector2]=LAB.semantic_targets(t)
        check(pts.size()==3,"exactly THREE linked recipients at "+str(t))
        for i in range(3):
            check(pts[i].distance_to(LAB.ally_chest(i,t)+Vector2(0,-12))<.01,"link ends on continuously MOVING target chest "+str(i))
            check(LAB.link_length(i,t)>60.0 and LAB.link_length(i,t)<260.0,"clear spatial link length "+str(i))
        check(not pts.has(LAB.ally_chest(3,t)+Vector2(0,-12)),"exclude fourth moving ally")
    var semantic_source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison16_van_linh_giai_ach/r2/van_linh_giai_ach_semantic.gd")
    check(semantic_source.contains("draw_set_transform(origin,delta.angle()"),"three spatially oriented atlas-backed links")
    check(semantic_source.contains("_flip(herb_frames") and semantic_source.contains("_flip(seal_frames"),"original herb leaves and healing seals not abstract ribbons only")
    check(semantic_source.contains("ally_chest(i,t)"),"three links are target-tracked rather than screen-stationary")
    var raw:=0
    for row in [
        [LAB.ASSET_ROOT+"poi16_r2_seed_08.png",Vector2(768,384)],
        [LAB.ASSET_ROOT+"poi16_r2_herb_12.png",Vector2(1536,960)],
        [LAB.ASSET_ROOT+"poi16_r2_stream_10.png",Vector2(1536,384)],
        [LAB.ASSET_ROOT+"poi16_r2_seal_10.png",Vector2(512,384)],
        [LAB.ASSET_ROOT+"poi16_r2_fade_08.png",Vector2(1024,448)]
    ]:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"semantic RGBA atlas "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"Godot import "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"exact atlas dimensions "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true alpha raster "+path)
        raw+=tex.get_width()*tex.get_height()*4
    check(raw<14*1024*1024,"RGBA raw atlas budget under14MiB")
    if failures==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.seed_frames.size()==8 and lab.herb_frames.size()==12 and lab.stream_frames.size()==10 and lab.seal_frames.size()==10 and lab.fade_frames.size()==8,"48 semantic RGBA source poses")
        lab.queue_free()
    print("POI16_SEMANTIC_R2_RAW_RGBA_BYTES=",raw)
    print("POI16_SEMANTIC_R2_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
