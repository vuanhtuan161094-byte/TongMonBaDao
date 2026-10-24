extends SceneTree

# Exact uncommitted baseline probe source used against PR #29 HEAD 9522812.
# The same four contract groups were expanded into the committed 40-check test.
var _failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> void:
    if not ok:
        _failures += 1
        push_error("S1_EDGE_FAIL: " + reason)

func _player(skills: Array) -> Dictionary:
    var stats: Dictionary = CombatStatsV2.derive(1,1,1,1,0.0)["stats"].duplicate(true)
    stats["max_hp"] = 10000.0
    stats["attack"] = 100.0
    stats["defense"] = 200.0
    return {
        "id":"d0","party_id":"p0","role":"ranged",
        "position":Vector2(10,10),"stats":stats,"hp":7000.0,
        "basic_range":1.9,"basic_interval":1.1,
        "skill_loadout":skills,"skill_factors":{}
    }

func _monster() -> Dictionary:
    var monster: Dictionary = MonsterCatalogueV2.create_actor("thanh_lang",1,1,"s1_edge_m")
    monster["id"] = "m0"
    monster["position"] = Vector2(12,10)
    monster["stats"] = monster["stats"].duplicate(true)
    monster["stats"]["max_hp"] = 100000.0
    monster["stats"]["attack"] = 1.0
    monster["hp"] = 100000.0
    return monster

func _count(battle: MapBattleV2, event_type: String, status: String = "") -> int:
    var count := 0
    for event in battle.events:
        if str(event.get("type","")) != event_type:
            continue
        if not status.is_empty() and str(event.get("status","")) != status:
            continue
        count += 1
    return count

func _encode_snapshot_payload(wrapper: Dictionary, payload: Dictionary) -> Dictionary:
    var result := wrapper.duplicate(true)
    result["payload"] = Marshalls.raw_to_base64(var_to_bytes(payload))
    return result

func _run() -> void:
    # A ready learned guard must be usable by a real frontline actor. The old
    # role guard must not immediately obscure it while its learned buff is active.
    var front_row := _player(["kim_cuong_ho_the"])
    front_row["role"] = "frontline"
    var frontline := MapBattleV2.new(90101)
    _check(bool(frontline.setup("s1_frontline_guard",[front_row],[_monster()]).get("ok",false)),
        "frontline guard setup")
    frontline.run(4,false)
    _check(_count(frontline,"status_applied","guard") == 1,
        "frontline learned guard must apply once")
    _check(_count(frontline,"guard") == 0,
        "generic guard must not overlap an active learned guard")
    var learned_until := float(frontline.actors["d0"].get("learned_guard_until",-1.0))
    frontline.run(12,false)
    _check(_count(frontline,"status_applied","guard") == 1,
        "frontline learned guard must not retrigger before expiration")
    _check(float(frontline.actors["d0"].get("learned_guard_until",-1.0)) == learned_until,
        "frontline learned guard expiration changed while active")

    # Status provenance must resolve to an opposing actor with the matching
    # authored skill effect; a non-empty arbitrary ID is not sufficient.
    var plain := MapBattleV2.new(90102)
    _check(bool(plain.setup("s1_snapshot",[ _player([]) ],[_monster()]).get("ok",false)),
        "snapshot fixture setup")
    var saved := MapBattleSnapshotV2.save(plain)
    var raw: Dictionary = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    for actor in raw["actors"]:
        if str(actor.get("id","")) == "m0":
            actor["status_effects"] = {
                "burn":{
                    "caster":"ghost","skill_id":"hoa_cau","until":2.0,
                    "ratio":0.16,"next_tick":1.0
                }
            }
    var ghost_status := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(ghost_status).get("ok",false)),
        "snapshot accepted status from unknown caster")

    # Every saved deadline must be finite so replay cannot pin an actor forever.
    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    raw["casts"] = [{
        "caster":"d0","target_id":"m0","skill_id":"hoa_cau",
        "ready":INF,"ratio":1.15,"element":"fire"
    }]
    var infinite_cast := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(infinite_cast).get("ok",false)),
        "snapshot accepted an infinite cast deadline")

    # A burn-caused continuous death is journaled once and stays exactly-once
    # after snapshot/reload and further simulation steps.
    var continuous := MapBattleV2.new(90103)
    _check(bool(continuous.setup("s1_burn_kill",[_player([])],[],true).get("ok",false)),
        "continuous burn setup")
    var doomed := _monster()
    doomed["id"] = "m_burn"
    doomed["position"] = Vector2(14,10)
    doomed["stats"]["max_hp"] = 100000.0
    doomed["stats"]["attack"] = 1.0
    doomed["hp"] = 1.0
    var add := continuous.add_continuous_monster({
        "id":"m_burn","spawn_slot_id":"s1_burn_slot","slot_generation":1,
        "species_id":"thanh_lang","race_id":str(doomed.get("race_id","beast")),
        "tier":"normal","position":doomed["position"],
        "stats":doomed["stats"],"hp":1.0
    })
    _check(bool(add.get("ok",false)),"continuous burn target spawn")
    continuous.actors["m_burn"]["status_effects"] = {
        "burn":{
            "caster":"d0","skill_id":"hoa_cau","until":3.0,
            "ratio":0.16,"next_tick":0.25
        }
    }
    continuous.step(false)
    _check(float(continuous.actors["m_burn"]["hp"]) <= 0.0,
        "burn did not down the low-health monster")
    _check(continuous.pending_kill_events().size() == 1,
        "burn kill did not create exactly one simulator kill receipt")
    _check(_count(continuous,"downed") == 1,
        "burn kill emitted duplicate downed events")
    var continuous_saved := MapBattleSnapshotV2.save(continuous)
    var resumed_result := MapBattleSnapshotV2.load(continuous_saved)
    _check(bool(resumed_result.get("ok",false)),"burn-death snapshot restore")
    if bool(resumed_result.get("ok",false)):
        var resumed: MapBattleV2 = resumed_result["battle"]
        resumed.run(8,false)
        _check(resumed.pending_kill_events().size() == 1,
            "burn kill receipt duplicated after reload")
        _check(_count(resumed,"downed") == 1,
            "burn downed event duplicated after reload")

    if _failures > 0:
        push_error("S1_EDGE_CONTRACT_FAIL checks=" + str(_failures))
        quit(1)
        return
    print("COMBAT_V3_S1_EDGE_CONTRACT_PASS checks=18")
    quit(0)
