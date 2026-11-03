class_name PveDistributedWorldV1
extends RefCounted

# PVE-P0: one persistent 192x192 Source A world with at most 30 independent
# hunters and a 200-slot registry. Only the zones near active hunters load
# monster actors. Offscreen monster AI is dormant; spawn timers stay canonical.
# This module does not invent drops, XP, actors or second runtime clocks.

const MAX_HUNTERS := MapBattleV2.MAX_DISCIPLES
const MAX_ACTIVE_MONSTERS := MapBattleV2.MAX_MONSTERS
const HUNT_RADIUS := 18.0
const MAX_DORMANT_BYTES := 32768

static func enabled(population: Dictionary) -> bool:
    return bool(population.get("p0_distributed_world",false))

static func zone_for_point(centers: Array, point: Vector2) -> int:
    if centers.size() != PveMultiCampPopulationV1.CAMP_COUNT:
        return -1
    var nearest := -1
    var best := INF
    for index in range(centers.size()):
        var row: Dictionary = centers[index]
        var at := Vector2(float(row.get("x",-1)),float(row.get("y",-1)))
        var distance := point.distance_squared_to(at)
        if distance+0.000001 < best:
            best = distance
            nearest = index
    return nearest

static func requested_camps(session: HuntingPveRunV2) -> Array[int]:
    var result: Array[int] = []
    if session == null or session.battle == null:
        return result
    var centers: Array = session.camp_population.get("world_camp_positions",[])
    var ids: Array = session.battle.actors.keys()
    ids.sort()
    var destination_zones: Array[int] = []
    for raw_id in ids:
        var actor: Dictionary = session.battle.actors[raw_id]
        if str(actor.get("side","")) != "disciple" or float(actor.get("hp",0.0)) <= 0.0:
            continue
        # Keep the *physical* camp active while its hunter is walking.
        # Replacing current position with the destination deactivated living
        # monsters under the hunter long before arrival. Preload the target as
        # an additional zone, never as a replacement for the present zone.
        var at: Vector2 = actor.get("position",Vector2.ZERO)
        var current_zone := zone_for_point(centers,at)
        if current_zone >= 0 and not result.has(current_zone):
            result.append(current_zone)
        if bool(actor.get("move_order_active",false)):
            var target: Vector2 = actor.get("move_order_position",at)
            var destination_zone := zone_for_point(centers,target)
            if destination_zone >= 0 and not destination_zones.has(destination_zone):
                destination_zones.append(destination_zone)
    # Physical occupancy always takes priority. World has exactly 20 camps;
    # this does not create new zones, NPC lives, or more than 40 live actors.
    for target_zone in destination_zones:
        if not result.has(target_zone):
            result.append(target_zone)
    result.sort()
    return result

static func desired_slots(session: HuntingPveRunV2) -> Dictionary:
    var zones := requested_camps(session)
    if zones.is_empty():
        return {"ok":false,"reason":"distributed_world_has_no_living_hunters"}
    # At 20 occupied zones this selects 2 monsters per zone; at one zone,
    # all ten local slots can be active. Registered 200 stay persistent.
    var per_zone := mini(PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP,
        maxi(1,int(MAX_ACTIVE_MONSTERS/zones.size())))
    var ids: Array[String] = []
    for zone in zones:
        for ordinal in range(per_zone):
            ids.append(PveMultiCampPopulationV1.slot_id(zone,ordinal))
    if ids.size() > MAX_ACTIVE_MONSTERS:
        return {"ok":false,"reason":"distributed_active_monster_cap"}
    return {"ok":true,"camps":zones,"slots":ids,"per_zone":per_zone}

static func _decode_dormant(encoded: Variant) -> Dictionary:
    if not (encoded is String) or str(encoded).is_empty() or str(encoded).length() > MAX_DORMANT_BYTES:
        return {}
    var raw := Marshalls.base64_to_raw(str(encoded))
    if raw.is_empty() or raw.size() > MAX_DORMANT_BYTES:
        return {}
    var decoded = bytes_to_var(raw)
    return decoded if decoded is Dictionary else {}

static func _validate_dormant_actor(session: HuntingPveRunV2,slot_id: String,row: Dictionary) -> bool:
    var b := session.battle
    var registry: Dictionary = session.camp_population
    var slot: Dictionary = registry.get("slots",{}).get(slot_id,{})
    var actor_id := str(row.get("id",""))
    var at = row.get("position",null)
    var home = row.get("home_position",at)
    return not slot.is_empty() and str(slot.get("phase","")) == "READY" \
        and str(row.get("side","")) == "monster" and not actor_id.is_empty() \
        and str(row.get("spawn_slot_id","")) == slot_id \
        and int(row.get("slot_generation",0)) == int(slot.get("generation",0)) \
        and actor_id == "%s/%s/g%d" % [b.encounter_id,slot_id,int(slot.get("generation",0))] \
        and at is Vector2 and home is Vector2 \
        and b.is_world_position_allowed(at) and b.is_world_position_allowed(home) \
        and float(row.get("hp",0.0)) > 0.0 \
        and float(row.get("hp",0.0)) <= float(row.get("max_hp",0.0)) \
        and float(row.get("max_hp",0.0)) > 0.0 \
        and row.get("stats",{}) is Dictionary \
        and str(row.get("tier","")) == "normal" \
        and HuntingMapV2.REGION_CONTENT[PveMultiCampPopulationV1.ZONE]["normal"].has(
            str(row.get("species_id","")))

static func validate_saved(session: HuntingPveRunV2) -> String:
    if session == null or session.battle == null or not session.battle.world_mode:
        return "p0_distributed_missing_world"
    var registry: Dictionary = session.camp_population
    if not enabled(registry):
        return ""
    var dormant = registry.get("p0_dormant_monsters",{})
    var camps = registry.get("p0_active_camps",[])
    if not (dormant is Dictionary) or dormant.size() > 200 or not (camps is Array) \
            or camps.size() > PveMultiCampPopulationV1.CAMP_COUNT:
        return "p0_dormant_payload_invalid"
    for raw_id in dormant.keys():
        var slot_id := str(raw_id)
        if not registry.get("slots",{}).has(slot_id):
            return "p0_unknown_dormant_slot"
        var actor := _decode_dormant(dormant[raw_id])
        if not _validate_dormant_actor(session,slot_id,actor):
            return "p0_dormant_actor_invalid"
    # One receipt per slot is retained across generations. Validate that a
    # cold-loaded world cannot reuse a paid life or accept a fake generation.
    var slots: Dictionary = registry.get("slots",{})
    var rewards = registry.get("p0_kill_rewards",{})
    if not (rewards is Dictionary) or rewards.size() > slots.size():
        return "p0_reward_ledger_invalid"
    for raw_slot_id in rewards.keys():
        var slot_id := str(raw_slot_id)
        if not slots.has(slot_id) or not (rewards[raw_slot_id] is Dictionary):
            return "p0_reward_receipt_unknown_slot"
        var receipt: Dictionary = rewards[raw_slot_id]
        var slot: Dictionary = slots[slot_id]
        var life := int(receipt.get("generation",0))
        var current_life := int(slot.get("generation",0))
        var expected_kill := "%s:slot:%s:g%d" % [b.encounter_id,slot_id,life]
        if int(receipt.get("version",0)) != PvePerKillRewardV1.VERSION \
                or life < 1 or life > current_life \
                or str(receipt.get("slot_id","")) != slot_id \
                or str(receipt.get("kill_id","")) != expected_kill \
                or str(receipt.get("killer_actor_id","")).is_empty() \
                or not ["DROPPED","NO_DROP"].has(str(receipt.get("disposition",""))) \
                or not (receipt.get("items",null) is Dictionary) \
                or not (receipt.get("actor_xp",null) is Dictionary):
            return "p0_reward_receipt_identity_invalid"
        if life == current_life and (str(slot.get("phase","")) == "READY" \
                or str(slot.get("kill_id","")) != expected_kill):
            return "p0_reward_receipt_life_mismatch"
    for raw_slot_id in slots.keys():
        var slot_id := str(raw_slot_id)
        var slot: Dictionary = slots[raw_slot_id]
        if str(slot.get("phase","")) == "COOLDOWN":
            var paid = rewards.get(slot_id,{})
            if not (paid is Dictionary) \
                    or str(paid.get("kill_id","")) != str(slot.get("kill_id","")):
                return "p0_cooldown_without_paid_receipt"
    return ""

static func safe_spawn_position(battle: MapBattleV2,slot_position: Vector2) -> Vector2:
    # A freshly activated or respawned mob may not overlap a living hunter.
    # The slot identity stays at its authored coordinate; only the visible
    # actor is offset by a few WALKABLE cells if the slot itself is occupied.
    # Empty geometry returns Vector2.INF: keep the life READY, retry later.
    var original := Vector2i(floori(slot_position.x),floori(slot_position.y))
    for radius in range(0,6):
        for dy in range(-radius,radius+1):
            for dx in range(-radius,radius+1):
                if maxi(absi(dx),absi(dy)) != radius:
                    continue
                var candidate := original+Vector2i(dx,dy)
                var point := Vector2(candidate)+Vector2(0.5,0.5)
                if not battle.is_world_position_allowed(point):
                    continue
                var occupied := false
                for actor_value in battle.actors.values():
                    var actor: Dictionary = actor_value
                    if float(actor.get("hp",0.0)) <= 0.0:
                        continue
                    var other: Vector2 = actor.get("position",Vector2.INF)
                    if point.distance_squared_to(other) < 0.64:
                        occupied = true
                        break
                if not occupied:
                    return point
    return Vector2.INF

static func synchronize(session: HuntingPveRunV2) -> Dictionary:
    if session == null or session.battle == null or not session.battle.world_mode:
        return {"ok":false,"reason":"p0_distributed_world_not_active"}
    if not enabled(session.camp_population):
        return {"ok":true,"changed":false,"activated":0,"deactivated":0}
    var plan := desired_slots(session)
    if not bool(plan.get("ok",false)):
        return plan
    var desired: Array = plan["slots"]
    var active_previous: Array = session.camp_slot_ids
    var registry: Dictionary = session.camp_population
    var dormant: Dictionary = registry.get("p0_dormant_monsters",{})
    if not (dormant is Dictionary):
        return {"ok":false,"reason":"p0_invalid_dormant_table"}
    var ids: Array = session.battle.actors.keys()
    ids.sort()
    var deactivated := 0
    # Never evict an unacknowledged HP=0 event; the caller must settle it first.
    var pending_slots: Dictionary = {}
    for event in session.battle.pending_kill_events():
        pending_slots[str(event.get("spawn_slot_id",""))] = true
    for actor_id in ids:
        var actor: Dictionary = session.battle.actors.get(actor_id,{})
        if str(actor.get("side","")) != "monster":
            continue
        var slot_id := str(actor.get("spawn_slot_id",""))
        if desired.has(slot_id):
            continue
        if pending_slots.has(slot_id):
            return {"ok":false,"reason":"p0_pending_kill_must_settle_before_lod"}
        if float(actor.get("hp",0.0)) > 0.0:
            var saved_actor := actor.duplicate(true)
            saved_actor["linked_disciple"] = null
            var encoded := Marshalls.raw_to_base64(var_to_bytes(saved_actor))
            if encoded.length() > MAX_DORMANT_BYTES:
                return {"ok":false,"reason":"p0_dormant_actor_too_large"}
            dormant[slot_id] = encoded
        var removed := session.battle.suspend_world_monster(str(actor_id))
        if not bool(removed.get("ok",false)):
            return removed
        deactivated += 1
    var activated := 0
    for slot_id_value in desired:
        var slot_id := str(slot_id_value)
        var slot: Dictionary = registry["slots"].get(slot_id,{})
        if slot.is_empty() or str(slot.get("phase","")) != "READY":
            continue
        var already_active := false
        for a in session.battle.actors.values():
            if str(a.get("side","")) == "monster" and str(a.get("spawn_slot_id","")) == slot_id:
                already_active = true
                break
        if already_active:
            continue
        var loaded: Dictionary = _decode_dormant(dormant.get(slot_id,""))
        if not loaded.is_empty():
            if not _validate_dormant_actor(session,slot_id,loaded):
                return {"ok":false,"reason":"p0_corrupt_dormant_actor"}
            var restored := session.battle.reactivate_world_monster(loaded)
            if not bool(restored.get("ok",false)):
                return restored
            dormant.erase(slot_id)
        else:
            var prefix := slot_id.substr(0,3)
            var zone := -1
            for index in range(PveMultiCampPopulationV1.CAMP_COUNT):
                if prefix == PveMultiCampPopulationV1.camp_id(index):
                    zone = index
                    break
            if zone < 0:
                return {"ok":false,"reason":"p0_invalid_slot_camp"}
            var ordinal := slot_id.get_slice("S",1).to_int()-1
            var rows := session._build_camp_monsters(session.battle.encounter_id,
                int(session.spawn_data.get("reward_seed",0)),registry,zone,
                PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP)
            if ordinal < 0 or ordinal >= rows.size():
                return {"ok":false,"reason":"p0_spawn_ordinal_missing"}
            var row: Dictionary = rows[ordinal]
            var position := Vector2(float(slot.get("world_x",-1)),float(slot.get("world_y",-1)))
            if not session.battle.is_world_position_allowed(position):
                return {"ok":false,"reason":"p0_spawn_not_walkable"}
            var spawn_position := safe_spawn_position(session.battle,position)
            if not is_finite(spawn_position.x):
                # A crowded spawn cannot interrupt the whole world clock.
                # Leave the registered slot READY and retry next simulation
                # frame without creating a new life or issuing any loot.
                continue
            row["position"] = spawn_position
            row["home_position"] = position
            var added := session.battle.add_continuous_monster(row)
            if not bool(added.get("ok",false)):
                return {"ok":false,"reason":"p0_spawn_failed","detail":added.get("reason","unknown")}
        activated += 1
    registry["p0_dormant_monsters"] = dormant
    registry["p0_active_camps"] = plan["camps"].duplicate()
    session.camp_slot_ids = desired.duplicate()
    session.camp_index = int(plan["camps"][0])
    var changed := active_previous != desired or activated > 0 or deactivated > 0
    if changed:
        session.battle._event("world_lod_changed",{
            "camps":plan["camps"],"active_slots":desired.size(),
            "activated":activated,"deactivated":deactivated})
    return {"ok":true,"changed":changed,"activated":activated,
        "deactivated":deactivated,"camps":plan["camps"],
        "active_slots":desired.size(),"per_zone":plan["per_zone"]}
