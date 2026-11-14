extends SceneTree
const LAB = preload("res://labs/combat_lab/poison04/co_vu_me_tung.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run_test")

func _check(ok: bool, why: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_POI04_FAIL " + why)

func _run_test() -> void:
    _check(LAB.SKILL_ID == "tmb.skill.poison.co_doc.active_03.human", "canonical human skill")
    _check(LAB.EFFECT == "poison" and LAB.SHAPE == "circle", "canonical effect and shape")
    _check(LAB.DECLARED_TARGET_LIMIT == 3 and LAB.DECLARED_RADIUS == 3.0, "catalogue shape radius cap")
    _check(LAB.DECLARED_CAST_TIME == 0.65, "catalogue cast time")
    _check(LAB.preview_target_count() == 3, "only three LAB targets")
    _check(LAB.phase_at(0.43) == "charge", "charge stage")
    _check(LAB.phase_at(0.70) == "release", "release stage")
    _check(LAB.phase_at(1.03) == "flight", "travel stage")
    _check(LAB.phase_at(1.54) == "expand", "AOE visually expands at contact only")
    _check(LAB.phase_at(2.46) == "sustain", "sustain")
    _check(LAB.phase_at(3.56) == "fade", "dissolve")
    _check(LAB.phase_at(4.32) == "idle", "idle")
    _check(LAB.flight_at(0.4) == 0.0 and LAB.flight_at(LAB.ARRIVE_AT) == 1.0, "bounded flight")
    _check(LAB.mist_gain(0.84) == 0.0 and LAB.mist_gain(4.40) == 0.0, "no before-contact or persistent false poison")
    _check(LAB.mist_gain(2.25) > 0.95, "mist visible in sustain")
    _check(LAB.seed_gain(0.0) == 0.0 and LAB.seed_gain(2.2) == 0.0, "seed vanishes at contact")
    _check(LAB.FOG.get_size() == Vector2(640,360), "authored cloud SVG import")
    _check(LAB.WISP.get_size() == Vector2(280,480), "authored wisp SVG import")
    _check(LAB.MOTH.get_size() == Vector2(256,256), "authored flying gu sprite")
    var preview := LAB.new()
    root.add_child(preview)
    await process_frame
    _check(preview._targets.size() == 3, "actual 3 distinct Godot dummy sprites")
    _check(preview._cloud_rear.size() == 4 and preview._cloud_front.size() == 3, "painted rear/front fog sprites")
    _check(preview._wisps.size() == 5 and preview._moths.size() == 6, "bounded sprite effects")
    _check(preview._seed != null and preview._charge_cloud != null, "art-backed projectile")
    for back in preview._cloud_rear:
        _check(back.z_index < preview._targets[0].z_index, "back mist behind target")
    for front in preview._cloud_front:
        _check(front.z_index > preview._targets[0].z_index, "front mist in front of target")
    for target in preview._targets:
        _check(target.z_index == 2, "actor not obscured by all fog")
    var script := FileAccess.get_file_as_string("res://labs/combat_lab/poison04/co_vu_me_tung.gd")
    for forbidden in ["SaveService.save","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        _check(not script.contains(forbidden), "visual-only, no authority " + forbidden)
    print("VFX_POI04_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    preview.queue_free()
    quit(0 if failures == 0 else 1)
