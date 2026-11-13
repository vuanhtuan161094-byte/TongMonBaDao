extends SceneTree
const LAB = preload("res://labs/combat_lab/poison02/xa_anh_source_vl_remake.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_test")

func _assert(condition: bool, explanation: String) -> void:
    if not condition:
        failures += 1
        push_error("VFX_POI02_FAIL " + explanation)

func _test() -> void:
    _assert(LAB.SKILL_ID == "tmb.skill.poison.co_doc.active_02.human", "exact canonical skill")
    _assert(LAB.FRAME_COUNT == 6, "independent painted sprite flipbook frames")
    _assert(LAB.phase_at(0.23) == "charge", "charge before launch")
    _assert(LAB.phase_at(0.98) == "flight", "flight")
    _assert(LAB.phase_at(2.05) == "bind", "bind")
    _assert(LAB.phase_at(2.86) == "dissolve", "dissolve")
    _assert(LAB.phase_at(3.8) == "idle", "no persistent fake DoT")
    _assert(LAB.flight_gain(0.12) == 0.0 and LAB.flight_gain(2.1) == 0.0, "bounded flight")
    _assert(LAB.bind_gain(1.1) == 0.0 and LAB.bind_gain(3.99) == 0.0, "bounded binding")
    _assert(LAB.impact_frame(0.4) == -1 and LAB.impact_frame(1.64) == 0, "no precontact JX impact")
    _assert(LAB.impact_frame(2.40) == -1, "source JX impact duration bounded")
    _assert(LAB.SOURCE_ATLAS.get_size() == Vector2(1536,358), "sprite sheet dimensions")
    _assert(LAB.COIL_ART.get_size() == Vector2(320,350), "bind asset dimensions")
    _assert(LAB.JX_IMPACT != null, "real local JX1 Wudu #63 impact asset")
    var preview := LAB.new()
    root.add_child(preview)
    await process_frame
    _assert(preview.flight_frames.size() == 6, "actual six imported AtlasTexture regions")
    _assert(preview._impact_rects.size() == 78, "13 original JX rects")
    var source := FileAccess.get_file_as_string("res://labs/combat_lab/poison02/xa_anh_source_vl_remake.gd")
    for forbidden in ["SaveService.save","CombatV2.","MapBattleV2.","V63FeatureGates.","apply_damage","apply_status"]:
        _assert(not source.contains(forbidden), "visual-only without authority: " + forbidden)
    print("VFX_POI02_FOCUSED_RESULT=" + ("PASS" if failures==0 else "FAIL") + " failures=" + str(failures))
    preview.queue_free()
    quit(0 if failures==0 else 1)
