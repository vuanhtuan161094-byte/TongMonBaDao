extends SceneTree
const LAB=preload("res://labs/combat_lab/fist03/than_quyen.gd")
var failures:=0
func _check(ok: bool,label: String) -> void:
    if not ok:
        failures+=1
        push_error("VFX_FIST03_FAIL "+label)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    _check(LAB.DISPLAY_NAME=="Thần Quyền","concept name not canonical ID")
    _check(LAB.CANONICAL_SKILL_ID=="tmb.skill.fist.ba_quyen.ultimate.human","canonical source selected")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire","damage fire")
    _check(LAB.SHAPE=="circle" and LAB.TARGET_LIMIT==3 and LAB.DECLARED_RADIUS==3.0,"AoE radius and cap")
    _check(is_equal_approx(LAB.CAST_TIME,1.15),"cast duration")
    _check(is_equal_approx(LAB.DECLARED_RANGE,5.0),"range")
    _check(is_equal_approx(LAB.DECLARED_PROJECTILE_SPEED,8.0),"projectile speed")
    _check(LAB.VICTIMS.size()==LAB.TARGET_LIMIT,"only three illustrative victims")
    _check(LAB.CONTACT_OFFSETS.size()==LAB.TARGET_LIMIT,"one visual contact per target")
    _check(LAB.phase_at(0.1)=="gather" and LAB.phase_at(0.75)=="manifest","cast phases")
    _check(LAB.phase_at(1.34)=="spirit_fist_flight","flight")
    _check(LAB.phase_at(2.05)=="three_target_contact_and_embers","blast")
    _check(LAB.phase_at(3.00)=="clear","fade")
    for i in range(LAB.TARGET_LIMIT):
        _check(LAB.hit_flash(1.45,i)==0.0,"cannot hit before contact "+str(i))
        _check(LAB.hit_flash(LAB.HIT_TIME+LAB.CONTACT_OFFSETS[i]+0.06,i)>0.0,"target reacts after hit "+str(i))
        _check(LAB.hit_flash(2.41,i)==0.0,"reaction bounded "+str(i))
    _check(LAB.hit_flash(2.0,3)==0.0,"fourth target forbidden")
    _check(LAB.CHARGE.get_size()==Vector2(1536.0,768.0),"eight charge poses")
    _check(LAB.HERO.get_size()==Vector2(1536.0,1152.0),"twelve fist poses")
    _check(LAB.EXPLOSION.get_size()==Vector2(1536.0,1152.0),"twelve painted blast poses")
    _check(LAB.DUST.get_size()==Vector2(1536.0,768.0),"eight dust poses")
    var s:=FileAccess.get_file_as_string("res://labs/combat_lab/fist03/than_quyen.gd")
    for ban in ["SaveService.","CombatV2.","apply_damage","apply_status","_deal_direct","health -=","hp -=","summon_actor","set_hp","MapBattleV2."]:
        _check(not s.contains(ban),"source is view-only "+ban)
    var node:=LAB.new()
    root.add_child(node)
    await process_frame
    _check(node.glow_tex != null,"native soft glow")
    node.queue_free()
    print("VFX_FIST03_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)