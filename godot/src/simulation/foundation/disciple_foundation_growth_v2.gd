class_name DiscipleFoundationGrowthV2
extends RefCounted

# Paid, exactly-once Permanent Tiềm Lực growth using an EXISTING earned PvE
# resource. No material faucet or per-minute free stat gain is introduced.
# A discrete Linh Tủy stack is consumed from the canonical Sect Warehouse.
# These are explicit pilot costs, not another six-stat formula/authority.
const SOURCE_LINH_TUY := &"linh_tuy"
const MATERIALS_PER_POINT := 10
const MAX_POINTS_PER_REQUEST := 1000

static func preview(state: SimulationState, disciple_id: StringName, points: int = 1) -> Dictionary:
    if state == null or not state.sect.foundation_points_enabled or not state.sect.p3_7_resources_enabled:
        return {"ok":false,"reason":"foundation_or_warehouse_disabled"}
    if points < 1 or points > MAX_POINTS_PER_REQUEST:
        return {"ok":false,"reason":"invalid_point_count"}
    if not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"unknown_disciple"}
    var actor: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.owns_v2_progression(actor) or not DiscipleRealmProgressV2.progression_ready(actor):
        return {"ok":false,"reason":"v2_foundation_profile_not_ready"}
    var required := points * MATERIALS_PER_POINT
    var warehouse := WarehouseSystem.new()
    if not warehouse.can_consume(state,SOURCE_LINH_TUY,required):
        return {"ok":false,"reason":"insufficient_unreserved_linh_tuy"}
    var after_potential := actor.potential + float(points)
    if is_nan(after_potential) or is_inf(after_potential):
        return {"ok":false,"reason":"nonfinite_potential_growth"}
    var current := DiscipleRealmProgressV2.derive_stats(actor)
    if not bool(current.get("ok",false)):
        return {"ok":false,"reason":"invalid_current_core"}
    var realm_state: Dictionary = actor.v2_realm_progress
    var cultivation: Dictionary = realm_state["cultivation"]
    var body: Dictionary = realm_state["body"]
    var after := CombatStatsV2.derive(
        int(cultivation["realm"]),int(cultivation["floor"]),
        int(body["realm"]),int(body["floor"]),after_potential
    )
    if not bool(after.get("ok",false)):
        return {"ok":false,"reason":"invalid_projected_core"}
    return {
        "ok":true,"resource_id":str(SOURCE_LINH_TUY),
        "resource_amount":required,"dimension":"potential","points":points,
        "old_potential":actor.potential,"new_potential":after_potential,
        "before_core":current.get("core_breakdown",{}),
        "after_core":after.get("core_breakdown",{})
    }

static func commit(
    state: SimulationState, disciple_id: StringName,
    points: int, request_id: String
) -> Dictionary:
    if state == null or request_id.is_empty() or request_id.length() > 160:
        return {"ok":false,"reason":"invalid_growth_request"}
    var receipt_key := "potential:%s" % request_id
    if state.sect.foundation_growth_receipts.has(receipt_key):
        var prior = state.sect.foundation_growth_receipts[receipt_key]
        if not (prior is Dictionary) or str(prior.get("disciple_id","")) != str(disciple_id) or int(prior.get("points",0)) != points:
            return {"ok":false,"reason":"conflicting_growth_replay"}
        return {"ok":true,"already_settled":true,"receipt":prior.duplicate(true)}

    var prepared := preview(state,disciple_id,points)
    if not bool(prepared.get("ok",false)):
        return prepared
    var actor: DiscipleState = state.disciples[disciple_id]
    var old_potential := actor.potential
    var old_hp := actor.hp
    var old_max_hp := actor.max_hp
    var old_quality := actor.disciple_quality

    # Validate and derive the true Realm+Body core FIRST. No HP mint:
    # FoundationSystem preserves the previous live-HP ratio.
    if not FoundationSystem.new().add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,float(points)):
        return {"ok":false,"reason":"core_growth_rejected"}
    var warehouse := WarehouseSystem.new()
    if not warehouse.consume(state,SOURCE_LINH_TUY,int(prepared["resource_amount"])):
        actor.potential = old_potential
        actor.hp = old_hp
        actor.max_hp = old_max_hp
        actor.disciple_quality = old_quality
        return {"ok":false,"reason":"material_commit_failed"}

    var receipt := {
        "kind":"earned_material_foundation_growth",
        "request_id":request_id,"disciple_id":str(disciple_id),
        "dimension":"potential","points":points,
        "resource_id":str(SOURCE_LINH_TUY),
        "material_paid":int(prepared["resource_amount"]),
        "old_potential":old_potential,"new_potential":actor.potential,
        "tick":state.tick
    }
    state.sect.foundation_growth_receipts[receipt_key] = receipt
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true)}
