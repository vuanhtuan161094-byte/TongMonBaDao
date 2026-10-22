class_name B3PillSatietyV1
extends RefCounted

# Owner-approved CARE pilot. One shared counter, one canonical scheduler day.
const VERSION := 1
const CAPACITY := 1000000
const DAY_TICKS := 1440
const COSTS := {"hoi_xuan_dan":10,"tu_khi_dan":25}
const TUVI := 10000.0
const MAX_SEQUENCE := 9007199254740991

static func enable(state: SimulationState, d: DiscipleState) -> Dictionary:
    if d == null or state.disciples.get(d.id) != d or not DiscipleRealmProgressV2.progression_ready(d):
        return {"ok":false,"reason":"care_requires_owned_v2_disciple"}
    if d.b3_pill_state.is_empty():
        d.b3_pill_state = {"version":VERSION,"capacity":CAPACITY,
            "day":int(state.tick/DAY_TICKS),"spent":0,"sequence":0,"receipt":{}}
    var error := validate(state,d)
    return {"ok":error.is_empty(),"reason":error}

static func spent_today(state: SimulationState, d: DiscipleState) -> int:
    return int(d.b3_pill_state.get("spent",0)) if int(d.b3_pill_state.get("day",-1)) == int(state.tick/DAY_TICKS) else 0

static func next_sequence(d: DiscipleState) -> int:
    return int(d.b3_pill_state.get("sequence",0))+1

static func consume(state: SimulationState, d: DiscipleState, pill: StringName, sequence: int) -> Dictionary:
    if d == null or state.disciples.get(d.id) != d or d.b3_pill_state.is_empty():
        return {"ok":false,"reason":"pill_satiety_not_enabled"}
    var error := validate(state,d)
    if not error.is_empty(): return {"ok":false,"reason":error}
    var p := d.b3_pill_state
    var last := int(p["sequence"])
    if sequence <= last:
        var receipt: Dictionary = p["receipt"]
        if sequence == last and str(receipt.get("pill","")) == str(pill):
            return {"ok":true,"replay":true,"receipt":receipt.duplicate(true)}
        return {"ok":false,"reason":"duplicate_or_conflicting_pill_request"}
    if sequence != last+1 or sequence > MAX_SEQUENCE or not COSTS.has(str(pill)):
        return {"ok":false,"reason":"invalid_pill_sequence_or_content"}
    if B3MedicalAutoplayV1.busy(state,d) or not state.sect.p3_7_resources_enabled:
        return {"ok":false,"reason":"pill_actor_busy"}
    var cost := int(COSTS[str(pill)])
    var spent := spent_today(state,d)
    if cost > CAPACITY-spent:
        return {"ok":false,"reason":"daily_pill_satiety_full"}
    var warehouse := WarehouseSystem.new()
    if not warehouse.can_consume(state,pill,1):
        return {"ok":false,"reason":"pill_out_of_stock_or_reserved"}
    var hp_before := d.hp
    var injury_before := d.injury_level
    var recovery_before := d.injury_recover_at_tick
    var xp_result: Dictionary = {}
    var prepared: DiscipleState
    if pill == &"hoi_xuan_dan":
        if not state.sect.needs_enabled or d.hp >= d.max_hp:
            return {"ok":false,"reason":"healing_pill_not_needed"}
        if not NeedsSystem.new()._use_healing_pill_unmetered(state,d):
            return {"ok":false,"reason":"healing_pill_commit_failed"}
    else:
        if not state.sect.v2_training_enabled:
            return {"ok":false,"reason":"pill_training_not_enabled"}
        # Prepare the complete canonical effect before the irreversible debit.
        # Fixed gain bypasses aptitude multipliers and cannot cross a major gate.
        prepared = DiscipleState.from_dict(d.to_dict())
        var costs: Dictionary = state.sect.v2_training_rules.get("cultivation",{}).get("floor_costs",{})
        xp_result = DiscipleRealmProgressV2.grant_xp(prepared,"cultivation",TUVI,"fixed",costs,
            [{"source_id":"b3/pill/tu_khi_dan","channel":"cultivation_xp_gain","mode":"percent_add","value":0.0}])
        if not xp_result.get("ok",false) or float(xp_result.get("unapplied_overflow",0.0)) > 0.0:
            return {"ok":false,"reason":"pill_xp_gate_or_content_blocked"}
        if not warehouse.consume(state,pill,1):
            return {"ok":false,"reason":"pill_debit_failed"}
        d.v2_realm_progress = prepared.v2_realm_progress.duplicate(true)
        d.v2_realm_progress["cultivation"]["last_training_event_id"] = "b3:pill:%s:%d" % [d.id,sequence]
        d.max_hp = prepared.max_hp
        d.hp = prepared.hp
    p["day"] = int(state.tick/DAY_TICKS)
    p["spent"] = spent+cost
    p["sequence"] = sequence
    p["receipt"] = {"sequence":sequence,"pill":str(pill),"state":"COMMITTED",
        "day":p["day"],"tick":state.tick,"cost":cost,"spent_after":p["spent"],
        "hp_delta":d.hp-hp_before,"tuvi":TUVI if pill == &"tu_khi_dan" else 0.0,
        "injury":injury_before,"recover_tick":recovery_before}
    return {"ok":true,"replay":false,"receipt":p["receipt"].duplicate(true)}

static func whole(value: Variant) -> bool:
    return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

static func validate(state: SimulationState, d: DiscipleState) -> String:
    var p := d.b3_pill_state
    if p.is_empty(): return ""
    if not DiscipleRealmProgressV2.progression_ready(d): return "satiety_without_v2_owner"
    for field in ["version","capacity","day","spent","sequence"]:
        if not whole(p.get(field)): return "invalid_satiety_"+field
    if int(p["version"]) != VERSION or int(p["capacity"]) != CAPACITY: return "unsupported_satiety_pilot"
    if int(p["day"]) < 0 or int(p["day"]) > int(state.tick/DAY_TICKS) or int(p["spent"]) < 0 or int(p["spent"]) > CAPACITY: return "invalid_satiety_day_or_spent"
    if int(p["sequence"]) < 0 or int(p["sequence"]) > MAX_SEQUENCE or not (p.get("receipt") is Dictionary): return "invalid_satiety_receipt_shape"
    var receipt: Dictionary = p["receipt"]
    if int(p["sequence"]) == 0:
        return "" if receipt.is_empty() and int(p["spent"]) == 0 else "satiety_missing_sequence"
    var pill := str(receipt.get("pill",""))
    if not COSTS.has(pill): return "unknown_satiety_pill"
    for field in ["sequence","day","tick","cost","spent_after","injury","recover_tick"]:
        if not whole(receipt.get(field)): return "invalid_pill_receipt_"+field
    if str(receipt.get("state","")) != "COMMITTED" or int(receipt["sequence"]) != int(p["sequence"]) or int(receipt["day"]) != int(p["day"]) or int(receipt["tick"]) < 0 or int(receipt["tick"]) > state.tick or int(int(receipt["tick"])/DAY_TICKS) != int(p["day"]) or int(receipt["cost"]) != int(COSTS[pill]) or int(receipt["spent_after"]) != int(p["spent"]) or int(p["spent"]) < int(receipt["cost"]): return "pill_receipt_counter_conflict"
    if not (receipt.get("hp_delta") is int or receipt.get("hp_delta") is float) or not (receipt.get("tuvi") is int or receipt.get("tuvi") is float): return "invalid_pill_effect_shape"
    var hp := float(receipt["hp_delta"])
    var xp := float(receipt["tuvi"])
    if not is_finite(hp) or not is_finite(xp) or hp < -0.0000001: return "invalid_pill_effect"
    if (pill == "hoi_xuan_dan" and (hp <= 0.0 or hp > NeedsSystem.HEALING_PILL_HP or xp != 0.0)) or (pill == "tu_khi_dan" and xp != TUVI): return "pill_effect_conflict"
    if not [0,1].has(int(receipt["injury"])) or int(receipt["recover_tick"]) < 0: return "pill_injury_receipt_conflict"
    return ""
