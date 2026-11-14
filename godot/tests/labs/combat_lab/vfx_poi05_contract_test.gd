extends SceneTree
const LAB = preload("res://labs/combat_lab/poison05/tan_co_dien_nhiem.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_check_lab")
func _check(ok: bool, why: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_POI05_FAIL "+why)
func _check_lab() -> void:
    _check(LAB.SKILL_ID == "tmb.skill.poison.co_doc.active_04.human","exact family ID")
    _check(LAB.EFFECT == "poison" and LAB.SHAPE=="circle","source effect and shape")
    _check(LAB.DECLARED_RADIUS == 2.5 and LAB.DECLARED_TARGET_LIMIT==3,"source radius and cap")
    _check(LAB.DECLARED_CAST_TIME==0.55 and LAB.DECLARED_POISON_STACKS==1,"source cast and stacks")
    _check(LAB.TARGETS.size()==3,"three visual-only targets")
    _check(LAB.COCOON.size()==12 and LAB.SCARAB.size()==4,"16 authored frame assets")
    _check(LAB.CAST_END==0.55 and LAB.LOOP_SECONDS==4.10,"preview timing distinct from source gameplay duration")
    _check(LAB.phase_at(0.24)=="charge","charge phase")
    _check(LAB.phase_at(0.87)=="travel","projectile phase")
    _check(LAB.phase_at(1.52)=="burst","chitin explosion phase")
    _check(LAB.phase_at(2.27)=="spread","spore spread phase")
    _check(LAB.phase_at(3.25)=="dissolve","release")
    _check(LAB.phase_at(3.88)=="idle","fully cleared")
    _check(LAB.travel_at(0.1)==0.0 and LAB.travel_at(LAB.ARRIVAL)==1.0,"travel bounded")
    _check(LAB.cocoon_frame_at(0.0)==0 and LAB.cocoon_frame_at(1.81)==11,"actual frame motion")
    _check(LAB.spread_gain(0.7)==0.0 and LAB.spread_gain(3.9)==0.0,"no fake persistent effect")
    _check(LAB.spread_gain(2.05)>0.90,"spores visible")
    _check(LAB.mark_gain(0.2,0)==0.0 and LAB.mark_gain(3.90,2)==0.0,"marks bound")
    for i in range(12):
        _check(LAB.COCOON[i].get_size()==Vector2(512,512),"12 transparent 512px frames "+str(i))
    for i in range(4):
        _check(LAB.SCARAB[i].get_size()==Vector2(256,256),"4 wing frames "+str(i))
    _check(LAB.MARK.get_size()==Vector2(512,512),"separate spore seal")
    var preview := LAB.new()
    root.add_child(preview)
    await process_frame
    _check(preview._soft_disc!=null,"radial light texture computed")
    var source := FileAccess.get_file_as_string("res://labs/combat_lab/poison05/tan_co_dien_nhiem.gd")
    for banned in ["SaveService.save","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not source.contains(banned),"view-only authority "+banned)
    print("VFX_POI05_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    preview.queue_free()
    quit(0 if failures==0 else 1)
