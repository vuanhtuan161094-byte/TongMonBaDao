class_name MapBattleSnapshotV2
extends RefCounted

# DV2-02 stabilization: a truthful checkpoint for ONE in-progress encounter.
# It serializes gameplay state, not a screenshot, and never creates rewards.
# Actor links to the legacy character owner are deliberately NOT persisted:
# those must be rebound by a sanctioned V2 character migration/owner.
# Version 3 is PH0's durable domain kill queue/slot watermark extension.
# Both upstream v1 and B2.4's v2 snapshots remain readable.
# Keep VERSION as the legacy finite writer's public version for DV2 callers.
# PH0 continuous snapshots use a separate schema version.
const VERSION := 1
const PREVIOUS_VERSION := 2
const PH0_VERSION := 3
const OPEN_WORLD_VERSION := 4
const LEGACY_VERSION := VERSION

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
    # Finite legacy worlds retain the EXACT VERSION=1 payload structure.
    # Only opted-in continuous worlds write PH0's versioned domain journal.
    var write_version := OPEN_WORLD_VERSION if battle.world_mode else (PH0_VERSION if battle.continuous_mode else LEGACY_VERSION)
    var payload := {
        "ok":true,"version":write_version,
        "encounter_id":battle.encounter_id,
        "rng_state":battle.rng.snapshot_seed_state(),
        "time":battle.now,"active":battle.active,"outcome":battle.outcome,
        "actions":battle.actions,"downed_disciples":battle.downed_disciples,
        "actors":serialized_actors,"casts":serialized_casts,"events":serialized_events
    }
    if battle.continuous_mode:
        payload["continuous_mode"] = true
        payload["external_hit_ids"] = battle._external_hit_ids.duplicate(true)
        payload["pending_kill_events"] = battle._pending_kill_events.duplicate(true)
        payload["last_spawn_generation"] = battle._last_spawn_generation.duplicate(true)
    if battle.world_mode:
        payload["world_mode"] = true
        payload["world_bounds"] = {"position":_encode_vec2(battle.world_bounds.position),"size":_encode_vec2(battle.world_bounds.size)}
        payload["world_navigation"] = battle.world_navigation.duplicate(true)
        payload["auto_hunt"] = battle.auto_hunt
    # JSON converts integers to floats and rounds float64 values, changing
    # mid-battle damage and RNG. Godot Variant bytes retain EXACT bit patterns.
    # Use a versioned base64 payload inside JSON, with object decoding OFF.
    return {"ok":true,"version":write_version,"encoding":"godot_variant_b64",
        "payload":Marshalls.raw_to_base64(var_to_bytes(payload))}

static func load(data: Dictionary) -> Dictionary:
    var wrapper_version := int(data.get("version", 0))
    if not bool(data.get("ok",false)) or not [LEGACY_VERSION, PREVIOUS_VERSION, PH0_VERSION, OPEN_WORLD_VERSION].has(wrapper_version):
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
    if not (raw is Dictionary) or int(raw.get("version",0)) != wrapper_version:
        return {"ok":false,"reason":"invalid_snapshot_payload"}
    return _restore_payload(raw)

static func _restore_payload(data: Dictionary) -> Dictionary:
    var payload_version := int(data.get("version", 0))
    if not [LEGACY_VERSION, PREVIOUS_VERSION, PH0_VERSION, OPEN_WORLD_VERSION].has(payload_version):
        return {"ok":false,"reason":"unsupported_snapshot_payload_version"}
    var id := str(data.get("encounter_id",""))
    if id.is_empty() or not (data.get("actors") is Array):
        return {"ok":false,"reason":"missing_encounter_or_actors"}
    var rows: Array = data["actors"]
    if rows.size() > MapBattleV2.MAX_DISCIPLES+MapBattleV2.MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_actor_count"}
    var battle := MapBattleV2.new(515151)
    battle.encounter_id = id
    battle.now = float(data.get("time",-1.0))
    battle.active = bool(data.get("active",false))
    battle.outcome = str(data.get("outcome","invalid"))
    battle.actions = int(data.get("actions",-1))
    battle.downed_disciples = int(data.get("downed_disciples",-1))
    battle.continuous_mode = bool(data.get("continuous_mode",false)) if payload_version >= PREVIOUS_VERSION else false
    if payload_version >= OPEN_WORLD_VERSION:
        if not battle.continuous_mode or not bool(data.get("world_mode",false)):
            return {"ok":false,"reason":"invalid_open_world_snapshot_flags"}
        var raw_bounds = data.get("world_bounds",{})
        var bounds_position = _decode_vec2(raw_bounds.get("position",null)) if raw_bounds is Dictionary else null
        var bounds_size = _decode_vec2(raw_bounds.get("size",null)) if raw_bounds is Dictionary else null
        var navigation = data.get("world_navigation",{})
        if not (bounds_position is Vector2) or not (bounds_size is Vector2) or not (navigation is Dictionary):
            return {"ok":false,"reason":"missing_open_world_navigation_snapshot"}
        battle.world_bounds = Rect2(bounds_position,bounds_size)
        battle.world_navigation = navigation.duplicate(true)
        battle.world_mode = true
        battle.auto_hunt = bool(data.get("auto_hunt",true))
        var world_error := battle._validate_world_navigation()
        if not world_error.is_empty():
            return {"ok":false,"reason":world_error}
    if rows.is_empty() and not battle.continuous_mode:
        return {"ok":false,"reason":"invalid_actor_count"}
    var max_time := 1000000000.0 if battle.continuous_mode else MapBattleV2.MAX_SECONDS
    if is_nan(battle.now) or is_inf(battle.now) or battle.now < 0.0 or battle.now > max_time:
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
    var observed_generations: Dictionary = {}
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
        if not (pos is Vector2) or not battle.is_world_position_allowed(pos):
            return {"ok":false,"reason":"invalid_actor_position"}
        actor["position"] = pos
        if battle.world_mode:
            var home = actor.get("home_position",pos)
            var move_order = actor.get("move_order_position",pos)
            if not (home is Vector2) or not battle.is_world_position_allowed(home) or not (move_order is Vector2) or (bool(actor.get("move_order_active",false)) and not battle.is_world_position_allowed(move_order)):
                return {"ok":false,"reason":"invalid_world_actor_order"}
        var stats: Dictionary = actor.get("stats",{})
        if stats.is_empty() or not (actor.get("resistances",{}) is Dictionary):
            return {"ok":false,"reason":"missing_stat_snapshot"}
        var max_hp := float(actor.get("max_hp",0.0))
        var hp := float(actor.get("hp",-1.0))
        if is_nan(hp) or is_inf(hp) or is_nan(max_hp) or is_inf(max_hp) or max_hp <= 0.0 or hp < 0.0 or hp > max_hp:
            return {"ok":false,"reason":"invalid_actor_hp"}
        if absf(max_hp-float(stats.get("max_hp",-1.0))) > 0.00001:
            return {"ok":false,"reason":"max_hp_stat_snapshot_mismatch"}
        var skill_loadout = actor.get("skill_loadout",[])
        var skill_ready = actor.get("skill_ready",{})
        if not (skill_loadout is Array) or skill_loadout.size() > CombatSkillSystem.SKILLS.size():
            return {"ok":false,"reason":"invalid_skill_loadout"}
        if not (skill_ready is Dictionary) or skill_ready.size() > skill_loadout.size():
            return {"ok":false,"reason":"invalid_skill_cooldowns"}
        var observed_skills: Dictionary = {}
        for raw_skill_id in skill_loadout:
            var skill_id := str(raw_skill_id)
            if not CombatSkillSystem.SKILLS.has(skill_id) or observed_skills.has(skill_id):
                return {"ok":false,"reason":"invalid_skill_loadout"}
            observed_skills[skill_id] = true
        for raw_skill_id in skill_ready.keys():
            var skill_id := str(raw_skill_id)
            var ready_value = skill_ready[raw_skill_id]
            if (not observed_skills.has(skill_id) or not (ready_value is int or ready_value is float) or
                is_nan(float(ready_value)) or is_inf(float(ready_value)) or
                float(ready_value) < 0.0 or float(ready_value) > max_time+90.0):
                return {"ok":false,"reason":"invalid_skill_cooldowns"}
        for timer_key in ["next_basic","next_skill"]:
            var timer_value = actor.get(timer_key,0.0)
            if (not (timer_value is int or timer_value is float) or
                is_nan(float(timer_value)) or is_inf(float(timer_value)) or
                float(timer_value) < 0.0 or float(timer_value) > max_time+90.0):
                return {"ok":false,"reason":"invalid_actor_action_timer"}
        var generic_guard_until = actor.get("guard_until",-1.0)
        if (not (generic_guard_until is int or generic_guard_until is float) or
            is_nan(float(generic_guard_until)) or is_inf(float(generic_guard_until)) or
            float(generic_guard_until) < -1.0 or float(generic_guard_until) > max_time+90.0):
            return {"ok":false,"reason":"invalid_role_guard_timer"}
        # Validate S1 authoritative statuses before replaying untrusted bytes.
        var statuses = actor.get("status_effects",{})
        if not (statuses is Dictionary) or statuses.size() > 3:
            return {"ok":false,"reason":"invalid_combat_status_map"}
        for status_key in statuses.keys():
            if str(status_key) == "v63_poison":
                var stacks = statuses[status_key]
                if not (stacks is Array) or stacks.size() > 30:
                    return {"ok":false,"reason":"invalid_owned_poison_stack_count"}
                var owner_counts: Dictionary = {}
                var stack_keys: Dictionary = {}
                for stack in stacks:
                    if not (stack is Dictionary):
                        return {"ok":false,"reason":"invalid_owned_poison_record"}
                    var owner_id := str(stack.get("owner_id", ""))
                    var key := "%s/%s/%d" % [owner_id,str(stack.get("source_skill_id", "")),int(stack.get("stack_ordinal", -1))]
                    var attack: Dictionary = stack.get("attack_snapshot", {})
                    if stack_keys.has(key) or int(stack.get("stack_ordinal", 0)) <= 0 or not is_finite(float(attack.get("attack", -1.0))) or float(attack.get("attack", -1.0)) <= 0.0 or str(stack.get("element", "")) not in CombatStatsV2.ELEMENTS:
                        return {"ok":false,"reason":"invalid_owned_poison_identity_or_attack"}
                    stack_keys[key] = true
                    owner_counts[owner_id] = int(owner_counts.get(owner_id, 0)) + 1
                    var ratio := float(stack.get("ratio", -1.0))
                    var expiry := float(stack.get("expires_at", -1.0))
                    var due := float(stack.get("next_tick", -1.0))
                    if owner_id.is_empty() or int(owner_counts[owner_id]) > 5 or not is_finite(ratio) or ratio < 0.0 or ratio > 0.2 or not is_finite(expiry) or expiry < battle.now or expiry > battle.now + 10.0 or not is_finite(due) or due < battle.now or due > expiry + 1.0 or not (stack.get("attack_snapshot", null) is Dictionary):
                        return {"ok":false,"reason":"invalid_owned_poison_values"}
                continue
            if not ["burn","weaken"].has(str(status_key)):
                return {"ok":false,"reason":"unsupported_combat_status"}
            var status = statuses[status_key]
            if not (status is Dictionary):
                return {"ok":false,"reason":"invalid_combat_status"}
            var until := float(status.get("until",-1.0))
            if is_nan(until) or is_inf(until) or until < 0.0 or until > max_time+90.0:
                return {"ok":false,"reason":"invalid_status_expiry"}
            if str(status.get("caster","")).is_empty() or str(status.get("skill_id","")).is_empty():
                return {"ok":false,"reason":"missing_status_provenance"}
            var factor := float(status.get("ratio",-1.0)) if str(status_key) == "burn" else float(status.get("factor",-1.0))
            if is_nan(factor) or is_inf(factor) or factor < 0.0 or factor > 1.0:
                return {"ok":false,"reason":"invalid_status_factor"}
            if str(status_key) == "burn":
                var due := float(status.get("next_tick",-1.0))
                if is_nan(due) or is_inf(due) or due < 0.0 or due > until+1.0:
                    return {"ok":false,"reason":"invalid_burn_tick"}
                if hp > 0.0 and until > battle.now and due <= battle.now:
                    return {"ok":false,"reason":"stale_burn_tick"}
        var learned_until := float(actor.get("learned_guard_until",-1.0))
        var learned_factor := float(actor.get("learned_guard_factor",1.0))
        if (is_nan(learned_until) or is_inf(learned_until) or learned_until < -1.0 or learned_until > max_time+90.0 or
            is_nan(learned_factor) or is_inf(learned_factor) or learned_factor < 0.01 or learned_factor > 1.0):
            return {"ok":false,"reason":"invalid_learned_guard"}
        if side == "disciple":
            disciples += 1
            var party_id := str(actor.get("party_id",""))
            party_sizes[party_id] = int(party_sizes.get(party_id,0))+1
            if party_id.is_empty() or int(party_sizes[party_id]) > 6:
                return {"ok":false,"reason":"invalid_party_ownership"}
        else:
            monsters += 1
            if battle.continuous_mode:
                var slot := str(actor.get("spawn_slot_id", ""))
                var generation := int(actor.get("slot_generation", 0))
                if slot.is_empty() or generation <= 0 or observed_generations.has(slot):
                    return {"ok":false,"reason":"invalid_monster_spawn_identity"}
                observed_generations[slot] = generation
            if not CombatContextEffectsV2.TIERS.has(str(actor.get("tier",""))) or not CombatContextEffectsV2.RACES.has(str(actor.get("race_id",""))):
                return {"ok":false,"reason":"invalid_monster_identity"}
        # Never deserialize an object pointer from untrusted save data.
        actor["linked_disciple"] = null
        battle.actors[actor_id] = actor
    # Status provenance is checked after all actors are loaded so save order
    # cannot affect whether a valid caster resolves.
    for actor_value in battle.actors.values():
        var actor: Dictionary = actor_value
        var statuses: Dictionary = actor.get("status_effects",{})
        for status_key in statuses.keys():
            if str(status_key) == "v63_poison":
                for stack in statuses[status_key]:
                    var owner_id := str(stack.get("owner_id", ""))
                    var source_id := str(stack.get("source_skill_id", ""))
                    var source: Dictionary = battle.actors.get(owner_id, {})
                    var definition := V63HumanSkillCombatSystem.skill_definition(source_id)
                    if definition.is_empty() and not source.is_empty():
                        definition = V63HumanSkillCombatSystem.boss_skill_definitions(str(source.get("v63_boss_id", ""))).get(source_id, {})
                    if source.is_empty() or str(source.get("side", "")) == str(actor.side) or str(definition.get("effect", "")) != "poison" or (str(source.get("side", "")) == "disciple" and not source.get("v63_skill_loadout", []).has(source_id)):
                        return {"ok":false,"reason":"invalid_owned_poison_provenance"}
                continue
            var status: Dictionary = statuses[status_key]
            var caster_id := str(status.get("caster",""))
            var skill_id := str(status.get("skill_id",""))
            if not battle.actors.has(caster_id):
                return {"ok":false,"reason":"orphan_combat_status_caster"}
            var caster: Dictionary = battle.actors[caster_id]
            var definition: Dictionary = CombatSkillSystem.SKILLS.get(skill_id,{})
            var caster_skills = caster.get("skill_loadout",[])
            if (str(caster.get("side","")) == str(actor.get("side","")) or
                str(definition.get("effect","")) != str(status_key) or
                not (caster_skills is Array) or not caster_skills.has(skill_id)):
                return {"ok":false,"reason":"invalid_combat_status_provenance"}
    if (disciples > MapBattleV2.MAX_DISCIPLES or monsters > MapBattleV2.MAX_MONSTERS or
        (not battle.continuous_mode and (disciples < 1 or monsters < 1))):
        return {"ok":false,"reason":"invalid_combat_side_size"}
    if data["casts"].size() > MapBattleV2.MAX_DISCIPLES+MapBattleV2.MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_cast_count"}
    for cast_raw in data["casts"]:
        if not (cast_raw is Dictionary):
            return {"ok":false,"reason":"invalid_cast"}
        var cast: Dictionary = cast_raw.duplicate(true)
        var caster_id := str(cast.get("caster",""))
        var ready_value = cast.get("ready",null)
        if not (ready_value is int or ready_value is float):
            return {"ok":false,"reason":"invalid_cast_deadline"}
        var ready_at := float(ready_value)
        if (not battle.actors.has(caster_id) or is_nan(ready_at) or is_inf(ready_at) or
            ready_at < battle.now or ready_at > max_time+90.0):
            return {"ok":false,"reason":"orphan_or_past_due_cast"}
        if cast.has("center"):
            var center = _decode_vec2(cast["center"])
            if not (center is Vector2) or not battle.is_world_position_allowed(center):
                return {"ok":false,"reason":"invalid_telegraph_position"}
            cast["center"] = center
        else:
            var target_id := str(cast.get("target_id",""))
            if not battle.actors.has(target_id):
                return {"ok":false,"reason":"invalid_skill_target"}
            var caster: Dictionary = battle.actors[caster_id]
            var target: Dictionary = battle.actors[target_id]
            var skill_id := str(cast.get("skill_id",""))
            var definition: Dictionary = CombatSkillSystem.SKILLS.get(skill_id,{})
            var effect := str(definition.get("effect",""))
            var self_target := bool(definition.get("self_target",false))
            var caster_skills = caster.get("skill_loadout",[])
            var cast_ratio = cast.get("ratio",null)
            if (not (cast_ratio is int or cast_ratio is float) or
                is_nan(float(cast_ratio)) or is_inf(float(cast_ratio)) or
                float(cast_ratio) < 0.0 or float(cast_ratio) > 1000.0 or
                not (caster_skills is Array) or not caster_skills.has(skill_id)):
                return {"ok":false,"reason":"invalid_cast_provenance_or_ratio"}
            var valid_effect := ["damage","burn","weaken","guard"].has(effect)
            if (not valid_effect or
                (self_target and (effect != "guard" or target_id != caster_id)) or
                (not self_target and (target_id == caster_id or
                    str(caster.get("side","")) == str(target.get("side",""))))):
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
    var saved_rng = data.get("rng_state",null)
    if not (saved_rng is int):
        return {"ok":false,"reason":"invalid_rng_state"}
    battle.rng.restore_seed_state(saved_rng)
    var saved_external_hits = data.get("external_hit_ids", {}) if payload_version >= PREVIOUS_VERSION else {}
    if not (saved_external_hits is Dictionary):
        return {"ok":false,"reason":"invalid_external_hit_ids"}
    if saved_external_hits.size() > MapBattleV2.MAX_EXTERNAL_DAMAGE_IDS:
        return {"ok":false,"reason":"external_damage_journal_limit_exceeded"}
    battle._external_hit_ids = saved_external_hits.duplicate(true)
    var generation_map = data.get("last_spawn_generation", {}) if payload_version >= PH0_VERSION else observed_generations
    if not (generation_map is Dictionary) or generation_map.size() > MapBattleV2.MAX_REMEMBERED_SPAWN_SLOTS:
        return {"ok":false,"reason":"invalid_spawn_watermarks"}
    for raw_slot in generation_map.keys():
        var slot := str(raw_slot)
        var generation := int(generation_map[raw_slot])
        if slot.is_empty() or generation <= 0 or generation < int(observed_generations.get(slot, 0)):
            return {"ok":false,"reason":"invalid_spawn_generation_watermark"}
    for raw_slot in observed_generations.keys():
        if not generation_map.has(raw_slot):
            return {"ok":false,"reason":"missing_spawn_generation_watermark"}
    battle._last_spawn_generation = generation_map.duplicate(true)
    var pending = data.get("pending_kill_events", []) if payload_version >= PH0_VERSION else []
    if not (pending is Array) or pending.size() > MapBattleV2.MAX_PENDING_KILLS:
        return {"ok":false,"reason":"invalid_kill_journal"}
    if not battle.continuous_mode and not pending.is_empty():
        return {"ok":false,"reason":"kill_journal_requires_continuous"}
    var kill_ids: Dictionary = {}
    for raw_event in pending:
        if not (raw_event is Dictionary):
            return {"ok":false,"reason":"invalid_kill_event"}
        var event: Dictionary = raw_event
        var kill_id := str(event.get("kill_id", ""))
        var slot := str(event.get("spawn_slot_id", ""))
        var generation := int(event.get("slot_generation", 0))
        var at_time := float(event.get("at_seconds", -1.0))
        var expected := "%s:slot:%s:g%d" % [battle.encounter_id, slot, generation]
        if (kill_id.is_empty() or kill_ids.has(kill_id) or slot.is_empty() or
            generation <= 0 or kill_id != expected or
            generation > int(generation_map.get(slot, 0)) or
            is_nan(at_time) or is_inf(at_time) or at_time < 0.0 or at_time > battle.now or
            str(event.get("monster_instance_id", "")).is_empty()):
            return {"ok":false,"reason":"invalid_kill_event_identity"}
        kill_ids[kill_id] = true
    battle._pending_kill_events = pending.duplicate(true)
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
