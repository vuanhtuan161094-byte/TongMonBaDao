class_name HuntingPveRunV2
extends RefCounted

# A single real multi-disciple hunting session: stored region-level choice
# -> actual disciple gear/skill sources -> real monster group -> map combat
# -> warehouse reward after victory. Not installed in legacy scheduler yet.
var owner_state: SimulationState
var region_id: String = ""
var spawn_data: Dictionary = {}
var battle: MapBattleV2

func begin(
    state: SimulationState, region: String, encounter_id: String, seed: int,
    party_members: Array
) -> Dictionary:
    if battle != null or state == null or not state.sect.v2_pve_enabled:
        return {"ok":false,"reason":"v2_pve_disabled_or_already_started"}
    if party_members.is_empty() or party_members.size() > MapBattleV2.MAX_DISCIPLES:
        return {"ok":false,"reason":"invalid_party_size"}
    if encounter_id.is_empty() or state.sect.v2_pve_active_runs.has(encounter_id) or state.sect.v2_pve_reward_claims.has(encounter_id) or state.sect.v2_pve_settlement_receipts.has(encounter_id):
        return {"ok":false,"reason":"duplicate_or_empty_encounter_id"}
    var level := HuntingMapV2.selected_level(state,region)
    if not HuntingMapV2.valid_choice(region,level):
        return {"ok":false,"reason":"invalid_map_level"}
    var seen: Dictionary = {}
    var actors: Array = []
    for member in party_members:
        if not (member is Dictionary):
            return {"ok":false,"reason":"invalid_party_member"}
        var record: Dictionary = member
        var disciple_id := str(record.get("disciple_id",""))
        if disciple_id.is_empty() or seen.has(disciple_id):
            return {"ok":false,"reason":"missing_or_duplicate_disciple"}
        seen[disciple_id] = true
        if not state.disciples.has(StringName(disciple_id)):
            return {"ok":false,"reason":"unknown_disciple"}
        var living: DiscipleState = state.disciples[StringName(disciple_id)]
        if living.hp <= 0.0:
            return {"ok":false,"reason":"downed_disciple_not_eligible"}
        if living.injury_level != 0:
            return {"ok":false,"reason":"injured_disciple_not_eligible"}
        if not living.active_pve_encounter_id.is_empty() or _actor_in_active_saved_run(state,disciple_id):
            return {"ok":false,"reason":"disciple_already_in_pve"}
        if living.region_id != &"sect" or not [&"EVALUATE",&"IDLE",&"HOLD"].has(living.current_action):
            return {"ok":false,"reason":"disciple_has_conflicting_action_or_location"}
        var buildings := BuildingSystem.new()
        if not living.work_cycle_state.is_empty() or buildings.disciple_has_active_spirit_plot(state,living.id) or buildings.disciple_has_active_timed_recipe(state,living.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,living):
            return {"ok":false,"reason":"disciple_has_reserved_occupation"}
        # DV2-03 will persist these independently; until then *explicit
        # passed* canonical progress is required, not inferred from P2 power.
        var realm := int(record.get("realm",0))
        var floor_index := int(record.get("floor",0))
        var body_realm := int(record.get("body_realm",0))
        var body_floor := int(record.get("body_floor",0))
        # A real initialized V2 disciple has ONE authority: their saved
        # independent track. Never let the map request spoof their realm.
        if DiscipleRealmProgressV2.valid_profile(living.v2_realm_progress):
            var canonical := DiscipleRealmProgressV2.current(living)
            var c: Dictionary = canonical["cultivation"]
            var b: Dictionary = canonical["body"]
            for field in ["realm","floor","body_realm","body_floor"]:
                var actual: int = int(c["realm"]) if field == "realm" else (
                    int(c["floor"]) if field == "floor" else (
                        int(b["realm"]) if field == "body_realm" else int(b["floor"])))
                if record.has(field) and int(record[field]) != actual:
                    return {"ok":false,"reason":"contradictory_persisted_v2_progress"}
            realm = int(c["realm"])
            floor_index = int(c["floor"])
            body_realm = int(b["realm"])
            body_floor = int(b["floor"])
        var role := str(record.get("role","frontline"))
        var party_id := str(record.get("party_id","party_0"))
        var position: Vector2 = record.get("position",Vector2(8.0,9.0))
        var actor := DiscipleCombatLoadoutV2.build(
            state,living,realm,floor_index,body_realm,body_floor,
            role,position,party_id
        )
        if not bool(actor.get("ok",false)):
            return actor
        # Battle owns HP until terminal; no live object link may leak mutations.
        actor["disciple"] = null
        actors.append(actor)
    actors.sort_custom(func(a,b): return str(a["id"]) < str(b["id"]))
    var spawned := HuntingMapV2.spawn(region,level,encounter_id,seed)
    if not bool(spawned.get("ok",false)):
        return spawned
    var map_battle := MapBattleV2.new(seed)
    var ready := map_battle.setup(encounter_id,actors,spawned["monsters"])
    if not bool(ready.get("ok",false)):
        return ready
    owner_state = state
    region_id = region
    spawn_data = spawned
    battle = map_battle
    var stored := _persist_live_state()
    if not bool(stored.get("ok",false)):
        battle = null
        owner_state = null
        spawn_data.clear()
        return stored
    # Atomically reserve validated actors after their checkpoint exists.
    for actor in actors:
        var participant: DiscipleState = state.disciples[StringName(str(actor["id"]))]
        participant.active_pve_encounter_id = encounter_id
    return {"ok":true,"encounter_id":encounter_id,"region_id":region,
        "level":level,"party_size":actors.size(),"monster_count":spawned["monsters"].size()}

func advance(viewed_map: bool = false) -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_active_session"}
    if owner_state.sect.v2_pve_settlement_receipts.has(battle.encounter_id):
        return {"ok":false,"reason":"encounter_already_settled"}
    var result := battle.step(viewed_map)
    if not bool(result.get("ok",false)):
        return result
    var stored := _persist_live_state()
    if not bool(stored.get("ok",false)):
        return stored
    if not battle.active:
        var settled := _settle_terminal()
        if not bool(settled.get("ok",false)):
            return settled
    return result

func finish(max_steps: int = 400) -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_session"}
    if owner_state.sect.v2_pve_settlement_receipts.has(battle.encounter_id):
        # A second resumed in-memory session may still be at an earlier battle
        # checkpoint. Replay combat locally to compare the immutable terminal
        # receipt, but do NOT persist, settle or mutate DiscipleState again.
        if battle.active:
            battle.run(max_steps,false)
        if battle.active:
            return {"ok":false,"reason":"stale_replay_still_active"}
        var repeated := _settle_terminal()
        if not bool(repeated.get("ok",false)):
            return repeated
        return {"ok":true,"summary":battle.summary(),"already_settled":true}
    if battle.active:
        battle.run(max_steps,false)
    var stored := _persist_live_state()
    if not bool(stored.get("ok",false)):
        return stored
    if battle.active:
        return {"ok":false,"reason":"encounter_still_active","summary":battle.summary()}
    var settled := _settle_terminal()
    if not bool(settled.get("ok",false)):
        return settled
    return {"ok":true,"summary":battle.summary(),"already_settled":bool(settled.get("already_settled",false))}

func claim() -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_session"}
    if battle.active:
        return {"ok":false,"reason":"encounter_not_final"}
    var settled := _settle_terminal()
    if not bool(settled.get("ok",false)):
        return settled
    var result := HuntingMapV2.claim_reward(owner_state,spawn_data,battle)
    if bool(result.get("ok",false)):
        owner_state.sect.v2_pve_active_runs.erase(battle.encounter_id)
    return result

func snapshot() -> Dictionary:
    if battle == null:
        return {"ok":false}
    return {"ok":true,"region_id":region_id,
        "level":int(spawn_data.get("level",0)),
        "encounter_id":str(spawn_data.get("encounter_id","")),
        "summary":battle.summary(),
        "possible_rewards":HuntingMapV2.preview_reward(spawn_data)}


func _persist_live_state() -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_session"}
    if owner_state.sect.v2_pve_reward_claims.has(battle.encounter_id):
        return {"ok":false,"reason":"claimed_encounter_cannot_reopen"}
    if owner_state.sect.v2_pve_settlement_receipts.has(battle.encounter_id):
        return {"ok":false,"reason":"settled_encounter_cannot_reopen"}
    var saved := save_state()
    if bool(saved.get("ok",false)):
        owner_state.sect.v2_pve_active_runs[battle.encounter_id] = saved.duplicate(true)
    return saved


# Older V2 saves can contain a valid active snapshot without a newer
# per-character reservation. Scan those snapshots when admitting new actors.
static func _actor_in_active_saved_run(state: SimulationState, disciple_id: String) -> bool:
    for raw_id in state.sect.v2_pve_active_runs.keys():
        var envelope = state.sect.v2_pve_active_runs[raw_id]
        if not (envelope is Dictionary):
            return true
        var checked := MapBattleSnapshotV2.load(envelope.get("battle",{}))
        if not bool(checked.get("ok",false)):
            return true
        var previous: MapBattleV2 = checked["battle"]
        if previous.active and previous.actors.has(disciple_id):
            return true
    return false

# Commit HP, Injury, auto-return and receipt as one in-memory transaction.
# The existing SaveService persists the whole SimulationState atomically.
func _settle_terminal() -> Dictionary:
    if battle == null or owner_state == null or battle.active:
        return {"ok":false,"reason":"encounter_not_terminal"}
    if not ["win","defeat","timeout_retreat"].has(battle.outcome):
        return {"ok":false,"reason":"invalid_terminal_outcome"}
    var encounter := battle.encounter_id
    var members: Dictionary = {}
    var prepared: Dictionary = {}
    var actor_ids: Array = battle.actors.keys()
    actor_ids.sort()
    for raw_id in actor_ids:
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side","")) != "disciple":
            continue
        var key := str(raw_id)
        if not owner_state.disciples.has(StringName(key)):
            return {"ok":false,"reason":"missing_terminal_disciple"}
        var disciple: DiscipleState = owner_state.disciples[StringName(key)]
        var actor_max := float(actor.get("max_hp",0.0))
        var actor_hp := float(actor.get("hp",-1.0))
        if actor_max <= 0.0 or is_nan(actor_hp) or is_inf(actor_hp) or actor_hp < 0.0 or actor_hp > actor_max or disciple.max_hp <= 0.0:
            return {"ok":false,"reason":"invalid_terminal_hp"}
        var downed := actor_hp <= 0.0
        var new_hp := 1.0 if downed else CombatStatsV2.rescale_current_hp(actor_hp,actor_max,disciple.max_hp)
        members[key] = {"actor_hp":actor_hp,"actor_max_hp":actor_max,"downed":downed}
        prepared[key] = {"hp":minf(disciple.max_hp,new_hp),"injury":1 if downed else 0}
    if members.is_empty():
        return {"ok":false,"reason":"empty_terminal_roster"}
    var previous_receipt = owner_state.sect.v2_pve_settlement_receipts.get(encounter,null)
    if previous_receipt != null:
        if not (previous_receipt is Dictionary):
            return {"ok":false,"reason":"invalid_terminal_receipt"}
        var receipt: Dictionary = previous_receipt
        if str(receipt.get("outcome","")) != battle.outcome or receipt.get("members",{}) != members:
            return {"ok":false,"reason":"conflicting_terminal_replay"}
        return {"ok":true,"already_settled":true}
    if not owner_state.sect.v2_pve_active_runs.has(encounter):
        return {"ok":false,"reason":"terminal_checkpoint_missing"}
    for key in prepared.keys():
        var disciple: DiscipleState = owner_state.disciples[StringName(key)]
        if disciple.active_pve_encounter_id != encounter:
            return {"ok":false,"reason":"missing_terminal_reservation"}
        if disciple.injury_level != 0:
            return {"ok":false,"reason":"participant_already_injured"}
    var when := owner_state.tick
    var ordered: Array = prepared.keys()
    ordered.sort()
    for key in ordered:
        var disciple: DiscipleState = owner_state.disciples[StringName(key)]
        var outcome: Dictionary = prepared[key]
        disciple.hp = float(outcome["hp"])
        disciple.injury_level = int(outcome["injury"])
        disciple.injury_recover_at_tick = when + 120 if disciple.injury_level == 1 else 0
        # GP-02C1 pilot return-to-Sect event has no travel delay.
        disciple.region_id = &"sect"
        disciple.target_region_id = &""
        disciple.current_action = &"EVALUATE"
        disciple.active_pve_encounter_id = ""
    owner_state.sect.v2_pve_settlement_receipts[encounter] = {
        "outcome":battle.outcome,"settled_tick":when,"members":members.duplicate(true)
    }
    if battle.outcome != "win":
        owner_state.sect.v2_pve_active_runs.erase(encounter)
    return {"ok":true,"already_settled":false,"settled_tick":when}

# Production-facing recovery path: only a snapshot already recorded in the
# canonical SectState may resume the encounter. Direct restore_state is a
# validated low-level utility for migration/tests.
static func resume_active(state: SimulationState, encounter_id: String) -> Dictionary:
    if state == null or encounter_id.is_empty():
        return {"ok":false,"reason":"missing_hunt_state"}
    var saved = state.sect.v2_pve_active_runs.get(encounter_id,null)
    if not (saved is Dictionary):
        return {"ok":false,"reason":"no_saved_active_encounter"}
    return restore_state(state,saved)

# Immutable encounter provenance + active fight snapshot. This does NOT
# award any loot, advance the simulation or save object references.
func save_state() -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_hunting_session"}
    var checkpoint := MapBattleSnapshotV2.save(battle)
    if not bool(checkpoint.get("ok",false)):
        return checkpoint
    return {
        "ok":true,"version":1,"region_id":region_id,
        "difficulty":int(spawn_data.get("level",0)),
        "encounter_id":str(spawn_data.get("encounter_id","")),
        "reward_seed":int(spawn_data.get("reward_seed",0)),
        "battle":checkpoint
    }

# The live character HP owner stays separate until DV2-03's real HP track
# migration. Rehydrated actors retain their exact battle HP but do not
# silently overwrite legacy DiscipleState HP or attach unsafe object pointers.
static func restore_state(state: SimulationState, saved: Dictionary) -> Dictionary:
    if state == null or not state.sect.p3_7_resources_enabled or not state.sect.v2_pve_enabled:
        return {"ok":false,"reason":"hunting_v2_not_enabled"}
    if not bool(saved.get("ok",false)) or int(saved.get("version",0)) != 1:
        return {"ok":false,"reason":"unsupported_hunt_save"}
    var region := str(saved.get("region_id",""))
    var level := int(saved.get("difficulty",0))
    var id := str(saved.get("encounter_id",""))
    if id.is_empty() or not HuntingMapV2.valid_choice(region,level) or not state.regions.has(StringName(region)):
        return {"ok":false,"reason":"unknown_saved_map"}
    var battle_data = saved.get("battle",{})
    if not (battle_data is Dictionary):
        return {"ok":false,"reason":"invalid_saved_battle"}
    var decoded := MapBattleSnapshotV2.load(battle_data)
    if not bool(decoded.get("ok",false)):
        return decoded
    var resumed: MapBattleV2 = decoded["battle"]
    if resumed.encounter_id != id:
        return {"ok":false,"reason":"battle_identity_mismatch"}
    var spawned := HuntingMapV2.spawn(region,level,id,int(saved.get("reward_seed",0)))
    if not bool(spawned.get("ok",false)):
        return spawned
    var expected: Dictionary = {}
    for entry in spawned["monsters"]:
        expected[str(entry["id"])] = entry
    var seen_monsters := 0
    var seen_disciples := 0
    for actor_data in resumed.actors.values():
        var row: Dictionary = actor_data
        if str(row["side"]) == "monster":
            seen_monsters += 1
            var actor_id := str(row["id"])
            if not expected.has(actor_id):
                return {"ok":false,"reason":"unexpected_saved_monster"}
            var original: Dictionary = expected[actor_id]
            if str(row.get("species_id","")) != str(original["species_id"]) or \
                str(row.get("tier","")) != str(original["tier"]) or \
                str(row.get("race_id","")) != str(original["race_id"]):
                return {"ok":false,"reason":"monster_provenance_mismatch"}
            if not is_equal_approx(float(row["max_hp"]),float(original["stats"]["max_hp"])):
                return {"ok":false,"reason":"monster_stat_content_incompatible"}
        elif str(row["side"]) == "disciple":
            seen_disciples += 1
            if not state.disciples.has(StringName(str(row["id"]))):
                return {"ok":false,"reason":"unknown_saved_disciple"}
        else:
            return {"ok":false,"reason":"unknown_battle_actor"}
    if seen_monsters != expected.size() or seen_disciples <= 0:
        return {"ok":false,"reason":"incomplete_saved_combat_roster"}
    var session := HuntingPveRunV2.new()
    session.owner_state = state
    session.region_id = region
    session.spawn_data = spawned
    session.battle = resumed
    return {"ok":true,"session":session}
