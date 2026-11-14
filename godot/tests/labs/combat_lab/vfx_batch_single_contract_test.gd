extends SceneTree
const LAB = preload("res://labs/vfx_batch/tmb_vfx_single_skill.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_test")
func _check(ok: bool,why: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_BATCH_SINGLE_FAIL "+why)
func _test() -> void:
    var skill := LAB.new()
    root.add_child(skill)
    await process_frame
    _check(skill._error == "", "default exact-ID cast preview can load")
    _check(skill.skill_id == "tmb.skill.poison.doc_cham.active_01.human", "canonical default ID")
    _check(str(skill.entry.get("id","")) == "tmb.skill.poison.doc_cham.active_01", "correct family")
    _check(str(skill.entry.get("effect","")) == "damage", "correct source effect")
    _check(skill._tex != null, "painted original material loaded")
    _check(LAB.phase_at(0.30) == "charge" and LAB.phase_at(1.1) == "travel", "cast/travel stages")
    _check(LAB.phase_at(2.2) == "contact" and LAB.phase_at(2.9) == "dissolve" and LAB.phase_at(3.9) == "idle", "contact/fade are bounded")
    _check(LAB.travel_at(0.30) == 0.0 and LAB.travel_at(LAB.ARRIVE_AT) == 1.0, "no early or late flight")
    var source := FileAccess.get_file_as_string("res://labs/vfx_batch/tmb_vfx_single_skill.gd")
    for forbidden in ["SaveService.save","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not source.contains(forbidden), "isolated art only, no gameplay mutation "+forbidden)
    print("VFX_BATCH_SINGLE_RESULT=" + ("PASS" if failures==0 else "FAIL") + " failures="+str(failures))
    skill.queue_free()
    quit(0 if failures==0 else 1)
