extends SceneTree
const LAB=preload("res://labs/combat_lab/poison17_yem_anh_bo/r1/yem_anh_bo.gd")
var failures:=0
func _initialize()->void:call_deferred("_check")
func check(ok:bool,why:String)->void:
    if not ok:
        failures+=1
        push_error("POI17_MOBILITY_R1_FAIL "+why)
func _check()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.mobility.human","canonical skill id")
    check(LAB.EFFECT=="mobility" and LAB.ELEMENT=="metal" and LAB.SHAPE=="single_target","real MOBILITY not poison attack")
    check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_RANGE==11.0,"self mobility target1 range11 world units")
    check(LAB.DECLARED_CAST==.1 and LAB.DECLARED_COOLDOWN==10.0 and LAB.DECLARED_DURATION==1.0,"true cast.1 cooldown10 duration1")
    check(LAB.DECLARED_PROJECTILE_SPEED==0.0 and LAB.DECLARED_POISON_STACKS==0,"no fake projectile or poison")
    check(LAB.DECLARED_DAMAGE_RATIO==.05 and LAB.DECLARED_POWER==0.0,"source metadata NOT real damage")
    check(LAB.visual_phase(.05)=="gather_footprint","recognizable pre-step")
    check(LAB.visual_phase(.57)=="step_afterimages","step follows real caster trajectory")
    check(LAB.visual_phase(1.13)=="landing_shadow_seal","arrival no enemy contact")
    check(LAB.visual_phase(1.73)=="clear","finite sprite aftermath")
    check(not LAB.demo_mobility_active(.09) and LAB.demo_mobility_active(.10) and LAB.demo_mobility_active(1.08) and not LAB.demo_mobility_active(1.13),"duration strictly one second")
    check(LAB.caster_foot(.05).distance_to(LAB.START_FOOT)<.001,"begin START_FOOT")
    check(LAB.caster_foot(1.14).distance_to(LAB.END_FOOT)<.001,"end END_FOOT")
    check(LAB.caster_foot(.52).distance_to(LAB.caster_foot(.25))>70.0,"continuous legible non-teleport motion")
    for t in [.31,.51,.72,.95]:
        var q:float=LAB.motion_fraction(t)
        check(q>0.0 and q<1.0,"mobility sprite is NOT a teleport "+str(t))
        var history:Array[Vector2]=LAB.step_history(t)
        check(history.size()>=2,"at least 2 history afterimages "+str(t))
        check(not LAB.has_damage_receipt(t),"ZERO fabricated enemy hit receipts")
    check(LAB.moving_monster_foot(.4).distance_to(LAB.moving_monster_foot(1.52))>10.0,"unaffected monster is really WALKING")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"real WALK animated actor")
    var s:=FileAccess.get_file_as_string("res://labs/combat_lab/poison17_yem_anh_bo/r1/yem_anh_bo.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_poison","apply_status","set_health","spawn_projectile","teleport_actor","stealth_invulnerable"]:
        check(not s.contains(forbidden),"no unauthorized actual PvE or false status "+forbidden)
    check(s.contains("_draw_disciple(hist[k],Color("),"approved source actor at real historical steps")
    check(s.contains("_pose(footprint_frames"),"readable original RGBA footprints are key semantic art")
    check(s.contains("_pose(stride_frames"),"speed wake original RGBA")
    var raw:=0
    for row in [
        [LAB.ASSET_ROOT+"poi17_gather_08.png",Vector2(1024,448)],
        [LAB.ASSET_ROOT+"poi17_stride_12.png",Vector2(1280,480)],
        [LAB.ASSET_ROOT+"poi17_footprint_12.png",Vector2(1024,576)],
        [LAB.ASSET_ROOT+"poi17_landing_08.png",Vector2(1024,448)]
    ]:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"original atlas persists "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"Godot import atlas "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"exact atlas dimensions "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true source alpha "+path)
        raw+=tex.get_width()*tex.get_height()*4
    check(raw<12*1024*1024,"source RGBA budget 12MiB")
    if failures==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.gather_frames.size()==8 and lab.stride_frames.size()==12 and lab.footprint_frames.size()==12 and lab.landing_frames.size()==8,"40 original frame-by-frame poses")
        lab.queue_free()
    print("POI17_MOBILITY_R1_RAW_RGBA_BYTES=",raw)
    print("POI17_MOBILITY_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
