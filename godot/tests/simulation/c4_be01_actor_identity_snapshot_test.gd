extends SceneTree

# C4-BE01: source-only name/realm fields survive combat and JSON snapshot.
# Never change V2 damage, RNG, time, target selection or the 30x10 ladder.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        push_error("C4 BE01 SOURCE IDENTITY: "+message)
        quit(1)
    return ok

func _run() -> void:
    var state := P37Factory.create_state(94117)
    var ids: Array = state.disciples.keys()
    ids.sort()
    if not _check(not ids.is_empty(),"canonical P37 roster absent"):
        return
    var disciple: DiscipleState = state.disciples[ids[0]]
    var real_actor := DiscipleCombatLoadoutV2.build(
        state,disciple,2,3,4,5,"frontline",Vector2(6.0,9.0),"team_1")
    if not _check(bool(real_actor.get("ok",false)) and
            str(real_actor.get("display_name","")) == str(disciple.display_name) and
            int(real_actor.get("realm_index",0)) == 2 and
            int(real_actor.get("floor_index",0)) == 3 and
            int(real_actor.get("body_realm_index",0)) == 4 and
            int(real_actor.get("body_floor_index",0)) == 5,
            "DiscipleCombatLoadout lost true cultivation/body source coordinates"):
        return
    var monster := MonsterCatalogueV2.create_actor("thanh_lang",2,4,"be01_wolf")
    if not _check(bool(monster.get("ok",false)),"monster source missing"):
        return
    monster["id"] = "be01_wolf"
    monster["position"] = Vector2(8.0,9.0)
    var a := MapBattleV2.new(431199)
    if not _check(bool(a.setup("be01_source",[real_actor],[monster]).get("ok",false)),
            "valid source-ranked battle rejected"):
        return
    var hero_row: Dictionary = a.actors[str(disciple.id)]
    var wolf_row: Dictionary = a.actors["be01_wolf"]
    if not _check(str(hero_row.get("display_name","")) == str(disciple.display_name) and
            int(hero_row.get("realm_index",0)) == 2 and
            int(hero_row.get("floor_index",0)) == 3 and
            int(hero_row.get("body_realm_index",0)) == 4 and
            int(hero_row.get("body_floor_index",0)) == 5 and
            int(wolf_row.get("realm_index",0)) == 2 and
            int(wolf_row.get("floor_index",0)) == 4 and
            str(wolf_row.get("name","")) == "Thanh Lang",
            "MapBattleV2.setup stripped authentic combat identities"):
        return

    var view := MapBattleWorldLayerV2.new()
    view.attach_session(a)
    if not _check(view.combat_actor_label(hero_row) == str(disciple.display_name) and
            view.combat_actor_rank_label(hero_row) == "Luyện Khí · Tầng 3" and
            view.combat_actor_body_label(hero_row) == "Dịch Cân · Tầng 5" and
            view.combat_actor_rank_label(wolf_row) == "Luyện Khí · Tầng 4",
            "HUD rank does not use real battle actor fields"):
        return
    var envelope := MapBattleSnapshotV2.save(a)
    var restored := MapBattleSnapshotV2.load(JSON.parse_string(JSON.stringify(envelope)))
    if not _check(bool(restored.get("ok",false)),
            "snapshot lost authentic rank fields"):
        return
    var b: MapBattleV2 = restored["battle"]
    if not _check(b.actors[str(disciple.id)].get("realm_index",-1) == 2 and
            b.actors[str(disciple.id)].get("body_realm_index",-1) == 4 and
            b.actors["be01_wolf"].get("floor_index",-1) == 4 and
            str(b.actors[str(disciple.id)].get("display_name","")) == str(disciple.display_name) and
            b.actors[str(disciple.id)].get("linked_disciple") == null,
            "save/replay lost source name/rank or reattached live owner"):
        return

    # Identical battles with/without OPTIONAL view identity must generate
    # exactly the same V2 attack events, HP, RNG and movement decisions.
    var legacy_actor: Dictionary = real_actor.duplicate(true)
    for field in ["display_name","realm_index","floor_index",
            "body_realm_index","body_floor_index"]:
        legacy_actor.erase(field)
    var legacy_wolf: Dictionary = monster.duplicate(true)
    for field in ["name","realm_index","floor_index"]:
        legacy_wolf.erase(field)
    var plain := MapBattleV2.new(431199)
    if not _check(bool(plain.setup("be01_source",[legacy_actor],[legacy_wolf]).get("ok",false)),
            "legacy actor without optional metadata must still load"):
        return
    for tick in range(24):
        if not a.active or not plain.active:
            break
        a.step(false)
        plain.step(true)
    if not _check(a.events == plain.events and
            a.rng.snapshot_seed_state() == plain.rng.snapshot_seed_state() and
            is_equal_approx(float(a.actors["be01_wolf"]["hp"]),
                float(plain.actors["be01_wolf"]["hp"])) and
            a.actors[str(disciple.id)]["position"] ==
                plain.actors[str(disciple.id)]["position"],
            "cosmetic identity changed deterministic V2 combat"):
        return
    if not _check(not plain.actors["be01_wolf"].has("realm_index") and
            view.combat_actor_rank_label(plain.actors["be01_wolf"]) == "",
            "legacy actor was silently assigned a fabricated realm"):
        return

    # Fail-closed: partial pair, invalid realm, typed string pretending to be
    # an integer, and monster with forged body channel are all invalid.
    var invalid_rows := [
        {"realm_index":2}, {"realm_index":31,"floor_index":1},
        {"realm_index":"2","floor_index":3},
        {"body_realm_index":3}
    ]
    for patch in invalid_rows:
        var broken: Dictionary = real_actor.duplicate(true)
        for field in patch:
            broken[field] = patch[field]
        if patch.has("realm_index") and not patch.has("floor_index"):
            broken.erase("floor_index")
        if patch.has("body_realm_index") and not patch.has("body_floor_index"):
            broken.erase("body_floor_index")
        var illegal := MapBattleV2.new(101)
        if not _check(not bool(illegal.setup("bad_disc",[broken],[monster]).get("ok",true)),
                "invalid disciple 30x10 metadata accepted: "+str(patch)):
            return
    var invalid_monster: Dictionary = monster.duplicate(true)
    invalid_monster["body_realm_index"] = 1
    invalid_monster["body_floor_index"] = 1
    var illegal_monster := MapBattleV2.new(102)
    if not _check(not bool(illegal_monster.setup("bad_monster",[real_actor],
            [invalid_monster]).get("ok",true)),
            "monster introduced an unowned body track"):
        return

    # Mutated snapshot is rejected without touching world/RNG; V1 legacy
    # payloads lacking optional fields remain compatible.
    var corrupt: Dictionary = envelope.duplicate(true)
    var decoded: Dictionary = bytes_to_var(
        Marshalls.base64_to_raw(str(corrupt["payload"])))
    decoded["actors"][0]["realm_index"] = 30
    decoded["actors"][0]["floor_index"] = 0
    corrupt["payload"] = Marshalls.raw_to_base64(var_to_bytes(decoded))
    if not _check(not bool(MapBattleSnapshotV2.load(corrupt).get("ok",true)),
            "invalid fake saved realm bypassed snapshot validation"):
        return
    var old_style := MapBattleSnapshotV2.save(plain)
    if not _check(bool(MapBattleSnapshotV2.load(old_style).get("ok",false)),
            "pre-identity V1 snapshot compatibility broken"):
        return
    # A legitimate restored Hunt derives monster source realm from the map.
    # Tampering rank/name in a persisted V1 battle must not change identity.
    if not _check(bool(HuntingMapV2.choose_level(
            state,"thanh_truc_lam",1).get("ok",false)),
            "cannot select focused hunting region"):
        return
    var hunt_member := {
        "disciple_id":str(disciple.id),"party_id":"team_1","role":"frontline",
        "position":Vector2(7.0,9.0),
        "realm":1,"floor":1,"body_realm":1,"body_floor":1
    }
    if DiscipleRealmProgressV2.valid_profile(disciple.v2_realm_progress):
        var cultivation: Dictionary = disciple.v2_realm_progress["cultivation"]
        var body: Dictionary = disciple.v2_realm_progress["body"]
        hunt_member["realm"] = int(cultivation["realm"])
        hunt_member["floor"] = int(cultivation["floor"])
        hunt_member["body_realm"] = int(body["realm"])
        hunt_member["body_floor"] = int(body["floor"])
    var hunt := HuntingPveRunV2.new()
    if not _check(bool(hunt.begin(state,"thanh_truc_lam",
            "be01_restore_hunt",121001,[hunt_member]).get("ok",false)),
            "genuine P37 hunting fixture rejected"):
        return
    var canonical_hunt := hunt.save_state()
    if not _check(bool(HuntingPveRunV2.restore_state(
            state,canonical_hunt).get("ok",false)),
            "unmodified hunting checkpoint fails provenance validation"):
        return
    for forged_field in ["realm_index","name"]:
        var envelope_copy: Dictionary = canonical_hunt.duplicate(true)
        var snapshot_copy: Dictionary = envelope_copy["battle"]
        var source_payload: Dictionary = bytes_to_var(
            Marshalls.base64_to_raw(str(snapshot_copy["payload"])))
        for saved_actor in source_payload["actors"]:
            if str(saved_actor.get("side","")) == "monster":
                if forged_field == "realm_index":
                    saved_actor["realm_index"] = 30
                else:
                    saved_actor["name"] = "Quái giả"
                break
        snapshot_copy["payload"] = Marshalls.raw_to_base64(
            var_to_bytes(source_payload))
        envelope_copy["battle"] = snapshot_copy
        if not _check(not bool(HuntingPveRunV2.restore_state(
                state,envelope_copy).get("ok",true)),
                "saved hunting monster passed forged provenance: "+forged_field):
            return
    var legacy_hunt: Dictionary = canonical_hunt.duplicate(true)
    var legacy_blob: Dictionary = legacy_hunt["battle"]
    var legacy_payload: Dictionary = bytes_to_var(
        Marshalls.base64_to_raw(str(legacy_blob["payload"])))
    for saved_actor in legacy_payload["actors"]:
        if str(saved_actor.get("side","")) == "monster":
            for field in ["name","realm_index","floor_index"]:
                saved_actor.erase(field)
    legacy_blob["payload"] = Marshalls.raw_to_base64(
        var_to_bytes(legacy_payload))
    legacy_hunt["battle"] = legacy_blob
    if not _check(bool(HuntingPveRunV2.restore_state(
            state,legacy_hunt).get("ok",false)),
            "legacy V1 hunting saves without rank must remain restorable"):
        return
    view.queue_free()
    print("C4 BE01 SOURCE IDENTITY, 30x10, SNAPSHOT, RNG ISOLATION: PASS")
    quit(0)
