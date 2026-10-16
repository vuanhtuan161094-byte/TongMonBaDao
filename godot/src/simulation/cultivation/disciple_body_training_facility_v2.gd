class_name DiscipleBodyTrainingFacilityV2
extends RefCounted

# DV2-03/Rèn Thân Đường: one simulation minute of active paid body training.
# This is the sole economic/slot consumer for the locked body_training source.
# It does not mint resources, award passive Body EXP or change expedition stamina.
const STONE_COST_PER_MINUTE := 1
const BASE_BODY_XP_PER_MINUTE := 1500.0

# Explicit management assignment. A reservation is a normal work-group/worksite
# assignment and therefore persists through existing DiscipleState save/load.
# No standby waitlist or silent reassignment of more disciples than physical slots.
static func reserve_slot(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if state == null or not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"body_training_disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if disciple.region_id != &"sect" or disciple.hp <= 0.0 or not disciple.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"training_actor_not_available"}
    # Preflight before any reservation mutation; do not hijack ongoing combat,
    # paid crops, or a disciple already waiting at an unapproved major gate.
    if not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"body_training_authority_disabled"}
    if not [&"EVALUATE",&"IDLE",&"HOLD",&"CULTIVATE",&"TRAIN_BODY"].has(disciple.current_action):
        return {"ok":false,"reason":"training_cannot_interrupt_active_work"}
    # Do not steal a queued player command or an existing Forge/production
    # assignment. An explicit release is required before reserving Rèn Thân.
    # Already-reserved trainees remain idempotent.
    if not disciple.direct_command.is_empty():
        return {"ok":false,"reason":"body_training_active_command"}
    if disciple.work_group_id != &"" and disciple.work_group_id != &"body_training_crew":
        return {"ok":false,"reason":"body_training_another_worksite"}
    if disciple.worksite_building_id != &"":
        var held = state.buildings.get(str(disciple.worksite_building_id))
        if not (held is BuildingState) or held.building_type != BuildingSystem.TYPE_BODY_TRAINING:
            return {"ok":false,"reason":"body_training_another_worksite"}
    # GP-02B1: a reserved Body slot must not silently settle an unfinished
    # Mine/Forest carry-cycle or transfer a worker from a paid timed job.
    if not disciple.work_cycle_state.is_empty():
        return {"ok":false,"reason":"training_cannot_interrupt_active_work"}
    if BuildingSystem.new().disciple_has_active_timed_recipe(state,disciple.id):
        return {"ok":false,"reason":"busy_timed_recipe"}
    if state.sect.spirit_stones < STONE_COST_PER_MINUTE:
        return {"ok":false,"reason":"insufficient_training_spirit_stones"}
    var rule = state.sect.v2_training_rules.get("body",null)
    if not (rule is Dictionary) or str(rule.get("training_mechanic","")) != "typed_source_contract":
        return {"ok":false,"reason":"body_training_rule_not_authorized"}
    var body: Dictionary = disciple.v2_realm_progress["body"]
    var costs = rule.get("floor_costs",null)
    var key := "%d:%d" % [int(body["realm"]),int(body["floor"])]
    if not (costs is Dictionary) or not costs.has(key):
        return {"ok":false,"reason":"body_training_cost_curve_missing"}
    if int(body["floor"]) == DiscipleRealmProgressV2.MAX_FLOOR and float(body["xp"]) >= float(costs[key]):
        return {"ok":false,"reason":"major_gate_waiting"}
    # One active Spirit Field plot reserves its disciple until harvest resolves.
    if BuildingSystem.new().disciple_has_active_spirit_plot(state,disciple.id):
        return {"ok":false,"reason":"busy_spirit_plot"}
    var building := BuildingSystem.new().primary_building(
        state, BuildingSystem.TYPE_BODY_TRAINING
    )
    if building == null or building.status != BuildingSystem.STATUS_ACTIVE:
        return {"ok":false,"reason":"body_training_facility_unavailable"}
    var buildings := BuildingSystem.new()
    var already := buildings.active_worker_ids(state, building).has(disciple_id)
    if not already and buildings.assigned_worker_ids(state, building).size() >= buildings.worker_slots(building):
        return {"ok":false,"reason":"body_training_slots_full"}
    if not already:
        # Do not depend on WorkforceSystem here: its policy depends on the
        # training action, so keeping the facility independent avoids a parser
        # cycle. The same canonical disciple assignment fields own this slot.
        disciple.work_group_id = building.worker_group_id
        disciple.worksite_building_id = building.id
        state.sect.workforce_event_count += 1
    return {"ok":true,"building_id":str(building.id),"reserved_slots":buildings.assigned_worker_ids(state,building).size(),
        "slots":buildings.worker_slots(building)}

# Fast membership check for the canonical dedicated training reservation.
# This never treats a stale group-only assignment or a different building as a
# paid training slot; the actual building slot count is still authoritative.
static func has_reserved_slot(state: SimulationState, disciple: DiscipleState) -> bool:
    if state == null or disciple == null or not state.p3_7_buildings_enabled:
        return false
    var facility := BuildingSystem.new().primary_building(
        state,BuildingSystem.TYPE_BODY_TRAINING
    )
    if facility == null or disciple.work_group_id != facility.worker_group_id:
        return false
    if disciple.worksite_building_id != facility.id and disciple.worksite_building_id != &"":
        return false
    return BuildingSystem.new().active_worker_ids(state,facility).has(disciple.id)

# Manual release makes a paid facility slot available for another disciple.
# Cannot release another building/group or an outside/missing character.
# This never refunds a completed minute and never deducts Sect Spirit Stones.
static func release_slot(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if state == null or not state.disciples.has(disciple_id) or not state.p3_7_buildings_enabled:
        return {"ok":false,"reason":"body_training_disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    var facility := BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_BODY_TRAINING)
    if facility == null or not has_reserved_slot(state,disciple):
        return {"ok":false,"reason":"body_training_slot_not_reserved"}
    disciple.work_group_id = &""
    disciple.worksite_building_id = &""
    if disciple.current_action == &"TRAIN_BODY":
        disciple.current_action = &"EVALUATE"
    # User explicitly stopped this assignment. Manual mode prevents the AI
    # from immediately requeueing paid training without a new player action.
    if DiscipleRealmProgressV2.progression_ready(disciple):
        # Persist the already-authorized manual enum directly here. Importing
        # DiscipleTrainingPolicyV2 would create a GDScript compile-time cycle
        # (TrainingAction -> Facility -> TrainingPolicy -> TrainingAction).
        disciple.v2_realm_progress["training_policy"] = "manual"
    state.sect.workforce_event_count += 1
    return {"ok":true,"released_disciple_id":str(disciple_id),
        "building_id":str(facility.id)}

# Read-only eligibility and exact Body grant preflight. Never debit or grant.
static func preview_minute(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var prepared := _prepare(state, disciple)
    if not bool(prepared.get("ok",false)):
        return prepared
    # Read-only progress projection without a fabricated cost receipt.
    # Only commit_minute() may assert a committed economic transaction.
    var preview := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",BASE_BODY_XP_PER_MINUTE,"natural",
        prepared["floor_costs"],[],true
    )
    if not bool(preview.get("ok",false)):
        return preview
    return {"ok":true,"track":"body","action":"TRAIN_BODY",
        "building_id":str(prepared["building"].id),
        "cost_spirit_stones":STONE_COST_PER_MINUTE,
        "base_body_xp_per_minute":BASE_BODY_XP_PER_MINUTE,
        "gained":float(preview.get("gained",0.0))}

# Called once by SimulationScheduler for a real TRAIN_BODY simulation minute.
# Charge first, grant only after the debit, rollback if grant cannot commit.
static func commit_minute(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if disciple == null or disciple.current_action != &"TRAIN_BODY":
        return {"ok":false,"reason":"body_training_action_not_current"}
    var prepared := _prepare(state,disciple)
    if not bool(prepared.get("ok",false)):
        return prepared
    # One-source-per-minute accounting is verified before payment.
    if int(disciple.v2_realm_progress.get("last_body_xp_tick",-1)) == state.tick:
        return {"ok":false,"reason":"body_xp_tick_already_awarded"}
    if state.tick <= 0:
        return {"ok":false,"reason":"no_committed_simulation_tick"}
    var dry_run := preview_minute(state,disciple)
    if not bool(dry_run.get("ok",false)):
        return dry_run
    var source := _source(prepared,true)
    # Preview and commit share the same authoritative floor-cost/source law.
    if state.sect.spirit_stones < STONE_COST_PER_MINUTE:
        return {"ok":false,"reason":"insufficient_training_spirit_stones"}
    state.sect.spirit_stones -= STONE_COST_PER_MINUTE
    var event_id := "dv2:ren_than:%s:%d" % [str(disciple.id),state.tick]
    var result := DiscipleBodyXpSourceV2.commit_minute(
        state,disciple,source,event_id
    )
    if not bool(result.get("ok",false)):
        state.sect.spirit_stones += STONE_COST_PER_MINUTE
        return result
    var building: BuildingState = prepared["building"]
    building.production_state["paid_training_minutes"] = int(
        building.production_state.get("paid_training_minutes",0)
    ) + 1
    building.production_state["spent_spirit_stones"] = int(
        building.production_state.get("spent_spirit_stones",0)
    ) + STONE_COST_PER_MINUTE
    state.building_event_count += 1
    result["building_id"] = str(building.id)
    result["spent_spirit_stones"] = STONE_COST_PER_MINUTE
    return result

static func _prepare(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if state == null or disciple == null or not state.p3_7_buildings_enabled or not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"body_training_authority_disabled"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"body_training_disciple_not_owned"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if disciple.region_id != &"sect" or disciple.hp <= 0.0 or not disciple.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"training_actor_not_available"}
    var building_system := BuildingSystem.new()
    var building := building_system.primary_building(state,BuildingSystem.TYPE_BODY_TRAINING)
    if building == null or building.status != BuildingSystem.STATUS_ACTIVE:
        return {"ok":false,"reason":"body_training_facility_unavailable"}
    # Important for 1,000-3,000 disciple rosters: the typical non-trainee
    # fails in O(1), without sorting/scanning the entire roster for slot access.
    if disciple.work_group_id != building.worker_group_id or (
        disciple.worksite_building_id != &"" and disciple.worksite_building_id != building.id
    ):
        return {"ok":false,"reason":"body_training_slot_not_reserved"}
    if building_system.disciple_has_active_spirit_plot(state,disciple.id):
        return {"ok":false,"reason":"busy_spirit_plot"}
    if not building_system.can_disciple_work(state,building,disciple):
        return {"ok":false,"reason":"body_training_slot_not_reserved"}
    if state.sect.spirit_stones < STONE_COST_PER_MINUTE:
        return {"ok":false,"reason":"insufficient_training_spirit_stones"}
    var rules = state.sect.v2_training_rules.get("body",null)
    if not (rules is Dictionary) or str(rules.get("training_mechanic","")) != "typed_source_contract":
        return {"ok":false,"reason":"body_training_rule_not_authorized"}
    var costs = rules.get("floor_costs",null)
    if not (costs is Dictionary):
        return {"ok":false,"reason":"body_training_cost_curve_missing"}
    var profile: Dictionary = disciple.v2_realm_progress["body"]
    var key := "%d:%d" % [int(profile["realm"]),int(profile["floor"])]
    if not costs.has(key):
        return {"ok":false,"reason":"body_training_cost_curve_missing"}
    if int(profile["floor"]) == DiscipleRealmProgressV2.MAX_FLOOR and float(profile["xp"]) >= float(costs[key]):
        return {"ok":false,"reason":"major_gate_waiting"}
    return {"ok":true,"building":building,"floor_costs":costs}

static func _source(prepared: Dictionary, paid: bool) -> Dictionary:
    var building: BuildingState = prepared["building"]
    return {
        "source_id":"ren_than_duong:%s" % str(building.id),
        "source_kind":DiscipleBodyXpSourceV2.SOURCE_BODY_TRAINING,
        "base_body_xp_per_minute":BASE_BODY_XP_PER_MINUTE,
        "floor_costs":prepared["floor_costs"],
        "modifiers":[],
        "training_access_verified":true,
        "training_cost_committed":paid
    }
