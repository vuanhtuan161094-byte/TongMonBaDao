class_name PveP0CommandsV1
extends RefCounted

# Canonical command bridge for the future P3.2 integration writer.
# UI never alters its renderer's battle snapshot directly. One runtime owner,
# one SaveService authority; every successful command returns save_required.
# Caller MUST await LiveGameRuntimeV2.save_async()/wait_for_pending_save().

const ROLES := ["frontline","ranged","mage","healer"]

static func build_members(state: SimulationState, selected_ids: Array,
        roles: Dictionary = {}, voluntary_parties: Dictionary = {}) -> Dictionary:
    # Never auto-create a six-member team. Unknown/duplicate/injured/busy
    # disciples fail closed before the game attempts to begin a hunt.
    if state == null or selected_ids.is_empty() \
            or selected_ids.size() > MapBattleV2.MAX_DISCIPLES:
        return {"ok":false,"reason":"p0_invalid_selected_hunter_count"}
    var seen: Dictionary = {}
    var members: Array = []
    for index in range(selected_ids.size()):
        var id := str(selected_ids[index])
        if id.is_empty() or seen.has(id) or not state.disciples.has(StringName(id)):
            return {"ok":false,"reason":"p0_unknown_or_duplicate_hunter"}
        seen[id] = true
        var member: DiscipleState = state.disciples[StringName(id)]
        if not DiscipleRealmProgressV2.progression_ready(member):
            return {"ok":false,"reason":"p0_member_not_v2"}
        if member.hp <= 0.0 or member.injury_level != 0 \
                or member.region_id != &"sect" \
                or not [&"IDLE",&"EVALUATE",&"HOLD"].has(member.current_action) \
                or not member.active_pve_encounter_id.is_empty() \
                or not member.work_cycle_state.is_empty() \
                or not member.work_progress.is_empty() \
                or not member.worksite_building_id.is_empty():
            return {"ok":false,"reason":"p0_member_busy_injured_or_outside_sect"}
        var buildings := BuildingSystem.new()
        if buildings.disciple_has_active_spirit_plot(state,member.id) \
                or buildings.disciple_has_active_timed_recipe(state,member.id) \
                or not buildings.active_resource_timer_for_worker(state,member.id).is_empty() \
                or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,member):
            return {"ok":false,"reason":"p0_member_has_reserved_occupation"}
        var chosen_role := str(roles.get(id,"frontline"))
        var group_id := str(voluntary_parties.get(id,"solo:"+id))
        if not ROLES.has(chosen_role) or group_id.is_empty():
            return {"ok":false,"reason":"p0_invalid_role_or_group"}
        var profile := DiscipleRealmProgressV2.current(member)
        var cultivation: Dictionary = profile["cultivation"]
        var body: Dictionary = profile["body"]
        members.append({
            "disciple_id":id,"party_id":group_id,"role":chosen_role,
            # begin_multicamp() replaces these finite-arena preflight
            # positions with REAL Source A topology (up to 30 unique cells).
            "position":Vector2(8.0+float(index%6)*0.55,
                8.7+float(int(index/6))*0.55),
            "realm":int(cultivation["realm"]),"floor":int(cultivation["floor"]),
            "body_realm":int(body["realm"]),"body_floor":int(body["floor"])
        })
    var counts: Dictionary = {}
    for raw in members:
        var party_id := str(raw["party_id"])
        counts[party_id] = int(counts.get(party_id,0))+1
        if int(counts[party_id]) > 6:
            return {"ok":false,"reason":"p0_voluntary_team_max_six"}
    return {"ok":true,"members":members,"solo_default":voluntary_parties.is_empty()}

static func deploy(owner: SimulationRuntimeOwnerV2, encounter_id: String,
        seed: int,selected_ids: Array, source_a_options: Dictionary,
        roles: Dictionary = {}, voluntary_parties: Dictionary = {}) -> Dictionary:
    if owner == null or owner.state == null or owner.durable_path.is_empty():
        return {"ok":false,"reason":"p0_requires_durable_new_game"}
    if not bool(source_a_options.get("ok",false)):
        return {"ok":false,"reason":"p0_requires_real_source_a_view"}
    var formed := build_members(owner.state,selected_ids,roles,voluntary_parties)
    if not bool(formed.get("ok",false)):
        return formed
    # The caller must supply topology extracted from the real Source A view.
    # Do not inject fake nav, teleport people or bypass birth/workforce checks.
    var options := source_a_options.duplicate(false)
    options["p0_distributed_world"] = true
    var session := HuntingPveRunV2.new()
    var launched := session.begin_multicamp(
        owner,encounter_id,seed,formed["members"],10,options)
    if not bool(launched.get("ok",false)):
        return launched
    launched["p0_distributed_world"] = true
    launched["voluntary_party_count"] = (
        (formed["members"] as Array).size() if bool(formed["solo_default"]) \
        else _distinct_party_count(formed["members"]))
    return launched

static func _distinct_party_count(members: Array) -> int:
    var groups: Dictionary = {}
    for raw in members:
        groups[str(raw.get("party_id",""))] = true
    return groups.size()

static func _active(owner: SimulationRuntimeOwnerV2) -> Dictionary:
    if owner == null or owner.state == null or owner.durable_path.is_empty() \
            or owner.b3_write_blocked or owner.runtime_write_blocked:
        return {"ok":false,"reason":"p0_runtime_save_retry_required"}
    var encounter := HuntingPveRunV2.active_multicamp_id(owner.state)
    if encounter.is_empty():
        return {"ok":false,"reason":"p0_no_active_hunt"}
    var session := owner.get_active_multicamp_session(encounter)
    if session == null:
        var overrides := owner.scheduler.v63_preview_overrides \
            if owner.scheduler != null else {}
        var restored := HuntingPveRunV2.resume_active(
            owner.state,encounter,overrides)
        if not bool(restored.get("ok",false)):
            return restored
        session = restored["session"]
        if not owner.cache_active_multicamp_session(session):
            return {"ok":false,"reason":"p0_failed_to_cache_restored_world"}
    if not PveDistributedWorldV1.enabled(session.camp_population):
        return {"ok":false,"reason":"p0_non_distributed_legacy_world"}
    return {"ok":true,"session":session}

static func _strict_selected(battle: MapBattleV2, ids: Array) -> Dictionary:
    if ids.is_empty() or ids.size() > MapBattleV2.MAX_DISCIPLES:
        return {"ok":false,"reason":"p0_no_selected_hunters"}
    var seen: Dictionary = {}
    var ordered: Array[String] = []
    for value in ids:
        var id := str(value)
        var actor: Dictionary = battle.actors.get(id,{})
        if id.is_empty() or seen.has(id) or actor.is_empty() \
                or str(actor.get("side","")) != "disciple" \
                or float(actor.get("hp",0.0)) <= 0.0:
            return {"ok":false,"reason":"p0_invalid_or_duplicate_selected_hunter"}
        seen[id] = true
        ordered.append(id)
    ordered.sort()
    return {"ok":true,"ids":ordered}

static func move(owner: SimulationRuntimeOwnerV2, ids: Array,
        destination: Vector2, arrival_policy: String = "keep") -> Dictionary:
    var current := _active(owner)
    if not bool(current.get("ok",false)):
        return current
    var session: HuntingPveRunV2 = current["session"]
    var selected := _strict_selected(session.battle,ids)
    if not bool(selected.get("ok",false)):
        return selected
    if not ["keep","auto","hold"].has(arrival_policy) \
            or not session.battle.is_world_position_allowed(destination):
        return {"ok":false,"reason":"p0_invalid_world_destination_or_arrival_mode"}
    var moved := session.battle.order_group_move(
        selected["ids"],destination,arrival_policy)
    if not bool(moved.get("ok",false)):
        return moved
    var checkpoint := session._persist_live_state()
    if not bool(checkpoint.get("ok",false)):
        return checkpoint
    return {"ok":true,"ordered_ids":selected["ids"],"destination":moved["destination"],
        "arrival_policy":arrival_policy,"save_required":true}

static func hunt_policy(owner: SimulationRuntimeOwnerV2, ids: Array,
        policy: String) -> Dictionary:
    var current := _active(owner)
    if not bool(current.get("ok",false)):
        return current
    var session: HuntingPveRunV2 = current["session"]
    var selected := _strict_selected(session.battle,ids)
    if not bool(selected.get("ok",false)):
        return selected
    var ordered := session.battle.set_disciple_hunt_policy(selected["ids"],policy)
    if not bool(ordered.get("ok",false)):
        return ordered
    var checkpoint := session._persist_live_state()
    if not bool(checkpoint.get("ok",false)):
        return checkpoint
    return {"ok":true,"ordered_ids":selected["ids"],
        "policy":policy,"save_required":true}


static func join_one(owner: SimulationRuntimeOwnerV2, disciple_id: String,
        role: String = "frontline", party_id: String = "") -> Dictionary:
    # New member walks onto the real world at its fixed entrance. No local
    # teleport to a remote hunting zone, free resource, or phantom recruit.
    var current := _active(owner)
    if not bool(current.get("ok",false)):
        return current
    var session: HuntingPveRunV2 = current["session"]
    if not session.battle.active or session.battle._count_alive("disciple") <= 0:
        return {"ok":false,"reason":"p0_world_not_accepting_joiners"}
    var parties := {}
    if not party_id.is_empty():
        parties[disciple_id] = party_id
    var formed := build_members(owner.state,[disciple_id],
        {disciple_id:role},parties)
    if not bool(formed.get("ok",false)):
        return formed
    # The active encounter may already have a legacy reservation snapshot
    # for this same disciple; never double-deploy an ID across worlds.
    if session.battle.actors.has(disciple_id) \
            or HuntingPveRunV2._actor_in_active_saved_run(owner.state,disciple_id):
        return {"ok":false,"reason":"p0_hunter_already_active"}
    var entry := Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5)
    var position := PveDistributedWorldV1.safe_spawn_position(session.battle,entry)
    if not is_finite(position.x) or not is_finite(position.y):
        return {"ok":false,"reason":"p0_world_entrance_occupied"}
    var record: Dictionary = formed["members"][0]
    var disciple: DiscipleState = owner.state.disciples[StringName(disciple_id)]
    var actor := DiscipleCombatLoadoutV2.build(
        owner.state,disciple,
        int(record["realm"]),int(record["floor"]),
        int(record["body_realm"]),int(record["body_floor"]),
        str(record["role"]),position,str(record["party_id"]))
    if not bool(actor.get("ok",false)):
        return actor
    var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(
        owner.state,actor,session.v63_preview_overrides)
    if not bool(attached.get("ok",false)):
        return attached
    actor["disciple"] = null
    var added := session.battle.add_world_disciple(actor)
    if not bool(added.get("ok",false)):
        return added
    var prior_events: Array = session.battle.events.duplicate(true)
    # The new event is useful for UI but must disappear on an unsuccessful
    # checkpoint, just like the actor and the canonical reservation.
    var prior_reservation := disciple.active_pve_encounter_id
    disciple.active_pve_encounter_id = session.battle.encounter_id
    var checkpoint := session._persist_live_state()
    if not bool(checkpoint.get("ok",false)):
        session.battle.actors.erase(disciple_id)
        session.battle.events = prior_events
        disciple.active_pve_encounter_id = prior_reservation
        return {"ok":false,"reason":"p0_join_checkpoint_failed",
            "detail":checkpoint.get("reason","unknown")}
    return {"ok":true,"joined":disciple_id,
        "party_id":str(record["party_id"]),
        "participants":int(added.get("participants",0)),
        "entry_position":position,
        "save_required":true}

static func return_one(owner: SimulationRuntimeOwnerV2,
        disciple_id: String) -> Dictionary:
    # Withdraw exactly one character. Never finish/settle the whole world.
    # Returning the last living hunter remains the existing explicit
    # "Về tông môn" retreat command; it has its own terminal receipt.
    var current := _active(owner)
    if not bool(current.get("ok",false)):
        return current
    var session: HuntingPveRunV2 = current["session"]
    var actor: Dictionary = session.battle.actors.get(disciple_id,{})
    if str(actor.get("side","")) != "disciple":
        return {"ok":false,"reason":"p0_not_an_active_hunter"}
    var disciple: DiscipleState = owner.state.disciples.get(
        StringName(disciple_id),null)
    if disciple == null or disciple.active_pve_encounter_id != session.battle.encounter_id:
        return {"ok":false,"reason":"p0_hunter_reservation_mismatch"}
    var hp := float(actor.get("hp",-1.0))
    var max_hp := float(actor.get("max_hp",0.0))
    if not is_finite(hp) or not is_finite(max_hp) \
            or hp < 0.0 or max_hp <= 0.0 or hp > max_hp \
            or disciple.max_hp <= 0.0:
        return {"ok":false,"reason":"p0_invalid_return_hp"}
    var downed := hp <= 0.0
    var returned_hp := 1.0 if downed else minf(
        disciple.max_hp,CombatStatsV2.rescale_current_hp(
            hp,max_hp,disciple.max_hp))
    var actor_snapshot := actor.duplicate(true)
    var old_events := session.battle.events.duplicate(true)
    var previous := {
        "hp":disciple.hp,
        "injury_level":disciple.injury_level,
        "injury_recover_at_tick":disciple.injury_recover_at_tick,
        "region_id":disciple.region_id,
        "target_region_id":disciple.target_region_id,
        "current_action":disciple.current_action,
        "reservation":disciple.active_pve_encounter_id
    }
    var withdrew := session.battle.withdraw_world_disciple(disciple_id)
    if not bool(withdrew.get("ok",false)):
        return withdrew
    disciple.hp = returned_hp
    disciple.injury_level = 1 if downed else 0
    disciple.injury_recover_at_tick = owner.state.tick+120 if downed else 0
    disciple.region_id = &"sect"
    disciple.target_region_id = &""
    disciple.current_action = &"EVALUATE"
    disciple.active_pve_encounter_id = ""
    var checkpoint := session._persist_live_state()
    if not bool(checkpoint.get("ok",false)):
        session.battle.actors[disciple_id] = actor_snapshot
        session.battle.events = old_events
        disciple.hp = float(previous["hp"])
        disciple.injury_level = int(previous["injury_level"])
        disciple.injury_recover_at_tick = int(previous["injury_recover_at_tick"])
        disciple.region_id = previous["region_id"]
        disciple.target_region_id = previous["target_region_id"]
        disciple.current_action = previous["current_action"]
        disciple.active_pve_encounter_id = previous["reservation"]
        return {"ok":false,"reason":"p0_return_checkpoint_failed",
            "detail":checkpoint.get("reason","unknown")}
    return {"ok":true,"returned":disciple_id,"injured":downed,
        "hp":returned_hp,"remaining_alive":int(withdrew["remaining_alive"]),
        "save_required":true}
