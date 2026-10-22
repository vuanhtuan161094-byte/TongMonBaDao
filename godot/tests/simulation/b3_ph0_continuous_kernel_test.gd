extends SceneTree

# B3-PH0: headless-only focused test; synthetic actors are TEST FIXTURES,
# not production disciples, rewards, or a canonical B3 world.
var checks: int = 0

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error("B3-PH0 FAILED: " + message)
        quit(1)
        return false
    checks += 1
    return true

func _disciple() -> Dictionary:
    return {
        "id":"test_disciple", "party_id":"party_0", "role":"frontline",
        "position":Vector2(8.0,10.0),"hp":1000000.0,
        "stats":{"max_hp":1000000.0,"attack":1000000.0,"defense":1000000.0,
            "crit_chance":0.0,"attack_speed":0.0},
        "basic_range":8.0,"basic_interval":1.6,"skill_loadout":[],
        "resistances":{},"context_sources":[],"move_speed":2.0
    }

func _monster(generation: int = 1, instance_id: String = "test_monster") -> Dictionary:
    return {
        "id":instance_id,"species_id":"truc_thu","race_id":"yeu_thu",
        "tier":"normal","spawn_slot_id":"test_slot","slot_generation":generation,
        "position":Vector2(10.0,10.0),"hp":40.0,
        "stats":{"max_hp":40.0,"attack":1.0,"defense":1.0,
            "crit_chance":0.0,"attack_speed":0.0},"resistances":{}
    }

func _battle(world: bool, seed_value: int = 12345) -> MapBattleV2:
    var battle := MapBattleV2.new(seed_value)
    var start := battle.setup("test_world",[_disciple()],[_monster()],world)
    if not _check(bool(start.get("ok",false)),"Battle setup failed: %s" % str(start)):
        return null
    return battle

func _kill_with_real_combat(battle: MapBattleV2) -> float:
    var attacker: Dictionary = battle.actors["test_disciple"]
    var target: Dictionary = battle.actors["test_monster"]
    return battle._deal_direct(attacker,target,1.0,"basic",true)

func _run() -> void:
    if not _test_legacy(): return
    if not _test_long_lived_idle(): return
    if not _test_death_spawn_and_journal(): return
    if not _test_party_wipe_and_backpressure(): return
    if not _test_snapshots(): return
    if not _test_view_parity(): return
    print("B3-PH0 CONTINUOUS KERNEL FOCUSED TEST PASS (%d assertions)" % checks)
    quit(0)

func _test_legacy() -> bool:
    # T01: original finite encounter behavior remains default without opt-in.
    var fin := _battle(false)
    if fin == null: return false
    fin.actors["test_monster"]["hp"] = 0.0
    var result := fin.step(false)
    if not _check(result.get("outcome") == "win" and not fin.active,
        "Finite WIN changed"): return false
    var defeated := _battle(false)
    if defeated == null: return false
    defeated.actors["test_disciple"]["hp"] = 0.0
    result = defeated.step(false)
    if not _check(result.get("outcome") == "defeat" and not defeated.active,
        "Finite DEFEAT changed"): return false
    var timed := MapBattleV2.new(7)
    var mob := _monster()
    mob["hp"] = 1000000000.0
    mob["stats"]["max_hp"] = 1000000000.0
    if not _check(timed.setup("finite_timeout",[_disciple()],[mob]).get("ok",false),
        "Finite timeout setup failed"): return false
    # Force no real combat progress while keeping valid actors.
    timed.actors["test_disciple"]["position"] = Vector2(0.0,0.0)
    timed.actors["test_disciple"]["move_speed"] = 0.0
    timed.actors["test_monster"]["position"] = Vector2(35.0,19.0)
    timed.actors["test_monster"]["move_speed"] = 0.0
    timed.run(400)
    if not _check(timed.outcome == "timeout_retreat" and not timed.active,
        "Finite MAX_SECONDS=90 timeout changed"): return false
    if not _check(not MapBattleV2.new().setup("legacy_empty",[],[],false).get("ok",false),
        "Finite empty roster accepted"): return false
    return true

func _test_long_lived_idle() -> bool:
    # T02/T03/T10: no actors or monsters is a valid, quiescent world owner.
    var b := MapBattleV2.new(1234)
    if not _check(b.setup("empty_world",[],[],true).get("ok",false),
        "Continuous empty world rejected"): return false
    b.run(14500)
    if not _check(b.active and b.outcome == "fighting" and b.now > 3600.0,
        "Continuous run still has a 90-second/one-hour limit"): return false
    if not _check(b.events.size() <= MapBattleV2.MAX_EVENTS,
        "Event history grew without bound"): return false
    var empty_replay := MapBattleSnapshotV2.load(MapBattleSnapshotV2.save(b))
    if not _check(empty_replay.get("ok", false) and
        float(empty_replay["battle"].now) == b.now and
        empty_replay["battle"].actors.is_empty(),
        "Long-running empty world was not restored"): return false
    var one := _monster()
    if not _check(b.add_continuous_monster(one).get("ok",false),
        "Could not dynamically spawn after an empty world"): return false
    if not _check(not b.add_continuous_monster(one).get("ok",false),
        "Duplicate live monster accepted"): return false
    if not _check(b.active and b.outcome == "fighting",
        "World reset after dynamic spawn"): return false
    return true

func _test_death_spawn_and_journal() -> bool:
    # T05/T06/T07: a single true Combat V2 HP0 produces ONE independent
    # persisted domain event, even when VFX has reached MAX_EVENTS.
    var b := _battle(true)
    if b == null: return false
    for i in range(MapBattleV2.MAX_EVENTS):
        b._event("test_display_noise",{"i":i})
    if not _check(b.events.size() == MapBattleV2.MAX_EVENTS,
        "Could not saturate bounded VFX event journal"): return false
    var dealt := _kill_with_real_combat(b)
    if not _check(dealt > 0.0 and b.actors["test_monster"]["hp"] == 0.0,
        "Direct hit never killed monster"): return false
    var pending := b.pending_kill_events()
    if not _check(pending.size() == 1 and
        str(pending[0]["kill_id"]) == "test_world:slot:test_slot:g1",
        "Typed domain event missing or wrong generation"): return false
    pending[0]["kill_id"] = "tampered"
    if not _check(b.pending_kill_events()[0]["kill_id"] != "tampered",
        "Caller could mutate authoritative journal"): return false
    if not _check(_kill_with_real_combat(b) == 0.0 and b.pending_kill_events().size() == 1,
        "Second lethal hit produced a second kill"): return false
    if not _check(b.step(false).get("outcome") == "fighting" and b.active,
        "World produced a WIN after last monster death"): return false
    if not _check(b.remove_downed_monster("test_monster"),
        "Cannot retire real corpse"): return false
    if not _check(not b.add_continuous_monster(_monster(1)).get("ok",false),
        "Old spawn generation was replayed"): return false
    if not _check(b.add_continuous_monster(_monster(2)).get("ok",false),
        "New generation spawn rejected"): return false
    if not _check(b._last_spawn_generation["test_slot"] == 2,
        "Generation watermark did not advance"): return false
    if not _check(_kill_with_real_combat(b) > 0.0 and b.pending_kill_events().size() == 2,
        "Second generation kill missing"): return false
    if not _check(b.pending_kill_events()[1]["kill_id"] != b.pending_kill_events()[0]["kill_id"],
        "Two generations share one kill identity"): return false
    var saved := MapBattleSnapshotV2.save(b)
    var restored := MapBattleSnapshotV2.load(saved)
    if not _check(restored.get("ok",false),"Continuous snapshot with kills rejected"): return false
    var copy: MapBattleV2 = restored["battle"]
    if not _check(copy.pending_kill_events().size() == 2,
        "Kill events vanished on exact snapshot reload"): return false
    if not _check(copy.acknowledge_kill_event("test_world:slot:test_slot:g1") and
        copy.pending_kill_events().size() == 1 and
        not copy.acknowledge_kill_event("test_world:slot:test_slot:g1"),
        "Kill ACK is not exactly-once"): return false
    if not _check(not copy.add_continuous_monster(_monster(1)).get("ok",false),
        "Snapshot lost last used generation"): return false
    return true

func _test_party_wipe_and_backpressure() -> bool:
    # T04: no world DEFEAT when every hunter is down. No fake heal.
    var b := _battle(true)
    if b == null: return false
    b.actors["test_disciple"]["hp"] = 0.0
    var old_time := b.now
    var step_result := b.step(false)
    if not _check(step_result.get("ok",false) and b.active and b.outcome == "fighting"
        and b.now > old_time and b._count_alive("disciple") == 0,
        "Party wipe terminated the world or revived a downed actor"): return false
    # T10: explicit backpressure, never loss from bounded domain journal.
    b._pending_kill_events.resize(MapBattleV2.MAX_PENDING_KILLS)
    old_time = b.now
    step_result = b.step(false)
    if not _check(not step_result.get("ok",false) and
        step_result.get("reason") == "kill_journal_backpressure" and
        b.now == old_time and b.active,
        "Full pending journal silently advanced world"): return false
    return true

func _test_snapshots() -> bool:
    # T08: V3 exact state, legacy v1 reader, B2.4 v2 reader and fail-closed data.
    var original := _battle(true)
    if original == null: return false
    original.run(480)
    var encoded := MapBattleSnapshotV2.save(original)
    if not _check(encoded.get("version") == 3,"PH0 writer isn't version 3"): return false
    var loaded := MapBattleSnapshotV2.load(encoded)
    if not _check(loaded.get("ok",false),"Version 3 snapshot not restored"): return false
    var later: MapBattleV2 = loaded["battle"]
    if not _check(later.continuous_mode and later.now == original.now and
        later.rng.snapshot_seed_state() == original.rng.snapshot_seed_state(),
        "Version 3 restored wrong clock or RNG"): return false
    if not _check(MapBattleSnapshotV2.save(_battle(false)).get("version") == 1,
        "Default finite save must keep legacy V1 writer"): return false
    for old_version in [1,2]:
        var old_battle := _battle(false) if old_version == 1 else _battle(true)
        if old_battle == null: return false
        var wrapped := MapBattleSnapshotV2.save(old_battle)
        var payload: Dictionary = bytes_to_var(Marshalls.base64_to_raw(wrapped["payload"]))
        payload["version"] = old_version
        payload.erase("pending_kill_events")
        payload.erase("last_spawn_generation")
        if old_version == 1:
            payload.erase("continuous_mode")
            payload.erase("external_hit_ids")
        wrapped["version"] = old_version
        wrapped["payload"] = Marshalls.raw_to_base64(var_to_bytes(payload))
        var old_result := MapBattleSnapshotV2.load(wrapped)
        if not _check(old_result.get("ok",false),
            "Legacy snapshot version %d no longer loads" % old_version): return false
        if not _check(bool(old_result["battle"].continuous_mode) == (old_version == 2),
            "Legacy snapshot changed finite/continuous mode"): return false
    var bad := encoded.duplicate(true)
    bad["version"] = 99
    if not _check(not MapBattleSnapshotV2.load(bad).get("ok",false),
        "Unknown future snapshot version accepted"): return false
    bad = encoded.duplicate(true)
    bad["payload"] = "not a base64 variant"
    if not _check(not MapBattleSnapshotV2.load(bad).get("ok",false),
        "Garbage snapshot payload accepted"): return false
    bad = encoded.duplicate(true)
    var corrupted: Dictionary = bytes_to_var(Marshalls.base64_to_raw(encoded["payload"]))
    corrupted["pending_kill_events"] = [{"kill_id":"forged"}]
    bad["payload"] = Marshalls.raw_to_base64(var_to_bytes(corrupted))
    if not _check(not MapBattleSnapshotV2.load(bad).get("ok",false),
        "Forged kill receipt loaded instead of failing closed"): return false
    return true

func _test_view_parity() -> bool:
    # T09: presentation viewed_map must not affect Combat V2 events or RNG.
    var a := _battle(true, 113)
    var b := _battle(true, 113)
    if a == null or b == null: return false
    for i in range(30):
        a.step(false)
        b.step(true)
    if not _check(a.summary() == b.summary() and
        a.pending_kill_events() == b.pending_kill_events() and
        a.rng.snapshot_seed_state() == b.rng.snapshot_seed_state(),
        "viewed_map changed the combat domain"): return false
    return true
