extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman05/cuu_thien_van_loi_phu.gd")
var failures:=0
func _initialize()->void:call_deferred("_run")
func _check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL05_FAIL "+msg)
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.talisman.loi_phu.ultimate.human","canonical ultimate")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="lightning" and LAB.SHAPE=="line","line thunder")
    _check(LAB.TARGET_LIMIT==3 and LAB.TARGETS.size()==3 and LAB.CONTACTS.size()==3,"three only")
    _check(LAB.DECLARED_CAST_TIME==1.05 and LAB.DECLARED_COOLDOWN==23.0,"canonical ultimate timing")
    _check(LAB.DECLARED_RANGE==11.0 and LAB.DECLARED_PROJECTILE_SPEED==0.0,"instant line range")
    _check(LAB.SKY_FRAMES.size()==10,"original ten heavenly rune poses")
    for i in range(10):
        _check(LAB.SKY_FRAMES[i].get_size()==Vector2(512,512),"heaven pose "+str(i))
    _check(LAB.phase_at(.70)=="ritual_charge" and LAB.phase_at(1.20)=="heaven_gate","windup and gate")
    _check(LAB.phase_at(1.65)=="thunder_descent" and LAB.phase_at(2.08)=="demo_contact","one descent contact phase")
    _check(LAB.phase_at(3.22)=="dissolve" and LAB.phase_at(4.2)=="idle","fade complete")
    _check(LAB.foot_gain(.70)>.70 and LAB.foot_gain(1.60)==0.0,"ceremonial caster foot only")
    _check(LAB.sky_gain(.50)==0.0 and LAB.sky_gain(1.50)>.8 and LAB.sky_gain(3.32)==0.0,"sky seal time")
    _check(LAB.bolt_gain(1.30)==0.0 and LAB.bolt_gain(1.77)>.8 and LAB.bolt_gain(2.43)==0.0,"one authentic storm pulse")
    _check(LAB.line_sweep_gain(1.83)==0.0 and LAB.line_sweep_gain(2.04)>.6 and LAB.line_sweep_gain(2.46)==0.0,"no early lateral fake contacts")
    _check(LAB.lateral_point(1.0,2.0,0).x==747.0 and LAB.lateral_point(1.0,2.0,1).x==1151.0,"lateral lightning ends on exactly two side targets")
    _check(LAB.CONTACT_FLOOR.get_size()==Vector2(320.0,160.0),"original impact foot sigil is imported")
    _check(LAB.hit_gain(1.60,0)==0.0 and LAB.hit_gain(2.04,2)>0.0 and LAB.hit_gain(2.03,3)==0.0,"no over-cap hit")
    _check(LAB.point_on_bolt(0.0,1.75).y==74.0 and LAB.point_on_bolt(1.0,1.75).y==449.0,"visible genuine vertical shaft")
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    _check(sample._talisman!=null and sample._glow!=null,"sprite and soft alpha")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman05/cuu_thien_van_loi_phu.gd")
    for banned in ["SaveService.","CombatV2.","V63FeatureGates.","apply_damage","apply_status","summon_actor"]:
        _check(not src.contains(banned),"lab view only "+banned)
    print("VFX_TAL05_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" heaven_poses=10 cap3 view_only=true")
    sample.queue_free()
    quit(0 if failures==0 else 1)
