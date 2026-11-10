extends SceneTree

# PVB1: source-backed Godot MapBattleV2 measurement, 21 lineage profiles x
# one- and three-target deterministic normalized trials. No fake payout.
# Recorded damage is genuine CombatStatsV2 + status events at fixed stats,
# NOT live player DPS or source-accurate realm11 monster TTK.
const SEED := 20261110
const BATTLE_STEPS := 300
const NORMALIZED_ATK := 180.0
var failures := 0
var profiles := 0
var trials := 0
var rows: Array = []

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, reason: String) -> void:
    if not condition:
        failures += 1
        push_error("PVB1_PROFILES_FAIL " + reason)

func _make_caster(branch: String, tier: String, lineage: String) -> Dictionary:
    var core := CombatStatsV2.derive(11, 1, 10, 1, 0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = NORMALIZED_ATK
    stats["defense"] = 100.0
    var base_tier := "divine" if tier == "rare" else tier
    var actions: Array = []
    var passives: Array = []
    for ordinal in range(1, 5):
        var active_suffix := "human" if base_tier == "human" else base_tier + "." + lineage
        actions.append("tmb.skill.poison.%s.active_%02d.%s" % [branch, ordinal, active_suffix])
    var ultimate_suffix := "human" if base_tier == "human" else base_tier + "." + lineage
    if tier == "rare":
        ultimate_suffix = "rare." + lineage
    var ultimate_id := "tmb.skill.poison.%s.ultimate.%s" % [branch, ultimate_suffix]
    actions.append(ultimate_id)
    for ordinal in range(1, 6):
        var passive_suffix := "human" if base_tier == "human" else base_tier + "." + lineage
        if tier == "rare" and ordinal == 5:
            passive_suffix = "rare_passive." + lineage
        passives.append("tmb.skill.poison.%s.passive_%02d.%s" % [branch, ordinal, passive_suffix])
    var innate_suffix := "human" if base_tier == "human" else base_tier + "." + lineage
    var innate_id := "tmb.skill.poison.%s.innate.%s" % [branch, innate_suffix]
    var basic_suffix := "human" if base_tier == "human" else base_tier + ".base"
    var basic_id := "tmb.skill.poison.basic.%s" % basic_suffix
    var basic := V63HumanSkillCombatSystem.skill_definition(basic_id)
    for id in actions + passives + [innate_id,basic_id]:
        _check(not V63HumanSkillCombatSystem.skill_definition(str(id)).is_empty(),
            "missing catalog skill " + str(id))
    return {
        "id":"trial_caster", "party_id":"measurement_party",
        "role":"healer" if branch == "duoc_doc" else "ranged",
        "tier":"disciple", "race_id":"nhan_toc", "position":Vector2(7.0,6.0),
        "stats":stats, "hp":100000.0,"max_hp":100000.0,
        "resistances":core.resistances.duplicate(true),
        "basic_range":float(basic.get("range",7.0)),
        "basic_ratio":float(basic.get("damage_ratio",1.0)),
        "basic_interval":1.6,"move_speed":1.0,
        "skill_loadout":[],"skill_factors":{},"context_sources":[],
        "v63_skill_loadout":actions,"v63_skill_ready":{},
        "v63_passive_ids":passives,"v63_combat_enabled":true,
        "v63_combat_branch_id":branch,"v63_combat_lineage":lineage,
        "v63_combat_generation":base_tier,"v63_innate_skill_id":innate_id,
        "v63_basic_skill_id":basic_id,"basic_element":"nether",
        "v63_divine_stage":1
    }

func _make_target(index: int) -> Dictionary:
    var actor: Dictionary = MonsterCatalogueV2.create_actor(
        "truc_thu",11,1,"pvb1_measure_target_%d" % index)
    var stats: Dictionary = actor.get("stats",{}).duplicate(true)
    # Make the actual authored species an immortal training dummy at
    # normalized ATK/HP/DEF so the combat lasts the same 75 seconds.
    # This is NOT a source-accurate TTK encounter or a drop scenario.
    stats["max_hp"] = 3000000.0
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    actor["stats"] = stats
    actor["hp"] = 3000000.0
    actor["max_hp"] = 3000000.0
    actor["position"] = Vector2(11.0 + float(index) * 0.5,
        6.0 + float(index) * 0.5)
    actor["move_speed"] = 0.0
    return actor

func _trial(branch: String, tier: String, lineage: String, target_count: int) -> void:
    var hero := _make_caster(branch,tier,lineage)
    var monsters: Array = []
    for index in range(target_count):
        monsters.append(_make_target(index))
    var battle := MapBattleV2.new(SEED)
    var identifier := "pvb1_profile_%s_%s_%s_%d" % [branch,tier,lineage,target_count]
    var started := battle.setup(identifier,[hero],monsters)
    _check(bool(started.get("ok",false)),identifier+" setup "+str(started))
    if not bool(started.get("ok",false)):
        return
    battle.run(BATTLE_STEPS)
    var direct := 0.0
    var dot := 0.0
    var healing := 0.0
    var cast_count := 0
    var distinct: Dictionary = {}
    var spread_count := 0
    var hit_count := 0
    for event in battle.events:
        var typ := str(event.get("type",""))
        if typ == "skill_cast" and str(event.get("actor_id","")) == "trial_caster":
            cast_count += 1
            distinct[str(event.get("skill_id",""))] = true
        elif typ == "hit" and str(event.get("attacker","")) == "trial_caster":
            var dealt := float(event.get("damage",0.0))
            if str(event.get("kind","")) == "v63_poison":
                dot += dealt
            else:
                direct += dealt
            hit_count += 1
        elif typ == "heal" and str(event.get("caster","")) == "trial_caster":
            healing += float(event.get("amount",0.0))
        elif typ == "v63_poison_spread" and str(event.get("caster","")) == "trial_caster":
            spread_count += 1
    _check(cast_count > 0,identifier+" never cast a combat skill")
    _check(direct + dot > 0.0,identifier+" produced no committed damage")
    _check(hit_count > 0,identifier+" produced no real hit")
    var elapsed := maxf(0.25,battle.now)
    var normalized_dps := (direct + dot)/elapsed/NORMALIZED_ATK
    var normalized_hps := healing/elapsed/100000.0
    _check(not is_nan(normalized_dps) and not is_inf(normalized_dps),
        identifier+" invalid normalized DPS")
    rows.append({
        "profile":branch+"."+tier+"."+lineage,
        "targets":target_count,"battle_seconds":elapsed,
        "cast_count":cast_count,"unique_cast_skill_ids":distinct.size(),
        "direct_damage":direct,"dot_damage":dot,"heal_hp":healing,
        "normalized_dps_per_atk":normalized_dps,
        "normalized_hps_per_maxhp":normalized_hps,
        "spread_events":spread_count,
        "fixture":"MapBattleV2/MonsterCatalogueV2, normalized target HP 3M/ATK180/DEF100",
        "seed":SEED
    })
    trials += 1

func _run() -> void:
    var branches := ["doc_cham","co_doc","duoc_doc"]
    for branch in branches:
        _trial(branch,"human","base",1)
        _trial(branch,"human","base",3)
        profiles += 1
        for tier in ["immortal","divine","rare"]:
            for lineage in ["a","b"]:
                _trial(branch,tier,lineage,1)
                _trial(branch,tier,lineage,3)
                profiles += 1
    _check(profiles == 21,"expected exactly 21 fixed build profiles")
    _check(trials == 42,"expected exactly 42 one-vs-three target trials")
    _check(V63FeatureGates.all_disabled(),"release gates must remain OFF")
    for record in rows:
        print("PVB1_MEASURE_PROFILE " + JSON.stringify(record))
    print("PVB1_MEASURE_SUMMARY " + JSON.stringify({
        "profiles":profiles,"trials":trials,"failures":failures,
        "label":"NORMALIZED_AUTHENTIC_ENGINE_MEASUREMENTS_NOT_LIVE_PLAYER_QA",
        "run_sha":OS.get_environment("GITHUB_SHA")
    }))
    quit(0 if failures == 0 else 1)
