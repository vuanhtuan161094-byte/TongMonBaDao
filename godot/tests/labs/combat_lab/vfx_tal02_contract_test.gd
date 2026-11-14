extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman02/thien_loi_dan_net.gd")
var failures:=0
func _initialize()->void: call_deferred("_run")
func _check(ok:bool,reason:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL02_FAIL "+reason)
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.talisman.loi_phu.active_02.human","canonical cast ID")
    _check(LAB.SHAPE=="line" and LAB.EFFECT=="damage" and LAB.ELEMENT=="lightning","exact line lightning damage")
    _check(LAB.TARGET_LIMIT==3 and LAB.TARGETS.size()==3 and LAB.CONTACTS.size()==3,"cap three")
    _check(LAB.DECLARED_CAST_TIME==0.62 and LAB.DECLARED_COOLDOWN==10.8,"source timing")
    _check(LAB.DECLARED_RANGE==9.5 and LAB.DECLARED_PROJECTILE_SPEED==0.0,"line no projectile")
    _check(LAB.STROKES.size()==10,"ten independently drawn ink poses")
    for i in range(10):
        _check(LAB.STROKES[i].get_size()==Vector2(1024.0,256.0),"stroke art size "+str(i))
    _check(LAB.phase_at(.3)=="inscribe" and LAB.phase_at(.9)=="draw_line","staging")
    _check(LAB.phase_at(1.47)=="demo_contact" and LAB.phase_at(2.10)=="dissolve","contact & decay")
    _check(LAB.stroke_index(.2)==-1 and LAB.stroke_index(1.43)==9 and LAB.stroke_index(2.3)==-1,"ink-reveal bounded")
    _check(LAB.line_point(0.0,1.0).x==398.0 and LAB.line_point(1.0,1.0).x==1133.0,"real connected line endpoints")
    _check(LAB.line_point(.60,1.0).x>LAB.line_point(.40,1.0).x,"line does not loop backward")
    _check(LAB.foot_gain(.07)==0.0 and LAB.foot_gain(.48)>0.6 and LAB.foot_gain(1.14)==0.0,"cast-only underfoot array")
    _check(LAB.contact_gain(1.1,0)==0.0 and LAB.contact_gain(1.50,0)>0.0,"never fake early impact")
    _check(LAB.contact_gain(1.45,2)==0.0 and LAB.contact_gain(1.59,2)>0.0,"staggered three only")
    _check(LAB.contact_gain(1.5,3)==0.0,"over-cap cannot contact")
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    _check(sample._seal!=null and sample._halo_texture!=null,"real painted sprite and radial alpha")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman02/thien_loi_dan_net.gd")
    for banned in ["SaveService.","CombatV2.","V63FeatureGates.","apply_damage","apply_status","summon_actor"]:
        _check(not src.contains(banned),"lab view-only "+banned)
    print("VFX_TAL02_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" poses=10 cap3 view_only=true")
    sample.queue_free()
    quit(0 if failures==0 else 1)
