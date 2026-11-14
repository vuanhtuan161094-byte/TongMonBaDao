extends SceneTree
const LAB=preload("res://labs/combat_lab/poison05/remake_r6/tan_co_dien_nhiem_r6.gd")
var failures:=0
func _initialize()->void:
    call_deferred("_run")
func _check(value: bool,why: String)->void:
    if not value:
        failures+=1
        push_error("VFX_POI05_R6_FAIL "+why)
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.poison.co_doc.active_04.human","canonical original skill")
    _check(LAB.EFFECT=="poison" and LAB.SHAPE=="circle","poison circle source")
    _check(LAB.DECLARED_TARGET_LIMIT==3 and LAB.TARGETS.size()==3,"source target cap, dummy count")
    _check(LAB.DECLARED_RADIUS==2.5 and LAB.DECLARED_CAST_TIME==0.55,"exact source radius/cast")
    _check(LAB.GU.size()==12 and LAB.SEED.size()==6 and LAB.MARK.size()==6 and LAB.SWARM.size()==8,"32 original pose assets, including distinct parasite gu flock")
    _check(LAB.phase_at(0.23)=="charge","charge")
    _check(LAB.phase_at(0.92)=="flight","spirit flight")
    _check(LAB.phase_at(1.44)=="split","one spirit branches visually")
    _check(LAB.phase_at(2.42)=="infection","three staggered target previews")
    _check(LAB.phase_at(3.26)=="dissolve","fade")
    _check(LAB.phase_at(3.90)=="idle","clear after release")
    _check(LAB.main_travel(0.3)==0.0 and LAB.main_travel(LAB.ARRIVAL)==1.0,"flight bounded")
    _check(LAB.mark_gain(0.7,0)==0.0 and LAB.mark_gain(4.0,2)==0.0,"no fake continuing mark")
    _check(LAB.mark_gain(2.31,0)>0.80 and LAB.mark_gain(2.50,2)>0.80,"three visual marks")
    _check(LAB.visual_total(4.0)==0.0,"full VFX cleared")
    for i in range(3):
        var destination: Vector2 = LAB.escort_point(2.17,i)
        var face: Vector2 = LAB.TARGETS[i]+Vector2(0.0,-97.0)
        _check(destination.distance_to(face)>40.0,"R10 gu must not hide target face "+str(i))
    
    for i in range(LAB.GU.size()):
        _check(LAB.GU[i].get_size()==Vector2(512,512),"lively spirit frame "+str(i))
    for i in range(LAB.SEED.size()):
        _check(LAB.SEED[i].get_size()==Vector2(512,512),"charged jade seed frame "+str(i))
    for i in range(LAB.MARK.size()):
        _check(LAB.MARK[i].get_size()==Vector2(320,320),"parasitic rune frame "+str(i))
    for i in range(LAB.SWARM.size()):
        _check(LAB.SWARM[i].get_size()==Vector2(384,384),"living jade moth frame "+str(i))
    _check(LAB.BACKGROUND.get_size()==Vector2(1280,720),"independent xianxia court")
    var lab:=LAB.new()
    root.add_child(lab)
    await process_frame
    _check(lab._glow!=null,"radial lighting only supports original sprites")
    var code:=FileAccess.get_file_as_string("res://labs/combat_lab/poison05/remake_r6/tan_co_dien_nhiem_r6.gd")
    for banned in ["CombatV2.","SaveService.save","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not code.contains(banned),"view-only, no state mutations "+banned)
    print("VFX_POI05_R6_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" gu=12 seed=6 mark=6 swarm=8")
    lab.queue_free()
    quit(0 if failures==0 else 1)
