extends SceneTree

# Official V6.3/MapBattleV2 positioning regression. Uses canonical actor
# fixtures; no fake damage, cast or Save. The closest basic must not force a
# ranged mage inward while her real equipped active skill has longer reach.
const SKILL_ID := "tmb.skill.poison.doc_cham.active_03.human"
var checks := 0
var failures := 0

func _check(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        push_error("POISON_MAX_RANGE_HOLD_FAIL: " + message)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var party := CombatLabRosterAdapter.build_party(1, "poison", "human", "doc_cham", "a")
    var enemy := CombatLabRosterAdapter.build_enemy("normal", "", "qa_far_target")
    _check(bool(party.get("ok", false)) and bool(enemy.get("ok", false)), "real catalog actors")
    if not bool(party.get("ok", false)) or not bool(enemy.get("ok", false)):
        quit(1)
        return
    var caster_row: Dictionary = party.party[0]
    caster_row["position"] = Vector2(5.0, 10.0)
    var monster: Dictionary = enemy.actor
    monster["position"] = Vector2(11.8, 10.0)
    var battle := MapBattleV2.new(89011)
    _check(bool(battle.setup("poison_range_hold", [caster_row], [monster]).get("ok", false)),
        "real finite battle starts")
    if not battle.active:
        quit(2)
        return
    var caster: Dictionary = battle.actors["lab_disciple_01"]
    var target: Dictionary = battle.actors["qa_far_target"]
    _check(bool(caster.get("v63_combat_enabled", false)), "canonical V6.3 skill owner")
    caster["v63_skill_loadout"] = [SKILL_ID]
    caster["v63_skill_ready"] = {SKILL_ID: 100.0}
    caster["next_skill"] = 100.0
    target["move_speed"] = 0.0
    var preferred := V63HumanSkillCombatSystem.preferred_offensive_range(caster)
    _check(is_equal_approx(float(caster["range"]), 6.0) and
        is_equal_approx(preferred, 7.0),
        "ranged hold uses authored active reach 7.0 rather than basic 6.0")
    var original: Vector2 = caster["position"]
    for _i in range(6):
        _check(bool(battle.step(false).get("ok", false)), "real combat step accepted")
    _check((caster["position"] as Vector2).distance_to(original) < 0.001,
        "caster does not step closer during cooldown while target is within max skill range")
    _check((target["position"] as Vector2).distance_to(original) > 6.0,
        "no phantom basic melee damage inferred from an out-of-range target")

    target["position"] = Vector2(15.0, 10.0)
    for _i in range(18):
        battle.step(false)
    var distance := (caster["position"] as Vector2).distance_to(target["position"])
    _check(distance <= preferred + 0.03 and distance >= 6.0,
        "ranged caster approaches only to longest real authored skill reach")
    var at_reach: Vector2 = caster["position"]
    for _i in range(4):
        battle.step(false)
    _check((caster["position"] as Vector2).distance_to(at_reach) < 0.001,
        "ranged caster remains at farthest attack position while cooldown persists")
    print("POISON_MAX_RANGE_HOLD_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " checks=" + str(checks) + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
