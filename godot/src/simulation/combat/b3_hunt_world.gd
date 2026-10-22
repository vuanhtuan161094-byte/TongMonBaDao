class_name B3HuntWorld
extends RefCounted

# One opt-in world, one slot, one deployed authentic disciple. Persistent truth
# is SectState.b3_hunt; the PH0 battle is reconstructed only for a clock batch.
# Bounded ledger: latest immutable result + monotonic paid-generation watermark.
const VERSION := 1
const MAX_BATCH_FRAMES := 2400

static func begin(owner: SimulationRuntimeOwnerV2, disciple_id: StringName) -> Dictionary:
    if owner == null or owner.state == null or owner.durable_path.is_empty():
        return {"ok":false,"reason":"b3_requires_durable_runtime_owner"}
    if owner.b3_write_blocked: return {"ok":false,"reason":"b3_save_retry_required"}
    var state := owner.state
    if not state.sect.b3_hunt.is_empty() and state.runtime_unconsumed_wall_seconds >= MapBattleV2.STEP_SECONDS:
        return {"ok":false,"reason":"b3_clock_backlog_pending"}
    var ready := admission(state,disciple_id)
    if not ready["ok"]:
        return ready
    var battle: MapBattleV2
    if state.sect.b3_hunt.is_empty():
        if state.runtime_unconsumed_wall_seconds >= 60.0:
            return {"ok":false,"reason":"b3_drain_existing_clock_backlog_first"}
        var id := "b3:vs1:%s:%d:%d" % [B3PilotContent.ZONE,state.seed,state.tick]
        battle = MapBattleV2.new(state.seed)
        var started := battle.setup(id,[],[B3PilotContent.monster(id,1)],true)
        if not started["ok"]:
            return started
        state.sect.b3_hunt = {
            "version":VERSION,"content_version":B3PilotContent.VERSION,
            "world_id":id,"zone":B3PilotContent.ZONE,"minute_phase":state.runtime_unconsumed_wall_seconds,
            "slot":{"generation":1,"paid_generation":0,"due_at":0.0},
            "receipt":{},"member":"","admissions":0,"returns":0,"last_return":{}
        }
        state.runtime_unconsumed_wall_seconds = 0.0
    else:
        var restored := restore(state)
        if not restored["ok"]:
            return restored
        battle = restored["battle"]
    var deployed := deploy(state,battle,disciple_id)
    if not deployed["ok"]: return deployed
    checkpoint(state,battle)
    return commit(owner)

# Admission into the existing PH0 world, also used by the canonical AUTO review.
static func deploy(state: SimulationState, battle: MapBattleV2, disciple_id: StringName) -> Dictionary:
    var ready := admission(state,disciple_id)
    if not ready["ok"]: return ready
    var d: DiscipleState = state.disciples[disciple_id]
    var progress := DiscipleRealmProgressV2.current(d)
    var c: Dictionary = progress["cultivation"]
    var b: Dictionary = progress["body"]
    var actor := DiscipleCombatLoadoutV2.build(state,d,int(c["realm"]),int(c["floor"]),
        int(b["realm"]),int(b["floor"]),"frontline",Vector2(8,10),"b3_party")
    if not actor["ok"]:
        return actor
    actor["disciple"] = null
    # PH0's public actor collection uses its setup validator, without resetting
    # world RNG/time/monsters. No second combat implementation is introduced.
    var staging := MapBattleV2.new(state.seed)
    var built := staging.setup("b3_admission",[actor],[],true)
    if not built["ok"]:
        return built
    battle.actors[str(d.id)] = staging.actors[str(d.id)]
    battle.actors[str(d.id)]["next_basic"] = battle.now
    battle.actors[str(d.id)]["next_skill"] = battle.now
    var world := state.sect.b3_hunt
    world["member"] = str(d.id)
    world["admissions"] = int(world["admissions"])+1
    d.active_pve_encounter_id = str(world["world_id"])
    d.region_id = StringName(B3PilotContent.ZONE)
    d.current_action = &"HOLD"
    return {"ok":true}

static func admission(state: SimulationState, id: StringName) -> Dictionary:
    if not state.disciples.has(id):
        return {"ok":false,"reason":"b3_unknown_disciple"}
    var d: DiscipleState = state.disciples[id]
    var buildings := BuildingSystem.new()
    if not DiscipleRealmProgressV2.progression_ready(d):
        return {"ok":false,"reason":"b3_requires_authentic_v2_disciple"}
    if d.injury_level != 0 or d.hp <= 0.0:
        return {"ok":false,"reason":"b3_injured_or_downed"}
    if not state.sect.b3_hunt.get("member","").is_empty() or not d.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"b3_already_reserved"}
    if d.region_id != &"sect" or not [&"EVALUATE",&"IDLE",&"HOLD"].has(d.current_action):
        return {"ok":false,"reason":"b3_conflicting_action"}
    if not d.work_cycle_state.is_empty() or d.worksite_building_id != &"" or not d.work_progress.is_empty() or buildings.disciple_has_active_spirit_plot(state,id) or buildings.disciple_has_active_timed_recipe(state,id) or not buildings.active_resource_timer_for_worker(state,id).is_empty() or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,d):
        return {"ok":false,"reason":"b3_reserved_occupation"}
    if not d.direct_command.is_empty() and WorkforceSystem.new().command_kind(d) != WorkforceSystem.COMMAND_HOLD:
        return {"ok":false,"reason":"b3_conflicting_command"}
    if HuntingPveRunV2._actor_in_active_saved_run(state,str(id)):
        return {"ok":false,"reason":"b3_legacy_pve_reserved"}
    if not state.sect.p3_7_resources_enabled or not ResourceRegistry.new().has(B3PilotContent.RESOURCE):
        return {"ok":false,"reason":"b3_canonical_warehouse_unavailable"}
    return {"ok":true}

static func restore(state: SimulationState) -> Dictionary:
    return MapBattleSnapshotV2.load(state.sect.b3_hunt.get("battle",{}))

static func checkpoint(state: SimulationState, battle: MapBattleV2) -> void:
    # UI events are a disposable bounded view, never the reward source.
    if battle.events.size() > 96:
        battle.events = battle.events.slice(battle.events.size()-96)
    state.sect.b3_hunt["battle"] = MapBattleSnapshotV2.save(battle)

static func advance_frame(state: SimulationState, battle: MapBattleV2) -> Dictionary:
    if not battle.pending_kill_events().is_empty():
        return settle_kills(state,battle,false)
    B3MedicalAutoplayV1.review(state,battle)
    var world := state.sect.b3_hunt
    var slot: Dictionary = world["slot"]
    if float(slot["due_at"]) > 0.0 and battle.now >= float(slot["due_at"]):
        var old := B3PilotContent.monster(str(world["world_id"]),int(slot["generation"]))
        battle.remove_downed_monster(str(old["id"]))
        var generation := int(slot["generation"])+1
        var spawned := battle.add_continuous_monster(B3PilotContent.monster(str(world["world_id"]),generation))
        if not spawned["ok"]:
            return spawned
        slot["generation"] = generation
        slot["due_at"] = 0.0
    var result := battle.step()
    if not result["ok"]:
        return result
    var member := str(world["member"])
    if not member.is_empty():
        var actor: Dictionary = battle.actors[member]
        var d: DiscipleState = state.disciples[StringName(member)]
        if float(actor["hp"]) <= 0.0:
            _return_member(state,battle,true)
        else:
            d.hp = d.max_hp*float(actor["hp"])/float(actor["max_hp"])
    return settle_kills(state,battle,true)

static func settle_kills(state: SimulationState, battle: MapBattleV2, stepped: bool) -> Dictionary:
    var world := state.sect.b3_hunt
    var slot: Dictionary = world["slot"]
    for event in battle.pending_kill_events():
        var generation := int(event["slot_generation"])
        var id := B3PilotContent.kill_id(str(world["world_id"]),generation)
        if str(event["kill_id"]) != id or str(event["species_id"]) != B3PilotContent.SPECIES or str(event["world_id"]) != str(world["world_id"]) or str(event["spawn_slot_id"]) != B3PilotContent.SLOT or generation != int(slot["generation"]):
            return {"ok":false,"reason":"b3_invalid_domain_kill"}
        var actor_id := str(event["monster_instance_id"])
        if not battle.actors.has(actor_id) or float(battle.actors[actor_id]["hp"]) != 0.0:
            return {"ok":false,"reason":"b3_kill_without_hp0"}
        if generation <= int(slot["paid_generation"]):
            continue
        var receipt: Dictionary = world["receipt"]
        if receipt.is_empty() or str(receipt["kill_id"]) != id:
            receipt = {"kill_id":id,"generation":generation,"state":"PENDING",
                "content_version":B3PilotContent.VERSION,"resource":str(B3PilotContent.RESOURCE),
                "quantity":B3PilotContent.QUANTITY,"at_seconds":event["at_seconds"]}
            world["receipt"] = receipt
        if not WarehouseSystem.new().add(state,B3PilotContent.RESOURCE,B3PilotContent.QUANTITY):
            return {"ok":false,"reason":"b3_warehouse_backpressure","stepped":stepped,"barrier":true}
        receipt["state"] = "COMMITTED"
        slot["paid_generation"] = generation
        slot["due_at"] = float(event["at_seconds"])+B3PilotContent.RESPAWN_SECONDS
    return {"ok":true,"stepped":stepped,"barrier":not battle.pending_kill_events().is_empty()}

static func commit(owner: SimulationRuntimeOwnerV2) -> Dictionary:
    if owner.durable_path.is_empty():
        return {"ok":false,"reason":"b3_missing_save_barrier"}
    var error := owner.saves.save_to_path(owner.state,owner.durable_path)
    owner.b3_write_blocked = error != OK
    if error != OK:
        return {"ok":false,"reason":"b3_save_barrier_failed","error":error}
    # Only the complete canonical payload is durable now. On crash the saved
    # COMMITTED receipt and unacked event are safely re-read, never re-awarded.
    var restored := restore(owner.state)
    if not restored["ok"]:
        return restored
    var battle: MapBattleV2 = restored["battle"]
    var slot: Dictionary = owner.state.sect.b3_hunt["slot"]
    for event in battle.pending_kill_events():
        if int(event["slot_generation"]) <= int(slot["paid_generation"]):
            battle.acknowledge_kill_event(str(event["kill_id"]))
    checkpoint(owner.state,battle)
    return {"ok":true,"saved":true,"paid_generation":slot["paid_generation"]}

static func return_to_sect(owner: SimulationRuntimeOwnerV2) -> Dictionary:
    if owner == null or owner.state == null or owner.b3_write_blocked:
        return {"ok":false,"reason":"b3_save_retry_required"}
    if owner.state.sect.b3_hunt.is_empty():
        return {"ok":false,"reason":"b3_no_world"}
    if owner.state.runtime_unconsumed_wall_seconds >= MapBattleV2.STEP_SECONDS:
        return {"ok":false,"reason":"b3_clock_backlog_pending"}
    var restored := restore(owner.state)
    if not restored["ok"]:
        return restored
    var battle: MapBattleV2 = restored["battle"]
    if str(owner.state.sect.b3_hunt["member"]).is_empty():
        return {"ok":false,"reason":"b3_no_deployed_disciple"}
    B3MedicalAutoplayV1.pause_manual(owner.state)
    _return_member(owner.state,battle,false)
    checkpoint(owner.state,battle)
    return commit(owner)

static func _return_member(state: SimulationState, battle: MapBattleV2, downed: bool) -> void:
    var world := state.sect.b3_hunt
    var id := str(world["member"])
    var d: DiscipleState = state.disciples[StringName(id)]
    var actor: Dictionary = battle.actors[id]
    d.hp = 1.0 if downed else maxf(1.0,d.max_hp*float(actor["hp"])/float(actor["max_hp"]))
    d.injury_level = 1 if downed else 0
    d.injury_recover_at_tick = state.tick+120 if downed else 0
    d.active_pve_encounter_id = ""
    d.region_id = &"sect"
    d.target_region_id = &""
    d.current_action = &"HOLD"
    WorkforceSystem.new().issue_command(state,d.id,WorkforceSystem.COMMAND_HOLD,"",1000000)
    world["last_return"] = {"disciple_id":id,"downed":downed,"tick":state.tick,"at_seconds":battle.now}
    world["returns"] = int(world["returns"])+1
    world["member"] = ""
    battle.actors.erase(id)
    battle.downed_disciples = 0
    var remaining: Array = []
    for cast in battle.pending_casts:
        if str(cast.get("caster","")) != id and str(cast.get("target_id","")) != id:
            remaining.append(cast)
    battle.pending_casts = remaining

static func owns_reservation(state: SimulationState, d: DiscipleState) -> bool:
    var w := state.sect.b3_hunt
    return not w.is_empty() and str(w.get("member","")) == str(d.id) and str(w.get("world_id","")) == d.active_pve_encounter_id

static func validate(state: SimulationState) -> String:
    var w := state.sect.b3_hunt
    if w.is_empty():
        for d in state.disciples.values():
            if d.active_pve_encounter_id.begins_with("b3:vs1:"):
                return "b3_missing_reservation_world"
        return ""
    if state.runtime_last_wall_unix <= 0 or state.runtime_clock_version != SimulationRuntimeClockV2.VERSION or not is_finite(state.runtime_unconsumed_wall_seconds) or state.runtime_unconsumed_wall_seconds < 0.0:
        return "b3_invalid_clock_owner"
    if int(w.get("version",0)) != VERSION or int(w.get("content_version",0)) != B3PilotContent.VERSION or str(w.get("zone","")) != B3PilotContent.ZONE:
        return "b3_unsupported_world"
    for field in ["slot","receipt","last_return","battle"]:
        if not (w.get(field) is Dictionary):
            return "b3_invalid_"+field
    var phase := float(w.get("minute_phase",-1.0))
    if not is_finite(phase) or phase < 0.0 or phase >= 60.0 or fmod(phase,0.25) != 0.0:
        return "b3_invalid_clock_phase"
    var restored := restore(state)
    if not restored["ok"]:
        return "b3_invalid_battle_snapshot"
    var battle: MapBattleV2 = restored["battle"]
    if not battle.continuous_mode or not battle.active or battle.encounter_id != str(w.get("world_id","")) or not battle.encounter_id.begins_with("b3:vs1:"+B3PilotContent.ZONE+":"):
        return "b3_invalid_world_identity"
    var slot: Dictionary = w["slot"]
    var gen := int(slot.get("generation",0))
    var paid := int(slot.get("paid_generation",-1))
    if gen < 1 or paid < 0 or paid > gen or gen-paid > 1 or not is_finite(float(slot.get("due_at",-1.0))) or float(slot.get("due_at",-1.0)) < 0.0:
        return "b3_invalid_slot"
    var monster_id := str(B3PilotContent.monster(battle.encounter_id,gen)["id"])
    if not battle.actors.has(monster_id):
        return "b3_missing_slot_actor"
    var monster: Dictionary = battle.actors[monster_id]
    if str(monster.get("species_id","")) != B3PilotContent.SPECIES or int(monster.get("slot_generation",0)) != gen or str(monster.get("spawn_slot_id","")) != B3PilotContent.SLOT:
        return "b3_monster_identity_conflict"
    var receipt: Dictionary = w["receipt"]
    if not receipt.is_empty():
        var rg := int(receipt.get("generation",0))
        if rg < 1 or str(receipt.get("kill_id","")) != B3PilotContent.kill_id(battle.encounter_id,rg) or not ["PENDING","COMMITTED"].has(str(receipt.get("state",""))) or str(receipt.get("resource","")) != str(B3PilotContent.RESOURCE) or int(receipt.get("quantity",0)) != 1 or int(receipt.get("content_version",0)) != B3PilotContent.VERSION:
            return "b3_invalid_receipt"
        if (str(receipt["state"]) == "COMMITTED" and rg != paid) or (str(receipt["state"]) == "PENDING" and (rg != gen or paid != gen-1)):
            return "b3_receipt_watermark_conflict"
    elif paid != 0:
        return "b3_missing_committed_receipt"
    var dead := float(monster["hp"]) == 0.0
    var pending := battle.pending_kill_events()
    if not dead and not receipt.is_empty() and str(receipt["state"]) == "PENDING":
        return "b3_pending_without_hp0"
    if pending.size() > 1:
        return "b3_duplicate_domain_kill"
    if dead:
        if receipt.is_empty() or int(receipt["generation"]) != gen:
            return "b3_downed_without_receipt"
        if str(receipt["state"]) == "PENDING" and (pending.size() != 1 or float(slot["due_at"]) != 0.0):
            return "b3_pending_without_domain_kill"
        if str(receipt["state"]) == "COMMITTED" and (paid != gen or float(slot["due_at"]) != float(receipt["at_seconds"])+B3PilotContent.RESPAWN_SECONDS):
            return "b3_committed_deadline_conflict"
    elif not pending.is_empty() or paid != gen-1 or float(slot["due_at"]) != 0.0:
        return "b3_living_slot_receipt_conflict"
    for event in pending:
        if str(event.get("kill_id","")) != B3PilotContent.kill_id(battle.encounter_id,gen) or str(event.get("monster_instance_id","")) != monster_id or str(event.get("species_id","")) != B3PilotContent.SPECIES or str(event.get("spawn_slot_id","")) != B3PilotContent.SLOT or int(event.get("slot_generation",0)) != gen or str(event.get("world_id","")) != battle.encounter_id or not dead or float(event.get("actual_damage",0.0)) <= 0.0 or not is_finite(float(event.get("at_seconds",-1.0))) or float(event.get("at_seconds",-1.0)) < 0.0 or float(event["at_seconds"]) > battle.now or float(receipt.get("at_seconds",-1.0)) != float(event["at_seconds"]):
            return "b3_invalid_pending_domain_kill"
    var member := str(w.get("member",""))
    if battle.actors.size() != (1 if member.is_empty() else 2):
        return "b3_unowned_actor"
    if not member.is_empty():
        if not state.disciples.has(StringName(member)) or not battle.actors.has(member):
            return "b3_missing_member"
        var d: DiscipleState = state.disciples[StringName(member)]
        var actor: Dictionary = battle.actors[member]
        if not owns_reservation(state,d) or not DiscipleRealmProgressV2.progression_ready(d) or d.injury_level != 0 or float(actor["hp"]) <= 0.0 or d.region_id != StringName(B3PilotContent.ZONE) or d.current_action != &"HOLD":
            return "b3_member_reservation_conflict"
        if state.sect.v2_pve_active_runs.has(d.active_pve_encounter_id):
            return "b3_legacy_mode_collision"
        if absf(d.hp/d.max_hp-float(actor["hp"])/float(actor["max_hp"])) > 0.00000001:
            return "b3_live_hp_conflict"
        var buildings := BuildingSystem.new()
        if not d.work_cycle_state.is_empty() or not buildings.active_resource_timer_for_worker(state,d.id).is_empty() or buildings.disciple_has_active_spirit_plot(state,d.id) or buildings.disciple_has_active_timed_recipe(state,d.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,d):
            return "b3_member_occupation_conflict"
    for d in state.disciples.values():
        if d.active_pve_encounter_id == battle.encounter_id and not owns_reservation(state,d):
            return "b3_orphan_reservation"
    return ""
