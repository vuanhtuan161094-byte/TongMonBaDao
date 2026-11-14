extends SceneTree
const LAB=preload("res://labs/combat_lab/fist04/lei_dinh_chan_quyen.gd")
var fail:=0
func _check(ok: bool,why: String) -> void:
    if not ok:
        fail+=1
        push_error("VFX_FIST04_FAIL "+why)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    _check(LAB.SKILL_ID=="tmb.skill.fist.ba_quyen.active_03.human","canonical skill")
    _check(LAB.ART_REVISION=="V3_CONTENT_ALPHA_FEATHER","V3 content-aware alpha")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire","fire damage not fake lightning gameplay")
    _check(LAB.SHAPE=="circle" and LAB.TARGET_LIMIT==3 and is_equal_approx(LAB.DECLARED_RADIUS,3.0),"AoE cap radius")
    _check(is_equal_approx(LAB.CAST_TIME,.45),"cast time")
    _check(is_equal_approx(LAB.DECLARED_RANGE,4.0),"range")
    _check(is_equal_approx(LAB.DECLARED_PROJECTILE_SPEED,8.0),"projectile speed")
    _check(LAB.VICTIMS.size()==LAB.TARGET_LIMIT,"three illustrative targets")
    _check(LAB.CONTACT_OFFSETS.size()==LAB.TARGET_LIMIT,"three bounded visual reactions")
    _check(LAB.phase_at(.3)=="gather" and LAB.phase_at(.7)=="thunder_release","gather release")
    _check(LAB.phase_at(1.5)=="circle_contact" and LAB.phase_at(2.5)=="clear","blast and full clear")
    for i in range(LAB.TARGET_LIMIT):
        _check(LAB.hit_alpha(.9,i)==0.0,"no hit before contact")
        _check(LAB.hit_alpha(LAB.HIT_TIME+LAB.CONTACT_OFFSETS[i]+.06,i)>.2,"hit reaction after contact")
        _check(LAB.hit_alpha(1.7,i)==0.0,"hit reaction bounded")
    _check(LAB.hit_alpha(1.3,3)==0.0,"no fourth target")
    _check(LAB.CHARGE.get_size()==Vector2(1536,768),"8 charge frames")
    _check(LAB.HERO.get_size()==Vector2(1536,1152),"12 travel frames")
    _check(LAB.IMPACT.get_size()==Vector2(1536,1152),"12 impact frames")
    _check(LAB.GRIT.get_size()==Vector2(1536,768),"8 grit frames")
    var s:=FileAccess.get_file_as_string("res://labs/combat_lab/fist04/lei_dinh_chan_quyen.gd")
    for ban in ["SaveService.","CombatV2.","apply_damage","apply_status","_deal_direct","hp -=","MapBattleV2.","summon_actor"]:
        _check(not s.contains(ban),"view-only "+ban)
    var obj:=LAB.new()
    root.add_child(obj)
    await process_frame
    _check(obj.soft_tex!=null,"native soft alpha")
    obj.queue_free()
    print("VFX_FIST04_FOCUSED_RESULT="+("PASS" if fail==0 else "FAIL")+" failures="+str(fail))
    quit(0 if fail==0 else 1)