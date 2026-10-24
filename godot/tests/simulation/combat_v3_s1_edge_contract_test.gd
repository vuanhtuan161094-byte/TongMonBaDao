extends SceneTree

# Extra S1 gates for the packet's live frontline and snapshot/replay edge cases.
var _failures := 0
var _checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> void:
    _checks += 1
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
    var guard_saved := MapBattleSnapshotV2.save(frontline)
    var guard_loaded := MapBattleSnapshotV2.load(guard_saved)
    _check(bool(guard_loaded.get("ok",false)),"active learned guard snapshot restore")
    frontline.run(12,false)
    if bool(guard_loaded.get("ok",false)):
        var guard_resume: MapBattleV2 = guard_loaded["battle"]
        guard_resume.run(12,false)
        _check(MapBattleSnapshotV2.save(frontline)==MapBattleSnapshotV2.save(guard_resume),
            "active learned guard diverged after save/load")
    _check(_count(frontline,"status_applied","guard") == 1,
        "frontline learned guard must not retrigger before expiration")
    _check(float(frontline.actors["d0"].get("learned_guard_until",-1.0)) == learned_until,
        "frontline learned guard expiration changed while active")

    # Status provenance must resolve to an opposing actor with the matching
    # authored skill effect; a non-empty arbitrary ID is not sufficient.
    var plain := MapBattleV2.new(90102)
    _check(bool(plain.setup("s1_snapshot",[ _player(["hoa_cau"]) ],[_monster()]).get("ok",false)),
        "snapshot fixture setup")
    var saved := MapBattleSnapshotV2.save(plain)
    _check(bool(MapBattleSnapshotV2.load(saved).get("ok",false)),
        "baseline-shaped version 1 snapshot was rejected")
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

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    for actor in raw["actors"]:
        if str(actor.get("id","")) == "m0":
            actor["status_effects"] = {
                "burn":{
                    "caster":"d0","skill_id":"han_suong_an","until":2.0,
                    "ratio":0.16,"next_tick":1.0
                }
            }
    var mismatched_status := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(mismatched_status).get("ok",false)),
        "snapshot accepted status whose skill has a different effect")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    for actor in raw["actors"]:
        if str(actor.get("id","")) == "d0":
            actor["status_effects"] = {
                "burn":{
                    "caster":"d0","skill_id":"hoa_cau","until":2.0,
                    "ratio":0.16,"next_tick":1.0
                }
            }
    var same_side_status := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(same_side_status).get("ok",false)),
        "snapshot accepted a status caster on the same side")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    raw["time"] = 1.0
    for actor in raw["actors"]:
        if str(actor.get("id","")) == "m0":
            actor["status_effects"] = {
                "burn":{
                    "caster":"d0","skill_id":"hoa_cau","until":3.0,
                    "ratio":0.16,"next_tick":0.25
                }
            }
    var stale_burn_tick := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(stale_burn_tick).get("ok",false)),
        "snapshot accepted an overdue burn tick that would tick every step")

    # Every saved deadline must be finite so replay cannot pin an actor forever.
    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    raw["casts"] = [{
        "caster":"d0","target_id":"m0","skill_id":"hoa_cau",
        "ready":INF,"ratio":1.15,"element":"fire"
    }]
    var infinite_cast := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(infinite_cast).get("ok",false)),
        "snapshot accepted an infinite cast deadline")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    raw["casts"] = [{
        "caster":"d0","target_id":"d0","skill_id":"hoa_cau",
        "ready":0.0,"ratio":1.15,"element":"fire"
    }]
    var self_targeted_damage := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(self_targeted_damage).get("ok",false)),
        "snapshot accepted a non-self skill targeting its caster")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    for actor in raw["actors"]:
        if str(actor.get("id","")) == "d0":
            actor["learned_guard_until"] = INF
    var infinite_guard := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(infinite_guard).get("ok",false)),
        "snapshot accepted an infinite learned-guard deadline")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    raw["casts"] = []
    for _index in range(MapBattleV2.MAX_DISCIPLES+MapBattleV2.MAX_MONSTERS+1):
        raw["casts"].append({})
    var too_many_casts := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(too_many_casts).get("ok",false)),
        "snapshot accepted an unbounded pending cast list")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    for actor in raw["actors"]:
        if str(actor.get("id","")) == "d0":
            actor["next_basic"] = INF
    var infinite_action_timer := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(infinite_action_timer).get("ok",false)),
        "snapshot accepted an infinite basic-action deadline")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    for actor in raw["actors"]:
        if str(actor.get("id","")) == "d0":
            actor["skill_ready"] = {"hoa_cau":INF}
    var infinite_skill_cooldown := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(infinite_skill_cooldown).get("ok",false)),
        "snapshot accepted an infinite learned-skill cooldown")

    raw = bytes_to_var(Marshalls.base64_to_raw(str(saved["payload"])))
    raw["casts"] = [{
        "caster":"d0","target_id":"m0","skill_id":"han_suong_an",
        "ready":0.0,"ratio":0.9,"element":"water"
    }]
    var unlearned_cast := _encode_snapshot_payload(saved,raw)
    _check(not bool(MapBattleSnapshotV2.load(unlearned_cast).get("ok",false)),
        "snapshot accepted a pending cast for an unlearned skill")

    # Historical finite v1, continuous v2, and current v3 snapshot layouts.
    var compat_continuous := MapBattleV2.new(90104)
    _check(bool(compat_continuous.setup("s1_compat",[_player([])],[],true).get("ok",false)),
        "continuous compatibility fixture setup")
    var compat_monster := _monster()
    var compat_spawn := compat_continuous.add_continuous_monster({
        "id":"m_compat","spawn_slot_id":"compat_slot","slot_generation":1,
        "species_id":"thanh_lang","race_id":str(compat_monster.get("race_id","beast")),
        "tier":"normal","position":Vector2(12,10),"stats":compat_monster["stats"],
        "hp":100000.0
    })
    _check(bool(compat_spawn.get("ok",false)),"continuous compatibility monster spawn")
    var v3_snapshot := MapBattleSnapshotV2.save(compat_continuous)
    _check(bool(MapBattleSnapshotV2.load(v3_snapshot).get("ok",false)),
        "continuous version 3 snapshot was rejected")
    raw = bytes_to_var(Marshalls.base64_to_raw(str(v3_snapshot["payload"])))
    raw["version"] = MapBattleSnapshotV2.PREVIOUS_VERSION
    raw.erase("pending_kill_events")
    raw.erase("last_spawn_generation")
    var v2_wrapper := v3_snapshot.duplicate(true)
    v2_wrapper["version"] = MapBattleSnapshotV2.PREVIOUS_VERSION
    var v2_snapshot := _encode_snapshot_payload(v2_wrapper,raw)
    _check(bool(MapBattleSnapshotV2.load(v2_snapshot).get("ok",false)),
        "historical continuous version 2 snapshot was rejected")

    # Movement into range must not accumulate basic-action backlog.
    var moving := MapBattleV2.new(90105)
    var moving_player := _player([])
    moving_player["position"] = Vector2(1,1)
    moving_player["move_speed"] = 8.0
    var moving_monster := _monster()
    moving_monster["position"] = Vector2(35,19)
    moving_monster["move_speed"] = 8.0
    _check(bool(moving.setup("s1_move_cadence",[moving_player],[moving_monster]).get("ok",false)),
        "movement cadence fixture setup")
    moving.run(48,false)
    var first_basic_time := INF
    var basic_by_time := {}
    var duplicate_basic_step := false
    for event in moving.events:
        if str(event.get("type","")) == "move":
            basic_by_time["moved"] = true
        if str(event.get("type","")) == "hit" and str(event.get("attacker","")) == "d0" and str(event.get("kind","")) == "basic":
            first_basic_time = minf(first_basic_time,float(event.get("time",INF)))
            var time_key := str(event.get("time",-1.0))
            if basic_by_time.has(time_key):
                duplicate_basic_step = true
            basic_by_time[time_key] = true
    _check(basic_by_time.has("moved") and first_basic_time > 0.25,
        "movement into range did not produce a delayed basic attack")
    _check(not duplicate_basic_step,
        "movement generated multiple basic hits in one simulation step")

    # Weaken replacement is strongest-only, reduces outgoing damage, and does
    # not affect the independent healing path.
    var weaken_battle := MapBattleV2.new(90106)
    _check(bool(weaken_battle.setup("s1_weaken",[_player(["chan_son_quyen","han_suong_an"])],[_monster()]).get("ok",false)),
        "weaken fixture setup")
    weaken_battle.now = 1.0
    var weak_caster: Dictionary = weaken_battle.actors["d0"]
    var weak_target: Dictionary = weaken_battle.actors["m0"]
    weaken_battle._apply_skill_status(weak_caster,weak_target,"chan_son_quyen",CombatSkillSystem.SKILLS["chan_son_quyen"])
    weaken_battle._apply_skill_status(weak_caster,weak_target,"han_suong_an",CombatSkillSystem.SKILLS["han_suong_an"])
    weaken_battle.now = 2.0
    weaken_battle._apply_skill_status(weak_caster,weak_target,"chan_son_quyen",CombatSkillSystem.SKILLS["chan_son_quyen"])
    var applied_weaken: Dictionary = weak_target["status_effects"]["weaken"]
    _check(absf(float(applied_weaken["factor"])-0.72)<0.00001 and absf(float(applied_weaken["until"])-5.0)<0.00001,
        "weaken did not retain strongest factor and authored expiry")

    var normal_strike := MapBattleV2.new(90107)
    var weak_strike := MapBattleV2.new(90107)
    normal_strike.setup("s1_weaken_damage",[_player([])],[_monster()])
    weak_strike.setup("s1_weaken_damage",[_player([])],[_monster()])
    weak_strike.actors["d0"]["status_effects"] = {
        "weaken":{"caster":"m0","skill_id":"chan_son_quyen","until":5.0,"factor":0.5}
    }
    var normal_damage := normal_strike._deal_direct(normal_strike.actors["d0"],normal_strike.actors["m0"],1.0,"test",false,"",false)
    var weakened_damage := weak_strike._deal_direct(weak_strike.actors["d0"],weak_strike.actors["m0"],1.0,"test",false,"",false)
    _check(normal_damage > 0.0 and absf(weakened_damage-normal_damage*0.5)<0.00001,
        "weaken did not reduce the affected actor's outgoing damage only")

    var healer_row := _player([])
    healer_row["role"] = "healer"
    var ally_row: Dictionary = _player([]).duplicate(true)
    ally_row["id"] = "d1"
    ally_row["hp"] = 5000.0
    var healer_test := MapBattleV2.new(90108)
    healer_test.setup("s1_weaken_heal",[healer_row,ally_row],[_monster()])
    healer_test.actors["d0"]["status_effects"] = {
        "weaken":{"caster":"m0","skill_id":"chan_son_quyen","until":5.0,"factor":0.2}
    }
    _check(healer_test._heal_ally(healer_test.actors["d0"]) and
        absf(float(healer_test.actors["d1"]["hp"])-5180.0)<0.00001,
        "weaken incorrectly reduced an ordinary heal")

    # The current pilot clears burn when its caster is downed. This is recorded
    # and tested here; changing that rule needs a separate design decision.
    var caster_death := MapBattleV2.new(90109)
    caster_death.setup("s1_burn_caster_down",[_player(["hoa_cau"])],[_monster()])
    caster_death._apply_skill_status(caster_death.actors["d0"],caster_death.actors["m0"],
        "hoa_cau",CombatSkillSystem.SKILLS["hoa_cau"])
    caster_death.actors["m0"]["status_effects"]["burn"]["next_tick"] = 0.25
    caster_death.actors["d0"]["hp"] = 0.0
    caster_death.step(false)
    _check(not caster_death.actors["m0"].get("status_effects",{}).has("burn") and
        _count(caster_death,"status_tick")==0,
        "burn caster-down pilot semantics changed")

    # A burn-caused continuous death is journaled once and stays exactly-once
    # after snapshot/reload and further simulation steps.
    var continuous := MapBattleV2.new(90103)
    _check(bool(continuous.setup("s1_burn_kill",[_player(["hoa_cau"])],[],true).get("ok",false)),
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
    print("COMBAT_V3_S1_EDGE_CONTRACT_PASS checks="+str(_checks))
    quit(0)
