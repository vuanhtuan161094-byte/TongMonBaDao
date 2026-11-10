extends SceneTree

# Isolated presentation QA: does NOT change HP, damage, V6.3 balance, or Save.
const Arena = preload("res://labs/combat_lab/combat_lab_arena.gd")
const V4 = preload("res://labs/combat_lab/combat_lab_poison_v4_layers.gd")

var checks := 0
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("POISON_V4_AIM_RANGE_FAIL: " + message)

func _run() -> void:
    var core: Dictionary = CombatStatsV2.derive(2, 3, 2, 3, 0.0)
    var stats: Dictionary = core.get("stats", {})
    var disciple := {
        "id":"qa_cast", "party_id":"qa_party", "role":"mage",
        "position":Vector2(8, 10), "stats":stats.duplicate(true),
        "hp":float(stats.max_hp), "max_hp":float(stats.max_hp),
        "basic_range":6.0, "resistances":core.get("resistances", {}).duplicate(true)
    }
    var monster := MonsterCatalogueV2.create_actor("truc_thu", 2, 1, "qa_target")
    monster["position"] = Vector2(15, 10)
    var battle := MapBattleV2.new(423901)
    _check(bool(battle.setup("poison_v4_aim", [disciple], [monster]).get("ok", false)), "canonical finite battle")
    if not battle.active:
        quit(1)
        return
    var arena := Arena.new()
    root.add_child(arena)
    arena.size = Vector2(680, 440)
    arena.set_battle(battle, "poison")
    var shot := {
        "kind":"projectile", "position":Vector2(15, 10),
        "from_position":Vector2(8, 10), "target_actor_id":"qa_target",
        "source_actor_id":"qa_cast", "skill_id":"tmb.skill.poison.doc_cham.active_01.human"
    }
    _check(arena._cue_target_world_position(shot) == Vector2(15, 10), "original projectile target")
    battle.actors["qa_target"]["position"] = Vector2(17.5, 11.0)
    _check(arena._cue_target_world_position(shot) == Vector2(17.5, 11.0),
        "projectile follows moving canonical target")
    var impact := shot.duplicate()
    impact["kind"] = "impact"
    _check(arena._cue_target_world_position(impact) == Vector2(17.5, 11.0),
        "hit locks to actual actor, not stale cast coordinate")
    var cloud := shot.duplicate()
    cloud["kind"] = "venom_cloud"
    _check(arena._cue_target_world_position(cloud) == Vector2(15, 10),
        "area VFX stays at canonical center, does not chase victim")
    var charge := shot.duplicate()
    charge["kind"] = "cast"
    charge["position"] = Vector2(8, 10)
    _check(arena._cue_target_world_position(charge) == Vector2(8, 10),
        "cast aura stays on caster")
    arena.set_zoom(1.0)
    var body1: float = arena._actor_body_offset_px("qa_target")
    arena.set_zoom(6.0)
    var body6: float = arena._actor_body_offset_px("qa_target")
    _check(body1 < 0.0 and body6 < body1 and body6 > -80.0,
        "monster body offset scales with actual rig, not a giant -17*zoom jump")
    for school in ["fist", "poison", "bow"]:
        var branch := {"fist":"ba_quyen", "poison":"doc_cham", "bow":"liep_anh"}[school]
        var expected_role := {"fist":"frontline", "poison":"mage", "bow":"ranged"}[school]
        var expected_range := {"fist":1.8, "poison":6.0, "bow":9.0}[school]
        var loadout := CombatLabRosterAdapter.build_party(1, school, "human", branch, "a")
        _check(bool(loadout.get("ok", false)), "real V6.3 Lab party " + school)
        if bool(loadout.get("ok", false)):
            var row: Dictionary = loadout.party[0]
            _check(str(row.get("role", "")) == expected_role and
                is_equal_approx(float(row.get("basic_range", -1.0)), expected_range),
                school + " has the intended basic reach and role")
    _check(V4.school("tmb.skill.poison.co_doc.active_01.human") == "co_doc", "distinct gu VFX school")
    _check(V63FeatureGates.all_disabled(), "visual test does not open production gates")
    arena.queue_free()
    print("POISON_V4_AIM_RANGE_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " checks=" + str(checks) + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
