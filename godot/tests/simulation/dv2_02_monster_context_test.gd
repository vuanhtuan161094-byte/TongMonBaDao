extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _close(a: float, b: float, precision: float = 0.00001) -> bool:
    return absf(a-b) <= precision

func _src(id: String, channel: String, mode: String, amount: float) -> Dictionary:
    return {"source_id":id,"channel":channel,"mode":mode,"value":amount}

func _run() -> void:
    if not MonsterCatalogueV2.validate_species():
        _fail("Monster V2 catalogue has invalid race, tier, element or missing P0 species.")
        return
    if MonsterCatalogueV2.SPECIES.size() != 7:
        _fail("Initial monster roster must contain seven authored species.")
        return
    for species_id in MonsterCatalogueV2.SPECIES.keys():
        var previous_hp := 0.0
        for realm in range(1,31):
            for floor_index in range(1,11):
                var actor := MonsterCatalogueV2.create_actor(
                    species_id,realm,floor_index,"qa_"+str(species_id)+"_"+str(realm)+"_"+str(floor_index)
                )
                if not bool(actor.get("ok",false)):
                    _fail("Monster species could not resolve numerical HP/ATK/DEF across 300 floors.")
                    return
                var stats: Dictionary = actor["stats"]
                if stats.size() != 16 or actor["resistances"].size() != 10:
                    _fail("Monster does not share the canonical 16 stats and 10 resistances.")
                    return
                if float(stats["max_hp"]) <= previous_hp:
                    _fail("Monster HP fell or stalled while floor advanced.")
                    return
                if float(stats["attack"]) <= 0.0 or float(stats["defense"]) <= 0.0:
                    _fail("Monster real Attack/Defense must be positive.")
                    return
                previous_hp = float(stats["max_hp"])

    var boss := MonsterCatalogueV2.create_actor("hac_lang_vuong",1,1,"boss_test")
    var elite := MonsterCatalogueV2.create_actor("huyet_lang_dau_dan",1,1,"elite_test")
    var ghost := MonsterCatalogueV2.create_actor("u_hon",1,1,"ghost_test")
    var normal := MonsterCatalogueV2.create_actor("hac_lang",1,1,"normal_test")
    if not _close(float(boss["stats"]["max_hp"]),190.0*1.15*4.0):
        _fail("Boss HP does not use species × tier multiplier.")
        return
    if not _close(float(elite["stats"]["attack"]),23.0*1.15*1.25):
        _fail("Elite Attack does not use real tier scaling.")
        return
    if float(normal["stats"]["max_hp"]) >= float(boss["stats"]["max_hp"]):
        _fail("Regional boss must have a meaningful HP pressure advantage.")
        return
    if not MonsterCatalogueV2.create_actor("hac_lang",31,1,"bad").is_empty():
        var error_actor := MonsterCatalogueV2.create_actor("hac_lang",31,1,"bad")
        if bool(error_actor.get("ok",true)):
            _fail("Out-of-range Realm created a Monster actor.")
            return

    var buffs: Array = [
        _src("boss_specialist","damage_vs_boss","percent_add",0.15),
        _src("hunter_of_beasts","damage_vs_race/yeu_thu","percent_add",0.10),
        _src("elite_hunter","damage_vs_elite","percent_add",0.40),
        _src("ghost_hunter","damage_vs_race/quy_toc","percent_add",0.07),
        _src("followup","basic_followup_chance","percentage_points",1.0)
    ]
    var boss_bonus := CombatContextEffectsV2.resolve_context(buffs,boss,"basic")
    if not bool(boss_bonus.get("ok",false)) or not _close(float(boss_bonus["outgoing_damage_factor"]),1.25):
        _fail("Boss + race damage should add (+15% +10%) not multiply or also gain elite bonus.")
        return
    if not _close(float(boss_bonus["basic_followup_chance"]),1.0):
        _fail("Basic followup proc did not apply to ordinary attacks.")
        return
    var elite_bonus := CombatContextEffectsV2.resolve_context(buffs,elite,"basic")
    if not _close(float(elite_bonus["outgoing_damage_factor"]),1.50):
        _fail("Elite must get elite 40% and correct race 10%, but no boss bonus.")
        return
    var ghost_bonus := CombatContextEffectsV2.resolve_context(buffs,ghost,"basic")
    if not _close(float(ghost_bonus["outgoing_damage_factor"]),1.07):
        _fail("Race-specific bonus leaked from beasts to ghost monsters.")
        return
    var skill_bonus := CombatContextEffectsV2.resolve_context(buffs,boss,"skill")
    if not _close(float(skill_bonus["outgoing_damage_factor"]),1.25) or float(skill_bonus["basic_followup_chance"]) != 0.0:
        _fail("Active combat skill incorrectly inherited a basic followup chance.")
        return
    if bool(CombatContextEffectsV2.resolve_context([
        _src("future_shield","damage_vs_shield","percent_add",0.50)
    ],boss,"basic").get("ok",true)):
        _fail("Future-only stat unexpectedly activated without a shield consumer.")
        return
    if bool(CombatContextEffectsV2.resolve_context([
        _src("fake","damage_vs_race/nonexistent","percent_add",0.50)
    ],boss,"basic").get("ok",true)):
        _fail("Invalid race modifier must fail validation.")
        return

    var disciple := DiscipleState.new({"id":"v2_monster_hunter"})
    disciple.hp = 80.0
    disciple.max_hp = 200.0
    var player_stats := CombatStatsV2.derive(1,1,1,1,0.0,[
        _src("blood_siphon","lifesteal","percentage_points",0.20)
    ])
    var attacker_stats: Dictionary = player_stats["stats"]
    var battle := MonsterEncounterV2.player_hit(
        disciple,attacker_stats,boss,buffs,GameRng.new(5109),
        "enc1_basic_1","basic",1.0,false
    )
    if not bool(battle.get("ok",false)) or not bool(battle.get("followup",false)):
        _fail("Real player-vs-boss basic hit failed to trigger one non-recursive followup.")
        return
    var first_expected := CombatStatsV2.resolve_direct_hit(
        attacker_stats,boss["stats"],boss["resistances"],1.25,false,"",1.0,false
    )
    var second_expected := CombatStatsV2.resolve_direct_hit(
        attacker_stats,boss["stats"],boss["resistances"],1.25*0.60,false,"",1.0,false
    )
    if not _close(float(battle["primary_damage"]),float(first_expected["damage"])):
        _fail("Primary boss damage failed to use bonus once after mitigation.")
        return
    if not _close(float(battle["extra_basic_damage"]),float(second_expected["damage"])):
        _fail("Non-recursive 60% extra basic hit failed to resolve on boss.")
        return
    if not _close(float(battle["actual_damage"]),float(first_expected["damage"])+float(second_expected["damage"])):
        _fail("More than one followup was spawned from a single basic hit.")
        return
    if not _close(float(battle["lifesteal_heal"]),float(first_expected["damage"])*0.20):
        _fail("Followup must not invent second lifesteal without content approval.")
        return
    if not _close(disciple.hp,80.0+float(battle["lifesteal_heal"])):
        _fail("Monster encounter did not heal actual DiscipleState HP.")
        return
    var after_first := float(boss["hp"])
    var repeated := MonsterEncounterV2.player_hit(
        disciple,attacker_stats,boss,buffs,GameRng.new(5109),
        "enc1_basic_1","basic",1.0,false
    )
    if bool(repeated.get("ok",true)) or not _close(float(boss["hp"]),after_first):
        _fail("Monster encounter replayed a hit or rewarded lifesteal twice.")
        return
    var monster_hit := MonsterEncounterV2.monster_basic_hit(
        boss,disciple,attacker_stats,"monster_retaliation_1"
    )
    if not bool(monster_hit.get("ok",false)) or float(monster_hit.get("actual_damage",0.0)) <= 0.0:
        _fail("Boss could not strike using real monster ATK against real disciple DEF.")
        return
    if not _close(disciple.hp,float(battle["attacker_hp_after"])-float(monster_hit["actual_damage"])):
        _fail("Real boss ATK did not subtract the correct DiscipleState HP.")
        return
    var monster_duplicate := MonsterEncounterV2.monster_basic_hit(
        boss,disciple,attacker_stats,"monster_retaliation_1"
    )
    if bool(monster_duplicate.get("ok",true)):
        _fail("A boss reused its own hit ID to hit twice.")
        return
    var miss_kind := CombatContextEffectsV2.resolve_context(
        buffs,ghost,"reflect"
    )
    if float(miss_kind.get("basic_followup_chance",99.0)) != 0.0:
        _fail("Reflected damage must never produce a basic followup.")
        return

    print("DV2-02 MONSTER REAL HP/STATS + BOSS/RACE DAMAGE + BASIC FOLLOWUP: PASS")
    quit(0)

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
