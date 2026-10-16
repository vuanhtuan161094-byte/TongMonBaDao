class_name FoundationGrowthV2
extends RefCounted

# One earned-material consumer for permanent Tiềm Lực. The only source is
# canonical Tử Vân Thảo grown in a Lv30+ Field; never mint free foundation
# points on idle ticks or from a second inventory.
#
# This pilot is intentionally limited to ONE point per completed transaction.
# Other Lục Duy routes require their own authored earned recipes, not a
# generic / arbitrary item-to-stat exchange.
const RECEIPT_VERSION := 1
const RESOURCE_ID := &"tu_van_thao"
const RESOURCE_QUANTITY := 1000
const POINT_GAIN := 1.0
const MAX_REQUEST_ID_LENGTH := 128

var warehouse := WarehouseSystem.new()
var foundation := FoundationSystem.new()
var buildings := BuildingSystem.new()

func preview(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if state == null or state.sect == null or not state.sect.p3_7_resources_enabled:
        return {"ok":false,"reason":"foundation_warehouse_unavailable"}
    if not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"foundation_unknown_disciple"}
    var actor: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(actor):
        return {"ok":false,"reason":"foundation_v2_profile_required"}
    if actor.foundation_model_version < FoundationSystem.MODEL_OPEN_POINTS:
        return {"ok":false,"reason":"foundation_open_points_required"}
    if actor.hp <= 0.0 or actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"foundation_actor_unavailable"}
    if not [&"IDLE",&"EVALUATE",&"HOLD"].has(actor.current_action):
        return {"ok":false,"reason":"foundation_active_action"}
    if (
        not actor.work_cycle_state.is_empty()
        or buildings.disciple_has_active_spirit_plot(state,actor.id)
        or buildings.disciple_has_active_timed_recipe(state,actor.id)
        or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor)
    ):
        return {"ok":false,"reason":"foundation_reserved_occupation"}
    if not warehouse.can_consume(state,RESOURCE_ID,RESOURCE_QUANTITY):
        return {"ok":false,"reason":"foundation_material_locked_or_missing",
            "available":warehouse.available_quantity(state,RESOURCE_ID),
            "required":RESOURCE_QUANTITY}
    return {"ok":true,"resource_id":str(RESOURCE_ID),"quantity":RESOURCE_QUANTITY,
        "dimension":str(FoundationSystem.DIM_POTENTIAL),"points":POINT_GAIN}

func commit(state: SimulationState, disciple_id: StringName, request_id: String) -> Dictionary:
    if state == null or state.sect == null or request_id.is_empty() or request_id.length() > MAX_REQUEST_ID_LENGTH:
        return {"ok":false,"reason":"foundation_invalid_request"}
    # Check before eligibility or costs: retry cannot spend twice after
    # stock drops or actor starts a different job.
    if state.sect.v2_foundation_growth_receipts.has(request_id):
        var previous = state.sect.v2_foundation_growth_receipts[request_id]
        if not (previous is Dictionary) or str(previous.get("disciple_id","")) != str(disciple_id):
            return {"ok":false,"reason":"foundation_request_id_conflict"}
        return {"ok":true,"already_settled":true,"receipt":previous.duplicate(true)}
    var ready := preview(state,disciple_id)
    if not bool(ready.get("ok",false)):
        return ready
    var actor: DiscipleState = state.disciples[disciple_id]
    var old_stock := state.sect.warehouse_resources.duplicate(true)
    var old_events := state.sect.warehouse_event_count
    var old_hp := actor.hp
    var old_max_hp := actor.max_hp
    var old_potential := actor.potential
    var old_quality := actor.disciple_quality
    var old_birth := actor.foundation_birth_values.duplicate(true)
    if not warehouse.consume(state,RESOURCE_ID,RESOURCE_QUANTITY):
        return {"ok":false,"reason":"foundation_material_debit_failed"}
    if not foundation.add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,POINT_GAIN):
        state.sect.warehouse_resources = old_stock
        state.sect.warehouse_event_count = old_events
        actor.hp = old_hp
        actor.max_hp = old_max_hp
        actor.potential = old_potential
        actor.disciple_quality = old_quality
        return {"ok":false,"reason":"foundation_growth_commit_failed"}
    # Immutable birth provenance cannot be rewritten by earned growth.
    if actor.foundation_birth_values != old_birth:
        state.sect.warehouse_resources = old_stock
        state.sect.warehouse_event_count = old_events
        actor.hp = old_hp
        actor.max_hp = old_max_hp
        actor.potential = old_potential
        actor.disciple_quality = old_quality
        actor.foundation_birth_values = old_birth
        return {"ok":false,"reason":"foundation_birth_history_modified"}
    var receipt := {
        "version":RECEIPT_VERSION,"request_id":request_id,
        "disciple_id":str(disciple_id),"resource_id":str(RESOURCE_ID),
        "spent":RESOURCE_QUANTITY,"points":POINT_GAIN,
        "dimension":str(FoundationSystem.DIM_POTENTIAL),
        "potential_after":actor.potential,"tick":state.tick
    }
    state.sect.v2_foundation_growth_receipts[request_id] = receipt.duplicate(true)
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true)}
