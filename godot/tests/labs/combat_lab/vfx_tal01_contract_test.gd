extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman01/dien_quang_khai_phu.gd")
var failures := 0
func _initialize()->void: call_deferred("_run")
func _check(ok:bool, msg:String)->void:
    if not ok:
        failures += 1
        push_error("VFX_TAL01_FAIL "+msg)
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.talisman.loi_phu.active_01.human","canonical ID")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="lightning","damage lightning")
    _check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"one target")
    _check(LAB.DECLARED_CAST_TIME==0.50 and LAB.DECLARED_COOLDOWN==9.40,"source timing")
    _check(LAB.DECLARED_RANGE==8.50 and LAB.DECLARED_PROJECTILE_SPEED==10.0,"range and speed metadata")
    _check(LAB.ATLAS.get_size()==Vector2(900,1440),"original atlas 12 frames")
    _check(LAB.phase_at(0.25)=="ink_charge" and LAB.phase_at(0.60)=="seal_release","real charging phases")
    _check(LAB.phase_at(0.98)=="electric_flight" and LAB.phase_at(1.49)=="demo_contact","release and one demo hit")
    _check(LAB.phase_at(2.00)=="dissolve" and LAB.phase_at(2.72)=="idle","complete fade")
    _check(LAB.contact_gain(1.25)==0.0 and LAB.contact_gain(1.49)>0.0,"impact cannot appear in flight")
    _check(LAB.travel_q(0.2)==0.0 and LAB.travel_q(1.43)>0.99,"flight bounded")
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    _check(sample._talisman!=null and sample._glow!=null,"actual raster sprite and softened gradient")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman01/dien_quang_khai_phu.gd")
    for banned in ["SaveService.","CombatV2.","V63FeatureGates.","apply_damage", "apply_status", "summon_actor"]:
        _check(not source.contains(banned),"view-only "+banned)
    print("VFX_TAL01_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" poses=12 view_only=true")
    sample.queue_free()
    quit(0 if failures==0 else 1)
