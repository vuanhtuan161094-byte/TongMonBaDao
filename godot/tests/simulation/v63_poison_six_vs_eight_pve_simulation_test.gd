extends SceneTree

# PVB1 controlled real MapBattleV2 six disciples / eight genuine-source monsters.
# Not a GUI/FPS test and not a monetary/EXP revenue simulation.
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("PVB1_SQUAD_FAIL " + detail)

func _caster(branch: String, lineage: String, index: int) -> Dictionary:
    var identity := "pvb1_%s_%s" % [branch, lineage]
    var core := CombatStatsV2.derive(11,1,10,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    var skills: Array = []
    var passives: Array = []
    for n in range(1,5):
        var action_id := "tmb.skill.poison.%s.active_%02d.divine.%s" % [branch,n,lineage]
        _check(not V63HumanSkillCombatSystem.skill_definition(action_id).is_empty(), "missing action "+action_id)
        skills.append(action_id)
    skills.append("tmb.skill.poison.%s.ultimate.divine.%s" % [branch,lineage])
    for n in range(1,6):
        passives.append("tmb.skill.poison.%s.passive_%02d.divine.%s" % [branch,n,lineage])
    var innate_id := "tmb.skill.poison.%s.innate.divine.%s" % [branch,lineage]
    var basic_id := "tmb.skill.poison.basic.divine.base"
    var basic := V63HumanSkillCombatSystem.skill_definition(basic_id)
    return {
        "id":identity,"party_id":"pvb1_squad","role":"healer" if branch=="duoc_doc" else "ranged",
        "tier":"disciple","race_id":"nhan_toc","position":Vector2(5.5,4.0+float(index)*1.6),
        "stats":stats,"hp":100000.0,"max_hp":100000.0,
        "resistances":core.resistances.duplicate(true),
        "basic_range":float(basic.get("range",7.0)),
        "basic_ratio":float(basic.get("damage_ratio",1.0)),
        "basic_interval":1.6,
        "move_speed":2.0,"skill_loadout":[],"skill_factors":{},"context_sources":[],
        "v63_skill_loadout":skills,"v63_skill_ready":{},"v63_combat_enabled":true,
        "v63_passive_ids":passives,"v63_combat_branch_id":branch,
        "v63_combat_lineage":lineage,"v63_combat_generation":"divine",
        "v63_innate_skill_id":innate_id,
        "v63_basic_skill_id":basic_id,"basic_element":"nether","v63_divine_stage":1
    }

func _enemy(index: int) -> Dictionary:
    var actor := MonsterCatalogueV2.create_actor("truc_thu",11,1,"pvb1_enemy_%02d" % index)
    actor["id"] = "pvb1_enemy_%02d" % index
    actor["position"] = Vector2(11.0+float(index % 2)*1.0,3.5+float(index / 2)*2.0)
    return actor

func _run() -> void:
    var party: Array = []
    var pairs := [
        ["doc_cham","a"], ["doc_cham","b"],["co_doc","a"],
        ["co_doc","b"],["duoc_doc","a"],["duoc_doc","b"]
    ]
    for idx in range(pairs.size()):
        party.append(_caster(str(pairs[idx][0]),str(pairs[idx][1]),idx))
    var monsters: Array = []
    for idx in range(8):
        monsters.append(_enemy(idx))
    var battle := MapBattleV2.new(20261110)
    var started := battle.setup("pvb1_real_6v8_candidate",party,monsters)
    _check(bool(started.get("ok",false)), "cannot start authentic MapBattleV2 "+str(started))
    if not bool(started.get("ok",false)):
        quit(1)
        return
    var validity := V63HumanSkillCombatSystem.validate_battle(battle)
    _check(validity.is_empty(),"invalid squad before run "+str(validity))
    battle.run(160)
    var events: Dictionary = {}
    var sources: Dictionary = {}
    var damage_by_caster: Dictionary = {}
    var total_damage := 0.0
    var hits := 0
    var casts := 0
    for row in battle.events:
        var kind := str(row.get("type",""))
        events[kind] = int(events.get(kind,0)) + 1
        if kind == "skill_cast":
            casts += 1
            var sid := str(row.get("skill_id",""))
            sources[sid] = true
        if kind == "hit":
            hits += 1
            var amount := float(row.get("damage",0.0))
            var caster_id := str(row.get("attacker",""))
            if caster_id.begins_with("pvb1_"):
                total_damage += amount
                damage_by_caster[caster_id] = float(damage_by_caster.get(caster_id,0.0)) + amount
    _check(casts >= 6,"expected at least one real cast per Divine branch")
    _check(sources.size() >= 6,"not enough distinct Divine skills committed")
    _check(hits > 0 and total_damage > 0.0,"no real damage event")
    _check(int(events.get("status_tick",0)) > 0,"expected authentic poison ticks in 6v8")
    _check(battle.actors.size()==14,"actor accounting corrupted")
    _check(V63FeatureGates.all_disabled(),"release gates changed")
    print("PVB1_REAL_MAPBATTLE_6V8 " + JSON.stringify({
        "event_counts":events,"distinct_skills":sources.size(),"casts":casts,
        "hits":hits,"committed_damage":total_damage,"damage_by_caster":damage_by_caster,
        "elapsed_seconds":battle.now,"alive_monsters":battle.actors.values().filter(
            func(a:Dictionary): return str(a.get("side",""))=="monster" and float(a.get("hp",0.0))>0.0).size(),
        "seed":20261110,"monsters":"MonsterCatalogueV2 truc_thu r11 f1, original stats",
        "disciple_stats":"controlled normalized ATK180 MaxHP100000; six Divine A/B variants",
        "scope":"actual battle runtime, NOT real source loot/XP or GUI TTK",
        "failures":failures
    }))
    quit(0 if failures == 0 else 1)
