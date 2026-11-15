extends SceneTree
const LAB = preload("res://labs/combat_lab/fist06/tran_dia_quyen.gd")
var failures:=0
func _check(ok: bool,why: String) -> void:
    if not ok:
        failures+=1
        push_error("VFX_FIST06_FAIL "+why)
func _initialize() -> void:
    call_deferred("_check_lab")
func _check_lab() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.fist.kim_cang.active_01.human","canonical ID")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="earth","damage earth")
    _check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"no fake AoE")
    _check(is_equal_approx(LAB.CAST_TIME,.45),"cast")
    _check(is_equal_approx(LAB.COOLDOWN,8.0),"cooldown")
    _check(is_equal_approx(LAB.DECLARED_RANGE,2.8),"range")
    _check(is_equal_approx(LAB.PROJECTILE_SPEED,8.0),"projectile speed")
    _check(is_equal_approx(LAB.DAMAGE_RATIO,1.35),"damage metadata read-only")
    _check(LAB.phase_at(.2)=="charge","charge")
    _check(LAB.phase_at(.54)=="earth_fist_travel","travel")
    _check(LAB.phase_at(.76)=="single_target_contact","hit")
    _check(LAB.phase_at(1.17)=="dust_settle","fade")
    _check(LAB.phase_at(1.33)=="clear","reset")
    _check(LAB.contact_alpha(.63)==0.0 and LAB.contact_alpha(.78)>.0,"one actual event cue")
    _check(LAB.contact_alpha(1.2)==0.0,"no persistent hit")
    _check(LAB.target_position(.4)!=LAB.target_position(.8),"moving target")
    _check(LAB.recoil(.62)==0.0 and LAB.recoil(.80)>0.0,"target recoils")
    _check(LAB.HERO.get_size()==Vector2(1024,1024),"16 main atlas poses")
    _check(LAB.HIT.get_size()==Vector2(1024,512),"8 hit atlas poses")
    _check(LAB.ATLAS_RAW_RGBA_BYTES==6291456,"6MiB raw RGBA budget")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/fist06/tran_dia_quyen.gd")
    for banned in ["SaveService.","CombatV2.","apply_damage","apply_status","hp -=","summon_actor","MapBattleV2."]:
        _check(not source.contains(banned),"view only "+banned)
    var instance:=LAB.new()
    root.add_child(instance)
    await process_frame
    _check(instance.glow_tex != null,"softlight texture exists")
    instance.queue_free()
    print("VFX_FIST06_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
