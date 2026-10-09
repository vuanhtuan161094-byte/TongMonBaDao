class_name DiscipleTrainingActionV2
extends RefCounted

# DV2-03 action bridge. Rates are normalized per simulation minute.
# Tu Vi itself is passive-time owned; CULTIVATE only selects Chuyên Tu.
# Luyện Thể source contract is locked, but its real facility/cost consumer is not ready yet. TRAIN_BODY is retained
# only as a fail-closed compatibility token and must not grant Body EXP.
const ACTION_TRACKS := {"CULTIVATE":"cultivation","TRAIN_BODY":"body"}

# Validate the same real EXP operation without changing a floor, XP or action.
# This rejects bad authored inputs before a player command can be accepted.
static func _validated_rule(disciple: DiscipleState, track: String, data: Variant) -> Dictionary:
    if track == "cultivation":
        return DiscipleTuViFlowV2.validate_rule(disciple,data)
    if track == "body":
        return {"ok":false,"reason":"body_training_consumer_not_ready"}
    return {"ok":false,"reason":"unsupported_training_track"}

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
    if track == "body":
        return {"ok":false,"reason":"body_training_consumer_not_ready"}
    var action := "CULTIVATE"
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
    return {"ok":false,"reason":"body_training_consumer_not_ready"}
