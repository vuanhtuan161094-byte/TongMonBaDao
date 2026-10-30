extends SceneTree

func _init() -> void:
    var battle := MapBattleV2.new(1107)
    battle.active = true
    battle.continuous_mode = true
    battle.encounter_id = "d6_boss_summon_no_reward"
    var boss: Dictionary = {
        "id":"divine_boss","side":"monster","tier":"boss","race_id":"yao_toc",
        "species_id":"d6_test_boss","v63_boss_id":"tmb.boss.divine.test",
        "hp":1000.0,"max_hp":1000.0,"position":Vector2(10.0,10.0),
        "stats":{"max_hp":1000.0,"attack":100.0,"defense":40.0}
    }
    battle.actors[boss.id] = boss
    var added := battle.add_v63_boss_summons(boss,2)
    if added != 2:
        push_error("ONE_GAME_D6_SUMMON_FAIL: expected two capped summons, got "+str(added))
        quit(1)
        return
    for ordinal in range(1,3):
        var summon_id := "divine_boss/summon/"+str(ordinal)
        var summon: Dictionary = battle.actors.get(summon_id,{})
        if summon.is_empty() or not bool(summon.get("v63_summon_no_reward",false)) or summon.has("v63_boss_id"):
            push_error("ONE_GAME_D6_SUMMON_FAIL: summon identity/authority invalid: "+summon_id)
            quit(1)
            return
        battle._record_monster_kill({"id":"party_member"},summon,"v63_skill",12.0)
    if not battle.pending_kill_events().is_empty():
        push_error("ONE_GAME_D6_SUMMON_FAIL: boss summons entered the durable reward journal")
        quit(1)
        return
    print("ONE_GAME_D6_SUMMON_PASS: two bounded Combat V2 summon actors; no boss authority inheritance or durable reward receipt")
    quit(0)
