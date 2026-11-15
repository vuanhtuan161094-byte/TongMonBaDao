extends SceneTree
const LAB=preload("res://labs/combat_lab/fist05/dia_mach_lien_chan.gd")
var errors:=0
func _check(ok: bool,message: String)->void:
    if not ok:
        errors+=1
        push_error("VFX_FIST05_FAIL "+message)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.fist.ba_quyen.active_04.human","ID")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire","fire damage not thunder type")
    _check(LAB.SHAPE=="circle" and LAB.TARGET_LIMIT==3,"circle cap 3")
    _check(is_equal_approx(LAB.CAST_TIME,.45),"cast .45")
    _check(is_equal_approx(LAB.DECLARED_RANGE,4.0),"range 4")
    _check(is_equal_approx(LAB.PROJECTILE_SPEED,8.0),"travel 8")
    _check(is_equal_approx(LAB.DECLARED_RADIUS,3.0),"radius 3")
    _check(LAB.phase_at(.23)=="charge","charge")
    _check(LAB.phase_at(.64)=="seismic_fault_travel","rift")
    _check(LAB.phase_at(1.20)=="triple_target_eruption","contact")
    _check(LAB.phase_at(2.07)=="rubble_fade","fade")
    _check(LAB.phase_at(2.78)=="clear","clear")
    _check(LAB.TARGETS.size()==3,"exact three preview targets")
    for k in range(3):
        _check(LAB.contact_alpha(.78,k)==0.0,"no before impact "+str(k))
        _check(LAB.contact_alpha(LAB.CONTACT_TIME+.022*k+.07,k)>0.0,"hit visual bounded "+str(k))
        _check(LAB.contact_alpha(2.6,k)==0.0,"contact gone "+str(k))
        _check(LAB.target_position(k,.20)!=LAB.target_position(k,.60),"moving preview target "+str(k))
    _check(LAB.contact_alpha(1.12,3)==0.0,"no fourth hit")
    _check(LAB.CHARGE.get_size()==Vector2(1536,768),"8 charge cells")
    _check(LAB.FAULT.get_size()==Vector2(1536,1152),"12 fault cells")
    _check(LAB.ERUPTION.get_size()==Vector2(1536,1152),"12 eruption cells")
    _check(LAB.CONTACT.get_size()==Vector2(1536,768),"8 contact cells")
    var body:=FileAccess.get_file_as_string("res://labs/combat_lab/fist05/dia_mach_lien_chan.gd")
    for prohibited in ["SaveService.","CombatV2.","apply_damage","apply_status","_deal_direct","hp -=","summon_actor","MapBattleV2."]:
        _check(not body.contains(prohibited),"source view only: "+prohibited)
    var lab:=LAB.new()
    root.add_child(lab)
    await process_frame
    _check(lab.glow_tex != null,"native soft material")
    lab.queue_free()
    print("VFX_FIST05_FOCUSED_RESULT="+("PASS" if errors==0 else "FAIL")+" failures="+str(errors))
    quit(0 if errors==0 else 1)
