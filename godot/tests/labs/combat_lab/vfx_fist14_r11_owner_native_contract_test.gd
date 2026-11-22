extends SceneTree
## FIST14 R11 source contract QA, native Godot only. Never edits CombatV2.
const LAB = preload("res://labs/combat_lab/fist14/r11_owner_review/fist14_r11_owner_review.gd")
const MONSTER = "res://assets/actors/v5_sa_monster_1113031_1/animations.tres"
const ACTOR = "res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png"
const ATLAS = "res://labs/combat_lab/fist14/r11_owner_review/assets/fist14_r11_rgba_atlas_4x4.png"
var failures := 0

func _must(ok: bool, why: String) -> void:
    if not ok:
        failures += 1
        push_error("FIST14_R11_FOCUSED_FAIL " + why)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    _must(LAB.SKILL_ID == "tmb.skill.fist.huyet_quyen.active_04.human", "skill-id")
    _must(LAB.EFFECT == "mark" and LAB.ELEMENT == "nether", "mechanic")
    _must(LAB.SHAPE == "single_target" and LAB.TARGET_LIMIT == 1, "only-one-target")
    _must(is_equal_approx(LAB.CAST_DURATION, 0.45) and is_equal_approx(LAB.MARK_DURATION, 6.0), "timing")
    _must(is_equal_approx(LAB.COOLDOWN, 8.0) and is_equal_approx(LAB.DECLARED_RANGE, 2.8), "cooldown-range")
    _must(is_zero_approx(LAB.PROJECTILE_SPEED), "non-projectile")
    _must(LAB.FRAME_COUNT == 16 and is_equal_approx(LAB.SIZE, 309.0), "source-frame-dimensions")
    var lab = LAB.new()
    _must(lab._target_at(0.20).distance_to(lab._target_at(1.04)) > 12.0, "WALK-target-actually-moves")
    _must(lab._chest_at(0.94).distance_to(lab._target_at(0.94)) > 60.0, "target-relative-chest-anchor")
    _must(lab._phase_progress(0.2) < lab._phase_progress(0.70), "charge-to-release")
    _must(lab._phase_progress(0.70) < lab._phase_progress(1.10), "release-to-impact")
    _must(ResourceLoader.exists(ATLAS) and ResourceLoader.exists(ACTOR) and ResourceLoader.exists(MONSTER), "all-real-source-assets")
    var image := Image.load_from_file(ATLAS)
    _must(image != null and image.get_width() == 1236 and image.get_height() == 1236, "atlas-size")
    var frames := load(MONSTER) as SpriteFrames
    _must(frames != null and frames.has_animation(&"walk") and frames.get_frame_count(&"walk") > 0, "real-WALK-monster")
    var code := FileAccess.get_file_as_string("res://labs/combat_lab/fist14/r11_owner_review/fist14_r11_owner_review.gd")
    for forbidden in ["SaveService.", "CombatV2.", "apply_damage(", "apply_status(", "Skeleton2D.new("]:
        _must(not code.contains(forbidden), "readonly:" + forbidden)
    print("FIST14_R11_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    lab.free()
    quit(0 if failures == 0 else 1)
