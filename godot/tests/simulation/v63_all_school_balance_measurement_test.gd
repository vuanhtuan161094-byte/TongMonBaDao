extends SceneTree

# SKILL-ALL-04: fixed-seed MapBattleV2 comparison across all 9 V63 branches.
# 3 realm tiers plus A/B Immortal, Divine, and rare successors; one and three
# authored targets. Normalized synthetic actors are measurement fixtures only:
# no live PvE, resource, reward, SaveService, or player-profile claim.
const SEED := 20261110
const BATTLE_STEPS := 300
const NORMALIZED_ATK := 180.0
const SCHOOL_BRANCHES := [
    {"school":"bow","branches":["liep_anh","linh_tien","thien_vu"]},
    {"school":"fist","branches":["ba_quyen","kim_cang","huyet_quyen"]},
    {"school":"poison","branches":["doc_cham","co_doc","duoc_doc"]}
]
var failures := 0
var profiles := 0
var trials := 0
var rows: Array = []

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, reason: String) -> void:
    if not condition:
        failures += 1
        push_error("SKILL_ALL_MEASURE_FAIL " + reason)

func _make_caster(school: String, branch: String, tier: String, lineage: String) -> Dictionary:
    var core := CombatStatsV2.derive(11, 1, 10, 1, 0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = NORMALIZED_ATK
    stats["defense"] = 100.0
    var generation := "divine" if tier == "rare" else tier
    var path_suffix := "human" if generation == "human" else generation + "." + lineage
    var actions: Array = []
    var passives: Array = []
    for ordinal in range(1, 5):
        actions.append("tmb.skill.%s.%s.active_%02d.%s" % [school, branch, ordinal, path_suffix])
    var ultimate_suffix := path_suffix if tier != "rare" else "rare." + lineage
    actions.append("tmb.skill.%s.%s.ultimate.%s" % [school, branch, ultimate_suffix])
    for ordinal in range(1, 6):
        var passive_suffix := path_suffix
        if tier == "rare" and ordinal == 5:
            passive_suffix = "rare_passive." + lineage
        passives.append("tmb.skill.%s.%s.passive_%02d.%s" % [school, branch, ordinal, passive_suffix])
    var innate_id := "tmb.skill.%s.%s.innate.%s" % [school, branch, path_suffix]
    var basic_suffix := "human" if generation == "human" else generation + ".base"
    var basic_id := "tmb.skill.%s.basic.%s" % [school, basic_suffix]
    for id in actions + passives + [innate_id, basic_id]:
        _check(not V63HumanSkillCombatSystem.skill_definition(str(id)).is_empty(), "missing catalog skill " + str(id))
    var role := "frontline" if school == "fist" else "healer" if branch == "duoc_doc" else "ranged"
    return {
        "id":"skill_all_caster", "party_id":"skill_all_measurement_party",
        "role":role, "tier":"disciple", "race_id":"nhan_toc", "position":Vector2(7.0,6.0),
        "stats":stats, "hp":100000.0, "max_hp":100000.0,
        "resistances":core.resistances.duplicate(true),
        "basic_range":float(V63HumanSkillCombatSystem.skill_definition(basic_id).get("range", 1.8)),
        "basic_ratio":float(V63HumanSkillCombatSystem.skill_definition(basic_id).get("damage_ratio", 1.0)),
        "basic_interval":1.6, "move_speed":2.7,
        "skill_loadout":[], "skill_factors":{}, "context_sources":[],
        "v63_skill_loadout":actions, "v63_skill_ready":{},
        "v63_passive_ids":passives, "v63_combat_enabled":true,
        "v63_combat_branch_id":branch, "v63_combat_lineage":lineage,
        "v63_combat_generation":generation, "v63_innate_skill_id":innate_id,
        "v63_basic_skill_id":basic_id, "basic_element":"nether", "v63_divine_stage":1
    }

func _make_target(index: int) -> Dictionary:
    var actor: Dictionary = MonsterCatalogueV2.create_actor("truc_thu", 11, 1, "skill_all_target_%d" % index)
    var stats: Dictionary = actor.get("stats", {}).duplicate(true)
    stats["max_hp"] = 3000000.0
    stats["attack"] = NORMALIZED_ATK
    stats["defense"] = 100.0
    actor["stats"] = stats
    actor["hp"] = 3000000.0
    actor["max_hp"] = 3000000.0
    actor["position"] = Vector2(11.0 + float(index) * 0.5, 6.0 + float(index) * 0.5)
    actor["move_speed"] = 0.0
    return actor

func _trial(school: String, branch: String, tier: String, lineage: String, target_count: int) -> void:
    var hero := _make_caster(school, branch, tier, lineage)
    var monsters: Array = []
    for index in range(target_count):
        monsters.append(_make_target(index))
    var battle := MapBattleV2.new(SEED)
    var identifier := "skill_all_%s_%s_%s_%s_%d" % [school, branch, tier, lineage, target_count]
    var started := battle.setup(identifier, [hero], monsters)
    _check(bool(started.get("ok", false)), identifier + " setup " + str(started))
    if not bool(started.get("ok", false)):
        return
    battle.run(BATTLE_STEPS)
    var damage_by_kind: Dictionary = {}
    var healing := 0.0
    var cast_count := 0
    var distinct: Dictionary = {}
    var hit_count := 0
    for event in battle.events:
        var typ := str(event.get("type", ""))
        if typ == "skill_cast" and str(event.get("actor_id", "")) == "skill_all_caster":
            cast_count += 1
            distinct[str(event.get("skill_id", ""))] = true
        elif typ == "hit" and str(event.get("attacker", "")) == "skill_all_caster":
            var kind := str(event.get("kind", "unknown"))
            damage_by_kind[kind] = float(damage_by_kind.get(kind, 0.0)) + float(event.get("damage", 0.0))
            hit_count += 1
        elif typ == "heal" and str(event.get("caster", "")) == "skill_all_caster":
            healing += float(event.get("amount", 0.0))
    var total_damage := 0.0
    for value in damage_by_kind.values():
        total_damage += float(value)
    _check(cast_count > 0, identifier + " never cast a combat skill")
    _check(total_damage > 0.0 and hit_count > 0, identifier + " produced no committed hit damage")
    var elapsed := maxf(0.25, battle.now)
    var record := {
        "school":school, "branch":branch, "profile":tier + "." + lineage,
        "targets":target_count, "battle_seconds":elapsed,
        "cast_count":cast_count, "unique_cast_skill_ids":distinct.size(),
        "damage_total":total_damage, "damage_by_kind":damage_by_kind, "heal_hp":healing,
        "normalized_dps_per_atk":total_damage / elapsed / NORMALIZED_ATK,
        "normalized_hps_per_maxhp":healing / elapsed / 100000.0,
        "fixture":"MapBattleV2/MonsterCatalogueV2; normalized ATK180/DEF100; target HP3M",
        "seed":SEED
    }
    rows.append(record)
    trials += 1

func _run() -> void:
    for school_row in SCHOOL_BRANCHES:
        var school := str(school_row.school)
        for raw_branch in school_row.branches:
            var branch := str(raw_branch)
            _trial(school, branch, "human", "base", 1)
            _trial(school, branch, "human", "base", 3)
            profiles += 1
            for tier in ["immortal", "divine", "rare"]:
                for lineage in ["a", "b"]:
                    _trial(school, branch, tier, lineage, 1)
                    _trial(school, branch, tier, lineage, 3)
                    profiles += 1
    _check(profiles == 63, "expected 63 fixed profiles across 9 branches")
    _check(trials == 126, "expected 126 one/three-target trials")
    _check(V63FeatureGates.all_disabled(), "release gates must remain OFF")
    for record in rows:
        print("SKILL_ALL_MEASURE_PROFILE " + JSON.stringify(record))
    print("SKILL_ALL_MEASURE_SUMMARY " + JSON.stringify({
        "schools":3, "branches":9, "profiles":profiles, "trials":trials,
        "failures":failures, "label":"NORMALIZED_ENGINE_FIXTURE_NOT_LIVE_PVE_OR_PLAYER_DPS",
        "run_sha":OS.get_environment("GITHUB_SHA")
    }))
    quit(0 if failures == 0 else 1)
