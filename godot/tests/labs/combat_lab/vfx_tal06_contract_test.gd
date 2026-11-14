extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman06/xich_diem_khai_van.gd")
var failures:=0
func check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL06_FAIL "+msg)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.hoa_phu.active_01.human","canonical ID")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire" and LAB.SHAPE=="single_target","fire damage single target")
    check(LAB.TARGET_LIMIT==1 and LAB.DECLARED_PROJECTILE_SPEED==8.5,"source projectile cap and speed")
    check(LAB.DECLARED_CAST_TIME==.50 and LAB.DECLARED_COOLDOWN==9.4 and LAB.DECLARED_RANGE==8.5,"canonical timing")
    check(LAB.SEAL.get_size()==Vector2(1024,768),"twelve original seal frames")
    check(LAB.COMET.get_size()==Vector2(1536,672),"twelve painted fire comet frames")
    check(LAB.IMPACT.get_size()==Vector2(1152,448),"eight original contact frames")
    check(LAB.FOOT.get_size()==Vector2(256,128),"independent smaller foot sign")
    check(LAB.MONSTER_FRAMES.has_animation("walk") and LAB.MONSTER_FRAMES.get_frame_count("walk")>=8,"true monster animation frames")
    check(LAB.phase_at(.30)=="charge" and LAB.phase_at(.90)=="projectile" and LAB.phase_at(1.49)=="demo_hit","phase choreography")
    check(LAB.phase_at(2.1)=="embers_fade" and LAB.phase_at(3.0)=="idle","no fake persistent burn")
    check(LAB.projectile_pos(.64)==LAB.HAND,"caster palm origin")
    check(LAB.target_foot(.55).distance_to(LAB.target_foot(1.46))>20,"monster genuinely moves during flight")
    check(LAB.target_contact(1.46).distance_to(LAB.target_foot(1.46)+Vector2(-6,-82))<.001,"contact follows same moving actor")
    check(LAB.projectile_pos(LAB.DEMO_HIT_AT).distance_to(LAB.target_contact(LAB.DEMO_HIT_AT))<.001,"visual head reaches live target")
    check(LAB.hit_gain(1.2)==0 and LAB.hit_gain(1.50)>.6 and LAB.hit_gain(1.81)==0,"one bounded visual contact")
    check(LAB.scorch_gain(2.25)>0 and LAB.scorch_gain(2.67)==0,"ground scorch dissipates")
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    check(sample._glow!=null,"glow assists painterly RGBA")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman06/xich_diem_khai_van.gd")
    for bad in ["SaveService.","CombatV2.","V63FeatureGates.","apply_damage","apply_status","summon_actor","add_burn"]:
        check(not src.contains(bad),"view only "+bad)
    print("VFX_TAL06_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" cap1 true_frames_12_12_8 moving_monster=true")
    sample.queue_free()
    quit(0 if failures==0 else 1)
