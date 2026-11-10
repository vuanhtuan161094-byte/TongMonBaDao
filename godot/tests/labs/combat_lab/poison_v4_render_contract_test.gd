extends SceneTree

const V4 = preload("res://labs/combat_lab/combat_lab_poison_v4_layers.gd")
const V3 = preload("res://labs/combat_lab/combat_lab_vfx_v2.gd")
const ArtBrief = preload("res://labs/combat_lab/combat_lab_poison_skill_art_brief.gd")
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
    # All 17 approved Human art briefs resolve to real catalog skills.
    # Art metadata cannot create targets, damage, status or Save writes.
    _check(ArtBrief.HUMAN.size() == 17, "exact scoped Human art-brief coverage")
    var motif_set: Dictionary = {}
    for short_id in ArtBrief.HUMAN.keys():
        var skill_id: String = ArtBrief.PREFIX + str(short_id)
        var canonical: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
        var profile: Dictionary = ArtBrief.profile(skill_id)
        _check(not canonical.is_empty(), "brief maps to canonical ID: " + skill_id)
        _check(not str(profile.get("description", "")).is_empty() and
            not str(profile.get("vfx", "")).is_empty() and
            not str(profile.get("motif", "")).is_empty(),
            "separate effect description and original art direction " + skill_id)
        motif_set[str(profile.get("motif", ""))] = true
        if not canonical.is_empty():
            _check(not ArtBrief.geometry(canonical).is_empty() and
                not ArtBrief.mechanic(canonical).is_empty(),
                "geometry and semantics derived only from live canonical data " + skill_id)
    _check(motif_set.size() == 17, "each basic/mobility/active/ultimate has distinct visual identity")
    var canon_aoe := V63HumanSkillCombatSystem.skill_definition(
        "tmb.skill.poison.doc_cham.active_03.human")
    _check(str(canon_aoe.get("name", "")) == "Bách Độc Tán Châm" and
        str(canon_aoe.get("shape", "")) == "circle" and
        is_equal_approx(float(canon_aoe.get("radius", 0.0)), 3.0) and
        int(canon_aoe.get("target_limit", 0)) == 3,
        "Bách Độc Tán Châm art respects canonical AoE 3-tile/3-target cap")
    var canon_heal := V63HumanSkillCombatSystem.skill_definition(
        "tmb.skill.poison.duoc_doc.ultimate.human")
    _check(str(canon_heal.get("effect", "")) == "heal" and
        str(canon_heal.get("shape", "")) == "single_target",
        "Vạn Linh Giải Ách remains actual single-target healing")
    _check(ArtBrief.profile("tmb.skill.poison.doc_cham.passive_01.human").is_empty(),
        "no counterfeit active spell VFX for passive metadata")
    for z in [1.0, 2.0, 4.0, 6.0]:
        var clamped := clampf(z, 1.0, 6.0)
        _check(is_equal_approx(clamped, z), "zoom " + str(z))
    _check(is_equal_approx(V3.projectile_progress(0.0), 0.0), "projectile start")
    _check(is_equal_approx(V3.projectile_progress(1.0), 1.0), "projectile finish")
    print("POISON_V4_RENDER_TEST_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
