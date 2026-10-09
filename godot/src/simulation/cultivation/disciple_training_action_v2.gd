class_name DiscipleTrainingActionV2
extends RefCounted

# DV2-03 action bridge. Rates are normalized per simulation minute.
# Tu Vi itself is passive-time owned; CULTIVATE only selects Chuyên Tu.
# TRAIN_BODY remains an explicit one-minute body-training action.
const ACTION_TRACKS := {"CULTIVATE":"cultivation","TRAIN_BODY":"body"}

# Validate the same real EXP operation without changing a floor, XP or action.
# This rejects bad authored inputs before a player command can be accepted.
static func _validated_rule(disciple: DiscipleState, track: String, data: Variant) -> Dictionary:
    if track == "cultivation":
        return DiscipleTuViFlowV2.validate_rule(disciple,data)
    if track != "body" or not (data is Dictionary):
        return {"ok":false,"reason":"missing_authored_training_rules"}
    var rule: Dictionary = data
    if str(rule.get("action","")) != "TRAIN_BODY" or str(rule.get("authority_id","")).is_empty():
        return {"ok":false,"reason":"invalid_training_rule_authority"}
    var raw_rate = rule.get("base_body_xp_per_minute",null)
    if not (raw_rate is float or raw_rate is int):
        return {"ok":false,"reason":"missing_training_base_rate"}
    var rate := float(raw_rate)
    if is_nan(rate) or is_inf(rate) or rate <= 0.0:
        return {"ok":false,"reason":"invalid_training_base_rate"}
    var costs = rule.get("floor_costs",null)
    if not (costs is Dictionary):
        return {"ok":false,"reason":"missing_authored_floor_costs"}
    var sources = rule.get("sources",[])
    if not (sources is Array):
        return {"ok":false,"reason":"invalid_training_source_list"}
    var preview := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",rate,"natural",costs,sources,true
    )
    if not bool(preview.get("ok",false)):
        return {"ok":false,"reason":str(preview.get("reason","invalid_training_preview"))}
    return {"ok":true,"rate":rate,"costs":costs,"sources":sources}

# Read-only eligibility/ratio surface shared by autonomous policy and UI.
# It uses the same authored rule validation as the eventual committed action.
static func preview_training(state: SimulationState, disciple: DiscipleState, track: String) -> Dictionary:
    if state == null or disciple == null or not state.sect.v2_training_enabled or not DiscipleRealmProgressV2.TRACKS.has(track):
        return {"ok":false,"reason":"invalid_or_disabled_training_preview"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"training_actor_not_owned_by_state"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_disciple_not_present"}
    var ready := _validated_rule(disciple,track,state.sect.v2_training_rules.get(track,null))
    if not bool(ready.get("ok",false)):
        return {"ok":false,"reason":str(ready.get("reason","invalid_training_rule"))}
    var row: Dictionary = disciple.v2_realm_progress[track]
    var key := "%d:%d" % [int(row["realm"]),int(row["floor"])]
    var costs: Dictionary = ready["costs"]
    if not costs.has(key):
        return {"ok":false,"reason":"xp_cost_content_not_authorized"}
    var current_cost := float(costs[key])
    var current_xp := float(row["xp"])
    if int(row["floor"]) == DiscipleRealmProgressV2.MAX_FLOOR and current_xp+0.0000001 >= current_cost:
        return {
            "ok":false,"reason":"major_gate_waiting",
            "track":track,"current_xp":current_xp,"current_cost":current_cost,
            "progress_ratio":1.0
        }
    return {
        "ok":true,"track":track,
        "action":"CULTIVATE" if track=="cultivation" else "TRAIN_BODY",
        "current_xp":current_xp,"current_cost":current_cost,
        "progress_ratio":clampf(current_xp/current_cost,0.0,1.0),
        "global_floor":DiscipleRealmProgressV2.global_floor(int(row["realm"]),int(row["floor"]))
    }

# One real player-facing command boundary, with NO immediate reward.
# The simulation scheduler still owns the actual elapsed-minute result. This does not
# add a second timer or let commands interrupt hunting/combat/urgent healing.
static func request_training(state: SimulationState, disciple_id: StringName, track: String) -> Dictionary:
    if state == null or not state.sect.v2_training_enabled or not DiscipleRealmProgressV2.TRACKS.has(track):
        return {"ok":false,"reason":"invalid_or_disabled_training_request"}
    if not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"unknown_training_disciple"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_disciple_not_present"}
    if not [&"EVALUATE",&"IDLE",&"HOLD",&"CULTIVATE",&"TRAIN_BODY"].has(disciple.current_action):
        return {"ok":false,"reason":"training_cannot_interrupt_active_work"}
    var action := "CULTIVATE" if track == "cultivation" else "TRAIN_BODY"
    var ready := _validated_rule(disciple,track,state.sect.v2_training_rules.get(track,null))
    if not bool(ready.get("ok",false)):
        return {"ok":false,"reason":str(ready.get("reason","invalid_training_rule"))}
    disciple.current_action = StringName(action)
    return {"ok":true,"track":track,"queued_action":action}

static func resolve(state: SimulationState, disciple: DiscipleState, action: String) -> Dictionary:
    if state == null or disciple == null or not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"v2_training_not_enabled"}
    if not ACTION_TRACKS.has(action):
        return {"ok":false,"reason":"unsupported_training_action"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"training_actor_not_owned_by_state"}
    if disciple.current_action != StringName(action):
        return {"ok":false,"reason":"training_action_not_current"}
    if state.tick <= 0:
        return {"ok":false,"reason":"no_committed_simulation_tick"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"v2_disciple_not_initialized"}
    # Cultivation and body training occur at the sect in this first bridge.
    # No expedition stamina / HP drain is invented for Body training.
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_actor_not_available"}
    var track: String = ACTION_TRACKS[action]
    if track == "cultivation":
        return {"ok":false,"reason":"cultivation_resolves_via_passive_time"}
    var ready := _validated_rule(disciple,track,state.sect.v2_training_rules.get(track,null))
    if not bool(ready.get("ok",false)):
        return {"ok":false,"reason":str(ready.get("reason","invalid_training_rule"))}
    var rate: float = ready["rate"]
    var costs: Dictionary = ready["costs"]
    var source_values: Array = ready["sources"]
    if int(disciple.v2_realm_progress.get("last_training_tick",-1)) == state.tick:
        return {"ok":false,"reason":"training_tick_already_awarded"}
    var row: Dictionary = disciple.v2_realm_progress[track]
    var event_id := "%d:%s:%s" % [state.tick,str(disciple.id),action]
    if str(row.get("last_training_event_id","")) == event_id:
        return {"ok":false,"reason":"training_event_already_awarded"}
    var gain := DiscipleRealmProgressV2.grant_xp(
        disciple,track,rate,"natural",costs,source_values
    )
    if not bool(gain.get("ok",false)):
        return gain
    disciple.v2_realm_progress[track]["last_training_event_id"] = event_id
    disciple.v2_realm_progress["last_training_tick"] = state.tick
    return {
        "ok":true,"event_id":event_id,
        "track":track,"action":action,"tick":state.tick,
        "base_body_xp_per_minute":rate,"gained":gain["gained"],
        "realm":gain["realm"],"floor":gain["floor"],
        "floors_earned":gain["floors_earned"],
        "xp":gain["xp"],"at_major_gate":gain["at_major_gate"],
        "unapplied_overflow":gain["unapplied_overflow"]
    }
