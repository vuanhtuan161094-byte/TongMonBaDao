extends SceneTree
const LAB = preload("res://labs/combat_lab/fist02/phi_than_lien_cuoc.gd")
var errors := 0
func _check(valid: bool, why: String) -> void:
    if not valid:
        errors += 1
        push_error("VFX_FIST02_FAIL " + why)
func _initialize() -> void:
    call_deferred("_test")
func _test() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.fist.ba_quyen.active_02.human","canonical skill")
    _check(LAB.REVISION=="V4_IMAGEGEN_SPRITE_FIRST_GUARD","V4 new art source")
    _check(LAB.EFFECT=="guard" and LAB.ELEMENT=="fire","guard/fire no damage")
    _check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"one recipient only")
    _check(is_equal_approx(LAB.CAST_TIME,0.45),"catalogue 0.45 cast")
    _check(is_equal_approx(LAB.DECLARED_RANGE,5.5),"catalogue range")
    _check(is_equal_approx(LAB.DECLARED_POWER,0.35),"catalogue guard power")
    _check(is_equal_approx(LAB.DECLARED_DURATION,4.0),"catalogue duration 4.0s")
    _check(is_zero_approx(LAB.PROJECTILE_SPEED),"no projectile")
    _check(LAB.phase_at(0.05)=="gather","precast")
    _check(LAB.phase_at(0.24)=="manifest","spirit manifest not physical kick")
    _check(LAB.phase_at(0.8)=="spirit_guard","protective effect")
    _check(LAB.phase_at(4.70)=="dissolve","guard fade")
    _check(LAB.phase_at(5.16)=="idle","clear")
    _check(LAB.guard_strength(0.3)==0.0 and LAB.guard_strength(0.8)>0.99,"guard after cast only")
    _check(LAB.guard_strength(4.34)>0.99 and LAB.guard_strength(4.96)==0.0,"4s sustain and end")
    _check(LAB.summon_strength(0.20)>0.0 and LAB.summon_strength(1.1)==0.0,
        "one 0.45s painted cast without repeated fake kicks")
    _check(LAB.SPIRIT_CAST.get_size()==Vector2(1280,960),"original 12 cast poses")
    _check(LAB.SPIRIT_GUARD.get_size()==Vector2(1280,640),"8 guard poses")
    _check(LAB.ASH.get_size()==Vector2(1280,640),"8 debris poses")
    var code := FileAccess.get_file_as_string("res://labs/combat_lab/fist02/phi_than_lien_cuoc.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status",
            "MapBattleV2.","summon_actor","caster_shift","_actor(CASTER +"]:
        _check(not code.contains(forbidden),"view-only / static actor: "+forbidden)
    var instance := LAB.new()
    root.add_child(instance)
    await process_frame
    _check(instance.glow_tex != null,"soft glow generated")
    print("VFX_FIST02_FOCUSED_RESULT="+("PASS" if errors==0 else "FAIL")+
        " failures="+str(errors))
    instance.queue_free()
    quit(0 if errors==0 else 1)
