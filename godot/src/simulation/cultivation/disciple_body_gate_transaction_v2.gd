class_name DiscipleBodyGateTransactionV2
extends RefCounted

# DV2-03F/F2 ONLY: atomic one-owner Body gate warehouse+disciple commit.
# Current F1 content is NOT playable. The default production authority denies
# every gate until F3 supplies real, verified source availability.
# Input is actor ID + opaque request ID ONLY; no caller costs or "verified" flag.
const RECEIPT_VERSION := 1
const MAX_REQUEST_ID_LENGTH := 128

var warehouse := WarehouseSystem.new()

func _content_ready(_state: SimulationState, recipe: Dictionary) -> bool:
    # F2 must not create an authorization shortcut. F3 will connect real,
    # already-earned material source availability here when separately approved.
    return bool(recipe.get("content_available", false))

func _after_debit(_state: SimulationState, _disciple: DiscipleState) -> bool:
    # No production failure injection; F2 tests override to exercise rollback.
    return true

func _gate_key(disciple_id: StringName, source_realm: int) -> String:
    return "%s:%d" % [str(disciple_id), source_realm]

func _requirements(recipe: Dictionary) -> Dictionary:
    var bundle := {
        str(recipe["main_id"]): int(recipe["main_qty"]),
        str(recipe["aux_id"]): int(recipe["aux_qty"])
    }
    if int(recipe["seal_qty"]) > 0:
        bundle[str(recipe["seal_id"])] = int(recipe["seal_qty"])
    return bundle

func preview_gate(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if state == null or state.sect == null or not state.sect.p3_7_resources_enabled:
        return {"ok":false,"reason":"body_gate_warehouse_unavailable"}
    if not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"body_gate_disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"body_gate_v2_disciple_not_ready"}
    if disciple.hp <= 0.0 or disciple.region_id != &"sect":
        return {"ok":false,"reason":"body_gate_disciple_unavailable"}
    if not [&"EVALUATE", &"HOLD", &"IDLE", &"CULTIVATE", &"TRAIN_BODY"].has(disciple.current_action):
        return {"ok":false,"reason":"body_gate_disciple_busy"}
    var body: Dictionary = disciple.v2_realm_progress["body"]
    var source_realm := int(body["realm"])
    var recipe := DiscipleBodyGateContentV2.recipe(source_realm)
    if recipe.is_empty():
        return {"ok":false,"reason":"body_gate_last_realm"}
    var gate_key := _gate_key(disciple_id,source_realm)
    if state.sect.v2_body_gate_receipts.has(gate_key):
        return {"ok":false,"reason":"body_gate_already_committed"}
    var xp_required := float(DiscipleProgressionBalanceV2.floor_cost(source_realm,10))
    if xp_required <= 0.0:
        return {"ok":false,"reason":"body_gate_cost_unavailable"}
    var requirements: Array = []
    var bundle := _requirements(recipe)
    var resource_ids: Array = bundle.keys()
    resource_ids.sort()
    var lack := false
    var protected := false
    for raw_id in resource_ids:
        var item_id := StringName(raw_id)
        var total := warehouse.quantity(state,item_id)
        var available := warehouse.available_quantity(state,item_id)
        var rule := warehouse.rule(state,item_id)
        var need := int(bundle[raw_id])
        requirements.append({
            "item_id":str(item_id),"need":need,"total":total,
            "available":available,
            "locked":bool(rule["locked"]),
            "reserve_min":int(rule["reserve_min"])
        })
        if total < need:
            lack = true
        elif available < need:
            protected = true
    # Precedence is explicit and read-only. Even ample QA-seeded stock cannot
    # make an unavailable F1 recipe playable through this public preview.
    var reason := ""
    if not _content_ready(state,recipe):
        reason = "content_unavailable"
    elif int(body["floor"]) != 10:
        reason = "body_major_gate_not_ready"
    elif float(body["xp"]) + 0.0000001 < xp_required:
        reason = "body_gate_xp_incomplete"
    elif lack:
        reason = "body_gate_material_missing"
    elif protected:
        reason = "body_gate_material_locked_or_reserved"
    return {
        "ok":true,"can_commit":reason.is_empty(),"reason":reason,
        "version":int(recipe["version"]),"source_realm":source_realm,
        "target_realm":source_realm+1,
        "xp_have":float(body["xp"]),"xp_need":xp_required,
        "requirements":requirements, "content_available":reason != "content_unavailable" and _content_ready(state,recipe)
    }

func commit_gate(state: SimulationState, disciple_id: StringName, request_id: String) -> Dictionary:
    if state == null or state.sect == null or request_id.is_empty() or request_id.length() > MAX_REQUEST_ID_LENGTH:
        return {"ok":false,"reason":"invalid_body_gate_request"}
    if not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"body_gate_disciple_missing"}
    # Stable retry verdict before current-realm evaluation: after a successful
    # commit the actor already moved to another realm. A reused request ID for
    # another actor/realm is rejected, never treated as a new claim.
    var existing_key := str(state.sect.v2_body_gate_request_index.get(request_id,""))
    if not existing_key.is_empty():
        var saved: Dictionary = state.sect.v2_body_gate_receipts.get(existing_key,{})
        if str(saved.get("disciple_id","")) != str(disciple_id):
            return {"ok":false,"reason":"body_gate_request_id_conflict"}
        return {"ok":false,"reason":"body_gate_already_committed",
            "receipt":saved.duplicate(true)}
    var preview := preview_gate(state,disciple_id)
    if not bool(preview.get("ok",false)) or not bool(preview.get("can_commit",false)):
        return {"ok":false,"reason":str(preview.get("reason","body_gate_denied"))}
    var source_realm := int(preview["source_realm"])
    var key := _gate_key(disciple_id,source_realm)
    if state.sect.v2_body_gate_receipts.has(key):
        return {"ok":false,"reason":"body_gate_already_committed"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    var recipe := DiscipleBodyGateContentV2.recipe(source_realm)
    var bundle := _requirements(recipe)
    # Recheck the canonical owner before ANY mutation. Never ignore locked or
    # reserve_min. Bundle consumes as one WarehouseSystem mutation.
    if not warehouse.can_consume_requirements(state,bundle):
        return {"ok":false,"reason":"body_gate_material_unavailable"}
    var old_resources := state.sect.warehouse_resources.duplicate(true)
    var old_warehouse_events := state.sect.warehouse_event_count
    var old_progress := disciple.v2_realm_progress.duplicate(true)
    var old_hp := disciple.hp
    var old_max_hp := disciple.max_hp
    if not warehouse.consume_requirements(state,bundle):
        return {"ok":false,"reason":"body_gate_warehouse_debit_failed"}
    var advance: Dictionary = {"ok":false,"reason":"body_gate_fault_after_debit"}
    if _after_debit(state,disciple):
        advance = DiscipleRealmProgressV2.commit_canonical_body_gate(
            disciple,true,"dv2:body-gate:%s" % key
        )
    if not bool(advance.get("ok",false)):
        # Single-threaded sim transaction rollback: no partial item cost,
        # no HP/progress corruption and no receipt on failed gate advance.
        state.sect.warehouse_resources = old_resources
        state.sect.warehouse_event_count = old_warehouse_events
        disciple.v2_realm_progress = old_progress
        disciple.hp = old_hp
        disciple.max_hp = old_max_hp
        return {"ok":false,"reason":str(advance.get("reason","body_gate_advance_failed"))}
    var receipt := {
        "version":RECEIPT_VERSION,"request_id":request_id,
        "disciple_id":str(disciple_id),
        "source_realm":source_realm,"target_realm":source_realm+1
    }
    state.sect.v2_body_gate_receipts[key] = receipt.duplicate(true)
    state.sect.v2_body_gate_request_index[request_id] = key
    return {"ok":true,"reason":"committed","receipt":receipt,
        "realm":int(advance["realm"]),"floor":int(advance["floor"]),
        "spent":bundle.duplicate(true)}
