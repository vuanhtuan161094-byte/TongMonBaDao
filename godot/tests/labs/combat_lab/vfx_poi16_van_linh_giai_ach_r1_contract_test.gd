extends SceneTree
const LAB=preload("res://labs/combat_lab/poison16_van_linh_giai_ach/r1/van_linh_giai_ach.gd")
var failures:=0
func _initialize()->void:call_deferred("_check")
func check(ok:bool,why:String)->void:
    if not ok:
        failures+=1
        push_error("POI16_ULTIMATE_R1_FAIL "+why)
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
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison16_van_linh_giai_ach/r1/van_linh_giai_ach.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status","apply_heal","heal_target","set_health","spawn_projectile","summon_actor"]:
        check(not source.contains(forbidden),"view only no real HP receipt "+forbidden)
    var raw:=0
    for row in [
        [LAB.ASSET_ROOT+"poi16_charge_08.png",Vector2(768,384)],
        [LAB.ASSET_ROOT+"poi16_bloom_12.png",Vector2(1536,960)],
        [LAB.ASSET_ROOT+"poi16_blessing_10.png",Vector2(768,576)],
        [LAB.ASSET_ROOT+"poi16_fade_08.png",Vector2(1024,448)]
    ]:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"source-persisted RGBA atlas "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"Godot import "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"exact dimensions "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true per-pixel alpha "+path)
        raw+=tex.get_width()*tex.get_height()*4
    check(raw<14*1024*1024,"RGBA raw atlas budget under14MiB")
    if failures==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.charge_frames.size()==8 and lab.bloom_frames.size()==12 and lab.blessing_frames.size()==10 and lab.fade_frames.size()==8,"38 authored RGBA poses")
        lab.queue_free()
    print("POI16_ULTIMATE_R1_RAW_RGBA_BYTES=",raw)
    print("POI16_VAN_LINH_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
