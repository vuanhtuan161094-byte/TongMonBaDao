extends SceneTree

# Source-authoritative Human realm range policy. No Save/loot/HP effects;
# cast-start only, with independent in/outside-distance oracles.
var failures := 0
var checks := 0
const SAMPLE := {
    "fist": {"skill":"tmb.skill.fist.ba_quyen.active_01.human", "range":2.8, "role":"frontline", "basic":1.8},
    "poison": {"skill":"tmb.skill.poison.doc_cham.active_01.human", "range":7.5, "role":"mage", "basic":6.0},
    "bow": {"skill":"tmb.skill.bow.liep_anh.active_01.human", "range":10.0, "role":"ranged", "basic":9.0}
}

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("V63_HUMAN_RANGE_ROLE_FAIL: " + label)

func _probe(school: String, within: bool) -> void:
    var row: Dictionary = SAMPLE[school]
    var skill_id := str(row.skill)
    var definition := V63HumanSkillCombatSystem.skill_definition(skill_id)
    _check(not definition.is_empty(), "skill must exist: " + skill_id)
    if definition.is_empty():
        return
    _check(is_equal_approx(float(definition.get("range", 0.0)), float(row.range)),
        "Human catalog range is explicit: " + skill_id)
    var source_position := Vector2(7.0, 10.0)
    var target_position := source_position + Vector2(float(row.range) + (-0.15 if within else 0.55), 0.0)
    var core := CombatStatsV2.derive(3, 3, 3, 3, 0.0)
    var stats: Dictionary = core.get("stats", {})
    var actor := {
        "id":"qa_" + school, "role":row.role, "party_id":"range_qa", "position":source_position,
        "stats":stats.duplicate(true), "hp":float(stats.max_hp), "basic_range":row.basic,
        "v63_combat_enabled":true, "v63_skill_loadout":[skill_id], "v63_skill_ready":{},
        "resistances":core.get("resistances", {}).duplicate(true)
    }
    var enemy := MonsterCatalogueV2.create_actor("truc_thu", 3, 1, "range_enemy")
    enemy["position"] = target_position
    var battle := MapBattleV2.new(566601)
    var setup := battle.setup("range_"+school+("_inside" if within else "_outside"), [actor], [enemy])
    _check(bool(setup.get("ok",false)), "real MapBattle setup")
    if not bool(setup.get("ok",false)): return
    var caster: Dictionary = battle.actors[actor.id]
    var victim: Dictionary = battle.actors.range_enemy
    var initial_hp := float(victim.hp)
    var started := V63HumanSkillCombatSystem._try_human_cast(battle,caster,victim)
    _check(started == within, "real skill respects checked distance: "+school+" within="+str(within))
    _check(bool(caster.get("v63_pending_cast", {}).is_empty()) != within,
        "cast is scheduled only for in-range targets")
    _check(is_equal_approx(initial_hp, float(victim.hp)),
        "no damage until the authoritative release event")
    _check(is_equal_approx(float(caster.range), float(row.basic)),
        "separate ordinary attack range")
    var emitted := 0
    for e in battle.events:
        if str(e.get("type","")) == "skill_cast" and str(e.get("skill_id","")) == skill_id:
            emitted += 1
    _check(emitted == (1 if within else 0), "event count reflects real cast validation")

func _run() -> void:
    for role_name in ["frontline", "mage", "healer", "ranged"]:
        var expected: float = {"frontline":1.8, "mage":6.0, "healer":6.0, "ranged":9.0}[role_name]
        _check(is_equal_approx(MapBattleV2.default_basic_range_for_role(role_name), expected),
            "canonical battle role default: " + role_name)
    for school in ["fist", "poison", "bow"]:
        _probe(school, true)
        _probe(school, false)
    var human := V63HumanSkillCombatSystem.load_catalogue()
    _check(bool(human.get("ok",false)), "all 105 human catalogue records validate")
    _check(V63FeatureGates.all_disabled(), "human range pilot does not enable production gates")
    print("V63_HUMAN_RANGE_ROLE_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " checks=" + str(checks) + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
