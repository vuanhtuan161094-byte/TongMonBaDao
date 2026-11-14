extends SceneTree
const LAB=preload("res://labs/combat_lab/fist02/phi_than_lien_cuoc.gd")
var failed:=0
func _check(ok: bool, why: String) -> void:
    if not ok:
        failed+=1
        push_error("VFX_FIST02_FAIL "+why)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.fist.ba_quyen.active_02.human","ID")
    _check(LAB.EFFECT=="guard" and LAB.ELEMENT=="fire","guard fire")
    _check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"no fake AoE")
    _check(is_equal_approx(LAB.CAST_TIME,0.45),"0.45 cast")
    _check(is_equal_approx(LAB.DECLARED_RANGE,5.5),"range")
    _check(is_equal_approx(LAB.DECLARED_POWER,0.35),"power")
    _check(is_equal_approx(LAB.DECLARED_DURATION,4.0),"4-second guard")
    _check(LAB.PROJECTILE_SPEED==0.0,"no attack bolt")
    _check(LAB.phase_at(0.13)=="kick_one","first step")
    _check(LAB.phase_at(0.33)=="kick_two","second step")
    _check(LAB.phase_at(0.88)=="guard","defense")
    _check(LAB.phase_at(4.70)=="dissolve","end guard")
    _check(LAB.phase_at(5.15)=="idle","clear")
    _check(LAB.guard_strength(0.3)==0.0 and LAB.guard_strength(0.8)>0.99,"guard starts after cast")
    _check(LAB.guard_strength(4.35)>0.99 and LAB.guard_strength(5.0)==0.0,"guard duration")
    _check(LAB.HEELS.get_size()==Vector2(1280,960),"12 painted heel frames")
    _check(LAB.SHIELD.get_size()==Vector2(1280,640),"8 guard frames")
    _check(LAB.DUST.get_size()==Vector2(1280,640),"8 footfall frames")
    var text:=FileAccess.get_file_as_string("res://labs/combat_lab/fist02/phi_than_lien_cuoc.gd")
    for banned in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","summon_actor"]:
        _check(not text.contains(banned),"view only "+banned)
    var obj:=LAB.new()
    root.add_child(obj)
    await process_frame
    _check(obj.glow_tex != null,"softlight loaded")
    print("VFX_FIST02_FOCUSED_RESULT="+("PASS" if failed==0 else "FAIL")+" failures="+str(failed))
    obj.queue_free()
    quit(0 if failed==0 else 1)
