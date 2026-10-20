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
    var serialized_world_templates: Array = []
    for raw_template in battle._world_monster_templates:
        if not (raw_template is Dictionary):
            continue
        var template: Dictionary = raw_template.duplicate(true)
        template["position"] = _encode_vec2(template.get("position", Vector2.ZERO))
        serialized_world_templates.append(template)
    var payload := {
        "ok":true,"version":VERSION,
        "encounter_id":battle.encounter_id,
        "rng_state":battle.rng.snapshot_seed_state(),
        "time":battle.now,"active":battle.active,"outcome":battle.outcome,
        "actions":battle.actions,"downed_disciples":battle.downed_disciples,
        "continuous_world":battle.continuous_world,
        "world_waves_completed":battle.world_waves_completed,
        "world_respawn_at":battle._world_respawn_at,
        "event_sequence":battle.event_sequence,
        "navigation_grid":battle.navigation_grid.duplicate(true),
        "world_monster_templates":serialized_world_templates,
        "actors":serialized_actors,"casts":serialized_casts,"events":serialized_events
    }
    # JSON converts integers to floats and rounds float64 values, changing
    # mid-battle damage and RNG. Godot Variant bytes retain EXACT bit patterns.
    # Use a versioned base64 payload inside JSON, with object decoding OFF.
    return {"ok":true,"version":VERSION,"encoding":"godot_variant_b64",
        "payload":Marshalls.raw_to_base64(var_to_bytes(_canonicalize(payload)))}

static func load(data: Dictionary) -> Dictionary:
    if not bool(data.get("ok",false)) or int(data.get("version",0)) != VERSION:
        return {"ok":false,"reason":"unsupported_battle_snapshot"}
    if str(data.get("encoding","")) != "godot_variant_b64" or not (data.get("payload") is String):
        return {"ok":false,"reason":"invalid_battle_snapshot_encoding"}
    var encoded: String = data["payload"]
    if encoded.is_empty() or encoded.length() > 16000000:
        return {"ok":false,"reason":"invalid_snapshot_size"}
    var bytes := Marshalls.base64_to_raw(encoded)
    if bytes.size() < 16 or bytes.size() > 12000000:
        return {"ok":false,"reason":"invalid_snapshot_binary"}
    var raw = bytes_to_var(bytes)
    if not (raw is Dictionary) or int(raw.get("version",0)) != VERSION:
        return {"ok":false,"reason":"invalid_snapshot_payload"}
    return _restore_payload(raw)

static func _restore_payload(data: Dictionary) -> Dictionary:
    var id := str(data.get("encounter_id",""))
    if id.is_empty() or not (data.get("actors") is Array):
        return {"ok":false,"reason":"missing_encounter_or_actors"}
    var rows: Array = data["actors"]
    if rows.is_empty() or rows.size() > MapBattleV2.MAX_DISCIPLES+MapBattleV2.MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_actor_count"}
    var battle := MapBattleV2.new(515151)
    var grid = data.get("navigation_grid",{})
    if not (grid is Dictionary) or not CombatWorldGridV2.valid(grid):
        return {"ok":false,"reason":"invalid_saved_navigation_grid"}
    battle.navigation_grid = grid.duplicate(true)
    battle.encounter_id = id
    battle.now = float(data.get("time",-1.0))
    battle.active = bool(data.get("active",false))
    battle.outcome = str(data.get("outcome","invalid"))
    battle.actions = int(data.get("actions",-1))
    battle.downed_disciples = int(data.get("downed_disciples",-1))
    battle.continuous_world = bool(data.get("continuous_world", false))
    battle.world_waves_completed = int(data.get("world_waves_completed", 0))
    battle._world_respawn_at = float(data.get("world_respawn_at", -1.0))
    battle.event_sequence = int(data.get("event_sequence", 0))
    if is_nan(battle.now) or is_inf(battle.now) or battle.now < 0.0 or (not battle.continuous_world and battle.now > MapBattleV2.MAX_SECONDS):
        return {"ok":false,"reason":"invalid_elapsed_time"}
    if battle.actions < 0 or battle.downed_disciples < 0 or battle.downed_disciples > MapBattleV2.MAX_DISCIPLES or battle.world_waves_completed < 0 or battle.event_sequence < 0:
        return {"ok":false,"reason":"invalid_action_or_downed_count"}
    if is_nan(battle._world_respawn_at) or is_inf(battle._world_respawn_at) or (battle._world_respawn_at >= 0.0 and battle._world_respawn_at < battle.now):
        return {"ok":false,"reason":"invalid_world_respawn_time"}
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
        if not (pos is Vector2) or not battle.world_bounds().has_point(pos):
            return {"ok":false,"reason":"invalid_actor_position"}
        if not CombatWorldGridV2.walkable(battle.navigation_grid,CombatWorldGridV2.cell_at(pos)):
            return {"ok":false,"reason":"saved_actor_in_blocked_cell"}
        actor["position"] = pos
        if side == "disciple":
            var learned_skill_ids: Array = actor.get("skill_loadout", [])
            var policy_result := AutoSkillPolicyV2.normalize(actor.get("auto_skill_policy", {}), learned_skill_ids)
            if not bool(policy_result.get("ok", false)):
                return {"ok":false,"reason":"invalid_saved_auto_skill_policy:" + str(policy_result.get("reason", "unknown"))}
            actor["auto_skill_policy"] = policy_result["policy"]
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
            if not (center is Vector2) or not battle.world_bounds().has_point(center):
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
        battle.event_sequence = maxi(battle.event_sequence, int(event.get("sequence", 0)))
    var raw_templates = data.get("world_monster_templates", [])
    if not (raw_templates is Array) or raw_templates.size() > MapBattleV2.MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_world_monster_templates"}
    for raw_template in raw_templates:
        if not (raw_template is Dictionary):
            return {"ok":false,"reason":"invalid_world_monster_template"}
        var template: Dictionary = raw_template.duplicate(true)
        var template_id := str(template.get("id", ""))
        var template_pos = _decode_vec2(template.get("position", null))
        if not battle.actors.has(template_id) or str(template.get("side", "")) != "monster" or not (template_pos is Vector2) or not battle.world_bounds().has_point(template_pos):
            return {"ok":false,"reason":"invalid_world_monster_template_identity"}
        var template_stats: Dictionary = template.get("stats", {})
        if template_stats.is_empty() or not is_equal_approx(float(template.get("max_hp", 0.0)), float(template_stats.get("max_hp", -1.0))):
            return {"ok":false,"reason":"invalid_world_monster_template_stats"}
        template["position"] = template_pos
        battle._world_monster_templates.append(template)
    if battle.continuous_world and battle._world_monster_templates.is_empty():
        for actor in battle.actors.values():
            if str(actor.get("side", "")) == "monster":
                battle._world_monster_templates.append((actor as Dictionary).duplicate(true))
    if battle.continuous_world and battle._world_monster_templates.is_empty():
        return {"ok":false,"reason":"missing_continuous_world_templates"}
    var saved_rng = data.get("rng_state",null)
    if not (saved_rng is int):
        return {"ok":false,"reason":"invalid_rng_state"}
    battle.rng.restore_seed_state(saved_rng)
    return {"ok":true,"battle":battle}

static func _encode_vec2(value: Vector2) -> Array:
    return [value.x,value.y]

static func _canonicalize(value: Variant) -> Variant:
    if value is Dictionary:
        var source: Dictionary = value
        var result: Dictionary = {}
        var keys: Array = source.keys()
        keys.sort()
        for key in keys:
            result[key] = _canonicalize(source[key])
        return result
    if value is Array:
        var result: Array = []
        for item in value:
            result.append(_canonicalize(item))
        return result
    return value

static func _decode_vec2(value: Variant) -> Variant:
    if not (value is Array) or value.size() != 2:
        return null
    var x := float(value[0])
    var y := float(value[1])
    if is_nan(x) or is_inf(x) or is_nan(y) or is_inf(y):
        return null
    return Vector2(x,y)
