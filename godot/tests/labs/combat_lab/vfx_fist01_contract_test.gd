extends SceneTree
const LAB = preload("res://labs/combat_lab/fist01/khai_son_trong_quyen.gd")
var failures := 0

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_FIST01_FAIL " + message)

func _initialize() -> void:
    call_deferred("_run_test")

func _run_test() -> void:
    _check(LAB.SKILL_ID == "tmb.skill.fist.ba_quyen.active_01.human", "canonical skill")
    _check(LAB.EFFECT == "damage" and LAB.ELEMENT == "fire", "damage/fire")
    _check(LAB.SHAPE == "single_target" and LAB.TARGET_LIMIT == 1, "one target")
    _check(is_equal_approx(LAB.DECLARED_CAST, 0.45), "cast 0.45")
    _check(is_equal_approx(LAB.DECLARED_RANGE, 2.8), "range 2.8")
    for t in [0.26, 0.48, 0.65, 0.95, 1.38, 1.89]:
        _check(LAB.phase_at(t) == ["charge", "release", "flight", "impact", "dissolve", "idle"][
            [0.26, 0.48, 0.65, 0.95, 1.38, 1.89].find(t)], "phase at " + str(t))
    _check(LAB.flight_at(LAB.RELEASE_END) == 0.0, "flight starts at zero")
    _check(LAB.flight_at(LAB.CONTACT_AT) == 1.0, "flight reaches target")
    _check(LAB.impact_gain(0.68) == 0.0, "no premature contact")
    _check(LAB.impact_gain(1.8) == 0.0, "impact bounded")
    _check(LAB.CHARGE.size() == 8 and LAB.FLIGHT.size() == 8 and LAB.IMPACT.size() == 8,
        "24 original authored poses")
    _check(LAB.GROUND.size() == 8, "8 grounded pressure-fracture poses")
    _check(LAB.FIST_REVISION == "R10_TURBULENT_PLASMA", "raster atlas revision")
    _check(LAB.PAINTED_HERO.get_size() == Vector2(1280.0, 960.0),
        "12 independent painted hero frames")
    _check(LAB.PAINTED_CHARGE.get_size() == Vector2(1280.0, 640.0),
        "8 painted charge frames")
    _check(LAB.PAINTED_IMPACT.get_size() == Vector2(1280.0, 640.0),
        "8 painted contact frames")
    for sprite in LAB.CHARGE + LAB.FLIGHT + LAB.IMPACT:
        _check(sprite.get_size() == Vector2(320.0, 320.0), "valid imported sprite")
    var content := FileAccess.get_file_as_string(
        "res://labs/combat_lab/fist01/khai_son_trong_quyen.gd")
    for token in ["SaveService.", "CombatV2.", "MapBattleV2.", "V63FeatureGates.",
            "apply_damage", "apply_status"]:
        _check(not content.contains(token), "view only " + token)
    var lab := LAB.new()
    root.add_child(lab)
    await process_frame
    _check(lab._glow != null, "radial light loaded")
    print("VFX_FIST01_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " failures=" + str(failures))
    lab.queue_free()
    quit(0 if failures == 0 else 1)
