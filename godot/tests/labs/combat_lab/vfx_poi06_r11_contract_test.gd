extends SceneTree
const LAB = preload("res://labs/combat_lab/poison06/r11_candidate/van_co_phe_gioi_r11.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_run")
func _check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("POI06_R11_FAIL " + reason)
func _run() -> void:
    _check(LAB.SKILL_ID == "tmb.skill.poison.co_doc.ultimate.human", "canonical id")
    _check(LAB.EFFECT == "poison" and LAB.SHAPE == "circle", "canonical poison/circle")
    _check(LAB.DECLARED_RADIUS == 3.0 and LAB.DECLARED_TARGET_LIMIT == 3, "radius and three targets")
    _check(LAB.DECLARED_CAST_TIME == 1.10 and LAB.DECLARED_RANGE == 8.0, "cast and range")
    _check(LAB.DECLARED_DURATION == 8.0 and LAB.DECLARED_STACKS == 2, "duration and stacks are metadata only")
    _check(LAB.FRAME_COUNT == 48 and LAB.COLS == 8 and LAB.CELL == Vector2(256,256), "48 alpha atlas frames")
    _check(LAB.TARGETS.size() == 3, "only three illustrative targets")
    _check(LAB.phase_at(0.5) == "charge" and LAB.phase_at(1.5) == "flight", "cast phases")
    _check(LAB.phase_at(2.9) == "realm_and_visual_contact" and LAB.phase_at(4.6) == "fade" and LAB.phase_at(5.3) == "idle", "contact and fade phases")
    _check(LAB.frame_index_at(0.0) == 0 and LAB.frame_index_at(2.7) >= 16 and LAB.frame_index_at(5.3) == 47, "bounded frame selection")
    var source := FileAccess.get_file_as_string("res://labs/combat_lab/poison06/r11_candidate/van_co_phe_gioi_r11.gd")
    for forbidden in ["SaveService.save", "CombatV2.", "MapBattleV2.", "apply_damage", "apply_status", "summon_actor", "V63FeatureGates."]:
        _check(not source.contains(forbidden), "view-only contract " + forbidden)
    var path := LAB.ATLAS_PATH
    _check(FileAccess.file_exists(path), "owner-approved R11 PNG must be committed")
    if FileAccess.file_exists(path):
        var img := Image.load_from_file(path)
        _check(img.get_size() == Vector2i(2048,1536), "native atlas dimensions")
        _check(img.detect_alpha() != Image.ALPHA_NONE, "RGBA alpha present")
        for i in range(48):
            var x := (i % 8) * 256
            var y := int(floor(float(i)/8.0)) * 256
            _check(img.get_pixel(x,y).a == 0.0 and img.get_pixel(x+255,y+255).a == 0.0, "alpha cell border " + str(i))
    if failures == 0:
        var sample := LAB.new()
        root.add_child(sample)
        await process_frame
        _check(sample._frames.size() == 48, "all native AtlasTextures created")
        sample.queue_free()
    print("VFX_POI06_R11_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
