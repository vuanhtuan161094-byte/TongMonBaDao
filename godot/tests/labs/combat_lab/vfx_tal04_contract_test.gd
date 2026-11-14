extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman04/cuu_tieu_pha_van.gd")
var failures:=0
func _initialize()->void:call_deferred("_run")
func _check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL04_FAIL "+msg)
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.talisman.loi_phu.active_04.human","correct ID")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="lightning" and LAB.SHAPE=="line","line lightning damage")
    _check(LAB.TARGET_LIMIT==2 and LAB.TARGETS.size()==2 and LAB.CONTACTS.size()==2,"exact two target cap")
    _check(LAB.DECLARED_CAST_TIME==.50 and LAB.DECLARED_COOLDOWN==13.6,"source cooldown and cast")
    _check(LAB.DECLARED_RANGE==9.0 and LAB.DECLARED_PROJECTILE_SPEED==0.0,"line instant")
    _check(LAB.CLOUD_POSES.size()==10,"original ten animated cloud poses")
    for i in range(10):
        _check(LAB.CLOUD_POSES[i].get_size()==Vector2(1024,300),"cloud sprite size "+str(i))
    _check(LAB.phase_at(.40)=="gather" and LAB.phase_at(.75)=="cloud_tear","staging")
    _check(LAB.phase_at(1.49)=="demo_contact" and LAB.phase_at(2.1)=="dissolve","one contact phase")
    _check(LAB.cloud_index(.20)==-1 and LAB.cloud_index(1.45)==9,"flipbook reveal")
    _check(LAB.floor_gain(.42)>.80 and LAB.floor_gain(1.06)==0.0,"cast-only underfoot")
    _check(LAB.contact_gain(1.20,0)==0.0 and LAB.contact_gain(1.54,0)>0.0,"no precontact")
    _check(LAB.contact_gain(1.46,1)==0.0 and LAB.contact_gain(1.64,1)>0.0,"second legal target contact")
    _check(LAB.contact_gain(1.60,2)==0.0,"over-cap never affected")
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    _check(sample._hero!=null and sample._glow!=null,"painted hero and soft core")
    var s:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman04/cuu_tieu_pha_van.gd")
    for banned in ["SaveService.","CombatV2.","V63FeatureGates.","apply_damage","apply_status","summon_actor"]:
        _check(not s.contains(banned),"view only "+banned)
    print("VFX_TAL04_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" cloud_poses=10 cap2 view_only=true")
    sample.queue_free()
    quit(0 if failures==0 else 1)
