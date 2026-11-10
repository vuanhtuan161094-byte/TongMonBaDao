extends SceneTree

const V4 = preload("res://labs/combat_lab/combat_lab_poison_v4_layers.gd")
const V3 = preload("res://labs/combat_lab/combat_lab_vfx_v2.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> void:
    if not ok:
        failures += 1
        push_error("POISON_V4_RENDER_FAIL " + label)

func _run() -> void:
    var cases := {
        "tmb.skill.poison.doc_cham.active_01.human": "doc_cham",
        "tmb.skill.poison.co_doc.active_01.human": "co_doc",
        "tmb.skill.poison.duoc_doc.active_01.human": "duoc_doc"
    }
    for skill_id in cases.keys():
        _check(V4.school(skill_id) == str(cases[skill_id]), "branch map " + skill_id)
        _check(not V63HumanSkillCombatSystem.skill_definition(skill_id).is_empty(), "canonical skill missing " + skill_id)
    for z in [1.0, 2.0, 4.0, 6.0]:
        var clamped := clampf(z, 1.0, 6.0)
        _check(is_equal_approx(clamped, z), "zoom " + str(z))
    _check(is_equal_approx(V3.projectile_progress(0.0), 0.0), "projectile start")
    _check(is_equal_approx(V3.projectile_progress(1.0), 1.0), "projectile finish")
    print("POISON_V4_RENDER_TEST_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
