class_name HuntingPveRunV2
extends RefCounted

# A single real multi-disciple hunting session: stored region-level choice
# -> actual disciple gear/skill sources -> real monster group -> map combat
# -> warehouse reward after victory. Not installed in legacy scheduler yet.
var owner_state: SimulationState
var region_id: String = ""
var spawn_data: Dictionary = {}
var battle: MapBattleV2
var mode: String = "encounter"
var camp_index: int = -1
var camp_population: Dictionary = {}
var camp_slot_ids: Array = []
var minute_phase: float = 0.0
var world_respawn_delay := 30.0
var performance_checkpoint_count := 0
var performance_checkpoint_usec_total := 0
var performance_checkpoint_usec_max := 0

func begin(
    state: SimulationState, region: String, encounter_id: String, seed: int,
    party_members: Array
) -> Dictionary:
    if battle != null or state == null or not state.sect.v2_pve_enabled:
        return {"ok":false,"reason":"v2_pve_disabled_or_already_started"}
    if not state.sect.b3_hunt.is_empty():
        return {"ok":false,"reason":"another_authoritative_hunt_world_is_active"}
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
    mode = "encounter"
    camp_index = -1
    camp_population.clear()
    camp_slot_ids.clear()
    minute_phase = 0.0
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

# A first playable Thanh Trúc Lâm camp: authentic V2 party, ten catalogue
# monsters and the same Combat V2 snapshot/save/settlement path as group PvE.
# Monster-specific payout and respawn delay are deliberately not invented;
# the existing, authored region clear table is claimed once after camp victory.
func begin_multicamp(owner: SimulationRuntimeOwnerV2, encounter_id: String,
		seed: int, party_members: Array, slots_per_camp: int = 10,
		open_world_options: Dictionary = {}) -> Dictionary:
    if owner == null or owner.state == null or owner.durable_path.is_empty():
        return {"ok":false,"reason":"multicamp_requires_durable_runtime_owner"}
    if owner.b3_write_blocked or owner.runtime_write_blocked:
        return {"ok":false,"reason":"runtime_save_retry_required"}
    if not owner.state.sect.b3_hunt.is_empty() or not owner.state.sect.v2_pve_active_runs.is_empty():
        return {"ok":false,"reason":"another_hunt_world_is_active"}
    if party_members.is_empty() or party_members.size() > 6:
        return {"ok":false,"reason":"multicamp_party_must_be_one_to_six"}
    if slots_per_camp != 10:
        return {"ok":false,"reason":"playable_pilot_requires_ten_monsters"}
    if not open_world_options.is_empty():
        var world_error := _validate_open_world_options(open_world_options)
        if not world_error.is_empty():
            return {"ok":false,"reason":world_error}
    var state := owner.state
    var selected := HuntingMapV2.choose_level(state,PveMultiCampPopulationV1.ZONE,1)
    if not bool(selected.get("ok",false)):
        return selected
    var started := begin(state,PveMultiCampPopulationV1.ZONE,encounter_id,seed,party_members)
    if not bool(started.get("ok",false)):
        return started

    var registry := PveMultiCampPopulationV1.new_registry(slots_per_camp)
    if not bool(registry.get("ok",false)):
        _rollback_uncommitted_begin()
        return registry
    var party: Array = []
    var actor_ids: Array = battle.actors.keys()
    actor_ids.sort()
    for actor_id in actor_ids:
        if str(battle.actors[actor_id].get("side","")) == "disciple":
            party.append(battle.actors[actor_id].duplicate(true))
    var monsters := _build_camp_monsters(encounter_id,seed,registry,0,slots_per_camp)
    if monsters.size() != slots_per_camp:
        _rollback_uncommitted_begin()
        return {"ok":false,"reason":"camp_catalogue_spawn_failed"}
    if not open_world_options.is_empty():
        var camp_positions: Array = open_world_options["camp_positions"]
        var slot_positions: Dictionary = open_world_options["slot_positions"]
        var party_spawn_points: Array = open_world_options["party_spawn_points"]
        for index in range(party.size()):
            party[index]["position"] = party_spawn_points[index]
        for row in monsters:
            var slot_id := str(row["spawn_slot_id"])
            var position: Vector2 = slot_positions[slot_id]
            row["position"] = position
            row["home_position"] = position
        var saved_camp_positions: Array = []
        for point in camp_positions:
            var center: Vector2 = point
            saved_camp_positions.append({"x":center.x,"y":center.y})
        registry["world_camp_positions"] = saved_camp_positions
        registry["world_source_sha"] = str(open_world_options["source_blob_sha"])
        registry["world_source_map"] = str(open_world_options.get("source_map",""))
        registry["world_respawn_delay"] = float(open_world_options.get("respawn_delay_sim_seconds",30.0))
        for slot_id in slot_positions:
            var point: Vector2 = slot_positions[slot_id]
            var slot: Dictionary = registry["slots"][str(slot_id)]
            slot["world_x"] = point.x
            slot["world_y"] = point.y
    var continuous := MapBattleV2.new(seed)
    var ready := continuous.setup_open_world(encounter_id,party,monsters,open_world_options) if not open_world_options.is_empty() else continuous.setup(encounter_id,party,monsters,true)
    if not bool(ready.get("ok",false)):
        _rollback_uncommitted_begin()
        return ready
    battle = continuous
    mode = "multicamp"
    camp_index = 0
    camp_population = registry
    camp_slot_ids.clear()
    for i in range(slots_per_camp):
        camp_slot_ids.append(PveMultiCampPopulationV1.slot_id(camp_index,i))
    world_respawn_delay = float(registry.get("world_respawn_delay",0.0)) if continuous.world_mode else 0.0
    minute_phase = 0.0
    var checkpoint := _persist_live_state()
    if not bool(checkpoint.get("ok",false)):
        _rollback_uncommitted_begin()
        return checkpoint
    var error := owner.saves.save_to_path(state,owner.durable_path)
    owner.runtime_write_blocked = error != OK
    if error != OK:
        return {"ok":false,"reason":"multicamp_initial_save_failed","error":error}
    return {"ok":true,"mode":mode,"encounter_id":encounter_id,
        "camp_id":PveMultiCampPopulationV1.camp_id(camp_index),
        "party_size":party.size(),"monster_count":monsters.size(),
        "resource_payout":"LOOT_PENDING" if continuous.world_mode else "canonical_region_clear_table",
        "world_mode":continuous.world_mode,"source_map":str(registry.get("world_source_map",""))}

func _validate_open_world_options(options: Dictionary) -> String:
    if not ["bounds","navigation","camp_positions","slot_positions","party_spawn_points","source_blob_sha"].all(func(key: String) -> bool: return options.has(key)):
        return "open_world_topology_missing_required_field"
    var bounds = options["bounds"]
    var navigation = options["navigation"]
    var camps = options["camp_positions"]
    var slots = options["slot_positions"]
    var party_points = options["party_spawn_points"]
    if not (bounds is Rect2) or not (navigation is Dictionary) or not (camps is Array) or not (slots is Dictionary) or not (party_points is Array):
        return "open_world_topology_invalid_type"
    if camps.size() != PveMultiCampPopulationV1.CAMP_COUNT or slots.size() != PveMultiCampPopulationV1.CAMP_COUNT*PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP or party_points.size() != 6:
        return "open_world_topology_population_invalid"
    if str(options["source_blob_sha"]).length() != 40 or str(navigation.get("source_blob_sha","")) != str(options["source_blob_sha"]):
        return "open_world_map_identity_invalid"
    var width := int(navigation.get("width",0))
    var height := int(navigation.get("height",0))
    if width < 2 or height < 2 or not is_equal_approx(bounds.size.x,float(width)) or not is_equal_approx(bounds.size.y,float(height)):
        return "open_world_topology_bounds_invalid"
    for camp_index in range(PveMultiCampPopulationV1.CAMP_COUNT):
        var center = camps[camp_index]
        if not (center is Vector2) or not PveOpenWorldTopologyV1._walkable(navigation,Vector2i(floori(center.x),floori(center.y))):
            return "open_world_camp_not_walkable"
        for ordinal in range(PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP):
            var id := PveMultiCampPopulationV1.slot_id(camp_index,ordinal)
            var point = slots.get(id,null)
            if not (point is Vector2) or not PveOpenWorldTopologyV1._walkable(navigation,Vector2i(floori(point.x),floori(point.y))):
                return "open_world_spawn_slot_not_walkable"
    for point in party_points:
        if not (point is Vector2) or not PveOpenWorldTopologyV1._walkable(navigation,Vector2i(floori(point.x),floori(point.y))):
            return "open_world_party_spawn_not_walkable"
    return ""

func _build_camp_monsters(encounter_id: String, seed: int, registry: Dictionary,
        camp: int, count: int) -> Array:
    var rows: Array = []
    var content: Dictionary = HuntingMapV2.REGION_CONTENT[PveMultiCampPopulationV1.ZONE]
    var wave_seed := seed ^ 0x41C64E6D ^ (camp*0x1F123BB5)
    if registry.get("world_camp_positions",[]) is Array:
        wave_seed ^= int(registry["slots"].get(PveMultiCampPopulationV1.slot_id(camp,0),{}).get("generation",1))-1
    var rng := GameRng.new(wave_seed)
    for i in range(count):
        var slot_id := PveMultiCampPopulationV1.slot_id(camp,i)
        var slot: Dictionary = registry["slots"][slot_id]
        var species := str(rng.weighted_pick(content["normal"]))
        var actor_id := "%s/%s/g%d" % [encounter_id,slot_id,int(slot["generation"])]
        var created := MonsterCatalogueV2.create_actor(species,1,1,actor_id)
        if not bool(created.get("ok",false)):
            return []
        created["id"] = actor_id
        created["spawn_slot_id"] = slot_id
        created["slot_generation"] = int(slot["generation"])
        created["position"] = Vector2(23.0+float(i%5)*1.05,7.2+float(int(i/5))*2.5)
        created["region_id"] = PveMultiCampPopulationV1.ZONE
        created["camp_id"] = PveMultiCampPopulationV1.camp_id(camp)
        rows.append(created)
    return rows

func _rollback_uncommitted_begin() -> void:
    if owner_state == null:
        return
    if battle != null:
        for actor in battle.actors.values():
            if str(actor.get("side","")) == "disciple" and owner_state.disciples.has(StringName(str(actor["id"]))):
                owner_state.disciples[StringName(str(actor["id"]))].active_pve_encounter_id = ""
    owner_state.sect.v2_pve_active_runs.erase(battle.encounter_id if battle != null else "")
    battle = null
    owner_state = null
    spawn_data.clear()
    camp_population.clear()
    camp_slot_ids.clear()
    mode = "encounter"
    camp_index = -1

func retreat_multicamp() -> Dictionary:
    if mode != "multicamp" or battle == null or owner_state == null:
        return {"ok":false,"reason":"no_active_multicamp"}
    if battle.active:
        battle.active = false
        battle.outcome = "timeout_retreat"
        battle._event("battle_end",{"outcome":battle.outcome,"elapsed":battle.now,
            "downed_disciples":battle.downed_disciples,"cause":"manual_return"})
    var stored := _persist_live_state()
    if not bool(stored.get("ok",false)):
        return stored
    var settled := _settle_terminal()
    if not bool(settled.get("ok",false)):
        return settled
    var receipt: Dictionary = owner_state.sect.v2_pve_settlement_receipts[battle.encounter_id]
    receipt["mode"] = mode
    receipt["camp_id"] = PveMultiCampPopulationV1.camp_id(camp_index)
    receipt["kills"] = _camp_kill_count()
    receipt["items"] = {}
    return {"ok":true,"outcome":battle.outcome,"kills":int(receipt["kills"]),
        "loot_disposition":"LOOT_PENDING" if battle.world_mode else "NO_CAMP_WIN_REWARD"}

func _camp_kill_count() -> int:
    if battle == null:
        return 0
    if battle.world_mode:
        return int(camp_population.get("world_total_kills",0))
    var dead := 0
    for actor in battle.actors.values():
        if str(actor.get("side","")) == "monster" and float(actor.get("hp",1.0)) <= 0.0:
            dead += 1
    return dead

func advance(viewed_map: bool = false) -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_active_session"}
    if mode == "multicamp":
        return _advance_multicamp(viewed_map)
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

func _advance_multicamp(viewed_map: bool) -> Dictionary:
    if battle != null and battle.world_mode:
        return _advance_open_world(viewed_map)
    var did_step := false
    if battle.active:
        var stepped := battle.step(viewed_map)
        if not bool(stepped.get("ok",false)):
            return stepped
        did_step = true
        if battle._count_alive("monster") == 0:
            battle.active = false
            battle.outcome = "win"
            battle._event("battle_end",{"outcome":"win","elapsed":battle.now,
                "downed_disciples":battle.downed_disciples,"camp_id":PveMultiCampPopulationV1.camp_id(camp_index)})
        elif battle._count_alive("disciple") == 0:
            battle.active = false
            battle.outcome = "defeat"
            battle._event("battle_end",{"outcome":"defeat","elapsed":battle.now,
                "downed_disciples":battle.downed_disciples,"camp_id":PveMultiCampPopulationV1.camp_id(camp_index)})
        var stored := _persist_live_state()
        if not bool(stored.get("ok",false)):
            return stored
    if not battle.active:
        var completed := _complete_multicamp()
        # The combat frame itself is already represented in the saved snapshot.
        # A warehouse backpressure result is retryable, not a lost combat step.
        if not bool(completed.get("ok",false)):
            return {"ok":true,"stepped":did_step,"barrier":true,
                "settlement_pending":str(completed.get("reason","settlement_pending")),
                "outcome":battle.outcome,"time":battle.now}
        completed["stepped"] = did_step
        completed["barrier"] = true
        return completed
    return {"ok":true,"stepped":did_step,"barrier":false,
        "outcome":battle.outcome,"time":battle.now,
        "alive_disciples":battle._count_alive("disciple"),
        "alive_monsters":battle._count_alive("monster")}

func _advance_open_world(viewed_map: bool) -> Dictionary:
    if battle == null or not battle.world_mode:
        return {"ok":false,"reason":"open_world_snapshot_missing"}
    var stepped := battle.step(viewed_map)
    if not bool(stepped.get("ok",false)):
        return stepped
    var kills := _record_open_world_kills()
    if not bool(kills.get("ok",false)):
        return kills
    var population_step := PveMultiCampPopulationV1.advance_respawns(camp_population,battle.now)
    if not bool(population_step.get("ok",false)):
        return population_step
    var zone_changed := false
    if battle._count_alive("disciple") == 0:
        battle.active = false
        battle.outcome = "defeat"
        battle._event("battle_end",{"outcome":"defeat","elapsed":battle.now,
            "downed_disciples":battle.downed_disciples,"cause":"all_party_members_downed"})
    elif battle._count_alive("monster") == 0:
        var next_camp := _next_ready_world_camp()
        if next_camp >= 0:
            var spawned := _spawn_open_world_camp(next_camp)
            if not bool(spawned.get("ok",false)):
                return spawned
            zone_changed = true
    var stored := _persist_live_state()
    if not bool(stored.get("ok",false)):
        return stored
    if not battle.active:
        var completed := _complete_multicamp()
        if not bool(completed.get("ok",false)):
            return {"ok":true,"stepped":true,"barrier":true,
                "settlement_pending":str(completed.get("reason","settlement_pending")),
                "outcome":battle.outcome,"time":battle.now}
        completed["stepped"] = true
        completed["barrier"] = true
        return completed
    return {"ok":true,"stepped":true,"barrier":false,"world_mode":true,
        "zone_changed":zone_changed,"camp_index":camp_index,
        "camp_id":PveMultiCampPopulationV1.camp_id(camp_index),
        "respawned":int(population_step.get("respawned",0)),
        "loot_disposition":"LOOT_PENDING","rewards_granted":false,
        "outcome":battle.outcome,"time":battle.now,
        "alive_disciples":battle._count_alive("disciple"),
        "alive_monsters":battle._count_alive("monster")}

func _record_open_world_kills() -> Dictionary:
    var recorded := 0
    for event in battle.pending_kill_events():
        var receipt := PveMultiCampPopulationV1.record_authoritative_battle_kill(
            camp_population,battle,event,world_respawn_delay)
        if not bool(receipt.get("ok",false)):
            return {"ok":false,"reason":"open_world_kill_receipt_rejected","detail":receipt.get("reason","unknown")}
        var slot_id := str(event.get("spawn_slot_id",""))
        var kill_id := str(event.get("kill_id",""))
        var ack := PveMultiCampPopulationV1.acknowledge_no_reward_receipt(
            camp_population,slot_id,kill_id,"LOOT_PENDING")
        if not bool(ack.get("ok",false)):
            return {"ok":false,"reason":"open_world_no_reward_receipt_failed","detail":ack.get("reason","unknown")}
        if not battle.acknowledge_kill_event(kill_id):
            return {"ok":false,"reason":"open_world_combat_kill_ack_failed"}
        camp_population["world_total_kills"] = int(camp_population.get("world_total_kills",0))+1
        recorded += 1
    return {"ok":true,"recorded":recorded,"rewards_granted":false}

func _next_ready_world_camp() -> int:
    for offset in range(1,PveMultiCampPopulationV1.CAMP_COUNT+1):
        var candidate := posmod(camp_index+offset,PveMultiCampPopulationV1.CAMP_COUNT)
        var ready := true
        for ordinal in range(PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP):
            var slot_id := PveMultiCampPopulationV1.slot_id(candidate,ordinal)
            var slot: Dictionary = camp_population.get("slots",{}).get(slot_id,{})
            if str(slot.get("phase","")) != "READY":
                ready = false
                break
        if ready:
            return candidate
    return -1

func _spawn_open_world_camp(next_camp: int) -> Dictionary:
    if next_camp < 0 or next_camp >= PveMultiCampPopulationV1.CAMP_COUNT:
        return {"ok":false,"reason":"invalid_open_world_spawn_zone"}
    var old_actor_ids: Array = []
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side","")) == "monster" and float(actor.get("hp",1.0)) <= 0.0:
            old_actor_ids.append(str(raw_id))
    old_actor_ids.sort()
    for actor_id in old_actor_ids:
        if not battle.remove_downed_monster(actor_id):
            return {"ok":false,"reason":"open_world_dead_actor_cleanup_failed"}
    var rows := _build_camp_monsters(battle.encounter_id,int(spawn_data.get("reward_seed",0)),camp_population,next_camp,PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP)
    if rows.size() != PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP:
        return {"ok":false,"reason":"open_world_catalogue_wave_failed"}
    for row in rows:
        var slot_id := str(row["spawn_slot_id"])
        var slot: Dictionary = camp_population["slots"][slot_id]
        if not slot.has("world_x") or not slot.has("world_y"):
            return {"ok":false,"reason":"open_world_slot_position_missing"}
        var position := Vector2(float(slot["world_x"]),float(slot["world_y"]))
        row["position"] = position
        row["home_position"] = position
        var added := battle.add_continuous_monster(row)
        if not bool(added.get("ok",false)):
            return {"ok":false,"reason":"open_world_wave_add_failed","detail":added.get("reason","unknown")}
    camp_index = next_camp
    camp_slot_ids.clear()
    for ordinal in range(PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP):
        camp_slot_ids.append(PveMultiCampPopulationV1.slot_id(camp_index,ordinal))
    battle._event("world_zone_entered",{"camp_id":PveMultiCampPopulationV1.camp_id(camp_index),"actor_count":rows.size()})
    return {"ok":true,"camp_index":camp_index,"spawned":rows.size()}

func _complete_multicamp() -> Dictionary:
    if battle == null or battle.active or not ["win","defeat","timeout_retreat"].has(battle.outcome):
        return {"ok":false,"reason":"multicamp_not_terminal"}
    var settled := _settle_terminal()
    if not bool(settled.get("ok",false)):
        return settled
    var receipt: Dictionary = owner_state.sect.v2_pve_settlement_receipts[battle.encounter_id]
    receipt["mode"] = mode
    receipt["camp_id"] = PveMultiCampPopulationV1.camp_id(camp_index)
    receipt["kills"] = _camp_kill_count()
    receipt["items"] = {}
    var paid: Dictionary = {"ok":true,"items":{}}
    if battle.outcome == "win" and not battle.world_mode:
        paid = claim()
        if not bool(paid.get("ok",false)):
            return paid
        receipt["items"] = paid.get("items",{}).duplicate(true)
    return {"ok":true,"outcome":battle.outcome,"kills":int(receipt["kills"]),
        "items":receipt["items"].duplicate(true),"summary":battle.summary()}

static func has_active_multicamp(state: SimulationState) -> bool:
    return not active_multicamp_id(state).is_empty()

static func active_multicamp_id(state: SimulationState) -> String:
    if state == null:
        return ""
    for raw_id in state.sect.v2_pve_active_runs.keys():
        var envelope = state.sect.v2_pve_active_runs[raw_id]
        if envelope is Dictionary and str(envelope.get("mode","")) == "multicamp":
            return str(raw_id)
    return ""

static func commit_owner(owner: SimulationRuntimeOwnerV2, async_save: bool = false) -> Dictionary:
    if owner == null or owner.state == null or owner.durable_path.is_empty():
        return {"ok":false,"reason":"multicamp_missing_save_barrier"}
    if async_save:
        var start_error := owner.saves.start_save_to_path_async(owner.state,owner.durable_path)
        owner.runtime_write_blocked = start_error != OK
        return {"ok":start_error == OK,"pending":start_error == OK,"error":start_error,
            "reason":"multicamp_save_barrier_failed" if start_error != OK else ""}
    var error := owner.saves.save_to_path(owner.state,owner.durable_path)
    owner.runtime_write_blocked = error != OK
    return {"ok":error == OK,"error":error,
        "reason":"multicamp_save_barrier_failed" if error != OK else ""}

func finish(max_steps: int = 400) -> Dictionary:
    if battle == null or owner_state == null:
        return {"ok":false,"reason":"no_session"}
    if mode == "multicamp":
        var progressed := 0
        while battle.active and progressed < maxi(0,max_steps):
            var frame := _advance_multicamp(false)
            if not bool(frame.get("ok",false)):
                return frame
            progressed += 1
        if battle.active:
            return {"ok":false,"reason":"multicamp_still_active","summary":battle.summary()}
        return _complete_multicamp()
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
    if battle.world_mode:
        return {"ok":false,"reason":"open_world_per_monster_loot_pending"}
    if battle.active:
        return {"ok":false,"reason":"encounter_not_final"}
    var settled := _settle_terminal()
    if not bool(settled.get("ok",false)):
        return settled
    var result := HuntingMapV2.claim_reward(owner_state,spawn_data,battle)
    if bool(result.get("ok",false)):
        owner_state.sect.v2_pve_active_runs.erase(battle.encounter_id)
        if mode == "multicamp" and owner_state.sect.v2_pve_settlement_receipts.has(battle.encounter_id):
            var receipt: Dictionary = owner_state.sect.v2_pve_settlement_receipts[battle.encounter_id]
            receipt["mode"] = mode
            receipt["camp_id"] = PveMultiCampPopulationV1.camp_id(camp_index)
            receipt["kills"] = _camp_kill_count()
            receipt["items"] = result.get("items",{}).duplicate(true)
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
    var profile := OS.get_environment("TMB_PVE_PERF_LOG") == "1"
    var started_usec := Time.get_ticks_usec() if profile else 0
    var saved := save_state()
    if bool(saved.get("ok",false)):
        owner_state.sect.v2_pve_active_runs[battle.encounter_id] = saved.duplicate(true)
    if profile:
        var elapsed_usec := Time.get_ticks_usec()-started_usec
        performance_checkpoint_count += 1
        performance_checkpoint_usec_total += elapsed_usec
        performance_checkpoint_usec_max = maxi(performance_checkpoint_usec_max,elapsed_usec)
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
    var terminal_receipt := {
        "outcome":battle.outcome,"settled_tick":when,"members":members.duplicate(true)
    }
    if mode == "multicamp":
        terminal_receipt["mode"] = mode
        terminal_receipt["camp_id"] = PveMultiCampPopulationV1.camp_id(camp_index)
        terminal_receipt["kills"] = _camp_kill_count()
        terminal_receipt["items"] = {}
        terminal_receipt["battle"] = MapBattleSnapshotV2.save(battle)
    owner_state.sect.v2_pve_settlement_receipts[encounter] = terminal_receipt
    if battle.outcome != "win":
        owner_state.sect.v2_pve_active_runs.erase(encounter)
    return {"ok":true,"already_settled":false,"settled_tick":when}


# GP-02C1: restore valid pre-reservation V2 saves before *any* offline tick.
# Two-phase validation leaves malformed/contested legacy saves untouched.
static func reconcile_loaded_v2_pve(state: SimulationState) -> Dictionary:
    if state == null:
        return {"ok":false,"reason":"missing_loaded_state"}
    if state.sect.v2_pve_active_runs.is_empty():
        return {"ok":true,"legacy_restored":0,"terminal_settled":0}
    var encountered: Dictionary = {}
    var pending: Dictionary = {}
    var ids: Array = state.sect.v2_pve_active_runs.keys()
    ids.sort()
    var buildings := BuildingSystem.new()
    for raw_id in ids:
        var id := str(raw_id)
        var snapshot = state.sect.v2_pve_active_runs[raw_id]
        if id.is_empty() or not (snapshot is Dictionary) or str(snapshot.get("encounter_id","")) != id:
            return {"ok":false,"reason":"legacy_encounter_identity_invalid"}
        if state.sect.v2_pve_reward_claims.has(id):
            return {"ok":false,"reason":"claimed_encounter_has_active_snapshot"}
        var restored := restore_state(state,snapshot)
        if not bool(restored.get("ok",false)):
            return {"ok":false,"reason":"legacy_encounter_snapshot_invalid","detail":restored.get("reason","unknown")}
        var session: HuntingPveRunV2 = restored["session"]
        var terminal := not session.battle.active
        var previous_receipt = state.sect.v2_pve_settlement_receipts.get(id,null)
        if previous_receipt != null:
            if not terminal or not (previous_receipt is Dictionary):
                return {"ok":false,"reason":"legacy_receipt_state_invalid"}
            var receipt: Dictionary = previous_receipt
            var members: Dictionary = {}
            for raw_actor_id in session.battle.actors.keys():
                var original: Dictionary = session.battle.actors[raw_actor_id]
                if str(original.get("side","")) == "disciple":
                    members[str(raw_actor_id)] = {
                        "actor_hp":float(original.get("hp",-1.0)),
                        "actor_max_hp":float(original.get("max_hp",0.0)),
                        "downed":float(original.get("hp",-1.0)) <= 0.0
                    }
            if str(receipt.get("outcome","")) != session.battle.outcome or receipt.get("members",{}) != members:
                return {"ok":false,"reason":"legacy_terminal_receipt_conflict"}
            continue
        for raw_actor_id in session.battle.actors.keys():
            var actor: Dictionary = session.battle.actors[raw_actor_id]
            if str(actor.get("side","")) != "disciple":
                continue
            var disciple_id := str(raw_actor_id)
            if encountered.has(disciple_id):
                return {"ok":false,"reason":"legacy_disciple_in_multiple_encounters"}
            encountered[disciple_id] = id
            if not state.disciples.has(StringName(disciple_id)):
                return {"ok":false,"reason":"legacy_participant_missing"}
            var disciple: DiscipleState = state.disciples[StringName(disciple_id)]
            if not disciple.active_pve_encounter_id.is_empty() and disciple.active_pve_encounter_id != id:
                return {"ok":false,"reason":"legacy_reservation_conflict"}
            if disciple.injury_level != 0 or disciple.hp <= 0.0 or disciple.max_hp <= 0.0:
                return {"ok":false,"reason":"legacy_participant_life_conflict"}
            if not disciple.work_cycle_state.is_empty() or buildings.disciple_has_active_spirit_plot(state,disciple.id) or buildings.disciple_has_active_timed_recipe(state,disciple.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
                return {"ok":false,"reason":"legacy_participant_occupation_conflict"}
            if not [&"EVALUATE",&"IDLE",&"HOLD"].has(disciple.current_action):
                return {"ok":false,"reason":"legacy_participant_action_conflict"}
            var actor_max := float(actor.get("max_hp",0.0))
            var actor_hp := float(actor.get("hp",-1.0))
            if actor_max <= 0.0 or is_nan(actor_hp) or is_inf(actor_hp) or actor_hp < 0.0 or actor_hp > actor_max:
                return {"ok":false,"reason":"legacy_participant_hp_invalid"}
        pending[id] = session
    # Only now may state change. All actors and terminal HPs are preflighted.
    var assigned := 0
    for key in encountered.keys():
        var participant: DiscipleState = state.disciples[StringName(str(key))]
        if participant.active_pve_encounter_id.is_empty():
            assigned += 1
        participant.active_pve_encounter_id = str(encountered[key])
    var settled := 0
    for raw_id in ids:
        var id := str(raw_id)
        if not pending.has(id):
            continue
        var run: HuntingPveRunV2 = pending[id]
        if not run.battle.active:
            var result := run._settle_terminal()
            if not bool(result.get("ok",false)):
                return {"ok":false,"reason":"legacy_terminal_settlement_failed","detail":result.get("reason","unknown")}
            settled += 1
    return {"ok":true,"legacy_restored":assigned,"terminal_settled":settled}

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
    var saved := {
        "ok":true,"version":1,"region_id":region_id,
        "difficulty":int(spawn_data.get("level",0)),
        "encounter_id":str(spawn_data.get("encounter_id","")),
        "reward_seed":int(spawn_data.get("reward_seed",0)),
        "battle":checkpoint
    }
    if mode == "multicamp":
        saved["mode"] = mode
        saved["camp_index"] = camp_index
        saved["camp_population"] = camp_population.duplicate(true)
        saved["camp_slot_ids"] = camp_slot_ids.duplicate()
        saved["minute_phase"] = minute_phase
        saved["camp_monster_count"] = camp_slot_ids.size()
        saved["world_mode"] = battle.world_mode
        saved["world_respawn_delay"] = world_respawn_delay
    return saved

# The live character HP owner stays separate until DV2-03's real HP track
# migration. Rehydrated actors retain their exact battle HP but do not
# silently overwrite legacy DiscipleState HP or attach unsafe object pointers.
# Validate that saved spawn slots and Combat V2 navigation belong to the same
# pinned world. A valid-looking 40-character SHA alone cannot prove identity.
# This is read-only preflight; it never rewrites saves or synthesizes a map.
static func saved_world_identity_matches(battle_snapshot: MapBattleV2,
        registry: Dictionary) -> bool:
    if battle_snapshot == null or not battle_snapshot.world_mode:
        return false
    var navigation: Dictionary = battle_snapshot.world_navigation
    var nav_sha := str(navigation.get("source_blob_sha",""))
    var slot_sha := str(registry.get("world_source_sha",""))
    var nav_map := str(navigation.get("source_map",""))
    var slot_map := str(registry.get("world_source_map",""))
    return nav_sha.length() == 40 and nav_sha == slot_sha \
        and not nav_map.is_empty() and nav_map == slot_map

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
    var mode_value := str(saved.get("mode","encounter"))
    if not ["encounter","multicamp"].has(mode_value):
        return {"ok":false,"reason":"unknown_saved_hunt_mode"}
    var expected: Dictionary = {}
    for entry in spawned["monsters"]:
        expected[str(entry["id"])] = entry
    var seen_monsters := 0
    var seen_disciples := 0
    var seen_slots: Dictionary = {}
    var camp_registry: Dictionary = {}
    var camp_index_value := -1
    var camp_slots: Array = []
    var phase := 0.0
    if mode_value == "multicamp":
        if not resumed.continuous_mode:
            return {"ok":false,"reason":"multicamp_snapshot_not_continuous"}
        camp_registry = saved.get("camp_population",{})
        camp_index_value = int(saved.get("camp_index",-1))
        camp_slots = saved.get("camp_slot_ids",[])
        phase = float(saved.get("minute_phase",-1.0))
        var world_mode_saved := bool(saved.get("world_mode",false))
        var camps_valid := camp_index_value >= 0 and camp_index_value < PveMultiCampPopulationV1.CAMP_COUNT if world_mode_saved else camp_index_value == 0
        var world_identity_valid := true
        if world_mode_saved:
            var world_centres = camp_registry.get("world_camp_positions",null)
            world_identity_valid = saved_world_identity_matches(resumed,camp_registry) \
                and world_centres is Array \
                and world_centres.size() == PveMultiCampPopulationV1.CAMP_COUNT \
                and float(saved.get("world_respawn_delay",0.0)) > 0.0 \
                and is_equal_approx(float(saved.get("world_respawn_delay",0.0)), \
                    float(camp_registry.get("world_respawn_delay",-1.0)))
        elif resumed.world_mode:
            world_identity_valid = false
        if not camps_valid or not world_identity_valid or PveMultiCampPopulationV1.verify_structure(camp_registry) != "" or camp_slots.size() != 10 or int(saved.get("camp_monster_count",0)) != 10 or not is_finite(phase) or phase < 0.0 or phase >= 60.0 or fmod(phase,MapBattleV2.STEP_SECONDS) != 0.0:
            return {"ok":false,"reason":"invalid_multicamp_population_checkpoint"}
    elif resumed.continuous_mode:
        return {"ok":false,"reason":"unexpected_continuous_hunt_snapshot"}
    for actor_data in resumed.actors.values():
        var row: Dictionary = actor_data
        if str(row["side"]) == "monster":
            seen_monsters += 1
            var actor_id := str(row["id"])
            if mode_value == "multicamp":
                var slot_id := str(row.get("spawn_slot_id",""))
                var generation := int(row.get("slot_generation",0))
                var slot_map: Dictionary = camp_registry.get("slots",{})
                if not camp_slots.has(slot_id) or seen_slots.has(slot_id) or not slot_map.has(slot_id):
                    return {"ok":false,"reason":"unexpected_multicamp_spawn_slot"}
                var slot: Dictionary = slot_map[slot_id]
                if not HuntingMapV2.REGION_CONTENT[PveMultiCampPopulationV1.ZONE]["normal"].has(str(row.get("species_id",""))) or str(row.get("tier","")) != "normal" or str(row.get("race_id","")) != "yeu_thu" or generation != int(slot.get("generation",0)) or actor_id != "%s/%s/g%d" % [id,slot_id,generation]:
                    return {"ok":false,"reason":"multicamp_monster_provenance_mismatch"}
                seen_slots[slot_id] = true
            else:
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
    if mode_value == "multicamp" and (seen_monsters != 10 or seen_slots.size() != 10 or seen_disciples <= 0 or seen_disciples > 6):
        return {"ok":false,"reason":"incomplete_multicamp_roster"}
    if mode_value == "encounter" and (seen_monsters != expected.size() or seen_disciples <= 0):
        return {"ok":false,"reason":"incomplete_saved_combat_roster"}
    var session := HuntingPveRunV2.new()
    session.owner_state = state
    session.region_id = region
    session.spawn_data = spawned
    session.battle = resumed
    session.mode = mode_value
    session.camp_index = camp_index_value
    session.camp_population = camp_registry
    session.camp_slot_ids = camp_slots.duplicate()
    session.minute_phase = phase
    session.world_respawn_delay = float(saved.get("world_respawn_delay",0.0)) if resumed.world_mode else 0.0
    return {"ok":true,"session":session}
