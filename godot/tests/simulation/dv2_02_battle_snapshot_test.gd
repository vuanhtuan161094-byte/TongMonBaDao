extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _assert(ok: bool, msg: String) -> bool:
    if not ok:
        push_error(msg)
        quit(1)
        return false
    return true

func _run() -> void:
    var group: Array = []
    var core: Dictionary = CombatStatsV2.derive(1,1,1,1,0.0)["stats"]
    for i in range(6):
        group.append({
            "id":"disciple_%02d" % i,
            "party_id":"party_a","stats":core.duplicate(true),
            "role":"healer" if i == 3 else ("mage" if i == 2 else "frontline"),
            "position":Vector2(8.0+float(i)*0.5,8.0+float(i%2)*0.5),
            "hp":float(core["max_hp"]),
            "context_sources":[{"source_id":"sect_art","channel":"damage_vs_boss",
                "mode":"percent_add","value":0.12}]
        })
    var mobs: Array = []
    for i in range(5):
        var species := "hac_lang_vuong" if i == 0 else "hac_lang"
        var data := MonsterCatalogueV2.create_actor(species,1,1,"snapshot_group_mob_%d" % i)
        data["id"] = "mob_%02d" % i
        data["position"] = Vector2(13.0+float(i)*0.5,8.0+float(i%2)*0.4)
        mobs.append(data)
    var live := MapBattleV2.new(191919)
    if not _assert(bool(live.setup("battle_snapshot_roundtrip",group,mobs).get("ok",false)),
        "Could not start 6-versus-5 real group battle for snapshot."):
        return
    for i in range(20):
        if not live.active:
            break
        live.step()
    if not _assert(live.active,"Pilot group battle ended before mid-combat snapshot."):
        return
    # Force a valid in-flight boss warning so the test proves its remaining
    # cast delay/geometry, not just actor HP and stat snapshots.
    var boss: Dictionary = live.actors["mob_00"]
    var victim: Dictionary = live.actors["disciple_00"]
    if float(boss["hp"]) > 0.0 and float(victim["hp"]) > 0.0:
        live._begin_telegraphed_aoe(boss,victim)
    var before_save_rng := live.rng.snapshot_seed_state()
    var snapshot := MapBattleSnapshotV2.save(live)
    if not _assert(bool(snapshot.get("ok",false)) and
        int(snapshot["version"]) == MapBattleSnapshotV2.VERSION,
        "Battle snapshot could not serialize the in-flight encounter."):
        return
    # A checkpoint MUST cross actual JSON persistence, including RNG state
    # and 2D coordinates; no String-typed Vector2 ambiguity is permitted.
    var json := JSON.stringify(snapshot)
    var parsed: Dictionary = JSON.parse_string(json)
    if not _assert(parsed is Dictionary and parsed["actors"] is Array and
        parsed["casts"] is Array and parsed["events"] is Array,
        "Battle state is not savegame-safe JSON."):
        return
    var loaded := MapBattleSnapshotV2.load(parsed)
    if not _assert(bool(loaded.get("ok",false)),
        "Valid battle save could not restore: "+str(loaded.get("reason","unknown"))):
        return
    var resumed: MapBattleV2 = loaded["battle"]
    if not _assert(resumed.rng.snapshot_seed_state() == before_save_rng and
        absf(resumed.now-live.now)<0.0000001 and
        resumed.pending_casts.size()==live.pending_casts.size(),
        "Mid-battle restore lost RNG, elapsed time or pending casts."):
        return
    for id in live.actors.keys():
        var lhs: Dictionary = live.actors[id]
        var rhs: Dictionary = resumed.actors[id]
        if not _assert(lhs["position"].distance_to(rhs["position"]) < 0.000001 and
            absf(float(lhs["hp"])-float(rhs["hp"]))<0.00001 and
            rhs["linked_disciple"] == null,
            "Restored actor differs or illegally reattached a legacy owner."):
            return
    var base_result := live.run(400,false)
    var resumed_result := resumed.run(400,true)
    if not _assert(base_result["outcome"] == resumed_result["outcome"] and
        base_result["actions"] == resumed_result["actions"] and
        base_result["downed_disciples"] == resumed_result["downed_disciples"] and
        absf(float(base_result["disciple_remaining_hp_ratio"]) -
            float(resumed_result["disciple_remaining_hp_ratio"])) < 0.000001,
        "Map outcome/health diverged after JSON save and resume."):
        return
    if not _assert(MapBattleSnapshotV2.save(live) == MapBattleSnapshotV2.save(resumed),
        "Combat event journal, cast ordering or final RNG differs on save/resume."):
        return
    # Replay-safe status and rejection of corrupted or old-format saves.
    var completed := MapBattleSnapshotV2.load(
        JSON.parse_string(JSON.stringify(MapBattleSnapshotV2.save(resumed)))
    )
    if not _assert(bool(completed.get("ok",false)) and
        completed["battle"].outcome == resumed.outcome and
        not completed["battle"].active,
        "Finished battle did not retain final outcome across JSON reload."):
        return
    var bad_version: Dictionary = parsed.duplicate(true)
    bad_version["version"] = 999
    if not _assert(not bool(MapBattleSnapshotV2.load(bad_version).get("ok",true)),
        "Future or unknown combat save version was silently accepted."):
        return
    var bad_hp: Dictionary = parsed.duplicate(true)
    bad_hp["actors"][0]["hp"] = -100.0
    if not _assert(not bool(MapBattleSnapshotV2.load(bad_hp).get("ok",true)),
        "Invalid negative HP was accepted from corrupted battle save."):
        return
    var bad_id: Dictionary = parsed.duplicate(true)
    bad_id["actors"][1]["id"] = bad_id["actors"][0]["id"]
    if not _assert(not bool(MapBattleSnapshotV2.load(bad_id).get("ok",true)),
        "Duplicate actor identity was accepted from combat save."):
        return
    var bad_outcome: Dictionary = parsed.duplicate(true)
    bad_outcome["outcome"] = "win"
    if not _assert(not bool(MapBattleSnapshotV2.load(bad_outcome).get("ok",true)),
        "Active fighting state forged a finished win when loading."):
        return
    print("DV2-02 COMBAT SNAPSHOT MID-FIGHT JSON, RNG, HP, CAST, EVENTS: PASS")
    quit(0)
