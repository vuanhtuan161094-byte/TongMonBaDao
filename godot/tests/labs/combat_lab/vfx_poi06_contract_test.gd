extends SceneTree
const LAB=preload("res://labs/combat_lab/poison06/van_co_phe_gioi.gd")
var failures:=0
func _initialize()->void:
    call_deferred("_run")
func _check(ok: bool,reason: String)->void:
    if not ok:
        failures+=1
        push_error("VFX_POI06_FAIL "+reason)
func _run()->void:
    _check(LAB.SKILL_ID=="tmb.skill.poison.co_doc.ultimate.human","canonical Co Doc ultimate")
    _check(LAB.EFFECT=="poison" and LAB.SHAPE=="circle","true effect/shape")
    _check(LAB.DECLARED_RADIUS==3.0 and LAB.DECLARED_TARGET_LIMIT==3,"radius3 cap3")
    _check(LAB.DECLARED_CAST_TIME==1.10 and LAB.DECLARED_DURATION==8.0 and LAB.DECLARED_STACKS==2,"source timing/stack")
    _check(LAB.GU.size()==8 and LAB.BRANDS.size()==6,"14 independent original gu/rune poses")
    for i in range(8):
        _check(LAB.GU[i].get_size()==Vector2(256,256),"gu frame "+str(i))
    for i in range(6):
        _check(LAB.BRANDS[i].get_size()==Vector2(256,256),"brand frame "+str(i))
    _check(LAB.TARGETS.size()==3,"three fake visual actors")
    _check(LAB.phase_at(0.50)=="convergence" and LAB.phase_at(1.57)=="transmission","charge/launch")
    _check(LAB.phase_at(2.31)=="realm_open" and LAB.phase_at(3.11)=="consumption","realm and visual gu")
    _check(LAB.phase_at(4.35)=="dissolve" and LAB.phase_at(5.30)=="idle","full fade and idle")
    _check(LAB.realm_gain(0.60)==0.0 and LAB.realm_gain(2.72)>0.98 and LAB.realm_gain(5.40)==0.0,"realm bounded")
    _check(LAB.connection_gain(1.50)==0.0 and LAB.connection_gain(3.14)>0.95,"no false precontact")
    _check(LAB.converged_at(0.0)==0.0 and LAB.converged_at(1.1)==1.0,"light streams converge to ring")
    _check(LAB.impact_gain(1.50,0)==0.0 and LAB.impact_gain(3.66,2)>0.95,"source event remains visual-only")
    for i in range(3):
        for j in range(8):
            var pos:=LAB.swarm_position(3.8,i,j)
            _check(pos.x>500.0 and pos.x<1280.0,"gu swarm target remains in scene "+str(i)+":"+str(j))
    var sample:=LAB.new()
    root.add_child(sample)
    await process_frame
    _check(sample._glow!=null,"soft alpha texture present")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison06/van_co_phe_gioi.gd")
    for forbidden in ["SaveService.save","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not source.contains(forbidden),"isolated view only "+forbidden)
    print("VFX_POI06_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" gu=8 brand=6")
    sample.queue_free()
    quit(0 if failures==0 else 1)
