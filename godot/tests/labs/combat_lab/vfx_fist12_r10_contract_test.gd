extends SceneTree
const LAB=preload("res://labs/combat_lab/fist12/r10/doan_mach_lien_quyen_r10.gd")
var failures:=0
func check(ok:bool,label:String)->void:
    if not ok:
        failures+=1
        push_error("FIST12_R10_FAIL "+label)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.fist.huyet_quyen.active_02.human","canonical skill")
    check(LAB.EFFECT=="mark" and LAB.ELEMENT=="nether","effect")
    check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"target cap")
    check(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8),"cast")
    check(is_equal_approx(LAB.DECLARED_DURATION,6.0),"6s status")
    check(is_zero_approx(LAB.DECLARED_PROJECTILE_SPEED) and is_zero_approx(LAB.DECLARED_RADIUS),"no projectile AOE")
    check(is_equal_approx(LAB.MARK_END-LAB.MARK_START,6),"single mark duration")
    check(LAB.phase_at(.22)=="compressed_hand_qi" and LAB.phase_at(.74)=="three_directional_punch_accents","phases")
    check(LAB.phase_at(.99)=="one_local_mark_contact" and LAB.phase_at(4.0)=="one_mark_six_seconds","contact and status")
    check(LAB.phase_at(7.10)=="mark_fade" and LAB.phase_at(7.40)=="idle","fade")
    check(LAB.beat_at(.52)==0 and LAB.beat_at(.70)==1 and LAB.beat_at(.84)==2,"three art-only distinct beats")
    check(LAB.beat_position(.55).distance_to(LAB.beat_position(.72))>8,"actual moving accent")
    check(LAB.mark_at(0,3.6).distance_to(LAB.mark_at(0,.92))>5,"target follows after mark")
    check(LAB.mark_at(0,2.7).y>LAB.foe_at(2.7).y-83,"mark below target face")
    check(LAB.mark_at(0,2.7).y<LAB.foe_at(2.7).y-49,"mark upper torso")
    check(LAB.target_position(1,.93)==Vector2(-10000,-10000),"one target")
    check(LAB.mark_alpha(.6)==0 and LAB.mark_alpha(4.1)>.95 and LAB.mark_alpha(7.27)==0,"alpha gates")
    check(LAB.CHARGE.get_size()==Vector2(1280,640),"charge atlas")
    check(LAB.WAVE.get_size()==Vector2(1280,1920),"three painterly punch atlases")
    check(LAB.CONTACT.get_size()==Vector2(1280,640),"contact atlas")
    check(LAB.MARK.get_size()==Vector2(1280,640),"mark atlas")
    check(LAB.ATLAS_RAW_RGBA_BYTES==19660800,"raw texture budget")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist12/r10/doan_mach_lien_quyen_r10.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_heal","apply_status"]:
        check(not src.contains(forbidden),"view-only "+forbidden)
    var node=LAB.new()
    root.add_child(node)
    await process_frame
    node.queue_free()
    print("VFX_FIST12_R10_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
