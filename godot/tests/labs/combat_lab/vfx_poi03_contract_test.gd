extends SceneTree
const LAB = preload("res://labs/combat_lab/poison03/fu_cot_co.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_check_lab")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_POI03_FAIL " + message)

func _check_lab() -> void:
    _check(LAB.SKILL_ID == "tmb.skill.poison.co_doc.active_01.human", "canonical ID")
    _check(LAB.phase_at(0.26) == "charge", "charge")
    _check(LAB.phase_at(0.52) == "release", "release")
    _check(LAB.phase_at(1.12) == "flight", "flight")
    _check(LAB.phase_at(1.87) == "contact", "mark contact only")
    _check(LAB.phase_at(2.88) == "dissolve", "dissolve")
    _check(LAB.phase_at(3.39) == "idle", "idle, not fake status")
    _check(LAB.gu_gain(0.0) == 0.0 and LAB.gu_gain(2.15) == 0.0, "bounded sprite")
    _check(LAB.mark_gain(1.1) == 0.0 and LAB.mark_gain(3.20) == 0.0, "bounded visual mark")
    _check(LAB.travel_at(LAB.LAUNCH_AT) == 0.0 and LAB.travel_at(LAB.CONTACT_AT) == 1.0, "honest flight")
    _check(LAB.jx_frame(1.21) == -1 and LAB.jx_frame(1.58) == 0, "no pre-contact JX effect")
    _check(LAB.jx_frame(2.31) == -1, "impact clip bounded")
    _check(LAB.GU_TEXTURE.get_size() == Vector2(512,512), "authored gu SVG import")
    _check(LAB.MARK_TEXTURE.get_size() == Vector2(512,512), "bone mark SVG import")
    _check(LAB.IMPACT_FRAMES == 13, "native JX Wudu #63 frames")
    var lab := LAB.new()
    root.add_child(lab)
    await process_frame
    _check(lab._impact_rects.size() == LAB.IMPACT_FRAMES * 6, "native manifest rectangles")
    _check(lab._trails.size() == LAB.TRAIL_COUNT, "bounded original-sprite echo count")
    _check(lab._target_actor != null, "unchanged target sprite")
    _check(lab._gu != null and lab._seal != null, "two independently authored sprites")
    _check(lab._gu.z_index < lab._seal.z_index, "mark after insect")
    var content := FileAccess.get_file_as_string("res://labs/combat_lab/poison03/fu_cot_co.gd")
    for forbidden in ["SaveService.save","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates."]:
        _check(not content.contains(forbidden), "view-only no authority: " + forbidden)
    print("VFX_POI03_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    lab.queue_free()
    quit(0 if failures == 0 else 1)
