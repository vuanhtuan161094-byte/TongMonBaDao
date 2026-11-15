extends SceneTree
const LAB=preload("res://labs/combat_lab/fist05/dia_mach_lien_chan.gd")
var failures := 0
func _check(ok: bool, why: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_FIST05_FAIL " + why)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    _check(LAB.ART_REVISION=="V9_LOW_ARC_EARTHFALL_SETTLE","rockfall revision")
    _check(LAB.SKILL_ID=="tmb.skill.fist.ba_quyen.active_04.human","ID")
    _check(LAB.EFFECT=="damage" and LAB.ELEMENT=="fire","fire damage")
    _check(LAB.SHAPE=="circle" and LAB.TARGET_LIMIT==3,"circle 3")
    _check(is_equal_approx(LAB.CAST_TIME,.45),"cast")
    _check(is_equal_approx(LAB.DECLARED_RANGE,4.0),"range")
    _check(is_equal_approx(LAB.PROJECTILE_SPEED,8.0),"speed read-only")
    _check(is_equal_approx(LAB.DECLARED_RADIUS,3.0),"radius")
    _check(LAB.phase_at(.23)=="charge" and LAB.phase_at(.64)=="seismic_fault_travel","cast/fault")
    _check(LAB.phase_at(1.20)=="triple_target_eruption","hit phase")
    _check(LAB.phase_at(2.07)=="rubble_fade" and LAB.phase_at(2.78)=="clear","end")
    _check(LAB.TARGETS.size()==3,"three targets")
    for k in range(3):
        _check(LAB.contact_alpha(.78,k)==0.0,"no premature hit "+str(k))
        _check(LAB.contact_alpha(LAB.CONTACT_TIME+.022*k+.07,k)>0.0,"bounded hit "+str(k))
        _check(LAB.contact_alpha(2.6,k)==0.0,"hit clears "+str(k))
        _check(LAB.target_position(k,.20)!=LAB.target_position(k,.60),"moving target "+str(k))
    _check(LAB.contact_alpha(1.12,3)==0.0,"no fourth target")
    _check(LAB.CORE.get_size()==Vector2(1024.0,1024.0),"16 frames on core atlas")
    _check(LAB.CONTACT.get_size()==Vector2(1024.0,512.0),"8 hit frames")
    _check(LAB.FAULT_PATH.get_size()==Vector2(1024.0,256.0),"one continuous crack strip")
    _check(LAB.ATLAS_RAW_RGBA_BYTES==7340032,"7.0 MiB raw RGBA cap")
    _check(LAB.fault_alpha(.20)==0.0 and LAB.fault_alpha(.80)>.99,"fault time bounded")
    _check(LAB.fault_alpha(2.60)==0.0,"fault clear")
    _check(LAB.eruption_alpha(2.25)>0.5,"late stone dust is still perceptible")
    _check(LAB.eruption_alpha(2.56)==0.0,"settlement clears at end")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist05/dia_mach_lien_chan.gd")
    for banned in ["SaveService.","CombatV2.","apply_damage","apply_status","_deal_direct","hp -=","summon_actor","MapBattleV2."]:
        _check(not src.contains(banned),"view only "+banned)
    var node:=LAB.new()
    root.add_child(node)
    await process_frame
    _check(node.get_process_mode()==Node.PROCESS_MODE_INHERIT,"lab process")
    node.queue_free()
    print("VFX_FIST05_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures))
    quit(0 if failures==0 else 1)
