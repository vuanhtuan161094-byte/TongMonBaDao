class_name CultivationGateV57
extends RefCounted

# SX-04: one real Tu Vi major-gate transaction. No optional pill is needed:
# base=25%, pity +5pp/failure, -10% floor-10 XP on failure.
# Optional graded breakthrough pill adds +15/25/35/45 percentage points,
# and is debited from the canonical Warehouse exactly once per attempted gate.
const MAX_REQUEST_LENGTH := 160

static func preview(state: SimulationState, disciple_id: StringName, pill_id: StringName = &"") -> Dictionary:
    if state == null or not state.sect.v2_training_enabled or not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"gate_training_unavailable"}
    var d: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(d) or d.hp <= 0.0             or d.region_id != &"sect" or not d.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"gate_actor_unavailable"}
    if not [&"EVALUATE",&"IDLE",&"HOLD",&"CULTIVATE",&"BREAKTHROUGH"].has(d.current_action):
        return {"ok":false,"reason":"gate_actor_busy"}
    var p: Dictionary = d.v2_realm_progress["cultivation"]
    var realm := int(p["realm"])
    if realm >= 30 or int(p["floor"]) != 10:
        return {"ok":false,"reason":"gate_not_at_final_floor"}
    var need := float(DiscipleProgressionBalanceV2.floor_cost(realm,10))
    if need <= 0.0 or float(p["xp"]) + 0.0000001 < need:
        return {"ok":false,"reason":"gate_xp_incomplete"}
    var base_chance := DiscipleBreakthroughBalanceV2.cultivation_base_chance(realm)
    if base_chance != 0.25:
        return {"ok":false,"reason":"gate_rule_not_updated"}
    var prior := int(p.get("gate_failures",0))
    var chance_without := clampf(base_chance+0.05*float(prior),0.0,1.0)
    var bonus := 0
    var selected := pill_id
    if selected != &"" and chance_without < 1.0:
        if not state.sect.p3_7_resources_enabled:
            return {"ok":false,"reason":"gate_warehouse_unavailable"}
        var med := MedicineCatalogueV2.definition(selected)
        if str(med.get("pill_family","")) != MedicineCatalogueV2.FAMILY_BREAK                 or int(med.get("realm_rank",0)) != realm:
            return {"ok":false,"reason":"wrong_breakthrough_pill"}
        if not WarehouseSystem.new().can_consume(state,selected,1):
            return {"ok":false,"reason":"breakthrough_pill_unavailable"}
        bonus = int(med.get("potency",0))
        if not [15,25,35,45].has(bonus):
            return {"ok":false,"reason":"breakthrough_pill_bonus_invalid"}
    else:
        selected = &""
    return {"ok":true,"realm":realm,"floor":10,"xp_required":need,
        "chance_without_pill":chance_without,
        "chance":clampf(chance_without+float(bonus)/100.0,0.0,1.0),
        "bonus_pp":bonus,"pill_id":str(selected),"pity":prior}

static func attempt(state: SimulationState, disciple_id: StringName, request_id: String,
        pill_id: StringName = &"", external_rng: GameRng = null) -> Dictionary:
    if request_id.is_empty() or request_id.length() > MAX_REQUEST_LENGTH:
        return {"ok":false,"reason":"invalid_gate_request"}
    if state == null or not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"gate_actor_missing"}
    var d: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(d):
        return {"ok":false,"reason":"gate_actor_unavailable"}
    for entry in d.v2_realm_progress["cultivation"].get("breakthrough_history",[]):
        if str(entry.get("event_id","")) == request_id:
            return {"ok":false,"reason":"breakthrough_event_replayed"}
    var check := preview(state,disciple_id,pill_id)
    if not bool(check.get("ok",false)):
        return check
    var selected := StringName(check.get("pill_id",""))
    var old_profile := d.v2_realm_progress.duplicate(true)
    var old_hp := d.hp
    var old_max_hp := d.max_hp
    var rng := external_rng
    if rng == null:
        # The live scheduler already owns the canonical RNG stream. UI gate
        # clicks must NOT advance state.rng_state independently, or its next
        # step would overwrite it from a stale in-memory GameRng instance.
        # Derive a deterministic request-specific substream instead.
        var derived_seed := posmod(state.seed,2147483647)
        for index in range(request_id.length()):
            derived_seed = posmod(derived_seed*31+request_id.unicode_at(index),2147483647)
        rng = GameRng.new(derived_seed)
    var old_rng_state := rng.snapshot_seed_state()
    var result := DiscipleRealmProgressV2.attempt_canonical_cultivation_breakthrough(
        d,rng,true,request_id,int(check.get("bonus_pp",0))
    )
    if not bool(result.get("ok",false)):
        return result
    if selected != &"" and not WarehouseSystem.new().consume(state,selected,1):
        d.v2_realm_progress = old_profile
        d.hp = old_hp
        d.max_hp = old_max_hp
        rng.restore_seed_state(old_rng_state)
        return {"ok":false,"reason":"breakthrough_pill_debit_failed"}
    var p: Dictionary = d.v2_realm_progress["cultivation"]
    var history: Array = p.get("breakthrough_history",[])
    if not history.is_empty():
        var last: Dictionary = history[history.size()-1]
        last["pill_id"] = str(selected)
        last["pill_bonus_pp"] = int(check.get("bonus_pp",0))
        history[history.size()-1] = last
        p["breakthrough_history"] = history
    # External scheduler RNG advances normally; manual substreams never
    # mutate that independent canonical stream.
    result["pill_spent"] = str(selected)
    result["bonus_pp"] = int(check.get("bonus_pp",0))
    return result
