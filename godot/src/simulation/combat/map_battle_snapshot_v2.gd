class_name MapBattleSnapshotV2
extends RefCounted

# DV2-02 stabilization: a truthful checkpoint for ONE in-progress encounter.
# It serializes gameplay state, not a screenshot, and never creates rewards.
# Actor links to the legacy character owner are deliberately NOT persisted:
# those must be rebound by a sanctioned V2 character migration/owner.
const VERSION := 1

static func save(battle: MapBattleV2) -> Dictionary:
    if battle == null or battle.encounter_id.is_empty():
        return {"ok":false,"reason":"no_battle_to_snapshot"}
    var serialized_actors: Array = []
    var ids: Array = battle.actors.keys()
    ids.sort()
    for raw_id in ids:
        var actor: Dictionary = battle.actors[raw_id].duplicate(true)
        actor.erase("linked_disciple")
        actor["position"] = _encode_vec2(actor.get("position",Vector2.ZERO))
        serialized_actors.append(actor)
    var serialized_casts: Array = []
    for entry in battle.pending_casts:
        var cast: Dictionary = entry.duplicate(true)
        if cast.has("center"):
            cast["center"] = _encode_vec2(cast["center"])
        serialized_casts.append(cast)
    var serialized_events: Array = []
    for entry in battle.events:
        var event: Dictionary = entry.duplicate(true)
        for field in ["center","position"]:
            if event.has(field):
                event[field] = _encode_vec2(event[field])
        serialized_events.append(event)
    return {
        "ok":true,"version":VERSION,
        "encounter_id":battle.encounter_id,
        # JSON integers above 2^53 lose RNG bits; encode signed int64 as TEXT.
        "rng_state":str(battle.rng.snapshot_seed_state()),
        "time":battle.now,"active":battle.active,"outcome":battle.outcome,
        "actions":battle.actions,"downed_disciples":battle.downed_disciples,
        "actors":serialized_actors,"casts":serialized_casts,"events":serialized_events
    }

static func load(data: Dictionary) -> Dictionary:
    if not bool(data.get("ok",false)) or int(data.get("version",0)) != VERSION:
        return {"ok":false,"reason":"unsupported_battle_snapshot"}
    var id := str(data.get("encounter_id",""))
    if id.is_empty() or not (data.get("actors") is Array):
        return {"ok":false,"reason":"missing_encounter_or_actors"}
    var rows: Array = data["actors"]
    if rows.is_empty() or rows.size() > MapBattleV2.MAX_DISCIPLES+MapBattleV2.MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_actor_count"}
    var battle := MapBattleV2.new(515151)
    battle.encounter_id = id
    battle.now = float(data.get("time",-1.0))
    battle.active = bool(data.get("active",false))
    battle.outcome = str(data.get("outcome","invalid"))
    battle.actions = int(data.get("actions",-1))
    battle.downed_disciples = int(data.get("downed_disciples",-1))
    if is_nan(battle.now) or is_inf(battle.now) or battle.now < 0.0 or battle.now > MapBattleV2.MAX_SECONDS:
        return {"ok":false,"reason":"invalid_elapsed_time"}
    if battle.actions < 0 or battle.downed_disciples < 0 or battle.downed_disciples > MapBattleV2.MAX_DISCIPLES:
        return {"ok":false,"reason":"invalid_action_or_downed_count"}
    if battle.active and battle.outcome != "fighting":
        return {"ok":false,"reason":"invalid_active_outcome"}
    if not battle.active and not ["win","defeat","timeout_retreat"].has(battle.outcome):
        return {"ok":false,"reason":"invalid_completed_outcome"}
    if not (data.get("casts") is Array) or not (data.get("events") is Array):
        return {"ok":false,"reason":"missing_cast_or_event_list"}
    var party_sizes: Dictionary = {}
    var disciples := 0
    var monsters := 0
    for raw in rows:
        if not (raw is Dictionary):
            return {"ok":false,"reason":"invalid_actor_record"}
        var actor: Dictionary = raw.duplicate(true)
        var actor_id := str(actor.get("id",""))
        var side := str(actor.get("side",""))
        if actor_id.is_empty() or battle.actors.has(actor_id) or not ["disciple","monster"].has(side):
            return {"ok":false,"reason":"invalid_actor_id_or_side"}
        var pos = _decode_vec2(actor.get("position",null))
        if not (pos is Vector2) or not MapBattleV2.ARENA.has_point(pos):
            return {"ok":false,"reason":"invalid_actor_position"}
        actor["position"] = pos
        var stats: Dictionary = actor.get("stats",{})
        if stats.is_empty() or not (actor.get("resistances",{}) is Dictionary):
            return {"ok":false,"reason":"missing_stat_snapshot"}
        var max_hp := float(actor.get("max_hp",0.0))
        var hp := float(actor.get("hp",-1.0))
        if is_nan(hp) or is_inf(hp) or is_nan(max_hp) or is_inf(max_hp) or max_hp <= 0.0 or hp < 0.0 or hp > max_hp:
            return {"ok":false,"reason":"invalid_actor_hp"}
        if absf(max_hp-float(stats.get("max_hp",-1.0))) > 0.00001:
            return {"ok":false,"reason":"max_hp_stat_snapshot_mismatch"}
        if side == "disciple":
            disciples += 1
            var party_id := str(actor.get("party_id",""))
            party_sizes[party_id] = int(party_sizes.get(party_id,0))+1
            if party_id.is_empty() or int(party_sizes[party_id]) > 6:
                return {"ok":false,"reason":"invalid_party_ownership"}
        else:
            monsters += 1
            if not CombatContextEffectsV2.TIERS.has(str(actor.get("tier",""))) or not CombatContextEffectsV2.RACES.has(str(actor.get("race_id",""))):
                return {"ok":false,"reason":"invalid_monster_identity"}
        # Never deserialize an object pointer from untrusted save data.
        actor["linked_disciple"] = null
        battle.actors[actor_id] = actor
    if disciples < 1 or disciples > MapBattleV2.MAX_DISCIPLES or monsters < 1 or monsters > MapBattleV2.MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_combat_side_size"}
    for cast_raw in data["casts"]:
        if not (cast_raw is Dictionary):
            return {"ok":false,"reason":"invalid_cast"}
        var cast: Dictionary = cast_raw.duplicate(true)
        if not battle.actors.has(str(cast.get("caster",""))) or float(cast.get("ready",-1.0)) < battle.now:
            return {"ok":false,"reason":"orphan_or_past_due_cast"}
        if cast.has("center"):
            var center = _decode_vec2(cast["center"])
            if not (center is Vector2) or not MapBattleV2.ARENA.has_point(center):
                return {"ok":false,"reason":"invalid_telegraph_position"}
            cast["center"] = center
        elif not battle.actors.has(str(cast.get("target_id",""))):
            return {"ok":false,"reason":"invalid_skill_target"}
        battle.pending_casts.append(cast)
    if data["events"].size() > MapBattleV2.MAX_EVENTS:
        return {"ok":false,"reason":"event_journal_limit_exceeded"}
    for event_raw in data["events"]:
        if not (event_raw is Dictionary):
            return {"ok":false,"reason":"invalid_event"}
        var event: Dictionary = event_raw.duplicate(true)
        for field in ["center","position"]:
            if event.has(field):
                var coord = _decode_vec2(event[field])
                if not (coord is Vector2):
                    return {"ok":false,"reason":"invalid_event_position"}
                event[field] = coord
        battle.events.append(event)
    var encoded_rng = data.get("rng_state",null)
    if not (encoded_rng is String) or not (encoded_rng as String).is_valid_int():
        return {"ok":false,"reason":"invalid_rng_int64_encoding"}
    battle.rng.restore_seed_state(int(encoded_rng))
    return {"ok":true,"battle":battle}

static func _encode_vec2(value: Vector2) -> Array:
    return [value.x,value.y]

static func _decode_vec2(value: Variant) -> Variant:
    if not (value is Array) or value.size() != 2:
        return null
    var x := float(value[0])
    var y := float(value[1])
    if is_nan(x) or is_inf(x) or is_nan(y) or is_inf(y):
        return null
    return Vector2(x,y)
