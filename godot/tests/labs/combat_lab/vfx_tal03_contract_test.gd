extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman03/loi_van_truy_an.gd")
var failures:=0
func _initialize()->void:call_deferred("_run")
func _check(ok:bool,msg:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL03_FAIL "+msg)
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.talisman.loi_phu.active_03.human","canonical mark ID")
    _check(LAB.EFFECT=="mark" and LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"one target mark")
    _check(LAB.DECLARED_CAST_TIME==.50 and LAB.DECLARED_COOLDOWN==12.2,"source timing")
    _check(LAB.DECLARED_RANGE==8.5 and LAB.DECLARED_DURATION==6.0,"source 6s mark")
    _check(LAB.MARKS.size()==8,"8 legacy ink poses")
    _check(LAB.PAINTED_MARKS.get_size()==Vector2(1280,640),"real alpha painted talisman mark atlas")
    _check(LAB.PAINTED_MASTER.get_size()==Vector2(320,320),"baked master painted mark")
    _check(LAB.PAINTED_FOOT.get_size()==Vector2(512,224),"shared real painterly foot array")
    _check(LAB.STAMP_INITIAL_RADIUS==52.0 and LAB.STAMP_STEADY_RADIUS==40.0,"talisman brand not obscuring face")
    _check(LAB.STAMP.y>=480.0 and LAB.STAMP.x>LAB.VICTIM.x-10 and LAB.STAMP.x<LAB.VICTIM.x+10,"mark anchored to lower chest, clear of face")
    for i in range(8):
        _check(LAB.MARKS[i].get_size()==Vector2(256,256),"pose size "+str(i))
    _check(LAB.phase_at(.31)=="inscribe" and LAB.phase_at(.7)=="seal_flight","windup and launch")
    _check(LAB.phase_at(1.0)=="demo_mark_present" and LAB.phase_at(7.2)=="idle","mark only")
    _check(LAB.mark_gain(.7)==0.0 and LAB.mark_gain(1.2)>.80 and LAB.mark_gain(6.2)>.80 and LAB.mark_gain(6.87)>.80 and LAB.mark_gain(7.16)==0.0,"six-second mark hold and bounded fade")
    _check(LAB.stamp_frame(.7)==-1 and LAB.stamp_frame(1.3)>=0,"no early seal")
    _check(LAB.foot_gain(.43)>.80 and LAB.foot_gain(1.1)==0.0,"caster underfoot only cast")
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    _check(sample._hero!=null and sample._radial!=null,"actual sprites and falloff")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman03/loi_van_truy_an.gd")
    for banned in ["SaveService.","CombatV2.","V63FeatureGates.","apply_damage","apply_status","summon_actor"]:
        _check(not src.contains(banned),"view only "+banned)
    print("VFX_TAL03_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" poses=8 mark6s view_only=true")
    sample.queue_free()
    quit(0 if failures==0 else 1)
