extends SceneTree

# Focused REAL Combat V2 HP0 evidence for one 10-monster camp.
# TEST actor stats are intentionally synthetic; no loot, EXP or Warehouse
# entitlement is created here and NO complete B3 world is claimed.
func _init() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("PVE MULTICAMP COMBAT HP0 BRIDGE FAIL: "+reason)
    quit(1)

func _disciple() -> Dictionary:
    return {"id":"fixture_hunter","party_id":"party_0","role":"frontline",
        "position":Vector2(8.0,10.0),"hp":1000000.0,
        "stats":{"max_hp":1000000.0,"attack":1000000.0,"defense":1000000.0,
            "crit_chance":0.0,"attack_speed":0.0},
        "basic_range":8.0,"basic_interval":1.6,"skill_loadout":[],
        "resistances":{},"context_sources":[],"move_speed":2.0}

func _mob(index: int) -> Dictionary:
    return {"id":"fixture_wolf_%02d" % index,"species_id":"truc_thu",
        "race_id":"yeu_thu","tier":"normal",
        "spawn_slot_id":PveMultiCampPopulationV1.slot_id(0,index),
        "slot_generation":1,
        "position":Vector2(23.0+float(index%5)*1.1,8.0+float(int(index/5))*1.9),
        "hp":40.0,
        "stats":{"max_hp":40.0,"attack":1.0,"defense":1.0,
            "crit_chance":0.0,"attack_speed":0.0},"resistances":{}}

func _run() -> void:
    var world := PveMultiCampPopulationV1.new_registry(10)
    if not bool(world.get("ok",false)):
        _fail("cannot seed 20-camp slot model")
        return
    var mobs: Array = []
    for i in range(10):
        mobs.append(_mob(i))
    var battle := MapBattleV2.new(20261025)
    var begun := battle.setup("ttl_camp01_test",[_disciple()],mobs,true)
    if not bool(begun.get("ok",false)) or battle._count_monster_records() != 10:
        _fail("actual MapBattleV2 did not host 10 unique real slot actors")
        return
    var attacker: Dictionary = battle.actors["fixture_hunter"]
    var target: Dictionary = battle.actors["fixture_wolf_00"]
    var dealt := battle._deal_direct(attacker,target,1.0,"basic",true)
    if dealt <= 0.0 or float(target["hp"]) != 0.0:
        _fail("actual Combat V2 did not produce HP0 through a legal direct hit")
        return
    var events := battle.pending_kill_events()
    if events.size() != 1:
        _fail("real HP0 did not emit exactly one pending kernel kill")
        return
    var event: Dictionary = events[0]
    var forged := event.duplicate(true)
    forged["monster_instance_id"] = "wrong_monster"
    if bool(PveMultiCampPopulationV1.record_authoritative_battle_kill(
            world,battle,forged,8.0).get("ok",false)):
        _fail("forged monster attribution was accepted")
        return
    forged = event.duplicate(true)
    forged["slot_generation"] = 999
    if bool(PveMultiCampPopulationV1.record_authoritative_battle_kill(
            world,battle,forged,8.0).get("ok",false)):
        _fail("forged generation was accepted")
        return
    var before := int(world["slots"][PveMultiCampPopulationV1.slot_id(0,0)]["generation"])
    var caller_copy := event.duplicate(true)
    caller_copy["at_seconds"] = float(event["at_seconds"])+3600.0
    var accepted := PveMultiCampPopulationV1.record_authoritative_battle_kill(
        world,battle,caller_copy,8.0)
    if not is_equal_approx(
            float(world["slots"][PveMultiCampPopulationV1.slot_id(0,0)]["due_at"]),
            float(event["at_seconds"])+8.0):
        _fail("respawn timer did not use the source journal timestamp")
        return
    if not bool(accepted.get("ok",false)) or bool(accepted.get("rewards_granted",true)):
        _fail("genuine Combat V2 HP0 was rejected or illegally paid rewards")
        return
    if bool(PveMultiCampPopulationV1.record_authoritative_battle_kill(
            world,battle,event,8.0).get("ok",false)):
        _fail("one real HP0 was registered twice")
        return
    var pending_id := PveMultiCampPopulationV1.slot_id(0,0)
    if int(world["slots"][pending_id]["generation"]) != before or str(world["slots"][pending_id]["phase"]) != "UNPAID_HP0":
        _fail("real kernel event did not enter correct unpaid-life barrier")
        return
    if battle.pending_kill_events().size() != 1:
        _fail("population-only bridge destroyed original Combat kill event")
        return
    var saved := JSON.stringify(world)
    var loaded: Dictionary = JSON.parse_string(saved)
    if PveMultiCampPopulationV1.verify_structure(loaded) != "":
        _fail("real HP0 registry could not survive a JSON round trip")
        return
    print("PVE MULTICAMP COMBAT HP0 BRIDGE PASS local_monsters=10 real_combat_hp0=true journal_checked=true unpaid_receipt=true reward=none")
    quit(0)
