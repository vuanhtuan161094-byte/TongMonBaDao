extends SceneTree

const SEEDS := [17, 79, 20261030]
const TEAM_COUNT := 3
const CAMP_COUNT := 20
const MONSTERS_PER_CAMPAIGN := 20
const DAMAGE := 1000000.0
const RESPAWN_SECONDS := 8.0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("V63_D8_MULTISEED_CAMP_BATTLE_FAIL: " + why)
        quit(1)
        return false
    return true

func _disciple(seed: int, team: int, member: int) -> Dictionary:
    var id := "d8_hunter_%d_%d_%d" % [seed, team, member]
    return {
        "id":id,"party_id":"d8_team_%d" % team,"role":"frontline",
        "position":Vector2(4.0+float(member)*0.7,9.0),
        "hp":1000000.0,
        "stats":{"max_hp":1000000.0,"attack":DAMAGE,"defense":1000000.0,
            "crit_chance":0.0,"attack_speed":0.0},
        "basic_range":8.0,"basic_interval":1.6,"skill_loadout":[],
        "resistances":{},"context_sources":[],"move_speed":2.0
    }

func _monster(seed: int, team: int, camp: int) -> Dictionary:
    var slot := PveMultiCampPopulationV1.slot_id(camp,0)
    var point := Vector2(6.0+float(camp%5)*6.0,4.0+float(int(camp/5))*4.0)
    return {
        "id":"d8_wolf_%d_%d_%d" % [seed,team,camp],
        "species_id":"truc_thu","race_id":"yeu_thu","tier":"normal",
        "spawn_slot_id":slot,"slot_generation":1,"position":point,
        "hp":40.0,
        "stats":{"max_hp":40.0,"attack":1.0,"defense":1.0,
            "crit_chance":0.0,"attack_speed":0.0},
        "resistances":{}
    }

func _run_campaign(seed: int, team: int) -> Dictionary:
    var world := PveMultiCampPopulationV1.new_registry(10)
    if not bool(world.get("ok",false)):
        return {"ok":false,"reason":"registry_failed"}
    var party: Array = []
    for member in range(6):
        party.append(_disciple(seed,team,member))
    var monsters: Array = []
    for camp in range(CAMP_COUNT):
        monsters.append(_monster(seed,team,camp))
    var encounter := "d8_seed_%d_team_%d" % [seed,team]
    var battle := MapBattleV2.new(seed+team*1009)
    var setup := battle.setup(encounter,party,monsters,true)
    if not bool(setup.get("ok",false)) or battle._count_monster_records() != MONSTERS_PER_CAMPAIGN:
        return {"ok":false,"reason":"combat_setup_failed:" + str(setup)}
    var trace: Array[Dictionary] = []
    var latest_due := 0.0
    for camp in range(CAMP_COUNT):
        var monster_id := "d8_wolf_%d_%d_%d" % [seed,team,camp]
        var hunter_id := "d8_hunter_%d_%d_0" % [seed,team]
        var attacker: Dictionary = battle.actors[hunter_id]
        var target: Dictionary = battle.actors[monster_id]
        var dealt := battle._deal_direct(attacker,target,1.0,"basic",true)
        if dealt <= 0.0 or float(target.get("hp",-1.0)) != 0.0:
            return {"ok":false,"reason":"real_combat_hp0_failed_camp_%d" % camp}
        var events := battle.pending_kill_events()
        if events.size() != camp+1:
            return {"ok":false,"reason":"combat_journal_count_failed_camp_%d" % camp}
        var event: Dictionary = events[camp]
        var slot_id := PveMultiCampPopulationV1.slot_id(camp,0)
        if str(event.get("spawn_slot_id","")) != slot_id:
            return {"ok":false,"reason":"journal_slot_mismatch_camp_%d" % camp}
        var accepted := PveMultiCampPopulationV1.record_authoritative_battle_kill(
            world,battle,event,RESPAWN_SECONDS
        )
        if not bool(accepted.get("ok",false)) or bool(accepted.get("rewards_granted",true)):
            return {"ok":false,"reason":"authoritative_hp0_or_no_reward_contract_failed"}
        var retry := PveMultiCampPopulationV1.record_authoritative_battle_kill(
            world,battle,event,RESPAWN_SECONDS,true
        )
        if not bool(retry.get("ok",false)) or not bool(retry.get("already_recorded",false)) or bool(retry.get("rewards_granted",true)):
            return {"ok":false,"reason":"hp0_retry_not_idempotent"}
        var no_reward := PveMultiCampPopulationV1.acknowledge_no_reward_receipt(
            world,slot_id,str(event["kill_id"]),"LOOT_PENDING"
        )
        var retry_receipt := PveMultiCampPopulationV1.acknowledge_no_reward_receipt(
            world,slot_id,str(event["kill_id"]),"LOOT_PENDING"
        )
        if not bool(no_reward.get("ok",false)) or bool(no_reward.get("rewards_granted",true)) or not bool(retry_receipt.get("already_acknowledged",false)):
            return {"ok":false,"reason":"no_reward_receipt_not_retry_safe"}
        latest_due = maxf(latest_due,float(world["slots"][slot_id]["due_at"]))
        trace.append({
            "camp":camp,"team":team,"seed":seed,"kill_id":str(event["kill_id"]),
            "damage":snappedf(dealt,0.001),"at_seconds":float(event["at_seconds"])
        })
    var advanced := PveMultiCampPopulationV1.advance_respawns(world,latest_due)
    if not bool(advanced.get("ok",false)) or int(advanced.get("respawned",0)) != CAMP_COUNT:
        return {"ok":false,"reason":"not_all_camps_respawned_after_receipts"}
    for camp in range(CAMP_COUNT):
        var slot: Dictionary = world["slots"][PveMultiCampPopulationV1.slot_id(camp,0)]
        if int(slot.get("generation",0)) != 2 or str(slot.get("phase","")) != "READY":
            return {"ok":false,"reason":"life_generation_not_advanced"}
    var serialized := JSON.stringify(world)
    var loaded: Dictionary = JSON.parse_string(serialized)
    if PveMultiCampPopulationV1.verify_structure(loaded) != "":
        return {"ok":false,"reason":"post_campaign_save_structure_invalid"}
    return {"ok":true,"trace":trace,"world":serialized}

func _run() -> void:
    if not _check(PveMultiCampPopulationV1.graph_connected(),
        "existing 20-camp route graph is not connected"):
        return
    var first_runs: Dictionary = {}
    var campaign_count := 0
    for seed in SEEDS:
        for team in range(TEAM_COUNT):
            var result := _run_campaign(int(seed),team)
            if not _check(bool(result.get("ok",false)),
                "first deterministic campaign failed: " + str(result.get("reason",""))):
                return
            first_runs["%d:%d" % [seed,team]] = JSON.stringify(result)
            campaign_count += 1
    for seed in SEEDS:
        for team in range(TEAM_COUNT):
            var result := _run_campaign(int(seed),team)
            if not _check(bool(result.get("ok",false)),
                "replayed campaign failed: " + str(result.get("reason",""))):
                return
            if not _check(first_runs["%d:%d" % [seed,team]] == JSON.stringify(result),
                "same seed/team did not reproduce exact combat+receipt trace"):
                return
    print("V63_D8_MULTISEED_CAMP_BATTLE_PASS: seeds=3 teams=3 camps_per_campaign=20 party=6 repeated=true journal_hp0=true receipt_retry=true rewards=none live_runtime_fps=NOT_MEASURED")
    quit(0)
