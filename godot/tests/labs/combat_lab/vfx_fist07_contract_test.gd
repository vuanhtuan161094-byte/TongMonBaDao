extends SceneTree
const LAB = preload("res://labs/combat_lab/fist07/kim_cang_ho_the.gd")
var failures := 0
func _check(ok: bool,label: String) -> void:
    if not ok:
        failures+=1
        push_error("VFX_FIST07_FAIL "+label)
func _initialize() -> void:
    call_deferred("_test")
func _test() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.fist.kim_cang.active_02.human","skill ID")
    _check(LAB.EFFECT=="guard" and LAB.ELEMENT=="earth","guard and earth")
    _check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"single recipient")
    _check(is_equal_approx(LAB.CAST_TIME,0.45),"0.45 cast")
    _check(is_equal_approx(LAB.COOLDOWN,8.0),"8 cooldown")
    _check(is_equal_approx(LAB.DECLARED_RANGE,5.5),"catalogue range")
    _check(is_equal_approx(LAB.DECLARED_POWER,0.35),"guard power")
    _check(is_equal_approx(LAB.DECLARED_DURATION,4.0),"4s guard duration")
    _check(is_zero_approx(LAB.PROJECTILE_SPEED),"no projectile")
    _check(LAB.phase_at(0.22)=="ward_manifest","casting")
    _check(LAB.phase_at(0.83)=="guard_active","guard after cast")
    _check(LAB.phase_at(4.63)=="ward_dissolve","correct fade")
    _check(LAB.phase_at(4.95)=="clear","fully clear")
    _check(is_zero_approx(LAB.guard_alpha(0.3)),"no pre-cast shield")
    _check(LAB.guard_alpha(0.8)>0.99 and LAB.guard_alpha(4.3)>0.99,"sustain 4s")
    _check(is_zero_approx(LAB.guard_alpha(5.0)),"clears after fade")
    _check(is_zero_approx(LAB.block_alpha(0.70,0.30)),"reject block outside guard")
    _check(is_zero_approx(LAB.block_alpha(4.55,4.53)),"block after guard rejected")
    _check(LAB.block_alpha(1.32,1.29)>0.1,"guarded-hit event has response")
    _check(is_zero_approx(LAB.block_alpha(1.90,1.29)),"no permanent block")
    _check(LAB.DEMO_BLOCK_TIMES.size()==2,"2 explicitly demo-only block events")
    _check(LAB.ATLAS_RAW_RGBA_BYTES==8650752,"8.25 MiB two source atlases (uncompressed)")
    _check(LAB.WARD.get_size()==Vector2(1280,1280),"owner illustrated 16 ward poses")
    _check(LAB.BLOCK.get_size()==Vector2(1024,512),"guard reaction 8 independent poses")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/fist07/kim_cang_ho_the.gd")
    for forbidden in ["draw_arc(","draw_line(","draw_circle(","_glow(","Image.create("]:
        _check(not source.contains(forbidden),"no procedural line art: "+forbidden)
    _check(source.contains("_ward_front_foot"),"actual painted lotus/ground art in front")
    _check(source.contains("owner_illustrated_reference"),"provenance for painted hero")
    for forbidden in ["SaveService.","CombatV2.","apply_damage", "apply_status", "MapBattleV2.","summon_actor", "caster_shift", "_actor(CASTER +"]:
        _check(not source.contains(forbidden),"view only "+forbidden)
    var scene:=LAB.new()
    root.add_child(scene)
    await process_frame
    _check(scene.ART_REVISION=="R4_OWNER_REFERENCE_SOFT_MATTE","art-first reference revision")
    scene.queue_free()
    print("VFX_FIST07_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
