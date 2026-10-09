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
        # DV2-03 will persist these independently; until then *explicit
        # passed* canonical progress is required, not inferred from P2 power.
        var realm := int(record.get("realm",0))
        var floor_index := int(record.get("floor",0))
        var body_realm := int(record.get("body_realm",0))
        var body_floor := int(record.get("body_floor",0))
        var role := str(record.get("role","frontline"))
        var party_id := str(record.get("party_id","party_0"))
        var position: Vector2 = record.get("position",Vector2(8.0,9.0))
        var actor := DiscipleCombatLoadoutV2.build(
            state,living,realm,floor_index,body_realm,body_floor,
            role,position,party_id
        )
        if not bool(actor.get("ok",false)):
            return actor
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
    return {"ok":true,"encounter_id":encounter_id,"region_id":region,
        "level":level,"party_size":actors.size(),"monster_count":spawned["monsters"].size()}

func advance(viewed_map: bool = false) -> Dictionary:
    if battle == null:
        return {"ok":false,"reason":"no_active_session"}
    return battle.step(viewed_map)

func finish(max_steps: int = 400) -> Dictionary:
    if battle == null:
        return {"ok":false,"reason":"no_session"}
    if battle.active:
        battle.run(max_steps,false)
    return {"ok":true,"summary":battle.summary()}

func claim() -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_session"}
    return HuntingMapV2.claim_reward(owner_state,spawn_data,battle)

func snapshot() -> Dictionary:
    if battle == null:
        return {"ok":false}
    return {"ok":true,"region_id":region_id,
        "level":int(spawn_data.get("level",0)),
        "encounter_id":str(spawn_data.get("encounter_id","")),
        "summary":battle.summary(),
        "possible_rewards":HuntingMapV2.preview_reward(spawn_data)}


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
